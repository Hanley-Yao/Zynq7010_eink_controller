`timescale 1ns / 1ps

module frame_processor_tb();

    // FDMA配置
    parameter FDMA_WID                = 64;           // FDMA数据宽度
    // EPD
    parameter EPD_WID                 = 8;  // 接口宽度
    parameter EPD_H                   = 1200;         // EPD屏幕长度
    parameter EPD_V                   = 825;          // EPD屏幕宽度
    // 输入图像配置
    parameter MAX_H                   = 2208;         // 考虑地址对齐所以+8
    parameter FRAME_H                 = 1920;         // 输入长度
    parameter FRAME_V                 = 1080;         // 输入宽度
    // 灰度转换精度
    parameter ACCURACY_NUM            = 20;

    // 缓冲区配置
    parameter GRAY_SIZE               = 4;            // 缓冲区长度单位MB
    parameter DATA_SIZE               = 1;
    parameter TEXTURE_ADDR_MEM_OFFSET = 32'h1F100000;
    parameter GRAY_0_ADDR_MEM_OFFSET  = 32'h1F500000;
    parameter GRAY_1_ADDR_MEM_OFFSET  = 32'h1F900000;
    parameter DATA_0_ADDR_MEM_OFFSET  = 32'h1FD00000;
    parameter DATA_1_ADDR_MEM_OFFSET  = 32'h1FE00000;

    reg                     clk;
    reg                     rst_n;

    reg                     pix_clk;
    wire                    rgb_de;
    wire                    rgb_hs;
    wire                    rgb_vs;
    reg     [7:0]           gray;

    reg                     w_gray_s_flag; // 开始处理一帧
    wire                    w_gray_busy;  // 正在采样
    wire                    w_gray_fflag;  // 采样完成标志

    reg                     clr_s_flag;
    wire                    clr_fflag;

    reg                     epd_clk;
    reg                     sw_rdata_addr;
    reg                     r_data_flag;
    reg                     r_data_fifo_ren;
    wire    [FDMA_WID -1:0] r_data_fifo_out;

    assign w_gray_addr = 32'h1F500000;
    assign r_gray_addr = 32'h1F900000;
    assign w_data_addr = 32'h1FD00000;
    assign r_data_addr = 32'h1FE00000;

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end

    initial begin
        pix_clk = 0;
        forever #(3) pix_clk = ~pix_clk;
    end

    initial begin
        epd_clk = 0;
        forever #(40) epd_clk = ~epd_clk;
    end

    initial begin
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end

    initial begin
        w_gray_s_flag = 0;
        repeat(100000) @(posedge clk);
        w_gray_s_flag = 1;
        repeat(20) @(posedge clk);
        w_gray_s_flag = 0;
    end

    initial begin
        clr_s_flag = 0;
        repeat(10000) @(posedge clk);
        clr_s_flag = 1;
        repeat(20) @(posedge clk);
        clr_s_flag = 0;
    end

    reg R_END_STATE;

    localparam R_END_IDEL = 0;
    localparam R_END_STATE1 = 1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            R_END_STATE <= 0;
            r_data_flag <= 0;
            r_data_fifo_ren <= 0;
        end
        else begin

            case(R_END_STATE)

                R_END_IDEL:begin
                    if (clr_fflag) begin
                        R_END_STATE <= R_END_STATE1;
                    end
                    else begin
                        r_data_flag <= 0;
                        sw_rdata_addr <= 0;
                        r_data_fifo_ren <= 0;
                    end
                end

                R_END_STATE1:begin
                    r_data_flag <= 1;
                    sw_rdata_addr <= 1;
                    r_data_fifo_ren <= 1;
                    R_END_STATE <= R_END_IDEL;
                end

                default:begin
                    R_END_STATE <= R_END_IDEL;
                end

            endcase

        end
    end

    vct #(
            .H_ActiveSize   (1920),
            .H_FrameSize    (2200),
            .H_SyncStart    (2008),
            .H_SyncEnd      (2052),
            .V_ActiveSize   (1080),
            .V_FrameSize    (1125),
            .V_SyncStart    (1083),
            .V_SyncEnd      (1088)
        ) vct (
            .vtc_rst_n      (rst_n),
            .vtc_pix_clk    (pix_clk),
            .vtc_vs_o       (rgb_vs),
            .vtc_hs_o       (rgb_hs),
            .vtc_de_o       (rgb_de)
        );

    initial begin
        gray = 0;
        forever #(3) gray = {$random} % 255;
    end

    frame_processor #(
            .FDMA_WID(FDMA_WID),
            .EPD_WID(EPD_WID),
            .EPD_H(EPD_H),
            .EPD_V(EPD_V),
            .MAX_H(MAX_H),
            .FRAME_H(FRAME_H),
            .FRAME_V(FRAME_V),
            .GRAY_SIZE(GRAY_SIZE),
            .DATA_SIZE(DATA_SIZE),
            .TEXTURE_ADDR_MEM_OFFSET(TEXTURE_ADDR_MEM_OFFSET),
            .GRAY_0_ADDR_MEM_OFFSET(GRAY_0_ADDR_MEM_OFFSET),
            .GRAY_1_ADDR_MEM_OFFSET(GRAY_1_ADDR_MEM_OFFSET),
            .DATA_0_ADDR_MEM_OFFSET(DATA_0_ADDR_MEM_OFFSET),
            .DATA_1_ADDR_MEM_OFFSET(DATA_1_ADDR_MEM_OFFSET)
        ) frame_processor (
            .clk             (clk),
            .rst_n           (rst_n),

            .w_gray_s_flag   (w_gray_s_flag),
            .pix_clk         (pix_clk),
            .gray_de         (rgb_de),
            .gray_hs         (rgb_hs),
            .gray_vs         (rgb_vs),
            .gray_data       (gray),
            .w_gray_busy     (w_gray_busy),
            .w_gray_fflag    (w_gray_fflag),

            .clr_s_flag      (clr_s_flag),
            .clr_fflag       (clr_fflag),

            .epd_clk         (epd_clk),
            .sw_rdata_addr   (sw_rdata_addr),

            .r_data_flag     (r_data_flag),
            .r_data_fifo_ren (r_data_fifo_ren),
            .r_data_fifo_out (r_data_fifo_out)
        );


endmodule
