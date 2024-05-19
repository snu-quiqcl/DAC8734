# -*- coding: utf-8 -*-
"""
Created on Tue Feb 13 17:22:32 2018

@author: iontrap
"""

from Arty_S7_v1_01 import ArtyS7
from uart_convertor import convert



class DAC8734():
    def __init__(self, com_port):
        self.fpga = ArtyS7(com_port)
        self.REF = 2.5 # gihwan added
    
    def close(self):
        self.fpga.close()
        convert()
        
    def print_idn(self):
        self.fpga.send_command('*IDN?') # com.write(b'!5*IDN?\r\n')
        print(self.fpga.read_next_message())
        #self.fpga.check_waveform_capture() # Check the status of trigger

    # gihwan set bipolar to False
    def voltage_register_update(self, dac_number, ch, voltage, bipolar=False, v_ref=2.5):
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
        message = [1<<dac_number, 0x04+ch, code // 256, code % 256]
            
        self.fpga.send_mod_BTF_int_list(message)
        self.fpga.send_command('WRITE REG')
    
    def load_dac(self):
        #dac.send_mod_BTF_int_list([0xff,0x00, 0x40, 0x3C])
        #dac.send_command('WRITE REG')
        self.fpga.send_command('LDAC')
    
    def update_ldac_period(self, clock_count):
        if clock_count > 255:
            raise ValueError('Error in update_ldac_period: clock_count should be less than 256')
        self.fpga.send_mod_BTF_int_list([clock_count])
        self.fpga.send_command('LDAC LENGTH')
    

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

    dac.voltage_register_update(0, 0, 1) # Set ch0 of DAC0 to 1.0 (V)
    dac.voltage_register_update(1, 0, 1) # Set ch0 of DAC0 to 1.0 (V)
    dac.voltage_register_update(2, 0, 1) # Set ch0 of DAC0 to 1.0 (V)
    dac.voltage_register_update(3, 0, 1) # Set ch0 of DAC0 to 1.0 (V)
    dac.voltage_register_update(4, 0, 1) # Set ch0 of DAC0 to 1.0 (V)
    dac.voltage_register_update(5, 0, 1) # Set ch0 of DAC0 to 1.0 (V)
    dac.voltage_register_update(6, 0, 1) # Set ch0 of DAC0 to 1.0 (V)
    dac.voltage_register_update(7, 0, 1) # Set ch0 of DAC0 to 1.0 (V)
    
    dac.close()


