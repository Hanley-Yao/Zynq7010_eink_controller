
module level2pulse(
    input wire clk,
    input wire rst_n,
    input wire in,
    output reg out
    );

    parameter MODE = "BOTH";  // 模式选择

    reg temp_out;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_out <= 0;
        end
        else begin
            temp_out <= in;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out <= 0;
        end
        else if (MODE == "BOTH") begin // BOTH:上升下降都会生成脉冲
            out = temp_out ^ in;
        end
        else if (MODE == "RISING") begin // RISING:上升会生成脉冲
            out = ~temp_out & in;
        end
        else if (MODE == "FALLING") begin // FALLING:下降会生成脉冲
            out = temp_out & ~in;
        end
    end
endmodule
