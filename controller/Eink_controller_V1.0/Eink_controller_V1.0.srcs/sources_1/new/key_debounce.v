
// 代码改编于 https://blog.csdn.net/reborn_lee/article/details/89927569

module key_debounce(
    input clk,
    input rst_n,
    input sw_in,
    output reg sw_out
    );

    //按键本身值为1，按下按键后键值为0.
    reg sw_in_r0;

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sw_in_r0 <= 1;
        end
        else begin
            sw_in_r0 <= sw_in;
        end
    end

    wire edge_l, edge_h;
    assign edge_l = sw_in_r0 & (~sw_in); //下降沿检测
    assign edge_h = sw_in & (~sw_in_r0);//上升沿检测

    wire edge_en; //键值变化后，edge_en变为高
    assign edge_en = edge_l | edge_h;

    reg [19:0] count;
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            count <= 0;
        end
        else if(edge_en) begin
            count <= 0;
        end
        else begin
            count <= count + 1;
        end

    end

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sw_out <= 1'b1;
        end
        else if(count == 20'h2BF20) begin
            sw_out <= sw_in;
        end
    end



endmodule