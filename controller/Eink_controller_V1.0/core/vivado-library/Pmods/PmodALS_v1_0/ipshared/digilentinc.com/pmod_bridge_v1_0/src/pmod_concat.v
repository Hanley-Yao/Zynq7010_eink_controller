//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Fri Feb 05 15:23:13 2016
//Host        : WK116 running 64-bit major release  (build 9200)
//Command     : generate_target pmod_concat.bd
//Design      : pmod_concat
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module pmod_concat
   (
   
    in_top_bus_I,
    in_top_bus_O,
    in_top_bus_T,
    in_top_uart_gpio_bus_I,
    in_top_uart_gpio_bus_O,
    in_top_uart_gpio_bus_T,
    in_top_i2c_gpio_bus_I,
    in_top_i2c_gpio_bus_O,
    in_top_i2c_gpio_bus_T,
    in_bottom_bus_I,
    in_bottom_bus_O,
    in_bottom_bus_T,
    in_bottom_uart_gpio_bus_I,
    in_bottom_uart_gpio_bus_O,
    in_bottom_uart_gpio_bus_T,
    in_bottom_i2c_gpio_bus_I,
    in_bottom_i2c_gpio_bus_O,
    in_bottom_i2c_gpio_bus_T,
    in0_I,
    in1_I,
    in2_I,
    in3_I,
    in4_I,
    in5_I,
    in6_I,
    in7_I,
    in0_O,
    in1_O,
    in2_O,
    in3_O,
    in4_O,
    in5_O,
    in6_O,
    in7_O,
    in0_T,
    in1_T,
    in2_T,
    in3_T,
    in4_T,
    in5_T,
    in6_T,
    in7_T,
    out0_I,
    out1_I,
    out2_I,
    out3_I,
    out4_I,
    out5_I,
    out6_I,
    out7_I,
    out0_O,
    out1_O,
    out2_O,
    out3_O,
    out4_O,
    out5_O,
    out6_O,
    out7_O,
    out0_T,
    out1_T,
    out2_T,
    out3_T,
    out4_T,
    out5_T,
    out6_T,
    out7_T);
    parameter Top_Row_Interface = "None";
    parameter Bottom_Row_Interface = "None";
    
    output [3:0] in_top_bus_I;
    input [3:0] in_top_bus_O;
    input [3:0] in_top_bus_T;
    output [1:0] in_top_uart_gpio_bus_I;
    input [1:0] in_top_uart_gpio_bus_O;
    input [1:0] in_top_uart_gpio_bus_T;
    output [1:0] in_top_i2c_gpio_bus_I;
    input [1:0] in_top_i2c_gpio_bus_O;
    input [1:0] in_top_i2c_gpio_bus_T;
    
    output [3:0] in_bottom_bus_I;          
    input [3:0] in_bottom_bus_O;          
    input [3:0] in_bottom_bus_T;          
    output [1:0] in_bottom_uart_gpio_bus_I;
    input [1:0] in_bottom_uart_gpio_bus_O;
    input [1:0] in_bottom_uart_gpio_bus_T;
    output [1:0] in_bottom_i2c_gpio_bus_I;
    input [1:0] in_bottom_i2c_gpio_bus_O; 
    input [1:0] in_bottom_i2c_gpio_bus_T; 
    
  output in0_I;
  output in1_I;
  output in2_I;
  output in3_I;
  output in4_I;
  output in5_I;
  output in6_I;
  output in7_I;
  input in0_O;
  input in1_O;
  input in2_O;
  input in3_O;
  input in4_O;
  input in5_O;
  input in6_O;
  input in7_O;
  input in0_T;
  input in1_T;
  input in2_T;
  input in3_T;
  input in4_T;
  input in5_T;
  input in6_T;
  input in7_T;
  
  input out0_I;
  input out1_I;
  input out2_I;
  input out3_I;
  input out4_I;
  input out5_I;
  input out6_I;
  input out7_I;
  output out0_O;
  output out1_O;
  output out2_O;
  output out3_O;
  output out4_O;
  output out5_O;
  output out6_O;
  output out7_O;
  output out0_T;
  output out1_T;
  output out2_T;
  output out3_T;
  output out4_T;
  output out5_T;
  output out6_T;
  output out7_T;

generate
      case (Top_Row_Interface)
         "GPIO": begin
                    assign in_top_bus_I={out3_I,out2_I,out1_I,out0_I};
                    assign {out3_O,out2_O,out1_O,out0_O}=in_top_bus_O;
                    assign {out3_T,out2_T,out1_T,out0_T}=in_top_bus_T;
                  end
         "UART": begin
                    assign in_top_uart_gpio_bus_I={out3_I,out0_I};
                    assign {out3_O,out0_O}=in_top_uart_gpio_bus_O;
                    assign {out3_T,out0_T}=in_top_uart_gpio_bus_T;
                    //assign in1_I=out1_I;
                    assign in2_I=out2_I;
                    assign out1_O = in1_O;
                    //assign out2_O = in2_O;
                    assign out1_T = 0;
                    assign out2_T = 1;
                  end
         "I2C": begin
                    assign in_top_i2c_gpio_bus_I={out1_I,out0_I};//Input is I2C bus, output is to Pmod Pins
                    assign {out1_O,out0_O}=in_top_i2c_gpio_bus_O;
                    assign {out1_T,out0_T}=in_top_i2c_gpio_bus_T;
                    assign out2_O = in2_O;
                    assign out3_O = in3_O;
                    assign out2_T = in2_T;
                    assign out3_T = in3_T;
                    assign in2_I = out2_I;
                    assign in3_I = out3_I;
                  end
         default: begin
                    assign out0_O = in0_O;
                    assign out1_O = in1_O;
                    assign out2_O = in2_O;
                    assign out3_O = in3_O;
                    assign out0_T = in0_T;
                    assign out1_T = in1_T;
                    assign out2_T = in2_T;
                    assign out3_T = in3_T;
                    assign in0_I = out0_I;
                    assign in1_I = out1_I;
                    assign in2_I = out2_I;
                    assign in3_I = out3_I;
                  end
      endcase
   endgenerate
  
generate
         case (Bottom_Row_Interface)
            "GPIO":begin
                       assign in_bottom_bus_I={out7_I,out6_I,out5_I,out4_I};
                       assign {out7_O,out6_O,out5_O,out4_O}=in_bottom_bus_O;
                       assign {out7_T,out6_T,out5_T,out4_T}=in_bottom_bus_T;
                     end
            "UART": begin
                       assign in_bottom_uart_gpio_bus_I={out7_I,out4_I};
                       assign {out7_O,out4_O}=in_bottom_uart_gpio_bus_O;
                       assign {out7_T,out4_T}=in_bottom_uart_gpio_bus_T;
                       assign out5_O = in5_O;
                       assign out6_O = in6_O;
                       assign out5_T = in5_T;
                       assign out6_T = in6_T;
                       assign in5_I = out5_I;
                       assign in6_I = out6_I;
                     end
            "I2C": begin
                       assign in_bottom_i2c_gpio_bus_I={out5_I,out4_I};
                       assign {out5_O,out4_O}=in_bottom_i2c_gpio_bus_O;
                       assign {out5_T,out4_T}=in_bottom_i2c_gpio_bus_T;
                       assign out6_O = in6_O;
                       assign out7_O = in6_O;
                       assign out6_T = in6_T;
                       assign out7_T = in7_T;
                       assign in6_I = out6_I;
                       assign in7_I = out7_I;
                     end
            default: begin
                        assign out4_O = in4_O;
                        assign out5_O = in5_O;
                        assign out6_O = in6_O;
                        assign out7_O = in7_O;
                        assign out4_T = in4_T;
                        assign out5_T = in5_T;
                        assign out6_T = in6_T;
                        assign out7_T = in7_T;
                        assign in4_I = out4_I;
                        assign in5_I = out5_I;
                        assign in6_I = out6_I;
                        assign in7_I = out7_I;
                     end
         endcase
      endgenerate


endmodule
