PmodCAN IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

At the step for connecting reference clocks, be sure to connect the IP's ext_spi_clk
port to a 100 MHz or slower clock. This clock can be the same one as the Pmod CAN IP's
AXI clock.

Demo Program in Xilinx SDK
--------------
Three different demo C files are provided with this IP core.
- LoopBack.c puts the Pmod CAN in hardware loopback mode, which means that the Pmod will echo its own messages back to itself.
- TX.c attempts to transmit a message over the CAN bus once per second.
- RX.c attempts to receive a message over the CAN bus once per second.

To set up any of the demos, a serial terminal, such as TeraTerm, needs to be opened
to see the data being printed out. Settings for the terminal will vary depending on
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
