
//////////////////////////////////////////////////////////////////////////////////
//
//  这个模块可以将DDR指定地址的图像逐行读出
//  按照约定行最宽2200
//  一个缓冲区划分DDR大小4MB
//
//  假设图像大小2*3则对应映射关系入下:
//
//  | V/H  | 1    | 2    | 3    | ...  | 2198 | 2199 | 2200 |
//  | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
//  | 1    | pix1 | pix2 | null | null | null | null | null |
//  | 2    | pix3 | pix4 | null | null | null | null | null |
//  | 3    | pix5 | pix6 | null | null | null | null | null |
//  | 4    | null | null | null | null | null | null | null |
//  | ...  | null | null | null | null | null | null | null |
//  | 1869 | null | null | null | null | null | null | null |
//  | 1870 | null | null | null | null | null | null | null |
//  | 1871 | null | null | null | null | null | null | null |
//  | 1872 | null | null | null | null | null | null | null |
//
//  用法:
//  fdma_w_gray 模块写完一行后发出 fdma_rflag 脉冲此模块将读出一行到FIFO等待调教
//
//////////////////////////////////////////////////////////////////////////////////

module fdma_r_gary#
    (
    parameter FDMA_WID   = 64,  // FDMA数据宽度
    parameter MAX_H      = 2208,
    parameter FRAME_H    = 1920,
    parameter FRAME_V    = 1080
    )
    (
    input wire                      clk,
    input wire                      rst_n,

    input wire                      fdma_rflag,    // 读一行信号

    input wire   [31:0]             buf_addr,      // 帧缓存区起始地址

    output reg   [31: 0]            fdma_raddr,    // 读地址
    output reg                      fdma_rareq,    // 读请求
    input  wire                     fdma_rbusy,    // 读就绪
    input  wire  [FDMA_WID - 1:0]   fdma_rdata,    // 读数据
    output wire                     fdma_rready,   // 读控制器就绪
    output wire  [15: 0]            fdma_rsize,    // 读大小
    input  wire                     fdma_rvalid,   // 读有效

    output wire                     rbusy,         // 读出忙
    output wire                     fflag,         // 行读出完成

    input  wire                     fifo_ren,      // 输出使能
    output wire  [FDMA_WID - 1:0]   fifo_out,      // 数据输出

    output wire                     fifo_full,     // FIFO满
    output wire                     fifo_empty     // FIFO空
    );

    reg [8:0]   FDMA_BURST_LEN;

    initial begin
        FDMA_BURST_LEN = ((FRAME_H * 8) + FDMA_WID - 1) / FDMA_WID;
    end

    assign fdma_rready = 1;
    assign fdma_rsize  = FDMA_BURST_LEN;

    xpm_fifo_rgray_buf #(
        .FDMA_WID(FDMA_WID),
        .FRAME_H(FRAME_H)
        )fdma_rgray_buf (
        .clk    (clk),
        .rst_n  (rst_n),
        .din    (fdma_rdata),
        .wr_en  (fdma_rvalid),
        .rd_en  (fifo_ren),
        .dout   (fifo_out),
        .full   (fifo_full),
        .empty  (fifo_empty)
    );

    reg [2:0]   READ_STATE;
    reg [31:0]  v_cnt;

    localparam READ_IDEL    = 3'b000;  // 等待读行开始信号
    localparam READ_STATE1  = 3'b001;  // 根据行数计算开始地址
    localparam READ_STATE2  = 3'b011;  // FDMA读取

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            READ_STATE <= 0;
            v_cnt      <= 0;
            fdma_raddr <= 0;
            fdma_rareq <= 0;
        end
        else begin

            case(READ_STATE)

                READ_IDEL:begin  // 等待读行开始信号
                    if (fdma_rflag) begin
                        READ_STATE <= READ_STATE1;
                    end
                    else begin
                        READ_STATE <= READ_IDEL;
                    end
                end

                READ_STATE1:begin  // 根据行数计算开始地址
                    if (v_cnt < FRAME_V) begin
                        v_cnt      <= v_cnt + 1;
                        fdma_raddr <= buf_addr + v_cnt * MAX_H;  // 一个地址可以存8bit数据 也就是一个像素
                        READ_STATE <= READ_STATE2;
                    end
                    else begin
                        v_cnt      <= 0;
                        READ_STATE <= READ_STATE1;
                    end
                end

                READ_STATE2:begin  // FDMA读取
                    if(!fdma_rbusy)begin
                        fdma_rareq <= 1'b1;
                    end
                    if(fdma_rareq&&fdma_rbusy)begin
                        fdma_rareq <= 1'b0;
                        READ_STATE <= READ_IDEL;
                    end
                end

                default:begin
                    READ_STATE     <= READ_IDEL;
                end

            endcase

        end
    end

    assign rbusy = fdma_rbusy;  // FDMA读就绪则读取忙

    level2pulse #(  // FDMA读取一行完成标志
        .MODE("FALLING")
        ) FDMA_R_finish_flag (
        .clk    (clk),
        .rst_n  (rst_n),
        .in     (rbusy),
        .out    (fflag)
    );

endmodule