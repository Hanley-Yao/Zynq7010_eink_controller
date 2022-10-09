PmodSF3 IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).
When you get to the step for connecting reference clocks, be sure to connect the
IP's ext_spi_clk port to a 50 MHz clock.
The QSPI_INTERRUPT pin needs to be connected to an interrupt controller. Be sure
to do this when instructed in the guide linked above.

Demo Program in Xilinx SDK
--------------
The demo program runs a test of the PmodSF3 by writing data using each of the
available write command sequences, and confirming that the data was written
(and read) properly by reading it back and comparing read data against the 
expected value for that address.

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
IP in the block design and clicking the IP Configuration tab.
