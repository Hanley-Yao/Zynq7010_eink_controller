PmodCOLOR IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in  Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

Demo Program in Xilinx SDK
--------------
The demo program continuously prints RGB color data provided by the PmodCOLOR.
This data is displayed in hexadecimal, and has been normalized such that the
maximum value seen on a color channel is treated as 0xFFFF, while the minimum
is treated as 0x0000. In order to get useful data, make sure to calibrate the
sensor by storing readings of something white and something black.

To set up the demo you will need to open a serial terminal, such as TeraTerm, to
see the data being printed out. Settings for the terminal will vary depending on
your board.

For Zynq projects, apply the following settings:
- Baud rate: 115200
- Data bits: 8
- Parity:    none
- Stop bits: 1

For MicroBlaze projects, apply the settings according to the AXI Uartlite IP
configurations. These settings can be found by double clicking the AXI Uartlite
IP in the block design and clicking the IP Configuration tab. By default, these
settings are:
- Baud rate: 9600
- Data bits: 8
- Parity:    none
- Stop bits: 1
