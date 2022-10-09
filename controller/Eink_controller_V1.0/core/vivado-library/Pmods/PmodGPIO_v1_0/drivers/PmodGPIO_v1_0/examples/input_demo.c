/******************************************************************************/
/*                                                                            */
/* input_demo.c -- Demo project for the PmodGPIO IP                           */
/*                                                                            */
/******************************************************************************/
/* Author: Samuel Lowe`                                                       */
/* Copyright 2016-2017, Digilent Inc.                                         */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo_project reads 4 inputs individually, then reads all 4 together,  */
/* and then prints the results out over UART to a Serial Terminal             */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/09/2016(SamL):     Created                                           */
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
   GPIO_begin(&myDevice, XPAR_PMODGPIO_0_AXI_LITE_GPIO_BASEADDR, 0xFF);
}

void DemoRun() {
   int pin1 = 0;
   int pin2 = 0;
   int pin3 = 0;
   int pin4 = 0;
   int all_pins = 0;

   xil_printf("GPIO Input Demo\n\r");

   while (1) {
      // Read individually
      pin1 = GPIO_getPin(&myDevice, 1);
      pin2 = GPIO_getPin(&myDevice, 2);
      pin3 = GPIO_getPin(&myDevice, 3);
      pin4 = GPIO_getPin(&myDevice, 4);

      // Read all together
      all_pins = GPIO_getPins(&myDevice);

      // Print individual reads and the total read masked to the first four bits
      xil_printf(
         "pin 1: %d   pin 2: %d   pin 3: %d   pin 4: %d   all pins: %x\n\r",
         pin1,
         pin2,
         pin3,
         pin4,
         all_pins & 0x0f
      );
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
