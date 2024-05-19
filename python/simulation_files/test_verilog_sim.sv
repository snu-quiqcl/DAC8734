`timescale 1ns / 1ps


module test_verilog_sim;
logic Uart_RXD;
logic Uart_TXD;
logic CLK100MHZ;
logic BTN0;
logic BTN1;
logic BTN2;
reg ja_7; //powerdown
reg ja_6; //sdio
reg ja_5; //csb
reg ja_4; //reset
reg ja_3; // sclk
reg ja_2; // powerdown2
reg ja_1; //sdio2
reg ja_0; // csb2
wire jb_0;
wire jb_1;
wire jb_2;
wire jb_3;
wire jb_4;
wire jb_5;
wire jb_6;
wire jb_7;
logic [5:2] led;
logic led0_r;
logic led0_g;
logic led0_b;
logic led1_r;
logic led1_g;
logic led1_b;
logic d5, d4, d3, d2, d1, d0;
wire jc_0;
wire jc_1;
wire jc_2;
wire jc_3;
wire jc_4;
wire jc_5;
wire jc_6;
wire jc_7;
wire jd_0;
wire jd_1;
wire jd_2;
wire jd_3;
wire jd_4;
wire jd_5;
wire jd_6;
wire jd_7;

logic io_val;

assign jc_4 = (~main0.AD9910_driver_0.slave_en_wire)? 1'bz:io_val;

main main0(
    .Uart_RXD(Uart_RXD),
    .Uart_TXD(Uart_TXD),
    .CLK100MHZ(CLK100MHZ),
    .BTN0(BTN0),
    .BTN1(BTN1),
    .BTN2(BTN2),
    .ja_7(ja_7), //powerdown
    .ja_6(ja_6),
    .ja_5(ja_5), //csb
    .ja_4(ja_4), //reset
    .ja_3(ja_3), // sclk
    .ja_2(ja_2), // powerdown2
    .ja_1(ja_1),
    .ja_0(ja_0), // csb2
    .jb_0(jb_0),
    .jb_1(jb_1),
    .jb_2(jb_2),
    .jb_3(jb_3),
    .jb_4(jb_4),
    .jb_5(jb_5),
    .jb_6(jb_6),
    .jb_7(jb_7),
    .jc_0(jc_0),
    .jc_1(jc_1),
    .jc_2(jc_2),
    .jc_3(jc_3),
    .jc_4(jc_4),
    .jc_5(jc_5),
    .jc_6(jc_6),
    .jc_7(jc_7),
    .jd_0(jd_0),
    .jd_1(jd_1),
    .jd_2(jd_2),
    .jd_3(jd_3),
    .jd_4(jd_4),
    .jd_5(jd_5),
    .jd_6(jd_6),
    .jd_7(jd_7),
    .led(led),
    .led0_r(led0_r),
    .led0_g(led0_g),
    .led0_b(led0_b),
    .led1_r(led1_r),
    .led1_g(led1_g),
    .led1_b(led1_b),
    .d5(d5), 
    .d4(d4), 
    .d3(d3), 
    .d2(d2), 
    .d1(d1), 
    .d0(d0) // For debugging purpose    
    );
   
always begin
    #5
    CLK100MHZ = ~CLK100MHZ;
end

int j,k;

parameter MAX_LENGTH = 256;

logic [MAX_LENGTH-1:0] TEMP;
logic [9:0] TEMP_S;
integer i;
initial begin
    //TEMP = (2**256-1) & 256'b 00001010 00001101 11001100 11001100 11001100 00001100 00000000 00000000 11111111 00111111 00001110 00111001 01100001 00110001 00100011;
    //TEMP = (2**256-1) & 256'b 1000010100 1000011010 1110011000 1110011000 1110011000 1000011000 1000000000 1000000000 1111111110 1001111110 1000011100 1001110010 1011000010 1001100010 1001000110;
    
    ja_7 <= 1'b1;
    ja_6 <= 1'b1;
    ja_5 <= 1'b1;
    ja_4 <= 1'b1;
    ja_3 <= 1'b1;
    ja_2 <= 1'b1;
    ja_1 <= 1'b1;
    ja_0 <= 1'b1;
    
    Uart_RXD = 1;
    CLK100MHZ = 0;
    BTN0 = 0;
    BTN1 = 0;
    BTN2 = 0;
    io_val = 1;

    #1000
    TEMP =((2**256 - 1) - (2**90- 1)) + 256'b100001010010000110101100110010100011001010000010001000000010100110100010011000101001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**130- 1)) + 256'b1000010100100001101010100011101010001010101010010010010000001010001010101010100010100100101010100100101010111010011100101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
end
endmodule