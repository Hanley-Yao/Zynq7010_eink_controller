module rgb2gray_tb();

    reg             pix_clk;
    reg             rgb_de;
    reg             rgb_hs;
    reg             rgb_vs;
    reg    [23:0]   rgb_data;
    wire            gray_de;
    wire            gray_hs;
    wire            gray_vs;
    wire   [23:0]   gray_data;

    rgb2gray inst_rgb2gray
        (
            .pix_clk   (pix_clk),
            .rgb_de    (rgb_de),
            .rgb_hs    (rgb_hs),
            .rgb_vs    (rgb_vs),
            .rgb_data  (rgb_data),
            .gray_de   (gray_de),
            .gray_hs   (gray_hs),
            .gray_vs   (gray_vs),
            .gray_data (gray_data)
        );


    initial begin
        pix_clk                = 0;
        forever #(10) pix_clk  = ~pix_clk;
    end

    initial begin
        rgb_de                 = 0;
        rgb_data               = 0;
        repeat(20) @(posedge pix_clk);
        rgb_de                 = 1;
        forever #(20) rgb_data = {$random} %16777215;
    end

endmodule
