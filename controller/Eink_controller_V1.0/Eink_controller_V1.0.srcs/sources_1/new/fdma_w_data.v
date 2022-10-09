
//////////////////////////////////////////////////////////////////////////////////
//
//  这个模块可以将处理后的图像数据写入指定的DDR缓冲区
//  按照约定行最宽2200
//  一个缓冲区划分DDR大小1MB
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
//  当所需的三行数据缓冲区都非空的时候开始图像处理并写入FIFO,处理完成后FIFO数据写入DDR
//
//////////////////////////////////////////////////////////////////////////////////

module fdma_w_data#
    (
    parameter FDMA_WID   = 64,  // FDMA数据宽度
    parameter MAX_H      = 2208,
    parameter FRAME_H    = 1920,
    parameter FRAME_V    = 1080
    )
    (
    input wire                      clk,
    input wire                      rst_n,

    input wire                      newFrame_fifo_empty,
    input wire                      oldFrame_fifo_empty,
    input wire                      texture_fifo_empty,

    output reg                      gray_ren,

    input wire [FDMA_WID - 1:0]     newFrame,
    input wire [FDMA_WID - 1:0]     oldFrame,
    input wire [FDMA_WID - 1:0]     texture,

    input wire  [31:0]              buf_addr,       // 帧缓存区起始地址

    output reg  [31:0]              fdma_waddr,     // 写地址
    output reg                      fdma_wareq,     // 写请求
    input  wire                     fdma_wbusy,     // 写就绪
    output wire [FDMA_WID - 1:0]    fdma_wdata,     // 写数据
    output wire                     fdma_wready,    // 写控制器就绪
    output wire [15:0]              fdma_wsize,     // 写大小
    input  wire                     fdma_wvalid,    // 写有效

    output wire                     wbusy,          // 写入忙
    output wire                     fflag           // 行写入完成
    );

    reg [8:0]                   FDMA_BURST_LEN;
    reg [11:0]                  W_PKG_CNT;
    reg [11:0]                  R_PKG_CNT;

    wire    [FDMA_WID/4 -1:0]   data;       // 组合数据
    wire    [FDMA_WID/8 -1:0]   valid_n;    // 全低有效
    wire                        valid;
    wire                        ready;
    wire                        algo_de;

    initial begin
        FDMA_BURST_LEN = ((FRAME_H * 2) + FDMA_WID - 1) / FDMA_WID;   // FDMA写入长度
        W_PKG_CNT      = FDMA_BURST_LEN * 4;                // 写一整行
        R_PKG_CNT      = ((FRAME_H * 8) + FDMA_WID - 1) / FDMA_WID;   // 读一整行
    end

    assign fdma_wready = 1;
    assign fdma_wsize  = FDMA_BURST_LEN;

    assign ready = ~newFrame_fifo_empty & ~oldFrame_fifo_empty & ~texture_fifo_empty;  // 等待三缓冲行非空

    reg [2:0] EN_STATE;

    reg [11:0] en_delay_cnt;
    reg [11:0] r_pkg_cnt;

    localparam EN_DELAY_CNT = 128;  // 当三个FIFO都有数据后延迟一定周期再进行处理能有效消除抖动

    localparam EN_IDEL   = 2'b00;
    localparam EN_STATE1 = 2'b01;
    localparam EN_STATE2 = 2'b10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            EN_STATE     <= 0;
            en_delay_cnt <= 0;
            r_pkg_cnt    <= 0;
            gray_ren     <= 0;
        end
        else begin

            case(EN_STATE)  // 等待FIFO就绪

                EN_IDEL:begin
                    if (ready) begin
                        EN_STATE     <= EN_STATE1;
                    end
                    else begin
                        EN_STATE     <= EN_STATE;
                    end
                end

                EN_STATE1:begin  // 延迟
                    if (en_delay_cnt < EN_DELAY_CNT) begin
                        en_delay_cnt <= en_delay_cnt + 1;
                        EN_STATE     <= EN_STATE1;
                    end
                    else begin
                        en_delay_cnt <= 0;
                        EN_STATE     <= EN_STATE2;
                    end
                end

                EN_STATE2:begin  // 读取一整行
                    if (r_pkg_cnt < R_PKG_CNT) begin
                        r_pkg_cnt    <= r_pkg_cnt + 1;
                        gray_ren     <= 1;
                        EN_STATE     <= EN_STATE2;
                    end
                    else begin
                        r_pkg_cnt    <= 0;
                        gray_ren     <= 0;
                        EN_STATE     <= EN_IDEL;
                    end
                end

                default:begin
                    EN_STATE         <= EN_IDEL;
                end

            endcase
        end
    end

    assign algo_de = gray_ren;  // 使能图像处理器

    // Generate block 建立并行图像处理核心
    genvar i;
    generate
        for(i=0; i < FDMA_WID / 8; i=i+1) begin:ALGO
            v_algo core(
                .clk        (clk),
                .rst_n      (rst_n),
                .algo_de    (algo_de),
                .newFrame   (newFrame[8*(i+1)-1:8*i]),
                .oldFrame   (oldFrame[8*(i+1)-1:8*i]),
                .texture    (texture[8*(i+1)-1:8*i]),
                .valid_n    (valid_n[i]),
                .data       (data[2*(i+1)-1:2*i])
            );
        end
    endgenerate

    assign valid = valid_n ? 0:1;  // 等待全部有效,理论上没啥影响不过保险起见

    reg                     PKG_STATE;
    reg [11:0]              w_pkg_cnt;
    reg [FDMA_WID/4 -1:0]   t_data;
    reg [FDMA_WID/4 -1:0]   tt_data;
    reg                     wr_en;
    wire                    aflag;  // 处理完成信号

    localparam PKG_IDEL   = 1'b0;
    localparam PKG_STATE1 = 1'b1;

    always @(posedge clk) begin  // 延迟两个时钟周期
        t_data  <= data;
        tt_data <= t_data;
    end

    always @(posedge clk or negedge rst_n) begin  // 写入块
        if (!rst_n) begin
            // reset
            PKG_STATE <= 0;
            w_pkg_cnt <= 0;
            wr_en     <= 0;
        end
        else begin

            case(PKG_STATE)

                PKG_IDEL:begin
                    if (valid) begin
                        PKG_STATE <= PKG_STATE1;
                    end
                    else begin
                        PKG_STATE <= PKG_IDEL;
                    end
                end

                PKG_STATE1:begin  // 保持块使能
                    if (w_pkg_cnt < W_PKG_CNT) begin
                        w_pkg_cnt <= w_pkg_cnt + 1;
                        wr_en     <= 1;
                        PKG_STATE <= PKG_STATE1;
                    end
                    else begin
                        w_pkg_cnt <= 0;
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

    level2pulse #(  // FIFO储存一行完成标志
        .MODE("FALLING")
        ) FIFO_W_finish_flag (
        .clk    (clk),
        .rst_n  (rst_n),
        .in     (wr_en),
        .out    (aflag)
    );

    xpm_fifo_wdata_buf #(  // 储存下处理完成的行
        .FDMA_WID(FDMA_WID),
        .FRAME_H(FRAME_H)
        ) fifo_wdata_buf (
        .clk   (clk),
        .rst_n (rst_n),
        .din   (tt_data),
        .wr_en (wr_en),
        .rd_en (fdma_wvalid),
        .dout  (fdma_wdata),
        .full  (),
        .empty ()
    );

    reg [1:0]   WRITE_STATE;
    reg [31:0]  v_cnt;

    localparam WRITE_IDEL   = 3'b00;  // 等待开始信号
    localparam WRITE_STATE1 = 3'b01;  // 计算行写入起始地址
    localparam WRITE_STATE2 = 3'b10;  // FDMA写入

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            WRITE_STATE <= 0;
            v_cnt       <= 0;
            fdma_waddr  <= 0;
            fdma_wareq  <= 0;
        end
        else begin

            case(WRITE_STATE)

                WRITE_IDEL:begin  // 等待开始信号
                    if (aflag) begin
                        WRITE_STATE <= WRITE_STATE1;
                    end
                    else begin
                        WRITE_STATE <= WRITE_IDEL;
                    end
                end

                WRITE_STATE1:begin  // 计算行写入起始地址
                    if (v_cnt < FRAME_V) begin
                        v_cnt       <= v_cnt + 1;
                        fdma_waddr  <= buf_addr + v_cnt * MAX_H / 4;  // 一个驱动数据2bit则一个地址可存4个驱动数据
                        WRITE_STATE <= WRITE_STATE2;
                    end
                    else begin
                        v_cnt       <= 0;
                        WRITE_STATE <= WRITE_STATE1;
                    end
                end

                WRITE_STATE2:begin  // FDMA写入
                    if(!fdma_wbusy)begin
                        fdma_wareq  <= 1'b1;
                    end
                    if(fdma_wareq&&fdma_wbusy)begin
                        fdma_wareq  <= 1'b0;
                        WRITE_STATE <= WRITE_IDEL;
                    end
                end

                default:begin
                    WRITE_STATE     <= WRITE_IDEL;
                end

            endcase

        end
    end

    assign wbusy = fdma_wbusy;  // FDMA写就绪则写入忙

    level2pulse #(  // FDMA写入一行完成标志
        .MODE("FALLING")
        ) FDMA_W_finish_flag (
        .clk    (clk),
        .rst_n  (rst_n),
        .in     (wbusy),
        .out    (fflag)
    );

endmodule