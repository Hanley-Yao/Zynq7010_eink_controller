PmodENC IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

Demo Program in Xilinx SDK
--------------
The demo program continuously polls the Pmod ENC pins to capture user input.

Controls:
Clockwise rotation of the shaft increments a counter for each tick.
Counterclockwise rotation of the shaft decrements a counter for each tick.
Clicking the button inline to the shaft prints the current tick count.
Setting the switch to the off position clears and disables the counter.

Use a serial terminal such as TeraTerm to see the data being printed out.
Settings for the terminal will vary depending on the target board.

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
