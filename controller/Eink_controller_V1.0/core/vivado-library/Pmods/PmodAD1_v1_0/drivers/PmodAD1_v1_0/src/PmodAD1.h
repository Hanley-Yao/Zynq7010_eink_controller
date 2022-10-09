/******************************************************************************/
/*                                                                            */
/* PmodAD1.h -- PmodAD1 Driver Definitions                                    */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains definitions for the PmodAD1 driver                      */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    08/15/2017(ArtVVB):   Created                                           */
/*    02/10/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODAD1_H
#define PMODAD1_H

/****************** Include Files ********************/

#include "xil_io.h"
#include "xil_types.h"

/* ------------------------------------------------------------ */
/*                  Definitions                                 */
/* ------------------------------------------------------------ */

#define AD1_NUM_BITS  12
#define AD1_DATA_MASK 0xFFF

typedef struct PmodAD1 {
   u32 BaseAddress;
} PmodAD1;

typedef u16 AD1_RawData[2];
typedef float AD1_PhysicalData[2];

/* ------------------------------------------------------------ */
/*                  Procedure Declarations                      */
/* ------------------------------------------------------------ */

void AD1_begin(PmodAD1 *InstancePtr, u32 SPI_Address);
void AD1_GetSample(PmodAD1 *InstancePtr, AD1_RawData *RawDataPtr);
void AD1_RawToPhysical(float ReferenceVoltage, AD1_RawData RawData,
      AD1_PhysicalData *PhysicalDataPtr);

#endif // PMODAD1_H
