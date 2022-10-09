-------------------------------------------------------------------------------
--
-- File: MIPI_DPHY_Receiver.vhd
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
-- The MIPI_DPHY_Receiver IP is an implementation of a subset of the PHY-level
-- protocol of the MIPI D-PHY 1.0 specification. It bundles a SCNN clock lane
-- and one or more SFEN data lanes to implement the reciever end of a Lane
-- Interconnect. In an FPGA implementation of the communication stack
-- it occupies the lowest level. On top of it, over the PHY-Protocol Interface
-- (PPI) connects the protocol layer specific to the application, like the Camera
-- Serial Interface (CSI).
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

use work.DPHY_types.ALL;
use work.DebugLib.all;

entity MIPI_DPHY_Receiver is
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
end MIPI_DPHY_Receiver;

architecture arch_imp of MIPI_DPHY_Receiver is

function MIN(LEFT, RIGHT: INTEGER) return INTEGER is
begin
  if LEFT < RIGHT then return LEFT;
  else return RIGHT;
  end if;
end;
  
constant kDlyRstDelay : natural := 32;
constant kGenerateIDELAYCTRL : boolean := kSharedLogic;

constant kCtlClkFreqHz : natural := kRefClkFreqHz;


--make all delays positive
constant kDelayAdjust : integer := MIN(kAddDelayClk_ps, MIN(kAddDelayData0_ps, kAddDelayData1_ps));
constant kAddAdjDelayClk_ps : integer := kAddDelayClk_ps - kDelayAdjust;
constant kAddAdjDelayData0_ps : integer := kAddDelayData0_ps - kDelayAdjust;
constant kAddAdjDelayData1_ps : integer := kAddDelayData1_ps - kDelayAdjust;

type dataLaneHSType is array(kNoOfDataLanes-1 downto 0) of std_logic;
type dataLaneLPType is array(kNoOfDataLanes-1 downto 0) of std_logic_vector(1 downto 0);
type dataLaneWordType is array(kNoOfDataLanes-1 downto 0) of std_logic_vector(7 downto 0);

type dLP_int_t is array (kNoOfDataLanes-1 downto 0) of std_logic_vector(7 downto 0);
signal dLP0_in, dLP1_in, dLP0_out, dLP1_out : dLP_int_t;

signal HS_Clock   : std_logic;
signal HS_Data    : dataLaneHSType;
signal LP_Clock   : std_logic_vector(1 downto 0);
signal aLPBuf, cLP_in, cLP_out    : dataLaneLPType;

signal dDataWord : dataLaneWordType;
signal dDataAligned : dataLaneHSType;

signal RxDDRClkHS_int, RxByteClkHS_int, aRxClkActiveHS_int : std_logic;
signal cHSClkLocked : std_logic;
signal xEnable, xSoftRst  : std_logic;

signal rDlyLckd, rDlyRst, rExtRst, rSoftRst, rSoftEnable, rIntRst : std_logic;
signal rDlyRstCnt : natural range 0 to kDlyRstDelay - 1 := kDlyRstDelay - 1;
signal aLaneSCNNEnable : std_logic;
signal aLaneSFENEnable : std_logic_vector(kNoOfDataLanes-1 downto 0);

type PPIRxLaneType is record
   aStopstate : std_logic; --Lane is in Stop state
   aEnable : std_logic; --Enable Lane Module
   aUlpsActiveNot : std_logic; --ULP State (not) Active
   
   rbRxDataHS : std_logic_vector(7 downto 0); --High-Speed Receive Data (least-significant first)
   rbRxValidHS : std_logic; --High-Speed Receive Data Valid
   rbRxActiveHS : std_logic; --High-Speed Reception Active
   rbRxSyncHS : std_logic; --Receiver Synchronization Observed (pulse)

   rbErrSotHS : std_logic; --Start-of-Transmission (SoT) Error (pulse)
   rbErrSotSyncHS : std_logic; --Start-of-Transmission (SoT) Synchronization Error (pulse)
   
   aForceRxmode : std_logic; --Force Lane Module Into Receive mode / Wait for Stop state
         
   RxClkEsc : std_logic; --Escape mode Receive Clock (not periodic)
   aRxDataEsc : std_logic_vector(7 downto 0); --Escape mode Receive Data
   aRxValidEsc : std_logic; --Escape mode Receive Data Valid
   aRxLpdtEsc : std_logic; --Escape Low-Power Data Receive Mode
   
   aRxUlpsEsc : std_logic; --Escape Ultra-Low Power (Receive) mode
   aRxTriggerEsc : std_logic_vector(3 downto 0); --Escape mode Receive Trigger 3-0
   
   aErrEsc : std_logic; --Escape Entry Error
   aErrControl : std_logic; --Control Error
end record PPIRxLaneType;
type PPIRxType is array(kNoOfDataLanes-1 downto 0) of PPIRxLaneType;
signal SFEN_Lanes : PPIRxType;

signal debugSCNN : DebugSCNN_Type;
type DebugSFEN_Lanes_Type is array(kNoOfDataLanes-1 downto 0) of DebugSFEN_Type;
signal debugSFEN : DebugSFEN_Lanes_Type;

signal rTrigOut : std_logic;
signal rTrigInAck, rSFEN_TrigOut, rbSFEN_TrigOut, rbSFEN_TrigInAck, rSFEN_TrigInAck : std_logic_vector(kNoOfDataLanes-1 downto 0);

begin
-------------------------------------------------------------------------------
-- Map PPI ports to array type signals for easier module instantiation below
-------------------------------------------------------------------------------
PPIGen1: if kNoOfDataLanes >= 1 generate
   aD0Stopstate <= SFEN_Lanes(0).aStopstate;
   SFEN_Lanes(0).aEnable <= aD0Enable;
   aD0UlpsActiveNot <= SFEN_Lanes(0).aUlpsActiveNot;
   
   rbD0RxDataHS <= SFEN_Lanes(0).rbRxDataHS;
   rbD0RxValidHS <= SFEN_Lanes(0).rbRxValidHS; 
   rbD0RxActiveHS <= SFEN_Lanes(0).rbRxActiveHS;
   rbD0RxSyncHS <= SFEN_Lanes(0).rbRxSyncHS;
   
   rbD0ErrSotHS <= SFEN_Lanes(0).rbErrSotHS;
   rbD0ErrSotSyncHS <= SFEN_Lanes(0).rbErrSotSyncHS;
   
   SFEN_Lanes(0).aForceRxmode <= aD0ForceRxmode;
         
   D0RxClkEsc <= SFEN_Lanes(0).RxClkEsc;
   aD0RxDataEsc <= SFEN_Lanes(0).aRxDataEsc;
   aD0RxValidEsc <= SFEN_Lanes(0).aRxValidEsc;
   aD0RxLpdtEsc <= SFEN_Lanes(0).aRxLpdtEsc;
   
   aD0RxUlpsEsc <= SFEN_Lanes(0).aRxUlpsEsc;
   aD0RxTriggerEsc <= SFEN_Lanes(0).aRxTriggerEsc;
   
   aD0ErrEsc <= SFEN_Lanes(0).aErrEsc;
   aD0ErrControl <= SFEN_Lanes(0).aErrControl;
end generate;
PPIGen2: if kNoOfDataLanes >= 2 generate
   aD1Stopstate <= SFEN_Lanes(1).aStopstate;
   SFEN_Lanes(1).aEnable <= aD1Enable;
   aD1UlpsActiveNot <= SFEN_Lanes(1).aUlpsActiveNot;
   
   rbD1RxDataHS <= SFEN_Lanes(1).rbRxDataHS;
   rbD1RxValidHS <= SFEN_Lanes(1).rbRxValidHS; 
   rbD1RxActiveHS <= SFEN_Lanes(1).rbRxActiveHS;
   rbD1RxSyncHS <= SFEN_Lanes(1).rbRxSyncHS;
   
   rbD1ErrSotHS <= SFEN_Lanes(1).rbErrSotHS;
   rbD1ErrSotSyncHS <= SFEN_Lanes(1).rbErrSotSyncHS;
   
   SFEN_Lanes(1).aForceRxmode <= aD1ForceRxmode;
         
   D1RxClkEsc <= SFEN_Lanes(1).RxClkEsc;
   aD1RxDataEsc <= SFEN_Lanes(1).aRxDataEsc;
   aD1RxValidEsc <= SFEN_Lanes(1).aRxValidEsc;
   aD1RxLpdtEsc <= SFEN_Lanes(1).aRxLpdtEsc;
   
   aD1RxUlpsEsc <= SFEN_Lanes(1).aRxUlpsEsc;
   aD1RxTriggerEsc <= SFEN_Lanes(1).aRxTriggerEsc;
   
   aD1ErrEsc <= SFEN_Lanes(1).aErrEsc;
   aD1ErrControl <= SFEN_Lanes(1).aErrControl;
end generate;

-------------------------------------------------------------------------------
-- AXI-Lite interface for control and status
-------------------------------------------------------------------------------
YesAXILITE: if kGenerateAXIL generate
   AXI_Lite_Control: entity work.MIPI_DPHY_Receiver_S_AXI_Lite
      generic map (
         kVersionMajor        => kVersionMajor,
         kVersionMinor        => kVersionMinor,
         C_S_AXI_DATA_WIDTH	=> C_S_AXI_LITE_DATA_WIDTH,
         C_S_AXI_ADDR_WIDTH	=> C_S_AXI_LITE_ADDR_WIDTH
      )
      port map (
         xEnable => xEnable,
         xRst => xSoftRst,
         S_AXI_ACLK	=> s_axi_lite_aclk,
         S_AXI_ARESETN	=> s_axi_lite_aresetn,
         S_AXI_AWADDR	=> s_axi_lite_awaddr,
         S_AXI_AWPROT	=> s_axi_lite_awprot,
         S_AXI_AWVALID	=> s_axi_lite_awvalid,
         S_AXI_AWREADY	=> s_axi_lite_awready,
         S_AXI_WDATA	=> s_axi_lite_wdata,
         S_AXI_WSTRB	=> s_axi_lite_wstrb,
         S_AXI_WVALID	=> s_axi_lite_wvalid,
         S_AXI_WREADY	=> s_axi_lite_wready,
         S_AXI_BRESP	=> s_axi_lite_bresp,
         S_AXI_BVALID	=> s_axi_lite_bvalid,
         S_AXI_BREADY	=> s_axi_lite_bready,
         S_AXI_ARADDR	=> s_axi_lite_araddr,
         S_AXI_ARPROT	=> s_axi_lite_arprot,
         S_AXI_ARVALID	=> s_axi_lite_arvalid,
         S_AXI_ARREADY	=> s_axi_lite_arready,
         S_AXI_RDATA	=> s_axi_lite_rdata,
         S_AXI_RRESP	=> s_axi_lite_rresp,
         S_AXI_RVALID	=> s_axi_lite_rvalid,
         S_AXI_RREADY	=> s_axi_lite_rready
      );
CoreSoftReset: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => xSoftRst,
      OutClk => RefClk,
      oRst => rSoftRst);
SyncAsyncClkEnable: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => '0', --lane-level enable
      aIn => xEnable,
      OutClk => RefClk,
      oOut => rSoftEnable);      
end generate;

NoAXILITE: if not kGenerateAXIL generate
   rSoftEnable <= '1';
   rSoftRst <= '0';
end generate;

-- We need a reset bridge to use the asynchronous aRst signal to reset our circuitry
-- and decrease the chance of metastability. The signal rExtRst can be used as
-- asynchronous reset for any flip-flop in the RefClk domain, since it will be de-asserted
-- synchronously.
CoreAsyncReset: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => aRst,
      OutClk => RefClk,
      oRst => rExtRst);

rIntRst <= rSoftRst or rExtRst;      
-------------------------------------------------------------------------------
-- IDELAYCTRL needed by the IDELAYE2 primitives on the data lanes
-------------------------------------------------------------------------------
GenIDELAYCTRL: if (kGenerateIDELAYCTRL) generate
   --IDELAYCTRL must be reset after configuration or refclk lost for 52ns(K7), 72ns(A7) at least
   ResetIDELAYCTRL: process(rIntRst, RefClk)
   begin
      if Rising_Edge(RefClk) then
         if (rIntRst = '1') then
            rDlyRstCnt <= kDlyRstDelay - 1;
            rDlyRst <= '1';
         elsif (rDlyRstCnt /= 0) then
            rDlyRstCnt <= rDlyRstCnt - 1;
         else
            rDlyRst <= '0';
         end if;
      end if;
   end process;

   IDelayCtrlX: IDELAYCTRL
      port map (
         RDY         => rDlyLckd,
         REFCLK      => RefClk,
         RST         => rDlyRst);

    rDlyCtrlLockedOut <= rDlyLckd;
    
end generate GenIDELAYCTRL;

GenNoIDELAYCTRL: if (not kGenerateIDELAYCTRL) generate
   rDlyLckd <= not rIntRst and rDlyCtrlLockedIn;
end generate GenNoIDELAYCTRL;

-------------------------------------------------------------------------------
-- Clock lane modules: enable, input buffer, D-PHY SCNN module
-------------------------------------------------------------------------------
aLaneSCNNEnable <= aClkEnable and rSoftEnable and rDlyLckd;
   
ClockInputBuffer: entity work.InputBuffer
   Port map (
      HS_p => dphy_clk_hs_p,
      HS_n => dphy_clk_hs_n,
      LP_n => dphy_clk_lp_n,
      LP_p => dphy_clk_lp_p,
      
      aHS => HS_Clock,
      aLP => LP_Clock 
   );
ClockLane: entity work.DPHY_LaneSCNN
   Generic map (
      kGenerateMMCM => false,
      kRefClkFreqHz => kRefClkFreqHz,      
      kAddDelay_ps => kAddAdjDelayClk_ps
   )
   Port map (
      aLP => LP_Clock,
      aHS => HS_Clock,
      RefClk => RefClk,
      
      RxDDRClkHS => RxDDRClkHS_int,
      RxByteClkHS => RxByteClkHS_int,
      aRxClkActiveHS => aRxClkActiveHS_int,
      aForceRxmode => aClkForceRxmode,
      aStopstate => aClkStopstate,
      aEnable => aLaneSCNNEnable,
      aRxUlpsClkNot => aRxUlpsClkNot,
      aUlpsActiveNot => aClkUlpsActiveNot,
      
      debug => debugSCNN
   );

-------------------------------------------------------------------------------
-- Date lane modules: enable, input buffer, D-PHY SFEN module
-------------------------------------------------------------------------------   
DataLaneGen: for i in kNoOfDataLanes-1 downto 0 generate
   InputBufferDataX: entity work.InputBuffer
      Generic map (
         kNoLP => kLPFromLane0 and i /= 0
      )
      Port map (
         HS_p => dphy_data_hs_p(i),
         HS_n => dphy_data_hs_n(i),
         LP_n => dphy_data_lp_n(i),
         LP_p => dphy_data_lp_p(i),
         
         aHS => HS_Data(i),
         aLP => aLPBuf(i) 
      );
   aLaneSFENEnable(i) <= SFEN_Lanes(i).aEnable and rSoftEnable and rDlyLckd;
      
   DPHY_LaneSFEN_X: entity work.DPHY_LaneSFEN
      Generic map (
         kRefClkFreqHz => kRefClkFreqHz,
         kAddDelay_ps => kAddAdjDelayData0_ps,
         kNoLP => kLPFromLane0 and i /= 0
      )
      Port map (
         dLP0_in => dLP0_in(i),
         dLP1_in => dLP1_in(i),
          
         dLP0_out => dLP0_out(i),
         dLP1_out => dLP1_out(i),
         
         cLP_in => cLP_in(i),
         cLP_out => cLP_out(i),
         
         aLP => aLPBuf(i),
         aHS => HS_Data(i),
         RefClk => RefClk,
         
         SerClkHS => RxDDRClkHS_int,
         DivClk => RxByteClkHS_int,
         aRxClkActiveHS => aRxClkActiveHS_int,
         
         --PPI
         RxByteClkHS => open, --see RxByteClkHS_int below
         rbRxDataHS => SFEN_Lanes(i).rbRxDataHS,
         rbRxValidHS => SFEN_Lanes(i).rbRxValidHS,
         rbRxActiveHS => SFEN_Lanes(i).rbRxActiveHS,
         rbRxSyncHS => SFEN_Lanes(i).rbRxSyncHS,
         rbErrSotHS => SFEN_Lanes(i).rbErrSotHS,
         rbErrSotSyncHS => SFEN_Lanes(i).rbErrSotSyncHS,
         
         aEnable => aLaneSFENEnable(i),
         aStopstate => SFEN_Lanes(i).aStopstate,
         aForceRxmode => SFEN_Lanes(i).aForceRxmode,
         aErrEsc => SFEN_Lanes(i).aErrEsc,
         aErrControl => SFEN_Lanes(i).aErrControl,
         
         debug => debugSFEN(i)
      );

ShareLPFromOtherLane: if kLPFromLane0 and i /= 0 generate
    dLP0_in(i) <= dLP0_out(0);
    dLP1_in(i) <= dLP0_out(0);
    cLP_in(i) <= cLP_out(0);
end generate ShareLPFromOtherLane;

      --D0RxClkEsc <=
      --aD0RxDataEsc <=
      --aD0RxValidEsc <=
      --aD0RxLpdtEsc <=
      
      --aD0RxUlpsEsc <=
      --aD0RxTriggerEsc <=
end generate DataLaneGen;

-- We output a single divided clock common for all data lanes 
RxByteClkHS <= RxByteClkHS_int;
RxDDRClkHS <= RxDDRClkHS_int;
aRxClkActiveHS <= aRxClkActiveHS_int;

----------------------------------------------------------------------------------
-- Debug modules
----------------------------------------------------------------------------------
GenerateDebug: if kDebug generate

ILA_SCNN_RefClkX : ila_scnn_refclk
PORT MAP (
	clk => RefClk,

	trig_out => rTrigOut,
	trig_out_ack => rTrigInAck(0),

	probe0(0) => debugSCNN.cIntRst, 
	probe1 => debugSCNN.cLP, 
	probe2(0) => debugSCNN.cHSRst, 
	probe3(0) => debugSCNN.cHSClkLocked, 
	probe4 => debugSCNN.state, 
	probe5(0) => debugSCNN.cClkSettleTout, 
	probe6(0) => debugSCNN.cBUFR_Rst, 
	probe7(0) => debugSCNN.cMMCM_Rst, 
	probe8(0) => debugSCNN.cMMCM_RstTout,
	probe9(0) => debugSCNN.cMMCM_Locked
);

ILA_SFEN_Gen: for i in kNoOfDataLanes-1 downto 0 generate      
ILA_SFEN_RefClkX : ila_sfen_refclk
   PORT MAP (
      clk => RefClk,
      trig_out => rSFEN_TrigOut(i),
      trig_out_ack => rSFEN_TrigInAck(i),
      trig_in => rTrigOut,
      trig_in_ack => rTrigInAck(i),
      probe0(0) => debugSFEN(i).cIntRst, 
      probe1 => debugSFEN(i).cLP, 
      probe2 => debugSFEN(i).state, 
      probe3(0) => debugSFEN(i).cHSClkRst, 
      probe4(0) => debugSFEN(i).cForceRxmode, 
      probe5(0) => debugSFEN(i).cInitTout, 
      probe6(0) => debugSFEN(i).cHSSettleTout, 
      probe7(0) => debugSFEN(i).cHSSettled,
      probe8(0) => debugSFEN(i).cHSReset
   );

SyncAsyncTrigAck: entity work.SyncAsync
   port map (
      aReset => '0',
      aIn => rbSFEN_TrigInAck(i),
      OutClk => RefClk,
      oOut => rSFEN_TrigInAck(i));
      
SyncAsyncTrigOut: entity work.SyncAsync
   port map (
      aReset => '0',
      aIn => rSFEN_TrigOut(i),
      OutClk => RxByteClkHS_int,
      oOut => rbSFEN_TrigOut(i));
      
ILA_SFEN_RxClkX : ila_sfen_rxclk
PORT MAP (
	clk => RxByteClkHS_int,

	trig_in => rbSFEN_TrigOut(i),
	trig_in_ack => rbSFEN_TrigInAck(i),
	probe0(0) => debugSFEN(i).dSyncHard, 
	probe1(0) => debugSFEN(i).dSyncSoft, 
	probe2(0) => debugSFEN(i).dSyncErr, 
	probe3(0) => SFEN_Lanes(i).rbRxActiveHS, 
	probe4(0) => SFEN_Lanes(i).rbRxSyncHS, 
	probe5(0) => SFEN_Lanes(i).rbRxValidHS, 
	probe6(0) => SFEN_Lanes(i).rbErrSotHS, 
	probe7(0) => SFEN_Lanes(i).rbErrSotSyncHS,
	probe8 => SFEN_Lanes(i).rbRxDataHS
);
end generate ILA_SFEN_Gen;
end generate;

end arch_imp;
