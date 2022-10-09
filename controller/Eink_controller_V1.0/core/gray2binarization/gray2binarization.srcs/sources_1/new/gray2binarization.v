
module gray2binarization
    #(
    parameter Threshold  = 8'd127 )  // 灰度阈值
    (
    input wire          pix_clk,
    input wire          gray_de,  // Gray数据同步信号
    input wire          gray_hs,
    input wire          gray_vs,
    input wire  [23:0]  gray_data,
    output reg          binary_de,
    output reg          binary_hs,
    output reg          binary_vs,  // Binary数据同步信号
    output reg  [23:0]  binary_data
    );

    // 建立LUT表

    reg [7:0] Threshold_LUT [0:255];
    reg [7:0] i;

    initial begin
        for (i = 0; i < 8'd255; i = i + 1) begin
            if (i < Threshold) begin
                Threshold_LUT[i] = 0;
            end
            else begin
                Threshold_LUT[i] = 8'd255;
            end
        end
    end

    always @(posedge pix_clk) begin
        binary_data[7:0]   <= Threshold_LUT[gray_data[7:0]];
        binary_data[15:8]  <= Threshold_LUT[gray_data[7:0]];
        binary_data[23:16] <= Threshold_LUT[gray_data[7:0]];
    end

    always @(posedge pix_clk) begin
        binary_de <= gray_de;
        binary_hs <= gray_hs;
        binary_vs <= gray_vs;
    end

endmodule
