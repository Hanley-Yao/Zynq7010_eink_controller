
//////////////////////////////////////////////////////////////////////////////////
//
//  这个模块用于重置缓冲区,效果表现在屏幕刷至全白
//
//////////////////////////////////////////////////////////////////////////////////

module fdma_clear#
    (
    parameter FDMA_WID      = 64,   // FDMA数据宽度
    parameter MAX_H         = 2208,
    parameter MAX_V         = 1872,
    parameter GRAY_0_ADDR_MEM_OFFSET    = 32'h1F500000,
    parameter GRAY_1_ADDR_MEM_OFFSET    = 32'h1F900000,
    parameter DATA_0_ADDR_MEM_OFFSET    = 32'h1FD00000,
    parameter DATA_1_ADDR_MEM_OFFSET    = 32'h1FE00000
    )
    (
    input wire                      clk,
    input wire                      rst_n,

    input wire                      clr_flag,       // 触发清除缓冲区

    output reg  [31:0]              fdma_waddr,     // 写地址
    output reg                      fdma_wareq,     // 写请求
    input wire                      fdma_wbusy,     // 写就绪
    output reg  [FDMA_WID - 1:0]    fdma_wdata,     // 写数据
    output wire                     fdma_wready,    // 写控制器就绪
    output wire [15:0]              fdma_wsize,     // 写大小
    input wire                      fdma_wvalid,    // 写有效

    output reg                      wbusy,
    output wire                     fflag
    );

    function integer burst_len  (  // 自动计算FDMA写入一次的突然长度
        input integer FDMA_WID,  // 接口位宽
        input integer MAX_H
        );
        burst_len = ((MAX_H * 8) + FDMA_WID - 1) / FDMA_WID;  // 写MAX_H行所需长度
    endfunction

    parameter FDMA_BURST_LEN = burst_len(FDMA_WID,MAX_H);

    assign fdma_wready = 1;
    assign fdma_wsize  = FDMA_BURST_LEN;

    reg [2:0]   CLEAR_STATE;
    reg [2:0]   P_STATE;
    reg [31:0]  buf_addr;
    reg [15:0]  v_cnt;  // 清除计数器
    reg         cle_flag;  // 写入完成需要发出刷新信号

    localparam CLEAR_IDEL   = 0;
    localparam CLEAR_STATE1 = 1;
    localparam CLEAR_STATE2 = 2;
    localparam CLEAR_STATE3 = 3;
    localparam CLEAR_STATE4 = 4;
    localparam WRITE_FDMA   = 5;
    localparam WAIT_FDMA    = 6;
    localparam WRITE_DONE   = 7;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            fdma_waddr  <= 0;
            fdma_wareq  <= 0;
            v_cnt <= 0;
            buf_addr <= 0;
            CLEAR_STATE <= 0;
            P_STATE <= 0;
            cle_flag <= 0;
            fdma_wdata <= 0;
            wbusy <= 0;
        end
        else begin

            case(CLEAR_STATE)

                CLEAR_IDEL:begin  // 等待开始信号
                    if (clr_flag) begin
                        CLEAR_STATE <= CLEAR_STATE1;
                        wbusy <= 1;
                    end
                    else begin
                        wbusy <= 0;
                    end
                end

                CLEAR_STATE1:begin  // 清除第一个GRAY缓冲区
                    if (v_cnt < MAX_V) begin
                        v_cnt <= v_cnt + 1;
                        buf_addr <= GRAY_0_ADDR_MEM_OFFSET + v_cnt * MAX_H;  // 计算写入地址
                        fdma_wdata <= {FDMA_WID{1'b1}};  // 写入数据
                        CLEAR_STATE <= WRITE_FDMA;
                        P_STATE <= CLEAR_STATE1;
                    end
                    else begin
                        v_cnt <= 0;
                        CLEAR_STATE <= CLEAR_STATE2;
                    end
                end

                CLEAR_STATE2:begin  // 清除第二个GRAY缓冲区
                    if (v_cnt < MAX_V) begin
                        v_cnt <= v_cnt + 1;
                        buf_addr <= GRAY_1_ADDR_MEM_OFFSET + v_cnt * MAX_H;  // 计算写入地址
                        fdma_wdata <= {FDMA_WID{1'b1}};  // 写入数据
                        CLEAR_STATE <= WRITE_FDMA;
                        P_STATE <= CLEAR_STATE2;
                    end
                    else begin
                        v_cnt <= 0;
                        CLEAR_STATE <= CLEAR_STATE3;
                    end
                end

                CLEAR_STATE3:begin  // 数据缓冲区置黑
                    if (v_cnt < MAX_V / 4) begin
                        v_cnt <= v_cnt + 1;
                        buf_addr <= DATA_0_ADDR_MEM_OFFSET + v_cnt * MAX_H;  // 计算写入地址
                        fdma_wdata <= {(FDMA_WID/2){2'b01}};  // 驱动黑"01"
                        CLEAR_STATE <= WRITE_FDMA;
                        P_STATE <= CLEAR_STATE3;
                    end
                    else begin
                        v_cnt <= 0;
                        CLEAR_STATE <= CLEAR_STATE4;
                    end
                end

                CLEAR_STATE4:begin  // 数据缓冲区置白
                    if (v_cnt < MAX_V / 4) begin
                        v_cnt <= v_cnt + 1;
                        buf_addr <= DATA_1_ADDR_MEM_OFFSET + v_cnt * MAX_H;  // 计算写入地址
                        fdma_wdata <= {(FDMA_WID/2){2'b10}};  // 驱动白"10"
                        CLEAR_STATE <= WRITE_FDMA;
                        P_STATE <= CLEAR_STATE4;
                    end
                    else begin
                        v_cnt <= 0;
                        CLEAR_STATE <= CLEAR_IDEL;
                    end
                end

                WRITE_FDMA:begin
                    if (!fdma_wbusy) begin
                        fdma_waddr  <= buf_addr;  // 开始写地址
                        fdma_wareq  <= 1'b1;
                    end
                    if (fdma_wareq&&fdma_wbusy) begin  // 等待开始写入
                        fdma_wareq  <= 1'b0;
                        CLEAR_STATE <= WAIT_FDMA;
                    end
                end

                WAIT_FDMA:begin
                    if (~fdma_wareq&&~fdma_wbusy) begin
                        CLEAR_STATE <= P_STATE;  // 等待写入完成
                    end
                end

                default:begin
                    CLEAR_STATE <= CLEAR_IDEL;
                end

            endcase

        end
    end

    level2pulse #(  // FDMA写入一行完成标志
        .MODE("FALLING")
        ) FDMA_W_finish_flag (
        .clk    (clk),
        .rst_n  (rst_n),
        .in     (wbusy),
        .out    (fflag)
    );

endmodule
