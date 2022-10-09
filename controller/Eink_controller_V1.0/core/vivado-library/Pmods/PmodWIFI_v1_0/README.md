PmodWIFI IP
============

Using the IP in Vivado
------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).
The demo programs for this Pmod IP require interrupts. Be sure to follow the
section for connecting interrupts in the tutorial above.

Demo Programs in Xilinx SDK
------------
When creating application projects in the Xilinx SDK using the PmodWIFI IP's
drivers, be sure to select __C++__ as the language in the _Target Software_ box
on the first screen of the dialogue box. On the next screen, select __Empty
Project__.

### HTTP Server ###
The HTTP Server demo allows users to interact with GPIO pins on their boards via
Wi-Fi. For example, users will be able to turn LEDs on or off and read the
positions of the board's switches. A video tutorial for this demo is available
[here](https://youtu.be/KTeTMv3oiPw?t=48s). Although this tutorial uses Vivado
2016.2, this IP core is designed to be used in Vivado 2016.4 or later.

### TCP Echo Server and TCP Echo Client ###
The TCP Echo Server and TCP Echo Client programs can be used in conjunction with
each other. The TCP Echo Server program will set up a server, that uses the
Transmission Control Protocol (TCP) to echo text sent by a client back to the
client. The TCP Echo Client program will connect to and send text to a TCP
server. Then the client, will display any text sent by the server it is
connected to.

### UDP Echo Server and UDP Echo Client ###
The UDP Echo Server and UDP Echo Client programs can be used in conjunction with
each other. The UDP Echo Server program will set up a server, that uses the User
Datagram Protocol (UDP) to echo text sent by a client back to the client. The
UDP Echo Client program will connect to and send text to a UDP server. Then the
client, will display any text sent by the server it is connected to.

### Wi-Fi Scan ###
The Wi-Fi Scan program will scan the network for all available routers and print
their parameters to a serial terminal.

### Demo Setup ###
Most of these demos have configuration parameters that need to be modified.
These parameters are:
- IP address
- Network security
- Router SSID
- Wi-Fi password

The programs that set up a server take the IP address as an integer array of
four elements. For the IP address 192.144.12.1, set the array equal to
{192,144,12,1}. The programs that are clients to the server take the IP address
as a string, such as "192.144.12.1".

Select your network's security type by uncommenting the corresponding macro
definition towards the top of the program.

The router SSID and Wi-Fi password are taken as strings. Replace the strings
"myRouter" and "myPassword" in the configuration section of the program you are
running with your router SSID and Wi-Fi password, respectively.

To see text output from the example programs, you will need to open a serial
terminal, such as TeraTerm. Settings for the terminal will vary depending on
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
- Baud rate: 9600
- Data bits: 8
- Parity:    none
- Stop bits: 1
