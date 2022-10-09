PmodR2R IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

Demo Program in Xilinx SDK
--------------
In order for the demo program to work, the math library needs to be added to the
Application Project's C/C++ Build Settings. See this [answer record](https://www.xilinx.com/support/answers/52971.html) for more information.

The demo program continuously writes a 0 to 3.3V sine wave with a period of 360ms
to the Pmod R2R Vout pin.
