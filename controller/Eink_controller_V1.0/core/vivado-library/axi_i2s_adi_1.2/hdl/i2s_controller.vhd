-- ***************************************************************************
-- ***************************************************************************
-- Copyright 2013(c) Analog Devices, Inc.
--  Author: Lars-Peter Clausen <lars-peter.clausen@analog.com>
-- 
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--     - Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     - Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in
--       the documentation and/or other materials provided with the
--       distribution.
--     - Neither the name of Analog Devices, Inc. nor the names of its
--       contributors may be used to endorse or promote products derived
--       from this software without specific prior written permission.
--     - The use of this software may or may not infringe the patent rights
--       of one or more patent holders.  This license does not release you
--       from the requirement that you obtain separate licenses from these
--       patent holders to use this software.
--     - Use of the software either in source or binary form, must be run
--       on or directly connected to an Analog Devices Inc. component.
--    
-- THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
-- INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED.
--
-- IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
-- RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
-- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
-- THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- ***************************************************************************
-- ***************************************************************************

library ieee;
use ieee.std_logic_1164.all;

library axi_i2s_adi_v1_00_a;
use axi_i2s_adi_v1_00_a.fifo_synchronizer;
use axi_i2s_adi_v1_00_a.i2s_clkgen;
use axi_i2s_adi_v1_00_a.i2s_tx;
use axi_i2s_adi_v1_00_a.i2s_rx;

entity i2s_controller is
	generic(
		C_SLOT_WIDTH		: integer := 24;	-- Width of one Slot
		C_BCLK_POL		: integer := 0;		-- BCLK Polarity (0 - Falling edge, 1 - Rising edge)
		C_LRCLK_POL		: integer := 0;		-- LRCLK Polarity (0 - Falling edge, 1 - Rising edge)
		C_NUM_CH		: integer := 1;
		C_HAS_TX		: integer := 1;
		C_HAS_RX		: integer := 1
	);
	port(
		clk			: in  std_logic;	-- System clock
		resetn			: in  std_logic; 	-- System reset

		data_clk		: in  std_logic;	-- Data clock should be less than clk / 4
		BCLK_O			: out std_logic_vector(C_NUM_CH - 1 downto 0); 	-- Bit Clock
		LRCLK_O			: out std_logic_vector(C_NUM_CH - 1 downto 0);	-- Frame Clock
		SDATA_O			: out std_logic_vector(C_NUM_CH - 1 downto 0);	-- Serial Data Output
		SDATA_I			: in  std_logic_vector(C_NUM_CH - 1 downto 0);	-- Serial Data Input

		tx_enable		: in  Boolean;	-- Enable TX
		tx_ack			: out std_logic;	-- Request new Slot Data
		tx_stb			: in  std_logic;	-- Request new Slot Data
		tx_data			: in  std_logic_vector(C_SLOT_WIDTH-1 downto 0); 	-- Slot Data in
	
		rx_enable		: in  Boolean;	-- Enable RX
		rx_ack			: in  std_logic;
		rx_stb			: out std_logic;	-- Valid Slot Data
		rx_data			: out std_logic_vector(C_SLOT_WIDTH-1 downto 0);	-- Slot Data out

		-- Runtime parameter
		bclk_div_rate		: in  natural range 0 to 255;
		lrclk_div_rate		: in  natural range 0 to 255
	);
end i2s_controller;

architecture Behavioral of i2s_controller is
constant NUM_TX			: integer := C_HAS_TX * C_NUM_CH;
constant NUM_RX			: integer := C_HAS_RX * C_NUM_CH;

signal enable			: Boolean;

signal tick			: std_logic;
signal tick_d1			: std_logic;
signal tick_d2			: std_logic;

signal BCLK_O_int		: std_logic;
signal LRCLK_O_int		: std_logic;

signal tx_bclk			: std_logic;
signal tx_lrclk			: std_logic;
signal tx_sdata			: std_logic_vector(C_NUM_CH - 1 downto 0);
signal tx_tick			: std_logic;
signal tx_channel_sync		: std_logic;
signal tx_frame_sync		: std_logic;

signal bclk_tick		: std_logic;

signal rx_bclk			: std_logic;
signal rx_lrclk			: std_logic;
signal rx_sdata			: std_logic_vector(NUM_RX - 1 downto 0);
signal rx_channel_sync		: std_logic;
signal rx_frame_sync		: std_logic;

signal tx_sync_fifo_out : std_logic_vector(3 + NUM_TX downto 0);
signal tx_sync_fifo_in : std_logic_vector(3 + NUM_TX downto 0);
signal rx_sync_fifo_out : std_logic_vector(3 + NUM_RX downto 0);
signal rx_sync_fifo_in : std_logic_vector(3 + NUM_RX downto 0);

begin
	enable <= rx_enable or tx_enable;

	-- Generate tick signal in the DATA_CLK_I domain
	process (data_clk)
	begin
		if rising_edge(data_clk) then
			if resetn = '0' then
				tick <= '0';
			else
				tick <= not tick;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if resetn = '0' then
				tick_d1 <= '0';
				tick_d2 <= '0';
			else
				tick_d1 <= tick;
				tick_d2 <= tick_d1;
			end if;
		end if;
	end process;

	tx_tick <= tick_d2 xor tick_d1;

	tx_sync_fifo_in(0) <= tx_channel_sync;
	tx_sync_fifo_in(1) <= tx_frame_sync;
	tx_sync_fifo_in(2) <= tx_bclk;
	tx_sync_fifo_in(3) <= tx_lrclk;
	tx_sync_fifo_in(3 + NUM_TX downto 4) <= tx_sdata;

	process (data_clk)
	begin
		if rising_edge(data_clk) then
			if resetn = '0' then
				BCLK_O <= (others => '1');
				LRCLK_O <= (others => '1');
				SDATA_O <= (others => '0');
			else
				if C_BCLK_POL = 0 then
					BCLK_O <= (others => tx_sync_fifo_out(2));
				else
					BCLK_O <= (others => not tx_sync_fifo_out(2));
				end if;

				if C_LRCLK_POL = 0 then
					LRCLK_O <= (others => tx_sync_fifo_out(3));
				else
					LRCLK_O <= (others => not tx_sync_fifo_out(3));
				end if;

				if C_HAS_TX = 1 then
					SDATA_O <= tx_sync_fifo_out(3 + NUM_TX downto 4);
				end if;
	
				if  C_HAS_RX = 1 then
					rx_sync_fifo_in(3 downto 0) <= tx_sync_fifo_out(3 downto 0);
					rx_sync_fifo_in(3 + NUM_RX downto 4) <= SDATA_I;
				end if;
			end if;
		end if;
	end process;

	tx_sync: entity fifo_synchronizer
		generic map (
			DEPTH => 4,
			WIDTH => NUM_TX + 4
		)
		port map (
			resetn => resetn,
			in_clk => clk,
			in_data => tx_sync_fifo_in,
			in_tick => tx_tick,

			out_clk => data_clk,
			out_data => tx_sync_fifo_out
		);

	clkgen: entity i2s_clkgen
		port map(
			clk => clk,
			resetn => resetn,
			enable => enable,
			tick => tx_tick,

			bclk_div_rate => bclk_div_rate,
			lrclk_div_rate => lrclk_div_rate,

			channel_sync => tx_channel_sync,
			frame_sync => tx_frame_sync,
			
			bclk => tx_bclk,
			lrclk => tx_lrclk
		);

	tx_gen: if C_HAS_TX = 1 generate
		tx: entity i2s_tx
			generic map (
				C_SLOT_WIDTH => C_SLOT_WIDTH,
				C_NUM => NUM_TX
			)
			port map (
				clk => clk,
				resetn => resetn,
				enable => tx_enable,

				channel_sync => tx_channel_sync,
				frame_sync => tx_frame_sync,
				bclk => tx_bclk,
				sdata => tx_sdata,
				
				ack => tx_ack,
				stb => tx_stb,
				data => tx_data
			);
	end generate;

	rx_gen: if C_HAS_RX = 1 generate
		rx: entity i2s_rx
			generic map (
				C_SLOT_WIDTH => C_SLOT_WIDTH,
				C_NUM => NUM_RX
			)
			port map (
				clk => clk,
				resetn => resetn,
				enable => rx_enable,

				channel_sync => rx_channel_sync,
				frame_sync => rx_frame_sync,
				bclk => rx_bclk,
				sdata => rx_sdata,
				
				ack => rx_ack,
				stb => rx_stb,
				data => rx_data
			);

		rx_channel_sync <= rx_sync_fifo_out(0);
		rx_frame_sync <= rx_sync_fifo_out(1);
		rx_bclk <= rx_sync_fifo_out(2);
		rx_lrclk <= rx_sync_fifo_out(3);
		rx_sdata <= rx_sync_fifo_out(3 + NUM_RX downto 4);

		rx_sync: entity fifo_synchronizer
			generic map (
				DEPTH => 4,
				WIDTH => NUM_RX + 4
			)
			port map (
				resetn => resetn,
				in_clk => data_clk,
				in_data => rx_sync_fifo_in,
				in_tick => '1',

				out_clk => clk,
				out_data => rx_sync_fifo_out
			);

	end generate;

end Behavioral;
