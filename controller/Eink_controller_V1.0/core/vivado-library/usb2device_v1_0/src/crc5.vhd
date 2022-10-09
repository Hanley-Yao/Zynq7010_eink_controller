-- Copyright (C) 2009 OutputLogic.com
-- This source file may be used and distributed without restriction
-- provided that this copyright statement is not removed from the file
-- and that any derivative work contains the original copyright notice
-- and the associated disclaimer.
-- 
-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
-------------------------------------------------------------------------------
-- CRC module for data(7:0)
--   lfsr(4:0)=1+x^2+x^5;
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity crc5 is
  port ( data_in : in std_logic_vector (10 downto 0);
--    crc_en , rst, clk : in std_logic;
    crc_out : out std_logic_vector (4 downto 0));
end crc5;

architecture imp_crc5 of crc5 is
  signal lfsr_q: std_logic_vector (4 downto 0);
  signal lfsr_c: std_logic_vector (4 downto 0);
  signal crc_out_buf: std_logic_vector (4 downto 0);
begin
    crc_out_buf <= lfsr_c;
    crc_out(4) <= not crc_out_buf(0);
    crc_out(3) <= not crc_out_buf(1);
    crc_out(2) <= not crc_out_buf(2);
    crc_out(1) <= not crc_out_buf(3);
    crc_out(0) <= not crc_out_buf(4);
    lfsr_q <= b"11111";

    lfsr_c(0) <= lfsr_q(0) xor lfsr_q(3) xor lfsr_q(4) xor data_in(0) xor data_in(3) xor data_in(5) xor data_in(6) xor data_in(9) xor data_in(10);
    lfsr_c(1) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(4) xor data_in(1) xor data_in(4) xor data_in(6) xor data_in(7) xor data_in(10);
    lfsr_c(2) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(4) xor data_in(0) xor data_in(2) xor data_in(3) xor data_in(6) xor data_in(7) xor data_in(8) xor data_in(9) xor data_in(10);
    lfsr_c(3) <= lfsr_q(1) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(4) xor data_in(1) xor data_in(3) xor data_in(4) xor data_in(7) xor data_in(8) xor data_in(9) xor data_in(10);
    lfsr_c(4) <= lfsr_q(2) xor lfsr_q(3) xor lfsr_q(4) xor data_in(2) xor data_in(4) xor data_in(5) xor data_in(8) xor data_in(9) xor data_in(10);
    
end imp_crc5; 