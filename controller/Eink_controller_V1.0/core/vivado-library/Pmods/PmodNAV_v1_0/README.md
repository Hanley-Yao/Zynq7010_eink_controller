PmodNAV IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).
At the step where reference clocks are connected, be sure to connect the
IP's ext_spi_clk port to a 50 MHz clock.

Demo Program in Xilinx SDK
--------------
The demo program continuously polls the data being collected by the Pmod NAV.
The data presented is as follows:
-Accelerometer / Gyroscope ID
-Magnetometer ID
-Altimeter ID
-Accelerometer X, Y, and Z readings, in units of G
-NAV offset from vertical in degrees, calculated from accelerometer data
-Magnetometer X, Y, and Z readings, in Gauss
-Y Axis compass heading, in degrees and cardinal direction name
-Pressure reading, in hectoPascals
-Altitude, in feet
-Temperature, in degrees Celsius and Fahrenheit

Make sure to enter the correct value for the INITIAL_ALTITUDE macro in
the demo main file for where the demo is being operated.

Make sure to set up a serial terminal, such as TeraTerm, to see the data
being printed out. Settings for the terminal will vary depending on
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
