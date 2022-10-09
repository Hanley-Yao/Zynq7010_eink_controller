/******************************************************************************/
/*                                                                            */
/* TX.c -- PmodCAN Example Projects                                           */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo sends data through the PmodCAN and sends it through UART as      */
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
CAN_Message DemoComposeMessage();
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

CAN_Message DemoComposeMessage() {
   CAN_Message message;

   message.id = 0x100;
   message.dlc = 6;
   message.eid = 0x15a;
   message.rtr = 0;
   message.ide = 0;
   message.data[0] = 0x01;
   message.data[1] = 0x02;
   message.data[2] = 0x04;
   message.data[3] = 0x08;
   message.data[4] = 0x10;
   message.data[5] = 0x20;
   message.data[6] = 0x40;
   message.data[7] = 0x80;

   return message;
}

void DemoRun() {
   CAN_Message TxMessage;
   u8 status;

   xil_printf("Welcome to the PmodCAN IP Core Transmit Demo\r\n");

   while (1) {
      xil_printf("Waiting to send\r\n");
      do {
         status = CAN_ReadStatus(&myDevice);
      } while ((status & CAN_STATUS_TX0REQ_MASK) != 0); // Wait for buffer 0 to
                                                        // be clear

      TxMessage = DemoComposeMessage();

      xil_printf("sending ");
      DemoPrintMessage(TxMessage);

      CAN_ModifyReg(&myDevice, CAN_CANINTF_REG_ADDR, CAN_CANINTF_TX0IF_MASK, 0);

      xil_printf("requesting to transmit message through transmit buffer 0 \
            \r\n");

      CAN_SendMessage(&myDevice, TxMessage, CAN_Tx0);

      CAN_ModifyReg(&myDevice, CAN_CANINTF_REG_ADDR, CAN_CANINTF_TX0IF_MASK, 0);

      do {
         status = CAN_ReadStatus(&myDevice);
         xil_printf("Waiting to complete transmission\r\n");
      } while ((status & CAN_STATUS_TX0IF_MASK) != 0); // Wait for message to
                                                       // transmit successfully

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
