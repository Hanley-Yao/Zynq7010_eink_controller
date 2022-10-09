
`timescale 1ns / 1ps

module sync_h2lck_tb();

    reg     in_clk;
    reg     out_clk;
    reg     rst_n;
    reg     level_in;
    wire    pulse_out;

    initial begin
        in_clk = 0;
        forever #(3) in_clk = ~in_clk;  // 50Mhz
    end

    initial begin
        out_clk = 0;
        forever #(10) out_clk = ~out_clk;  // 50Mhz
    end

    initial begin
        rst_n = 0;
        repeat(100) @(posedge in_clk);
        rst_n = 1;
    end

    initial begin
        level_in = 0;
        repeat(500) @(posedge in_clk);

        level_in = 1;
        repeat(1) @(posedge in_clk);
        level_in = 0;

        repeat(1000) @(posedge in_clk);

        level_in = 1;
        repeat(20) @(posedge in_clk);
        level_in = 0;


        repeat(1000) @(posedge in_clk);

        level_in = 1;
        repeat(2) @(posedge in_clk);
        level_in = 0;

        repeat(1000) @(posedge in_clk);

        level_in = 1;
        repeat(1) @(posedge in_clk);
        level_in = 0;

        repeat(1000) @(posedge in_clk);

        level_in = 1;
        repeat(1) @(posedge in_clk);
        level_in = 0;

        repeat(1000) @(posedge in_clk);

        level_in = 1;
        repeat(1) @(posedge in_clk);
        level_in = 0;

        repeat(1000) @(posedge in_clk);

        $stop;
    end

    sync_h2lck inst_sync_h2lck
        (
            .in_clk    (in_clk),
            .out_clk   (out_clk),
            .rst_n     (rst_n),
            .level_in  (level_in),
            .pulse_out (pulse_out)
        );

endmodule