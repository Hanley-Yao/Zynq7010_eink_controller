
`timescale 1 ns / 1 ps

	module PmodAD1_v1_0 #
	(
		// Users to add parameters here
        // 2x89KSPS with these parameters
        parameter INCLUDE_DEBUG_INTERFACE = 0,
        parameter AD1_CLOCKS_PER_BIT = 20,//1 bit per 200ns
        parameter AD1_CLOCKS_BEFORE_DATA = 60,//600ns
        parameter AD1_CLOCKS_AFTER_DATA = 500,//5us
        parameter AD1_CLOCKS_BETWEEN_TRANSACTIONS = 400,//4us
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
      input Pmod_out_pin10_i,
      output Pmod_out_pin10_o,
      output Pmod_out_pin10_t,
      input Pmod_out_pin1_i,
      output Pmod_out_pin1_o,
      output Pmod_out_pin1_t,
      input Pmod_out_pin2_i,
      output Pmod_out_pin2_o,
      output Pmod_out_pin2_t,
      input Pmod_out_pin3_i,
      output Pmod_out_pin3_o,
      output Pmod_out_pin3_t,
      input Pmod_out_pin4_i,
      output Pmod_out_pin4_o,
      output Pmod_out_pin4_t,
      input Pmod_out_pin7_i,
      output Pmod_out_pin7_o,
      output Pmod_out_pin7_t,
      input Pmod_out_pin8_i,
      output Pmod_out_pin8_o,
      output Pmod_out_pin8_t,
      input Pmod_out_pin9_i,
      output Pmod_out_pin9_o,
      output Pmod_out_pin9_t,
              output wire [1:0] led,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
	wire ad1_cs;
	wire ad1_sdin0;
	wire ad1_sdin1;
	wire ad1_sclk;
// Instantiation of Axi Bus Interface S00_AXI
	PmodAD1_v1_0_S00_AXI # (
        .INCLUDE_DEBUG_INTERFACE(INCLUDE_DEBUG_INTERFACE),
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
        .AD1_CLOCKS_PER_BIT(AD1_CLOCKS_PER_BIT),//1 bit per 200ns
        .AD1_CLOCKS_BEFORE_DATA(AD1_CLOCKS_BEFORE_DATA),//600ns
        .AD1_CLOCKS_AFTER_DATA(AD1_CLOCKS_AFTER_DATA),//5us
        .AD1_CLOCKS_BETWEEN_TRANSACTIONS(AD1_CLOCKS_BETWEEN_TRANSACTIONS)//4us
	) PmodAD1_v1_0_S00_AXI_inst (
        .ad1_cs     (ad1_cs   ),
        .ad1_sdin0  (ad1_sdin0),
        .ad1_sdin1  (ad1_sdin1),
        .ad1_sclk   (ad1_sclk ),
        .led(led),
            
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);
	
    pmod_bridge_0 PmodAD1_pmod_bridge_0_0
       (.in0_I(),
        .in0_O(ad1_cs),
        .in0_T(1'b0),
        .in1_I(ad1_sdin0),
        .in1_O(),
        .in1_T(1'b1),
        .in2_I(ad1_sdin1),
        .in2_O(),
        .in2_T(1'b1),
        .in3_I(),
        .in3_O(ad1_sclk),
        .in3_T(1'b0),
        
        .out0_I(Pmod_out_pin1_i),
        .out0_O(Pmod_out_pin1_o),
        .out0_T(Pmod_out_pin1_t),
        .out1_I(Pmod_out_pin2_i),
        .out1_O(Pmod_out_pin2_o),
        .out1_T(Pmod_out_pin2_t),
        .out2_I(Pmod_out_pin3_i),
        .out2_O(Pmod_out_pin3_o),
        .out2_T(Pmod_out_pin3_t),
        .out3_I(Pmod_out_pin4_i),
        .out3_O(Pmod_out_pin4_o),
        .out3_T(Pmod_out_pin4_t),
        .out4_I(Pmod_out_pin7_i),
        .out4_O(Pmod_out_pin7_o),
        .out4_T(Pmod_out_pin7_t),
        .out5_I(Pmod_out_pin8_i),
        .out5_O(Pmod_out_pin8_o),
        .out5_T(Pmod_out_pin8_t),
        .out6_I(Pmod_out_pin9_i),
        .out6_O(Pmod_out_pin9_o),
        .out6_T(Pmod_out_pin9_t),
        .out7_I(Pmod_out_pin10_i),
        .out7_O(Pmod_out_pin10_o),
        .out7_T(Pmod_out_pin10_t)
    );

	// Add user logic here

	// User logic ends

	endmodule
