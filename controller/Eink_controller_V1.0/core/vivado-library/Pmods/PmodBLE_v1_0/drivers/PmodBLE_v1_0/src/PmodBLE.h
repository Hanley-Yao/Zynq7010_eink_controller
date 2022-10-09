/******************************************************************************/
/*                                                                            */
/* PmodBLE.h -- Driver definitions for the PmodBLE                            */
/*                                                                            */
/******************************************************************************/
/* Author: Thomas Kappenman                                    				  */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodBLE IP from Digilent            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*  01/15/2018(TommyK): Created                                       		  */
/*                                                                            */
/******************************************************************************/

#ifndef PMODBLE_H
#define PMODBLE_H

/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xuartns550.h"

/************************** Data Types ****************************/
typedef struct PmodBLE {
    u32 AXI_ClockFreq;
    u32 GpioBaseAddr;
    XUartNs550 Uart;
} PmodBLE;

/************************** Function Prototypes ****************************/

void BLE_Begin(PmodBLE* InstancePtr, u32 GPIO_Address, u32 UART_Address, u32 AXI_ClockFreq, u32 Uart_Baud);
int BLE_RecvData(PmodBLE* InstancePtr, u8 *Data, int nData);
int BLE_SendData(PmodBLE* InstancePtr, u8 *Data, int nData);
void BLE_ChangeBaud(PmodBLE* InstancePtr, int baud);
void BLE_WriteRTS(PmodBLE* InstancePtr, u8 enable);
int BLE_ReadCTS(PmodBLE* InstancePtr);
void BLE_SetReset(PmodBLE* InstancePtr, u8 Value);
int BLE_IsConnected(PmodBLE* InstancePtr);

#endif // PMODBLE_H
