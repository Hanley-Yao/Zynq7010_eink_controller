`timescale 1ns / 1ps

module iic_config_tb();

    reg     clk;
    reg     rst_n;
    wire    scl;
    wire    sda;
    wire    cfg_done;

    initial begin
        clk = 0;
        forever #(10) clk = ~clk;  // 50Mhz
    end

    initial begin
        rst_n = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;
    end

    iic_config #(
            .VCOM(2780),
            .SYS_CLK_FREQ(50),
            .SCL_FREQ(100)
        ) inst_iic_config (
            .clk       (clk),
            .rst_n     (rst_n),
            .scl       (scl),
            .sda       (sda),
            .REG_INDEX (REG_INDEX),
            .REG_DATA  (REG_DATA),
            .REG_SIZE  (REG_SIZE),
            .cfg_done  (cfg_done)
        );


    config_reg #(
            .VCOM(2780)
        ) config_reg (
            .REG_INDEX(REG_INDEX),
            .REG_DATA(REG_DATA),
            .REG_SIZE(REG_SIZE)
        );

    EEPROM_AT24C64_SIM EEPROM_AT24C64_SIM (.scl(scl), .sda(sda));  // 用于写入测试

endmodule