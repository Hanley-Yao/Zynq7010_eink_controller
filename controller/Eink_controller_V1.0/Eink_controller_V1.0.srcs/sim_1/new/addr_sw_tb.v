`timescale 1ns / 1ps

module addr_sw_tb();

    reg             clk;
    reg             rst_n;

    reg             sw;
    wire    [31:0]  data_w_addr;
    wire    [31:0]  data_r_addr;

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
        sw = 0;
        repeat(200) @(posedge clk);
        sw = 1;
        repeat(10) @(posedge clk);
        sw = 0;
    end

    addr_sw #(  // 驱动数据地址转换器
            .ADDR_0         ({32{0}}),
            .ADDR_1         ({32{1}})
        ) addr_sw_wdata (
            .clk            (clk),
            .rst_n          (rst_n),  // 清除缓冲区时复位地址指针
            .sw             (sw),  // 切地址信号
            .new_addr       (data_w_addr),
            .old_addr       (data_r_addr)
        );

endmodule
