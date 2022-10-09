
///////////////////////////////////////////////////////////////////
// 模块改编于[ https://github.com/vipinkmenon/rgb2gray ]侵权请告知 //
///////////////////////////////////////////////////////////////////

module rgb2gray(
    input wire          pix_clk,
    input wire          rgb_de,  // RGB数据同步信号
    input wire          rgb_hs,
    input wire          rgb_vs,
    input wire  [23:0]  rgb_data,
    output reg          gray_de,
    output reg          gray_hs,
    output reg          gray_vs,  // Gray数据同步信号
    output reg  [23:0]  gray_data
    );

    wire    [7:0]   w_red;
    wire    [7:0]   w_green;
    wire    [7:0]   w_blue;

    assign w_red   = rgb_data[7:0];
    assign w_green = rgb_data[15:8];
    assign w_blue  = rgb_data[23:16];

    always @(posedge pix_clk) begin
        //gray_data[7:0]   <= (w_red>>2)+(w_red>>5)+(w_green>>1)+(w_green>>4)+(w_blue>>4)+(w_blue>>5);
        //gray_data[15:8]  <= (w_red>>2)+(w_red>>5)+(w_green>>1)+(w_green>>4)+(w_blue>>4)+(w_blue>>5);
        //gray_data[23:16] <= (w_red>>2)+(w_red>>5)+(w_green>>1)+(w_green>>4)+(w_blue>>4)+(w_blue>>5);
        gray_data[7:0]   <= (w_red * 313524 + w_blue * 119538 + w_green * 615514) >> 20;
        gray_data[15:8]  <= (w_red * 313524 + w_blue * 119538 + w_green * 615514) >> 20;
        gray_data[23:16] <= (w_red * 313524 + w_blue * 119538 + w_green * 615514) >> 20;
    end

    always @(posedge pix_clk) begin
        gray_de <= rgb_de;
        gray_hs <= rgb_hs;
        gray_vs <= rgb_vs;
    end

endmodule