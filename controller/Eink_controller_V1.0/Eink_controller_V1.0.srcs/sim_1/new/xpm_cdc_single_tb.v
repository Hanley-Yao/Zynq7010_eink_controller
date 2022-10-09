`timescale 1ns / 1ps

module xpm_cdc_single_tb();

    reg     fast_clk;
    reg     slow_clk;
    reg     src_in;

    initial begin
        fast_clk = 0;
        forever #(2) fast_clk = ~fast_clk;
    end

    initial begin
        slow_clk = 0;
        forever #(10) slow_clk = ~slow_clk;  // 50Mhz
    end

    initial begin
       src_in = 0;
       repeat(100) @(posedge fast_clk);
       src_in = 1;
       repeat(19) @(posedge fast_clk);
       src_in = 0;
       repeat(1) @(posedge fast_clk);
       src_in = 1;
       repeat(27) @(posedge fast_clk);
       src_in = 0;
       repeat(100) @(posedge fast_clk);
       $stop;
    end

   // xpm_cdc_single: Single-bit Synchronizer
   // Xilinx Parameterized Macro, version 2020.2

   xpm_cdc_single #(
      .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(1), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_single_inst (

      .src_clk(fast_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(src_in),     // 1-bit input: Input signal to be synchronized to dest_clk domain.

      .dest_clk(slow_clk), // 1-bit input: Clock signal for the destination clock domain.
      .dest_out(dest_out)  // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.
   );

endmodule
