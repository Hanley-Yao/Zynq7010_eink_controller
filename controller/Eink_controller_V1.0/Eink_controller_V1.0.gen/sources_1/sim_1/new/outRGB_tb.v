`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/31 19:57:57
// Design Name:
// Module Name: outRGB_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module outRGB_tb();

    reg clk;
    reg rst_n;
    wire pix_clk;
    wire rgb_de;
    wire rgb_hs;
    wire rgb_vs;
    wire [7:0] rgb_r;
    wire [7:0] rgb_g;
    wire [7:0] rgb_b;

    outRGB inst_outRGB
        (
            .clk         (clk),
            .rst_n       (rst_n),
            .IMAGE_EN    (0),
            .EN_GRAY_IMG (1),
            .PURE_COLOR  (24'h7F7F7F),
            .pix_clk     (pix_clk),
            .rgb_de      (rgb_de),
            .rgb_hs      (rgb_hs),
            .rgb_vs      (rgb_vs),
            .rgb_r       (rgb_r),
            .rgb_g       (rgb_g),
            .rgb_b       (rgb_b)
        );



   initial begin
        clk = 0;
        forever #(10) clk = ~clk;
    end

    initial begin
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
    end


endmodule
