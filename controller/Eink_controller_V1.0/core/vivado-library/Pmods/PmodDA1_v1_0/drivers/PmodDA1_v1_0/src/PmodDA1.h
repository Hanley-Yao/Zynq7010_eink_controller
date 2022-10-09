/******************************************************************************/
/*                                                                            */
/* PmodDA1.h -- Declaration for PmodDA1 library                               */
/*                                                                            */
/******************************************************************************/
/* Author: Jon Peyron                                                         */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file declares the DA1 library functions.                              */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/20/2016(JonP):     Created                                           */
/*    04/28/2017(ArtVVB):   Validated                                         */
/*    02/13/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODDA1_H
#define PMODDA1_H

/****************** Include Files ********************/

#include "xil_types.h"
#include "xspi.h"
#include "xspi_l.h"
#include "xstatus.h"

/* ------------------------------------------------------------ */
/*                  Definitions                                 */
/* ------------------------------------------------------------ */

#define DA1_SPI_NO_BITS              8    // Number of data bits per transaction
#define DA1_SPI_CTRL_BYTE            0x00 // Select DAC A to be written
#define DA1_SPI_ERR_SUCCESS          0    // The action completed successfully
#define DA1_SPI_ERR_VAL_OUT_OF_RANGE 1    // The value is out of range

typedef struct PmodDA1 {
   XSpi DA1Spi;
} PmodDA1;

/* ------------------------------------------------------------ */
/*                  Procedure Declarations                      */
/* ------------------------------------------------------------ */

void DA1_begin(PmodDA1 *InstancePtr, u32 SPI_Address);
void DA1_end(PmodDA1 *InstancePtr);
int DA1_SPIInit(XSpi *SpiInstancePtr);
u8 DA1_WriteIntegerValue(PmodDA1 *InstancePtr, u8 bIntegerValue);
u8 DA1_WritePhysicalValue(PmodDA1 *InstancePtr, float dPhysicalValue);

#endif // PMODDA1_H
