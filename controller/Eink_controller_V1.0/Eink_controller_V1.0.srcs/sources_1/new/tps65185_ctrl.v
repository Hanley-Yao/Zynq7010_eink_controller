
module tps65185_ctrl
    (
    input wire          clk,
    input wire          rst_n,
    input wire          epd_busy,   // EPD状态监视
    input wire          epd_pwr_sw,     // 高电平启动电源输出
    input wire          pwr_good,   // 高电平电源输出就绪
    output reg          epd_pwr_en    // 唤醒信号(高有效),把这个信号拉高唤醒电源
    );

    assign wake_up = 1;


    reg [3:0] PWR_STATE;

    localparam PWR_IDEL   = 0;
    localparam PWR_STATE1 = 1;
    localparam PWR_STATE2 = 2;
    localparam PWR_STATE3 = 3;
    localparam PWR_DONE   = 4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            epd_pwr_en <= 0;
            PWR_STATE <= 0;
        end
        else begin
            case(PWR_STATE)

                PWR_IDEL:begin
                    if (epd_pwr_sw) begin
                        PWR_STATE <= PWR_STATE1;
                    end
                end

                PWR_STATE1:begin  // 等待屏幕空闲开始上电
                    if (!epd_busy) begin
                        epd_pwr_en <= 1;
                        PWR_STATE <= PWR_STATE2;
                    end
                end

                PWR_STATE2:begin  // 下电时序
                    if (!epd_pwr_sw) begin
                        PWR_STATE <= PWR_STATE3;
                    end
                end

                PWR_STATE3:begin  // 等待屏幕空闲开始下电
                    if (!epd_busy) begin
                        epd_pwr_en <= 0;
                        PWR_STATE <= PWR_DONE;
                    end
                end

                PWR_DONE:begin
                    PWR_STATE <= PWR_IDEL;
                end

                default:begin
                    PWR_STATE <= PWR_IDEL;
                end

            endcase
        end
    end


endmodule


