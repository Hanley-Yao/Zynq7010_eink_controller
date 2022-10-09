/******************************************************************************/
/*                                                                            */
/* main.c -- PmodENC Example Project                                          */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains code for running a demonstration of the Pmod Encoder    */
/* when used with the PmodENC IP core.                                        */
/*                                                                            */
/* Rotating the PmodENC's rotary shaft increments or decrements a counter,    */
/* depending on direction of rotation. The PmodENC's switch controls whether  */
/* the counter is enabled. Pressing the PmodENC's shaft in prints the current */
/* count                                                                      */
/*                                                                            */
/* Requires a serial terminal, such as TeraTerm. The Baud rate for the        */
/* terminal will vary depending on the target board. For Zynq projects use    */
/* 115200 Baud. For MicroBlaze projects use the Baud rate specified in the    */
/* AXI Uartlite IP, 9600 Baud by default.                                     */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    02/13/2017(ArtVVB):   Validated for 2015.4                              */
/*    10/25/2017(ArtVVB):   Validated for 2016.4                              */
/*    02/13/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#include "PmodENC.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xparameters.h"

void DemoInitialize();
void DemoRun();
void DemoCleanup();
void EnableCaches();
void DisableCaches();

PmodENC myDevice;

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();
   ENC_begin(&myDevice, XPAR_PMODENC_0_AXI_LITE_GPIO_BASEADDR);
}

void DemoCleanup() {
   DisableCaches();
}

void DemoRun() {
   u32 state, laststate; // Comparing current and previous state to detect edges
   int ticks = 0;        // on GPIO pins

   xil_printf("Running PmodENC Demo\n\r");
   laststate = ENC_getState(&myDevice);

   while (1) {
      state = ENC_getState(&myDevice);

      if (ENC_switchOn(state)) // Using switch as an enable for counter
         ticks += ENC_getRotation(state, laststate);
      else
         ticks = 0;

      // Only print on button posedge
      if (ENC_buttonPressed(state) && !ENC_buttonPressed(laststate)) {
         if (ENC_switchOn(state))
            xil_printf("ticks = %d\n\r", ticks);
         else
            xil_printf("tick counter disabled\r\n");
      }
      laststate = state;
      usleep(1000);
   }
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
