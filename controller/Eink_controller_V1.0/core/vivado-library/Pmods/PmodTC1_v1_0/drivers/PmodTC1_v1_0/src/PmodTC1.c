/******************************************************************************/
/*                                                                            */
/* PmodTC1.c -- Definitions for the PmodTC1 library                           */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains a basic library in order to read temperature from       */
/* Digilent's PmodTC1 thermocouple                                            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/02/2016(MikelS):   Created                                           */
/*    03/01/2017(ArtVVB):   Validated for Vivado 2015.4                       */
/*    02/14/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodTC1.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
  
/************************** Function Definitions ***************************/
XSpi_Config TC1Config =
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
/*** void TC1_begin()
**
**   Parameters:
**      InstancePtr: A PmodTC1 object to start
**      SPI_Address: The Base address of the PmodTC1 SPI
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Initialize the PmodTC1.
*/
void TC1_begin(PmodTC1 *InstancePtr, u32 SPI_Address) {
   TC1Config.BaseAddress = SPI_Address;
   TC1_SPIInit(&InstancePtr->TC1Spi);
}

/* ------------------------------------------------------------ */
/*** TC1_end()
**
**   Parameters:
**      InstancePtr: PmodTC1 object to stop
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Stops the device
*/
void TC1_end(PmodTC1 *InstancePtr) {
   XSpi_Stop(&InstancePtr->TC1Spi);
}

/* ------------------------------------------------------------ */
/*** TC1_SPIInit()
**
**   Parameters:
**      XSpi *SpiInstancePtr
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Initializes the PmodTC1 SPI.
*/

int TC1_SPIInit(XSpi *SpiInstancePtr) {
   int Status;

   Status = XSpi_CfgInitialize(SpiInstancePtr, &TC1Config,
         TC1Config.BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   u32 options = (XSP_MASTER_OPTION | XSP_CLK_ACTIVE_LOW_OPTION
         | XSP_CLK_PHASE_1_OPTION) | XSP_MANUAL_SSELECT_OPTION;
   Status = XSpi_SetOptions(SpiInstancePtr, options);
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
/*** TC1_readData()
**
**   Parameters:
**      InstancePtr: A PmodTC1 object to load data into
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Will read the bitstream from the TC1 and store it into data member
**      "data" of type int. Reads one int per function call.
*/
void TC1_readData(PmodTC1 *InstancePtr) {
   u8 byte[4];
   InstancePtr->data = 0;
   XSpi_Transfer(&InstancePtr->TC1Spi, byte, byte, 4);

   // Convert the byte array to an int
   InstancePtr->data |= byte[0];
   InstancePtr->data = InstancePtr->data << 8;
   InstancePtr->data |= byte[1];
   InstancePtr->data = InstancePtr->data << 8;
   InstancePtr->data |= byte[2];
   InstancePtr->data = InstancePtr->data << 8;
   InstancePtr->data |= byte[3];
}

/* ------------------------------------------------------------ */
/*** TC1_getTemp()
**
**   Parameters:
**      InstancePtr: Compute Celsius measurement from PmodTC1 object
**
**   Return Value:
**      double result -  value of the read temp data from readData
**
**   Errors:
**      None
**
**   Description:
**      Call readData and return that value in Celsius
*/
double TC1_getTemp(PmodTC1 *InstancePtr) {

   int modded = 0;
   int buffer = 0;
   double temp = 0;

   TC1_readData(InstancePtr);

   buffer = InstancePtr->data & 0xFFFC0000;

   // Shift over to LSB
   buffer = buffer >> 18;

   modded = buffer % 4;
   temp = (double) (buffer / 4);

   temp = temp + (modded * .25);

   return temp;
}

/* ------------------------------------------------------------ */
/*** TC1_getAMBTemp()
**
**   Parameters:
**      InstancePtr: A PmodTC1 object
**
**   Return Value:
**      double temperature of chip
**
**   Errors:
**      None
**
**   Description:
**      Will extract the chip temperature data from the data stream
*/
double TC1_getAMBTemp(PmodTC1 *InstancePtr){
   int buffer = 0;
   double ambTemp = 0;
   int modded = 0;

   TC1_readData(InstancePtr);

   buffer = InstancePtr->data & 0x0000FFF0;

   buffer = buffer >> 4;

   modded = buffer % 16;
   ambTemp = (double) (buffer / 16);

   ambTemp = ambTemp + (modded * .0625);

   return ambTemp;
}

/* ------------------------------------------------------------ */
/*** TC1_celToFar()
**
**   Parameters:
**      double celsius: value to convert to Fahrenheit
**
**   Return Value:
**      double farenheit: converted Fahrenheit value
**
**   Errors:
**      None
**
**   Description:
**      Converts a temperature in celsius to farenheit
*/
double TC1_tempC2F(double celsius) {
   return (celsius * 1.8) + 32;
}
