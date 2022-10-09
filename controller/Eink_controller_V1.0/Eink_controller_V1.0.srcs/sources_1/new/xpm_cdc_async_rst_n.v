
module xpm_cdc_async_rst_n(
    input wire src_arst_n,
    input wire dest_clk,
    output wire dest_arst_n
    );

   // xpm_cdc_async_rst: Asynchronous Reset Synchronizer
   // Xilinx Parameterized Macro, version 2020.2

   xpm_cdc_async_rst #(
      .DEST_SYNC_FF(4),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
   )
   xpm_cdc_async_rst_inst (
      .dest_arst(dest_arst_n), // 1-bit output: src_arst asynchronous reset signal synchronized to destination
                               // clock domain. This output is registered. NOTE: Signal asserts asynchronously
                               // but deasserts synchronously to dest_clk. Width of the reset signal is at least
                               // (DEST_SYNC_FF*dest_clk) period.

      .dest_clk(dest_clk),     // 1-bit input: Destination clock.
      .src_arst(src_arst_n)    // 1-bit input: Source asynchronous reset signal.
   );


endmodule
