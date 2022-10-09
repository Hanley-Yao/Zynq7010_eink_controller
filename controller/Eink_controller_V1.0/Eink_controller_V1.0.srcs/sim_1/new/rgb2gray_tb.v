`timescale 1ns / 1ps

module rgb2gray_tb();

    // 图像处理配置
    parameter ACCURACY_NUM  = 10;           // 灰度处理精度 越大消耗资源越多
    reg                     clk;
    reg                     rst_n;
    wire                    pix_clk;
    wire                    rgb_de;
    wire                    rgb_hs;
    wire                    rgb_vs;
    wire    [7:0]           rgb_r;
    wire    [7:0]           rgb_g;
    wire    [7:0]           rgb_b;

    wire                    gray_de;
    wire                    gray_hs;
    wire                    gray_vs;
    wire    [23:0]          gray_data;

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end
    initial begin
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end
    outRGB_0 outRGB (
        .clk(clk),
        .rst_n(rst_n),
        .IMAGE_EN(1'b1),
        .PURE_COLOR(),
        .pix_clk(pix_clk),
        .rgb_de(rgb_de),
        .rgb_hs(rgb_hs),
        .rgb_vs(rgb_vs),
        .rgb_r(rgb_r),
        .rgb_g(rgb_g),
        .rgb_b(rgb_b)
    );

    rgb2gray #(
            .ACCURACY_NUM(ACCURACY_NUM)
        ) inst_rgb2gray (
            .pix_clk   (pix_clk),
            .rgb_de    (rgb_de),
            .rgb_hs    (rgb_hs),
            .rgb_vs    (rgb_vs),
            .rgb_data  ({rgb_r,rgb_g,rgb_b}),
            .gray_de   (gray_de),
            .gray_hs   (gray_hs),
            .gray_vs   (gray_vs),
            .gray_data (gray_data)
        );

endmodule
