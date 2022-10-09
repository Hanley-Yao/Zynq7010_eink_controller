/******************************************************************************/
/*                                                                            */
/* main.c -- PmodAD1 Example Project                                          */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains code for running a demonstration of the PmodAD1 when    */
/* used with the PmodAD1 IP core. This demo initializes the PmodAD1 IP core   */
/* and then polls its sample register, printing the analog voltage last       */
/* sampled by each of the AD1's two channels over UART.                       */
/*                                                                            */
/* Messages printed by this demo can be received by using a serial terminal   */
/* configured with the appropriate Baud rate. 115200 for Zynq systems, and    */
/* whatever the AXI UARTLITE IP is configured with for MicroBlaze systems,    */
/* typically 9600 or 115200 Baud.                                             */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    08/15/2017(ArtVVB):   Created                                           */
/*    02/10/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#include <stdio.h>
#include "PmodAD1.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "xil_types.h"
#include "xparameters.h"

PmodAD1 myDevice;
const float ReferenceVoltage = 3.3;

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

   AD1_begin(&myDevice, XPAR_PMODAD1_0_AXI_LITE_SAMPLE_BASEADDR);

   // Wait for AD1 to finish powering on
   usleep(1); // 1 us (minimum)
}

void DemoRun() {
   AD1_RawData RawData;
   AD1_PhysicalData PhysicalData;

   while (1) {
      AD1_GetSample(&myDevice, &RawData); // Capture raw samples

      // Convert raw samples into floats scaled to 0 - VDD
      AD1_RawToPhysical(ReferenceVoltage, RawData, &PhysicalData);

      printf("Input Data 1: %.02f;   ", PhysicalData[0]);
      printf("Input Data 2: %.02f\r\n", PhysicalData[1]);

      // Do this 10x per second
      usleep(100000);
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
