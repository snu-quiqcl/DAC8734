`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// SNU Junho Jeong
// SNU QuIQCL Yongwhan Cha
// 
// Create Date: 2017/11/23 20:28:05
// Design Name: 
// Module Name: main
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
//  The FILE_TYPE of this file is set to SystemVerilog to utilize SystemVerilog features.
//  Generally to apply SystemVerilog syntax, the file extension should be ".sv" rather than ".v"
//  If you want to choose between verilog2001 and SystemVerilog without changing the file extension, 
//  right-click on the file name in "Design Sources", choose "Source Node Properties...", and 
//  change FILE_TYPE in Properties tab.
//////////////////////////////////////////////////////////////////////////////////
function integer bits_to_represent; //https://www.beyond-circuits.com/wordpress/2008/11/constant-functions/
    input integer value;
    begin
        for (bits_to_represent=0; value>0; bits_to_represent=bits_to_represent+1)
            value = value>>1;
    end
endfunction

module main_without_capture_waveform_data(
    input Uart_RXD,
    output Uart_TXD,
    input CLK100MHZ,
    input BTN0,
    input BTN1,
    input BTN2,
    output ck_io_39, ck_io_38, ck_io_37, // DAC0 
    output ck_io_36, ck_io_35, ck_io_34, // DAC1
    output ck_io_31, ck_io_30, ck_io_29, // DAC6
    output ck_io_28, ck_io_27, ck_io_26, // DAC7
    output ck_io_13, ck_io_12, ck_io_11, // DAC2
    output ck_io_10, ck_io_9, ck_io_8, // DAC3
    output ck_io_5, ck_io_4, ck_io_3, // DAC4
    output ck_io_2, ck_io_1, ck_io_0, // DAC5
    
    output ck_io_6, // LDAC
    output ja_0,
    output ja_1,
    output ja_2,
    output ja_3,
    output ja_4,
    output ja_5,
    output ja_6,
    output ja_7,
    
    output jb_0,
    output jb_1,
    output jb_2,
    output jb_3,
    output jb_4,
    output jb_5,
    output jb_6,
    output jb_7,
        
    output [5:2] led,
    output led0_r,
    output led0_g,
    output led0_b,
    output led1_r,
    output led1_g,
    output led1_b,
    output d5, d4, d3, d2, d1, d0 // For debugging purpose    
);
    
    
/////////////////////////////////////////////////////////////////
// UART setting
/////////////////////////////////////////////////////////////////
parameter ClkFreq                       = 100000000;	// make sure this matches the clock frequency on your board
parameter BaudRate                      = 57600;    // Baud rate

/////////////////////////////////////////////////////////////////
// Global setting
/////////////////////////////////////////////////////////////////
parameter BTF_MAX_BYTES                 = 9'h100;
parameter BTF_MAX_BUFFER_WIDTH          = 8 * BTF_MAX_BYTES;
parameter BTF_MAX_BUFFER_COUNT_WIDTH    = bits_to_represent(BTF_MAX_BYTES);

/////////////////////////////////////////////////////////////////
// To receive data from PC
/////////////////////////////////////////////////////////////////
parameter BTF_RX_BUFFER_BYTES           = BTF_MAX_BYTES;
parameter BTF_RX_BUFFER_WIDTH           = BTF_MAX_BUFFER_WIDTH;
parameter BTF_RX_BUFFER_COUNT_WIDTH     = BTF_MAX_BUFFER_COUNT_WIDTH;
parameter CMD_RX_BUFFER_BYTES           = 4'hf;
parameter CMD_RX_BUFFER_WIDTH           = 8 * CMD_RX_BUFFER_BYTES;

wire [BTF_RX_BUFFER_WIDTH:1] BTF_Buffer;
wire [BTF_RX_BUFFER_COUNT_WIDTH-1:0] BTF_Length;

wire [CMD_RX_BUFFER_WIDTH:1] CMD_Buffer;
wire [3:0] CMD_Length;    
wire CMD_Ready;

wire esc_char_detected;
wire [7:0] esc_char;

wire wrong_format;
    

data_receiver receiver(
    .RxD                                (Uart_RXD), 
    .clk                                (CLK100MHZ), 
    .BTF_Buffer                         (BTF_Buffer), 
    .BTF_Length                         (BTF_Length), 
    .CMD_Buffer                         (CMD_Buffer), 
    .CMD_Length                         (CMD_Length), 
    .CMD_Ready                          (CMD_Ready), 
    .esc_char_detected                  (esc_char_detected), 
    .esc_char                           (esc_char),
    .wrong_format                       (wrong_format)
);
defparam receiver.BTF_RX_BUFFER_COUNT_WIDTH = BTF_RX_BUFFER_COUNT_WIDTH;
defparam receiver.BTF_RX_BUFFER_BYTES   = BTF_RX_BUFFER_BYTES; // can be between 1 and 2^BTF_RX_BUFFER_COUNT_WIDTH - 1
defparam receiver.BTF_RX_BUFFER_WIDTH   = BTF_RX_BUFFER_WIDTH;
defparam receiver.ClkFreq               = ClkFreq;
defparam receiver.BaudRate              = BaudRate;
defparam receiver.CMD_RX_BUFFER_BYTES   = CMD_RX_BUFFER_BYTES;
defparam receiver.CMD_RX_BUFFER_WIDTH   = CMD_RX_BUFFER_WIDTH;

/////////////////////////////////////////////////////////////////
// To send data to PC
/////////////////////////////////////////////////////////////////

parameter TX_BUFFER1_BYTES              = 4'hf;
parameter TX_BUFFER1_WIDTH              = 8 * TX_BUFFER1_BYTES;
parameter TX_BUFFER1_LENGTH_WIDTH       = bits_to_represent(TX_BUFFER1_BYTES);

parameter TX_BUFFER2_BYTES              = BTF_MAX_BYTES;
parameter TX_BUFFER2_WIDTH              = BTF_MAX_BUFFER_WIDTH;
parameter TX_BUFFER2_LENGTH_WIDTH       = BTF_MAX_BUFFER_COUNT_WIDTH;

reg [TX_BUFFER1_LENGTH_WIDTH-1:0] TX_buffer1_length;
reg [1:TX_BUFFER1_WIDTH] TX_buffer1;
reg TX_buffer1_ready;

reg [TX_BUFFER2_LENGTH_WIDTH-1:0] TX_buffer2_length;
reg [1:TX_BUFFER2_WIDTH] TX_buffer2;
reg TX_buffer2_ready;

wire TX_FIFO_ready;
wire [1:32] monitoring_32bits;

data_sender sender(
    .FSMState                               (),
    .clk                                    (CLK100MHZ),
    .TxD                                    (Uart_TXD),
    .esc_char_detected                      (esc_char_detected),
    .esc_char                               (esc_char),
    .wrong_format                           (wrong_format),
    .TX_buffer1_length                      (TX_buffer1_length),
    .TX_buffer1                             (TX_buffer1),
    .TX_buffer1_ready                       (TX_buffer1_ready),
    .TX_buffer2_length                      (TX_buffer2_length),
    .TX_buffer2                             (TX_buffer2),
    .TX_buffer2_ready                       (TX_buffer2_ready),
    .TX_FIFO_ready                          (TX_FIFO_ready),
    .bits_to_send                           (monitoring_32bits)
);

defparam sender.ClkFreq                 = ClkFreq;
defparam sender.BaudRate                = BaudRate;
defparam sender.TX_BUFFER1_LENGTH_WIDTH = TX_BUFFER1_LENGTH_WIDTH;
defparam sender.TX_BUFFER1_BYTES        =  TX_BUFFER1_BYTES;
defparam sender.TX_BUFFER1_WIDTH        = TX_BUFFER1_WIDTH;
defparam sender.TX_BUFFER2_LENGTH_WIDTH = TX_BUFFER2_LENGTH_WIDTH;
defparam sender.TX_BUFFER2_BYTES        = TX_BUFFER2_BYTES;
defparam sender.TX_BUFFER2_WIDTH        = TX_BUFFER2_WIDTH;

/////////////////////////////////////////////////////////////////
// Capture waveform data
/////////////////////////////////////////////////////////////////
reg waveform_capture_start_trigger;

/////////////////////////////////////////////////////////////////
// LED0 & LED1 intensity adjustment
/////////////////////////////////////////////////////////////////

reg [7:0] LED_intensity;
wire red0, green0, blue0, red1, green1, blue1;
initial begin
    LED_intensity <= 0;
end

led_intensity_adjust led_intensity_modulator(
    .led0_r                             (led0_r), 
    .led0_g                             (led0_g), 
    .led0_b                             (led0_b), 
    .led1_r                             (led1_r), 
    .led1_g                             (led1_g), 
    .led1_b                             (led1_b), 
    .red0                               (red0), 
    .green0                             (green0), 
    .blue0                              (blue0), 
    .red1                               (red1), 
    .green1                             (green1), 
    .blue1                              (blue1),
    .intensity                          (LED_intensity), 
    .CLK100MHZ                          (CLK100MHZ) 
);



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Command definitions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




/////////////////////////////////////////////////////////////////
// Command definition for *IDN? command
/////////////////////////////////////////////////////////////////
parameter CMD_IDN                       = "*IDN?";
parameter IDN_REPLY                     = "DAC v1_10"; // 9 characters


/////////////////////////////////////////////////////////////////
// Command definition for Test command
/////////////////////////////////////////////////////////////////
parameter CMD_TEST                      = {8'h10, "TEST", 8'h10};

/////////////////////////////////////////////////////////////////
// Command definition for DAC
/////////////////////////////////////////////////////////////////
localparam NUM_CS                        = 8;
parameter CMD_SET_SPI_CONFIG            = "SET CONFIG";
parameter CMD_WRITE_REG                 = "WRITE REG"; // 9 characters
parameter CMD_RESET                     = "RESET";
parameter DAC_DATA_WIDTH                = 24;

reg spi_reset;
reg [31:0] spi_config_in;
reg spi_config_selected;
reg [31:0] spi_data_in;
reg spi_data_selected;
wire sdi;
wire busy;
wire [31:0] spi_data_out;
wire data_write;
wire sdo;
wire cpha;
wire cpol;
wire cspol;
wire slave_en;
wire cs_next;
wire sck_next;
wire [NUM_CS-1:0] cs_val;
wire sck;
wire [NUM_CS-1:0] cs;
wire io;

// Instantiate the SPI FSM module
spi_fsm_module #(
    .NUM_CS                              (NUM_CS)
) spi_fsm_inst (
    .CLK100MHZ                           (CLK100MHZ),
    .reset                               (spi_reset),
    .spi_config_in                       (spi_config_in),
    .spi_config_selected                 (spi_config_selected),
    .spi_data_in                         (spi_data_in),
    .spi_data_selected                   (spi_data_selected),
    .sdi                                 (sdi),
    .busy                                (busy),
    .spi_data_out                        (spi_data_out),
    .data_write                          (data_write),
    .sdo                                 (sdo),
    .cpha                                (cpha),
    .cpol                                (cpol),
    .cspol                               (cspol),
    .slave_en                            (slave_en),
    .cs_next                             (cs_next),
    .sck_next                            (sck_next),
    .cs_val                              (cs_val)
);

// Instantiate the SPI Multiple Single Output module
spi_multiple_single_output #(
    .NUM_CS                              (NUM_CS)
) spi_mso_inst (
    .CLK100MHZ                           (CLK100MHZ),
    .cpol                                (cpol),
    .cspol                               (cspol),
    .slave_en                            (slave_en),
    .cs_next                             (cs_next),
    .sdo                                 (sdo),
    .sck_next                            (sck_next),
    .cs_val                              (cs_val),
    .sdi                                 (sdi),
    .io                                  ({ck_io_26, ck_io_29, ck_io_0, ck_io_3, ck_io_8, ck_io_11, ck_io_34, ck_io_37}),
    .sck                                 (sck),
    .cs                                  (cs)
);

reg ldac_bar; // Minimum 15ns for 3.6V < DV_DD �� 5.5V, 2.7V �� IOV_DD �� DV_DD
initial ldac_bar = 1'b1;

assign {ck_io_39, ck_io_38} = {cs[0], sck};
assign {ck_io_36, ck_io_35} = {cs[1], sck};
assign {ck_io_31, ck_io_30} = {cs[6], sck};
assign {ck_io_28, ck_io_27} = {cs[7], sck};
assign {ck_io_13, ck_io_12} = {cs[2], sck};
assign {ck_io_10, ck_io_9} = {cs[3], sck};
assign {ck_io_5, ck_io_4} = {cs[4], sck};
assign {ck_io_2, ck_io_1} = {cs[5], sck};


assign ck_io_6 = ldac_bar;


parameter CMD_LDAC                      = "LDAC"; // 4 characters
parameter CMD_UPDATE_LDAC_LENGTH        = "LDAC LENGTH"; // 1 characters

reg [7:0] ldac_length;
initial ldac_length <= 40;
reg [7:0] ldac_pause_count; // (LDAC_length+2)*10ns. LDAC signal is distributed to 8 chips, so for the output to swing down enough, pulse should be longer than 200ns when 2 chips were populated   

/////////////////////////////////////////////////////////////////
// Command definition for LED0 & LED1 intensity adjustment
/////////////////////////////////////////////////////////////////
parameter CMD_ADJUST_INTENSITY          = "ADJ INTENSITY"; // 13 characters
parameter CMD_READ_INTENSITY            = "READ INTENSITY"; // 14 characters




/////////////////////////////////////////////////////////////////
// Command definition to investigate the contents in the BTF buffer
/////////////////////////////////////////////////////////////////
// Capturing the snapshot of BTF buffer
parameter CMD_CAPTURE_BTF_BUFFER        = "CAPTURE BTF"; // 11 characters
reg [BTF_RX_BUFFER_WIDTH:1] BTF_capture;
// Setting the number of bytes to read from the captured BTF buffer
parameter CMD_SET_BTF_BUFFER_READING_COUNT = "BTF READ COUNT"; // 14 characters
reg [BTF_RX_BUFFER_COUNT_WIDTH-1:0] BTF_read_count;
// Read from the captured BTF buffer
parameter CMD_READ_BTF_BUFFER           = "READ BTF"; // 8 characters


/////////////////////////////////////////////////////////////////
// Command definition for bit patterns manipulation
/////////////////////////////////////////////////////////////////
// This command uses the first PATTERN_WIDTH bits as mask bits to update and update those bits with the following PATTERN_WIDTH bits
parameter CMD_UPDATE_BIT_PATTERNS       = "UPDATE BITS"; // 11 characters
parameter PATTERN_BYTES = 4;
parameter PATTERN_WIDTH = PATTERN_BYTES * 8; 
reg [1:PATTERN_WIDTH] patterns;
wire [1:PATTERN_WIDTH] pattern_masks;
wire [1:PATTERN_WIDTH] pattern_data;

assign pattern_masks = BTF_Buffer[2*PATTERN_WIDTH:PATTERN_WIDTH+1];
assign pattern_data = BTF_Buffer[PATTERN_WIDTH:1];

// This command reads the 32-bit patterns
parameter CMD_READ_BIT_PATTERNS         = "READ BITS"; // 9 characters




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DEBUG LED CONTROL
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////
// Main FSM
/////////////////////////////////////////////////////////////////
typedef enum logic [3:0] {MAIN_IDLE, 
                        MAIN_SPI_CONFIG,
                        MAIN_RESET,
                        MAIN_DAC_WAIT_FOR_BUSY_ON, 
                        MAIN_DAC_WAIT_FOR_BUSY_OFF,
                        MAIN_DAC_LDAC_PAUSE, 
                        MAIN_DAC_LDAC_OFF, 
                        MAIN_UNKNOWN_CMD} state_type;
state_type main_state;

initial begin
    main_state <= MAIN_IDLE;
    patterns <= 'd0;
    TX_buffer1_ready <= 1'b0;
    TX_buffer2_ready <= 1'b0;
    waveform_capture_start_trigger <= 1'b0;
end

always @ (posedge CLK100MHZ) begin
    if (esc_char_detected == 1'b1) begin
        if (esc_char == "C") begin
            TX_buffer1_ready <= 1'b0;
            TX_buffer2_ready <= 1'b0;
            main_state <= MAIN_IDLE;
            spi_reset <= 1'b0;
            spi_config_in <= 32'h0;
            spi_config_selected <= 1'b0;
            spi_data_in <= 32'h0;
            spi_data_selected <= 1'b0;
        end
    end
    else begin
        case (main_state)
            MAIN_IDLE: begin
                spi_config_in <= 32'h0;
                spi_config_selected <= 1'b0;
                spi_data_in <= 32'h0;
                spi_data_selected <= 1'b0;
                if (CMD_Ready == 1'b1) begin
                    if ((CMD_Length == $bits(CMD_IDN)/8) && (CMD_Buffer[$bits(CMD_IDN):1] == CMD_IDN)) begin
                        TX_buffer1[1:$bits(IDN_REPLY)] <= IDN_REPLY;
                        TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= $bits(IDN_REPLY)/8;
                        TX_buffer1_ready <= 1'b1;
                    end

                    else if ((CMD_Length == $bits(CMD_TEST)/8) && (CMD_Buffer[$bits(CMD_TEST):1] == CMD_TEST)) begin
                        TX_buffer1[1:10*8] <= "Test rec'd";
                        TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd10;
                        TX_buffer1_ready <= 1'b1;
                    end

                    else if ((CMD_Length == $bits(CMD_WRITE_REG)/8) && (CMD_Buffer[$bits(CMD_WRITE_REG):1] == CMD_WRITE_REG)) begin
                        if (BTF_Length != (4)) begin
                            $display("SET SPI DATA %d",BTF_Length);
                            TX_buffer1[1:13*8] <= {"Wrong length", BTF_Length[7:0]}; // Assuming that BTF_Length is less than 256
                            TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd13;
                            TX_buffer1_ready <= 1'b1;
                        end
                        else if (busy != 1'b1) begin
                            spi_data_in <= BTF_Buffer[32:1];
                            main_state <= MAIN_DAC_WAIT_FOR_BUSY_ON;
                            spi_data_selected <= 1'b1;
                        end
                    
                    end
                    
                    else if ((CMD_Length == $bits(CMD_SET_SPI_CONFIG)/8) && (CMD_Buffer[$bits(CMD_SET_SPI_CONFIG):1] == CMD_SET_SPI_CONFIG)) begin
                        if (BTF_Length != (8)) begin
                            $display("SET SPI CONFIG %d",BTF_Length);
                            TX_buffer1[1:13*8] <= {"Wrong length", BTF_Length[7:0]}; // Assuming that BTF_Length is less than 256
                            TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd13;
                            TX_buffer1_ready <= 1'b1;
                        end
                        else if (busy != 1'b1) begin
                            spi_config_in <= BTF_Buffer[32:1];
                            main_state <= MAIN_SPI_CONFIG;
                            spi_config_selected <= 1'b1;
                        end
                    end
                    
                    else if ((CMD_Length == $bits(CMD_RESET)/8) && (CMD_Buffer[$bits(CMD_RESET):1] == CMD_RESET)) begin
                        spi_reset <= 1'b1;
                        main_state <= MAIN_RESET;
                    end

                    else if ((CMD_Length == $bits(CMD_LDAC)/8) && (CMD_Buffer[$bits(CMD_LDAC):1] == CMD_LDAC)) begin
                        ldac_bar <= 1'b0;
                        ldac_pause_count <= ldac_length;
                        main_state <= MAIN_DAC_LDAC_PAUSE;
                    end

                    else if ((CMD_Length == $bits(CMD_UPDATE_LDAC_LENGTH)/8) && (CMD_Buffer[$bits(CMD_UPDATE_LDAC_LENGTH):1] == CMD_UPDATE_LDAC_LENGTH)) begin
                        ldac_length[7:0] <= BTF_Buffer[8:1];
                    end

                    else if ((CMD_Length == $bits(CMD_ADJUST_INTENSITY)/8) && (CMD_Buffer[$bits(CMD_ADJUST_INTENSITY):1] == CMD_ADJUST_INTENSITY)) begin
                        LED_intensity[7:0] <= BTF_Buffer[8:1];
                    end

                    else if ((CMD_Length == $bits(CMD_READ_INTENSITY)/8) && (CMD_Buffer[$bits(CMD_READ_INTENSITY):1] == CMD_READ_INTENSITY)) begin
                        TX_buffer1[1:8] <= LED_intensity;
                        TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd1;
                        TX_buffer1_ready <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end

                    else if ((CMD_Length == $bits(CMD_CAPTURE_BTF_BUFFER)/8) && (CMD_Buffer[$bits(CMD_CAPTURE_BTF_BUFFER):1] == CMD_CAPTURE_BTF_BUFFER)) begin
                        BTF_capture[BTF_RX_BUFFER_WIDTH:1] <= BTF_Buffer[BTF_RX_BUFFER_WIDTH:1];
                        main_state <= MAIN_IDLE;
                    end


                    else if ((CMD_Length == $bits(CMD_SET_BTF_BUFFER_READING_COUNT)/8) && (CMD_Buffer[$bits(CMD_SET_BTF_BUFFER_READING_COUNT):1] == CMD_SET_BTF_BUFFER_READING_COUNT)) begin
                        BTF_read_count[BTF_RX_BUFFER_COUNT_WIDTH-1:0] <= BTF_Buffer[BTF_RX_BUFFER_COUNT_WIDTH:1];
                        main_state <= MAIN_IDLE;
                    end

                    else if ((CMD_Length == $bits(CMD_READ_BTF_BUFFER)/8) && (CMD_Buffer[$bits(CMD_READ_BTF_BUFFER):1] == CMD_READ_BTF_BUFFER)) begin
                        TX_buffer2[1:TX_BUFFER2_WIDTH] <= BTF_capture[BTF_RX_BUFFER_WIDTH:1];
                        TX_buffer2_length[TX_BUFFER2_LENGTH_WIDTH-1:0] <= BTF_read_count[BTF_RX_BUFFER_COUNT_WIDTH-1:0];
                        TX_buffer2_ready <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end

                    else if ((CMD_Length == $bits(CMD_UPDATE_BIT_PATTERNS)/8) && (CMD_Buffer[$bits(CMD_UPDATE_BIT_PATTERNS):1] == CMD_UPDATE_BIT_PATTERNS)) begin
                        patterns <= (patterns & ~pattern_masks) | (pattern_masks & pattern_data);
                    end

                    else if ((CMD_Length == $bits(CMD_READ_BIT_PATTERNS)/8) && (CMD_Buffer[$bits(CMD_READ_BIT_PATTERNS):1] == CMD_READ_BIT_PATTERNS)) begin
                        TX_buffer1[1:PATTERN_WIDTH] <= patterns;
                        TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= PATTERN_WIDTH/8;
                        TX_buffer1_ready <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end

                    else begin
                        main_state <= MAIN_UNKNOWN_CMD;
                    end
                end
                else begin
                    TX_buffer1_ready <= 1'b0;
                    TX_buffer2_ready <= 1'b0;
                end
            end

            MAIN_DAC_WAIT_FOR_BUSY_ON: begin
                spi_data_selected <= 1'b0;
                if (busy != 1'b1) begin
                    main_state <= MAIN_DAC_WAIT_FOR_BUSY_OFF;
                end
            end


            MAIN_DAC_WAIT_FOR_BUSY_OFF: begin
                if (busy != 1'b1) begin 
                    main_state <= MAIN_IDLE;
                end
            end
            
            MAIN_SPI_CONFIG : begin
                if (busy != 1'b1) begin 
                    main_state <= MAIN_IDLE;
                end
            end

            MAIN_DAC_LDAC_PAUSE: begin // ldac should be low for at least 15ns
                if (ldac_pause_count == 0) begin
                    main_state <= MAIN_DAC_LDAC_OFF;
                end
                ldac_pause_count <= ldac_pause_count - 'd1;
            end

            MAIN_DAC_LDAC_OFF: begin
                ldac_bar <= 1'b1;
                main_state <= MAIN_IDLE;
            end
            
            MAIN_RESET: begin
                spi_reset <= 1'b0;
                main_state <= MAIN_IDLE;
            end

            MAIN_UNKNOWN_CMD: begin
                TX_buffer1[1:11*8] <= "Unknown CMD";
                TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd11;
                TX_buffer1_ready <= 1'b1;

                main_state <= MAIN_IDLE;
            end
                
            default: begin
                main_state <= MAIN_IDLE;
            end
        endcase
    end            
end
                








////////////////////////////////////////////////////////////////
// Detect when BTN0 is pressed
////////////////////////////////////////////////////////////////
wire BTN0EdgeDetect;
reg BTN0Delay;
initial BTN0Delay = 1'b0;
always @ (posedge CLK100MHZ) begin
    BTN0Delay <= BTN0;
end
assign BTN0EdgeDetect = (BTN0 & !BTN0Delay);


assign {d0, d1, d2, d3, d4, d5} = 6'h00;
assign monitoring_32bits = patterns[1:32];
 
endmodule
