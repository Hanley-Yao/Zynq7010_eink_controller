
/******************************************************************************/
/*                                                                            */
/* PmodAQS.c -- Definition for PmodAQS library                                */
/*                                                                            */
/******************************************************************************/
/* Author: AJon Peyron                                                        */
/* Copyright 2019, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file defines functions for PmodAQS                                    */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    01/16/2019(JPeyron):   Created                                          */
/*                                                                            */
/******************************************************************************/


/***************************** Include Files *******************************/
#include "PmodAQS.h"
#include "xiic_l.h"
#include "xiic.h"
#include "xparameters.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>




void AQS_Init(PmodAQS* InstancePtr);



/************************** Function Definitions ***************************/
XIic_Config AQS_Config =
{

	0,
	0,
	0,
	2

};
static void StatusHandler(PmodAQS *InstancePtr);
/* ------------------------------------------------------------ */
/***	void AQS_begin(PmodAQS* InstancePtr, u32 IIC_Address)
**
**	Parameters:
**		InstancePtr: A PmodAQS object to start
**		IIC_Address: The Base address of the PmodAQS IIC
**		Chip_Address: 7 bit Pmod device address
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Initialize the IIC, set the GPIO pins to 0(IO/INT and WAKE/RST pins on the PmodAQS)
*/
void AQS_begin(PmodAQS* InstancePtr, u32 IIC_Address, u8 Chip_Address)
{

	u8 setValue= 0x00;
    u8 getValue[1];
	AQS_Config.BaseAddress=IIC_Address;
	InstancePtr->chipAddr=Chip_Address;
	AQS_IICInit(&InstancePtr->AQSIic);
	XIic_SetAddress(&InstancePtr->AQSIic, XII_ADDR_TO_SEND_TYPE, InstancePtr->chipAddr);


	XIic_SetGpOutput(&InstancePtr->AQSIic, setValue);

	XIic_GetGpOutput(&InstancePtr->AQSIic, getValue);

	AQS_Init(InstancePtr);
}

/* ------------------------------------------------------------ */
/***	void AQS_init(PmodAQS* InstancePtr)
**
**	Parameters:
**		InstancePtr: A PmodAQS object to start
**		IIC_Address: The Base address of the PmodAQS IIC
**		Chip_Address: 7 bit Pmod device address
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		start the bootloader app and configure the MEAS_MODE register
*/

void AQS_Init(PmodAQS* InstancePtr)
{
	u8 temp[2];
		u8 data[1];
	data[0]= 0x10;

	AQS_WriteIIC(InstancePtr, 0xF4 , temp , 0); //starting the bootloader app

	AQS_WriteIIC( InstancePtr, 0x01, data,  1); //setting the MEAS_MODE TO 0X10


	}

/* ------------------------------------------------------------ */
/***	void AQS_GetData(PmodAQS* InstancePtr, u8 reg, u8 *Data, int nData)
**
**	Parameters:
**		InstancePtr: A PmodAQS object to start
**		IIC_Address: The Base address of the PmodAQS IIC
**		Chip_Address: 7 bit Pmod device address
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Read the status register. When data is ready then read ALG_RESULT_DATA register.
*/
void AQS_GetData(PmodAQS* InstancePtr, u8 *Data)
{
  u8 temp[3];
 
		  AQS_ReadIIC(InstancePtr, 0x00 , temp , 1); //Reading the status register(0x00)

			if(temp[0]== 0x98|| temp[0] == 0x90) //is status is 0x98 or 0x90
			{
				

			temp[0]=  0x5B;
			AQS_WriteIIC(InstancePtr, 0x02 , temp  , 0); //Writing the ALG_RESULT_DATA(0x02)




			AQS_ReadIIC(InstancePtr, 0x02 , temp , 3); //Reading the ALG_RESULT_DATA(0x03)

			Data[0] = temp[0];
			Data[1] = temp[1];
			Data[2] = temp[2];

			AQS_ReadIIC(InstancePtr, 0x02 , temp , 2); //Reading the ALG_RESULT_DATA(0x02)

			Data[3] = temp[0];
			Data[4] = temp[1];
			}
	  
}


/* ------------------------------------------------------------ */
/***	AQS_end(void)
**
**	Parameters:
**		InstancePtr		- PmodAQS object to stop
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
void AQS_end(PmodAQS* InstancePtr){
	XIic_Stop(&InstancePtr->AQSIic);
}

/* ------------------------------------------------------------ */
/***	AQS_IICInit
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
**		Initializes the PmodAQS IIC.

*/

int AQS_IICInit(XIic *IicInstancePtr){
	int Status;

	Status = XIic_CfgInitialize(IicInstancePtr, &AQS_Config, AQS_Config.BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}



	/*
	 * Start the IIC driver so that the device is enabled.
	 */
	XIic_Start(IicInstancePtr);

	/*
	 * Disable Global interrupt to use polled mode operation
	 */
	XIic_IntrGlobalDisable(IicInstancePtr);

	return XST_SUCCESS;

}




/* ------------------------------------------------------------ */
/***	AQS_ReadIIC
**
**	Parameters:
**		InstancePtr - PmodAQS object to initialize
**		reg			- Register to read from
**		Data		- Pointer to recieve buffer
**		nData		- Number of data values to read
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Reads nData data bytes from register reg
**
*/
void AQS_ReadIIC(PmodAQS* InstancePtr, u8 reg, u8 *Data, int nData)
{
	int Status;
	Status = XIic_Start(&InstancePtr->AQSIic);
	if (Status != XST_SUCCESS) {
		return;
	}
	if (InstancePtr->currentRegister!=reg){
		//XIic_MasterSend(&InstancePtr->AQSIic, &reg, 1);
		XIic_Send(InstancePtr->AQSIic.BaseAddress, InstancePtr->chipAddr, &reg, 1, XII_REPEATED_START_OPTION);
		InstancePtr->currentRegister=reg;
	}//else{
		//XIic_MasterRecv(&InstancePtr->AQSIic, Data, nData);
	//}


	XIic_Recv(InstancePtr->AQSIic.BaseAddress, InstancePtr->chipAddr, Data, nData, XIIC_STOP);


	//XIic_MasterSend(&InstancePtr->AQSIic, &reg, 2);
	//InstancePtr->recvbytes=nData+1;
	//InstancePtr->recv=Data;
	//XIic_MasterRecv(&InstancePtr->AQSIic, Data, nData);

	Status = XIic_Stop(&InstancePtr->AQSIic);
	if (Status != XST_SUCCESS) {
		return;
	}
}

/* ------------------------------------------------------------ */
/***	AQS_WriteIIC
**
**	Parameters:
**		InstancePtr - PmodAQS object to initialize
**		reg			- Register to send to
**		Data		- Pointer to data buffer to send
**		nData		- Number of data values to send
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Writes nData data bytes to register reg
**
*/
void AQS_WriteIIC(PmodAQS* InstancePtr, u8 reg, u8 *Data, int nData)
{
	u8 out[10];
	out[0]=reg;
	out[1]=*Data;
	int Status;

	if (InstancePtr->currentRegister!=reg){
			InstancePtr->currentRegister=reg;
	}
	Status = XIic_Start(&InstancePtr->AQSIic);
	if (Status != XST_SUCCESS) {
		return;
	}
	XIic_Send(InstancePtr->AQSIic.BaseAddress, InstancePtr->chipAddr, out, nData+1, XIIC_STOP);

	//XIic_MasterSend(&InstancePtr->AQSIic, out, nData+1);

	//XIic_DynMasterSend(&InstancePtr->AQSIic, out, nData+1);

	//while(XIic_IsIicBusy(&InstancePtr->AQSIic));

	Status = XIic_Stop(&InstancePtr->AQSIic);
	if (Status != XST_SUCCESS) {
		return;
	}

}


static void StatusHandler(PmodAQS *InstancePtr){
	xil_printf("status\r\n");
}
