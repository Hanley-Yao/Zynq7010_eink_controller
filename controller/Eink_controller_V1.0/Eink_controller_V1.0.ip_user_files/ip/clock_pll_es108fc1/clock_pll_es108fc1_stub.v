// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Sun Oct  2 11:56:32 2022
// Host        : Duller running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.gen/sources_1/ip/clock_pll_es108fc1/clock_pll_es108fc1_stub.v
// Design      : clock_pll_es108fc1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clock_pll_es108fc1(epd_clk, clk_50m, resetn, locked, clk_in)
/* synthesis syn_black_box black_box_pad_pin="epd_clk,clk_50m,resetn,locked,clk_in" */;
  output epd_clk;
  output clk_50m;
  input resetn;
  output locked;
  input clk_in;
endmodule
