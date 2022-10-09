/******************************************************************************/
/*                                                                            */
/* PmodDPG1.h -- Driver definitions for the PmodDPG1                          */
/*                                                                            */
/******************************************************************************/
/* Author: Jon Peyron                                                         */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodDPG1 IP from Digilent           */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    08/10/2016(jpeyron):  Created                                           */
/*    09/29/2017(atangzwj): Validated for Vivado 2015.4                       */
/*    10/20/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    03/16/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODDPG1_H
#define PMODDPG1_H

/************ Include Files ************/

#include "xil_types.h"
#include "xspi_l.h"
#include "xspi.h"
#include "xstatus.h"


/************ Macro Definitions ************/

// Pressure unit codes
#define DPG1_KPA_PRESSURE_TYPE   0
#define DPG1_ATM_PRESSURE_TYPE   1
#define DPG1_PSI_PRESSURE_TYPE   2
#define DPG1_INH2O_PRESSURE_TYPE 3
#define DPG1_CMH2O_PRESSURE_TYPE 4
#define DPG1_MMHG_PRESSURE_TYPE  5


/************ Type Definitions ************/

typedef struct PmodDPG1 {
   XSpi DPG1Spi;
   u32 data;
} PmodDPG1;


/************ Function Prototypes ************/

void   DPG1_begin(PmodDPG1 *InstancePtr, u32 SPI_Address);
void   DPG1_end(PmodDPG1 *InstancePtr);
int    DPG1_SPIInit(XSpi *SpiInstancePtr);
void   DPG1_readData(PmodDPG1 *InstancePtr);
double DPG1_GetPressure(int pType, PmodDPG1 *InstancePtr);

#endif // PMODDPG1_H
