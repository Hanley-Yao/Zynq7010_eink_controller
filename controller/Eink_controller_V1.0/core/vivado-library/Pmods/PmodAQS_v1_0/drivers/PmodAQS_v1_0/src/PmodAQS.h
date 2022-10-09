/******************************************************************************/
/*                                                                            */
/* PmodAQS.h -- Declaration for PmodAQS library                               */
/*                                                                            */
/******************************************************************************/
/* Author: JOn Peyron                                                         */
/* Copyright 2019, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file declares the PmodAQS library functions and the constants         */
/* involved.                                                                  */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    01/16/2019(JPeyron):   Created                                          */
/*                                                                            */
/******************************************************************************/
#ifndef PMODAQS_H
#define PMODAQS_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xiic_l.h"
#include "xiic.h"
#include "xparameters.h"
#include "sleep.h"

/* ------------------------------------------------------------ */
/*					Definitions									*/
/* ------------------------------------------------------------ */
#define bool u8
#define true 1
#define false 0


/* ------------------------------------------------------------ */
/*		Register addresses Definitions							*/
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*				Bit masks Definitions							*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Parameters Definitions							*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */

typedef struct PmodAQS{
	XIic AQSIic;
	u8 chipAddr;
	u8 currentRegister;
	u8 recvbytes;
	u8* recv;

}PmodAQS;

void AQS_begin(PmodAQS* InstancePtr, u32 IIC_Address, u8 Chip_Address);
void AQS_end(PmodAQS* InstancePtr);
int AQS_IICInit(XIic *IicInstancePtr);
void AQS_ReadIIC(PmodAQS* InstancePtr, u8 reg, u8 *Data, int nData);
void AQS_WriteIIC(PmodAQS* InstancePtr, u8 reg, u8 *Data, int nData);

void AQS_GetData(PmodAQS* InstancePtr, u8 *Data);

#endif // PMODAQS_H
