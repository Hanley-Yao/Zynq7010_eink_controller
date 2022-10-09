----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2016 01:54:29 PM
-- Design Name: 
-- Module Name: tb_MIPI_DPHY_Receiver - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_MIPI_DPHY_Receiver is
--   Port ( );
end tb_MIPI_DPHY_Receiver;

architecture Behavioral of tb_MIPI_DPHY_Receiver is

component MIPI_DPHY_Receiver is
    generic (
		-- Users to add parameters here
      kVersionMajor : natural := 0; -- TCL-propagated from VLNV
      kVersionMinor : natural := 0; -- TCL-propagated from VLNV
      kNoOfDataLanes : natural range 1 to 2:= 2;
      kGenerateMMCM : boolean := false;
      kGenerateAXIL : boolean := false;
      kAddDelayClk_ps : integer := 0;
      kAddDelayData0_ps : integer := 0;
      kAddDelayData1_ps : integer := 0;
      kRefClkFreqHz : integer := 200_000_000; -- TCL-propagated
      kDebug : boolean := true;
      kLPFromLane0 : boolean := true;
      kSharedLogic : boolean := true;
      -- Parameters of Axi Slave Bus Interface S_AXI_LITE
      C_S_AXI_LITE_DATA_WIDTH	: integer	:= 32;
      C_S_AXI_LITE_ADDR_WIDTH	: integer	:= 4;
      C_S_AXI_LITE_FREQ_HZ : integer      := 100_000_000 -- TCL-propagated
	);
	port (
		-- Users to add ports here
      dphy_clk_hs_p : in std_logic;
      dphy_clk_hs_n : in std_logic;
      dphy_clk_lp_p : in std_logic;
      dphy_clk_lp_n : in std_logic;      
      
      dphy_data_hs_p : in std_logic_vector(kNoOfDataLanes-1 downto 0);
      dphy_data_hs_n : in std_logic_vector(kNoOfDataLanes-1 downto 0);
      dphy_data_lp_p : in std_logic_vector(kNoOfDataLanes-1 downto 0);
      dphy_data_lp_n : in std_logic_vector(kNoOfDataLanes-1 downto 0);
      
      RefClk : in std_logic; --200MHz
      aRst : in std_logic; --Only to be de-asserted when RefClk is valid
      rDlyCtrlLockedIn : in std_logic; --if IDELAYCTRL instantiated externally, input its locked signal
      rDlyCtrlLockedOut : out std_logic; --if IDELAYCTRL instantiated internally, output its locked signal
      
      --PHY-Protocol Interface (PPI)
      --Clock lane
      RxDDRClkHS : out std_logic; --Receiver DDR Clock (may be used by the protocol)
      aRxClkActiveHS : out std_logic; --Receiver Clock Active
      aClkStopstate : out std_logic; --Lane is in Stop state 
      aClkEnable : in std_logic; --Enable Lane Module
      
      aClkUlpsActiveNot : out std_logic; --ULP State (not) Active
      aRxUlpsClkNot : out std_logic; --Receive Ultra-Low Power State on Clock Lane
      aClkForceRxmode : in std_logic; --Force Lane Module Into Receive mode / Wait for Stop state
      aClkErrControl : out std_logic; --Control Error  
      RxByteClkHS : out std_logic; --High-Speed Receive Byte Clock
      
      --Data lane 0      
      aD0Stopstate : out std_logic; --Lane is in Stop state
      aD0Enable : in std_logic; --Enable Lane Module
      aD0UlpsActiveNot : out std_logic; --ULP State (not) Active
      
      rbD0RxDataHS : out std_logic_vector(7 downto 0); --High-Speed Receive Data (least-significant first)
      rbD0RxValidHS : out std_logic; --High-Speed Receive Data Valid
      rbD0RxActiveHS : out std_logic; --High-Speed Reception Active
      rbD0RxSyncHS : out std_logic; --Receiver Synchronization Observed (pulse)

      rbD0ErrSotHS : out std_logic; --Start-of-Transmission (SoT) Error (pulse)
      rbD0ErrSotSyncHS : out std_logic; --Start-of-Transmission (SoT) Synchronization Error (pulse)
      
      aD0ForceRxmode : in std_logic; --Force Lane Module Into Receive mode / Wait for Stop state
            
      D0RxClkEsc : out std_logic; --Escape mode Receive Clock (not periodic)
      aD0RxDataEsc : out std_logic_vector(7 downto 0); --Escape mode Receive Data
      aD0RxValidEsc : out std_logic; --Escape mode Receive Data Valid
      aD0RxLpdtEsc : out std_logic; --Escape Low-Power Data Receive Mode
      
      aD0RxUlpsEsc : out std_logic; --Escape Ultra-Low Power (Receive) mode
      aD0RxTriggerEsc : out std_logic_vector(3 downto 0); --Escape mode Receive Trigger 3-0
      
      aD0ErrEsc : out std_logic; --Escape Entry Error
      aD0ErrControl : out std_logic; --Control Error
      
      --Data lane 1      
      aD1Stopstate : out std_logic; --Lane is in Stop state
      aD1Enable : in std_logic; --Enable Lane Module
      aD1UlpsActiveNot : out std_logic; --ULP State (not) Active
      
      rbD1RxDataHS : out std_logic_vector(7 downto 0); --High-Speed Receive Data (least-significant first)
      rbD1RxValidHS : out std_logic; --High-Speed Receive Data Valid
      rbD1RxActiveHS : out std_logic; --High-Speed Reception Active
      rbD1RxSyncHS : out std_logic; --Receiver Synchronization Observed (pulse)

      rbD1ErrSotHS : out std_logic; --Start-of-Transmission (SoT) Error (pulse)
      rbD1ErrSotSyncHS : out std_logic; --Start-of-Transmission (SoT) Synchronization Error (pulse)
      
      aD1ForceRxmode : in std_logic; --Force Lane Module Into Receive mode / Wait for Stop state
            
      D1RxClkEsc : out std_logic; --Escape mode Receive Clock (not periodic)
      aD1RxDataEsc : out std_logic_vector(7 downto 0); --Escape mode Receive Data
      aD1RxValidEsc : out std_logic; --Escape mode Receive Data Valid
      aD1RxLpdtEsc : out std_logic; --Escape Low-Power Data Receive Mode
      
      aD1RxUlpsEsc : out std_logic; --Escape Ultra-Low Power (Receive) mode
      aD1RxTriggerEsc : out std_logic_vector(3 downto 0); --Escape mode Receive Trigger 3-0
      
      aD1ErrEsc : out std_logic; --Escape Entry Error
      aD1ErrControl : out std_logic; --Control Error
  		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_AXI_LITE
		s_axi_lite_aclk	: in std_logic;
		s_axi_lite_aresetn	: in std_logic;
		s_axi_lite_awaddr	: in std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);
		s_axi_lite_awprot	: in std_logic_vector(2 downto 0);
		s_axi_lite_awvalid	: in std_logic;
		s_axi_lite_awready	: out std_logic;
		s_axi_lite_wdata	: in std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0);
		s_axi_lite_wstrb	: in std_logic_vector((C_S_AXI_LITE_DATA_WIDTH/8)-1 downto 0);
		s_axi_lite_wvalid	: in std_logic;
		s_axi_lite_wready	: out std_logic;
		s_axi_lite_bresp	: out std_logic_vector(1 downto 0);
		s_axi_lite_bvalid	: out std_logic;
		s_axi_lite_bready	: in std_logic;
		s_axi_lite_araddr	: in std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);
		s_axi_lite_arprot	: in std_logic_vector(2 downto 0);
		s_axi_lite_arvalid	: in std_logic;
		s_axi_lite_arready	: out std_logic;
		s_axi_lite_rdata	: out std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0);
		s_axi_lite_rresp	: out std_logic_vector(1 downto 0);
		s_axi_lite_rvalid	: out std_logic;
		s_axi_lite_rready	: in std_logic
	);
end component MIPI_DPHY_Receiver;

function max(l : time; r : time) return time is
begin
   if (l > r) then
      return l;
   else
      return r;
   end if;
end function max;

constant kUI : time := 2 ns; --500Mbps
constant kNoOfDataLanes : natural := 2;
constant kRefClkPeriod : time := 5 ns;
constant kTRst : time := 1us;
constant kT_LPX : time := 50 ns;
constant kT_HS_PREPARE : time := 40 ns + 4*kUI;
constant kT_HS_ZERO : time := 100 ns + 6*kUI;
constant kT_HS_TRAIL : time := max(1*8*kUI, 60 ns + 1*4*kUI);
constant kT_HS_EXIT : time := 100 ns;
constant kTInit      : time := 100 us;
constant kT_CLK_PREPARE : time := 38ns; --max 95ns
constant kT_CLK_ZERO : time := 300ns - kT_CLK_PREPARE;
constant kT_CLK_PRE : time := 8*kUI;
constant kT_CLK_POST : time := 60 ns + 52*kUI;
constant kT_CLK_TRAIL : time := 60ns;
constant kSyncSeq : std_logic_vector(7 downto 0) := "10111000"; --least significant bit

type mem is array (natural range <>) of std_logic_vector(15 downto 0);
constant data_stim : mem := (x"78CC", x"0F00",
            x"00FF", x"0200", x"DCB9", x"72F3", x"D4BB", x"5AB8", x"75C8", x"7CC2", x"F881", x"DF05", x"00FF", x"0100",
            x"00F0",
            
            --dummy data
            x"04fc", x"3729"
);

type vector1 is array (natural range <>) of std_logic;
type vector2 is array (natural range <>) of std_logic_vector(1 downto 0);
type vector4 is array (natural range <>) of std_logic_vector(3 downto 0);
type vector8 is array (natural range <>) of std_logic_vector(7 downto 0);

signal RefClk, aRst : std_logic := '0';

signal DPHY_DataHS : std_logic_vector(0 to kNoOfDataLanes-1);
signal DPHY_DataLP : vector2(0 to kNoOfDataLanes-1);
signal DPHY_ClkHS : std_logic;
signal DPHY_ClkLP : std_logic_vector(1 downto 0);

signal RxDDRClkHS, RxByteClkHS : std_logic;
signal aRxClkActiveHS, aClkStopstate, aClkUlpsActiveNot, aRxUlpsClkNot, aClkErrControl : std_logic;
signal aClkEnable, aClkForceRxmode : std_logic;

signal aDxStopstate, aDxForceRxmode, aDxEnable, aDxUlpsActiveNot, rbDxRxValidHS, rbDxRxActiveHS, rbDxRxSyncHS,
aDxErrEsc, aDxErrControl, rbDxErrSotHS, rbDxErrSotSyncHS : vector1(0 to kNoOfDataLanes-1);
signal rbDxRxDataHS : vector8(0 to kNoOfDataLanes-1);
signal fClockReady,fData0Ready, fData1Ready : boolean := false;

   procedure Stopstate(dur : in time; signal LP : out std_logic_vector(1 downto 0); signal HS : out std_logic) is
   begin
      LP <= "11";
      HS <= 'X';
      wait for dur;
   end procedure;
   
   procedure HS_Rqst(signal LP : out std_logic_vector(1 downto 0)) is
   begin
      LP <= "01";
      wait for kT_LPX;
   end procedure;

   procedure HS_Prepare(signal LP : out std_logic_vector(1 downto 0)) is
   begin
      LP <= "00";
      wait for kT_HS_PREPARE;
   end procedure;
   
   procedure HS_Zero(signal HS : out std_logic) is
   begin
      HS <= '0';
      wait for kT_HS_ZERO;
   end procedure;   

   procedure HS_Send0(nbits : in natural; signal HS : out std_logic) is
   begin
      for i in 0 to nbits-1 loop
         HS <= '0';
         wait until DPHY_ClkHS'event;
      end loop;
   end procedure;
   
   procedure HS_Send(byte : in std_logic_vector(7 downto 0);  signal HS : out std_logic) is
   begin
      for i in 0 to 7 loop
         wait for kUI / 2; --90deg phase difference between data and clock
         HS <= byte(i);
         wait until DPHY_ClkHS'event;
      end loop;   
   end procedure;
   
   procedure HS_Trail(signal HS : out std_logic) is
   begin
      wait for kUI / 2;
      HS <= '0';
      wait for kT_HS_TRAIL;
   end procedure;     
begin

--200MHz reference clock
RefClk <= not RefClk after kRefClkPeriod / 2;

--Startup reset
aRst <= '1', '0' after kTRst;

aClkEnable <= '0', '1' after kTRst;
aDxEnable(0) <= '0', '1' after kTRst;
aDxEnable(1) <= '0', '1' after kTRst;

aClkForceRxmode <= '0';
aDxForceRxmode(0) <= '0';
aDxForceRxmode(1) <= '0';

ClockStimulus: process
   procedure HS_Prepare is
   begin
      DPHY_ClkLP <= "00";
      wait for kT_CLK_PREPARE;
   end procedure;
   procedure HS_Zero is
   begin
      DPHY_ClkHS <= '0';
      wait for kT_CLK_ZERO;
   end procedure;
   procedure HS_ClkPrePost(t : in time) is
   variable start : time;
   begin
      start := now;
      loop
         DPHY_ClkHS <= not DPHY_ClkHS;
         wait for kUI;
         if (now - start > t) then
            exit;
         end if;
      end loop;
   end procedure;
   procedure HS_Trail is
   begin
      wait for kUI / 2;
      DPHY_ClkHS <= '0';
      wait for kT_CLK_TRAIL;
   end procedure;
begin

Stopstate(kTInit + 1 us, DPHY_ClkLP, DPHY_ClkHS);

HS_Rqst(DPHY_ClkLP);
HS_Prepare;
HS_Zero;
HS_ClkPrePost(kT_CLK_PRE);
fClockReady <= true;
loop
   DPHY_ClkHS <= not DPHY_ClkHS;
   wait for kUI;
   if (fData0Ready and fData1Ready) then
      exit;
   end if;
end loop;
HS_ClkPrePost(kT_CLK_POST);
HS_Trail;
Stopstate(kT_HS_EXIT, DPHY_ClkLP, DPHY_ClkHS);
wait;
end process ClockStimulus;


DataStimulus0: process
   variable seed1, seed2: positive;               -- seed values for random generator
   variable rand: real;   -- random real-number value in range 0 to 1.0  
   variable range_of_rand : real := 10.0;    -- the range of random values created will be 0 to +1000.
   variable to_send : natural;
begin

   Stopstate(kTInit + 1 us, DPHY_DataLP(0), DPHY_DataHS(0));
   wait until fClockReady; 
   HS_Rqst(DPHY_DataLP(0));
   HS_Prepare(DPHY_DataLP(0));
   wait for kUI; -- this will test different word alignments
   HS_Zero(DPHY_DataHS(0));
   wait until Falling_Edge(DPHY_ClkHS);
   HS_Send(kSyncSeq, DPHY_DataHS(0));
   uniform(seed1, seed2, rand);   -- generate random number
   for j in data_stim'range loop
      HS_Send(data_stim(j)(7 downto 0), DPHY_DataHS(0)); 
   end loop;
--   for j in 0 to integer(rand*range_of_rand) loop
--      case (j) is
--         when 0 => HS_Send(x"DE",DPHY_DataHS(0));
--         when 1 => HS_Send(x"AD",DPHY_DataHS(0));
--         when 2 => HS_Send(x"BE",DPHY_DataHS(0));
--         when 3 => HS_Send(x"EF",DPHY_DataHS(0));
--         when others => HS_Send(std_logic_vector(to_unsigned(j-4,8)), DPHY_DataHS(0));
--      end case;
--   end loop;
   HS_Trail(DPHY_DataHS(0));
   Stopstate(kT_HS_EXIT, DPHY_DataLP(0), DPHY_DataHS(0));

   HS_Rqst(DPHY_DataLP(0));
   HS_Prepare(DPHY_DataLP(0));
   wait for kUI; -- this will test different word alignments
   HS_Zero(DPHY_DataHS(0));
   wait until Falling_Edge(DPHY_ClkHS);
   HS_Send(kSyncSeq, DPHY_DataHS(0));
   uniform(seed1, seed2, rand);   -- generate random number
   for j in data_stim'range loop
      HS_Send(data_stim(j)(7 downto 0), DPHY_DataHS(0)); 
   end loop;
--   for j in 0 to integer(rand*range_of_rand) loop
--      case (j) is
--         when 0 => HS_Send(x"DE",DPHY_DataHS(0));
--         when 1 => HS_Send(x"AD",DPHY_DataHS(0));
--         when 2 => HS_Send(x"BE",DPHY_DataHS(0));
--         when 3 => HS_Send(x"EF",DPHY_DataHS(0));
--         when others => HS_Send(std_logic_vector(to_unsigned(j-4,8)), DPHY_DataHS(0));
--      end case;
--   end loop;
   HS_Trail(DPHY_DataHS(0));
   Stopstate(kT_HS_EXIT, DPHY_DataLP(0), DPHY_DataHS(0));   
   fData0Ready <= true;
wait;

end process DataStimulus0;

DataStimulus1: process
   variable seed1, seed2: positive;               -- seed values for random generator
   variable rand: real;   -- random real-number value in range 0 to 1.0  
   variable range_of_rand : real := 10.0;    -- the range of random values created will be 0 to +1000.
   variable to_send : natural;
begin

   Stopstate(kTInit + 1 us, DPHY_DataLP(1), DPHY_DataHS(1));
   wait until fClockReady; 
   HS_Rqst(DPHY_DataLP(1));
   HS_Prepare(DPHY_DataLP(1));
   wait for kUI; -- this will test different word alignments
   HS_Zero(DPHY_DataHS(1));
   wait until Falling_Edge(DPHY_ClkHS);
   HS_Send(kSyncSeq, DPHY_DataHS(1));
   uniform(seed1, seed2, rand);   -- generate random number
   for j in data_stim'range loop
      HS_Send(data_stim(j)(15 downto 8), DPHY_DataHS(1)); 
   end loop;
--   for j in 0 to integer(rand*range_of_rand) loop
--      case (j) is
--         when 0 => HS_Send(x"DE",DPHY_DataHS(1));
--         when 1 => HS_Send(x"AD",DPHY_DataHS(1));
--         when 2 => HS_Send(x"BE",DPHY_DataHS(1));
--         when 3 => HS_Send(x"EF",DPHY_DataHS(1));
--         when others => HS_Send(std_logic_vector(to_unsigned(j-4,8)), DPHY_DataHS(1));
--      end case;
--   end loop;
   HS_Trail(DPHY_DataHS(1));
   Stopstate(kT_HS_EXIT, DPHY_DataLP(1), DPHY_DataHS(1));
   
   HS_Rqst(DPHY_DataLP(1));
   HS_Prepare(DPHY_DataLP(1));
   wait for kUI; -- this will test different word alignments
   HS_Zero(DPHY_DataHS(1));
   wait until Falling_Edge(DPHY_ClkHS);
   HS_Send(kSyncSeq, DPHY_DataHS(1));
   uniform(seed1, seed2, rand);   -- generate random number
   for j in data_stim'range loop
      HS_Send(data_stim(j)(15 downto 8), DPHY_DataHS(1)); 
   end loop;
--   for j in 0 to integer(rand*range_of_rand) loop
--      case (j) is
--         when 0 => HS_Send(x"DE",DPHY_DataHS(1));
--         when 1 => HS_Send(x"AD",DPHY_DataHS(1));
--         when 2 => HS_Send(x"BE",DPHY_DataHS(1));
--         when 3 => HS_Send(x"EF",DPHY_DataHS(1));
--         when others => HS_Send(std_logic_vector(to_unsigned(j-4,8)), DPHY_DataHS(1));
--      end case;
--   end loop;
   HS_Trail(DPHY_DataHS(1));
   Stopstate(kT_HS_EXIT, DPHY_DataLP(1), DPHY_DataHS(1));
   
   fData1Ready <= true;
wait;

end process DataStimulus1;

DUT: MIPI_DPHY_Receiver
	generic map (
        kNoOfDataLanes => kNoOfDataLanes,
        kDebug => false,
        kSharedLogic => true,
        kGenerateMMCM => false,
        kAddDelayClk_ps => 0,
        kAddDelayData0_ps => 0,
        kAddDelayData1_ps => -500
	)
	port map (
      dphy_clk_hs_p => DPHY_ClkHS, 
      dphy_clk_hs_n => not DPHY_ClkHS,
      dphy_clk_lp_n => DPHY_ClkLP(0), --Dn is LP(0)
      dphy_clk_lp_p => DPHY_ClkLP(1), --Dp is LP(1)
      
      dphy_data_hs_p => DPHY_DataHS,
      dphy_data_hs_n => not DPHY_DataHS,
      dphy_data_lp_n => DPHY_DataLP(0)(0) & DPHY_DataLP(1)(0), --Dn is LP(0)
      dphy_data_lp_p => DPHY_DataLP(0)(1) & DPHY_DataLP(1)(1), --Dp is LP(1)
      
      RefClk => RefClk,
      aRst => aRst,
      rDlyCtrlLockedIn => '0', --unused if kSharedLogic=true
      
      --PHY-Protocol Interface (PPI)
      --Clock lane
      RxDDRClkHS => RxDDRClkHS, --Receiver DDR Clock (may be used by the protocol)
      aRxClkActiveHS => aRxClkActiveHS, --Receiver Clock Active
      aClkStopstate => aClkStopstate, --Lane is in Stop state 
      aClkEnable => aClkEnable, --Enable Lane Module
      
      aClkUlpsActiveNot => aClkUlpsActiveNot, --ULP State (not) Active
      aRxUlpsClkNot => aRxUlpsClkNot, --Receive Ultra-Low Power State on Clock Lane
      aClkForceRxmode => aClkForceRxmode, --Force Lane Module Into Receive mode / Wait for Stop state
      aClkErrControl => aClkErrControl, --Control Error  
      RxByteClkHS => RxByteClkHS, --High-Speed Receive Byte Clock
      
      --Data lane 0      
      aD0Stopstate => aDxStopstate(0), --Lane is in Stop state
      aD0Enable => aDxEnable(0), --Enable Lane Module
      aD0UlpsActiveNot => aDxUlpsActiveNot(0), --ULP State (not) Active
      
      rbD0RxDataHS => rbDxRxDataHS(0), --High-Speed Receive Data (least-significant first)
      rbD0RxValidHS => rbDxRxValidHS(0), --High-Speed Receive Data Valid
      rbD0RxActiveHS => rbDxRxActiveHS(0), --High-Speed Reception Active
      rbD0RxSyncHS => rbDxRxSyncHS(0), --Receiver Synchronization Observed (pulse)

      rbD0ErrSotHS => rbDxErrSotHS(0), --Start-of-Transmission (SoT) Error (pulse)
      rbD0ErrSotSyncHS => rbDxErrSotSyncHS(0), --Start-of-Transmission (SoT) Synchronization Error (pulse)
      
      aD0ForceRxmode => aDxForceRxmode(0), --Force Lane Module Into Receive mode / Wait for Stop state
            
      D0RxClkEsc => open, --Escape mode Receive Clock (not periodic)
      aD0RxDataEsc => open, --Escape mode Receive Data
      aD0RxValidEsc => open, --Escape mode Receive Data Valid
      aD0RxLpdtEsc => open, --Escape Low-Power Data Receive Mode
      
      aD0RxUlpsEsc => open, --Escape Ultra-Low Power (Receive) mode
      aD0RxTriggerEsc => open, --Escape mode Receive Trigger 3-0
      
      aD0ErrEsc => aDxErrEsc(0), --Escape Entry Error
      aD0ErrControl => aDxErrControl(0), --Control Error
      
      --Data lane 1      
      aD1Stopstate => aDxStopstate(1), --Lane is in Stop state
      aD1Enable => aDxEnable(1), --Enable Lane Module
      aD1UlpsActiveNot => aDxUlpsActiveNot(1), --ULP State (not) Active
      
      rbD1RxDataHS => rbDxRxDataHS(1), --High-Speed Receive Data (least-significant first)
      rbD1RxValidHS => rbDxRxValidHS(1), --High-Speed Receive Data Valid
      rbD1RxActiveHS => rbDxRxActiveHS(1), --High-Speed Reception Active
      rbD1RxSyncHS => rbDxRxSyncHS(1), --Receiver Synchronization Observed (pulse)

      rbD1ErrSotHS => rbDxErrSotHS(1), --Start-of-Transmission (SoT) Error (pulse)
      rbD1ErrSotSyncHS => rbDxErrSotSyncHS(1), --Start-of-Transmission (SoT) Synchronization Error (pulse)
      
      aD1ForceRxmode => aDxForceRxmode(1), --Force Lane Module Into Receive mode / Wait for Stop state
            
      D1RxClkEsc => open, --Escape mode Receive Clock (not periodic)
      aD1RxDataEsc => open, --Escape mode Receive Data
      aD1RxValidEsc => open, --Escape mode Receive Data Valid
      aD1RxLpdtEsc => open, --Escape Low-Power Data Receive Mode
      
      aD1RxUlpsEsc => open, --Escape Ultra-Low Power (Receive) mode
      aD1RxTriggerEsc => open, --Escape mode Receive Trigger 3-0
      
      aD1ErrEsc => aDxErrEsc(1), --Escape Entry Error
      aD1ErrControl => aDxErrControl(1), --Control Error

--		-- Ports of Axi Slave Bus Interface S_AXI_LITE
		s_axi_lite_aclk	   => '0',
		s_axi_lite_aresetn	=> '0',
		s_axi_lite_awaddr	=> (others => '0'),
		s_axi_lite_awprot	=> (others => '0'),
		s_axi_lite_awvalid	=> '0',
		s_axi_lite_awready	=> open,
		s_axi_lite_wdata	=> (others => '0'),
		s_axi_lite_wstrb	=> (others => '0'),
		s_axi_lite_wvalid	=> '0',
		s_axi_lite_wready	=> open,
		s_axi_lite_bresp	=> open,
		s_axi_lite_bvalid	=> open,
		s_axi_lite_bready	=> '0',
		s_axi_lite_araddr	=> (others => '0'),
		s_axi_lite_arprot	=> (others => '0'),
		s_axi_lite_arvalid	=> '0',
		s_axi_lite_arready	=> open,
		s_axi_lite_rdata	=> open,
		s_axi_lite_rresp	=> open,
		s_axi_lite_rvalid	=> open,
		s_axi_lite_rready	=> '0'
	);

end Behavioral;
