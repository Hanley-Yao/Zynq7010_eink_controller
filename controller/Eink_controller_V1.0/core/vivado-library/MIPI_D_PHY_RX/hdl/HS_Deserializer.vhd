-------------------------------------------------------------------------------
--
-- File: HS_Deserializer.vhd
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
-- HS_Deserializer instantiates 7-series-specific primitives for deserialization
-- of a high-speed data burst on a D-PHY data lane. Once enabled it looks
-- for the sync sequence (SoT) and performs necessary alignment to the byte
-- boundary. It outputs either valid de-serialized data, or reports a synchronization
-- error. It is expected to be clocked according to the clocking requirements
-- of the ISERDESE2 primitives.
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

use work.DPHY_types.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity HS_Deserializer is
   Generic (
      kIs8b9b : boolean := false;
      kIDLY_TapWidth : natural := 5;
      kAddDelay_ps : integer := 0;
      kNoLP : boolean := false
   );
   Port (
      dLP0_in : in std_logic_vector(7 downto 0);
      dLP1_in : in std_logic_vector(7 downto 0);
      dLP0_out : out std_logic_vector(7 downto 0);
      dLP1_out : out std_logic_vector(7 downto 0);
      
      SerClk : in STD_LOGIC; -- DDR serial clock
      DivClk : in STD_LOGIC; -- SDR parallel clock; 1:8 factor => par clock = ser clock/4
      aHSIn : in std_logic;
      aLPIn : in std_logic_vector(1 downto 0);
      
      aLPOut : out std_logic_vector(1 downto 0);
           
      dDataOut8 : out std_logic_vector(7 downto 0); --if !kIs8b9b
      dDataOut9 : out std_logic_vector(8 downto 0); --if kIs8b9b
      dValid : out std_logic;

      dSyncHard : out std_logic;
      dSyncSoft : out std_logic;
      dSyncErr : out std_logic;

      --Control for phase alignment
      CtlClk : in std_logic;
      cIDLY_LD : in STD_LOGIC;   --IDELAYE2 Load
      cIDLY_CE : in STD_LOGIC;   --IDELAYE2 CE
      cIDLY_INC : in STD_LOGIC;  --IDELAYE2 Tap Increment
      cIDLY_CNT : out std_logic_vector(kIDLY_TapWidth-1 downto 0);  --IDELAYE2 Current Tap Count
            
      aRst : in std_logic; -- should be de-asserted only when SerClk and DivClk are stable
      aSettled : in std_logic --should be asserted when T_HS_SETTLE expired
   );
end HS_Deserializer;

architecture Behavioral of HS_Deserializer is

   constant kRefClkFreqInMHz : real := 200.0;
   constant kAddDelayTaps : natural := natural(ceil(real(kAddDelay_ps) * (kRefClkFreqInMHz*2.0*32.0) / 1_000_000.0));
   constant kDelayTaps : natural := 12 + kAddDelayTaps; -- 12*(1/(32*2*F_REF)) = 937.5 ps

   function isSoftMatch(mask : std_logic_vector(7 downto 0); word : std_logic_vector(7 downto 0)) return boolean is
   variable diff : std_logic_vector(7 downto 0);
   variable sum : unsigned(3 downto 0) := "0000";
   begin
      diff := mask xor word;
      SumDiff: for i in diff'high downto diff'low loop
         sum := sum + unsigned(diff(i downto i));
      end loop;
      if (sum = 1) then
         return true;
      else
         return false;
      end if;
   end isSoftMatch;
   
   procedure findMatch (
      constant mask : in std_logic_vector(7 downto 0); --sequence to find
      signal word : in std_logic_vector(15 downto 0); --two words most significant first
      variable hard : inout std_logic;
      variable soft : inout std_logic;
      variable alignment : inout natural range 0 to 7
      ) is

   begin
      hard := '0';
      soft := '0';
   --The sync word is constructed in such a way that either there is a match
   --or a soft match with 1 bit error, but not both
      FindHardLoop: for i in 0 to 7 loop
         if (mask = word(i+7 downto i)) then
            alignment := i;
            hard := '1';
            soft := '0';
         end if;
      end loop FindHardLoop;
      if (hard = '0') then
         FindSoftLoop: for i in 0 to 7 loop
            if (isSoftMatch(mask, word(i+7 downto i))) then
               alignment := i;
               soft := '1';
            end if;
         end loop FindSoftLoop;
      end if;
   end procedure findMatch;

-- Synq sequence as written in the spec (most significant last)
constant kSyncSeq : std_logic_vector(7 downto 0) := "00011101";

signal DataInDly, SerClkInv : std_logic;
signal dDataIn_int : std_logic_vector(7 downto 0);
signal dDataIn_reg : vector8(0 to 3); --data byte pipeline for sync detection and alignment
signal dValid_reg : vector1(0 to 3); --sync flag pipeline
signal dSyncHard_int, dSyncSoft_int, dSyncErr_int : std_logic;
signal dSettled, dSerdesRst, dLogicRst: std_logic;
signal dAlignment_int : natural range 0 to 7 := 0;
signal wordToAlign : std_logic_vector(15 downto 0);

-- LP sampled at high-speed as a nibble
type dLP_t is array (0 to 1) of std_logic_vector(7 downto 0);
signal dLP : dLP_t;
signal dLPBridge, dLPStop : std_logic;

attribute DONT_TOUCH : string;
attribute DONT_TOUCH of dLP: signal is "TRUE";
begin

-- Delay element for phase alignment of serial data
InputDelay: IDELAYE2
   generic map (
      CINVCTRL_SEL           => "FALSE",     -- TRUE, FALSE
      DELAY_SRC              => "IDATAIN",   -- IDATAIN, DATAIN
      HIGH_PERFORMANCE_MODE  => "TRUE",      -- TRUE, FALSE
      IDELAY_TYPE            => "VARIABLE",  -- FIXED, VARIABLE, or VAR_LOADABLE
      IDELAY_VALUE           => kDelayTaps,           
      REFCLK_FREQUENCY       => kRefClkFreqInMHz,
      PIPE_SEL               => "FALSE",
      SIGNAL_PATTERN         => "DATA")      -- CLOCK, DATA
   port map (
      DATAOUT                => DataInDly, -- Delayed signal
      DATAIN                 => '0', -- Not used; IDATAIN instead
      C                      => CtlClk, -- Clock for control signals (CE,INC...)
      CE                     => cIDLY_CE,
      INC                    => cIDLY_INC,
      IDATAIN                => aHSIn, -- Driven by IOB
      LD                     => cIDLY_LD,
      REGRST                 => '0', --not used in VARIABLE mode
      LDPIPEEN               => '0',
      CNTVALUEIN             => "00000", --not used in VARIABLE mode
      CNTVALUEOUT            => cIDLY_CNT, -- current tap value
      CINVCTRL               => '0');
assert (not kIs8b9b) report "8b9b encoding not supported yet" severity failure;


--Invert locally for ISERDESE2
SerClkInv <= not SerClk;

-- De-serializer, 1:8 DDR, non-cascaded,
-- Least-significant first: bit sent first should be bit(0) in PPI byte
Deserializer: ISERDESE2
   generic map (
      DATA_RATE         => "DDR",
      DATA_WIDTH        => 8,
      INTERFACE_TYPE    => "NETWORKING", 
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN    => "FALSE",
      NUM_CE            => 1,
      OFB_USED          => "FALSE",
      IOBDELAY          => "IFD",         -- Use input at DDLY to output the data on Q1-Q6
      SERDES_MODE       => "MASTER",
      INIT_Q1           => '0',
      INIT_Q2           => '0',
      INIT_Q3           => '0',
      INIT_Q4           => '0',
      SRVAL_Q1          => '0',
      SRVAL_Q2          => '0',
      SRVAL_Q3          => '0',
      SRVAL_Q4          => '0')
   port map (
      Q1                => dDataIn_int(0),
      Q2                => dDataIn_int(1),
      Q3                => dDataIn_int(2),
      Q4                => dDataIn_int(3),
      Q5                => dDataIn_int(4),
      Q6                => dDataIn_int(5),
      Q7                => dDataIn_int(6),
      Q8                => dDataIn_int(7), -- bit sent first
      SHIFTOUT1         => open, -- Cascade connection to Slave ISERDES
      SHIFTOUT2         => open, -- Cascade connection to Slave ISERDES
      BITSLIP           => '0', -- 1-bit Invoke Bitslip. This can be used with any 
      CE1               => '1', -- 1-bit Clock enable input
      CE2               => '1', -- 1-bit Clock enable input
      CLK               => SerClk, -- Fast Source Synchronous SERDES clock from BUFIO
      CLKB              => SerClkInv, -- Locally inverted clock
      CLKDIV            => DivClk, -- Slow clock driven by BUFR
      CLKDIVP           => '0', --Not used here
      D                 => '0',                                
      DDLY              => DataInDly, -- 1-bit Input signal from IODELAYE1.
      RST               => dSerdesRst, -- 1-bit Asynchronous reset only.
      SHIFTIN1          => '0',
      SHIFTIN2          => '0',
      -- unused connections
      DYNCLKDIVSEL      => '0',
      DYNCLKSEL         => '0',
      OFB               => '0',
      OCLK              => '0',
      OCLKB             => '0',
      O                 => open); -- unregistered output of ISERDESE1

-- We need a reset bridge to use the asynchronous aRst signal to reset our
-- ISERDESE2 
SerdesReset: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => aRst,
      OutClk => DivClk,
      oRst => dSerdesRst);
-- We do not have a lot of time to bring aSettled into the DivClk domain
-- T_HS_SETTLE_max = 145ns + 10*UI
-- T_HS_SETTLE_min = 85ns + 6*UI
-- aSettled measures 85ns, and we synchronize it with only one flip-flop
-- dSettled should be used downstream in simple combinational logic only
SyncAsyncSettled: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 1) --see above
   port map (
      aReset => not aSettled,
      aIn => '1',
      OutClk => DivClk,
      oOut => dSettled);
      
-- LP de-serializer, 1:8 DDR, non-cascaded,
-- Although LP signals are low-speed and not synchronous with the HS clock, we need to detect LP
-- state changes as soon as possible due to tight timing between LP states and HS start.
UseOwnLP: if not kNoLP generate
LPxx: for i in 0 to 1 generate
LP_DeserializerX: ISERDESE2
   generic map (
      DATA_RATE         => "DDR",
      DATA_WIDTH        => 8,
      INTERFACE_TYPE    => "NETWORKING", 
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN    => "FALSE",
      NUM_CE            => 1,
      OFB_USED          => "FALSE",
      IOBDELAY          => "NONE",         -- combinatorial output = D, registered output = D
      SERDES_MODE       => "MASTER",
      INIT_Q1           => '1',
      INIT_Q2           => '1',
      INIT_Q3           => '1',
      INIT_Q4           => '1',
      SRVAL_Q1          => '1',
      SRVAL_Q2          => '1',
      SRVAL_Q3          => '1',
      SRVAL_Q4          => '1')
   port map (
      Q1                => dLP(i)(0),
      Q2                => dLP(i)(1),
      Q3                => dLP(i)(2),
      Q4                => dLP(i)(3), 
      Q5                => dLP(i)(4),
      Q6                => dLP(i)(5),
      Q7                => dLP(i)(6),
      Q8                => dLP(i)(7), -- bit sent first
      SHIFTOUT1         => open, -- Cascade connection to Slave ISERDES
      SHIFTOUT2         => open, -- Cascade connection to Slave ISERDES
      BITSLIP           => '0', -- 1-bit Invoke Bitslip. This can be used with any 
      CE1               => '1', -- 1-bit Clock enable input
      CE2               => '1', -- 1-bit Clock enable input
      CLK               => SerClk, -- Fast Source Synchronous SERDES clock from BUFIO
      CLKB              => SerClkInv, -- Locally inverted clock
      CLKDIV            => DivClk, -- Slow clock driven by BUFR
      CLKDIVP           => '0', --Not used here
      D                 => aLPIn(i),                                
      DDLY              => '0', -- 1-bit Input signal from IODELAYE1.
      RST               => dSerdesRst, -- 1-bit Asynchronous reset only.
      SHIFTIN1          => '0',
      SHIFTIN2          => '0',
      -- unused connections
      DYNCLKDIVSEL      => '0',
      DYNCLKSEL         => '0',
      OFB               => '0',
      OCLK              => '0',
      OCLKB             => '0',
      O                 => aLPOut(i)); -- unregistered output of ISERDESE1
end generate LPxx;
dLP0_out <= dLP(0);
dLP1_out <= dLP(1);
end generate UseOwnLP;

ShareLPFromOtherLane: if kNoLP generate
    dLP(0) <= dLP0_in;
    dLP(1) <= dLP1_in;
    aLPOut <= aLPIn;
end generate ShareLPFromOtherLane;

-- We are in Bridge (or HS) state when we sampled 0 at least 2 times on both LP1 on and LP0
-- TODO: glitch filtering? problematic, because serial clock frequency changes dynamically
dLPBridge <= '1' when dLP(0)(1 downto 0) = "00" and dLP(1)(1 downto 0) = "00" else
             '0';
-- We are in Stop state when we sampled 1 at least 2 times on both LP1 on and LP0
-- TODO: glitch filtering? problematic, because serial clock frequency changes dynamically   
dLPStop <=   '1' when dLP(0)(1 downto 0) = "11" and dLP(1)(1 downto 0) = "11" else
             '0';

-- Logic should be held in reset for one more period, because ISERDES output
-- is only valid starting from the second DivClk period      
process(DivClk, dSerdesRst)
variable dSerdesRst_q : std_logic;
begin
   if (dSerdesRst = '1') then
      dLogicRst <= '1';
      dSerdesRst_q := '1';
   elsif Rising_Edge(DivClk) then
      if (dSerdesRst_q = '0' and dSettled = '1') then
         dLogicRst <= '0';
      elsif (dValid_reg(3) = '0') then
         dLogicRst <= '1';
      end if;
      dSerdesRst_q := dSerdesRst;
   end if;
end process;      

------------------------------------------------------------- 
-- Buffer data to detect sync sequence early enough
-------------------------------------------------------------
DataPipeline: process(DivClk)
begin
   if Rising_Edge(DivClk) then
      if dLogicRst = '1' then
         dDataIn_reg <= (others => (others => '0'));
      else
         for i in dDataIn_reg'low to dDataIn_reg'high-1 loop
            dDataIn_reg(i+1) <= dDataIn_reg(i);
         end loop;
         dDataIn_reg(0) <= dDataIn_int;
      end if;
   end if;
end process;

AlignFlagPipeline: process(DivClk)
begin
   if Rising_Edge(DivClk) then
      if dLogicRst = '1' then
         dValid_reg <= (others => '0');
      else      
         for i in 2 to dValid_reg'high-1 loop
            dValid_reg(i+1) <= dValid_reg(i);
         end loop;
         dValid_reg(2) <= (dSyncHard_int or dSyncSoft_int) and not dLPStop;
      end if;
   end if;
end process;

wordToAlign <= dDataIn_reg(1) & dDataIn_reg(0);

process(DivClk)
variable nextMust : boolean;
variable hard, soft : std_logic;
variable alignment : natural range 0 to 7;

begin
   if Rising_Edge(DivClk) then
      if (dLogicRst = '1') then
         dSyncHard_int <= '0';
         dSyncSoft_int <= '0';
         dAlignment_int <= 0;
         dSyncErr_int <= '0';
         nextMust := false;
      elsif (dSyncHard_int = '0' and dSyncSoft_int = '0' and dSyncErr_int = '0') then
         --If we are seeing ones in the early part of the word, or we saw ones in the latter part of the
         --word in the previous period, we must find a sequence or error out
         if (dDataIn_reg(0)(7 downto 4) /= "0000" or nextMust) then
            findMatch(kSyncSeq, wordToAlign, hard, soft, alignment);
            if (hard = '0' and soft = '0') then
               dSyncErr_int <= '1';
            end if;
            dSyncHard_int <= hard;
            dSyncSoft_int <= soft;
            dAlignment_int <= alignment;
         end if;
         --If we are seeing ones, we must find the sequence in the next period
         if (dDataIn_reg(0)(3 downto 0) /= "0000") then
            nextMust := true;
         end if;
      end if;
   end if;
end process;

dSyncErr <= dSyncErr_int;
dSyncHard <= dSyncHard_int;
dSyncSoft <= dSyncSoft_int;

------------------------------------------------------------- 
-- Since the sync sequence is short and it is immediately followed by data, using
-- bitslip is out of question because it is slow and would lead to the loss of the first
-- words in the transmission 
------------------------------------------------------------- 
WordAlignment: process(DivClk)
constant kPos : natural := 3;
variable delay : natural range 0 to kPos := kPos;
begin
   if Rising_Edge(DivClk) then
      if (dValid_reg(kPos) = '0' or dLogicRst = '1') then
         dDataOut8 <= (others => '0');
         dValid <= '0';
      else
         case (dAlignment_int) is
         -- 76543210|76543210|76543210
         -- 00000000|00011101|abcdefgh          
            when 0 =>
               dDataOut8 <= dDataIn_reg(kPos-1);
         -- 00000000|0011101a|bcdefgha
            when 1 => 
               dDataOut8 <= dDataIn_reg(kPos)(0 downto 0) & dDataIn_reg(kPos-1)(7 downto 1);
         -- 00000000|011101ab|cdefghab            
            when 2 =>
               dDataOut8 <= dDataIn_reg(kPos)(1 downto 0) & dDataIn_reg(kPos-1)(7 downto 2);
         -- 00000000|11101abc|defghabc            
            when 3 => 
               dDataOut8 <= dDataIn_reg(kPos)(2 downto 0) & dDataIn_reg(kPos-1)(7 downto 3);            
         -- 00000001|1101abcd|efghabcd            
            when 4 => 
               dDataOut8 <= dDataIn_reg(kPos)(3 downto 0) & dDataIn_reg(kPos-1)(7 downto 4);          
         -- 00000011|101abcde|fghabcde            
            when 5 => 
               dDataOut8 <= dDataIn_reg(kPos)(4 downto 0) & dDataIn_reg(kPos-1)(7 downto 5);        
         -- 00000111|01abcdef|ghabcdef            
            when 6 => 
               dDataOut8 <= dDataIn_reg(kPos)(5 downto 0) & dDataIn_reg(kPos-1)(7 downto 6);           
         -- 00001110|1abcdefg|habcdefg            
            when 7 => 
               dDataOut8 <= dDataIn_reg(kPos)(6 downto 0) & dDataIn_reg(kPos-1)(7 downto 7);           
         end case;
         dValid <= dValid_reg(kPos);
      end if;
   end if;
end process;

end Behavioral;
