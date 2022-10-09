PmodSD IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

When creating the application project in Xilinx SDK, make sure to change the target
language to C++ instead of C.

Demo Program in Xilinx SDK
--------------
The provided demo runs a self-test of the PmodSD. A file named "newfile.txt" is
created at the root directory of the attached SD card's filesystem. The string
"It works!!!" is then written into this file. The file is closed, reopened,
read, and its contents are sent to the host computer over UART.

Make sure that an SD card is plugged into the PmodSD's SD card slot.

To set up this demo, a serial terminal, such as TeraTerm, needs to be opened
to see the data being printed out. Settings for the terminal will vary depending on
the target board.

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
