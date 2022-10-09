
//////////////////////////////////////////////////////////////////////////////////
//
//  这个模块采用瞎写的流水线结构实现RGB转GRAY图像避免输入时钟过快导致的时序问题
//
//////////////////////////////////////////////////////////////////////////////////

module rgb2gray#(
    parameter ACCURACY_NUM = 10  // 精度调整
    )(
    input wire          pix_clk,
    input wire          rgb_de,  // RGB数据同步信号
    input wire          rgb_hs,
    input wire          rgb_vs,
    input wire  [23:0]  rgb_data,
    output reg          gray_de,
    output reg          gray_hs,
    output reg          gray_vs,  // Gray数据同步信号
    output wire [23:0]  gray_data
    );

    reg  [7:0] gray_data_r;
    wire [7:0] w_red;
    wire [7:0] w_green;
    wire [7:0] w_blue;
    reg  [26:0] t_red;
    reg  [24:0] t_blue;
    reg  [27:0] t_green;

    assign w_red   = rgb_data[7:0];
    assign w_green = rgb_data[15:8];
    assign w_blue  = rgb_data[23:16];

    always @(posedge pix_clk) begin
        case(ACCURACY_NUM)
            0:begin
                t_red   <= w_red   * 30;
                t_blue  <= w_green * 11;
                t_green <= w_blue  * 59+50;
            end
            1:begin
                t_red   <= w_red   * 30;
                t_blue  <= w_green * 11;
                t_green <= w_blue  * 59+50;
            end
            2:begin
                t_red   <= w_red   * 1;
                t_blue  <= w_green * 1;
                t_green <= w_blue  * 2;
            end
            3:begin
                t_red   <= w_red   * 2;
                t_blue  <= w_green * 1;
                t_green <= w_blue  * 5;
            end
            4:begin
                t_red   <= w_red   * 4;
                t_blue  <= w_green * 2;
                t_green <= w_blue  * 10;
            end
            5:begin
                t_red   <= w_red   * 9;
                t_blue  <= w_green * 4;
                t_green <= w_blue  * 19;
            end
            6:begin
                t_red   <= w_red   * 19;
                t_blue  <= w_green * 8;
                t_green <= w_blue  * 37;
            end
            7:begin
                t_red   <= w_red   * 38;
                t_blue  <= w_green * 15;
                t_green <= w_blue  * 75;
            end
            8:begin
                t_red   <= w_red   * 76;
                t_blue  <= w_green * 30;
                t_green <= w_blue  * 150;
            end
            9:begin
                t_red   <= w_red   * 153;
                t_blue  <= w_green * 59;
                t_green <= w_blue  * 300;
            end
            10:begin
                t_red   <= w_red   * 306;
                t_blue  <= w_green * 117;
                t_green <= w_blue  * 601;
            end
            11:begin
                t_red   <= w_red   * 612;
                t_blue  <= w_green * 234;
                t_green <= w_blue  * 1202;
            end
            12:begin
                t_red   <= w_red   * 1224;
                t_blue  <= w_green * 467;
                t_green <= w_blue  * 2405;
            end
            13:begin
                t_red   <= w_red   * 2449;
                t_blue  <= w_green * 934;
                t_green <= w_blue  * 4809;
            end
            14:begin
                t_red   <= w_red   * 4898;
                t_blue  <= w_green * 1868;
                t_green <= w_blue  * 9618;
            end
            15:begin
                t_red   <= w_red   * 9797;
                t_blue  <= w_green * 3736;
                t_green <= w_blue  * 19235;
            end
            16:begin
                t_red   <= w_red   * 19595;
                t_blue  <= w_green * 7472;
                t_green <= w_blue  * 38469;
            end
            17:begin
                t_red   <= w_red   * 39190;
                t_blue  <= w_green * 14943;
                t_green <= w_blue  * 76939;
            end
            18:begin
                t_red   <= w_red   * 78381;
                t_blue  <= w_green * 29885;
                t_green <= w_blue  * 153878;
            end
            19:begin
                t_red   <= w_red   * 156762;
                t_blue  <= w_green * 59769;
                t_green <= w_blue  * 307757;
            end
            default:begin
                t_red   <= w_red   * 313524;
                t_blue  <= w_green * 119538;
                t_green <= w_blue  * 615514;
            end
        endcase
    end

    always @(posedge pix_clk) begin
        case(ACCURACY_NUM)
            0:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) /  100;
            1:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) /  100;
            2:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) >> 2;
            3:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) >> 3;
            4:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) >> 4;
            5:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) >> 5;
            6:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) >> 6;
            7:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) >> 7;
            8:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) >> 8;
            9:gray_data_r[7:0]       <= ( t_red + t_blue + t_green ) >> 9;
            10:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 10;
            11:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 11;
            12:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 12;
            13:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 13;
            14:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 14;
            15:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 15;
            16:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 16;
            17:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 17;
            18:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 18;
            19:gray_data_r[7:0]      <= ( t_red + t_blue + t_green ) >> 19;
            default:gray_data_r[7:0] <= ( t_red + t_blue + t_green ) >> 20;
        endcase
    end

    reg t_rgb_de;
    reg t_rgb_hs;
    reg t_rgb_vs;

    always @(posedge pix_clk) begin  // 打拍
        t_rgb_de <= rgb_de;
        t_rgb_hs <= rgb_hs;
        t_rgb_vs <= rgb_vs;

        gray_de <= t_rgb_de;
        gray_hs <= t_rgb_hs;
        gray_vs <= t_rgb_vs;
    end

    assign gray_data = {3{gray_data_r}};  // 拼接

endmodule