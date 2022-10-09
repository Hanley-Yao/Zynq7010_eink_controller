module delay_cnt#
    (
        parameter[31:0]NUM = 32'h00ffff00
    )(
    input wire  clk_i,
    input wire  rstn_i,
    output wire rst_o
    );

    reg [31:0]  cnt;
    reg         rst_d0;

    /*count for clock*/
    always@(posedge clk_i)
    begin
        if(!rstn_i)
        begin
           cnt<=32'd0;
        end
        else begin
           cnt <= ( cnt <= NUM)?( cnt + 32'd1 ):NUM;
        end
    end

    /*generate output signal*/
    always@(posedge clk_i)
    begin
        if(!rstn_i)
        begin
            rst_d0 <= 1'b0;
        end
        else begin
           rst_d0 <= ( cnt >= NUM)?1'b1:1'b0;
        end
    end

    assign rst_o = rst_d0;

endmodule