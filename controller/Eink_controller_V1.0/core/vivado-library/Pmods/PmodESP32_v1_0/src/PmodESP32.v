//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
//Date        : Wed Jun 13 09:35:49 2018
//Host        : WK142 running 64-bit major release  (build 9200)
//Command     : generate_target PmodESP32.bd
//Design      : PmodESP32
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "PmodESP32,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=PmodESP32,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=1,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "PmodESP32.hwdef" *) 
module PmodESP32
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
    AXI_LITE_UART_araddr,
    AXI_LITE_UART_arready,
    AXI_LITE_UART_arvalid,
    AXI_LITE_UART_awaddr,
    AXI_LITE_UART_awready,
    AXI_LITE_UART_awvalid,
    AXI_LITE_UART_bready,
    AXI_LITE_UART_bresp,
    AXI_LITE_UART_bvalid,
    AXI_LITE_UART_rdata,
    AXI_LITE_UART_rready,
    AXI_LITE_UART_rresp,
    AXI_LITE_UART_rvalid,
    AXI_LITE_UART_wdata,
    AXI_LITE_UART_wready,
    AXI_LITE_UART_wstrb,
    AXI_LITE_UART_wvalid,
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
    gpio_interrupt,
    s_axi_aclk,
    s_axi_aresetn,
    uart_interrupt);
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME AXI_LITE_GPIO, ADDR_WIDTH 9, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN PmodESP32_s_axi_aclk_0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 0, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [8:0]AXI_LITE_GPIO_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) output AXI_LITE_GPIO_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) input AXI_LITE_GPIO_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) input [8:0]AXI_LITE_GPIO_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) output AXI_LITE_GPIO_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) input AXI_LITE_GPIO_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) input AXI_LITE_GPIO_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) output [1:0]AXI_LITE_GPIO_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) output AXI_LITE_GPIO_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) output [31:0]AXI_LITE_GPIO_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) input AXI_LITE_GPIO_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) output [1:0]AXI_LITE_GPIO_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) output AXI_LITE_GPIO_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) input [31:0]AXI_LITE_GPIO_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) output AXI_LITE_GPIO_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) input [3:0]AXI_LITE_GPIO_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_GPIO " *) input AXI_LITE_GPIO_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME AXI_LITE_UART, ADDR_WIDTH 4, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN PmodESP32_s_axi_aclk_0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 0, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [3:0]AXI_LITE_UART_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) output AXI_LITE_UART_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) input AXI_LITE_UART_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) input [3:0]AXI_LITE_UART_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) output AXI_LITE_UART_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) input AXI_LITE_UART_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) input AXI_LITE_UART_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) output [1:0]AXI_LITE_UART_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) output AXI_LITE_UART_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) output [31:0]AXI_LITE_UART_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) input AXI_LITE_UART_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) output [1:0]AXI_LITE_UART_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) output AXI_LITE_UART_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) input [31:0]AXI_LITE_UART_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) output AXI_LITE_UART_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) input [3:0]AXI_LITE_UART_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXI_LITE_UART " *) input AXI_LITE_UART_wvalid;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) input Pmod_out_pin10_i;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin10_o;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin10_t;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) input Pmod_out_pin1_i;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin1_o;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin1_t;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) input Pmod_out_pin2_i;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin2_o;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin2_t;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) input Pmod_out_pin3_i;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin3_o;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin3_t;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) input Pmod_out_pin4_i;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin4_o;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin4_t;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) input Pmod_out_pin7_i;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin7_o;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin7_t;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) input Pmod_out_pin8_i;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin8_o;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin8_t;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) input Pmod_out_pin9_i;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin9_o;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out " *) output Pmod_out_pin9_t;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.GPIO_INTERRUPT INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.GPIO_INTERRUPT, PortWidth 1, SENSITIVITY LEVEL_HIGH" *) output gpio_interrupt;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.S_AXI_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.S_AXI_ACLK, ASSOCIATED_BUSIF AXI_LITE_GPIO:AXI_LITE_UART, ASSOCIATED_RESET s_axi_aresetn, CLK_DOMAIN PmodESP32_s_axi_aclk_0, FREQ_HZ 100000000, PHASE 0.000" *) input s_axi_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.S_AXI_ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.S_AXI_ARESETN, POLARITY ACTIVE_LOW" *) input s_axi_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.UART_INTERRUPT INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.UART_INTERRUPT, PortWidth 1, SENSITIVITY EDGE_RISING" *) output uart_interrupt;

  wire [3:0]S_AXI_0_1_ARADDR;
  wire S_AXI_0_1_ARREADY;
  wire S_AXI_0_1_ARVALID;
  wire [3:0]S_AXI_0_1_AWADDR;
  wire S_AXI_0_1_AWREADY;
  wire S_AXI_0_1_AWVALID;
  wire S_AXI_0_1_BREADY;
  wire [1:0]S_AXI_0_1_BRESP;
  wire S_AXI_0_1_BVALID;
  wire [31:0]S_AXI_0_1_RDATA;
  wire S_AXI_0_1_RREADY;
  wire [1:0]S_AXI_0_1_RRESP;
  wire S_AXI_0_1_RVALID;
  wire [31:0]S_AXI_0_1_WDATA;
  wire S_AXI_0_1_WREADY;
  wire [3:0]S_AXI_0_1_WSTRB;
  wire S_AXI_0_1_WVALID;
  wire [8:0]S_AXI_1_1_ARADDR;
  wire S_AXI_1_1_ARREADY;
  wire S_AXI_1_1_ARVALID;
  wire [8:0]S_AXI_1_1_AWADDR;
  wire S_AXI_1_1_AWREADY;
  wire S_AXI_1_1_AWVALID;
  wire S_AXI_1_1_BREADY;
  wire [1:0]S_AXI_1_1_BRESP;
  wire S_AXI_1_1_BVALID;
  wire [31:0]S_AXI_1_1_RDATA;
  wire S_AXI_1_1_RREADY;
  wire [1:0]S_AXI_1_1_RRESP;
  wire S_AXI_1_1_RVALID;
  wire [31:0]S_AXI_1_1_WDATA;
  wire S_AXI_1_1_WREADY;
  wire [3:0]S_AXI_1_1_WSTRB;
  wire S_AXI_1_1_WVALID;
  wire [3:0]axi_gpio_0_GPIO2_TRI_I;
  wire [3:0]axi_gpio_0_GPIO2_TRI_O;
  wire [3:0]axi_gpio_0_GPIO2_TRI_T;
  wire [1:0]axi_gpio_0_GPIO_TRI_I;
  wire [1:0]axi_gpio_0_GPIO_TRI_O;
  wire [1:0]axi_gpio_0_GPIO_TRI_T;
  wire axi_gpio_0_ip2intc_irpt;
  wire axi_uartlite_0_UART_RxD;
  wire axi_uartlite_0_UART_TxD;
  wire axi_uartlite_0_interrupt;
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
  wire s_axi_aclk_0_1;
  wire s_axi_aresetn_0_1;

  assign AXI_LITE_GPIO_arready = S_AXI_1_1_ARREADY;
  assign AXI_LITE_GPIO_awready = S_AXI_1_1_AWREADY;
  assign AXI_LITE_GPIO_bresp[1:0] = S_AXI_1_1_BRESP;
  assign AXI_LITE_GPIO_bvalid = S_AXI_1_1_BVALID;
  assign AXI_LITE_GPIO_rdata[31:0] = S_AXI_1_1_RDATA;
  assign AXI_LITE_GPIO_rresp[1:0] = S_AXI_1_1_RRESP;
  assign AXI_LITE_GPIO_rvalid = S_AXI_1_1_RVALID;
  assign AXI_LITE_GPIO_wready = S_AXI_1_1_WREADY;
  assign AXI_LITE_UART_arready = S_AXI_0_1_ARREADY;
  assign AXI_LITE_UART_awready = S_AXI_0_1_AWREADY;
  assign AXI_LITE_UART_bresp[1:0] = S_AXI_0_1_BRESP;
  assign AXI_LITE_UART_bvalid = S_AXI_0_1_BVALID;
  assign AXI_LITE_UART_rdata[31:0] = S_AXI_0_1_RDATA;
  assign AXI_LITE_UART_rresp[1:0] = S_AXI_0_1_RRESP;
  assign AXI_LITE_UART_rvalid = S_AXI_0_1_RVALID;
  assign AXI_LITE_UART_wready = S_AXI_0_1_WREADY;
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
  assign S_AXI_0_1_ARADDR = AXI_LITE_UART_araddr[3:0];
  assign S_AXI_0_1_ARVALID = AXI_LITE_UART_arvalid;
  assign S_AXI_0_1_AWADDR = AXI_LITE_UART_awaddr[3:0];
  assign S_AXI_0_1_AWVALID = AXI_LITE_UART_awvalid;
  assign S_AXI_0_1_BREADY = AXI_LITE_UART_bready;
  assign S_AXI_0_1_RREADY = AXI_LITE_UART_rready;
  assign S_AXI_0_1_WDATA = AXI_LITE_UART_wdata[31:0];
  assign S_AXI_0_1_WSTRB = AXI_LITE_UART_wstrb[3:0];
  assign S_AXI_0_1_WVALID = AXI_LITE_UART_wvalid;
  assign S_AXI_1_1_ARADDR = AXI_LITE_GPIO_araddr[8:0];
  assign S_AXI_1_1_ARVALID = AXI_LITE_GPIO_arvalid;
  assign S_AXI_1_1_AWADDR = AXI_LITE_GPIO_awaddr[8:0];
  assign S_AXI_1_1_AWVALID = AXI_LITE_GPIO_awvalid;
  assign S_AXI_1_1_BREADY = AXI_LITE_GPIO_bready;
  assign S_AXI_1_1_RREADY = AXI_LITE_GPIO_rready;
  assign S_AXI_1_1_WDATA = AXI_LITE_GPIO_wdata[31:0];
  assign S_AXI_1_1_WSTRB = AXI_LITE_GPIO_wstrb[3:0];
  assign S_AXI_1_1_WVALID = AXI_LITE_GPIO_wvalid;
  assign gpio_interrupt = axi_gpio_0_ip2intc_irpt;
  assign pmod_bridge_0_Pmod_out_PIN10_I = Pmod_out_pin10_i;
  assign pmod_bridge_0_Pmod_out_PIN1_I = Pmod_out_pin1_i;
  assign pmod_bridge_0_Pmod_out_PIN2_I = Pmod_out_pin2_i;
  assign pmod_bridge_0_Pmod_out_PIN3_I = Pmod_out_pin3_i;
  assign pmod_bridge_0_Pmod_out_PIN4_I = Pmod_out_pin4_i;
  assign pmod_bridge_0_Pmod_out_PIN7_I = Pmod_out_pin7_i;
  assign pmod_bridge_0_Pmod_out_PIN8_I = Pmod_out_pin8_i;
  assign pmod_bridge_0_Pmod_out_PIN9_I = Pmod_out_pin9_i;
  assign s_axi_aclk_0_1 = s_axi_aclk;
  assign s_axi_aresetn_0_1 = s_axi_aresetn;
  assign uart_interrupt = axi_uartlite_0_interrupt;
  PmodESP32_axi_gpio_0_0 axi_gpio_0
       (.gpio2_io_i(axi_gpio_0_GPIO2_TRI_I),
        .gpio2_io_o(axi_gpio_0_GPIO2_TRI_O),
        .gpio2_io_t(axi_gpio_0_GPIO2_TRI_T),
        .gpio_io_i(axi_gpio_0_GPIO_TRI_I),
        .gpio_io_o(axi_gpio_0_GPIO_TRI_O),
        .gpio_io_t(axi_gpio_0_GPIO_TRI_T),
        .ip2intc_irpt(axi_gpio_0_ip2intc_irpt),
        .s_axi_aclk(s_axi_aclk_0_1),
        .s_axi_araddr(S_AXI_1_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_0_1),
        .s_axi_arready(S_AXI_1_1_ARREADY),
        .s_axi_arvalid(S_AXI_1_1_ARVALID),
        .s_axi_awaddr(S_AXI_1_1_AWADDR),
        .s_axi_awready(S_AXI_1_1_AWREADY),
        .s_axi_awvalid(S_AXI_1_1_AWVALID),
        .s_axi_bready(S_AXI_1_1_BREADY),
        .s_axi_bresp(S_AXI_1_1_BRESP),
        .s_axi_bvalid(S_AXI_1_1_BVALID),
        .s_axi_rdata(S_AXI_1_1_RDATA),
        .s_axi_rready(S_AXI_1_1_RREADY),
        .s_axi_rresp(S_AXI_1_1_RRESP),
        .s_axi_rvalid(S_AXI_1_1_RVALID),
        .s_axi_wdata(S_AXI_1_1_WDATA),
        .s_axi_wready(S_AXI_1_1_WREADY),
        .s_axi_wstrb(S_AXI_1_1_WSTRB),
        .s_axi_wvalid(S_AXI_1_1_WVALID));
  PmodESP32_axi_uartlite_0_0 axi_uartlite_0
       (.interrupt(axi_uartlite_0_interrupt),
        .rx(axi_uartlite_0_UART_RxD),
        .s_axi_aclk(s_axi_aclk_0_1),
        .s_axi_araddr(S_AXI_0_1_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_0_1),
        .s_axi_arready(S_AXI_0_1_ARREADY),
        .s_axi_arvalid(S_AXI_0_1_ARVALID),
        .s_axi_awaddr(S_AXI_0_1_AWADDR),
        .s_axi_awready(S_AXI_0_1_AWREADY),
        .s_axi_awvalid(S_AXI_0_1_AWVALID),
        .s_axi_bready(S_AXI_0_1_BREADY),
        .s_axi_bresp(S_AXI_0_1_BRESP),
        .s_axi_bvalid(S_AXI_0_1_BVALID),
        .s_axi_rdata(S_AXI_0_1_RDATA),
        .s_axi_rready(S_AXI_0_1_RREADY),
        .s_axi_rresp(S_AXI_0_1_RRESP),
        .s_axi_rvalid(S_AXI_0_1_RVALID),
        .s_axi_wdata(S_AXI_0_1_WDATA),
        .s_axi_wready(S_AXI_0_1_WREADY),
        .s_axi_wstrb(S_AXI_0_1_WSTRB),
        .s_axi_wvalid(S_AXI_0_1_WVALID),
        .tx(axi_uartlite_0_UART_TxD));
  PmodESP32_pmod_bridge_0_0 pmod_bridge_0
       (.in1_O(axi_uartlite_0_UART_TxD),
        .in2_I(axi_uartlite_0_UART_RxD),
        .in_bottom_bus_I(axi_gpio_0_GPIO2_TRI_I),
        .in_bottom_bus_O(axi_gpio_0_GPIO2_TRI_O),
        .in_bottom_bus_T(axi_gpio_0_GPIO2_TRI_T),
        .in_top_uart_gpio_bus_I(axi_gpio_0_GPIO_TRI_I),
        .in_top_uart_gpio_bus_O(axi_gpio_0_GPIO_TRI_O),
        .in_top_uart_gpio_bus_T(axi_gpio_0_GPIO_TRI_T),
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
