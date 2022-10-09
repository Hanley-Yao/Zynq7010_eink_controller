`timescale 1ns / 1ps

module v_mirror_tb(

    );

    reg                     clk;
    reg                     rst_n;

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end
    initial begin
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end

    vct #(
            .H_Active(1280),
            .H_FrontPorch(88),
            .H_SyncWidth(44),
            .H_BackPorch(148),
            .V_Active(720),
            .V_FrontPorch(4),
            .V_SyncWidth(5),
            .V_BackPorch(36)
        ) inst_vct (
            .vtc_rst_n   (rst_n),
            .vtc_pix_clk (clk),
            .vtc_vs_o    (vtc_vs_o),
            .vtc_hs_o    (vtc_hs_o),
            .vtc_de_o    (vtc_de_o)
        );


    v_mirror #(
            .FRAME_H(1280),
            .FRAME_V(720),
            .Frame_bpp(8)
        ) inst_v_mirror (
            .pix_clk      (clk),
            .rst_n        (rst_n),
            .vs_i         (vtc_vs_o),
            .hs_i         (vtc_hs_o),
            .de_i         (vtc_de_o),
            .image_data_i (image_data_i),
            .vs_o         (vs_o),
            .hs_o         (hs_o),
            .de_o         (de_o),
            .image_data_o (image_data_o)
        );


endmodule
