//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Sun Oct  2 11:37:45 2022
//Host        : Duller running 64-bit major release  (build 9200)
//Command     : generate_target ps_system_wrapper.bd
//Design      : ps_system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module ps_system_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    clk,
    data_fdma_raddr,
    data_fdma_rareq,
    data_fdma_rbusy,
    data_fdma_rdata,
    data_fdma_rready,
    data_fdma_rsize,
    data_fdma_rvalid,
    data_fdma_waddr,
    data_fdma_wareq,
    data_fdma_wbusy,
    data_fdma_wdata,
    data_fdma_wready,
    data_fdma_wsize,
    data_fdma_wvalid,
    gray_fdma_raddr,
    gray_fdma_rareq,
    gray_fdma_rbusy,
    gray_fdma_rdata,
    gray_fdma_rready,
    gray_fdma_rsize,
    gray_fdma_rvalid,
    gray_fdma_waddr,
    gray_fdma_wareq,
    gray_fdma_wbusy,
    gray_fdma_wdata,
    gray_fdma_wready,
    gray_fdma_wsize,
    gray_fdma_wvalid,
    rst_n,
    texture_fdma_raddr,
    texture_fdma_rareq,
    texture_fdma_rbusy,
    texture_fdma_rdata,
    texture_fdma_rready,
    texture_fdma_rsize,
    texture_fdma_rvalid,
    texture_fdma_waddr,
    texture_fdma_wareq,
    texture_fdma_wbusy,
    texture_fdma_wdata,
    texture_fdma_wready,
    texture_fdma_wsize,
    texture_fdma_wvalid);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input clk;
  input [31:0]data_fdma_raddr;
  input data_fdma_rareq;
  output data_fdma_rbusy;
  output [63:0]data_fdma_rdata;
  input data_fdma_rready;
  input [15:0]data_fdma_rsize;
  output data_fdma_rvalid;
  input [31:0]data_fdma_waddr;
  input data_fdma_wareq;
  output data_fdma_wbusy;
  input [63:0]data_fdma_wdata;
  input data_fdma_wready;
  input [15:0]data_fdma_wsize;
  output data_fdma_wvalid;
  input [31:0]gray_fdma_raddr;
  input gray_fdma_rareq;
  output gray_fdma_rbusy;
  output [63:0]gray_fdma_rdata;
  input gray_fdma_rready;
  input [15:0]gray_fdma_rsize;
  output gray_fdma_rvalid;
  input [31:0]gray_fdma_waddr;
  input gray_fdma_wareq;
  output gray_fdma_wbusy;
  input [63:0]gray_fdma_wdata;
  input gray_fdma_wready;
  input [15:0]gray_fdma_wsize;
  output gray_fdma_wvalid;
  input [0:0]rst_n;
  input [31:0]texture_fdma_raddr;
  input texture_fdma_rareq;
  output texture_fdma_rbusy;
  output [63:0]texture_fdma_rdata;
  input texture_fdma_rready;
  input [15:0]texture_fdma_rsize;
  output texture_fdma_rvalid;
  input [31:0]texture_fdma_waddr;
  input texture_fdma_wareq;
  output texture_fdma_wbusy;
  input [63:0]texture_fdma_wdata;
  input texture_fdma_wready;
  input [15:0]texture_fdma_wsize;
  output texture_fdma_wvalid;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire clk;
  wire [31:0]data_fdma_raddr;
  wire data_fdma_rareq;
  wire data_fdma_rbusy;
  wire [63:0]data_fdma_rdata;
  wire data_fdma_rready;
  wire [15:0]data_fdma_rsize;
  wire data_fdma_rvalid;
  wire [31:0]data_fdma_waddr;
  wire data_fdma_wareq;
  wire data_fdma_wbusy;
  wire [63:0]data_fdma_wdata;
  wire data_fdma_wready;
  wire [15:0]data_fdma_wsize;
  wire data_fdma_wvalid;
  wire [31:0]gray_fdma_raddr;
  wire gray_fdma_rareq;
  wire gray_fdma_rbusy;
  wire [63:0]gray_fdma_rdata;
  wire gray_fdma_rready;
  wire [15:0]gray_fdma_rsize;
  wire gray_fdma_rvalid;
  wire [31:0]gray_fdma_waddr;
  wire gray_fdma_wareq;
  wire gray_fdma_wbusy;
  wire [63:0]gray_fdma_wdata;
  wire gray_fdma_wready;
  wire [15:0]gray_fdma_wsize;
  wire gray_fdma_wvalid;
  wire [0:0]rst_n;
  wire [31:0]texture_fdma_raddr;
  wire texture_fdma_rareq;
  wire texture_fdma_rbusy;
  wire [63:0]texture_fdma_rdata;
  wire texture_fdma_rready;
  wire [15:0]texture_fdma_rsize;
  wire texture_fdma_rvalid;
  wire [31:0]texture_fdma_waddr;
  wire texture_fdma_wareq;
  wire texture_fdma_wbusy;
  wire [63:0]texture_fdma_wdata;
  wire texture_fdma_wready;
  wire [15:0]texture_fdma_wsize;
  wire texture_fdma_wvalid;

  ps_system ps_system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .clk(clk),
        .data_fdma_raddr(data_fdma_raddr),
        .data_fdma_rareq(data_fdma_rareq),
        .data_fdma_rbusy(data_fdma_rbusy),
        .data_fdma_rdata(data_fdma_rdata),
        .data_fdma_rready(data_fdma_rready),
        .data_fdma_rsize(data_fdma_rsize),
        .data_fdma_rvalid(data_fdma_rvalid),
        .data_fdma_waddr(data_fdma_waddr),
        .data_fdma_wareq(data_fdma_wareq),
        .data_fdma_wbusy(data_fdma_wbusy),
        .data_fdma_wdata(data_fdma_wdata),
        .data_fdma_wready(data_fdma_wready),
        .data_fdma_wsize(data_fdma_wsize),
        .data_fdma_wvalid(data_fdma_wvalid),
        .gray_fdma_raddr(gray_fdma_raddr),
        .gray_fdma_rareq(gray_fdma_rareq),
        .gray_fdma_rbusy(gray_fdma_rbusy),
        .gray_fdma_rdata(gray_fdma_rdata),
        .gray_fdma_rready(gray_fdma_rready),
        .gray_fdma_rsize(gray_fdma_rsize),
        .gray_fdma_rvalid(gray_fdma_rvalid),
        .gray_fdma_waddr(gray_fdma_waddr),
        .gray_fdma_wareq(gray_fdma_wareq),
        .gray_fdma_wbusy(gray_fdma_wbusy),
        .gray_fdma_wdata(gray_fdma_wdata),
        .gray_fdma_wready(gray_fdma_wready),
        .gray_fdma_wsize(gray_fdma_wsize),
        .gray_fdma_wvalid(gray_fdma_wvalid),
        .rst_n(rst_n),
        .texture_fdma_raddr(texture_fdma_raddr),
        .texture_fdma_rareq(texture_fdma_rareq),
        .texture_fdma_rbusy(texture_fdma_rbusy),
        .texture_fdma_rdata(texture_fdma_rdata),
        .texture_fdma_rready(texture_fdma_rready),
        .texture_fdma_rsize(texture_fdma_rsize),
        .texture_fdma_rvalid(texture_fdma_rvalid),
        .texture_fdma_waddr(texture_fdma_waddr),
        .texture_fdma_wareq(texture_fdma_wareq),
        .texture_fdma_wbusy(texture_fdma_wbusy),
        .texture_fdma_wdata(texture_fdma_wdata),
        .texture_fdma_wready(texture_fdma_wready),
        .texture_fdma_wsize(texture_fdma_wsize),
        .texture_fdma_wvalid(texture_fdma_wvalid));
endmodule
