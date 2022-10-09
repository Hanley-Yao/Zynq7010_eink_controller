
//////////////////////////////////////////////////////////////////////////////////
//
//  这是个用于仿真的模块
//  由于AXI FDMA仿真不太正常...所以设计了这个测试用的模块,其只响应写入读出并不储存数据
//
//////////////////////////////////////////////////////////////////////////////////

module fdma_sim_slave#(
    parameter FDMA_WID = 64  // 输入数据宽度
    )
    (
    input wire                      clk,
    input wire                      rst_n,

    input wire  [31:0]              fdma_waddr,     // 写地址
    input wire                      fdma_wareq,     // 写请求
    output reg                      fdma_wbusy,     // 写就绪
    input wire  [FDMA_WID - 1:0]    fdma_wdata,     // 写数据
    input wire                      fdma_wready,    // 写控制器就绪
    input wire  [15:0]              fdma_wsize,     // 写大小
    output reg                      fdma_wvalid,    // 写有效

    input wire  [31: 0]             fdma_raddr,     // 读地址
    input wire                      fdma_rareq,     // 读请求
    output reg                      fdma_rbusy,     // 读就绪
    output reg  [FDMA_WID - 1:0]    fdma_rdata,     // 读数据
    input wire                      fdma_rready,    // 读控制器就绪
    input wire  [15: 0]             fdma_rsize,     // 读大小
    output reg                      fdma_rvalid     // 读有效
    );

    // ----------WRITE----------

    reg [15:0] write_cnt;  // 写有效计数器
    reg [1:0]  WRITE_STATE;

    localparam WRITE_IDEL   = 2'b00;
    localparam WRITE_STATE1 = 2'b01;
    localparam WRITE_STATE2 = 2'b11;
    localparam WRITE_STATE3 = 2'b10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            write_cnt <= 0;
            fdma_wbusy <= 0;
            fdma_wvalid <= 0;
        end
        else begin

            case(WRITE_STATE)

                WRITE_IDEL:begin  // 等待写请求
                    if (fdma_wareq) begin
                        WRITE_STATE <= WRITE_STATE1;
                    end
                    else begin
                        WRITE_STATE <= WRITE_IDEL;
                    end
                end

                WRITE_STATE1:begin  // 开始写
                    fdma_wbusy <= 1;
                    WRITE_STATE <= WRITE_STATE2;
                end

                WRITE_STATE2:begin  // 有效数据计数器
                    if (write_cnt < fdma_wsize) begin
                        write_cnt <= write_cnt + 1;
                        fdma_wvalid <= 1;
                        WRITE_STATE <= WRITE_STATE2;
                    end
                    else begin
                        write_cnt <= 0;
                        fdma_wvalid <= 0;
                        WRITE_STATE <= WRITE_STATE3;
                    end
                end

                WRITE_STATE3:begin  // 写结束
                    fdma_wbusy <= 0;
                    WRITE_STATE <= WRITE_IDEL;
                end

                default:begin
                    WRITE_STATE <= WRITE_IDEL;
                end

            endcase

        end
    end

    // ----------READ----------

    reg [15:0] read_cnt;  // 写有效计数器
    reg [1:0]  READ_STATE;

    localparam READ_IDEL   = 2'b00;
    localparam READ_STATE1 = 2'b01;
    localparam READ_STATE2 = 2'b11;
    localparam READ_STATE3 = 2'b10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            read_cnt <= 0;
            fdma_rbusy <= 0;
            fdma_rdata <= 0;
            fdma_rvalid <= 0;
        end
        else begin

            case(READ_STATE)

                READ_IDEL:begin  // 等待读请求
                    if (fdma_rareq) begin
                        READ_STATE <= READ_STATE1;
                    end
                    else begin
                        READ_STATE <= READ_IDEL;
                    end
                end

                READ_STATE1:begin  // 开始读
                    fdma_rbusy <= 1;
                    READ_STATE <= READ_STATE2;
                end

                READ_STATE2:begin  // 有效数据计数器
                    if (read_cnt < fdma_rsize) begin
                        read_cnt <= read_cnt + 1;
                        fdma_rvalid <= 1;
                        fdma_rdata <= {8{{$random}%8'd255}};
                        READ_STATE <= READ_STATE2;
                    end
                    else begin
                        read_cnt <= 0;
                        fdma_rvalid <= 0;
                        fdma_rdata <= 0;
                        READ_STATE <= READ_STATE3;
                    end
                end

                READ_STATE3:begin  // 读结束
                    fdma_rbusy <= 0;
                    READ_STATE <= READ_IDEL;
                end

                default:begin
                    READ_STATE <= READ_IDEL;
                end

            endcase

        end
    end


endmodule
