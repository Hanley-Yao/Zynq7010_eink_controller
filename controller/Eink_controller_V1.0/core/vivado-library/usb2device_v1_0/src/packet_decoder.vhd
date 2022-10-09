-------------------------------------------------------------------------------
--
-- File: Packet_Decoder.vhd
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
-- This module implements chapter 8 of the USB protocol
--  
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Packet_Decoder is
    Port ( Ulpi_Clk : in STD_LOGIC;
           reset : in STD_LOGIC; 
           Axi_Resetn : IN STD_LOGIC;
           Axi_Clk : IN STD_LOGIC;            
           -- Transmit FIFO interface
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
           --Receive FIFO interface
           u_Rx_Fifo_s_Aclk : OUT std_logic;
           u_Rx_Fifo_s_Axis_Tready : IN std_logic;
           u_Rx_Fifo_s_Axis_Tvalid : OUT std_logic;
           u_Rx_Fifo_s_Axis_Tdata : OUT std_logic_vector(31 downto 0);
           u_Rx_Fifo_s_Axis_Tkeep : OUT std_logic_vector (3 downto 0);
           u_Rx_Fifo_s_Axis_Tlast : OUT std_logic;
           u_Rx_Fifo_Axis_Overflow : IN std_logic;
           u_Rx_Fifo_Axis_Underflow : IN std_logic;
           
           --Command FIFO(used to keep track of OUT packets) interface
           u_Command_Fifo_Rd_En : IN std_logic;
           u_Command_Fifo_Dout  : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
           u_Command_Fifo_Empty : OUT std_logic;
           u_Command_Fifo_Valid : OUT std_logic;
           
           --Setup packets are stored in these registers before being copied into the dQH
           u_Setup_Buffer_Bytes_3_0  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           u_Setup_Buffer_Bytes_7_4  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           --ULPI state machine interace
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
           
           --Status registers used by the DMA_Transfer_Manager block or by the Control_Register Block
           u_Setup_Received : OUT std_logic;
           u_Setup_Received_Rst : in std_logic;
           u_In_Token_Received : OUT std_logic;
           u_Send_Zero_Length_Packet_Ack_Set : OUT STD_LOGIC;
           u_Send_Zero_Length_Packet_Clear : OUT STD_LOGIC;
           u_Send_Zero_Length_Packet : in STD_LOGIC;
           u_In_Packet_Complete : OUT std_logic;
           u_In_Packet_Complete_Rst : IN std_logic; 
           u_Endp_Nr  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); 
           u_iPush_Endpt_Nr_PD : OUT STD_LOGIC;          
           u_NAK_Sent : out STD_LOGIC;
           u_Frame_Index : out STD_LOGIC_VECTOR (10 downto 0);
           u_SOF_Received : out STD_LOGIC;
           u_Resend_Set : out STD_LOGIC;
           u_Cnt_Bytes_Sent : out std_logic_vector(12 downto 0);
           u_Cnt_Bytes_Sent_Latch : out STD_LOGIC;
           
           --Input ontrol registers sourced by the Control_registers block 
           u_USBADRA : in STD_LOGIC_VECTOR (7 downto 0); 
           u_Endp_Type : in STD_LOGIC_VECTOR(1 downto 0);
           u_Endp_Stall : IN STD_LOGIC;       
           
           axis_32_to_8_latency_comp_out_port : out STD_LOGIC;
           ulpi_latency_comp_out : in STD_LOGIC;
           state_ind_pd : out STD_LOGIC_VECTOR(6 downto 0);
           packet_err : out STD_LOGIC
           
         );
end Packet_Decoder;

architecture Behavioral of Packet_Decoder is

COMPONENT crc5 
  PORT ( 
        data_in : in std_logic_vector (10 downto 0);
--        crc_en , rst, clk : in std_logic;
        crc_out : out std_logic_vector (4 downto 0)
        );
END COMPONENT;
     
COMPONENT crc16 
  PORT ( 
        data_in : in std_logic_vector (7 downto 0);
        crc_en , rst, clk : in std_logic;
        crc_out_res : out std_logic_vector (15 downto 0);
        crc_out : out std_logic_vector (15 downto 0)
        );        
END COMPONENT;

--receives data through the DMA controller; implements a 1KB buffer in BRAM for each endpoint
--provides data to the ULPI block on demand from the Packet_Decoder state machine
COMPONENT Transmit_Path
  PORT (
        Axi_Resetn : IN STD_LOGIC;
        Axi_Clk : IN STD_LOGIC;
        Ulpi_Clk : in  STD_LOGIC;
        u_Resetn : IN STD_LOGIC;
    
        u_PE_Endpt_Nr: in std_logic_vector(4 downto 0);
        a_Arb_Endpt_Nr : in std_logic_vector(4 downto 0);     
      
        Tx_Fifo_S_Aresetn : IN STD_LOGIC;
        a_Tx_Fifo_S_Aclk : IN STD_LOGIC;
        a_Tx_Fifo_S_Axis_Tvalid : IN STD_LOGIC;
        a_Tx_Fifo_S_Axis_Tready : OUT STD_LOGIC;
        a_Tx_Fifo_S_Axis_Tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        a_Tx_Fifo_S_Axis_Tlast : IN STD_LOGIC;
        a_Tx_Fifo_S_Axis_Tkeep : IN std_logic_vector(3 downto 0);
        a_Tx_Fifo_S_Axis_Tuser : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    
        u_Send_Packet : in STD_LOGIC;
        u_Tx_Data_En : in STD_LOGIC;
        u_Tx_Data : out STD_LOGIC_VECTOR(7 downto 0);
        u_Send_Packet_Last : out STD_LOGIC;
        u_Endpt_Ready : out STD_LOGIC;
        latency_comp_in : in STD_LOGIC;
        latency_comp_out : out STD_LOGIC;
        tx_fifo_axis_overflow : OUT STD_LOGIC;
        tx_fifo_axis_underflow : OUT STD_LOGIC
        ); 
END COMPONENT;

--buffers data received over yhe ULPI bus. OUT packets are stored in a FIFO,
--SETUP data follows a different path. OUT transactions are not currently working
COMPONENT Receive_Path
  PORT (
      Ulpi_Clk : in STD_LOGIC;
      Axi_Clk : IN std_logic;
      reset : in STD_LOGIC;
      
      --RX FIFO STREAM INTERFACE
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
      u_Setup_Buffer_Bytes_3_0_Loc  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);             
      
      u_Device_Addr : IN STD_LOGIC_VECTOR (6 downto 0);
      u_Fifo_Empty : OUT STD_LOGIC;
      --inputs from ULPI
      u_Rx_Data : in STD_LOGIC_VECTOR(7 downto 0);
      u_Ulpi_Dir_Out : in  STD_LOGIC;
      
      --inputs from FSM 
      u_Store_Packet : in STD_LOGIC;
      u_Store_Packet_State : in STD_LOGIC;
      u_End_Packet_Set : in STD_LOGIC;
      u_Fifo_Write_Toggle_Set : in STD_LOGIC;
      u_Fifo_Write_Toggle_Rst : in STD_LOGIC;
      u_Fifo_Rst_q : in STD_LOGIC;
      u_Input_Buffer_Loaded_Rst : in STD_LOGIC;
      u_Accept_Setup_Data_Set : in STD_LOGIC;      
      u_Accept_Data_Set : in STD_LOGIC;
      
      u_Setup_Received_Set : OUT std_logic;
      u_Input_CR16 : OUT std_logic_vector(15 downto 0)
  );
END COMPONENT;

constant CONTROL	:	STD_LOGIC_VECTOR (1 downto 0) := "00";
constant BULK	:	STD_LOGIC_VECTOR (1 downto 0) := "10";
constant ISOCHRONOUS	:	STD_LOGIC_VECTOR (1 downto 0) := "01";
constant INTERRUPT	:	STD_LOGIC_VECTOR (1 downto 0) := "11";

constant PID_OUT	:	STD_LOGIC_VECTOR (3 downto 0) := "0001";
constant PID_IN   	:	STD_LOGIC_VECTOR (3 downto 0) := "1001";
constant PID_SOF	:	STD_LOGIC_VECTOR (3 downto 0) := "0101";
constant PID_SETUP	:	STD_LOGIC_VECTOR (3 downto 0) := "1101";
constant PID_DATA0	:	STD_LOGIC_VECTOR (3 downto 0) := "0011";
constant PID_DATA1	:	STD_LOGIC_VECTOR (3 downto 0) := "1011";
constant PID_DATA2	:	STD_LOGIC_VECTOR (3 downto 0) := "0111";
constant PID_MDATA	:	STD_LOGIC_VECTOR (3 downto 0) := "1111";
constant PID_ACK	:	STD_LOGIC_VECTOR (3 downto 0) := "0010";
constant PID_NAK	:	STD_LOGIC_VECTOR (3 downto 0) := "1010";
constant PID_STALL	:	STD_LOGIC_VECTOR (3 downto 0) := "1110";
constant PID_NYET	:	STD_LOGIC_VECTOR (3 downto 0) := "0110";
constant PID_PRE	:	STD_LOGIC_VECTOR (3 downto 0) := "1100";
constant PID_ERR	:	STD_LOGIC_VECTOR (3 downto 0) := "1100";
constant PID_SPLIT	:	STD_LOGIC_VECTOR (3 downto 0) := "1000";
constant PID_PING	:	STD_LOGIC_VECTOR (3 downto 0) := "0100";

constant TIMEOUT	:	INTEGER  := 100;

type state_type is (IDLE, IGNORE_PACKET, TOKEN, STORE_PACKET_STATE, CHECK_TOKEN_PID, DECODE_PID,WAIT_DATA_PID, PL_TOP, ERROR, DEV_DO_BCINTO_SOF, DEV_DO_ISCHO, DEV_DO_BCINTO, DEV_DO_BCO, DEV_DO_BCINTI, DEV_DO_ISOCHI, DEV_DO_HSPING, DCHPKT2, DOPKT, DSPACE, DDO_IODATA, D_DO_IINEXT, DEV_RESP, DEV_DO_BCINTI_PACKET, DEV_DO_BCINTI_ZERO_LENGTH, DEV_DO_BCINTI_NAK, DEV_DO_BCINTI_STALL, DEV_DO_BCINTO_CHECK_PID, SEND_CRC16_1, SEND_CRC16_2, SEND_CRC16_END); 
signal state, next_state : state_type;

signal u_Token_Byte1 : STD_LOGIC_VECTOR(7 downto 0);
signal u_Token_Byte2 : STD_LOGIC_VECTOR(7 downto 0);
signal u_Token_Byte1_Latch : STD_LOGIC;
signal u_Token_Byte2_Latch : STD_LOGIC;
signal u_Endp_Field : STD_LOGIC_VECTOR(3 downto 0);
signal u_PID_Field : STD_LOGIC_VECTOR(3 downto 0);
signal u_PID_Field_Latch : STD_LOGIC;
signal u_Token_PID : STD_LOGIC_VECTOR(3 downto 0);
signal u_Token_PID_Latch : STD_LOGIC;
signal u_Device_Address : STD_LOGIC_VECTOR (6 downto 0);
signal u_DEVICEADDR : STD_LOGIC_VECTOR (6 downto 0);
signal u_Endp_Nr_Latch : STD_LOGIC;
signal u_Endp_Nr_Loc  :  STD_LOGIC_VECTOR(4 DOWNTO 0);

signal u_CRC16_Field : STD_LOGIC_VECTOR (15 downto 0);
signal u_CRC5_Field : STD_LOGIC_VECTOR(4 downto 0);
signal u_Tx_Data_En_q : STD_LOGIC;
--Buffer Control
signal u_Fifo_Write_Toggle_Set : STD_LOGIC;
signal u_Fifo_Write_Toggle_Rst : STD_LOGIC;
signal u_Fifo_Rst : STD_LOGIC;
signal u_Fifo_Rst_q : STD_LOGIC;
signal u_Buffer_Available : STD_LOGIC;
signal u_Buffer_Available_Latch : STD_LOGIC;
signal u_Buffer_Empty : STD_LOGIC;
--Buffer_Load_Proc control signals
signal u_Store_Packet, u_Store_Packet_State : STD_LOGIC;
signal u_Input_Buffer_Loaded_Rst : STD_LOGIC;
signal u_End_Packet_Set : STD_LOGIC;
--Input_Buffer_Read_Proc
signal u_Accept_Data_Set : STD_LOGIC;
signal u_Accept_Setup_Data_Set : STD_LOGIC;
--auxiliary signals
signal u_Tx_Data_Loc : STD_LOGIC_VECTOR(7 downto 0);
signal u_In_Token_Received_Fsm, u_In_Token_Received_Fsm_q, u_In_Token_Received_Fsm_qq :  std_logic;
signal u_Data_Pid_Sync, u_Data_Pid_Sync_Tx : STD_LOGIC_VECTOR (3 downto 0);
signal u_Data_Sync_Toggle, u_Data_Sync_Toggle_Tx  : STD_LOGIC;
signal u_Data_Sync_Toggle_Rst, u_Data_Sync_Toggle_Rst_Tx  : STD_LOGIC;
signal u_Frame_Index_Latch : STD_LOGIC;
signal u_Cnt_Bytes_Sent_Loc : STD_LOGIC_VECTOR(12 downto 0);
signal u_Cnt_Bytes_Sent_Rst : STD_LOGIC;
signal u_Setup_Buffer_Bytes_3_0_Loc : STD_LOGIC_VECTOR(31 downto 0);
signal u_Setup_Buffer_Bytes_3_0_Inversed : STD_LOGIC_VECTOR(31 downto 0);
signal u_Setup_Buffer_Bytes_7_4_Inversed : STD_LOGIC_VECTOR(31 downto 0);
signal u_Setup_Received_Set : STD_LOGIC;
signal u_Resend_Set_Fsm : STD_LOGIC;
signal u_Cnt_Timeout_CE : STD_LOGIC; 
signal u_Cnt_Timeout_Rst : STD_LOGIC; 
signal u_Cnt_Timeout : integer range 0 to 500; 
--Output Path
signal u_Send_Packet : STD_LOGIC;
signal Transmit_Path_rst : STD_LOGIC;
signal u_Send_Packet_Last, u_Endpt_Ready : STD_LOGIC;
signal u_In_Packet_Complete_Set : STD_LOGIC;
signal axis_32_to_8_latency_comp_out : STD_LOGIC;
signal u_BRAM_Read_Data : STD_LOGIC_VECTOR(7 downto 0);
--CRC
signal u_CRC16_Input_Mux : STD_LOGIC;
signal u_CRC5_Data_In : STD_LOGIC_VECTOR(10 downto 0);
signal u_CRC5_Output : STD_LOGIC_VECTOR(4 downto 0);
signal u_CRC16_Rst : STD_LOGIC;
signal u_CRC16_Rst_Fsm : STD_LOGIC;
signal u_CRC16_En : STD_LOGIC;
signal u_CRC16_Data_In : STD_LOGIC_VECTOR(7 downto 0);
signal u_CRC16_Data_In_Inversed : STD_LOGIC_VECTOR(7 downto 0);
signal u_CRC16_Output : STD_LOGIC_VECTOR(15 downto 0);
signal u_CRC16_Residual :  std_logic_vector (15 downto 0);
--Device address change from software
signal u_Inhibit : std_logic;  
signal u_New_Deviceaddr : std_logic_vector(6 downto 0);
signal u_In_ACK, u_In_ACK_q : std_logic;
signal u_Advance : std_logic;

attribute mark_debug : string;
attribute keep : string;

--attribute mark_debug of u_Endp_Field  : signal is "true";
--attribute keep of u_Endp_Field : signal is "true";
--attribute mark_debug of u_Device_Address  : signal is "true";
--attribute keep of u_Device_Address : signal is "true";
--attribute mark_debug of u_CRC5_Field  : signal is "true";
--attribute keep of u_CRC5_Field : signal is "true";
--attribute mark_debug of u_DEVICEADDR  : signal is "true";
--attribute keep of u_DEVICEADDR : signal is "true";
--attribute mark_debug of u_Setup_Buffer_Bytes_3_0_Inversed  : signal is "true";
--attribute keep of u_Setup_Buffer_Bytes_3_0_Inversed : signal is "true";
--attribute mark_debug of u_Setup_Buffer_Bytes_7_4_Inversed  : signal is "true";
--attribute keep of u_Setup_Buffer_Bytes_7_4_Inversed : signal is "true"; 
--attribute mark_debug of u_Setup_Received_Set  : signal is "true";
--attribute keep of u_Setup_Received_Set : signal is "true";
--attribute mark_debug of u_Setup_Received  : signal is "true";
--attribute keep of u_Setup_Received : signal is "true";
--attribute mark_debug of u_Setup_Received_Rst  : signal is "true";
--attribute keep of u_Setup_Received_Rst : signal is "true";
--attribute mark_debug of u_Cnt_Bytes_Sent  : signal is "true";
--attribute keep of u_Cnt_Bytes_Sent : signal is "true";
--attribute mark_debug of u_Endpt_Ready  : signal is "true";
--attribute keep of u_Endpt_Ready : signal is "true";
--attribute mark_debug of u_Tx_Data_Loc  : signal is "true";
--attribute keep of u_Tx_Data_Loc : signal is "true";
--attribute mark_debug of u_Tx_Data_En  : signal is "true";
--attribute keep of u_Tx_Data_En : signal is "true";
--attribute mark_debug of u_Send_Last  : signal is "true";
--attribute keep of u_Send_Last : signal is "true";
--attribute mark_debug of u_CRC16_Output  : signal is "true";
--attribute keep of u_CRC16_Output : signal is "true";
--attribute mark_debug of u_In_Packet_Complete_Rst  : signal is "true";
--attribute keep of u_In_Packet_Complete_Rst : signal is "true";
--attribute mark_debug of u_In_Packet_Complete  : signal is "true";
--attribute keep of u_In_Packet_Complete : signal is "true";
--attribute mark_debug of u_In_Packet_Complete_Set  : signal is "true";
--attribute keep of u_In_Packet_Complete_Set : signal is "true"; 
--attribute mark_debug of u_Resend_Set_Fsm  : signal is "true";
--attribute keep of u_Resend_Set_Fsm : signal is "true"; 
--attribute mark_debug of u_Cnt_Timeout  : signal is "true";
--attribute keep of u_Cnt_Timeout : signal is "true";
--attribute mark_debug of u_BRAM_Read_Data  : signal is "true";
--attribute keep of u_BRAM_Read_Data : signal is "true"; 

--attribute mark_debug of u_Data_Pid_Sync  : signal is "true";
--attribute keep of u_Data_Pid_Sync : signal is "true"; 
--attribute mark_debug of u_Data_Sync_Toggle  : signal is "true";
--attribute keep of u_Data_Sync_Toggle : signal is "true"; 
--attribute mark_debug of u_Data_Sync_Toggle_Rst  : signal is "true";
--attribute keep of u_Data_Sync_Toggle_Rst : signal is "true"; 
  
begin
axis_32_to_8_latency_comp_out_port <= axis_32_to_8_latency_comp_out;
u_Tx_Data <= u_Tx_Data_Loc;
u_Endp_Nr <= u_Endp_Nr_Loc;
u_CRC5_Data_In <= u_Token_Byte1(0) & u_Token_Byte1(1) & u_Token_Byte1(2) & u_Token_Byte1(3) & u_Token_Byte1(4) & u_Token_Byte1(5) & u_Token_Byte1(6) & u_Token_Byte1(7) & u_Token_Byte2(0) & u_Token_Byte2(1) & u_Token_Byte2(2);
u_CRC16_Data_In <= u_Rx_Data when u_CRC16_Input_Mux = '1' else u_Tx_Data_Loc;
u_CRC16_Rst <= reset and u_CRC16_Rst_Fsm;
u_Advance <= u_USBADRA(0);


TX_DATA_EN_DELAY_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Tx_Data_En_q <= '0';
            else
                u_Tx_Data_En_q <= u_Tx_Data_En;           
            end if;
        end if;   
end process;   

u_Setup_Buffer_Bytes_3_0(7 downto 0)   <=  u_Setup_Buffer_Bytes_3_0_Inversed(31 downto 24);
u_Setup_Buffer_Bytes_3_0(15 downto 8)  <=  u_Setup_Buffer_Bytes_3_0_Inversed(23 downto 16);
u_Setup_Buffer_Bytes_3_0(23 downto 16) <=  u_Setup_Buffer_Bytes_3_0_Inversed(15 downto 8);
u_Setup_Buffer_Bytes_3_0(31 downto 24) <=  u_Setup_Buffer_Bytes_3_0_Inversed(7 downto 0);
u_Setup_Buffer_Bytes_7_4(7 downto 0)   <=  u_Setup_Buffer_Bytes_7_4_Inversed(31 downto 24);
u_Setup_Buffer_Bytes_7_4(15 downto 8)  <=  u_Setup_Buffer_Bytes_7_4_Inversed(23 downto 16);
u_Setup_Buffer_Bytes_7_4(23 downto 16) <=  u_Setup_Buffer_Bytes_7_4_Inversed(15 downto 8);
u_Setup_Buffer_Bytes_7_4(31 downto 24) <=  u_Setup_Buffer_Bytes_7_4_Inversed(7 downto 0);

u_CRC16_Data_In_Inversed(0) <= u_CRC16_Data_In(7);
u_CRC16_Data_In_Inversed(1) <= u_CRC16_Data_In(6);
u_CRC16_Data_In_Inversed(2) <= u_CRC16_Data_In(5);
u_CRC16_Data_In_Inversed(3) <= u_CRC16_Data_In(4);
u_CRC16_Data_In_Inversed(4) <= u_CRC16_Data_In(3);
u_CRC16_Data_In_Inversed(5) <= u_CRC16_Data_In(2);
u_CRC16_Data_In_Inversed(6) <= u_CRC16_Data_In(1);
u_CRC16_Data_In_Inversed(7) <= u_CRC16_Data_In(0);

crc5_1 : crc5 
  PORT MAP ( 
        data_in => u_CRC5_Data_In,
        crc_out => u_CRC5_Output
        );
        
crc16_1 : crc16 
  PORT MAP ( 
        clk => Ulpi_Clk,
        rst => u_CRC16_Rst,
        data_in => u_CRC16_Data_In_Inversed, -- data is registered once in ULPI block. data_in must correspond to tx_data_r in ULPI block
        crc_en => u_CRC16_En,
        crc_out_res => u_CRC16_Residual,
        crc_out => u_CRC16_Output
        );     
  
Inst_Receive_Path : Receive_Path
  PORT MAP (
        Ulpi_Clk => Ulpi_Clk,
        Axi_Clk => Axi_Clk,
        reset => reset,
        
        u_Rx_Fifo_s_Aclk => u_Rx_Fifo_s_Aclk,
        u_Rx_Fifo_s_Axis_Tready => u_Rx_Fifo_s_Axis_Tready,
        u_Rx_Fifo_s_Axis_Tvalid => u_Rx_Fifo_s_Axis_Tvalid,
        u_Rx_Fifo_s_Axis_Tdata => u_Rx_Fifo_s_Axis_Tdata,
        u_Rx_Fifo_s_Axis_Tkeep => u_Rx_Fifo_s_Axis_Tkeep,
        u_Rx_Fifo_s_Axis_Tlast => u_Rx_Fifo_s_Axis_Tlast,
        u_Rx_Fifo_Axis_Overflow => u_Rx_Fifo_Axis_Overflow,
        u_Rx_Fifo_Axis_Underflow => u_Rx_Fifo_Axis_Underflow, 
        u_Command_Fifo_Rd_En => u_Command_Fifo_Rd_En,
        u_Command_Fifo_Dout => u_Command_Fifo_Dout,
        u_Command_Fifo_Empty => u_Command_Fifo_Empty,
        u_Command_Fifo_Valid => u_Command_Fifo_Valid,
                  
        u_Setup_Buffer_Bytes_3_0 => u_Setup_Buffer_Bytes_3_0_Inversed,
        u_Setup_Buffer_Bytes_7_4 => u_Setup_Buffer_Bytes_7_4_Inversed,
        u_Setup_Buffer_Bytes_3_0_Loc => u_Setup_Buffer_Bytes_3_0_Loc,          
        
        u_Device_Addr => u_Device_Address,
        u_Fifo_Empty => u_Buffer_Empty,
        
        u_Rx_Data => u_Rx_Data,
        u_Ulpi_Dir_Out => u_Ulpi_Dir_Out,
        
        u_Store_Packet => u_Store_Packet,
        u_Store_Packet_State => u_Store_Packet_State,
        u_End_Packet_Set => u_End_Packet_Set,
        u_Fifo_Write_Toggle_Set => u_Fifo_Write_Toggle_Set,
        u_Fifo_Write_Toggle_Rst => u_Fifo_Write_Toggle_Rst,
        u_Fifo_Rst_q => u_Fifo_Rst_q,
        u_Input_Buffer_Loaded_Rst => u_Input_Buffer_Loaded_Rst,             
        u_Accept_Data_Set => u_Accept_Data_Set,
        u_Accept_Setup_Data_Set => u_Accept_Setup_Data_Set,
                                    
        u_Setup_Received_Set => u_Setup_Received_Set,
        u_Input_CR16 => u_CRC16_Field
        );          

    Transmit_Path_rst <= reset and u_Cnt_Bytes_Sent_Rst;

	Inst_Transmit_Path: Transmit_Path PORT MAP(
		Axi_Resetn => Axi_Resetn,
        Axi_Clk => Axi_Clk,
        Ulpi_Clk => Ulpi_Clk,
        u_Resetn => reset,
    
        u_PE_Endpt_Nr => u_Endp_Nr_Loc,
        a_Arb_Endpt_Nr => a_Arb_Endpt_Nr,   
      
        Tx_Fifo_S_Aresetn => Tx_Fifo_S_Aresetn,
        a_Tx_Fifo_S_Aclk => a_Tx_Fifo_S_Aclk,
        a_Tx_Fifo_S_Axis_Tvalid => a_Tx_Fifo_S_Axis_Tvalid,
        a_Tx_Fifo_S_Axis_Tready => a_Tx_Fifo_S_Axis_Tready,
        a_Tx_Fifo_S_Axis_Tdata => a_Tx_Fifo_S_Axis_Tdata,
        a_Tx_Fifo_S_Axis_Tlast => a_Tx_Fifo_S_Axis_Tlast,
        a_Tx_Fifo_S_Axis_Tkeep => a_Tx_Fifo_S_Axis_Tkeep,
        a_Tx_Fifo_S_Axis_Tuser => a_Tx_Fifo_S_Axis_Tuser,
    
        u_Send_Packet => u_Send_Packet,
        u_Tx_Data_En => u_Tx_Data_En,
        u_Tx_Data => u_BRAM_Read_Data,
        u_Send_Packet_Last => u_Send_Packet_Last,
        u_Endpt_Ready => u_Endpt_Ready,
        latency_comp_in => u_Send_Packet,
        latency_comp_out => axis_32_to_8_latency_comp_out,
        tx_fifo_axis_overflow => tx_fifo_axis_overflow,
        tx_fifo_axis_underflow => tx_fifo_axis_underflow
	);	

--u_In_Token_Received is a pulse that signals to upper layers an IN token was detected      
IN_TOKEN_SET_DELAY_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_In_Token_Received <= '0';
                u_In_Token_Received_Fsm_q <= '0';
                u_In_Token_Received_Fsm_qq <= '0';
            else
                u_In_Token_Received_Fsm_q <= u_In_Token_Received_Fsm;    
                u_In_Token_Received_Fsm_qq <= u_In_Token_Received_Fsm_q;  
                u_In_Token_Received <= u_In_Token_Received_Fsm_q and (not u_In_Token_Received_Fsm_qq);   
            end if;
        end if;   
end process;    
  
--  u_Buffer_Available used to generate a NAK on response to OUT tokens in case the input buffer is full  
SPACE_AVAIL_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Buffer_Available <= '0';
            elsif (u_Buffer_Available_Latch = '1') then
                u_Buffer_Available <= u_Buffer_Empty;               
            end if;
        end if;   
end process; 
  
--u_Fifo_Rst_q used to reset the input buffer in case the data received has an invalid CRC    
RESET_BUFFER_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Fifo_Rst_q <= '0';
            else
                if (u_Fifo_Rst = '1') then
                    u_Fifo_Rst_q <= '1';
                else
                    u_Fifo_Rst_q <= '0';
                end if;                
            end if;
        end if;   
end process;   

--this process decodes token packets
TOCKEN_DECODE_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_PID_Field <=  (others => '0');
                u_Token_Byte1 <= (others => '0');
                u_Token_Byte2 <= (others => '0'); 
            else
                --state_ind_pd_r <= state_ind_pd;
                if (u_PID_Field_Latch = '1') then
                    u_PID_Field <= u_Rx_Data(3 downto 0);
                elsif (u_Token_Byte1_Latch = '1') then
                    u_Token_Byte1 <= u_Rx_Data;
                elsif (u_Token_Byte2_Latch = '1') then
                    u_Token_Byte2 <= u_Rx_Data;   
                end if;
            end if;
        end if;   
end process;

--Frame index is obtained from SOF packets. Frame index is stored into a register
--in the Control_registers block   
FRAME_INDEX_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Frame_Index <= (others => '0');
                u_SOF_Received <= '0'; 
            else
                if (u_Frame_Index_Latch = '1') then
                    u_Frame_Index(7 downto 0) <= u_Rx_Data;
                    u_SOF_Received <= '0';
                elsif (u_Token_Byte2_Latch = '1') then
                    u_Frame_Index(10 downto 8) <= u_Rx_Data(2 downto 0);   
                    u_SOF_Received <= '1';
                else
                    u_SOF_Received <= '0';    
                end if;
            end if;
        end if;   
end process;    
  
--register the incoming token PID   
TOKEN_PID_Q_PROC: process (Ulpi_Clk)
    begin
       if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
          if (reset = '0') then
             u_Token_PID <= (others => '0');
          elsif (u_Token_PID_Latch = '1') then
             u_Token_PID <= u_PID_Field;
          end if;        
       end if;
end process;      

u_Device_Address <= u_Token_Byte1(6 downto 0);
u_Endp_Field <= u_Token_Byte2(2 downto 0) & u_Token_Byte1(7);
u_CRC5_Field(0) <= u_Token_Byte2(3);
u_CRC5_Field(1) <= u_Token_Byte2(4);
u_CRC5_Field(2) <= u_Token_Byte2(5);
u_CRC5_Field(3) <= u_Token_Byte2(6);
u_CRC5_Field(4) <= u_Token_Byte2(7);

--signal to upper layers on which endpoint to take action
PE_ENDPT_NR_PROC: process (Ulpi_Clk)
    begin
          if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
             if (reset = '0') then
                u_Endp_Nr_Loc <= (others => '0');
                u_iPush_Endpt_Nr_PD <= '0';
             elsif (u_Endp_Nr_Latch = '1') then
                u_iPush_Endpt_Nr_PD <= '1';
                if (u_PID_Field = PID_SETUP or u_PID_Field = PID_OUT) then
                    u_Endp_Nr_Loc <= u_Endp_Field & '0';
                elsif (u_PID_Field = PID_IN) then
                    u_Endp_Nr_Loc <= u_Endp_Field & '1';
                end if;
             else
                u_iPush_Endpt_Nr_PD <= '0';   
             end if;        
          end if;
end process;

--Data synchronization
DATA_SYNC_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if ((reset = '0') or (u_Data_Sync_Toggle_Rst = '0')) then
                u_Data_Pid_Sync <= PID_DATA0;
            elsif (u_Data_Sync_Toggle = '1') then
                u_Data_Pid_Sync(3) <= not (u_Data_Pid_Sync(3));               
            end if;
        end if;   
end process;
    
--TX packets data synchronization    
DATA_SYNC_TX_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if ((reset = '0') or (u_Data_Sync_Toggle_Rst_Tx = '0')) then
                u_Data_Pid_Sync_Tx <= PID_DATA1;
            elsif (u_Data_Sync_Toggle_Tx = '1') then
                u_Data_Pid_Sync_Tx(3) <= not (u_Data_Pid_Sync_Tx(3));               
            end if;
        end if;   
end process;                  

--indicate a SETUP packet was received
SETUP_RECEIVED_PROC: process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0' or u_Setup_Received_Rst = '0') then
            u_Setup_Received <= '0';
         elsif (u_Setup_Received_Set = '1') then
            u_Setup_Received <= '1';
         end if;        
      end if;
end process;

--indicate an input transaction was completed succesfully   
PACKET_IN_COMPLETE_PROC: process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0' or u_In_Packet_Complete_Rst = '0') then
            u_In_Packet_Complete <= '0';
         elsif (u_In_Packet_Complete_Set = '1') then
            u_In_Packet_Complete <= '1';
         end if;        
      end if;
end process;  
 
--Counts packet bytes sent over the ULPI interface   
IN_PACKET_COUNTER_TMP_PROC: process (Ulpi_Clk)
   begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
           if (reset = '0' or u_Cnt_Bytes_Sent_Rst = '0') then
               u_Cnt_Bytes_Sent_Loc <= (others => '0');
           else
               if (u_Tx_Data_En = '1' and u_Send_Packet = '1') then
                   u_Cnt_Bytes_Sent_Loc <= std_logic_vector(unsigned(u_Cnt_Bytes_Sent_Loc)+1);
               end if;
           end if;        
       end if;
end process;  

U_IN_ACK_Q_PROC: process (Ulpi_Clk)
        begin
           if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
              if (reset = '0') then
                 u_In_ACK_q <= '0';  
              else
                 u_In_ACK_q <= u_In_ACK;  
              end if;        
           end if;
end process;
   
U_DEVICEADDR_UPDATE_PROC: process (Ulpi_Clk)
         begin
            if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
               if (reset = '0') then
                  u_DEVICEADDR <= (others => '0');
               else
                  if (u_Advance = '1') then
                      if (u_In_ACK_q = '1') then
                        u_DEVICEADDR <= u_USBADRA(7 downto 1); 
                      end if;  
                  else
                        u_DEVICEADDR <= u_USBADRA(7 downto 1);    
                  end if;   
               end if;        
            end if;
end process;

--monitors the host handshake response time for IN packets     
U_TIMEOUT_PROC: process (Ulpi_Clk)
          begin
             if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
                if ((reset = '0') or (u_Cnt_Timeout_Rst = '0'))then
                   u_Cnt_Timeout <= 0;
                else
                   if (u_Cnt_Timeout_CE = '1') then
                       if (u_Cnt_Timeout = 500) then
                           u_Cnt_Timeout <= 0; 
                       else
                           u_Cnt_Timeout <= u_Cnt_Timeout +1;    
                       end if;   
                   end if;   
                end if;        
             end if;
end process; 
  
--signals to upper layers that a packet needs to be resent     
U_RESEND_PROC: process (Ulpi_Clk)
      begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0')then
                u_Resend_Set <= '0';
            else
                u_Resend_Set <= u_Resend_Set_Fsm;
            end if;        
         end if;
end process;            

   u_Cnt_Bytes_Sent <= u_Cnt_Bytes_Sent_Loc;

--Chapter8 State Machines
SYNC_PROC: process (Ulpi_Clk)
   begin
      if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
         if (reset = '0') then
            state <= IDLE;
         else
            state <= next_state;
         end if;        
      end if;
end process;
 
NEXT_STATE_DECODE: process (state, u_Rx_Data, u_Inhibit, u_CRC5_Field, u_CRC16_Residual, u_PID_Field, u_Send_Zero_Length_Packet, u_Tx_Pid_Phase_Done, u_CRC16_En_Ulpi, u_Device_Address, u_DEVICEADDR, u_Rx_Packet_Received, u_CRC5_Output, u_CRC16_Output, u_Send_Packet_Last, u_Tx_Data_En, u_BRAM_Read_Data, u_USB_Mode, u_Token_PID, u_Buffer_Available, u_Endp_Type, u_Data_Pid_Sync, u_Tx_Cmd_Done, u_Endp_Stall, u_RxActive, u_RxEvent)
   begin
   next_state <= state;
   packet_err <= '0';
   u_PID_Field_Latch <= '0';
   u_Token_Byte1_Latch <= '0';
   u_Token_Byte2_Latch <= '0';
   u_Token_PID_Latch <= '0';
   u_Store_Packet <= '0';
   u_End_Packet_Set <= '0';
   u_Fifo_Rst <= '0';
   u_Accept_Data_Set <= '0';
   u_Send_PID_CMD <= '0';
   u_Send_Last <= '0';
   u_Tx_Data_Loc <= (others => '0');
   u_Tx_Pid <= (others => '0');
   
   u_Buffer_Available_Latch <= '0';
   u_In_Token_Received_Fsm <= '0';
   u_Fifo_Write_Toggle_Set <= '0';
   u_Fifo_Write_Toggle_Rst <= '1';
   u_Data_Sync_Toggle_Rst <= '1';
   u_Data_Sync_Toggle_Rst_Tx <= '1';
   u_Data_Sync_Toggle_Tx <= '0';
   u_Data_Sync_Toggle <= '0';
   u_Accept_Setup_Data_Set <= '0';
   u_Input_Buffer_Loaded_Rst <= '1';
   state_ind_pd <= "0000000";
   u_CRC16_En <= '0';
   u_CRC16_Input_Mux <= '0';
   u_Send_Packet <= '0';
   u_CRC16_Rst_Fsm <= '1';
   u_Cnt_Bytes_Sent_Rst <= '1';
   u_In_Packet_Complete_Set <= '0';
   u_NAK_Sent <= '0';
   u_Frame_Index_Latch <= '0';
   u_Endp_Nr_Latch <= '0';
   u_Cnt_Bytes_Sent_Latch <= '0';
   u_Send_Zero_Length_Packet_Ack_Set <= '0';
   u_Send_Zero_Length_Packet_Clear <= '0';
   u_Store_Packet_State <= '0';
   u_In_ACK <= '0';
   u_Cnt_Timeout_CE <= '0'; 
   u_Cnt_Timeout_Rst <= '0'; 
   u_Resend_Set_Fsm <= '0';
      
   case (state) is
         when IDLE =>
         u_CRC16_Rst_Fsm <= '0';
         state_ind_pd <= "0000001";
         u_CRC16_Input_Mux <= '1';
            if (u_Rx_Packet_Received = '1' and u_RxActive = '1' and u_RxEvent = "01") then --Packet data received over ULPI 
                if ((u_Rx_Data(3 downto 0) = PID_OUT) or (u_Rx_Data(3 downto 0) = PID_IN) or (u_Rx_Data(3 downto 0) = PID_SETUP) or (u_Rx_Data(3 downto 0) = PID_SOF))then --check for valid PID
                    u_PID_Field_Latch <= '1';
                    next_state <= DECODE_PID;
                else
                    next_state <= IGNORE_PACKET;    
                end if;
            end if;
            
         when IGNORE_PACKET =>
            if (u_RxEvent = "00") then
                next_state <= IDLE;
            end if; 
              
         when DECODE_PID =>
            state_ind_pd <= "0000010";
            if (((u_PID_Field = PID_OUT) or (u_PID_Field = PID_IN) or (u_PID_Field = pid_SETUP)) and (u_RxActive = '1' and u_RxEvent = "01"))then
                if(u_Rx_Packet_Received = '1') then --if this is a token, store the first byte 
                    u_Token_PID_Latch <= '1';
                    u_Token_Byte1_Latch <= '1'; 
                    u_CRC16_Input_Mux <= '1';               
                    if (u_PID_Field = PID_SOF) then 
                        u_Frame_Index_Latch <= '1';   
                    end if; 
                    next_state <= TOKEN;
                end if;        
            elsif ((u_PID_Field = PID_ACK) and (u_RxActive = '1' and u_RxEvent = "01")) then
                next_state <= IDLE;
            elsif ((u_PID_Field = PID_NAK) and (u_RxActive = '1' and u_RxEvent = "01")) then
                next_state <= IDLE;
                
            else
                packet_err <= '1';
                if (u_RxActive = '0' or u_RxEvent /= "01") then
                     next_state <= IDLE;
                end if;         
            end if;

         when TOKEN =>
         u_CRC16_Input_Mux <= '1'; 
         u_Input_Buffer_Loaded_Rst <= '0';
         u_Fifo_Write_Toggle_Rst <= '0';
         state_ind_pd <= "0000110";
            if (u_RxActive = '1' and u_RxEvent = "01") then
                if(u_Rx_Packet_Received = '1') then --if packet data is valid, store the second byte of the token
                    u_Token_Byte2_Latch <= '1';
                    if (u_PID_Field = PID_SOF) then
                        next_state <= IDLE;
                    else    
                        next_state <= CHECK_TOKEN_PID;
                    end if;      
                end if;        
            else
                packet_err <= '1';
                if (u_RxActive = '0' or u_RxEvent /= "01") then
                    next_state <= IDLE;
                end if;    
            end if;
         
         when CHECK_TOKEN_PID => --decide by which state machine the packet will be processed; if we are dealing with a SETUP/OUT packet, store it first
            state_ind_pd <= "0000111";
            if ((u_CRC5_Output = u_CRC5_Field) and (u_Device_Address = u_DEVICEADDR))  then --check CRC and device address
                if ((u_PID_Field = PID_OUT) or (u_PID_Field = pid_SETUP)) then
                    u_Endp_Nr_Latch <= '1';
                    if (u_PID_Field = pid_SETUP) then
                        u_Data_Sync_Toggle_Rst <= '0';
                        u_Data_Sync_Toggle_Rst_Tx <= '0';
                    end if;
                    next_state <= WAIT_DATA_PID;
                elsif (u_PID_Field = PID_IN) then 
                    u_Endp_Nr_Latch <= '1';
                    next_state <= PL_TOP; 
                elsif (u_USB_Mode = '1' and u_Token_PID = PID_PING) then --Dev_HS-ping
                    next_state <= DEV_DO_HSPING; 
                elsif (u_Token_PID = PID_SOF) then
                    next_state <= IDLE; 
                else
                    next_state <= IDLE;    
                end if;  
            else
                if (u_RxActive = '0') then
                    next_state <= IDLE;
                end if;    
            end if;   
            
         when WAIT_DATA_PID => --wait for incoming packet
         state_ind_pd <= "0001000";
            u_CRC16_Input_Mux <= '1'; 
            if (u_Rx_Packet_Received = '1' and u_RxActive = '1' and u_RxEvent = "01") then
                u_PID_Field_Latch <= '1';
                u_Buffer_Available_Latch <= '1';
                next_state <= STORE_PACKET_STATE;
            end if;
         
         when STORE_PACKET_STATE => 
            state_ind_pd <= "0001001";
            u_CRC16_Input_Mux <= '1';
            u_Store_Packet_State <= '1'; 
            if ( (u_Token_PID = PID_OUT) or (u_Token_PID = PID_SETUP) ) then                
                    if ((u_PID_Field = PID_DATA0) or (u_PID_Field = PID_DATA1) or (u_PID_Field = PID_DATA2) or (u_PID_Field = PID_MDATA) or (u_PID_Field = PID_SETUP)) then
                        if (u_Rx_Packet_Received = '1' and u_RxActive = '1' and u_RxEvent = "01") then --store data
                            u_CRC16_En <= '1'; 
                            if (u_Buffer_Available = '1') then  --if PID valid and space is available in the input buffer, store the packet
                                u_Store_Packet <= '1';   
                            end if;    
                        elsif (u_RxActive /= '1' or u_RxEvent /= "01") then --advance to next state when the packet has ended
                            u_End_Packet_Set <= '1';
                            next_state <= PL_TOP;
                        end if;
                    else
                        next_state <= ERROR;
                    end if;  
            else
                next_state <= PL_TOP;    
            end if;       
                           
         when PL_TOP => --decide by which state machine the packet will be processed
            state_ind_pd <= "0001010";
                if (u_Token_PID = PID_OUT or u_Token_PID = PID_SETUP) then --Device_Do_OUT
                    u_Send_Zero_Length_Packet_Clear <= '1';
                    if ((u_Token_PID = PID_SETUP) and u_Endp_Type /= CONTROL) then
                       next_state <= IDLE; --ABORT PACKET, take no action
                    elsif ((u_Token_PID = PID_SETUP and u_Endp_Type = CONTROL) or u_Token_PID = PID_OUT) then
                        if (u_Endp_Type = ISOCHRONOUS) then --Dev_Do_IschO
                            next_state <= DEV_DO_ISCHO;
                        elsif ((u_USB_Mode = '0' and (u_Endp_Type = CONTROL or u_Endp_Type = BULK)) or u_Endp_Type = INTERRUPT) then --Dev_Do-BCINTO
                            next_state <= DEV_DO_BCINTO;
                        elsif (u_USB_Mode = '1' and (u_Endp_Type = CONTROL or u_Endp_Type = BULK)) then --Dev_Do_BCO
                            next_state <= DEV_DO_BCO;
                        else  -- should not occur, undifined state
                            next_state <= IDLE;
                        end if;
                    else -- should not occur, undifined state
                        next_state <= IDLE; 
                    end if;
                elsif (u_Token_PID = PID_IN) then --Device_do_IN
                    u_CRC16_Rst_Fsm <= '0';
                    if (u_Endp_Type = CONTROL or u_Endp_Type = BULK or u_Endp_Type = INTERRUPT) then --Dev_Do_BCINTI
                        next_state <= DEV_DO_BCINTI;
                    elsif (u_Endp_Type = ISOCHRONOUS) then  --Dev_Do_IsochI 
                        next_state <= DEV_DO_ISOCHI;
                    end if;
                else --ABORT/IGNORE data
                    next_state <= IDLE;
                end if;
                
------------------------------------------------------------------------------------------------- 
---------- Dev_Do_BCINTO Not tested-------------------------------------------------------------------------           
          
        when DEV_DO_BCINTO =>
            state_ind_pd <= "0001011";
            if (u_Token_PID = PID_OUT and ((u_PID_Field = PID_DATA0) or (u_PID_Field = PID_DATA1) or (u_PID_Field = PID_DATA2) or (u_PID_Field = PID_MDATA))) then
                if (u_Data_Pid_Sync /= u_PID_Field and u_CRC16_Output = "0000000000000000") then --discard_data
                    u_Fifo_Write_Toggle_Set <= '0';            
                    u_Fifo_Rst <= '1';
                    next_state <= DOPKT;
                elsif (u_Data_Pid_Sync = u_PID_Field and u_CRC16_Output = "0000000000000000" and u_Buffer_Available = '1') then
                    u_Accept_Data_Set <= '1';--accept_data
                    u_Data_Sync_Toggle <= '1'; --toggle sequence bit
                    u_Fifo_Write_Toggle_Set <= '1';  
                    next_state <= DOPKT;
                elsif (u_Data_Pid_Sync = u_PID_Field and u_CRC16_Output = "0000000000000000" and u_Buffer_Available = '0') then
                    --issue NAK
                    u_Send_PID_CMD <= '1';
                    u_Tx_Pid <= PID_NAK;
                    u_Send_Last <= '1';
                    ----------
                    if (u_Tx_Cmd_Done = '1') then
                        u_NAK_Sent <= '1';
                        next_state <= IDLE;
                    end if;    
                elsif (u_Endp_Stall = '1') then
                    --issue STALL
                    u_Send_PID_CMD <= '1';
                    u_Tx_Pid <= PID_STALL;
                    u_Send_Last <= '1';
                    ---------------
                    u_Fifo_Rst <= '1';--reset FIFO
                    if (u_Tx_Cmd_Done = '1') then
                        next_state <= IDLE;
                    end if;
                end if;    
            elsif (u_Token_PID = PID_SETUP and u_PID_Field = PID_DATA0) then
                if (u_Buffer_Available = '0') then
                    next_state <= IDLE;
                elsif (u_Buffer_Available = '1' and u_CRC16_Output = "0000000000000000") then
                    u_Accept_Setup_Data_Set <= '1';
                    u_Data_Sync_Toggle <= '1'; --toggle sequence bit
                    u_Fifo_Write_Toggle_Set <= '1';
                    next_state <= DOPKT;
                else --invalid
                    u_Fifo_Rst <= '1';--reset FIFO
                    next_state <= IDLE;
                end if;
            else
                u_Fifo_Rst <= '1';--reset FIFO
                next_state <= IDLE;
            end if;
       
        when DOPKT =>
            state_ind_pd <= "0001100";
            --issue ACK
            u_Send_PID_CMD <= '1'; 
            u_Tx_Pid <= PID_ACK;
            u_Send_Last <= '1';
            ----------
            if (u_Tx_Cmd_Done = '1') then
                next_state <= IDLE;
            end if;            
            
-------------------------------------------------------------------------------------------------------------        
----------Dev_HS_BCO-----------------------------------------------------------------------------------------
        
        when DEV_DO_BCO =>
            --state_ind_pd <= "0001101";
            if (u_Token_PID = PID_OUT and ((u_PID_Field = PID_DATA0) or (u_PID_Field = PID_DATA1) or (u_PID_Field = PID_DATA2) or (u_PID_Field = PID_MDATA))) then
                state_ind_pd <= "0001101";
                if (u_Data_Pid_Sync = u_PID_Field and u_CRC16_Residual = "1000000000001101" and u_Buffer_Available = '0') then
                    --issue NAK                   
                    u_Send_PID_CMD <= '1';
                    u_Tx_Pid <= PID_NAK;
                    u_Send_Last <= '1';
                    ----------
                    u_Fifo_Rst <= '1';--reset FIFO
                    if (u_Tx_Cmd_Done = '1') then
                        u_NAK_Sent <= '1';
                        next_state <= IDLE;
                    end if;
                elsif (u_Data_Pid_Sync /= u_PID_Field and u_CRC16_Residual = "1000000000001101") then
                    --issue ACK
                    u_Send_PID_CMD <= '1';
                    u_Tx_Pid <= PID_ACK;
                    u_Send_Last <= '1';
                    ----------
                    u_Fifo_Rst <= '1';--reset FIFO
                    u_Fifo_Write_Toggle_Set <= '0';
                    if (u_Tx_Cmd_Done = '1') then
                        next_state <= IDLE;
                    end if;
                elsif (u_Data_Pid_Sync = u_PID_Field and u_CRC16_Residual = "1000000000001101" and u_Buffer_Available = '1') then
                    u_Accept_Data_Set <= '1';--accept_data
                    u_Data_Sync_Toggle <= '1'; --toggle sequence bit
                    u_Fifo_Write_Toggle_Set <= '1';
                    next_state <= DSPACE;
                elsif (u_Endp_Stall = '1') then
                    --issue STALL
                    u_Send_PID_CMD <= '1';
                    u_Tx_Pid <= PID_STALL;
                    u_Send_Last <= '1';
                    ---------------
                    u_Fifo_Rst <= '1';--reset FIFO
                    if (u_Tx_Cmd_Done = '1') then
                        next_state <= IDLE;
                    end if;
                else
                    u_Fifo_Rst <= '1';--reset FIFO
                    next_state <= IDLE;
                end if;
            elsif (u_Token_PID = PID_SETUP and u_PID_Field = PID_DATA0) then
                state_ind_pd <= "1111111";
                    if (u_Buffer_Available = '0') then
                        --u_Fifo_Rst <= '1';--reset FIFO
                        next_state <= IDLE;
                    elsif (u_Buffer_Available = '1' and u_CRC16_Residual = "1000000000001101") then
                        u_Accept_Setup_Data_Set <= '1';
                        u_Data_Sync_Toggle <= '1'; --toggle sequence bit
                        u_Fifo_Write_Toggle_Set <= '1';
                        next_state <= DSPACE;
                    else --invalid
                        u_Fifo_Rst <= '1';--reset FIFO
                        next_state <= IDLE;
                    end if;                 
            else --discard data
                state_ind_pd <= "0000000";
                u_Fifo_Rst <= '1';--reset FIFO
                next_state <= IDLE;
            end if;   
             
        when DSPACE =>
            state_ind_pd <= "0001110";
            --issue ACK
            u_Send_PID_CMD <= '1';
            u_Tx_Pid <= PID_ACK;
            u_Send_Last <= '1';
            ----------
            --u_Fifo_Rst <= '1';--reset FIFO
            if (u_Tx_Cmd_Done = '1') then
                next_state <= IDLE;
            end if;
----------------------------------------------------------------------------------------------
--------Dev_Do_IsochO-------------------------------------------------------------------------
            
        when DEV_DO_ISCHO =>
            state_ind_pd <= "0001111";
            if (((u_PID_Field = PID_DATA0) or (u_PID_Field = PID_DATA1) or (u_PID_Field = PID_DATA2) or (u_PID_Field = PID_MDATA)) and u_CRC16_Output = "0000000000000000")  then
                u_Accept_Data_Set <= '1';--accept_data
                u_Fifo_Write_Toggle_Set <= '1';
                next_state <= DDO_IODATA;
            else
                --Dev_Record_error
                next_state <= DDO_IODATA;
            end if;
            
        when DDO_IODATA =>
            state_ind_pd <= "0010000";
            --Respond Dev Do next data??
            u_Send_PID_CMD <= '1';
            u_Tx_Pid <= PID_NAK;
            u_Send_Last <= '1';
            ----------
            if (u_Tx_Cmd_Done = '1') then
                u_NAK_Sent <= '1';
                next_state <= IDLE;
            end if;  
            
--------------------------------------------------------------------------------------------------
------------Dev_Do_IsochI-------------------------------------------------------------------------
        
        when DEV_DO_ISOCHI =>
            --issue packet
            state_ind_pd <= "0010001";
            next_state <= D_DO_IINEXT; 
            
        when D_DO_IINEXT =>
            --RespondDev Do_next_data
            u_Send_PID_CMD <= '1';
            u_Tx_Pid <= PID_NAK;
            u_Send_Last <= '1';
            ----------
            if (u_Tx_Cmd_Done = '1') then
                u_NAK_Sent <= '1';
                next_state <= IDLE;
            end if; 
            
----------------------------------------------------------------------------------------------------  
-------------Dev_DoBCINTI---------------------------------------------------------------------------

        when DEV_DO_BCINTI =>
            state_ind_pd <= "0010010";
            if (u_Send_Zero_Length_Packet = '1') then --Zero Length packets use a different framework
                next_state <= DEV_DO_BCINTI_ZERO_LENGTH;
            elsif (u_Endpt_Ready = '1') then -- send packet data  
                next_state <= DEV_DO_BCINTI_PACKET;     
            elsif (u_Endpt_Ready = '0') then --issue a NAK handshake packet
                next_state <= DEV_DO_BCINTI_NAK;
            elsif (u_Endp_Stall = '1') then
                next_state <= DEV_DO_BCINTI_STALL;
            else
                next_state <= IDLE;
            end if;
            
        when DEV_DO_BCINTI_PACKET =>
            state_ind_pd <= "1000000";   
            if (u_Endpt_Ready = '1') then
                u_In_Token_Received_Fsm <= '1';
                u_Send_Packet <= '1';
                if (axis_32_to_8_latency_comp_out = '1') then
                    u_Tx_Pid <= u_Data_Pid_Sync_Tx;
                    u_Send_PID_CMD <= '1';
                    u_Tx_Data_Loc <= u_BRAM_Read_Data;
                    if (u_Tx_Data_En = '1') then
                        u_CRC16_En <= u_CRC16_En_Ulpi;
                        if (u_Send_Packet_Last = '1') then
                            next_state <= SEND_CRC16_1;
                        end if;   
                    end if;
                end if; 
             else
                next_state <= ERROR;   
             end if;     
        
        when DEV_DO_BCINTI_ZERO_LENGTH =>
            state_ind_pd <= "1100000";    
            if (u_Send_Zero_Length_Packet = '1') then
                u_In_ACK <= '1';
                u_In_Token_Received_Fsm <= '1';
                u_Send_PID_CMD <= '1';
                u_Tx_Pid <= u_Data_Pid_Sync;
                u_Tx_Data_Loc <= u_CRC16_Output(15 downto 8);
                if (u_Tx_Pid_Phase_Done = '1') then
                    u_Cnt_Bytes_Sent_Latch <= '1';
                    next_state <= SEND_CRC16_2;
                end if;
             else
                next_state <= ERROR;
             end if;   
        
        when DEV_DO_BCINTI_NAK => 
                state_ind_pd <= "1110000";   
                --issue NAK
                u_Send_PID_CMD <= '1';
                u_Tx_Pid <= PID_NAK;
                u_Send_Last <= '1';
                ----------
                if (u_Tx_Cmd_Done = '1') then
                    u_NAK_Sent <= '1';
                    next_state <= IDLE;
                end if;         
        
        when DEV_DO_BCINTI_STALL => 
                state_ind_pd <= "1111000";  
                --issue STALL
                u_Send_PID_CMD <= '1';
                u_Tx_Pid <= PID_STALL;
                u_Send_Last <= '1';
                ---------------
                if (u_Tx_Cmd_Done = '1') then
                    next_state <= IDLE;
                end if;
                
        when SEND_CRC16_1 => --send first CRC16 byte
            u_Cnt_Bytes_Sent_Latch <= '1';
            state_ind_pd <= "0010011";
            if(u_Tx_Data_En = '1') then
                u_Tx_Data_Loc <= u_CRC16_Output(15 downto 8);
                next_state <= SEND_CRC16_2;
            else
                u_Tx_Data_Loc <= u_BRAM_Read_Data;    
            end if;         
            
        when SEND_CRC16_2 => --send second CRC16 byte
            state_ind_pd <= "0010100";
            u_Tx_Data_Loc <= u_CRC16_Output(7 downto 0);
            u_Send_Last <= '1';
            next_state <= SEND_CRC16_END;

            
        when SEND_CRC16_END =>   
            u_Cnt_Bytes_Sent_Rst <= '0';
            u_Send_Last <= '1';
            if (u_Tx_Cmd_Done = '1') then
                u_Tx_Data_Loc <= (others => '0');
                next_state <= DEV_RESP;
            else
                if(u_Tx_Data_En = '0') then
                    u_Tx_Data_Loc <= u_CRC16_Output(7 downto 0);
                else 
                    u_Tx_Data_Loc <= (others => '0');
                end if;    
            end if; 
         
        when DEV_RESP => --wait for host to respond with a hanshake packet
            state_ind_pd <= "0010101";
            u_Cnt_Timeout_CE <= '1';
            u_Cnt_Timeout_Rst <= '1'; 
            if (u_Rx_Packet_Received = '1' and u_RxActive = '1' and u_RxEvent = "01") then
                u_PID_Field_Latch <= '1';
                next_state <= DEV_DO_BCINTO_CHECK_PID;
            elsif (u_Cnt_Timeout = TIMEOUT) then
                u_Cnt_Timeout_Rst <= '0'; 
                u_Resend_Set_Fsm <= '1';
                next_state <= IDLE;      
            end if;
        
        when DEV_DO_BCINTO_CHECK_PID => --check host response PID
            state_ind_pd <= "0010110";
            u_Cnt_Timeout_Rst <= '1';
            if (u_PID_Field = PID_ACK) then
                --Respond dev do next data
                u_In_Packet_Complete_Set <= '1'; --IN Packet completed succesfully
                u_Data_Sync_Toggle_Tx <= '1'; --Toggle data sync bit
                u_Send_Zero_Length_Packet_Ack_Set <= '1';
                u_Send_Zero_Length_Packet_Clear <= '1';
                -------------------
                next_state <= IDLE;
            elsif (u_PID_Field = PID_SOF and (u_RxActive = '1' and u_RxEvent = "01")) then
                u_Frame_Index_Latch <= '1';
                next_state <= DEV_DO_BCINTO_SOF;      
            else
                u_Resend_Set_Fsm <= '1';
                next_state <= IDLE;
            end if;    
   
        when DEV_DO_BCINTO_SOF => --new state
            state_ind_pd <= "0010110";
            u_Cnt_Timeout_Rst <= '1'; 
            if (u_RxActive = '1' and u_RxEvent = "01") then
            end if;  
            next_state <= DEV_RESP;                      
------------------------------------------------------------------------------------------------------
-----------Dev_HS_ping Not Tested--------------------------------------------------------------------------------

        when DEV_DO_HSPING =>
            state_ind_pd <= "0010111";
            if (u_Buffer_Available = '0') then
                --issue NAK
                u_Send_PID_CMD <= '1';
                u_Tx_Pid <= PID_NAK;
                u_Send_Last <= '1';
                ----------
                if (u_Tx_Cmd_Done = '1') then
                    u_NAK_Sent <= '1';
                    next_state <= IDLE;
                end if;
            elsif (u_Buffer_Available = '1') then
                --issue ACK
                u_Send_PID_CMD <= '1';
                u_Tx_Pid <= PID_ACK;
                u_Send_Last <= '1';
                ----------
                if (u_Tx_Cmd_Done = '1') then
                    next_state <= IDLE;
                end if;            
            elsif (u_Endp_Stall = '1') then
                --issue STALL
                u_Send_PID_CMD <= '1';
                u_Tx_Pid <= PID_STALL;
                u_Send_Last <= '1';
                ---------------
                if (u_Tx_Cmd_Done = '1') then
                    next_state <= IDLE;
                end if;
            else
                next_state <= IDLE;    
            end if;   
                                             
        when others =>
            state_ind_pd <= "1111111";
            next_state <= IDLE;
      end case;      
   end process;

end Behavioral;