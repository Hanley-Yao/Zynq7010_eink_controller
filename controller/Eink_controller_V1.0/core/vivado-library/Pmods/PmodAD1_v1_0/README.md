PmodAD1 IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

Before generating the bitstream, if the AXI clock connected to the AD1 IP core 
is faster than 100MHz, customize the AD1 block (by double clicking on it). The
Clocks Per Bit, Clocks Before Data, Clocks After Data, and Clocks Between Transitions
parameters should be increased to scale with the increase in clock frequency.

Demo Program in Xilinx SDK
--------------
The demo program constantly polls the AD1 IP core, which is constantly requesting
data from the Pmod AD1. Read data is then converted into Volts and sent to the
host computer over UART.

To set up the demo a serial terminal, such as TeraTerm, needs to be opened to
see the data being printed out. Settings for the terminal will vary depending on
your board.

For Zynq projects, apply the following settings:
- Baud rate: 115200
- Data bits: 8
- Parity:    none
- Stop bits: 1

For MicroBlaze projects, apply the settings according to the AXI Uartlite IP
configurations. These settings can be found by double clicking the AXI Uartlite
IP in the block design and clicking the IP Configuration tab. By default, this
is the following:
- Baud rate: 9600
- Data bits: 8
- Parity:    none
- Stop bits: 1
