
//////////////////////////////////////////////////////////////////////////////////
//
//  生成视频时序
//  模块改编于 米联客 uivct.v
//  利用CRU.exe计算时序
//
//////////////////////////////////////////////////////////////////////////////////

module vct #(
    parameter H_Active     = 1920,
    parameter H_FrontPorch = 88,
    parameter H_SyncWidth  = 44,
    parameter H_BackPorch  = 148,

    parameter V_Active     = 1080,
    parameter V_FrontPorch = 4,
    parameter V_SyncWidth  = 5,
    parameter V_BackPorch  = 36
    )
    (
    input           vtc_rst_n,
    input           vtc_pix_clk,
    output  reg     vtc_vs_o,
    output  reg     vtc_hs_o,
    output  reg     vtc_de_o
    );

    localparam H_FrameSize  = H_Active + H_FrontPorch + H_SyncWidth + H_BackPorch;
    localparam V_FrameSize  = V_Active + V_FrontPorch + V_SyncWidth + V_BackPorch;

    reg [11:0]  hcnt = 12'd0;
    reg [11:0]  vcnt = 12'd0;
    reg [2 :0]  rst_cnt = 3'd0;
    wire        rst_sync = rst_cnt[2];

    always @(posedge vtc_pix_clk)begin
        if(!vtc_rst_n)
            rst_cnt <= 3'd0;
        else if(rst_cnt[2] == 1'b0)
            rst_cnt <= rst_cnt + 1'b1;
    end

    always @(posedge vtc_pix_clk)begin
        if(rst_sync == 1'b0)
            hcnt <= 12'd0;
        else if(hcnt < (H_FrameSize - 1'b1))
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 12'd0;
    end

    always @(posedge vtc_pix_clk)begin
        if(rst_sync == 1'b0)
            vcnt <= 12'd0;
        else if(hcnt == (H_Active  - 1'b1)) begin
            vcnt <= (vcnt == (V_FrameSize - 1'b1)) ? 12'd0 : vcnt + 1'b1;
        end
    end

    wire    hs_valid = hcnt < H_Active;
    wire    vs_valid = vcnt >= V_FrameSize - V_Active;
    wire    vtc_hs   = (hcnt >= H_Active + H_FrontPorch && hcnt < H_Active + H_FrontPorch + H_SyncWidth);
    wire    vtc_vs   = (vcnt > V_FrontPorch && vcnt <= V_FrontPorch + V_SyncWidth);
    wire    vtc_de   = hs_valid && vs_valid;

    always @(posedge vtc_pix_clk)begin
        if(rst_sync == 1'b0)begin
            vtc_vs_o <= 1'b0;
            vtc_hs_o <= 1'b0;
            vtc_de_o <= 1'b0;
        end
        else begin
            vtc_vs_o <= vtc_vs;
            vtc_hs_o <= vtc_hs;
            vtc_de_o <= vtc_de;
        end
    end

endmodule
