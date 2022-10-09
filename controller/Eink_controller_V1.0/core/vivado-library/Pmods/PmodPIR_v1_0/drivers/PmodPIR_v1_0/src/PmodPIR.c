
/******************************************************************************/
/*                                                                            */
/* PmodPIR.c -- Definition for PmodPIR library                                */
/*                                                                            */
/******************************************************************************/
/* Author: Jon Peyron                                                        */
/* Copyright 2019, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file defines functions for PmodPIR                                    */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/26/2019(JPeyron):   Created                                          */
/*                                                                            */
/******************************************************************************/



/***************************** Include Files *******************************/
#include "PmodPIR.h"


/************************** Function Definitions ***************************/

/* ------------------------------------------------------------ */



/***	void PIR_begin(PmodPIR* InstancePtr, u32 GPIO_Address)
**
**	Parameters:
**		InstancePtr: A PmodPIR object to start
**		GPIO_Address: The Base address of the PmodPIR GPIO
**
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Initialize the PmodPIR.
*/
void PIR_begin(PmodPIR* InstancePtr, u32 GPIO_Address)
{


	 InstancePtr->GPIO_addr = GPIO_Address;
	   // Set tri-state register, lower 4 pins are column outputs, upper 4 pins are
	   // row inputs
	 Xil_Out32(InstancePtr->GPIO_addr + 4, 0x1);




}


/***	u32 PIR_getState(PmodPIR* InstancePtr)
**
**	Parameters:
**		InstancePtr: A PmodPIR object to start
**
**
**
**	Return Value:
**		state of pin 1
**
**	Errors:
**		none
**
**	Description:
**		returns the state of pin 1 using the Xil_In32 function and masking all but pin 1 of the Pmod PIR
*/

u32 PIR_getState(PmodPIR* InstancePtr) {

	 return  Xil_In32(InstancePtr->GPIO_addr)& 0x1;
}

