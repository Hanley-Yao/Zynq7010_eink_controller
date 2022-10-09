
`timescale 1ns / 1ps

module delay_cnt_tb();

    reg     clk;
    reg     rst_n;
    wire    rst_o;

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end

    initial begin
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end


    delay_cnt #(
            .NUM(32'h01FFFFF0)
        ) delay_cnt (
            .clk_i(clk),
            .rstn_i(rst_n),
            .rst_o(rst_o)
        );

endmodule
