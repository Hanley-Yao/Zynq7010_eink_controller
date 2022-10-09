//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Tue Apr 25 09:03:37 2017
//Host        : WK115 running 64-bit major release  (build 9200)
//Command     : generate_target PmodAMP2.bd
//Design      : PmodAMP2
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "PmodAMP2,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=PmodAMP2,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=6,numReposBlks=6,numNonXlnxBlks=2,numHierBlks=0,maxHierDepth=0,synth_mode=Global}" *) (* HW_HANDOFF = "PmodAMP2.hwdef" *) 
module PmodAMP2
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
    AXI_LITE_PWM_araddr,
    AXI_LITE_PWM_arprot,
    AXI_LITE_PWM_arready,
    AXI_LITE_PWM_arvalid,
    AXI_LITE_PWM_awaddr,
    AXI_LITE_PWM_awprot,
    AXI_LITE_PWM_awready,
    AXI_LITE_PWM_awvalid,
    AXI_LITE_PWM_bready,
    AXI_LITE_PWM_bresp,
    AXI_LITE_PWM_bvalid,
    AXI_LITE_PWM_rdata,
    AXI_LITE_PWM_rready,
    AXI_LITE_PWM_rresp,
    AXI_LITE_PWM_rvalid,
    AXI_LITE_PWM_wdata,
    AXI_LITE_PWM_wready,
    AXI_LITE_PWM_wstrb,
    AXI_LITE_PWM_wvalid,
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
    s_axi_aclk,
    s_axi_aresetn,
    timer_interrupt);
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
  input [6:0]AXI_LITE_PWM_araddr;
  input [2:0]AXI_LITE_PWM_arprot;
  output AXI_LITE_PWM_arready;
  input AXI_LITE_PWM_arvalid;
  input [6:0]AXI_LITE_PWM_awaddr;
  input [2:0]AXI_LITE_PWM_awprot;
  output AXI_LITE_PWM_awready;
  input AXI_LITE_PWM_awvalid;
  input AXI_LITE_PWM_bready;
  output [1:0]AXI_LITE_PWM_bresp;
  output AXI_LITE_PWM_bvalid;
  output [31:0]AXI_LITE_PWM_rdata;
  input AXI_LITE_PWM_rready;
  output [1:0]AXI_LITE_PWM_rresp;
  output AXI_LITE_PWM_rvalid;
  input [31:0]AXI_LITE_PWM_wdata;
  output AXI_LITE_PWM_wready;
  input [3:0]AXI_LITE_PWM_wstrb;
  input AXI_LITE_PWM_wvalid;
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
  input s_axi_aclk;
  input s_axi_aresetn;
  output timer_interrupt;

  wire [0:0]PWM_0_pwm;
  wire [6:0]PWM_AXI_1_ARADDR;
  wire [2:0]PWM_AXI_1_ARPROT;
  wire PWM_AXI_1_ARREADY;
  wire PWM_AXI_1_ARVALID;
  wire [6:0]PWM_AXI_1_AWADDR;
  wire [2:0]PWM_AXI_1_AWPROT;
  wire PWM_AXI_1_AWREADY;
  wire PWM_AXI_1_AWVALID;
  wire PWM_AXI_1_BREADY;
  wire [1:0]PWM_AXI_1_BRESP;
  wire PWM_AXI_1_BVALID;
  wire [31:0]PWM_AXI_1_RDATA;
  wire PWM_AXI_1_RREADY;
  wire [1:0]PWM_AXI_1_RRESP;
  wire PWM_AXI_1_RVALID;
  wire [31:0]PWM_AXI_1_WDATA;
  wire PWM_AXI_1_WREADY;
  wire [3:0]PWM_AXI_1_WSTRB;
  wire PWM_AXI_1_WVALID;
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
  wire [4:0]S_AXI_2_ARADDR;
  wire S_AXI_2_ARREADY;
  wire S_AXI_2_ARVALID;
  wire [4:0]S_AXI_2_AWADDR;
  wire S_AXI_2_AWREADY;
  wire S_AXI_2_AWVALID;
  wire S_AXI_2_BREADY;
  wire [1:0]S_AXI_2_BRESP;
  wire S_AXI_2_BVALID;
  wire [31:0]S_AXI_2_RDATA;
  wire S_AXI_2_RREADY;
  wire [1:0]S_AXI_2_RRESP;
  wire S_AXI_2_RVALID;
  wire [31:0]S_AXI_2_WDATA;
  wire S_AXI_2_WREADY;
  wire [3:0]S_AXI_2_WSTRB;
  wire S_AXI_2_WVALID;
  wire [2:0]axi_gpio_0_gpio_io_o;
  wire axi_timer_0_interrupt;
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
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;
  wire [3:0]xlconcat_0_dout;
  wire [3:0]xlconstant_0_dout;

  assign AXI_LITE_GPIO_arready = S_AXI_1_ARREADY;
  assign AXI_LITE_GPIO_awready = S_AXI_1_AWREADY;
  assign AXI_LITE_GPIO_bresp[1:0] = S_AXI_1_BRESP;
  assign AXI_LITE_GPIO_bvalid = S_AXI_1_BVALID;
  assign AXI_LITE_GPIO_rdata[31:0] = S_AXI_1_RDATA;
  assign AXI_LITE_GPIO_rresp[1:0] = S_AXI_1_RRESP;
  assign AXI_LITE_GPIO_rvalid = S_AXI_1_RVALID;
  assign AXI_LITE_GPIO_wready = S_AXI_1_WREADY;
  assign AXI_LITE_PWM_arready = PWM_AXI_1_ARREADY;
  assign AXI_LITE_PWM_awready = PWM_AXI_1_AWREADY;
  assign AXI_LITE_PWM_bresp[1:0] = PWM_AXI_1_BRESP;
  assign AXI_LITE_PWM_bvalid = PWM_AXI_1_BVALID;
  assign AXI_LITE_PWM_rdata[31:0] = PWM_AXI_1_RDATA;
  assign AXI_LITE_PWM_rresp[1:0] = PWM_AXI_1_RRESP;
  assign AXI_LITE_PWM_rvalid = PWM_AXI_1_RVALID;
  assign AXI_LITE_PWM_wready = PWM_AXI_1_WREADY;
  assign AXI_LITE_TIMER_arready = S_AXI_2_ARREADY;
  assign AXI_LITE_TIMER_awready = S_AXI_2_AWREADY;
  assign AXI_LITE_TIMER_bresp[1:0] = S_AXI_2_BRESP;
  assign AXI_LITE_TIMER_bvalid = S_AXI_2_BVALID;
  assign AXI_LITE_TIMER_rdata[31:0] = S_AXI_2_RDATA;
  assign AXI_LITE_TIMER_rresp[1:0] = S_AXI_2_RRESP;
  assign AXI_LITE_TIMER_rvalid = S_AXI_2_RVALID;
  assign AXI_LITE_TIMER_wready = S_AXI_2_WREADY;
  assign PWM_AXI_1_ARADDR = AXI_LITE_PWM_araddr[6:0];
  assign PWM_AXI_1_ARPROT = AXI_LITE_PWM_arprot[2:0];
  assign PWM_AXI_1_ARVALID = AXI_LITE_PWM_arvalid;
  assign PWM_AXI_1_AWADDR = AXI_LITE_PWM_awaddr[6:0];
  assign PWM_AXI_1_AWPROT = AXI_LITE_PWM_awprot[2:0];
  assign PWM_AXI_1_AWVALID = AXI_LITE_PWM_awvalid;
  assign PWM_AXI_1_BREADY = AXI_LITE_PWM_bready;
  assign PWM_AXI_1_RREADY = AXI_LITE_PWM_rready;
  assign PWM_AXI_1_WDATA = AXI_LITE_PWM_wdata[31:0];
  assign PWM_AXI_1_WSTRB = AXI_LITE_PWM_wstrb[3:0];
  assign PWM_AXI_1_WVALID = AXI_LITE_PWM_wvalid;
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
  assign S_AXI_1_ARADDR = AXI_LITE_GPIO_araddr[8:0];
  assign S_AXI_1_ARVALID = AXI_LITE_GPIO_arvalid;
  assign S_AXI_1_AWADDR = AXI_LITE_GPIO_awaddr[8:0];
  assign S_AXI_1_AWVALID = AXI_LITE_GPIO_awvalid;
  assign S_AXI_1_BREADY = AXI_LITE_GPIO_bready;
  assign S_AXI_1_RREADY = AXI_LITE_GPIO_rready;
  assign S_AXI_1_WDATA = AXI_LITE_GPIO_wdata[31:0];
  assign S_AXI_1_WSTRB = AXI_LITE_GPIO_wstrb[3:0];
  assign S_AXI_1_WVALID = AXI_LITE_GPIO_wvalid;
  assign S_AXI_2_ARADDR = AXI_LITE_TIMER_araddr[4:0];
  assign S_AXI_2_ARVALID = AXI_LITE_TIMER_arvalid;
  assign S_AXI_2_AWADDR = AXI_LITE_TIMER_awaddr[4:0];
  assign S_AXI_2_AWVALID = AXI_LITE_TIMER_awvalid;
  assign S_AXI_2_BREADY = AXI_LITE_TIMER_bready;
  assign S_AXI_2_RREADY = AXI_LITE_TIMER_rready;
  assign S_AXI_2_WDATA = AXI_LITE_TIMER_wdata[31:0];
  assign S_AXI_2_WSTRB = AXI_LITE_TIMER_wstrb[3:0];
  assign S_AXI_2_WVALID = AXI_LITE_TIMER_wvalid;
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
  assign timer_interrupt = axi_timer_0_interrupt;
  PmodAMP2_PWM_0_0 PWM_0
       (.pwm(PWM_0_pwm),
        .pwm_axi_aclk(s_axi_aclk_1),
        .pwm_axi_araddr(PWM_AXI_1_ARADDR),
        .pwm_axi_aresetn(s_axi_aresetn_1),
        .pwm_axi_arprot(PWM_AXI_1_ARPROT),
        .pwm_axi_arready(PWM_AXI_1_ARREADY),
        .pwm_axi_arvalid(PWM_AXI_1_ARVALID),
        .pwm_axi_awaddr(PWM_AXI_1_AWADDR),
        .pwm_axi_awprot(PWM_AXI_1_AWPROT),
        .pwm_axi_awready(PWM_AXI_1_AWREADY),
        .pwm_axi_awvalid(PWM_AXI_1_AWVALID),
        .pwm_axi_bready(PWM_AXI_1_BREADY),
        .pwm_axi_bresp(PWM_AXI_1_BRESP),
        .pwm_axi_bvalid(PWM_AXI_1_BVALID),
        .pwm_axi_rdata(PWM_AXI_1_RDATA),
        .pwm_axi_rready(PWM_AXI_1_RREADY),
        .pwm_axi_rresp(PWM_AXI_1_RRESP),
        .pwm_axi_rvalid(PWM_AXI_1_RVALID),
        .pwm_axi_wdata(PWM_AXI_1_WDATA),
        .pwm_axi_wready(PWM_AXI_1_WREADY),
        .pwm_axi_wstrb(PWM_AXI_1_WSTRB),
        .pwm_axi_wvalid(PWM_AXI_1_WVALID));
  PmodAMP2_axi_gpio_0_0 axi_gpio_0
       (.gpio_io_o(axi_gpio_0_gpio_io_o),
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
  PmodAMP2_axi_timer_0_0 axi_timer_0
       (.capturetrig0(1'b0),
        .capturetrig1(1'b0),
        .freeze(1'b0),
        .interrupt(axi_timer_0_interrupt),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(S_AXI_2_ARADDR),
        .s_axi_aresetn(s_axi_aresetn_1),
        .s_axi_arready(S_AXI_2_ARREADY),
        .s_axi_arvalid(S_AXI_2_ARVALID),
        .s_axi_awaddr(S_AXI_2_AWADDR),
        .s_axi_awready(S_AXI_2_AWREADY),
        .s_axi_awvalid(S_AXI_2_AWVALID),
        .s_axi_bready(S_AXI_2_BREADY),
        .s_axi_bresp(S_AXI_2_BRESP),
        .s_axi_bvalid(S_AXI_2_BVALID),
        .s_axi_rdata(S_AXI_2_RDATA),
        .s_axi_rready(S_AXI_2_RREADY),
        .s_axi_rresp(S_AXI_2_RRESP),
        .s_axi_rvalid(S_AXI_2_RVALID),
        .s_axi_wdata(S_AXI_2_WDATA),
        .s_axi_wready(S_AXI_2_WREADY),
        .s_axi_wstrb(S_AXI_2_WSTRB),
        .s_axi_wvalid(S_AXI_2_WVALID));
  PmodAMP2_pmod_bridge_0_0 pmod_bridge_0
       (.in_top_bus_O(xlconcat_0_dout),
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
  PmodAMP2_xlconcat_0_0 xlconcat_0
       (.In0(PWM_0_pwm),
        .In1(axi_gpio_0_gpio_io_o),
        .dout(xlconcat_0_dout));
  PmodAMP2_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule
