//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
//Date        : Mon Sep 11 17:52:03 2017
//Host        : WK39 running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target PmodMAXSONAR.bd
//Design      : PmodMAXSONAR
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "PmodMAXSONAR,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=PmodMAXSONAR,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=4,numReposBlks=4,numNonXlnxBlks=2,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "PmodMAXSONAR.hwdef" *) 
module PmodMAXSONAR
   (AXI_LITE_GPIO_araddr,
    AXI_LITE_GPIO_arprot,
    AXI_LITE_GPIO_arready,
    AXI_LITE_GPIO_arvalid,
    AXI_LITE_GPIO_awaddr,
    AXI_LITE_GPIO_awprot,
    AXI_LITE_GPIO_awready,
    AXI_LITE_GPIO_awvalid,
    AXI_LITE_GPIO_bready,
    AXI_LITE_GPIO_bresp,
    AXI_LITE_GPIO_bvalid,
    AXI_LITE_GPIO_rdata,
    AXI_LITE_GPIO_rready,
    AXI_LITE_GPIO_rresp,
    AXI_LITE_GPIO_rvalid,
    AXI_LITE_GPIO_wdata,
    AXI_LITE_GPIO_wready,
    AXI_LITE_GPIO_wstrb,
    AXI_LITE_GPIO_wvalid,
    Pmod_out_pin10_i,
    Pmod_out_pin10_o,
    Pmod_out_pin10_t,
    Pmod_out_pin1_i,
    Pmod_out_pin1_o,
    Pmod_out_pin1_t,
    Pmod_out_pin2_i,
    Pmod_out_pin2_o,
    Pmod_out_pin2_t,
    Pmod_out_pin3_i,
    Pmod_out_pin3_o,
    Pmod_out_pin3_t,
    Pmod_out_pin4_i,
    Pmod_out_pin4_o,
    Pmod_out_pin4_t,
    Pmod_out_pin7_i,
    Pmod_out_pin7_o,
    Pmod_out_pin7_t,
    Pmod_out_pin8_i,
    Pmod_out_pin8_o,
    Pmod_out_pin8_t,
    Pmod_out_pin9_i,
    Pmod_out_pin9_o,
    Pmod_out_pin9_t,
    s00_axi_aclk,
    s00_axi_aresetn);
  input [3:0]AXI_LITE_GPIO_araddr;
  input [2:0]AXI_LITE_GPIO_arprot;
  output AXI_LITE_GPIO_arready;
  input AXI_LITE_GPIO_arvalid;
  input [3:0]AXI_LITE_GPIO_awaddr;
  input [2:0]AXI_LITE_GPIO_awprot;
  output AXI_LITE_GPIO_awready;
  input AXI_LITE_GPIO_awvalid;
  input AXI_LITE_GPIO_bready;
  output [1:0]AXI_LITE_GPIO_bresp;
  output AXI_LITE_GPIO_bvalid;
  output [31:0]AXI_LITE_GPIO_rdata;
  input AXI_LITE_GPIO_rready;
  output [1:0]AXI_LITE_GPIO_rresp;
  output AXI_LITE_GPIO_rvalid;
  input [31:0]AXI_LITE_GPIO_wdata;
  output AXI_LITE_GPIO_wready;
  input [3:0]AXI_LITE_GPIO_wstrb;
  input AXI_LITE_GPIO_wvalid;
  input Pmod_out_pin10_i;
  output Pmod_out_pin10_o;
  output Pmod_out_pin10_t;
  input Pmod_out_pin1_i;
  output Pmod_out_pin1_o;
  output Pmod_out_pin1_t;
  input Pmod_out_pin2_i;
  output Pmod_out_pin2_o;
  output Pmod_out_pin2_t;
  input Pmod_out_pin3_i;
  output Pmod_out_pin3_o;
  output Pmod_out_pin3_t;
  input Pmod_out_pin4_i;
  output Pmod_out_pin4_o;
  output Pmod_out_pin4_t;
  input Pmod_out_pin7_i;
  output Pmod_out_pin7_o;
  output Pmod_out_pin7_t;
  input Pmod_out_pin8_i;
  output Pmod_out_pin8_o;
  output Pmod_out_pin8_t;
  input Pmod_out_pin9_i;
  output Pmod_out_pin9_o;
  output Pmod_out_pin9_t;
  input s00_axi_aclk;
  input s00_axi_aresetn;

  wire [3:0]AXI_LITE_GPIO_1_ARADDR;
  wire [2:0]AXI_LITE_GPIO_1_ARPROT;
  wire AXI_LITE_GPIO_1_ARREADY;
  wire AXI_LITE_GPIO_1_ARVALID;
  wire [3:0]AXI_LITE_GPIO_1_AWADDR;
  wire [2:0]AXI_LITE_GPIO_1_AWPROT;
  wire AXI_LITE_GPIO_1_AWREADY;
  wire AXI_LITE_GPIO_1_AWVALID;
  wire AXI_LITE_GPIO_1_BREADY;
  wire [1:0]AXI_LITE_GPIO_1_BRESP;
  wire AXI_LITE_GPIO_1_BVALID;
  wire [31:0]AXI_LITE_GPIO_1_RDATA;
  wire AXI_LITE_GPIO_1_RREADY;
  wire [1:0]AXI_LITE_GPIO_1_RRESP;
  wire AXI_LITE_GPIO_1_RVALID;
  wire [31:0]AXI_LITE_GPIO_1_WDATA;
  wire AXI_LITE_GPIO_1_WREADY;
  wire [3:0]AXI_LITE_GPIO_1_WSTRB;
  wire AXI_LITE_GPIO_1_WVALID;
  wire pmod_bridge_0_Pmod_out_PIN10_I;
  wire pmod_bridge_0_Pmod_out_PIN10_O;
  wire pmod_bridge_0_Pmod_out_PIN10_T;
  wire pmod_bridge_0_Pmod_out_PIN1_I;
  wire pmod_bridge_0_Pmod_out_PIN1_O;
  wire pmod_bridge_0_Pmod_out_PIN1_T;
  wire pmod_bridge_0_Pmod_out_PIN2_I;
  wire pmod_bridge_0_Pmod_out_PIN2_O;
  wire pmod_bridge_0_Pmod_out_PIN2_T;
  wire pmod_bridge_0_Pmod_out_PIN3_I;
  wire pmod_bridge_0_Pmod_out_PIN3_O;
  wire pmod_bridge_0_Pmod_out_PIN3_T;
  wire pmod_bridge_0_Pmod_out_PIN4_I;
  wire pmod_bridge_0_Pmod_out_PIN4_O;
  wire pmod_bridge_0_Pmod_out_PIN4_T;
  wire pmod_bridge_0_Pmod_out_PIN7_I;
  wire pmod_bridge_0_Pmod_out_PIN7_O;
  wire pmod_bridge_0_Pmod_out_PIN7_T;
  wire pmod_bridge_0_Pmod_out_PIN8_I;
  wire pmod_bridge_0_Pmod_out_PIN8_O;
  wire pmod_bridge_0_Pmod_out_PIN8_T;
  wire pmod_bridge_0_Pmod_out_PIN9_I;
  wire pmod_bridge_0_Pmod_out_PIN9_O;
  wire pmod_bridge_0_Pmod_out_PIN9_T;
  wire [3:0]pmod_bridge_0_in_top_bus_I;
  wire s00_axi_aclk_1;
  wire s00_axi_aresetn_1;
  wire [3:0]xlconstant_0_dout;
  wire [0:0]xlslice_0_Dout;

  assign AXI_LITE_GPIO_1_ARADDR = AXI_LITE_GPIO_araddr[3:0];
  assign AXI_LITE_GPIO_1_ARPROT = AXI_LITE_GPIO_arprot[2:0];
  assign AXI_LITE_GPIO_1_ARVALID = AXI_LITE_GPIO_arvalid;
  assign AXI_LITE_GPIO_1_AWADDR = AXI_LITE_GPIO_awaddr[3:0];
  assign AXI_LITE_GPIO_1_AWPROT = AXI_LITE_GPIO_awprot[2:0];
  assign AXI_LITE_GPIO_1_AWVALID = AXI_LITE_GPIO_awvalid;
  assign AXI_LITE_GPIO_1_BREADY = AXI_LITE_GPIO_bready;
  assign AXI_LITE_GPIO_1_RREADY = AXI_LITE_GPIO_rready;
  assign AXI_LITE_GPIO_1_WDATA = AXI_LITE_GPIO_wdata[31:0];
  assign AXI_LITE_GPIO_1_WSTRB = AXI_LITE_GPIO_wstrb[3:0];
  assign AXI_LITE_GPIO_1_WVALID = AXI_LITE_GPIO_wvalid;
  assign AXI_LITE_GPIO_arready = AXI_LITE_GPIO_1_ARREADY;
  assign AXI_LITE_GPIO_awready = AXI_LITE_GPIO_1_AWREADY;
  assign AXI_LITE_GPIO_bresp[1:0] = AXI_LITE_GPIO_1_BRESP;
  assign AXI_LITE_GPIO_bvalid = AXI_LITE_GPIO_1_BVALID;
  assign AXI_LITE_GPIO_rdata[31:0] = AXI_LITE_GPIO_1_RDATA;
  assign AXI_LITE_GPIO_rresp[1:0] = AXI_LITE_GPIO_1_RRESP;
  assign AXI_LITE_GPIO_rvalid = AXI_LITE_GPIO_1_RVALID;
  assign AXI_LITE_GPIO_wready = AXI_LITE_GPIO_1_WREADY;
  assign Pmod_out_pin10_o = pmod_bridge_0_Pmod_out_PIN10_O;
  assign Pmod_out_pin10_t = pmod_bridge_0_Pmod_out_PIN10_T;
  assign Pmod_out_pin1_o = pmod_bridge_0_Pmod_out_PIN1_O;
  assign Pmod_out_pin1_t = pmod_bridge_0_Pmod_out_PIN1_T;
  assign Pmod_out_pin2_o = pmod_bridge_0_Pmod_out_PIN2_O;
  assign Pmod_out_pin2_t = pmod_bridge_0_Pmod_out_PIN2_T;
  assign Pmod_out_pin3_o = pmod_bridge_0_Pmod_out_PIN3_O;
  assign Pmod_out_pin3_t = pmod_bridge_0_Pmod_out_PIN3_T;
  assign Pmod_out_pin4_o = pmod_bridge_0_Pmod_out_PIN4_O;
  assign Pmod_out_pin4_t = pmod_bridge_0_Pmod_out_PIN4_T;
  assign Pmod_out_pin7_o = pmod_bridge_0_Pmod_out_PIN7_O;
  assign Pmod_out_pin7_t = pmod_bridge_0_Pmod_out_PIN7_T;
  assign Pmod_out_pin8_o = pmod_bridge_0_Pmod_out_PIN8_O;
  assign Pmod_out_pin8_t = pmod_bridge_0_Pmod_out_PIN8_T;
  assign Pmod_out_pin9_o = pmod_bridge_0_Pmod_out_PIN9_O;
  assign Pmod_out_pin9_t = pmod_bridge_0_Pmod_out_PIN9_T;
  assign pmod_bridge_0_Pmod_out_PIN10_I = Pmod_out_pin10_i;
  assign pmod_bridge_0_Pmod_out_PIN1_I = Pmod_out_pin1_i;
  assign pmod_bridge_0_Pmod_out_PIN2_I = Pmod_out_pin2_i;
  assign pmod_bridge_0_Pmod_out_PIN3_I = Pmod_out_pin3_i;
  assign pmod_bridge_0_Pmod_out_PIN4_I = Pmod_out_pin4_i;
  assign pmod_bridge_0_Pmod_out_PIN7_I = Pmod_out_pin7_i;
  assign pmod_bridge_0_Pmod_out_PIN8_I = Pmod_out_pin8_i;
  assign pmod_bridge_0_Pmod_out_PIN9_I = Pmod_out_pin9_i;
  assign s00_axi_aclk_1 = s00_axi_aclk;
  assign s00_axi_aresetn_1 = s00_axi_aresetn;
  PmodMAXSONAR_PWM_Analyzer_0_1 PWM_Analyzer_0
       (.pwm(xlslice_0_Dout),
        .s00_axi_aclk(s00_axi_aclk_1),
        .s00_axi_araddr(AXI_LITE_GPIO_1_ARADDR),
        .s00_axi_aresetn(s00_axi_aresetn_1),
        .s00_axi_arprot(AXI_LITE_GPIO_1_ARPROT),
        .s00_axi_arready(AXI_LITE_GPIO_1_ARREADY),
        .s00_axi_arvalid(AXI_LITE_GPIO_1_ARVALID),
        .s00_axi_awaddr(AXI_LITE_GPIO_1_AWADDR),
        .s00_axi_awprot(AXI_LITE_GPIO_1_AWPROT),
        .s00_axi_awready(AXI_LITE_GPIO_1_AWREADY),
        .s00_axi_awvalid(AXI_LITE_GPIO_1_AWVALID),
        .s00_axi_bready(AXI_LITE_GPIO_1_BREADY),
        .s00_axi_bresp(AXI_LITE_GPIO_1_BRESP),
        .s00_axi_bvalid(AXI_LITE_GPIO_1_BVALID),
        .s00_axi_rdata(AXI_LITE_GPIO_1_RDATA),
        .s00_axi_rready(AXI_LITE_GPIO_1_RREADY),
        .s00_axi_rresp(AXI_LITE_GPIO_1_RRESP),
        .s00_axi_rvalid(AXI_LITE_GPIO_1_RVALID),
        .s00_axi_wdata(AXI_LITE_GPIO_1_WDATA),
        .s00_axi_wready(AXI_LITE_GPIO_1_WREADY),
        .s00_axi_wstrb(AXI_LITE_GPIO_1_WSTRB),
        .s00_axi_wvalid(AXI_LITE_GPIO_1_WVALID));
  PmodMAXSONAR_pmod_bridge_0_0 pmod_bridge_0
       (.in_top_bus_I(pmod_bridge_0_in_top_bus_I),
        .in_top_bus_O(xlconstant_0_dout),
        .in_top_bus_T(xlconstant_0_dout),
        .out0_I(pmod_bridge_0_Pmod_out_PIN1_I),
        .out0_O(pmod_bridge_0_Pmod_out_PIN1_O),
        .out0_T(pmod_bridge_0_Pmod_out_PIN1_T),
        .out1_I(pmod_bridge_0_Pmod_out_PIN2_I),
        .out1_O(pmod_bridge_0_Pmod_out_PIN2_O),
        .out1_T(pmod_bridge_0_Pmod_out_PIN2_T),
        .out2_I(pmod_bridge_0_Pmod_out_PIN3_I),
        .out2_O(pmod_bridge_0_Pmod_out_PIN3_O),
        .out2_T(pmod_bridge_0_Pmod_out_PIN3_T),
        .out3_I(pmod_bridge_0_Pmod_out_PIN4_I),
        .out3_O(pmod_bridge_0_Pmod_out_PIN4_O),
        .out3_T(pmod_bridge_0_Pmod_out_PIN4_T),
        .out4_I(pmod_bridge_0_Pmod_out_PIN7_I),
        .out4_O(pmod_bridge_0_Pmod_out_PIN7_O),
        .out4_T(pmod_bridge_0_Pmod_out_PIN7_T),
        .out5_I(pmod_bridge_0_Pmod_out_PIN8_I),
        .out5_O(pmod_bridge_0_Pmod_out_PIN8_O),
        .out5_T(pmod_bridge_0_Pmod_out_PIN8_T),
        .out6_I(pmod_bridge_0_Pmod_out_PIN9_I),
        .out6_O(pmod_bridge_0_Pmod_out_PIN9_O),
        .out6_T(pmod_bridge_0_Pmod_out_PIN9_T),
        .out7_I(pmod_bridge_0_Pmod_out_PIN10_I),
        .out7_O(pmod_bridge_0_Pmod_out_PIN10_O),
        .out7_T(pmod_bridge_0_Pmod_out_PIN10_T));
  PmodMAXSONAR_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
  PmodMAXSONAR_xlslice_0_0 xlslice_0
       (.Din(pmod_bridge_0_in_top_bus_I),
        .Dout(xlslice_0_Dout));
endmodule
