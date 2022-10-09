/******************************************************************************/
/*                                                                            */
/* main.c -- Definition for PmodAQS demo                                      */
/*                                                                            */
/******************************************************************************/
/* Author: Jon Peyron                                                         */
/* Copyright 2019, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file defines a demonstration for the use of the Pmod AQS IP core.     */
/* CO2/VOT gas data are captured from the I2C connection and                  */
/* displayed over the serial connection once per second.                      */
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
/*    01/16/2019(JPeyron):   Created                                          */
/*                                                                            */
/*                                                                            */
/******************************************************************************/

#include "PmodAQS.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xparameters.h"


PmodAQS myDevice;


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
   xil_printf("Init Started\n\r");
   AQS_begin(&myDevice, XPAR_PMODAQS_0_AXI_LITE_IIC_BASEADDR, 0x5B); // Chip address of PmodAQS IIC
   xil_printf("Init Done\n\r");
}

void DemoCleanup() {
   DisableCaches();
}

void DemoRun() {




   while (1) {


	   u8 buf[5];
	   u16 eCO2;
	   u16 TVOC;

	   AQS_GetData(&myDevice, buf);



	        eCO2 = ((u16)buf[0] << 8) | ((u16)buf[1]);
	   		TVOC = ((u16)buf[2] << 8) | ((u16)buf[3]);

	   	xil_printf("The CO2 = %d ppm\n\r",eCO2);
	 	xil_printf("The VOC = %d ppb\n\r",TVOC);





      sleep(1);
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
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheDisable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheDisable();
#endif
#endif
}
