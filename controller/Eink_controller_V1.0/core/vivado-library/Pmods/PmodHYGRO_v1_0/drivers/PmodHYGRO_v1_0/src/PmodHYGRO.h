/******************************************************************************/
/*                                                                            */
/* HYGROI2C.h -- Declaration for HYGROI2C library                             */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file declares the HYGROI2C library functions and the constants        */
/* involved.                                                                  */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    01/30/2017(ArtVVB):   Created                                           */
/*    02/21/2017(ArtVVB):   Validated                                         */
/*    11/08/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    02/17/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODHYGRO_H
#define PMODHYGRO_H

/************ Include Files ************/

#include "xiic.h"
#include "xiic_l.h"
#include "xil_types.h"
#include "xstatus.h"
#include "xtmrctr.h"


/************ Macro Definitions ************/

// Register address definitions
#define HYGRO_CONFIG 0x2
#define HYGRO_HUM    0x1
#define HYGRO_TEMP   0x0

// Bit mask definitions
#define HYGRO_CONFIG_RST     0x8000
#define HYGRO_CONFIG_HEAT    0x2000
#define HYGRO_CONFIG_MODE    0x1000
#define HYGRO_CONFIG_BTST    0x0800
#define HYGRO_CONFIG_TRES    0x0400
#define HYGRO_CONFIG_HRES8   0x0200
#define HYGRO_CONFIG_HRES11  0x0100

#define HYGRO_CONFIG_DEFAULT 0x1000


/************ Type Definitions ************/

typedef struct PmodHYGRO {
   XIic HYGROIic;
   XTmrCtr HYGROTimer;
   u32 clockFreqHz;
   u8 chipAddr;
   u8 currentRegister;
   u8 recvbytes;
   u8 *recv;
} PmodHYGRO;

void HYGRO_begin(PmodHYGRO *InstancePtr, u32 IIC_Address, u8 Chip_Address,
      u32 TMR_Address, UINTPTR TMR_DeviceId, u32 TMR_SysClockFreqHz);
void HYGRO_TimerInit(XTmrCtr *TMRInstancePtr, XTmrCtr_Config *TMRConfigPtr);
int HYGRO_IICInit(XIic *IicInstancePtr);
void HYGRO_ReadIIC(PmodHYGRO *InstancePtr, u8 reg, u8 *Data, int nData,
      u32 conversion_delay_ms);
void HYGRO_WriteIIC(PmodHYGRO *InstancePtr, u8 reg, u8 *Data, int nData);
void HYGRO_DelayMillis(PmodHYGRO *InstancePtr, u32 millis);

float HYGRO_getTemperature(PmodHYGRO *InstancePtr);
float HYGRO_getHumidity(PmodHYGRO *InstancePtr);
float HYGRO_tempF2C(float tempF);
float HYGRO_tempC2F(float tempC);

#endif // PMODHYGRO_H
