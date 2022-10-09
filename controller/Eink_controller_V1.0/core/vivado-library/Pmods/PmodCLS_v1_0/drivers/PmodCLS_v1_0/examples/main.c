/******************************************************************************/
/*                                                                            */
/* main.c -- PmodCLS Example Projects                                         */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo sends data through SPI to the PmodCLS. The demo alters the first */
/* string slightly so you can see that the data is changing between the       */
/* different prints to the PmodCLS. Depending on the Rev of the PmodCLS the   */
/* jumper configuration will be different. Make sure to refer to the          */
/* Reference Manual for the correct jumper configuration.                     */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/15/2016(MikelSkreen): Created                                        */
/*    08/17/2017(jPeyron):     Updated                                        */
/*    11/03/2017(artvvb):      2016.4 Maintenance                             */
/*    02/12/2018(atangzwj):    Validated for Vivado 2017.4                    */
/*                                                                            */
/******************************************************************************/
/* Baud Rates:                                                                */
/*                                                                            */
/* Microblaze: 9600 or what was specified in UARTlite core                    */
/* Zynq: 115200                                                               */
/*                                                                            */
/******************************************************************************/

#include <stdio.h>
#include "PmodCLS.h"
#include "sleep.h"
#include "string.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xparameters.h"

void DemoInitialize();
void DemoRun();
void DemoCleanup();
void EnableCaches();
void DisableCaches();

PmodCLS myDevice;

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();
   CLS_begin(&myDevice, XPAR_PMODCLS_0_AXI_LITE_SPI_BASEADDR);
}

void DemoRun() {
   char szInfo1[32];
   char szInfo2[32];

   CLS_DisplayClear(&myDevice);
   strcpy(szInfo1, "  PmodCLS Demo");
   strcpy(szInfo2, "  Hello World!");
   CLS_WriteStringAtPos(&myDevice, 0, 0, szInfo1);
   CLS_WriteStringAtPos(&myDevice, 1, 0, szInfo2);

   usleep(500000);

   while (1) {
      CLS_DisplayClear(&myDevice);
      strcpy(szInfo1, "->PmodCLS Demo<- ");
      CLS_WriteStringAtPos(&myDevice, 0, 0, szInfo1);
      CLS_WriteStringAtPos(&myDevice, 1, 0, szInfo2);

      usleep(500000);

      CLS_DisplayClear(&myDevice);
      strcpy(szInfo1, "  PmodCLS Demo   ");
      CLS_WriteStringAtPos(&myDevice, 0, 0, szInfo1);
      CLS_WriteStringAtPos(&myDevice, 1, 0, szInfo2);

      usleep(500000);
   }
}

void DemoCleanup() {
   CLS_end(&myDevice);
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
