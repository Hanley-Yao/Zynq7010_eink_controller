/******************************************************************************/
/*                                                                            */
/* PmodTMP3.h -- PmodTMP3 Library                                             */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains code for running a demonstration of the PmodTMP3 when   */
/* PmodTMP3 when used with the PmodTMP3 IP core.                              */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/09/2016(ABrown):   Created                                           */
/*    05/08/2017(jPeyron):  Updated                                           */
/*    11/10/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    01/13/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODTMP3_H
#define PMODTMP3_H

/************ Include Files ************/

#include "xiic.h"
#include "xiic_l.h"
#include "xil_types.h"
#include "xstatus.h"


/************ Macro Definitions ************/

// Register addresses
#define TMP3_REG_TEMP     0x0
#define TMP3_REG_CONFIG   0x1
#define TMP3_REG_HYST     0x2
#define TMP3_REG_LIMITSET 0x3

// Configuration settings
#define TMP3_ONESHOT   0x80 //One Shot mode
#define TMP3_RES9      0x00 //9-bit resolution
#define TMP3_RES10     0x20 //10-bit resolution
#define TMP3_RES11     0x40 //11-bit resolution
#define TMP3_RES12     0x60 //12-bit resolution
#define TMP3_FAULT1    0x00 //1 fault queue bits
#define TMP3_FAULT2    0x08 //2 fault queue bits
#define TMP3_FAULT4    0x10 //4 fault queue bits
#define TMP3_FAULT6    0x18 //6 fault queue bits
#define TMP3_ALERTLOW  0x00 //Alert bit active-low
#define TMP3_ALERTHIGH 0x04 //Alert bit active-high
#define TMP3_CMPMODE   0x00 //comparator mode
#define TMP3_INTMODE   0x02 //interrupt mode
#define TMP3_SHUTDOWN  0x01 //Shutdown enabled
#define	TMP3_STARTUP   0x00 //Shutdown Disabled

//Device Constants
#define TMP3_ADDR 0x48 // Based on jumpers JP1, JP2, and JP3
                       // A table explaining the various address configurations
                       // is available in the PmodTMP3 reference manual

#define TMP3_CONF_DEFAULT \
      (TMP3_RES9 | TMP3_FAULT1 | TMP3_ALERTLOW | TMP3_CMPMODE)
      // Default Startup Configuration Used, this is just so the device can be
      // reset to startup configurations at a later time, it doesn't need to be
      // called anywhere.


/************ Type Definitions ************/

typedef struct PmodTMP3 {
   XIic TMP3Iic;
   u8 chipAddr;
   u8 currentRegister;
   u8 recvbytes;
   u8 *recv;
} PmodTMP3;


/************ Function Prototypes ************/

void TMP3_begin(PmodTMP3 *InstancePtr, u32 IIC_Address, u8 Chip_Address);
void TMP3_end(PmodTMP3 *InstancePtr);
int  TMP3_IICInit(XIic *IicInstancePtr);
void TMP3_ReadIIC(PmodTMP3 *InstancePtr, u8 reg, u8 *Data, int nData);
void TMP3_WriteIIC(PmodTMP3 *InstancePtr, u8 reg, u8 *Data, int nData);
void TMP3_config(PmodTMP3 *InstancePtr, u8 configuration);
double TMP3_getTemp(PmodTMP3 *InstancePtr);
double TMP3_FtoC(double tempF);
double TMP3_CtoF(double tempC);

#endif // PMODTMP3_H
