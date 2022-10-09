-------------------------------------------------------------------------------
--
-- File: FIFO.vhd
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
-- RX FIFO instantiation
--  
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FIFO is
  generic (
    NUM_TX_FIFO    : integer    := 1
  );
  
  PORT (
  resetn : IN STD_LOGIC;
  rx_fifo_s_aresetn : IN STD_LOGIC;
  rx_fifo_m_aclk : IN STD_LOGIC;
  rx_fifo_s_aclk : IN STD_LOGIC;
  
  rx_fifo_s_axis_tvalid : IN STD_LOGIC;
  rx_fifo_s_axis_tready : OUT STD_LOGIC;
  rx_fifo_s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  rx_fifo_s_axis_tkeep : IN std_logic_vector (3 downto 0);
  rx_fifo_s_axis_tlast : IN STD_LOGIC;
  rx_fifo_s_axis_tuser : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  rx_fifo_m_axis_tvalid : OUT STD_LOGIC;
  rx_fifo_m_axis_tready : IN STD_LOGIC;
  rx_fifo_m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  rx_fifo_m_axis_tkeep : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  rx_fifo_m_axis_tlast : OUT STD_LOGIC;
  rx_fifo_m_axis_tuser : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  rx_fifo_axis_overflow : OUT STD_LOGIC;
  rx_fifo_axis_underflow : OUT STD_LOGIC

); 

end FIFO;

architecture Behavioral of FIFO is

COMPONENT fifo_generator_0
  PORT (
    m_aclk : IN STD_LOGIC;
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

begin

RX_FIFO : fifo_generator_0
  PORT MAP (
    m_aclk => rx_fifo_m_aclk,
    s_aclk => rx_fifo_s_aclk,
    s_aresetn => rx_fifo_s_aresetn,
    s_axis_tvalid => rx_fifo_s_axis_tvalid,
    s_axis_tready => rx_fifo_s_axis_tready,
    s_axis_tdata => rx_fifo_s_axis_tdata,
    s_axis_tkeep => rx_fifo_s_axis_tkeep,
    s_axis_tlast => rx_fifo_s_axis_tlast,
    s_axis_tuser => rx_fifo_s_axis_tuser,
    m_axis_tvalid => rx_fifo_m_axis_tvalid,
    m_axis_tready => rx_fifo_m_axis_tready,
    m_axis_tdata => rx_fifo_m_axis_tdata,
    m_axis_tkeep => rx_fifo_m_axis_tkeep,
    m_axis_tlast => rx_fifo_m_axis_tlast,
    m_axis_tuser => rx_fifo_m_axis_tuser,
    axis_overflow => rx_fifo_axis_overflow,
    axis_underflow => rx_fifo_axis_underflow
  );
     
end Behavioral;
