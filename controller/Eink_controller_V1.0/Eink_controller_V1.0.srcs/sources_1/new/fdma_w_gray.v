
//////////////////////////////////////////////////////////////////////
//
//  这个模块可以将整帧写入指定的DDR地址
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
//  使用fdma_wpulse脉冲触发写入
//
//////////////////////////////////////////////////////////////////////

module fdma_w_gray#
    (
    parameter FDMA_WID   = 64,  // FDMA数据宽度
    parameter MAX_H      = 2208,
    parameter FRAME_H    = 1920,
    parameter FRAME_V    = 1080
    )
    (
    input wire                      clk,
    input wire                      rst_n,

    input wire                      fdma_wflag,     // 写一帧信号

    input wire                      pix_clk,
    input wire  [7:0]               gray_data,
    input wire                      gray_vs,        // 换帧
    input wire                      gray_hs,        // 换行
    input wire                      gray_de,        // pix有效

    input wire  [31:0]              buf_addr,       // 帧缓存区起始地址

    output reg  [31:0]              fdma_waddr,     // 写地址
    output reg                      fdma_wareq,     // 写请求
    input  wire                     fdma_wbusy,     // 写就绪
    output wire [FDMA_WID - 1:0]    fdma_wdata,     // 写数据
    output wire                     fdma_wready,    // 写控制器就绪
    output wire [15:0]              fdma_wsize,     // 写大小
    input  wire                     fdma_wvalid,    // 写有效

    output wire                     wbusy,          // 写入忙
    output wire                     fflag,          // 行写入完成标志

    input wire                      fifo_ren,       // 输出使能
    output wire [FDMA_WID - 1:0]    fifo_out,       // 数据输出

    output wire                     fifo_full,      // FIFO满
    output wire                     fifo_empty      // FIFO空
    );

    reg [8:0]   FDMA_BURST_LEN;
    reg [11:0]  PKG_CNT;

    initial begin
        FDMA_BURST_LEN = ((FRAME_H * 8) + FDMA_WID - 1) / FDMA_WID;
        PKG_CNT        = FDMA_BURST_LEN * FDMA_WID / 8;
    end

    assign fdma_wready = 1;
    assign fdma_wsize  = FDMA_BURST_LEN;

    wire t_gray_vs;
    wire t_gray_hs;
    wire t_gray_de;

    sync_h2lck sync_gray_vs
        (
            .in_clk    (pix_clk),
            .out_clk   (clk),
            .rst_n     (rst_n),
            .level_in  (gray_vs),
            .pulse_out (t_gray_vs)
        );

    sync_h2lck sync_gray_hs
        (
            .in_clk    (pix_clk),
            .out_clk   (clk),
            .rst_n     (rst_n),
            .level_in  (gray_hs),
            .pulse_out (t_gray_hs)
        );

    sync_h2lck sync_gray_de
        (
            .in_clk    (pix_clk),
            .out_clk   (clk),
            .rst_n     (rst_n),
            .level_in  (gray_de),
            .pulse_out (t_gray_de)
        );

    reg         PKG_STATE;
    reg [11:0]  pkg_cnt;
    reg [7:0]   t_gray_data;
    reg [7:0]   tt_gray_data;
    reg         wr_en;

    localparam PKG_IDEL   = 1'b0;
    localparam PKG_STATE1 = 1'b1;

    always @(posedge pix_clk) begin  // 延迟两个时钟周期
        t_gray_data  <= gray_data;
        tt_gray_data <= t_gray_data;
    end

    always @(posedge pix_clk or negedge rst_n) begin  // 写入块
        if (!rst_n) begin
            // reset
            PKG_STATE <= 0;
            pkg_cnt   <= 0;
            wr_en     <= 0;
        end
        else begin

            case(PKG_STATE)

                PKG_IDEL:begin
                    if (gray_de) begin
                        PKG_STATE <= PKG_STATE1;
                    end
                    else begin
                        PKG_STATE <= PKG_IDEL;
                    end
                end

                PKG_STATE1:begin  // 保持块使能
                    if (pkg_cnt < PKG_CNT) begin
                        pkg_cnt   <= pkg_cnt + 1;
                        wr_en     <= 1;
                        PKG_STATE <= PKG_STATE1;
                    end
                    else begin
                        pkg_cnt   <= 0;
                        wr_en     <= 0;
                        PKG_STATE <= PKG_IDEL;
                    end
                end

                default:begin
                    PKG_STATE     <= PKG_IDEL;
                end

            endcase

        end
    end

    reg fifo_rst_n;

    wire t_fifo_rst_n;

    // 数据用于FDMA读取
    xpm_fifo_wgray_buf #(
        .FDMA_WID(FDMA_WID),
        .FRAME_H(FRAME_H)
        ) fdma_wgray_buf (  // 非对称FIFO 比率1:4
        .rst_n      (t_fifo_rst_n),
        .wr_clk     (pix_clk),
        .rd_clk     (clk),
        .din        (tt_gray_data),
        .wr_en      (wr_en),
        .rd_en      (fdma_wvalid),
        .dout       (fdma_wdata),
        .full       (),
        .empty      ()
    );

    // 数据用于图像处理模块读取
    xpm_fifo_wgray_buf #(
        .FDMA_WID(FDMA_WID),
        .FRAME_H(FRAME_H)
        ) fifo_algo_buf (  // 非对称FIFO 比率1:4
        .rst_n      (t_fifo_rst_n),
        .wr_clk     (pix_clk),
        .rd_clk     (clk),
        .din        (tt_gray_data),
        .wr_en      (wr_en),
        .rd_en      (fifo_ren),
        .dout       (fifo_out),
        .full       (fifo_full),
        .empty      (fifo_empty)
    );

    reg [2:0]   WRITE_STATE;
    reg [31:0]  v_cnt;

    localparam WRITE_IDEL   = 3'b000;  // 等待开始信号
    localparam WRITE_STATE1 = 3'b001;  // 等待换帧(保证采集完整一帧)
    localparam WRITE_STATE2 = 3'b011;  // 等待行数据有效
    localparam WRITE_STATE3 = 3'b010;  // 等待换行
    localparam WRITE_STATE4 = 3'b110;  // 换行结束
    localparam WRITE_STATE5 = 3'b111;  // 根据行数计算开始地址
    localparam WRITE_STATE6 = 3'b101;  // FDMA写入

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            WRITE_STATE <= 0;
            fdma_wareq       <= 0;
            fifo_rst_n       <= 0;
            v_cnt            <= 0;
            fdma_waddr       <= 0;
        end
        else begin
            case(WRITE_STATE)

                WRITE_IDEL:begin  // 等待开始信号
                    if (fdma_wflag) begin
                        WRITE_STATE <= WRITE_STATE1;
                    end
                    else begin
                        fifo_rst_n  <= 0;
                    end
                end

                WRITE_STATE1:begin  // 等待换帧(保证采集完整一帧)
                    if (t_gray_vs) begin
                        fifo_rst_n         <= 1;  // 仅允许在帧有效的时候写入fifo
                        WRITE_STATE <= WRITE_STATE2;
                    end
                    else begin
                        WRITE_STATE <= WRITE_STATE1;
                    end
                end

                WRITE_STATE2:begin  // 等待行数据有效
                    if (t_gray_de) begin
                        WRITE_STATE <= WRITE_STATE3;
                    end
                    else begin
                        WRITE_STATE <= WRITE_STATE2;
                    end
                end

                WRITE_STATE3:begin  // 等待换行
                    if (t_gray_hs) begin
                        WRITE_STATE <= WRITE_STATE4;
                    end
                    else begin
                        WRITE_STATE <= WRITE_STATE3;
                    end
                end

                WRITE_STATE4:begin  // 换行结束
                    if (!t_gray_hs) begin
                        WRITE_STATE <= WRITE_STATE5;
                    end
                    else begin
                        WRITE_STATE <= WRITE_STATE4;
                    end
                end

                WRITE_STATE5:begin  // 根据行数计算开始地址
                    if (v_cnt < FRAME_V) begin
                        v_cnt            <= v_cnt + 1;
                        fdma_waddr       <= buf_addr + v_cnt * MAX_H;
                        WRITE_STATE <= WRITE_STATE6;
                    end
                    else begin
                        v_cnt            <= 0;
                        WRITE_STATE <= WRITE_IDEL;
                    end
                end

                WRITE_STATE6:begin  // FDMA写入
                    if(!fdma_wbusy)begin
                        fdma_wareq       <= 1;
                    end
                    if(fdma_wareq&&fdma_wbusy)begin
                        fdma_wareq       <= 0;
                        WRITE_STATE <= WRITE_STATE3;
                    end
                end

                default:begin
                    WRITE_STATE     <= WRITE_IDEL;
                end

            endcase
        end
    end

    xpm_cdc_async_rst_n async_fifo_rst_n (
            .src_arst_n(fifo_rst_n),
            .dest_clk(pix_clk),
            .dest_arst_n(t_fifo_rst_n)
        );

    level2pulse #(  // FDMA写入一行完成标志
        .MODE("FALLING")
        ) FDMA_W_finish_flag (
        .clk    (clk),
        .rst_n  (rst_n),
        .in     (fifo_rst_n),
        .out    (fflag)
    );

    assign wbusy = fifo_rst_n;

endmodule