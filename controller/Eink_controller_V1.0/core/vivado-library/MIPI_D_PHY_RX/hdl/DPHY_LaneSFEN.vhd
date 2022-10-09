-------------------------------------------------------------------------------
--
-- File: DPHY_LaneSFEN.vhd
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
-- This module implements a MIPI D-PHY 1.0 CIL-SFEN lane: slave (receiver), 
-- forward high-speed, events forward escape mode (future work), no reverse
-- direction. It is architecture-independent by itself, but the instantiated
-- HS-Deserializer has its own requirements. The D-PHY physical interface is
-- assumed to be de-multiplexed into low-power LP(1:0) and high-speed HS inputs
-- by external circuitry (outside the FPGA). On the logic side data is forwarded
-- via the PPI interface as described in the D-PHY spec Annex A.
-- This data lane module requires high-speed serial and divided parallel clocks
-- as provided by the accompanying SCNN clock lane module. 
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

entity DPHY_LaneSFEN is
   Generic (
      kRefClkFreqHz : natural := 200_000_000;
      kAddDelay_ps : integer := 0;
      kNoLP : boolean := false
   );
   Port (
      dLP0_in : in std_logic_vector(7 downto 0);
      dLP1_in : in std_logic_vector(7 downto 0);
      dLP0_out : out std_logic_vector(7 downto 0);
      dLP1_out : out std_logic_vector(7 downto 0);
      cLP_in : in STD_LOGIC_VECTOR (1 downto 0);
      cLP_out : out STD_LOGIC_VECTOR (1 downto 0);
      
      aLP : in STD_LOGIC_VECTOR (1 downto 0);
      aHS : in STD_LOGIC;
      RefClk : in STD_LOGIC;
      
      SerClkHS : in STD_LOGIC;
      DivClk : in STD_LOGIC;
      aRxClkActiveHS : in STD_LOGIC;

      --PPI
      RxByteClkHS : out std_logic;      
      rbRxDataHS : out std_logic_vector(7 downto 0);
      rbRxValidHS : out std_logic;
      rbRxActiveHS : out std_logic;
      rbRxSyncHS : out std_logic;
      rbErrSotHS : out std_logic;
      rbErrSotSyncHS : out std_logic;
      
      aEnable : in std_logic; --Enable Lane Module. DivClk&SerClkHS must be stable
      aForceRxmode : in std_logic; --Force Lane Module Into Receive mode / Wait for Stop state 
      aStopstate : out std_logic; --Lane is in Stop state.
      aErrEsc : out std_logic; --Escape Entry Error.
      aErrControl : out std_logic; --Control Error.

      debug : out DebugSFEN_Type
--      dbg_cIntRst : out std_logic;
--      dbg_cLP : out std_logic_vector(1 downto 0);
--      dbg_state : out std_logic_vector(2 downto 0);
--      dbg_cHSClkRst : out std_logic;
--      dbg_cForceRxmode : out std_logic;
--      dbg_cInitTout : out std_logic;
--      dbg_cHSSettleTout : out std_logic;
--      dbg_cHSSettled : out std_logic;
--      dbg_cHSReset : out std_logic;
--      dbg_dSyncHard : out std_logic;
--      dbg_dSyncSoft : out std_logic;
--      dbg_dSyncErr : out std_logic
   );
end DPHY_LaneSFEN;

architecture Behavioral of DPHY_LaneSFEN is

function MAX(LEFT, RIGHT: INTEGER) return INTEGER is
begin
   if LEFT > RIGHT then return LEFT;
   else return RIGHT;
   end if;
end;
  
type state_type is (stInitCountDown, stWaitForStop, stStop, stHS_Rqst, stHS_Settle, stHS_Rcv); 
signal state, nstate : state_type := stInitCountDown; 

alias CtlClk : std_logic is RefClk;
alias kCtlClkFreqHz : natural is kRefClkFreqHz;

signal aLP_int, cLP, cLPGlitch: std_logic_vector(1 downto 0);
constant kTInit      : natural := natural(ceil(100.0 * real(kCtlClkFreqHz) / 1_000_000.0)); --100us
constant kTHSSettle  : natural := natural(ceil(85.0 * real(kCtlClkFreqHz) / 1_000_000_000.0)); --85ns
constant kTMinRx : natural := natural(ceil(20.0 * real(kCtlClkFreqHz) / 1_000_000_000.0)); --20ns
constant kOffset     : natural := 3 + 1 ; -- adjust timeout values above to account for late start due to CtlClk sync
signal cDelayCnt : natural range 0 to MAX(kTInit,kTHSSettle) := 0;
signal cHS_Trail, cHSReset, dDelayCntEn, cDelayCntEn : std_logic;
signal dSyncHard, dSyncSoft, dSyncErr, dIntRst, dHSReset, dStopstate, dValid : std_logic;
signal cEnable, cIntRst, cHSClkRst, cForceRxmode, cInitDone, cHSSettled, cValid : std_logic;
signal cInitTout, cHSSettleTout: std_logic; --CtlClk timeout flags
signal dSyncHard_reg, dSyncSoft_reg, dSyncErr_reg, dInitDone : std_logic; -- for pulse generation 
signal dDataOut : std_logic_vector(7 downto 0);
signal aNotEnable, aNotRxClkActiveHS : std_logic;
begin

debug.cIntRst <= cIntRst;
debug.cHSClkRst <= cHSClkRst;
debug.cLP <= cLP;
debug.state <= std_logic_vector(to_unsigned(state_type'pos(state), 3));
debug.cForceRxmode <= cForceRxmode;
debug.cInitTout <= cInitTout;
debug.cHSSettleTout <= cHSSettleTout;
debug.cHSSettled <= cHSSettled;
debug.cHSReset <= cHSReset;
debug.dSyncHard <= dSyncHard;
debug.dSyncSoft <= dSyncSoft;
debug.dSyncErr <= dSyncErr;

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

aNotRxClkActiveHS <= not aRxClkActiveHS;
RxClkActiveHSResetBridge: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => aNotRxClkActiveHS,
      OutClk => CtlClk,
      oRst => cHSClkRst);
 
               
SyncAsyncForceRxMode: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => cIntRst,
      aIn => aForceRxmode,
      OutClk => CtlClk,
      oOut => cForceRxmode);

UseOwnLP: if not kNoLP generate
-- Sync LP with CtlClk
-- T_LPX_min = 50ns = 4*UI_max
-- Synchronizing the LP bits separately is OK, because entering HS is done by
-- LP-11, LP-01, LP-00 sequences, so only one bit changes from one LPX period
-- to another.
-- At the end of HS, LP-00 goes to LP-11, but this is the only valid transition. So
-- spurious LP-01 or LP-10 between them can be ignored, until it stabilizes in LP-11.
GenSyncLP: for i in 0 to 1 generate
   SyncAsyncx: entity work.SyncAsync
      generic map (
         kResetTo => '0',
         kStages => 2) --use double FF synchronizer
      port map (
         aReset => '0',
         aIn => aLP_int(i),
         OutClk => CtlClk,
         oOut => cLPGlitch(i));
   GlitchFilterLPC: entity work.GlitchFilter
      generic map (
         kNoOfPeriodsToFilter => kTMinRx)
      port map (
         SampleClk => CtlClk,
         sIn => cLPGlitch(i),
         sOut => cLP(i),
         sRst => '0');         
end generate GenSyncLP;
end generate UseOwnLP;

cLP_out <= cLP;

ShareLPFromOtherLane: if kNoLP generate
    cLP <= cLP_in;
end generate ShareLPFromOtherLane;
      
-- Time delay counter running on CtlClk, because it has a known, fixed frequency
-- We use it to keep track of timing parameters in time units rather than UIs.
DelayCounter: process(CtlClk)
begin
   if Rising_Edge(CtlClk) then
      if (cDelayCntEn = '0') then
         cDelayCnt <= 0;
      else
         cDelayCnt <= cDelayCnt + 1;
      end if;
   end if;
end process DelayCounter;

cInitTout <=      '1' when cDelayCnt = kTInit                  else '0';
cHSSettleTout <=  '1' when cDelayCnt = kTHSSettle-1              else '0';
--Outputs
cDelayCntEn <=    '1' when state = stInitCountDown or nstate = stHS_Settle else
                  '0';
                  
ModeFSM_SyncProc: process (CtlClk)
begin
   if Rising_Edge(CtlClk) then
      if (cIntRst = '1') then
         state <= stInitCountDown;
      else
         state <= nstate;
      end if;        
   end if;
end process;

process(CtlClk, cHSClkRst)
begin
   if (cHSClkRst = '1') then
      cHSReset <= '1';
   elsif Rising_Edge(CtlClk) then
      if nstate = stHS_Settle then
         cHSReset <= '0';
      elsif state = stStop and cValid = '0' then
         cHSReset <= '1';
      end if;
   end if;
end process;

process(CtlClk, cHSClkRst)
begin
   if (cHSClkRst = '1') then
      cHSSettled <= '0';
   elsif Rising_Edge(CtlClk) then
      if state = stHS_Settle and cHSSettleTout = '1' then
         cHSSettled <= '1';
      elsif state = stStop and cValid = '0' then
         cHSSettled <= '0';
      end if;
   end if;
end process;


ModeFSM_NextStateProc: process (state, cLP, cInitTout, cForceRxmode, cHSSettleTout)
   begin
      nstate <= state;
      case (state) is
         when stInitCountDown =>
            if cInitTout = '1' or cForceRxmode = '1'  then
               nstate <= stWaitForStop;
            end if;   
         when stWaitForStop =>
            if cLP = "11" then
               nstate <= stStop;
            end if;
         when stStop =>
            if cLP = "01" then -- HS-Rqst
               nstate <= stHS_Rqst;
            end if;
         when stHS_Rqst =>
            if cLP = "11" then
               nstate <= stStop;
            elsif cLP = "00" then
               nstate <= stHS_Settle;
            end if;
         when stHS_Settle =>
            if cLP = "11" then
               nstate <= stStop;
            elsif (cHSSettleTout = '1') then
               nstate <= stHS_Rcv;
            end if;
         when stHS_Rcv =>
            if cLP = "11" then
               nstate <= stStop;
            end if;
         when others =>
            null;
      end case;      
   end process;

-----------------------------------------------------------------
-- PPI
-----------------------------------------------------------------
aStopstate <=  '1' when state = stStop else '0';

RxByteClkHS <= DivClk;
--PPI requires least-significant bit to be the first one received
MakeLSF: for i in rbRxDataHS'range generate  
   rbRxDataHS(i) <= dDataOut(rbRxDataHS'length-1-i);
end generate MakeLSF;
rbRxValidHS <= dValid;
rbRxActiveHS <= dSyncHard or dSyncSoft;
rbRxSyncHS <= (dSyncHard and not dSyncHard_reg) or (dSyncSoft and not dSyncSoft_reg);
rbErrSotSyncHS <= (dSyncSoft and not dSyncSoft_reg);
rbErrSotHS <= dSyncErr and not dSyncErr_reg;
GenSyncPulse: process(DivClk)
begin
   if Rising_Edge(DivClk) then
      dSyncHard_reg <= dSyncHard;
      dSyncSoft_reg <= dSyncSoft;
      dSyncErr_reg <= dSyncErr;
   end if;
end process;

HSDeserializerX: entity work.HS_Deserializer
   Generic map (
      kIs8b9b => false,
      kAddDelay_ps => kAddDelay_ps,
      kNoLP => kNoLP
   )
   Port map (
      dLP0_in => dLP0_in,
      dLP1_in => dLP1_in,
      
      dLP0_out => dLP0_out,
      dLP1_out => dLP1_out,
      
      SerClk => SerClkHS,
      DivClk => DivClk,
      aHSIn => aHS,
      aLPIn => aLP,
      
      aLPOut => aLP_int,
      dDataOut8 => dDataOut,
      dValid => dValid,
      
      dSyncHard => dSyncHard,
      dSyncSoft => dSyncSoft,
      dSyncErr => dSyncErr,
      
      CtlClk => CtlClk,
      cIDLY_LD => '0',     --IDELAYE2 Load
      cIDLY_CE => '0',     --IDELAYE2 CE
      cIDLY_INC => '0',    --IDELAYE2 Tap Increment
      cIDLY_CNT => open,   --IDELAYE2 Current Tap Count
      aRst => cHSReset,
      aSettled => cHSSettled
   );     

SyncAsyncValid: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => cHSClkRst,
      aIn => dValid,
      OutClk => CtlClk,
      oOut => cValid);
           
end Behavioral;
