//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Wed Mar 09 18:07:30 2016
//Host        : WK116 running 64-bit major release  (build 9200)
//Command     : generate_target PmodMTDS.bd
//Design      : PmodMTDS
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module PmodMTDS
   (AXI_LITE_GPIO_araddr,
    AXI_LITE_GPIO_arready,
    AXI_LITE_GPIO_arvalid,
    AXI_LITE_GPIO_awaddr,
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
    AXI_LITE_SPI_araddr,
    AXI_LITE_SPI_arready,
    AXI_LITE_SPI_arvalid,
    AXI_LITE_SPI_awaddr,
    AXI_LITE_SPI_awready,
    AXI_LITE_SPI_awvalid,
    AXI_LITE_SPI_bready,
    AXI_LITE_SPI_bresp,
    AXI_LITE_SPI_bvalid,
    AXI_LITE_SPI_rdata,
    AXI_LITE_SPI_rready,
    AXI_LITE_SPI_rresp,
    AXI_LITE_SPI_rvalid,
    AXI_LITE_SPI_wdata,
    AXI_LITE_SPI_wready,
    AXI_LITE_SPI_wstrb,
    AXI_LITE_SPI_wvalid,
    AXI_LITE_TIMER_araddr,
    AXI_LITE_TIMER_arready,
    AXI_LITE_TIMER_arvalid,
    AXI_LITE_TIMER_awaddr,
    AXI_LITE_TIMER_awready,
    AXI_LITE_TIMER_awvalid,
    AXI_LITE_TIMER_bready,
    AXI_LITE_TIMER_bresp,
    AXI_LITE_TIMER_bvalid,
    AXI_LITE_TIMER_rdata,
    AXI_LITE_TIMER_rready,
    AXI_LITE_TIMER_rresp,
    AXI_LITE_TIMER_rvalid,
    AXI_LITE_TIMER_wdata,
    AXI_LITE_TIMER_wready,
    AXI_LITE_TIMER_wstrb,
    AXI_LITE_TIMER_wvalid,
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
    SPI_SS_I,
    SPI_SS_O,
    SPI_SS_T,
    SPI_IO0_I,
    SPI_IO0_O,
    SPI_IO0_T,
    SPI_IO1_I,
    SPI_IO1_O,
    SPI_IO1_T,
    SPI_CLK_I,
    SPI_CLK_O,
    SPI_CLK_T,
    SPI_Interrupt,
    GPIO_Interrupt,
    s_axi_aclk,
    s_axi_aresetn);
    parameter Interface = "SPI";
  input [8:0]AXI_LITE_GPIO_araddr;
  output AXI_LITE_GPIO_arready;
  input AXI_LITE_GPIO_arvalid;
  input [8:0]AXI_LITE_GPIO_awaddr;
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
  input [6:0]AXI_LITE_SPI_araddr;
  output AXI_LITE_SPI_arready;
  input AXI_LITE_SPI_arvalid;
  input [6:0]AXI_LITE_SPI_awaddr;
  output AXI_LITE_SPI_awready;
  input AXI_LITE_SPI_awvalid;
  input AXI_LITE_SPI_bready;
  output [1:0]AXI_LITE_SPI_bresp;
  output AXI_LITE_SPI_bvalid;
  output [31:0]AXI_LITE_SPI_rdata;
  input AXI_LITE_SPI_rready;
  output [1:0]AXI_LITE_SPI_rresp;
  output AXI_LITE_SPI_rvalid;
  input [31:0]AXI_LITE_SPI_wdata;
  output AXI_LITE_SPI_wready;
  input [3:0]AXI_LITE_SPI_wstrb;
  input AXI_LITE_SPI_wvalid;
  input [4:0]AXI_LITE_TIMER_araddr;
  output AXI_LITE_TIMER_arready;
  input AXI_LITE_TIMER_arvalid;
  input [4:0]AXI_LITE_TIMER_awaddr;
  output AXI_LITE_TIMER_awready;
  input AXI_LITE_TIMER_awvalid;
  input AXI_LITE_TIMER_bready;
  output [1:0]AXI_LITE_TIMER_bresp;
  output AXI_LITE_TIMER_bvalid;
  output [31:0]AXI_LITE_TIMER_rdata;
  input AXI_LITE_TIMER_rready;
  output [1:0]AXI_LITE_TIMER_rresp;
  output AXI_LITE_TIMER_rvalid;
  input [31:0]AXI_LITE_TIMER_wdata;
  output AXI_LITE_TIMER_wready;
  input [3:0]AXI_LITE_TIMER_wstrb;
  input AXI_LITE_TIMER_wvalid;
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
  input SPI_SS_I;
  output SPI_SS_O;
  output SPI_SS_T;
  input SPI_IO0_I;
  output SPI_IO0_O;
  output SPI_IO0_T;
  input SPI_IO1_I;
  output SPI_IO1_O;
  output SPI_IO1_T;
  input SPI_CLK_I;
  output SPI_CLK_O;
  output SPI_CLK_T;
  output SPI_Interrupt;
  output GPIO_Interrupt;
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
  wire [8:0]S_AXI_1_ARADDR;
  wire S_AXI_1_ARREADY;
  wire S_AXI_1_ARVALID;
  wire [8:0]S_AXI_1_AWADDR;
  wire S_AXI_1_AWREADY;
  wire S_AXI_1_AWVALID;
  wire S_AXI_1_BREADY;
  wire [1:0]S_AXI_1_BRESP;
  wire S_AXI_1_BVALID;
  wire [31:0]S_AXI_1_RDATA;
  wire S_AXI_1_RREADY;
  wire [1:0]S_AXI_1_RRESP;
  wire S_AXI_1_RVALID;
  wire [31:0]S_AXI_1_WDATA;
  wire S_AXI_1_WREADY;
  wire [3:0]S_AXI_1_WSTRB;
  wire S_AXI_1_WVALID;
  wire [4:0]AXI_LITE_2_ARADDR;
    wire AXI_LITE_2_ARREADY;
    wire AXI_LITE_2_ARVALID;
    wire [4:0]AXI_LITE_2_AWADDR;
    wire AXI_LITE_2_AWREADY;
    wire AXI_LITE_2_AWVALID;
    wire AXI_LITE_2_BREADY;
    wire [1:0]AXI_LITE_2_BRESP;
    wire AXI_LITE_2_BVALID;
    wire [31:0]AXI_LITE_2_RDATA;
    wire AXI_LITE_2_RREADY;
    wire [1:0]AXI_LITE_2_RRESP;
    wire AXI_LITE_2_RVALID;
    wire [31:0]AXI_LITE_2_WDATA;
    wire AXI_LITE_2_WREADY;
    wire [3:0]AXI_LITE_2_WSTRB;
    wire AXI_LITE_2_WVALID;
  wire [4:0]axi_gpio_0_GPIO_TRI_I;
  wire [4:0]axi_gpio_0_GPIO_TRI_O;
  wire [4:0]axi_gpio_0_GPIO_TRI_T;
  wire axi_quad_spi_0_SPI_0_IO0_I;
  wire axi_quad_spi_0_SPI_0_IO0_O;
  wire axi_quad_spi_0_SPI_0_IO0_T;
  wire axi_quad_spi_0_SPI_0_IO1_I;
  wire axi_quad_spi_0_SPI_0_IO1_O;
  wire axi_quad_spi_0_SPI_0_IO1_T;
  wire axi_quad_spi_0_SPI_0_SCK_I;
  wire axi_quad_spi_0_SPI_0_SCK_O;
  wire axi_quad_spi_0_SPI_0_SCK_T;
  wire axi_quad_spi_0_SPI_0_SS_I;
  wire [0:0]axi_quad_spi_0_SPI_0_SS_O;
  wire axi_quad_spi_0_SPI_0_SS_T;
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
  wire SPI_Interrupt_1;
  wire GPIO_Interrupt_1;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;

  assign AXI_LITE_1_ARADDR = AXI_LITE_SPI_araddr[6:0];
  assign AXI_LITE_1_ARVALID = AXI_LITE_SPI_arvalid;
  assign AXI_LITE_1_AWADDR = AXI_LITE_SPI_awaddr[6:0];
  assign AXI_LITE_1_AWVALID = AXI_LITE_SPI_awvalid;
  assign AXI_LITE_1_BREADY = AXI_LITE_SPI_bready;
  assign AXI_LITE_1_RREADY = AXI_LITE_SPI_rready;
  assign AXI_LITE_1_WDATA = AXI_LITE_SPI_wdata[31:0];
  assign AXI_LITE_1_WSTRB = AXI_LITE_SPI_wstrb[3:0];
  assign AXI_LITE_1_WVALID = AXI_LITE_SPI_wvalid;
  assign AXI_LITE_GPIO_arready = S_AXI_1_ARREADY;
  assign AXI_LITE_GPIO_awready = S_AXI_1_AWREADY;
  assign AXI_LITE_GPIO_bresp[1:0] = S_AXI_1_BRESP;
  assign AXI_LITE_GPIO_bvalid = S_AXI_1_BVALID;
  assign AXI_LITE_GPIO_rdata[31:0] = S_AXI_1_RDATA;
  assign AXI_LITE_GPIO_rresp[1:0] = S_AXI_1_RRESP;
  assign AXI_LITE_GPIO_rvalid = S_AXI_1_RVALID;
  assign AXI_LITE_GPIO_wready = S_AXI_1_WREADY;
  assign AXI_LITE_SPI_arready = AXI_LITE_1_ARREADY;
  assign AXI_LITE_SPI_awready = AXI_LITE_1_AWREADY;
  assign AXI_LITE_SPI_bresp[1:0] = AXI_LITE_1_BRESP;
  assign AXI_LITE_SPI_bvalid = AXI_LITE_1_BVALID;
  assign AXI_LITE_SPI_rdata[31:0] = AXI_LITE_1_RDATA;
  assign AXI_LITE_SPI_rresp[1:0] = AXI_LITE_1_RRESP;
  assign AXI_LITE_SPI_rvalid = AXI_LITE_1_RVALID;
  assign AXI_LITE_SPI_wready = AXI_LITE_1_WREADY;
  
  assign AXI_LITE_2_ARADDR = AXI_LITE_TIMER_araddr[4:0];
  assign AXI_LITE_2_ARVALID = AXI_LITE_TIMER_arvalid;
  assign AXI_LITE_2_AWADDR = AXI_LITE_TIMER_awaddr[4:0];
  assign AXI_LITE_2_AWVALID = AXI_LITE_TIMER_awvalid;
  assign AXI_LITE_2_BREADY = AXI_LITE_TIMER_bready;
  assign AXI_LITE_2_RREADY = AXI_LITE_TIMER_rready;
  assign AXI_LITE_2_WDATA = AXI_LITE_TIMER_wdata[31:0];
  assign AXI_LITE_2_WSTRB = AXI_LITE_TIMER_wstrb[3:0];
  assign AXI_LITE_2_WVALID = AXI_LITE_TIMER_wvalid;
  assign AXI_LITE_TIMER_arready = AXI_LITE_2_ARREADY;
  assign AXI_LITE_TIMER_awready = AXI_LITE_2_AWREADY;
  assign AXI_LITE_TIMER_bresp[1:0] = AXI_LITE_2_BRESP;
  assign AXI_LITE_TIMER_bvalid = AXI_LITE_2_BVALID;
  assign AXI_LITE_TIMER_rdata[31:0] = AXI_LITE_2_RDATA;
  assign AXI_LITE_TIMER_rresp[1:0] = AXI_LITE_2_RRESP;
  assign AXI_LITE_TIMER_rvalid = AXI_LITE_2_RVALID;
  assign AXI_LITE_TIMER_wready = AXI_LITE_2_WREADY;

  assign S_AXI_1_ARADDR = AXI_LITE_GPIO_araddr[8:0];
  assign S_AXI_1_ARVALID = AXI_LITE_GPIO_arvalid;
  assign S_AXI_1_AWADDR = AXI_LITE_GPIO_awaddr[8:0];
  assign S_AXI_1_AWVALID = AXI_LITE_GPIO_awvalid;
  assign S_AXI_1_BREADY = AXI_LITE_GPIO_bready;
  assign S_AXI_1_RREADY = AXI_LITE_GPIO_rready;
  assign S_AXI_1_WDATA = AXI_LITE_GPIO_wdata[31:0];
  assign S_AXI_1_WSTRB = AXI_LITE_GPIO_wstrb[3:0];
  assign S_AXI_1_WVALID = AXI_LITE_GPIO_wvalid;
  assign ext_spi_clk_1 = s_axi_aclk;

  assign SPI_Interrupt = SPI_Interrupt_1;
  assign GPIO_Interrupt = GPIO_Interrupt_1;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  PmodMTDS_axi_gpio_0_0 axi_gpio_0
       (.gpio_io_i(axi_gpio_0_GPIO_TRI_I[1 : 0]),
        .gpio_io_o(axi_gpio_0_GPIO_TRI_O[1 : 0]),
        .gpio_io_t(axi_gpio_0_GPIO_TRI_T[1 : 0]),
        .gpio2_io_i(axi_gpio_0_GPIO_TRI_I[4 : 2]),
        .gpio2_io_o(axi_gpio_0_GPIO_TRI_O[4 : 2]),
        .gpio2_io_t(axi_gpio_0_GPIO_TRI_T[4 : 2]),
        .ip2intc_irpt(GPIO_Interrupt_1),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(S_AXI_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arready(S_AXI_1_ARREADY),
        .s_axi_arvalid(S_AXI_1_ARVALID),
        .s_axi_awaddr(S_AXI_1_AWADDR),
        .s_axi_awready(S_AXI_1_AWREADY),
        .s_axi_awvalid(S_AXI_1_AWVALID),
        .s_axi_bready(S_AXI_1_BREADY),
        .s_axi_bresp(S_AXI_1_BRESP),
        .s_axi_bvalid(S_AXI_1_BVALID),
        .s_axi_rdata(S_AXI_1_RDATA),
        .s_axi_rready(S_AXI_1_RREADY),
        .s_axi_rresp(S_AXI_1_RRESP),
        .s_axi_rvalid(S_AXI_1_RVALID),
        .s_axi_wdata(S_AXI_1_WDATA),
        .s_axi_wready(S_AXI_1_WREADY),
        .s_axi_wstrb(S_AXI_1_WSTRB),
        .s_axi_wvalid(S_AXI_1_WVALID));
  PmodMTDS_axi_quad_spi_0_0 axi_quad_spi_0
       (.ext_spi_clk(ext_spi_clk_1),
        .io0_i(axi_quad_spi_0_SPI_0_IO0_I),
        .io0_o(axi_quad_spi_0_SPI_0_IO0_O),
        .io0_t(axi_quad_spi_0_SPI_0_IO0_T),
        .io1_i(axi_quad_spi_0_SPI_0_IO1_I),
        .io1_o(axi_quad_spi_0_SPI_0_IO1_O),
        .io1_t(axi_quad_spi_0_SPI_0_IO1_T),
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
        .sck_i(axi_quad_spi_0_SPI_0_SCK_I),
        .sck_o(axi_quad_spi_0_SPI_0_SCK_O),
        .sck_t(axi_quad_spi_0_SPI_0_SCK_T),
        .ss_i(0'b1),
        .ss_o(0'b1),
        .ss_t(0'b1),
        .ip2intc_irpt(SPI_Interrupt_1));
        

generate
    case(Interface)    
    "PMOD":begin
	    PmodMTDS_pmod_bridge_0_0 pmod_bridge_0
		   (.in0_I(axi_gpio_0_GPIO_TRI_I[4]),
			.in0_O(axi_gpio_0_GPIO_TRI_O[4]),
			.in0_T(axi_gpio_0_GPIO_TRI_T[4]),
			.in1_I(axi_quad_spi_0_SPI_0_IO0_I),
			.in1_O(axi_quad_spi_0_SPI_0_IO0_O),
			.in1_T(axi_quad_spi_0_SPI_0_IO0_T),
			.in2_I(axi_quad_spi_0_SPI_0_IO1_I),
			.in2_O(axi_quad_spi_0_SPI_0_IO1_O),
			.in2_T(axi_quad_spi_0_SPI_0_IO1_T),
			.in3_I(axi_quad_spi_0_SPI_0_SCK_I),
			.in3_O(axi_quad_spi_0_SPI_0_SCK_O),
			.in3_T(axi_quad_spi_0_SPI_0_SCK_T),
			.in_bottom_bus_I(axi_gpio_0_GPIO_TRI_I[3:0]),
			.in_bottom_bus_O(axi_gpio_0_GPIO_TRI_O[3:0]),
			.in_bottom_bus_T(axi_gpio_0_GPIO_TRI_T[3:0]),
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
        assign pmod_bridge_0_Pmod_out_PIN10_I = Pmod_out_pin10_i;
        assign pmod_bridge_0_Pmod_out_PIN1_I = Pmod_out_pin1_i;
        assign pmod_bridge_0_Pmod_out_PIN2_I = Pmod_out_pin2_i;
        assign pmod_bridge_0_Pmod_out_PIN3_I = Pmod_out_pin3_i;
        assign pmod_bridge_0_Pmod_out_PIN4_I = Pmod_out_pin4_i;
        assign pmod_bridge_0_Pmod_out_PIN7_I = Pmod_out_pin7_i;
        assign pmod_bridge_0_Pmod_out_PIN8_I = Pmod_out_pin8_i;
        assign pmod_bridge_0_Pmod_out_PIN9_I = Pmod_out_pin9_i;
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
     end
     "SPI":begin
        assign axi_quad_spi_0_SPI_0_IO0_I=SPI_IO0_I;
        assign SPI_IO0_O=axi_quad_spi_0_SPI_0_IO0_O;
        assign SPI_IO0_T=axi_quad_spi_0_SPI_0_IO0_T;
        assign axi_quad_spi_0_SPI_0_IO1_I=SPI_IO1_I;
        assign SPI_IO1_O=axi_quad_spi_0_SPI_0_IO1_O;
        assign SPI_IO1_T=axi_quad_spi_0_SPI_0_IO1_T;
        assign axi_quad_spi_0_SPI_0_SCK_I=SPI_CLK_I;
        assign SPI_CLK_O=axi_quad_spi_0_SPI_0_SCK_O;
        assign SPI_CLK_T=axi_quad_spi_0_SPI_0_SCK_T;
        assign axi_gpio_0_GPIO_TRI_I[4]=SPI_SS_I;
        assign SPI_SS_O=axi_gpio_0_GPIO_TRI_O[4];
        assign SPI_SS_T=axi_gpio_0_GPIO_TRI_T[4];
		PmodMTDS_pmod_bridge_0_0 pmod_bridge_0
		   (.in0_I(),
			.in0_O(),
			.in0_T(),
			.in1_I(),
			.in1_O(),
			.in1_T(),
			.in2_I(),
			.in2_O(),
			.in2_T(),
			.in3_I(),
			.in3_O(),
			.in3_T(),
			.in_bottom_bus_I(axi_gpio_0_GPIO_TRI_I[3:0]),
			.in_bottom_bus_O(axi_gpio_0_GPIO_TRI_O[3:0]),
			.in_bottom_bus_T(axi_gpio_0_GPIO_TRI_T[3:0]),
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
     end
    endcase
 endgenerate
    axi_timer_0 axi_timer_0
       (.capturetrig0(),
        .capturetrig1(),
        .generateout0(),
        .generateout1(),
        .pwm0(),
        .interrupt(),
        .freeze(),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_awaddr(AXI_LITE_2_AWADDR),
        .s_axi_awvalid(AXI_LITE_2_AWVALID),
        .s_axi_awready(AXI_LITE_2_AWREADY),
        .s_axi_wdata(AXI_LITE_2_WDATA),
        .s_axi_wstrb(AXI_LITE_2_WSTRB),
        .s_axi_wvalid(AXI_LITE_2_WVALID),
        .s_axi_wready(AXI_LITE_2_WREADY),
        .s_axi_bresp(AXI_LITE_2_BRESP),
        .s_axi_bvalid(AXI_LITE_2_BVALID),
        .s_axi_bready(AXI_LITE_2_BREADY),
        .s_axi_araddr(AXI_LITE_2_ARADDR),
        .s_axi_arvalid(AXI_LITE_2_ARVALID),
        .s_axi_arready(AXI_LITE_2_ARREADY),
        .s_axi_rdata(AXI_LITE_2_RDATA),
        .s_axi_rresp(AXI_LITE_2_RRESP),      
        .s_axi_rvalid(AXI_LITE_2_RVALID),     
        .s_axi_rready(AXI_LITE_2_RREADY));     
endmodule
