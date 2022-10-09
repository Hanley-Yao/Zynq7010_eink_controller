
`timescale 1 ns / 1 ps

	module PWM_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface PWM_AXI
		parameter integer C_PWM_AXI_DATA_WIDTH	= 32,
		parameter integer C_PWM_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
        output wire pwm,
        output wire interrupt,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface PWM_AXI
		input wire  pwm_axi_aclk,
		input wire  pwm_axi_aresetn,
		input wire [C_PWM_AXI_ADDR_WIDTH-1 : 0] pwm_axi_awaddr,
		input wire [2 : 0] pwm_axi_awprot,
		input wire  pwm_axi_awvalid,
		output wire  pwm_axi_awready,
		input wire [C_PWM_AXI_DATA_WIDTH-1 : 0] pwm_axi_wdata,
		input wire [(C_PWM_AXI_DATA_WIDTH/8)-1 : 0] pwm_axi_wstrb,
		input wire  pwm_axi_wvalid,
		output wire  pwm_axi_wready,
		output wire [1 : 0] pwm_axi_bresp,
		output wire  pwm_axi_bvalid,
		input wire  pwm_axi_bready,
		input wire [C_PWM_AXI_ADDR_WIDTH-1 : 0] pwm_axi_araddr,
		input wire [2 : 0] pwm_axi_arprot,
		input wire  pwm_axi_arvalid,
		output wire  pwm_axi_arready,
		output wire [C_PWM_AXI_DATA_WIDTH-1 : 0] pwm_axi_rdata,
		output wire [1 : 0] pwm_axi_rresp,
		output wire  pwm_axi_rvalid,
		input wire  pwm_axi_rready
	);
	
	reg [C_PWM_AXI_DATA_WIDTH-1:0]duty_reg_latch;
	wire [C_PWM_AXI_DATA_WIDTH-1:0]duty_reg;
	wire [C_PWM_AXI_DATA_WIDTH-1:0]period_reg;
	wire [C_PWM_AXI_DATA_WIDTH-1:0]ctrl_reg;
	wire [C_PWM_AXI_DATA_WIDTH-1:0]status_reg;
	
// Instantiation of Axi Bus Interface PWM_AXI
	PWM_v1_0_PWM_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_PWM_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_PWM_AXI_ADDR_WIDTH)
	) PWM_v1_0_PWM_AXI_inst (
	    .duty_reg_out(duty_reg),
	    .period_reg_out(period_reg),
	    .ctrl_reg_out(ctrl_reg),
	    .status_reg_out(status_reg),
		.S_AXI_ACLK(pwm_axi_aclk),
		.S_AXI_ARESETN(pwm_axi_aresetn),
		.S_AXI_AWADDR(pwm_axi_awaddr),
		.S_AXI_AWPROT(pwm_axi_awprot),
		.S_AXI_AWVALID(pwm_axi_awvalid),
		.S_AXI_AWREADY(pwm_axi_awready),
		.S_AXI_WDATA(pwm_axi_wdata),
		.S_AXI_WSTRB(pwm_axi_wstrb),
		.S_AXI_WVALID(pwm_axi_wvalid),
		.S_AXI_WREADY(pwm_axi_wready),
		.S_AXI_BRESP(pwm_axi_bresp),
		.S_AXI_BVALID(pwm_axi_bvalid),
		.S_AXI_BREADY(pwm_axi_bready),
		.S_AXI_ARADDR(pwm_axi_araddr),
		.S_AXI_ARPROT(pwm_axi_arprot),
		.S_AXI_ARVALID(pwm_axi_arvalid),
		.S_AXI_ARREADY(pwm_axi_arready),
		.S_AXI_RDATA(pwm_axi_rdata),
		.S_AXI_RRESP(pwm_axi_rresp),
		.S_AXI_RVALID(pwm_axi_rvalid),
		.S_AXI_RREADY(pwm_axi_rready)
	);
    
    integer count=0;
    integer max=4096;
    reg enable=1'b0;
    
	// Add user logic here
    always@(posedge (pwm_axi_aclk))begin
        if (ctrl_reg[0]==1)begin//Ctrl_reg 0 = enable
            enable<=1;
            max<=period_reg;
            end
        else
            enable<=0;
        if (ctrl_reg[1]==1)begin//Ctrl_reg 1 = hardware pwm
        end
        else begin
        end 
         
    end
    
    always@(posedge(pwm_axi_aclk))begin
        if (enable==1'b1)begin
            if (count<max)
                count=count+1;
            else begin
                duty_reg_latch=duty_reg;//Latch duty cycle at end of window
                count=0;
            end
        end
        else
            count=0;
    end
    
    assign pwm = duty_reg_latch < count ? 1'b1 : 1'b0;
    assign interrupt = (count == max) ? 1'b1: 1'b0;
	// User logic ends

	endmodule
