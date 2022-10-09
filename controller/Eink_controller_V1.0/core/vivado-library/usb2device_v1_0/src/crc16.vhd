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
--   lfsr(15:0)=1+x^2+x^15+x^16;
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity crc16 is
  port ( data_in : in std_logic_vector (7 downto 0);
    crc_en , rst, clk : in std_logic;
    crc_out_res : out std_logic_vector (15 downto 0);
    crc_out : out std_logic_vector (15 downto 0));
end crc16;

architecture imp_crc16 of crc16 is
  signal lfsr_q: std_logic_vector (15 downto 0);
  signal lfsr_c: std_logic_vector (15 downto 0);
  
  signal data_in1 : std_logic_vector (7 downto 0);
  signal crc_out1 : std_logic_vector (15 downto 0);

--attribute mark_debug : string;
--attribute keep : string;
--attribute mark_debug of data_in  : signal is "true";
--attribute keep of data_in : signal is "true";
 
begin

crc_out_res <= crc_out1;

crc_out(0) <=not crc_out1(7);
crc_out(1) <=not crc_out1(6);
crc_out(2) <=not crc_out1(5);
crc_out(3) <=not crc_out1(4);
crc_out(4) <=not crc_out1(3);
crc_out(5) <=not crc_out1(2);
crc_out(6) <=not crc_out1(1);
crc_out(7) <=not crc_out1(0);
crc_out(8) <=not crc_out1(15);
crc_out(9) <=not crc_out1(14);
crc_out(10) <=not crc_out1(13);
crc_out(11) <=not crc_out1(12);
crc_out(12) <=not crc_out1(11);
crc_out(13) <=not crc_out1(10);
crc_out(14) <=not crc_out1(9);
crc_out(15) <=not crc_out1(8);

--data_in1(7) <= data_in(0);
--data_in1(6) <= data_in(1);
--data_in1(5) <= data_in(2);
--data_in1(4) <= data_in(3);
--data_in1(3) <= data_in(4);
--data_in1(2) <= data_in(5);
--data_in1(1) <= data_in(6);
--data_in1(0) <= data_in(7);
data_in1 <= data_in;

    crc_out1 <= lfsr_q;

    lfsr_c(0) <= lfsr_q(8) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(15) xor data_in1(0) xor data_in1(1) xor data_in1(2) xor data_in1(3) xor data_in1(4) xor data_in1(5) xor data_in1(6) xor data_in1(7);
    lfsr_c(1) <= lfsr_q(9) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(15) xor data_in1(1) xor data_in1(2) xor data_in1(3) xor data_in1(4) xor data_in1(5) xor data_in1(6) xor data_in1(7);
    lfsr_c(2) <= lfsr_q(8) xor lfsr_q(9) xor data_in1(0) xor data_in1(1);
    lfsr_c(3) <= lfsr_q(9) xor lfsr_q(10) xor data_in1(1) xor data_in1(2);
    lfsr_c(4) <= lfsr_q(10) xor lfsr_q(11) xor data_in1(2) xor data_in1(3);
    lfsr_c(5) <= lfsr_q(11) xor lfsr_q(12) xor data_in1(3) xor data_in1(4);
    lfsr_c(6) <= lfsr_q(12) xor lfsr_q(13) xor data_in1(4) xor data_in1(5);
    lfsr_c(7) <= lfsr_q(13) xor lfsr_q(14) xor data_in1(5) xor data_in1(6);
    lfsr_c(8) <= lfsr_q(0) xor lfsr_q(14) xor lfsr_q(15) xor data_in1(6) xor data_in1(7);
    lfsr_c(9) <= lfsr_q(1) xor lfsr_q(15) xor data_in1(7);
    lfsr_c(10) <= lfsr_q(2);
    lfsr_c(11) <= lfsr_q(3);
    lfsr_c(12) <= lfsr_q(4);
    lfsr_c(13) <= lfsr_q(5);
    lfsr_c(14) <= lfsr_q(6);
    lfsr_c(15) <= lfsr_q(7) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(15) xor data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(5) xor data_in(6) xor data_in(7);

    process (clk,rst) begin
      if (clk'EVENT and clk = '1') then
        if (rst = '0') then
            lfsr_q <= b"1111111111111111";
        else
            if (crc_en = '1') then
                lfsr_q <= lfsr_c;
            end if;
        end if;
      end if;  
    end process;
    
end architecture imp_crc16; 