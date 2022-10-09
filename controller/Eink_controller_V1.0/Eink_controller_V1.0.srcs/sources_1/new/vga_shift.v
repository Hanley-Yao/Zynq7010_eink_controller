// --------------------------------------------------------------------
// Copyright (c) 2019 by MicroPhase Technologies Inc.
// --------------------------------------------------------------------
//
// Permission:
//
//   MicroPhase grants permission to use and modify this code for use
//   in synthesis for all MicroPhase Development Boards.
//   Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  MicroPhase provides no warranty regarding the use
//   or functionality of this code.
//
// --------------------------------------------------------------------
//
//                     MicroPhase Technologies Inc
//                     Shanghai, China
//
//                     web: http://www.microphase.cn/
//                     email: support@microphase.cn
//
// --------------------------------------------------------------------
// --------------------------------------------------------------------
//
// Major Functions:
//
// --------------------------------------------------------------------
// --------------------------------------------------------------------
//
//  Revision History:
//  Date          By            Revision    Change Description
//---------------------------------------------------------------------
//2019-12-07      Chaochen Wei  1.0          Original
//2019/                         1.1
// --------------------------------------------------------------------
// --------------------------------------------------------------------


module vga_shift(
input   wire                rst             ,//复位
input   wire                vpg_pclk        ,//像素时钟
input   wire    [23:0]      rd_data         ,//读出的图像数据
output  wire                rd_req          ,//读数据请求
output  reg                 vpg_de          ,//输出数据有效信号
output  reg                 vpg_hs          ,//行同步信号
output  reg                 vpg_vs          ,//场同步信号
output  wire    [7:0]       rgb_r           ,//输出图像值
output  wire    [7:0]       rgb_g           ,//输出图像值
output  wire    [7:0]       rgb_b            //输出图像值
);

parameter       H_TOTAL  = 2200 - 1     ;//一行总共需要计数的值
parameter       H_SYNC   = 44 - 1       ;//行同步计数值
parameter       H_START  = 190 - 1      ;//行图像数据有效开始计数值
parameter       H_END    = 2110 - 1     ;//行图像数据有效结束计数值
parameter       V_TOTAL  = 1125 - 1     ;//场总共需要计数的值
parameter       V_SYNC   = 5 - 1        ;//场同步计数值
parameter       V_START  = 41 - 1       ;//场图像数据有效开始计数值
parameter       V_END    = 1121 - 1     ;//场图像数据有效结束计数值
parameter       SQUARE_X = 256          ;//方块的宽度
parameter       SQUARE_Y = 256          ;//方块的长度
parameter       SCREEN_X = 1920         ;//屏幕水平长度
parameter       SCREEN_Y = 1080         ;//屏幕垂直长度

//=======================================================
//  Signal declarations
//=======================================================
reg [12:0]  cnt_h;//行计数器
reg [12:0]  cnt_v;//场计数器
reg [11:0]  x    ;//方块左上角横坐标
reg         flag_x;//方块水平移动方向指示信号
reg [11:0]  y    ;//方块左上角纵坐标
reg         flag_y;//方块垂直移动方向指示信号
reg [23:0]  rgb     ;

reg         rd_req_r    ;

assign {rgb_r,rgb_g,rgb_b} = rgb;
assign rd_req = rd_req_r;

 //行计数器
always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        cnt_h <= 'd0;
    end
    else if (cnt_h == H_TOTAL) begin//计数到最大值，清零
        cnt_h <= 'd0;
    end
    else if(cnt_h != H_TOTAL) begin//还没有计数到最大值，每个时钟周期加一
        cnt_h <= cnt_h + 1'b1;
    end
end

//场计数器
always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        cnt_v <='d0;
    end
    else if (cnt_v == V_TOTAL && cnt_h == H_TOTAL) begin//场计数器计数到最大值，清零（一帧结束）
        cnt_v <= 'd0;
    end
    else if(cnt_h == H_TOTAL) begin//一行扫描结束，场计数器加一
        cnt_v <= cnt_v + 1'b1;
    end
end

//行同步信号
always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        vpg_hs <= 1'b1;
    end
    else if (cnt_h == H_TOTAL) begin
        vpg_hs <= 1'b1;
    end
    else if (cnt_h == H_SYNC) begin
        vpg_hs <= 1'b0;
    end
end

//场同步信号
always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        vpg_vs <= 1'b1;
    end
    else if (cnt_v == V_TOTAL && cnt_h == H_TOTAL) begin
        vpg_vs <= 1'b1;
    end
    else if (cnt_v == V_SYNC && cnt_h == H_TOTAL) begin
        vpg_vs <=  1'b0;
    end
end


always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        vpg_de <= 1'b0;
    end
    else if ((cnt_h >= H_START) && (cnt_h < H_END) && (cnt_v >= V_START) && (cnt_v < V_END)) begin
        vpg_de <= 1'b1;
    end
    else begin
        vpg_de <=  1'b0;
    end
end
//移动方块的左上角水平方向坐标
always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        x <='d0;
    end
    else if (flag_x == 1'b0 && cnt_v == V_TOTAL && cnt_h == H_TOTAL) begin
        x <= x + 1'b1;
    end
    else if(flag_x == 1'b1 && cnt_v == V_TOTAL && cnt_h == H_TOTAL) begin
        x <= x - 1'b1;
    end
end

//移动方块左上角移动方向指示信号
always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        flag_x <= 1'b0;
    end
    else if (flag_x == 1'b0 && cnt_v ==V_TOTAL && cnt_h == H_TOTAL && x==(H_END - H_START - SQUARE_X - 1'b1)) begin
        flag_x <= 1'b1;
    end
    else if (flag_x == 1'b1 && cnt_v ==V_TOTAL && cnt_h == H_TOTAL && x=='d1) begin
        flag_x <= 1'b0;
    end
end

//移动方块的左上角垂直方向坐标
always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        y <= 'd0;
    end
    else if (flag_y == 1'b0 && cnt_v ==V_TOTAL && cnt_h == H_TOTAL) begin
        y <= y + 1'b1;
    end
    else if (flag_y == 1'b1 && cnt_v ==V_TOTAL && cnt_h == H_TOTAL) begin
        y <= y - 1'b1;
    end
end

//移动方块左上角垂直移动方向指示信号
always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        flag_y <= 1'b0;
    end
    else if (flag_y == 1'b0 && cnt_v ==V_TOTAL && cnt_h == H_TOTAL && y==(V_END - V_START - SQUARE_Y - 1'b1)) begin
        flag_y <= 1'b1;
    end
    else if (flag_y == 1'b1 && cnt_v ==V_TOTAL && cnt_h == H_TOTAL && y=='d1 ) begin
        flag_y <= 1'b0;
    end
end

//----------------rd_req_r------------------
always @(posedge vpg_pclk) begin
    if (rst==1'b1) begin
        rd_req_r <= 1'b0;
    end
    else if(cnt_h >=H_START+x-2 && cnt_h <H_START+SQUARE_X+x-2 && cnt_v >=V_START+y && cnt_v <V_START+SQUARE_Y+y)begin
        rd_req_r <= 1'b1;
    end
    else begin
        rd_req_r <= 1'b0;
    end
end


//rgb
always @(posedge vpg_pclk ) begin
    if (rst==1'b1) begin
        rgb <='d0;
    end
    else if(cnt_h >=H_START+x && cnt_h <H_START+SQUARE_X+x && cnt_v >=V_START+y && cnt_v <V_START+SQUARE_Y+y)begin
        //转换为BGR格式
        rgb <= {rd_data[7:0],rd_data[15:8],rd_data[23:16]};//输出方块图像
    end
    else if (cnt_h >=H_START && cnt_h <H_END && cnt_v >=V_START && cnt_v <V_END && cnt_h[4:0]>='d20) begin
        rgb <=24'h00FF00;//green
    end
    else if (cnt_h >=H_START && cnt_h <H_END && cnt_v >=V_START && cnt_v <V_END && (cnt_h[4:0]>='d10 && cnt_h[2:0]<'d20)) begin
        rgb <=24'h0000FF;//bulue
    end
    else if (cnt_h >=H_START && cnt_h <H_END && cnt_v >=V_START && cnt_v <V_END && cnt_h[4:0]<'d10) begin
        rgb <=24'hFF0000;//red
    end
    else begin
        rgb <= 'd0;
    end
end

endmodule
