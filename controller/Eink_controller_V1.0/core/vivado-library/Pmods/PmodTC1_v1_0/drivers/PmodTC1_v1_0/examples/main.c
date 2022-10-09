/******************************************************************************/
/*                                                                            */
/* main.c -- Definition for PmodTC1 demo                                      */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file defines a demonstration for the use of the Pmod Thermocouple IP  */
/* core. Temperature data in Fahrenheit and Celsius is streamed out over UART */
/* to a serial terminal such as TeraTerm twice per second.                    */
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
/*    02/14/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#include <stdio.h>
#include "PmodTC1.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xparameters.h"

void DemoInitialize();
void DemoRun();
void DemoCleanup();
void EnableCaches();
void DisableCaches();

PmodTC1 myDevice;

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();
   TC1_begin(&myDevice, XPAR_PMODTC1_0_AXI_LITE_SPI_BASEADDR);
}

void DemoRun() {
   double celsius, fahrenheit;
   printf("Starting Pmod TC1 Demo...\n\r");

   while (1) {
      celsius = TC1_getTemp(&myDevice);
      fahrenheit = TC1_tempC2F(celsius);
      printf("Temperature: %f deg F   %f deg C\n\r", (fahrenheit), (celsius));
      usleep(500000);
   }
}

void DemoCleanup() {
   TC1_end(&myDevice);
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
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheDisable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheDisable();
#endif
#endif
}
