/******************************************************************************/
/*                                                                            */
/* PmodAD1.c -- PmodAD1 Driver Source                                         */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains source code for the PmodAD1 driver                      */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    08/15/2017(ArtVVB):   Created                                           */
/*    02/10/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodAD1.h"

/************************** Function Definitions ***************************/

/* ------------------------------------------------------------ */
/*** void AD1_begin(PmodAD1 *InstancePtr, u32 BaseAddress)
**
**   Parameters:
**      InstancePtr: A PmodAD1 object to start
**      BaseAddress: The base address of the PmodAD1 AXI_LITE_SAMPLE interface
**
**   Description:
**      Initialize the PmodAD1 device - note that the AD1 IP is free-running,
**      and this function just prepares the driver for use.
*/
void AD1_begin(PmodAD1 *InstancePtr, u32 BaseAddress) {
   InstancePtr->BaseAddress = BaseAddress;
}

/* ------------------------------------------------------------ */
/*** void AD1_GetSample(PmodAD1 *InstancePtr, AD1_RawData *RawDataPtr)
**
**   Parameters:
**      InstancePtr: A PmodAD1 object to start
**      RawDataPtr:  Pointer to an array of raw data to return values in
**
**   Return:
**      *RawDataPtr: an array of unsigned 16 bit integers to store the ADC data
**         Channel 1's 12 bit data is stored in the RawData array at index 0
**         Channel 2's 12 bit data is stored in the RawData array at index 1
**
**   Description:
**      This function captures the most recently read sample from the PmodAD1 IP
**      core.
*/
void AD1_GetSample(PmodAD1 *InstancePtr, AD1_RawData *RawDataPtr) {
   u32 data;
   data = Xil_In32(InstancePtr->BaseAddress);
   (*RawDataPtr)[0] = data & AD1_DATA_MASK;
   (*RawDataPtr)[1] = (data >> 16) & AD1_DATA_MASK;
}

/* ------------------------------------------------------------ */
/*** void AD1_RawToPhysical(float ReferenceVoltage, AD1_RawData RawData,
**         AD1_PhysicalData *PhysicalDataPtr)
**
**   Parameters:
**      ReferenceVoltage: Floating point representation of the voltage available
**                        to the AD1's VCC pin.
**      RawData:          Array of raw 12 bit sample data received from the
**                        PmodAD1
**      PhysicalDataPtr:  Pointer to an array of floats to return values in
**
**   Return:
**      *PhysicalDataPtr: an array of floats to store the converted data in.
**
**   Description:
**      This function converts an AD1 sample to a human readable value.
*/
void AD1_RawToPhysical(float ReferenceVoltage, AD1_RawData RawData,
      AD1_PhysicalData *PhysicalDataPtr) {
   float conversionFactor = ReferenceVoltage / ((1 << AD1_NUM_BITS) - 1);
   (*PhysicalDataPtr)[0] = ((float) RawData[0]) * conversionFactor;
   (*PhysicalDataPtr)[1] = ((float) RawData[1]) * conversionFactor;
}
