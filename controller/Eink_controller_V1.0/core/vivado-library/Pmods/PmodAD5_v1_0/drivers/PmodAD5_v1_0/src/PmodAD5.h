/*************************************************************************/
/*                                                                       */
/*     PmodAD5.h --     PmodAD5 Driver Source							 */
/*                                                                       */
/*************************************************************************/
/*     Author: Jon Peyron                                                */
/*     Copyright 2017, Digilent Inc.                                     */
/*************************************************************************/
/*  Module Description:                                                  */
/*                                                                       */
/*            This file contains source code for the PmodAD5 driver    	 */
/*                                                                       */
/*************************************************************************/
/*  Revision History:                                                    */
/*                                                                       */
/*            12/19/2017(JPEYRON): Created                                */
/*                                                                       */
/*************************************************************************/

#ifndef PMODAD5_H
#define PMODAD5_H

/****************** Include Files ********************/

#include "xil_types.h"
#include "xstatus.h"
#include "xspi_l.h"
#include "xspi.h"

/* ------------------------------------------------------------ */
/*					Definitions									*/
/* ------------------------------------------------------------ */





typedef struct PmodAD5 {
	 XSpi AD5Spi;
	   u8 data1;
	   u8 data2;
	   u8 data3;

} PmodAD5;



/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */

void   AD5_begin(PmodAD5* InstancePtr, u32 SPI_Address);
void   AD5_end(PmodAD5* InstancePtr);
int    AD5_SPIInit(XSpi *SpiInstancePtr);
void   AD5_readData(PmodAD5* InstancePtr);
void   AD5_WriteConfig(PmodAD5* InstancePtr);
float  AD5_DataToVoltage(PmodAD5* InstancePtr);

#endif // PMODAD5_H
