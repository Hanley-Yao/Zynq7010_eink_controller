/******************************************************************************/
/*                                                                            */
/* calibrate_example.c -- Calibration project for the PmodJSTK2 IP            */
/*                                                                            */
/******************************************************************************/
/*                                                                            */
/* Author: Samuel Lowe`                                                       */
/* Copyright 2016-17, Digilent Inc.                                           */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo runs through the calibration process for the PmodJSTK2.          */
/*                                                                            */
/* After programming your board, wait for the blue blinking light on the      */
/* JSTK2 to turn on. Then, move the joystick in a circle at the far edges of  */
/* where it can move. After completing one full circle, release the joystick. */
/* Let the joystick stay still until the green light flashes twice, this      */
/* indicates that the calbration process is complete.                         */
/*                                                                            */
/* Status messages can be received by connecting your board to a serial       */
/* terminal application at the Baud rate specified below.                     */
/*                                                                            */
/******************************************************************************/
/*  Baud Rates:                                                               */
/*                                                                            */
/*  Microblaze: 9600 or what was specified in UARTlite core                   */
/*  Zynq: 115200                                                              */
/*                                                                            */
/******************************************************************************/
/*  Revision History:                                                         */
/*                                                                            */
/*     06/27/2016(SamL):     Created                                          */
/*     08/09/2017(ArtVVB):   Validated for Vivado 2015.4                      */
/*     11/02/2017(atangzwj): Validated for Vivado 2016.4                      */
/*     01/13/2018(atangzwj): Validated for Vivado 2017.4                      */
/*                                                                            */
/******************************************************************************/

#include <stdio.h>
#include "PmodJSTK2.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xparameters.h"

#ifdef __MICROBLAZE__
#define CPU_CLOCK_FREQ_HZ (XPAR_CPU_CORE_CLOCK_FREQ_HZ)
#else
#define CPU_CLOCK_FREQ_HZ (XPAR_PS7_CORTEXA9_0_CPU_CLK_FREQ_HZ)
#endif

PmodJSTK2 joystick;

void DemoInitialize();
void DemoRun();
void DemoCleanup();
void EnableCaches();
void DisableCaches();

int main() {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();

   // Init joystick
   JSTK2_begin(
      &joystick,
      XPAR_PMODJSTK2_0_AXI_LITE_SPI_BASEADDR,
      XPAR_PMODJSTK2_0_AXI_LITE_GPIO_BASEADDR
   );
}

void DemoRun() {
   u8 Status;

   // Reload calibration values from flash in case users run this demo
   // multiple times without power-cycling the system board in order to
   // make sure that the original collected values are correct and not
   // the RAM values from the previous run-through.
   xil_printf("Starting up by reloading calibration values from flash memory\r\n");
   JSTK2_startFlashReload(&joystick);
   usleep(100); // Delay for 100 us
   // Check if the reload was successful
   Status = JSTK2_getStatus(&joystick);
   xil_printf("Reload %s\r\n\n",
         (Status & JSTK2_bitLastFRS) != 0 ? "successful" : "failed");

   xil_printf("Values stored in flash:\r\n");

   xil_printf("power-up smpXMin: %d\r\n", JSTK2_getCalXMin(&joystick));
   xil_printf("power-up smpXMax: %d\r\n", JSTK2_getCalXMax(&joystick));
   xil_printf("power-up smpYMin: %d\r\n", JSTK2_getCalYMin(&joystick));
   xil_printf("power-up smpYMax: %d\r\n", JSTK2_getCalYMax(&joystick));
   xil_printf("power-up smpXCenterMin: %d\r\n", JSTK2_getCalXCenMin(&joystick));
   xil_printf("power-up smpXCenterMax: %d\r\n", JSTK2_getCalXCenMax(&joystick));
   xil_printf("power-up smpYCenterMin: %d\r\n", JSTK2_getCalYCenMin(&joystick));
   xil_printf("power-up smpYCenterMax: %d\r\n", JSTK2_getCalYCenMax(&joystick));

   xil_printf("\n");

   xil_printf("calibrating, rotate the Joystick around in all directions then let it rest for 1 second\r\n");

   JSTK2_startCalibration(&joystick);
   sleep(1);

   // Wait until calibration is completed
   while ((JSTK2_getStatus(&joystick) & JSTK2_bitCalibrating) != 0) {
      usleep(100000);
   }

   xil_printf("calibration complete!\r\n");

   JSTK2_setInversion(&joystick, 0, 1);

   xil_printf("Saving to flash memory....\n\r");

   JSTK2_startFlashWrite(&joystick);
   usleep(5000);
   // Check if the write was successful
   Status = JSTK2_getStatus(&joystick);
   xil_printf("Save %s\n\r",
         (Status & JSTK2_bitLastFWS) != 0 ? "successful" : "failed");

   xil_printf("saved smpXMin: %d\r\n", JSTK2_getCalXMin(&joystick));
   xil_printf("saved smpXMax: %d\r\n", JSTK2_getCalXMax(&joystick));
   xil_printf("saved smpYMin: %d\r\n", JSTK2_getCalYMin(&joystick));
   xil_printf("saved smpYMax: %d\r\n", JSTK2_getCalYMax(&joystick));
   xil_printf("saved smpXCenterMin: %d\r\n", JSTK2_getCalXCenMin(&joystick));
   xil_printf("saved smpXCenterMax: %d\r\n", JSTK2_getCalXCenMax(&joystick));
   xil_printf("saved smpYCenterMin: %d\r\n", JSTK2_getCalYCenMin(&joystick));
   xil_printf("saved smpYCenterMax: %d\r\n", JSTK2_getCalYCenMax(&joystick));
}

void DemoCleanup() {
   JSTK2_end(&joystick);
   DisableCaches();
}

void EnableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheEnable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheEnable();
#endif
#endif
}

void DisableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheDisable();
#endif
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheDisable();
#endif
#endif
}
