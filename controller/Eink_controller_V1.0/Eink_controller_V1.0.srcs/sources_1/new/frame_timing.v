
//////////////////////////////////////////////////////////////////////////////////////////////
//
//  设计支持最大分辨率
//  H(max) = 2200 [11:0]
//  V(max) = 1872 [10:0]
//
//  时序部分我也没弄明白到底咋回事
//  不过按照规格书的时序需求我推导出了一些公式
//
//  pix_Freq(max) = 125Mhz
//
//  tLEdly(min) = 40ns   这几个值可以从规格书中得到
//  tLEw(min)   = 40ns   大部分屏幕采用的参数都是这几个
//  tLEoff(min) = 200ns  当时少部分屏幕的时序要求不太一样
//
//  指令周期: tcy = 1x10^9ns / pix_Freq
//
//  循环周期: N_SKV = V + 5
//
//  由于可能出现tcy大于被除数的情况导致int值为0,故采用
//
//  向上取整公式: (a+b-1)/b 进行计算
//
//  持续周期:
//
//  T_SKV = H/4 + tLEdly/tcy + tLEw/tcy + tLEoff/tcy
//
//  萝莉分析仪测13.3以及9.7的时序得 SKV为高的占Data的比例
//
//  | ED097TC2 | 0.88 |
//  | ES133UT1 | 0.9  |
//
//  由于SPV持续高时屏幕刷新行,持续越久行通电时间越久
//  所以取值理论上是可变的但是其最大值应该是:
//
//  T_SKV_H(max) = H/4
//
//  目前我还不知道该值如何计算,故取0.9占空比以后再优化调整
//
//  XLE拉高应该在SKV拉低之后XLE_H个XCL周期:
//
//  XLE_H = (T_SKV - T_SKV_H - LEdly - LEw - LEoff) / 2
//
//  XSTL拉低应在XLE拉高后tLEw + tLEoff个XCL周期:
//
//  XSTL_L = XLE_H + + tLEw + tLEoff
//
//  SPV拉低: SPV_L = T_SKV_H / 2
//
//  如果使用该模块生成的时序参数不能让你的屏幕正常工作
//  那么请通过萝莉分析仪抓取数据✔
//  想要获得正确的时序你需要按照下面这两个例子操作
//
//
// Demo_1:
//
//  | IT8951_Timing | H    | V    | Freq | Wide |
//  | ------------- | ---- | ---- | ---- | ---- |
//  | ES133UT1      | 1600 | 1200 | 65Hz | 8bit |
//
//  iLA_logic_Freq = 240Mhz
//
//  XCL = 40Mhz
//
//  cty = 25ns
//
//
//  SKV循环V+5个周期
//
//  一个SKV周期占440个XCL周期,SKV在第398个XCL周期时低保持
//
//  SPV在第一个SKV周期开始后185个XCL周期后拉低440个XCL周期后高保持
//
//
//  XSTL和XLE循环V个周期
//
//  XSTL在第四个SKV周期开始后432个XCL时低保持二个XCL周期 (在SKV低后32个XCL周期  432 = 32+400)
//
//  XLE在第五个SKV周期开始后420个XCL时高保持二个XCL周期 (在SKV低后20个XCL周期  420 = 20+400)
//
//
//  ED097TC2数据分析:
//
//  XLE前与数据间距:(420-400)*tcy = 500ns
//
//  XLE高保持时间:2*cty = 50ns
//
//  XLE后与数据间距:(432-420-2)*tcy = 250ns
//
//  H        = 1200
//  V        = 825
//  N_SKV    = 830
//  T_SKV    = 344
//  T_SKV_H  = 265
//  SPV_L    = 131
//  XLE_H    = 322
//  XLE_H_K  = 4
//  XSTL_L   = 330
//  XSTL_L_K = 2
//
//
// Demo_2:
//
//  | IT8951_Timing | H    | V    | Freq | Wide |
//  | ------------- | ---- | ---- | ---- | ---- |
//  | ED097TC2      | 1200 | 825  | 85Hz | 8bit |
//
//  iLA_logic_Freq = 240Mhz
//
//  XCL = 24Mhz
//
//  cty = 41.6ns
//
//
//  SKV循环V+5个周期
//
//  一个SKV周期占344个XCL周期,SKV在第265个XCL周期时低保持
//
//  SPV在第一个SKV周期开始后131个XCL周期后拉低344个XCL周期后高保持
//
//
//  XSTL和XLE循环V个周期
//
//  XSTL在第四个SKV周期开始后330个XCL时低保持四个XCL周期 (在SKV低后65个XCL周期  330 = 65+265)
//
//  XLE在第五个SKV周期开始后322个XCL时高保持二个XCL周期 (在SKV低后57个XCL周期  322 = 57+265)
//
//
//  ES133UT1数据分析:
//
//  XLE前与数据间距:(322-265)*tcy = 2371.2ns
//
//  XLE高保持时间:2*cty = 166.4ns
//
//  XLE后与数据间距:(330-322-4)*tcy = 166.4ns
//
//  H        = 1600
//  V        = 1200
//  N_SKV    = 1205
//  T_SKV    = 440
//  T_SKV_H  = 398
//  SPV_L    = 185
//  XLE_H    = 420
//  XLE_H_K  = 2
//  XSTL_L   = 432
//  XSTL_L_K = 2
//
//////////////////////////////////////////////////////////////////////////////////////////////

module frame_timing
    #(
    // 屏幕信息
    parameter EPD_WID   = 8,
    parameter EPD_FREQ  = 25,
    parameter EPD_H     = 1200,
    parameter EPD_V     = 825,
    // 时序信息
    parameter tLEdly    = 40,
    parameter tLEw      = 40,
    parameter tLEoff    = 200
    )
    (
    input wire          clk,
    input wire          rst_n,

    output reg  [10:0]  N_SKV,      // 循环周期数
    output reg  [10:0]  T_SKV,      // SKV持续XCL周期
    output reg  [10:0]  T_SKV_H,    // SKV高保持XCL周期
    output reg  [10:0]  SPV_L,      // SPV拉低
    output reg  [10:0]  XLE_H,      // XLE拉高
    output reg  [10:0]  XLE_H_K,    // XLE高保持时间
    output reg  [10:0]  XSTL_L,     // XSTL拉低
    output reg  [10:0]  XSTL_L_K    // XSTL低保持时间
    );

    localparam  CNT_1S = 1000000000;  // 1s = 1000000000ns

    reg [10:0]  OUT_cty;
    reg [10:0]  OUT_T_LEdly;
    reg [10:0]  OUT_XLE_H_K;
    reg [10:0]  OUT_T_LEoff;
    reg [10:0]  OUT_T_SKV;
    reg [10:0]  OUT_T_SKV_H;
    reg [10:0]  OUT_XLE_H;
    reg [10:0]  OUT_T_N_SKV;
    reg [10:0]  OUT_SPV_L;
    reg [10:0]  OUT_XSTL_L;
    reg [10:0]  OUT_XSTL_L_K;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            OUT_cty      <= 0;
            OUT_T_LEdly  <= 0;
            OUT_XLE_H_K  <= 0;
            OUT_T_LEoff  <= 0;
            OUT_T_SKV    <= 0;
            OUT_T_SKV_H  <= 0;
            OUT_T_N_SKV  <= 0;
            OUT_SPV_L    <= 0;
            OUT_XLE_H    <= 0;
            OUT_XSTL_L   <= 0;
        end
        else begin
            OUT_cty      = CNT_1S / (EPD_FREQ * 20'd1000000);
            OUT_T_LEdly  = (tLEdly + OUT_cty - 1) / OUT_cty;
            OUT_XLE_H_K  = (tLEw   + OUT_cty - 1) / OUT_cty;
            OUT_T_LEoff  = (tLEoff + OUT_cty - 1) / OUT_cty;
            OUT_T_SKV    = (EPD_H / 4) + OUT_T_LEdly + OUT_XLE_H_K + OUT_T_LEoff;
            OUT_T_SKV_H  = (EPD_H / 4) * 0.95;  // SKV为高的周期数占Data所需周期数的0.8
            OUT_T_N_SKV  = EPD_V + 5;
            OUT_SPV_L    = OUT_T_SKV_H / 2;
            OUT_XLE_H    = (OUT_T_SKV - OUT_T_SKV_H - OUT_T_LEdly - OUT_XLE_H_K - OUT_T_LEoff) / 2 + OUT_T_SKV_H;
            OUT_XSTL_L   = OUT_XLE_H + OUT_XLE_H_K + OUT_T_LEoff;
            OUT_XSTL_L_K = EPD_H / 4;

            N_SKV        = OUT_T_N_SKV - 1;  // 时序补偿
            T_SKV        = OUT_T_SKV - 1;
            T_SKV_H      = OUT_T_SKV_H;
            SPV_L        = OUT_SPV_L;
            XLE_H        = OUT_XLE_H;
            XLE_H_K      = OUT_XLE_H_K - 1;
            XSTL_L       = OUT_XSTL_L;
            XSTL_L_K     = OUT_XSTL_L_K - 1;
        end
    end

endmodule