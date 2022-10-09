`timescale 1ns / 1ns

module fdma_clear_tb();

    parameter FDMA_WID      = 64;   // FDMA数据宽度
    parameter MAX_H         = 2208;
    parameter MAX_V         = 1872;
    parameter GRAY_0_ADDR_MEM_OFFSET    = 32'h1F500000;
    parameter GRAY_1_ADDR_MEM_OFFSET    = 32'h1F900000;
    parameter DATA_0_ADDR_MEM_OFFSET    = 32'h1FD00000;
    parameter DATA_1_ADDR_MEM_OFFSET    = 32'h1FE00000;

    reg                     clk;
    reg                     rst_n;
    reg                     clr_flag;  // 触发清除缓冲区
    wire    [31:0]          fdma_waddr;
    wire                    fdma_wareq;
    wire                    fdma_wbusy;
    wire    [FDMA_WID -1:0] fdma_wdata;
    wire                    fdma_wready;
    wire    [15:0]          fdma_wsize;
    wire                    fdma_wvalid;
    wire                    wbusy;
    wire                    fflag;

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end

    initial begin
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end

    initial begin  // 产生按钮信号
        clr_flag = 0;
        repeat(200) @(posedge clk);
        clr_flag = 1;
        repeat(5) @(posedge clk);
        clr_flag = 0;
    end


    fdma_clear #(
            .FDMA_WID(FDMA_WID),
            .MAX_H(MAX_H),
            .MAX_V(MAX_V),
            .GRAY_0_ADDR_MEM_OFFSET(GRAY_0_ADDR_MEM_OFFSET),
            .GRAY_1_ADDR_MEM_OFFSET(GRAY_1_ADDR_MEM_OFFSET),
            .DATA_0_ADDR_MEM_OFFSET(DATA_0_ADDR_MEM_OFFSET),
            .DATA_1_ADDR_MEM_OFFSET(DATA_1_ADDR_MEM_OFFSET)
        ) fdma_clear (
            .clk         (clk),
            .rst_n       (rst_n),
            .clr_flag    (clr_flag),
            .fdma_waddr  (fdma_waddr),
            .fdma_wareq  (fdma_wareq),
            .fdma_wbusy  (fdma_wbusy),
            .fdma_wdata  (fdma_wdata),
            .fdma_wready (fdma_wready),
            .fdma_wsize  (fdma_wsize),
            .fdma_wvalid (fdma_wvalid),
            .wbusy       (wbusy),
            .fflag       (fflag)
        );




    fdma_sim_slave #(
            .FDMA_WID(FDMA_WID)
        ) fdma_sim_slave (
            .clk         (clk),
            .rst_n       (rst_n),
            .fdma_waddr  (fdma_waddr),
            .fdma_wareq  (fdma_wareq),
            .fdma_wbusy  (fdma_wbusy),
            .fdma_wdata  (fdma_wdata),
            .fdma_wready (fdma_wready),
            .fdma_wsize  (fdma_wsize),
            .fdma_wvalid (fdma_wvalid),
            .fdma_raddr  (),
            .fdma_rareq  (),
            .fdma_rbusy  (),
            .fdma_rdata  (),
            .fdma_rready (),
            .fdma_rsize  (),
            .fdma_rvalid ()
        );

endmodule
