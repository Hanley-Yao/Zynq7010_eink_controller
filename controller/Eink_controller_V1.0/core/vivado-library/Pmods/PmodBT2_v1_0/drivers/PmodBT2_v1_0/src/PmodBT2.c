/******************************************************************************/
/*                                                                            */
/* PmodBT2.c -- Driver definitions for the PmodBT2                            */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen, Thomas Kappenman                                     */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodBT2 IP from Digilent            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    07/12/2016(TommyK, MikelS): Created                                     */
/*    10/04/2017(artvvb):         Validated for Vivado 2015.4                 */
/*    01/30/2018(atangzwj):       Validated for Vivado 2017.4                 */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *****************************/

#include "PmodBT2.h"

/************************** Function Definitions *************************/

XUartNs550_Config BT2_Config =
{
   0,
   0,
   0,
   0
};

/* ------------------------------------------------------------ */
/* BT2_begin(PmodBT2 *InstancePtr, u32 GPIO_Address, u32 UART_Address)
**
** Parameters:
**    InstancePtr:   A PmodBT2 object to start
**    GPIO_Address:  The Base address of the PmodBT2 GPIO
**    UART_Address:  The Base address of the PmodBT2 UART
**    AXI_ClockFreq: The clock frequency of the PmodBT2 IP core's s_axi_aclk pin
**    Uart_Baud:     The default baud rate to use for the PmodBT2's UART
**                   connection
**
** Return Value:
**    none
**
** Errors:
**    none
**
** Description:
**    Initialize the PmodBT2.
**
******************************************************************/
void BT2_Begin(PmodBT2 *InstancePtr, u32 GPIO_Address, u32 UART_Address,
      u32 AXI_ClockFreq, u32 Uart_Baud) {
   BT2_Config.BaseAddress = UART_Address;
   BT2_Config.InputClockHz = AXI_ClockFreq;
   BT2_Config.DefaultBaudRate = Uart_Baud;
   InstancePtr->GpioBaseAddr = GPIO_Address;
   InstancePtr->AXI_ClockFreq = AXI_ClockFreq;

   Xil_Out32(InstancePtr->GpioBaseAddr + 4, 0x1);
   Xil_Out32(InstancePtr->GpioBaseAddr, 0x0); // set CTS to 0

   XUartNs550_CfgInitialize(&InstancePtr->Uart, &BT2_Config,
         BT2_Config.BaseAddress);
   XUartNs550_SetOptions(&InstancePtr->Uart, XUN_OPTION_FIFOS_ENABLE);
}

/* ------------------------------------------------------------ */
/* int BT2_RecvData(PmodBT2 *InstancePtr, u8 *Data, int nData)
**
** Parameters:
**    InstancePtr: PmodBT2 object to receive data from
**    Data:        Buffer to place read data into
**    ndata:       Number of bytes to read
**
** Return Value:
**    Number of bytes received
**
** Errors:
**    none
**
** Description:
**    Reads data from the BT2
**
******************************************************************/
int BT2_RecvData(PmodBT2 *InstancePtr, u8 *Data, int nData) {
   return XUartNs550_Recv(&InstancePtr->Uart, Data, nData);
}

/* ------------------------------------------------------------ */
/* int BT2_SendData(PmodBT2 *InstancePtr, u8 *Data, int nData)
**
** Parameters:
**    InstancePtr: PmodBT2 object to configure
**    Data:        Buffer of data to be sent
**    nData:       Number of bytes to be sent
**
** Return Value:
**    Return the number of bytes sent
**
** Errors:
**    none
**
** Description:
**    Sends a buffer of data to the BT2
**
******************************************************************/
int BT2_SendData(PmodBT2 *InstancePtr, u8 *Data, int nData) {
   return XUartNs550_Send(&InstancePtr->Uart, Data, nData);
}

/* ------------------------------------------------------------ */
/* BT2_changeBaud(PmodBT2 *InstancePtr, int baud)
**
** Parameters:
**    InstancePtr:  PmodBT2 object to configure
**    baud:         Desired baud rate to set the PmodBT2 to
**
** Return Value:
**    1 if successful, 0 if invalid baud
**
** Errors:
**    none
**
** Description:
**    Changes the baud rate of the PmodBT2
**
******************************************************************/
void BT2_ChangeBaud(PmodBT2 *InstancePtr, int baud) {
   XUartNs550_SetBaud(InstancePtr->Uart.BaseAddress, InstancePtr->AXI_ClockFreq,
         baud);
}
