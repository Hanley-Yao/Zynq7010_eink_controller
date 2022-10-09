-------------------------------------------------------------------------------
--
-- File: Context_to_Stream.vhd
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
-- This module handles control data transfers through the DMA module
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

entity Context_to_Stream is
    Port (
        CLK : in STD_LOGIC;
        RESETN : in STD_LOGIC;
        ind_statte_axistream : out std_logic_vector(4 downto 0);
        
        dQH_RD : in STD_LOGIC;
        dQH_WR : in STD_LOGIC;
        dTD_RD : in STD_LOGIC;
        dTD_WR : in STD_LOGIC;
        SETUP_WR : in STD_LOGIC;
        dQH_WR_EN : out STD_LOGIC;
        
        s_axis_mm2s_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_mm2s_tkeep : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        s_axis_mm2s_tvalid : IN STD_LOGIC;
        s_axis_mm2s_tready : OUT STD_LOGIC;
        s_axis_mm2s_tlast : IN STD_LOGIC;    
    
        m_axis_s2mm_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_s2mm_tkeep : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        m_axis_s2mm_tvalid : OUT STD_LOGIC;
        m_axis_s2mm_tready : IN STD_LOGIC;
        m_axis_s2mm_tlast : OUT STD_LOGIC;
        
        --READ S2MM
        dQH_MULT_rd : in STD_LOGIC_VECTOR (1 downto 0);
        dQH_ZLT_rd : in STD_LOGIC;
        dQH_MAX_PACKET_LENGTH_rd : in STD_LOGIC_VECTOR (10 downto 0);
        dQH_IOS_rd : in STD_LOGIC;
        dQH_CURRENT_dTD_POINTER_rd : in STD_LOGIC_VECTOR (26 downto 0);
        dQH_NEXT_dTD_POINTER_rd : in STD_LOGIC_VECTOR (26 downto 0);
        dQH_T_rd : in STD_LOGIC;
        dQH_SETUP_BUFFER_BYTES_3_0_rd : in STD_LOGIC_VECTOR (31 downto 0);
        dQH_SETUP_BUFFER_BYTES_7_4_rd : in STD_LOGIC_VECTOR (31 downto 0);
           
        dTD_TOTAL_BYTES_rd : in STD_LOGIC_VECTOR (14 downto 0);
        dTD_IOC_rd : in STD_LOGIC;
        dTD_C_PAGE_rd : in STD_LOGIC_VECTOR (2 downto 0);
        dTD_MULT_rd : in STD_LOGIC_VECTOR (1 downto 0);
        dTD_STATUS_rd : in STD_LOGIC_VECTOR (7 downto 0);
        dTD_PAGE0_rd : in STD_LOGIC_VECTOR (19 downto 0);
        dTD_PAGE1_rd : in STD_LOGIC_VECTOR (19 downto 0);
        dTD_PAGE2_rd : in STD_LOGIC_VECTOR (19 downto 0);
        dTD_PAGE3_rd : in STD_LOGIC_VECTOR (19 downto 0);
        dTD_PAGE4_rd : in STD_LOGIC_VECTOR (19 downto 0);
        dTD_CURRENT_OFFSET_rd : in STD_LOGIC_VECTOR (11 downto 0);
        --WRITE MM2S
        dQH_MULT_wr : out STD_LOGIC_VECTOR (1 downto 0);
        dQH_ZLT_wr : out STD_LOGIC;
        dQH_MAX_PACKET_LENGTH_wr : out STD_LOGIC_VECTOR (10 downto 0);
        dQH_IOS_wr : out STD_LOGIC;
        dQH_CURRENT_dTD_POINTER_wr : out STD_LOGIC_VECTOR (26 downto 0);
        dQH_NEXT_dTD_POINTER_wr : out STD_LOGIC_VECTOR (26 downto 0);
        dQH_T_wr : out STD_LOGIC;
        dQH_SETUP_BUFFER_BYTES_3_0_wr : out STD_LOGIC_VECTOR (31 downto 0);
        dQH_SETUP_BUFFER_BYTES_7_4_wr : out STD_LOGIC_VECTOR (31 downto 0);
           
        dTD_TOTAL_BYTES_wr : out STD_LOGIC_VECTOR (14 downto 0);
        dTD_IOC_wr : out STD_LOGIC;
        dTD_C_PAGE_wr : out STD_LOGIC_VECTOR (2 downto 0);
        dTD_MULT_wr : out STD_LOGIC_VECTOR (1 downto 0);
        dTD_STATUS_wr : out STD_LOGIC_VECTOR (7 downto 0);
        dTD_PAGE0_wr : out STD_LOGIC_VECTOR (19 downto 0);
        dTD_PAGE1_wr : out STD_LOGIC_VECTOR (19 downto 0);
        dTD_PAGE2_wr : out STD_LOGIC_VECTOR (19 downto 0);
        dTD_PAGE3_wr : out STD_LOGIC_VECTOR (19 downto 0);
        dTD_PAGE4_wr : out STD_LOGIC_VECTOR (19 downto 0);
        dTD_CURRENT_OFFSET_wr : out STD_LOGIC_VECTOR (11 downto 0)
    );
end Context_to_Stream;

architecture Behavioral of Context_to_Stream is

    type state_type is (IDLE, WRITE_DQH, WRITE_DTD, READ_DQH, READ_DTD, WRITE_SETUP, ERROR); 
    signal state, next_state : state_type;
    
    type dQH_vector is array (11 downto 0) of std_logic_vector(31 downto 0); 
    
    signal dQH_vector_rd : dQH_vector;
    signal dQH_vector_rd_reg : dQH_vector;
    signal dQH_vector_wr : dQH_vector;
    
    signal count : integer range 0 to 11;
    signal index : integer range 0 to 11;
    signal wr_en_aux : STD_LOGIC_VECTOR (11 downto 0); 
	signal count_en : STD_LOGIC;
	signal count_reset : STD_LOGIC;
    
    signal dQH_write_enable : STD_LOGIC;
    signal dQH_write_enable_reg : STD_LOGIC;
    signal s_axis_tdata : STD_LOGIC_VECTOR (31 downto 0);
	signal s_axi_tready : STD_LOGIC;
    signal m_axis_tdata : STD_LOGIC_VECTOR (31 downto 0);
    signal m_axis_tlast : STD_LOGIC;
    signal m_axis_tvalid : STD_LOGIC; 
    
--    attribute mark_debug : string;
--    attribute keep : string;
--    attribute mark_debug of m_axis_s2mm_tready : signal is "true";
--    attribute keep of m_axis_s2mm_tready : signal is "true";
--    attribute mark_debug of count : signal is "true";
--    attribute keep of count : signal is "true";   
   
begin
     dQH_WR_EN <= dQH_write_enable_reg;
	 m_axis_s2mm_tkeep <= "1111";
     s_axis_tdata <= s_axis_mm2s_tdata;
     m_axis_s2mm_tdata <= m_axis_tdata;
     m_axis_s2mm_tlast <= m_axis_tlast;
	 s_axis_mm2s_tready <= s_axi_tready;
	 m_axis_s2mm_tvalid <= m_axis_tvalid;
	 
	 dQH_MULT_wr <= dQH_vector_rd_reg (0)(31 downto 30);
	 dQH_ZLT_wr <= dQH_vector_rd_reg (0)(29);
	 dQH_MAX_PACKET_LENGTH_wr <= dQH_vector_rd_reg (0)(26 downto 16);
	 dQH_IOS_wr <= dQH_vector_rd_reg (0)(15);
	 dQH_CURRENT_dTD_POINTER_wr <= dQH_vector_rd_reg (1)(31 downto 5);
	 dQH_NEXT_dTD_POINTER_wr <= dQH_vector_rd_reg (2)(31 downto 5); 
	 dQH_T_wr <= dQH_vector_rd_reg (2)(0);
	 dQH_SETUP_BUFFER_BYTES_3_0_wr <= dQH_vector_rd_reg (10);
	 dQH_SETUP_BUFFER_BYTES_7_4_wr <= dQH_vector_rd_reg (11);
	 dTD_TOTAL_BYTES_wr <= dQH_vector_rd_reg (3)(30 downto 16); 
	 dTD_IOC_wr <= dQH_vector_rd_reg (3)(15);
	 dTD_C_PAGE_wr <= dQH_vector_rd_reg (3)(14 downto 12);
	 dTD_MULT_wr <= dQH_vector_rd_reg (3)(11 downto 10);
	 dTD_STATUS_wr <= dQH_vector_rd_reg (3)(7 downto 0);
	 dTD_PAGE0_wr <= dQH_vector_rd_reg (4)(31 downto 12);
	 dTD_PAGE1_wr <= dQH_vector_rd_reg (5)(31 downto 12);
	 dTD_PAGE2_wr <= dQH_vector_rd_reg (6)(31 downto 12);
	 dTD_PAGE3_wr <= dQH_vector_rd_reg (7)(31 downto 12);
     dTD_PAGE4_wr <= dQH_vector_rd_reg (8)(31 downto 12);
	 dTD_CURRENT_OFFSET_wr <= dQH_vector_rd_reg (4)(11 downto 0);
	 
    dQH_vector_wr(0) <= dQH_MULT_rd & dQH_ZLT_rd & "00" & dQH_MAX_PACKET_LENGTH_rd & dQH_IOS_rd & "000000000000000";
    dQH_vector_wr(1) <= dQH_CURRENT_dTD_POINTER_rd & "00000";
    dQH_vector_wr(2) <= dQH_NEXT_dTD_POINTER_rd & "0000" & dQH_T_rd;
    dQH_vector_wr(3) <= '0' & dTD_TOTAL_BYTES_rd & dTD_IOC_rd & dTD_C_PAGE_rd & dTD_MULT_rd & "00" & dTD_STATUS_rd;
    dQH_vector_wr(4) <= dTD_PAGE0_rd & dTD_CURRENT_OFFSET_rd;
    dQH_vector_wr(5) <= dTD_PAGE1_rd & "000000000000";
    dQH_vector_wr(6) <= dTD_PAGE2_rd & "000000000000";
    dQH_vector_wr(7) <= dTD_PAGE3_rd & "000000000000";
    dQH_vector_wr(8) <= dTD_PAGE4_rd & "000000000000";
    dQH_vector_wr(9) <= (others => '0');
    dQH_vector_wr(10) <= dQH_SETUP_BUFFER_BYTES_3_0_rd;
    dQH_vector_wr(11) <= dQH_SETUP_BUFFER_BYTES_7_4_rd;

    process (CLK)
    begin
    if (CLK'event and CLK = '1') then
      if (RESETN = '0') then
        dQH_vector_rd_reg <= (others=> (others=>'0')); 
        dQH_write_enable_reg <= '0';
      else 
        dQH_write_enable_reg <= dQH_write_enable;
	    for index in 0 to 11 loop
            if (wr_en_aux(index) = '1') then
                dQH_vector_rd_reg(index) <= dQH_vector_rd(index);
            end if;
        end loop;
      end if;        
    end if;
    end process;

    COUNTER: process (CLK, count_en)
    begin
    if (CLK'event and CLK = '1') then
      if (RESETN = '0' or count_reset = '1') then
         count <= 0;
      elsif (count_en = '1') then
			count <= count + 1;
      end if;        
    end if;
    end process;

    SYNC_PROC: process (CLK)
    begin
    if (CLK'event and CLK = '1') then
      if (RESETN = '0') then
         state <= IDLE;
--         init_write_dma_reg <= '0';
--         init_read_dma_reg <= '0';
      else
         state <= next_state;
--         init_write_dma_reg <= init_write_dma;
--         init_read_dma_reg <= init_read_dma;
      end if;        
    end if;
    end process;
    
   NEXT_STATE_DECODE: process (state, dQH_RD, dQH_WR, dTD_RD, dTD_WR, SETUP_WR, s_axis_mm2s_tvalid, s_axis_tdata, count, s_axis_mm2s_tlast, dQH_vector_wr, m_axis_s2mm_tready)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      count_reset <= '1';
	  count_en <= '0';
	  dQH_vector_rd <= (others=> (others=>'0'));
      m_axis_tlast <= '0';
	  m_axis_tdata <= (others => '0');
      s_axi_tready <= '0';
      dQH_write_enable <= '0';
      m_axis_tvalid <= '0';
      wr_en_aux <=  (others => '0');
      ind_statte_axistream <=  (others => '0');
      --insert statements to decode next_state
      --below is a simple example 
      case state is
      
         when IDLE =>   
            if (dQH_RD = '1') then
                count_reset <= '0';
                next_state <= READ_DQH;
            elsif (dTD_RD = '1') then
                count_reset <= '0';
                next_state <= READ_DTD;
            elsif (dQH_WR = '1') then
                count_reset <= '0';
                next_state <= WRITE_DQH; 
            elsif (dTD_WR = '1') then
                count_reset <= '0';
                next_state <= WRITE_DTD;
            elsif (SETUP_WR = '1') then
                count_reset <= '0';
                next_state <= WRITE_SETUP;
            else
                next_state <= IDLE;
            end if;
            
         when READ_DQH => --READ(mm2s) on axi_stream slave
            ind_statte_axistream <= "00001";
            count_reset <= '0';
            dQH_vector_rd(count) <= s_axis_tdata;
		    s_axi_tready <= '1';
		    --wr_en_aux(count) <= '1';
            if (s_axis_mm2s_tvalid = '1') then
                wr_en_aux(count) <= '1';
                count_en <= '1';
                if (count = 11) then
                    if (s_axis_mm2s_tlast = '1') then
                        dQH_write_enable <= '1';
                        count_reset <= '1';
                        next_state <= IDLE;
                    else
                        next_state <= ERROR;
                    end if;
                else
                    next_state <= READ_DQH;    
                end if;
            end if;
            
         when READ_DTD => --READ(mm2s) on axi_stream slave
               ind_statte_axistream <= "00010";
               count_reset <= '0';
               dQH_vector_rd(count+2) <= s_axis_tdata;
               s_axi_tready <= '1';
--               wr_en_aux(count+2) <= '1'; --data needs to be copied in the overlay area so a +2 offset is required
               if (s_axis_mm2s_tvalid = '1') then
                   wr_en_aux(count+2) <= '1'; --data needs to be copied in the overlay area so a +2 offset is required
                   count_en <= '1';
                   if (count = 6) then
                       if (s_axis_mm2s_tlast = '1') then
                           dQH_write_enable <= '1';
                           count_reset <= '1';
                           next_state <= IDLE;
                       else
                           next_state <= ERROR;
                       end if;
                   else
                       next_state <= READ_DTD;    
                   end if;
               end if;              
                
         when WRITE_DQH => --WRITE(s2mm) on axi_stream master
                  ind_statte_axistream <= "00100";
                  count_reset <= '0';
                  m_axis_tdata <= dQH_vector_wr(count);
                  m_axis_tvalid <= '1';
                  if (m_axis_s2mm_tready = '1') then
                      count_en <= '1';
                      if (count = 11) then
                         m_axis_tlast <= '1';
                         count_reset <= '1';
                         next_state <= IDLE;
                      else
                          next_state <= WRITE_DQH;    
                      end if;
                  end if; 
                  
         when WRITE_DTD =>  --WRITE(s2mm) on axi_stream master
                  ind_statte_axistream <= "00101";
                  count_reset <= '0';
                  m_axis_tdata <= dQH_vector_wr(count);
                  m_axis_tvalid <= '1';
                  if (m_axis_s2mm_tready = '1') then
                      count_en <= '1';
                      if (count = 6) then
                          m_axis_tlast <= '1';
                          count_reset <= '1';
                          next_state <= IDLE;
                      else
                          next_state <= WRITE_DTD;    
                      end if;
                  end if;
                    
         when WRITE_SETUP =>  --WRITE(s2mm) on axi_stream master
            ind_statte_axistream <= "00110";
            count_reset <= '0';
            m_axis_tdata <= dQH_vector_wr(count+10);
            m_axis_tvalid <= '1';
            if (m_axis_s2mm_tready = '1') then
                count_en <= '1';
                if (count = 1) then
                    m_axis_tlast <= '1';
                    count_reset <= '1';
                    next_state <= IDLE;
                else
                    next_state <= WRITE_SETUP;    
                end if;
            end if;       
						
			when ERROR =>					
				next_state <= IDLE;
         when others =>
            next_state <= IDLE;
      end case;      
   end process;	
end Behavioral;
