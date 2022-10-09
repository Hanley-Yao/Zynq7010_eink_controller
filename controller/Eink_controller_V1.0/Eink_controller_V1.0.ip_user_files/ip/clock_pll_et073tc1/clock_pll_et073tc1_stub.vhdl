-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Sun Oct  2 13:37:44 2022
-- Host        : Duller running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.gen/sources_1/ip/clock_pll_et073tc1/clock_pll_et073tc1_stub.vhdl
-- Design      : clock_pll_et073tc1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_pll_et073tc1 is
  Port ( 
    epd_clk : out STD_LOGIC;
    clk_50m : out STD_LOGIC;
    resetn : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in : in STD_LOGIC
  );

end clock_pll_et073tc1;

architecture stub of clock_pll_et073tc1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "epd_clk,clk_50m,resetn,locked,clk_in";
begin
end;
