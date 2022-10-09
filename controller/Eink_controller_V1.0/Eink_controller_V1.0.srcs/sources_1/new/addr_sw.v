
module addr_sw#(
    parameter [31:0] ADDR_0 = 0,
    parameter [31:0] ADDR_1 = 1
    )
    (
    input wire          clk,
    input wire          rst_n,

    input wire          sw,  // 切换

    output reg  [31:0]  new_addr,
    output reg  [31:0]  old_addr
    );

    wire flag;

    level2pulse #(.MODE("RISING")) swflag (.clk(clk), .rst_n(rst_n), .in(sw), .out(flag));

    reg STATE;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            STATE <= 0;
        end
        else if (flag) begin
            STATE <= STATE + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            new_addr <= ADDR_0;
            old_addr <= ADDR_1;
        end
        else begin
            case(STATE)

            0:begin
                new_addr <= ADDR_0;
                old_addr <= ADDR_1;
            end

            1:begin
                new_addr <= ADDR_1;
                old_addr <= ADDR_0;
            end

            endcase
        end
    end

endmodule
