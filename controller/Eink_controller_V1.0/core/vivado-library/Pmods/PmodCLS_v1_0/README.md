PmodCLS IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

When prompted to connect additional clocks, make sure to connect the ext_spi_clk
pin to an 50 MHz clock source.

Demo Program in Xilinx SDK
--------------
Make sure to connect the Pmod CLS's J1 port to the top row of the Pmod port
of the target board that was selected in the tutorial above. Configure the
MD0,1,2 jumpers on the Pmod CLS to SPI mode. For Rev. E, only short MD0.
For other revisions, short only MD1 and MD2.

To set up the demo, a serial terminal application, such as TeraTerm, may be
used to see initialization messages. Settings for the terminal will vary
depending on the target board.

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

This demo initializes a SPI connection with the Pmod CLS and displays the following:
" ->PmodCLS Demo<--  "
"   Hello World      "
The arrows on the first line will blink once a second.