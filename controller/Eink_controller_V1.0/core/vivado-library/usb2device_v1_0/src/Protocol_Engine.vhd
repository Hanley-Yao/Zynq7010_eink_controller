-------------------------------------------------------------------------------
--
-- File: Protocol_Engine.vhd
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
-- This module instantiates all the necessary modules to implement ULPI 
-- communication, Speed negotiation , Reset and Suspend. Packet data is
-- sent/received over AXI Stream. Synchronization modules for registers
-- that corss the ULPI Clock domain to AXI clock domain is implemented
-- here  
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity Protocol_Engine is
	generic (
    MAX_NR_ENDP           : integer    := 1
    );
    Port ( 
           Axi_Clk : IN std_logic;
           Axi_Resetn : IN STD_LOGIC; 
           Ulpi_Clk : in  STD_LOGIC;
           u_ResetN : in  STD_LOGIC;
           --ULPI Bus
           Ulpi_Reset : out  STD_LOGIC;
		   u_Ulpi_Data : INOUT std_logic_vector(7 downto 0); 
           u_Ulpi_Dir : IN std_logic;
           u_Ulpi_Nxt : IN std_logic;
           u_Ulpi_Stp : OUT std_logic;
           led : out STD_LOGIC;  --debug purposes       
            
           --Transmit FIFO write channel
           a_Arb_Endpt_Nr : in std_logic_vector(4 downto 0); 
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
           
           --Receive FIFO write channel
           u_Rx_Fifo_s_Aclk : OUT std_logic;
           u_Rx_Fifo_s_Axis_Tready : IN std_logic;
           u_Rx_Fifo_s_Axis_Tvalid : OUT std_logic;
           u_Rx_Fifo_s_Axis_Tdata : OUT std_logic_vector(31 downto 0);
           u_Rx_Fifo_s_Axis_Tkeep : OUT std_logic_vector (3 downto 0);
           u_Rx_Fifo_s_Axis_Tlast : OUT std_logic;
           u_Rx_Fifo_Axis_Overflow : IN std_logic;
           u_Rx_Fifo_Axis_Underflow : IN std_logic;
           
           --Command FIFO; used to keep track of received OUT transactions
           u_Command_Fifo_Rd_En : IN std_logic;
           u_Command_Fifo_Dout  : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
           u_Command_Fifo_Empty : OUT std_logic;
           u_Command_Fifo_Valid : OUT std_logic;
           
           --control signals to/from DMA_Transfer_Manager
           a_In_Packet_Complete_oData : OUT std_logic_vector(31 downto 0); --a bit is set when the corresponding endpoint has completed an IN transaction
           a_In_Packet_Complete_Set_En : OUT std_logic; --a_In_Packet_Complete_oData strobe
           u_Send_Zero_Length_Packet_Rd : IN STD_LOGIC_VECTOR(31 downto 0); --If a bit is set, the corresponding endpoint needs to send a Zero Length Packet
           a_Send_Zero_Length_Packet_Clear_oData :  OUT STD_LOGIC_VECTOR(31 downto 0); --ZLP Hanshake between Packet_Decoder and DMA_Transfer_Manager
           a_Send_Zero_Length_Packet_Clear_En :  OUT STD_LOGIC; --ZLP Hanshake between Packet_Decoder and DMA_Transfer_Manager 
           a_Send_Zero_Length_Packet_Ack_oData :  OUT STD_LOGIC_VECTOR(31 downto 0); --ZLP Hanshake between Packet_Decoder and DMA_Transfer_Manager
           a_Send_Zero_Length_Packet_Ack_Set_En :  OUT STD_LOGIC; --ZLP Hanshake between Packet_Decoder and DMA_Transfer_Manager
           a_Cnt_Bytes_Sent_oData : out std_logic_vector(12 downto 0); --number of bytes sent in response to an IN token
           a_Cnt_Bytes_Sent_oValid : OUT std_logic;  -- a_Cnt_Bytes_Sent_oData strobe
           a_Resend_oData : OUT STD_LOGIC_VECTOR(31 downto 0); --indicates to the upper layers that the endpoint corresponding to set bits need to resend a packet
           a_Resend_Wr_En : OUT std_logic;  --a_Resend_oData
           a_In_Token_Received_oData : OUT std_logic_vector(31 downto 0);  -- a bit is set when the corresponding endpoint has received an IN token
           a_In_Token_Received_Set_En : OUT std_logic; --a_In_Token_Received_oData strobe
           a_Endpt_Nr  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); --endpoint accessed by the lower layers (ULPI, Packet_Decoder)
           u_Endp_Nr  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
           u_Endp_Nr_Arb  : IN STD_LOGIC_VECTOR(4 DOWNTO 0);  --endpoint accessed by the DMA_Transfer_Manager
           u_Endp_Nr_Arb_Ack : OUT std_logic;
           u_Endp_Nr_Arb_Valid : IN std_logic;
           --Setup packets are stored in these registers before being copied into the dQH
           a_Setup_Buffer_Bytes_3_0_oData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           a_Setup_Buffer_Bytes_7_4_oData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  
           
           --Interface to Control_Registers block 
           u_Endp_Type : in STD_LOGIC_VECTOR(47 downto 0);
           u_Endp_Stall : IN STD_LOGIC_VECTOR(23 downto 0);           
           u_USBADRA : in STD_LOGIC_VECTOR (7 downto 0);
           a_FRINDEX_oData    : out std_logic_vector(10 downto 0);
           a_FRINDEX_Wr_En    : out std_logic;
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
           u_USBCMD_RS : in std_logic;
           
           state_ind : out STD_LOGIC_VECTOR(5 downto 0);
           state_ind_pd : out STD_LOGIC_VECTOR(6 downto 0);
           state_ind_hs : out STD_LOGIC_VECTOR(4 downto 0)
		 );
end Protocol_Engine;
         
architecture Behavioral of Protocol_Engine is
    
	COMPONENT ULPI
	PORT(
		Ulpi_Clk : IN std_logic;
		reset : IN std_logic;
		u_Ulpi_Data : INOUT std_logic_vector(7 downto 0); 
		u_Ulpi_Dir : IN std_logic;
		u_Ulpi_Nxt : IN std_logic;
		u_Ulpi_Stp : OUT std_logic;
	    u_Ulpi_Reset : OUT std_logic;
		u_Send_NOOP_CMD : IN std_logic;
		u_Send_NOPID_CMD : IN std_logic;
		u_Send_PID_CMD : IN std_logic;
		u_Send_EXTW_CMD : IN std_logic;
		u_Send_REGW_CMD : IN std_logic;
		u_Send_EXTR_CMD : IN std_logic;
		u_Send_REGR_CMD : IN std_logic;
		u_Send_STP_CMD : IN std_logic;
		u_Send_Last : IN std_logic;
		u_Send_Err : IN std_logic;
		
		u_Tx_Data : IN std_logic_vector(7 downto 0);
		u_Tx_Data_En : OUT std_logic;
		u_Tx_Pid : IN std_logic_vector(3 downto 0);
		u_Tx_Regw_Data : in  STD_LOGIC_VECTOR (7 downto 0);
		u_Tx_Reg_Addr : in  STD_LOGIC_VECTOR (7 downto 0);
		u_Tx_Cmd_Done : OUT STD_LOGIC;
		u_USB_Mode : IN std_logic;         
		u_CRC16_En : out STD_LOGIC;
		u_Tx_Pid_Phase_Done : out STD_LOGIC;
		u_Rx_Data : OUT std_logic_vector(7 downto 0);
		u_Rx_Packet_Received : OUT std_logic;
		u_Ulpi_Dir_Out : out  STD_LOGIC;
		u_LineState : OUT std_logic_vector(1 downto 0);
		u_Vbus : OUT std_logic_vector(1 downto 0);
		u_RxEvent : OUT std_logic_vector(1 downto 0);
		u_RxActive  : out  STD_LOGIC;
		u_ID : OUT std_logic;
		u_Alt_Int : OUT std_logic;
		u_Rx_Cmd_Received : OUT std_logic;
		state_ind : out STD_LOGIC_VECTOR(5 downto 0);
		u_Rx_Register_Data : OUT std_logic_vector(7 downto 0);
		u_Rx_Register_Data_Received : OUT std_logic
		);
	END COMPONENT;

	COMPONENT HS_Negotiation
	PORT(
		u_Reset : IN std_logic;
		Ulpi_Clk : IN std_logic;
		
		u_Remote_Wake : IN std_logic;
		
		u_LineState : IN std_logic_vector(1 downto 0);
		u_Vbus : IN std_logic_vector(1 downto 0);
		u_Rx_Cmd_Received : IN std_logic;
		
		u_Send_NOPID_CMD : OUT std_logic;
		u_Send_EXTW_CMD : OUT std_logic;
		u_Send_REGW_CMD : OUT std_logic;
		u_Send_EXTR_CMD : OUT std_logic;
		u_Send_REGR_CMD : OUT std_logic;
		u_Send_STP_CMD : OUT std_logic;
		u_Send_Last : OUT std_logic;

		u_Tx_Data : OUT std_logic_vector(7 downto 0);
		u_Tx_Regw_Data : OUT  STD_LOGIC_VECTOR (7 downto 0);
		u_Tx_Cmd_Done : IN STD_LOGIC;
		u_Tx_Reg_Addr : OUT  STD_LOGIC_VECTOR (7 downto 0);

		u_USB_Mode : OUT std_logic;
		u_Not_Connected : OUT std_logic;
		u_Set_Mode_HS : OUT std_logic;
		u_Set_Mode_FS : OUT std_logic;
		u_Wake : OUT std_logic;
		u_USBCMD_RS : in std_logic;
		state_ind_hs : out STD_LOGIC_VECTOR(4 downto 0);
		u_Negociation_Done : out  STD_LOGIC
		);
	END COMPONENT;
    
	COMPONENT Packet_Decoder
	PORT(
	    Ulpi_Clk : in STD_LOGIC;
	    reset : in STD_LOGIC;
	    Axi_Clk : IN std_logic;
	    Axi_Resetn : IN STD_LOGIC; 
	    
        a_Arb_Endpt_Nr : in std_logic_vector(4 downto 0); 
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
        --RX FIFO (write)
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
        
        u_Setup_Buffer_Bytes_3_0  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        u_Setup_Buffer_Bytes_7_4  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        u_Send_PID_CMD : out  STD_LOGIC;
        u_Send_Last : out  STD_LOGIC;
        u_Tx_Data : out  STD_LOGIC_VECTOR (7 downto 0);
        u_Tx_Data_En : in STD_LOGIC;
        u_Tx_Pid : out  STD_LOGIC_VECTOR (3 downto 0);
        u_Tx_Cmd_Done : in STD_LOGIC;
        u_Tx_Pid_Phase_Done : in STD_LOGIC;           
        u_CRC16_En_Ulpi : in STD_LOGIC;
        u_RxEvent : in STD_LOGIC_VECTOR(1 downto 0);
        u_RxActive  : in  STD_LOGIC;
        u_Rx_Packet_Received : in STD_LOGIC;
        u_Ulpi_Dir_Out : in  STD_LOGIC;
        u_Rx_Data : in STD_LOGIC_VECTOR(7 downto 0);
        u_USB_Mode : in STD_LOGIC;
       
        u_Setup_Received : OUT std_logic;
        u_Setup_Received_Rst : IN std_logic;
        u_In_Token_Received : OUT std_logic;
        u_In_Packet_Complete : OUT std_logic;
        u_In_Packet_Complete_Rst : IN std_logic;
        u_iPush_Endpt_Nr_PD : OUT STD_LOGIC;
--        endp_enable : IN STD_LOGIC(11 downto 0);
        u_Send_Zero_Length_Packet : in STD_LOGIC;
        u_Send_Zero_Length_Packet_Ack_Set : OUT STD_LOGIC;
        u_Send_Zero_Length_Packet_Clear : OUT STD_LOGIC;
        u_NAK_Sent : out STD_LOGIC;
        u_Frame_Index : out STD_LOGIC_VECTOR (10 downto 0);
        u_SOF_received : out STD_LOGIC;
        u_Cnt_Bytes_Sent : out std_logic_vector(12 downto 0);
        u_Cnt_Bytes_Sent_Latch : out STD_LOGIC;    
        u_Resend_Set : out STD_LOGIC;
        u_Endp_Nr  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);

        u_Endp_Stall : IN STD_LOGIC;
        u_Endp_Type : in STD_LOGIC_VECTOR(1 downto 0);   
        u_USBADRA : in STD_LOGIC_VECTOR (7 downto 0);    
        axis_32_to_8_latency_comp_out_port : out STD_LOGIC;
        ulpi_latency_comp_out : in STD_LOGIC;
        state_ind_pd : out STD_LOGIC_VECTOR(6 downto 0);
        packet_err : out STD_LOGIC
		);	
	END COMPONENT;
	
	COMPONENT SyncBase
	Generic (
       kResetTo : std_logic := '0'; --value when reset and upon init
       kStages : natural := 2); --double sync by default
    PORT(
        aReset : IN std_logic;
        InClk : IN std_logic;
        iIn : IN std_logic;
        OutClk : IN std_logic;          
        oOut : OUT std_logic
        );
    END COMPONENT;

	type state_type is (IDLE, SEND_ZERO_LENGTH_STATE, RESET_SETUP_RECEIVED); 
    signal state, next_state : state_type;
    type PACKET_IN_BYTE_COUNT is array (11 downto 0) of std_logic_vector(12 downto 0);
    signal u_Cnt_Bytes_Sent_Array : PACKET_IN_BYTE_COUNT; 
	
	signal reset : STD_LOGIC;
	signal not_reset : STD_LOGIC;
	signal not_axi_resetn : STD_LOGIC;
	signal u_Send_NOPID_CMD : STD_LOGIC;
	signal u_Send_PID_CMD : STD_LOGIC;
	signal u_Send_EXTW_CMD : STD_LOGIC;
	signal u_Send_REGW_CMD : STD_LOGIC;
	signal u_Send_EXTR_CMD : STD_LOGIC;
	signal u_Send_REGR_CMD : STD_LOGIC;
	signal u_Send_STP_CMD : STD_LOGIC;
    signal u_Send_Last : STD_LOGIC;
    signal u_Send_Last_HSNegociation : STD_LOGIC;
    signal u_Send_Last_PD : STD_LOGIC;
    signal u_Tx_Pid : STD_LOGIC_VECTOR(3 downto 0); 
    signal u_Tx_Data : STD_LOGIC_VECTOR(7 downto 0);
    signal u_Tx_Regw_Data : STD_LOGIC_VECTOR(7 downto 0);
    signal u_Tx_Cmd_Done : STD_LOGIC;
    signal u_Tx_Reg_Addr : STD_LOGIC_VECTOR(7 downto 0);
    signal u_Tx_Data_HSNegociation : STD_LOGIC_VECTOR(7 downto 0);
    signal u_Tx_Data_PD : STD_LOGIC_VECTOR(7 downto 0);
    signal u_Tx_Data_En : STD_LOGIC;
    signal u_Tx_Pid_Phase_Done : STD_LOGIC;
    signal u_CRC16_En : STD_LOGIC;
	
	signal u_Rx_Data : STD_LOGIC_VECTOR(7 downto 0);
	signal u_Rx_Cmd_Received : STD_LOGIC;
    signal u_RxEvent : STD_LOGIC_VECTOR(1 downto 0);
    signal u_RxActive : STD_LOGIC;
    signal u_Rx_Register_Data : STD_LOGIC_VECTOR(7 downto 0);
    signal u_Rx_Register_Data_Received : STD_LOGIC;
    signal u_Rx_Packet_Received : STD_LOGIC;
	signal u_LineState : STD_LOGIC_VECTOR(1 downto 0);
	signal u_Vbus : STD_LOGIC_VECTOR(1 downto 0);
	signal u_Ulpi_Dir_Out : STD_LOGIC;
	signal u_ID : STD_LOGIC;
	signal u_Alt_Int : STD_LOGIC;
	signal u_Negociation_Done : STD_LOGIC;
    signal u_USB_Mode : STD_LOGIC;
    signal packet_err : STD_LOGIC;	
    
    type u_Cnt_Bytes_Sent_iData_Array is array (MAX_NR_ENDP downto 0) of std_logic_vector(12 downto 0);
    signal u_Cnt_Bytes_Sent_iData : u_Cnt_Bytes_Sent_iData_Array; 
    type a_Cnt_Bytes_Sent_oData_Array is array (MAX_NR_ENDP downto 0) of std_logic_vector(12 downto 0);
    signal a_Cnt_Bytes_Sent_oData_Loc : a_Cnt_Bytes_Sent_oData_Array; 
    type u_Cnt_Bytes_Sent_iPush_Array is array (MAX_NR_ENDP downto 0) of std_logic;
    signal u_Cnt_Bytes_Sent_iPush : u_Cnt_Bytes_Sent_iPush_Array; 
    type u_Cnt_Bytes_Sent_iRdy_Array is array (MAX_NR_ENDP downto 0) of std_logic;
    signal u_Cnt_Bytes_Sent_iRdy : u_Cnt_Bytes_Sent_iRdy_Array; 
    type a_Cnt_Bytes_Sent_oValid_Array is array (MAX_NR_ENDP downto 0) of std_logic;
    signal a_Cnt_Bytes_Sent_oValid_Loc : a_Cnt_Bytes_Sent_oValid_Array;      
    signal u_Cnt_Bytes_Sent : STD_LOGIC_VECTOR(12 downto 0);  
    signal u_Cnt_Bytes_Sent_Latch, u_Cnt_Bytes_Sent_Latch_q : STD_LOGIC;    
    
    signal u_ENDPTNAK_iData    :  std_logic_vector(31 downto 0);
    signal a_ENDPTNAK_oValid   : STD_LOGIC;
    signal a_ENDPTNAK_Wr_En_q    : STD_LOGIC;
    signal u_ENDPTNAK_iPush : STD_LOGIC;
    signal u_ENDPTNAK_iRdy : STD_LOGIC;
    
    signal u_ENDPTSETUPSTAT_iData    :  std_logic_vector(31 downto 0);
    signal a_ENDPTSETUPSTAT_Wr_En_q    :  std_logic;
    signal u_ENDPTSETUPSTAT_iPush : STD_LOGIC;
    signal u_ENDPTSETUPSTAT_iRdy : STD_LOGIC;
    signal a_ENDPTSETUPSTAT_oValid : STD_LOGIC;
    signal u_Setup_Received : STD_LOGIC; 
    signal u_Setup_Received_Rst : STD_LOGIC;
    signal a_ENDPTSETUP_RECEIVED_Wr_En_qq, a_ENDPTSETUP_RECEIVED_Wr_En_q, a_ENDPTSETUP_RECEIVED_Wr_En_Loc : STD_LOGIC;
    signal ENDPTSETUPSTAT_Hanshake_Rst, a_ENDPTSETUPSTAT_Hanshake_Rst : STD_LOGIC;
    
    signal u_In_Packet_Complete_iData : std_logic_vector (31 downto 0);
    signal u_In_Packet_Complete_iPush : std_logic;
    signal u_In_Packet_Complete_iRdy  : std_logic;
    signal a_In_Packet_Complete_Set_En_q, a_In_Packet_Complete_Set_En_qq  : std_logic; 
    signal a_Packet_In_Complete_Hanshake_Rst, Packet_In_Complete_Hanshake_Rst : std_logic;
    signal a_In_Packet_Complete_Set_En_Loc : std_logic;
    signal a_In_Packet_Complete_Wr_En_q : std_logic;
    signal a_In_Packet_In_Complete_oValid : STD_LOGIC;
    signal u_In_Packet_Complete : STD_LOGIC;
    signal u_In_Packet_Complete_Rst : STD_LOGIC;
    
    signal u_FRINDEX_iData : std_logic_vector(10 downto 0);             
    signal a_FRINDEX_Wr_En_q : std_logic;
    signal a_FRINDEX_oValid : STD_LOGIC;
    signal u_FRINDEX_iPush : STD_LOGIC;
    signal u_FRINDEX_iRdy : STD_LOGIC;   
    signal u_SOF_Received : STD_LOGIC;
    signal u_Frame_Index : STD_LOGIC_VECTOR(10 downto 0);
    
    signal u_In_Token_Received : std_logic;
    signal u_In_Token_Received_iData  :  std_logic_vector(31 downto 0); 
    signal a_In_Token_Received_Set_En_q, a_In_Token_Received_Set_En_qq, a_In_Token_Received_Set_En_Loc : STD_LOGIC;
    signal u_In_Token_Received_iPush : STD_LOGIC;
    signal u_In_Token_Received_iRdy : STD_LOGIC; 
    signal a_In_Token_Received_oValid : STD_LOGIC; 
    signal a_In_Token_Received_Hanshake_Rst, In_Token_Received_Hanshake_Rst  : STD_LOGIC;
    
    signal u_Send_Zero_Length_Packet_Clear_iData : std_logic_vector(31 downto 0);
    signal u_Send_Zero_Length_Packet_Clear : std_logic;
    signal u_Send_Zero_Length_Packet_Clear_iPush : std_logic;
    signal u_Send_Zero_Length_Packet_Clear_iRdy : std_logic;
    signal a_Send_Zero_Length_Packet_Clear_oValid : std_logic;
    signal a_Send_Zero_Length_Packet_Clear_En_q, a_Send_Zero_Length_Packet_Clear_En_qq : std_logic;    
    signal a_Send_Zero_Length_Packet_Clear_En_Loc : std_logic;    
    signal Send_Zero_Length_Packet_Clear_Hanshake_Rst, a_Send_Zero_Length_Packet_Clear_Hanshake_Rst : std_logic;

	signal u_Send_Zero_Length_Packet_Ack_iData, u_Send_Zero_Length_Packet_Ack_iData_q :  std_logic_vector(31 downto 0); 
    signal u_Send_Zero_Length_Packet_Ack_iRdy : std_logic;
    signal u_Send_Zero_Length_Packet_Ack_Set : STD_LOGIC;
    signal u_Send_Zero_Length_Packet_Ack_iPush : std_logic;
    signal a_Send_Zero_Length_Packet_Ack_oValid  : STD_LOGIC; 
    signal a_Send_Zero_Length_Packet_Ack_Set_En_q, a_Send_Zero_Length_Packet_Ack_Set_En_qq : std_logic;
    signal u_Send_Zero_Length_Packet : STD_LOGIC;  
    signal a_Send_Zero_Length_Packet_Ack_Set_En_Loc : std_logic;    
    signal a_Send_Zero_Length_Packet_Ack_Set_Hanshake_Rst, Send_Zero_Length_Packet_Ack_Set_Hanshake_Rst : std_logic;  

    signal u_Setup_Buffer_Bytes_3_0_iData  :  STD_LOGIC_VECTOR(31 DOWNTO 0); 
    signal u_Setup_Buffer_Bytes_3_0_q  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal u_Setup_Buffer_Bytes_3_0_iPush : STD_LOGIC;  
    signal u_Setup_Buffer_Bytes_3_0_iRdy : STD_LOGIC; 
    signal a_Setup_Buffer_Bytes_3_0_oValid : STD_LOGIC;
        
    signal u_Setup_Buffer_Bytes_7_4_iData  :  STD_LOGIC_VECTOR(31 DOWNTO 0); 
    signal u_Setup_Buffer_Bytes_7_4_q  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal u_Setup_Buffer_Bytes_7_4_iPush : STD_LOGIC;  
    signal u_Setup_Buffer_Bytes_7_4_iRdy : STD_LOGIC; 
    signal a_Setup_Buffer_Bytes_7_4_oValid : STD_LOGIC; 
    
    signal u_NAK_Sent : STD_LOGIC;
    signal u_USBSTS_NAKI_iData    :  std_logic_vector(0 downto 0);
    signal a_USBSTS_NAKI_Wr_En_q : std_logic;
    signal u_USBSTS_NAKI_iPush  : std_logic;
    signal u_USBSTS_NAKI_iRdy   : std_logic;
    signal a_USBSTS_NAKI_oValid : std_logic;
    signal a_USBSTS_NAKI_Vector : STD_LOGIC_VECTOR(0 downto 0);     
    
    signal u_USBSTS_SLI_iData    :  std_logic_vector(0 downto 0);
    signal u_USBSTS_SLI_iPush : std_logic;
    signal u_USBSTS_SLI_iRdy : std_logic;
    signal a_USBSTS_SLI_oValid : std_logic;
    signal a_USBSTS_SLI_Vector  : STD_LOGIC_VECTOR(0 downto 0);
    signal a_USBSTS_SLI_Wr_En_q : std_logic;
    signal u_Suspend_State, u_Suspend_State_q, u_Set_Suspend_State : STD_LOGIC;
    signal u_Clear_Suspend_State, u_Set_Clear_Suspend_State, u_Set_Clear_Suspend_State_q : STD_LOGIC;
     
    signal u_USBSTS_SRI_iData    :  std_logic_vector(0 downto 0); 
    signal u_USBSTS_SRI_iPush : std_logic;  
    signal u_USBSTS_SRI_iRdy  : std_logic;   
    signal a_USBSTS_SRI_oValid : std_logic;    
    signal a_USBSTS_SRI_Vector  : STD_LOGIC_VECTOR(0 downto 0);
    signal a_USBSTS_SRI_Wr_En_q : std_logic;
    
    signal u_USBSTS_URI_iData    :  std_logic_vector(0 downto 0);
    signal u_USBSTS_URI_iPush    :  std_logic;
    signal u_USBSTS_URI_iRdy     :  std_logic;
    signal a_USBSTS_URI_oValid   :  std_logic;
    signal a_USBSTS_URI_Vector  : STD_LOGIC_VECTOR(0 downto 0);            
    signal a_USBSTS_URI_Wr_En_q    : std_logic; 
    signal u_Reset_Received_Ulpi_q, u_Reset_Received, u_Reset_Received_Ulpi : STD_LOGIC;
    
    signal u_USBSTS_PCI_iData    :  std_logic_vector(0 downto 0);
    signal u_USBSTS_PCI_iPush : STD_LOGIC; 
    signal u_USBSTS_PCI_iRdy: STD_LOGIC;
    signal a_USBSTS_PCI_oValid: STD_LOGIC;
    signal a_USBSTS_PCI_Vector  : STD_LOGIC_VECTOR(0 downto 0);
    signal a_USBSTS_PCI_Wr_En_q : std_logic;
    signal u_Port_Change_Detect : STD_LOGIC;
    signal u_Wake : STD_LOGIC;
    signal u_Set_Mode_FS : STD_LOGIC;
    signal u_Set_Mode_HS : STD_LOGIC;
    
    signal u_PORTSC1_iData    :  std_logic_vector(1 downto 0);
    signal u_PORTSC1_iPush : STD_LOGIC;  
    signal u_PORTSC1_iRdy : STD_LOGIC; 
    signal a_PORTSC1_oValid : STD_LOGIC; 
    signal a_PORTSC1_PSPD_Wr_En_q  : STD_LOGIC; 
    signal u_Not_Connected : STD_LOGIC;
    signal u_Not_Connected_Pulse : STD_LOGIC;
    signal u_Not_Connected_q : STD_LOGIC; 
    
    signal u_Resend_Set : STD_LOGIC;
    signal u_Resend_iData : std_logic_vector (31 downto 0);
    signal u_Resend_iPush : std_logic;
    signal u_Resend_iRdy  : std_logic;
    signal a_Resend_Wr_En_q : std_logic;
    signal a_Resend_oValid : STD_LOGIC;        
                    
    signal u_Endpt_Nr_Loc : STD_LOGIC_VECTOR(4 downto 0);
    signal u_iPush_Endpt_Nr, u_iPush_Endpt_Nr_PD, u_Endpt_Nr_oValid, u_Endpt_Nr_iRdy : STD_LOGIC; 
    signal pe_endpt_nr_int_4msb : integer range 0 to 12;
    signal pe_endpt_nr_int : integer range 0 to 21;
    signal pe_endpt_nr_index : integer range 0 to 27;     
    signal arb_endpt_nr_int_4msb : integer range 0 to 22;  
    signal a_Arb_Endpt_Nr_Int_4msb : integer range 0 to 22;    
    signal u_Arb_Endpt_Nr_Loc, a_Arb_Endpt_Nr_Loc: STD_LOGIC_VECTOR(4 downto 0);
                           
    signal u_Endp_Stall_PD : STD_LOGIC;
    signal u_Endp_Type_PD : STD_LOGIC_VECTOR(1 downto 0);   
    signal state_ind_hs_loc :  STD_LOGIC_VECTOR(4 downto 0);
    signal ulpi_latency_comp_in, ulpi_latency_comp_out : STD_LOGIC; 

--	attribute mark_debug : string;
--    attribute keep : string;
--    attribute mark_debug of u_Send_Zero_Length_Packet_Ack_iPush : signal is "true";
--    attribute keep of u_Send_Zero_Length_Packet_Ack_iPush : signal is "true"; 
   
--attribute mark_debug of u_In_Packet_Complete_iData  : signal is "true";
--attribute keep of u_In_Packet_Complete_iData : signal is "true";
--attribute mark_debug of u_In_Packet_Complete_iPush  : signal is "true";
--attribute keep of u_In_Packet_Complete_iPush : signal is "true";
--attribute mark_debug of u_In_Packet_Complete_iRdy  : signal is "true";
--attribute keep of u_In_Packet_Complete_iRdy : signal is "true";
--attribute mark_debug of a_In_Packet_Complete_oData  : signal is "true";
--attribute keep of a_In_Packet_Complete_oData : signal is "true";
--attribute mark_debug of a_In_Packet_Complete_Set_En  : signal is "true";
--attribute keep of a_In_Packet_Complete_Set_En : signal is "true";
--attribute mark_debug of u_ENDPTSETUPSTAT_iData  : signal is "true";
--attribute keep of u_ENDPTSETUPSTAT_iData : signal is "true";
--attribute mark_debug of a_ENDPTSETUP_RECEIVED_oData  : signal is "true";
--attribute keep of a_ENDPTSETUP_RECEIVED_oData : signal is "true";
--attribute mark_debug of u_ENDPTSETUPSTAT_iPush  : signal is "true";
--attribute keep of u_ENDPTSETUPSTAT_iPush : signal is "true";
--attribute mark_debug of ENDPTSETUPSTAT_Hanshake_Rst  : signal is "true";
--attribute keep of ENDPTSETUPSTAT_Hanshake_Rst : signal is "true";   

--attribute mark_debug of u_In_Token_Received_iData  : signal is "true";
--attribute keep of u_In_Token_Received_iData : signal is "true";   
--attribute mark_debug of u_In_Token_Received_iPush  : signal is "true";
--attribute keep of u_In_Token_Received_iPush : signal is "true";   
--attribute mark_debug of a_In_Token_Received_oValid  : signal is "true";
--attribute keep of a_In_Token_Received_oValid : signal is "true";   
--attribute mark_debug of a_In_Token_Received_oData  : signal is "true";
--attribute keep of a_In_Token_Received_oData : signal is "true";  
--attribute mark_debug of In_Token_Received_Hanshake_Rst  : signal is "true";
--attribute keep of In_Token_Received_Hanshake_Rst : signal is "true";    

--attribute mark_debug of u_Cnt_Bytes_Sent_iPush  : signal is "true";
--attribute keep of u_Cnt_Bytes_Sent_iPush : signal is "true";   
--attribute mark_debug of a_Cnt_Bytes_Sent_oData_Loc  : signal is "true";
--attribute keep of a_Cnt_Bytes_Sent_oData_Loc : signal is "true";    


begin

u_Endp_Nr <= u_Endpt_Nr_Loc;
not_reset <= not (reset);
reset <= u_ResetN;
not_axi_resetn <= not (axi_resetn);
u_Arb_Endpt_Nr_Loc <= u_Endp_Nr_Arb;
a_Arb_Endpt_Nr_Loc <= a_Arb_Endpt_Nr;
state_ind_hs <= state_ind_hs_loc;
    
led <= '1';

--Transmit data MUX. During speed negotiation HS_Negotiation controls the ULPI bus.
--Once negotiation is done, the Packet_Decoder controls the ULPI bus

u_Tx_Data <= u_Tx_Data_PD when u_Negociation_Done = '1'
			  else u_Tx_Data_HSNegociation;--reg_data;--
u_Send_Last <= u_Send_Last_PD when u_Negociation_Done = '1'
			    else u_Send_Last_HSNegociation;

-- This module handles ULPI transmissions (NOPID, PID, EXTW, REGW, EXTR, REGR)
-- and reception  
			
	Inst_ULPI: ULPI PORT MAP(
		u_Ulpi_Data => u_Ulpi_Data,
		Ulpi_Clk => Ulpi_Clk,
		reset => reset,
		u_Ulpi_Dir => u_Ulpi_Dir,
		u_Ulpi_Nxt => u_Ulpi_Nxt,
		u_Ulpi_Stp => u_Ulpi_Stp,
		u_Ulpi_Reset => Ulpi_Reset,
		u_Send_NOOP_CMD => '0',
		u_Send_NOPID_CMD => u_Send_NOPID_CMD,
		u_Send_PID_CMD => u_Send_PID_CMD,
		u_Send_EXTW_CMD => u_Send_EXTW_CMD,
		u_Send_REGW_CMD => u_Send_REGW_CMD,
		u_Send_EXTR_CMD => u_Send_EXTR_CMD,
		u_Send_REGR_CMD => u_Send_REGR_CMD,
		u_Send_STP_CMD => u_Send_STP_CMD,
		u_Send_Last => u_Send_Last,
		u_Send_Err => '0',
		u_Tx_Data => u_Tx_Data,
		u_Tx_Data_En => u_Tx_Data_En,		
		u_Tx_Pid => u_Tx_Pid,		
		u_Tx_Regw_Data => u_Tx_Regw_Data,
		u_Tx_Reg_Addr => u_Tx_Reg_Addr,		
		u_Tx_Cmd_Done => u_Tx_Cmd_Done,
		u_CRC16_En => u_CRC16_En,
		u_Tx_Pid_Phase_Done => u_Tx_Pid_Phase_Done,
		u_Rx_Data => u_Rx_Data,
		u_Rx_Packet_Received => u_Rx_Packet_Received,
		u_Ulpi_Dir_Out => u_Ulpi_Dir_Out,
		u_LineState => u_LineState,
		u_Vbus => u_Vbus,
		u_RxEvent => u_RxEvent,
		u_RxActive => u_RxActive,
		u_ID => u_ID,
		u_Alt_Int => u_Alt_Int,
		u_Rx_Cmd_Received => u_Rx_Cmd_Received,
		state_ind => state_ind,
		u_Rx_Register_Data => u_Rx_Register_Data,
		u_Rx_Register_Data_Received => u_Rx_Register_Data_Received,
		u_USB_Mode => u_USB_Mode
	);

-- This module handles the USB speed negociatian, reset and suspend protocols
	
	Inst_HS_Negotiation: HS_Negotiation PORT MAP(
		u_Reset => reset,
		Ulpi_Clk => Ulpi_Clk,
		
		u_Send_NOPID_CMD => u_Send_NOPID_CMD,
		u_Send_EXTW_CMD => u_Send_EXTW_CMD,
		u_Send_REGW_CMD => u_Send_REGW_CMD,
		u_Send_EXTR_CMD => u_Send_EXTR_CMD,
		u_Send_REGR_CMD => u_Send_REGR_CMD,
		u_Send_STP_CMD => u_Send_STP_CMD,
		u_Send_Last => u_Send_Last_HSNegociation,
		u_Remote_Wake => '0',
		
		u_Rx_Cmd_Received => u_Rx_Cmd_Received,
		u_LineState => u_LineState,
		u_Vbus => u_Vbus,

		u_Tx_Data => u_Tx_Data_HSNegociation,
		u_Tx_Regw_Data => u_Tx_Regw_Data,
		u_Tx_Cmd_Done => u_Tx_Cmd_Done,
		u_Tx_Reg_Addr => u_Tx_Reg_Addr,
		
		u_USB_Mode => u_USB_Mode,
		u_Not_Connected => u_Not_Connected,
		u_Set_Mode_HS => u_Set_Mode_HS,
		u_Set_Mode_FS => u_Set_Mode_FS,
		u_Wake => u_Wake,
	    u_USBCMD_RS => u_USBCMD_RS,
		state_ind_hs => state_ind_hs_loc,
		u_Negociation_Done => u_Negociation_Done
	);
	
	u_Endp_Stall_PD <= u_Endp_Stall(pe_endpt_nr_int);
	u_Endp_Type_PD <= u_Endp_Type((pe_endpt_nr_int*2) + 1 downto pe_endpt_nr_int*2);
	u_Send_Zero_Length_Packet <= u_Send_Zero_Length_Packet_Rd(pe_endpt_nr_index);

-- This module implements chapter 8 of the USB protocol

	Inst_Packet_Decoder: Packet_Decoder PORT MAP(
	   Ulpi_Clk => Ulpi_Clk,
	   Axi_Clk => Axi_Clk,
	   reset => reset,
	   Axi_Resetn => Axi_Resetn,
       
       a_Arb_Endpt_Nr => a_Arb_Endpt_Nr,
       Tx_Fifo_S_Aresetn => Tx_Fifo_S_Aresetn, 
       a_Tx_Fifo_S_Aclk => a_Tx_Fifo_S_Aclk,
       a_Tx_Fifo_S_Axis_Tvalid => a_Tx_Fifo_S_Axis_Tvalid,
       a_Tx_Fifo_S_Axis_Tready => a_Tx_Fifo_S_Axis_Tready,
       a_Tx_Fifo_S_Axis_Tdata => a_Tx_Fifo_S_Axis_Tdata,
       a_Tx_Fifo_S_Axis_Tlast => a_Tx_Fifo_S_Axis_Tlast,
       a_Tx_Fifo_S_Axis_Tkeep => a_Tx_Fifo_S_Axis_Tkeep,
       a_Tx_Fifo_S_Axis_Tuser => a_Tx_Fifo_S_Axis_Tuser,
       tx_fifo_axis_overflow => tx_fifo_axis_overflow,
       tx_fifo_axis_underflow => tx_fifo_axis_underflow,
       
       u_Rx_Fifo_s_Aclk => u_Rx_Fifo_s_Aclk,
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
       
       u_Setup_Buffer_Bytes_3_0  => u_Setup_Buffer_Bytes_3_0_iData,
       u_Setup_Buffer_Bytes_7_4 => u_Setup_Buffer_Bytes_7_4_iData,
     
       u_Send_PID_CMD => u_Send_PID_CMD,
       u_Send_Last => u_Send_Last_PD,
       u_Tx_Data => u_Tx_Data_PD,
       u_Tx_Data_En => u_Tx_Data_En, 
       u_Tx_Pid => u_Tx_Pid,
       u_Tx_Cmd_Done => u_Tx_Cmd_Done,
       u_Tx_Pid_Phase_Done => u_Tx_Pid_Phase_Done,
       u_CRC16_En_Ulpi => u_CRC16_En, 
       u_Rx_Data => u_Rx_Data,
       u_Rx_Packet_Received => u_Rx_Packet_Received,
       u_Ulpi_Dir_Out => u_Ulpi_Dir_Out,
       u_RxEvent => u_RxEvent, 
       u_RxActive => u_RxActive,   
       u_USB_Mode => u_USB_Mode,                
   
	   u_Setup_Received => u_Setup_Received,
	   u_Setup_Received_Rst => u_Setup_Received_Rst,
       u_In_Token_Received => u_In_Token_Received,
       u_In_Packet_Complete => u_In_Packet_Complete,
       u_In_Packet_Complete_Rst => u_In_Packet_Complete_Rst,
       u_Cnt_Bytes_Sent_Latch => u_Cnt_Bytes_Sent_Latch,
       u_Cnt_Bytes_Sent => u_Cnt_Bytes_Sent,
       u_Resend_Set => u_Resend_Set,
       u_Endp_Nr => u_Endpt_Nr_Loc,
       u_iPush_Endpt_Nr_PD => u_iPush_Endpt_Nr_PD,
       u_Send_Zero_Length_Packet_Clear => u_Send_Zero_Length_Packet_Clear,
       u_Send_Zero_Length_Packet => u_Send_Zero_Length_Packet,
       u_Send_Zero_Length_Packet_Ack_Set => u_Send_Zero_Length_Packet_Ack_Set,       
       u_NAK_Sent => u_NAK_Sent,
       u_Frame_Index => u_Frame_Index,
	   u_SOF_Received => u_SOF_Received,
	   
	   u_USBADRA => u_USBADRA,
	   u_Endp_Type => u_Endp_Type_PD,
	   u_Endp_Stall => u_Endp_Stall_PD,
       ulpi_latency_comp_out => ulpi_latency_comp_out,
	   state_ind_pd => state_ind_pd,
	   packet_err =>packet_err
	);     
	
--Synchronization modules for data that crosses the ULPI clock domain to AXI clock domain	

    u_iPush_Endpt_Nr <= u_iPush_Endpt_Nr_PD when (u_Endpt_Nr_iRdy = '1') else '0';
    Inst_HandshakeData_pe_endpt_nr: entity work.HandshakeData  
    GENERIC MAP (
    kDataWidth => 5)
    PORT MAP(
        InClk => Ulpi_Clk,
        OutClk => Axi_Clk,
        iData => u_Endpt_Nr_Loc,
        oData => a_Endpt_Nr ,
        iPush => u_iPush_Endpt_Nr,
        iRdy => u_Endpt_Nr_iRdy,
        oAck => u_Endpt_Nr_oValid,
        oValid => u_Endpt_Nr_oValid,
        aReset => not_axi_resetn
    );                                                                                 
--------------------------------------------------------------------------------------------
   pe_endpt_nr_int_4msb <= to_integer(unsigned(u_Endpt_Nr_Loc(4 downto 1)));
   pe_endpt_nr_int <= to_integer(unsigned(u_Endpt_Nr_Loc));
   arb_endpt_nr_int_4msb <= to_integer(unsigned(u_Arb_Endpt_Nr_Loc(4 downto 1)));
   a_Arb_Endpt_Nr_Int_4msb <= to_integer(unsigned(a_Arb_Endpt_Nr_Loc(4 downto 1)));
     
   DEFINE_INDEX_PROC: process (reset, u_Endpt_Nr_Loc, pe_endpt_nr_int_4msb)
   begin
       if (reset = '0') then
            pe_endpt_nr_index <= 0;
       else
            if (u_Endpt_Nr_Loc(0) = '0') then
                pe_endpt_nr_index <= pe_endpt_nr_int_4msb;
            else
                pe_endpt_nr_index <= pe_endpt_nr_int_4msb + 16;    
            end if;
       end if;        
   end process;

    MULTIPLE_HANDSHAKE : for i in 0 to MAX_NR_ENDP generate      
    Inst_HandshakeData_Count: entity work.HandshakeData  
        GENERIC MAP (
            kDataWidth => 13)
            PORT MAP(
            InClk => Ulpi_Clk,
            OutClk => Axi_Clk,
            iData => u_Cnt_Bytes_Sent_iData(i),
            oData => a_Cnt_Bytes_Sent_oData_Loc(i),
            iPush => u_Cnt_Bytes_Sent_iPush(i),
            iRdy => u_Cnt_Bytes_Sent_iRdy(i),
            oAck => a_Cnt_Bytes_Sent_oValid_Loc(i),
            oValid => a_Cnt_Bytes_Sent_oValid_Loc(i),
            aReset => not_axi_resetn
        ); 
    end generate;   

    IN_PACKET_COUNTER_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Cnt_Bytes_Sent_iData <= (others => (others => '0'));
            else
                if (u_Cnt_Bytes_Sent_Latch = '1') then
                    u_Cnt_Bytes_Sent_iData(pe_endpt_nr_int_4msb) <= u_Cnt_Bytes_Sent;
                end if;
            end if;        
        end if;
    end process; 

    IPUSH_COUNTER_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Cnt_Bytes_Sent_iPush <= (others => '0');
                u_Cnt_Bytes_Sent_Latch_q <= '0';
            else
                u_Cnt_Bytes_Sent_Latch_q <= u_Cnt_Bytes_Sent_Latch;
                if ((u_Cnt_Bytes_Sent_Latch_q = '1') and (u_Cnt_Bytes_Sent_iRdy(pe_endpt_nr_int_4msb) = '1'))then
                    u_Cnt_Bytes_Sent_iPush(pe_endpt_nr_int_4msb) <= '1';
                else
                    u_Cnt_Bytes_Sent_iPush(pe_endpt_nr_int_4msb) <= '0';
                end if;   
            end if;
        end if;    
    end process;        
    
    IN_TRANSF_CNT_OVALID_PROC : process (Axi_Clk)
        begin 
        if (Axi_Clk'event and Axi_Clk = '1') then
           if (axi_resetn = '0') then 
              a_Cnt_Bytes_Sent_oValid <= '0';
           else
              a_Cnt_Bytes_Sent_oValid <= a_Cnt_Bytes_Sent_oValid_Loc(a_Arb_Endpt_Nr_Int_4msb);
           end if;
        end if;              
        end process; 

    IN_TRANSF_CNT_ODATA_PROC : process (Axi_Clk)
        begin
        if (Axi_Clk'event and Axi_Clk = '1') then
           if (axi_resetn = '0') then 
              a_Cnt_Bytes_Sent_oData <= (others => '0');
           else
              if (a_Cnt_Bytes_Sent_oValid_Loc(a_Arb_Endpt_Nr_Int_4msb) = '1') then
                 a_Cnt_Bytes_Sent_oData <= a_Cnt_Bytes_Sent_oData_Loc(a_Arb_Endpt_Nr_Int_4msb);
              end if;  
           end if;
        end if;              
        end process;             
        
---------------------------------------------------------------------------------------------------------                
   NAK_PROC: process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_ENDPTNAK_iData <= (others => '0');
            u_ENDPTNAK_iPush <= '0';
         else
            if (u_NAK_Sent = '1' and u_ENDPTNAK_iRdy = '1') then
                u_ENDPTNAK_iData(pe_endpt_nr_index) <= '1';
                u_ENDPTNAK_iPush <= '1';
            else
                u_ENDPTNAK_iData <= (others => '0');
                u_ENDPTNAK_iPush <= '0'; 
            end if;    
         end if;        
      end if;
   end process; 
   
   ENDPTNAK_wr_en_PROC : process (Axi_Clk) 
   begin
   if (Axi_Clk'event and Axi_Clk = '1') then
      if (axi_resetn = '0') then 
         a_ENDPTNAK_Wr_En <= '0';
         a_ENDPTNAK_Wr_En_q <= '0';
      else
        a_ENDPTNAK_Wr_En_q <= a_ENDPTNAK_oValid;
        a_ENDPTNAK_Wr_En <= a_ENDPTNAK_oValid and (not a_ENDPTNAK_Wr_En_q); 
      end if;
   end if;              
   end process;  
        
   Inst_HandshakeData_ENDPTNAK : entity work.HandshakeData 
   GENERIC MAP (
       kDataWidth => 32)
       PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_ENDPTNAK_iData,
       oData => a_ENDPTNAK_oData,
       iPush => u_ENDPTNAK_iPush,
       iRdy => u_ENDPTNAK_iRdy,
       oAck => a_ENDPTNAK_oValid,
       oValid => a_ENDPTNAK_oValid,
       aReset => not_axi_resetn
   ); 
-----------------------------------------------------------------------------------------------    
   ENDPTSETUPSTAT_PROC : process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_Setup_Received_Rst <= '0';
            u_ENDPTSETUPSTAT_iData <= (others => '0');
            u_ENDPTSETUPSTAT_iPush <= '0';
         else
            if (u_Setup_Received = '1' and u_ENDPTSETUPSTAT_iRdy = '1') then
                u_ENDPTSETUPSTAT_iData(pe_endpt_nr_index) <= '1';
                u_ENDPTSETUPSTAT_iPush <= '1';
                u_Setup_Received_Rst <= '0';
            else
                u_ENDPTSETUPSTAT_iData <= (others => '0');
                u_Setup_Received_Rst <= '1';
                u_ENDPTSETUPSTAT_iPush <= '0';  
            end if;    
         end if;        
      end if;
   end process; 

   ENDPTSETUPSTAT_wr_en_PROC : process (Axi_Clk)
   begin
   if (Axi_Clk'event and Axi_Clk = '1') then
      if (axi_resetn = '0') then 
         a_ENDPTSETUP_RECEIVED_Wr_En_Loc <= '0';
         a_ENDPTSETUPSTAT_Wr_En_q <= '0';
         a_ENDPTSETUP_RECEIVED_Wr_En_qq <= '0';
         a_ENDPTSETUPSTAT_Hanshake_Rst <= '0';
         a_ENDPTSETUP_RECEIVED_Wr_En_q <= '0';
      else
        a_ENDPTSETUPSTAT_Wr_En_q <= a_ENDPTSETUPSTAT_oValid;
        a_ENDPTSETUP_RECEIVED_Wr_En_Loc <= a_ENDPTSETUPSTAT_oValid and (not a_ENDPTSETUPSTAT_Wr_En_q); 
        a_ENDPTSETUP_RECEIVED_Wr_En_q <= a_ENDPTSETUP_RECEIVED_Wr_En_Loc;
        a_ENDPTSETUP_RECEIVED_Wr_En_qq <= a_ENDPTSETUP_RECEIVED_Wr_En_q;
        a_ENDPTSETUPSTAT_Hanshake_Rst <= a_ENDPTSETUP_RECEIVED_Wr_En_qq;
      end if;
   end if;              
   end process; 
   
   ENDPTSETUPSTAT_Hanshake_Rst <= a_ENDPTSETUPSTAT_Hanshake_Rst or not_axi_resetn;
   a_ENDPTSETUP_RECEIVED_Wr_En <= a_ENDPTSETUP_RECEIVED_Wr_En_Loc;
      
   Inst_HandshakeData_ENDPTSETUPSTAT : entity work.HandshakeData 
       GENERIC MAP (
       kDataWidth => 32)
       PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_ENDPTSETUPSTAT_iData,
       oData => a_ENDPTSETUP_RECEIVED_oData,
       iPush => u_ENDPTSETUPSTAT_iPush,
       iRdy => u_ENDPTSETUPSTAT_iRdy,
       oAck => a_ENDPTSETUPSTAT_oValid,
       oValid => a_ENDPTSETUPSTAT_oValid,
       aReset => ENDPTSETUPSTAT_Hanshake_Rst
   );    
------------------------------------------------------------------------------------------------
   PACKET_IN_COMPLETE_PROC : process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_In_Packet_Complete_iData <= (others => '0');
            u_In_Packet_Complete_iPush <= '0';
            u_In_Packet_Complete_Rst <= '0';
         else
            if (u_In_Packet_Complete = '1' and u_In_Packet_Complete_iRdy = '1') then
                u_In_Packet_Complete_iData(pe_endpt_nr_index) <= '1';
                u_In_Packet_Complete_iPush <= '1';
                u_In_Packet_Complete_Rst <= '0';
            else
                u_In_Packet_Complete_iData <= (others => '0');
                u_In_Packet_Complete_Rst <= '1';
                u_In_Packet_Complete_iPush <= '0';  
            end if;    
         end if;        
      end if;
   end process;

    packet_in_complete_wr_en_PROC : process (Axi_Clk) 
    begin
    if (Axi_Clk'event and Axi_Clk = '1') then
       if (axi_resetn = '0') then 
          a_In_Packet_Complete_Set_En_Loc <= '0';
          a_In_Packet_Complete_Wr_En_q <= '0';
          a_In_Packet_Complete_Set_En_q <= '0';
          a_In_Packet_Complete_Set_En_qq <= '0';
          a_Packet_In_Complete_Hanshake_Rst <= '0'; 
       else
         a_In_Packet_Complete_Wr_En_q <= a_In_Packet_In_Complete_oValid;
         a_In_Packet_Complete_Set_En_Loc <= a_In_Packet_In_Complete_oValid and (not a_In_Packet_Complete_Wr_En_q); 
         a_In_Packet_Complete_Set_En_q <= a_In_Packet_Complete_Set_En_Loc;
         a_In_Packet_Complete_Set_En_qq <= a_In_Packet_Complete_Set_En_q;
         a_Packet_In_Complete_Hanshake_Rst <= a_In_Packet_Complete_Set_En_qq; 
       end if;
    end if;              
    end process;  
    
    a_In_Packet_Complete_Set_En <= a_In_Packet_Complete_Set_En_Loc;
    Packet_In_Complete_Hanshake_Rst <= a_Packet_In_Complete_Hanshake_Rst or not_axi_resetn; 
            
   Inst_HandshakeData_packet_in_complete : entity work.HandshakeData 
      GENERIC MAP (
      kDataWidth => 32)
      PORT MAP(
          InClk => Ulpi_Clk,
          OutClk => Axi_Clk,
          iData => u_In_Packet_Complete_iData,
          oData => a_In_Packet_Complete_oData,
          iPush => (u_In_Packet_Complete_iPush and u_In_Packet_Complete_iRdy),
          iRdy => u_In_Packet_Complete_iRdy,
          oAck => a_In_Packet_In_Complete_oValid,
          oValid => a_In_Packet_In_Complete_oValid,
          aReset => Packet_In_Complete_Hanshake_Rst
          );     
-----------------------------------------------------------------------------------------------------     
   FRINDEX_PROC : process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_FRINDEX_iData <= (others => '0');
            u_FRINDEX_iPush <= '0';
         else
            if (u_SOF_Received = '1' and u_FRINDEX_iRdy = '1') then
                u_FRINDEX_iData(10 downto 0) <= u_Frame_Index;
                u_FRINDEX_iPush <= '1';
            else
                u_FRINDEX_iPush <= '0';    
            end if;    
         end if;        
      end if;
   end process;  
                     
   FRINDEX_wr_en_PROC : process (Axi_Clk)
       begin
       if (Axi_Clk'event and Axi_Clk = '1') then
          if (axi_resetn = '0') then 
             a_FRINDEX_Wr_En <= '0';
             a_FRINDEX_Wr_En_q <= '0';
          else
            a_FRINDEX_Wr_En_q <= a_FRINDEX_oValid;
            a_FRINDEX_Wr_En <= a_FRINDEX_oValid and (not a_FRINDEX_Wr_En_q); 
          end if;
       end if;              
   end process;                      
                     
   Inst_HandshakeData_FRINDEX : entity work.HandshakeData 
       GENERIC MAP (
       kDataWidth => 11)
       PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_FRINDEX_iData,
       oData => a_FRINDEX_oData,
       iPush => u_FRINDEX_iPush,
       iRdy => u_FRINDEX_iRdy,
       oAck => a_FRINDEX_oValid,
       oValid => a_FRINDEX_oValid,
       aReset => not_axi_resetn
   );       
---------------------------------------------------------------------------------------------------------
   IN_TOKEN_RECEIVED_PROC: process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_In_Token_Received_iData <= (others => '0');
            u_In_Token_Received_iPush <= '0';
         else
            u_In_Token_Received_iPush <= u_In_Token_Received and u_In_Token_Received_iRdy;
            if (u_In_Token_Received = '1') then
                u_In_Token_Received_iData(pe_endpt_nr_index) <= '1';
            else
                u_In_Token_Received_iData <= (others => '0');   
            end if;    
         end if;        
      end if;
   end process;   
   
    in_token_received_set_en_PROC : process (Axi_Clk) 
        begin
        if (Axi_Clk'event and Axi_Clk = '1') then
           if (axi_resetn = '0') then 
              a_In_Token_Received_Set_En_Loc <= '0';
              a_In_Token_Received_Set_En_qq <= '0';
              a_In_Token_Received_Set_En_q <= '0';
              a_In_Token_Received_Hanshake_Rst <= '0';
           else
             a_In_Token_Received_Set_En_q <= a_In_Token_Received_oValid;
             a_In_Token_Received_Set_En_Loc <= a_In_Token_Received_oValid and (not a_In_Token_Received_Set_En_q); 
             a_In_Token_Received_Set_En_qq <= a_In_Token_Received_Set_En_Loc;
             a_In_Token_Received_Hanshake_Rst <= a_In_Token_Received_Set_En_qq;
           end if;
        end if;              
        end process; 
        
        a_In_Token_Received_Set_En <= a_In_Token_Received_Set_En_Loc;
        In_Token_Received_Hanshake_Rst <= a_In_Token_Received_Hanshake_Rst or not_axi_resetn;
   
   Inst_HandshakeData_in_token_received : entity work.HandshakeData 
       GENERIC MAP (
       kDataWidth => 32)
       PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_In_Token_Received_iData,
       oData => a_In_Token_Received_oData,
       iPush => u_In_Token_Received_iPush,
       iRdy => u_In_Token_Received_iRdy,
       oAck => a_In_Token_Received_oValid,
       oValid => a_In_Token_Received_oValid,
       aReset => In_Token_Received_Hanshake_Rst
    );    
-----------------------------------------------------------------------------------------------------------
   SEND_ZERO_LENGTH_PROC : process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_Send_Zero_Length_Packet_Clear_iData <= (others => '1');
            u_Send_Zero_Length_Packet_Clear_iPush <= '0';
         else
            if (u_Send_Zero_Length_Packet_Clear = '1') then
                u_Send_Zero_Length_Packet_Clear_iData(pe_endpt_nr_index) <= '0';
                u_Send_Zero_Length_Packet_Clear_iPush <= '1';
            else
                u_Send_Zero_Length_Packet_Clear_iData <= (others => '1');  
                u_Send_Zero_Length_Packet_Clear_iPush <= '0';
            end if;    
         end if;        
      end if;
   end process;  
   
    send_zero_length_packet_clear_en_PROC : process (Axi_Clk) 
    begin
       if (Axi_Clk'event and Axi_Clk = '1') then
          if (axi_resetn = '0') then 
             a_Send_Zero_Length_Packet_Clear_En_Loc <= '0';
             a_Send_Zero_Length_Packet_Clear_En_qq <= '0';
             a_Send_Zero_Length_Packet_Clear_En_q <= '0';
             a_Send_Zero_Length_Packet_Clear_Hanshake_Rst <= '0';
          else
            a_Send_Zero_Length_Packet_Clear_En_q <= a_In_Token_Received_oValid;
            a_Send_Zero_Length_Packet_Clear_En_Loc <= a_Send_Zero_Length_Packet_Clear_oValid and (not a_Send_Zero_Length_Packet_Clear_En_q); 
            a_Send_Zero_Length_Packet_Clear_En_qq <= a_Send_Zero_Length_Packet_Clear_En_Loc;
            a_Send_Zero_Length_Packet_Clear_Hanshake_Rst <= a_Send_Zero_Length_Packet_Clear_Hanshake_Rst;
          end if;
       end if;              
       end process; 
       
       a_Send_Zero_Length_Packet_Clear_En <= a_Send_Zero_Length_Packet_Clear_En_Loc;
       Send_Zero_Length_Packet_Clear_Hanshake_Rst <= a_Send_Zero_Length_Packet_Clear_Hanshake_Rst or not_axi_resetn;     
   
   Inst_HandshakeData_zero_length_clear: entity work.HandshakeData  
   GENERIC MAP (
       kDataWidth => 32)
       PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_Send_Zero_Length_Packet_Clear_iData,
       oData => a_Send_Zero_Length_Packet_Clear_oData ,
       iPush => (u_Send_Zero_Length_Packet_Clear_iPush and u_Send_Zero_Length_Packet_Clear_iRdy),
       iRdy => u_Send_Zero_Length_Packet_Clear_iRdy,
       oAck => a_Send_Zero_Length_Packet_Clear_oValid,
       oValid => a_Send_Zero_Length_Packet_Clear_oValid,
       aReset => Send_Zero_Length_Packet_Clear_Hanshake_Rst
   );    
-------------------------------------------------------------------------------------------------------------   
   SEND_ZERO_LENGTH_ACK_PROC : process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_Send_Zero_Length_Packet_Ack_iData <= (others => '0');
         else
            if (u_Send_Zero_Length_Packet_Ack_Set = '1') then
                u_Send_Zero_Length_Packet_Ack_iData(pe_endpt_nr_index) <= '1';
            else
                u_Send_Zero_Length_Packet_Ack_iData <= (others => '0');  
            end if;    
         end if;        
      end if;
   end process;
   
   IPUSH_SEND_ZERO_LENGTH_ACK_PROC : process (Ulpi_Clk)
   begin
       if (Ulpi_Clk'event and Ulpi_Clk = '1') then
          if (reset = '0') then 
             u_Send_Zero_Length_Packet_Ack_iPush <= '0';
             u_Send_Zero_Length_Packet_Ack_iData_q <= (others => '0');
          else
              u_Send_Zero_Length_Packet_Ack_iData_q <= u_Send_Zero_Length_Packet_Ack_iData;
              if (u_Send_Zero_Length_Packet_Ack_iData /= u_Send_Zero_Length_Packet_Ack_iData_q and u_Send_Zero_Length_Packet_Ack_iRdy = '1') then
                  u_Send_Zero_Length_Packet_Ack_iPush <= '1';
              else
                  u_Send_Zero_Length_Packet_Ack_iPush <= '0';
              end if;
          end if;
       end if;              
   end process;
     
    Send_Zero_Length_Packet_Ack_Set_En_PROC : process (Axi_Clk) 
    begin
          if (Axi_Clk'event and Axi_Clk = '1') then
             if (axi_resetn = '0') then 
                a_Send_Zero_Length_Packet_Ack_Set_En_Loc <= '0';
                a_Send_Zero_Length_Packet_Ack_Set_En_qq <= '0';
                a_Send_Zero_Length_Packet_Ack_Set_En_q <= '0';
                a_Send_Zero_Length_Packet_Ack_Set_Hanshake_Rst <= '0';
             else
               a_Send_Zero_Length_Packet_Ack_Set_En_q <= a_Send_Zero_Length_Packet_Ack_oValid;
               a_Send_Zero_Length_Packet_Ack_Set_En_Loc <= a_Send_Zero_Length_Packet_Ack_oValid and (not a_Send_Zero_Length_Packet_Ack_Set_En_q); 
               a_Send_Zero_Length_Packet_Ack_Set_En_qq <= a_Send_Zero_Length_Packet_Ack_Set_En_Loc;
               a_Send_Zero_Length_Packet_Ack_Set_Hanshake_Rst <= a_Send_Zero_Length_Packet_Ack_Set_En_qq;
             end if;
          end if;              
    end process; 
          
          a_Send_Zero_Length_Packet_Ack_Set_En <= a_Send_Zero_Length_Packet_Ack_Set_En_Loc;
          Send_Zero_Length_Packet_Ack_Set_Hanshake_Rst <= a_Send_Zero_Length_Packet_Ack_Set_Hanshake_Rst or not_axi_resetn;          
   
   Inst_HandshakeData_zero_length_ack: entity work.HandshakeData  
   GENERIC MAP (
       kDataWidth => 32)
       PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_Send_Zero_Length_Packet_Ack_iData,
       oData => a_Send_Zero_Length_Packet_Ack_oData ,
       iPush => u_Send_Zero_Length_Packet_Ack_iPush,
       iRdy => u_Send_Zero_Length_Packet_Ack_iRdy,
       oAck => a_Send_Zero_Length_Packet_Ack_oValid,
       oValid => a_Send_Zero_Length_Packet_Ack_oValid,
       aReset => Send_Zero_Length_Packet_Ack_Set_Hanshake_Rst
   );         
----------------------------------------------------------------------------------------------------------------  
    IPUSH_pe_SETUP_BUFFER_BYTES_3_0_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk'event and Ulpi_Clk = '1') then
           if (reset = '0') then 
              u_Setup_Buffer_Bytes_3_0_iPush <= '0';
              u_Setup_Buffer_Bytes_3_0_q <= (others => '0');
           else
               u_Setup_Buffer_Bytes_3_0_q <= u_Setup_Buffer_Bytes_3_0_iData;
               if (u_Setup_Buffer_Bytes_3_0_iData /= u_Setup_Buffer_Bytes_3_0_q and u_Setup_Buffer_Bytes_3_0_iRdy = '1') then
                   u_Setup_Buffer_Bytes_3_0_iPush <= '1';
               else
                   u_Setup_Buffer_Bytes_3_0_iPush <= '0';
               end if;
           end if;
        end if;              
    end process;
    
    Inst_HandshakeData_SETUP_BUFFER_BYTES_3_0 : entity work.HandshakeData 
    GENERIC MAP (
    kDataWidth => 32)
    PORT MAP(
           InClk => Ulpi_Clk,
           OutClk => Axi_Clk,
           iData => u_Setup_Buffer_Bytes_3_0_iData,
           oData => a_Setup_Buffer_Bytes_3_0_oData,
           iPush => u_Setup_Buffer_Bytes_3_0_iPush,
           iRdy => u_Setup_Buffer_Bytes_3_0_iRdy,
           oAck => a_Setup_Buffer_Bytes_3_0_oValid,
           oValid => a_Setup_Buffer_Bytes_3_0_oValid,
           aReset => not_axi_resetn
       );    
----------------------------------------------------------------------------------------------------------------
    IPUSH_pe_SETUP_BUFFER_BYTES_7_4_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk'event and Ulpi_Clk = '1') then
           if (reset = '0') then 
              u_Setup_Buffer_Bytes_7_4_iPush <= '0';
              u_Setup_Buffer_Bytes_7_4_q <= (others => '0');
           else
               u_Setup_Buffer_Bytes_7_4_q <= u_Setup_Buffer_Bytes_7_4_iData;
               if (u_Setup_Buffer_Bytes_7_4_iData /= u_Setup_Buffer_Bytes_7_4_q and u_Setup_Buffer_Bytes_7_4_iRdy = '1') then
                   u_Setup_Buffer_Bytes_7_4_iPush <= '1';
               else
                   u_Setup_Buffer_Bytes_7_4_iPush <= '0';
               end if;
           end if;
        end if;              
    end process;   
    
    Inst_HandshakeData_pe_SETUP_BUFFER_BYTES_7_4 : entity work.HandshakeData 
    GENERIC MAP (
    kDataWidth => 32)
    PORT MAP(
        InClk => Ulpi_Clk,
        OutClk => Axi_Clk,
        iData => u_Setup_Buffer_Bytes_7_4_iData,
        oData => a_Setup_Buffer_Bytes_7_4_oData,
        iPush => u_Setup_Buffer_Bytes_7_4_iPush,
        iRdy => u_Setup_Buffer_Bytes_7_4_iRdy,
        oAck => a_Setup_Buffer_Bytes_7_4_oValid,
        oValid => a_Setup_Buffer_Bytes_7_4_oValid,
        aReset => not_axi_resetn
    );   
----------------------------------------------------------------------------------------------------------------
    USBSTS_NAKI_PROC: process (Ulpi_Clk)
    begin
       if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
          if (reset = '0') then
             u_USBSTS_NAKI_iData <= "0";
             u_USBSTS_NAKI_iPush <= '0';
          else
             if (u_NAK_Sent = '1' and u_USBSTS_NAKI_iRdy = '1') then
                 u_USBSTS_NAKI_iData <= "1";
                 u_USBSTS_NAKI_iPush <= '1';
             else
                 u_USBSTS_NAKI_iPush <= '0';
             end if;                                                              
          end if;        
       end if;
    end process; 

    USBSTS_wr_en_NAK_PROC : process (Axi_Clk)
    begin
    if (Axi_Clk'event and Axi_Clk = '1') then
       if (axi_resetn = '0') then 
          a_USBSTS_NAKI_Wr_En <= '0';
          a_USBSTS_NAKI_Wr_En_q <= '0';
       else
         a_USBSTS_NAKI_Wr_En_q <= a_USBSTS_NAKI_oValid;
         a_USBSTS_NAKI_Wr_En <= a_USBSTS_NAKI_oValid and (not a_USBSTS_NAKI_Wr_En_q); 
       end if;
    end if;              
    end process;

   Inst_HandshakeData_NAKI : entity work.HandshakeData  
   GENERIC MAP (
   kDataWidth => 1)
   PORT MAP(
      InClk => Ulpi_Clk,
      OutClk => Axi_Clk,
      iData => u_USBSTS_NAKI_iData,
      oData => a_USBSTS_NAKI_Vector,
      iPush => u_USBSTS_NAKI_iPush,
      iRdy => u_USBSTS_NAKI_iRdy,
      oAck => a_USBSTS_NAKI_oValid,
      oValid => a_USBSTS_NAKI_oValid,
      aReset => not_axi_resetn
   ); 
   a_USBSTS_NAKI_oData <= a_USBSTS_NAKI_Vector(0);  
----------------------------------------------------------------------------------------------------------------   
    SET_CLEAR_SUSPEND_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Set_Suspend_State <= '0';
                u_Set_Clear_Suspend_State <= '0';
                u_Reset_Received_Ulpi <= '0';
            else
                if (state_ind_hs_loc = "10010") then
                    u_Set_Suspend_State <= '1';
                    u_Set_Clear_Suspend_State <= '0';
                    u_Reset_Received_Ulpi <= '0';
                else    
                    u_Set_Suspend_State <= '0';
                    u_Set_Clear_Suspend_State <= '1';
                    if(state_ind_hs_loc = "01000") then
                        u_Reset_Received_Ulpi <= '1';
                    else
                        u_Reset_Received_Ulpi <= '0';         
                    end if;                    
                end if;
            end if;    
        end if;
    end process;

    SET_SUSPEND_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk'event and Ulpi_Clk = '1') then
           if (reset = '0') then 
              u_Suspend_State <= '0';
              u_Suspend_State_q <= '0';
           else
             u_Suspend_State_q <= u_Set_Suspend_State;
             u_Suspend_State <= u_Set_Suspend_State and (not u_Suspend_State_q); 
           end if;
        end if;              
    end process;
    
    CLEAR_SUSPEND_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk'event and Ulpi_Clk = '1') then
           if (reset = '0') then 
              u_Clear_Suspend_State <= '0';
              u_Set_Clear_Suspend_State_q <= '0';
           else
             u_Set_Clear_Suspend_State_q <= u_Set_Clear_Suspend_State;
             u_Clear_Suspend_State <= u_Set_Clear_Suspend_State and (not u_Set_Clear_Suspend_State_q); 
           end if;
        end if;              
    end process;     
    
   USBSTS_SLI_PROC: process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_USBSTS_SLI_iData <= "0";
            u_USBSTS_SLI_iPush <= '0';
         else
            if (u_Suspend_State = '1' and u_USBSTS_SLI_iRdy = '1') then
                u_USBSTS_SLI_iData <= "1";
                u_USBSTS_SLI_iPush <= '1';  
            elsif (u_Clear_Suspend_State = '1' and u_USBSTS_SLI_iRdy = '1') then
                u_USBSTS_SLI_iData <= "1";
                u_USBSTS_SLI_iPush <= '1';
            else
                u_USBSTS_SLI_iPush <= '0'; 
            end if;       
         end if;    
      end if;
   end process; 
 
   USBSTS_wr_en_SLI_PROC : process (Axi_Clk)
   begin
       if (Axi_Clk'event and Axi_Clk = '1') then
          if (axi_resetn = '0') then 
             a_USBSTS_SLI_Wr_En <= '0';
             a_USBSTS_SLI_Wr_En_q <= '0';
          else
            a_USBSTS_SLI_Wr_En_q <= a_USBSTS_SLI_oValid;
            a_USBSTS_SLI_Wr_En <= a_USBSTS_SLI_oValid and (not a_USBSTS_SLI_Wr_En_q); 
          end if;
       end if;              
   end process;
      
   Inst_HandshakeData_SLI: entity work.HandshakeData  
   GENERIC MAP (
   kDataWidth => 1)
   PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_USBSTS_SLI_iData,
       oData => a_USBSTS_SLI_Vector,
       iPush => u_USBSTS_SLI_iPush,
       iRdy => u_USBSTS_SLI_iRdy,
       oAck => a_USBSTS_SLI_oValid,
       oValid => a_USBSTS_SLI_oValid,
       aReset => not_axi_resetn
    );
    a_USBSTS_SLI_oData <= a_USBSTS_SLI_Vector(0);
------------------------------------------------------------------------------------------------------------------------------------          
   USBSTS_SRI_PROC: process (Ulpi_Clk) 
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_USBSTS_SRI_iData <= "0";
            u_USBSTS_SRI_iPush <= '0';
         else
            if (u_SOF_Received = '1' and u_USBSTS_SRI_iRdy = '1') then
                u_USBSTS_SRI_iData <= "1";
                u_USBSTS_SRI_iPush <= '1';
            else
                u_USBSTS_SRI_iPush <= '0';
            end if;                                                                    
         end if;        
      end if;
   end process; 

   USBSTS_wr_en_SRI_PROC : process (Axi_Clk)
   begin
   if (Axi_Clk'event and Axi_Clk = '1') then
      if (axi_resetn = '0') then 
         a_USBSTS_SRI_Wr_En <= '0';
         a_USBSTS_SRI_Wr_En_q <= '0';
      else
        a_USBSTS_SRI_Wr_En_q <= a_USBSTS_SRI_oValid;
        a_USBSTS_SRI_Wr_En <= a_USBSTS_SRI_oValid and (not a_USBSTS_SRI_Wr_En_q); 
      end if;
   end if;              
   end process;

   Inst_HandshakeData_SRI: entity work.HandshakeData  
   GENERIC MAP (
   kDataWidth => 1)
   PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_USBSTS_SRI_iData,
       oData => a_USBSTS_SRI_Vector,
       iPush => u_USBSTS_SRI_iPush,
       iRdy => u_USBSTS_SRI_iRdy,
       oAck => a_USBSTS_SRI_oValid,
       oValid => a_USBSTS_SRI_oValid,
       aReset => not_axi_resetn
   );   
   a_USBSTS_SRI_oData <= a_USBSTS_SRI_Vector(0);
--------------------------------------------------------------------------------------------------------------------------------------
    USBSTS_URI_PROC: process (Ulpi_Clk)
    begin
       if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
          if (reset = '0') then
             u_USBSTS_URI_iData <= "0";
             u_USBSTS_URI_iPush <= '0';
          else
             if (u_Reset_Received = '1'  and u_USBSTS_URI_iRdy = '1') then
                 u_USBSTS_URI_iData <= "1";
                 u_USBSTS_URI_iPush <= '1';
             else
                 u_USBSTS_URI_iPush <= '0';
             end if;                                                                             
          end if;        
       end if;
    end process; 

    RESET_RECEIVED_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk'event and Ulpi_Clk = '1') then
           if (reset = '0') then 
              u_Reset_Received <= '0';
              u_Reset_Received_Ulpi_q <= '0';
           else
             u_Reset_Received_Ulpi_q <= u_Reset_Received_Ulpi;
             u_Reset_Received <= u_Reset_Received_Ulpi and (not u_Reset_Received_Ulpi_q); 
           end if;
        end if;              
    end process; 

    USBSTS_wr_en_URI_PROC : process (Axi_Clk)
    begin
        if (Axi_Clk'event and Axi_Clk = '1') then
           if (axi_resetn = '0') then 
              a_USBSTS_URI_Wr_En <= '0';
              a_USBSTS_URI_Wr_En_q <= '0';
           else
             a_USBSTS_URI_Wr_En_q <= a_USBSTS_URI_oValid;
             a_USBSTS_URI_Wr_En <= a_USBSTS_URI_oValid and (not a_USBSTS_URI_Wr_En_q); 
           end if;
        end if;              
    end process;
       
    Inst_HandshakeData_URI: entity work.HandshakeData  
    GENERIC MAP (
    kDataWidth => 1)
    PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_USBSTS_URI_iData,
       oData => a_USBSTS_URI_Vector,
       iPush => u_USBSTS_URI_iPush,
       iRdy => u_USBSTS_URI_iRdy,
       oAck => a_USBSTS_URI_oValid,
       oValid => a_USBSTS_URI_oValid,
       aReset => not_axi_resetn
    ); 
    a_USBSTS_URI_oData <= a_USBSTS_URI_Vector(0);           
--------------------------------------------------------------------------------------------------------------------------------------     
   
   u_Port_Change_Detect <= u_Wake or u_Set_Mode_HS or u_Set_Mode_FS;
   
   USBSTS_PCI_PROC: process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_USBSTS_PCI_iData <= "0";
            u_USBSTS_PCI_iPush <= '0';
         else
            if (u_Port_Change_Detect = '1' and u_USBSTS_PCI_iRdy = '1') then --resume signaling or port enters high speed or full speed mode
                u_USBSTS_PCI_iData <= "1";
                u_USBSTS_PCI_iPush <= '1';
            else
                u_USBSTS_PCI_iPush <= '0';
            end if;              
        end if;
      end if;  
   end process;   

    USBSTS_wr_en_PCI_PROC : process (Axi_Clk)
    begin
        if (Axi_Clk'event and Axi_Clk = '1') then
           if (axi_resetn = '0') then 
              a_USBSTS_PCI_Wr_En <= '0';
              a_USBSTS_PCI_Wr_En_q <= '0';
           else
             a_USBSTS_PCI_Wr_En_q <= a_USBSTS_PCI_oValid;
             a_USBSTS_PCI_Wr_En <= a_USBSTS_PCI_oValid and (not a_USBSTS_PCI_Wr_En_q); 
           end if;
        end if;              
    end process;         
            
   Inst_HandshakeData_PCI : entity work.HandshakeData  
   GENERIC MAP (
   kDataWidth => 1)
   PORT MAP(
      InClk => Ulpi_Clk,
      OutClk => Axi_Clk,
      iData => u_USBSTS_PCI_iData,
      oData => a_USBSTS_PCI_Vector,
      iPush => u_USBSTS_PCI_iPush,
      iRdy => u_USBSTS_PCI_iRdy,
      oAck => a_USBSTS_PCI_oValid,
      oValid => a_USBSTS_PCI_oValid,
      aReset => not_axi_resetn
   );
   a_USBSTS_PCI_oData <= a_USBSTS_PCI_Vector(0);      
------------------------------------------------------------------------------------------------------------------------------------------   
   URESEND_IDATA_PROC: process (Ulpi_Clk)
        begin
           if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
              if (reset = '0') then
                 u_Resend_iData <= (others => '0');
                 u_Resend_iPush <= '0';
              else
                 if (u_Resend_Set = '1' and u_Resend_iRdy = '1') then --resume signaling or port enters high speed or full speed mode
                     u_Resend_iData(pe_endpt_nr_index) <= '1';
                     u_Resend_iPush <= '1';
                 else
                     u_Resend_iPush <= '0';
                     u_Resend_iData <= (others => '0');
                 end if;              
             end if;
           end if;  
    end process;   

 RESEND_WR_EN_PROC : process (Axi_Clk)
 begin
     if (Axi_Clk'event and Axi_Clk = '1') then
        if (axi_resetn = '0') then 
           a_Resend_Wr_En <= '0';
           a_Resend_Wr_En_q <= '0';
        else
          a_Resend_Wr_En_q <= a_Resend_oValid;
          a_Resend_Wr_En <= a_Resend_oValid and (not a_Resend_Wr_En_q); 
        end if;
     end if;              
 end process;         
         
    Inst_HandshakeData_Resend : entity work.HandshakeData  
    GENERIC MAP (
    kDataWidth => 32)
    PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_Resend_iData,
       oData => a_Resend_oData,
       iPush => u_Resend_iPush,
       iRdy => u_Resend_iRdy,
       oAck => a_Resend_oValid,
       oValid => a_Resend_oValid,
       aReset => not_axi_resetn
    );
------------------------------------------------------------------------------------------------------------------------------------------
   PORTSC1_PSPD_PROC: process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            u_PORTSC1_iData <= "00";
            u_PORTSC1_iPush <= '0';
         else
            if (u_Not_Connected = '1') then
                if (u_Not_Connected_Pulse = '1' and u_PORTSC1_iRdy = '1') then
                    u_PORTSC1_iData <= "11";
                    u_PORTSC1_iPush <= '1';
                end if;    
            else
                if (u_Set_Mode_HS = '1' and u_PORTSC1_iRdy = '1') then
                    u_PORTSC1_iData <= "10";
                    u_PORTSC1_iPush <= '1';
                elsif (u_Set_Mode_FS = '0' and u_Not_Connected = '0' and u_PORTSC1_iRdy = '1')then
                    u_PORTSC1_iData <= "01";  
                    u_PORTSC1_iPush <= '1';
                else
                    u_PORTSC1_iPush <= '0';
                end if;         
            end if;    
         end if;        
      end if;
   end process;        
        
   PORTSC1_PSPD_wr_en_PROC : process (Axi_Clk)
   begin
       if (Axi_Clk'event and Axi_Clk = '1') then
          if (axi_resetn = '0') then 
             a_PORTSC1_PSPD_Wr_En <= '0';
             a_PORTSC1_PSPD_Wr_En_q <= '0';
          else
            a_PORTSC1_PSPD_Wr_En_q <= a_PORTSC1_oValid;
            a_PORTSC1_PSPD_Wr_En <= a_PORTSC1_oValid and (not a_PORTSC1_PSPD_Wr_En_q); 
          end if;
       end if;              
   end process;
   
   Inst_HandshakeData_PORTSC1: entity work.HandshakeData  
   GENERIC MAP (
   kDataWidth => 2)
   PORT MAP(
       InClk => Ulpi_Clk,
       OutClk => Axi_Clk,
       iData => u_PORTSC1_iData,
       oData => a_PORTSC1_PSPD_oData,
       iPush => u_PORTSC1_iPush,
       iRdy => u_PORTSC1_iRdy,
       oAck => a_PORTSC1_oValid,
       oValid => a_PORTSC1_oValid,
       aReset => not_axi_resetn
   );  
          
    NOT_CONNECTED_PROC : process (Ulpi_Clk)
    begin
    if (Ulpi_Clk'event and Ulpi_Clk = '1') then
       if (reset = '0') then 
          u_Not_Connected_Pulse <= '0';
          u_Not_Connected_q <= '0';
       else
         u_Not_Connected_q <= u_Not_Connected;
         u_Not_Connected_Pulse <= u_Not_Connected and (not u_Not_Connected_q); 
       end if;
    end if;              
    end process;                                                          
                                    
end Behavioral;
