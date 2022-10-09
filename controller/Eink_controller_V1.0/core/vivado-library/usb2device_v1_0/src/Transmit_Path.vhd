-------------------------------------------------------------------------------
--
-- File: Transmit_Path.vhd
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
-- This module is responsible for buffering the data transfered through DMA,
-- implementing the TX endpoints and sending the packet data on request from
-- the protocol engine state machine request
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;

entity Transmit_Path is
	generic (
    C_S_AXI_DATA_WIDTH    : integer    := 3;
    MAX_NR_ENDP           : integer    := 1
    );
  PORT (
    Axi_Resetn : IN STD_LOGIC;
    Axi_Clk : IN STD_LOGIC;
    Ulpi_Clk : in  STD_LOGIC;
    u_Resetn : IN STD_LOGIC;

    u_PE_Endpt_Nr: in std_logic_vector(4 downto 0);
    a_Arb_Endpt_Nr : in std_logic_vector(4 downto 0);  --!!!!! bits need to be synchronised     
    
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
    end Transmit_Path;
architecture Behavioral of Transmit_Path is

COMPONENT blk_mem_gen_1
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

COMPONENT TX_FIFO
  PORT (
    s_aclk : IN STD_LOGIC;
    s_aresetn : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_tkeep : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axis_tlast : IN STD_LOGIC;
    s_axis_tuser : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_tkeep : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axis_tlast : OUT STD_LOGIC;
    m_axis_tuser : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    axis_overflow : OUT STD_LOGIC;
    axis_underflow : OUT STD_LOGIC
  );
END COMPONENT;
type a_BRAM_Base_AddrA_Array is array (MAX_NR_ENDP downto 0) of std_logic_vector(11 downto 0);
constant a_BRAM_Base_AddrA : a_BRAM_Base_AddrA_Array := ("010000000000","000000000000"); 
constant u_BRAM_Base_AddrB : a_BRAM_Base_AddrA_Array := ("010000000000","000000000000"); 
type a_BRAM_Load_Array is array (MAX_NR_ENDP downto 0) of std_logic_vector(11 downto 0);
signal a_BRAM_Load_Counter_Array : a_BRAM_Load_Array; 
type u_Cnt_Load_Bram_oData_Array is array (MAX_NR_ENDP downto 0) of std_logic_vector(11 downto 0);
signal u_Cnt_Load_Bram_oData : u_Cnt_Load_Bram_oData_Array; 
type a_Cnt_Load_Bram_iPush_Array is array (MAX_NR_ENDP downto 0) of std_logic;
signal a_Cnt_Load_Bram_iPush : a_Cnt_Load_Bram_iPush_Array; 
type a_Cnt_Load_Bram_iRdy_Array is array (MAX_NR_ENDP downto 0) of std_logic;
signal a_Cnt_Load_Bram_iRdy : a_Cnt_Load_Bram_iRdy_Array; 
type u_Cnt_Load_Bram_oValid_Array is array (MAX_NR_ENDP downto 0) of std_logic;
signal u_Cnt_Load_Bram_oValid : u_Cnt_Load_Bram_oValid_Array; 
type aReset_Handshake_Array is array (MAX_NR_ENDP downto 0) of std_logic;
signal aReset_Handshake, aReset_Handshake_Loc : u_Cnt_Load_Bram_oValid_Array; 

signal u_Resetn_N : STD_LOGIC;
signal a_BRAM_EnA :  STD_LOGIC;
signal a_BRAM_WeA :  STD_LOGIC_VECTOR(0 DOWNTO 0);
signal a_BRAM_AddrA, a_BRAM_AddrA_q :  STD_LOGIC_VECTOR(11 DOWNTO 0);
signal a_BRAM_Dina :  STD_LOGIC_VECTOR(7 DOWNTO 0);
signal u_BRAM_Enb, u_BRAM_Enb_Loc :  STD_LOGIC;
signal u_BRAM_AddrB :  STD_LOGIC_VECTOR(11 DOWNTO 0);
signal u_BRAM_DoutB, u_BRAM_DoutB_q :  STD_LOGIC_VECTOR(7 DOWNTO 0);
signal a_Tx_Fifo_M_Axis_Tvalid  :      STD_LOGIC;
signal a_Tx_Fifo_M_Axis_Tready  :      STD_LOGIC;
signal a_Tx_Fifo_M_Axis_Tdata   :      STD_LOGIC_VECTOR(31 DOWNTO 0);
signal a_Tx_Fifo_M_Axis_Tkeep   :      STD_LOGIC_VECTOR(3 DOWNTO 0);
signal a_Tx_Fifo_M_Axis_Tlast   :      STD_LOGIC;
signal a_Tx_Fifo_M_Load_Last    :      STD_LOGIC;
--signal a_Tx_Fifo_M_Axis_Tuser :  STD_LOGIC_VECTOR(3 DOWNTO 0);

signal a_Byte_Index        :    integer range 0 to C_S_AXI_DATA_WIDTH;
--signal a_Byte_Index_Rst    : 	STD_LOGIC;
signal a_Byte_Index_Inc    : 	STD_LOGIC;
signal a_Cnt_Load_Bram     :    STD_LOGIC_VECTOR(11 DOWNTO 0);
signal a_Cnt_Load_Bram_Rst : 	STD_LOGIC;
signal u_Cnt_Read_Bram     :    STD_LOGIC_VECTOR(11 DOWNTO 0);
signal u_Cnt_Read_Bram_Rst : 	STD_LOGIC;

signal a_DMA_Transfer_Start, a_DMA_Transfer_Start_Pulse, a_DMA_Transfer_Start_q : 	STD_LOGIC;
signal a_Tx_Fifo_M_Axis_Tlast_q, a_Tx_Fifo_M_Axis_Tlast_NPulse, a_Tx_Fifo_M_Axis_Tlast_NPulse_q : 	STD_LOGIC;
signal a_Tx_Fifo_S_Axis_Tlast_q, a_Tx_Fifo_S_Axis_Tlast_NPulse : 	STD_LOGIC;
signal a_Load_BRAM_Start : STD_LOGIC;

signal u_Send_Packet_Pulse, u_Send_Packet_PulseN, u_Send_Packet_q, u_Send_Packet_Pulse_q : STD_LOGIC;
signal u_Tx_Data_En_q : STD_LOGIC;

signal a_Arb_Endpt_Nr_Int, u_PE_Endpt_Nr_Int : integer range 0 to MAX_NR_ENDP;

--attribute mark_debug : string;
--attribute keep : string;

--attribute mark_debug of a_Tx_Fifo_S_Axis_Tvalid  : signal is "true";
--attribute keep of a_Tx_Fifo_S_Axis_Tvalid : signal is "true";  
--attribute mark_debug of a_Tx_Fifo_S_Axis_Tdata  : signal is "true";
--attribute keep of a_Tx_Fifo_S_Axis_Tdata : signal is "true";  
--attribute mark_debug of a_Tx_Fifo_S_Axis_Tready  : signal is "true";
--attribute keep of a_Tx_Fifo_S_Axis_Tready : signal is "true";  
--attribute mark_debug of a_Tx_Fifo_S_Axis_Tlast  : signal is "true";
--attribute keep of a_Tx_Fifo_S_Axis_Tlast : signal is "true"; 

--attribute mark_debug of a_Tx_Fifo_M_Axis_Tdata  : signal is "true";
--attribute keep of a_Tx_Fifo_M_Axis_Tdata : signal is "true";  
--attribute mark_debug of a_Tx_Fifo_M_Axis_Tvalid  : signal is "true";
--attribute keep of a_Tx_Fifo_M_Axis_Tvalid : signal is "true";  
--attribute mark_debug of a_Tx_Fifo_M_Axis_Tkeep  : signal is "true";
--attribute keep of a_Tx_Fifo_M_Axis_Tkeep : signal is "true";  
--attribute mark_debug of a_Tx_Fifo_M_Axis_Tlast  : signal is "true";
--attribute keep of a_Tx_Fifo_M_Axis_Tlast : signal is "true"; 
--attribute mark_debug of a_Tx_Fifo_M_Axis_Tready  : signal is "true";
--attribute keep of a_Tx_Fifo_M_Axis_Tready : signal is "true";

--attribute mark_debug of a_Byte_Index  : signal is "true";
--attribute keep of a_Byte_Index : signal is "true";
--attribute mark_debug of a_BRAM_WeA  : signal is "true";
--attribute keep of a_BRAM_WeA : signal is "true";
--attribute mark_debug of a_BRAM_AddrA_q  : signal is "true";
--attribute keep of a_BRAM_AddrA_q : signal is "true";
--attribute mark_debug of a_BRAM_Dina  : signal is "true";
--attribute keep of a_BRAM_Dina : signal is "true";
--attribute mark_debug of u_BRAM_Enb  : signal is "true";
--attribute keep of u_BRAM_Enb : signal is "true";
--attribute mark_debug of u_BRAM_AddrB  : signal is "true";
--attribute keep of u_BRAM_AddrB : signal is "true";
--attribute mark_debug of u_BRAM_DoutB  : signal is "true";
--attribute keep of u_BRAM_DoutB : signal is "true";
--attribute mark_debug of u_BRAM_DoutB_q  : signal is "true";
--attribute keep of u_BRAM_DoutB_q : signal is "true"; 
--attribute mark_debug of u_Send_Packet_Last  : signal is "true";
--attribute keep of u_Send_Packet_Last : signal is "true";
--attribute mark_debug of u_Cnt_Read_Bram  : signal is "true";
--attribute keep of u_Cnt_Read_Bram : signal is "true";   
--attribute mark_debug of a_Tx_Fifo_M_Load_Last  : signal is "true";  
--attribute keep of a_Tx_Fifo_M_Load_Last : signal is "true";
--attribute mark_debug of a_Arb_Endpt_Nr_Int  : signal is "true";  
--attribute keep of a_Arb_Endpt_Nr_Int : signal is "true";   
--attribute mark_debug of u_PE_Endpt_Nr_Int  : signal is "true";  
--attribute keep of u_PE_Endpt_Nr_Int : signal is "true";
--attribute mark_debug of a_Tx_Fifo_S_Axis_Tlast_NPulse  : signal is "true";  
--attribute keep of a_Tx_Fifo_S_Axis_Tlast_NPulse : signal is "true";
--attribute mark_debug of a_Cnt_Load_Bram  : signal is "true";  
--attribute keep of a_Cnt_Load_Bram : signal is "true";
--attribute mark_debug of u_Send_Packet_Pulse_q  : signal is "true";  
--attribute keep of u_Send_Packet_Pulse_q : signal is "true";

--attribute mark_debug of a_BRAM_Load_Counter_Array  : signal is "true";  
--attribute keep of a_BRAM_Load_Counter_Array : signal is "true";
--attribute mark_debug of u_Cnt_Load_Bram_oData  : signal is "true";  
--attribute keep of u_Cnt_Load_Bram_oData : signal is "true";
--attribute mark_debug of u_Cnt_Load_Bram_oValid  : signal is "true";  
--attribute keep of u_Cnt_Load_Bram_oValid : signal is "true";
--attribute mark_debug of a_Cnt_Load_Bram_iPush  : signal is "true";  
--attribute keep of a_Cnt_Load_Bram_iPush : signal is "true";
--attribute mark_debug of a_Cnt_Load_Bram_iRdy  : signal is "true";  
--attribute keep of a_Cnt_Load_Bram_iRdy : signal is "true";
--attribute mark_debug of aReset_Handshake  : signal is "true";  
--attribute keep of aReset_Handshake : signal is "true";
--attribute mark_debug of a_Tx_Fifo_M_Axis_Tlast_NPulse  : signal is "true";  
--attribute keep of a_Tx_Fifo_M_Axis_Tlast_NPulse : signal is "true";
--attribute mark_debug of u_Send_Packet_PulseN  : signal is "true";  
--attribute keep of u_Send_Packet_PulseN : signal is "true";
--attribute mark_debug of u_Send_Packet  : signal is "true";  
--attribute keep of u_Send_Packet : signal is "true";

begin

u_Resetn_N <= not u_Resetn;
a_Arb_Endpt_Nr_Int <= to_integer (unsigned (a_Arb_Endpt_Nr(4 downto 1)));
u_PE_Endpt_Nr_Int <= to_integer (unsigned (u_PE_Endpt_Nr(4 downto 1)));
a_BRAM_Dina <= a_Tx_Fifo_M_Axis_Tdata((a_Byte_Index *8 + 7) downto a_Byte_Index * 8);
u_Endpt_Ready <= u_Cnt_Load_Bram_oValid(u_PE_Endpt_Nr_Int);
				
TX_FIFO_INST: TX_FIFO
  PORT MAP (
    s_aclk => a_Tx_Fifo_S_Aclk,
    s_aresetn => Tx_Fifo_S_Aresetn,
    s_axis_tvalid => a_Tx_Fifo_S_Axis_Tvalid,
    s_axis_tready => a_Tx_Fifo_S_Axis_Tready,
    s_axis_tdata => a_Tx_Fifo_S_Axis_Tdata,
    s_axis_tkeep => a_Tx_Fifo_S_Axis_Tkeep,
    s_axis_tlast => a_Tx_Fifo_S_Axis_Tlast,
    s_axis_tuser => a_Tx_Fifo_S_Axis_Tuser,
    m_axis_tvalid => a_Tx_Fifo_M_Axis_Tvalid,
    m_axis_tready => a_Tx_Fifo_M_Axis_Tready,
    m_axis_tdata => a_Tx_Fifo_M_Axis_Tdata,
    m_axis_tkeep => a_Tx_Fifo_M_Axis_Tkeep,
    m_axis_tlast => a_Tx_Fifo_M_Axis_Tlast,
    m_axis_tuser => open,
    axis_overflow => tx_fifo_axis_overflow,
    axis_underflow => tx_fifo_axis_underflow
  );

BRAM: blk_mem_gen_1
    PORT MAP (
      clka => Axi_Clk,
      ena => a_BRAM_EnA,
      wea => a_BRAM_WeA,
      addra => a_BRAM_AddrA_q,
      dina => a_BRAM_Dina,
      clkb => Ulpi_Clk,
      enb => u_BRAM_Enb,
      addrb => u_BRAM_AddrB,
      doutb => u_BRAM_DoutB
    );

u_BRAM_Enb <= u_BRAM_Enb_Loc or u_Send_Packet_Pulse_q;
a_BRAM_EnA <= '1';  
    
BYTE_INDEX_PROC: process(Axi_Clk)
begin
    if (Axi_Clk 'event and Axi_Clk = '1') then
        if ((Axi_Resetn = '0') or (a_Tx_Fifo_M_Axis_Tlast_NPulse_q = '1')) then
            a_Byte_Index <= 0;
        elsif (a_Byte_Index_Inc = '1') then
            if (a_Byte_Index = (C_S_AXI_DATA_WIDTH)) then
                a_Byte_Index <= 0;
            else    
                a_Byte_Index <= a_Byte_Index + 1;
            end if;    
        end if;
    end if;
end process; 

BRAM_WEA_PROC: process(Axi_Clk)
begin
    if (Axi_Clk 'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_BRAM_WeA <= "0";
        else 
            if ((a_Tx_Fifo_M_Axis_Tvalid = '1') and (a_Tx_Fifo_M_Axis_Tkeep(a_Byte_Index) = '1')and (a_Load_BRAM_Start = '1')) then
                a_BRAM_WeA <= "1";
            else
                a_BRAM_WeA <= "0";    
            end if;    
        end if;
   end if;
end process;   

BRAM_READY_PROC: process(Axi_Clk)
begin
    if (Axi_Clk 'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Tx_Fifo_M_Axis_Tready <= '0'; 
        else 
            if (a_Byte_Index = (C_S_AXI_DATA_WIDTH-1) ) then --if ((a_Byte_Index = (C_S_AXI_DATA_WIDTH-1)) or (a_Tx_Fifo_S_Axis_Tlast_NPulse = '1')) then
                a_Tx_Fifo_M_Axis_Tready <= '1';
            else
                a_Tx_Fifo_M_Axis_Tready <= '0';     
            end if;   
        end if;
    end if;
end process;

BYTE_INDEX_INC_PROC: process(Axi_Clk)
begin
    if (Axi_Clk 'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_Byte_Index_Inc <= '0'; 
        else 
            if ((a_Tx_Fifo_M_Axis_Tvalid = '1') and (a_Load_BRAM_Start = '1')) then
                a_Byte_Index_Inc <= '1';
            else
                a_Byte_Index_Inc <= '0';  
            end if;    
        end if;
    end if;
end process;

LOAD_BRAM_START_PROC: process(Axi_Clk)
begin
    if (Axi_Clk 'event and Axi_Clk = '1') then
        if ((Axi_Resetn = '0') or (a_Tx_Fifo_M_Axis_Tlast_NPulse = '1')) then
            a_Load_BRAM_Start <= '0'; 
        else 
            if (a_Tx_Fifo_S_Axis_Tlast_NPulse = '1') then
                a_Load_BRAM_Start <= '1';
            end if;    
        end if;
    end if;
end process;

BRAM_ADDRESSA_PROC: process(Axi_Clk)
begin
    if (Axi_Clk 'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0') then
            a_BRAM_AddrA <= (others => '0');
            a_BRAM_AddrA_q <= (others => '0');
        else
            a_BRAM_AddrA_q <= a_BRAM_AddrA;
            if (a_DMA_Transfer_Start_Pulse = '1') then
                a_BRAM_AddrA <= a_BRAM_Base_AddrA(a_Arb_Endpt_Nr_Int);
            elsif ((a_Tx_Fifo_M_Axis_Tvalid = '1') and (a_Tx_Fifo_M_Axis_Tkeep(a_Byte_Index) = '1') and (a_Load_BRAM_Start = '1')) then
                a_BRAM_AddrA <= std_logic_vector( to_unsigned((to_integer(unsigned(a_BRAM_AddrA)) + 1),12) );   
            end if;    
        end if;
    end if;
end process;     

DMA_TRANSFER_START_PROC: process(Axi_Clk)
begin
    if (Axi_Clk 'event and Axi_Clk = '1') then
        if (Axi_Resetn = '0' or a_Tx_Fifo_M_Axis_Tlast_q = '1') then
            a_DMA_Transfer_Start <= '0';
        elsif (a_Tx_Fifo_S_Axis_Tvalid = '1') then
            a_DMA_Transfer_Start <= '1';   
        end if;
    end if;
end process; 

DMA_TRANSFER_START_PULSE_PROC: process (Axi_Clk)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
       if (Axi_Resetn = '0') then 
          a_DMA_Transfer_Start_Pulse <= '0';
          a_DMA_Transfer_Start_q <= '0';
       else
         a_DMA_Transfer_Start_q <= a_DMA_Transfer_Start;
         a_DMA_Transfer_Start_Pulse <= a_DMA_Transfer_Start and (not a_DMA_Transfer_Start_q); 
       end if;
    end if;              
end process; 

a_Tx_Fifo_M_Load_Last <= '1' when ((a_Tx_Fifo_M_Axis_Tlast = '1') and (a_Byte_Index = 3)) else '0';

M_LAST_NPULSE_PROC: process (Axi_Clk)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
       if (Axi_Resetn = '0') then 
          a_Tx_Fifo_M_Axis_Tlast_NPulse <= '0';
          a_Tx_Fifo_M_Axis_Tlast_NPulse_q <= '0';
          a_Tx_Fifo_M_Axis_Tlast_q <= '0';
          a_Cnt_Load_Bram_Rst <= '0';
       else
         a_Tx_Fifo_M_Axis_Tlast_q <= a_Tx_Fifo_M_Load_Last;
         a_Tx_Fifo_M_Axis_Tlast_NPulse <= a_Tx_Fifo_M_Load_Last and  (not a_Tx_Fifo_M_Axis_Tlast_q); 
         a_Cnt_Load_Bram_Rst <= a_Tx_Fifo_M_Axis_Tlast_NPulse_q;
         a_Tx_Fifo_M_Axis_Tlast_NPulse_q <= a_Tx_Fifo_M_Axis_Tlast_NPulse;
       end if;
    end if;              
end process;

S_LAST_NPULSE_PROC: process (Axi_Clk)
begin
    if (Axi_Clk'event and Axi_Clk = '1') then
       if (Axi_Resetn = '0') then 
          a_Tx_Fifo_S_Axis_Tlast_NPulse <= '0';
          a_Tx_Fifo_s_Axis_Tlast_q <= '0';
       else
         a_Tx_Fifo_S_Axis_Tlast_q <= a_Tx_Fifo_S_Axis_Tlast;
         a_Tx_Fifo_S_Axis_Tlast_NPulse <= (not a_Tx_Fifo_S_Axis_Tlast) and  a_Tx_Fifo_S_Axis_Tlast_q; 
       end if;
    end if;              
end process;  

BRAM_LOAD_COUNTER_PROC: process (Axi_Clk)  -- Ulpi_Clk = 60MHz => T = 0.01666666 Us
begin
	if (Axi_Clk' event and Axi_Clk = '1') then
		if ((a_Cnt_Load_Bram_Rst = '1') or (Axi_Resetn = '0')) then
			a_Cnt_Load_Bram <= (others => '0');
		elsif (a_BRAM_WeA = "1") then
			a_Cnt_Load_Bram <= a_Cnt_Load_Bram + '1';
		end if;
	end if;
end process; 

BRAM_LOAD_PROC: process (Axi_Clk)  -- Ulpi_Clk = 60MHz => T = 0.01666666 Us
begin
	if (Axi_Clk' event and Axi_Clk = '1') then
		if (Axi_Resetn = '0') then
			a_BRAM_Load_Counter_Array <= (others => (others => '0'));
		elsif (a_Tx_Fifo_M_Axis_Tlast_NPulse_q = '1') then
			a_BRAM_Load_Counter_Array(a_Arb_Endpt_Nr_Int) <= (a_Cnt_Load_Bram - '1');
		end if;
	end if;
end process; 


---------------------------------------------------------------------------------------------------  

TDATA_PROC: process(u_Tx_Data_En, u_Tx_Data_En_q, u_BRAM_DoutB, u_BRAM_DoutB_q)
begin
    if (u_Tx_Data_En = '0') then
        u_Tx_Data <= u_BRAM_DoutB_q;
    else
        u_Tx_Data <= u_BRAM_DoutB;
    end if;
end process; 

REG_AXIS_TDATA_PROC: process(Ulpi_Clk)
begin
    if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
        if (u_Resetn = '0') then
            u_BRAM_DoutB_q <= (others => '0');
            latency_comp_out <= '0';
        else
            latency_comp_out <= latency_comp_in;
            if((u_BRAM_Enb = '1') or (u_Cnt_Read_Bram = u_Cnt_Load_Bram_oData(u_PE_Endpt_Nr_Int)) or (u_Send_Packet_Pulse_q = '1')) then  
                u_BRAM_DoutB_q <= u_BRAM_DoutB;
            end if;
        end if;
    end if;
end process;   

SEND_PACKET_PULSE_PROC: process (Ulpi_Clk)
begin
    if (Ulpi_Clk'event and Ulpi_Clk = '1') then
       if (u_Resetn = '0') then 
          u_Send_Packet_Pulse <= '0';
          u_Send_Packet_PulseN <= '0';
          u_Send_Packet_q <= '0';
          u_Send_Packet_Pulse_q <= '0';
       else
         u_Send_Packet_q <= u_Send_Packet;
         u_Send_Packet_Pulse <= u_Send_Packet and (not u_Send_Packet_q); 
         u_Send_Packet_PulseN <= (not u_Send_Packet) and  u_Send_Packet_q;
         u_Send_Packet_Pulse_q <= u_Send_Packet_Pulse;
       end if;
    end if;              
end process; 

DELAY_PROC: process (Ulpi_Clk)
begin
    if (Ulpi_Clk'event and Ulpi_Clk = '1') then
       if (u_Resetn = '0') then 
          u_Tx_Data_En_q <= '0';
       else
         u_Tx_Data_En_q <= u_Tx_Data_En;
       end if;
    end if;              
end process;    				

ENB_PROC: process (u_Send_Packet, u_Tx_Data_En, u_Tx_Data_En_q)
begin
  --if (Axi_Clk'event and Axi_Clk = '1') then
    if (u_Send_Packet = '1') then
        if (u_Tx_Data_En = '1') then     
            u_BRAM_Enb_Loc <= '1';
        --elsif ((u_Tx_Data_En = '0') and (u_Tx_Data_En_q = '1')) then
        --    u_BRAM_Enb_Loc <= '1';
        else
            u_BRAM_Enb_Loc <= '0';
        end if;    
    else
      u_BRAM_Enb_Loc <= '0';
    end if;
  --end if;              
end process;   				

BRAM_ADDRESSB_PROC: process(Ulpi_Clk)
begin
    if (Ulpi_Clk 'event and Ulpi_Clk = '1') then
        if (u_Resetn = '0') then
            u_BRAM_AddrB <= (others => '0');
        else
            if (u_Send_Packet_Pulse = '1') then
                u_BRAM_AddrB <= u_BRAM_Base_AddrB(u_PE_Endpt_Nr_Int);
            elsif ((u_Send_Packet = '1') and (u_BRAM_Enb = '1')) then
                u_BRAM_AddrB <= std_logic_vector( to_unsigned((to_integer(unsigned(u_BRAM_AddrB)) + 1),12) );   
            end if;    
        end if;
    end if;
end process; 

u_Cnt_Read_Bram_Rst <= u_Send_Packet_Pulse;

BRAM_READ_COUNTER_PROC: process (Ulpi_Clk)  -- Ulpi_Clk = 60MHz => T = 0.01666666 Us
begin
	if (Ulpi_Clk' event and Ulpi_Clk = '1') then
		if ((u_Cnt_Read_Bram_Rst = '1') or (u_Resetn = '0')) then
			u_Cnt_Read_Bram <= (others => '0');
		elsif (u_BRAM_Enb = '1') then
			u_Cnt_Read_Bram <= u_Cnt_Read_Bram + '1';
		end if;
	end if;
end process; 


LAST_PROC: process (Ulpi_Clk)  -- Ulpi_Clk = 60MHz => T = 0.01666666 Us
begin
    if (Ulpi_Clk' event and Ulpi_Clk = '1') then
	   if (u_Resetn = '0') then
			u_Send_Packet_Last <= '0';
	   elsif((u_Send_Packet = '1') and (u_Tx_Data_En = '1')) then
		  if ((u_Cnt_Load_Bram_oData(u_PE_Endpt_Nr_Int) - '1') = u_Cnt_Read_Bram) then-- std_logic_vector( to_unsigned((to_integer(unsigned(u_Cnt_Read_Bram)) - 3),12))) then
		      u_Send_Packet_Last <= '1';
		  else
		      u_Send_Packet_Last <= '0';
		  end if;
	  elsif ((u_Send_Packet_Pulse = '1') and (u_Cnt_Load_Bram_oData(u_PE_Endpt_Nr_Int) = "0000000000000001")) then
	      u_Send_Packet_Last <= '1';
	  else
		  u_Send_Packet_Last <= '0';  
	  end if;
	end if;
end process;    
-- u_Cnt_Load_Bram_oValid(u_PE_Endpt_Nr_Int)
MULTIPLE_HANDSHAKE : for i in 0 to MAX_NR_ENDP generate      
Inst_HandshakeData_Count: entity work.HandshakeData  
    GENERIC MAP (
        kDataWidth => 12)
        PORT MAP(
        InClk => Axi_Clk,
        OutClk => Ulpi_Clk,
        iData => a_BRAM_Load_Counter_Array(i),
        oData => u_Cnt_Load_Bram_oData(i),
        iPush => a_Cnt_Load_Bram_iPush(i),
        iRdy => a_Cnt_Load_Bram_iRdy(i),
        oAck => u_Cnt_Load_Bram_oValid(i),
        oValid => u_Cnt_Load_Bram_oValid(i),
        aReset => aReset_Handshake(i)
    ); 
end generate;

--aReset_Handshake <= (u_Resetn_N or (u_Send_Packet_PulseN));

ARESETN_PROC: process (Axi_Clk)  -- Ulpi_Clk = 60MHz => T = 0.01666666 Us
begin
    if (Ulpi_Clk' event and Ulpi_Clk = '1') then
        if (u_Resetn = '0') then
			aReset_Handshake <= (others => ('1'));
		else
		    for index in 0 to MAX_NR_ENDP loop
                aReset_Handshake(index) <= aReset_Handshake_Loc(index) or u_Resetn_N; 
            end loop;    	
		end if;
	end if;
end process;

ARESETN_LOC_PROC: process (Axi_Clk)  -- Ulpi_Clk = 60MHz => T = 0.01666666 Us
begin
    if (Ulpi_Clk' event and Ulpi_Clk = '1') then
        if (u_Resetn = '0') then
			aReset_Handshake_Loc <= (others => ('0'));
		else
            aReset_Handshake_Loc(u_PE_Endpt_Nr_Int) <= u_Send_Packet_PulseN; 	
		end if;
	end if;
end process; 

IPUSH_PROC: process (Axi_Clk)  -- Ulpi_Clk = 60MHz => T = 0.01666666 Us
begin
	if (Axi_Clk' event and Axi_Clk = '1') then
		if (Axi_Resetn = '0') then
			a_Cnt_Load_Bram_iPush <= (others => ('0'));
		else
		  if ((a_Cnt_Load_Bram_iRdy(a_Arb_Endpt_Nr_Int) = '1') and (a_Tx_Fifo_M_Axis_Tlast_NPulse_q = '1'))then
			a_Cnt_Load_Bram_iPush(a_Arb_Endpt_Nr_Int) <= '1';
		  else
		    a_Cnt_Load_Bram_iPush(a_Arb_Endpt_Nr_Int) <= '0';
		  end if;  	
		end if;
	end if;
end process; 


end Behavioral;
