
module config_reg_et073tc1 #(
    parameter VCOM=2780)  // -2.78V
    (
    input      [8 :0]  REG_INDEX,
    output reg [39:0]  REG_DATA,
    output     [8 :0]  REG_SIZE
    );

    localparam vcom = VCOM/10;

    assign  REG_SIZE = 9'd183;

    //-----------------------------------------------------------------
    /////////////////////   Config Data REG   //////////////////////////
    always@(*)
    case(REG_INDEX)
    //write Data Index       len    addr  data_0 data_1 data_2
        0   : REG_DATA  =   {8'd3, 8'h98, 8'hF4, 8'h80, 8'h00};  // CEC Map I2C address
        1   : REG_DATA  =   {8'd3, 8'h98, 8'hF5, 8'h7c, 8'h00};  // INFOFRAME Map I2C address
        2   : REG_DATA  =   {8'd3, 8'h98, 8'hF8, 8'h4c, 8'h00};  // DPLL Map I2C address
        3   : REG_DATA  =   {8'd3, 8'h98, 8'hF9, 8'h64, 8'h00};  // KSV Map I2C address
        4   : REG_DATA  =   {8'd3, 8'h98, 8'hFA, 8'h6c, 8'h00};  // EDID Map I2C address
        5   : REG_DATA  =   {8'd3, 8'h98, 8'hFB, 8'h68, 8'h00};  // HDMI Map I2C address
        6   : REG_DATA  =   {8'd3, 8'h98, 8'hFD, 8'h44, 8'h00};  // CP Map I2C address
        7   : REG_DATA  =   {8'd3, 8'h98, 8'h01, 8'h05, 8'h00};  // Prim_Mode = 110b HDMI-GR
        8   : REG_DATA  =   {8'd3, 8'h98, 8'h00, 8'h13, 8'h00};
        // data_1 = [F0] YUV [F2]RGB
        9   : REG_DATA  =   {8'd3, 8'h98, 8'h02, 8'hF0, 8'h00};
        // data_1 = [40] 24-Bit SDR 444 Mode
        // data_1 = [80] 16-Bit SDR 422 Mode
        10  : REG_DATA  =   {8'd3, 8'h98, 8'h03, 8'h80, 8'h00};
        11  : REG_DATA  =   {8'd3, 8'h98, 8'h04, 8'h42, 8'h00};  // OP_CH_SEL
        12  : REG_DATA  =   {8'd3, 8'h98, 8'h05, 8'h28, 8'h00};  // AV Codes Off
        13  : REG_DATA  =   {8'd3, 8'h98, 8'h06, 8'ha7, 8'h00};  //
        14  : REG_DATA  =   {8'd3, 8'h98, 8'h0b, 8'h44, 8'h00};  // Power up part
        15  : REG_DATA  =   {8'd3, 8'h98, 8'h0C, 8'h42, 8'h00};  // Power up part
        16  : REG_DATA  =   {8'd3, 8'h98, 8'h15, 8'h80, 8'h00};  // Disable Tristate of Pins
        17  : REG_DATA  =   {8'd3, 8'h98, 8'h19, 8'h8a, 8'h00};  // LLC DLL phase
        18  : REG_DATA  =   {8'd3, 8'h98, 8'h33, 8'h40, 8'h00};  // LLC DLL enable
        19  : REG_DATA  =   {8'd3, 8'h98, 8'h14, 8'h3f, 8'h00};  // Max Drive Strength
        20  : REG_DATA  =   {8'd3, 8'h44, 8'hba, 8'h01, 8'h00};  // Set HDMI FreeRun
        21  : REG_DATA  =   {8'd3, 8'h44, 8'h7c, 8'h01, 8'h00};  //
        22  : REG_DATA  =   {8'd3, 8'h64, 8'h40, 8'h81, 8'h00};  // Disable HDCP 1.1 features
        23  : REG_DATA  =   {8'd3, 8'h68, 8'h9b, 8'h03, 8'h00};  // ADI recommanded setting
        24  : REG_DATA  =   {8'd3, 8'h68, 8'hc1, 8'h01, 8'h00};  // ADI recommanded setting
        25  : REG_DATA  =   {8'd3, 8'h68, 8'hc2, 8'h01, 8'h00};  // ADI recommanded setting
        26  : REG_DATA  =   {8'd3, 8'h68, 8'hc3, 8'h01, 8'h00};  // ADI recommanded setting
        27  : REG_DATA  =   {8'd3, 8'h68, 8'hc4, 8'h01, 8'h00};  // ADI recommanded setting
        28  : REG_DATA  =   {8'd3, 8'h68, 8'hc5, 8'h01, 8'h00};  // ADI recommanded setting
        29  : REG_DATA  =   {8'd3, 8'h68, 8'hc6, 8'h01, 8'h00};  // ADI recommanded setting
        30  : REG_DATA  =   {8'd3, 8'h68, 8'hc7, 8'h01, 8'h00};  // ADI recommanded setting
        31  : REG_DATA  =   {8'd3, 8'h68, 8'hc8, 8'h01, 8'h00};  // ADI recommanded setting
        32  : REG_DATA  =   {8'd3, 8'h68, 8'hc9, 8'h01, 8'h00};  // ADI recommanded setting
        33  : REG_DATA  =   {8'd3, 8'h68, 8'hca, 8'h01, 8'h00};  // ADI recommanded setting
        34  : REG_DATA  =   {8'd3, 8'h68, 8'hcb, 8'h01, 8'h00};  // ADI recommanded setting
        35  : REG_DATA  =   {8'd3, 8'h68, 8'hcc, 8'h01, 8'h00};  // ADI recommanded setting
        36  : REG_DATA  =   {8'd3, 8'h68, 8'h00, 8'h00, 8'h00};  // Set HDMI input Port A
        37  : REG_DATA  =   {8'd3, 8'h68, 8'h83, 8'hfe, 8'h00};  // terminator for Port A
        38  : REG_DATA  =   {8'd3, 8'h68, 8'h6f, 8'h08, 8'h00};  // ADI recommended setting
        39  : REG_DATA  =   {8'd3, 8'h68, 8'h85, 8'h1f, 8'h00};  // ADI recommended setting
        40  : REG_DATA  =   {8'd3, 8'h68, 8'h87, 8'h70, 8'h00};  // ADI recommended setting
        41  : REG_DATA  =   {8'd3, 8'h68, 8'h8d, 8'h04, 8'h00};  // LFG
        42  : REG_DATA  =   {8'd3, 8'h68, 8'h8e, 8'h1e, 8'h00};  // HFG
        43  : REG_DATA  =   {8'd3, 8'h68, 8'h1a, 8'h8a, 8'h00};  // unmute audio
        44  : REG_DATA  =   {8'd3, 8'h68, 8'h57, 8'hda, 8'h00};  // ADI recommended setting
        45  : REG_DATA  =   {8'd3, 8'h68, 8'h58, 8'h01, 8'h00};  // ADI recommended setting
        46  : REG_DATA  =   {8'd3, 8'h68, 8'h75, 8'h10, 8'h00};  // DDC drive strength
        47  : REG_DATA  =   {8'd3, 8'h68, 8'h6c, 8'ha3, 8'h00};  // enable manual HPA
        48  : REG_DATA  =   {8'd3, 8'h98, 8'h20, 8'h70, 8'h00};  // HPD low
        49  : REG_DATA  =   {8'd3, 8'h64, 8'h74, 8'h00, 8'h00};  // Disable the Internal EDID
    //edid par  200x750 60Hz
        50  : REG_DATA  =   {8'd3, 8'h6c, 8'd0 , 8'h00, 8'h00};
        51  : REG_DATA  =   {8'd3, 8'h6c, 8'd1 , 8'hff, 8'h00};
        52  : REG_DATA  =   {8'd3, 8'h6c, 8'd2 , 8'hff, 8'h00};
        53  : REG_DATA  =   {8'd3, 8'h6c, 8'd3 , 8'hff, 8'h00};
        54  : REG_DATA  =   {8'd3, 8'h6c, 8'd4 , 8'hff, 8'h00};
        55  : REG_DATA  =   {8'd3, 8'h6c, 8'd5 , 8'hff, 8'h00};
        56  : REG_DATA  =   {8'd3, 8'h6c, 8'd6 , 8'hff, 8'h00};
        57  : REG_DATA  =   {8'd3, 8'h6c, 8'd7 , 8'h00, 8'h00};
        58  : REG_DATA  =   {8'd3, 8'h6c, 8'd8 , 8'h04, 8'h00};
        59  : REG_DATA  =   {8'd3, 8'h6c, 8'd9 , 8'h72, 8'h00};
        60  : REG_DATA  =   {8'd3, 8'h6c, 8'd10, 8'h14, 8'h00};
        61  : REG_DATA  =   {8'd3, 8'h6c, 8'd11, 8'h04, 8'h00};
        62  : REG_DATA  =   {8'd3, 8'h6c, 8'd12, 8'had, 8'h00};
        63  : REG_DATA  =   {8'd3, 8'h6c, 8'd13, 8'h5c, 8'h00};
        64  : REG_DATA  =   {8'd3, 8'h6c, 8'd14, 8'h80, 8'h00};
        65  : REG_DATA  =   {8'd3, 8'h6c, 8'd15, 8'h72, 8'h00};
        66  : REG_DATA  =   {8'd3, 8'h6c, 8'd16, 8'h1c, 8'h00};
        67  : REG_DATA  =   {8'd3, 8'h6c, 8'd17, 8'h1b, 8'h00};
        68  : REG_DATA  =   {8'd3, 8'h6c, 8'd18, 8'h01, 8'h00};
        69  : REG_DATA  =   {8'd3, 8'h6c, 8'd19, 8'h04, 8'h00};
        70  : REG_DATA  =   {8'd3, 8'h6c, 8'd20, 8'ha5, 8'h00};
        71  : REG_DATA  =   {8'd3, 8'h6c, 8'd21, 8'h3c, 8'h00};
        72  : REG_DATA  =   {8'd3, 8'h6c, 8'd22, 8'h22, 8'h00};
        73  : REG_DATA  =   {8'd3, 8'h6c, 8'd23, 8'h78, 8'h00};
        74  : REG_DATA  =   {8'd3, 8'h6c, 8'd24, 8'h3e, 8'h00};
        75  : REG_DATA  =   {8'd3, 8'h6c, 8'd25, 8'h48, 8'h00};
        76  : REG_DATA  =   {8'd3, 8'h6c, 8'd26, 8'he0, 8'h00};
        77  : REG_DATA  =   {8'd3, 8'h6c, 8'd27, 8'ha5, 8'h00};
        78  : REG_DATA  =   {8'd3, 8'h6c, 8'd28, 8'h58, 8'h00};
        79  : REG_DATA  =   {8'd3, 8'h6c, 8'd29, 8'h50, 8'h00};
        80  : REG_DATA  =   {8'd3, 8'h6c, 8'd30, 8'ha0, 8'h00};
        81  : REG_DATA  =   {8'd3, 8'h6c, 8'd31, 8'h23, 8'h00};
        82  : REG_DATA  =   {8'd3, 8'h6c, 8'd32, 8'h0b, 8'h00};
        83  : REG_DATA  =   {8'd3, 8'h6c, 8'd33, 8'h50, 8'h00};
        84  : REG_DATA  =   {8'd3, 8'h6c, 8'd34, 8'h54, 8'h00};
        85  : REG_DATA  =   {8'd3, 8'h6c, 8'd35, 8'h00, 8'h00};
        86  : REG_DATA  =   {8'd3, 8'h6c, 8'd36, 8'h00, 8'h00};
        87  : REG_DATA  =   {8'd3, 8'h6c, 8'd37, 8'h00, 8'h00};
        88  : REG_DATA  =   {8'd3, 8'h6c, 8'd38, 8'h01, 8'h00};
        89  : REG_DATA  =   {8'd3, 8'h6c, 8'd39, 8'h01, 8'h00};
        90  : REG_DATA  =   {8'd3, 8'h6c, 8'd40, 8'h01, 8'h00};
        91  : REG_DATA  =   {8'd3, 8'h6c, 8'd41, 8'h01, 8'h00};
        92  : REG_DATA  =   {8'd3, 8'h6c, 8'd42, 8'h01, 8'h00};
        93  : REG_DATA  =   {8'd3, 8'h6c, 8'd43, 8'h01, 8'h00};
        94  : REG_DATA  =   {8'd3, 8'h6c, 8'd44, 8'h01, 8'h00};
        95  : REG_DATA  =   {8'd3, 8'h6c, 8'd45, 8'h01, 8'h00};
        96  : REG_DATA  =   {8'd3, 8'h6c, 8'd46, 8'h01, 8'h00};
        97  : REG_DATA  =   {8'd3, 8'h6c, 8'd47, 8'h01, 8'h00};
        98  : REG_DATA  =   {8'd3, 8'h6c, 8'd48, 8'h01, 8'h00};
        99  : REG_DATA  =   {8'd3, 8'h6c, 8'd49, 8'h01, 8'h00};
        100 : REG_DATA  =   {8'd3, 8'h6c, 8'd50, 8'h01, 8'h00};
        101 : REG_DATA  =   {8'd3, 8'h6c, 8'd51, 8'h01, 8'h00};
        102 : REG_DATA  =   {8'd3, 8'h6c, 8'd52, 8'h01, 8'h00};
        103 : REG_DATA  =   {8'd3, 8'h6c, 8'd53, 8'h01, 8'h00};
        104 : REG_DATA  =   {8'd3, 8'h6c, 8'd54, 8'hbd, 8'h00};
        105 : REG_DATA  =   {8'd3, 8'h6c, 8'd55, 8'h04, 8'h00};
        106 : REG_DATA  =   {8'd3, 8'h6c, 8'd56, 8'hee, 8'h00};
        107 : REG_DATA  =   {8'd3, 8'h6c, 8'd57, 8'ha0, 8'h00};
        108 : REG_DATA  =   {8'd3, 8'h6c, 8'd58, 8'h20, 8'h00};
        109 : REG_DATA  =   {8'd3, 8'h6c, 8'd59, 8'hc8, 8'h00};
        110 : REG_DATA  =   {8'd3, 8'h6c, 8'd60, 8'h16, 8'h00};
        111 : REG_DATA  =   {8'd3, 8'h6c, 8'd61, 8'h00, 8'h00};
        112 : REG_DATA  =   {8'd3, 8'h6c, 8'd62, 8'h30, 8'h00};
        113 : REG_DATA  =   {8'd3, 8'h6c, 8'd63, 8'h20, 8'h00};
        114 : REG_DATA  =   {8'd3, 8'h6c, 8'd64, 8'h3a, 8'h00};
        115 : REG_DATA  =   {8'd3, 8'h6c, 8'd65, 8'h00, 8'h00};
        116 : REG_DATA  =   {8'd3, 8'h6c, 8'd66, 8'hbb, 8'h00};
        117 : REG_DATA  =   {8'd3, 8'h6c, 8'd67, 8'h32, 8'h00};
        118 : REG_DATA  =   {8'd3, 8'h6c, 8'd68, 8'h00, 8'h00};
        119 : REG_DATA  =   {8'd3, 8'h6c, 8'd69, 8'h00, 8'h00};
        120 : REG_DATA  =   {8'd3, 8'h6c, 8'd70, 8'h00, 8'h00};
        121 : REG_DATA  =   {8'd3, 8'h6c, 8'd71, 8'h1e, 8'h00};
        122 : REG_DATA  =   {8'd3, 8'h6c, 8'd72, 8'h00, 8'h00};
        123 : REG_DATA  =   {8'd3, 8'h6c, 8'd73, 8'h00, 8'h00};
        124 : REG_DATA  =   {8'd3, 8'h6c, 8'd74, 8'h00, 8'h00};
        125 : REG_DATA  =   {8'd3, 8'h6c, 8'd75, 8'hfc, 8'h00};
        126 : REG_DATA  =   {8'd3, 8'h6c, 8'd76, 8'h00, 8'h00};
        127 : REG_DATA  =   {8'd3, 8'h6c, 8'd77, 8'h58, 8'h00};
        128 : REG_DATA  =   {8'd3, 8'h6c, 8'd78, 8'h47, 8'h00};
        129 : REG_DATA  =   {8'd3, 8'h6c, 8'd79, 8'h32, 8'h00};
        130 : REG_DATA  =   {8'd3, 8'h6c, 8'd80, 8'h37, 8'h00};
        131 : REG_DATA  =   {8'd3, 8'h6c, 8'd81, 8'h30, 8'h00};
        132 : REG_DATA  =   {8'd3, 8'h6c, 8'd82, 8'h48, 8'h00};
        133 : REG_DATA  =   {8'd3, 8'h6c, 8'd83, 8'h55, 8'h00};
        134 : REG_DATA  =   {8'd3, 8'h6c, 8'd84, 8'h0a, 8'h00};
        135 : REG_DATA  =   {8'd3, 8'h6c, 8'd85, 8'h20, 8'h00};
        136 : REG_DATA  =   {8'd3, 8'h6c, 8'd86, 8'h20, 8'h00};
        137 : REG_DATA  =   {8'd3, 8'h6c, 8'd87, 8'h20, 8'h00};
        138 : REG_DATA  =   {8'd3, 8'h6c, 8'd88, 8'h20, 8'h00};
        139 : REG_DATA  =   {8'd3, 8'h6c, 8'd89, 8'h20, 8'h00};
        140 : REG_DATA  =   {8'd3, 8'h6c, 8'd90, 8'h00, 8'h00};
        141 : REG_DATA  =   {8'd3, 8'h6c, 8'd91, 8'h00, 8'h00};
        142 : REG_DATA  =   {8'd3, 8'h6c, 8'd92, 8'h00, 8'h00};
        143 : REG_DATA  =   {8'd3, 8'h6c, 8'd93, 8'h10, 8'h00};
        144 : REG_DATA  =   {8'd3, 8'h6c, 8'd94, 8'h00, 8'h00};
        145 : REG_DATA  =   {8'd3, 8'h6c, 8'd95, 8'h00, 8'h00};
        146 : REG_DATA  =   {8'd3, 8'h6c, 8'd96, 8'h00, 8'h00};
        147 : REG_DATA  =   {8'd3, 8'h6c, 8'd97, 8'h00, 8'h00};
        148 : REG_DATA  =   {8'd3, 8'h6c, 8'd98, 8'h00, 8'h00};
        149 : REG_DATA  =   {8'd3, 8'h6c, 8'd99, 8'h00, 8'h00};
        150 : REG_DATA  =   {8'd3, 8'h6c, 8'd100,8'h00, 8'h00};
        151 : REG_DATA  =   {8'd3, 8'h6c, 8'd101,8'h00, 8'h00};
        152 : REG_DATA  =   {8'd3, 8'h6c, 8'd102,8'h00, 8'h00};
        153 : REG_DATA  =   {8'd3, 8'h6c, 8'd103,8'h00, 8'h00};
        154 : REG_DATA  =   {8'd3, 8'h6c, 8'd104,8'h00, 8'h00};
        155 : REG_DATA  =   {8'd3, 8'h6c, 8'd105,8'h00, 8'h00};
        156 : REG_DATA  =   {8'd3, 8'h6c, 8'd106,8'h00, 8'h00};
        157 : REG_DATA  =   {8'd3, 8'h6c, 8'd107,8'h00, 8'h00};
        158 : REG_DATA  =   {8'd3, 8'h6c, 8'd108,8'h00, 8'h00};
        159 : REG_DATA  =   {8'd3, 8'h6c, 8'd109,8'h00, 8'h00};
        160 : REG_DATA  =   {8'd3, 8'h6c, 8'd110,8'h00, 8'h00};
        161 : REG_DATA  =   {8'd3, 8'h6c, 8'd111,8'h10, 8'h00};
        162 : REG_DATA  =   {8'd3, 8'h6c, 8'd112,8'h00, 8'h00};
        163 : REG_DATA  =   {8'd3, 8'h6c, 8'd113,8'h00, 8'h00};
        164 : REG_DATA  =   {8'd3, 8'h6c, 8'd114,8'h00, 8'h00};
        165 : REG_DATA  =   {8'd3, 8'h6c, 8'd115,8'h00, 8'h00};
        166 : REG_DATA  =   {8'd3, 8'h6c, 8'd116,8'h00, 8'h00};
        167 : REG_DATA  =   {8'd3, 8'h6c, 8'd117,8'h00, 8'h00};
        168 : REG_DATA  =   {8'd3, 8'h6c, 8'd118,8'h00, 8'h00};
        169 : REG_DATA  =   {8'd3, 8'h6c, 8'd119,8'h00, 8'h00};
        170 : REG_DATA  =   {8'd3, 8'h6c, 8'd120,8'h00, 8'h00};
        171 : REG_DATA  =   {8'd3, 8'h6c, 8'd121,8'h00, 8'h00};
        172 : REG_DATA  =   {8'd3, 8'h6c, 8'd122,8'h00, 8'h00};
        173 : REG_DATA  =   {8'd3, 8'h6c, 8'd123,8'h00, 8'h00};
        174 : REG_DATA  =   {8'd3, 8'h6c, 8'd124,8'h00, 8'h00};
        175 : REG_DATA  =   {8'd3, 8'h6c, 8'd125,8'h00, 8'h00};
        176 : REG_DATA  =   {8'd3, 8'h6c, 8'd126,8'h00, 8'h00};
        177 : REG_DATA  =   {8'd3, 8'h6c, 8'd127,8'h14, 8'h00};
        // EDID END
        178 : REG_DATA  =   {8'd3, 8'h64, 8'h74, 8'h01, 8'h00};  // Enable the Internal EDID for Ports
        179 : REG_DATA  =   {8'd3, 8'h98, 8'h20, 8'hf0, 8'h00};  // HPD high
        180 : REG_DATA  =   {8'd3, 8'h68, 8'h6c, 8'ha2, 8'h00};  // disable manual HPA
        181 : REG_DATA  =   {8'd3, 8'h98, 8'hf4, 8'h00, 8'h00};
        // tps65185 config
        182 : REG_DATA  =   {8'd4, 8'hd0, 8'h03, vcom[7:0], vcom[15:8]};
        default:REG_DATA =0;
    endcase


endmodule
