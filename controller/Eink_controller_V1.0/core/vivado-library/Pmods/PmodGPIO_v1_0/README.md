PmodGPIO IP
==============

Target Pmods
--------------
This IP is intended to be used with one of many different Pmods:
-8LD
-BB
-BTN
-LED
-SSR
-SWT

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

There are no special prompts that must be followed over the course of this demo
(the IP does not require interrupts or an additional clock).

Demo Program in Xilinx SDK
--------------
One of two examples can be selected. The input_demo.c file is an example of how
to communicate with an input only Pmod, such as the SWT (Dip Switches), while
the output_demo.c file is an example of how to communicate with an output only
Pmod, such as the LED. Select one or the other depending on the Pmod being used.

To set up the demo a serial terminal, such as TeraTerm, needs to be used to
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
