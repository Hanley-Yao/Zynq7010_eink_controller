
module i2c_top #(
    parameter WMEN_LEN     = 8'd1,
    parameter RMEN_LEN     = 8'd1,
    parameter SYS_CLK_FREQ = 50,
    parameter SCL_FREQ     = 100
    )(
    input wire                      clk_i,
    input wire                      rst_n,
    output reg                      iic_scl,
    inout wire                      iic_sda,
    input wire  [WMEN_LEN*8 -1:0]   wr_data,    //write data
    input wire  [7:0]               wr_cnt,     //write data lenth include device address
    output reg  [RMEN_LEN*8 -1:0]   rd_data,    //read data
    input wire  [7:0]               rd_cnt,     //read data lenth
    input wire                      iic_en,     //iic_en == 1 enable iic transmit
    input wire                      iic_mode,   //iic_mode = 1 random read iic_mode = 0 current read or page read
    output reg                      iic_busy,   //iic controller busy
    output reg                      sda_dg      //for ila debug
    );

    localparam IDLE   = 4'd0;
    localparam START  = 4'd1;
    localparam W_WAIT = 4'd2;
    localparam W_ACK  = 4'd3;
    localparam R_WAIT = 4'd4;
    localparam R_ACK  = 4'd5;
    localparam STOP1  = 4'd6;
    localparam STOP2  = 4'd7;

    localparam CLK_DIV = SYS_CLK_FREQ * 500 / SCL_FREQ - 1;

    reg [2:0] IIC_S = 4'd0;
    //generate  scl
    reg [15:0] clkdiv = 16'd0;
    reg scl_clk = 1'b0;

    always@(posedge clk_i)
        if(clkdiv < CLK_DIV)
            clkdiv <= clkdiv + 1'b1;
        else begin
            clkdiv <= 16'd0;
            scl_clk <= !scl_clk;
        end

    localparam OFFSET = CLK_DIV - CLK_DIV/4;
    wire scl_offset  = (clkdiv == OFFSET);//scl delay output to fit timing

    reg scl_r;
    reg sda_o;
    reg [7:0] sda_r;
    reg [7:0] sda_i_r;
    reg [7:0] wcnt;
    reg [7:0] rcnt;
    reg [2:0] bcnt;
    reg rd_en;
    wire sda_i;

    IOBUF #(
            .DRIVE(12), // Specify the output drive strength
            .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE"
            .IOSTANDARD("DEFAULT"), // Specify the I/O standard
            .SLEW("SLOW") // Specify the output slew rate
        ) IOBUF_inst (
            .O(sda_i),    // Buffer output
            .IO(iic_sda), // Buffer inout port (connect directly to top-level port)
            .I(sda_o),    // Buffer input
            .T(sda_o)     // 3-state enable input, high=input, low=output
        );

    always @(posedge clk_i) iic_scl <=  scl_offset ?  scl_r : iic_scl;
    // Pullup output (connect directly to top-level port)
    PULLUP PULLUP_inst (.O(iic_sda));
    //scl output
    always @(*) begin
        if(IIC_S == IDLE || IIC_S == STOP1 || IIC_S == STOP2)
            scl_r <= 1'b1;
        else
            scl_r <= ~scl_clk;
    end
    //sda output
    always @(*) begin
        if(IIC_S == START || IIC_S == STOP1 || (IIC_S == R_ACK && (rcnt != rd_cnt)))
            sda_o <= 1'b0;
        else if(IIC_S == W_WAIT)
            sda_o <= sda_r[7];
        else  sda_o <= 1'b1;
    end
    //sda output shift
    always @(negedge scl_clk or negedge rst_n) begin
        if (!rst_n) begin
            sda_r <= 8'b0;
        end
        else if(IIC_S == W_ACK || IIC_S == START)begin
            sda_r <= wr_data[(wcnt*8) +: 8];
            if( rd_en ) sda_r <= {wr_data[7:1],1'b1};
        end
        else if(IIC_S == W_WAIT)
            sda_r <= {sda_r[6:0],1'b1};
        else
            sda_r <= sda_r;
    end
    //sda input shift
    always @(posedge scl_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data <= 0;
            sda_i_r <= 8'd0;
        end
        else if(IIC_S == R_WAIT ||IIC_S == W_ACK ) begin
            sda_i_r <= {sda_i_r[6:0],sda_i};
        end
        else if(IIC_S == R_ACK)
            rd_data[((rcnt-1'b1)*8) +: 8] <= sda_i_r[7:0];
        else if(IIC_S == IDLE)begin
            sda_i_r <= 8'd0;
        end
    end

    reg iic_sda_r;

    always @(posedge scl_clk or negedge rst_n) begin
        if (!rst_n) begin
            iic_sda_r = 1'b1;
        end
        else begin
            iic_sda_r <= sda_i;
        end
    end
    always @(posedge clk_i) sda_dg <= sda_i;

    //iic state machine
    always @(negedge scl_clk)begin
            case(IIC_S) //sda = 1 scl =1
            IDLE://idle wait iic_en == 1'b1 start trasmit   rd_en == 1'b1 restart
            if(iic_en == 1'b1 || rd_en == 1'b1)begin
               iic_busy <= 1'b1;
               IIC_S  <= START;
            end
            else begin
               iic_busy <= 1'b0;
               wcnt <= 8'd0;
               rcnt <= 8'd0;
               rd_en <= 1'b0;
            end
            START:begin //sda = 0  then scl_clk =0 scl =0 generate start
               bcnt <= 3'd7;
               IIC_S  <= W_WAIT;
            end
            W_WAIT://write data
            begin
               if(bcnt > 3'd0)
                   bcnt  <= bcnt - 1'b1;
               else begin
                   wcnt <= wcnt + 1'b1;
                   IIC_S  <= W_ACK;
               end
            end
            W_ACK://write data ack
            begin
               if(wcnt < wr_cnt)begin
                  bcnt <= 3'd7;
                  IIC_S <= W_WAIT;
               end
               else if(rd_cnt > 3'd0)begin// read data
                  if(rd_en == 1'b0 && iic_mode == 1'b1)begin
                      rd_en <= 1'b1;
                      IIC_S <= IDLE;
                  end
                  else
                      IIC_S <= R_WAIT;
                  bcnt <= 3'd7;
               end
               else
                  IIC_S <= STOP1;
                  if(iic_sda_r == 1'b1)
                  IIC_S <= STOP1;
            end
            R_WAIT://read data
            begin
               rd_en <= 1'b0;
               bcnt  <= bcnt - 1'b1;
               if(bcnt == 3'd0)begin
                  rcnt <= (rcnt < rd_cnt) ? (rcnt + 1'b1) : rcnt;
                  IIC_S  <= R_ACK;
               end
            end
            R_ACK://read date ack
            begin
               bcnt <= 3'd7;
               IIC_S <= (rcnt < rd_cnt) ? R_WAIT : STOP1;
            end
            STOP1://sda = 0 scl = 1
                IIC_S <= STOP2;
            STOP2://sda = 1 scl = 1
                IIC_S <= IDLE;
            default:
                IIC_S <= IDLE;
        endcase
    end

endmodule
