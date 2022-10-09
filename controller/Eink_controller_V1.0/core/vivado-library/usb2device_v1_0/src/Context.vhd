-------------------------------------------------------------------------------
--
-- File: Context.vhd
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
-- This module implements the context memory (Queue Heads, Transfer Descriptors)
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

entity Context is
	generic (
    MAX_NR_ENDP           : integer    := 1
    );
    Port ( CLK : in STD_LOGIC;
           RESETN : in STD_LOGIC;
           ENDPT_NR : in integer range 0 to (MAX_NR_ENDP*2+1);
--           ENDPT_NR_PD : in integer range 0 to 22;
           RD_EN : in STD_LOGIC; 
           WR_EN : in STD_LOGIC;
           dTD_TOTAL_BYTES_WR_EN  : in STD_LOGIC;
           dTD_STATUS_WR_EN : in STD_LOGIC; 
           dQH_CURRENT_dTD_POINTER_wr_EN  : in STD_LOGIC;
           dQH_NEXT_dTD_POINTER_wr_EN  : in STD_LOGIC;
           dQH_SETUP_BUFFER_wr_EN : in STD_LOGIC;
           
           --READ
           dQH_MULT_rd : out STD_LOGIC_VECTOR (1 downto 0);
           dQH_ZLT_rd : out STD_LOGIC;
--           pe_dQH_ZLT_rd : out STD_LOGIC;
           dQH_MAX_PACKET_LENGTH_rd : out STD_LOGIC_VECTOR (10 downto 0);
--           dQH_MAX_PACKET_LENGTH_rd_pd : out STD_LOGIC_VECTOR (10 downto 0);
           dQH_IOS_rd : out STD_LOGIC;
           dQH_CURRENT_dTD_POINTER_rd : out STD_LOGIC_VECTOR (26 downto 0);
           dQH_NEXT_dTD_POINTER_rd : out STD_LOGIC_VECTOR (26 downto 0);
           dQH_T_rd : out STD_LOGIC;
           dQH_SETUP_BUFFER_BYTES_3_0_rd : out STD_LOGIC_VECTOR (31 downto 0);
           dQH_SETUP_BUFFER_BYTES_7_4_rd : out STD_LOGIC_VECTOR (31 downto 0);
              
           dTD_TOTAL_BYTES_rd : out STD_LOGIC_VECTOR (14 downto 0);
           dTD_IOC_rd : out STD_LOGIC;
           dTD_C_PAGE_rd : out STD_LOGIC_VECTOR (2 downto 0);
           dTD_MULT_rd : out STD_LOGIC_VECTOR (1 downto 0);
           dTD_STATUS_rd : out STD_LOGIC_VECTOR (7 downto 0);
           dTD_PAGE0_rd : out STD_LOGIC_VECTOR (19 downto 0);
           dTD_PAGE1_rd : out STD_LOGIC_VECTOR (19 downto 0);
           dTD_PAGE2_rd : out STD_LOGIC_VECTOR (19 downto 0);
           dTD_PAGE3_rd : out STD_LOGIC_VECTOR (19 downto 0);
           dTD_PAGE4_rd : out STD_LOGIC_VECTOR (19 downto 0);
           dTD_CURRENT_OFFSET_rd : out STD_LOGIC_VECTOR (11 downto 0);
           --WRITE
           dQH_MULT_wr : in STD_LOGIC_VECTOR (1 downto 0);
           dQH_ZLT_wr : in STD_LOGIC;
           dQH_MAX_PACKET_LENGTH_wr : in STD_LOGIC_VECTOR (10 downto 0);
           dQH_IOS_wr : in STD_LOGIC;
           dQH_CURRENT_dTD_POINTER_wr : in STD_LOGIC_VECTOR (26 downto 0);
           dQH_NEXT_dTD_POINTER_wr : in STD_LOGIC_VECTOR (26 downto 0);
           dQH_T_wr : in STD_LOGIC;
           dQH_SETUP_BUFFER_BYTES_3_0_wr : in STD_LOGIC_VECTOR (31 downto 0);
           dQH_SETUP_BUFFER_BYTES_7_4_wr : in STD_LOGIC_VECTOR (31 downto 0);
              
           dTD_TOTAL_BYTES_wr : in STD_LOGIC_VECTOR (14 downto 0);
           dTD_IOC_wr : in STD_LOGIC;
           dTD_C_PAGE_wr : in STD_LOGIC_VECTOR (2 downto 0);
           dTD_MULT_wr : in STD_LOGIC_VECTOR (1 downto 0);
           dTD_STATUS_wr : in STD_LOGIC_VECTOR (7 downto 0);
           dTD_PAGE0_wr : in STD_LOGIC_VECTOR (19 downto 0);
           dTD_PAGE1_wr : in STD_LOGIC_VECTOR (19 downto 0);
           dTD_PAGE2_wr : in STD_LOGIC_VECTOR (19 downto 0);
           dTD_PAGE3_wr : in STD_LOGIC_VECTOR (19 downto 0);
           dTD_PAGE4_wr : in STD_LOGIC_VECTOR (19 downto 0);
           dTD_CURRENT_OFFSET_wr : in STD_LOGIC_VECTOR (11 downto 0)
          );
end Context;

architecture Behavioral of Context is

    type dQH is
        record
            dQH_MULT :  STD_LOGIC_VECTOR (1 downto 0);
            dQH_ZLT :  STD_LOGIC;
            dQH_MAX_PACKET_LENGTH :  STD_LOGIC_VECTOR (10 downto 0);
            dQH_IOS :  STD_LOGIC;
            dQH_CURRENT_dTD_POINTER :  STD_LOGIC_VECTOR (26 downto 0);
            dQH_NEXT_dTD_POINTER :  STD_LOGIC_VECTOR (26 downto 0);
            dQH_T :  STD_LOGIC;
            dQH_SETUP_BUFFER_BYTES_3_0 :  STD_LOGIC_VECTOR (31 downto 0);
            dQH_SETUP_BUFFER_BYTES_7_4 :  STD_LOGIC_VECTOR (31 downto 0);
     
            dTD_TOTAL_BYTES : STD_LOGIC_VECTOR (14 downto 0);
            dTD_IOC : STD_LOGIC;
            dTD_C_PAGE : STD_LOGIC_VECTOR (2 downto 0);
            dTD_MULT : STD_LOGIC_VECTOR (1 downto 0);
            dTD_STATUS : STD_LOGIC_VECTOR (7 downto 0);
            dTD_PAGE0 : STD_LOGIC_VECTOR (19 downto 0);
            dTD_PAGE1 : STD_LOGIC_VECTOR (19 downto 0);
            dTD_PAGE2 : STD_LOGIC_VECTOR (19 downto 0);
            dTD_PAGE3 : STD_LOGIC_VECTOR (19 downto 0);
            dTD_PAGE4 : STD_LOGIC_VECTOR (19 downto 0);
            dTD_CURRENT_OFFSET : STD_LOGIC_VECTOR (11 downto 0);
     end record;
     
    type array_DQH is array ((MAX_NR_ENDP*2+1) downto 0) of dQH; 
    signal dQH_reg : array_DQH;
    
    signal byte_index	: integer;
    
    signal dQH_MULT_rd_mux : STD_LOGIC_VECTOR (1 downto 0);
    signal dQH_ZLT_rd_mux : STD_LOGIC;
    signal dQH_MAX_PACKET_LENGTH_rd_mux : STD_LOGIC_VECTOR (10 downto 0);
    signal dQH_IOS_rd_mux : STD_LOGIC;
    signal dQH_CURRENT_dTD_POINTER_rd_mux : STD_LOGIC_VECTOR (26 downto 0);
    signal dQH_NEXT_dTD_POINTER_rd_mux : STD_LOGIC_VECTOR (26 downto 0);
    signal dQH_T_rd_mux : STD_LOGIC;
    signal dQH_SETUP_BUFFER_BYTES_3_0_rd_mux : STD_LOGIC_VECTOR (31 downto 0);
    signal dQH_SETUP_BUFFER_BYTES_7_4_rd_mux : STD_LOGIC_VECTOR (31 downto 0);
              
    signal dTD_TOTAL_BYTES_rd_mux : STD_LOGIC_VECTOR (14 downto 0);
    signal dTD_IOC_rd_mux : STD_LOGIC;
    signal dTD_C_PAGE_rd_mux : STD_LOGIC_VECTOR (2 downto 0);
    signal dTD_MULT_rd_mux : STD_LOGIC_VECTOR (1 downto 0);
    signal dTD_STATUS_rd_mux : STD_LOGIC_VECTOR (7 downto 0);
    signal dTD_PAGE0_rd_mux : STD_LOGIC_VECTOR (19 downto 0);
    signal dTD_PAGE1_rd_mux : STD_LOGIC_VECTOR (19 downto 0);
    signal dTD_PAGE2_rd_mux : STD_LOGIC_VECTOR (19 downto 0);
    signal dTD_PAGE3_rd_mux : STD_LOGIC_VECTOR (19 downto 0);
    signal dTD_PAGE4_rd_mux : STD_LOGIC_VECTOR (19 downto 0);
    signal dTD_CURRENT_OFFSET_rd_mux : STD_LOGIC_VECTOR (11 downto 0);
    
--    attribute mark_debug : string;
--    attribute keep : string;
--    attribute mark_debug of dQH_reg : signal is "true";
--    attribute keep of dQH_reg : signal is "true"; 
         
begin

    dQH_MULT_rd <= dQH_MULT_rd_mux;
    dQH_ZLT_rd <=  dQH_ZLT_rd_mux;
    dQH_MAX_PACKET_LENGTH_rd <= dQH_MAX_PACKET_LENGTH_rd_mux;
    dQH_IOS_rd <= dQH_IOS_rd_mux;
    dQH_CURRENT_dTD_POINTER_rd <= dQH_CURRENT_dTD_POINTER_rd_mux;
    dQH_NEXT_dTD_POINTER_rd <= dQH_NEXT_dTD_POINTER_rd_mux;
    dQH_T_rd <= dQH_T_rd_mux;
    dQH_SETUP_BUFFER_BYTES_3_0_rd <= dQH_SETUP_BUFFER_BYTES_3_0_rd_mux;
    dQH_SETUP_BUFFER_BYTES_7_4_rd <= dQH_SETUP_BUFFER_BYTES_7_4_rd_mux;
              
    dTD_TOTAL_BYTES_rd <= dTD_TOTAL_BYTES_rd_mux;
    dTD_IOC_rd <= dTD_IOC_rd_mux;
    dTD_C_PAGE_rd <= dTD_C_PAGE_rd_mux;
    dTD_MULT_rd <= dTD_MULT_rd_mux;
    dTD_STATUS_rd <= dTD_STATUS_rd_mux;
    dTD_PAGE0_rd <= dTD_PAGE0_rd_mux;
    dTD_PAGE1_rd <= dTD_PAGE1_rd_mux;
    dTD_PAGE2_rd <= dTD_PAGE2_rd_mux;
    dTD_PAGE3_rd <= dTD_PAGE3_rd_mux;
    dTD_PAGE4_rd <= dTD_PAGE4_rd_mux;
    dTD_CURRENT_OFFSET_rd <= dTD_CURRENT_OFFSET_rd_mux;
                 
	  process(CLK)                                            
	  begin                                                                
	    if (rising_edge (CLK)) then                                 
	      if (RESETN = '0') then                                   
                dQH_MULT_rd_mux <= (others => '0');
                dQH_ZLT_rd_mux <= '0';
                dQH_MAX_PACKET_LENGTH_rd_mux <= (others => '0');
                dQH_IOS_rd_mux <= '0';
                dQH_CURRENT_dTD_POINTER_rd_mux <= (others => '0');
                dQH_NEXT_dTD_POINTER_rd_mux <= (others => '0');
                dQH_T_rd_mux <= '0';
                dQH_SETUP_BUFFER_BYTES_3_0_rd_mux <= (others => '0');
                dQH_SETUP_BUFFER_BYTES_7_4_rd_mux <= (others => '0');
                dTD_TOTAL_BYTES_rd_mux <= (others => '0');
                dTD_IOC_rd_mux <= '0';
                dTD_C_PAGE_rd_mux <= (others => '0');
                dTD_MULT_rd_mux <= (others => '0');
                dTD_STATUS_rd_mux <= (others => '0');
                dTD_PAGE0_rd_mux <= (others => '0');
                dTD_PAGE1_rd_mux <= (others => '0');
                dTD_PAGE2_rd_mux <= (others => '0');
                dTD_PAGE3_rd_mux <= (others => '0');
                dTD_PAGE4_rd_mux <= (others => '0');
                dTD_CURRENT_OFFSET_rd_mux <= (others => '0'); 
--                pe_dQH_ZLT_rd  <= '0';
--                dQH_MAX_PACKET_LENGTH_rd_pd <= (others => '0');                                         
	      else
	            dQH_MULT_rd_mux <= dQH_reg(ENDPT_NR).dQH_MULT;
                dQH_ZLT_rd_mux <= dQH_reg(ENDPT_NR). dQH_ZLT;
                dQH_MAX_PACKET_LENGTH_rd_mux <= dQH_reg(ENDPT_NR). dQH_MAX_PACKET_LENGTH;
                dQH_IOS_rd_mux <= dQH_reg(ENDPT_NR). dQH_IOS;
                dQH_CURRENT_dTD_POINTER_rd_mux <= dQH_reg(ENDPT_NR). dQH_CURRENT_dTD_POINTER;
                dQH_NEXT_dTD_POINTER_rd_mux <= dQH_reg(ENDPT_NR). dQH_NEXT_dTD_POINTER;
                dQH_T_rd_mux <= dQH_reg(ENDPT_NR). dQH_T;
                dQH_SETUP_BUFFER_BYTES_3_0_rd_mux <= dQH_reg(ENDPT_NR). dQH_SETUP_BUFFER_BYTES_3_0;
                dQH_SETUP_BUFFER_BYTES_7_4_rd_mux <= dQH_reg(ENDPT_NR). dQH_SETUP_BUFFER_BYTES_7_4;
                dTD_TOTAL_BYTES_rd_mux <= dQH_reg(ENDPT_NR). dTD_TOTAL_BYTES;
                dTD_IOC_rd_mux <= dQH_reg(ENDPT_NR). dTD_IOC;
                dTD_C_PAGE_rd_mux <= dQH_reg(ENDPT_NR). dTD_C_PAGE;
                dTD_MULT_rd_mux <= dQH_reg(ENDPT_NR). dTD_MULT;
                dTD_STATUS_rd_mux <= dQH_reg(ENDPT_NR). dTD_STATUS;
                dTD_PAGE0_rd_mux <= dQH_reg(ENDPT_NR). dTD_PAGE0;
                dTD_PAGE1_rd_mux <= dQH_reg(ENDPT_NR). dTD_PAGE1;
                dTD_PAGE2_rd_mux <= dQH_reg(ENDPT_NR). dTD_PAGE2;
                dTD_PAGE3_rd_mux <= dQH_reg(ENDPT_NR). dTD_PAGE3;
                dTD_PAGE4_rd_mux <= dQH_reg(ENDPT_NR). dTD_PAGE4;
                dTD_CURRENT_OFFSET_rd_mux <= dQH_reg(ENDPT_NR). dTD_CURRENT_OFFSET;  
--                pe_dQH_ZLT_rd  <= dQH_reg(ENDPT_NR_PD). dQH_ZLT;
--                dQH_MAX_PACKET_LENGTH_rd_pd <= dQH_reg(ENDPT_NR_PD). dQH_MAX_PACKET_LENGTH;                                                                                                    
	      end if;
	   end if;                                                            
    end process; 
    
	process(CLK)                                            
    begin                                                                
      if (rising_edge (CLK)) then                                 
        if (RESETN = '0') then                                   
          for index in 0 to (MAX_NR_ENDP*2+1) loop
              dQH_reg(index). dQH_MULT <= (others => '0');
              dQH_reg(index). dQH_ZLT <= '0';
              dQH_reg(index). dQH_MAX_PACKET_LENGTH <= (others => '0');
              dQH_reg(index). dQH_IOS <= '0';
              dQH_reg(index). dQH_CURRENT_dTD_POINTER <= (others => '0');
              dQH_reg(index). dQH_NEXT_dTD_POINTER <= (others => '0');
              dQH_reg(index). dQH_T <= '0';
              dQH_reg(index). dQH_SETUP_BUFFER_BYTES_3_0 <= (others => '0');
              dQH_reg(index). dQH_SETUP_BUFFER_BYTES_7_4 <= (others => '0');
              dQH_reg(index). dTD_TOTAL_BYTES <= (others => '0');
              dQH_reg(index). dTD_IOC <= '0';
              dQH_reg(index). dTD_C_PAGE <= (others => '0');
              dQH_reg(index). dTD_MULT <= (others => '0');
              dQH_reg(index). dTD_STATUS <= (others => '0');
              dQH_reg(index). dTD_PAGE0 <= (others => '0');
              dQH_reg(index). dTD_PAGE1 <= (others => '0');
              dQH_reg(index). dTD_PAGE2 <= (others => '0');
              dQH_reg(index). dTD_PAGE3 <= (others => '0');
              dQH_reg(index). dTD_PAGE4 <= (others => '0');
              dQH_reg(index). dTD_CURRENT_OFFSET <= (others => '0');  
          end loop;                                           
        elsif (WR_EN = '1') then
             dQH_reg(ENDPT_NR). dQH_MULT <= dQH_MULT_wr;
             dQH_reg(ENDPT_NR). dQH_ZLT <= dQH_ZLT_wr;
             dQH_reg(ENDPT_NR). dQH_MAX_PACKET_LENGTH <= dQH_MAX_PACKET_LENGTH_wr;
             dQH_reg(ENDPT_NR). dQH_IOS <=  dQH_IOS_wr;
             --dQH_reg(ENDPT_NR). dQH_CURRENT_dTD_POINTER <= dQH_CURRENT_dTD_POINTER_wr;
             dQH_reg(ENDPT_NR). dQH_NEXT_dTD_POINTER <= dQH_NEXT_dTD_POINTER_wr;
             dQH_reg(ENDPT_NR). dQH_T <=  dQH_T_wr;
             dQH_reg(ENDPT_NR). dQH_SETUP_BUFFER_BYTES_3_0 <= dQH_SETUP_BUFFER_BYTES_3_0_wr;
             dQH_reg(ENDPT_NR). dQH_SETUP_BUFFER_BYTES_7_4 <= dQH_SETUP_BUFFER_BYTES_7_4_wr;
             dQH_reg(ENDPT_NR). dTD_TOTAL_BYTES <= dTD_TOTAL_BYTES_wr;
             dQH_reg(ENDPT_NR). dTD_IOC <=  dTD_IOC_wr;
             dQH_reg(ENDPT_NR). dTD_C_PAGE <= dTD_C_PAGE_wr;
             dQH_reg(ENDPT_NR). dTD_MULT <= dTD_MULT_wr;
             dQH_reg(ENDPT_NR). dTD_STATUS <= dTD_STATUS_wr;
             dQH_reg(ENDPT_NR). dTD_PAGE0 <= dTD_PAGE0_wr;
             dQH_reg(ENDPT_NR). dTD_PAGE1 <= dTD_PAGE1_wr;
             dQH_reg(ENDPT_NR). dTD_PAGE2 <= dTD_PAGE2_wr;
             dQH_reg(ENDPT_NR). dTD_PAGE3 <= dTD_PAGE3_wr;
             dQH_reg(ENDPT_NR). dTD_PAGE4 <= dTD_PAGE4_wr;
             dQH_reg(ENDPT_NR). dTD_CURRENT_OFFSET <= dTD_CURRENT_OFFSET_wr;
        elsif (dTD_TOTAL_BYTES_WR_EN = '1') then
            dQH_reg(ENDPT_NR). dTD_TOTAL_BYTES <= dTD_TOTAL_BYTES_wr;            
        elsif (dQH_CURRENT_dTD_POINTER_wr_EN = '1') then
            dQH_reg(ENDPT_NR). dQH_CURRENT_dTD_POINTER <= dQH_CURRENT_dTD_POINTER_wr;
        elsif (dQH_NEXT_dTD_POINTER_wr_EN = '1') then
            dQH_reg(ENDPT_NR). dQH_NEXT_dTD_POINTER <= dQH_NEXT_dTD_POINTER_wr;
        elsif (dTD_STATUS_WR_EN = '1') then 
            dQH_reg(ENDPT_NR). dTD_STATUS <= dTD_STATUS_wr;   
        elsif (dQH_SETUP_BUFFER_wr_EN = '1') then
            dQH_reg(ENDPT_NR). dQH_SETUP_BUFFER_BYTES_3_0 <= dQH_SETUP_BUFFER_BYTES_3_0_wr;
            dQH_reg(ENDPT_NR). dQH_SETUP_BUFFER_BYTES_7_4 <= dQH_SETUP_BUFFER_BYTES_7_4_wr;                                                                                                          
        end if;
     end if;                                                            
  end process;        

end Behavioral;
