/******************************************************************************/
/*                                                                            */
/* main.c -- Example program using the PmodGYRO IP                            */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo continuously polls the PmodGYRO for its angular momentum and     */
/* prints those values to the terminal.                                       */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/15/2016(MikelS):   Created                                           */
/*    10/02/2017(atangzwj): Validated for Vivado 2015.4                       */
/*    10/27/2017(artvvb):   Validated for Vivado 2016.4                       */
/*    02/17/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/************ Include Files ************/

#include "PmodGYRO.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"


/************ Function Prototypes ************/

void DemoInitialize();

void DemoRun();

void DemoCleanup();

void EnableCaches();

void DisableCaches();

/************ Global Variables ************/

PmodGYRO myDevice;

/************ Function Definitions ************/

int main() {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();
   GYRO_begin(&myDevice, XPAR_PMODGYRO_0_AXI_LITE_SPI_BASEADDR,
         XPAR_PMODGYRO_0_AXI_LITE_GPIO_BASEADDR);

   // Set Threshold Registers
   GYRO_setThsXH(&myDevice, 0x0F);
   GYRO_setThsYH(&myDevice, 0x0F);
   GYRO_setThsZH(&myDevice, 0x0F);

   GYRO_enableInt1(&myDevice, GYRO_INT1_XHIE);    // Threshold interrupt
   GYRO_enableInt2(&myDevice, GYRO_REG3_I2_DRDY); // Data Rdy/FIFO interrupt
}

void DemoRun() {
   int16_t xAxis = 0;
   int16_t yAxis = 0;
   int16_t zAxis = 0;
   int8_t temp = 0;
   int trig = 0;

   print("Starting...\n\r");
   while (1) {
      usleep(500000);

      if (GYRO_Int1Status(&myDevice) != 0) {
         xil_printf("\x1B[2J");
         xil_printf("\x1B[H");
         xil_printf("Threshold reached\n\r");
         trig = 1;
      }
      if (GYRO_Int2Status(&myDevice) != 0) {
         if (trig == 1) {
            trig = 0;
         } else {
            xil_printf("\x1B[2J"); // Clear screen
            xil_printf("\x1B[H");  // Reset cursor to 0,0
         }
         xil_printf("Data is ready\n\r\n\r");

         xAxis = GYRO_getX(&myDevice);
         yAxis = GYRO_getY(&myDevice);
         zAxis = GYRO_getZ(&myDevice);
         temp = GYRO_getTemp(&myDevice);

         xil_printf("X Axis: 0x%04x\n\r", xAxis & 0xFFFF);
         xil_printf("Y Axis: 0x%04x\n\r", yAxis & 0xFFFF);
         xil_printf("Z Axis: 0x%04x\n\r", zAxis & 0xFFFF);

         xil_printf("\n\r");

         xil_printf("Temperature: %d deg F\n\r", temp);
      }
   }
}

void DemoCleanup() {
   GYRO_end(&myDevice);
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
