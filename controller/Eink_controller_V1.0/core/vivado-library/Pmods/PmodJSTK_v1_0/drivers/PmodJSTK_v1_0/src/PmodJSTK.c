/******************************************************************************/
/*                                                                            */
/* PmodJSTK.c -- Driver source for the PmodJSTK                               */
/*                                                                            */
/******************************************************************************/
/* Author: Samuel Lowe`                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodJSTK IP from Digilent           */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/01/2016(SamL):     Created                                           */
/*    08/21/2017(ArtVVB):   Validated for Vivado 2015.4                       */
/*    11/03/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    01/13/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodJSTK.h"
#include "sleep.h"

/************************** Function Definitions ***************************/

XSpi_Config JSTKConfig =
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
/*** void JSTK_begin(PmodJSTK* InstancePtr, u32 SPI_Address, u32 GPIO_Address)
**
**   Parameters:
**      InstancePtr:    A PmodJSTK object to start
**      SPI_Address:    The base address of the PmodJSTK SPI Device
**      GPIO_Address:   The base address of the PmodJSTK Chip-Select GPIO Device
**
**   Return Value:
**      none
**
**   Description:
**      Initialize the JSTK IP
*/
void JSTK_begin(PmodJSTK *InstancePtr, u32 SPI_Address, u32 GPIO_Address) {
   JSTKConfig.BaseAddress = SPI_Address;
   InstancePtr->GpioAddr = GPIO_Address;
   InstancePtr->LedState = 0;
   JSTK_SPIInit(&InstancePtr->SpiDevice);
   Xil_Out32(InstancePtr->GpioAddr + 4, 0x0);
   Xil_Out32(InstancePtr->GpioAddr, 0x1);
   JSTK_getDataPacket(InstancePtr);
}

/* ------------------------------------------------------------ */
/*** JSTK_end(void)
**
**	 Parameters:
**      InstancePtr - PmodJSTK device to stop
**
**   Return Value:
**      none
**
**  Description:
**      Clean up the JSTK
*/
void JSTK_end(PmodJSTK *InstancePtr) {
   XSpi_Stop(&InstancePtr->SpiDevice);
}

/* ------------------------------------------------------------ */
/*** int JSTK_SPIInit(XSpi *SpiInstancePtr)
**
**   Parameters:
**      SpiInstancePtr: JSTK SPI driver device to initialize
**
**   Return Value:
**      XST_SUCCESS or XST_FAILURE
**
**   Description:
**      Initializes the PmodJSTK SPI.
*/
int JSTK_SPIInit(XSpi *SpiInstancePtr) {
   int Status;

   Status = XSpi_CfgInitialize(SpiInstancePtr, &JSTKConfig,
         JSTKConfig.BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   Status = XSpi_SetOptions(SpiInstancePtr,
         XSP_MASTER_OPTION | XSP_MANUAL_SSELECT_OPTION);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   // Even though we are generating the CS signal through the GPIO controller,
   // the SPI driver does not work without this statement
   Status = XSpi_SetSlaveSelect(SpiInstancePtr, 1);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   // Start the SPI driver so that the device is enabled.
   XSpi_Start(SpiInstancePtr);

   // Disable Global interrupt to use polled mode operation
   XSpi_IntrGlobalDisable(SpiInstancePtr);

   return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/*** void JSTK_getBtn(PmodJSTK* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK object to start
**
**   Return Value:
**      btn: The 8 bit representation of the buttons which are in the
**           0th and 1st positions
**
**   Description:
**      Gets the push button states of the PmodJSTK2
**      The button states can be accessed from the return value of this function
**      with the following macros:
**         JSTK_<bn/bit>Button1 : 1 if BTN1 is pressed
**         JSTK_<bn/bit>Button2 : 1 if BTN2 is pressed
**         JSTK_<bn/bit>JSTK	 : 1 if the joystick inline button is pressed
**      In order to test a button state, the following operation is recommended:
**         if ((Status & JSTK_bit<a button bit name>) != 0)
*/
void JSTK_setLeds(PmodJSTK *InstancePtr, u8 leds) {
   InstancePtr->LedState = leds;

   JSTK_getDataPacket(InstancePtr);
}

/* ------------------------------------------------------------ */
/*** JSTK_DataPacket JSTK_getDataPacket(PmodJSTK* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK device to interact with
**
**   Return Value:
**      A basic data packet containing button states and X and Y position data
**
**   Description:
**      Captures state data from the JSTK
*/
JSTK_DataPacket JSTK_getDataPacket(PmodJSTK *InstancePtr) {
	u8 recv[5] = {0};
	JSTK_DataPacket rawdata;

	recv[0] = 0x80 | InstancePtr->LedState;

	JSTK_getData(InstancePtr, recv, 5);

	rawdata.XData = recv[0] | (recv[1] << 8);
	rawdata.YData = recv[2] | (recv[3] << 8);
	rawdata.Button1 = (recv[4] & JSTK_bitButton1) >> JSTK_bnButton1;
	rawdata.Button2 = (recv[4] & JSTK_bitButton2) >> JSTK_bnButton2;
	rawdata.Jstk = (recv[4] & JSTK_bitJstk) >> JSTK_bnJstk;

	return rawdata;
}

/* ------------------------------------------------------------ */
/*** void JSTK_getData(PmodJSTK* InstancePtr, u8* recv, u8 nData)
**
**   Parameters:
**      InstancePtr: A PmodJSTK device to capture from
**      recv:        A byte array to act as the receive and send buffer
**      nData:       The number of bytes to send and receive, recv must be at
**                   least this size
**
**   Return Value:
**      none
**
**   Description:
**      Manages a SPI transaction with the PmodJSTK
**
**   Problems:
**      Holding the chip select low between bytes through the QSPI driver isn't
**      working so bit-banging that line with an AXI GPIO controller instead
*/
void JSTK_getData(PmodJSTK *InstancePtr, u8 *recv, u8 nData) {
   int i = 0;

   // Bring chip select low
   Xil_Out32(InstancePtr->GpioAddr, 0x0);

   usleep(5); // 5 us delay from cs->low to first byte

   for (i = 0; i < nData; i++) {
      usleep(10); // 10 us delay between bytes
      XSpi_Transfer(&InstancePtr->SpiDevice, &recv[i], &recv[i], 1);
   }

   usleep(20); // 20 us delay from last packet to cs->high

   // Bring chip select high
   Xil_Out32(InstancePtr->GpioAddr, 0x1);

   usleep(25);
}
