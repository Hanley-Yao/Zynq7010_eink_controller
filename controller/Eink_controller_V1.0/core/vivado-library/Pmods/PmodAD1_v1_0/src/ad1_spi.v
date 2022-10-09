`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigilentInc
// Engineer: Arthur Brown
// 
// Create Date: 09/22/2016 09:58:43 AM
// Module Name: ad1_spi
// Project Name: PmodAD1 IP
// Description: SPI Controller, continuously polls the AD1 SPI.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ad1_spi (
    clk,
    rst,
    cs,
    sdin0,
    sdin1,
    sclk,
    drdy,
    dout0,
    dout1
    
    ,led
);
    parameter INCLUDE_DEBUG_INTERFACE = 0;
    parameter CLOCKS_PER_BIT = 20;//1 bit per 200ns
    parameter CLOCKS_BEFORE_DATA = 60;//600ns
    parameter CLOCKS_AFTER_DATA = 500;//5us
    parameter CLOCKS_BETWEEN_TRANSACTIONS = 400;//4us
    localparam BITS_PER_TRANSACTION = 16;
    localparam BIT_HALFWAY_CLOCK = CLOCKS_PER_BIT>>1;

    input clk;
    input rst;
//    reg [15:0] dout0 = 0;
//    reg [15:0] dout1 = 0;
    output cs;
    input sdin0;
    input sdin1;
    output sclk;//period=200ns
    output reg drdy = 0; // data ready flag
    output reg [15:0] dout0 = 0;
    output reg [15:0] dout1 = 0;
    output [1:0] led;
    
    localparam S_HOLD        = 0; // 4000ns
    localparam S_FRONT_PORCH = 1; // 600ns
    localparam S_SHIFTING    = 2; // 16*sclk.per
    localparam S_BACK_PORCH  = 3; // 5000ns
        
    reg [1:0] state = S_HOLD;
    reg [31:0] count0 = 0;
    reg [31:0] count1 = 0;
    reg [15:0] shft0 = 0;
    reg [15:0] shft1 = 0;
    
    assign cs = (state == S_HOLD) ? 1 : 0;
    assign sclk = (state == S_SHIFTING && count0 <= BIT_HALFWAY_CLOCK-1) ? 0 : 1;
    
    generate if (INCLUDE_DEBUG_INTERFACE == 1)
        assign led = state;
    endgenerate
    
    always@(posedge clk)
        if (rst == 1) begin
            drdy <= 0;
            dout0 <= 0;
            dout1 <= 0;
            state <= S_HOLD;
            count0 <= 0;
            count1 <= 0;
            shft0 <= 0;
            shft1 <= 0;
        end else case (state)
        S_HOLD: if (count0 == CLOCKS_BETWEEN_TRANSACTIONS-1) begin
            state <= S_FRONT_PORCH;
            count0 <= 0;
        end else
            count0 <= count0 + 1;
        S_FRONT_PORCH: if (count0 == CLOCKS_BEFORE_DATA-1) begin
            state <= S_SHIFTING;
            count0 <= 0;
            count1 <= 0;
            shft0 <= 0;
            shft1 <= 0;
        end else
            count0 <= count0 + 1;
        S_SHIFTING: if (count0 == CLOCKS_PER_BIT-1) begin
            count0 <= 0;
            if (count1 == BITS_PER_TRANSACTION-1) begin
                dout0 <= shft0;
                dout1 <= shft1;
                drdy <= 1;
                state <= S_BACK_PORCH;
            end else
                count1 <= count1 + 1;
        end else begin
            count0 <= count0 + 1;
            if (count0 == BIT_HALFWAY_CLOCK-1) begin
                shft0 <= {shft0[14:0], sdin0};
                shft1 <= {shft1[14:0], sdin1};
            end
        end
        S_BACK_PORCH: if (count0 == CLOCKS_AFTER_DATA-1) begin
            count0 <= 0;
            drdy <= 0;
            state <= S_HOLD;
        end else
            count0 <= count0 + 1;
        endcase
        
endmodule