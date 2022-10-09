PmodKYPD IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

Demo Program in Xilinx SDK
--------------
The demo program continuously polls the Pmod KYPD at regular time intervals 
to determine what keys are pressed.

To set up the demo, a serial terminal, such as TeraTerm, needs to be used to
see the data being printed out. Settings for the terminal will vary depending on
the target board.

For Zynq projects, apply the following settings:
- Baud rate: 115200
- Data bits: 8
- Parity:    none
- Stop bits: 1

For MicroBlaze projects, apply the settings according to the AXI Uartlite IP
configurations. These settings can be found by double clicking the AXI Uartlite
IP in the block design and clicking the IP Configuration tab.
