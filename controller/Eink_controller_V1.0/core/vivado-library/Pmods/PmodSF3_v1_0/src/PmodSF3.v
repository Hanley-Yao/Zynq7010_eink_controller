//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4.1 (win64) Build 1431336 Fri Dec 11 14:52:45 MST 2015
//Date        : Tue Aug 16 14:45:48 2016
//Host        : WK117 running 64-bit major release  (build 9200)
//Command     : generate_target PmodSF3.bd
//Design      : PmodSF3
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "PmodSF3,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=PmodSF3,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=1,numHierBlks=0,maxHierDepth=0,synth_mode=Global}" *) (* HW_HANDOFF = "PmodSF3.hwdef" *) 
module PmodSF3
   (AXI_LITE_araddr,
    AXI_LITE_arready,
    AXI_LITE_arvalid,
    AXI_LITE_awaddr,
    AXI_LITE_awready,
    AXI_LITE_awvalid,
    AXI_LITE_bready,
    AXI_LITE_bresp,
    AXI_LITE_bvalid,
    AXI_LITE_rdata,
    AXI_LITE_rready,
    AXI_LITE_rresp,
    AXI_LITE_rvalid,
    AXI_LITE_wdata,
    AXI_LITE_wready,
    AXI_LITE_wstrb,
    AXI_LITE_wvalid,
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
    QSPI_INTERRUPT,
    ext_spi_clk,
    s_axi_aclk,
    s_axi_aresetn);
  input [6:0]AXI_LITE_araddr;
  output AXI_LITE_arready;
  input AXI_LITE_arvalid;
  input [6:0]AXI_LITE_awaddr;
  output AXI_LITE_awready;
  input AXI_LITE_awvalid;
  input AXI_LITE_bready;
  output [1:0]AXI_LITE_bresp;
  output AXI_LITE_bvalid;
  output [31:0]AXI_LITE_rdata;
  input AXI_LITE_rready;
  output [1:0]AXI_LITE_rresp;
  output AXI_LITE_rvalid;
  input [31:0]AXI_LITE_wdata;
  output AXI_LITE_wready;
  input [3:0]AXI_LITE_wstrb;
  input AXI_LITE_wvalid;
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
  output QSPI_INTERRUPT;
  input ext_spi_clk;
  input s_axi_aclk;
  input s_axi_aresetn;

  wire [6:0]AXI_LITE_1_ARADDR;
  wire AXI_LITE_1_ARREADY;
  wire AXI_LITE_1_ARVALID;
  wire [6:0]AXI_LITE_1_AWADDR;
  wire AXI_LITE_1_AWREADY;
  wire AXI_LITE_1_AWVALID;
  wire AXI_LITE_1_BREADY;
  wire [1:0]AXI_LITE_1_BRESP;
  wire AXI_LITE_1_BVALID;
  wire [31:0]AXI_LITE_1_RDATA;
  wire AXI_LITE_1_RREADY;
  wire [1:0]AXI_LITE_1_RRESP;
  wire AXI_LITE_1_RVALID;
  wire [31:0]AXI_LITE_1_WDATA;
  wire AXI_LITE_1_WREADY;
  wire [3:0]AXI_LITE_1_WSTRB;
  wire AXI_LITE_1_WVALID;
  wire axi_quad_spi_0_io0_o;
  wire axi_quad_spi_0_io0_t;
  wire axi_quad_spi_0_io1_o;
  wire axi_quad_spi_0_io1_t;
  wire axi_quad_spi_0_io2_o;
  wire axi_quad_spi_0_io2_t;
  wire axi_quad_spi_0_io3_o;
  wire axi_quad_spi_0_io3_t;
  wire axi_quad_spi_0_ip2intc_irpt;
  wire axi_quad_spi_0_sck_o;
  wire axi_quad_spi_0_sck_t;
  wire [0:0]axi_quad_spi_0_ss_o;
  wire axi_quad_spi_0_ss_t;
  wire ext_spi_clk_1;
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
  wire pmod_bridge_0_in0_I;
  wire pmod_bridge_0_in1_I;
  wire pmod_bridge_0_in2_I;
  wire pmod_bridge_0_in3_I;
  wire pmod_bridge_0_in6_I;
  wire pmod_bridge_0_in7_I;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;

  assign AXI_LITE_1_ARADDR = AXI_LITE_araddr[6:0];
  assign AXI_LITE_1_ARVALID = AXI_LITE_arvalid;
  assign AXI_LITE_1_AWADDR = AXI_LITE_awaddr[6:0];
  assign AXI_LITE_1_AWVALID = AXI_LITE_awvalid;
  assign AXI_LITE_1_BREADY = AXI_LITE_bready;
  assign AXI_LITE_1_RREADY = AXI_LITE_rready;
  assign AXI_LITE_1_WDATA = AXI_LITE_wdata[31:0];
  assign AXI_LITE_1_WSTRB = AXI_LITE_wstrb[3:0];
  assign AXI_LITE_1_WVALID = AXI_LITE_wvalid;
  assign AXI_LITE_arready = AXI_LITE_1_ARREADY;
  assign AXI_LITE_awready = AXI_LITE_1_AWREADY;
  assign AXI_LITE_bresp[1:0] = AXI_LITE_1_BRESP;
  assign AXI_LITE_bvalid = AXI_LITE_1_BVALID;
  assign AXI_LITE_rdata[31:0] = AXI_LITE_1_RDATA;
  assign AXI_LITE_rresp[1:0] = AXI_LITE_1_RRESP;
  assign AXI_LITE_rvalid = AXI_LITE_1_RVALID;
  assign AXI_LITE_wready = AXI_LITE_1_WREADY;
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
  assign QSPI_INTERRUPT = axi_quad_spi_0_ip2intc_irpt;
  assign ext_spi_clk_1 = ext_spi_clk;
  assign pmod_bridge_0_Pmod_out_PIN10_I = Pmod_out_pin10_i;
  assign pmod_bridge_0_Pmod_out_PIN1_I = Pmod_out_pin1_i;
  assign pmod_bridge_0_Pmod_out_PIN2_I = Pmod_out_pin2_i;
  assign pmod_bridge_0_Pmod_out_PIN3_I = Pmod_out_pin3_i;
  assign pmod_bridge_0_Pmod_out_PIN4_I = Pmod_out_pin4_i;
  assign pmod_bridge_0_Pmod_out_PIN7_I = Pmod_out_pin7_i;
  assign pmod_bridge_0_Pmod_out_PIN8_I = Pmod_out_pin8_i;
  assign pmod_bridge_0_Pmod_out_PIN9_I = Pmod_out_pin9_i;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  PmodSF3_axi_quad_spi_0_0 axi_quad_spi_0
       (.ext_spi_clk(ext_spi_clk_1),
        .io0_i(pmod_bridge_0_in1_I),
        .io0_o(axi_quad_spi_0_io0_o),
        .io0_t(axi_quad_spi_0_io0_t),
        .io1_i(pmod_bridge_0_in2_I),
        .io1_o(axi_quad_spi_0_io1_o),
        .io1_t(axi_quad_spi_0_io1_t),
        .io2_i(pmod_bridge_0_in6_I),
        .io2_o(axi_quad_spi_0_io2_o),
        .io2_t(axi_quad_spi_0_io2_t),
        .io3_i(pmod_bridge_0_in7_I),
        .io3_o(axi_quad_spi_0_io3_o),
        .io3_t(axi_quad_spi_0_io3_t),
        .ip2intc_irpt(axi_quad_spi_0_ip2intc_irpt),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(AXI_LITE_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arready(AXI_LITE_1_ARREADY),
        .s_axi_arvalid(AXI_LITE_1_ARVALID),
        .s_axi_awaddr(AXI_LITE_1_AWADDR),
        .s_axi_awready(AXI_LITE_1_AWREADY),
        .s_axi_awvalid(AXI_LITE_1_AWVALID),
        .s_axi_bready(AXI_LITE_1_BREADY),
        .s_axi_bresp(AXI_LITE_1_BRESP),
        .s_axi_bvalid(AXI_LITE_1_BVALID),
        .s_axi_rdata(AXI_LITE_1_RDATA),
        .s_axi_rready(AXI_LITE_1_RREADY),
        .s_axi_rresp(AXI_LITE_1_RRESP),
        .s_axi_rvalid(AXI_LITE_1_RVALID),
        .s_axi_wdata(AXI_LITE_1_WDATA),
        .s_axi_wready(AXI_LITE_1_WREADY),
        .s_axi_wstrb(AXI_LITE_1_WSTRB),
        .s_axi_wvalid(AXI_LITE_1_WVALID),
        .sck_i(pmod_bridge_0_in3_I),
        .sck_o(axi_quad_spi_0_sck_o),
        .sck_t(axi_quad_spi_0_sck_t),
        .ss_i(pmod_bridge_0_in0_I),
        .ss_o(axi_quad_spi_0_ss_o),
        .ss_t(axi_quad_spi_0_ss_t));
  PmodSF3_pmod_bridge_0_0 pmod_bridge_0
       (.in0_I(pmod_bridge_0_in0_I),
        .in0_O(axi_quad_spi_0_ss_o),
        .in0_T(axi_quad_spi_0_ss_t),
        .in1_I(pmod_bridge_0_in1_I),
        .in1_O(axi_quad_spi_0_io0_o),
        .in1_T(axi_quad_spi_0_io0_t),
        .in2_I(pmod_bridge_0_in2_I),
        .in2_O(axi_quad_spi_0_io1_o),
        .in2_T(axi_quad_spi_0_io1_t),
        .in3_I(pmod_bridge_0_in3_I),
        .in3_O(axi_quad_spi_0_sck_o),
        .in3_T(axi_quad_spi_0_sck_t),
        .in4_O(1'b1),
        .in4_T(1'b1),
        .in5_O(1'b1),
        .in5_T(1'b1),
        .in6_I(pmod_bridge_0_in6_I),
        .in6_O(axi_quad_spi_0_io2_o),
        .in6_T(axi_quad_spi_0_io2_t),
        .in7_I(pmod_bridge_0_in7_I),
        .in7_O(axi_quad_spi_0_io3_o),
        .in7_T(axi_quad_spi_0_io3_t),
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
endmodule
