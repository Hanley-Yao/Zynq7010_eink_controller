/******************************************************************************/
/*                                                                            */
/* main.c -- Definition for HYGROI2C demo                                     */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file defines a demonstration for the use of the Pmod HYGRO IP core.   */
/* Temperature and humidity data are captured from the I2C connection and     */
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
/*    01/30/2017(ArtVVB):   Created                                           */
/*    02/21/2017(ArtVVB):   Validated                                         */
/*    11/08/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    02/17/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#include "PmodHYGRO.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xparameters.h"

#ifdef __MICROBLAZE__
#define TIMER_FREQ_HZ XPAR_CPU_M_AXI_DP_FREQ_HZ
#else
#define TIMER_FREQ_HZ 100000000
#endif

PmodHYGRO myDevice;

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
   HYGRO_begin(
      &myDevice,
      XPAR_PMODHYGRO_0_AXI_LITE_IIC_BASEADDR,
      0x40, // Chip address of PmodHYGRO IIC
      XPAR_PMODHYGRO_0_AXI_LITE_TMR_BASEADDR,
      XPAR_PMODHYGRO_0_DEVICE_ID,
      TIMER_FREQ_HZ // Clock frequency of AXI bus, used to convert timer data
   );
   xil_printf("Init Done\n\r");
}

void DemoCleanup() {
   DisableCaches();
}

void DemoRun() {
   float temp_degc, hum_perrh, temp_degf;
   while (1) {
      temp_degc = HYGRO_getTemperature(&myDevice);
      temp_degf = HYGRO_tempC2F(temp_degc);
      hum_perrh = HYGRO_getHumidity(&myDevice);
      xil_printf(
         "Temperature: %d.%02d deg F  Humidity: %d.%02d RH\n\r",
         (int) temp_degf,
         ((int) (temp_degf * 100)) % 100,
         (int) hum_perrh,
         ((int) (hum_perrh * 100)) % 100
      );
      // %f does not work with xil_printf
      // instead, converting float to a pair of ints to display %.2f.

      // 1 sample per second maximum, as per 9.2.1 in HDC1080 reference manual
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
