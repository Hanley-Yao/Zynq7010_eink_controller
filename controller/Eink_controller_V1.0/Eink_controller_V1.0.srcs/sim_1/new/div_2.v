
module div_2(
    input wire clk,
    input wire rst_n,
    output reg q
    );

    always @ (posedge clk or negedge rst_n)
        if (!rst_n)
            q<=1'b0; // 复位置零
        else
            q<=~q; // 否则q信号翻转

endmodule
