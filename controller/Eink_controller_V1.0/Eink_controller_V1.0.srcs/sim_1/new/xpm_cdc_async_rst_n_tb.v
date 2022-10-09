
`timescale 1ns / 1ps

module xpm_cdc_async_rst_n_tb();

    reg     slow_clk;
    reg     fast_clk;
    reg     rst_n;
    wire    dest_arst_n;

    initial begin
        slow_clk = 0;
        forever #(10) slow_clk = ~slow_clk;  // 50Mhz
    end

    initial begin
        fast_clk = 0;
        forever #(3) fast_clk = ~fast_clk;
    end

    initial begin
        rst_n = 0;
        repeat(100) @(posedge slow_clk);
        rst_n = 1;
        repeat(1000) @(posedge slow_clk);
        rst_n = 0;
        repeat(10) @(posedge slow_clk);
        rst_n = 1;
    end

    xpm_cdc_async_rst_n inst_xpm_cdc_async_rst_n (.src_arst_n(rst_n), .dest_clk(fast_clk), .dest_arst_n(dest_arst_n));

endmodule
