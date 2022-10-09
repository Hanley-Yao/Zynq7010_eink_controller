/******************************************************************************/
/*                                                                            */
/* RX.c -- PmodCAN Example Projects                                           */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo receives data through the PmodCAN and sends it through UART as   */
/* well.                                                                      */
/* Normal mode function                                                       */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    08/30/2017(ArtVVB):   Created                                           */
/*    09/01/2017(jPeyron):  Formatted Validated                               */
/*    09/06/2017(jPeyron):  Added RX and TX demos                             */
/*    02/24/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/
/* Baud Rates:                                                                */
/*                                                                            */
/*    Microblaze: 9600 or what was specified in UARTlite core                 */
/*    Zynq: 115200                                                            */
/*                                                                            */
/******************************************************************************/

#include "PmodCAN.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xparameters.h"

void DemoInitialize();
void DemoRun();
void DemoCleanup();
void DemoPrintMessage(CAN_Message message);
void EnableCaches();
void DisableCaches();

PmodCAN myDevice;

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();
   CAN_begin(&myDevice, XPAR_PMODCAN_0_AXI_LITE_GPIO_BASEADDR,
         XPAR_PMODCAN_0_AXI_LITE_SPI_BASEADDR);
   CAN_Configure(&myDevice, CAN_ModeNormalOperation);
}

void DemoPrintMessage(CAN_Message message) {
   u8 i;

   xil_printf("message:\r\n");

   xil_printf("    %s Frame\r\n", (message.ide) ? "Extended" : "Standard");
   xil_printf("    ID: %03x\r\n", message.id);

   if (message.ide)
      xil_printf("    EID: %05x\r\n", message.eid);

   if (message.rtr)
      xil_printf("    Remote Transmit Request\r\n");

   else
      xil_printf("    Standard Data Frame\r\n");

   xil_printf("    dlc: %01x\r\n", message.dlc);
   xil_printf("    data:\r\n");

   for (i = 0; i < message.dlc; i++)
      xil_printf("        %02x\r\n", message.data[i]);
}

void DemoRun() {
   CAN_Message RxMessage;
   CAN_RxBuffer target;
   u8 status;
   u8 rx_int_mask;

   xil_printf("Welcome to the PmodCAN IP Core Receive Demo\r\n");

   while (1) {
      do {
         status = CAN_ReadStatus(&myDevice);
         xil_printf("Waiting to receive\r\n");
      } while ((status & CAN_STATUS_RX0IF_MASK) != 0
            && (status & CAN_STATUS_RX1IF_MASK) != 0);

      switch (status & 0x03) {
      case 0b01:
      case 0b11:
         xil_printf("fetching message from receive buffer 0\r\n");
         target = CAN_Rx0;
         rx_int_mask = CAN_CANINTF_RX0IF_MASK;
         break;
      case 0b10:
         xil_printf("fetching message from receive buffer 1\r\n");
         target = CAN_Rx1;
         rx_int_mask = CAN_CANINTF_RX1IF_MASK;
         break;
      default:
         xil_printf("Error, message not received\r\n");
         continue;
      }

      CAN_ReceiveMessage(&myDevice, &RxMessage, target);

      CAN_ModifyReg(&myDevice, CAN_CANINTF_REG_ADDR, rx_int_mask, 0);

      xil_printf("received ");
      DemoPrintMessage(RxMessage);

      sleep(1);
   }
}

void DemoCleanup() {
   CAN_end(&myDevice);
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
