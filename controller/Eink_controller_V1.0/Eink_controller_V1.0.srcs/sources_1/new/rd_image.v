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
//2020-03-24      Chaochen Wei  1.0          Original
//2020-                         1.1
// --------------------------------------------------------------------
// --------------------------------------------------------------------
`timescale 1ns / 1ps
module rd_image(
    input   wire            clk     ,
    input   wire            rst     ,
    input   wire            rd_req  ,
    input   wire            EN_GRAY_IMG,
    output  wire    [23:0]   rd_data
    );

//==========================================
//parameter define
//==========================================
parameter   STOP_ADDR = 256*256 - 1;

reg     [15:0]      rd_addr;
wire    [24:0]      dout;

wire    [23:0]      dout_r;
wire    [7:0]       dout_g;

assign rd_data = dout;
//----------------rd_addr------------------
always @(posedge clk) begin
    if (rst==1'b1) begin
        rd_addr <= 'd0;
    end
    else if(rd_req==1'b1 )begin //读数据请求来临时，读地址加一
        if(rd_addr == STOP_ADDR)begin
            rd_addr <= 'd0;
        end
        else begin
            rd_addr <= rd_addr + 1'b1;
        end
    end
end

assign clk_g = EN_GRAY_IMG ? clk:0;
assign clk_r = EN_GRAY_IMG ? 0:clk;

assign dout = EN_GRAY_IMG ? {3{dout_g}}:dout_r;

blk_mem_gen_gray inst_gray_rom (
  .clka(clk_g),    // input wire clka
  .addra(rd_addr),  // input wire [15 : 0] addra
  .douta(dout_g)  // output wire [23 : 0] douta
);

blk_mem_gen_rgb inst_rgb_rom (
  .clka(clk_r),    // input wire clka
  .addra(rd_addr),  // input wire [15 : 0] addra
  .douta(dout_r)  // output wire [23 : 0] douta
);

endmodule
