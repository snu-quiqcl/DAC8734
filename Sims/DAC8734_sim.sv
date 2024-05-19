`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/19 16:28:05
// Design Name: 
// Module Name: DAC8734_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DAC8734_sim;

localparam BaudRate                      = 57600;
localparam MAX_UART_LEN                  = 256;

reg Uart_RXD;
reg CLK100MHZ;
reg BTN0;
reg BTN1;
reg BTN2;

wire Uart_TXD;
wire ck_io_39, ck_io_38, ck_io_37; // DAC0
wire ck_io_36, ck_io_35, ck_io_34; // DAC1
wire ck_io_31, ck_io_30, ck_io_29; // DAC6
wire ck_io_28, ck_io_27, ck_io_26; // DAC7
wire ck_io_13, ck_io_12, ck_io_11; // DAC2
wire ck_io_10, ck_io_9, ck_io_8; // DAC3
wire ck_io_5, ck_io_4, ck_io_3; // DAC4
wire ck_io_2, ck_io_1, ck_io_0; // DAC5

wire ck_io_6; // LDAC
wire ja_0;
wire ja_1;
wire ja_2;
wire ja_3;
wire ja_4;
wire ja_5;
wire ja_6;
wire ja_7;

wire jb_0;
wire jb_1;
wire jb_2;
wire jb_3;
wire jb_4;
wire jb_5;
wire jb_6;
wire jb_7;

wire [5:2] led;
wire led0_r;
wire led0_g;
wire led0_b;
wire led1_r;
wire led1_g;
wire led1_b;
wire d5, d4, d3, d2, d1, d0; // For debugging purpose

reg  [MAX_UART_LEN-1:0] uart_data;

//////////////////////////////////////////////////////////////////////////////////
// DUT declaration
//////////////////////////////////////////////////////////////////////////////////
main_without_capture_waveform_data dut (
    .Uart_RXD                           (Uart_RXD),
    .Uart_TXD                           (Uart_TXD),
    .CLK100MHZ                          (CLK100MHZ),
    .BTN0                               (BTN0),
    .BTN1                               (BTN1),
    .BTN2                               (BTN2),
    .ck_io_39                           (ck_io_39), 
    .ck_io_38                           (ck_io_38), 
    .ck_io_37                           (ck_io_37), // DAC0
    .ck_io_36                           (ck_io_36), 
    .ck_io_35                           (ck_io_35), 
    .ck_io_34                           (ck_io_34), // DAC1
    .ck_io_31                           (ck_io_31), 
    .ck_io_30                           (ck_io_30), 
    .ck_io_29                           (ck_io_29), // DAC6
    .ck_io_28                           (ck_io_28), 
    .ck_io_27                           (ck_io_27), 
    .ck_io_26                           (ck_io_26), // DAC7
    .ck_io_13                           (ck_io_13), 
    .ck_io_12                           (ck_io_12), 
    .ck_io_11                           (ck_io_11), // DAC2
    .ck_io_10                           (ck_io_10), 
    .ck_io_9                            (ck_io_9), 
    .ck_io_8                            (ck_io_8), // DAC3
    .ck_io_5                            (ck_io_5), 
    .ck_io_4                            (ck_io_4), 
    .ck_io_3                            (ck_io_3), // DAC4
    .ck_io_2                            (ck_io_2), 
    .ck_io_1                            (ck_io_1), 
    .ck_io_0                            (ck_io_0), // DAC5
    .ck_io_6                            (ck_io_6), // LDAC
    .ja_0                               (ja_0),
    .ja_1                               (ja_1),
    .ja_2                               (ja_2),
    .ja_3                               (ja_3),
    .ja_4                               (ja_4),
    .ja_5                               (ja_5),
    .ja_6                               (ja_6),
    .ja_7                               (ja_7),
    .jb_0                               (jb_0),
    .jb_1                               (jb_1),
    .jb_2                               (jb_2),
    .jb_3                               (jb_3),
    .jb_4                               (jb_4),
    .jb_5                               (jb_5),
    .jb_6                               (jb_6),
    .jb_7                               (jb_7),
    .led                                (led),
    .led0_r                             (led0_r),
    .led0_g                             (led0_g),
    .led0_b                             (led0_b),
    .led1_r                             (led1_r),
    .led1_g                             (led1_g),
    .led1_b                             (led1_b),
    .d5                                 (d5), 
    .d4                                 (d4), 
    .d3                                 (d3), 
    .d2                                 (d2), 
    .d1                                 (d1), 
    .d0                                 (d0)
);
 
 
//////////////////////////////////////////////////////////////////////////////////
// UART task
//////////////////////////////////////////////////////////////////////////////////
task automatic uart_transmit(
    input integer baudrate,
    input integer trans_len,
    input [MAX_UART_LEN-1:0] data
);
    begin
        int bit_time;
        int i;
        int j;
        int byte_num = (trans_len/8);
        
        if( trans_len % 8 == 0) begin
            byte_num = byte_num;
        end
        else begin
            byte_num = byte_num + 1;
        end
        $display("UART SEND : %x",data);
        bit_time = 1000000000 / baudrate;
        
        for (i = 0; i < byte_num; i = i + 1) begin
            /* 
             *Start bit
             */
            Uart_RXD = 0;
            #(bit_time);
        
            /* 
             * Data bits
             */
            if( i - 1 != byte_num ) begin
                for (j = 0; j < 8; j = j + 1) begin
                    Uart_RXD = data[i * 8 + j];
                    #(bit_time);
                end
            end
            else begin
                if( trans_len % 8 == 0 ) begin
                    for (j = 0; j < 8; j = j + 1) begin
                        Uart_RXD = data[i * 8 + j];
                        #(bit_time);
                    end
                end
                else begin
                    for (j = 0; j < trans_len % 8; j = j + 1) begin
                        Uart_RXD = data[i * 8 + j];
                        #(bit_time);
                    end
                end
            end
        
            /* 
             * Stop bit
             */
            Uart_RXD = 1;
            #(bit_time);
        end
    end
endtask

//////////////////////////////////////////////////////////////////////////////////
// Clock Generation
//////////////////////////////////////////////////////////////////////////////////
initial begin
    CLK100MHZ <= 0;
    forever begin
        #5 CLK100MHZ <= ~CLK100MHZ;
    end
end

//////////////////////////////////////////////////////////////////////////////////
// Main testbench
//////////////////////////////////////////////////////////////////////////////////
initial begin
    Uart_RXD <= 1;
    BTN0 <= 0;
    BTN1 <= 0;
    BTN2 <= 0;
    
    #1000;
    
    
    /*
    * output of python file
    */
    $display("output of python file");
    #10000000;
    /*
    * b'#14\x01\x04\x19\x99\r\n'
    */
    $display("b'#14\x01\x04\x19\x99\r\n'");
    uart_data = MAX_UART_LEN'(72'b000010100000110110011001000110010000010000000001001101000011000100100011);
    uart_transmit(BaudRate,72,uart_data);
    #10000000;
    /*
    * b'!9WRITE REG\r\n'
    */
    $display("b'!9WRITE REG\r\n'");
    uart_data = MAX_UART_LEN'(104'b00001010000011010100011101000101010100100010000001000101010101000100100101010010010101110011100100100001);
    uart_transmit(BaudRate,104,uart_data);
    #10000000;
    $finish;

end
    


endmodule
