-------------------------------------------------------------------------------
--
-- File: Receive_Path.vhd
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
-- This module stores the data received over the UPLI bus on demand from the
-- packet decoder state machine. The data is formated to the AXI Stream protocol 
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Receive_Path is
    Port ( 
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
       u_Accept_Data_Set : in STD_LOGIC;
       u_Accept_Setup_Data_Set : in STD_LOGIC;
       
       u_Setup_Received_Set : OUT std_logic;
       u_Input_CR16 : OUT std_logic_vector(15 downto 0)
       
     );
end Receive_Path;

architecture Behavioral of Receive_Path is

COMPONENT fifo_generator_input_buffer
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT fifo_generator_command
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    full : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;

signal u_Command_Fifo_Din : STD_LOGIC_VECTOR (23 downto 0);
signal u_Command_Fifo_Wr_En : STD_LOGIC;
--DELAY PACKET BYTES
signal u_End_Packet : STD_LOGIC;
signal u_End_Packet_Rst : STD_LOGIC;

signal u_Rx_Data_q : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal u_Rx_Data_qq : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal u_Store_Packet_q : STD_LOGIC;
signal u_Store_Packet_qq : STD_LOGIC;

signal u_Input_Byte_Count : STD_LOGIC_VECTOR (14 downto 0);
signal u_Input_Byte_CE : STD_LOGIC;
signal u_Input_Byte_CE_Aux : STD_LOGIC;
signal u_Input_Byte_Count_Rst : STD_LOGIC;

type store_counter is array (1 downto 0) of std_logic_vector(14 downto 0);
signal u_Input_Byte_Count_Array : store_counter;
signal u_Input_Byte_Count_Aux : STD_LOGIC_VECTOR (14 downto 0);
signal u_Input_Byte_Count_Aux1 : STD_LOGIC_VECTOR (14 downto 0);
signal u_Input_Byte_Count_Complement : std_logic_vector(1 downto 0);

signal u_Packet_Byte_Count : STD_LOGIC_VECTOR (12 downto 0);
signal u_Packet_Byte_CE : STD_LOGIC;
signal u_Packet_Byte_Count_Rst : STD_LOGIC;

signal    u_Fifo_Din : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal    u_Fifo_Wr_En : STD_LOGIC;
signal    u_Fifo_Wr_En_Aux : STD_LOGIC;
signal    u_Fifo_Wr_En_Complete32 : STD_LOGIC; --if the packet has a number of bytes not multiple of 4 dummy bytes must be added so that the last 4 byte word is available at the FIFO output
signal    u_Fifo_Rd_En : STD_LOGIC;
signal    u_Fifo_Dout :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal    u_Fifo_Valid : STD_LOGIC;
signal    u_Fifo_Empty_Out : STD_LOGIC;
signal    u_Fifo_Reset_Array : STD_LOGIC_VECTOR (1 downto 0);

signal    u_Fifo1_Reset : STD_LOGIC;
signal    u_Fifo1_Din : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal    u_Fifo1_Wr_En : STD_LOGIC;
signal    u_Fifo1_Rd_En : STD_LOGIC;
signal    u_Fifo1_Dout :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal    u_Fifo1_Full : STD_LOGIC;
signal    u_Fifo1_Empty : STD_LOGIC;
signal    u_Fifo1_Valid : STD_LOGIC;

signal    u_Fifo2_Reset : STD_LOGIC;
signal    u_Fifo2_Din : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal    u_Fifo2_Wr_En : STD_LOGIC;
signal    u_Fifo2_Rd_En : STD_LOGIC;
signal    u_Fifo2_Dout :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal    u_Fifo2_Full : STD_LOGIC;
signal    u_Fifo2_Empty : STD_LOGIC;
signal    u_Fifo2_Valid : STD_LOGIC;

signal u_Input_Buffer_Loaded_set : STD_LOGIC;
signal u_Input_Buffer_Loaded : STD_LOGIC;
signal u_Fifo_Write_Toggle_Aux : STD_LOGIC;
signal u_Fifo_Write_Toggle_En_Pulse : STD_LOGIC;
signal u_Fifo_Write_Toggle_En : STD_LOGIC;
signal u_Fifo_Write_Toggle_En_q : STD_LOGIC;
signal u_Fifo_Write_Toggle : STD_LOGIC;
signal u_Fifo_Write_Toggle_Ready : STD_LOGIC;
signal u_Fifo_Toggle_Read_Set : STD_LOGIC;
signal u_Fifo_Toggle_Read : STD_LOGIC;
signal u_Rx_Transfer_Done : STD_LOGIC;
signal u_Rx_Transfer_Done_q : STD_LOGIC;
signal u_Rx_Transfer_Done_Pulse : STD_LOGIC;
signal u_Accept_Setup_Data : STD_LOGIC;
signal u_Accept_Data : STD_LOGIC;

signal u_Setup_Buffer_Bytes_7_4_Latch : STD_LOGIC;
signal u_Setup_Buffer_Bytes_3_0_Latch : STD_LOGIC;

signal index1 : std_logic_vector(0 downto 0);
signal index2 : std_logic_vector(0 downto 0);
signal index1_int : integer range 0 to 1;
signal index2_int : integer range 0 to 1;

begin    

u_Rx_Fifo_s_Aclk <= Ulpi_Clk;
-----COMMAND FIFO-----------------------------------------------
u_Command_Fifo_Din <= u_Packet_Byte_Count & u_Device_Addr & "0000";

RX_COMMAND_FIFO : fifo_generator_command
  PORT MAP (
    rst => reset,
    wr_clk => Ulpi_Clk,
    rd_clk => Axi_Clk,
    din => u_Command_Fifo_Din,
    wr_en => u_Command_Fifo_Wr_En,
    rd_en => u_Command_Fifo_Rd_En,
    dout => u_Command_Fifo_Dout,
    full => open,
    valid => u_Command_Fifo_Valid,
    empty => u_Command_Fifo_Empty
  );
  
--------------------------------------------------------------------
index1(0) <= u_Fifo_Toggle_Read;
index2(0) <= u_Fifo_Write_Toggle;
index1_int <= to_integer(unsigned(index1));
index2_int <= to_integer(unsigned(index2));

-- Load packet into input buffer. Separate CRC16 bytes from the rest of the packet    
    END_PACKET_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
           if (reset = '0' or u_End_Packet_Rst = '0') then
              u_End_Packet <= '0';
           elsif (u_End_Packet_Set = '1') then
              u_End_Packet <= '1';
           end if;        
        end if;
    end process; 	 
    
   DELAY_PACKET_BYTES: process (Ulpi_Clk)
     begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
           if (reset = '0') then  
              u_End_Packet_Rst <= '0';  
              u_Input_Byte_CE_Aux <= '0';     
              u_Rx_Data_q <= (others => '0');
              u_Rx_Data_qq <= (others => '0');
              u_Store_Packet_q <= '0';
              u_Store_Packet_qq <= '0';
              u_Fifo_Wr_En_Complete32 <= '0';
              u_Input_Buffer_Loaded_set <= '0';
              u_Input_Byte_Count_Rst <= '0';
           elsif (u_Store_Packet = '1') then
              u_Fifo_Wr_En_Complete32 <= '0';
              u_End_Packet_Rst <= '1';
              u_Input_Buffer_Loaded_set <= '0';
              u_Input_Byte_Count_Rst <= '1';
              u_Rx_Data_q <= u_Rx_Data;
              u_Rx_Data_qq <= u_Rx_Data_q;
              u_Store_Packet_q <= u_Store_Packet;
              u_Store_Packet_qq <= u_Store_Packet_q;
           elsif (u_End_Packet = '1') then 
               if(u_Input_Byte_Count = "00000000000010") then --zero length packet
                  u_Store_Packet_qq <= '0';  
                  u_Store_Packet_q <= '0';
                  u_End_Packet_Rst <= '0'; 
                  u_Rx_Data_qq <= (others => '0');
                  u_Input_Byte_Count_Rst <= '0';
                  u_Input_Byte_CE_Aux <= '0';
                  u_Fifo_Wr_En_Complete32 <= '0';
                  u_Input_Buffer_Loaded_set <= '1';              
               else      
                  u_Store_Packet_qq <= '0';  
                  u_Store_Packet_q <= '0';        
                  if (u_Input_Byte_Count(1 downto 0) = "00" and u_End_Packet_Rst /= '0') then --u_Input_Byte_Count = packet bytes + 2bytes(CRC16)
                    u_End_Packet_Rst <= '0';
                    u_Rx_Data_qq <= (others => '0');
                    u_Input_Byte_Count_Rst <= '0';
                    u_Input_Byte_CE_Aux <= '0';
                    u_Fifo_Wr_En_Complete32 <= '0';
                    u_Input_Buffer_Loaded_set <= '1';
                  elsif (u_End_Packet_Rst = '0') then
                    u_Fifo_Wr_En_Complete32 <= '0';
                    u_Input_Byte_Count_Rst <= '0';
                    u_Input_Byte_CE_Aux <= '0';
                    u_Input_Buffer_Loaded_set <= '0';  
                  else
                    u_Fifo_Wr_En_Complete32 <= '1';
                    u_Input_Byte_Count_Rst <= '1';
                    u_Input_Byte_CE_Aux <= '1';
                    u_Input_Buffer_Loaded_set <= '0';
                  end if;
               end if;       
           else
            u_Input_Buffer_Loaded_set <= '0';
            u_Input_Byte_CE_Aux <= '0';
            u_Fifo_Wr_En_Complete32 <= '0';
            u_Rx_Data_q <= u_Rx_Data;
            u_Rx_Data_qq <= u_Rx_Data_q;
            u_Store_Packet_q <= u_Store_Packet;
            u_Store_Packet_qq <= u_Store_Packet_q;
            u_End_Packet_Rst <= '1';                  
           end if;     
        end if;
     end process;    

   CRC16_PROC: process (Ulpi_Clk, u_Store_Packet_q, u_Store_Packet_qq, u_Store_Packet)
       begin
          if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
             if (reset = '0') then
                u_Input_CR16 <= (others => '0');
             elsif (u_End_Packet_Set = '1') then
                u_Input_CR16 <= u_Rx_Data_qq & u_Rx_Data_q;
             end if;        
          end if;
       end process;  

	u_Input_Byte_CE <= u_Fifo_Wr_En or u_Input_Byte_CE_Aux;

    INPUT_BUFFER_BYTE_PROC : process (Ulpi_Clk) --count bytes stored in the input buffer
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if ((reset = '0') or ((u_Input_Byte_Count_Rst or u_Store_Packet) = '0')) then
                u_Input_Byte_Count <= (others => '0');
            else
                if (u_Input_Byte_CE = '1') then
                    u_Input_Byte_Count <= std_logic_vector(unsigned(u_Input_Byte_Count)+1);
                end if;
            end if;    
        end if;   
    end process;	   

---------------DOUBLE BUFFER--------------------------------------	   
    FIFO1 : fifo_generator_input_buffer
    PORT MAP (
        rst => u_Fifo1_Reset,
        wr_clk => Ulpi_Clk,
        rd_clk => Ulpi_Clk,
        din => u_Fifo1_Din,
        wr_en => u_Fifo1_Wr_En,
        rd_en => u_Fifo1_Rd_En,
        dout => u_Fifo1_Dout,
        full => u_Fifo1_Full,
        empty => u_Fifo1_Empty,
        valid => u_Fifo1_Valid
    );
    FIFO2 : fifo_generator_input_buffer
    PORT MAP (
        rst => u_Fifo2_Reset,
        wr_clk => Ulpi_Clk,
        rd_clk => Ulpi_Clk,
        din => u_Fifo2_Din,
        wr_en => u_Fifo2_Wr_En,
        rd_en => u_Fifo2_Rd_En,
        dout => u_Fifo2_Dout,
        full => u_Fifo2_Full,
        empty => u_Fifo2_Empty,
        valid => u_Fifo2_Valid
    ); 
	
	    FIFO_RESET_ARRAY_PROC: process (Ulpi_Clk, u_Store_Packet_q, u_Store_Packet_qq, u_Store_Packet)
         begin
            if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
               if (reset = '0') then
                  u_Fifo_Reset_Array <= (others => '0');
               else 
                  u_Fifo_Reset_Array(to_integer(unsigned(index1))) <= u_Rx_Transfer_Done_Pulse;
               end if;        
            end if;
         end process; 
	
	u_Fifo_Din <= u_Rx_Data_qq;
    u_Fifo_Wr_En_Aux <= (u_Store_Packet_qq and u_Store_Packet_State) when (u_Ulpi_Dir_Out = '1') else '0';
    u_Fifo_Wr_En <= u_Fifo_Wr_En_Aux or u_Fifo_Wr_En_Complete32; --u_Fifo_Wr_En <= (u_Store_Packet_qq and store_packet) or u_Fifo_Wr_En_Complete32;  
   
	u_Fifo1_Reset <= u_Fifo_Rst_q or (not reset) or u_Fifo_Reset_Array(0);  --The reset is edge-sensitive and not level-sensitive. The synchronization logic looks for the rising edge of rst and creates an internal reset for the core
    u_Fifo2_Reset <= u_Fifo_Rst_q or (not reset) or u_Fifo_Reset_Array(1);
    u_Fifo1_Din <= u_Fifo_Din when u_Fifo_Write_Toggle = '0' else (others => '0');
    u_Fifo2_Din <= u_Fifo_Din when u_Fifo_Write_Toggle = '1' else (others => '0'); 
    u_Fifo1_Wr_En <= u_Fifo_Wr_En when u_Fifo_Write_Toggle = '0' else '0';
    u_Fifo2_Wr_En <= u_Fifo_Wr_En when u_Fifo_Write_Toggle = '1' else '0'; 
    u_Fifo1_Rd_En <= u_Fifo_Rd_En when u_Fifo_Toggle_Read = '0' else '0';
    u_Fifo2_Rd_En <= u_Fifo_Rd_En when u_Fifo_Toggle_Read = '1' else '0';  
    u_Fifo_Dout <= u_Fifo1_Dout when u_Fifo_Toggle_Read = '0' else u_Fifo2_Dout;
    u_Fifo_Empty  <= u_Fifo1_Empty when u_Fifo_Write_Toggle = '0' else u_Fifo2_Empty;
    u_Fifo_Empty_Out  <= u_Fifo1_Empty when u_Fifo_Toggle_Read = '0' else u_Fifo2_Empty;
    u_Fifo_Valid <= u_Fifo1_Valid when u_Fifo_Toggle_Read = '0' else u_Fifo2_Valid;	
	   
---Double buffer selection signals--------------------------------	   

    RX_TRANSFER_DONE_PULSE_PROC : process (Ulpi_Clk)
    begin
    if (Ulpi_Clk'event and Ulpi_Clk = '1') then
       if (reset = '0') then 
          u_Rx_Transfer_Done_Pulse <= '0';
          u_Rx_Transfer_Done_q <= '0';
       else
         u_Rx_Transfer_Done_q <= u_Rx_Transfer_Done;
         u_Rx_Transfer_Done_Pulse <= u_Rx_Transfer_Done and (not u_Rx_Transfer_Done_q); 
       end if;
    end if;              
    end process;

    FSM_FIFO_IN_TOGGLE_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0' or u_Fifo_Write_Toggle_Rst = '0') then
                u_Fifo_Write_Toggle_Aux <= '0';
            elsif (u_Fifo_Write_Toggle_Set = '1') then
                u_Fifo_Write_Toggle_Aux <= '1';               
            end if;
        end if;   
    end process; 
	
    INPUT_BUFFER_LOADED_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0' or u_Input_Buffer_Loaded_Rst = '0') then
                u_Input_Buffer_Loaded <= '0';
            elsif (u_Input_Buffer_Loaded_set = '1') then
                u_Input_Buffer_Loaded <= '1';               
            end if;
        end if;   
    end process; 	
	
	u_Fifo_Write_Toggle_En <= u_Input_Buffer_Loaded and u_Fifo_Write_Toggle_Aux;
	
	FIFO_TOGGLE_IN_PULSE : process (Ulpi_Clk)
    begin
    if (Ulpi_Clk'event and Ulpi_Clk = '1') then
       if (reset = '0') then 
          u_Fifo_Write_Toggle_En_Pulse <= '0';
          u_Fifo_Write_Toggle_En_q <= '0';
       else
         u_Fifo_Write_Toggle_En_q <= u_Fifo_Write_Toggle_En;
         u_Fifo_Write_Toggle_En_Pulse <= u_Fifo_Write_Toggle_En and (not u_Fifo_Write_Toggle_En_q); 
       end if;
    end if;              
    end process;
	
	FIFO_IN_TOGGLE_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Fifo_Write_Toggle <= '0';
            elsif (u_Fifo_Write_Toggle_En_Pulse = '1') then
                u_Fifo_Write_Toggle <= not (u_Fifo_Write_Toggle);               
            end if;
        end if;   
    end process;
		
    FIFO_IN_TOGGLE_READY_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0' or u_Rx_Transfer_Done_Pulse = '1') then
                u_Fifo_Write_Toggle_Ready <= '0';
            elsif (u_Fifo_Write_Toggle_En_Pulse = '1') then
                u_Fifo_Write_Toggle_Ready <= '1';               
            end if;
        end if;   
    end process;
	

   FIFO_OUT_TOGGLE: process (Ulpi_Clk)
       begin
          if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
             if (reset = '0') then
                u_Fifo_Toggle_Read_Set <= '0';
             elsif (u_Rx_Transfer_Done_Pulse = '1') then
                 if (u_Fifo_Write_Toggle /= u_Fifo_Toggle_Read) then 
                     u_Fifo_Toggle_Read_Set <= '1';
                 end if;
             else
                 u_Fifo_Toggle_Read_Set <= '0';    
             end if;        
          end if;
       end process;

    FIFO_OUT_TOGGLE_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Fifo_Toggle_Read <= '0';
            elsif (u_Fifo_Toggle_Read_Set = '1') then
                u_Fifo_Toggle_Read <= not (u_Fifo_Toggle_Read);               
            end if;
        end if;   
    end process;	
	
----------------------NATIVE FIFO TO AXI TREAM CONVERTER------------------------------------- 	
    ACCEPT_DATA_PROC: process (Ulpi_Clk)
     begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
           if (reset = '0' or u_Rx_Transfer_Done = '1') then
              u_Accept_Data <= '0';
           elsif (u_Accept_Data_Set = '1') then
              u_Accept_Data <= '1';
           end if;        
        end if;
     end process;
 
   ACCEPT_SETUP_DATA_PROC: process (Ulpi_Clk)
         begin
            if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
               if (reset = '0' or u_Rx_Transfer_Done = '1') then
                  u_Accept_Setup_Data <= '0';
               elsif (u_Accept_Setup_Data_Set = '1') then
                  u_Accept_Setup_Data <= '1';
               end if;        
            end if;
         end process;     

    RX_FIFO_COMB_PROC : process (reset, u_Fifo_Valid, u_Fifo_Write_Toggle_Ready, u_Input_Byte_Count_Array, index1, u_Accept_Setup_Data, u_Fifo_Dout, u_Input_Byte_Count_Aux, u_Packet_Byte_Count, u_Fifo_Valid, u_Accept_Data, u_Rx_Fifo_s_Axis_Tready)
    begin
        if (reset = '0') then
            u_Fifo_Rd_En <= '0';
            u_Packet_Byte_CE <= '0';
            u_Rx_Transfer_Done <= '0';
            u_Setup_Received_Set <= '0';
            u_Packet_Byte_Count_Rst <= '0';
            u_Command_Fifo_Wr_En <= '0';
            u_Rx_Fifo_s_Axis_Tkeep <= "0000";
            u_Rx_Fifo_s_Axis_Tdata <= (others => '0');
            u_Rx_Fifo_s_Axis_Tlast <= '0';
            u_Setup_Buffer_Bytes_7_4_Latch <= '0';
            u_Setup_Buffer_Bytes_3_0_Latch <= '0';
        elsif (u_Fifo_Write_Toggle_Ready = '1') then    
            if (u_Accept_Data = '1') then
                u_Setup_Buffer_Bytes_7_4_Latch <= '0';
                u_Setup_Buffer_Bytes_3_0_Latch <= '0';
                u_Setup_Received_Set <= '0';
                u_Rx_Fifo_s_Axis_Tdata <= u_Fifo_Dout;
                u_Fifo_Rd_En <= '1';
                if (u_Packet_Byte_Count = "0000000000000" and u_Input_Byte_Count_Aux = "000000000000000") then -- zero length packet
                    u_Rx_Fifo_s_Axis_Tlast <= '0';
                    u_Rx_Fifo_s_Axis_Tkeep <= "1111";
                    u_Command_Fifo_Wr_En <= '0';
                    u_Packet_Byte_Count_Rst <= '0';
                    u_Fifo_Rd_En <= '0';
                    u_Packet_Byte_CE <= '0';
                    u_Rx_Transfer_Done <= '1';                   
                elsif (u_Rx_Fifo_s_Axis_Tready = '1') then
                    if (u_Fifo_Valid = '1') then
                        u_Packet_Byte_CE <= '1';
                        if (u_Packet_Byte_Count =  u_Input_Byte_Count_Aux(14 downto 2)) then
                            u_Rx_Transfer_Done <= '1';
                            u_Packet_Byte_Count_Rst <= '0';
                            u_Command_Fifo_Wr_En <= '1';
                            u_Rx_Fifo_s_Axis_Tlast <= '1';
                                if (u_Input_Byte_Count_Array(to_integer(unsigned(index1)))(1 downto 0) = "00") then --n*4 bytes + 2CRC (CRC16 not saved)
                                    u_Rx_Fifo_s_Axis_Tkeep <= "1111";
                                elsif (u_Input_Byte_Count_Array(to_integer(unsigned(index1)))(1 downto 0) = "01") then  --n*4 bytes + 1byte + 2CRC
                                    u_Rx_Fifo_s_Axis_Tkeep <= "0001";
                                elsif (u_Input_Byte_Count_Array(to_integer(unsigned(index1)))(1 downto 0) = "10") then  --n*4 bytes + 2bytes + 2CRC
                                    u_Rx_Fifo_s_Axis_Tkeep <= "0011";
                                elsif (u_Input_Byte_Count_Array(to_integer(unsigned(index1)))(1 downto 0) = "11") then  --n*4 bytes + 3byte + 2CRC
                                    u_Rx_Fifo_s_Axis_Tkeep <= "0111";
                                else
                                    u_Rx_Fifo_s_Axis_Tkeep <= "1111";    
                                end if;          
                        else
                            u_Rx_Fifo_s_Axis_Tlast <= '0';
                            u_Rx_Fifo_s_Axis_Tkeep <= "1111";
                            u_Rx_Transfer_Done <= '0';
                            u_Packet_Byte_Count_Rst <= '1';
                            u_Command_Fifo_Wr_En <= '0';
                        end if; 
                    else
                        u_Rx_Fifo_s_Axis_Tlast <= '0';
                        u_Rx_Fifo_s_Axis_Tkeep <= "1111";
                        u_Command_Fifo_Wr_En <= '0';
                        u_Packet_Byte_Count_Rst <= '1';
                        u_Rx_Transfer_Done <= '0';
                        u_Packet_Byte_CE <= '0';
                    end if;                        
                else
                    u_Rx_Fifo_s_Axis_Tlast <= '0';
                    u_Rx_Fifo_s_Axis_Tkeep <= "1111";
                    u_Command_Fifo_Wr_En <= '0';
                    u_Packet_Byte_Count_Rst <= '1';
                    u_Fifo_Rd_En <= '0';
                    u_Packet_Byte_CE <= '0';
                    u_Rx_Transfer_Done <= '0';
                end if;
            elsif (u_Accept_Setup_Data = '1') then
                u_Rx_Fifo_s_Axis_Tdata <= (others => '0');
                u_Rx_Fifo_s_Axis_Tkeep <= "1111";
                u_Rx_Fifo_s_Axis_Tlast <= '0';
                u_Command_Fifo_Wr_En <= '0';
                u_Fifo_Rd_En <= '1';
                u_Setup_Buffer_Bytes_7_4_Latch <= '0';
                u_Setup_Buffer_Bytes_3_0_Latch <= '0';
                if (u_Fifo_Valid = '1') then
                    u_Packet_Byte_CE <= '1';
                    if (u_Packet_Byte_Count = "0000000000000") then
                        u_Rx_Transfer_Done <= '0';
                        u_Setup_Received_Set <= '0';    
                        u_Packet_Byte_Count_Rst <= '1';
                        u_Setup_Buffer_Bytes_3_0_Latch <= '1';
                    elsif (u_Packet_Byte_Count = "0000000000001") then
                        u_Rx_Transfer_Done <= '1';
                        u_Setup_Received_Set <= '1';
                        u_Packet_Byte_Count_Rst <= '0';
                        u_Setup_Buffer_Bytes_7_4_Latch <= '1';
                    else
                        u_Rx_Transfer_Done <= '0';
                        u_Setup_Received_Set <= '0';
                        u_Packet_Byte_Count_Rst <= '1';
                    end if;
                else
                    u_Setup_Received_Set <= '0';
                    u_Rx_Transfer_Done <= '0';
                    u_Packet_Byte_Count_Rst <= '1';
                    u_Packet_Byte_CE <= '0';
                end if;    
            else
                u_Packet_Byte_Count_Rst <= '0';
                u_Rx_Fifo_s_Axis_Tdata <= (others => '0');
                u_Setup_Buffer_Bytes_7_4_Latch <= '0';
                u_Setup_Buffer_Bytes_3_0_Latch <= '0';
                u_Rx_Fifo_s_Axis_Tlast <= '0';
                u_Setup_Received_Set <= '0';
                u_Command_Fifo_Wr_En <= '0';
                u_Rx_Transfer_Done <= '0';
                u_Fifo_Rd_En <= '0';
                u_Packet_Byte_CE <= '0';   
                u_Rx_Fifo_s_Axis_Tkeep <= "1111";     
            end if;  
        else
            u_Packet_Byte_Count_Rst <= '0';
            u_Rx_Fifo_s_Axis_Tdata <= (others => '0');
            u_Setup_Buffer_Bytes_7_4_Latch <= '0';
            u_Setup_Buffer_Bytes_3_0_Latch <= '0';
            u_Rx_Fifo_s_Axis_Tlast <= '0';
            u_Setup_Received_Set <= '0';
            u_Command_Fifo_Wr_En <= '0';
            u_Rx_Transfer_Done <= '0';
            u_Fifo_Rd_En <= '0';
            u_Packet_Byte_CE <= '0';   
            u_Rx_Fifo_s_Axis_Tkeep <= "1111";                  
        end if;        
    end process;      

    RX_FIFO_S_AXIS_TVALID_PROC: process (Ulpi_Clk, u_Accept_Setup_Data, u_Fifo_Valid)
    begin
        if (u_Accept_Setup_Data = '1') then
            if (u_Fifo_Valid = '1') then
                u_Rx_Fifo_s_Axis_Tvalid <= '1';
            else
                u_Rx_Fifo_s_Axis_Tvalid <= '0';   
            end if;     
        else
            u_Rx_Fifo_s_Axis_Tvalid <= '0';       
        end if;
      end process;
	  
    RX_FIFO_PROC : process (Ulpi_Clk, u_Setup_Buffer_Bytes_3_0_Latch, u_Setup_Buffer_Bytes_7_4_Latch)
    begin
    if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
        if (reset = '0') then
            u_Setup_Buffer_Bytes_3_0  <= (others => '0');
            u_Setup_Buffer_Bytes_3_0_Loc  <= (others => '0');
            u_Setup_Buffer_Bytes_7_4  <= (others => '0');
        else
            if (u_Setup_Buffer_Bytes_3_0_Latch = '1') then
                u_Setup_Buffer_Bytes_3_0 <= u_Fifo_Dout;
                u_Setup_Buffer_Bytes_3_0_Loc <= u_Fifo_Dout;
            elsif(u_Setup_Buffer_Bytes_7_4_Latch = '1') then
                u_Setup_Buffer_Bytes_7_4 <= u_Fifo_Dout;
            end if;
        end if;  
    end if;
    end process;	

    FIFO_BYTE_COUNT_PROC : process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if ((reset = '0') or (u_Packet_Byte_Count_Rst = '0')) then
                u_Packet_Byte_Count <= (others => '0');
            else
                if (u_Packet_Byte_CE = '1') then
                    u_Packet_Byte_Count <= std_logic_vector(unsigned(u_Packet_Byte_Count)+1);
                end if;
            end if;    
        end if;   
    end process;
	
    TKEEP_PROC: process (Ulpi_Clk)
       begin
          if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
             if (reset = '0') then
                u_Input_Byte_Count_Array(0) <= (others => '0');
                u_Input_Byte_Count_Array(1) <= (others => '0');
                --index2 <= "0";
             else
                --index2(0) <= fifo_toggle_in; 
                if (u_End_Packet_Set = '1') then
                    u_Input_Byte_Count_Array (to_integer (unsigned (index2))) <= u_Input_Byte_Count;
                end if;    
             end if;        
          end if;
    end process; 

    BYTE_COUNT_ADD_PROC: process (Ulpi_Clk, u_Store_Packet_q, u_Store_Packet_qq, u_Store_Packet)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                u_Input_Byte_Count_Complement <= (others => '0');
            else  
                if (u_Input_Byte_CE_Aux = '1') then
                    u_Input_Byte_Count_Complement(to_integer(unsigned(index2))) <= '1';
                elsif (u_Rx_Transfer_Done = '1') then 
                    u_Input_Byte_Count_Complement(to_integer(unsigned(index1))) <= '0';
                end if;       
            end if;        
        end if;
    end process; 	

    FIFO_BYTE_COUNT_INC_PROC: process (Ulpi_Clk)
    begin
        if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
            if (reset = '0') then
                --index1 <= "0";
                u_Input_Byte_Count_Aux <= (others => '0');
                u_Input_Byte_Count_Aux1 <= (others => '0'); 
            else
                if (u_Input_Byte_Count_Array(index1_int) = "000000000000000") then 
                    u_Input_Byte_Count_Aux <= (others => '0');
                    u_Input_Byte_Count_Aux1 <= (others => '0');    
                else
                    if (u_Input_Byte_Count_Complement(index1_int) = '0') then
                        u_Input_Byte_Count_Aux <= std_logic_vector(unsigned(u_Input_Byte_Count_Array(index1_int))-4);
                        u_Input_Byte_Count_Aux1 <= u_Input_Byte_Count_Array(index1_int);--std_logic_vector(unsigned(u_Input_Byte_Count_Array(index1_int)));
                    else
                        u_Input_Byte_Count_Aux <= u_Input_Byte_Count_Array(index1_int);--std_logic_vector(unsigned(tkeep_byte_count(index1_int)));
                        u_Input_Byte_Count_Aux1 <= std_logic_vector(unsigned(u_Input_Byte_Count_Array(index1_int))+4);
                    end if;    
                end if;        
            end if;        
        end if;
    end process;	

end Behavioral;
