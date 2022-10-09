`timescale  1ns/1ns

//////////////////////////////////////////////////////////////////////////////////
//
//  读取并输出
//
//////////////////////////////////////////////////////////////////////////////////

`define SEEK_SET    0
`define SEEK_CUR    1
`define SEEK_END    2

module  image_src #(
    parameter H_Active     = 1920,
    parameter H_FrontPorch = 88,
    parameter H_SyncWidth  = 44,
    parameter H_BackPorch  = 148,

    parameter V_Active     = 1080,
    parameter V_FrontPorch = 4,
    parameter V_SyncWidth  = 5,
    parameter V_BackPorch  = 36,

    parameter Frame_cnt    = 1,
    parameter Frame_bpp    = 24,
    parameter Frame_src    = "txt_i/img.txt"
    )(
    input wire                      pix_clk,
    input wire                      rst_n,
    output reg                      vs,
    output reg                      hs,
    output reg                      de,
    output reg  [Frame_bpp -1:0]    image_data = 0
    );

    // RGB Timing

    localparam H_FrameSize  = H_Active + H_FrontPorch + H_SyncWidth + H_BackPorch;
    localparam V_FrameSize  = V_Active + V_FrontPorch + V_SyncWidth + V_BackPorch;

    reg [11:0] hcnt = 12'd0;
    reg [11:0] vcnt = 12'd0;
    reg [2 :0] rst_cnt = 3'd0;
    wire       rst_sync = rst_cnt[2];

    always @(posedge pix_clk)begin
        if (!rst_n)
            rst_cnt <= 3'd0;
        else if (rst_cnt[2] == 1'b0)
            rst_cnt <= rst_cnt + 1'b1;
    end

    always @(posedge pix_clk)begin
        if (rst_sync == 1'b0)
            hcnt <= 12'd0;
        else if (hcnt < (H_FrameSize - 1'b1))
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 12'd0;
    end

    always @(posedge pix_clk)begin
        if (rst_sync == 1'b0)
            vcnt <= 12'd0;
        else if (hcnt == (H_Active  - 1'b1)) begin
            vcnt <= (vcnt == (V_FrameSize - 1'b1)) ? 12'd0 : vcnt + 1'b1;
        end
    end

    wire hs_t;
    wire vs_t;
    wire de_t;

    assign hs_valid = hcnt < H_Active;
    assign vs_valid = vcnt >= V_FrameSize - V_Active;
    assign hs_t = (hcnt >= H_Active + H_FrontPorch && hcnt < H_Active + H_FrontPorch + H_SyncWidth);
    assign vs_t = (vcnt > V_FrontPorch && vcnt <= V_FrontPorch + V_SyncWidth);
    assign de_t = hs_valid && vs_valid;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            vs <= 0;
            hs <= 0;
            de <= 0;
        end
        else begin
            vs <= vs_t;
            hs <= hs_t;
            de <= de_t;
        end
    end

    // Image_data

    level2pulse #(
            .MODE("RISING")
        ) vs_pulse (
            .clk(pix_clk),
            .rst_n(rst_n),
            .in(vs_t),
            .out(vs_pos)
        );

    reg [31:0] vs_cnt;  // 帧计数

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            vs_cnt <= 0;
        end
        else if (vs_cnt > Frame_cnt) begin
            vs_cnt <= 1;
        end
        else if (vs_pos) begin
            vs_cnt <= vs_cnt + 1;
        end
    end

    integer fp_r = 0;
    integer index = 0;
    //index
    always @(posedge pix_clk or negedge rst_n)begin
        if(rst_n == 1'b0) begin
            index   <=  0;
        end
        else if (vs_cnt > Frame_cnt) begin
            index   <=  0;
        end
        else if (de_t) begin
            fp_r  = $fopen(Frame_src,"r");
            //查找当前需要读取的文件位置
            $fseek(fp_r,index,`SEEK_SET);
            $fscanf(fp_r,"%x\n",image_data);
            index <=  index + Frame_bpp/4 + 2;  // 换行符有两个字节
            $fclose(fp_r);
            //$display("%x\n",image_data);
        end
    end

endmodule