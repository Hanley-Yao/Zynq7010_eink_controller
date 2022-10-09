-------------------------------------------------------------------------------
--
-- File: HS_Clocking.vhd
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
-- This module instantiates all the necessary primitives to obtain a fast
-- serial clock and a divided parallel clock from the the D-PHY high-speed
-- clock input. It also instantiates logic for IDELAYE2 primitives to be
-- usable throughout the design.
-- Connect this module to the output of the HS clock lane input buffer. Connect
-- an architecture-dependent 200/300 MHz reference clock for IDELAYCTRL
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity HS_Clocking is
   Generic (
      kGenerateMMCM : boolean := false;
      kCtlClkFreqHz : integer := 100_000_000;
      kRefClkFreqHz : integer := 200_000_000;
      kAddDelay_ps : integer := 0
   );
   Port (
      HS_Clock : in STD_LOGIC;
      HS_SerClk : out STD_LOGIC;
      HS_Div4Clk : out STD_LOGIC;
      CtlClk : in STD_LOGIC;
      cRst : in std_logic; --Must be asserted when CtlClk or HS_Clk are not present/stable; must be de-asserted synchronously with CtlClk
      aLocked : out std_logic;
      
      dbg_cBUFR_Rst : out std_logic;
      dbg_cMMCM_Rst : out std_logic;
      dbg_cMMCM_RstTout : out std_logic;  
      dbg_cMMCM_Locked : out std_logic  
   );
end HS_Clocking;

architecture Behavioral of HS_Clocking is

constant kRefClkFreqInMHz : real := real(kRefClkFreqHz) / 1_000_000.0;
constant kDelayTaps : natural := natural(ceil(real(kAddDelay_ps) * (kRefClkFreqInMHz*2.0*32.0) / 1_000_000.0)); 
constant kMMCM_RSTMINPULSE : real := 5.0; --ns; Artix-7 spec
constant kTMMCM_Rst : natural := natural(ceil(kMMCM_RSTMINPULSE / (10.0**9) * real(kCtlClkFreqHz)));

signal cBUFR_Rst, cExtRst, cMMCM_Rst : std_logic;
signal cDelayCnt : natural range 0 to kTMMCM_Rst := 0;
signal cMMCM_RstTout, cDelayCntEn : std_logic;
signal aMMCM_Locked, cMMCM_Locked, cMMCM_LockedFalling, cMMCM_LockedRising : std_logic;
signal cMMCM_Reset_q : std_logic_vector(1 downto 0);
signal cMMCM_Locked_q : std_logic_vector(1 downto 0);
signal dDiv4ClkActive : std_logic;
signal ClkFbOut, ClkFbIn, HS_Clock_1X, HS_Div4Clk_int, HS_Clock_Buf, HS_ClockDly : std_logic;
signal divclk_dbg : std_logic;

begin

dbg_cBUFR_Rst <= cBUFR_Rst;
dbg_cMMCM_Rst <= cMMCM_Rst;
dbg_cMMCM_RstTout <= cMMCM_RstTout;   
dbg_cMMCM_Locked <= cMMCM_Locked;

cExtRst <= cRst;

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

cMMCM_RstTout <=      '1' when cDelayCnt = kTMMCM_Rst                  else '0';
                  
-- Delay element for phase alignment of serial data
InputDelay: IDELAYE2
   generic map (
      CINVCTRL_SEL           => "FALSE",     -- TRUE, FALSE
      DELAY_SRC              => "IDATAIN",   -- IDATAIN, DATAIN
      HIGH_PERFORMANCE_MODE  => "TRUE",      -- TRUE, FALSE
      IDELAY_TYPE            => "FIXED",  -- FIXED, VARIABLE, or VAR_LOADABLE
      IDELAY_VALUE           => kDelayTaps,           
      REFCLK_FREQUENCY       => kRefClkFreqInMHz,
      PIPE_SEL               => "FALSE",
      SIGNAL_PATTERN         => "CLOCK")      -- CLOCK, DATA
   port map (
      DATAOUT                => HS_ClockDly, -- Delayed signal
      DATAIN                 => '0', -- Not used; IDATAIN instead
      C                      => CtlClk, -- Not used in FIXED mode
      CE                     => '0', -- Not used in FIXED mode
      INC                    => '0', -- Not used in FIXED mode
      IDATAIN                => HS_Clock, -- Driven by IOB
      LD                     => '0', -- Not used in FIXED mode
      REGRST                 => '0', --not used in VARIABLE mode
      LDPIPEEN               => '0',
      CNTVALUEIN             => "00000", -- Not used in FIXED mode
      CNTVALUEOUT            => open, -- Not used in FIXED mode
      CINVCTRL               => '0' -- Not used in FIXED mode
   );


--Complex use case, with MMCM
GenMMCM: if kGenerateMMCM generate
SerClockGen: MMCME2_ADV
   generic map
      (BANDWIDTH            => "OPTIMIZED",
      CLKOUT4_CASCADE      => FALSE,
      COMPENSATION         => "ZHOLD",
      STARTUP_WAIT         => FALSE,
      DIVCLK_DIVIDE        => 1,
      CLKFBOUT_MULT_F      => 15.0,
      CLKFBOUT_PHASE       => 0.000,
      CLKFBOUT_USE_FINE_PS => FALSE,
      CLKOUT0_DIVIDE_F     => 15.0,
      CLKOUT0_PHASE        => 0.000,
      CLKOUT0_DUTY_CYCLE   => 0.500,
      CLKOUT0_USE_FINE_PS  => FALSE,
      CLKIN1_PERIOD        => 16.666, --60MHz for now
      REF_JITTER1          => 0.010)
   port map
   -- Output clocks
   (
      CLKFBOUT            => ClkFbOut,
      CLKFBOUTB           => open,
      CLKOUT0             => HS_Clock_1X,
      CLKOUT0B            => open,
      CLKOUT1             => open,
      CLKOUT1B            => open,
      CLKOUT2             => open,
      CLKOUT2B            => open,
      CLKOUT3             => open,
      CLKOUT3B            => open,
      CLKOUT4             => open,
      CLKOUT5             => open,
      CLKOUT6             => open,
      -- Input clock control
      CLKFBIN             => ClkFbIn,
      CLKIN1              => HS_ClockDly,
      CLKIN2              => '0',
      -- Tied to always select the primary input clock
      CLKINSEL            => '1',
      -- Ports for dynamic reconfiguration
      DADDR               => (others => '0'),
      DCLK                => '0',
      DEN                 => '0',
      DI                  => (others => '0'),
      DO                  => open,
      DRDY                => open,
      DWE                 => '0',
      -- Ports for dynamic phase shift
      PSCLK               => '0',
      PSEN                => '0',
      PSINCDEC            => '0',
      PSDONE              => open,
      -- Other control and status signals
      LOCKED              => aMMCM_Locked,
      CLKINSTOPPED        => open,
      CLKFBSTOPPED        => open,
      PWRDWN              => '0',
      RST                 => cMMCM_Rst);

-- To make sure the MMCM output is phase-aligned to its input, we need to replicate the buffers from clock output
-- in the feedback loop. Since we use a BUFIO/BUFR pair at the MMCM output, we add a BUFR to the feedback loop 
FeedbackBuffer: BUFR
   generic map (
      BUFR_DIVIDE => "1",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
      SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
   )
   port map (
      O => ClkFbIn,     -- 1-bit output: Clock output port
      CE => '1',   -- 1-bit input: Active high, clock enable (Divided modes only)
      CLR => cMMCM_Rst, -- 1-bit input: Active high, asynchronous clear (Divided modes only)        
      I => ClkFbOut      -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
   );

-- Synchronize MMCM Locked into the CtlClk domain
MMCM_LockSync: entity work.SyncAsync
   port map (
      aReset => '0',
      aIn => aMMCM_Locked,
      OutClk => CtlClk,
      oOut => cMMCM_Locked);

-- Edge detector for MMCM Locked flag;      
MMCM_LockedDetect: process(CtlClk)
begin
   if Rising_Edge(CtlClk) then
      cMMCM_Locked_q <= cMMCM_Locked & cMMCM_Locked_q(1);
      cMMCM_LockedFalling <= cMMCM_Locked_q(1) and not cMMCM_Locked;
      cMMCM_LockedRising <= not cMMCM_Locked_q(1) and cMMCM_Locked;
   end if;
end process MMCM_LockedDetect;
 
-- Generate MMCM reset on external reset or lock lost event
MMCM_Reset: process(cExtRst, CtlClk)
begin
   if (cExtRst = '1') then
      cMMCM_Rst <= '1';
      cDelayCntEn <= '1';
   elsif Rising_Edge(CtlClk) then
      if (cMMCM_LockedFalling = '1') then
         cMMCM_Rst <= '1';
         cDelayCntEn <= '1';
      elsif cMMCM_RstTout = '1' then --count down to minimum reset pulse width
         cMMCM_Rst <= '0';
         cDelayCntEn <= '0';
      end if;
   end if; 
end process MMCM_Reset;

cBUFR_Rst <= not cMMCM_Locked;

HS_Clock_Buf <= HS_Clock_1X;
end generate GenMMCM;

GenNoMMCM: if not kGenerateMMCM generate
--Simple use case, no PLL, just BUFIO and BUFR
   HS_Clock_Buf <= HS_ClockDly;
   cBUFR_Rst <= cExtRst when Rising_Edge(CtlClk); --make external reset glitch free
   cDelayCntEn <= '0';
   cMMCM_Rst <= '0';
   cMMCM_Locked <= '1';
end generate GenNoMMCM;

--Fast serial clock
SerialClkBuffer: BUFIO
   port map (
      O => HS_SerClk, -- 1-bit output: Clock output (connect to I/O clock loads).
      I => HS_Clock_Buf  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
   );
-- 1x slow parallel clock
DivClkBuffer: BUFR
   generic map (
      BUFR_DIVIDE => "4",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
      SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
   )
   port map (
      O => HS_Div4Clk_int,     -- 1-bit output: Clock output port
      CE => '1',   -- 1-bit input: Active high, clock enable (Divided modes only)
      CLR => cBUFR_Rst, -- 1-bit input: Active high, asynchronous clear (Divided modes only)        
      I => HS_Clock_Buf      -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
   );

SyncAsyncLocked: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => cBUFR_Rst,
      aIn => '1',
      OutClk => HS_Div4Clk_int,
      oOut => dDiv4ClkActive);

HS_Div4Clk <= HS_Div4Clk_int;
aLocked <= dDiv4ClkActive;

end Behavioral;
