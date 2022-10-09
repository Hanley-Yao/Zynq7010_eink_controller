-------------------------------------------------------------------------------
--
-- File: DMA_Transfer_Manager.vhd
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
-- This module manages all transfers from main memory to local buffers through 
-- DMA, both control data (Queue Heads, Transfer Descriptors)and packet data.  
-- Control registers are visible to this module.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

entity DMA_Transfer_Manager is
	generic (
		-- The master will start generating data from the C_M_START_DATA_VALUE value
		C_M_START_DATA_VALUE	: std_logic_vector	:= x"AA000000";
		-- The master requires a target slave base address.
    -- The master will initiate read and write transactions on the slave with base address specified here as a parameter.
		C_M_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= "0100000000";
		-- Width of M_AXI address bus. 
    -- The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.
		C_M_AXI_ADDR_WIDTH	: integer	:= 10;
		-- Width of M_AXI data bus. 
    -- The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH
		C_M_AXI_DATA_WIDTH	: integer	:= 32;
		-- Transaction number is the number of write 
    -- and read transactions the master will perform as a part of this example memory test.
		C_M_TRANSACTIONS_NUM	: integer	:= 4;
		
		C_FIFO_SIZE	: integer	:= 64
	);
	port (
		Axi_Clk : IN std_logic;
	    Axi_Resetn : IN std_logic;
	    state_ind_dma : out STD_LOGIC_VECTOR(4 downto 0); --debug purposes
	    state_ind_arb : out std_logic_vector(5 downto 0); --debug purposes 
	    DEBUG_REG_DATA : OUT std_logic_vector(31 downto 0); --debug purposes 
	    ind_statte_axistream : out std_logic_vector(4 downto 0); --debug purposes 
        
        --AXI Lite Master for DMA control
		a_M_Axi_Awaddr	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		a_M_Axi_Awprot	: out std_logic_vector(2 downto 0);
		a_M_Axi_Awvalid	: out std_logic;
		a_M_Axi_Awready	: in std_logic;
		a_M_Axi_Wdata	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		a_M_Axi_Wstrb	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		a_M_Axi_Wvalid	: out std_logic;
		a_M_Axi_Wready	: in std_logic;
		a_M_Axi_Bresp	: in std_logic_vector(1 downto 0);
		a_M_Axi_Bvalid	: in std_logic;
		a_M_Axi_Bready	: out std_logic;
		a_M_Axi_Araddr	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		a_M_Axi_Arprot	: out std_logic_vector(2 downto 0); 
		a_M_Axi_Arvalid	: out std_logic;
		a_M_Axi_Arready	: in std_logic;
		a_M_Axi_Rdata	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		a_M_Axi_Rresp	: in std_logic_vector(1 downto 0);
		a_M_Axi_Rvalid	: in std_logic;
		a_M_Axi_Rready	: out std_logic;
		
		--AXI Stream interface taht enables the DMA to write/read to/from the Context Memory
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
        
        --Command FIFO; used to keep track of received OUT transactions
        RX_COMMAND_FIFO_RD_EN : OUT std_logic;
        RX_COMMAND_FIFO_DOUT  : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
        RX_COMMAND_FIFO_EMPTY : IN std_logic;
        RX_COMMAND_FIFO_VALID : IN std_logic;
        --FIFO control signals
        arb_tx_fifo_s_aresetn : OUT std_logic;
        
        --multiplex between FIFO access and Context memory access
        a_Axis_MM2S_Mux_Ctrl  : OUT STD_LOGIC;
        a_Axis_S2MM_Mux_Ctrl  : OUT STD_LOGIC;
        
        --Protocol_Engine interface
        a_Send_Zero_Length_Packet_Set : OUT STD_LOGIC_VECTOR(31 downto 0); --ZLP Hanshake between Packet_Decoder and DMA_Transfer_Manager
        a_Send_Zero_Length_Packet_Set_En : OUT STD_LOGIC; --ZLP Hanshake between Packet_Decoder and DMA_Transfer_Manager
        a_Send_Zero_Length_Packet_Ack_Rd : IN STD_LOGIC_VECTOR(31 downto 0); --ZLP Hanshake between Packet_Decoder and DMA_Transfer_Manager
        a_Send_Zero_Length_Packet_Ack_Clear : OUT STD_LOGIC_VECTOR(31 downto 0); --ZLP Hanshake between Packet_Decoder and DMA_Transfer_Manager
        a_Send_Zero_Length_Packet_Ack_Clear_En : OUT STD_LOGIC; --ZLP Hanshake between Packet_Decoder and DMA_Transfer_Manager
        a_Arb_dQH_Setup_Buffer_Bytes_3_0_Wr  : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --Setup packets are stored in these registers before being copied into the dQH
        a_Arb_dQH_Setup_Buffer_Bytes_7_4_Wr  : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --Setup packets are stored in these registers before being copied into the dQH

        a_In_Packet_Complete_Rd : IN STD_LOGIC_VECTOR(31 downto 0); --a bit is set when the corresponding endpoint has completed an IN transaction
        a_In_Packet_Complete_Clear : OUT STD_LOGIC_VECTOR(31 downto 0);  --In_Packet_Complete Hanshake between DMA_Transfer_Manager and Packet_Decoder 
        a_In_Packet_Complete_Clear_En : OUT STD_LOGIC; --In_Packet_Complete Hanshake between DMA_Transfer_Manager and Packet_Decoder 
        a_In_Token_Received_Rd  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  -- a bit is set when the corresponding endpoint has received an IN token
        a_In_Token_Received_Clear : OUT STD_LOGIC_VECTOR(31 downto 0); --In_Token_Received_Clear Hanshake between DMA_Transfer_Manager and Packet_Decoder 
        a_In_Token_Received_Clear_En : OUT STD_LOGIC; --In_Token_Received_Clear Hanshake between DMA_Transfer_Manager and Packet_Decoder 
        a_Cnt_Bytes_Sent : in std_logic_vector(12 downto 0);  --number of bytes sent in response to an IN token
        a_Cnt_Bytes_Sent_oValid : IN std_logic;
        a_Resend : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --indicates that the endpoint corresponding to set bits need to resend a packet
        a_Resend_Clear : OUT STD_LOGIC_VECTOR(31 downto 0); --Resend Hanshake between DMA_Transfer_Manager and Packet_Decoder 
        a_Resend_Clear_En : OUT STD_LOGIC; --Resend Hanshake between DMA_Transfer_Manager and Packet_Decoder 
        a_Pe_Endpt_Nr  : IN STD_LOGIC_VECTOR(4 DOWNTO 0);  --endpoint accessed by the lower layers (ULPI, Packet_Decoder)
        a_Arb_Endpt_Nr : OUT std_logic_vector(4 downto 0); --endpoint accessed by the DMA_Transfer_Manager
     
        --Control_Registers interface
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
end DMA_Transfer_Manager;

architecture implementation of DMA_Transfer_Manager is  
    
	COMPONENT DMA_Operations
    PORT(
    
        CLK : in STD_LOGIC;
        RESETN : in STD_LOGIC;
        DEBUG_REG_DATA : OUT std_logic_vector(31 downto 0);
        state_ind_dma : out STD_LOGIC_VECTOR(4 downto 0);
        M_AXI_AWREADY : IN std_logic;
        M_AXI_WREADY : IN std_logic;
        M_AXI_BRESP : IN std_logic_vector(1 downto 0);
        M_AXI_BVALID : IN std_logic;
        M_AXI_ARREADY : IN std_logic;
        M_AXI_RDATA : IN std_logic_vector(31 downto 0);
        M_AXI_RRESP : IN std_logic_vector(1 downto 0);
        M_AXI_RVALID : IN std_logic;  

        M_AXI_AWADDR : OUT std_logic_vector(9 downto 0);
        M_AXI_AWPROT : OUT std_logic_vector(2 downto 0);
        M_AXI_AWVALID : OUT std_logic;
        M_AXI_WDATA : OUT std_logic_vector(31 downto 0);
        M_AXI_WSTRB : OUT std_logic_vector(3 downto 0);
        M_AXI_WVALID : OUT std_logic;
        M_AXI_BREADY : OUT std_logic;
        M_AXI_ARADDR : OUT std_logic_vector(9 downto 0);
        M_AXI_ARPROT : OUT std_logic_vector(2 downto 0);
        M_AXI_ARVALID : OUT std_logic;
        M_AXI_RREADY : OUT std_logic;
        
        dma_transfer_complete  : OUT std_logic;
        start_dma_s2mm : IN std_logic;
        start_dma_mm2s : IN std_logic;
        dma_transfer_length : in STD_LOGIC_VECTOR(31 downto 0);
        dma_source_dest_address : IN std_logic_vector(31 downto 0)
        );
    END COMPONENT;  
    
    COMPONENT Context
    PORT(
        CLK : IN std_logic;
        RESETN : IN std_logic;
        ENDPT_NR : in integer range 0 to 22;
--        ENDPT_NR_PD : in integer range 0 to 22;
        RD_EN : IN std_logic;
        WR_EN : IN std_logic;
        dTD_TOTAL_BYTES_WR_EN : IN std_logic; 
        dTD_STATUS_WR_EN : IN std_logic;
        dQH_CURRENT_dTD_POINTER_wr_EN  : in STD_LOGIC;
        dQH_NEXT_dTD_POINTER_wr_EN  : in STD_LOGIC;
        dQH_SETUP_BUFFER_wr_EN : in STD_LOGIC;
        dQH_MULT_wr : IN std_logic_vector(1 downto 0);
        dQH_ZLT_wr : IN std_logic;
        dQH_MAX_PACKET_LENGTH_wr : IN std_logic_vector(10 downto 0);
        dQH_IOS_wr : IN std_logic;
        dQH_CURRENT_dTD_POINTER_wr : IN std_logic_vector(26 downto 0);
        dQH_NEXT_dTD_POINTER_wr : IN std_logic_vector(26 downto 0);
        dQH_T_wr : IN std_logic;
        dQH_SETUP_BUFFER_BYTES_3_0_wr : IN std_logic_vector(31 downto 0);
        dQH_SETUP_BUFFER_BYTES_7_4_wr : IN std_logic_vector(31 downto 0);
        dTD_TOTAL_BYTES_wr : IN std_logic_vector(14 downto 0);
        dTD_IOC_wr : IN std_logic;
        dTD_C_PAGE_wr : IN std_logic_vector(2 downto 0);
        dTD_MULT_wr : IN std_logic_vector(1 downto 0);
        dTD_STATUS_wr : IN std_logic_vector(7 downto 0);
        dTD_PAGE0_wr : IN std_logic_vector(19 downto 0);
        dTD_PAGE1_wr : IN std_logic_vector(19 downto 0);
        dTD_PAGE2_wr : IN std_logic_vector(19 downto 0);
        dTD_PAGE3_wr : IN std_logic_vector(19 downto 0);
        dTD_PAGE4_wr : IN std_logic_vector(19 downto 0);
        dTD_CURRENT_OFFSET_wr : IN std_logic_vector(11 downto 0);          
        dQH_MULT_rd : OUT std_logic_vector(1 downto 0);
        dQH_ZLT_rd : OUT std_logic;
--        pe_dQH_ZLT_rd : OUT STD_LOGIC;
        dQH_MAX_PACKET_LENGTH_rd : OUT std_logic_vector(10 downto 0);
        dQH_IOS_rd : OUT std_logic;
        dQH_CURRENT_dTD_POINTER_rd : OUT std_logic_vector(26 downto 0);
        dQH_NEXT_dTD_POINTER_rd : OUT std_logic_vector(26 downto 0);
        dQH_T_rd : OUT std_logic;
        dQH_SETUP_BUFFER_BYTES_3_0_rd : OUT std_logic_vector(31 downto 0);
        dQH_SETUP_BUFFER_BYTES_7_4_rd : OUT std_logic_vector(31 downto 0);
        dTD_TOTAL_BYTES_rd : OUT std_logic_vector(14 downto 0);
        dTD_IOC_rd : OUT std_logic;
        dTD_C_PAGE_rd : OUT std_logic_vector(2 downto 0);
        dTD_MULT_rd : OUT std_logic_vector(1 downto 0);
        dTD_STATUS_rd : OUT std_logic_vector(7 downto 0);
        dTD_PAGE0_rd : OUT std_logic_vector(19 downto 0);
        dTD_PAGE1_rd : OUT std_logic_vector(19 downto 0);
        dTD_PAGE2_rd : OUT std_logic_vector(19 downto 0);
        dTD_PAGE3_rd : OUT std_logic_vector(19 downto 0);
        dTD_PAGE4_rd : OUT std_logic_vector(19 downto 0);
        dTD_CURRENT_OFFSET_rd : OUT std_logic_vector(11 downto 0)
        );
    END COMPONENT; 
    
	COMPONENT Context_to_Stream
    PORT(
        CLK : IN std_logic;
        RESETN : IN std_logic;
        ind_statte_axistream : out std_logic_vector(4 downto 0);
        dQH_RD : IN std_logic;
        dQH_WR : IN std_logic;
        dTD_RD : IN std_logic;
        dTD_WR : IN std_logic;
        SETUP_WR : IN STD_LOGIC;
        dQH_WR_EN : out STD_LOGIC;
        s_axis_mm2s_tdata : IN std_logic_vector(31 downto 0);
        s_axis_mm2s_tkeep : IN std_logic_vector(3 downto 0);
        s_axis_mm2s_tvalid : IN std_logic;
        s_axis_mm2s_tlast : IN std_logic;
        m_axis_s2mm_tready : IN std_logic;
        dQH_MULT_rd : IN std_logic_vector(1 downto 0);
        dQH_ZLT_rd : IN std_logic;
        dQH_MAX_PACKET_LENGTH_rd : IN std_logic_vector(10 downto 0);
        dQH_IOS_rd : IN std_logic;
        dQH_CURRENT_dTD_POINTER_rd : IN std_logic_vector(26 downto 0);
        dQH_NEXT_dTD_POINTER_rd : IN std_logic_vector(26 downto 0);
        dQH_T_rd : IN std_logic;
        dQH_SETUP_BUFFER_BYTES_3_0_rd : IN std_logic_vector(31 downto 0);
        dQH_SETUP_BUFFER_BYTES_7_4_rd : IN std_logic_vector(31 downto 0);
        dTD_TOTAL_BYTES_rd : IN std_logic_vector(14 downto 0);
        dTD_IOC_rd : IN std_logic;
        dTD_C_PAGE_rd : IN std_logic_vector(2 downto 0);
        dTD_MULT_rd : IN std_logic_vector(1 downto 0);
        dTD_STATUS_rd : IN std_logic_vector(7 downto 0);
        dTD_PAGE0_rd : IN std_logic_vector(19 downto 0);
        dTD_PAGE1_rd : IN std_logic_vector(19 downto 0);
        dTD_PAGE2_rd : IN std_logic_vector(19 downto 0);
        dTD_PAGE3_rd : IN std_logic_vector(19 downto 0);
        dTD_PAGE4_rd : IN std_logic_vector(19 downto 0);
        dTD_CURRENT_OFFSET_rd : IN std_logic_vector(11 downto 0);          
        s_axis_mm2s_tready : OUT std_logic;
        m_axis_s2mm_tdata : OUT std_logic_vector(31 downto 0);
        m_axis_s2mm_tkeep : OUT std_logic_vector(3 downto 0);
        m_axis_s2mm_tvalid : OUT std_logic;
        m_axis_s2mm_tlast : OUT std_logic;
        dQH_MULT_wr : OUT std_logic_vector(1 downto 0);
        dQH_ZLT_wr : OUT std_logic;
        dQH_MAX_PACKET_LENGTH_wr : OUT std_logic_vector(10 downto 0);
        dQH_IOS_wr : OUT std_logic;
        dQH_CURRENT_dTD_POINTER_wr : OUT std_logic_vector(26 downto 0);
        dQH_NEXT_dTD_POINTER_wr : OUT std_logic_vector(26 downto 0);
        dQH_T_wr : OUT std_logic;
        dQH_SETUP_BUFFER_BYTES_3_0_wr : OUT std_logic_vector(31 downto 0);
        dQH_SETUP_BUFFER_BYTES_7_4_wr : OUT std_logic_vector(31 downto 0);
        dTD_TOTAL_BYTES_wr : OUT std_logic_vector(14 downto 0);
        dTD_IOC_wr : OUT std_logic;
        dTD_C_PAGE_wr : OUT std_logic_vector(2 downto 0);
        dTD_MULT_wr : OUT std_logic_vector(1 downto 0);
        dTD_STATUS_wr : OUT std_logic_vector(7 downto 0);
        dTD_PAGE0_wr : OUT std_logic_vector(19 downto 0);
        dTD_PAGE1_wr : OUT std_logic_vector(19 downto 0);
        dTD_PAGE2_wr : OUT std_logic_vector(19 downto 0);
        dTD_PAGE3_wr : OUT std_logic_vector(19 downto 0);
        dTD_PAGE4_wr : OUT std_logic_vector(19 downto 0);
        dTD_CURRENT_OFFSET_wr : OUT std_logic_vector(11 downto 0)
        );               
    END COMPONENT;
    
constant ATDTW : integer := 14;
constant SUTW : integer  := 13;
constant SLOM : integer  := 3;

type state_type is (IDLE, PRIME_MM2S_DQH, PRIME_WAIT0, PRIME_MM2S_DTD, PRIME_WAIT1, PRIME_WAIT2, PRIME_FILL_FIFO, PRIME_FILL_FIFO_1, IN_HANDSHAKE, PRIME_FILL_FIFO_2, SETUP_LOCKOUT_TRIPWIRE, SETUP_UPDATE_SETUP_BYTES, SETUP_WAIT1, SETUP_S2MM, SETUP_UPDATE_ENDPTSETUP_RECEIVED, SETUP_WAIT2, START_OUT_FRAMEWORK, OUT_START_TRANSFER, OUT_TRANSFER_S2MM, OUT_WAIT1, OUT_CHECK_COMPLETE, OUT_TRANSFER_COMPLETE, OUT_FETCH_NEXT_DTD, OUT_WAIT2,START_IN_FRAMEWORK, IN_TRANSFER_MM2S, IN_RELOAD_BUFFER, IN_WAIT0, IN_WAIT1, IN_CHECK_COMPLETE, IN_TRANSACTION_COMPLETE, IN_FETCH_NEXT_DTD, IN_WAIT2); 
signal state, next_state : state_type;  
type DMA_CURRENT_TRANSFER_ADDRESS is array (11 downto 0) of std_logic_vector(31 downto 0);
signal a_DMA_Current_Transfer_Addr_Array, a_DMA_Current_Transfer_Addr_Array_q : DMA_CURRENT_TRANSFER_ADDRESS; 
                                               
signal a_Context_Mux_Ctrl    :  std_logic;
signal a_Read_dQH    :  std_logic;
signal a_Read_dQH_Fsm    :  std_logic;
signal a_Read_dQH_q    :  std_logic;
signal a_Write_dQH    :  std_logic;
signal a_Write_dQH_Fsm    :  std_logic;
signal a_Write_dQH_q   :  std_logic;
signal a_Read_dTD    :  std_logic;
signal a_Read_dTD_Fsm    :  std_logic;
signal a_Read_dTD_q    :  std_logic; 
signal write_dTD    :  std_logic;
signal a_Write_Setup_Bytes, a_Write_Setup_Bytes_q, a_Write_Setup_Bytes_FSM    :  std_logic;
signal a_dQH_Wr_En_Mux_Stream    :  std_logic;
signal a_dQH_Wr_En_Mux_Out    :  std_logic;
signal a_dQH_Wr_En_Mux_Arb    :  std_logic;
signal a_Start_DMA_S2MM    :  std_logic;
signal a_Start_DMA_MM2S    :  std_logic;
signal a_DMA_Source_Dest_Addr	: std_logic_vector(31 downto 0);
signal a_DMA_Transfer_Length    : std_logic_vector(31 downto 0);
signal a_DMA_Current_Transfer_Addr_Fsm : std_logic_vector (31 downto 0);
signal a_DMA_Current_Transfer_Addr_Le : std_logic;
signal a_DMA_Transfer_Complete : STD_LOGIC;
signal a_Aux_Addr_Register : std_logic_vector (31 downto 0);
signal a_DMA_In_Transfer_Length : std_logic_vector (31 downto 0);
signal a_DMA_In_Transfer_Length_Le : std_logic;
signal a_Axis_MM2S_Mux_Ctrl_Fsm , a_Axis_S2MM_Mux_Ctrl_Fsm  : STD_LOGIC;
    
signal a_Arb_dQH_MULT_Wr : STD_LOGIC_VECTOR (1 downto 0);  --not used
signal a_Arb_dQH_ZLT_Wr : STD_LOGIC;  --not used
signal a_Arb_dQH_Max_Packet_Length_Wr : STD_LOGIC_VECTOR (10 downto 0);  --not used
signal a_Arb_dQH_IOS_Wr : STD_LOGIC;  --not used
signal a_Arb_dQH_Current_dTD_Pointer_Wr : STD_LOGIC_VECTOR (26 downto 0);
signal a_Arb_dQH_Current_dTD_Pointer_Wr_En  : STD_LOGIC;
signal a_Arb_dQH_Next_dTD_Pointer_Wr : STD_LOGIC_VECTOR (26 downto 0);  --not used
signal a_Arb_dQH_Next_dTD_Pointer_Wr_En  : STD_LOGIC; --not used
signal a_Arb_dQH_T_Wr : STD_LOGIC; --not used  
signal a_Arb_dTD_Total_Bytes_Wr : STD_LOGIC_VECTOR (14 downto 0);
signal a_Arb_dTD_Total_Bytes_Wr_En  : STD_LOGIC;
signal a_Arb_dTD_IOC_Wr : STD_LOGIC; --not used
signal a_Arb_dTD_C_Page_Wr : STD_LOGIC_VECTOR (2 downto 0); --not used
signal a_Arb_dTD_Mult_Wr : STD_LOGIC_VECTOR (1 downto 0); --not used
signal a_Arb_dTD_Status_Wr : STD_LOGIC_VECTOR (7 downto 0); --not used
signal a_Arb_dTD_Page0_Wr : STD_LOGIC_VECTOR (19 downto 0); --not used
signal a_Arb_dTD_Page1_Wr : STD_LOGIC_VECTOR (19 downto 0); --not used
signal a_Arb_dTD_Page2_Wr : STD_LOGIC_VECTOR (19 downto 0); --not used
signal a_Arb_dTD_Page3_Wr : STD_LOGIC_VECTOR (19 downto 0); --not used
signal a_Arb_dTD_Page4_wr : STD_LOGIC_VECTOR (19 downto 0); --not used
signal a_Arb_dTD_Current_Offset_Wr : STD_LOGIC_VECTOR (11 downto 0); --not used    
    
signal a_Stream_dQH_Mult_Wr : STD_LOGIC_VECTOR (1 downto 0);
signal a_Stream_dQH_Zlt_Wr : STD_LOGIC;
signal a_Stream_dQH_Max_Packet_Length_Wr : STD_LOGIC_VECTOR (10 downto 0);
signal a_Stream_dQH_IOS_Wr : STD_LOGIC;
signal a_Stream_dQH_Current_dTD_Pointer_Wr : STD_LOGIC_VECTOR (26 downto 0);
signal a_Stream_dQH_Next_dTD_Pointer_wr : STD_LOGIC_VECTOR (26 downto 0);
signal a_Stream_dQH_T_Wr : STD_LOGIC;
signal a_Stream_dQH_Setup_Buffer_Bytes_3_0_Wr : STD_LOGIC_VECTOR (31 downto 0);
signal a_Stream_dQH_Setup_Buffer_Bytes_7_4_Wr : STD_LOGIC_VECTOR (31 downto 0);   
signal a_Stream_dTD_Total_Bytes_Wr : STD_LOGIC_VECTOR (14 downto 0);
signal a_Stream_dTD_IOC_Wr : STD_LOGIC;
signal a_Stream_dTD_C_Page_Wr : STD_LOGIC_VECTOR (2 downto 0);
signal a_Stream_dTD_Mult_Wr : STD_LOGIC_VECTOR (1 downto 0);
signal a_Stream_dTD_Status_Wr : STD_LOGIC_VECTOR (7 downto 0);
signal a_Stream_dTD_Page0_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_Stream_dTD_Page1_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_Stream_dTD_Page2_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_Stream_dTD_Page3_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_Stream_dTD_Page4_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_Stream_dTD_Current_Offset_Wr : STD_LOGIC_VECTOR (11 downto 0);
    
signal a_dQH_Mult_Wr : STD_LOGIC_VECTOR (1 downto 0);
signal a_dQH_ZLT_Wr : STD_LOGIC;
signal a_dQH_Max_Packet_Length_Wr : STD_LOGIC_VECTOR (10 downto 0);
signal a_dQH_IOS_Wr : STD_LOGIC;
signal a_dQH_Current_dTD_Pointer_Wr : STD_LOGIC_VECTOR (26 downto 0);
signal a_dQH_Next_dTD_Pointer_Wr : STD_LOGIC_VECTOR (26 downto 0);
signal a_dQH_T_Wr : STD_LOGIC;
signal a_dQH_Setup_Buffer_Bytes_3_0_Wr : STD_LOGIC_VECTOR (31 downto 0);
signal a_dQH_Setup_Buffer_Bytes_7_4_Wr : STD_LOGIC_VECTOR (31 downto 0);   
signal a_dTD_Total_Bytes_Wr : STD_LOGIC_VECTOR (14 downto 0);
signal a_dTD_IOC_Wr : STD_LOGIC;
signal a_dTD_C_Page_Wr : STD_LOGIC_VECTOR (2 downto 0);
signal a_dTD_Mult_Wr : STD_LOGIC_VECTOR (1 downto 0);
signal a_dTD_Status_Wr : STD_LOGIC_VECTOR (7 downto 0);
signal a_dTD_Page0_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Page1_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Page2_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Page3_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Page4_Wr : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Current_Offset_Wr : STD_LOGIC_VECTOR (11 downto 0); 
signal a_dQH_Setup_Buffer_Wr_En    :  std_logic;
signal a_dTD_Status_Wr_En : STD_LOGIC;
    
signal a_dQH_MULT_Rd : STD_LOGIC_VECTOR (1 downto 0);
signal a_dQH_ZLT_Rd : STD_LOGIC;
signal a_dQH_Max_Packet_Length_Rd : STD_LOGIC_VECTOR (10 downto 0);
signal a_dQH_IOS_Rd : STD_LOGIC;
signal a_dQH_Current_dTD_Pointer_Rd : STD_LOGIC_VECTOR (26 downto 0);
signal a_dQH_Next_dTD_Pointer_Rd : STD_LOGIC_VECTOR (26 downto 0);
signal a_dQH_T_Rd : STD_LOGIC;
signal a_dQH_Setup_Buffer_Bytes_3_0_Rd : STD_LOGIC_VECTOR (31 downto 0);
signal a_dQH_Setup_Buffer_Bytes_7_4_Rd : STD_LOGIC_VECTOR (31 downto 0);   
signal a_dTD_Total_Bytes_Rd : STD_LOGIC_VECTOR (14 downto 0);
signal a_dTD_IOC_Rd : STD_LOGIC;
signal a_dTD_C_Page_Rd : STD_LOGIC_VECTOR (2 downto 0);
signal a_dTD_Mult_Rd : STD_LOGIC_VECTOR (1 downto 0);
signal a_dTD_Status_Rd : STD_LOGIC_VECTOR (7 downto 0);
signal a_dTD_Page0_Rd : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Page1_Rd : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Page2_Rd : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Page3_Rd : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Page4_Rd : STD_LOGIC_VECTOR (19 downto 0);
signal a_dTD_Current_Offset_Rd : STD_LOGIC_VECTOR (11 downto 0);
signal a_Out_Transfer_Byte_Count_Le1 : STD_LOGIC;
signal a_Out_Transfer_Byte_Count_Le2 : STD_LOGIC;  
signal a_Out_Transfer_Byte_Count : std_logic_vector (12 downto 0);

signal a_Endpointlistaddr_Loc	: std_logic_vector(20 downto 0);
signal a_ENDPTSETUPSTAT_Wr_En_Fsm    : std_logic;
signal a_ENDPTSETUPSTAT_Wr_Fsm    : std_logic_vector(31 downto 0);
signal a_USBSTS_Wr_UI_Fsm    : std_logic;
signal a_USBSTS_Wr_En_UI_Fsm    : std_logic;
signal a_ENDPTSTAT_Set : std_logic_vector(31 downto 0);
signal a_ENDPTSTAT_Set_En : std_logic;
signal a_ENDPTSTAT_clear	: std_logic_vector(31 downto 0);
signal a_ENDPTSTAT_Clear_En : std_logic;
signal a_ENDPTSTAT_Wr_Loc : std_logic_vector(31 downto 0);
    
signal tx_fifo_resetn : std_logic;
    
signal a_Prime : STD_LOGIC; 
signal a_Setup_Received : STD_LOGIC;
signal a_In_Token_Received : STD_LOGIC;
signal a_Endpt_Nr_Int : integer range 0 to 23;
signal a_Endpt_Nr_Fsm : integer range 0 to 23;
signal a_Endpt_Nr_Le : STD_LOGIC;
signal a_Endpt_Nr : std_logic_vector(4 downto 0);
signal a_Endpt_Nr_4b : integer range 0 to 27;
signal a_Endpt_Nr_Prime : integer range 0 to 23;
signal a_Endpt_Nr_Setup : integer range 0 to 23;
signal a_Endpt_Nr_In_Token : integer range 0 to 23;
signal a_Endpt_In_Out : STD_LOGIC; 
signal a_Bit_Index : integer range 0 to 27;  
signal a_Cnt_Bytes_Sent_Loc : std_logic_vector (12 downto 0);
    
--    attribute mark_debug : string;
--    attribute keep : string;
--    attribute mark_debug of state_ind_arb : signal is "true";
--    attribute keep of state_ind_arb : signal is "true"; 
--    attribute mark_debug of a_ENDPTCOMPLETE_Wr_En : signal is "true";     
--    attribute keep of a_ENDPTCOMPLETE_Wr_En : signal is "true";
--    attribute mark_debug of a_ENDPTCOMPLETE_Wr : signal is "true";     
--    attribute keep of a_ENDPTCOMPLETE_Wr : signal is "true";
--    attribute mark_debug of a_Setup_Received : signal is "true";
--    attribute keep of a_Setup_Received : signal is "true";
--    attribute mark_debug of a_Cnt_Bytes_Sent_Loc : signal is "true";
--    attribute keep of a_Cnt_Bytes_Sent_Loc : signal is "true";       
--    attribute mark_debug of a_In_Packet_Complete_Rd : signal is "true"; 
--    attribute keep of a_In_Packet_Complete_Rd : signal is "true";  
--    attribute mark_debug of a_In_Token_Received : signal is "true"; 
--    attribute keep of a_In_Token_Received : signal is "true"; 
--    attribute mark_debug of a_Arb_ENDPTSETUP_RECEIVED_Rd : signal is "true"; 
--    attribute keep of a_Arb_ENDPTSETUP_RECEIVED_Rd : signal is "true"; 
--    attribute mark_debug of a_Bit_Index : signal is "true"; 
--    attribute keep of a_Bit_Index : signal is "true";
--    attribute mark_debug of a_Endpt_Nr_Prime : signal is "true";  
--    attribute keep of a_Endpt_Nr_Prime : signal is "true";
--    attribute mark_debug of a_Endpt_Nr : signal is "true"; 
--    attribute keep of a_Endpt_Nr : signal is "true";
--    attribute mark_debug of a_Endpt_In_Out : signal is "true"; 
--    attribute keep of a_Endpt_In_Out : signal is "true";
--    attribute mark_debug of a_In_Token_Received_Rd : signal is "true"; 
--    attribute keep of a_In_Token_Received_Rd : signal is "true";
--    attribute mark_debug of a_dTD_Total_Bytes_Rd : signal is "true"; 
--    attribute keep of a_dTD_Total_Bytes_Rd : signal is "true";    
--    attribute mark_debug of a_Prime : signal is "true"; 
--    attribute keep of a_Prime : signal is "true";  
--    attribute mark_debug of a_ENDPTSTAT_Wr_Loc : signal is "true"; 
--    attribute keep of a_ENDPTSTAT_Wr_Loc : signal is "true"; 
--    attribute mark_debug of a_ENDPTSTAT_Set_En : signal is "true"; 
--    attribute keep of a_ENDPTSTAT_Set_En : signal is "true";  
--    attribute mark_debug of a_ENDPTSTAT_Set : signal is "true"; 
--    attribute keep of a_ENDPTSTAT_Set : signal is "true";  
--    attribute mark_debug of a_EMDPTFLUSH_Rd : signal is "true"; 
--    attribute keep of a_EMDPTFLUSH_Rd : signal is "true";  
--    attribute mark_debug of a_Endpt_Nr_Int : signal is "true"; 
--    attribute keep of a_Endpt_Nr_Int : signal is "true";   

begin

    a_Aux_Addr_Register <= a_dTD_Page0_Rd & a_dTD_Current_Offset_Rd;
    arb_tx_fifo_s_aresetn <= tx_fifo_resetn;
    a_Axis_MM2S_Mux_Ctrl <= a_Axis_MM2S_Mux_Ctrl_Fsm;    
    a_Axis_S2MM_Mux_Ctrl <= a_Axis_S2MM_Mux_Ctrl_Fsm;  
    a_Endpointlistaddr_Loc <= a_ENDPOINTLISTADDR_Rd(31 downto 11);

-- This module is responsible with implementing the S2MM and MM2S frameworks for the DMA engine
           
	Inst_DMA_Operations: DMA_Operations PORT MAP(
          CLK => Axi_Clk,
          RESETN => Axi_Resetn,
          state_ind_dma => state_ind_dma,
          DEBUG_REG_DATA => DEBUG_REG_DATA,
          M_AXI_AWADDR => a_M_Axi_Awaddr,
          M_AXI_AWPROT => a_M_Axi_Awprot,
          M_AXI_AWVALID => a_M_Axi_Awvalid,
          M_AXI_AWREADY => a_M_Axi_Awready,
          M_AXI_WDATA => a_M_Axi_Wdata,
          M_AXI_WSTRB => a_M_Axi_Wstrb,
          M_AXI_WVALID => a_M_Axi_Wvalid,
          M_AXI_WREADY => a_M_Axi_Wready,
          M_AXI_BRESP => a_M_Axi_Bresp,
          M_AXI_BVALID => a_M_Axi_Bvalid,
          M_AXI_BREADY => a_M_Axi_Bready,
          M_AXI_ARADDR => a_M_Axi_Araddr,
          M_AXI_ARPROT => a_M_Axi_Arprot,
          M_AXI_ARVALID => a_M_Axi_Arvalid,
          M_AXI_ARREADY => a_M_Axi_Arready,
          M_AXI_RDATA => a_M_Axi_Rdata,
          M_AXI_RRESP => a_M_Axi_Rresp,
          M_AXI_RVALID => a_M_Axi_Rvalid,
          M_AXI_RREADY => a_M_Axi_Rready,
          
          dma_transfer_complete => a_DMA_Transfer_Complete,
		  start_dma_s2mm => a_Start_DMA_S2MM,
          start_dma_mm2s => a_Start_DMA_MM2S,
          dma_source_dest_address => a_DMA_Source_Dest_Addr,
          dma_transfer_length => a_DMA_Transfer_Length  
    );
 
-- This module implements the context memory (Queue Heads, Transfer Descriptors)
          
      	Inst_Context: Context PORT MAP(
          CLK => Axi_Clk,
          RESETN => Axi_Resetn,
          ENDPT_NR => a_Endpt_Nr_Int,
          RD_EN => '0',
          WR_EN => a_dQH_Wr_En_Mux_Out,
          dQH_CURRENT_dTD_POINTER_wr_EN => a_Arb_dQH_Current_dTD_Pointer_Wr_En,
          dQH_NEXT_dTD_POINTER_wr_en => a_Arb_dQH_Next_dTD_Pointer_Wr_En,
          dTD_TOTAL_BYTES_WR_EN => a_Arb_dTD_Total_Bytes_Wr_En,
          dTD_STATUS_WR_EN => a_dTD_Status_Wr_En,
          dQH_SETUP_BUFFER_wr_EN => a_dQH_Setup_Buffer_Wr_En,
          dQH_MULT_rd => a_dQH_MULT_Rd,
          dQH_ZLT_rd => a_dQH_ZLT_Rd,
          dQH_MAX_PACKET_LENGTH_rd => a_dQH_Max_Packet_Length_Rd,
          dQH_IOS_rd => a_dQH_IOS_Rd,
          dQH_CURRENT_dTD_POINTER_rd => a_dQH_Current_dTD_Pointer_Rd,
          dQH_NEXT_dTD_POINTER_rd => a_dQH_Next_dTD_Pointer_Rd,
          dQH_T_rd => a_dQH_T_Rd,
          dQH_SETUP_BUFFER_BYTES_3_0_rd => a_dQH_Setup_Buffer_Bytes_3_0_Rd,
          dQH_SETUP_BUFFER_BYTES_7_4_rd => a_dQH_Setup_Buffer_Bytes_7_4_Rd,
          dTD_TOTAL_BYTES_rd => a_dTD_Total_Bytes_Rd,
          dTD_IOC_rd => a_dTD_IOC_Rd,
          dTD_C_PAGE_rd => a_dTD_C_Page_Rd,
          dTD_MULT_rd => a_dTD_Mult_Rd,
          dTD_STATUS_rd => a_dTD_Status_Rd,
          dTD_PAGE0_rd => a_dTD_Page0_Rd ,
          dTD_PAGE1_rd => a_dTD_Page1_Rd,
          dTD_PAGE2_rd => a_dTD_Page2_Rd,
          dTD_PAGE3_rd => a_dTD_Page3_Rd,
          dTD_PAGE4_rd => a_dTD_Page4_Rd,
          dTD_CURRENT_OFFSET_rd => a_dTD_Current_Offset_Rd,
          dQH_MULT_wr => a_dQH_Mult_Wr,
          dQH_ZLT_wr => a_dQH_ZLT_Wr,
          dQH_MAX_PACKET_LENGTH_wr => a_dQH_Max_Packet_Length_Wr,
          dQH_IOS_wr => a_dQH_IOS_Wr,
          dQH_CURRENT_dTD_POINTER_wr => a_dQH_Current_dTD_Pointer_Wr,
          dQH_NEXT_dTD_POINTER_wr => a_dQH_Next_dTD_Pointer_Wr,
          dQH_T_wr => a_dQH_T_Wr,
          dQH_SETUP_BUFFER_BYTES_3_0_wr => a_dQH_Setup_Buffer_Bytes_3_0_Wr,
          dQH_SETUP_BUFFER_BYTES_7_4_wr => a_dQH_Setup_Buffer_Bytes_7_4_Wr,
          dTD_TOTAL_BYTES_wr => a_dTD_Total_Bytes_Wr,
          dTD_IOC_wr => a_dTD_IOC_Wr,
          dTD_C_PAGE_wr => a_dTD_C_Page_Wr,
          dTD_MULT_wr => a_dTD_Mult_Wr,
          dTD_STATUS_wr => a_dTD_Status_Wr,
          dTD_PAGE0_wr => a_dTD_Page0_Wr,
          dTD_PAGE1_wr => a_dTD_Page1_Wr,
          dTD_PAGE2_wr => a_dTD_Page2_Wr,
          dTD_PAGE3_wr => a_dTD_Page3_Wr,
          dTD_PAGE4_wr => a_dTD_Page4_Wr,
          dTD_CURRENT_OFFSET_wr => a_dTD_Current_Offset_Wr
      );
 
-- This module handles control data transfers (Setup packets, dTD, dQH, Status) through the DMA module 
      
      Inst_Context_to_Stream: Context_to_Stream PORT MAP(
          CLK => Axi_Clk,
          RESETN => Axi_Resetn,
          ind_statte_axistream => ind_statte_axistream,
          dQH_RD => a_Read_dQH,
          dQH_WR => a_Write_dQH,
          dTD_RD => a_Read_dTD,
          dTD_WR => write_dTD,
          SETUP_WR => a_Write_Setup_Bytes,
          dQH_WR_EN => a_dQH_Wr_En_Mux_Stream,
          s_axis_mm2s_tdata => a_S_Axis_MM2S_Tdata,
          s_axis_mm2s_tkeep => a_S_Axis_MM2S_Tkeep,
          s_axis_mm2s_tvalid => a_S_Axis_MM2S_Tvalid,
          s_axis_mm2s_tready => a_S_Axis_MM2S_Tready,
          s_axis_mm2s_tlast => a_S_Axis_MM2S_Tlast,
          m_axis_s2mm_tdata => a_M_Axis_S2MM_Tdata,
          m_axis_s2mm_tkeep => a_M_Axis_S2MM_Tkeep,
          m_axis_s2mm_tvalid => a_M_Axis_S2MM_Tvalid,
          m_axis_s2mm_tready => a_M_Axis_S2MM_Tready,
          m_axis_s2mm_tlast => a_M_Axis_S2MM_Tlast,
          dQH_MULT_rd => a_dQH_MULT_Rd,
          dQH_ZLT_rd => a_dQH_ZLT_Rd,
          dQH_MAX_PACKET_LENGTH_rd => a_dQH_Max_Packet_Length_Rd,
          dQH_IOS_rd => a_dQH_IOS_Rd,
          dQH_CURRENT_dTD_POINTER_rd => a_dQH_Current_dTD_Pointer_Rd,
          dQH_NEXT_dTD_POINTER_rd => a_dQH_Next_dTD_Pointer_Rd,
          dQH_T_rd => a_dQH_T_Rd,
          dQH_SETUP_BUFFER_BYTES_3_0_rd => a_dQH_Setup_Buffer_Bytes_3_0_Rd,
          dQH_SETUP_BUFFER_BYTES_7_4_rd => a_dQH_Setup_Buffer_Bytes_7_4_Rd,
          dTD_TOTAL_BYTES_rd => a_dTD_Total_Bytes_Rd,
          dTD_IOC_rd => a_dTD_IOC_Rd,
          dTD_C_PAGE_rd => a_dTD_C_Page_Rd,
          dTD_MULT_rd => a_dTD_Mult_Rd,
          dTD_STATUS_rd => a_dTD_Status_Rd,
          dTD_PAGE0_rd => a_dTD_Page0_Rd,
          dTD_PAGE1_rd => a_dTD_Page1_Rd,
          dTD_PAGE2_rd => a_dTD_Page2_Rd,
          dTD_PAGE3_rd => a_dTD_Page3_Rd,
          dTD_PAGE4_rd => a_dTD_Page4_Rd,
          dTD_CURRENT_OFFSET_rd => a_dTD_Current_Offset_Rd, 
          dQH_MULT_wr => a_Stream_dQH_Mult_Wr,
          dQH_ZLT_wr => a_Stream_dQH_Zlt_Wr,
          dQH_MAX_PACKET_LENGTH_wr => a_Stream_dQH_Max_Packet_Length_Wr,
          dQH_IOS_wr => a_Stream_dQH_IOS_Wr,
          dQH_CURRENT_dTD_POINTER_wr => a_Stream_dQH_Current_dTD_Pointer_Wr,
          dQH_NEXT_dTD_POINTER_wr => a_Stream_dQH_Next_dTD_Pointer_wr,
          dQH_T_wr => a_Stream_dQH_T_Wr,
          dQH_SETUP_BUFFER_BYTES_3_0_wr => a_Stream_dQH_Setup_Buffer_Bytes_3_0_Wr,
          dQH_SETUP_BUFFER_BYTES_7_4_wr => a_Stream_dQH_Setup_Buffer_Bytes_7_4_Wr,
          dTD_TOTAL_BYTES_wr => a_Stream_dTD_Total_Bytes_Wr,
          dTD_IOC_wr => a_Stream_dTD_IOC_Wr,
          dTD_C_PAGE_wr => a_Stream_dTD_C_Page_Wr,
          dTD_MULT_wr => a_Stream_dTD_Mult_Wr,
          dTD_STATUS_wr => a_Stream_dTD_Status_Wr,
          dTD_PAGE0_wr => a_Stream_dTD_Page0_Wr,
          dTD_PAGE1_wr => a_Stream_dTD_Page1_Wr,
          dTD_PAGE2_wr => a_Stream_dTD_Page2_Wr,
          dTD_PAGE3_wr => a_Stream_dTD_Page3_Wr,
          dTD_PAGE4_wr => a_Stream_dTD_Page4_Wr,
          dTD_CURRENT_OFFSET_wr => a_Stream_dTD_Current_Offset_Wr
    );

--Both DMA Engine and the DMA_Transfer_MAnager can read/write to the context memory. The MUX is implemented below
--DMA_Transfer_MAnager controls this MUX

a_dQH_Mult_Wr <= a_Stream_dQH_Mult_Wr when (a_Context_Mux_Ctrl = '0') else
               a_Arb_dQH_MULT_Wr ;
a_dQH_ZLT_Wr <= a_Stream_dQH_Zlt_Wr  when (a_Context_Mux_Ctrl = '0') else 
              a_Arb_dQH_ZLT_Wr;
a_dQH_Max_Packet_Length_Wr <= a_Stream_dQH_Max_Packet_Length_Wr  when (a_Context_Mux_Ctrl = '0') else
                            a_Arb_dQH_Max_Packet_Length_Wr;
a_dQH_IOS_Wr <= a_Stream_dQH_IOS_Wr  when (a_Context_Mux_Ctrl = '0') else
              a_Arb_dQH_IOS_Wr;
a_dQH_Current_dTD_Pointer_Wr <= a_Stream_dQH_Current_dTD_Pointer_Wr  when (a_Context_Mux_Ctrl = '0') else
                              a_Arb_dQH_Current_dTD_Pointer_Wr;
a_dQH_Next_dTD_Pointer_Wr <= a_Stream_dQH_Next_dTD_Pointer_wr  when (a_Context_Mux_Ctrl = '0') else
                           a_Arb_dQH_Next_dTD_Pointer_Wr;
a_dQH_T_Wr <= a_Stream_dQH_T_Wr  when (a_Context_Mux_Ctrl = '0') else
            a_Arb_dQH_T_Wr;
a_dQH_Setup_Buffer_Bytes_3_0_Wr <= a_Stream_dQH_Setup_Buffer_Bytes_3_0_Wr  when (a_Context_Mux_Ctrl = '0') else
                                 a_Arb_dQH_Setup_Buffer_Bytes_3_0_Wr;
a_dQH_Setup_Buffer_Bytes_7_4_Wr <= a_Stream_dQH_Setup_Buffer_Bytes_7_4_Wr  when (a_Context_Mux_Ctrl = '0') else 
                                 a_Arb_dQH_Setup_Buffer_Bytes_7_4_Wr;
a_dTD_Total_Bytes_Wr <= a_Stream_dTD_Total_Bytes_Wr  when (a_Context_Mux_Ctrl = '0') else
                      a_Arb_dTD_Total_Bytes_Wr;
a_dTD_IOC_Wr <= a_Stream_dTD_IOC_Wr  when (a_Context_Mux_Ctrl = '0') else
              a_Arb_dTD_IOC_Wr;
a_dTD_C_Page_Wr <= a_Stream_dTD_C_Page_Wr  when (a_Context_Mux_Ctrl = '0') else
              a_Arb_dTD_C_Page_Wr;
a_dTD_Mult_Wr <= a_Stream_dTD_Mult_Wr  when (a_Context_Mux_Ctrl = '0') else
               a_Arb_dTD_Mult_Wr;
a_dTD_Status_Wr <= a_Stream_dTD_Status_Wr  when (a_Context_Mux_Ctrl = '0') else
                 a_Arb_dTD_Status_Wr;
a_dTD_Page0_Wr <= a_Stream_dTD_Page0_Wr  when (a_Context_Mux_Ctrl = '0') else
                a_Arb_dTD_Page0_Wr;
a_dTD_Page1_Wr <= a_Stream_dTD_Page1_Wr  when (a_Context_Mux_Ctrl = '0') else
                a_Arb_dTD_Page1_Wr;
a_dTD_Page2_Wr <= a_Stream_dTD_Page2_Wr  when (a_Context_Mux_Ctrl = '0') else
                a_Arb_dTD_Page2_Wr;
a_dTD_Page3_Wr <= a_Stream_dTD_Page3_Wr  when (a_Context_Mux_Ctrl = '0') else
                a_Arb_dTD_Page3_Wr;
a_dTD_Page4_Wr <= a_Stream_dTD_Page4_Wr  when (a_Context_Mux_Ctrl = '0') else 
                a_Arb_dTD_Page4_wr;
a_dTD_Current_Offset_Wr <= a_Stream_dTD_Current_Offset_Wr  when (a_Context_Mux_Ctrl = '0') else
                         a_Arb_dTD_Current_Offset_Wr;
a_dQH_Wr_En_Mux_Out <= a_dQH_Wr_En_Mux_Stream when (a_Context_Mux_Ctrl = '0') else
                     a_dQH_Wr_En_Mux_Arb;    

--Generate control signals for Context_to_Stream module. Control signals
--must be pulses                     
IMPULSE_WRITE_DQH: process (Axi_Clk, a_Write_dQH_Fsm)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Write_dQH <= '0'; 
            a_Write_dQH_q <= '0';
        else
            a_Write_dQH_q <= a_Write_dQH_Fsm;
            a_Write_dQH <= a_Write_dQH_Fsm and (not a_Write_dQH_q); 
        end if;
    end if;              
end process;
                   
IMPULSE_WRITE_SETUP: process (Axi_Clk, a_Write_Setup_Bytes_FSM)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Write_Setup_Bytes <= '0'; 
            a_Write_Setup_Bytes_q <= '0';
        else
            a_Write_Setup_Bytes_q <= a_Write_Setup_Bytes_FSM;
            a_Write_Setup_Bytes <= a_Write_Setup_Bytes_FSM and (not a_Write_Setup_Bytes_q); 
        end if;
    end if;              
end process;   
                     
IMPULSE_READ_DQH: process (Axi_Clk, a_Read_dQH_Fsm)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Read_dQH <= '0'; 
            a_Read_dQH_q <= '0';
        else
            a_Read_dQH_q <= a_Read_dQH_Fsm;
            a_Read_dQH <= a_Read_dQH_Fsm and (not a_Read_dQH_q); 
        end if;
    end if;              
end process;   
                     
IMPULSE_READ_DTD_PROC: process (Axi_Clk, a_Read_dTD_Fsm)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Read_dTD <= '0'; 
            a_Read_dTD_q <= '0';
        else
            a_Read_dTD_q <= a_Read_dTD_Fsm;
            a_Read_dTD <= a_Read_dTD_Fsm and (not a_Read_dTD_q); 
        end if;
    end if;              
end process;  

--combinational signals generated by the state machine are registered                        

REGISTER_Q_PROC: process (Axi_Clk)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_ENDPTSETUPSTAT_Wr_En <= '0';
            a_ENDPTSETUPSTAT_Wr <= (others => '0');
            a_USBSTS_Wr_UI <= '0';
            a_USBSTS_Wr_en_UI <= '0';
        else 
            a_ENDPTSETUPSTAT_Wr_En <= a_ENDPTSETUPSTAT_Wr_En_Fsm;  
            a_ENDPTSETUPSTAT_Wr <= a_ENDPTSETUPSTAT_Wr_Fsm;   
            a_USBSTS_Wr_UI <= a_USBSTS_Wr_UI_Fsm; 
            a_USBSTS_Wr_en_UI <= a_USBSTS_Wr_En_UI_Fsm;             
        end if;              
    end if;
end process;
    
a_ENDPTSTAT_Wr <= a_ENDPTSTAT_Wr_Loc;

--generate the ENDPTSTAT register
ENDPTSTAT_PROC: process (Axi_Clk)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_ENDPTSTAT_Wr_Loc <= (others => '0'); 
        elsif (a_ENDPTSTAT_Set_En = '1') then
            a_ENDPTSTAT_Wr_Loc <= a_ENDPTSTAT_Wr_Loc or a_ENDPTSTAT_Set;
        elsif (a_ENDPTSTAT_Clear_En = '1') then
            a_ENDPTSTAT_Wr_Loc <= a_ENDPTSTAT_Wr_Loc and a_ENDPTSTAT_clear;  
        elsif (a_EMDPTFLUSH_Rd /= "00000000000000000000000000000000") then  
            a_ENDPTSTAT_Wr_Loc <= a_ENDPTSTAT_Wr_Loc  and (not(a_EMDPTFLUSH_Rd));       
        end if;
    end if;              
end process;

a_Cnt_Bytes_Sent_Loc <= a_Cnt_Bytes_Sent;

-- a_Arb_Endpt_Nr is the endpoint the DMA_Transfer_Manager work on in integer format
ENDPT_NR_INT_PROC: process (Axi_Clk)
    begin
    if (Axi_Clk'event and Axi_Clk = '1') then
       if (Axi_Resetn = '0') then
          a_Endpt_Nr_Int <= 0;
       elsif (a_Endpt_Nr_Le = '1') then
          a_Endpt_Nr_Int <= a_Endpt_Nr_Fsm; 
       end if;              
    end if;
end process;
 
a_Endpt_Nr <= std_logic_vector(to_unsigned(a_Endpt_Nr_Int,5));
 
-- a_Arb_Endpt_Nr is the endpoint the DMA_Transfer_Manager work on. Lower layers need to be aware of this   
ARB_ENDPT_NR_PROC: process (Axi_Clk)
    begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Arb_Endpt_Nr <= (others => '0');
        else 
            a_Arb_Endpt_Nr <= a_Endpt_Nr;                 
        end if;              
    end if;
end process;    

--determin the endpoint type    
DET_ENDPTTYPE: process (Axi_Resetn, a_Endpt_Nr)
    begin
       if (a_Endpt_Nr(0) = '0') then
          a_Endpt_In_Out <= '0';
       else
         a_Endpt_In_Out <= '1';
       end if;              
end process;
    
a_Endpt_Nr_4b <= to_integer(unsigned(a_Endpt_Nr(4 downto 1)));

-- Control registers usually have bits [27:16] referring to IN endpoints asnd bits[11:0] referring to OUT endpoint   
DET_INDEX: process (Axi_Resetn, a_Endpt_Nr_4b, a_Endpt_In_Out)
begin
       if (a_Endpt_In_Out = '0') then
          a_Bit_Index <= a_Endpt_Nr_4b;
       else
         a_Bit_Index <= a_Endpt_Nr_4b + 16;
       end if;              
end process;       
    
-- Determin the endpoint selected for priming from endptprime register
DET_PRIME_ENDPTNR_PROC: process (Axi_Clk, a_ENDPTPRIME_Rd)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Endpt_Nr_Prime <= 0;
            a_Prime <= '0';
        elsif(a_ENDPTPRIME_Rd /= "00000000000000000000000000000000") then
            a_Prime <= '1';
            for endptprime_index in 0 to 27 loop
                if (endptprime_index < 12) then
                    if (a_ENDPTPRIME_Rd(endptprime_index) = '1') then
                        a_Endpt_Nr_Prime <= endptprime_index * 2; --OUT endpoints (0, 2, 4, ... ,20)
                    end if;
                elsif (endptprime_index >= 16) then
                    if (a_ENDPTPRIME_Rd(endptprime_index) = '1') then
                        a_Endpt_Nr_Prime <= (endptprime_index - 16) * 2 + 1; -- IN endpoints (1, 3, ..., 21)
                    end if;
                end if;             
            end loop;
        else
            a_Endpt_Nr_Prime <= 0;
            a_Prime <= '0';
        end if; 
    end if;             
end process;  
--Determin the endpoint number from setup_received register
DET_SETUP_ENDPTNR_PROC: process (Axi_Clk)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Endpt_Nr_Setup <= 0;
            a_Setup_Received <= '0';
        elsif(a_Arb_ENDPTSETUP_RECEIVED_Rd /= "00000000000000000000000000000000") then
            a_Setup_Received <= '1';
            for setup_index in 0 to 27 loop
                if (setup_index < 12) then
                    if (a_Arb_ENDPTSETUP_RECEIVED_Rd(setup_index) = '1') then
                        a_Endpt_Nr_Setup <= setup_index * 2; --OUT endpoints (0, 2, 4, ... ,20)
                    end if;
                elsif (setup_index >= 16) then
                    if (a_Arb_ENDPTSETUP_RECEIVED_Rd(setup_index) = '1') then
                        a_Endpt_Nr_Setup <= (setup_index - 16) * 2 + 1; -- IN endpoints (1, 3, ..., 21)
                    end if;
                end if;             
            end loop;
        else
            a_Endpt_Nr_Setup <= 0;
            a_Setup_Received <= '0';
        end if; 
    end if;             
end process; 
--Determin the endpoint number from token_in_received register     
DET_TOKEN_IN_ENDPTNR_PROC: process (Axi_Clk, a_In_Token_Received_Rd)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Endpt_Nr_In_Token <= 0;
            a_In_Token_Received <= '0';    
        elsif((a_In_Token_Received_Rd and a_ENDPTSTAT_Wr_Loc) /= "00000000000000000000000000000000") then
            a_In_Token_Received <= '1';  
            for token_in_index in 0 to 27 loop
                if (token_in_index < 12) then
                    if (a_In_Token_Received_Rd(token_in_index) = '1') then
                        a_Endpt_Nr_In_Token <= token_in_index * 2; --OUT endpoints (0, 2, 4, ... ,20)
                    end if;
                elsif (token_in_index >= 16) then
                    if (a_In_Token_Received_Rd(token_in_index) = '1') then
                        a_Endpt_Nr_In_Token <= (token_in_index - 16) * 2 + 1; -- IN endpoints (1, 3, ..., 21)
                    end if;
                end if;             
            end loop;
        else
            a_Endpt_Nr_In_Token <= 0;
            a_In_Token_Received <= '0';
        end if; 
    end if;             
end process;                       
   
OUT_TRANSFER_BYTE_COUNT_PROC: process (Axi_Clk)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Out_Transfer_Byte_Count <= (others => '0');
        elsif (a_Out_Transfer_Byte_Count_Le1 = '1') then
            a_Out_Transfer_Byte_Count <= RX_COMMAND_FIFO_DOUT(23 downto 11);
        elsif (a_Out_Transfer_Byte_Count_Le2 = '1') then
            a_Out_Transfer_Byte_Count <= std_logic_vector( to_unsigned((to_integer(unsigned(RX_COMMAND_FIFO_DOUT(23 downto 11))) - to_integer(unsigned(a_dTD_Total_Bytes_Rd))),13) );    
        end if;              
    end if;
end process;
   
DMA_TRANSFER_ADDR_PROC: process (Axi_Clk)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_DMA_Current_Transfer_Addr_Array   <= (others =>(others => '0')); 
            a_DMA_Current_Transfer_Addr_Array_q <= (others =>(others => '0')); 
        elsif (a_DMA_Current_Transfer_Addr_Le = '1') then
            a_DMA_Current_Transfer_Addr_Array(a_Endpt_Nr_4b) <= a_DMA_Current_Transfer_Addr_Fsm;  
            a_DMA_Current_Transfer_Addr_Array_q(a_Endpt_Nr_4b) <= a_DMA_Current_Transfer_Addr_Array(a_Endpt_Nr_4b);
        end if;
    end if;              
end process;    

------------------------------------------------------------------------------------------------------  
   
DECIDE_LENGTH_PROC: process (Axi_Clk)
   begin
      if (Axi_Clk'event and Axi_Clk = '1') then
         if (Axi_Resetn = '0') then
            a_DMA_In_Transfer_Length <= (others => '0');
         else
            if (a_DMA_In_Transfer_Length_Le = '1') then
                if (to_integer(unsigned(a_dTD_Total_Bytes_Rd)) < C_FIFO_SIZE) then
                    a_DMA_In_Transfer_Length <= "00000000000000000" & a_dTD_Total_Bytes_Rd;
                else
                    a_DMA_In_Transfer_Length <= std_logic_vector(to_unsigned(C_FIFO_SIZE,32));
                end if;
            end if;
         end if;        
      end if;
end process;  

--DMA_Transfer_Manager State Machine

SYNC_PROC: process (Axi_Clk)
   begin
      if (Axi_Clk'event and Axi_Clk = '1') then
         if (Axi_Resetn = '0') then
            state <= IDLE;
         else
            state <= next_state;
         end if;        
      end if;
   end process;

NEXT_STATE_DECODE: process (state, a_dQH_Next_dTD_Pointer_Rd, a_Arb_ENDPTSETUP_RECEIVED_Ack, a_Cnt_Bytes_Sent_oValid, a_Send_Zero_Length_Packet_Ack_Rd, a_DMA_Current_Transfer_Addr_Array, a_Prime, RX_COMMAND_FIFO_VALID, a_dTD_Page0_Rd, a_dTD_Current_Offset_Rd,a_Endpt_Nr_4b, a_Endpt_Nr_Int, a_Aux_Addr_Register, a_In_Packet_Complete_Rd, a_Endpt_Nr_In_Token, RX_COMMAND_FIFO_EMPTY, a_Endpt_Nr_Setup, a_USBMODE_Rd, a_Bit_Index, RX_COMMAND_FIFO_DOUT, a_Out_Transfer_Byte_Count, a_Cnt_Bytes_Sent_Loc, a_dTD_Total_Bytes_Rd, a_dQH_Current_dTD_Pointer_Rd, a_dQH_T_Rd, a_Endpt_Nr_Prime, a_In_Token_Received, a_Endpt_In_Out, a_Setup_Received, a_DMA_Transfer_Complete, a_Endpointlistaddr_Loc)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  
      state_ind_arb <= "000000";
      a_Context_Mux_Ctrl <= '0';
      a_dQH_Wr_En_Mux_Arb <= '0';
      a_Arb_dQH_Current_dTD_Pointer_Wr_En <= '0';
      a_Arb_dTD_Total_Bytes_Wr_En <= '0';
      a_Arb_dQH_Next_dTD_Pointer_Wr_En <= '0';
      a_dQH_Setup_Buffer_Wr_En <= '0';
      a_dTD_Status_Wr_En <= '0';
      a_Read_dQH_Fsm <= '0';
      a_Write_dQH_Fsm <= '0';
      a_Read_dTD_Fsm <= '0';
      write_dTD <= '0';
      a_Write_Setup_Bytes_FSM <= '0';
      a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO as a DEFAULT; FIFO connected to DMA only when data ready
      a_Axis_S2MM_Mux_Ctrl_Fsm <= '1';
      a_Start_DMA_S2MM <= '0';
      a_Start_DMA_MM2S <= '0';
      a_DMA_Source_Dest_Addr <= (others => '0');
      a_DMA_Transfer_Length <= (others => '0');
      tx_fifo_resetn <= '1';
      a_Endpt_Nr_Fsm <= 0;
      a_Endpt_Nr_Le <= '0';
      RX_COMMAND_FIFO_RD_EN <= '0';
      a_Out_Transfer_Byte_Count_Le1 <= '0';
      a_Out_Transfer_Byte_Count_Le2 <= '0';
      a_DMA_Current_Transfer_Addr_Fsm <= (others => '0');
      a_DMA_Current_Transfer_Addr_Le <= '0';
--      pe_setup_received_rst <= '1';
      
      a_Arb_dQH_MULT_Wr <= (others => '0');
      a_Arb_dQH_ZLT_Wr <= '0';
      a_Arb_dQH_Max_Packet_Length_Wr <= (others => '0');
      a_Arb_dQH_IOS_Wr <= '0';
      a_Arb_dQH_Current_dTD_Pointer_Wr <= (others => '0');
      a_Arb_dQH_Next_dTD_Pointer_Wr <= (others => '0');
      a_Arb_dQH_T_Wr <= '0'; 
      a_Arb_dTD_Total_Bytes_Wr   <= (others => '0');
      a_Arb_dTD_IOC_Wr <= '0';
      a_Arb_dTD_C_Page_Wr  <= (others => '0');
      a_Arb_dTD_Mult_Wr  <= (others => '0');
      a_Arb_dTD_Status_Wr  <= (others => '0');
      a_Arb_dTD_Page0_Wr  <= (others => '0');
      a_Arb_dTD_Page1_Wr  <= (others => '0');
      a_Arb_dTD_Page2_Wr  <= (others => '0');
      a_Arb_dTD_Page3_Wr  <= (others => '0');
      a_Arb_dTD_Page4_wr  <= (others => '0');
      a_Arb_dTD_Current_Offset_Wr  <= (others => '0');
      
      a_USBSTS_Wr_UI_Fsm <= '0';
      a_USBSTS_Wr_En_UI_Fsm <= '0';
      a_USBCMD_SUTW_Wr <= '0';
      a_USBCMD_SUTW_Wr_En <= '0'; 
      a_USBCMD_ATDTW_Wr <= '0';
      a_USBCMD_ATDTW_Wr_En  <= '0';
      a_ENDPTPRIME_Clear <= (others => '1');
      a_ENDPTPRIME_Clear_En <= '0';
      a_ENDPTPRIME_Set <= (others => '0');
      a_ENDPTPRIME_Set_En <= '0';
      a_ENDPTCOMPLETE_Wr <=  (others => '0');
      a_ENDPTCOMPLETE_Wr_En <= '0';
      a_ENDPTSETUPSTAT_Wr_Fsm <= (others => '0');
      a_ENDPTSETUPSTAT_Wr_En_Fsm <= '0';
      a_Arb_ENDPTSETUP_RECEIVED_Clear <= (others => '1');
      a_Arb_ENDPTSETUP_RECEIVED_Clear_En <= '0';
      a_ENDPTSTAT_Set	 <= (others => '0');
      a_ENDPTSTAT_Set_En <= '0';
      a_ENDPTSTAT_clear <= (others => '1');
      a_ENDPTSTAT_Clear_En <= '0';
      a_EMDPTFLUSH_Set	 <= (others => '0');
      a_EMDPTFLUSH_Set_En <= '0';
      a_In_Packet_Complete_Clear_En <= '0';
      a_In_Packet_Complete_Clear  <= (others => '1');
      a_Send_Zero_Length_Packet_Set <=  (others => '0');
      a_Send_Zero_Length_Packet_Set_En <= '0';
      a_Send_Zero_Length_Packet_Ack_Clear  <= (others => '1');
      a_Send_Zero_Length_Packet_Ack_Clear_En <= '0';
      a_In_Token_Received_Clear  <= (others => '1');
      a_In_Token_Received_Clear_En <= '0';
      a_Resend_Clear_En <= '0';
      a_Resend_Clear <= (others => '1');
      a_DMA_In_Transfer_Length_Le <= '0';

      case state is -- state machine triggered by 2 conditions: priming of an endpoint or setup packet arrival; setup packets processed separately; OUT framework not tested
         when IDLE =>
            state_ind_arb <= "000000";
            if (a_Prime = '1') then
                a_Endpt_Nr_Fsm <= a_Endpt_Nr_Prime;
                a_Context_Mux_Ctrl <= '0'; -- DMA writes Context
                a_Endpt_Nr_Le <= '1';
                next_state <= PRIME_MM2S_DQH; 
            elsif (a_Setup_Received = '1') then
                a_Context_Mux_Ctrl <= '1';  
                a_Endpt_Nr_Fsm <= a_Endpt_Nr_Setup;  
                a_Endpt_Nr_Le <= '1';   
                next_state <= SETUP_LOCKOUT_TRIPWIRE;                
            elsif (a_In_Token_Received = '1') then
                a_Context_Mux_Ctrl <= '0'; -- DMA writes Context 
                a_Endpt_Nr_Fsm <= a_Endpt_Nr_In_Token;
                a_Endpt_Nr_Le <= '1';
                next_state <= START_IN_FRAMEWORK;                
            elsif (RX_COMMAND_FIFO_EMPTY /= '1' and RX_COMMAND_FIFO_VALID = '1') then
                RX_COMMAND_FIFO_RD_EN <= '1';     
                next_state <= START_OUT_FRAMEWORK;    
            end if;

------------------SETUP PACKET PROCESSING--------------------------
     
        when SETUP_LOCKOUT_TRIPWIRE =>   
             state_ind_arb <= "000001";
             a_Context_Mux_Ctrl <= '1'; 
             if (a_USBMODE_Rd(SLOM) = '0') then
                next_state <= IDLE;
             else 
                a_USBCMD_SUTW_Wr <= '0';
                a_USBCMD_SUTW_Wr_En <= '1'; 
                a_In_Token_Received_Clear(a_Bit_Index + 16)  <= '0';
                a_In_Token_Received_Clear_En <= '1';
                a_EMDPTFLUSH_Set(a_Bit_Index + 16)	 <= '1';
                a_EMDPTFLUSH_Set_En <= '1';
                next_state <= SETUP_UPDATE_SETUP_BYTES;  
             end if;     
                
        when SETUP_UPDATE_SETUP_BYTES =>
             state_ind_arb <= "000010";
             a_USBCMD_SUTW_Wr <= '0';
             a_USBCMD_SUTW_Wr_En <= '1'; 
             a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
             a_Context_Mux_Ctrl <= '1';  -- DMA_Transfer_Manager writes Context 
             a_dQH_Setup_Buffer_Wr_En <= '1';
             next_state <= SETUP_WAIT1;
         
        when SETUP_WAIT1 => --wait for dqh to be updated in context memory   
            state_ind_arb <= "000011";
            a_USBCMD_SUTW_Wr <= '0';
            a_USBCMD_SUTW_Wr_En <= '1';        
            next_state <= SETUP_S2MM;   
            
        when SETUP_S2MM =>
            state_ind_arb <= "000100";
            a_USBCMD_SUTW_Wr <= '0';
            a_USBCMD_SUTW_Wr_En <= '1'; 
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
            a_Context_Mux_Ctrl <= '0'; -- DMA writes Context
            a_Start_DMA_S2MM <= '1';
            a_Write_Setup_Bytes_FSM <= '1';
            a_DMA_Source_Dest_Addr <= a_Endpointlistaddr_Loc & std_logic_vector(to_unsigned(((a_Endpt_Nr_Int*64)+40),11));
            a_DMA_Transfer_Length <= std_logic_vector(to_unsigned(8,32)); --dQH = 2*4 Bytes
            if (a_DMA_Transfer_Complete = '1') then
                a_Write_Setup_Bytes_FSM <= '0';
                a_ENDPTSETUPSTAT_Wr_Fsm(a_Bit_Index) <= '1';
                a_ENDPTSETUPSTAT_Wr_En_Fsm <= '1';
                a_USBSTS_Wr_UI_Fsm <= '1';
                a_USBSTS_Wr_En_UI_Fsm <= '1';
                next_state <= SETUP_UPDATE_ENDPTSETUP_RECEIVED;
            end if;
            
        when SETUP_UPDATE_ENDPTSETUP_RECEIVED =>
            state_ind_arb <= "000101";
            a_Arb_ENDPTSETUP_RECEIVED_Clear(a_Bit_Index) <= '0';
            a_Arb_ENDPTSETUP_RECEIVED_Clear_En <= '1';
            if (a_Arb_ENDPTSETUP_RECEIVED_Ack = '1') then
                next_state <= SETUP_WAIT2;
            end if; 
            
        when SETUP_WAIT2 =>
            next_state <= IDLE; 
            
------------------------------ PRIME FRAMEWORK ----------------------------------------- 
                  
         when PRIME_MM2S_DQH => --read DQH from main memory   
            state_ind_arb <= "000110";
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
            a_Context_Mux_Ctrl <= '0'; -- DMA writes Context
            a_DMA_Source_Dest_Addr <= a_Endpointlistaddr_Loc & std_logic_vector(to_unsigned((a_Endpt_Nr_Int*64),11));
            a_DMA_Transfer_Length <= std_logic_vector(to_unsigned(48,32)); --dQH = 48 Bytes
            a_Start_DMA_MM2S <= '1';     
            a_Read_dQH_Fsm <= '1';              
            if (a_DMA_Transfer_Complete = '1') then
                next_state <= PRIME_WAIT0;
            end if; 
            
         when PRIME_WAIT0 =>
                state_ind_arb <= "000000";
                a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
                a_Context_Mux_Ctrl <= '0'; -- DMA writes Context
                next_state <= PRIME_MM2S_DTD;      
            
         when PRIME_MM2S_DTD => --read DQH from main memory   
            state_ind_arb <= "100110";
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
            a_Context_Mux_Ctrl <= '0'; -- DMA writes Context
            a_DMA_Source_Dest_Addr <= a_dQH_Next_dTD_Pointer_Rd & "00000"; 
            a_DMA_Transfer_Length <= std_logic_vector(to_unsigned(28,32)); --dTD = 7*4 Bytes
            a_Start_DMA_MM2S <= '1';  
            a_Read_dTD_Fsm <= '1';               
            if (a_DMA_Transfer_Complete = '1') then
                a_Arb_dQH_Current_dTD_Pointer_Wr <= a_dQH_Next_dTD_Pointer_Rd;
                a_Arb_dQH_Current_dTD_Pointer_Wr_En <= '1';
                a_DMA_Current_Transfer_Addr_Fsm <=  a_dTD_Page0_Rd & a_dTD_Current_Offset_Rd; --initialize the transfer address with PAGE0
                a_DMA_Current_Transfer_Addr_Le <= '1';
                if (a_Endpt_In_Out = '1') then --IN endpoint, FIFO needs to be prepared with transmit data
                    tx_fifo_resetn <= '0';  -- flush fifo;
                    a_Axis_MM2S_Mux_Ctrl_Fsm <= '0'; -- FIFO connected to DMA stream port, not context memory                        
                    next_state <= PRIME_FILL_FIFO;
                else --OUT endpoint
                    a_ENDPTPRIME_Clear(a_Bit_Index) <= '0';
                    a_ENDPTPRIME_Clear_En <= '1';
                    a_ENDPTSTAT_Set(a_Bit_Index) <= '1';
                    a_ENDPTSTAT_Set_En <= '1';
                    next_state <= PRIME_WAIT1; 
                end if; 
            end if;                      

         when PRIME_FILL_FIFO => --extract necessary data to fill TX fifo 
            state_ind_arb <= "000111";
            a_Context_Mux_Ctrl <= '1'; -- DMA_Transfer_Manager writes Context
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '0'; -- FIFO connected to DMA stream port, not context memory 
            if (a_dTD_Total_Bytes_Rd = "000000000000000") then
                a_ENDPTPRIME_Clear(a_Bit_Index) <= '0';
                a_ENDPTPRIME_Clear_En <= '1';
                a_ENDPTSTAT_Set(a_Bit_Index) <= '1';
                a_ENDPTSTAT_Set_En <= '1';
                a_Send_Zero_Length_Packet_Set(a_Bit_Index) <= '1';
                a_Send_Zero_Length_Packet_Set_En <= '1';
                next_state <= PRIME_WAIT1;
            else
                if (to_integer(unsigned(a_dTD_Total_Bytes_Rd)) < C_FIFO_SIZE) then
                    next_state <= PRIME_FILL_FIFO_1;
                else
                    next_state <= PRIME_FILL_FIFO_2;    
                end if;
            end if;       
            
            when PRIME_FILL_FIFO_1 =>
                state_ind_arb <= "001000";
                a_Axis_MM2S_Mux_Ctrl_Fsm <= '0'; -- FIFO connected to DMA stream port, not context memory 
                a_Context_Mux_Ctrl <= '1'; -- DMA_Transfer_Manager writes Context
                a_DMA_Transfer_Length <=  "00000000000000000" & a_dTD_Total_Bytes_Rd;
                a_DMA_Source_Dest_Addr <=  a_DMA_Current_Transfer_Addr_Array(a_Endpt_Nr_4b);
                a_Start_DMA_MM2S <= '1';
                if (a_DMA_Transfer_Complete = '1') then
                    a_ENDPTPRIME_Clear(a_Bit_Index) <= '0';
                    a_ENDPTPRIME_Clear_En <= '1';
                    a_ENDPTSTAT_Set(a_Bit_Index) <= '1';
                    a_ENDPTSTAT_Set_En <= '1';
                    a_Arb_dQH_Current_dTD_Pointer_Wr <= std_logic_vector(unsigned(a_dQH_Current_dTD_Pointer_Rd) + unsigned(a_dTD_Total_Bytes_Rd)); --update the memory address for the s2mm transfer
                    a_Arb_dQH_Current_dTD_Pointer_Wr_En <= '1';
                    next_state <= PRIME_WAIT1;
                end if;           
            
            when PRIME_FILL_FIFO_2 =>  
                state_ind_arb <= "001001";
                a_Axis_MM2S_Mux_Ctrl_Fsm <= '0'; -- FIFO connected to DMA stream port, not context memory  
                a_Context_Mux_Ctrl <= '1'; -- DMA_Transfer_Manager writes Context            
                a_DMA_Source_Dest_Addr <=  a_DMA_Current_Transfer_Addr_Array(a_Endpt_Nr_4b);
                a_DMA_Transfer_Length <= std_logic_vector(to_unsigned(C_FIFO_SIZE,32)); 
                a_Start_DMA_MM2S <= '1';
                if (a_DMA_Transfer_Complete = '1') then
                    a_DMA_Current_Transfer_Addr_Fsm <= std_logic_vector(unsigned(a_Aux_Addr_Register) + (C_FIFO_SIZE));
                    a_DMA_Current_Transfer_Addr_Le <= '1';
                    a_ENDPTPRIME_Clear(a_Bit_Index) <= '0';
                    a_ENDPTPRIME_Clear_En <= '1';
                    a_ENDPTSTAT_Set(a_Bit_Index) <= '1';
                    a_ENDPTSTAT_Set_En <= '1';
                    a_Arb_dQH_Current_dTD_Pointer_Wr <= std_logic_vector(unsigned(a_dQH_Current_dTD_Pointer_Rd) + (C_FIFO_SIZE)); --update the memory address for the s2mm transfer
                    a_Arb_dQH_Current_dTD_Pointer_Wr_En <= '1';
                    next_state <= PRIME_WAIT1;
                end if;   
                
            when PRIME_WAIT1 =>
                state_ind_arb <= "001010";
                next_state <= PRIME_WAIT2;    
                
            when PRIME_WAIT2 =>
                state_ind_arb <= "001011";
                next_state <= IDLE;                                
---------OUT_TOKEN_FRAMEWORK (RX_PACKET)---------------------------------------------------------------------------
         when START_OUT_FRAMEWORK => 
            state_ind_arb <= "001100";
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '0'; -- FIFO connected to DMA stream port, not context memory
            a_Context_Mux_Ctrl <= '1'; -- DMA_Transfer_Manager writes Context
            a_Out_Transfer_Byte_Count_Le1 <= '1';
            a_Endpt_Nr_Fsm <= to_integer(unsigned(RX_COMMAND_FIFO_DOUT(10 downto 7)));   
            a_Endpt_Nr_Le <= '1'; 
            next_state <=  OUT_START_TRANSFER;   
                               
         when OUT_START_TRANSFER => 
            state_ind_arb <= "001101";
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '0'; -- FIFO connected to DMA stream port, not context memory
            a_Context_Mux_Ctrl <= '1'; -- DMA_Transfer_Manager writes Context   
            if (a_Out_Transfer_Byte_Count <= a_dTD_Total_Bytes_Rd)then
                next_state <= OUT_TRANSFER_S2MM;  
            else
                next_state <= IDLE; --ERROR                                     
            end if;
            
        when OUT_TRANSFER_S2MM =>
            state_ind_arb <= "001110";
            a_Axis_S2MM_Mux_Ctrl_Fsm <= '0'; -- FIFO connected to DMA stream port, not context memory
            a_Context_Mux_Ctrl <= '1'; -- DMA_Transfer_Manager writes Context
            a_DMA_Source_Dest_Addr <= a_DMA_Current_Transfer_Addr_Array(a_Endpt_Nr_4b);            
            a_DMA_Transfer_Length <= "0000000000000000000" & a_Out_Transfer_Byte_Count; --transfer the received packet in main memory
            a_Start_DMA_S2MM <= '1';
            if (a_DMA_Transfer_Complete = '1') then
                a_Arb_dTD_Total_Bytes_Wr <= std_logic_vector(unsigned(a_dTD_Total_Bytes_Rd)- unsigned(a_Out_Transfer_Byte_Count)); --update the number of bytes left to transfer
                a_Arb_dTD_Total_Bytes_Wr_En <= '1'; -- update dTD_TOTAL_BYTES  
                a_DMA_Current_Transfer_Addr_Fsm <= std_logic_vector(unsigned(a_DMA_Current_Transfer_Addr_Array(a_Endpt_Nr_4b)) + unsigned(a_Out_Transfer_Byte_Count)); --update the memory address for the s2mm transfer
                a_DMA_Current_Transfer_Addr_Le <= '1';
                next_state <= OUT_WAIT1;
            end if;
            
        when OUT_WAIT1 =>
            state_ind_arb <= "001111";
            next_state <= OUT_CHECK_COMPLETE;
                        
        when OUT_CHECK_COMPLETE =>
            state_ind_arb <= "010000";
            if (a_dTD_Total_Bytes_Rd = "000000000000000") then
                a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
                a_Context_Mux_Ctrl <= '0';  -- DMA writes Context
                a_ENDPTPRIME_Set(a_Bit_Index) <= '1';
                a_ENDPTPRIME_Set_En <= '1';
                next_state <= OUT_TRANSFER_COMPLETE;
            else
                next_state <= IDLE;                         
            end if;                          
                
         when OUT_TRANSFER_COMPLETE =>
            state_ind_arb <= "010001";
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
            a_Context_Mux_Ctrl <= '0'; -- DMA writes Context
            a_Start_DMA_S2MM <= '1';
            a_Write_dQH_Fsm <= '1';
            a_DMA_Source_Dest_Addr <= a_Endpointlistaddr_Loc & std_logic_vector(to_unsigned((a_Endpt_Nr_Int*64),11));
            a_DMA_Transfer_Length <= std_logic_vector(to_unsigned(48,32)); --dQH = 48 Bytes
            if (a_DMA_Transfer_Complete = '1') then
                a_Write_dQH_Fsm <= '0';
                if (a_dQH_T_Rd = '0') then
                    a_USBCMD_ATDTW_Wr <= '0';
                    a_USBCMD_ATDTW_Wr_En <= '1'; 
                    a_USBSTS_Wr_UI_Fsm <= '1';
                    a_USBSTS_Wr_En_UI_Fsm <= '1';
                    next_state <= OUT_FETCH_NEXT_DTD;
                else
                    a_ENDPTCOMPLETE_Wr(a_Bit_Index) <= '1';
                    a_ENDPTCOMPLETE_Wr_En <= '1';
                    next_state <= IDLE;   
                end if;    
            end if; 
        
        when OUT_FETCH_NEXT_DTD =>
               state_ind_arb <= "010010";
               a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
               a_Context_Mux_Ctrl <= '0'; -- DMA writes Context
               a_DMA_Source_Dest_Addr <= a_dQH_Next_dTD_Pointer_Rd & "00000";
               a_DMA_Transfer_Length <= std_logic_vector(to_unsigned(28,32)); --dQH = 7*4 Bytes
               a_Start_DMA_MM2S <= '1';  
               a_Read_dTD_Fsm <= '1';                 
               if (a_DMA_Transfer_Complete = '1') then
                    a_Arb_dQH_Current_dTD_Pointer_Wr <= a_dQH_Next_dTD_Pointer_Rd;
                    a_Arb_dQH_Current_dTD_Pointer_Wr_En <= '1';
                    a_ENDPTPRIME_Clear(a_Bit_Index) <= '0';
                    a_ENDPTPRIME_Clear_En <= '1';
                    next_state <= OUT_WAIT2;   
               end if;             
        
        when OUT_WAIT2 =>
            state_ind_arb <= "010011";
            next_state <= IDLE; 
              
---------IN_TOKEN_FRAMEWORK (TX_PACKET)---------------------------------------------------------------------------

         when START_IN_FRAMEWORK => 
            state_ind_arb <= "010100";
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; --context memory  connected to DMA stream port, not FIFO  if 0 fifo will assert tvalid for 1 ck cycle
            a_Context_Mux_Ctrl <= '0'; 
            a_In_Token_Received_Clear(a_Bit_Index)  <= '0';
            a_In_Token_Received_Clear_En <= '1';
                if (a_In_Packet_Complete_Rd(a_Bit_Index) = '1') then 
                    a_In_Packet_Complete_Clear(a_Bit_Index) <= '0';
                    a_In_Packet_Complete_Clear_En <= '1';
                    next_state <= IN_HANDSHAKE;
                elsif (a_Resend(a_Bit_Index) = '1') then
                    tx_fifo_resetn <= '0';  -- flush fifo;
                    next_state <= IN_HANDSHAKE;
                end if; 
                    
         when IN_HANDSHAKE =>   
            state_ind_arb <= "010101";   
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
            a_Context_Mux_Ctrl <= '1';      
                if (a_Cnt_Bytes_Sent_oValid = '1') then
                    if (a_Resend(a_Bit_Index) = '0') then
                         a_Arb_dTD_Total_Bytes_Wr <= std_logic_vector(unsigned(a_dTD_Total_Bytes_Rd)- unsigned(a_Cnt_Bytes_Sent_Loc)); --update the number of bytes left to transfer
                         a_Arb_dTD_Total_Bytes_Wr_En <= '1'; -- update dTD_TOTAL_BYTES                     
                    end if;    
                    next_state <= IN_WAIT0;
                end if;         
            
         when IN_WAIT0 =>
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
            state_ind_arb <= "010111";
            if (a_Resend(a_Bit_Index) = '0') then
                next_state <= IN_CHECK_COMPLETE;
            else
                a_Resend_Clear(a_Bit_Index)  <= '0';  
                a_Resend_Clear_En <= '1';
                next_state <= IN_RELOAD_BUFFER;             
            end if;            
            
         when IN_CHECK_COMPLETE =>
               state_ind_arb <= "011000";
               a_DMA_In_Transfer_Length_Le <= '1';
               if (a_dTD_Total_Bytes_Rd = "000000000000000") then
                   a_dTD_Status_Wr_En <= '1'; --write 0 to active bit
                   next_state <= IN_TRANSACTION_COMPLETE; 
               else
                   next_state <= IN_TRANSFER_MM2S;    
               end if;               
                      
         when IN_TRANSFER_MM2S =>
            state_ind_arb <= "010110";  
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '0'; -- FIFO connected to DMA stream port, not context memory 
            a_Context_Mux_Ctrl <= '1'; -- DMA_Transfer_Manager writes Context
            a_DMA_Transfer_Length <= a_DMA_In_Transfer_Length; 
            a_DMA_Source_Dest_Addr <=  a_DMA_Current_Transfer_Addr_Array(a_Endpt_Nr_4b);
            a_Start_DMA_MM2S <= '1';
            if (a_DMA_Transfer_Complete = '1') then
                next_state <= IN_WAIT1;
                a_DMA_Current_Transfer_Addr_Fsm <= std_logic_vector(unsigned(a_Aux_Addr_Register) + unsigned(a_Cnt_Bytes_Sent_Loc));
                a_DMA_Current_Transfer_Addr_Le <= '1';
                a_Arb_dQH_Current_dTD_Pointer_Wr <= std_logic_vector(unsigned(a_dQH_Current_dTD_Pointer_Rd) + unsigned(a_Cnt_Bytes_Sent_Loc)); --update the memory address for the s2mm transfer
                a_Arb_dQH_Current_dTD_Pointer_Wr_En <= '1';
            end if;
            
         when IN_RELOAD_BUFFER =>
               state_ind_arb <= "111011";  
               a_Axis_MM2S_Mux_Ctrl_Fsm <= '0'; -- FIFO connected to DMA stream port, not context memory 
               a_Context_Mux_Ctrl <= '1'; -- DMA_Transfer_Manager writes Context
               a_DMA_Transfer_Length <= a_DMA_In_Transfer_Length;
               a_DMA_Source_Dest_Addr <=  a_DMA_Current_Transfer_Addr_Array_q(a_Endpt_Nr_4b);
               a_Start_DMA_MM2S <= '1';
               if (a_DMA_Transfer_Complete = '1') then
                   next_state <= IN_WAIT1;
               end if;                        
         
         when IN_WAIT1 =>
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
            state_ind_arb <= "010111";
            next_state <= IDLE;
       
         when IN_TRANSACTION_COMPLETE => --copy dQH back to main memory with status updated
            state_ind_arb <= "011001";
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
            a_Context_Mux_Ctrl <= '0'; -- DMA writes Context
            a_Start_DMA_S2MM <= '1';
            a_Write_dQH_Fsm <= '1';
            a_DMA_Source_Dest_Addr <= a_Endpointlistaddr_Loc & std_logic_vector(to_unsigned((a_Endpt_Nr_Int*64),11));
            a_DMA_Transfer_Length <= std_logic_vector(to_unsigned(48,32)); --dQH = 48 Bytes
            if (a_DMA_Transfer_Complete = '1' or a_Send_Zero_Length_Packet_Ack_Rd(a_Bit_Index) = '1') then
                a_Write_dQH_Fsm <= '0';
                a_Send_Zero_Length_Packet_Ack_Clear(a_Bit_Index) <= '1';
                a_Send_Zero_Length_Packet_Ack_Clear_En <= '1';  
                if (a_dQH_T_Rd = '1') then
                    a_ENDPTCOMPLETE_Wr(a_Bit_Index) <= '1';
                    a_ENDPTCOMPLETE_Wr_En <= '1';
                    a_ENDPTSTAT_clear(a_Bit_Index) <= '0';
                    a_ENDPTSTAT_Clear_En <= '1';
                    a_USBSTS_Wr_UI_Fsm <= '1';
                    a_USBSTS_Wr_En_UI_Fsm <= '1';
                    next_state <= IDLE;
                else
                    a_USBCMD_ATDTW_Wr <= '0';
                    a_USBCMD_ATDTW_Wr_En <= '1'; 
                    a_ENDPTPRIME_Set(a_Bit_Index) <= '1';
                    a_ENDPTPRIME_Set_En <= '1';
                    next_state <= IN_FETCH_NEXT_DTD;        
                end if;    
            end if;  
           
         when IN_FETCH_NEXT_DTD =>
            state_ind_arb <= "011010";
            a_Axis_MM2S_Mux_Ctrl_Fsm <= '1'; -- context memory connected to DMA stream port, not FIFO
            a_Context_Mux_Ctrl <= '0'; -- DMA writes Context
            a_DMA_Source_Dest_Addr <= a_dQH_Next_dTD_Pointer_Rd & "00000";
            a_DMA_Transfer_Length <= std_logic_vector(to_unsigned(28,32)); --dQH = 7*4 Bytes
            a_Start_DMA_MM2S <= '1';  
            a_Read_dTD_Fsm <= '1';                 
            if (a_DMA_Transfer_Complete = '1') then
                a_Arb_dQH_Current_dTD_Pointer_Wr <= a_dQH_Next_dTD_Pointer_Rd;
                a_Arb_dQH_Current_dTD_Pointer_Wr_En <= '1';
                a_ENDPTPRIME_Clear(a_Bit_Index) <= '0';
                a_ENDPTPRIME_Clear_En <= '1';
                next_state <= IN_WAIT2;   
            end if;                     
         
         when IN_WAIT2 =>
            state_ind_arb <= "011011";
            next_state <= IDLE;     
                            
         when others =>
            state_ind_arb <= "011100";
            next_state <= IDLE;
      end case;      
   end process;			
			 
end implementation;
