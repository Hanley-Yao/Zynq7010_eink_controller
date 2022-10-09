`timescale 1ns / 1ps

module display_mgr_tb();

    parameter SYS_CLK_FREQ = 50;    // 系统时钟Mhz
    parameter FDMA_WID     = 64;    // FDMA数据宽度
    // 屏幕信息
    parameter EPD_WID      = 16;     // EPD数据宽度
    parameter EPD_FREQ     = 50;    // EPD像素时钟频率Mhz
    parameter EPD_H        = 1920;  // 屏幕宽度
    parameter EPD_V        = 1080;   // 屏幕长度
    parameter PERIOD_CNT   = 10;    // 帧刷新次数
    // 时序信息
    parameter tFdly        = 0;     // 帧间隔ms 较小值可能会导致更大的漏电流...
    parameter tLEdly       = 450;    // 单位ns
    parameter tLEw         = 300;
    parameter tLEoff       = 200;

    reg                     clk;
    wire                    epd_clk;
    wire                    clk_50m;
    reg                     rst_n;

    reg                     s_flag;
    wire [7:0]              period_cnt;
    wire                    d_busy;
    wire                    d_fflag;
    wire                    r_flag;
    wire                    fifo_ren;
    reg   [FDMA_WID -1:0]   din;
    wire                    EPD_SKV;
    wire                    EPD_SPV;
    wire                    EPD_XCL;
    wire                    EPD_XLE;
    wire                    EPD_XSTL;
    wire  [EPD_WID -1:0]    EPD_DOUT;

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end

    clock_pll clock_pll
        (
            .clk_in(clk),
            .resetn(rst_n),

            .clk_50m(clk_50m),
            .epd_clk(epd_clk),

            .locked()
        );

    initial begin
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end

    initial begin
        s_flag = 0;
        repeat(200) @(posedge clk_50m);
        s_flag = 1;
        repeat(20) @(posedge clk_50m);
        s_flag = 0;
    end

    initial begin
       din = {8'd8,8'd16,8'd24,8'd36,8'd40,8'd48,8'd56,8'd64};
       repeat(1) @(posedge fifo_ren);
       din = {8'd222,8'd134,8'd240,8'd142,8'd140,8'd148,8'd156,8'd164};
       repeat(1) @(posedge fifo_ren);
       din = {8'd8,8'd16,8'd24,8'd36,8'd40,8'd48,8'd56,8'd64};
       repeat(1) @(posedge fifo_ren);
       din = {8'd22,8'd13,8'd40,8'd142,8'd10,8'd18,8'd156,8'd16};
    end

    display_mgr #(
            .SYS_CLK_FREQ(SYS_CLK_FREQ),
            .FDMA_WID(FDMA_WID),
            .EPD_WID(EPD_WID),
            .EPD_FREQ(EPD_FREQ),
            .EPD_H(EPD_H / (EPD_WID/8)),
            .EPD_V(EPD_V),
            .PERIOD_CNT(PERIOD_CNT),
            .tFdly(tFdly),
            .tLEdly(tLEdly),
            .tLEw(tLEw),
            .tLEoff(tLEoff)
        ) inst_display_mgr (
            .clk        (clk_50m),
            .epd_clk    (epd_clk),
            .rst_n      (rst_n),
            .s_flag     (s_flag),
            .period_cnt (period_cnt),
            .d_busy     (d_busy),
            .d_fflag    (d_fflag),
            .r_flag     (r_flag),
            .fifo_ren   (fifo_ren),
            .din        (din),
            .EPD_SKV    (EPD_SKV),
            .EPD_SPV    (EPD_SPV),
            .EPD_XCL    (EPD_XCL),
            .EPD_XLE    (EPD_XLE),
            .EPD_XSTL   (EPD_XSTL),
            .EPD_DOUT   (EPD_DOUT)
        );

endmodule
