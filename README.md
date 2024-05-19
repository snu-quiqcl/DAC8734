# DAC8734
## Overview
This is QuIQCL 32 channel DAC8734 control verilog code. Note that ```async_receiver.v```, ```data_receiver_v1_00.v``` files are different from Sequencer due to simulation. 

## Installation
Run the following code in the ```\DAC8734``` directory using ```VivadoPmgr``` package. Also, make sure to update the ```configuration.json``` file with your target directory, common directory and vivado direcotry. For more details, refer to the https://github.com/snu-quiqcl/Vivado_prj_manager.

```
MakeVivadoProject -f .\DAC8734.json
```

## Simulation
To generate SystemVerilog code for simulation, change the ```TEST``` variable to 1 in ```python/Arty_S7_v1_01.py```. This will create the partial system verilog code in ```DAC8734/python/simulation_files/test_uart_output.txt```. Copy and paste this code into ```DAC8734_sim.sv```. You can then observe the SPI protocol in the TCL console. Below figure shows example of simulation.

<p align="center">
<img width="1086" alt="image" src="https://github.com/snu-quiqcl/DAC8734/assets/49219392/938c4144-3ff2-405e-ae50-a8d9c778c2e4">
</p>

