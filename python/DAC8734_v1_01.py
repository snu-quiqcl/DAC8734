# -*- coding: utf-8 -*-
"""
Created on Tue Feb 13 17:22:32 2018

@author: iontrap
"""
from Arty_S7_v1_01 import ArtyS7
from uart_convertor import convert
import random

CHANNEL_LENGTH          = 12

SPI_CONFIG_WRITE        = ( ( 0 << 31 ) \
                        | ( 0 << 30 ) \
                        | ( 0 << 29 ) \
                        | ( 0b00000000 << 16 ) \
                        | ( 16 << 0 ) )
SPI_CONFIG_READ         = ( ( 0 << 31 ) \
                        | ( 1 << 30 ) \
                        | ( 0 << 29 ) \
                        | ( 0b00000000 << 16 ) \
                        | ( 16 << 0 ) )
    

class DAC8734():
    def __init__(self, com_port):
        self.fpga = ArtyS7(com_port)
        # spi configuration
        self.spi_config = 0
        self.spi_config_int_list = []
        self.set_config( cs = 0, cpol = 1, length = 24, end_spi = 1 )
        
        self.REF = 2.5 # gihwan added
        
    def reset(self):
        self.fpga.send_command('RESET');
        
    def make_8_int_list(self, data : int):
        """
        
        Parameters
        ----------
        data : int
            int data to make 8 int lists

        Returns
        -------
        int_list : list(int)
            list of int which will be sent to FPGA
            
        This function returns list of int which will be sent to FPGA

        """
        int_list = []
        int_list.append( ( data >> 56 ) & 0xff )
        int_list.append( ( data >> 48 ) & 0xff )
        int_list.append( ( data >> 40 ) & 0xff )
        int_list.append( ( data >> 32 ) & 0xff )
        int_list.append( ( data >> 24 ) & 0xff )
        int_list.append( ( data >> 16 ) & 0xff )
        int_list.append( ( data >> 8  ) & 0xff )
        int_list.append( ( data >> 0  ) & 0xff )
        
        return int_list
        
    def set_config(
            self, 
            cs : int = 0, 
            length : int = 24, 
            end_spi : int = 1, 
            slave_en : int = 0, 
            lsb_first : int = 0, 
            cspol : int = 0, 
            cpol : int = 1, 
            cpha : int = 0, 
            clk_div : int = 2
        ):
        """
        Parameters
        ----------
        cs : int
            Number of chip selected to send data
        length : int
            Length of data which will be sent
        end_spi : int 
            Indicate whether SPI communication ends after this command
        slave_en : int 
            Indicate whether FPGA read from other devices.
            (i.e. AD9910 : master -> FPGA : slave)
        lsb_first : int
            Specify order of data. For instance, at lsb first data 0b00001111 
            data will be sent as 0 0 0 0 1 1 1 1, and msb first data will be 
            sent as 1 1 1 1 0 0 0 0.
        cspol : int 
            Chip select polarity. when cspol is 0, chip select be LOW
            when data is sent. When cspol is 1, chip select become HIGH when 
            data is sent.
        cpol : int
            Clock polarity. when clock polarity is 0, positive edge makes data 
            transmission to module. On the other hand, when clock polarity is 1
            negative edge makes data transmission.
        cpha : int
            Clock phase. When cpha is 0, data(SDIO) changes when data 
            transmission ends. On the other hand, when cpha is 1, data 
            changes when data transmission occurs.
        clk_div : int
            Division of clock which will be used as a SCLK. For instance, when 
            FPGA clock is 100MHz, and clk_div is 16, SCLK is 100/16 = 6.25MHz

        Returns
        -------
        config_int_list : list(int)
            SPI configuration data list from FPGA
            
        This function returns SPI configuration int list according to input
        parameters.
        """
        config = (    ( lsb_first << 31 ) \
                    | ( slave_en << 30 ) \
                    | ( end_spi << 29 ) \
                    | ( 0 << 24 ) \
                    | ( cs << 16 ) \
                    | ( ( length - 1 ) << 11 ) \
                    | ( cspol << 10 ) \
                    | ( cpol << 9 ) \
                    | ( cpha << 8 ) \
                    | ( clk_div << 0 ) )
            
        config_int_list = self.make_8_int_list(config)
        self.spi_config = config
        self.spi_config_int_list = config_int_list
        
        return config_int_list
    
    def close(self):
        self.fpga.close()
        convert()
        
    def print_idn(self):
        self.fpga.send_command('*IDN?') # com.write(b'!5*IDN?\r\n')
        print(self.fpga.read_next_message())
        #self.fpga.check_waveform_capture() # Check the status of trigger

    # gihwan set bipolar to False
    def voltage_register_update(self, dac_number, ch, voltage, bipolar=True, v_ref=7.5):
        if bipolar:
            input_code = int(65536/(4*v_ref)*voltage)
            if (input_code < -32768) or (input_code > 32767):
                raise ValueError('Error in voltage_out: voltage is out of range')
        
            code = (input_code + 65536) % 65536
        else:
            if voltage < 0:
                raise ValueError('Error in voltage_out: voltage cannot be negative with unipolar setting')
            elif voltage > 17.5:
                raise ValueError('Error in voltage_out: voltage cannot be larger than 17.5 V')
                
            code = int(65536/(4*v_ref)*voltage)
            if (code > 65535):
                raise ValueError('Error in voltage_out: voltage is out of range')

        #print('Code:', code)
        
        
        message = [(0x04+ch) & 0xff, (code >> 8) & 0xff, code & 0xff, 0x00]
        
        config_int_list = self.set_config( cs = (1 << dac_number), cpol =1, 
                                          length = 24, end_spi = 1 )
        self.fpga.send_mod_BTF_int_list(config_int_list)
        self.fpga.send_command('SET CONFIG')
        self.fpga.send_mod_BTF_int_list(message)
        self.fpga.send_command('WRITE REG')
    
    def load_dac(self):
        self.fpga.send_command('LDAC')
    
    def update_ldac_period(self, clock_count):
        if clock_count > 255:
            raise ValueError('Error in update_ldac_period: clock_count should be less than 256')
        self.fpga.send_mod_BTF_int_list([clock_count])
        self.fpga.send_command('LDAC LENGTH')

    def ld(self, dac_number):
        message = [0x40 & 0xff, (0x00 >> 8) & 0xff, 0x00 & 0xff, 0x00 & 0xff]
            
        config_int_list = self.set_config( cs = dac_number, cpol =1,
                                          length = 24, end_spi = 1 )
        self.fpga.send_mod_BTF_int_list(config_int_list)
        self.fpga.send_command('SET CONFIG')
        self.fpga.send_mod_BTF_int_list(message)
        self.fpga.send_command('WRITE REG')
        
    def pseudo_ld(self, ch_list):
        message = [ch_list, 0x00, 0x40, 0x00]
        self.fpga.send_mod_BTF_int_list(message)
        #print(dac.capture_btf())
        self.fpga.send_command('WRITE REG')
    

def set_ch0_a1_a2_a3(dac, voltage, bipolar=True, v_ref=7.5):
    dac.voltage_register_update(0, 1, voltage, bipolar, v_ref)
    dac.voltage_register_update(0, 2, voltage, bipolar, v_ref)
    dac.voltage_register_update(0, 3, voltage, bipolar, v_ref)
    dac.load_dac()

def set_123(dac, ch, voltage, bipolar=False, v_ref=7.5):
    dac.voltage_register_update(ch, 1, voltage, bipolar, v_ref)
    dac.voltage_register_update(ch, 2, voltage, bipolar, v_ref)
    dac.voltage_register_update(ch, 3, voltage, bipolar, v_ref)
    dac.load_dac()
    
if __name__ == '__main__':
    dac = DAC8734(None)
    dac.reset()
    
    for i in range(10):
        for j in range(4):
            v = random.uniform(-15, +15)
            for k in range(8):
                dac.voltage_register_update(k, j, v) # Set ch0 of DAC0 to 1.0 (V)
        dac.ld(0b11111111)
    
    dac.close()


