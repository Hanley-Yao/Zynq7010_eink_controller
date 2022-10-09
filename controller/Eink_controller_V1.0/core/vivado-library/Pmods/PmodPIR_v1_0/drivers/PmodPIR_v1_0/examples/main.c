/******************************************************************************/
/*                                                                            */
/* main.c -- Definition for PmodPIR demo                                      */
/*                                                                            */
/******************************************************************************/
/* Author: Jon Peyron                                                         */
/* Copyright 2019, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file defines a demonstration for the use of the Pmod PIR IP core.     */
/* The PIR is a passive infrared sensor for motion which is captured with GPIO*/
/* on pin 1.                                                                  */
/* There is a 2 second software delay before it will sense                    */
/* motion after a motion is sensed                                            */
/*                                                                            */
/* This application configures UART 16550 to Baud rate 9600. PS7 UART (Zynq)  */
/* is not initialized by this application, since bootrom/bsp configures it to */
/* Baud rate 115200.                                                          */
/*                                                                            */
/*    UART TYPE   BAUD RATE                                                   */
/*    uartns550   9600                                                        */
/*    uartlite    Configurable only in HW design                              */
/*    ps7_uart    115200 (configured by bootrom/bsp)                          */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/26/2019(JPeyron):   Created                                          */
/*                                                                            */
/*                                                                            */
/******************************************************************************/

#include "PmodPIR.h"

void DemoInitialize();
void DemoRun();
void DemoCleanup();
void EnableCaches();
void DisableCaches();

PmodPIR myDevice;

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();
   PIR_begin(&myDevice, XPAR_PMODPIR_0_AXI_LITE_GPIO_BASEADDR);
}

void DemoCleanup() {
   DisableCaches();
}

void DemoRun()
{
u32 state=0;
xil_printf("Running PmodPIR Demo\n\r");
	while (1)
	{
	state = PIR_getState(&myDevice);
		if(state==1)
		{
		xil_printf("Motion Detected \n\r");
		sleep(2);
		}
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
