PmodDA1 IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

When prompted to connect additional clocks, make sure to connect the ext_spi_clk
pin to an 50 MHz clock source.

Demo Program in Xilinx SDK
--------------
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

This demo creates a 3V peak-to-peak triangle wave of an unspecified frequency
is output on the A1 pin of the Pmod DA1. An oscilloscope should be used to view
the resulting waveform.