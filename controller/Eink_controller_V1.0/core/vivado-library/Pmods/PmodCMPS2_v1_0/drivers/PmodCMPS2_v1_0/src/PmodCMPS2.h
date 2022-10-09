/******************************************************************************/
/*                                                                            */
/* PmodCMPS2.h -- Driver definitions for the PmodCMPS2                        */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodCMPS2 IP from Digilent.         */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    10/02/2017(artvvb):   Created                                           */
/*    02/17/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODCMPS2_H
#define PMODCMPS2_H

/****************** Include Files ********************/

#include "xiic.h"
#include "xiic_l.h"
#include "xil_types.h"
#include "xparameters.h"
#include "xstatus.h"

/****************** Register Definitions ********************/

#define CMPS2_INTCONREG0_REG            0x07
#define CMPS2_INTCONREG0_SETSENSOR_MASK 0x20
#define CMPS2_INTCONREG0_TAKEMEAS_MASK  0x01
#define CMPS2_INTCONREG1_REG            0x08
#define CMPS2_STATUS_REG                0x06
#define CMPS2_STATUS_MEASDONE_MASK      0x01

/****************** Type Definitions ********************/

typedef struct CMPS2_DataPacket {
   u16 x, y, z;
} CMPS2_DataPacket;

typedef struct PmodCMPS2 {
   XIic CMPS2Iic;
   u8 chipAddr;
   u8 currentRegister;
   u8 recvbytes;
   u8 *recv;
} PmodCMPS2;

/****************** Function Definitions ********************/

void CMPS2_begin(PmodCMPS2 *InstancePtr, u32 IIC_Address, u8 Chip_Address);
int CMPS2_IICInit(XIic *IicInstancePtr);
void CMPS2_ReadIIC(PmodCMPS2 *InstancePtr, u8 reg, u8 *Data, int nData);
void CMPS2_WriteIIC(PmodCMPS2 *InstancePtr, u8 reg, u8 *Data, int nData);

CMPS2_DataPacket CMPS2_GetData(PmodCMPS2 *InstancePtr);
void CMPS2_SetSensor(PmodCMPS2 *InstancePtr);
void CMPS2_SetOutputResolution(PmodCMPS2 *InstancePtr, u8 res);

#endif // PMODCMPS2_H
