
//////////////////////////////////////////////////////////////////////////////////
//
//  这个模块用异步输入信号的脉冲宽度小于时钟周期时的同步电路（高速时钟域→低速时钟域）
//
//////////////////////////////////////////////////////////////////////////////////

module sync_h2lck (
    input wire  in_clk,
    input wire  out_clk,

    input wire  rst_n,

    input wire  level_in,

    output wire pulse_out
    );

   // xpm_cdc_pulse: Pulse Transfer
   // Xilinx Parameterized Macro, version 2020.2

    xpm_cdc_pulse #(
        .DEST_SYNC_FF(10),
        .INIT_SYNC_FF(1),
        .REG_OUTPUT(1),
        .RST_USED(1),
        .SIM_ASSERT_CHK(0)
    ) xpm_cdc_pulse (

        .src_clk(in_clk),
        .src_rst(~rst_n),
        .src_pulse(level_in),

        .dest_clk(out_clk),
        .dest_rst(0),
        .dest_pulse(pulse_out)
    );

endmodule