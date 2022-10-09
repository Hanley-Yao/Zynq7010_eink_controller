`timescale 1ns / 1ps

module v_algo_tb();

    reg             clk;
    reg             rst_n;
    reg             algo_de;
    reg     [7:0]   newFrame;
    reg     [7:0]   oldFrame;
    reg     [7:0]   texture;
    wire            valid_n;  // 低有效
    wire    [1:0]   data;      // 数据输出

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end

    initial begin
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end

    initial begin
        algo_de <= 1;
        newFrame = 8'd127;
        oldFrame = 8'd255;
        texture = 8'd0;
        repeat(200) @(posedge clk);
        forever #(20) texture = texture + 1;  // 50Mhz
    end



    v_algo v_algo
        (
            .clk      (clk),
            .rst_n    (rst_n),
            .algo_de  (algo_de),
            .newFrame (newFrame),
            .oldFrame (oldFrame),
            .texture  (texture),
            .valid_n  (valid_n),
            .data     (data)
        );

endmodule
