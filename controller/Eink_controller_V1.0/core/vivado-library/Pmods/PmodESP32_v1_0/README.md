PmodESP32 IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).
This Pmod IP does not require interrupts for normal operation.
The frequency of the AXI clock provided to the IP core must be 100MHz.

Demo Program in Xilinx SDK
--------------
The demo program provides a direct connection between the Pmod ESP32's ESP32 chip
and a connected serial terminal. AT commands, documented in [this PDF](https://www.espressif.com/sites/default/files/documentation/esp32_at_instruction_set_and_examples_en.pdf) from Espressif, can be used to query the ESP32's settings,
modify the ESP32's settings, and execute commands. Through this command set, The ESP32 can be made to create a
Wifi access point, connect to an existing one, connect to a TCP socket, and much more.

Upon startup, the ESP32 is configured to echo serial commands sent to it. the AT command "ATE0" can be
used to prevent the demo from printing each character received from the host PC's serial terminal twice.

The AT command "AT" can be used to check if the ESP32 is on and working, if it is, the ESP32 will respond "OK".

To set up the demo you will need to open a serial terminal, such as [TeraTerm](https://ttssh2.osdn.jp/index.html.en),
in order to access the serial connection to the ESP32. Settings for the terminal will vary depending on
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
