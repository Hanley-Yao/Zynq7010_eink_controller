PmodCMPS2 IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

There are no special prompts that must be followed over the course of this tutorial
(the IP does not require interrupts or an additional clock).

Demo Program in Xilinx SDK
--------------
After creating the application project for this demo, use [this answer record](https://www.xilinx.com/support/answers/52971.html)
to link the math.h library.

Leave the pull-up resistor enable jumpers open on the CMPS2 while using this demo,
the IP core sets up pull-ups internal to the FPGA.

The demo program continuously polls the PmodCMPS2 at regular time intervals for
magnetometer readings and prints the calculated angle between the Y axis of the 
compass and north as well as the cardinal direction of the y axis. 

Due to how the calibration algorithm used in the demo works, the CMPS2 must be
rotated a full 360 degrees about the Z axis before printed data can be considered
accurate.

Note that the angle reading will only be accurate while the compass is sitting flat,
right-side up.

To set up the demo you will need to open a serial terminal, such as TeraTerm, to
see the data being printed out. Settings for the terminal will vary depending on
your board.

For Zynq projects, apply the following settings:
- Baud rate: 115200
- Data bits: 8
- Parity:    none
- Stop bits: 1

For MicroBlaze projects, apply the settings according to the AXI Uartlite IP
configuration. These settings can be found by double clicking the AXI Uartlite
IP in the block design and clicking the IP Configuration tab. By default, this
is the following:
- Baud rate: 9600
- Data bits: 8
- Parity:    none
- Stop bits: 1