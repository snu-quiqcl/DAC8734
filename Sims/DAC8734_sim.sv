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
localparam SPI_CLK                       = 50000000; // 50MHz

reg Uart_RXD;
reg CLK100MHZ;
reg BTN0;
reg BTN1;
reg BTN2;

wire Uart_TXD;
wire [7:0] DAC_CSB;
wire [7:0] DAC_SCLK;
wire [7:0] DAC_SDO;

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
    .ck_io_39                           (DAC_CSB[0]), 
    .ck_io_38                           (DAC_SCLK[0]), 
    .ck_io_37                           (DAC_SDO[0]), // DAC0
    .ck_io_36                           (DAC_CSB[1]), 
    .ck_io_35                           (DAC_SCLK[1]), 
    .ck_io_34                           (DAC_SDO[1]), // DAC1
    .ck_io_31                           (DAC_CSB[6]), 
    .ck_io_30                           (DAC_SCLK[6]), 
    .ck_io_29                           (DAC_SDO[6]), // DAC6
    .ck_io_28                           (DAC_CSB[7]), 
    .ck_io_27                           (DAC_SCLK[7]), 
    .ck_io_26                           (DAC_SDO[7]), // DAC7
    .ck_io_13                           (DAC_CSB[2]), 
    .ck_io_12                           (DAC_SCLK[2]), 
    .ck_io_11                           (DAC_SDO[2]), // DAC2
    .ck_io_10                           (DAC_CSB[3]), 
    .ck_io_9                            (DAC_SCLK[3]), 
    .ck_io_8                            (DAC_SDO[3]), // DAC3
    .ck_io_5                            (DAC_CSB[4]), 
    .ck_io_4                            (DAC_SCLK[4]), 
    .ck_io_3                            (DAC_SDO[4]), // DAC4
    .ck_io_2                            (DAC_CSB[5]), 
    .ck_io_1                            (DAC_SCLK[5]), 
    .ck_io_0                            (DAC_SDO[5]), // DAC5
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
// SPI Verification Task
//////////////////////////////////////////////////////////////////////////////////
wire csb, sclk, sdo;
assign csb = &DAC_CSB;
assign sclk = |((~DAC_CSB) & DAC_SCLK);
assign sdo = |((~DAC_CSB) & DAC_SDO);
                   
task automatic verify_spi_data();
    begin
        int k;
        reg [23:0] received_data;
        int dac_channel;

        @(negedge csb);
        case(~DAC_CSB)
            8'b10000000: begin
                dac_channel = 7;
            end
            8'b01000000: begin
                dac_channel = 6;
            end
            8'b00100000: begin
                dac_channel = 5;
            end
            8'b00010000: begin
                dac_channel = 4;
            end
            8'b00001000: begin
                dac_channel = 3;
            end
            8'b00000100: begin
                dac_channel = 2;
            end
            8'b00000010: begin
                dac_channel = 1;
            end
            8'b00000001: begin
                dac_channel = 0;
            end
            default: begin
                $display("Invalid DAC channel: %x", ~DAC_CSB);
                $finish;
            end
        endcase

        // Read the data from the SPI bus
        for (k = 23; k >= 0; k = k - 1) begin
            @(negedge sclk);
            received_data[k] = sdo;
        end

        // Wait for the CSB to go high, indicating the end of SPI communication
        @(posedge csb);
        
        $display("DAC channel %0d, address %0h, data %0h", dac_channel, received_data[23:16], received_data[15:0]);
    end
endtask

initial begin
    forever begin
        verify_spi_data();
    end
end

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
    
    
    //////////////////////////////////////////////////////////////////////////////////
    // UART simulation code to be written
    //////////////////////////////////////////////////////////////////////////////////
    /*
    * output of python file
     */
    #10000000;
    /*
    * b'#14\x01\x04\x19\x99\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(72'b000010100000110110011001000110010000010000000001001101000011000100100011);
    uart_transmit(BaudRate,72,uart_data);
    /*
    * b'!9WRITE REG\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(104'b00001010000011010100011101000101010100100010000001000101010101000100100101010010010101110011100100100001);
    uart_transmit(BaudRate,104,uart_data);
    /*
    * b'#14\x02\x04\x19\x99\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(72'b000010100000110110011001000110010000010000000010001101000011000100100011);
    uart_transmit(BaudRate,72,uart_data);
    /*
    * b'!9WRITE REG\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(104'b00001010000011010100011101000101010100100010000001000101010101000100100101010010010101110011100100100001);
    uart_transmit(BaudRate,104,uart_data);
    /*
    * b'#14\x04\x04\x19\x99\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(72'b000010100000110110011001000110010000010000000100001101000011000100100011);
    uart_transmit(BaudRate,72,uart_data);
    /*
    * b'!9WRITE REG\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(104'b00001010000011010100011101000101010100100010000001000101010101000100100101010010010101110011100100100001);
    uart_transmit(BaudRate,104,uart_data);
    /*
    * b'#14\x08\x04\x19\x99\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(72'b000010100000110110011001000110010000010000001000001101000011000100100011);
    uart_transmit(BaudRate,72,uart_data);
    /*
    * b'!9WRITE REG\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(104'b00001010000011010100011101000101010100100010000001000101010101000100100101010010010101110011100100100001);
    uart_transmit(BaudRate,104,uart_data);
    /*
    * b'#14\x10\x10\x04\x19\x99\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(80'b00001010000011011001100100011001000001000001000000010000001101000011000100100011);
    uart_transmit(BaudRate,80,uart_data);
    /*
    * b'!9WRITE REG\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(104'b00001010000011010100011101000101010100100010000001000101010101000100100101010010010101110011100100100001);
    uart_transmit(BaudRate,104,uart_data);
    /*
    * b'#14 \x04\x19\x99\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(72'b000010100000110110011001000110010000010000100000001101000011000100100011);
    uart_transmit(BaudRate,72,uart_data);
    /*
    * b'!9WRITE REG\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(104'b00001010000011010100011101000101010100100010000001000101010101000100100101010010010101110011100100100001);
    uart_transmit(BaudRate,104,uart_data);
    /*
    * b'#14@\x04\x19\x99\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(72'b000010100000110110011001000110010000010001000000001101000011000100100011);
    uart_transmit(BaudRate,72,uart_data);
    /*
    * b'!9WRITE REG\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(104'b00001010000011010100011101000101010100100010000001000101010101000100100101010010010101110011100100100001);
    uart_transmit(BaudRate,104,uart_data);
    /*
    * b'#14\x80\x04\x19\x99\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(72'b000010100000110110011001000110010000010010000000001101000011000100100011);
    uart_transmit(BaudRate,72,uart_data);
    /*
    * b'!9WRITE REG\r\n'
     */
    #1000;
    uart_data = MAX_UART_LEN'(104'b00001010000011010100011101000101010100100010000001000101010101000100100101010010010101110011100100100001);
    uart_transmit(BaudRate,104,uart_data);
    #10000000;
    /*
    * End of simulation
     */
    $finish;

end
    


endmodule
