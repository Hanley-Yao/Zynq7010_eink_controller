PmodAMP2 IP
==============

Using the IP in Vivado
--------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

The timer_interrupt pin needs to be connected to an interrupt controller. Be sure
to do this when instructed in the guide linked above.

Demo Program in Xilinx SDK
--------------
The demo program continuously drives the Pmod AMP2 at regular time intervals with
a triangle wave alternating between 440 (the A above middle C) and 587 (the D
above middle C) Hertz.

Be sure to connect a speaker or pair of headphones to the 3.5mm jack (J2) to
hear the tones produced. These tones can be fairly loud, so it is not
recommended to wear headphones that are connected to the demo.
