/******************************************************************************/
/*                                                                            */
/* PmodPIR.h -- Declaration for PmodPIR library                               */
/*                                                                            */
/******************************************************************************/
/* Author: JOn Peyron                                                         */
/* Copyright 2019, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file declares the PmodPIR library functions and the constants         */
/* involved.                                                                  */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/26/2019(JPeyron):   Created                                          */
/*                                                                            */
/******************************************************************************/


#ifndef PmodPIR_H
#define PmodPIR_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xil_io.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xparameters.h"





/* ------------------------------------------------------------ */
/*					Definitions									*/
/* ------------------------------------------------------------ */




typedef struct PmodPIR{
	u32 GPIO_addr;
}PmodPIR;

	void PIR_begin(PmodPIR* InstancePtr, u32 GPIO_Address);
	u32 PIR_getState(PmodPIR* InstancePtr);

#endif // PmodPIR_H
