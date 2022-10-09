PmodGPS IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).
This Pmod IP does not require interrupts for normal operation, but the demo
supplied with the drivers requires interrupts, be sure to follow the section
for connecting interrupts in the tutorial above if you will be using the demo.
More details on interrupts and polling are available in the following section.

Demo Program in Xilinx SDK
--------------
The demo program continuously prints location data provided by the PmodGPS. That
data is formatted as follows:

- Latitude:
- Longitude:
- Altitude:
- Number of Satellites:

If the PmodGPS fails to connect to the GPS satellites, the demo will only print
out the line for number of satellites.

The demo program uses interrupts, but the IP can also be polled for data. To use
the IP in polling mode, call the function GPS_getData(), then call the functions
that return the information you want (getLatitude(), getLongitude(), etc.).

The PmodGPS generally has trouble connecting to the satellites while indoors. If
you have connectivity issues, try taking the Pmod outdoors or next to a window.
A way to see if the Pmod has been able to determine its location is to check
the LED on the Pmod. If the Pmod has determined its location, the LED will stay
off; otherwise, the LED will alternate between on and off every second.

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
IP in the block design and clicking the IP Configuration tab. By default, these
settings are:
-Baud rate: 9600
-Data bits: 8
-Parity:    none
-Stop bits: 1

When viewing the demo's output in certain terminals, the degree symbol in the
latitude and longitude lines may not display correctly. A way to work around
this is to log the terminal's output to a text file, which should display all
characters correctly.
