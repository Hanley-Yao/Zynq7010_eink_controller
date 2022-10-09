`timescale 1ns / 1ps

module frame_ctrl_tb();

    // 屏幕信息
    parameter EPD_WID   = 8;
    parameter EPD_FREQ  = 24;
    parameter EPD_H     = 600;
    parameter EPD_V     = 600;
    // 时序信息
    parameter tLEdly    = 120;
    parameter tLEw      = 300;
    parameter tLEoff    = 200;

    reg     epd_clk;
    reg     rst_n;
    reg     s_flag;
    wire    SKV;
    wire    SPV;
    wire    XCL;
    wire    XLE;
    wire    XSTL;
    wire    r_flag;
    wire    end_flag;

    initial begin
        epd_clk = 0;
        forever #(20) epd_clk = ~epd_clk;  // 25Mhz
    end

    initial begin
        rst_n = 0;
        repeat(100) @(posedge epd_clk);
        rst_n = 1;
    end

    initial begin
        s_flag = 0;
        repeat(1000) @(posedge epd_clk);
        s_flag = 1;
        repeat(40) @(posedge epd_clk);
        s_flag = 0;
    end

    frame_ctrl #(
            .EPD_WID(EPD_WID),
            .EPD_FREQ(EPD_FREQ),
            .EPD_H(EPD_H),
            .EPD_V(EPD_V),
            .tLEdly(tLEdly),
            .tLEw(tLEw),
            .tLEoff(tLEoff)
        ) inst_frame_ctrl (
            .rst_n    (rst_n),
            .epd_clk  (epd_clk),
            .s_flag   (s_flag),
            .SKV      (SKV),
            .SPV      (SPV),
            .XCL      (XCL),
            .XLE      (XLE),
            .XSTL     (XSTL),
            .r_flag   (r_flag),
            .end_flag (end_flag)
        );


endmodule
