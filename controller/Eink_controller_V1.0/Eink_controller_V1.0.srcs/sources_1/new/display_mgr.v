
//////////////////////////////////////////////////////////////////////////////////
//
//  这个模块用于控制屏幕刷新
//
//////////////////////////////////////////////////////////////////////////////////

module display_mgr#
    (
    parameter SYS_CLK_FREQ = 50,    // 系统时钟Mhz
    parameter FDMA_WID     = 64,    // FDMA数据宽度
    // 屏幕信息
    parameter EPD_WID      = 8,     // EPD数据宽度
    parameter EPD_FREQ     = 25,    // EPD像素时钟频率Mhz
    parameter EPD_H        = 1200,  // 屏幕宽度
    parameter EPD_V        = 825,   // 屏幕长度
    parameter PERIOD_CNT   = 10,    // 帧刷新次数
    // 时序信息
    parameter tFdly        = 0,     // 帧间隔ms 较小值可能会导致更大的漏电流...
    parameter tLEdly       = 40,    // 单位ns
    parameter tLEw         = 40,
    parameter tLEoff       = 200
    )
    (
    input wire                      clk,
    input wire                      epd_clk,
    input wire                      rst_n,

    input wire                      s_flag,  // 触发刷新
    output reg  [7:0]               period_cnt,  // 周期计数器
    output reg                      d_busy,  // 正在刷新屏幕
    output reg                      d_fflag,   // 屏幕刷新完成
    // 数据
    output wire                     r_flag,     // 读取一行信号
    output wire                     fifo_ren,   // 使能FIFO输出数据
    input wire  [FDMA_WID - 1:0]    din,
    // 屏幕驱动信号
    output wire                     EPD_SKV,
    output wire                     EPD_SPV,
    output wire                     EPD_XCL,
    output wire                     EPD_XLE,
    output wire                     EPD_XSTL,
    output wire [EPD_WID -1:0]      EPD_DOUT
    );

    wire s_flag_t;

    sync_h2lck sync_s_flag
        (
            .in_clk    (clk),
            .out_clk   (epd_clk),
            .rst_n     (rst_n),
            .level_in  (s_flag),
            .pulse_out (s_flag_t)
        );

    reg [31:0] DELAY_CNT;

    initial begin
        DELAY_CNT = (EPD_FREQ * 32'd500) * tFdly;  // N0毫秒计数器
    end

    wire fend_flag;  // 帧刷新完成
    reg sf_flag;  // 触发帧信号
    reg [1:0] MGR_STATE;
    reg [31:0] delay_cnt;

    localparam MGR_IDEL   = 2'd0;
    localparam MGR_STATE1 = 2'd1;
    localparam MGR_STATE2 = 2'd2;
    localparam MGR_STATE3 = 2'd3;

    always @(posedge epd_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            MGR_STATE <= 0;
            period_cnt <= 0;
            delay_cnt <= 0;
            sf_flag <= 0;
            d_busy <= 0;
            d_fflag <= 0;
        end
        else begin

            case(MGR_STATE)

                MGR_IDEL:begin  // 等待开始信号
                    d_fflag <= 0;
                    if (s_flag_t) begin
                        d_busy <= 1;
                        MGR_STATE <= MGR_STATE1;
                    end
                    else begin
                        d_busy <= 0;
                    end
                end

                MGR_STATE1:begin
                    if (period_cnt < PERIOD_CNT) begin
                        period_cnt <= period_cnt + 1;  // 一次有效刷新需要输出几帧
                        MGR_STATE <= MGR_STATE2;
                        sf_flag <= 1;  // 触发刷新
                    end
                    else begin
                        period_cnt <= 0;
                        d_fflag <= 1;
                        MGR_STATE <= MGR_IDEL;
                    end
                end

                MGR_STATE2:begin
                    if (fend_flag) begin  // 刷新完成
                        MGR_STATE <= MGR_STATE3;
                    end
                    else begin
                        sf_flag <= 0;
                    end
                end

                MGR_STATE3:begin
                    if (delay_cnt < DELAY_CNT) begin  // 刷新完延迟一段时间
                        delay_cnt <= delay_cnt + 1;
                    end
                    else begin
                        delay_cnt <= 0;
                        MGR_STATE <= MGR_STATE1;
                    end
                end

                default:begin
                    MGR_STATE <= MGR_IDEL;
                end

            endcase

        end
    end

    frame_ctrl #(
            .EPD_WID(EPD_WID),
            .EPD_FREQ(EPD_FREQ),
            .EPD_H(EPD_H),
            .EPD_V(EPD_V),
            .tLEdly(tLEdly),
            .tLEw(tLEw),
            .tLEoff(tLEoff)
        ) frame_ctrl (
            .rst_n    (rst_n),
            .epd_clk  (epd_clk),
            .s_flag   (sf_flag),  // 开始信号
            .SKV      (EPD_SKV),
            .SPV      (EPD_SPV),
            .XCL      (EPD_XCL),
            .XLE      (EPD_XLE),
            .XSTL     (EPD_XSTL),
            .r_flag   (r_flag),  // FDMA读取一行
            .end_flag (fend_flag)  // 帧完成
        );

    wire [EPD_WID - 1:0] DOUT;

    data_mgr #(
            .IN_WID(FDMA_WID),
            .OUT_WID(EPD_WID)
        ) data_mgr (
            .clk      (epd_clk),
            .rst_n    (rst_n),
            .fifo_ren (fifo_ren),
            .din      (din),
            .data_ren (~EPD_XSTL),
            .dout     (DOUT)
        );

    genvar i;
    generate for(i = 0; i < EPD_WID - 1; i = i + 2) begin
      assign EPD_DOUT[i + 1 : i] = DOUT[EPD_WID - 1 - i : EPD_WID - 2 - i];
    end endgenerate

//    DATA_MGR_LOGIC DATA_MGR_LOGIC (
//        .clk(epd_clk), // input wire clk
//
//        .probe0(
//            {EPD_SPV,
//            r_flag,
//            fifo_ren,
//            din,
//            EPD_XSTL,
//            EPD_DOUT})
//    );

endmodule
