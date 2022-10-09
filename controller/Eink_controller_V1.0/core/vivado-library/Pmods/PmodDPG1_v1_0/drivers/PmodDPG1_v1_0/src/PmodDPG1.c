/******************************************************************************/
/*                                                                            */
/* PmodDPG1.c -- Driver definitions for the PmodDPG1                          */
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

/***************************** Include Files *******************************/

#include "PmodDPG1.h"


/************************** Function Definitions ***************************/

XSpi_Config DPG1Config =
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
/*** void DPG1_begin(PmodDPG1 *InstancePtr, u32 SPI_Address)
 **
 **  Parameters:
 **     InstancePtr: A PmodDPG1 object to start
 **     SPI_Address: The Base address of the PmodDPG1 SPI
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Initialize the PmodDPG1.
 */
void DPG1_begin(PmodDPG1 *InstancePtr, u32 SPI_Address) {
   DPG1Config.BaseAddress = SPI_Address;
   DPG1_SPIInit(&InstancePtr->DPG1Spi);
}

/* ------------------------------------------------------------ */
/*** DPG1_end(void)
 **
 **  Parameters:
 **     InstancePtr: PmodDPG1 object to stop
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Stops the device
 */
void DPG1_end(PmodDPG1 *InstancePtr) {
   XSpi_Stop(&InstancePtr->DPG1Spi);
}

/* ------------------------------------------------------------ */
/*** DPG1_SPIInit
 **
 **  Parameters:
 **     None
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Initializes the PmodDPG1 SPI.
 */
int DPG1_SPIInit(XSpi *SpiInstancePtr) {
   int Status;

   Status = XSpi_CfgInitialize(SpiInstancePtr, &DPG1Config,
         DPG1Config.BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   Status = XSpi_SetOptions(SpiInstancePtr, (XSP_MASTER_OPTION
         | XSP_CLK_ACTIVE_LOW_OPTION | XSP_CLK_PHASE_1_OPTION)
         | XSP_MANUAL_SSELECT_OPTION);
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
/*** DPG1_ReadSpi
 **
 **  Synopsis:
 **     DPG1_ReadSpi(&DPG1obj);
 **
 **  Parameters:
 **     InstancePtr: the PmodDPG1 object to communicate with
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Reads data in through SPI. It will read the first byte from the starting
 **     register, then the next from the following register. Data is stored into
 **     data.
 */
void DPG1_readData(PmodDPG1 *InstancePtr) {
   u8 byte[4];
   InstancePtr->data = 0;
   XSpi_Transfer(&InstancePtr->DPG1Spi, byte, byte, 4);

   // Convert the byte array to an int
   InstancePtr->data |= byte[0];
   InstancePtr->data = InstancePtr->data << 8;
   InstancePtr->data |= byte[1];
}

/* ------------------------------------------------------------ */
/*** DPG1_GetPressure
 **
 **  Synopsis:
 **     myDPG1_GetPressure();
 **
 **  Parameters:
 **     int pType (0 by default, meaning kPa) - pressure unit of return
 **
 **  Return Values:
 **     double - the pressure data after it's been calculated
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     This function takes the data from the Pmod, and calculates its pressure
 **     in a variety of pressure units. By default, it will return pressure in
 **     units of kPa.
 */
double DPG1_GetPressure(int pType, PmodDPG1 *InstancePtr) {
   // Calculate kPa from raw data
   double kPa = (InstancePtr->data / 4096.0 - 0.08) / 0.09;

   switch (pType) {
   case 0:
      return kPa; // kilopascal (kPa)
   case 1:
      return kPa / 101.325; // atmospheres (atm)
   case 2:
      return kPa * 0.145038; // pound-force per square inch (psi)
   case 3:
      return kPa * 4.01865; // inches of water (inH2O)
   case 4:
      return kPa * 10.1972; // centimeters of water (cmH2O)
   case 5:
      return kPa * 760.0 / 101.325; // millimeters of mercury (mmHg)
   default:
      return kPa;
   }
}
