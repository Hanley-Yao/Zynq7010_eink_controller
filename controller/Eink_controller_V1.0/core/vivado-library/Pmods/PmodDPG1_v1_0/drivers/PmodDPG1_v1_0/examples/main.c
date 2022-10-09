/******************************************************************************/
/*                                                                            */
/* main.c -- Example program using the PmodDPG1 IP                            */
/*                                                                            */
/******************************************************************************/
/* Author: Jon Peyron                                                         */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo continuously polls the PmodDPG1 for pressure measurements and    */
/* prints the data in 6 different units (kPa, atm, psi, inH2O, cmH2O, and     */
/* mmHg).                                                                     */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    08/19/2016(jpeyron):  Created                                           */
/*    09/29/2017(atangzwj): Validated for Vivado 2015.4                       */
/*    10/20/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    03/16/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/************ Include Files ************/

#include "PmodDPG1.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xparameters.h"


/************ Macro Definitions ************/

// Pressure unit types
#define KPA   DPG1_KPA_PRESSURE_TYPE
#define ATM   DPG1_ATM_PRESSURE_TYPE
#define PSI   DPG1_PSI_PRESSURE_TYPE
#define INH2O DPG1_INH2O_PRESSURE_TYPE
#define CMH2O DPG1_CMH2O_PRESSURE_TYPE
#define MMHG  DPG1_MMHG_PRESSURE_TYPE


/************ Function Prototypes ************/

void DemoInitialize();

void DemoRun();

void DemoCleanup();

void EnableCaches();

void DisableCaches();


/************ Global Variables ************/

PmodDPG1 myDevice;


/************ Function Definitions ************/

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();

   DPG1_begin(&myDevice, XPAR_PMODDPG1_0_AXI_LITE_SPI_BASEADDR);
}

void DemoRun() {
   xil_printf("starting...\n\r");

   while (1) {
      int rawData;
      double pressureValue;
      DPG1_readData(&myDevice);

      // Read raw data from PmodDPG1 and print it
      rawData = (int) myDevice.data;
      xil_printf("Raw data: %d \n\r", rawData); // Format text for display

      int whole; // Used to get the whole number for the float
      int not_whole;// Used to get the non whole number for the float

      // Convert raw data into units of kPa and print it
      pressureValue = DPG1_GetPressure(KPA, &myDevice);
      whole = pressureValue; // Get whole number part of the physical value
      not_whole = (pressureValue - whole) * 1000000; // Get fractional part
      xil_printf("kPa: %d.%06d \n\r", whole, not_whole); // Format and print

      // Convert raw data into units of atm and print it
      pressureValue = DPG1_GetPressure(ATM, &myDevice);
      whole = pressureValue;
      not_whole = (pressureValue - whole) * 1000000;
      xil_printf("atm: %d.%06d \n\r", whole, not_whole);

      // Convert raw data into units of and print it
      pressureValue = DPG1_GetPressure(PSI, &myDevice);
      whole = pressureValue;
      not_whole = (pressureValue - whole) * 1000000;
      xil_printf("psi: %d.%06d \n\r", whole, not_whole);

      // Convert raw data into units of and print it
      pressureValue = DPG1_GetPressure(INH2O,&myDevice);
      whole = pressureValue;
      not_whole = (pressureValue - whole) * 1000000;
      xil_printf("inH20: %d.%06d \n\r", whole, not_whole);

      // Convert raw data into units of and print it
      pressureValue = DPG1_GetPressure(CMH2O,&myDevice);
      whole = pressureValue;
      not_whole = (pressureValue - whole) * 1000000;
      xil_printf("cmH20: %d.%06d \n\r", whole, not_whole);

      // Convert raw data into units of and print it
      pressureValue = DPG1_GetPressure(MMHG, &myDevice);
      whole = pressureValue;
      not_whole = (pressureValue - whole) * 1000000;
      xil_printf("mmHg: %d.%06d \n\r", whole, not_whole);

      xil_printf("\n\r\n\r");

      sleep(1);
   }
}

void DemoCleanup() {
   DPG1_end(&myDevice);
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
