`timescale 1ns / 1ps
`define timeslice 1250

module EEPROM_AT24C64_SIM(
    scl,
    sda
);
    input scl;               //串行时钟线
    inout sda;               //串行数据线

    reg out_flag;            //SDA数据输出的控制信号

    reg[7:0] memory[8191:0]; //数组模拟存储器
    reg[12:0]address;        //地址总线
    reg[7:0]memory_buf;      //数据输入输出寄存器
    reg[7:0]sda_buf;         //SDA数据输出寄存器
    reg[7:0]shift;           //SDA数据输入寄存器
    reg[7:0]addr_byte_h;     //EEPROM存储单元地址高字节寄存器
    reg[7:0]addr_byte_l;     //EEPROM存储单元地址低字节寄存器
    reg[7:0]ctrl_byte;       //控制字寄存器
    reg[1:0]State;           //状态寄存器

    integer i;

    //---------------------------
    parameter
        r7 = 8'b1010_1111,  w7 = 8'b1010_1110,   //main7
        r6 = 8'b1010_1101,  w6 = 8'b1010_1100,   //main6
        r5 = 8'b1010_1011,  w5 = 8'b1010_1010,   //main5
        r4 = 8'b1010_1001,  w4 = 8'b1010_1000,   //main4
        r3 = 8'b1010_0111,  w3 = 8'b1010_0110,   //main3
        r2 = 8'b1010_0101,  w2 = 8'b1010_0100,   //main2
        r1 = 8'b1010_0011,  w1 = 8'b1010_0010,   //main1
        r0 = 8'b1010_0001,  w0 = 8'b1010_0000;   //main0
    //---------------------------

    assign sda = (out_flag == 1) ? sda_buf[7] : 1'bz;

    //------------寄存器和存储器初始化---------------
    initial
    begin
        addr_byte_h    = 0;
        addr_byte_l    = 0;
        ctrl_byte    = 0;
        out_flag     = 0;
        sda_buf      = 0;
        State        = 2'b00;
        memory_buf   = 0;
        address      = 0;
        shift        = 0;

        for(i=0;i<=8191;i=i+1)
            memory[i] = 0;
    end

    //启动信号
    always@(negedge sda)
    begin
        if(scl == 1)
        begin
            State = State + 1;
            if(State == 2'b11)
                disable write_to_eeprom;
        end
    end

    //主状态机
    always@(posedge sda)
    begin
        if(scl == 1)                //停止操作
            stop_W_R;
        else
        begin
            casex(State)
                2'b01:begin
                    read_in;
                    if(ctrl_byte == w7 || ctrl_byte == w6
                        || ctrl_byte == w5  || ctrl_byte == w4
                        || ctrl_byte == w3  || ctrl_byte == w2
                        || ctrl_byte == w1  || ctrl_byte == w0)
                    begin
                        State = 2'b10;
                        write_to_eeprom;    //写操作
                    end
                    else
                        State = 2'b00;
                end

                2'b11:
                    read_from_eeprom;

                default:
                    State = 2'b00;
            endcase
        end
    end     //主状态机结束

    //操作停止
    task stop_W_R;
    begin
        State        = 2'b00;
        addr_byte_h  = 0;
        addr_byte_l  = 0;
        ctrl_byte    = 0;
        out_flag     = 0;
        sda_buf      = 0;
    end
    endtask

    //读进控制字和存储单元地址
    task read_in;
    begin
        shift_in(ctrl_byte);
        shift_in(addr_byte_h);
        shift_in(addr_byte_l);
    end
    endtask

    //EEPROM的写操作
    task write_to_eeprom;
    begin
        shift_in(memory_buf);
        address = {addr_byte_h[4:0], addr_byte_l};
        memory[address] = memory_buf;
        State = 2'b00;
    end
    endtask

    //EEPROM的读操作
    task read_from_eeprom;
    begin
        shift_in(ctrl_byte);
        if(ctrl_byte == r7 || ctrl_byte == w6
            || ctrl_byte == r5  || ctrl_byte == r4
            || ctrl_byte == r3  || ctrl_byte == r2
            || ctrl_byte == r1  || ctrl_byte == r0)
        begin
            address = {addr_byte_h[4:0], addr_byte_l};
            sda_buf = memory[address];
            shift_out;
            State = 2'b00;
        end
    end
    endtask

    //SDA数据线上的数据存入寄存器，数据在SCL的高电平有效
    task shift_in;
        output[7:0]shift;
        begin
            @(posedge scl) shift[7] = sda;
            @(posedge scl) shift[6] = sda;
            @(posedge scl) shift[5] = sda;
            @(posedge scl) shift[4] = sda;
            @(posedge scl) shift[3] = sda;
            @(posedge scl) shift[2] = sda;
            @(posedge scl) shift[1] = sda;
            @(posedge scl) shift[0] = sda;

            @(negedge scl)
            begin
                #`timeslice;
                out_flag = 1;     //应答信号输出
                sda_buf = 0;
            end

            @(negedge scl)
            begin
                #`timeslice;
                out_flag = 0;
            end
        end
    endtask

    //EEPROM存储器中的数据通过SDA数据线输出，数据在SCL低电平时变化
    task shift_out;
    begin
        out_flag = 1;
        for(i=6; i>=0; i=i-1)
        begin
            @(negedge scl);
            #`timeslice;
            sda_buf = sda_buf << 1;
        end
        @(negedge scl) #`timeslice sda_buf[7] = 1;    //非应答信号输出
        @(negedge scl) #`timeslice out_flag = 0;
    end
    endtask

endmodule
