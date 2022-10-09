`timescale 1ns / 1ps

`define vsim

module eink_controller_ed108_tb();

    parameter SYS_CLK_FREQ            = 50;           // 系统时钟Mhz
    parameter SCL_FREQ                = 10000;           // I2C时钟频率Khz
    parameter DELAY_CNT               = 32'h0; // 系统配置延迟
    // 显示管理
    parameter VCOM                    = 1810;         // -1.81V
    parameter EPD_WID                 = 16;            // EPD数据宽度
    parameter EPD_FREQ                = 30;           // EPD像素时钟频率Mhz
    parameter EPD_H                   = 1920;         // EPD屏幕长度
    parameter EPD_V                   = 1080;          // EPD屏幕宽度
    parameter PERIOD_CNT              = 1;           // EPD图像刷新周期数
    parameter SPL_TIME                = 1;            // 在第 PERIOD_CNT - SPL_TIME 周期触发帧采样
    // 时序信息
    parameter tFdly                   = 0;            // 帧间隔ms 较小值可能会导致更大的漏电流...
    parameter tLEdly                  = 500;           // 单位ns
    parameter tLEw                    = 400;
    parameter tLEoff                  = 300;
    // 输入图像配置
    parameter MAX_H                   = 2208;         // 考虑地址对齐所以+8
    parameter MAX_V                   = 1872;         //
    parameter FRAME_H                 = 1920;         // 输入长度
    parameter FRAME_V                 = 1080;          // 输入宽度
    // FDMA配置
    parameter FDMA_WID                = 64;           // FDMA数据宽度
    // 缓冲区配置
    parameter GRAY_SIZE               = 4;            // 缓冲区长度单位MB
    parameter DATA_SIZE               = 1;
    parameter TEXTURE_ADDR_MEM_OFFSET = 32'hF100000;
    parameter GRAY_0_ADDR_MEM_OFFSET  = 32'hF500000;
    parameter GRAY_1_ADDR_MEM_OFFSET  = 32'hF900000;
    parameter DATA_0_ADDR_MEM_OFFSET  = 32'hFD00000;
    parameter DATA_1_ADDR_MEM_OFFSET  = 32'hFE00000;

    parameter H_Active     = 1920;
    parameter H_FrontPorch = 88;
    parameter H_SyncWidth  = 44;
    parameter H_BackPorch  = 148;

    parameter V_Active     = 1080;
    parameter V_FrontPorch = 4;
    parameter V_SyncWidth  = 5;
    parameter V_BackPorch  = 36;

    parameter Frame_cnt    = 10;
    parameter Frame_bpp    = 8;
    parameter Frame_src    = "../../../../viewer/txt_i/2.txt";

    reg                         clk;
    reg                         pix_clk;
    reg                         rst_n;
    reg                         clr_flag;

    wire                        epd_pwr_en;

    wire                        EPD_SKV;
    wire                        EPD_SPV;
    wire                        EPD_XCL;
    wire                        EPD_XLE;
    wire                        EPD_XSTL;
    wire    [EPD_WID -1:0]      EPD_DOUT;

    wire                        sda;
    wire                        scl;

    wire                        vs;
    wire                        hs;
    wire                        de;
    wire    [Frame_bpp -1:0]    image_data;

    always #3 pix_clk = ~pix_clk;

    always #10 clk = ~clk;

    initial begin
        clr_flag = 1;
        pix_clk = 1;
        clk = 1;
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end

    image_src #(
            .H_Active(H_Active),
            .H_FrontPorch(H_FrontPorch),
            .H_SyncWidth(H_SyncWidth),
            .H_BackPorch(H_BackPorch),
            .V_Active(V_Active),
            .V_FrontPorch(V_FrontPorch),
            .V_SyncWidth(V_SyncWidth),
            .V_BackPorch(V_BackPorch),
            .Frame_cnt(Frame_cnt),
            .Frame_bpp(Frame_bpp),
            .Frame_src(Frame_src)
        ) inst_image_src (
            .pix_clk    (pix_clk),
            .rst_n      (rst_n),
            .vs         (vs),
            .hs         (hs),
            .de         (de),
            .image_data (image_data)
        );


    eink_controller_es108fc1 #(
            .SYS_CLK_FREQ(SYS_CLK_FREQ),
            .SCL_FREQ(SCL_FREQ),
            .DELAY_CNT(DELAY_CNT),
            .VCOM(VCOM),
            .EPD_WID(EPD_WID),
            .EPD_FREQ(EPD_FREQ),
            .EPD_H(EPD_H),
            .EPD_V(EPD_V),
            .PERIOD_CNT(PERIOD_CNT),
            .SPL_TIME(SPL_TIME),
            .tFdly(tFdly),
            .tLEdly(tLEdly),
            .tLEw(tLEw),
            .tLEoff(tLEoff),
            .MAX_H(MAX_H),
            .MAX_V(MAX_V),
            .FRAME_H(FRAME_H),
            .FRAME_V(FRAME_V),
            .FDMA_WID(FDMA_WID),
            .GRAY_SIZE(GRAY_SIZE),
            .DATA_SIZE(DATA_SIZE),
            .TEXTURE_ADDR_MEM_OFFSET(TEXTURE_ADDR_MEM_OFFSET),
            .GRAY_0_ADDR_MEM_OFFSET(GRAY_0_ADDR_MEM_OFFSET),
            .GRAY_1_ADDR_MEM_OFFSET(GRAY_1_ADDR_MEM_OFFSET),
            .DATA_0_ADDR_MEM_OFFSET(DATA_0_ADDR_MEM_OFFSET),
            .DATA_1_ADDR_MEM_OFFSET(DATA_1_ADDR_MEM_OFFSET)
        ) inst_eink_controller_es108fc1 (
            .clk        (clk),
            .rst_n      (rst_n),
            .clr_flag   (clr_flag),
            .sda        (sda),
            .scl        (scl),
            .epd_pwr_sw (1),
            .pwr_good   (1),
            .epd_pwr_en (epd_pwr_en),
            .EPD_SKV    (EPD_SKV),
            .EPD_SPV    (EPD_SPV),
            .EPD_XCL    (EPD_XCL),
            .EPD_XLE    (EPD_XLE),
            .EPD_XSTL   (EPD_XSTL),
            .EPD_DOUT   (EPD_DOUT),
            .hs_i       (hs),
            .vs_i       (vs),
            .de_i       (de),
            .pix_clk    (pix_clk),
            .gray_i     (image_data)
        );


endmodule
