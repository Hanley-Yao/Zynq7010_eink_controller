
module ebaz4205_test(
    input wire  clk,
    input wire  rst_n,  // M20
    // DATA 1
    output wire H16,
    output wire B20,
    output wire D18,
    output wire D19,
    output wire E19,
    output wire K17,
    output wire A20,
    output wire B19,
    output wire C20,
    output wire H17,
    output wire D20,
    output wire H18,
    output wire F20,
    output wire F19,
    // DATA 2
    output wire J18,
    output wire H20,
    output wire J20,
    input  wire L20,
    output wire L17,
    output wire G20,
    output wire G19,
    output wire J19,
    output wire K18,
    output wire L16,
    output wire M18,
    // DATA 3
    output wire L19,
    output wire M17,
    output wire R19,
    output wire T20,
    output wire T19,
    output wire U19,
    output wire K19,
    output wire P18,
    output wire N17,
    output wire P20,
    output wire R18,
    output wire P19,
    output wire U20,
    output wire V20,
    // config
    inout wire  sda,  // N20
    output wire scl   // M19
    );

    iic_config #(
            .VCOM(1810),
            .SYS_CLK_FREQ(50),
            .SCL_FREQ(50)
        ) iic_config (
            .clk      (clk),
            .rst_n    (rst_n),
            .scl      (scl),
            .sda      (sda),
            .cfg_done (cfg_done)
        );

    assign H16 = clk;
    assign B20 = clk;
    assign D18 = clk;
    assign D19 = clk;
    assign E19 = clk;
    assign K17 = clk;
    assign A20 = clk;
    assign B19 = clk;
    assign C20 = clk;
    assign H17 = clk;
    assign D20 = clk;
    assign H18 = clk;
    assign F20 = clk;
    assign F19 = clk;
    assign J18 = clk;
    assign H20 = clk;
    assign J20 = clk;
    //assign L20 = clk;
    assign L17 = clk;
    assign G20 = clk;
    assign G19 = clk;
    assign J19 = clk;
    assign K18 = clk;
    assign L16 = L20;
    assign M18 = clk;
    assign L19 = L20;
    assign M17 = clk;
    assign R19 = clk;
    assign T20 = clk;
    assign T19 = clk;
    assign U19 = clk;
    assign K19 = 1;
    assign P18 = clk;
    assign N17 = clk;
    assign P20 = clk;
    assign R18 = clk;
    assign P19 = clk;
    assign U20 = clk;
    assign V20 = clk;

endmodule
