module outRGB(
    input wire pix_clk,
    input wire rst_n,
    input wire IMAGE_EN,
    input wire EN_GRAY_IMG,
    input wire [23:0] PURE_COLOR,
    output wire rgb_de,
    output wire rgb_hs,
    output wire rgb_vs,
    output wire [7:0] rgb_r,
    output wire [7:0] rgb_g,
    output wire [7:0] rgb_b
    );

    wire rst;

    assign rst = ~rst_n;


    wire [23:0] rd_data;
    wire [23:0] img;
    wire        rd_ren;

    assign rd_req = rd_ren && IMAGE_EN;

    assign img = IMAGE_EN ? rd_data : PURE_COLOR;  // PURE_COLOR = 24'h7F7F7F

    rd_image inst_rd_image (
            .clk         (pix_clk),
            .rst         (rst),
            .rd_req      (rd_req),
            .EN_GRAY_IMG (EN_GRAY_IMG),
            .rd_data     (rd_data)
        );


    vga_shift inst_vga_shift (
            .rst      (rst),
            .vpg_pclk (pix_clk),
            .rd_data  (img),
            .rd_req   (rd_ren),
            .vpg_de   (rgb_de),
            .vpg_hs   (rgb_hs),
            .vpg_vs   (rgb_vs),
            .rgb_r    (rgb_r),
            .rgb_g    (rgb_g),
            .rgb_b    (rgb_b)
        );

endmodule
