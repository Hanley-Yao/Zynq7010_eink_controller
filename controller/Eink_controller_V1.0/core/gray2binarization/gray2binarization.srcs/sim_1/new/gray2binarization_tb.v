
`timescale 1ns / 1ps

module gray2binarization_tb();

    reg         pix_clk;
    reg         gray_de;
    reg         gray_hs;
    reg         gray_vs;
    reg  [23:0] gray_data;
    wire        binary_de;
    wire        binary_hs;
    wire        binary_vs;
    wire [23:0] binary_data;



    gray2binarization #(
            .Threshold(Threshold)
        ) inst_gray2binarization (
            .pix_clk     (pix_clk),
            .gray_de     (gray_de),
            .gray_hs     (gray_hs),
            .gray_vs     (gray_vs),
            .gray_data   (gray_data),
            .binary_de   (binary_de),
            .binary_hs   (binary_hs),
            .binary_vs   (binary_vs),
            .binary_data (binary_data)
        );


    parameter Threshold = 127;

    initial begin
        pix_clk = 0;
        forever #(10) pix_clk = ~pix_clk;
    end

    initial begin
        gray_de = 0;
        gray_data       = 0;
        repeat(20) @(posedge pix_clk);
        gray_de = 1;
        forever #(20) gray_data = {$random} %255;
    end

endmodule
