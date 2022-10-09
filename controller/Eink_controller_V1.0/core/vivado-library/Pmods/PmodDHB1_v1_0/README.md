PmodDHB1 IP
============

Pmod External Connections
------------
An example for connecting the PmodDHB1 to two motors with feedback can be found
[here](https://projects.digilentinc.com/atang08/artybot-551478) at the Hackster 
page for the ArtyBot robotics platform in the "Equipment, Assembly, and Project
Setup" section.

Using the IP in Vivado
------------
A tutorial for using Pmod IP cores in Vivado is available [here](https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start).

Demo Program in Xilinx SDK
------------
The demo program drives a two-wheel chassis in four possible directions:
forward, backward, turn left, and turn right. The platform that this demo was
written for is the ArtyBot; see its [Hackster page](https://projects.digilentinc.com/atang08/artybot-551478)
for more examples using the included drivers beyond this demo.

IMPORTANT: Note that all calls to set motor directions are preceded by a call
that disables the motors. Changing directions without disabling the motors first
may cause a short circuit in the H-bridge of the DHB1, which may damage the
DHB1.

The values of parameters used in this program are specific to the ArtyBot
platform. The demo's platform-specific parameters include
 - Values of parameters passed to DHB1_setDirs()
 - Macros SENSOR_EDGES_PER_REV and GEARBOX_RATIO

Adjustments to these values may be necessary for use with other platforms.

The provided combination of parameters to the DHB1_setDirs() function should
drive the chassis as described above. However, these same values may produce
different behaviors on other platforms.

The SENSOR_EDGES_PER_REV macro is specific to the magnetic encoder disk used in
the ArtyBot platform. This macro is equal to the number of positive edges that
the ArtyBot's Hall effect sensor would produce in one revolution of the magnetic
encoder disk. The ArtyBot's encoder disks each have eight magnets placed with
alternating polarity around the disk, which causes the Hall effect sensor to
produce four positive edges in one revolution.

The GEARBOX_RATIO macro is specific to the motors on the ArtyBot. For every
revolution of the wheels on the ArtyBot, the magnetic encoder disk revolves 48
times.
