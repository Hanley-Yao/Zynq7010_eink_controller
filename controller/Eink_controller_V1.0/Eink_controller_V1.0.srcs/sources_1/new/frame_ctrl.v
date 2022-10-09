
module frame_ctrl
    #(
    // 屏幕信息
    parameter EPD_WID   = 8,
    parameter EPD_FREQ  = 25,
    parameter EPD_H     = 1200,
    parameter EPD_V     = 825,
    // 时序信息
    parameter tLEdly    = 40,
    parameter tLEw      = 40,
    parameter tLEoff    = 200
    )
    (
    input wire rst_n,
    input wire epd_clk,

    input wire  s_flag,        // 帧开始

    output reg  SKV,          // 时钟脉冲源驱动
    output reg  SPV,          // 启动脉冲门驱动器
    output wire XCL,          // 时钟脉冲源驱动
    output reg  XLE,          // 锁存使能源驱动器
    output reg  XSTL,         // 启动脉冲源驱动器

    output wire r_flag,        // 读取新的一行数据

    output reg  end_flag       // 帧结束
    );

    ///////////////////////////////////
    //-----------时序初始化-----------//
    ///////////////////////////////////

    wire    [10:0]  N_SKV;    // SKV循环周期
    wire    [10:0]  T_SKV;    // SKV持续XCL周期
    wire    [10:0]  T_SKV_H;  // SKV高保持XCL周期
    wire    [10:0]  SPV_L;    // SPV拉低
    wire    [10:0]  XLE_H;    // XLE拉高
    wire    [10:0]  XLE_H_K;  // XLE高保持时间
    wire    [10:0]  XSTL_L;   // XSTL拉低
    wire    [10:0]  XSTL_L_K; // XSTL低保持时间

    frame_timing #(
            .EPD_WID(EPD_WID),
            .EPD_FREQ(EPD_FREQ),
            .EPD_H(EPD_H),
            .EPD_V(EPD_V),
            .tLEdly(tLEdly),
            .tLEw(tLEw),
            .tLEoff(tLEoff)
        ) frame_timing (
            .clk      (epd_clk),
            .rst_n    (rst_n),
            .N_SKV    (N_SKV),
            .T_SKV    (T_SKV),
            .T_SKV_H  (T_SKV_H),
            .SPV_L    (SPV_L),
            .XLE_H    (XLE_H),
            .XLE_H_K  (XLE_H_K),
            .XSTL_L   (XSTL_L),
            .XSTL_L_K (XSTL_L_K)
        );

    ///////////////////////////////////
    //-------生成EPD主时钟XCL--------//
    ///////////////////////////////////

    assign XCL = epd_clk;

    ///////////////////////////////////
    //-------------SKV---------------//
    ///////////////////////////////////

    reg [10:0]  cnt_n_skv;  // 第几行
    reg [10:0]  cnt_t_skv;  // 周期宽度

    reg [3:0]   SKV_STATE;  // 状态

    localparam  SKV_IDEL   = 4'd0,
                SKV_STATE1 = 4'd1,
                SKV_STATE2 = 4'd2,
                SKV_STATE3 = 4'd3,
                SKV_DONE   = 4'd4;

    always @(posedge epd_clk or negedge rst_n) begin  // s_flag触发
        if (!rst_n) begin
            // reset
            SKV       <= 0;
            end_flag  <= 0;
            cnt_n_skv <= 0;
            cnt_t_skv <= 0;
            SKV_STATE <= 0;
        end
        else begin
            case(SKV_STATE)

                SKV_IDEL:begin
                    if (s_flag) begin  // 等待帧开始信号
                        SKV_STATE <= SKV_STATE1;
                    end
                end

                SKV_STATE1:begin
                    if (cnt_t_skv < T_SKV_H) begin  // SKV保持为高T_SKV_H个周期
                        cnt_t_skv <= cnt_t_skv + 1;
                        SKV       <= 1;
                    end
                    else if (cnt_t_skv < T_SKV) begin
                        cnt_t_skv <= cnt_t_skv + 1;
                        SKV       <= 0;
                    end
                    else if (cnt_t_skv == T_SKV) begin  // 循环T_SKV个周期
                        if (cnt_n_skv < N_SKV) begin
                            cnt_t_skv <= 0;
                            cnt_n_skv <= cnt_n_skv + 1;
                        end
                        else begin
                            SKV_STATE <= SKV_DONE;
                            end_flag   <= 1;
                        end
                    end
                end

                SKV_DONE:begin
                    SKV       <= 0;
                    end_flag  <= 0;
                    cnt_n_skv <= 0;
                    cnt_t_skv <= 0;
                    SKV_STATE <= 0;
                end

                default:begin
                    SKV_STATE <= 0;
                end

            endcase
        end
    end

    ///////////////////////////////////
    //-------------SPV---------------//
    ///////////////////////////////////

    reg [3:0]   SPV_STATE;  // 状态

    reg [10:0]  cnt_spv;

    localparam  SPV_IDEL   = 4'd0,
                SPV_STATE1 = 4'd1,
                SPV_STATE2 = 4'd2,
                SPV_DONE   = 4'd3;

    always @(posedge epd_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            SPV       <= 1;
            cnt_spv   <= 0;
            SPV_STATE <= 0;
        end
        else begin
            case(SPV_STATE)

                SPV_IDEL:begin
                    if (s_flag) begin
                        SPV_STATE <= SPV_STATE1;
                    end
                end

                SPV_STATE1:begin
                    if (cnt_t_skv == SPV_L) begin
                        cnt_spv   <= cnt_spv + 1;
                        SPV       <= 0;
                        SPV_STATE <= SPV_STATE2;
                    end
                end

                SPV_STATE2:begin  // 保持T_SKV时间低电平
                    if (cnt_spv < T_SKV) begin
                        cnt_spv <= cnt_spv + 1;
                        SPV     <= 0;
                    end
                    else begin
                        SPV_STATE <= SPV_DONE;
                        SPV       <= 1;
                    end
                end

                SPV_DONE:begin
                    SPV       <= 1;
                    cnt_spv   <= 0;
                    SPV_STATE <= 0;
                end

                default:begin
                    SPV_STATE <= 0;
                end

            endcase
        end
    end


    ///////////////////////////////////
    //-------------XSTL--------------//
    ///////////////////////////////////

    reg [10:0]  cnt_xstl;
    reg [10:0]  cnt_v_xstl;

    reg [3:0]   XSTL_STATE;

    localparam XSTL_IDEL   = 4'd0;
    localparam XSTL_STATE1 = 4'd1;
    localparam XSTL_STATE2 = 4'd2;
    localparam XSTL_DONE   = 4'd3;

    always @(posedge epd_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            XSTL_STATE <= 0;
            cnt_v_xstl <= 0;
            cnt_xstl   <= 0;
            XSTL       <= 1;
        end
        else begin
            case(XSTL_STATE)

                XSTL_IDEL:begin
                    if (cnt_n_skv == 4'd3) begin  // 等待SKV的第四个周期开始
                        XSTL_STATE <= XSTL_STATE1;
                        cnt_xstl   <= cnt_xstl + 1;
                    end
                end

                XSTL_STATE1:begin
                    if (cnt_xstl < XSTL_L) begin
                        cnt_xstl   <= cnt_xstl + 1;
                        XSTL       <= 1;
                    end
                    else begin
                        cnt_xstl   <= 0;
                        XSTL       <= 0;
                        XSTL_STATE <= XSTL_STATE2;
                    end
                end

                XSTL_STATE2:begin
                    if (cnt_xstl < XSTL_L_K) begin  // 保持为低XSTL_L_K个周期
                        cnt_xstl <= cnt_xstl + 1;
                        XSTL     <= 0;
                    end
                    else if (cnt_xstl < T_SKV) begin
                        cnt_xstl <= cnt_xstl + 1;
                        XSTL     <= 1;
                    end
                    else begin
                        if (cnt_v_xstl < EPD_V - 1) begin  // 循环V个周期
                            cnt_v_xstl <= cnt_v_xstl + 1;
                            cnt_xstl   <= 0;
                            XSTL       <= 0;
                        end
                        else begin
                            XSTL_STATE <= XSTL_DONE;
                        end
                    end
                end

                XSTL_DONE:begin
                    XSTL_STATE <= 0;
                    cnt_v_xstl <= 0;
                    cnt_xstl   <= 0;
                    XSTL       <= 1;
                end

                default:begin
                    XSTL_STATE <= 0;
                end

            endcase
        end
    end

    ///////////////////////////////////
    //-------------DATA--------------//
    ///////////////////////////////////

    reg [10:0]  cnt_data;
    reg [10:0]  cnt_v_data;

    reg r_flag_t;

    reg [3:0]   DATA_STATE;

    localparam DATA_IDEL   = 4'd0;
    localparam DATA_STATE1 = 4'd1;
    localparam DATA_STATE2 = 4'd2;
    localparam DATA_DONE   = 4'd3;

    always @(posedge epd_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            DATA_STATE <= 0;
            cnt_v_data <= 0;
            cnt_data   <= 0;
            r_flag_t     <= 1;
        end
        else begin
            case(DATA_STATE)

                DATA_IDEL:begin
                    if (cnt_n_skv == 4'd2) begin  // 等待SKV的第三个周期开始
                        DATA_STATE <= DATA_STATE1;
                        cnt_data   <= cnt_data + 1;
                    end
                end

                DATA_STATE1:begin
                    if (cnt_data < XSTL_L) begin
                        cnt_data   <= cnt_data + 1;
                        r_flag_t       <= 1;
                    end
                    else begin
                        cnt_data   <= 0;
                        r_flag_t       <= 0;
                        DATA_STATE <= DATA_STATE2;
                    end
                end

                DATA_STATE2:begin
                    if (cnt_data < XSTL_L_K) begin  // 保持为低DATA_L_K个周期
                        cnt_data <= cnt_data + 1;
                        r_flag_t     <= 0;
                    end
                    else if (cnt_data < T_SKV) begin
                        cnt_data <= cnt_data + 1;
                        r_flag_t     <= 1;
                    end
                    else begin
                        if (cnt_v_data < EPD_V - 1) begin  // 循环V个周期
                            cnt_v_data <= cnt_v_data + 1;
                            cnt_data   <= 0;
                            r_flag_t       <= 0;
                        end
                        else begin
                            DATA_STATE <= DATA_DONE;
                        end
                    end
                end

                DATA_DONE:begin
                    DATA_STATE <= 0;
                    cnt_v_data <= 0;
                    cnt_data   <= 0;
                    r_flag_t     <= 1;
                end

                default:begin
                    DATA_STATE <= 0;
                end

            endcase
        end
    end

    level2pulse #(.MODE("FALLING")) pulse_r_flag (.clk(epd_clk), .rst_n(rst_n), .in(r_flag_t), .out(r_flag));

    ///////////////////////////////////
    //--------------XLE--------------//
    ///////////////////////////////////

    reg [10:0]  cnt_xle;
    reg [10:0]  cnt_v_xle;

    reg [3:0]   XLE_STATE;

    localparam XLE_IDEL   = 4'd0;
    localparam XLE_STATE1 = 4'd1;
    localparam XLE_STATE2 = 4'd2;
    localparam XLE_DONE   = 4'd3;

    always @(posedge epd_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            XLE_STATE <= 0;
            cnt_v_xle <= 0;
            cnt_xle   <= 0;
            XLE       <= 0;
        end
        else begin
            case(XLE_STATE)

                XLE_IDEL:begin
                    if (cnt_n_skv == 4'd4) begin  // 等待SKV的第五个周期开始
                        XLE_STATE <= XLE_STATE1;
                        cnt_xle   <= cnt_xle + 1;
                    end
                end

                XLE_STATE1:begin
                    if (cnt_xle < XLE_H) begin
                        cnt_xle <= cnt_xle + 1;
                        XLE     <= 0;
                    end
                    else begin
                        cnt_xle   <= 0;
                        XLE       <= 1;
                        XLE_STATE <= XLE_STATE2;
                    end
                end

                XLE_STATE2:begin
                    if (cnt_xle < XLE_H_K) begin  // 保持为高XLE_H_K个周期
                        cnt_xle <= cnt_xle + 1;
                        XLE <= 1;
                    end
                    else if (cnt_xle < T_SKV) begin
                        cnt_xle <= cnt_xle + 1;
                        XLE     <= 0;
                    end
                    else begin
                        if (cnt_v_xle < EPD_V - 1) begin
                            cnt_v_xle <= cnt_v_xle + 1;
                            cnt_xle   <= 0;
                            XLE       <= 1;
                        end
                        else begin
                            XLE_STATE <= XLE_DONE;
                        end
                    end
                end

                XLE_DONE:begin
                    XLE_STATE <= 0;
                    cnt_v_xle <= 0;
                    cnt_xle   <= 0;
                    XLE       <= 0;
                end

                default:begin
                    XLE_STATE <= 0;
                end

            endcase
        end
    end

endmodule
