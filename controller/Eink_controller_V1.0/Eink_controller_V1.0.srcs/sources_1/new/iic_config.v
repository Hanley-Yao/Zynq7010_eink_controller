
//////////////////////////////////////////////////////////////////////////////////
//
//  这个模块用于批量配置外部IIC寄存器
//
//////////////////////////////////////////////////////////////////////////////////


module iic_config #(
    parameter VCOM         = 2780,
    parameter SYS_CLK_FREQ = 50,
    parameter SCL_FREQ     = 100
    )
    (
    input wire          clk,
    input wire          rst_n,
    output wire         scl,
    inout wire          sda,

    output reg  [8 :0]  REG_INDEX,
    input wire  [39:0]  REG_DATA,
    input wire  [8 :0]  REG_SIZE,

    output reg          cfg_done
    );

    //reset counter for delay time
    reg  [8 :0] rst_cnt = 9'd0;
    always@(posedge clk) begin
        if(!rst_n)
            rst_cnt <= 9'd0;
        else if(!rst_cnt[8])
            rst_cnt <= rst_cnt + 1'b1;
    end

    reg  iic_en;
    wire iic_busy;
    reg  [31:0] wr_data;
    reg  [7: 0] wr_len;
    reg  [1 :0] TS_S;

    //state machine write one byte and then read one byte
    always@(posedge clk) begin
        if(!rst_cnt[8])begin
            REG_INDEX<= 9'd0;
            iic_en  <= 1'b0;
            wr_data <= 32'd0;
            cfg_done<= 1'b0;
            TS_S    <= 2'd0;
        end
        else begin
            case(TS_S)
            0:if(cfg_done == 1'b0)
                TS_S <= 2'd1;
            1:if(!iic_busy)begin//write data
                iic_en  <= 1'b1;
                wr_len [7:0]   <= REG_DATA[39:32];
                wr_data[7:0]   <= REG_DATA[31:24];
                wr_data[15:8]  <= REG_DATA[23:16];
                wr_data[23:16] <= REG_DATA[15:8];
                wr_data[31:24] <= REG_DATA[7:0];
            end
            else
                TS_S    <= 2'd2;
            2:begin
                iic_en  <= 1'b0;
                if(!iic_busy)begin
                REG_INDEX<= REG_INDEX + 1'b1;
                TS_S    <= 2'd3;
                end
            end
            3:begin//read rtc register
                if(REG_INDEX == REG_SIZE)begin
                    cfg_done <= 1'b1;
                end
                TS_S    <= 2'd0;
            end
        endcase
       end
    end

    i2c_top#(
            .WMEN_LEN(4),
            .RMEN_LEN(1),
            .SYS_CLK_FREQ(SYS_CLK_FREQ),
            .SCL_FREQ(SCL_FREQ)
        )iic_ctrl(
            .clk_i(clk),
            .rst_n(rst_n),
            .iic_scl(scl),
            .iic_sda(sda),
            .wr_data(wr_data),
            .wr_cnt(wr_len),  //write data max len = 4BYTES
            .rd_data(),       //read not used
            .rd_cnt(8'd0),    //read not used
            .iic_mode(1'b0),
            .iic_en(iic_en),
            .iic_busy(iic_busy)
        );

endmodule
