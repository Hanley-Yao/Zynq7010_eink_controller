/******************************************************************************/
/*                                                                            */
/* PmodBLE.c -- Driver definitions for the PmodBLE                            */
/*                                                                            */
/******************************************************************************/
/* Author: Thomas Kappenman        				                              */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodBLE IP from Digilent            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*  07/12/2016(TommyK: Created			                                      */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *****************************/
#include "PmodBLE.h"
/************************** Function Definitions *************************/
XUartNs550_Config BLE_Config =
{
		0,
		0,
		0,
		0
};

/* ------------------------------------------------------------ */
/*  BLE_begin(PmodBLE* InstancePtr, u32 GPIO_Address, u32 UART_Address)
**
**  Parameters:
**      InstancePtr:    A PmodBLE object to start
**      GPIO_Address:   The Base address of the PmodBLE GPIO
**      UART_Address:   The Base address of the PmodBLE UART
**      AXI_ClockFreq:  The clock frequency of the PmodBLE IP core's s_axi_aclk pin
**      Uart_Baud:      The default baud rate to use for the PmodBLE's UART connection
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Initialize the PmodBLE.
**
******************************************************************/
void BLE_Begin(PmodBLE* InstancePtr, u32 GPIO_Address, u32 UART_Address, u32 AXI_ClockFreq, u32 Uart_Baud)
{
	BLE_Config.BaseAddress = UART_Address;
	BLE_Config.InputClockHz = AXI_ClockFreq;
	BLE_Config.DefaultBaudRate = Uart_Baud;
	InstancePtr->GpioBaseAddr=GPIO_Address;
	InstancePtr->AXI_ClockFreq = AXI_ClockFreq;
	
	Xil_Out32(InstancePtr->GpioBaseAddr, 0b1111);//Set output of GPIO Pins on the bottom row of the pmod
	Xil_Out32(InstancePtr->GpioBaseAddr+8, 0b00);//Set output of RTS CTS
	Xil_Out32(InstancePtr->GpioBaseAddr+4, 0b1001);//Set tristates of bottom row
	Xil_Out32(InstancePtr->GpioBaseAddr+12, 0b10);//RTS output, CTS input
	
	XUartNs550_CfgInitialize(&InstancePtr->Uart, &BLE_Config, BLE_Config.BaseAddress);
    XUartNs550_SetOptions(&InstancePtr->Uart, XUN_OPTION_FIFOS_ENABLE);
}

/* ------------------------------------------------------------ */
/*  int BLE_RecvData(PmodBLE* InstancePtr, u8 *Data, int nData)
**
**  Parameters:
**    InstancePtr:  PmodBLE object to receive data from
**    Data:         buffer to place read data into
**    ndata:        number of bytes to read
**
**  Return Value:
**    Number of bytes received
**
**  Errors:
**    none
**
**  Description:
**    Reads data from the BLE
**
******************************************************************/
int BLE_RecvData(PmodBLE* InstancePtr, u8 *Data, int nData)
{
    return XUartNs550_Recv(&InstancePtr->Uart, Data, nData);
}

/* ------------------------------------------------------------ */
/*  int BLE_SendData(PmodBLE* InstancePtr, u8* Data, int nData)
**
**  Parameters:
**    InstancePtr:  PmodBLE object to configure
**    Data:         buffer of data to be sent
**    nData:        number of bytes to be sent
**
**  Return Value:
**    Return the number of bytes sent
**
**  Errors:
**    none
**
**  Description:
**    Sends a buffer of data to the BLE
**
******************************************************************/
int BLE_SendData(PmodBLE* InstancePtr, u8* Data, int nData)
{
    return XUartNs550_Send(&InstancePtr->Uart, Data, nData);
}

/* ------------------------------------------------------------ */
/*  BLE_changeBaud(PmodBLE* InstancePtr, int baud)
**
**  Parameters:
**    InstancePtr:  PmodBLE object to configure
**    baud:         Desired baud rate to set the PmodBLE to
**
**  Return Value:
**    1 if successful, 0 if invalid baud
**
**  Errors:
**    none
**
**  Description:
**    Changes the baud rate of the PmodBLE
**
******************************************************************/
void BLE_ChangeBaud(PmodBLE* InstancePtr, int baud) {
    XUartNs550_SetBaud(InstancePtr->Uart.BaseAddress, InstancePtr->AXI_ClockFreq, baud);
}

/* ------------------------------------------------------------ */
/*  BLE_WriteRTS(PmodBLE* InstancePtr, bool enable)
**
**  Parameters:
**	  InstancePtr:	PmodBLE object to write to
**	  bool:			Enable
**
**  Return Value:
**	  void
**
**  Errors:
**    none
**
**  Description:
**    Enables or disables the RTS pin
**
******************************************************************/
void BLE_WriteRTS(PmodBLE* InstancePtr, u8 enable){
	Xil_Out32(InstancePtr->GpioBaseAddr+8, enable);
}

/* ------------------------------------------------------------ */
/*  BLE_ReadCTS(PmodBLE* InstancePtr)
**
**  Parameters:
**	  InstancePtr: PmodBLE object to read from
**
**  Return Value:
**	  pin value if read
**
**  Errors:
**    none
**
**  Description:
**    Reads from the CTS pin
**
******************************************************************/
int BLE_ReadCTS(PmodBLE* InstancePtr){
	return Xil_In32(InstancePtr->GpioBaseAddr+8)&0b10;
}

/* ------------------------------------------------------------ */
/*  BLE_SetReset(PmodBLE* InstancePtr, bool Value)
**
**  Parameters:
**	  InstancePtr: PmodBLE object to set Reset value of
**	  Value:	Value to set Reset pin to
**
**  Return Value:
**	  none
**
**  Errors:
**    none
**
**  Description:
**    Sets the Reset pin to the specified value
**
******************************************************************/
void BLE_SetReset(PmodBLE* InstancePtr, u8 Value){
	if (Value){
		Xil_Out32(InstancePtr->GpioBaseAddr, Xil_In32(InstancePtr->GpioBaseAddr)|0b0010);//Set reset pin high (turn off reset)
	}
	else{
		Xil_Out32(InstancePtr->GpioBaseAddr, Xil_In32(InstancePtr->GpioBaseAddr) & 0b1101);//Set reset pin low (turn on reset)
	}
}

/* ------------------------------------------------------------ */
/*  BLE_IsConnected(PmodBLE* InstancePtr)
**
**  Parameters:
**	  InstancePtr: PmodBLE object to read
**
**  Return Value:
**	  1 if connected, 0 if not
**
**  Errors:
**    none
**
**  Description:
**    Reads the P1_6/STATUS Pin to determine if the PmodBLE is connected to a device or not
**
******************************************************************/

int BLE_IsConnected(PmodBLE* InstancePtr){
	return (Xil_In32(InstancePtr->GpioBaseAddr)&0b1000) ? 0 : 1;
}
