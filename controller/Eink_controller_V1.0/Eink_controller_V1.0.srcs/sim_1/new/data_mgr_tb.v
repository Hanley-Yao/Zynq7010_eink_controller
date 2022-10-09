`timescale 1ns / 1ps

module data_mgr_tb();

    parameter IN_WID    = 64;
    parameter OUT_WID   = 16;

    reg clk;
    reg rst_n;
    reg [IN_WID -1:0] din;
    wire [OUT_WID -1:0] dout;
    reg data_ren;

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end

    initial begin
        rst_n = 0;
        repeat(40) @(posedge clk);
        rst_n = 1;
    end

    initial begin
        din = 0;
        data_ren = 0;
        repeat(80) @(posedge clk);
        din = {8'd8,8'd16,8'd24,8'd36,8'd40,8'd48,8'd56,8'd64};
        repeat(80) @(posedge clk);
        data_ren = 1;
        repeat(80) @(posedge clk);
        data_ren = 0;
    end

    data_mgr #(
            .IN_WID(IN_WID),
            .OUT_WID(OUT_WID)
        ) inst_data_mgr (
            .clk      (clk),
            .rst_n    (rst_n),
            .fifo_ren (fifo_ren),
            .din      (din),
            .data_ren (data_ren),
            .dout     (dout)
        );


endmodule
