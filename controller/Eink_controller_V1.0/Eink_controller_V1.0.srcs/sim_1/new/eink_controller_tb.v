
`timescale 1ns / 1ns

`define vsim

module eink_controller_tb();

    parameter SYS_CLK_FREQ            = 50;           // 系统时钟Mhz
    parameter SCL_FREQ                = 10000;        // I2C时钟频率
    parameter DELAY_CNT               = 32'h0;        // 系统配置延迟
    // 显示管理
    parameter VCOM                    = 2780;         // -2.78V
    parameter EPD_WID                 = 8;            // EPD数据宽度
    parameter EPD_FREQ                = 50;           // EPD像素时钟频率Mhz
    parameter EPD_H                   = 1200;         // EPD屏幕长度
    parameter EPD_V                   = 825;          // EPD屏幕宽度
    parameter PERIOD_CNT              = 4;            // EPD帧刷新次数
    parameter SPL_TIME                = 2;            // 在第 PERIOD_CNT - SPL_TIME 周期触发帧采样
    // 时序信息
    parameter tFdly                   = 0;            // 帧间隔ms 较小值可能会导致更大的漏电流...
    parameter tLEdly                  = 40;           // 单位ns
    parameter tLEw                    = 40;
    parameter tLEoff                  = 200;
    // 输入图像配置
    parameter MAX_H                   = 2208;         // 考虑地址对齐所以+8
    parameter MAX_V                   = 1872;
    parameter FRAME_H                 = 1920;         // 输入长度
    parameter FRAME_V                 = 1080;         // 输入宽度
    // 图像处理配置
    parameter ACCURACY_NUM            = 2;            // 灰度处理精度 越大消耗资源越多
    // FDMA配置
    parameter FDMA_WID                = 64;           // FDMA数据宽度
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
    reg                     clr_flag;

    wire                    EPD_SKV;
    wire                    EPD_SPV;
    wire                    EPD_XCL;
    wire                    EPD_XLE;
    wire                    EPD_XSTL;
    wire    [EPD_WID -1:0]  EPD_DOUT;

    wire                    sda;
    wire                    scl;
    wire                    pwr_good;
    wire                    wake_up;
    wire                    pwr_up;
    wire                    pwr_com;
    wire                    adv_en;

    reg                     pix_clk;
    wire                    rgb_de;
    wire                    rgb_hs;
    wire                    rgb_vs;
    reg    [7:0]            rgb_r;
    reg    [7:0]            rgb_g;
    reg    [7:0]            rgb_b;

    assign PWR_GOOD = 1;

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end

    initial begin
        pix_clk = 0;
        forever #(3) pix_clk = ~pix_clk;
    end

    initial begin
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end

    localparam FREQ = 50;
    localparam dly = 500;  // ms

    localparam CNT = (FREQ * 32'd500) * dly;

    reg [31:0] cnt ;

    //计数器计数进程
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 32'd0;
            clr_flag <= 1;
        end
        else if(cnt == CNT) begin  // 250ms 计时器
            //cnt <= 32'd0;
            clr_flag <= 0;  // 触发清屏
        end
        else begin
            cnt <= cnt + 1'b1;
            clr_flag <= 1;
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
        rgb_r = 0;
        forever #(3) rgb_r = {$random} % 255;
    end

    initial begin
        rgb_g = 0;
        forever #(3) rgb_g = {$random} % 255;
    end

    initial begin
        rgb_b = 0;
        forever #(3) rgb_b = {$random} % 255;
    end

    //outRGB_0 outRGB (
    //    .clk(clk),
    //    .rst_n(rst_n),
    //    .IMAGE_EN(1'b1),
    //    .PURE_COLOR(),
    //    .pix_clk(pix_clk),
    //    .rgb_de(rgb_de),
    //    .rgb_hs(rgb_hs),
    //    .rgb_vs(rgb_vs),
    //    .rgb_r(rgb_r),
    //    .rgb_g(rgb_g),
    //    .rgb_b(rgb_b)
    //);

    eink_controller #(
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
            .ACCURACY_NUM(ACCURACY_NUM),
            .FDMA_WID(FDMA_WID),
            .GRAY_SIZE(GRAY_SIZE),
            .DATA_SIZE(DATA_SIZE),
            .TEXTURE_ADDR_MEM_OFFSET(TEXTURE_ADDR_MEM_OFFSET),
            .GRAY_0_ADDR_MEM_OFFSET(GRAY_0_ADDR_MEM_OFFSET),
            .GRAY_1_ADDR_MEM_OFFSET(GRAY_1_ADDR_MEM_OFFSET),
            .DATA_0_ADDR_MEM_OFFSET(DATA_0_ADDR_MEM_OFFSET),
            .DATA_1_ADDR_MEM_OFFSET(DATA_1_ADDR_MEM_OFFSET)
        ) eink_controller (
            .clk      (clk),
            .rst_n    (rst_n),
            .clr_flag (clr_flag),

            .sda      (sda),
            .scl      (scl),

            .EPD_SKV  (EPD_SKV),
            .EPD_SPV  (EPD_SPV),
            .EPD_XCL  (EPD_XCL),
            .EPD_XLE  (EPD_XLE),
            .EPD_XSTL (EPD_XSTL),
            .EPD_DOUT (EPD_DOUT),

            .pwr_good (pwr_good),
            .wake_up  (wake_up),
            .pwr_up   (pwr_up),
            .pwr_com  (pwr_com),

            .adv_en   (adv_en),
            .hs_i     (~vtc_hs_o),
            .vs_i     (~vtc_vs_o),
            .de_i     (vtc_de_o),
            .pix_clk  (pix_clk),
            .rgb_i    ({rgb_r,rgb_g,rgb_b})
        );

    EEPROM_AT24C64_SIM EEPROM_AT24C64_SIM (.scl(scl), .sda(sda));  // 用于写入测试

endmodule


