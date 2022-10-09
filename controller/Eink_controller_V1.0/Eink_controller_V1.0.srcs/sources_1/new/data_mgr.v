
//////////////////////////////////////////////////////////////////////////////////
//
//  这是一个并行数据管理器,用于自动请求FIFO中的数据并转换成所需位宽
//
//////////////////////////////////////////////////////////////////////////////////

module data_mgr#
    (
    parameter IN_WID    = 64,  // FDMA数据宽度
    parameter OUT_WID   = 8   // 屏幕数据宽度
    )
    (
    input wire                      clk,
    input wire                      rst_n,
    output wire                     fifo_ren,  // 使能FIFO输出数据
    input wire  [IN_WID - 1:0]      din,
    input wire                      data_ren,  // 使能data_mgr输出数据
    output wire [OUT_WID - 1:0]     dout
    );

    reg [4:0]   DATA_CNT;

    initial begin
        DATA_CNT = IN_WID / OUT_WID;  // 读一次FIFO有几个驱动数据
    end

    reg [4:0]               data_cnt;
    reg [IN_WID - 1:0]    t_din;  // 移位

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            t_din <= 0;
            data_cnt <= 0;
        end
        else if (data_ren) begin
            if (data_cnt < DATA_CNT - 1) begin
                data_cnt   <= data_cnt + 1;
                t_din      <= {t_din[IN_WID -1: 2*OUT_WID], t_din[2*OUT_WID -1: OUT_WID]};
            end
            else begin
                t_din <= din;
                data_cnt <= 0;
            end
        end
        else begin
            t_din <= din;
            data_cnt <= 0;
        end

    end

    wire sw_line;
    reg fifo_rflag;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            fifo_rflag <= 0;
        end
        else if (data_cnt == DATA_CNT - 1) begin
            fifo_rflag <= 1;
        end
        else begin
            fifo_rflag <= 0;
        end
    end

    // 开始读(data_ren Low -> High)说明开始读取一行
    level2pulse #(
            .MODE("RISING")
        ) newline_flag (
            .clk(clk),
            .rst_n(rst_n),
            .in(data_ren),
            .out(sw_line)
        );

    assign fifo_ren = (data_ren) ? (fifo_rflag || sw_line) : 0;

    assign dout = t_din[OUT_WID - 1:0];  // 截取驱动数据

endmodule