PmodOLED IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

There are no special prompts that must be followed over the course of this demo
(the IP does not require interrupts or an additional clock).

It should be noted that This IP will not function properly when the provided AXI
clock has a frequency greater than 160 MHz.

Demo Program in Xilinx SDK
--------------
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

The demo writes a sequence of images to the Pmod OLED. First, the message "Pmod
OLED / by Digilent / Simple Demo" will scroll onto the screen. Then, a series
of rectangles displaying each of the fill patterns available in the device drivers
will be displayed.

To make sure that the Pmod OLED isn't damaged, make sure to safely quit the demo.
On MicroBlaze, this happens automatically at the end of the image sequence. On
Zynq, a 'q' needs to be typed at the quit prompt in the serial terminal.