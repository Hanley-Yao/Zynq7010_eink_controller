/******************************************************************************/
/*                                                                            */
/* main.c -- Example program using the PmodAD5 IP                            */
/*                                                                            */
/******************************************************************************/
/* Author: Jon Peyron                                                         */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo continuously reads analog data from the PmodAD5 converts it into */
/* digital data. Then it converts the digital data into voltage and prints    */
/* the value through uart to a serial terminal                                */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    12/19/17(JPEYRON):  Created                                             */
/*                                                                            */
/******************************************************************************/

/************ Include Files ************/

#include "PmodAD5.h"
#include "sleep.h"
#include "xil_cache.h"
#include <stdio.h>
#include "xparameters.h"


/************ Macro Definitions ************/



/************ Function Prototypes ************/

void DemoInitialize();

void DemoRun();

void DemoCleanup();

void EnableCaches();

void DisableCaches();


/************ Global Variables ************/

PmodAD5 myDevice;


/************ Function Definitions ************/

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();

   AD5_begin(&myDevice, XPAR_PMODAD5_0_AXI_LITE_SPI_BASEADDR);

}

void DemoRun() {
   xil_printf("starting...\n\r");

   while (1) {


      float voltage= 0;

      AD5_readData(&myDevice);

      voltage = AD5_DataToVoltage(&myDevice);

      printf("Voltage is: %lf \n\r", voltage); // format text for display


      sleep(10);
   }
}

void DemoCleanup() {
   AD5_end(&myDevice);
   DisableCaches();
}

void EnableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheEnable();
#endif
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheEnable();
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
