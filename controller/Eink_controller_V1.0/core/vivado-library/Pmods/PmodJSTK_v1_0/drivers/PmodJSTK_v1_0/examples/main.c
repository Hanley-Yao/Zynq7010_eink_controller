/******************************************************************************/
/*                                                                            */
/* main.c -- Demo project for the PmodJSTK IP                                 */
/*                                                                            */
/******************************************************************************/
/*                                                                            */
/*  Author: Samuel Lowe`                                                      */
/*  Copyright 2016, Digilent Inc.                                             */
/*                                                                            */
/******************************************************************************/
/*  File Description:                                                         */
/*                                                                            */
/*  This demo reads the calibrated data from the PmodJSTK and prints the X    */
/*  and Y position values. If the buttons on the JSTK are pressed, the        */
/*  adjacent LED will turn red. If any of the three buttons are pressed, a    */
/*  message stating which of the buttons are pressed will be printed along    */
/*  with positional data.                                                     */
/*                                                                            */
/*  Messages can be received with a serial terminal application               */
/*  connected to your board and configured to use the appropriate baud        */
/*  rate below.                                                               */
/*                                                                            */
/******************************************************************************/
/*  Revision History:                                                         */
/*                                                                            */
/*  06/27/2016(SamL):     Created                                             */
/*  08/21/2017(artvvb):   Validated for Vivado 2015.4                         */
/*  11/03/2017(atangzwj): Validated for Vivado 2016.4                         */
/*  01/13/2018(atangzwj): Validated for Vivado 2017.4                         */
/*                                                                            */
/******************************************************************************/
/*  Baud Rates:                                                               */
/*                                                                            */
/*  Microblaze: 9600 or other as specified in UARTlite core                   */
/*  Zynq: 115200                                                              */
/*                                                                            */
/******************************************************************************/

#include "PmodJSTK.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"

#ifdef __MICROBLAZE__
#define CPU_CLOCK_FREQ_HZ (XPAR_CPU_CORE_CLOCK_FREQ_HZ)
#else
#define CPU_CLOCK_FREQ_HZ (XPAR_PS7_CORTEXA9_0_CPU_CLK_FREQ_HZ)
#endif

PmodJSTK joystick;

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

   xil_printf("test\r\n");
   // Initialize the joystick device
   JSTK_begin(
      &joystick,
      XPAR_PMODJSTK_0_AXI_LITE_SPI_BASEADDR,
      XPAR_PMODJSTK_0_AXI_LITE_GPIO_BASEADDR
   );
}

void DemoRun() {
   JSTK_DataPacket rawdata;
   u8 led;

   xil_printf("\r\nJoystick Demo\r\n");

   while (1) {
      // Capture button states and positional data
      rawdata = JSTK_getDataPacket(&joystick);

      xil_printf(
         "X:%d\tY:%d%s%s%s\r\n",
         rawdata.XData,
         rawdata.YData,
         (rawdata.Jstk != 0) ? "\tJoystick pressed" : "",
         (rawdata.Button1 != 0) ? "\tButton 1 pressed" : "",
         (rawdata.Button2 != 0) ? "\tButton 2 pressed" : ""
      );

      // Wait for 50ms
      usleep(50000);

      // Map LEDs to adjacent buttons
      led = 0x0;
      if (rawdata.Button1 != 0) {
         led |= 0x1;
      }
      if (rawdata.Button2 != 0) {
         led |= 0x2;
      }
      JSTK_setLeds(&joystick, led);
   }
}

void DemoCleanup() {
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
