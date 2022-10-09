
//////////////////////////////////////////////////////////////////////////////////
//
//  该模块用于数据镜像排列处理
//
//  | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    |
//  | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
//  | 9    | 10   | 11   | 12   | 13   | 14   | 15   | 16   |
//
//                  ↓
//
//  | 8    | 7    | 6    | 5    | 4    | 3    | 2    | 1    |
//  | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
//  | 16   | 15   | 14   | 13   | 12   | 11   | 10   | 9    |
//
//////////////////////////////////////////////////////////////////////////////////

module v_mirror#(
    parameter FRAME_H   = 1280,         // 输入长度
    parameter FRAME_V   = 720,          // 输入宽度
    parameter Frame_bpp = 8
    )

    (
    input wire                      pix_clk,
    input wire                      rst_n,
    input wire                      vs_i,
    input wire                      hs_i,
    input wire                      de_i,
    input wire  [Frame_bpp -1:0]    image_data_i,

    output wire                     vs_o,
    output wire                     hs_o,
    output reg                      de_o,
    output wire  [Frame_bpp -1:0]   image_data_o
    );

    reg [11:0]                  waddr;
    reg [11:0]                  raddr;

    //-----------写入控制-----------//

    always @(posedge pix_clk or negedge rst_n) begin  // 地址递增
        if (!rst_n) begin
            // reset
            waddr <= 0;
        end
        else if (de_i) begin
            if (waddr < FRAME_H * 2 - 1) begin
                waddr <= waddr + 1;
            end
            else begin
                waddr <= 0;
            end
        end
    end

   //----------- Converted 时序生成-----------//

    reg [10:0] HS_L_CNT;

    reg [3:0] HS_L_CNT_STATE;

    localparam HS_L_CNT_IDEL   = 0;
    localparam HS_L_CNT_STATE1 = 1;
    localparam HS_L_CNT_STATE2 = 2;
    localparam HS_L_CNT_DONE   = 3;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            HS_L_CNT <= FRAME_H;
            HS_L_CNT_STATE <= 0;
        end
        else begin
            case(HS_L_CNT_STATE)  // 统计行低电平时间

                HS_L_CNT_IDEL:begin
                    if (hs_i) begin
                        HS_L_CNT_STATE <= HS_L_CNT_STATE1;
                    end
                end

                HS_L_CNT_STATE1:begin
                    if (!hs_i) begin
                        HS_L_CNT <= 0;
                        HS_L_CNT_STATE <= HS_L_CNT_STATE2;
                    end
                end

                HS_L_CNT_STATE2:begin
                    if (hs_i) begin
                        HS_L_CNT_STATE <= HS_L_CNT_DONE;
                    end
                    else begin
                        HS_L_CNT <= HS_L_CNT + 1;
                    end
                end

                HS_L_CNT_DONE:begin
                    HS_L_CNT <= HS_L_CNT;
                end

                default:begin
                    HS_L_CNT_STATE <= HS_L_CNT_IDEL;
                end

            endcase
        end
    end

    assign vs_o = vs_i;
    assign hs_o = hs_i;

    level2pulse #(  // 换行下降沿触发
            .MODE("FALLING")
        ) de_level2pulse (
            .clk(pix_clk),
            .rst_n(rst_n),
            .in(de_i),
            .out(de_p)
        );

    level2pulse #(  // 数据结束触发
            .MODE("FALLING")
        ) hs_level2pulse (
            .clk(pix_clk),
            .rst_n(rst_n),
            .in(hs_i),
            .out(hs_p)
        );

    reg de_o_t;
    reg [10:0] DE_CNT;
    reg [3:0] DE_STATE;

    localparam DE_IDEL   = 0;
    localparam DE_STATE1 = 1;
    localparam DE_STATE2 = 2;
    localparam DE_STATE3 = 3;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            de_o_t <= 0;
            DE_CNT <= 0;
            DE_STATE <= 0;
        end
        else begin
            case(DE_STATE)  // 生成 DE 信号

                DE_IDEL:begin  // 等待 DE 下降
                    if (de_p) begin
                        DE_STATE <= DE_STATE1;
                    end
                end

                DE_STATE1:begin  // 等待 HS 下降
                    if (hs_p) begin
                        DE_STATE <= DE_STATE2;
                    end
                end

                DE_STATE2:begin  // 肩宽控制
                    if (DE_CNT < (HS_L_CNT - FRAME_H)/2) begin
                        DE_CNT <= DE_CNT + 1;
                    end
                    else begin
                        DE_STATE <= DE_STATE3;
                    end
                end

                DE_STATE3:begin  // 数据有效
                    if (DE_CNT - (HS_L_CNT - FRAME_H)/2 < FRAME_H) begin
                        DE_CNT <= DE_CNT + 1;
                        de_o_t <= 1;
                    end
                    else begin
                        de_o_t <= 0;
                        DE_CNT <= 0;
                        DE_STATE <= DE_IDEL;
                    end
                end

                default:begin
                    DE_STATE <= DE_IDEL;
                end

            endcase
        end
    end

    //-----------读取控制-----------//

    reg SW_LINE_CNT;
    reg [3:0] MIRROR_R_STATE;

    localparam MIRROR_R_IDEL   = 0;
    localparam MIRROR_R_STATE1 = 1;
    localparam MIRROR_R_STATE2 = 2;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            raddr <= 0;
            SW_LINE_CNT <= 0;
            MIRROR_R_STATE <= 0;
        end
        else begin
            case(MIRROR_R_STATE)

                MIRROR_R_IDEL:begin  // 触发读取
                    if (de_o_t) begin
                        case(SW_LINE_CNT)
                            1'd0:begin  // Converted_Line_0
                                raddr <= FRAME_H - 1;
                                MIRROR_R_STATE <= MIRROR_R_STATE1;
                            end
                            1'd1:begin  // Converted_Line_1
                                raddr <= FRAME_H*2 - 1;
                                MIRROR_R_STATE <= MIRROR_R_STATE1;
                            end
                        endcase
                    end
                end

                MIRROR_R_STATE1:begin  // 第一起始位 指针计算
                    case(SW_LINE_CNT)
                        1'd0:begin
                            if (raddr == 0) begin
                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                MIRROR_R_STATE <= MIRROR_R_IDEL;
                            end
                            else begin
                                raddr <= raddr - 1;
                            end
                        end
                        1'd1:begin
                            if (raddr == FRAME_H) begin
                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                MIRROR_R_STATE <= MIRROR_R_IDEL;
                            end
                            else begin
                                raddr <= raddr - 1;
                            end
                        end
                    endcase
                end

                default:begin
                    MIRROR_R_STATE <= MIRROR_R_IDEL;
                end

            endcase
        end
    end

    reg de_o_tt;
    reg de_o_ttt;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            de_o_tt <= 0;
            de_o <= 0;
        end
        else begin
            de_o_tt <= de_o_t;
            de_o_ttt <= de_o_tt;
            de_o <= de_o_ttt;
        end
    end

    blk_line_buf line_buf
        (
            .clka(pix_clk),
            .clkb(pix_clk),

            .wea(de_i),
            .addra(waddr),
            .dina(image_data_i),

            .addrb(raddr),
            .doutb(image_data_o)
        );

endmodule
