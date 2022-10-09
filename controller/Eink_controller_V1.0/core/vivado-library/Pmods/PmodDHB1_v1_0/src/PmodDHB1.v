//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
//Date        : Thu Sep 14 11:19:46 2017
//Host        : WK39 running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target PmodDHB1.bd
//Design      : PmodDHB1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "PmodDHB1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=PmodDHB1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=12,numReposBlks=12,numNonXlnxBlks=3,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_board_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "PmodDHB1.hwdef" *) 
module PmodDHB1
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
    MOTOR_FB_AXI_araddr,
    MOTOR_FB_AXI_arprot,
    MOTOR_FB_AXI_arready,
    MOTOR_FB_AXI_arvalid,
    MOTOR_FB_AXI_awaddr,
    MOTOR_FB_AXI_awprot,
    MOTOR_FB_AXI_awready,
    MOTOR_FB_AXI_awvalid,
    MOTOR_FB_AXI_bready,
    MOTOR_FB_AXI_bresp,
    MOTOR_FB_AXI_bvalid,
    MOTOR_FB_AXI_rdata,
    MOTOR_FB_AXI_rready,
    MOTOR_FB_AXI_rresp,
    MOTOR_FB_AXI_rvalid,
    MOTOR_FB_AXI_wdata,
    MOTOR_FB_AXI_wready,
    MOTOR_FB_AXI_wstrb,
    MOTOR_FB_AXI_wvalid,
    PWM_AXI_araddr,
    PWM_AXI_arprot,
    PWM_AXI_arready,
    PWM_AXI_arvalid,
    PWM_AXI_awaddr,
    PWM_AXI_awprot,
    PWM_AXI_awready,
    PWM_AXI_awvalid,
    PWM_AXI_bready,
    PWM_AXI_bresp,
    PWM_AXI_bvalid,
    PWM_AXI_rdata,
    PWM_AXI_rready,
    PWM_AXI_rresp,
    PWM_AXI_rvalid,
    PWM_AXI_wdata,
    PWM_AXI_wready,
    PWM_AXI_wstrb,
    PWM_AXI_wvalid,
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
    motor_fb_axi_aclk,
    motor_fb_axi_aresetn,
    pwm_axi_aclk,
    pwm_axi_aresetn,
    s_axi_aclk,
    s_axi_aresetn);
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
  input [4:0]MOTOR_FB_AXI_araddr;
  input [2:0]MOTOR_FB_AXI_arprot;
  output MOTOR_FB_AXI_arready;
  input MOTOR_FB_AXI_arvalid;
  input [4:0]MOTOR_FB_AXI_awaddr;
  input [2:0]MOTOR_FB_AXI_awprot;
  output MOTOR_FB_AXI_awready;
  input MOTOR_FB_AXI_awvalid;
  input MOTOR_FB_AXI_bready;
  output [1:0]MOTOR_FB_AXI_bresp;
  output MOTOR_FB_AXI_bvalid;
  output [31:0]MOTOR_FB_AXI_rdata;
  input MOTOR_FB_AXI_rready;
  output [1:0]MOTOR_FB_AXI_rresp;
  output MOTOR_FB_AXI_rvalid;
  input [31:0]MOTOR_FB_AXI_wdata;
  output MOTOR_FB_AXI_wready;
  input [3:0]MOTOR_FB_AXI_wstrb;
  input MOTOR_FB_AXI_wvalid;
  input [6:0]PWM_AXI_araddr;
  input [2:0]PWM_AXI_arprot;
  output PWM_AXI_arready;
  input PWM_AXI_arvalid;
  input [6:0]PWM_AXI_awaddr;
  input [2:0]PWM_AXI_awprot;
  output PWM_AXI_awready;
  input PWM_AXI_awvalid;
  input PWM_AXI_bready;
  output [1:0]PWM_AXI_bresp;
  output PWM_AXI_bvalid;
  output [31:0]PWM_AXI_rdata;
  input PWM_AXI_rready;
  output [1:0]PWM_AXI_rresp;
  output PWM_AXI_rvalid;
  input [31:0]PWM_AXI_wdata;
  output PWM_AXI_wready;
  input [3:0]PWM_AXI_wstrb;
  input PWM_AXI_wvalid;
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
  input motor_fb_axi_aclk;
  input motor_fb_axi_aresetn;
  input pwm_axi_aclk;
  input pwm_axi_aresetn;
  input s_axi_aclk;
  input s_axi_aresetn;

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
  wire [4:0]S00_AXI_1_ARADDR;
  wire [2:0]S00_AXI_1_ARPROT;
  wire S00_AXI_1_ARREADY;
  wire S00_AXI_1_ARVALID;
  wire [4:0]S00_AXI_1_AWADDR;
  wire [2:0]S00_AXI_1_AWPROT;
  wire S00_AXI_1_AWREADY;
  wire S00_AXI_1_AWVALID;
  wire S00_AXI_1_BREADY;
  wire [1:0]S00_AXI_1_BRESP;
  wire S00_AXI_1_BVALID;
  wire [31:0]S00_AXI_1_RDATA;
  wire S00_AXI_1_RREADY;
  wire [1:0]S00_AXI_1_RRESP;
  wire S00_AXI_1_RVALID;
  wire [31:0]S00_AXI_1_WDATA;
  wire S00_AXI_1_WREADY;
  wire [3:0]S00_AXI_1_WSTRB;
  wire S00_AXI_1_WVALID;
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
  wire [0:0]axi_gpio_0_gpio2_io_o;
  wire [1:0]axi_gpio_0_gpio_io_o;
  wire [0:0]axi_gpio_0_gpio_io_o1;
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
  wire [3:0]pmod_bridge_0_in_bottom_bus_I;
  wire [3:0]pmod_bridge_0_in_top_bus_I;
  wire pwm_axi_aclk_1;
  wire pwm_axi_aresetn_1;
  wire s00_axi_aclk_1;
  wire s00_axi_aresetn_1;
  wire s_axi_aclk_1;
  wire s_axi_aresetn_1;
  wire [3:0]xlconcat_M1_dout;
  wire [3:0]xlconcat_M2_dout;
  wire [3:0]xlconstant_0_dout;
  wire [1:0]xlconstant_0_dout1;
  wire [0:0]xlslice_EN1_Dout;
  wire [0:0]xlslice_EN2_Dout;
  wire [0:0]xlslice_m1_feedback_Dout;
  wire [0:0]xlslice_m2_feedback_Dout;

  assign AXI_LITE_GPIO_arready = S_AXI_1_ARREADY;
  assign AXI_LITE_GPIO_awready = S_AXI_1_AWREADY;
  assign AXI_LITE_GPIO_bresp[1:0] = S_AXI_1_BRESP;
  assign AXI_LITE_GPIO_bvalid = S_AXI_1_BVALID;
  assign AXI_LITE_GPIO_rdata[31:0] = S_AXI_1_RDATA;
  assign AXI_LITE_GPIO_rresp[1:0] = S_AXI_1_RRESP;
  assign AXI_LITE_GPIO_rvalid = S_AXI_1_RVALID;
  assign AXI_LITE_GPIO_wready = S_AXI_1_WREADY;
  assign MOTOR_FB_AXI_arready = S00_AXI_1_ARREADY;
  assign MOTOR_FB_AXI_awready = S00_AXI_1_AWREADY;
  assign MOTOR_FB_AXI_bresp[1:0] = S00_AXI_1_BRESP;
  assign MOTOR_FB_AXI_bvalid = S00_AXI_1_BVALID;
  assign MOTOR_FB_AXI_rdata[31:0] = S00_AXI_1_RDATA;
  assign MOTOR_FB_AXI_rresp[1:0] = S00_AXI_1_RRESP;
  assign MOTOR_FB_AXI_rvalid = S00_AXI_1_RVALID;
  assign MOTOR_FB_AXI_wready = S00_AXI_1_WREADY;
  assign PWM_AXI_1_ARADDR = PWM_AXI_araddr[6:0];
  assign PWM_AXI_1_ARPROT = PWM_AXI_arprot[2:0];
  assign PWM_AXI_1_ARVALID = PWM_AXI_arvalid;
  assign PWM_AXI_1_AWADDR = PWM_AXI_awaddr[6:0];
  assign PWM_AXI_1_AWPROT = PWM_AXI_awprot[2:0];
  assign PWM_AXI_1_AWVALID = PWM_AXI_awvalid;
  assign PWM_AXI_1_BREADY = PWM_AXI_bready;
  assign PWM_AXI_1_RREADY = PWM_AXI_rready;
  assign PWM_AXI_1_WDATA = PWM_AXI_wdata[31:0];
  assign PWM_AXI_1_WSTRB = PWM_AXI_wstrb[3:0];
  assign PWM_AXI_1_WVALID = PWM_AXI_wvalid;
  assign PWM_AXI_arready = PWM_AXI_1_ARREADY;
  assign PWM_AXI_awready = PWM_AXI_1_AWREADY;
  assign PWM_AXI_bresp[1:0] = PWM_AXI_1_BRESP;
  assign PWM_AXI_bvalid = PWM_AXI_1_BVALID;
  assign PWM_AXI_rdata[31:0] = PWM_AXI_1_RDATA;
  assign PWM_AXI_rresp[1:0] = PWM_AXI_1_RRESP;
  assign PWM_AXI_rvalid = PWM_AXI_1_RVALID;
  assign PWM_AXI_wready = PWM_AXI_1_WREADY;
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
  assign S00_AXI_1_ARADDR = MOTOR_FB_AXI_araddr[4:0];
  assign S00_AXI_1_ARPROT = MOTOR_FB_AXI_arprot[2:0];
  assign S00_AXI_1_ARVALID = MOTOR_FB_AXI_arvalid;
  assign S00_AXI_1_AWADDR = MOTOR_FB_AXI_awaddr[4:0];
  assign S00_AXI_1_AWPROT = MOTOR_FB_AXI_awprot[2:0];
  assign S00_AXI_1_AWVALID = MOTOR_FB_AXI_awvalid;
  assign S00_AXI_1_BREADY = MOTOR_FB_AXI_bready;
  assign S00_AXI_1_RREADY = MOTOR_FB_AXI_rready;
  assign S00_AXI_1_WDATA = MOTOR_FB_AXI_wdata[31:0];
  assign S00_AXI_1_WSTRB = MOTOR_FB_AXI_wstrb[3:0];
  assign S00_AXI_1_WVALID = MOTOR_FB_AXI_wvalid;
  assign S_AXI_1_ARADDR = AXI_LITE_GPIO_araddr[8:0];
  assign S_AXI_1_ARVALID = AXI_LITE_GPIO_arvalid;
  assign S_AXI_1_AWADDR = AXI_LITE_GPIO_awaddr[8:0];
  assign S_AXI_1_AWVALID = AXI_LITE_GPIO_awvalid;
  assign S_AXI_1_BREADY = AXI_LITE_GPIO_bready;
  assign S_AXI_1_RREADY = AXI_LITE_GPIO_rready;
  assign S_AXI_1_WDATA = AXI_LITE_GPIO_wdata[31:0];
  assign S_AXI_1_WSTRB = AXI_LITE_GPIO_wstrb[3:0];
  assign S_AXI_1_WVALID = AXI_LITE_GPIO_wvalid;
  assign pmod_bridge_0_Pmod_out_PIN10_I = Pmod_out_pin10_i;
  assign pmod_bridge_0_Pmod_out_PIN1_I = Pmod_out_pin1_i;
  assign pmod_bridge_0_Pmod_out_PIN2_I = Pmod_out_pin2_i;
  assign pmod_bridge_0_Pmod_out_PIN3_I = Pmod_out_pin3_i;
  assign pmod_bridge_0_Pmod_out_PIN4_I = Pmod_out_pin4_i;
  assign pmod_bridge_0_Pmod_out_PIN7_I = Pmod_out_pin7_i;
  assign pmod_bridge_0_Pmod_out_PIN8_I = Pmod_out_pin8_i;
  assign pmod_bridge_0_Pmod_out_PIN9_I = Pmod_out_pin9_i;
  assign pwm_axi_aclk_1 = pwm_axi_aclk;
  assign pwm_axi_aresetn_1 = pwm_axi_aresetn;
  assign s00_axi_aclk_1 = motor_fb_axi_aclk;
  assign s00_axi_aresetn_1 = motor_fb_axi_aresetn;
  assign s_axi_aclk_1 = s_axi_aclk;
  assign s_axi_aresetn_1 = s_axi_aresetn;
  PmodDHB1_MotorFeedback_0_0 MotorFeedback_0
       (.m1_feedback(xlslice_m1_feedback_Dout),
        .m2_feedback(xlslice_m2_feedback_Dout),
        .s00_axi_aclk(s00_axi_aclk_1),
        .s00_axi_araddr(S00_AXI_1_ARADDR),
        .s00_axi_aresetn(s00_axi_aresetn_1),
        .s00_axi_arprot(S00_AXI_1_ARPROT),
        .s00_axi_arready(S00_AXI_1_ARREADY),
        .s00_axi_arvalid(S00_AXI_1_ARVALID),
        .s00_axi_awaddr(S00_AXI_1_AWADDR),
        .s00_axi_awprot(S00_AXI_1_AWPROT),
        .s00_axi_awready(S00_AXI_1_AWREADY),
        .s00_axi_awvalid(S00_AXI_1_AWVALID),
        .s00_axi_bready(S00_AXI_1_BREADY),
        .s00_axi_bresp(S00_AXI_1_BRESP),
        .s00_axi_bvalid(S00_AXI_1_BVALID),
        .s00_axi_rdata(S00_AXI_1_RDATA),
        .s00_axi_rready(S00_AXI_1_RREADY),
        .s00_axi_rresp(S00_AXI_1_RRESP),
        .s00_axi_rvalid(S00_AXI_1_RVALID),
        .s00_axi_wdata(S00_AXI_1_WDATA),
        .s00_axi_wready(S00_AXI_1_WREADY),
        .s00_axi_wstrb(S00_AXI_1_WSTRB),
        .s00_axi_wvalid(S00_AXI_1_WVALID));
  PmodDHB1_PWM_0_0 PWM_0
       (.pwm(axi_gpio_0_gpio_io_o),
        .pwm_axi_aclk(pwm_axi_aclk_1),
        .pwm_axi_araddr(PWM_AXI_1_ARADDR),
        .pwm_axi_aresetn(pwm_axi_aresetn_1),
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
  PmodDHB1_axi_gpio_0_0 axi_gpio_0
       (.gpio2_io_o(axi_gpio_0_gpio2_io_o),
        .gpio_io_o(axi_gpio_0_gpio_io_o1),
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
  PmodDHB1_pmod_bridge_0_0 pmod_bridge_0
       (.in_bottom_bus_I(pmod_bridge_0_in_bottom_bus_I),
        .in_bottom_bus_O(xlconcat_M2_dout),
        .in_bottom_bus_T(xlconstant_0_dout),
        .in_top_bus_I(pmod_bridge_0_in_top_bus_I),
        .in_top_bus_O(xlconcat_M1_dout),
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
  PmodDHB1_xlconcat_1_0 xlconcat_M1
       (.In0(xlslice_EN1_Dout),
        .In1(axi_gpio_0_gpio_io_o1),
        .In2(xlconstant_0_dout1),
        .dout(xlconcat_M1_dout));
  PmodDHB1_xlconcat_0_0 xlconcat_M2
       (.In0(xlslice_EN2_Dout),
        .In1(axi_gpio_0_gpio2_io_o),
        .In2(xlconstant_0_dout1),
        .dout(xlconcat_M2_dout));
  PmodDHB1_xlconstant_0_1 xlconstant_0
       (.dout(xlconstant_0_dout1));
  PmodDHB1_xlconstant_0_0 xlconstant_pb_tristate
       (.dout(xlconstant_0_dout));
  PmodDHB1_xlslice_0_2 xlslice_EN1
       (.Din(axi_gpio_0_gpio_io_o),
        .Dout(xlslice_EN1_Dout));
  PmodDHB1_xlslice_0_3 xlslice_EN2
       (.Din(axi_gpio_0_gpio_io_o),
        .Dout(xlslice_EN2_Dout));
  PmodDHB1_xlslice_1_0 xlslice_m1_feedback
       (.Din(pmod_bridge_0_in_top_bus_I),
        .Dout(xlslice_m1_feedback_Dout));
  PmodDHB1_xlslice_0_0 xlslice_m2_feedback
       (.Din(pmod_bridge_0_in_bottom_bus_I),
        .Dout(xlslice_m2_feedback_Dout));
endmodule
