/************************************************************************/
/*																		*/
/* PmodMTDS.c	--		Template driver for a Pmod which uses SPI		*/
/*																		*/
/************************************************************************/
/*	Author:		Thomas Kappenman										*/
/*	Copyright 2015, Digilent Inc.										*/
/************************************************************************/
/*
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
/************************************************************************/
/*  File Description:													*/
/*																		*/
/*	This file contains a template that you can use to create a library
/*	for the PmodMTDS (insert name, duh). 
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	04/19/2016(TommyK): Created 
/*																		*/
/************************************************************************/

/***************************** Include Files *******************************/
#include "PmodMTDS.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
/************************** Function Definitions ***************************/
XSpi_Config MTDSConfig =
{
	0,
	0,
	1,
	0,
	1,
	8,
	0,
	0,
	0,
	0,
	0
};
/* ------------------------------------------------------------ */
/***	void MTDS_begin(PmodMTDS* InstancePtr, u32 GPIO_Address, u32 SPI_Address)
**
**	Parameters:
**		InstancePtr: A PmodMTDS object to start
**		GPIO_Address: The Base address of the PmodMTDS GPIO
**		SPI_Address: The Base address of the PmodMTDS SPI
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Initialize the PmodMTDS.
*/
void MTDS_begin(PmodMTDS* InstancePtr, u32 GPIO_Address, u32 SPI_Address)
{
	InstancePtr->GPIO_addr=GPIO_Address;
	MTDSConfig.BaseAddress=SPI_Address;
	Xil_Out32(InstancePtr->GPIO_addr+4, 0b1111);//0b1111 for input 0b0000 for output, 0b0001 for pin1 in pin 2 out etc. 
	MTDS_SPIInit(&InstancePtr->MTDSSpi);
}
/* ------------------------------------------------------------ */
/***	MTDS_end(void)
**
**	Parameters:
**		InstancePtr		- PmodMTDS object to stop
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Stops the device
*/
void MTDS_end(PmodMTDS* InstancePtr){
	XSpi_Stop(&InstancePtr->MTDSSpi);
}

/* ------------------------------------------------------------ */
/***	MTDS_SPIInit
**
**	Parameters:
**		none
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Initializes the PmodMTDS SPI.

*/

int MTDS_SPIInit(XSpi *SpiInstancePtr){
	int Status;

	Status = XSpi_CfgInitialize(SpiInstancePtr, &MTDSConfig, MTDSConfig.BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}



	Status = XSpi_SetOptions(SpiInstancePtr, (XSP_MASTER_OPTION | XSP_CLK_ACTIVE_LOW_OPTION | XSP_CLK_PHASE_1_OPTION) | XSP_MANUAL_SSELECT_OPTION); //Change these based on your SPI device
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XSpi_SetSlaveSelect(SpiInstancePtr, 1);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Start the SPI driver so that the device is enabled.
	 */
	XSpi_Start(SpiInstancePtr);

	/*
	 * Disable Global interrupt to use polled mode operation
	 */
	XSpi_IntrGlobalDisable(SpiInstancePtr);

	return XST_SUCCESS;

}

/* ------------------------------------------------------------ */
/***	MTDS_Readbyte
**
**	Synopsis:
**		byte = MTDS_Readbyte(&MTDS)
**
**	Parameters:
**		PmodMTDS *InstancePtr	- the PmodMTDS object to communicate with
**
**	Return Value:
**		u8 byte	- Byte read from XSpi
**
**	Errors:
**		none
**
**	Description:
**		Reads SPI
*/

u8 MTDS_ReadByte(PmodMTDS* InstancePtr){
	u8 byte;
	XSpi_Transfer(&InstancePtr->MTDSSpi, &byte, &byte, 1);
	return byte;
}

/* ------------------------------------------------------------ */
/***	MTDS_WriteSPICommand
**
**	Parameters:
**		InstancePtr - PmodMTDS object to send to
**		cmd			- Command to send
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Writes a single byte over SPI
**
**
*/
void MTDS_WriteByte(PmodMTDS* InstancePtr, u8 cmd)
{
	XSpi_Transfer(&InstancePtr->MTDSSpi, &cmd, NULL, 1);
}

/* ------------------------------------------------------------ */
/***	MTDS_WriteSpi
**
**	Synopsis:
**		MTDS_WriteSpi(&MTDSobj, 0x3A, &bytearray, 5);
**
**	Parameters:
**		PmodMTDS *InstancePtr	- the PmodMTDS object to communicate with
**		u8 reg			- the starting register to write to
**		u8* wData		- the data to write
**		int nData		- the number of data bytes to write
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Writes the byte array to the chip via SPI. It will write the first byte into the specified register, then the next into the following register until all of the data has been sent.

*/
void MTDS_WriteSpi(PmodMTDS* InstancePtr, u8 reg, u8 *wData, int nData)
{
	// As requested by documentation, first byte contains:
	//	bit 7 = 0 because is a write operation
	//	bit 6 = 1 if more than one bytes is written, 0 if a single byte is written
	// 	bits 5-0 - the address
	u8 bytearray[nData+1];
	bytearray[0] = ((nData>1) ? 0x40: 0) | (reg&0x3F);
	memcpy(&bytearray[1],wData, nData);//Copy write commands over to bytearray
	XSpi_Transfer(&InstancePtr->MTDSSpi, bytearray, 0, nData+1);

}


/* ------------------------------------------------------------ */
/***	MTDS_ReadSpi
**
**	Synopsis:
**		MTDS_ReadSpi(&MTDSobj, 0x3A, &bytearray, 5);
**
**	Parameters:
**		PmodMTDS *InstancePtr	- the PmodMTDS object to communicate with
**		u8 reg			- the starting register to read from
**		u8* rData		- the byte array to read into
**		int nData		- the number of data bytes to read
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Reads data in through SPI. It will read the first byte from the starting register, then the next from the following register. Data is stored into rData.
*/
void MTDS_ReadSpi(PmodMTDS* InstancePtr, u8 reg, u8 *rData, int nData)
{
	// As requested by documentation, first byte contains:
	//	bit 7 = 1 because is a read operation
	//	bit 6 = 1 if more than one bytes is written, 0 if a single byte is written
	// 	bits 5-0 - the address
	u8 bytearray[nData+1];

	bytearray[0] = ((nData>1) ? 0xC0: 0x80) | (reg&0x3F);
	XSpi_Transfer(&InstancePtr->MTDSSpi, bytearray, bytearray, nData+1);
	memcpy(rData,&bytearray[1], nData);
}

/* ------------------------------------------------------------ */
/*        SetRegisterBits
**
**        Synopsis:
**				SetRegisterBits(&MTDSobj, MTDS_ADR_POWER_CTL, bPowerControlMask, fValue);
**        Parameters:
**        		PmodMTDS *InstancePtr		- the PmodMTDS object to communicate with
**				u8 bRegisterAddress 	- the address of the register whose bits are set
**				u8 bMask				- the mask indicating which bits are affected
**				bool fValue					- 1 if the bits are set or 0 if their bits are reset
**
**
**        Return Values:
**                void
**
**        Errors:
**
**
**        Description:
**				This function sets the value of some bits (corresponding to the bMask) of a register (indicated by bRegisterAddress) to 1 or 0 (indicated by fValue).
**
**
*/
void MTDS_SetRegisterBits(PmodMTDS* InstancePtr, u8 reg, u8 mask, bool fValue){
	u8 regval;
	MTDS_ReadSpi(InstancePtr, reg, &regval, 1);
	if (fValue)regval |= mask;
	else regval &= ~mask;
	MTDS_WriteSpi(InstancePtr, reg, &regval, 1);
}

/* ------------------------------------------------------------ */
/*        GetRegisterBits
**
**        Synopsis:
**				return GetRegisterBits(&MTDSobj, MTDS_ADR_BW_RATE, MSK_BW_RATE_RATE);
**        Parameters:
**        		PmodMTDS *InstancePtr	- the PmodMTDS object to communicate with
**				u8 bRegisterAddress 	- the address of the register whose bits are read
**				u8 bMask				- the mask indicating which bits are read
**
**
**        Return Values:
**                u8 					- a byte containing only the bits correspoding to the mask.
**
**        Errors:
**
**
**        Description:
**				Returns a byte containing only the bits from a register (indicated by bRegisterAddress), correspoding to the bMask mask.
**
**
*/
u8 MTDS_GetRegisterBits(PmodMTDS* InstancePtr, u8 bRegisterAddress, u8 bMask)
{
	u8 bRegValue;
	MTDS_ReadSpi(InstancePtr, bRegisterAddress, &bRegValue, 1);
	return bRegValue & bMask;
}

