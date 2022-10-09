PmodTMP3 IP
============

Using the IP in Vivado
------------
A tutorial for using Pmod IP cores in  Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

Demo Program in Xilinx SDK
------------
The demo program continuously prints temperature data collected by the PmodTMP3
to the serial terminal in both Fahrenheit and Celsius.

To see text output from the example program, you will need to open a serial
terminal, such as TeraTerm. Settings for the terminal will vary depending on
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
