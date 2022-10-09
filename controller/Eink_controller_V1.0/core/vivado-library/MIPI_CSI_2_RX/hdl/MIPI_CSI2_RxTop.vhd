-------------------------------------------------------------------------------
--
-- File: MIPI_CSI2_RxTop.vhd
-- Author: Elod Gyorgy
-- Original Project: MIPI CSI-2 Receiver IP
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mipi_csi2_rx_top is
   Generic (
      kVersionMajor : natural := 0; -- TCL-propagated from VLNV
      kVersionMinor : natural := 0; -- TCL-propagated from VLNV
      kTargetDT : string := "RAW10";
      kGenerateAXIL : boolean := false;
      kDebug : boolean := true; 
      
      --PPI
      kLaneCount : natural range 1 to 4 := 2; --[1,2,4]
      --Video Format
      C_M_AXIS_COMPONENT_WIDTH : natural := 10; -- [8,10]
      C_M_AXIS_TDATA_WIDTH : natural := 40;
      C_M_MAX_SAMPLES_PER_CLOCK : natural := 4;
		-- Parameters of Axi Slave Bus Interface S_AXI_LITE
      C_S_AXI_LITE_DATA_WIDTH   : integer   := 32;
      C_S_AXI_LITE_ADDR_WIDTH   : integer   := 4
   );
   Port ( 
      --PPI
      RxByteClkHS : in STD_LOGIC;
      aClkStopstate : in std_logic;
      aRxClkActiveHS : in std_logic;
      
      RxDataHSD0 : in  STD_LOGIC_VECTOR (7 downto 0);
      RxSyncHSD0 : in  STD_LOGIC;
      RxValidHSD0 : in  STD_LOGIC;
      RxActiveHSD0 : in  STD_LOGIC;
      aD0Enable : out STD_LOGIC;
      
      RxDataHSD1 : in  STD_LOGIC_VECTOR (7 downto 0);
      RxSyncHSD1 : in  STD_LOGIC;
      RxValidHSD1 : in  STD_LOGIC;
      RxActiveHSD1 : in  STD_LOGIC;
      aD1Enable : out STD_LOGIC;
      
      RxDataHSD2 : in  STD_LOGIC_VECTOR (7 downto 0);
      RxSyncHSD2 : in  STD_LOGIC;
      RxValidHSD2 : in  STD_LOGIC;
      RxActiveHSD2 : in  STD_LOGIC;
      aD2Enable : out STD_LOGIC;
      
      RxDataHSD3 : in  STD_LOGIC_VECTOR (7 downto 0);
      RxSyncHSD3 : in  STD_LOGIC;
      RxValidHSD3 : in  STD_LOGIC;
      RxActiveHSD3 : in  STD_LOGIC;
      aD3Enable : out STD_LOGIC;      
      aClkEnable : out STD_LOGIC;
      
      --axi stream signals
      m_axis_video_tdata    : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
      m_axis_video_tvalid   : out std_logic;
      m_axis_video_tready   : in std_logic;
      m_axis_video_tlast    : out std_logic;
      m_axis_video_tuser    : out std_logic_vector(0 downto 0);
      
      video_aresetn        : in std_logic; --available when the AXI-Lite interface is disabled
      video_aclk           : in std_logic;
      
		-- Ports of Axi Slave Bus Interface S_AXI_LITE
      s_axi_lite_aclk   : in std_logic;
      s_axi_lite_aresetn   : in std_logic;
      s_axi_lite_awaddr   : in std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);
      s_axi_lite_awprot   : in std_logic_vector(2 downto 0);
      s_axi_lite_awvalid   : in std_logic;
      s_axi_lite_awready   : out std_logic;
      s_axi_lite_wdata   : in std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0);
      s_axi_lite_wstrb   : in std_logic_vector((C_S_AXI_LITE_DATA_WIDTH/8)-1 downto 0);
      s_axi_lite_wvalid   : in std_logic;
      s_axi_lite_wready   : out std_logic;
      s_axi_lite_bresp   : out std_logic_vector(1 downto 0);
      s_axi_lite_bvalid   : out std_logic;
      s_axi_lite_bready   : in std_logic;
      s_axi_lite_araddr   : in std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);
      s_axi_lite_arprot   : in std_logic_vector(2 downto 0);
      s_axi_lite_arvalid   : in std_logic;
      s_axi_lite_arready   : out std_logic;
      s_axi_lite_rdata   : out std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0);
      s_axi_lite_rresp   : out std_logic_vector(1 downto 0);
      s_axi_lite_rvalid   : out std_logic;
      s_axi_lite_rready   : in std_logic
        
   );
end mipi_csi2_rx_top;

architecture Behavioral of mipi_csi2_rx_top is    
   constant kMaxLaneCount : natural := 4;
   signal rbRxDataHS : STD_LOGIC_VECTOR (8 * kLaneCount - 1 downto 0);
   signal rbRxSyncHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal rbRxValidHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal rbRxActiveHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal aDEnable : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal xSoftEnable, xSoftRst, vSoftEnable, vSoftRst, vRst_n  : std_logic;
begin
    
InputDataGen: for i in 0 to kLaneCount-1 generate
    DataLane0: if i = 0 generate
        rbRxDataHS(8 * (i + 1) - 1 downto 8 * i) <= RxDataHSD0;
        rbRxValidHS(i) <= RxValidHSD0;
        rbRxActiveHS(i) <= RxActiveHSD0;
        rbRxSyncHS(i) <= RxSyncHSD0;
        aD0Enable <= aDEnable(i);
    end generate;
    
    DataLane1: if i = 1 generate
        rbRxDataHS(8 * (i + 1) - 1 downto 8 * i) <= RxDataHSD1;
        rbRxValidHS(i) <= RxValidHSD1;
        rbRxActiveHS(i) <= RxActiveHSD1;
        rbRxSyncHS(i) <= RxSyncHSD1;
        aD1Enable <= aDEnable(i);
    end generate;
    
    DataLane2: if i = 2 generate
        rbRxDataHS(8 * (i + 1) - 1 downto 8 * i) <= RxDataHSD2;
        rbRxValidHS(i) <= RxValidHSD2;
        rbRxActiveHS(i) <= RxActiveHSD2;
        rbRxSyncHS(i) <= RxSyncHSD2;
        aD2Enable <= aDEnable(i);
    end generate;
    
    DataLane3: if i = 3 generate
        rbRxDataHS(8 * (i + 1) - 1 downto 8 * i) <= RxDataHSD3;
        rbRxValidHS(i) <= RxValidHSD3;
        rbRxActiveHS(i) <= RxActiveHSD3;
        rbRxSyncHS(i) <= RxSyncHSD3;
        aD3Enable <= aDEnable(i);
    end generate;
end generate InputDataGen;

MIPI_CSI2_Rx_inst: entity work.MIPI_CSI2_Rx
   Generic map(
      kTargetDT => kTargetDT,
      kDebug => kDebug,
      --PPI
      kLaneCount => kLaneCount, --[1,2,4]
      --Video Format
      C_M_AXIS_COMPONENT_WIDTH => C_M_AXIS_COMPONENT_WIDTH, -- [8,10]
      C_M_AXIS_TDATA_WIDTH => C_M_AXIS_TDATA_WIDTH,
      C_M_MAX_SAMPLES_PER_CLOCK => C_M_MAX_SAMPLES_PER_CLOCK
   )
   Port map( 
      --PPI
      RxByteClkHS => RxByteClkHS,
      aClkStopstate => aClkStopstate,
      aRxClkActiveHS => aRxClkActiveHS,
      
      rbRxDataHS => rbRxDataHS,
      rbRxSyncHS => rbRxSyncHS,
      rbRxValidHS => rbRxValidHS,
      rbRxActiveHS => rbRxActiveHS,
      aDEnable => aDEnable,      
      aClkEnable => aClkEnable,      
      
      --axi stream signals
      m_axis_video_tdata    => m_axis_video_tdata,
      m_axis_video_tvalid   => m_axis_video_tvalid,
      m_axis_video_tready   => m_axis_video_tready,
      m_axis_video_tlast    => m_axis_video_tlast,
      m_axis_video_tuser    => m_axis_video_tuser,
      
      video_aresetn        => vRst_n,
      video_aclk           => video_aclk,
      vEnable              => vSoftEnable
    );
    
-------------------------------------------------------------------------------
-- AXI-Lite interface for control and status
-------------------------------------------------------------------------------
YesAXILITE: if kGenerateAXIL generate
   AXI_Lite_Control: entity work.MIPI_CSI_2_RX_S_AXI_LITE
    generic map (
       kVersionMajor        => kVersionMajor,
       kVersionMinor        => kVersionMinor,
       C_S_AXI_DATA_WIDTH   => C_S_AXI_LITE_DATA_WIDTH,
       C_S_AXI_ADDR_WIDTH   => C_S_AXI_LITE_ADDR_WIDTH
    )
    port map (
       xEnable => xSoftEnable,
       xRst => xSoftRst,
       S_AXI_ACLK   => s_axi_lite_aclk,
       S_AXI_ARESETN   => s_axi_lite_aresetn,
       S_AXI_AWADDR   => s_axi_lite_awaddr,
       S_AXI_AWPROT   => s_axi_lite_awprot,
       S_AXI_AWVALID   => s_axi_lite_awvalid,
       S_AXI_AWREADY   => s_axi_lite_awready,
       S_AXI_WDATA   => s_axi_lite_wdata,
       S_AXI_WSTRB   => s_axi_lite_wstrb,
       S_AXI_WVALID   => s_axi_lite_wvalid,
       S_AXI_WREADY   => s_axi_lite_wready,
       S_AXI_BRESP   => s_axi_lite_bresp,
       S_AXI_BVALID   => s_axi_lite_bvalid,
       S_AXI_BREADY   => s_axi_lite_bready,
       S_AXI_ARADDR   => s_axi_lite_araddr,
       S_AXI_ARPROT   => s_axi_lite_arprot,
       S_AXI_ARVALID   => s_axi_lite_arvalid,
       S_AXI_ARREADY   => s_axi_lite_arready,
       S_AXI_RDATA   => s_axi_lite_rdata,
       S_AXI_RRESP   => s_axi_lite_rresp,
       S_AXI_RVALID   => s_axi_lite_rvalid,
       S_AXI_RREADY   => s_axi_lite_rready
    );
CoreSoftReset: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => xSoftRst,
      OutClk => video_aclk,
      oRst => vSoftRst);
      
SyncAsyncClkEnable: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => '0', --lane-level enable
      aIn => xSoftEnable,
      OutClk => video_aclk,
      oOut => vSoftEnable);
      
GlitchFreeReset: process(video_aclk)
begin
   if Rising_Edge(video_aclk) then
      vRst_n <= video_aresetn and not vSoftRst; --combinational logic can produce glitches
   end if;
end process;
           
end generate;
    
NoAXILITE: if not kGenerateAXIL generate
   vSoftEnable <= '1';
   vRst_n <= video_aresetn;
end generate;

end Behavioral;
