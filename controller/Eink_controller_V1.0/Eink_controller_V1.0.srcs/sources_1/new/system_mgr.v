
//////////////////////////////////////////////////////////////////////////////////
//
//  这是一个系统管理器,用于管理各个模块与屏幕刷新
//
//////////////////////////////////////////////////////////////////////////////////

module system_mgr#
    (
    parameter PERIOD_CNT = 10,  // EPD刷新重复周期数
    parameter SPL_TIME   = 2    // 在第 PERIOD_CNT - SPL_TIME 周期触发帧采样
    )
    (
    input wire          clk,
    input wire          rst_n,
    // 帧采样处理
    output reg          w_gray_s_flag,  // 开始处理一帧
    input wire          w_gray_busy,   // 正在采样
    input wire          w_gray_fflag,  // 采样完成标志
    // 缓冲区屏幕清理
    input wire          clr_flag,  // 准备清除缓冲区
    output reg          clr_s_flag,  // 开始清除缓冲区
    input wire          clr_fflag,  // 清除完成
    // 显示管理
    input wire          epd_clk,
    output reg          epd_s_flag,  // 开始刷新
    input wire  [7:0]   period_cnt,
    input wire          epd_busy,  // 正在刷新屏幕
    input wire          epd_fflag   // 屏幕刷新完成
    );

    reg clr_flag_t;  // 暂存
    reg [1:0] CLR_T_STATE;

    localparam CLR_T_STATE1 = 0;
    localparam CLR_T_STATE2 = 1;
    localparam CLR_T_STATE3 = 2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            CLR_T_STATE <= 0;
            clr_flag_t <= 0;
        end
        else begin
            case(CLR_T_STATE)

                CLR_T_STATE1:begin
                    if (clr_flag) begin
                        clr_flag_t <= 1;
                        CLR_T_STATE <= CLR_T_STATE2;
                    end
                end

                CLR_T_STATE2:begin
                    if (clr_s_flag) begin
                        clr_flag_t <= 0;
                        CLR_T_STATE <= CLR_T_STATE3;
                    end
                end

                CLR_T_STATE3:begin
                    if (clr_fflag) begin  // 等待清屏结束
                        CLR_T_STATE <= CLR_T_STATE1;
                    end
                end

                default:begin
                    CLR_T_STATE <= CLR_T_STATE1;
                end

            endcase

        end
    end

    wire epd_fflag_t;

    sync_h2lck sync_epd_fflag
        (
            .in_clk    (epd_clk),
            .out_clk   (clk),
            .rst_n     (rst_n),
            .level_in  (epd_fflag),
            .pulse_out (epd_fflag_t)
        );

    reg [3:0] SYS_STATE;
    reg [3:0] clr_cnt;

    localparam SYS_IDEL   = 0;
    localparam SYS_STATE1 = 1;
    localparam SYS_STATE2 = 2;
    localparam SYS_STATE3 = 3;
    localparam SYS_STATE4 = 4;
    localparam SYS_STATE5 = 5;
    localparam SYS_STATE6 = 6;
    localparam SYS_STATE7 = 7;
    localparam SYS_STATE8 = 8;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            SYS_STATE <= 0;
            clr_s_flag <= 0;
            clr_cnt <= 0;
            epd_s_flag <= 0;
            w_gray_s_flag <= 0;
        end
        else begin
            case(SYS_STATE)

                SYS_IDEL:begin
                    if (clr_flag_t) begin  // 触发
                        SYS_STATE <= SYS_STATE1;
                    end
                end

                SYS_STATE1:begin
                    clr_s_flag <= 1;  // 触发清除缓冲区
                    SYS_STATE <= SYS_STATE2;
                end

                SYS_STATE2:begin
                    clr_s_flag <= 0;
                    if (clr_fflag) begin  // 等待缓存清除完成
                        SYS_STATE <= SYS_STATE3;
                    end
                end

                SYS_STATE3:begin  // 刷新两帧清除屏幕
                    if (clr_cnt < 2'd2) begin
                        clr_cnt <= clr_cnt + 1;
                        epd_s_flag <= 1;
                        SYS_STATE <= SYS_STATE4;
                    end
                    else begin
                        clr_cnt <= 0;
                        if (clr_flag_t) begin
                            SYS_STATE <= SYS_STATE1;  // 清屏按钮未抬起继续执行清屏操作
                        end
                        else begin
                            SYS_STATE <= SYS_STATE5;  // 跳转到采样刷新状态
                        end

                    end
                end

                SYS_STATE4:begin
                    epd_s_flag <= 0;
                    if (epd_fflag_t) begin  // 等待屏幕刷新完成
                        SYS_STATE <= SYS_STATE3;
                    end
                end

                SYS_STATE5:begin
                    w_gray_s_flag <= 1;  // 触发帧采样
                    SYS_STATE <= SYS_STATE6;
                end

                SYS_STATE6:begin
                    w_gray_s_flag <= 0;
                    if (w_gray_fflag) begin  // 等待采样完成
                        epd_s_flag <= 1;  // 触发屏幕刷新
                        SYS_STATE <= SYS_STATE7;
                    end
                end

                SYS_STATE7:begin
                    epd_s_flag <= 0;
                    if (period_cnt == PERIOD_CNT - SPL_TIME) begin
                        w_gray_s_flag <= 1;  // 触发帧采样
                        SYS_STATE <= SYS_STATE8;
                    end
                end

                SYS_STATE8:begin
                    w_gray_s_flag <= 0;
                    if (~epd_busy & ~ w_gray_busy) begin  // 写入与刷新完成后
                        if (clr_flag_t) begin
                            SYS_STATE <= SYS_STATE1;
                        end
                        else begin
                            epd_s_flag <= 1;  // 触发屏幕刷新
                            SYS_STATE <= SYS_STATE7;
                        end
                    end
                end

                default:begin
                    SYS_STATE <= SYS_IDEL;
                end

            endcase
        end
    end


endmodule
