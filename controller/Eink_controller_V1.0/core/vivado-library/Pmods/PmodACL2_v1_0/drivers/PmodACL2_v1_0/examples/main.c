/******************************************************************************/
/*                                                                            */
/* main.c -- Demonstration of a simple use of the Pmod ACL2                   */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen                                                       */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains a basic demo in order to use the ACL2 sample capture    */
/* mode.                                                                      */
/*                                                                            */
/* X, Y, and Z axis data is captured and printed over UART.                   */
/* This data can be viewed with a serial terminal application connected to    */
/* your board and configured to use the appropriate Baud rate below.          */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    04/19/2016(MikelS):   Created                                           */
/*    08/24/2017(artvvb):   Validated for Vivado 2015.4                       */
/*    02/03/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/
/* Baud Rates:                                                                */
/*                                                                            */
/* Microblaze: 9600 or what was specified in UARTlite core                    */
/* Zynq: 115200                                                               */
/*                                                                            */
/******************************************************************************/

#include <stdio.h>
#include "PmodACL2.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xparameters.h"

void DemoInitialize();
void DemoRun();
void DemoCleanup();
void EnableCaches();
void DisableCaches();

PmodACL2 myDevice;

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();

   return 0;
}

void DemoInitialize() {
   EnableCaches();

   // Initialize the ACL2 driver device
   ACL2_begin(&myDevice, XPAR_PMODACL2_0_AXI_LITE_GPIO_BASEADDR,
         XPAR_PMODACL2_0_AXI_LITE_SPI_BASEADDR);

   // Reset the ACL2
   ACL2_reset(&myDevice);
   usleep(1000);

   // Set ACL2 configuration data
   ACL2_configure(&myDevice);
}

void DemoRun() {
   int status;
   ACL2_SamplePacket data;

   xil_printf("Starting ACL2 Demo...\n\r");

   while (1) {
      status = ACL2_getStatus(&myDevice);

      // Capture data only when there is data available
      if ((ACL2_STATUS_DATA_READY_MASK & status) != 0) {
         data = ACL2_getSample(&myDevice);

         // Convert data to units of g before printing
         printf(
            "X: %.2f \tY: %.2f \tZ: %.2f\r\n",
            ACL2_DataToG(&myDevice, data.XData),
            ACL2_DataToG(&myDevice, data.YData),
            ACL2_DataToG(&myDevice, data.ZData)
         );
      }
   }

   ACL2_end(&myDevice);
}

void DemoCleanup() {
   ACL2_end(&myDevice);
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
