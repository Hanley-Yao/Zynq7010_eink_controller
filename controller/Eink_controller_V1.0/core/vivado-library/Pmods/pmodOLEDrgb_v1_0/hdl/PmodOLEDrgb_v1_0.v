
`timescale 1 ns / 1 ps
 
	module PmodOLEDrgb_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Parameters of Axi Slave Bus Interface AXI_LITE_SPI
		parameter integer C_AXI_LITE_SPI_DATA_WIDTH	= 32,
		parameter integer C_AXI_LITE_SPI_ADDR_WIDTH	= 7, 

		// Parameters of Axi Slave Bus Interface AXI_LITE_GPIO
		parameter integer C_AXI_LITE_GPIO_DATA_WIDTH	= 32,
		parameter integer C_AXI_LITE_GPIO_ADDR_WIDTH	= 9
	)
	(
		// Users to add ports here
        input wire ext_spi_clk,
        input wire pmod_out_pin10_i,
        output wire pmod_out_pin10_o,
        output wire pmod_out_pin10_t,
        input wire pmod_out_pin1_i,
        output wire pmod_out_pin1_o,
        output wire pmod_out_pin1_t,
        input wire pmod_out_pin2_i,
        output wire pmod_out_pin2_o,
        output wire pmod_out_pin2_t,
        input wire pmod_out_pin3_i,
        output wire pmod_out_pin3_o,
        output wire pmod_out_pin3_t,
        input wire pmod_out_pin4_i,
        output wire pmod_out_pin4_o,
        output wire pmod_out_pin4_t,
        input wire pmod_out_pin7_i,
        output wire pmod_out_pin7_o,
        output wire pmod_out_pin7_t,
        input wire pmod_out_pin8_i,
        output wire pmod_out_pin8_o,
        output wire pmod_out_pin8_t,
        input wire pmod_out_pin9_i,
        output wire pmod_out_pin9_o,
        output wire pmod_out_pin9_t,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface AXI_LITE_SPI
		input wire  s_axi_aclk,
		input wire  s_axi_aclk2,
		input wire  s_axi_aresetn,
		input wire [C_AXI_LITE_SPI_ADDR_WIDTH-1 : 0] axi_lite_spi_awaddr,
		input wire [2 : 0] axi_lite_spi_awprot,
		input wire  axi_lite_spi_awvalid,
		output wire  axi_lite_spi_awready,
		input wire [C_AXI_LITE_SPI_DATA_WIDTH-1 : 0] axi_lite_spi_wdata,
		input wire [(C_AXI_LITE_SPI_DATA_WIDTH/8)-1 : 0] axi_lite_spi_wstrb,
		input wire  axi_lite_spi_wvalid,
		output wire  axi_lite_spi_wready,
		output wire [1 : 0] axi_lite_spi_bresp,
		output wire  axi_lite_spi_bvalid,
		input wire  axi_lite_spi_bready,
		input wire [C_AXI_LITE_SPI_ADDR_WIDTH-1 : 0] axi_lite_spi_araddr,
		input wire [2 : 0] axi_lite_spi_arprot,
		input wire  axi_lite_spi_arvalid,
		output wire  axi_lite_spi_arready,
		output wire [C_AXI_LITE_SPI_DATA_WIDTH-1 : 0] axi_lite_spi_rdata,
		output wire [1 : 0] axi_lite_spi_rresp,
		output wire  axi_lite_spi_rvalid,
		input wire  axi_lite_spi_rready,

		// Ports of Axi Slave Bus Interface AXI_LITE_GPIO
		input wire [C_AXI_LITE_GPIO_ADDR_WIDTH-1 : 0] axi_lite_gpio_awaddr,
		input wire [2 : 0] axi_lite_gpio_awprot,
		input wire  axi_lite_gpio_awvalid,
		output wire  axi_lite_gpio_awready,
		input wire [C_AXI_LITE_GPIO_DATA_WIDTH-1 : 0] axi_lite_gpio_wdata,
		input wire [(C_AXI_LITE_GPIO_DATA_WIDTH/8)-1 : 0] axi_lite_gpio_wstrb,
		input wire  axi_lite_gpio_wvalid,
		output wire  axi_lite_gpio_wready,
		output wire [1 : 0] axi_lite_gpio_bresp,
		output wire  axi_lite_gpio_bvalid,
		input wire  axi_lite_gpio_bready,
		input wire [C_AXI_LITE_GPIO_ADDR_WIDTH-1 : 0] axi_lite_gpio_araddr,
		input wire [2 : 0] axi_lite_gpio_arprot,
		input wire  axi_lite_gpio_arvalid,
		output wire  axi_lite_gpio_arready,
		output wire [C_AXI_LITE_GPIO_DATA_WIDTH-1 : 0] axi_lite_gpio_rdata,
		output wire [1 : 0] axi_lite_gpio_rresp,
		output wire  axi_lite_gpio_rvalid,
		input wire  axi_lite_gpio_rready
	);
	
 wire dc_i;
 wire dc_o;
 wire dc_t;
 wire res_i;
 wire res_o;
 wire res_t;
 wire vccen_i;
 wire vccen_o;
 wire vccen_t;
 wire pmoden_i;
 wire pmoden_o;
 wire pmoden_t;
 
 wire ss_i;
 wire ss_o;
 wire ss_t;
 wire sck_i;
 wire sck_o;
 wire sck_t;
 wire mosi_i;
 wire mosi_o;
 wire mosi_t;
 wire miso_i;
 wire miso_o;
 wire miso_t;
 
// Instantiation of Axi Bus Interface AXI_LITE_SPI
	/*PmodOLEDrgb_v1_0_AXI_LITE_SPI # ( 
		.C_S_AXI_DATA_WIDTH(C_AXI_LITE_SPI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_AXI_LITE_SPI_ADDR_WIDTH)
	) PmodOLEDrgb_v1_0_AXI_LITE_SPI_inst (
		.S_AXI_ACLK(s_axi_aclk),
		.S_AXI_ARESETN(s_axi_aresetn),
		.S_AXI_AWADDR(axi_lite_spi_awaddr),
		.S_AXI_AWPROT(axi_lite_spi_awprot),
		.S_AXI_AWVALID(axi_lite_spi_awvalid),
		.S_AXI_AWREADY(axi_lite_spi_awready),
		.S_AXI_WDATA(axi_lite_spi_wdata),
		.S_AXI_WSTRB(axi_lite_spi_wstrb),
		.S_AXI_WVALID(axi_lite_spi_wvalid),
		.S_AXI_WREADY(axi_lite_spi_wready),
		.S_AXI_BRESP(axi_lite_spi_bresp),
		.S_AXI_BVALID(axi_lite_spi_bvalid),
		.S_AXI_BREADY(axi_lite_spi_bready),
		.S_AXI_ARADDR(axi_lite_spi_araddr),
		.S_AXI_ARPROT(axi_lite_spi_arprot),
		.S_AXI_ARVALID(axi_lite_spi_arvalid),
		.S_AXI_ARREADY(axi_lite_spi_arready),
		.S_AXI_RDATA(axi_lite_spi_rdata),
		.S_AXI_RRESP(axi_lite_spi_rresp),
		.S_AXI_RVALID(axi_lite_spi_rvalid),
		.S_AXI_RREADY(axi_lite_spi_rready)
	);*/

// Instantiation of Axi Bus Interface AXI_LITE_GPIO
	/*PmodOLEDrgb_AXI_LITE_GPIO # ( 
		.C_S_AXI_DATA_WIDTH(C_AXI_LITE_GPIO_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_AXI_LITE_GPIO_ADDR_WIDTH)
	) PmodOLEDrgb_AXI_LITE_GPIO_inst (
	    .pin7_o(pin7_o),
	    .pin8_o(pin8_o),
	    .pin9_o(pin9_o),
	    .pin10_o(pin10_o),
		.S_AXI_ACLK(s_axi_aclk),
		.S_AXI_ARESETN(s_axi_aresetn),
		.S_AXI_AWADDR(axi_lite_gpio_awaddr),
		.S_AXI_AWPROT(axi_lite_gpio_awprot),
		.S_AXI_AWVALID(axi_lite_gpio_awvalid),
		.S_AXI_AWREADY(axi_lite_gpio_awready),
		.S_AXI_WDATA(axi_lite_gpio_wdata),
		.S_AXI_WSTRB(axi_lite_gpio_wstrb),
		.S_AXI_WVALID(axi_lite_gpio_wvalid),
		.S_AXI_WREADY(axi_lite_gpio_wready),
		.S_AXI_BRESP(axi_lite_gpio_bresp),
		.S_AXI_BVALID(axi_lite_gpio_bvalid),
		.S_AXI_BREADY(axi_lite_gpio_bready),
		.S_AXI_ARADDR(axi_lite_gpio_araddr),
		.S_AXI_ARPROT(axi_lite_gpio_arprot),
		.S_AXI_ARVALID(axi_lite_gpio_arvalid),
		.S_AXI_ARREADY(axi_lite_gpio_arready),
		.S_AXI_RDATA(axi_lite_gpio_rdata),
		.S_AXI_RRESP(axi_lite_gpio_rresp),
		.S_AXI_RVALID(axi_lite_gpio_rvalid),
		.S_AXI_RREADY(axi_lite_gpio_rready)
	);*/
	// Add user logic here



PmodOLEDrgb_pmod_bridge_0_0 pmod_bridge_0
       (.in0_I(ss_i),
        .in0_O(ss_o),
        .in0_T(ss_t),
        .in1_I(mosi_i),
        .in1_O(mosi_o),
        .in1_T(mosi_t),
        .in2_I(miso_i),
        .in2_O(miso_o),
        .in2_T(miso_t),
        .in3_I(sck_i),
        .in3_O(sck_o),
        .in3_T(sck_t),
        .in4_I(dc_i),
        .in4_O(dc_o),
        .in4_T(dc_t),
        .in5_I(res_i),
        .in5_O(res_o),
        .in5_T(res_t),
        .in6_I(vccen_i),
        .in6_O(vccen_o),
        .in6_T(vccen_t),
        .in7_I(pmoden_i),
        .in7_O(pmoden_o),
        .in7_T(pmoden_t),
        .out0_I(pmod_out_pin1_i),
        .out0_O(pmod_out_pin1_o),
        .out0_T(pmod_out_pin1_t),
        .out1_I(pmod_out_pin2_i),
        .out1_O(pmod_out_pin2_o),
        .out1_T(pmod_out_pin2_t),
        .out2_I(pmod_out_pin3_i),
        .out2_O(pmod_out_pin3_o),
        .out2_T(pmod_out_pin3_t),
        .out3_I(pmod_out_pin4_i),
        .out3_O(pmod_out_pin4_o),
        .out3_T(pmod_out_pin4_t),
        .out4_I(pmod_out_pin7_i),
        .out4_O(pmod_out_pin7_o),
        .out4_T(pmod_out_pin7_t),
        .out5_I(pmod_out_pin8_i),
        .out5_O(pmod_out_pin8_o),
        .out5_T(pmod_out_pin8_t),
        .out6_I(pmod_out_pin9_i),
        .out6_O(pmod_out_pin9_o),
        .out6_T(pmod_out_pin9_t),
        .out7_I(pmod_out_pin10_i),
        .out7_O(pmod_out_pin10_o),
        .out7_T(pmod_out_pin10_t));

  PmodOLEDrgb_axi_gpio_0_1 axi_gpio_0
       (.gpio_io_i({pmoden_i,vccen_i,res_i,dc_i}),
        .gpio_io_o({pmoden_o,vccen_o,res_o,dc_o}),
        .gpio_io_t({pmoden_t,vccen_t,res_t,dc_t}),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(axi_lite_gpio_araddr),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_arready(axi_lite_gpio_arready),
        .s_axi_arvalid(axi_lite_gpio_arvalid),
        .s_axi_awaddr(axi_lite_gpio_awaddr),
        .s_axi_awready(axi_lite_gpio_awready),
        .s_axi_awvalid(axi_lite_gpio_awvalid),
        .s_axi_bready(axi_lite_gpio_bready),
        .s_axi_bresp(axi_lite_gpio_bresp),
        .s_axi_bvalid(axi_lite_gpio_bvalid),
        .s_axi_rdata(axi_lite_gpio_rdata),
        .s_axi_rready(axi_lite_gpio_rready),
        .s_axi_rresp(axi_lite_gpio_rresp),
        .s_axi_rvalid(axi_lite_gpio_rvalid),
        .s_axi_wdata(axi_lite_gpio_wdata),
        .s_axi_wready(axi_lite_gpio_wready),
        .s_axi_wstrb(axi_lite_gpio_wstrb),
        .s_axi_wvalid(axi_lite_gpio_wvalid));

  PmodOLEDrgb_axi_quad_spi_0_0 axi_quad_spi_0
        (.ext_spi_clk(ext_spi_clk),
          .io0_i(mosi_i),
          .io0_o(mosi_o),
          .io0_t(mosi_t),
          .io1_i(miso_i),
          .io1_o(miso_o),
          .io1_t(miso_t),
          .s_axi_aclk(s_axi_aclk2),
          .s_axi_araddr(axi_lite_spi_araddr),
          .s_axi_aresetn(s_axi_aresetn),
          .s_axi_arready(axi_lite_spi_arready),
          .s_axi_arvalid(axi_lite_spi_arvalid),
          .s_axi_awaddr(axi_lite_spi_awaddr),
          .s_axi_awready(axi_lite_spi_awready),
          .s_axi_awvalid(axi_lite_spi_awvalid),
          .s_axi_bready(axi_lite_spi_bready),
          .s_axi_bresp(axi_lite_spi_bresp),
          .s_axi_bvalid(axi_lite_spi_bvalid),
          .s_axi_rdata(axi_lite_spi_rdata),
          .s_axi_rready(axi_lite_spi_rready),
          .s_axi_rresp(axi_lite_spi_rresp),
          .s_axi_rvalid(axi_lite_spi_rvalid),
          .s_axi_wdata(axi_lite_spi_wdata),
          .s_axi_wready(axi_lite_spi_wready),
          .s_axi_wstrb(axi_lite_spi_wstrb),
          .s_axi_wvalid(axi_lite_spi_wvalid),
          .sck_i(sck_i),
          .sck_o(sck_o),
          .sck_t(sck_t),
          .ss_i(ss_i),
          .ss_o(ss_o),
          .ss_t(ss_t));
	// User logic ends

	endmodule
