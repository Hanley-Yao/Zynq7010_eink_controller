
-------------------------------------------------------------------------------
--
-- File: DAC_SPI.vhd
-- Author: Tudor Gherman
-- Original Project: Zmod DAC 1411 Low Level Controller
-- Date: 15 January 2020
--
-------------------------------------------------------------------------------
-- (c) 2020 Copyright Digilent Incorporated
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
--This module manages the SPI communication with the Zmod DAC 1411's AD9717.
--  
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.ALL;

entity DAC_SPI is
    Port (
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           SPI_CLK : out STD_LOGIC;
           SDIO : inout STD_LOGIC;
           CS : out STD_LOGIC;
           --TEST : out std_logic;
           
           START_TRANSFER : in std_logic;
           RD_DATA : out std_logic_vector(7 downto 0);
           WR_DATA : in std_logic_vector(7 downto 0);
           ADDRESS : in std_logic_vector(4 downto 0);
           WIDTH : in std_logic_vector(1 downto 0); --only one byte rx/tx supported
           RD_WR : in STD_LOGIC; 
           DONE : out STD_LOGIC
         );
end DAC_SPI;

architecture Behavioral of DAC_SPI is

type states is (ST_WRITE, ST_READ1,ST_READ3, ST_ERROR, StIdle, ST_DONE, ST_DLY_DIR_CS, ST_RST_DLY, ST_DLY_DIR, DECODE); 
signal spi_sCurrentState, spi_sNextState : states;
signal rx_data, tx_data, tx_shift, rx_shift, rst_dir, spi_clk_rst : std_logic;
signal rd_data_r : std_logic_vector(7 downto 0);
signal tx_vector : std_logic_vector (15 downto 0);
signal dir, dir_fsm : std_logic;
signal clk_counter : std_logic_vector(3 downto 0);
signal tx_count, rx_count, nr_bits, nr_bits_r : std_logic_vector(4 downto 0);
signal ld_rx_fsm, ld_rx_fsm_r, ld_rx_pulse, ld_rd_data : std_logic;
signal done_fsm, done_fsm_r, done_fsm_rr, CS_fsm : std_logic;
signal fsm_state, fsm_state_r : std_logic_vector(3 downto 0);
signal Start_Transfer_r, Start_Transfer_pulse : std_logic;

signal delay_cnt : std_logic_vector (5 downto 0);
signal delay_inc, delay_rst : std_logic;

signal read_en, write_en: std_logic;
            
begin

read_en <= '1' when RD_WR = '1' else '0';
write_en <= '0' when RD_WR = '1' else '1';

   IOBUF_inst : IOBUF
   generic map (
      DRIVE => 12,
      IOSTANDARD => "LVCMOS18",
      SLEW => "SLOW")
   port map (
      O => rx_data,     -- Buffer output
      IO => SDIO,   -- Buffer inout port (connect directly to top-level port)
      I => tx_data,     -- Buffer input
      T => dir      -- 3-state enable input, high=input, low=output 
   );

DELAY_COUNTER_PROC: process (CLK)  
      begin
          if (CLK' event and CLK = '1') then
              if ((RST = '0') or (delay_rst = '1')) then
                  delay_cnt <= (others => '0');
              else
                if (delay_inc = '1') then 
                    delay_cnt <= delay_cnt + '1';
                end if;    
              end if;
          end if;
      end process; 
   
START_TRANSFER_PROC: process (CLK)  
    begin
        if (CLK' event and CLK = '1') then
            if (RST = '0') then
                Start_Transfer_r <= '0';
                done_fsm_r <= '0';
                done_fsm_rr <= '0';
                ld_rx_fsm_r <= '0';
            else
                Start_Transfer_r <= START_TRANSFER;
                done_fsm_r  <= done_fsm;
                done_fsm_rr <= done_fsm_r;
                ld_rx_fsm_r <= ld_rx_fsm;
            end if;
        end if;
    end process;    

Start_Transfer_pulse <= (not Start_Transfer_r) and START_TRANSFER;
ld_rx_pulse <= (not ld_rx_fsm_r) and ld_rx_fsm;
   
CLK_COUNTER_PROC: process (CLK)  
      begin
          if (CLK' event and CLK = '1') then
              if (RST = '0') then
                  clk_counter <= (others => '0');
              else
                  if (spi_clk_rst = '0') then
                    clk_counter <= clk_counter + '1';
                  else
                    if (clk_counter > "1000") then --finish clock period
                        clk_counter <= clk_counter + '1';
                    else
                        clk_counter <= (others => '0');   
                    end if; 
                  end if;   
              end if;
          end if;
      end process; 

SPI_CLK <= clk_counter(3); --divide input clock by 16                   

nr_bits <= (WIDTH + '1') & "000";

SHIFT_TX_PROC: process (CLK)  -- SYS_CLK = 100MHz => AP_START=1MHz
      begin
          if (CLK' event and CLK = '1') then
              if ((RST = '0') or (Start_Transfer_pulse = '1')) then
                  tx_vector <= RD_WR & WIDTH & ADDRESS & WR_DATA;
                  tx_count <= (others => '0');
                  tx_data <= '0';
              else
                if(tx_shift = '1') then 
                    if (clk_counter = "0100") then
                      tx_vector(15 downto 0) <= tx_vector(14 downto 0) & '0';
                      tx_count <= tx_count + '1';
                      tx_data <= tx_vector(15);
                    end if;  
                end if;    
              end if;
          end if;
      end process;

DIR_PROC: process (CLK)  -- SYS_CLK = 100MHz => AP_START=1MHz
      begin
          if (CLK' event and CLK = '1') then
              if ((RST = '0') or (rst_dir = '1')) then
                  dir <= dir_fsm;
              else
                --if (clk_counter = "1111") then
                      dir <= dir_fsm;
                --end if;  
              end if;    
          end if;
      end process;
 
SHIFT_RX_PROC: process (CLK)  -- SYS_CLK = 100MHz => AP_START=1MHz
    begin
        if (CLK' event and CLK = '1') then
            if ((RST = '0') or (rx_shift = '0')) then
                rd_data_r <= (others =>'0');
                rx_count <= (others =>'0');
            else
                if (rx_shift = '1') then
                    if ((clk_counter = "1011") or (ld_rd_data = '1')) then
                        rd_data_r(7 downto 0) <= rd_data_r(6 downto 0) & rx_data;
                        rx_count <= rx_count + '1';
                    end if;    
                end if;  
            end if;
        end if;
    end process;
    
RD_DATA_PROC: process (CLK, rst)
      begin
         if (CLK'event and CLK = '1') then
            if (rst = '0') then
               RD_DATA <= (others => '0');
               DONE <= '0';
            else
                DONE <= (not done_fsm_rr) and done_fsm_r;
                if (ld_rx_pulse = '1') then
                    RD_DATA <= rd_data_r;
                end if;    
            end if;        
         end if;
      end process;
  
FSM_SYNC_PROC: process (CLK, rst)
      begin
         if (CLK'event and CLK = '1') then
            if (rst = '0') then
               spi_sCurrentState <= StIdle;
            else
               spi_sCurrentState <= spi_sNextState;
            end if;        
         end if;
      end process;
      
sNextState_DECODE: process (spi_sCurrentState, tx_count, rx_count, nr_bits, Start_Transfer_pulse, delay_cnt)
      begin         
         spi_sNextState <= spi_sCurrentState;  
         dir_fsm <= '0';
         CS_fsm <= '1';
         done_fsm <= '0';
         rx_shift <= '0';
         tx_shift <= '0';
         fsm_state <= (others => '0');
         rst_dir <= '0';
         spi_clk_rst <= '1';
         delay_rst <= '1';
         delay_inc <= '0';
         ld_rx_fsm <= '0';
         ld_rd_data <= '0';
         
         case (spi_sCurrentState) is
            when StIdle =>
               fsm_state <= "0000";
               dir_fsm <= '0';
               CS_fsm <= '1';
               done_fsm <= '0';
               rx_shift <= '0';
               tx_shift <= '0';
               rst_dir <= '1';
               spi_clk_rst <= '1';
               if (Start_Transfer_pulse = '1') then
                   if (read_en = '1') then
                       spi_sNextState <= ST_READ1;
                   elsif (write_en = '1') then
                       spi_sNextState <= ST_WRITE;
                   end if;
               end if;
               
            when DECODE =>
                fsm_state <= "0001";
                if (RD_WR = '0') then
                    spi_sNextState <= ST_WRITE;
                else
                    spi_sNextState <= ST_READ1;
                end if; 
              
            when ST_READ1 =>
                fsm_state <= "0010";
                dir_fsm <= '0';
                CS_fsm <= '0';
                done_fsm <= '0';
                rx_shift <= '0';
                tx_shift <= '1';
                spi_clk_rst <= '0'; 
                if (tx_count = "01000") then
                    --dir_fsm <= '1';
                    spi_sNextState <= ST_DLY_DIR; 
                end if;       

            when ST_DLY_DIR => 
                fsm_state <= "0100";
                delay_rst <= '0';
                delay_inc <= '1'; 
                dir_fsm <= '0';
                spi_clk_rst <= '0'; 
                CS_fsm <= '0';
                rx_shift <= '1';
                tx_shift <= '0';          
                if (delay_cnt = "000100") then --hold DIR low for another 1/4 period
                    spi_sNextState <= ST_READ3;
                end if;      
                                                  
            when ST_READ3 =>
                fsm_state <= "0101";
                dir_fsm <= '1';
                CS_fsm <= '0';
                done_fsm <= '0';
                rx_shift <= '1';
                tx_shift <= '0';
                spi_clk_rst <= '0';
                if (rx_count = "01000") then
                    spi_sNextState <= ST_DLY_DIR_CS;
                end if;
            
            when ST_DLY_DIR_CS =>
                fsm_state <= "0110";
                dir_fsm <= '1';
                CS_fsm <= '0';
                delay_rst <= '0';
                delay_inc <= '1';
                rx_shift <= '1';
                if (delay_cnt = "001000") then
                    spi_sNextState <= ST_RST_DLY;
                end if;
              
            when ST_RST_DLY =>
                fsm_state <= "0111";
                delay_rst <= '1';
                CS_fsm <= '1';
                spi_clk_rst <= '1';
                rx_shift <= '1';
                ld_rd_data <= '1';
                spi_sNextState <= ST_DONE;
                    
                
            when ST_WRITE =>
                fsm_state <= "1000";
                dir_fsm <= '0';
                CS_fsm <= '0';
                done_fsm <= '0';
                rx_shift <= '0';
                tx_shift <= '1';
                spi_clk_rst <= '0';
                if (tx_count = (nr_bits + "01001")) then
                    spi_sNextState <= ST_DONE;
                end if;
                
             when ST_DONE =>
                fsm_state <= "1001";
                dir_fsm <= '0';
                CS_fsm <= '1';
                rx_shift <= '1';
                tx_shift <= '0';
                spi_clk_rst <= '1';
                delay_rst <= '0';
                delay_inc <= '1';
                ld_rx_fsm <= '1';
                if (delay_cnt = "111111") then
                    spi_sNextState <= StIdle;
                    done_fsm <= '1';
                end if;    
                     
            when others =>
                fsm_state <= (others => '1');
                spi_sNextState <= StIdle;
         end case;      
      end process;    

FSM_OUT_PROC: process (CLK, rst)
      begin
         if (CLK'event and CLK = '1') then
            if (rst = '0') then
               CS <= '0';
               fsm_state_r <= (others => '0');
               nr_bits_r <= (others => '0');
            else
               CS <= CS_fsm;
               fsm_state_r <= fsm_state;
               nr_bits_r <= nr_bits;
            end if;        
         end if;
      end process;
      
end Behavioral;      