-------------------------------------------------------------------------------
--
-- File: top.vhd
-- Author: Gherman Tudor
-- Original Project: USB Device IP on 7-series Xilinx FPGA
-- Date: 2 May 2016
--
-------------------------------------------------------------------------------
-- (c) 2016 Copyright Digilent Incorporated
-- All Rights Reserved
-- 
-- This program is free software; distributed under the terms of BSD 3-clause 
-- license ("Revised BSD License", "New BSD License", or "Modified BSD License")
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
--    of its contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
--
-- Purpose:
-- This is the top module of the USB_Device IP core. It is designed to work 
-- with an ULPI PHY and, together, to implement the Electrical layer and the 
-- Protocol layer of the USB 2.0 device.  It exports an AXI Lite slave 
-- interface to communicate with the processor. An integrated DMA engine is
-- suposed to connect to the system memory through an AXI4 interface. 
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
--  Port ( );
port (
    S_AXI_ACLK : IN std_logic;

    INTERRUPT : OUT STD_LOGIC; 
    --ULPI Interface 
    ulpi_clk : in  STD_LOGIC;  
    ulpi_data : inout  STD_LOGIC_VECTOR(7 downto 0);
    ulpi_dir : in  STD_LOGIC;
    ulpi_nxt : in  STD_LOGIC;
    ulpi_stp : out  STD_LOGIC;
    led : out STD_LOGIC;
    ulpi_resetn : out  STD_LOGIC;
	
	--AXI4 exported by the AXI DMA Controller	
    m_axi_mm2s_aclk : IN STD_LOGIC;
    m_axi_s2mm_aclk : IN STD_LOGIC;
    
    m_axi_s2mm_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_s2mm_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_s2mm_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_s2mm_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_s2mm_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_s2mm_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_s2mm_awvalid : OUT STD_LOGIC;
    m_axi_s2mm_awready : IN STD_LOGIC;
    m_axi_s2mm_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_s2mm_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_s2mm_wlast : OUT STD_LOGIC;
    m_axi_s2mm_wvalid : OUT STD_LOGIC;
    m_axi_s2mm_wready : IN STD_LOGIC;
    m_axi_s2mm_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_s2mm_bvalid : IN STD_LOGIC;
    m_axi_s2mm_bready : OUT STD_LOGIC;

    m_axi_mm2s_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_mm2s_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_mm2s_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mm2s_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mm2s_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mm2s_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mm2s_arvalid : OUT STD_LOGIC;
    m_axi_mm2s_arready : IN STD_LOGIC;
    m_axi_mm2s_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_mm2s_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mm2s_rlast : IN STD_LOGIC;
    m_axi_mm2s_rvalid : IN STD_LOGIC;
    m_axi_mm2s_rready : OUT STD_LOGIC;

    --AXI Lite Slave interface; Access to Control Registers
    S_AXI_ARESETN : IN std_logic;
    S_AXI_AWADDR : IN std_logic_vector(31 downto 0);
    S_AXI_AWPROT : IN std_logic_vector(2 downto 0);
    S_AXI_AWVALID : IN std_logic;
    S_AXI_WDATA : IN std_logic_vector(31 downto 0);
    S_AXI_WSTRB : IN std_logic_vector(3 downto 0);
    S_AXI_WVALID : IN std_logic;
    S_AXI_BREADY : IN std_logic;
    S_AXI_ARADDR : IN std_logic_vector(31 downto 0);
    S_AXI_ARPROT : IN std_logic_vector(2 downto 0);
    S_AXI_ARVALID : IN std_logic;
    S_AXI_RREADY : IN std_logic;          
    S_AXI_AWREADY : OUT std_logic;
    S_AXI_WREADY : OUT std_logic;
    S_AXI_BRESP : OUT std_logic_vector(1 downto 0);
    S_AXI_BVALID : OUT std_logic;
    S_AXI_ARREADY : OUT std_logic;
    S_AXI_RDATA : OUT std_logic_vector(31 downto 0);
    S_AXI_RRESP : OUT std_logic_vector(1 downto 0);
    S_AXI_RVALID : OUT std_logic
    );
end top;

architecture Behavioral of top is
    
COMPONENT Control_Registers
PORT(
    S_AXI_ACLK : IN std_logic;
    S_AXI_ARESETN : IN std_logic;
    S_AXI_AWADDR : IN std_logic_vector(31 downto 0);
    S_AXI_AWPROT : IN std_logic_vector(2 downto 0);
    S_AXI_AWVALID : IN std_logic;
    S_AXI_WDATA : IN std_logic_vector(31 downto 0);
    S_AXI_WSTRB : IN std_logic_vector(3 downto 0);
    S_AXI_WVALID : IN std_logic;
    S_AXI_BREADY : IN std_logic;
    S_AXI_ARADDR : IN std_logic_vector(31 downto 0);
    S_AXI_ARPROT : IN std_logic_vector(2 downto 0);
    S_AXI_ARVALID : IN std_logic;
    S_AXI_RREADY : IN std_logic;          
    S_AXI_AWREADY : OUT std_logic;
    S_AXI_WREADY : OUT std_logic;
    S_AXI_BRESP : OUT std_logic_vector(1 downto 0);
    S_AXI_BVALID : OUT std_logic;
    S_AXI_ARREADY : OUT std_logic;
    S_AXI_RDATA : OUT std_logic_vector(31 downto 0);
    S_AXI_RRESP : OUT std_logic_vector(1 downto 0);
    S_AXI_RVALID : OUT std_logic;
    
    USBSCFG_rd	: out std_logic_vector(31 downto 0);
    USBCMD_rd    : out std_logic_vector(31 downto 0);
    USBCMD_SUTW_wr    : in std_logic;
    USBCMD_SUTW_wr_en    : in std_logic;
    USBCMD_ATDTW_wr    : in std_logic;
    USBCMD_ATDTW_wr_en    : in std_logic;
    USBSTS_rd    : out std_logic_vector(31 downto 0);
    USBSTS_wr_UI  : in std_logic;
    USBSTS_wr_NAKI    :  in std_logic;  
    USBSTS_wr_SLI    :  in std_logic;
    USBSTS_wr_SRI    :  in std_logic;
    USBSTS_wr_URI    :  in std_logic;
    USBSTS_wr_PCI    :  in std_logic;
    USBSTS_wr_en_NAK    :  in std_logic;
    USBSTS_wr_en_SLI    :  in std_logic;
    USBSTS_wr_en_SRI    :  in std_logic;
    USBSTS_wr_en_URI    :  in std_logic;
    USBSTS_wr_en_PCI    :  in std_logic;
    USBSTS_wr_en_UI  : in std_logic;
    USBINTR_rd    : out std_logic_vector(31 downto 0);
    FRINDEX_rd    : out std_logic_vector(31 downto 0);
    FRINDEX_wr    : in std_logic_vector(10 downto 0);
    FRINDEX_wr_en    : in std_logic;
    a_DEVICEADDR_rd    : out std_logic_vector(31 downto 0);
    a_DEVICEADDR_IPush	: out std_logic;
    ENDPOINTLISTADDR_rd    : out std_logic_vector(31 downto 0);
    ENDPTNAK_rd    : out std_logic_vector(31 downto 0);
    ENDPTNAK_wr    : in std_logic_vector(31 downto 0);
    ENDPTNAK_wr_en    : in std_logic;
    ENDPTNAKEN_rd    : out std_logic_vector(31 downto 0);
    CONFIGFLAG_rd    : out std_logic_vector(31 downto 0);
    PORTSC1_rd    : out std_logic_vector(31 downto 0);
    PORTSC1_PSPD_Wr    : in std_logic_vector(1 downto 0);
    PORTSC1_PSPD_wr_en    : in std_logic;
    OTGSC_rd    : out std_logic_vector(31 downto 0);
    USBMODE_rd    : out std_logic_vector(31 downto 0);
    ENDPTSETUPSTAT_rd    : out std_logic_vector(31 downto 0);
    ENDPTSETUPSTAT_wr    : in std_logic_vector(31 downto 0);
    ENDPTSETUPSTAT_wr_en    : in std_logic;
    ENDPTPRIME_rd    : out std_logic_vector(31 downto 0);
    ENDPTPRIME_clear    : in std_logic_vector(31 downto 0);
    ENDPTPRIME_clear_en    : in std_logic;
    ENDPTPRIME_set    : in std_logic_vector(31 downto 0);
    ENDPTPRIME_set_en    : in std_logic;
    EMDPTFLUSH_rd    : out std_logic_vector(31 downto 0);
    EMDPTFLUSH_clear    : in std_logic_vector(31 downto 0);
    EMDPTFLUSH_clear_en    : in std_logic;
    EMDPTFLUSH_set    : in std_logic_vector(31 downto 0);
    EMDPTFLUSH_set_en    : in std_logic;
    ENDPTSTAT_wr    : in std_logic_vector(31 downto 0);
    ENDPTCOMPLETE_rd    : out std_logic_vector(31 downto 0);
    ENDPTCOMPLETE_wr    : in std_logic_vector(31 downto 0);
    ENDPTCOMPLETE_wr_en    : in std_logic;
    ENDPTCTRL0_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL1_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL2_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL3_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL4_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL5_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL6_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL7_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL8_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL9_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL10_rd    : out std_logic_vector(31 downto 0);
    ENDPTCTRL11_rd    : out std_logic_vector(31 downto 0)
);
END COMPONENT;

COMPONENT DMA_Transfer_Manager
PORT(
    Axi_Resetn : IN STD_LOGIC;
    Axi_Clk : IN STD_LOGIC; 
        
    ind_statte_axistream : out std_logic_vector(4 downto 0);
	DEBUG_REG_DATA : OUT std_logic_vector(31 downto 0);
	state_ind_dma : out STD_LOGIC_VECTOR(4 downto 0);
    state_ind_arb : out std_logic_vector(5 downto 0);  
	a_M_Axi_Awaddr	: out std_logic_vector(9 downto 0);
    a_M_Axi_Awprot    : out std_logic_vector(2 downto 0);
    a_M_Axi_Awvalid    : out std_logic;
    a_M_Axi_Awready    : in std_logic;
    a_M_Axi_Wdata    : out std_logic_vector(31 downto 0);
    a_M_Axi_Wstrb    : out std_logic_vector(3 downto 0);
    a_M_Axi_Wvalid    : out std_logic;
    a_M_Axi_Wready    : in std_logic;
    a_M_Axi_Bresp    : in std_logic_vector(1 downto 0);
    a_M_Axi_Bvalid    : in std_logic;
    a_M_Axi_Bready    : out std_logic;
    a_M_Axi_Araddr    : out std_logic_vector(9 downto 0);
    a_M_Axi_Arprot    : out std_logic_vector(2 downto 0); 
    a_M_Axi_Arvalid    : out std_logic;
    a_M_Axi_Arready    : in std_logic;
    a_M_Axi_Rdata    : in std_logic_vector(31 downto 0);
    a_M_Axi_Rresp    : in std_logic_vector(1 downto 0);
    a_M_Axi_Rvalid    : in std_logic;
    a_M_Axi_Rready    : out std_logic;

	a_S_Axis_MM2S_Tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    a_S_Axis_MM2S_Tkeep : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    a_S_Axis_MM2S_Tvalid : IN STD_LOGIC;
    a_S_Axis_MM2S_Tready : OUT STD_LOGIC;
    a_S_Axis_MM2S_Tlast : IN STD_LOGIC;    
    
    a_M_Axis_S2MM_Tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    a_M_Axis_S2MM_Tkeep : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    a_M_Axis_S2MM_Tvalid : OUT STD_LOGIC;
    a_M_Axis_S2MM_Tready : IN STD_LOGIC;
    a_M_Axis_S2MM_Tlast : OUT STD_LOGIC; 
        
    RX_COMMAND_FIFO_RD_EN : OUT std_logic;
    RX_COMMAND_FIFO_DOUT  : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    RX_COMMAND_FIFO_EMPTY : IN std_logic;
    RX_COMMAND_FIFO_VALID : IN std_logic;
         
    a_Axis_MM2S_Mux_Ctrl  : OUT STD_LOGIC;
    a_Axis_S2MM_Mux_Ctrl  : OUT STD_LOGIC;   
        
    a_Send_Zero_Length_Packet_Set : OUT STD_LOGIC_VECTOR(31 downto 0);
    a_Send_Zero_Length_Packet_Set_En : OUT STD_LOGIC;
    a_Send_Zero_Length_Packet_Ack_Rd : IN STD_LOGIC_VECTOR(31 downto 0);
    a_Send_Zero_Length_Packet_Ack_Clear : OUT STD_LOGIC_VECTOR(31 downto 0);
    a_Send_Zero_Length_Packet_Ack_Clear_En : OUT STD_LOGIC;
    a_Arb_dQH_Setup_Buffer_Bytes_3_0_Wr  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    a_Arb_dQH_Setup_Buffer_Bytes_7_4_Wr  : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
    a_In_Packet_Complete_Rd : IN STD_LOGIC_VECTOR(31 downto 0);
    a_In_Packet_Complete_Clear : OUT STD_LOGIC_VECTOR(31 downto 0); 
    a_In_Packet_Complete_Clear_En : OUT STD_LOGIC;
    a_In_Token_Received_Rd  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    a_In_Token_Received_Clear : OUT STD_LOGIC_VECTOR(31 downto 0);
    a_In_Token_Received_Clear_En : OUT STD_LOGIC;
            

    a_Resend : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    a_Resend_Clear : OUT STD_LOGIC_VECTOR(31 downto 0);
    a_Resend_Clear_En : OUT STD_LOGIC; 
    a_Cnt_Bytes_Sent : IN std_logic_vector(12 downto 0); 
    a_Cnt_Bytes_Sent_oValid : IN std_logic;
    a_Pe_Endpt_Nr  : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    a_Arb_Endpt_Nr : out std_logic_vector(4 downto 0);
        
    arb_tx_fifo_s_aresetn : OUT std_logic;
        
    a_USBSTS_Wr_UI  : OUT std_logic;
    a_USBSTS_Wr_en_UI  : OUT std_logic;
    a_USBMODE_Rd    : in std_logic_vector(31 downto 0);
    a_USBCMD_SUTW_Wr    : out std_logic;
    a_USBCMD_SUTW_Wr_En    : out std_logic;
    a_USBCMD_ATDTW_Wr    : out std_logic;
    a_USBCMD_ATDTW_Wr_En    : out std_logic;
    a_EMDPTFLUSH_Rd    : in std_logic_vector(31 downto 0);
    a_EMDPTFLUSH_Set    : out std_logic_vector(31 downto 0);
    a_EMDPTFLUSH_Set_En    : out std_logic;
    a_ENDPTPRIME_Rd    : in std_logic_vector(31 downto 0);
    a_ENDPTPRIME_Clear    : out std_logic_vector(31 downto 0);
    a_ENDPTPRIME_Clear_En    : out std_logic;
    a_ENDPTPRIME_Set    : out std_logic_vector(31 downto 0);
    a_ENDPTPRIME_Set_En    : out std_logic;
    a_ENDPTSTAT_Wr    : out std_logic_vector(31 downto 0);
    a_ENDPTCOMPLETE_Wr    : out std_logic_vector(31 downto 0);
    a_ENDPTCOMPLETE_Wr_En    : out std_logic;
    a_ENDPTSETUPSTAT_Wr    : out std_logic_vector(31 downto 0);
    a_ENDPTSETUPSTAT_Wr_En    : out std_logic;
    a_Arb_ENDPTSETUP_RECEIVED_Rd   : in std_logic_vector(31 downto 0);
    a_Arb_ENDPTSETUP_RECEIVED_Clear    : out std_logic_vector(31 downto 0);
    a_Arb_ENDPTSETUP_RECEIVED_Clear_En    : out std_logic;
    a_Arb_ENDPTSETUP_RECEIVED_Ack    :  in std_logic; 
    a_ENDPOINTLISTADDR_Rd    : in std_logic_vector(31 downto 0)
);
END COMPONENT;
	
COMPONENT axi_dma_0
PORT (
    s_axi_lite_aclk : IN STD_LOGIC;
    m_axi_mm2s_aclk : IN STD_LOGIC;
    m_axi_s2mm_aclk : IN STD_LOGIC;
    axi_resetn : IN STD_LOGIC;
    s_axi_lite_awvalid : IN STD_LOGIC;
    s_axi_lite_awready : OUT STD_LOGIC;
    s_axi_lite_awaddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    s_axi_lite_wvalid : IN STD_LOGIC;
    s_axi_lite_wready : OUT STD_LOGIC;
    s_axi_lite_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_lite_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_lite_bvalid : OUT STD_LOGIC;
    s_axi_lite_bready : IN STD_LOGIC;
    s_axi_lite_arvalid : IN STD_LOGIC;
    s_axi_lite_arready : OUT STD_LOGIC;
    s_axi_lite_araddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    s_axi_lite_rvalid : OUT STD_LOGIC;
    s_axi_lite_rready : IN STD_LOGIC;
    s_axi_lite_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_lite_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mm2s_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_mm2s_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_mm2s_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mm2s_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mm2s_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mm2s_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mm2s_arvalid : OUT STD_LOGIC;
    m_axi_mm2s_arready : IN STD_LOGIC;
    m_axi_mm2s_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_mm2s_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mm2s_rlast : IN STD_LOGIC;
    m_axi_mm2s_rvalid : IN STD_LOGIC;
    m_axi_mm2s_rready : OUT STD_LOGIC;
    mm2s_prmry_reset_out_n : OUT STD_LOGIC;
    m_axis_mm2s_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_mm2s_tkeep : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axis_mm2s_tvalid : OUT STD_LOGIC;
    m_axis_mm2s_tready : IN STD_LOGIC;
    m_axis_mm2s_tlast : OUT STD_LOGIC;
    m_axi_s2mm_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_s2mm_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_s2mm_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_s2mm_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_s2mm_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_s2mm_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_s2mm_awvalid : OUT STD_LOGIC;
    m_axi_s2mm_awready : IN STD_LOGIC;
    m_axi_s2mm_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_s2mm_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_s2mm_wlast : OUT STD_LOGIC;
    m_axi_s2mm_wvalid : OUT STD_LOGIC;
    m_axi_s2mm_wready : IN STD_LOGIC;
    m_axi_s2mm_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_s2mm_bvalid : IN STD_LOGIC;
    m_axi_s2mm_bready : OUT STD_LOGIC;
    s2mm_prmry_reset_out_n : OUT STD_LOGIC;
    s_axis_s2mm_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_s2mm_tkeep : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axis_s2mm_tvalid : IN STD_LOGIC;
    s_axis_s2mm_tready : OUT STD_LOGIC;
    s_axis_s2mm_tlast : IN STD_LOGIC;
    mm2s_introut : OUT STD_LOGIC;
    s2mm_introut : OUT STD_LOGIC;
    axi_dma_tstvec : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);
END COMPONENT;
    
COMPONENT FIFO
PORT(
    resetn : IN STD_LOGIC;
    rx_fifo_s_aresetn : IN std_logic;
    rx_fifo_m_aclk : IN std_logic;
    rx_fifo_s_aclk : IN std_logic;
    rx_fifo_s_axis_tvalid : IN std_logic;
    rx_fifo_s_axis_tdata : IN std_logic_vector(31 downto 0);
    rx_fifo_s_axis_tkeep : IN std_logic_vector (3 downto 0);
    rx_fifo_s_axis_tlast : IN std_logic;
    rx_fifo_s_axis_tuser : IN std_logic_vector(3 downto 0);
    rx_fifo_m_axis_tready : IN std_logic;        
    rx_fifo_s_axis_tready : OUT std_logic;
    rx_fifo_m_axis_tvalid : OUT std_logic;
    rx_fifo_m_axis_tdata : OUT std_logic_vector(31 downto 0);
    rx_fifo_m_axis_tlast : OUT std_logic;
    rx_fifo_m_axis_tuser : OUT std_logic_vector(3 downto 0);
    rx_fifo_m_axis_tkeep : OUT std_logic_vector(3 downto 0);
    rx_fifo_axis_overflow : OUT std_logic;
    rx_fifo_axis_underflow : OUT std_logic
);
END COMPONENT;
 
COMPONENT Protocol_Engine
PORT(
    axi_clk : IN std_logic;
    Axi_ResetN : in STD_LOGIC;     		    
    Ulpi_Clk : in  STD_LOGIC;
    u_ResetN : in  STD_LOGIC;
    ulpi_reset : out  STD_LOGIC;           
    u_Ulpi_Data : inout  STD_LOGIC_VECTOR(7 downto 0);
    u_Ulpi_Dir : in  STD_LOGIC;
    u_Ulpi_Nxt : in  STD_LOGIC;
    u_Ulpi_Stp : out  STD_LOGIC;
    led : out STD_LOGIC;
            
    a_Arb_Endpt_Nr : in std_logic_vector(4 downto 0);  --!!!!! bits need to be synchronised  
    Tx_Fifo_S_Aresetn : IN STD_LOGIC;  
    a_Tx_Fifo_S_Aclk : IN STD_LOGIC;
    a_Tx_Fifo_S_Axis_Tvalid : IN STD_LOGIC;
    a_Tx_Fifo_S_Axis_Tready : OUT STD_LOGIC;
    a_Tx_Fifo_S_Axis_Tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    a_Tx_Fifo_S_Axis_Tlast : IN STD_LOGIC;
    a_Tx_Fifo_S_Axis_Tkeep : IN std_logic_vector(3 downto 0);
    a_Tx_Fifo_S_Axis_Tuser : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    tx_fifo_axis_overflow : OUT STD_LOGIC;
    tx_fifo_axis_underflow : OUT STD_LOGIC;
            
    u_Rx_Fifo_s_Aclk : OUT std_logic;
    u_Rx_Fifo_s_Axis_Tready : IN std_logic;
    u_Rx_Fifo_s_Axis_Tvalid : OUT std_logic;
    u_Rx_Fifo_s_Axis_Tdata : OUT std_logic_vector(31 downto 0);
    u_Rx_Fifo_s_Axis_Tkeep : OUT std_logic_vector (3 downto 0);
    u_Rx_Fifo_s_Axis_Tlast : OUT std_logic;
    u_Rx_Fifo_Axis_Overflow : IN std_logic;
    u_Rx_Fifo_Axis_Underflow : IN std_logic;
  
    u_Command_Fifo_Rd_En : IN std_logic;
    u_Command_Fifo_Dout  : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    u_Command_Fifo_Empty : OUT std_logic;
    u_Command_Fifo_Valid : OUT std_logic;

    u_USBADRA : in STD_LOGIC_VECTOR (7 downto 0);
    u_Endp_Nr_Arb  : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --new 
    u_Endp_Nr_Arb_Ack : OUT std_logic;
    u_Endp_Nr_Arb_Valid : IN std_logic;
    u_Endp_Type : in STD_LOGIC_VECTOR(47 downto 0);
    u_Endp_Stall : IN STD_LOGIC_VECTOR(23 downto 0);
    u_USBCMD_RS : in std_logic;            
--          endp_enable : IN STD_LOGIC(11 downto 0); --new            

    a_In_Packet_Complete_oData : OUT std_logic_vector(31 downto 0);
    a_In_Packet_Complete_Set_En : OUT std_logic;
    u_Send_Zero_Length_Packet_Rd : IN STD_LOGIC_VECTOR(31 downto 0);
    a_Send_Zero_Length_Packet_Clear_oData :  OUT STD_LOGIC_VECTOR(31 downto 0);
    a_Send_Zero_Length_Packet_Clear_En :  OUT STD_LOGIC; 
    a_Send_Zero_Length_Packet_Ack_oData :  OUT STD_LOGIC_VECTOR(31 downto 0);
    a_Send_Zero_Length_Packet_Ack_Set_En :  OUT STD_LOGIC; 
    a_Cnt_Bytes_Sent_oData : out std_logic_vector(12 downto 0);  --new
    a_Cnt_Bytes_Sent_oValid : OUT std_logic;
    a_In_Token_Received_oData : OUT std_logic_vector(31 downto 0); --new
    a_In_Token_Received_Set_En : OUT std_logic; --new
    a_Resend_oData : OUT STD_LOGIC_VECTOR(31 downto 0);
    a_Resend_Wr_En : OUT std_logic;
    a_Endpt_Nr  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); --new + 1 bit
    u_Endp_Nr  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);          
    a_FRINDEX_oData    : out std_logic_vector(10 downto 0);
    a_FRINDEX_Wr_En    : out std_logic;
    a_Setup_Buffer_Bytes_3_0_oData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    a_Setup_Buffer_Bytes_7_4_oData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  
    a_PORTSC1_PSPD_oData    : out std_logic_vector(1 downto 0);
    a_PORTSC1_PSPD_Wr_En    : out std_logic;
    a_ENDPTNAK_oData    : out std_logic_vector(31 downto 0);
    a_ENDPTNAK_Wr_En    : out std_logic;
    a_ENDPTSETUP_RECEIVED_oData    : out std_logic_vector(31 downto 0);
    a_ENDPTSETUP_RECEIVED_Wr_En    : out std_logic;
    a_USBSTS_NAKI_oData    :  out std_logic;
    a_USBSTS_NAKI_Wr_En    :  out std_logic;  
    a_USBSTS_SLI_oData    :  out std_logic;
    a_USBSTS_SLI_Wr_En    :  out std_logic;
    a_USBSTS_SRI_oData    :  out std_logic;
    a_USBSTS_SRI_Wr_En    :  out std_logic;
    a_USBSTS_URI_oData    :  out std_logic;
    a_USBSTS_URI_Wr_En    :  out std_logic;
    a_USBSTS_PCI_oData    :  out std_logic;
    a_USBSTS_PCI_Wr_En    :  out std_logic;
            
    state_ind : out STD_LOGIC_VECTOR(5 downto 0);
    state_ind_pd : out STD_LOGIC_VECTOR(6 downto 0);
    state_ind_hs : out STD_LOGIC_VECTOR(4 downto 0)
);        
END COMPONENT;
 
COMPONENT ResetBridge
Generic (
   kPolarity : std_logic);
PORT(
    aRst : IN std_logic;
    OutClk : IN std_logic;          
    oRst : OUT std_logic
    );
END COMPONENT;
    
type ENDPOINTCTRL_REGISTERS is array (11 downto 0) of std_logic_vector(31 downto 0);
signal ENDPTCTRL : ENDPOINTCTRL_REGISTERS;  

signal Ulpi_Clk_MMCM_Clkin : STD_LOGIC;
signal Ulpi_Clk_MMCM_Clkfbin : STD_LOGIC;  
signal Ulpi_Clk_MMCM_Clkfbout : STD_LOGIC;
signal Ulpi_Clk_MMCM_Clkout0 : STD_LOGIC;
signal Ulpi_Clk_MMCM_Locked : STD_LOGIC;
signal Ulpi_ResetN_oRst : STD_LOGIC; 
signal u_ResetN : STD_LOGIC; 
signal u_MMCM_Rst : STD_LOGIC;
signal a_Axi_Reset : STD_LOGIC;
signal a_Axi_DMA_Tstvec :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_MM2S_Introut :  STD_LOGIC;
signal a_S2MM_Introut :  STD_LOGIC;
signal a_S2MM_Prmry_Reset_Out_N :  STD_LOGIC;
signal a_MM2S_Prmry_Reset_Out_N :  STD_LOGIC;
------------------------------------------------------------------------
signal a_Axis_MM2S_Mux_Ctrl, a_Axis_S2MM_Mux_Ctrl :  STD_LOGIC;
signal a_Setup_Buffer_Bytes_3_0_Wr                :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_Setup_Buffer_Bytes_7_4_Wr                :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_Pe_Endpt_Nr, pe_endpt_nr_ulpi_clk        : STD_LOGIC_VECTOR(4 DOWNTO 0);
    
signal a_DMA_S_Axis_S2MM_Tdata  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_DMA_S_Axis_S2MM_Tkeep  :  STD_LOGIC_VECTOR(3 DOWNTO 0);
signal a_DMA_S_Axis_S2MM_Tvalid :  STD_LOGIC;
signal a_DMA_S_Axis_S2MM_Tready :  STD_LOGIC;
signal a_DMA_S_Axis_S2MM_Tlast  :  STD_LOGIC;
    
signal a_DMA_M_Axis_MM2S_Tdata  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_DMA_M_Axis_MM2S_Tkeep  :  STD_LOGIC_VECTOR(3 DOWNTO 0);
signal a_DMA_M_Axis_MM2S_Tvalid :  STD_LOGIC;
signal a_DMA_M_Axis_MM2S_Tready :  STD_LOGIC;
signal a_DMA_M_Axis_MM2S_Tlast  :  STD_LOGIC;
    
signal a_FIFO_Axis_S2MM_Tdata  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_FIFO_Axis_S2MM_Tkeep  :  STD_LOGIC_VECTOR(3 DOWNTO 0);
signal a_FIFO_Axis_S2MM_Tvalid :  STD_LOGIC;
signal a_FIFO_Axis_S2MM_Tready :  STD_LOGIC;
signal a_FIFO_Axis_S2MM_Tlast  :  STD_LOGIC;
    
signal a_FIFO_Axis_MM2S_Tdata  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_FIFO_Axis_MM2S_Tkeep  :  STD_LOGIC_VECTOR(3 DOWNTO 0);
signal a_FIFO_Axis_MM2S_Tvalid :  STD_LOGIC;
signal a_FIFO_Axis_MM2S_Tready :  STD_LOGIC;
signal a_FIFO_Axis_MM2S_Tlast  :  STD_LOGIC;
    
signal a_Arb_Axis_S2MM_Tdata   :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_Arb_Axis_S2MM_Tkeep   :  STD_LOGIC_VECTOR(3 DOWNTO 0);
signal a_Arb_Axis_S2MM_Tvalid  :  STD_LOGIC;
signal a_Arb_Axis_S2MM_Tready  :  STD_LOGIC;
signal a_Arb_Axis_S2MM_Tlast   :  STD_LOGIC;
    
signal a_Arb_Axis_MM2S_Tdata   :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_Arb_Axis_MM2S_Tkeep   :  STD_LOGIC_VECTOR(3 DOWNTO 0);
signal a_Arb_Axis_MM2S_Tvalid  :  STD_LOGIC;
signal a_Arb_Axis_MM2S_Tready  :  STD_LOGIC;
signal a_Arb_Axis_MM2S_Tlast   :  STD_LOGIC;
------------------------------------------------------------------------    
signal u_Rx_Fifo_s_Aclk          :  STD_LOGIC;
signal u_Rx_Fifo_s_Axis_Tready   :  STD_LOGIC;
signal u_Rx_Fifo_s_Axis_Tvalid   :  STD_LOGIC;
signal u_Rx_Fifo_s_Axis_Tdata    :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal u_Rx_Fifo_s_Axis_Tkeep    :  STD_LOGIC_VECTOR(3 DOWNTO 0);
signal u_Rx_Fifo_s_Axis_Tlast    :  STD_LOGIC;
signal u_Rx_Fifo_Axis_Overflow   :  std_logic;
signal u_Rx_Fifo_Axis_Underflow  :  std_logic;
signal tx_fifo_reset_vector      :  STD_LOGIC_VECTOR(11 DOWNTO 0);
signal u_Command_Fifo_Rd_En      :  std_logic;
signal u_Command_Fifo_Dout       :  STD_LOGIC_VECTOR(23 DOWNTO 0);
signal u_Command_Fifo_Empty      :  std_logic;
signal u_Command_Fifo_Valid      : std_logic;
    
signal a_DMA_Axilite_Awaddr      : std_logic_vector(9 downto 0);
signal a_DMA_Axilite_Awprot      : std_logic_vector(2 downto 0);
signal a_DMA_Axilite_Awvalid     : std_logic;
signal a_DMA_Axilite_Awready     : std_logic;
signal a_DMA_Axilite_Wdata       : std_logic_vector(31 downto 0);
signal a_DMA_Axilite_Wstrb       : std_logic_vector(3 downto 0);
signal a_DMA_Axilite_Wvalid      : std_logic;
signal a_DMA_Axilite_Wready      : std_logic;
signal a_DMA_Axilite_Bresp       : std_logic_vector(1 downto 0);
signal a_DMA_Axilite_Bvalid      : std_logic;
signal a_DMA_Axilite_Bready      : std_logic;
signal a_DMA_Axilite_Araddr      : std_logic_vector(9 downto 0);
signal a_DMA_Axilite_Arprot      : std_logic_vector(2 downto 0);
signal a_DMA_Axilite_Arvalid     : std_logic;
signal a_DMA_Axilite_Arready     : std_logic;
signal a_DMA_Axilite_Rdata       : std_logic_vector(31 downto 0);
signal a_DMA_Axilite_Rresp       : std_logic_vector(1 downto 0);
signal a_DMA_Axilite_Rvalid      : std_logic;
signal a_DMA_Axilite_Ready       : std_logic;
    
signal arb_tx_fifo_s_aresetn : std_logic; 
    
signal a_SBUSCFG_Rd	: std_logic_vector(31 downto 0);
signal a_USBCMD_Rd    : std_logic_vector(31 downto 0);
signal a_USBCMD_SUTW_Wr    : std_logic;
signal a_USBCMD_SUTW_Wr_En    :  std_logic;
signal a_USBCMD_ATDTW_Wr    : std_logic;
signal a_USBCMD_ATDTW_Wr_En    :  std_logic;
signal a_USBSTS_Rd    :  std_logic_vector(31 downto 0);
signal a_USBSTS_Wr_NAKI    :  std_logic;  
signal a_USBSTS_Wr_SLI    :  std_logic;
signal a_USBSTS_Wr_SRI    :  std_logic;
signal a_USBSTS_Wr_URI    :  std_logic;
signal a_USBSTS_Wr_PCI    :  std_logic;
signal a_USBSTS_Wr_En_NAK    :  std_logic;
signal a_USBSTS_Wr_En_SLI    :  std_logic;
signal a_USBSTS_Wr_En_SRI    :  std_logic;
signal a_USBSTS_Wr_En_URI    :  std_logic;
signal a_USBSTS_Wr_En_PCI    :  std_logic;
signal a_USBSTS_Wr_UI  :  std_logic;
signal a_USBSTS_Wr_en_UI  :  std_logic;
signal a_USBINTR_Rd    :  std_logic_vector(31 downto 0);
signal a_FRINDEX_Rd    :  std_logic_vector(31 downto 0);
signal a_FRINDEX_Wr    :  std_logic_vector(10 downto 0);
signal a_FRINDEX_Wr_En    :  std_logic;
signal a_DEVICEADDR_rd, u_DEVICEADDR_rd    :  std_logic_vector(31 downto 0);
signal a_DEVICEADDR_IPush    :  std_logic;
signal a_DEVICEADDR_IRdy    :  std_logic;
signal u_DEVICEADDR_oValid    :  std_logic;
signal a_ENDPOINTLISTADDR_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTNAK_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTNAK_Wr    :  std_logic_vector(31 downto 0);
signal a_ENDPTNAK_Wr_En    :  std_logic;
signal a_ENDPTNAKEN_Rd    :  std_logic_vector(31 downto 0);
signal a_CONFIGFLAG_Rd    :  std_logic_vector(31 downto 0);
signal a_PORTSC1_Rd    :  std_logic_vector(31 downto 0);
signal a_PORTSC1_PSPD_Wr    :  std_logic_vector(1 downto 0);
signal a_PORTSC1_PSPD_Wr_En    :  std_logic;
signal a_OTGSC_Rd    :  std_logic_vector(31 downto 0);
signal a_USBMODE_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTSETUPSTAT_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTSETUPSTAT_Wr    :  std_logic_vector(31 downto 0);
signal a_ENDPTSETUPSTAT_Wr_En    :  std_logic;
signal a_PE_ENDPTSETUP_RECEIVED_Wr    :  std_logic_vector(31 downto 0);
signal a_PE_ENDPTSETUP_RECEIVED_Wr_En    :  std_logic;
signal a_Arb_ENDPTSETUP_RECEIVED_Rd   :  std_logic_vector(31 downto 0);
signal a_Arb_ENDPTSETUP_RECEIVED_Clear    :  std_logic_vector(31 downto 0);
signal a_Arb_ENDPTSETUP_RECEIVED_Clear_En    :  std_logic;
signal a_Arb_ENDPTSETUP_RECEIVED_Ack    :  std_logic;  
signal a_ENDPTPRIME_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTPRIME_Clear    :  std_logic_vector(31 downto 0);
signal a_ENDPTPRIME_Clear_En    :  std_logic;
signal a_ENDPTPRIME_Set    :  std_logic_vector(31 downto 0);
signal a_ENDPTPRIME_Set_En    :  std_logic;
signal a_EMDPTFLUSH_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTFLUSH_Clear, a_EMDPTFLUSH_Set    :  std_logic_vector(31 downto 0);
signal a_ENDPTFLUSH_Clear_En, a_EMDPTFLUSH_Set_En    :  std_logic;
signal a_ENDPTSTAT_Wr    :  std_logic_vector(31 downto 0);
signal a_ENDPTCOMPLETE_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCOMPLETE_Wr    :  std_logic_vector(31 downto 0);
signal a_ENDPTCOMPLETE_Wr_En    :  std_logic;
signal a_ENDPTCTRL0_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL1_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL2_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL3_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL4_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL5_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL6_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL7_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL8_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL9_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL10_Rd    :  std_logic_vector(31 downto 0);
signal a_ENDPTCTRL11_Rd    :  std_logic_vector(31 downto 0);
signal a_USBCMD_RS, u_USBCMD_RS : std_logic;
    
signal a_In_Packet_Complete_Set :  std_logic_vector(31 downto 0);
signal a_In_Packet_Complete_Set_En :  std_logic; 
signal a_In_Packet_Complete_Rd :  std_logic_vector(31 downto 0);
signal a_In_Packet_Complete_Clear : STD_LOGIC_VECTOR(31 downto 0);
signal a_In_Packet_Complete_Clear_En : STD_LOGIC;
signal a_Send_Zero_Length_Packet_iData, u_Send_Zero_Length_Packet_oData, a_Send_Zero_Length_Packet_iData_q :  STD_LOGIC_VECTOR(31 downto 0);
signal a_Send_Zero_Length_Packet_iPush, a_Send_Zero_Length_Packet_iRdy, u_Send_Zero_Length_Packet_oValid : std_logic;
signal a_Send_Zero_Length_Packet_Set :  STD_LOGIC_VECTOR(31 downto 0);
signal a_Send_Zero_Length_Packet_Set_En :  STD_LOGIC;
signal a_Send_Zero_Length_Packet_Clear  :  STD_LOGIC_VECTOR(31 downto 0);
signal a_Send_Zero_Length_Packet_Clear_En :  STD_LOGIC; 
signal a_Send_Zero_Length_Packet_Ack_Rd :  STD_LOGIC_VECTOR(31 downto 0);
signal a_Send_Zero_Length_Packet_Ack_Clear :  STD_LOGIC_VECTOR(31 downto 0);
signal a_Send_Zero_Length_Packet_Ack_Clear_En :  STD_LOGIC;
signal a_Send_Zero_Length_Packet_Ack_Set :  STD_LOGIC_VECTOR(31 downto 0);
signal a_Send_Zero_Length_Packet_Ack_Set_En :  STD_LOGIC;
signal a_In_Token_Received_Set, a_In_Token_Received_Rd, a_In_Token_Received_Clear : STD_LOGIC_VECTOR(31 downto 0);
signal a_In_Token_Received_Set_En, a_In_Token_Received_Clear_En :  STD_LOGIC; 
signal a_Cnt_Bytes_Sent : std_logic_vector(12 downto 0);
signal a_Cnt_Bytes_Sent_oValid :  STD_LOGIC;
signal a_Arb_Endpt_Nr : std_logic_vector(4 downto 0);
signal a_Endpt_Type_iData, u_Endpt_Type_oData, a_Endpt_Type_iData_q : std_logic_vector(47 downto 0);
signal a_Endpt_Type_iPush, a_Endpt_Type_iRdy, u_Endpt_Type_oValid : std_logic;
signal a_Endpt_Enable_iData, u_Endpt_Enable_oData, a_Endpt_Enable_iData_q : std_logic_vector(23 downto 0); 
signal a_Endpt_Enable_iPush, a_Endpt_Enable_iRdy, u_Endpt_Enable_oValid : std_logic;
signal a_Endpt_Stall_iData, u_Endpt_Stall_oData, a_Endpt_Stall_iData_q : std_logic_vector(23 downto 0);
signal a_Endpt_Stall_iPush, a_Endpt_Stall_iRdy, u_Endpt_Stall_oValid : std_logic;
signal a_INTERRUPT_Loc : std_logic;
signal DEBUG_REG_DATA :  std_logic_vector(31 downto 0); 
signal a_USBSTS_UI_Change : std_logic;
signal a_Resend :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_Resend_Clear :  STD_LOGIC_VECTOR(31 downto 0);
signal a_Resend_Clear_En :  STD_LOGIC;
signal a_Resend_oData :  STD_LOGIC_VECTOR(31 downto 0);
signal a_Resend_Wr_En :  STD_LOGIC;  

attribute clock_buffer_type : string;
attribute clock_buffer_type of ulpi_clk : signal is "none"; 
 
    signal state_ind : STD_LOGIC_VECTOR(5 downto 0);
    signal state_ind_pd : STD_LOGIC_VECTOR(6 downto 0);
    signal state_ind_hs : STD_LOGIC_VECTOR(4 downto 0);
    signal state_ind_dma : STD_LOGIC_VECTOR(4 downto 0);
    signal state_ind_arb : std_logic_vector(5 downto 0);  
    signal ind_statte_axistream : std_logic_vector(4 downto 0); 
    
--    attribute mark_debug : string;  
--    attribute keep : string;
--        attribute mark_debug of u_USBCMD_RS : signal is "true";
--        attribute keep of u_USBCMD_RS : signal is "true"; 
   
begin

ulpi_resetn <= S_AXI_ARESETN;
a_Axi_Reset <= not S_AXI_ARESETN;
a_USBCMD_RS <= a_USBCMD_Rd(0);
led <= '0';
u_ResetN <= Ulpi_ResetN_oRst and (Ulpi_Clk_MMCM_Locked);

Inst_ResetBridge: ResetBridge 
GENERIC MAP (
    kPolarity => '0')
PORT MAP(
    aRst => S_AXI_ARESETN,
    OutClk => Ulpi_Clk_MMCM_Clkout0,
    oRst => Ulpi_ResetN_oRst
);   

u_MMCM_Rst <= '0';

-- This module implements the control registers required by USB Device IP.
-- Control Registers data is written/read over an AXI Lite interface 
    
Inst_Control_Registers: Control_Registers PORT MAP(
    S_AXI_ACLK => S_AXI_ACLK,
    S_AXI_ARESETN => S_AXI_ARESETN,
    S_AXI_AWADDR => S_AXI_AWADDR,
    S_AXI_AWPROT => S_AXI_AWPROT,
    S_AXI_AWVALID => S_AXI_AWVALID,
    S_AXI_AWREADY => S_AXI_AWREADY,
    S_AXI_WDATA => S_AXI_WDATA,
    S_AXI_WSTRB => S_AXI_WSTRB,
    S_AXI_WVALID => S_AXI_WVALID,
    S_AXI_WREADY => S_AXI_WREADY,
    S_AXI_BRESP => S_AXI_BRESP,
    S_AXI_BVALID => S_AXI_BVALID,
    S_AXI_BREADY => S_AXI_BREADY,
    S_AXI_ARADDR => S_AXI_ARADDR,
    S_AXI_ARPROT => S_AXI_ARPROT,
    S_AXI_ARVALID => S_AXI_ARVALID,
    S_AXI_ARREADY => S_AXI_ARREADY,
    S_AXI_RDATA => S_AXI_RDATA,
    S_AXI_RRESP => S_AXI_RRESP,
    S_AXI_RVALID => S_AXI_RVALID,
    S_AXI_RREADY => S_AXI_RREADY,
        
    USBSCFG_rd => a_SBUSCFG_Rd,
    USBCMD_rd => a_USBCMD_Rd,    
    USBCMD_SUTW_wr => a_USBCMD_SUTW_Wr,
    USBCMD_SUTW_wr_en => a_USBCMD_SUTW_Wr_En,
    USBCMD_ATDTW_wr => a_USBCMD_ATDTW_Wr,
    USBCMD_ATDTW_wr_en => a_USBCMD_ATDTW_Wr_En,
    USBSTS_rd => a_USBSTS_Rd,
    USBSTS_wr_UI  => a_USBSTS_Wr_UI,
    USBSTS_wr_NAKI => a_USBSTS_Wr_NAKI, 
    USBSTS_wr_SLI => a_USBSTS_Wr_SLI,
    USBSTS_wr_SRI => a_USBSTS_Wr_SRI,
    USBSTS_wr_URI => a_USBSTS_Wr_URI,
    USBSTS_wr_PCI => a_USBSTS_Wr_PCI,
    USBSTS_wr_en_NAK => a_USBSTS_Wr_En_NAK,
    USBSTS_wr_en_SLI => a_USBSTS_Wr_En_SLI,
    USBSTS_wr_en_SRI => a_USBSTS_Wr_En_SRI,
    USBSTS_wr_en_URI => a_USBSTS_Wr_En_URI,
    USBSTS_wr_en_PCI  => a_USBSTS_Wr_En_PCI,
    USBSTS_wr_en_UI => a_USBSTS_Wr_en_UI,
    USBINTR_rd => a_USBINTR_Rd,
    FRINDEX_rd => a_FRINDEX_Rd,
    FRINDEX_wr => a_FRINDEX_Wr,
    FRINDEX_wr_en => a_FRINDEX_Wr_En,
    a_DEVICEADDR_rd => a_DEVICEADDR_rd,
    a_DEVICEADDR_IPush => a_DEVICEADDR_IPush,
    ENDPOINTLISTADDR_rd => a_ENDPOINTLISTADDR_Rd,
    ENDPTNAK_rd => a_ENDPTNAK_Rd,
    ENDPTNAK_wr => a_ENDPTNAK_Wr,
    ENDPTNAK_wr_en => a_ENDPTNAK_Wr_En,
    ENDPTNAKEN_rd => a_ENDPTNAKEN_Rd,
    CONFIGFLAG_rd => a_CONFIGFLAG_Rd,
    PORTSC1_rd => a_PORTSC1_Rd,
    PORTSC1_PSPD_wr => a_PORTSC1_PSPD_Wr,
    PORTSC1_PSPD_wr_en => a_PORTSC1_PSPD_Wr_En,
    OTGSC_rd => a_OTGSC_Rd,
    USBMODE_rd => a_USBMODE_Rd,
    ENDPTSETUPSTAT_rd => a_ENDPTSETUPSTAT_Rd,
    ENDPTSETUPSTAT_wr => a_ENDPTSETUPSTAT_Wr,
    ENDPTSETUPSTAT_wr_en => a_ENDPTSETUPSTAT_Wr_En, 
    ENDPTPRIME_rd => a_ENDPTPRIME_Rd,
    ENDPTPRIME_clear => a_ENDPTPRIME_Clear,
    ENDPTPRIME_clear_en => a_ENDPTPRIME_Clear_En,
    ENDPTPRIME_set => a_ENDPTPRIME_Set,
    ENDPTPRIME_set_en => a_ENDPTPRIME_Set_En,
    EMDPTFLUSH_rd => a_EMDPTFLUSH_Rd,
    EMDPTFLUSH_clear => a_ENDPTFLUSH_Clear,
    EMDPTFLUSH_clear_en => a_ENDPTFLUSH_Clear_En,
    EMDPTFLUSH_set => a_EMDPTFLUSH_Set,
    EMDPTFLUSH_set_en  => a_EMDPTFLUSH_Set_En,
    ENDPTSTAT_wr => a_ENDPTSTAT_Wr,
    ENDPTCOMPLETE_rd => a_ENDPTCOMPLETE_Rd,
    ENDPTCOMPLETE_wr => a_ENDPTCOMPLETE_Wr,
    ENDPTCOMPLETE_wr_en => a_ENDPTCOMPLETE_Wr_En,
    ENDPTCTRL0_rd => a_ENDPTCTRL0_Rd,
    ENDPTCTRL1_rd => a_ENDPTCTRL1_Rd,
    ENDPTCTRL2_rd => a_ENDPTCTRL2_Rd,
    ENDPTCTRL3_rd => a_ENDPTCTRL3_Rd,
    ENDPTCTRL4_rd => a_ENDPTCTRL4_Rd, 
    ENDPTCTRL5_rd => a_ENDPTCTRL5_Rd,
    ENDPTCTRL6_rd => a_ENDPTCTRL6_Rd,
    ENDPTCTRL7_rd => a_ENDPTCTRL7_Rd,
    ENDPTCTRL8_rd => a_ENDPTCTRL8_Rd,
    ENDPTCTRL9_rd => a_ENDPTCTRL9_Rd,
    ENDPTCTRL10_rd => a_ENDPTCTRL10_Rd,
    ENDPTCTRL11_rd => a_ENDPTCTRL11_Rd
);    

-- This module manages all transfers from main memory to local buffers through 
-- DMA, both control data (Queue Heads, Transfer Descriptors)and packet data.  

Inst_DMA_Transfer_Manager: DMA_Transfer_Manager PORT MAP(
    Axi_Clk => S_AXI_ACLK,
    Axi_Resetn => S_AXI_ARESETN,
    ind_statte_axistream => ind_statte_axistream,
    state_ind_dma => state_ind_dma,
    state_ind_arb => state_ind_arb,
    a_M_Axi_Awaddr => a_DMA_Axilite_Awaddr,
    a_M_Axi_Awprot => a_DMA_Axilite_Awprot,
    a_M_Axi_Awvalid => a_DMA_Axilite_Awvalid,
    a_M_Axi_Awready => a_DMA_Axilite_Awready,
    a_M_Axi_Wdata => a_DMA_Axilite_Wdata,
    a_M_Axi_Wstrb => a_DMA_Axilite_Wstrb,
    a_M_Axi_Wvalid => a_DMA_Axilite_Wvalid,
    a_M_Axi_Wready => a_DMA_Axilite_Wready,
    a_M_Axi_Bresp => a_DMA_Axilite_Bresp,
    a_M_Axi_Bvalid => a_DMA_Axilite_Bvalid,
    a_M_Axi_Bready => a_DMA_Axilite_Bready,
    a_M_Axi_Araddr => a_DMA_Axilite_Araddr,
    a_M_Axi_Arprot => a_DMA_Axilite_Arprot,
    a_M_Axi_Arvalid => a_DMA_Axilite_Arvalid,
    a_M_Axi_Arready => a_DMA_Axilite_Arready,
    a_M_Axi_Rdata => a_DMA_Axilite_Rdata,
    a_M_Axi_Rresp => a_DMA_Axilite_Rresp,
    a_M_Axi_Rvalid => a_DMA_Axilite_Rvalid,
    a_M_Axi_Rready => a_DMA_Axilite_Ready,
            
    a_S_Axis_MM2S_Tdata => a_Arb_Axis_MM2S_Tdata,
    a_S_Axis_MM2S_Tkeep => a_Arb_Axis_MM2S_Tkeep,
    a_S_Axis_MM2S_Tvalid => a_Arb_Axis_MM2S_Tvalid,
    a_S_Axis_MM2S_Tready => a_Arb_Axis_MM2S_Tready,
    a_S_Axis_MM2S_Tlast => a_Arb_Axis_MM2S_Tlast,  
        
    a_M_Axis_S2MM_Tdata => a_Arb_Axis_S2MM_Tdata,
    a_M_Axis_S2MM_Tkeep => a_Arb_Axis_S2MM_Tkeep,
    a_M_Axis_S2MM_Tvalid => a_Arb_Axis_S2MM_Tvalid,
    a_M_Axis_S2MM_Tready => a_Arb_Axis_S2MM_Tready,
    a_M_Axis_S2MM_Tlast => a_Arb_Axis_S2MM_Tlast, 
            
    RX_COMMAND_FIFO_RD_EN => u_Command_Fifo_Rd_En,
    RX_COMMAND_FIFO_DOUT  => u_Command_Fifo_Dout,
    RX_COMMAND_FIFO_EMPTY => u_Command_Fifo_Empty,
    RX_COMMAND_FIFO_VALID => u_Command_Fifo_Valid,
            
    a_Axis_MM2S_Mux_Ctrl  => a_Axis_MM2S_Mux_Ctrl,
    a_Axis_S2MM_Mux_Ctrl  => a_Axis_S2MM_Mux_Ctrl,        
    a_Send_Zero_Length_Packet_Set => a_Send_Zero_Length_Packet_Set,
    a_Send_Zero_Length_Packet_Set_En => a_Send_Zero_Length_Packet_Set_En, 
    a_Send_Zero_Length_Packet_Ack_Rd => a_Send_Zero_Length_Packet_Ack_Rd,
    a_Send_Zero_Length_Packet_Ack_Clear => a_Send_Zero_Length_Packet_Ack_Clear,
    a_Send_Zero_Length_Packet_Ack_Clear_En => a_Send_Zero_Length_Packet_Ack_Clear_En,
    a_Arb_dQH_Setup_Buffer_Bytes_3_0_Wr => a_Setup_Buffer_Bytes_3_0_Wr,
    a_Arb_dQH_Setup_Buffer_Bytes_7_4_Wr => a_Setup_Buffer_Bytes_7_4_Wr,       
    a_In_Packet_Complete_Rd => a_In_Packet_Complete_Rd,
    a_In_Packet_Complete_Clear => a_In_Packet_Complete_Clear,
    a_In_Packet_Complete_Clear_En => a_In_Packet_Complete_Clear_En,    
    a_In_Token_Received_Rd  => a_In_Token_Received_Rd,   
    a_In_Token_Received_Clear => a_In_Token_Received_Clear,
    a_In_Token_Received_Clear_En => a_In_Token_Received_Clear_En,
    a_Cnt_Bytes_Sent => a_Cnt_Bytes_Sent,
    a_Cnt_Bytes_Sent_oValid => a_Cnt_Bytes_Sent_oValid,
    a_Pe_Endpt_Nr  => a_Pe_Endpt_Nr,
    a_Arb_Endpt_Nr  => a_Arb_Endpt_Nr,
    a_Resend => a_Resend,
    a_Resend_Clear => a_Resend_Clear,
    a_Resend_Clear_En => a_Resend_Clear_En,
    arb_tx_fifo_s_aresetn => arb_tx_fifo_s_aresetn,       
    a_USBSTS_Wr_UI  => a_USBSTS_Wr_UI,
    a_USBSTS_Wr_en_UI => a_USBSTS_Wr_en_UI,
    a_USBMODE_Rd => a_USBMODE_Rd,
    a_USBCMD_SUTW_Wr => a_USBCMD_SUTW_Wr,
    a_USBCMD_SUTW_Wr_En => a_USBCMD_SUTW_Wr_En,
    a_USBCMD_ATDTW_Wr => a_USBCMD_ATDTW_Wr,
    a_USBCMD_ATDTW_Wr_En => a_USBCMD_ATDTW_Wr_En,
    a_EMDPTFLUSH_Rd    => a_EMDPTFLUSH_Rd,
    a_EMDPTFLUSH_Set => a_EMDPTFLUSH_Set,
    a_EMDPTFLUSH_Set_En => a_EMDPTFLUSH_Set_En,
    a_ENDPTPRIME_Rd => a_ENDPTPRIME_Rd,
    a_ENDPTPRIME_Clear => a_ENDPTPRIME_Clear,
    a_ENDPTPRIME_Clear_En => a_ENDPTPRIME_Clear_En,
    a_ENDPTPRIME_Set => a_ENDPTPRIME_Set,
    a_ENDPTPRIME_Set_En  => a_ENDPTPRIME_Set_En,
    a_ENDPTSTAT_Wr => a_ENDPTSTAT_Wr,
    a_ENDPTCOMPLETE_Wr => a_ENDPTCOMPLETE_Wr,
    a_ENDPTCOMPLETE_Wr_En => a_ENDPTCOMPLETE_Wr_En,
    a_ENDPTSETUPSTAT_Wr => a_ENDPTSETUPSTAT_Wr,
    a_ENDPTSETUPSTAT_Wr_En => a_ENDPTSETUPSTAT_Wr_En,
    a_Arb_ENDPTSETUP_RECEIVED_Rd  => a_Arb_ENDPTSETUP_RECEIVED_Rd,
    a_Arb_ENDPTSETUP_RECEIVED_Clear  => a_Arb_ENDPTSETUP_RECEIVED_Clear,
    a_Arb_ENDPTSETUP_RECEIVED_Clear_En  => a_Arb_ENDPTSETUP_RECEIVED_Clear_En,
    a_Arb_ENDPTSETUP_RECEIVED_Ack  => a_Arb_ENDPTSETUP_RECEIVED_Ack,
    a_ENDPOINTLISTADDR_Rd => a_ENDPOINTLISTADDR_Rd
);

--AXI DMA Controller
	
your_instance_name: axi_dma_0 PORT MAP (
    s_axi_lite_aclk => S_AXI_ACLK,
    m_axi_mm2s_aclk => m_axi_mm2s_aclk,
    m_axi_s2mm_aclk => m_axi_s2mm_aclk,
    axi_resetn => S_AXI_ARESETN,
    s_axi_lite_awvalid => a_DMA_Axilite_Awvalid,
    s_axi_lite_awready => a_DMA_Axilite_Awready,
    s_axi_lite_awaddr => a_DMA_Axilite_Awaddr,
    s_axi_lite_wvalid => a_DMA_Axilite_Wvalid,
    s_axi_lite_wready => a_DMA_Axilite_Wready,
    s_axi_lite_wdata => a_DMA_Axilite_Wdata,
    s_axi_lite_bresp => a_DMA_Axilite_Bresp,
    s_axi_lite_bvalid => a_DMA_Axilite_Bvalid,
    s_axi_lite_bready => a_DMA_Axilite_Bready,
    s_axi_lite_arvalid => a_DMA_Axilite_Arvalid,
    s_axi_lite_arready => a_DMA_Axilite_Arready,
    s_axi_lite_araddr => a_DMA_Axilite_Araddr,
    s_axi_lite_rvalid => a_DMA_Axilite_Rvalid,
    s_axi_lite_rready => a_DMA_Axilite_Ready,
    s_axi_lite_rdata => a_DMA_Axilite_Rdata,
    s_axi_lite_rresp => a_DMA_Axilite_Rresp,
    m_axi_mm2s_araddr => m_axi_mm2s_araddr,
    m_axi_mm2s_arlen => m_axi_mm2s_arlen,
    m_axi_mm2s_arsize => m_axi_mm2s_arsize,
    m_axi_mm2s_arburst => m_axi_mm2s_arburst,
    m_axi_mm2s_arprot => m_axi_mm2s_arprot,
    m_axi_mm2s_arcache => m_axi_mm2s_arcache,
    m_axi_mm2s_arvalid => m_axi_mm2s_arvalid,
    m_axi_mm2s_arready => m_axi_mm2s_arready,
    m_axi_mm2s_rdata => m_axi_mm2s_rdata,
    m_axi_mm2s_rresp => m_axi_mm2s_rresp,
    m_axi_mm2s_rlast => m_axi_mm2s_rlast,
    m_axi_mm2s_rvalid => m_axi_mm2s_rvalid,
    m_axi_mm2s_rready => m_axi_mm2s_rready,
    mm2s_prmry_reset_out_n => a_MM2S_Prmry_Reset_Out_N,
    m_axis_mm2s_tdata => a_DMA_M_Axis_MM2S_Tdata,
    m_axis_mm2s_tkeep => a_DMA_M_Axis_MM2S_Tkeep,
    m_axis_mm2s_tvalid => a_DMA_M_Axis_MM2S_Tvalid,
    m_axis_mm2s_tready => a_DMA_M_Axis_MM2S_Tready,
    m_axis_mm2s_tlast => a_DMA_M_Axis_MM2S_Tlast,
    m_axi_s2mm_awaddr => m_axi_s2mm_awaddr,
    m_axi_s2mm_awlen => m_axi_s2mm_awlen,
    m_axi_s2mm_awsize => m_axi_s2mm_awsize,
    m_axi_s2mm_awburst => m_axi_s2mm_awburst,
    m_axi_s2mm_awprot => m_axi_s2mm_awprot,
    m_axi_s2mm_awcache => m_axi_s2mm_awcache,
    m_axi_s2mm_awvalid => m_axi_s2mm_awvalid,
    m_axi_s2mm_awready => m_axi_s2mm_awready,
    m_axi_s2mm_wdata => m_axi_s2mm_wdata,
    m_axi_s2mm_wstrb => m_axi_s2mm_wstrb,
    m_axi_s2mm_wlast => m_axi_s2mm_wlast,
    m_axi_s2mm_wvalid => m_axi_s2mm_wvalid,
    m_axi_s2mm_wready => m_axi_s2mm_wready,
    m_axi_s2mm_bresp => m_axi_s2mm_bresp,
    m_axi_s2mm_bvalid => m_axi_s2mm_bvalid,
    m_axi_s2mm_bready => m_axi_s2mm_bready,
    s2mm_prmry_reset_out_n => a_S2MM_Prmry_Reset_Out_N,
    s_axis_s2mm_tdata => a_DMA_S_Axis_S2MM_Tdata,
    s_axis_s2mm_tkeep => a_DMA_S_Axis_S2MM_Tkeep,
    s_axis_s2mm_tvalid => a_DMA_S_Axis_S2MM_Tvalid,
    s_axis_s2mm_tready => a_DMA_S_Axis_S2MM_Tready,
    s_axis_s2mm_tlast => a_DMA_S_Axis_S2MM_Tlast,
    mm2s_introut => a_MM2S_Introut,
    s2mm_introut => a_S2MM_Introut,
    axi_dma_tstvec => a_Axi_DMA_Tstvec
);

--Receive Packet FIFO   
      
Inst_FIFO: FIFO PORT MAP(
    resetn => S_AXI_ARESETN,
    rx_fifo_s_aresetn => S_AXI_ARESETN,
    rx_fifo_m_aclk => m_axi_mm2s_aclk,
    rx_fifo_s_aclk => u_Rx_Fifo_s_Aclk ,
              
    rx_fifo_s_axis_tvalid => u_Rx_Fifo_s_Axis_Tvalid,
    rx_fifo_s_axis_tready => u_Rx_Fifo_s_Axis_Tready,
    rx_fifo_s_axis_tdata => u_Rx_Fifo_s_Axis_Tdata,
    rx_fifo_s_axis_tkeep => u_Rx_Fifo_s_Axis_Tkeep,
    rx_fifo_s_axis_tlast => u_Rx_Fifo_s_Axis_Tlast,
    rx_fifo_s_axis_tuser => "0000",
    rx_fifo_m_axis_tvalid => a_FIFO_Axis_S2MM_Tvalid,
    rx_fifo_m_axis_tready => a_FIFO_Axis_S2MM_Tready,
    rx_fifo_m_axis_tdata => a_FIFO_Axis_S2MM_Tdata,
    rx_fifo_m_axis_tlast => a_FIFO_Axis_S2MM_Tlast,
    rx_fifo_m_axis_tkeep => a_FIFO_Axis_S2MM_Tkeep,
    rx_fifo_m_axis_tuser => open,
    rx_fifo_axis_overflow => u_Rx_Fifo_Axis_Overflow,
    rx_fifo_axis_underflow => u_Rx_Fifo_Axis_Underflow
);       

-- This module instantiates all the necessary modules to implement ULPI 
-- communication, Speed negotiation , Reset and Suspend. Packet data is
-- sent/received over AXI Stream. Synchronization modules for registers
-- that corss the ULPI Clock domain to AXI clock domain is implemented
-- here 
       
Inst_Protocol_Engine: Protocol_Engine PORT MAP(
    Axi_Clk => S_AXI_ACLK,
    axi_resetn => S_AXI_ARESETN,
    Ulpi_Clk => Ulpi_Clk_MMCM_Clkout0,
    u_ResetN => u_ResetN,
    ulpi_reset => open,
    u_Ulpi_Data => ulpi_data,
    u_Ulpi_Dir => ulpi_dir,
    u_Ulpi_Nxt => ulpi_nxt,
    u_Ulpi_Stp => ulpi_stp,
    led => open, 
    
    a_Arb_Endpt_Nr => a_Arb_Endpt_Nr,
    Tx_Fifo_S_Aresetn => arb_tx_fifo_s_aresetn,
    a_Tx_Fifo_S_Aclk => m_axi_s2mm_aclk,
    a_Tx_Fifo_S_Axis_Tvalid => a_FIFO_Axis_MM2S_Tvalid,
    a_Tx_Fifo_S_Axis_Tready => a_FIFO_Axis_MM2S_Tready,
    a_Tx_Fifo_S_Axis_Tdata => a_FIFO_Axis_MM2S_Tdata,
    a_Tx_Fifo_S_Axis_Tlast => a_FIFO_Axis_MM2S_Tlast,
    a_Tx_Fifo_S_Axis_Tkeep => a_FIFO_Axis_MM2S_Tkeep,
    a_Tx_Fifo_S_Axis_Tuser => "0000",
    tx_fifo_axis_overflow => open,
    tx_fifo_axis_underflow => open,
              
    u_Rx_Fifo_s_Aclk => u_Rx_Fifo_s_Aclk ,
    u_Rx_Fifo_s_Axis_Tready => u_Rx_Fifo_s_Axis_Tready,
    u_Rx_Fifo_s_Axis_Tvalid => u_Rx_Fifo_s_Axis_Tvalid,
    u_Rx_Fifo_s_Axis_Tdata => u_Rx_Fifo_s_Axis_Tdata,
    u_Rx_Fifo_s_Axis_Tkeep => u_Rx_Fifo_s_Axis_Tkeep,
    u_Rx_Fifo_s_Axis_Tlast => u_Rx_Fifo_s_Axis_Tlast,
    u_Rx_Fifo_Axis_Overflow => u_Rx_Fifo_Axis_Overflow,
    u_Rx_Fifo_Axis_Underflow => u_Rx_Fifo_Axis_Underflow,
              
    u_Command_Fifo_Rd_En => u_Command_Fifo_Rd_En,
    u_Command_Fifo_Dout  => u_Command_Fifo_Dout,
    u_Command_Fifo_Empty => u_Command_Fifo_Empty,
    u_Command_Fifo_Valid => u_Command_Fifo_Valid,
    a_FRINDEX_oData => a_FRINDEX_Wr,
    a_FRINDEX_Wr_En => a_FRINDEX_Wr_En,
    a_Setup_Buffer_Bytes_3_0_oData => a_Setup_Buffer_Bytes_3_0_Wr,
    a_Setup_Buffer_Bytes_7_4_oData => a_Setup_Buffer_Bytes_7_4_Wr, 
    a_PORTSC1_PSPD_oData => a_PORTSC1_PSPD_Wr,
    a_PORTSC1_PSPD_Wr_En => a_PORTSC1_PSPD_Wr_En,
    a_ENDPTNAK_oData => a_ENDPTNAK_Wr,
    a_ENDPTNAK_Wr_En => a_ENDPTNAK_Wr_En,
    a_ENDPTSETUP_RECEIVED_oData => a_PE_ENDPTSETUP_RECEIVED_Wr,
    a_ENDPTSETUP_RECEIVED_Wr_En => a_PE_ENDPTSETUP_RECEIVED_Wr_En,
    a_USBSTS_NAKI_oData => a_USBSTS_Wr_NAKI, 
    a_USBSTS_SLI_oData => a_USBSTS_Wr_SLI,
    a_USBSTS_SRI_oData => a_USBSTS_Wr_SRI,
    a_USBSTS_URI_oData => a_USBSTS_Wr_URI,
    a_USBSTS_PCI_oData => a_USBSTS_Wr_PCI,
    a_USBSTS_NAKI_Wr_En => a_USBSTS_Wr_En_NAK,
    a_USBSTS_SLI_Wr_En => a_USBSTS_Wr_En_SLI,
    a_USBSTS_SRI_Wr_En => a_USBSTS_Wr_En_SRI,
    a_USBSTS_URI_Wr_En => a_USBSTS_Wr_En_URI,
    a_USBSTS_PCI_Wr_En  => a_USBSTS_Wr_En_PCI,
    u_Send_Zero_Length_Packet_Rd => u_Send_Zero_Length_Packet_oData,
    a_Send_Zero_Length_Packet_Clear_oData => a_Send_Zero_Length_Packet_Clear,
    a_Send_Zero_Length_Packet_Clear_En => a_Send_Zero_Length_Packet_Clear_En,
    a_Send_Zero_Length_Packet_Ack_oData => a_Send_Zero_Length_Packet_Ack_Set,
    a_Send_Zero_Length_Packet_Ack_Set_En => a_Send_Zero_Length_Packet_Ack_Set_En,
    a_In_Packet_Complete_oData => a_In_Packet_Complete_Set,
    a_In_Packet_Complete_Set_En => a_In_Packet_Complete_Set_En,
    a_Cnt_Bytes_Sent_oData => a_Cnt_Bytes_Sent, 
    a_Cnt_Bytes_Sent_oValid => a_Cnt_Bytes_Sent_oValid,
    a_In_Token_Received_oData => a_In_Token_Received_Set,
    a_In_Token_Received_Set_En => a_In_Token_Received_Set_En,
    a_Resend_oData => a_Resend_oData,
    a_Resend_Wr_En => a_Resend_Wr_En,
    a_Endpt_Nr => a_Pe_Endpt_Nr,
    u_Endp_Nr => pe_endpt_nr_ulpi_clk, 
              
    u_Endp_Nr_Arb  => "00000", 
    u_Endp_Nr_Arb_Ack => open,
    u_Endp_Nr_Arb_Valid => '0',
    u_USBCMD_RS => u_USBCMD_RS, 
    u_Endp_Type => u_Endpt_Type_oData,
    u_Endp_Stall => u_Endpt_Stall_oData,
    u_USBADRA => u_DEVICEADDR_rd(31 downto 24),
    --      endp_enable => pe_endpt_enable,
    state_ind => state_ind,
    state_ind_hs => state_ind_hs,
    state_ind_pd => state_ind_pd
);

-- ULPI clock deskew

Ulpi_Clk_MMCM_Clkin <= ulpi_clk;

MMCME2_BASE_inst: MMCME2_BASE
generic map (
    BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
    CLKFBOUT_MULT_F => 10.0,    -- Multiply value for all CLKOUT (2.000-64.000).
    CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
    CLKIN1_PERIOD => 0.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
    -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
    CLKOUT1_DIVIDE => 1,
    CLKOUT2_DIVIDE => 1,
    CLKOUT3_DIVIDE => 1,
    CLKOUT4_DIVIDE => 1,
    CLKOUT5_DIVIDE => 1,
    CLKOUT6_DIVIDE => 1,
    CLKOUT0_DIVIDE_F => 10.0,   -- Divide amount for CLKOUT0 (1.000-128.000).
    -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
    CLKOUT0_DUTY_CYCLE => 0.5,
    CLKOUT1_DUTY_CYCLE => 0.5,
    CLKOUT2_DUTY_CYCLE => 0.5,
    CLKOUT3_DUTY_CYCLE => 0.5,
    CLKOUT4_DUTY_CYCLE => 0.5,
    CLKOUT5_DUTY_CYCLE => 0.5,
    CLKOUT6_DUTY_CYCLE => 0.5,
    -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
    CLKOUT0_PHASE => 0.0,
    CLKOUT1_PHASE => 0.0,
    CLKOUT2_PHASE => 0.0,
    CLKOUT3_PHASE => 0.0,
    CLKOUT4_PHASE => 0.0,
    CLKOUT5_PHASE => 0.0,
    CLKOUT6_PHASE => 0.0,
    CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
    DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
    REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
    STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
    )
port map (
    -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
    CLKOUT0 => Ulpi_Clk_MMCM_Clkout0,     -- 1-bit output: CLKOUT0
    CLKOUT0B => open,   -- 1-bit output: Inverted CLKOUT0
    CLKOUT1 => open,     -- 1-bit output: CLKOUT1
    CLKOUT1B => open,   -- 1-bit output: Inverted CLKOUT1
    CLKOUT2 => open,     -- 1-bit output: CLKOUT2
    CLKOUT2B => open,   -- 1-bit output: Inverted CLKOUT2
    CLKOUT3 => open,     -- 1-bit output: CLKOUT3
    CLKOUT3B => open,   -- 1-bit output: Inverted CLKOUT3
    CLKOUT4 => open,     -- 1-bit output: CLKOUT4
    CLKOUT5 => open,     -- 1-bit output: CLKOUT5
    CLKOUT6 => open,     -- 1-bit output: CLKOUT6
    -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
    CLKFBOUT => Ulpi_Clk_MMCM_Clkfbout,   -- 1-bit output: Feedback clock
    CLKFBOUTB => open, -- 1-bit output: Inverted CLKFBOUT
    -- Status Ports: 1-bit (each) output: MMCM status ports
    LOCKED => Ulpi_Clk_MMCM_Locked,       -- 1-bit output: LOCK
    -- Clock Inputs: 1-bit (each) input: Clock input
    CLKIN1 => Ulpi_Clk_MMCM_Clkin,       -- 1-bit input: Clock
    -- Control Ports: 1-bit (each) input: MMCM control ports
    PWRDWN => '0',       -- 1-bit input: Power-down
    RST => u_MMCM_Rst,             -- 1-bit input: Reset
    -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
    CLKFBIN => Ulpi_Clk_MMCM_Clkfbin      -- 1-bit input: Feedback clock
);
 

BUFG_inst : BUFG
port map (
    O => Ulpi_Clk_MMCM_Clkfbin, -- 1-bit output: Clock output 
    I => Ulpi_Clk_MMCM_Clkfbout  -- 1-bit input: Clock input 
);
  
--DMA needs to write/read to/from both packet FIFOs and context memory; "MUX" implemented below  
  
a_DMA_S_Axis_S2MM_Tdata <= a_Arb_Axis_S2MM_Tdata when (a_Axis_S2MM_Mux_Ctrl = '1') else
                           a_FIFO_Axis_S2MM_Tdata;
a_DMA_S_Axis_S2MM_Tkeep <= a_Arb_Axis_S2MM_Tkeep when (a_Axis_S2MM_Mux_Ctrl = '1') else
                           a_FIFO_Axis_S2MM_Tkeep;
a_DMA_S_Axis_S2MM_Tvalid <= a_Arb_Axis_S2MM_Tvalid when (a_Axis_S2MM_Mux_Ctrl = '1') else
                            a_FIFO_Axis_S2MM_Tvalid;
a_Arb_Axis_S2MM_Tready <= a_DMA_S_Axis_S2MM_Tready when (a_Axis_S2MM_Mux_Ctrl = '1') else
                          '0';
a_FIFO_Axis_S2MM_Tready <= a_DMA_S_Axis_S2MM_Tready when (a_Axis_S2MM_Mux_Ctrl = '0') else
                           '0';                                
a_DMA_S_Axis_S2MM_Tlast <= a_Arb_Axis_S2MM_Tlast when (a_Axis_S2MM_Mux_Ctrl = '1') else
                           a_FIFO_Axis_S2MM_Tlast;
      
a_Arb_Axis_MM2S_Tdata <= a_DMA_M_Axis_MM2S_Tdata when (a_Axis_MM2S_Mux_Ctrl = '1') else (others => '0');
a_FIFO_Axis_MM2S_Tdata <= a_DMA_M_Axis_MM2S_Tdata when (a_Axis_MM2S_Mux_Ctrl = '0') else (others => '0');
      
a_Arb_Axis_MM2S_Tkeep <= a_DMA_M_Axis_MM2S_Tkeep when (a_Axis_MM2S_Mux_Ctrl = '1') else (others => '0');
a_FIFO_Axis_MM2S_Tkeep <= a_DMA_M_Axis_MM2S_Tkeep when (a_Axis_MM2S_Mux_Ctrl = '0') else (others => '0');
            
a_Arb_Axis_MM2S_Tvalid <= a_DMA_M_Axis_MM2S_Tvalid when (a_Axis_MM2S_Mux_Ctrl = '1') else '0';
a_FIFO_Axis_MM2S_Tvalid <= a_DMA_M_Axis_MM2S_Tvalid when (a_Axis_MM2S_Mux_Ctrl = '0') else '0';
      
a_DMA_M_Axis_MM2S_Tready <= a_Arb_Axis_MM2S_Tready when (a_Axis_MM2S_Mux_Ctrl = '1') else
                            a_FIFO_Axis_MM2S_Tready;
                                
a_Arb_Axis_MM2S_Tlast <= a_DMA_M_Axis_MM2S_Tlast when (a_Axis_MM2S_Mux_Ctrl = '1') else '0';
a_FIFO_Axis_MM2S_Tlast <= a_DMA_M_Axis_MM2S_Tlast when (a_Axis_MM2S_Mux_Ctrl = '0') else '0';
      
--------------------------------------------------------------------------------------------------
                          
    ENDPTCTRL(0) <= a_ENDPTCTRL0_Rd;
    ENDPTCTRL(1) <= a_ENDPTCTRL1_Rd;
    ENDPTCTRL(2) <= a_ENDPTCTRL2_Rd;
    ENDPTCTRL(3) <= a_ENDPTCTRL3_Rd;
    ENDPTCTRL(4) <= a_ENDPTCTRL4_Rd;
    ENDPTCTRL(5) <= a_ENDPTCTRL5_Rd;
    ENDPTCTRL(6) <= a_ENDPTCTRL6_Rd;
    ENDPTCTRL(7) <= a_ENDPTCTRL7_Rd;
    ENDPTCTRL(8) <= a_ENDPTCTRL8_Rd;
    ENDPTCTRL(9) <= a_ENDPTCTRL9_Rd;
    ENDPTCTRL(10) <= a_ENDPTCTRL10_Rd; 
    ENDPTCTRL(11) <= a_ENDPTCTRL11_Rd;
    
   ENDP_TYPE_PROC: process (ENDPTCTRL)
     begin
     for endpt_type_index in 0 to 11 loop
        a_Endpt_Type_iData((endpt_type_index*4+3) downto endpt_type_index*4) <= ENDPTCTRL(endpt_type_index)(19 downto 18) & ENDPTCTRL(endpt_type_index)(3 downto 2);   
        a_Endpt_Stall_iData((endpt_type_index*2+1) downto endpt_type_index*2) <= ENDPTCTRL(endpt_type_index)(16) & ENDPTCTRL(endpt_type_index)(0); 
        a_Endpt_Enable_iData((endpt_type_index*2+1) downto endpt_type_index*2) <= ENDPTCTRL(endpt_type_index)(23) & ENDPTCTRL(endpt_type_index)(7);
     end loop;              
     end process;        
    
   TX_FIFO_RESET_PROC: process (ENDPTCTRL)
      begin
      for tx_fifo_reset_index in 0 to 11 loop
        tx_fifo_reset_vector(tx_fifo_reset_index) <= (not(a_EMDPTFLUSH_Rd(tx_fifo_reset_index+16)) and arb_tx_fifo_s_aresetn);
      end loop;              
      end process;  

--Synchronization modules for data that crosses the AXI clock domain to ULPI clock domain         

   ENDPT_TYPE_IPUSH_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_Endpt_Type_iData_q <= (others => '0');
            a_Endpt_Type_iPush <= '0';
        else
            a_Endpt_Type_iData_q <= a_Endpt_Type_iData; 
            if(a_Endpt_Type_iData_q /= a_Endpt_Type_iData and a_Endpt_Type_iRdy = '1') then
                a_Endpt_Type_iPush <= '1';
            else
                a_Endpt_Type_iPush <= '0';    
            end if;
        end if;
    end if;              
    end process;  
    
   ENDPT_STALL_IPUSH_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_Endpt_Stall_iData_q <= (others => '0');
            a_Endpt_Stall_iPush <= '0';
        else
            a_Endpt_Stall_iData_q <= a_Endpt_Stall_iData; 
            if(a_Endpt_Stall_iData_q /= a_Endpt_Stall_iData and a_Endpt_Stall_iRdy = '1') then
                a_Endpt_Stall_iPush <= '1';
            else
                a_Endpt_Stall_iPush <= '0';    
            end if;
        end if;
   end if;              
   end process;    
     
   ENDPT_ENABLE_IPUSH_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_Endpt_Enable_iData_q <= (others => '0');
            a_Endpt_Enable_iPush <= '0';
        else
            a_Endpt_Enable_iData_q <= a_Endpt_Enable_iData; 
            if(a_Endpt_Enable_iData_q /= a_Endpt_Enable_iData and a_Endpt_Enable_iRdy = '1') then
                a_Endpt_Enable_iPush <= '1';
            else
                a_Endpt_Enable_iPush <= '0';    
            end if;
        end if;
   end if;              
   end process;   
   
   ZERO_LENGTH_PUSH_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_Send_Zero_Length_Packet_iData_q <= (others => '0');
            a_Send_Zero_Length_Packet_iPush <= '0';
        else
            a_Send_Zero_Length_Packet_iData_q <= a_Send_Zero_Length_Packet_iData; 
            if(a_Send_Zero_Length_Packet_iData_q /= a_Send_Zero_Length_Packet_iData and a_Send_Zero_Length_Packet_iRdy = '1') then
                a_Send_Zero_Length_Packet_iPush <= '1';
            else
                a_Send_Zero_Length_Packet_iPush <= '0';    
            end if;
        end if;
    end if;              
    end process; 
   
    SyncAsyncPushT_USBCMD_RS: entity work.SyncAsync
        generic map (
        kResetTo => '0',
        kStages => 2)
        port map (
        aReset => a_Axi_Reset,
        aIn => a_USBCMD_RS,
        OutClk => Ulpi_Clk_MMCM_Clkout0,
        oOut => u_USBCMD_RS
        );             

    Inst_HandshakeData_endpt_type: entity work.HandshakeData  
        GENERIC MAP (
        kDataWidth => 48)
        PORT MAP(
        InClk => S_AXI_ACLK,
        OutClk => Ulpi_Clk_MMCM_Clkout0,
        iData => a_Endpt_Type_iData,
        oData => u_Endpt_Type_oData,
        iPush => a_Endpt_Type_iPush,
        iRdy => a_Endpt_Type_iRdy,
        oAck => u_Endpt_Type_oValid,
        oValid => u_Endpt_Type_oValid,
        aReset => a_Axi_Reset
        );  

    Inst_HandshakeData_endpt_stall: entity work.HandshakeData  
        GENERIC MAP (
        kDataWidth => 24)
        PORT MAP(
        InClk => S_AXI_ACLK,
        OutClk => Ulpi_Clk_MMCM_Clkout0,
        iData => a_Endpt_Stall_iData,
        oData => u_Endpt_Stall_oData,
        iPush => a_Endpt_Stall_iPush,
        iRdy => a_Endpt_Stall_iRdy,
        oAck => u_Endpt_Stall_oValid,
        oValid => u_Endpt_Stall_oValid,
        aReset => a_Axi_Reset
        );  

    Inst_HandshakeData_endpt_enable: entity work.HandshakeData  
        GENERIC MAP (
        kDataWidth => 24)
        PORT MAP(
        InClk => S_AXI_ACLK,
        OutClk => Ulpi_Clk_MMCM_Clkout0,
        iData => a_Endpt_Enable_iData,
        oData => u_Endpt_Enable_oData,
        iPush => a_Endpt_Enable_iPush,
        iRdy => a_Endpt_Enable_iRdy,
        oAck => u_Endpt_Enable_oValid,
        oValid => u_Endpt_Enable_oValid,
        aReset => a_Axi_Reset
        );  
        
    Inst_HandshakeData_send_zero_length_packet: entity work.HandshakeData  
        GENERIC MAP (
        kDataWidth => 32)
        PORT MAP(
        InClk => S_AXI_ACLK,
        OutClk => Ulpi_Clk_MMCM_Clkout0,
        iData => a_Send_Zero_Length_Packet_iData,
        oData => u_Send_Zero_Length_Packet_oData,
        iPush => a_Send_Zero_Length_Packet_iPush,
        iRdy => a_Send_Zero_Length_Packet_iRdy,
        oAck => u_Send_Zero_Length_Packet_oValid,
        oValid => u_Send_Zero_Length_Packet_oValid,
        aReset => a_Axi_Reset
        ); 
        
    Inst_HandshakeData_DEVICEADDR: entity work.HandshakeData  
         GENERIC MAP (
         kDataWidth => 32)
         PORT MAP(
         InClk => S_AXI_ACLK,
         OutClk => Ulpi_Clk_MMCM_Clkout0,
         iData => a_DEVICEADDR_rd,
         oData => u_DEVICEADDR_rd,
         iPush => a_DEVICEADDR_IPush,
         iRdy => a_DEVICEADDR_IRdy,
         oAck => u_DEVICEADDR_oValid,
         oValid => u_DEVICEADDR_oValid,
         aReset => a_Axi_Reset
         );         
                
--Interrupts
        
   a_USBSTS_UI_Change <= a_ENDPTSETUPSTAT_Wr_En or a_ENDPTCOMPLETE_Wr_En;
       
   INTERRUPT_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_INTERRUPT_Loc <= '0';
        else
            if ((a_USBINTR_Rd and a_USBSTS_Rd) /= "00000000000000000000000000000000") then
                if (a_USBSTS_UI_Change = '1') then
                    a_INTERRUPT_Loc <= '0';
                else
                    a_INTERRUPT_Loc <= '1';
                end if;    
            else
                a_INTERRUPT_Loc <= '0';    
            end if;
        end if;
    end if;              
    end process;  
    
    INTERRUPT <= a_INTERRUPT_Loc;
 
--Status Registers, Hanshake between Protocol_Engine and DMA_Transfer_Manager  
    
    ENDPT_FLUSH_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_ENDPTFLUSH_Clear <= (others => '0');
            a_ENDPTFLUSH_Clear_En <= '0';
        else
            if(a_EMDPTFLUSH_Rd /= "00000000000000000000000000000000") then
                a_ENDPTFLUSH_Clear_En <= '1';
                a_ENDPTFLUSH_Clear <= (others => '0');
            else
                a_ENDPTFLUSH_Clear_En <= '0';      
            end if;
        end if;
    end if;              
    end process;       
     
    ENDPTSETUP_RECEIVED_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_Arb_ENDPTSETUP_RECEIVED_Rd <= (others => '0');
            a_Arb_ENDPTSETUP_RECEIVED_Ack <= '0';
        else
            if (a_PE_ENDPTSETUP_RECEIVED_Wr_En = '1') then
                a_Arb_ENDPTSETUP_RECEIVED_Rd <= a_PE_ENDPTSETUP_RECEIVED_Wr;
                a_Arb_ENDPTSETUP_RECEIVED_Ack <= '0';
            elsif(a_Arb_ENDPTSETUP_RECEIVED_Clear_En = '1') then
                a_Arb_ENDPTSETUP_RECEIVED_Rd <= a_Arb_ENDPTSETUP_RECEIVED_Rd and a_Arb_ENDPTSETUP_RECEIVED_Clear;
                a_Arb_ENDPTSETUP_RECEIVED_Ack <= '1';
            else 
                a_Arb_ENDPTSETUP_RECEIVED_Ack <= '0';    
            end if;
        end if;
    end if;              
    end process;

    PACKET_IN_COMPLETE_RD_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_In_Packet_Complete_Rd <= (others => '0');
        else
            if (a_In_Packet_Complete_Set_En = '1') then
                a_In_Packet_Complete_Rd <= a_In_Packet_Complete_Rd or a_In_Packet_Complete_Set;
            elsif(a_In_Packet_Complete_Clear_En = '1') then
                a_In_Packet_Complete_Rd <= a_In_Packet_Complete_Rd and a_In_Packet_Complete_Clear;   
            end if;
        end if;
    end if;              
    end process;      
   
    SEND_ZERO_LENGTH_RD_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_Send_Zero_Length_Packet_iData <= (others => '0');
        else
            if (a_Send_Zero_Length_Packet_Set_En = '1') then
                a_Send_Zero_Length_Packet_iData <= a_Send_Zero_Length_Packet_iData or a_Send_Zero_Length_Packet_Set;
            elsif(a_Send_Zero_Length_Packet_Clear_En = '1') then
                a_Send_Zero_Length_Packet_iData <= a_Send_Zero_Length_Packet_iData and a_Send_Zero_Length_Packet_Clear;   
            end if;
        end if;
    end if;              
    end process;     

    SEND_ZERO_LENGTH_ACK_RD_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_Send_Zero_Length_Packet_Ack_Rd <= (others => '0');
        else
            if (a_Send_Zero_Length_Packet_Ack_Set_En = '1') then
                a_Send_Zero_Length_Packet_Ack_Rd <= a_Send_Zero_Length_Packet_Ack_Rd or a_Send_Zero_Length_Packet_Ack_Set;
            elsif(a_Send_Zero_Length_Packet_Ack_Clear_En = '1') then
                a_Send_Zero_Length_Packet_Ack_Rd <= a_Send_Zero_Length_Packet_Ack_Rd and a_Send_Zero_Length_Packet_Ack_Clear;   
            end if;
        end if;
    end if;              
    end process; 

    RESEND_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_Resend <= (others => '0');
        else
            if (a_Resend_Wr_En = '1') then
                a_Resend <= a_Resend or a_Resend_oData;
            elsif(a_Resend_Clear_En = '1') then
                a_Resend <= a_Resend and a_Resend_Clear;   
            end if;
        end if;
    end if;              
    end process; 
    
    PE_IN_TOKEN_RECEIVED_PROC: process (S_AXI_ACLK)
    begin
    if (S_AXI_ACLK' event and S_AXI_ACLK = '1') then
        if (S_AXI_ARESETN = '0') then
            a_In_Token_Received_Rd <= (others => '0');
        else
            if (a_In_Token_Received_Set_En = '1') then
                a_In_Token_Received_Rd <= a_In_Token_Received_Rd or a_In_Token_Received_Set;
            elsif(a_In_Token_Received_Clear_En = '1') then
                a_In_Token_Received_Rd <= a_In_Token_Received_Rd and a_In_Token_Received_Clear;   
            end if;
        end if;
    end if;              
    end process;   
                 
end Behavioral;
