#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 24 15:51:42 2020

@author: parkjeonghyun
"""
import os
import shutil

    
def convert():
    rf = open(os.path.join(os.getcwd(),'simulation_files', 'test_output.txt'), 'r')
    wf = open(os.path.join(os.getcwd(),'simulation_files',  r'test_uart_output.txt'), 'w')
    
    print(rf)
    print(wf)
    print('converting start')
    i = 0
    while True:
        line = rf.readline()
        if not line:
            rf.close()
            wf.close()
            print('converting end')
            return
        if line[0] == '1' or line[0] == '0':
            line = line.replace('\n','')
            uart_len = len(line) 
            wf.write(f"    uart_data = MAX_UART_LEN\'({uart_len}'b{line});\n")
            wf.write(f"    uart_transmit(BaudRate,{uart_len},uart_data);")
            wf.write('\n')
        else:
            line = line.replace('\n','')
            wf.write("    /*\n")
            wf.write(f"    * {line}\n")
            wf.write("     */\n")
            wf.write(f"    $display(\"{line}\");\n")
            wf.write("    #10000000;\n")

if __name__ == "__main__":
    convert()