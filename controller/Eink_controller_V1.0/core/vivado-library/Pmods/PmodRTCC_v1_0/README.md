PmodRTCC IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

There are no special prompts that must be followed over the course of this demo
(the IP does not require interrupts or an additional clock).

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


In this demo, the RTCC date and time registers are set to specified values. The
two alarms are set to trigger 30 seconds and one minute after the RTCC is 
initialized. After initialization, the date and time are printed out over
UART once per second.

The demo can be modified to only read the date and time by changing the SET_RTCC
macro to 0 from 1. The date and time that the RTCC is set to can be changed by
modifying the values that the elements of RTCC_TIME time are set to in the
DemoInitialize function. By default, the RTCC is set to Tuesday 02/06/18 12:24:36 PM.
