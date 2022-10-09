
//////////////////////////////////////////////////////////////////////////////////
//
//  该模块用于数据重新排列
//
//  | 1    | 2    | 3    | 4    |
//  | ---- | ---- | ---- | ---- |
//  | 5    | 6    | 7    | 8    |
//  | ---- | ---- | ---- | ---- |
//  | 9    | 10   | 11   | 12   |
//  | ---- | ---- | ---- | ---- |
//  | 13   | 14   | 15   | 16   |
//
//                  ↓
//
//  | 1    | 5    | 2    | 6    | 3    | 7    | 4    | 8    |
//  | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
//  | 9    | 13   | 10   | 14   | 11   | 15   | 12   | 16   |
//
//  使用RAM地址指针实现数据的重新排列
//
//  共缓冲四行原始数据(交替)
//
//  需要地址空间为 ADDR = H * 4
//
//////////////////////////////////////////////////////////////////////////////////

module CTM_E #(  // 展开
    parameter H_Active     = 200,
    parameter V_Active     = 750,
    parameter Frame_bpp    = 8
    )(
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

    reg                         wen;
    reg [11:0]                  waddr;
    reg [11:0]                  raddr;

    //-----------写入控制-----------//

    reg [Frame_bpp -1:0] data_i_t;  // 打一拍

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            data_i_t <= 0;
        end
        else begin
            data_i_t <= image_data_i;
        end
    end

    reg [1:0] SW_LINE_CNT;
    reg [3:0] CTM_R_STATE;

    localparam CTM_R_IDEL   = 0;
    localparam CTM_R_STATE1 = 1;
    localparam CTM_R_STATE2 = 2;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            waddr <= 0;
            wen <= 0;
            SW_LINE_CNT <= 0;
            CTM_R_STATE <= 0;
        end
        else begin
            case(CTM_R_STATE)

                CTM_R_IDEL:begin  // 当 Data 有效时触发写入
                    if (de_i) begin
                        wen <= 1;
                        case(SW_LINE_CNT)
                            2'd0:begin  // Converted_Line_0 第一起始位
                                waddr <= 0;
                                CTM_R_STATE <= CTM_R_STATE1;
                            end
                            2'd1:begin  // Converted_Line_0 第二起始位
                                waddr <= 1;
                                CTM_R_STATE <= CTM_R_STATE2;
                            end
                            2'd2:begin  // Converted_Line_1 第一起始位
                                waddr <= H_Active*2 + 0;
                                CTM_R_STATE <= CTM_R_STATE1;
                            end
                            2'd3:begin  // Converted_Line_1 第二起始位
                                waddr <= H_Active*2 + 1;
                                CTM_R_STATE <= CTM_R_STATE2;
                            end
                        endcase
                    end
                end

                CTM_R_STATE1:begin  // 第一起始位 指针计算
                    case(SW_LINE_CNT)
                        2'd0:begin
                            if (waddr == H_Active * 2 - 2) begin
                                wen <= 0;
                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                CTM_R_STATE <= CTM_R_IDEL;
                            end
                            else begin
                                waddr <= waddr + 2;
                            end
                        end
                        2'd2:begin
                            if (waddr == H_Active * 4 - 2) begin
                                wen <= 0;
                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                CTM_R_STATE <= CTM_R_IDEL;
                            end
                            else begin
                                waddr <= waddr + 2;
                            end
                        end
                    endcase
                end

                CTM_R_STATE2:begin  // 第二起始位 指针计算
                    case(SW_LINE_CNT)
                        2'd1:begin
                            if (waddr == H_Active * 2 - 1) begin
                                wen <= 0;
                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                CTM_R_STATE <= CTM_R_IDEL;
                            end
                            else begin
                                waddr <= waddr + 2;
                            end
                        end
                        2'd3:begin
                            if (waddr == H_Active * 4 - 1) begin
                                wen <= 0;
                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                CTM_R_STATE <= CTM_R_IDEL;
                            end
                            else begin
                                waddr <= waddr + 2;
                            end
                        end
                    endcase
                end

                default:begin
                    CTM_R_STATE <= CTM_R_IDEL;
                end

            endcase
        end
    end

    //----------- Converted 时序生成-----------//

    assign vs_o = vs_i;

    reg [11:0] HS_CNT;

    always @(posedge de_i or posedge vs_i) begin
        if (vs_i) begin
            // reset
            HS_CNT <= 0;
        end
        else if (de_i) begin
            HS_CNT <= HS_CNT + 1;
        end
    end

    level2pulse #(
            .MODE("FALLING")
        ) inst_level2pulse (
            .clk(pix_clk),
            .rst_n(rst_n),
            .in(hs_i),
            .out(hs_i_t)
        );

    reg       hs_sw;
    reg [11:0] T_CNT;
    reg [11:0] TT_CNT;
    reg [3:0] T_STATE;

    localparam T_IDEL   = 0;
    localparam T_STATE1 = 1;
    localparam T_STATE2 = 2;

    always @(posedge pix_clk or posedge vs_i) begin
        if (vs_i) begin
            // reset
            T_STATE <= 0;
            T_CNT <= 0;
            TT_CNT <= 9'd2;
            hs_sw <= 0;
        end
        else begin
            case(T_STATE)

                T_IDEL:begin
                    if (HS_CNT == TT_CNT) begin
                        TT_CNT <= TT_CNT + 2;
                        T_STATE <= T_STATE1;
                    end
                end

                T_STATE1:begin
                    if (hs_i_t) begin
                        T_STATE <= T_STATE2;
                    end
                end

                T_STATE2:begin  // 计时
                    if (T_CNT < H_Active * 2) begin
                        T_CNT <= T_CNT + 1;
                        hs_sw <= 1;
                    end
                    else begin
                        T_CNT <= 0;
                        hs_sw <= 0;
                        T_STATE <= T_IDEL;
                    end
                end

                default:begin
                    T_STATE <= T_IDEL;
                end

            endcase
        end
    end

    assign hs_o = (hs_sw) ? 0:hs_i;

    reg de_o_t;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            de_o_t <= 0;
            de_o <= 0;
        end
        else begin
            de_o_t <= hs_sw;
            de_o <= de_o_t;
        end
    end

    //-----------读取控制-----------//

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            raddr <= 0;
        end
        else if (hs_sw) begin
            if (raddr < H_Active * 4 - 1) begin
                raddr <= raddr + 1;
            end
            else begin
                raddr <= 0;
            end
        end
    end

    //-----------RAM-----------//

    blk_line_buf line_buf
        (
            .clka(pix_clk),
            .clkb(pix_clk),

            .wea(wen),
            .addra(waddr),
            .dina(data_i_t),

            .addrb(raddr),
            .doutb(image_data_o)
        );

endmodule

//////////////////////////////////////////////////////////////////////////////////
//
//  该模块用于数据重新排列
//
//  | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    |
//  | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
//  | 9    | 10   | 11   | 12   | 13   | 14   | 15   | 16   |
//
//                  ↓
//
//  | 1    | 3    | 5    | 7    |
//  | ---- | ---- | ---- | ---- |
//  | 2    | 4    | 8    | 10   |
//  | ---- | ---- | ---- | ---- |
//  | 9    | 11   | 13   | 15   |
//  | ---- | ---- | ---- | ---- |
//  | 10   | 12   | 14   | 16   |
//
//  使用RAM地址指针实现数据的重新排列
//
//  共缓冲二行原始数据(交替)
//
//  需要地址空间为 ADDR = H * 2
//
//////////////////////////////////////////////////////////////////////////////////

module CTM_F #(  // 折叠
    parameter H_Active     = 750,
    parameter V_Active     = 200,
    parameter Frame_bpp    = 8
    )(
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
            if (waddr < H_Active * 2 - 1) begin
                waddr <= waddr + 1;
            end
            else begin
                waddr <= 0;
            end
        end
    end

    //----------- Converted 时序生成-----------//

    reg [11:0] HS_H_CNT;

    reg [3:0] HS_H_CNT_STATE;

    localparam HS_H_CNT_IDEL   = 0;
    localparam HS_H_CNT_STATE1 = 1;
    localparam HS_H_CNT_STATE2 = 2;
    localparam HS_H_CNT_STATE3 = 3;
    localparam HS_H_CNT_DONE   = 4;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            HS_H_CNT <= 0;
            HS_H_CNT_STATE <= 0;
        end
        else begin
            case(HS_H_CNT_STATE)  // 统计行高电平时间

                HS_H_CNT_IDEL:begin
                    if (hs_i) begin
                        HS_H_CNT_STATE <= HS_H_CNT_STATE1;
                    end
                end

                HS_H_CNT_STATE1:begin
                    if (!hs_i) begin
                        HS_H_CNT_STATE <= HS_H_CNT_STATE2;
                    end
                end

                HS_H_CNT_STATE2:begin
                    if (hs_i) begin
                        HS_H_CNT_STATE <= HS_H_CNT_STATE3;
                    end
                end

                HS_H_CNT_STATE3:begin
                    if (!hs_i) begin
                        HS_H_CNT_STATE <= HS_H_CNT_DONE;
                    end
                    else if (hs_i) begin
                        HS_H_CNT <= HS_H_CNT + 1;
                    end
                end

                HS_H_CNT_DONE:begin
                    HS_H_CNT <= HS_H_CNT;
                end

                default:begin
                    HS_H_CNT_STATE <= HS_H_CNT_IDEL;
                end

            endcase
        end
    end

    reg [11:0] HS_L_CNT;

    reg [3:0] HS_L_CNT_STATE;

    localparam HS_L_CNT_IDEL   = 0;
    localparam HS_L_CNT_STATE1 = 1;
    localparam HS_L_CNT_STATE2 = 2;
    localparam HS_L_CNT_DONE   = 3;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            HS_L_CNT <= H_Active;
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

    reg [11:0] HS_CNT;

    always @(posedge de_i or posedge vs_i) begin
        if (vs_i) begin
            // reset
            HS_CNT <= 0;
        end
        else if (de_i) begin
            HS_CNT <= HS_CNT + 1;
        end
    end

    level2pulse #(
            .MODE("FALLING")
        ) hs_i_level2pulse (
            .clk(pix_clk),
            .rst_n(rst_n),
            .in(hs_i),
            .out(hs_i_t)
        );

    reg       hs_sw;
    reg [11:0] T_CNT;
    reg [11:0] TT_CNT;
    reg [3:0] T_STATE;

    localparam T_IDEL   = 0;
    localparam T_STATE1 = 1;
    localparam T_STATE2 = 2;

    always @(posedge pix_clk or posedge vs_i) begin
        if (vs_i) begin
            // reset
            T_STATE <= 0;
            T_CNT <= 0;
            TT_CNT <= 9'd1;
            hs_sw <= 0;
        end
        else begin
            case(T_STATE)

                T_IDEL:begin
                    if (HS_CNT == TT_CNT) begin
                        TT_CNT <= TT_CNT + 1;
                        T_STATE <= T_STATE1;
                    end
                end

                T_STATE1:begin
                    if (hs_i_t) begin
                        T_STATE <= T_STATE2;
                    end
                end

                T_STATE2:begin  // 计时
                    if (T_CNT < HS_L_CNT / 2 - HS_H_CNT / 2) begin
                        T_CNT <= T_CNT + 1;
                        hs_sw <= 1;
                    end
                    else begin
                        T_CNT <= 0;
                        hs_sw <= 0;
                        T_STATE <= T_IDEL;
                    end
                end

                default:begin
                    T_STATE <= T_IDEL;
                end

            endcase
        end
    end

    level2pulse #(
            .MODE("FALLING")
        ) hs_sw_p_o_level2pulse (
            .clk(pix_clk),
            .rst_n(rst_n),
            .in(hs_sw),
            .out(hs_o_1)
        );

    reg hs_o_2;
    reg [11:0] HS_O_H_CNT;
    reg [3:0] HS_O_STATE;

    localparam HS_O_IDEL   = 0;
    localparam HS_O_STATE1 = 1;
    localparam HS_O_STATE2 = 2;
    localparam HS_O_STATE3 = 3;
    localparam HS_O_DONE   = 4;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            hs_o_2 <= 0;
            HS_O_H_CNT <= 0;
            HS_O_STATE <= 0;
        end
        else begin
            case(HS_O_STATE)

                HS_O_IDEL:begin
                    if (hs_o_1) begin
                        HS_O_STATE <= HS_H_CNT_STATE1;
                    end
                end

                HS_O_STATE1:begin  // 展开信号
                    if (HS_O_H_CNT <= HS_H_CNT) begin
                        HS_O_H_CNT <= HS_O_H_CNT + 1;
                        hs_o_2 <= 1;
                    end
                    else begin
                        hs_o_2 <= 0;
                        HS_O_H_CNT <= 0;
                        HS_O_STATE <= HS_O_IDEL;
                    end
                end

                default:begin
                    HS_O_STATE <= HS_O_IDEL;
                end

            endcase
        end
    end


    assign hs_o = hs_i + hs_o_2;

    level2pulse #(
            .MODE("BOTH")
        ) hs_sw_wd_level2pulse (
            .clk(pix_clk),
            .rst_n(rst_n),
            .in(hs_sw),
            .out(rd_flag)
        );

    reg de_o_t;
    reg [11:0] DE_CNT;
    reg [3:0] DE_STATE;

    localparam DE_IDEL   = 0;
    localparam DE_STATE1 = 1;
    localparam DE_STATE2 = 2;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            de_o_t <= 0;
            DE_CNT <= 0;
            DE_STATE <= 0;
        end
        else begin
            case(DE_STATE)

                DE_IDEL:begin  // 等待读取flag
                    if (rd_flag) begin
                        DE_STATE <= DE_STATE1;
                    end
                end

                DE_STATE1:begin  // 肩宽控制
                    if (DE_CNT < (HS_L_CNT - H_Active)/4 + HS_H_CNT/2) begin
                        DE_CNT <= DE_CNT + 1;
                    end
                    else begin
                        DE_STATE <= DE_STATE2;
                    end
                end

                DE_STATE2:begin  // 数据有效
                    if (DE_CNT - (HS_L_CNT - H_Active)/4 < H_Active/2) begin
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

    reg [1:0] SW_LINE_CNT;
    reg [3:0] CTM_R_STATE;

    localparam CTM_R_IDEL   = 0;
    localparam CTM_R_STATE1 = 1;
    localparam CTM_R_STATE2 = 2;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            raddr <= 0;
            SW_LINE_CNT <= 0;
            CTM_R_STATE <= 0;
        end
        else begin
            case(CTM_R_STATE)

                CTM_R_IDEL:begin  // 触发读取
                    if (de_o_t) begin
                        case(SW_LINE_CNT)
                            2'd0:begin  // Converted_Line_0 第一起始位
                                raddr <= 0;
                                CTM_R_STATE <= CTM_R_STATE1;
                            end
                            2'd1:begin  // Converted_Line_0 第二起始位
                                raddr <= 1;
                                CTM_R_STATE <= CTM_R_STATE2;
                            end
                            2'd2:begin  // Converted_Line_1 第一起始位
                                raddr <= H_Active + 0;
                                CTM_R_STATE <= CTM_R_STATE1;
                            end
                            2'd3:begin  // Converted_Line_1 第二起始位
                                raddr <= H_Active + 1;
                                CTM_R_STATE <= CTM_R_STATE2;
                            end
                        endcase
                    end
                end

                CTM_R_STATE1:begin  // 第一起始位 指针计算
                    case(SW_LINE_CNT)
                        2'd0:begin
                            if (raddr == H_Active - 2) begin

                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                CTM_R_STATE <= CTM_R_IDEL;
                            end
                            else begin
                                raddr <= raddr + 2;
                            end
                        end
                        2'd2:begin
                            if (raddr == H_Active * 2 - 2) begin
                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                CTM_R_STATE <= CTM_R_IDEL;
                            end
                            else begin
                                raddr <= raddr + 2;
                            end
                        end
                    endcase
                end

                CTM_R_STATE2:begin  // 第二起始位 指针计算
                    case(SW_LINE_CNT)
                        2'd1:begin
                            if (raddr == H_Active - 1) begin
                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                CTM_R_STATE <= CTM_R_IDEL;
                            end
                            else begin
                                raddr <= raddr + 2;
                            end
                        end
                        2'd3:begin
                            if (raddr == H_Active * 2 - 1) begin
                                SW_LINE_CNT <= SW_LINE_CNT + 1;
                                CTM_R_STATE <= CTM_R_IDEL;
                            end
                            else begin
                                raddr <= raddr + 2;
                            end
                        end
                    endcase
                end

                default:begin
                    CTM_R_STATE <= CTM_R_IDEL;
                end

            endcase
        end
    end

    reg de_o_tt;
    reg de_o_ttt;

    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            de_o_ttt <= 0;
            de_o_tt <= 0;
            de_o <= 0;
        end
        else begin
            de_o_tt <= de_o_t;
            de_o_ttt <= de_o_tt;
            de_o <= de_o_ttt;
        end
    end

    //-----------RAM-----------//

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