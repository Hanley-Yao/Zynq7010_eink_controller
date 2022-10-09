           ***********************************
           *    Multi-Touch Display System   *
           *---------------------------------*
           *        Xilinx SDK README        *
           ***********************************

Welcome to the Multi-Touch Display System (MTDS)! This package contains
libraries for your MTDS display along with their associated documentation and
demos. It includes two libraries:
 
mtds   - A complete set of functions for graphics processing, touch handling,
         and more.
MyDisp - A very easy to use library built on the mtds library that simplifies
         designing embedded GUIs.

This document includes a quick overview of the contents of the examples folder
for this IP core, and a guide to help you get started running the included
Multi-Touch Display System example demos.


Examples Contents
-------------------------------------------------------------------------------
*Documentation
   *Complete Documentation for the two libraries and an errata document

*Resources
   *Helpful images for demos and drawing GUIs. The BmpLib folder has useful
    images that can be used as buttons, switches, and indicators. The Images
    folder includes several images used by the mtds example demos.

*MtdsDemo
   *7 example programs that demonstrate how to use the mtds library.

*MyDispDemo
   *3 example programs that demonstrate how to use the MyDisp library.

*main.cc
   *This file must be copied into the same project as whatever example program
    is being run. It includes the main function.
-------------------------------------------------------------------------------


Pre-requisites
-------------------------------------------------------------------------------
* It is expected that you have followed the Using Pmod IPs tutorial found here:
  https://reference.digilentinc.com/learn/programmable-logic/tutorials/pmod-ips/start .

* A FAT formatted microSD card
-------------------------------------------------------------------------------


Warnings
-------------------------------------------------------------------------------
1) The demo programs and drivers will only work with one MTDS module per host
   board.

2) The demo programs and drivers will fail if the PmodMTDS IP in Vivado is
   is renamed from the default (PmodMTDS_0).
-------------------------------------------------------------------------------


1) Copy the contents of the Resources folder to the microSD card. The microSD
   card should now have two folders titled "BmpLib" and "Images" in its base
   directory.

   WARNING: The microSD card should not contain the Resources folder or else
            the example demos will not run correctly.

2) Insert the microSD card into the MTDS display platform.

3) Attach the display platform to your host platform, then connect your host
   platform to your computer via USB.

4) In Xilinx SDK, create an Empty Application project and BSP like normal,
   except select C++ for the BSP language.

5) Copy the .cc file for the example program you would like to run into the src
   folder of your new application project.

   TIP: We recommend starting with the MyDisp examples, as that library is
        very easy to use and should provide enough functionality for most use
        cases.

6) Copy the main.cc file into the src folder of your new application project.

7) The example project should now build, and you can program your device with
   the newly built program. See the comments inside the demo code to understand
   what is happening.
   
8) You can repeat steps 4-7 to run other demos. You will need to reset the
   display before you run a different demo by disconnecting and reconnecting the
   display, or by power-cycling the entire host board. If you are using the
   shield, you can just press the reset button found on the host board.
   
   TIP: You only need to create a BSP for the first application project you
        create, additional projects you create can just point at the same BSP. 
