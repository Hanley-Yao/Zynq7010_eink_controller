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

#ifndef PMODBT2_H
#define PMODBT2_H

/****************** Include Files ********************/

#include "xil_types.h"
#include "xstatus.h"
#include "xuartns550.h"

/************************** Data Types ****************************/

typedef struct PmodBT2 {
    u32 AXI_ClockFreq;
    u32 GpioBaseAddr;
    XUartNs550 Uart;
} PmodBT2;

/************************** Function Prototypes ****************************/

void BT2_Begin(PmodBT2 *InstancePtr, u32 GPIO_Address, u32 UART_Address,
      u32 AXI_ClockFreq, u32 Uart_Baud);
int BT2_RecvData(PmodBT2 *InstancePtr, u8 *Data, int nData);
int BT2_SendData(PmodBT2 *InstancePtr, u8 *Data, int nData);
void BT2_ChangeBaud(PmodBT2 *InstancePtr, int baud);

#endif // PMODBT2_H
