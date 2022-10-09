-------------------------------------------------------------------------------
--
-- File: DPHY_LaneSCNN.vhd
-- Author: Elod Gyorgy
-- Original Project: MIPI D-PHY Receiver IP
-- Date: 15 December 2017
--
-------------------------------------------------------------------------------
--MIT License
--
--Copyright (c) 2016 Digilent
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- Purpose:
-- This module implements a MIPI D-PHY 1.0 CIL-SCNN lane: slave (receiver) clock.
-- It is architecture-independent by itself, but the instantiated HS-Clocking has
-- its own requirements. The D-PHY physical interface is assumed to be de-multiplexed
-- into low-power LP(1:0) and high-speed HS inputs by external circuitry (outside
-- the FPGA). On the logic side data is forwarded via the PPI interface as
-- described in the D-PHY spec Annex A.
-------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;

use work.DebugLib.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DPHY_LaneSCNN is
   Generic (
      kGenerateMMCM : boolean := false;
      kRefClkFreqHz : natural := 200_000_000;
      kAddDelay_ps : integer := 0
   );
   Port (
      aLP : in STD_LOGIC_VECTOR (1 downto 0);
      aHS : in STD_LOGIC;
      RefClk : in STD_LOGIC; --200MHz
      
      RxDDRClkHS : out STD_LOGIC;
      RxByteClkHS : out STD_LOGIC;
      aRxClkActiveHS : out STD_LOGIC;
      aForceRxmode : in STD_LOGIC;
      aStopstate : out STD_LOGIC;
      aEnable : in STD_LOGIC;
      
      aRxUlpsClkNot : out std_logic; --Receive Ultra-Low Power State on Clock Lane.
      aUlpsActiveNot : out std_logic; --ULP State (not) Active.
      
      debug : out DebugSCNN_Type
   );
end DPHY_LaneSCNN;

architecture Behavioral of DPHY_LaneSCNN is

function MAX(LEFT, RIGHT: INTEGER) return INTEGER is
begin
  if LEFT > RIGHT then return LEFT;
  else return RIGHT;
    end if;
  end;
  
type state_type is (stInit, stStop, stHS_Prpr, stHS_Term, stHS_Clk, stHS_End, stULPS, stULPS_Exit, stULPS_Rqst); 
signal state, nstate : state_type := stInit; 

attribute fsm_encoding : string;
attribute fsm_encoding of state : signal is "one_hot";

signal cLP, cLPGlitch : std_logic_vector(1 downto 0);
signal cIntRst : std_logic;

attribute DONT_TOUCH : string;
attribute DONT_TOUCH of cLP: signal is "TRUE";

alias CtlClk : std_logic is RefClk;
alias kCtlClkFreqHz : natural is kRefClkFreqHz;

constant kTInit      : natural := natural(ceil(100.0 / 10.0**6 * real(kCtlClkFreqHz))); --100us
constant kTClkTermEn : natural := natural(ceil(38.0 / 10.0**9 * real(kCtlClkFreqHz))); --38ns
constant kTClkSettle : natural := natural(ceil(95.0 / 10.0**9 * real(kCtlClkFreqHz))); --95ns min
constant kTMinRx : natural := natural(ceil(20.0 / 10.0**9 * real(kCtlClkFreqHz))); --20ns
signal cClkSettleTout : std_logic;

signal cDelayCnt : natural range 0 to MAX(kTInit,MAX(kTClkTermEn, kTClkSettle)) := 0;
signal aClkLocked, cClkLocked, cHSRst, cDelayCntEn, aHSClkLocked, cHSClkLocked, cHSClkLocked_q, cHSClkLost : std_logic;



signal cEnable : std_logic;
begin

debug.cIntRst <= cIntRst;
debug.cLP <= cLP;
debug.cHSRst <= cHSRst;
debug.cHSClkLocked <= cHSClkLocked;
debug.state <= std_logic_vector(to_unsigned(state_type'pos(state), 4));
debug.cClkSettleTout <= cClkSettleTout;

SyncAsyncEnable: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => '0',
      aIn => aEnable,
      OutClk => CtlClk,
      oOut => cEnable);

cIntRst <= not cEnable;

aStopstate <=  '1' when state = stStop else
               '0';
aRxUlpsClkNot <=     '0' when state = stULPS or state = stULPS_Exit else
                     '1';
aUlpsActiveNot <=    '0' when state = stULPS else
                     '1';
aRxClkActiveHS <= aHSClkLocked;                        

-------------------------------------------------------------------------------
-- Synchronize LP signals into the CtlClk domain, then filter glitches
-------------------------------------------------------------------------------              
GenSyncLP: for i in 0 to 1 generate
   SyncAsyncx: entity work.SyncAsync
      generic map (
         kResetTo => '0',
         kStages => 2) --use double FF synchronizer
      port map (
         aReset => '0',
         aIn => aLP(i),
         OutClk => CtlClk,
         oOut => cLPGlitch(i));
--TODO: LP 0 not in sync with LP 1; OK? because on HS-entry LPs don't change
-- simultaneously, only on HS-exit, where they both rise to 1 together.
-- On HS-exit only the "11" condition is used, so this skew at most delays exit.
   GlitchFilterLP: entity work.GlitchFilter
      generic map (
         kNoOfPeriodsToFilter => kTMinRx)
      port map (
         SampleClk => CtlClk,
         sIn => cLPGlitch(i),
         sOut => cLP(i),
         sRst => cIntRst);
end generate GenSyncLP;

DelayCounter: process(CtlClk)
begin
   if Rising_Edge(CtlClk) then
      if (cDelayCntEn = '0') then
         cDelayCnt <= 0;
      elsif (cDelayCntEn = '1') then
         cDelayCnt <= cDelayCnt + 1;
      end if;
   end if;
end process DelayCounter;

cClkSettleTout <=  '1' when cDelayCnt = kTClkSettle-1
                  else '0';
--Outputs
cDelayCntEn <=  '1' when state = stHS_Term else
                '0';


ModeFSM_SyncProc: process (CtlClk)
begin
   if Rising_Edge(CtlClk) then
      if (cIntRst = '1') then
         state <= stInit;
      else
         state <= nstate;
      end if;        
   end if;
end process;

cHSRst <= '0' when state = stHS_Clk and cIntRst = '0' else
          '1';

ModeFSM_NextStateProc: process (state, cLP, cClkSettleTout, cClkLocked, cHSClkLost)
   begin
      nstate <= state;
      case (state) is
         when stInit =>
            if cLP = "11" then
               nstate <= stStop;
            end if;
         when stStop =>
            if cLP = "01" then -- HS-Rqst
               nstate <= stHS_Prpr;
            elsif cLP = "10" then -- ULPS-Rqst
               nstate <= stULPS_Rqst;
            end if;
         when stULPS_Rqst =>
            if (cLP = "11" or cLP = "01") then
               nstate <= stStop;
            elsif (cLP = "00") then
               nstate <= stULPS;
            end if;
         when stULPS =>
            if (cLP = "10") then
               nstate <= stULPS_Exit;
            end if;
         when stULPS_Exit =>
            if (cLP = "11") then
               nstate <= stStop;
            end if;
         when stHS_Prpr =>
            if (cLP = "11") then
               nstate <= stStop;
            elsif cLP = "00" then -- Bridge
               nstate <= stHS_Term;
            end if;
         when stHS_Term =>
            if (cLP = "11") then
               nstate <= stStop;
            elsif (cLP = "00" and cClkSettleTout = '1') then -- Bridge
               nstate <= stHS_Clk;
            end if;
         when stHS_Clk =>
            if (cHSClkLost = '1') then --Clock lost
               nstate <= stHS_End;
            elsif (cLP = "11") then -- Stop, we might not have seen the loss of clock
               nstate <= stStop;
            end if;
         when stHS_End =>
            if (cLP = "11") then -- Stop
               nstate <= stStop;
            end if;
      end case;      
   end process;
   
HSClockingX: entity work.HS_Clocking
   Generic map (
      kGenerateMMCM => kGenerateMMCM,
      kCtlClkFreqHz => kCtlClkFreqHz,
      kRefClkFreqHz => kRefClkFreqHz,
      kAddDelay_ps => kAddDelay_ps
   )
   Port map (
      HS_Clock => aHS,
      HS_SerClk => RxDDRClkHS,
      HS_Div4Clk => RxByteClkHS,
      CtlClk => CtlClk,
      cRst => cHSRst,
      aLocked => aHSClkLocked,
      
      dbg_cBUFR_Rst => debug.cBUFR_Rst,
      dbg_cMMCM_Rst => debug.cMMCM_Rst,
      dbg_cMMCM_RstTout => debug.cMMCM_RstTout,
      dbg_cMMCM_Locked => debug.cMMCM_Locked
   );

SyncAsyncLocked: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => cHSRst,
      aIn => aHSClkLocked,
      OutClk => CtlClk,
      oOut => cHSClkLocked);

process(CtlClk)
begin
   if Rising_Edge(CtlClk) then
      cHSClkLocked_q <= cHSClkLocked;
   end if;
end process;

cHSClkLost <= cHSClkLocked_q and not cHSClkLocked;

end Behavioral;
