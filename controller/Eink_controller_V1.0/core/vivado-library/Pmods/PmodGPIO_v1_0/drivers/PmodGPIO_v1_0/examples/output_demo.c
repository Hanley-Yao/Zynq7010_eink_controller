/******************************************************************************/
/*                                                                            */
/* output_demo.c -- Demo project for the PmodGPIO IP                          */
/*                                                                            */
/******************************************************************************/
/* Author: Samuel Lowe`                                                       */
/* Copyright 2016-2017, Digilent Inc.                                         */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo_project assigns each output high one at a time and then toggles  */
/* all outputs on and off 3 times                                             */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/09/2016(SamL):     Created                                           */
/*    10/31/2017(ArtVVB):   Validated for 2016.4                              */
/*    10/31/2017(ArtVVB):   Validated for 2016.4                              */
/*    02/24/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/
/* Baud Rates:                                                                */
/*                                                                            */
/*    Microblaze: 9600 or what was specified in UARTlite core                 */
/*    Zynq: 115200                                                            */
/*                                                                            */
/******************************************************************************/

#include "PmodGPIO.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"

PmodGPIO myDevice;

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
   GPIO_begin(&myDevice, XPAR_PMODGPIO_0_AXI_LITE_GPIO_BASEADDR, 0x00);
}

void DemoRun() {
   u8 count = 0;
   int i = 0;

   xil_printf("GPIO Output Demo\n\r");
   while (1) {
      GPIO_setPin(&myDevice, count, 1);
      if (count >= 8) {
         count = 0;
         for (i = 0; i < 4; i++) {
            GPIO_setPins(&myDevice, 0xFF);
            usleep(300000);
            GPIO_setPins(&myDevice, 0x00);
            usleep(300000);
         }
      } else {
         count++;
      }
      usleep(200000);
   }
}

void DemoCleanup() {
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
