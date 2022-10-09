-------------------------------------------------------------------------------
--
-- File: DMA_Operations.vhd
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
-- This module is responsible with implementing the S2MM and MM2S frameworks for the DMA engine
--  
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DMA_Operations is
	generic (
        C_M_START_DATA_VALUE    : std_logic_vector    := x"AA000000";
        C_M_TARGET_SLAVE_BASE_ADDR    : std_logic_vector    := "0100000000";
        C_M_AXI_ADDR_WIDTH    : integer    := 10;
        C_M_AXI_DATA_WIDTH    : integer    := 32;
        C_M_TRANSACTIONS_NUM    : integer    := 4
    );
  Port ( 
        CLK : in STD_LOGIC;
        RESETN : in STD_LOGIC;
        state_ind_dma : out STD_LOGIC_VECTOR(4 downto 0);
        DEBUG_REG_DATA : OUT std_logic_vector(31 downto 0);

        M_AXI_AWADDR    : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        M_AXI_AWPROT    : out std_logic_vector(2 downto 0);
        M_AXI_AWVALID    : out std_logic;
        M_AXI_AWREADY    : in std_logic;
        M_AXI_WDATA    : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        M_AXI_WSTRB    : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
        M_AXI_WVALID    : out std_logic;
        M_AXI_WREADY    : in std_logic;
        M_AXI_BRESP    : in std_logic_vector(1 downto 0);
        M_AXI_BVALID    : in std_logic;
        M_AXI_BREADY    : out std_logic;
        M_AXI_ARADDR    : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        M_AXI_ARPROT    : out std_logic_vector(2 downto 0);
        M_AXI_ARVALID    : out std_logic;
        M_AXI_ARREADY    : in std_logic;
        M_AXI_RDATA    : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        M_AXI_RRESP    : in std_logic_vector(1 downto 0);
        M_AXI_RVALID    : in std_logic;
        M_AXI_RREADY    : out std_logic;
       
        dma_transfer_complete  : out std_logic;
        start_dma_s2mm : in STD_LOGIC;
        start_dma_mm2s : in STD_LOGIC;
        dma_source_dest_address : in STD_LOGIC_VECTOR(31 downto 0);
        dma_transfer_length : in STD_LOGIC_VECTOR(31 downto 0)
  );
end DMA_Operations;

architecture Behavioral of DMA_Operations is

	COMPONENT axi_master
    PORT(
        M_AXI_ACLK : IN std_logic;
        M_AXI_ARESETN : IN std_logic;
        M_AXI_AWREADY : IN std_logic;
        M_AXI_WREADY : IN std_logic;
        M_AXI_BRESP : IN std_logic_vector(1 downto 0);
        M_AXI_BVALID : IN std_logic;
        M_AXI_ARREADY : IN std_logic;
        M_AXI_RDATA : IN std_logic_vector(31 downto 0);
        M_AXI_RRESP : IN std_logic_vector(1 downto 0);
        M_AXI_RVALID : IN std_logic;
        INIT_WRITE : IN std_logic;
        INIT_READ : IN std_logic;
        WRITE_DATA : IN std_logic_vector(31 downto 0);
        WRITE_ADDRESS : IN std_logic_vector(9 downto 0);
        READ_ADDRESS : IN std_logic_vector(9 downto 0);         
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
        WRITE_COMPLETE : OUT std_logic;
        READ_COMPLETE : OUT std_logic;
        READ_DATA : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
    type state_type is (IDLE, S2MM_WRITE_DMASR, MM2S_WRITE_DMASR, S2MM_READ_STATUS1, S2MM_READ_STATUS2, WRITE_S2MM_DMACR, WRITE_S2MM_SA, INIT_S2MM_WRITE_LENGTH, MM2S_READ_STATUS1, MM2S_READ_STATUS2, WRITE_MM2S_DMACR, WRITE_MM2S_SA,  INIT_MM2S_WRITE_LENGTH); 
    signal state, next_state : state_type;
    
--    signal state_ind_dma : STD_LOGIC_VECTOR(4 downto 0);
    signal init_write_dma :  STD_LOGIC;
    signal init_read_dma :  STD_LOGIC;
	signal init_write_dma_reg :  STD_LOGIC;
    signal init_read_dma_reg :  STD_LOGIC;
    signal dma_reg_write_address :  STD_LOGIC_VECTOR(C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal dma_reg_read_address :  STD_LOGIC_VECTOR(C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal dma_reg_write_data :  STD_LOGIC_VECTOR(31 downto 0);
	signal dma_reg_read_data :  STD_LOGIC_VECTOR(31 downto 0);
	signal dma_reg_write_complete :  STD_LOGIC;
    signal dma_reg_read_complete :  STD_LOGIC;
    signal clear_first_transfer_s2mm :  STD_LOGIC; 
    signal is_first_transfer_s2mm :  STD_LOGIC;
    signal clear_first_transfer_mm2s :  STD_LOGIC; 
    signal is_first_transfer_mm2s :  STD_LOGIC;
    signal dma_transfer_complete_fsm :  STD_LOGIC; 
    signal start_dma_mm2s_r :  STD_LOGIC;
    signal start_dma_s2mm_r :  STD_LOGIC;
    signal start_dma_mm2s_pulse :  STD_LOGIC;
    signal start_dma_s2mm_pulse :  STD_LOGIC;
    
--    attribute mark_debug : string;
--    attribute keep : string;
--    attribute mark_debug of state_ind_dma : signal is "true";
--    attribute keep of state_ind_dma : signal is "true"; 
--    attribute mark_debug of dma_reg_read_complete : signal is "true";
--    attribute keep of dma_reg_read_complete : signal is "true";
--    attribute mark_debug of is_first_transfer_s2mm : signal is "true";
--    attribute keep of is_first_transfer_s2mm : signal is "true";

begin
    DEBUG_REG_DATA <= dma_reg_read_data;
    dma_transfer_complete <= dma_transfer_complete_fsm;
    
	Inst_axi_master: axi_master PORT MAP(
		M_AXI_ACLK => CLK,
		M_AXI_ARESETN => RESETN,
		M_AXI_AWADDR => M_AXI_AWADDR,
		M_AXI_AWPROT => M_AXI_AWPROT,
		M_AXI_AWVALID => M_AXI_AWVALID,
		M_AXI_AWREADY => M_AXI_AWREADY,
		M_AXI_WDATA => M_AXI_WDATA,
		M_AXI_WSTRB => M_AXI_WSTRB,
		M_AXI_WVALID => M_AXI_WVALID,
		M_AXI_WREADY => M_AXI_WREADY,
		M_AXI_BRESP => M_AXI_BRESP,
		M_AXI_BVALID => M_AXI_BVALID,
		M_AXI_BREADY => M_AXI_BREADY,
		M_AXI_ARADDR => M_AXI_ARADDR,
		M_AXI_ARPROT => M_AXI_ARPROT,
		M_AXI_ARVALID => M_AXI_ARVALID,
		M_AXI_ARREADY => M_AXI_ARREADY,
		M_AXI_RDATA => M_AXI_RDATA,
		M_AXI_RRESP => M_AXI_RRESP,
		M_AXI_RVALID => M_AXI_RVALID,
		M_AXI_RREADY => M_AXI_RREADY,
		
		INIT_WRITE  => init_write_dma_reg,
        INIT_READ   => init_read_dma_reg,
        WRITE_COMPLETE  => dma_reg_write_complete,
        READ_COMPLETE   => dma_reg_read_complete,
        WRITE_DATA      => dma_reg_write_data,
        WRITE_ADDRESS   => dma_reg_write_address,
        READ_DATA       => dma_reg_read_data,
        READ_ADDRESS    => dma_reg_read_address
	);
	
   MM2S_PULSE_PROC: process (CLK)
     begin
        if (CLK'event and CLK = '1') then
           if (RESETN = '0') then
             start_dma_mm2s_r <= '0';
             start_dma_mm2s_pulse <= '0';
           else
             start_dma_mm2s_r <= start_dma_mm2s;
             start_dma_mm2s_pulse <= start_dma_mm2s and (not start_dma_mm2s_r);
           end if;        
        end if;
     end process;	
     
   S2MM_PULSE_PROC: process (CLK)
       begin
          if (CLK'event and CLK = '1') then
             if (RESETN = '0') then
               start_dma_s2mm_r <= '0';
               start_dma_s2mm_pulse <= '0';
             else
               start_dma_s2mm_r <= start_dma_s2mm;
               start_dma_s2mm_pulse <= start_dma_s2mm and (not start_dma_s2mm_r);
             end if;        
          end if;
       end process;         
	
   FIRST_DMA_TRANSFER_S2MM: process (CLK)
    begin
       if (CLK'event and CLK = '1') then
          if (RESETN = '0') then
            is_first_transfer_s2mm <= '1';
          elsif (clear_first_transfer_s2mm = '1') then
            is_first_transfer_s2mm <= '0';
          end if;        
       end if;
    end process;

   FIRST_DMA_TRANSFER_MM2S: process (CLK)
    begin
       if (CLK'event and CLK = '1') then
          if (RESETN = '0') then
            is_first_transfer_mm2s <= '1';
          elsif (clear_first_transfer_mm2s = '1') then
            is_first_transfer_mm2s <= '0';
          end if;        
       end if;
    end process;

   SYNC_PROC: process (CLK)
   begin
      if (CLK'event and CLK = '1') then
         if (RESETN = '0') then
            state <= IDLE;
            init_write_dma_reg <= '0';
            init_read_dma_reg <= '0';
         else
            state <= next_state;
            init_write_dma_reg <= init_write_dma;
            init_read_dma_reg <= init_read_dma;
         end if;        
      end if;
   end process;

   NEXT_STATE_DECODE: process (state, dma_reg_write_complete, dma_reg_read_complete, dma_transfer_length, is_first_transfer_mm2s, is_first_transfer_s2mm, start_dma_s2mm_pulse, dma_reg_read_data, start_dma_mm2s_pulse, dma_source_dest_address)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      state_ind_dma <= "00000";
      dma_transfer_complete_fsm <= '0';
      init_write_dma <= '0';
      init_read_dma <= '0';
      dma_reg_write_address <= (others=>'0');
      dma_reg_read_address <= (others=>'0');
      dma_reg_write_data <= (others=>'0');
      clear_first_transfer_s2mm <= '0';
      clear_first_transfer_mm2s <= '0';
      --insert statements to decode next_state
      --below is a simple example 
      case state is
         when IDLE =>
            state_ind_dma <= "00000";
            --init_write_dma <= '1';
            if (start_dma_s2mm_pulse = '1') then
                init_read_dma <= '1';  -- initiate axi_master read
                next_state <= S2MM_READ_STATUS1;
            elsif (start_dma_mm2s_pulse = '1') then 
                init_read_dma <= '1';  -- initiate axi_master read
                next_state <= MM2S_READ_STATUS1;                
            end if;

         when S2MM_READ_STATUS1 =>
            state_ind_dma <= "00001";
            init_write_dma <= '0';
            dma_reg_read_address <= "0000110100";
            --dma_reg_write_data <= "00000000000000000000000000000001";
            if (dma_reg_read_complete = '1') then
                if (dma_reg_read_data(1) = '1' or (dma_reg_read_data(1) = '0' and is_first_transfer_s2mm = '1')) then --DMA controller idle
                    init_write_dma <= '1';  -- initiate axi_master write
                    next_state <= WRITE_S2MM_DMACR;                
                else
                    init_read_dma <= '1';
                    next_state <= S2MM_READ_STATUS1;
                end if;
             end if;
            
         when WRITE_S2MM_DMACR =>
            state_ind_dma <= "00010";
            init_write_dma <= '0';
            dma_reg_write_address <= "0000110000";
            dma_reg_write_data <= "00000000000000000000000000000001";
            if (dma_reg_write_complete = '1') then
                init_write_dma <= '1';
                next_state <= WRITE_S2MM_SA;
            else
               next_state <= WRITE_S2MM_DMACR;
            end if;
            
         when WRITE_S2MM_SA =>
            state_ind_dma <= "00011";
            init_write_dma <= '0';
            dma_reg_write_address <= "0001001000";
            dma_reg_write_data <= dma_source_dest_address;
                if (dma_reg_write_complete = '1') then
                    init_write_dma <= '1';
                    next_state <= INIT_S2MM_WRITE_LENGTH;
                end if;
                
            when INIT_S2MM_WRITE_LENGTH =>
                state_ind_dma <= "00100";
                clear_first_transfer_s2mm <= '1';
                dma_reg_write_address <= "0001011000";
                dma_reg_write_data <= dma_transfer_length;
                    if (dma_reg_write_complete = '1') then
                        init_read_dma <= '1';
                        next_state <= S2MM_READ_STATUS2;
                    end if;
                    
            when S2MM_READ_STATUS2 =>
                state_ind_dma <= "00101";
                dma_reg_read_address <= "0000110100";
                ---dma_reg_write_data <= "00000000000000000000000000000001";
                    if (dma_reg_read_complete = '1') then
                        if (dma_reg_read_data(12) = '1' and dma_reg_read_data(1) = '1') then --IOC detected
                            --dma_transfer_complete_fsm <= '1';
                            init_write_dma <= '1';
                            next_state <= S2MM_WRITE_DMASR;                
                        else
                            init_read_dma <= '1';
                            next_state <= S2MM_READ_STATUS2;
                        end if;
                    end if;
                    
            when S2MM_WRITE_DMASR =>
                       state_ind_dma <= "00110";
                       dma_reg_write_address <= "0000110100";
                       dma_reg_write_data <= "00000000000000000001000000000000";
                       if (dma_reg_write_complete = '1') then
                           dma_transfer_complete_fsm <= '1';
                           next_state <= IDLE;
                       end if;                    
                    
         when MM2S_READ_STATUS1 =>
            state_ind_dma <= "00111";
            init_write_dma <= '0';
                dma_reg_read_address <= "0000000100";
                --dma_reg_write_data <= "00000000000000000000000000000001";
                    if (dma_reg_read_complete = '1') then
                        if (dma_reg_read_data(1) = '1' or (dma_reg_read_data(1) = '0' and is_first_transfer_mm2s = '1')) then
                               init_write_dma <= '1';  -- initiate axi_master write
                               next_state <= WRITE_MM2S_DMACR;
                           else
                               init_read_dma <= '1';
                               next_state <= MM2S_READ_STATUS1;
                           end if;
                        end if;
                       
         when WRITE_MM2S_DMACR =>
            state_ind_dma <= "01000";
            init_write_dma <= '0';
            dma_reg_write_address <= "0000000000";
            dma_reg_write_data <= "00000000000000000000000000000001";
                if (dma_reg_write_complete = '1') then
                    init_write_dma <= '1';
                    next_state <= WRITE_MM2S_SA;
                else
                    next_state <= WRITE_MM2S_DMACR;
                end if;
                       
         when WRITE_MM2S_SA =>
            state_ind_dma <= "01001";
            init_write_dma <= '0';
            dma_reg_write_address <= "0000011000";
            dma_reg_write_data <= dma_source_dest_address;
                if (dma_reg_write_complete = '1') then
                    init_write_dma <= '1';
                    next_state <= INIT_MM2S_WRITE_LENGTH;
                end if;
                           
         when INIT_MM2S_WRITE_LENGTH =>
            state_ind_dma <= "01010";
            clear_first_transfer_mm2s <= '1';
            dma_reg_write_address <= "0000101000";
            dma_reg_write_data <= dma_transfer_length;
            if (dma_reg_write_complete = '1') then
                init_read_dma <= '1';
                next_state <= MM2S_READ_STATUS2;
            end if;            

         when MM2S_READ_STATUS2 =>
            state_ind_dma <= "01011";
            dma_reg_read_address <= "0000000100";
            --dma_reg_write_data <= "00000000000000000000000000000001";
            if (dma_reg_read_complete = '1') then
                if (dma_reg_read_data(12) = '1' and dma_reg_read_data(1) = '1') then --IOC detected
                    --dma_transfer_complete_fsm <= '1';
                    init_write_dma <= '1';
                    next_state <= MM2S_WRITE_DMASR;
                else
                    init_read_dma <= '1';
                    next_state <= MM2S_READ_STATUS2;
                end if;
            end if;
            
         when MM2S_WRITE_DMASR =>
            state_ind_dma <= "01100";
            dma_reg_write_address <= "0000000100";
            dma_reg_write_data <= "00000000000000000001000000000000";
            if (dma_reg_write_complete = '1') then
                dma_transfer_complete_fsm <= '1';
                next_state <= IDLE;
            end if;
            
         when others =>
            next_state <= IDLE;
      end case;      
   end process;	

end Behavioral;
