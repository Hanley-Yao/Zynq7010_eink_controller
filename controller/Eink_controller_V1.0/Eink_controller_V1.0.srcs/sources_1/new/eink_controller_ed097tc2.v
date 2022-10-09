//`define vsim  // 仿真命令

module eink_controller_ed097tc2#
    (
    parameter SYS_CLK_FREQ            = 50,           // 系统时钟Mhz
    parameter SCL_FREQ                = 50,           // I2C时钟频率Khz
    parameter DELAY_CNT               = 32'h00FFFFFF, // 系统配置延迟
    // 显示管理
    parameter VCOM                    = 1810,         // -1.81V
    parameter EPD_WID                 = 8,            // EPD数据宽度
    parameter EPD_FREQ                = 30,           // EPD像素时钟频率Mhz
    parameter EPD_H                   = 1200,         // EPD屏幕长度
    parameter EPD_V                   = 825,          // EPD屏幕宽度
    parameter PERIOD_CNT              = 10,           // EPD图像刷新周期数
    parameter SPL_TIME                = 2,            // 在第 PERIOD_CNT - SPL_TIME 周期触发帧采样
    // 时序信息
    parameter tFdly                   = 0,            // 帧间隔ms 较小值可能会导致更大的漏电流...
    parameter tLEdly                  = 40,           // 单位ns
    parameter tLEw                    = 40,
    parameter tLEoff                  = 200,
    // 输入图像配置
    parameter MAX_H                   = 2208,         // 考虑地址对齐所以+8
    parameter MAX_V                   = 1872,         //
    parameter FRAME_H                 = 1200,         // 输入长度
    parameter FRAME_V                 = 825,          // 输入宽度
    // FDMA配置
    parameter FDMA_WID                = 64,           // FDMA数据宽度
    // 缓冲区配置
    parameter GRAY_SIZE               = 4,            // 缓冲区长度单位MB
    parameter DATA_SIZE               = 1,
    parameter TEXTURE_ADDR_MEM_OFFSET = 32'hF100000,
    parameter GRAY_0_ADDR_MEM_OFFSET  = 32'hF500000,
    parameter GRAY_1_ADDR_MEM_OFFSET  = 32'hF900000,
    parameter DATA_0_ADDR_MEM_OFFSET  = 32'hFD00000,
    parameter DATA_1_ADDR_MEM_OFFSET  = 32'hFE00000
    )

    (
    input wire                      clk,
    input wire                      rst_n,
    input wire                      clr_flag,  // 清屏
    // config
    inout  wire                     sda,
    output wire                     scl,
    // Power
    input wire                      pwr_en,
    output wire                     wake_up,
    output wire                     pwr_up,
    output wire                     pwr_com,
    // EPD CTRL
    output wire                     EPD_SKV,
    output wire                     EPD_SPV,
    output wire                     EPD_XCL,
    output wire                     EPD_XLE,
    output wire                     EPD_XSTL,
    output wire [EPD_WID -1:0]      EPD_DOUT,
    // ADV7611 HDMI RX
    input wire                      hs_i,
    input wire                      vs_i,
    input wire                      de_i,
    input wire                      pix_clk,
    input wire [7:0]                gray_i
    );

//--------------------------------------------------------------
    reg                     gray_de;
    reg                     gray_hs;
    reg                     gray_vs;
    reg   [7:0]             gray_data;
//--------------------------------------------------------------
    wire                    w_gray_busy;
    wire                    w_gray_fflag;
    wire                    clr_fflag;
    wire [FDMA_WID -1:0]    r_data_fifo_out;
//--------------------------------------------------------------
    wire  [7:0]             period_cnt;
    wire                    epd_busy;
    wire                    epd_fflag;
    wire                    r_data_flag;
    wire                    r_data_fifo_ren;
//--------------------------------------------------------------
    wire                    w_gray_s_flag;
    wire                    clr_s_flag;
    wire                    epd_clk;
    wire                    epd_s_flag;
//--------------------------------------------------------------
    wire                    cfg_done;

    wire        [8 :0]      REG_INDEX;
    wire        [39:0]      REG_DATA;
    wire        [8 :0]      REG_SIZE;

    wire                    p_clr_flag;
//--------------------------------------------------------------
    wire                    rst_o;
//--------------------------------------------------------------
    wire                    clk_50m;
    wire                    pll_locked;
    wire                    sys_rst_n;
//--------------------------------------------------------------

    assign sys_rst_n = pll_locked & rst_n;

    `ifdef vsim

    div_2 test_clk (.clk(clk), .rst_n(rst_n), .q(epd_clk));

    assign clk_50m = clk;
    assign pll_locked = 1;

    `else
    clock_pll_ed097tc2 clock_pll
        (
            .clk_in(clk),
            .resetn(rst_n),

            .clk_50m(clk_50m),
            .epd_clk(epd_clk),

            .locked(pll_locked)
        );
    `endif

    delay_cnt #(
            .NUM(DELAY_CNT)
        ) delay_cnt (
            .clk_i(clk_50m),
            .rstn_i(sys_rst_n),
            .rst_o(rst_o)
        );

    iic_config #(
            .VCOM(VCOM),
            .SYS_CLK_FREQ(SYS_CLK_FREQ),
            .SCL_FREQ(SCL_FREQ)
        ) iic_config (
            .clk       (clk),
            .rst_n     (rst_n),
            .scl       (scl),
            .sda       (sda),
            .REG_INDEX (REG_INDEX),
            .REG_DATA  (REG_DATA),
            .REG_SIZE  (REG_SIZE),
            .cfg_done  (cfg_done)
        );

    config_reg_ed097tc2 #(
            .VCOM(VCOM)
        ) config_reg_ed097tc2 (
            .REG_INDEX(REG_INDEX),
            .REG_DATA(REG_DATA),
            .REG_SIZE(REG_SIZE)
        );


    level2pulse #(.MODE("RISING")) clear_flag (.clk(clk_50m), .rst_n(sys_rst_n), .in(cfg_done), .out(p_clr_flag));

    always @(posedge pix_clk)begin  // buf
        gray_hs    <= ~hs_i;
        gray_vs    <= ~vs_i;
        gray_de    <= de_i;
        gray_data  <= gray_i;
    end

//--------------------------------------------------------------

    tps65185_ctrl tps65185_ctrl
        (
            .clk      (clk_50m),
            .rst_n    (sys_rst_n & cfg_done),  // 等待配置完成
            .pwr_en   (pwr_en),
            .pwr_good (pwr_good),
            .wake_up  (wake_up),
            .pwr_up   (pwr_up),
            .pwr_com  (pwr_com)
        );

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
            .clk             (clk_50m),  // input
            .rst_n           (sys_rst_n),  // input

            .w_gray_s_flag   (w_gray_s_flag),  // input
            .pix_clk         (pix_clk),  // input
            .gray_de         (gray_de),  // input
            .gray_hs         (gray_hs),  // input
            .gray_vs         (gray_vs),  // input
            .gray_data       (gray_data[7:0]),  // input
            .w_gray_busy     (w_gray_busy),  // output
            .w_gray_fflag    (w_gray_fflag),  // output

            .clr_s_flag      (clr_s_flag),  // input
            .clr_fflag       (clr_fflag),  // output

            .epd_clk         (epd_clk),  // input
            .sw_rdata_addr   (epd_fflag),  // input
            .r_data_flag     (r_data_flag),  // input
            .r_data_fifo_ren (r_data_fifo_ren),  // input
            .r_data_fifo_out (r_data_fifo_out)  // output
        );

    display_mgr #(
            .SYS_CLK_FREQ(SYS_CLK_FREQ),
            .FDMA_WID(FDMA_WID),
            .EPD_WID(EPD_WID),
            .EPD_FREQ(EPD_FREQ),
            .EPD_H(EPD_H),
            .EPD_V(EPD_V),
            .PERIOD_CNT(PERIOD_CNT),
            .tFdly(tFdly),
            .tLEdly(tLEdly),
            .tLEw(tLEw),
            .tLEoff(tLEoff)
        ) display_mgr (
            .clk        (clk_50m),  // input
            .epd_clk    (epd_clk),  // input
            .rst_n      (sys_rst_n),  // input

            .s_flag     (epd_s_flag),       // input 刷新
            .period_cnt (period_cnt),       // output 周期计数器
            .d_busy     (epd_busy),         // output 屏幕刷新忙
            .d_fflag    (epd_fflag),        // output 屏幕刷新完成

            .r_flag     (r_data_flag),      // output FDMA读一行
            .fifo_ren   (r_data_fifo_ren),  // output FIFO读一行
            .din        (r_data_fifo_out),  // input FIFO数据

            .EPD_SKV    (EPD_SKV),  // output
            .EPD_SPV    (EPD_SPV),  // output
            .EPD_XCL    (EPD_XCL),  // output
            .EPD_XLE    (EPD_XLE),  // output
            .EPD_XSTL   (EPD_XSTL),  // output
            .EPD_DOUT   (EPD_DOUT)  // output
        );

    system_mgr #(
            .PERIOD_CNT(PERIOD_CNT),
            .SPL_TIME  (SPL_TIME)
        ) system_mgr (
            .clk           (clk_50m),  // input
            .rst_n         (sys_rst_n),  // input

            .w_gray_s_flag (w_gray_s_flag),  // output
            .w_gray_busy   (w_gray_busy),  // input
            .w_gray_fflag  (w_gray_fflag),  // input

            .clr_flag      (~clr_flag || p_clr_flag),  // input 配置完成清除缓冲区
            .clr_s_flag    (clr_s_flag),  // output
            .clr_fflag     (clr_fflag),  // input

            .epd_clk       (epd_clk),  // input
            .epd_s_flag    (epd_s_flag),  // output
            .period_cnt    (period_cnt),  // input
            .epd_busy      (epd_busy),  // input
            .epd_fflag     (epd_fflag)  // input
        );

//    GRAY_RX GRAY_RX (
//        .clk(pix_clk),
//
//        .probe0(gray_de),
//        .probe1(gray_hs),
//        .probe2(gray_vs),
//        .probe3(gray_data)
//    );

//    EPD_LOGIC EPD_LOGIC (
//        .clk(EPD_XCL), // input wire clk
//
//        .probe0 (
//            {EPD_SKV,
//            EPD_SPV,
//            EPD_XLE,
//            EPD_XSTL,
//            EPD_DOUT,
//            w_gray_busy,
//            w_gray_fflag,
//            clr_fflag,
//            period_cnt,
//            epd_busy,
//            epd_fflag,
//            r_data_flag,
//            r_data_fifo_ren,
//            w_gray_s_flag,
//            clr_s_flag,
//            epd_s_flag}
//        )
//    );

endmodule