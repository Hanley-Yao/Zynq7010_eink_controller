/******************************************************************************/
/*                                                                            */
/* main.c -- Definition for PmodR2R Resistor Ladder DAC demo                  */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file defines a demonstration for the use of the PmodR2R IP core. A    */
/* 3.3V sine wave with period 360ms is created on the Vout pin.               */
/*                                                                            */
/* A UART connection is used - but is not required for demo functionality.    */
/* to connect, use a serial terminal such as TeraTerm attached to the         */
/* programmed FPGA's port at the proper Baud rate to see print statements     */
/*                                                                            */
/*    UART TYPE BAUD RATE                                                     */
/*    uartns550 9600                                                          */
/*    uartlite  Configurable only in HW design                                */
/*    ps7_uart  115200 (configured by bootrom/bsp)                            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    02/28/2017(ArtVVB):   Validated                                         */
/*    02/13/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#include "math.h"
#include "PmodR2R.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xparameters.h"

void DemoInitialize();
void DemoRun();
void DemoCleanup();
void EnableCaches();
void DisableCaches();

PmodR2R myDevice;

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoRun() {
   const double one_degree_delta = 3.14159 / 180;
   double i = 0, voltage;
   u32 data;
   xil_printf("Demo Initialized, producing 3.3 V sin wave, T = 360ms\n\r");

   while (1) {
      voltage = 3.3 * (sin(i) + 1.0) / 2.0;

      if (voltage > 3.3)
         data = 0xFF;
      else if (voltage < 0.0)
         data = 0x00;
      else
         data = (int) (255.0 * voltage / 3.3);

      // Convert degrees to radians, output 0->3.3V sin wave
      R2R_write(&myDevice, data);

      i = i + one_degree_delta;
      if (i >= 6.28318)
         i -= 6.28318;

      usleep(1000);
   }
}

void DemoInitialize() {
   EnableCaches();
   R2R_begin(&myDevice, XPAR_PMODR2R_0_AXI_LITE_GPIO_BASEADDR);
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
