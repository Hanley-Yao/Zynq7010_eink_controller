PmodACL2 IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

At the step for connecting reference clocks, be sure to connect the IP's ext_spi_clk
port to a 50 MHz or clock source.

Demo Program in Xilinx SDK
--------------
The demo provided with this IP core collects light level data 10x per second from
the AD2 and sends it to the host computer over UART.

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
