
//////////////////////////////////////////////////////////////////////////////////
//
//  这是一个专用的图像处理模块
//  可将输入的新旧两帧图像取新不同并使用蓝噪声纹理进行抖动处理后映射成2bit驱动信号
//
//  | Bit 1 | Bit 0 | Action     |
//  | ----- | ----- | ---------- |
//  | 0     | 0     | No action  |
//  | 0     | 1     | Draw black |
//  | 1     | 0     | Draw white |
//  | 1     | 1     | No action  |
//
//////////////////////////////////////////////////////////////////////////////////

module v_algo
    (
    input wire clk,
    input wire rst_n,

    input wire algo_de,  // 输入使能

    input wire [7:0]    newFrame,
    input wire [7:0]    oldFrame,
    input wire [7:0]    texture,

    output reg          valid_n,  // 低有效
    output reg  [1:0]   data      // 数据输出
    );

    // 有三种情况不需要驱动
    // ① 前后两个像素相等
    // ② 前后两个像素同时大于纹理
    // ③ 前后两个像素同时小于纹理

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            data <= 0;
        end
        else if (algo_de) begin
            if (newFrame > texture) begin
                if (oldFrame > texture) begin
                    data <= 2'b00;  // 不驱动
                end
                if (oldFrame <= texture) begin
                    data <= 2'b10;  // 驱动白
                end
            end
            if (newFrame <= texture) begin
                if (oldFrame <= texture) begin
                    data <= 2'b00;  // 不驱动
                end
                if (oldFrame > texture) begin
                    data <= 2'b01;  // 驱动黑
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            valid_n <= 1;
        end
        else if (algo_de) begin
            valid_n <= 0;
        end
        else begin
            valid_n <= 1;
        end
    end

endmodule
