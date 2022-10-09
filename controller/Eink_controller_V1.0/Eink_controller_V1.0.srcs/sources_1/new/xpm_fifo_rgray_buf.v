
//////////////////////////////////////////////////////////////////////////////////
//
//  INST_XPM_FIFO_SYNC
//
//////////////////////////////////////////////////////////////////////////////////

module xpm_fifo_rgray_buf#
    (
    parameter FDMA_WID = 64,  // FDMA数据宽度
    parameter FRAME_H  = 1920
    )
    (
    input wire clk,
    input wire rst_n,
    input wire [FDMA_WID -1:0] din,
    input wire wr_en,
    input wire rd_en,
    output wire [FDMA_WID -1:0] dout,
    output wire full,
    output wire empty
    );

    function integer depth (
        input integer width,  // 接口位宽
        input integer length,  // 数据长度
        input integer bpp      // 像素位数
        );
        for(depth=16; depth < ((length * bpp + width - 1) / width)*2; depth = depth*2) begin end  // 求最合适的写入深度
    endfunction

    localparam DEPTH = depth(FDMA_WID, FRAME_H, 8);

    // xpm_fifo_sync: Synchronous FIFO
    // Xilinx Parameterized Macro, version 2020.2

    xpm_fifo_sync #(
        .DOUT_RESET_VALUE("0"),
        .ECC_MODE("no_ecc"),
        .FIFO_MEMORY_TYPE("auto"),
        .FIFO_READ_LATENCY(0),
        .FIFO_WRITE_DEPTH(DEPTH),
        .FULL_RESET_VALUE(0),
        .PROG_EMPTY_THRESH(10),
        .PROG_FULL_THRESH(10),
        .RD_DATA_COUNT_WIDTH(1),
        .READ_DATA_WIDTH(FDMA_WID),
        .READ_MODE("fwft"),
        .SIM_ASSERT_CHK(0),
        .USE_ADV_FEATURES("0000"),
        .WAKEUP_TIME(0),
        .WRITE_DATA_WIDTH(FDMA_WID),
        .WR_DATA_COUNT_WIDTH(1)
    ) xpm_fifo_sync (
        .almost_empty(),
        .almost_full(),
        .data_valid(),
        .dbiterr(),
        .dout(dout),
        .empty(empty),
        .full(full),
        .overflow(),
        .prog_empty(),
        .prog_full(),
        .rd_data_count(),
        .rd_rst_busy(),
        .sbiterr(),
        .underflow(),
        .wr_ack(),
        .wr_data_count(),
        .wr_rst_busy(),
        .din(din),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rd_en(rd_en),
        .rst(~rst_n),
        .sleep(1'b0),
        .wr_clk(clk),
        .wr_en(wr_en)
    );

endmodule
