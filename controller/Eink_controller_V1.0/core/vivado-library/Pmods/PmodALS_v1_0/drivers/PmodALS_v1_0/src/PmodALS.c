/******************************************************************************/
/*                                                                            */
/* PmodALS.c -- Driver source for the PmodALS                                 */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodALS IP from Digilent            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    03/31/2016(tkappenman): Created                                         */
/*    08/24/2017(artvvb):     Validated for Vivado 2015.4                     */
/*    01/23/2018(atangzwj):   Validated for Vivado 2017.4                     */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodALS.h"

/************************** Function Definitions ***************************/

XSpi_Config XSpi_ALSConfig =
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
/*** XStatus ALS_begin(PmodALS *InstancePtr, u32 GPIO_Address, u32 SPI_Address)
**
**   Parameters:
**      InstancePtr: A PmodALS device to start
**      SPI_Address: The base address of the PmodALS SPI device
**
**   Return Value:
**      none
**
**   Description:
**      Initialize the PmodALS.
*/
XStatus ALS_begin(PmodALS *InstancePtr, u32 SPI_Address) {
   XSpi_ALSConfig.BaseAddress = SPI_Address;
   return ALS_SPIInit(&InstancePtr->ALSSpi);
}

/* ------------------------------------------------------------ */
/*** XStatus ALS_SPIInit(XSpi *SpiInstancePtr)
**
**   Parameters:
**      SpiInstancePtr: ALS AXI SPI device to initialize
**
**   Return Value:
**      Failure or success status
**
**   Description:
**      Initializes the PmodALS SPI.
*/
XStatus ALS_SPIInit(XSpi *SpiInstancePtr) {
   XStatus Status;
   XSpi_Config *ConfigPtr;

   /*
    * Initialize the SPI driver so that it is ready to use.
    */
   ConfigPtr = &XSpi_ALSConfig;
   if (ConfigPtr == NULL) {
      return XST_DEVICE_NOT_FOUND;
   }

   Status = XSpi_CfgInitialize(SpiInstancePtr, ConfigPtr,
         ConfigPtr->BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   u32 options = (XSP_MASTER_OPTION | XSP_CLK_ACTIVE_LOW_OPTION
         | XSP_CLK_PHASE_1_OPTION) | XSP_MANUAL_SSELECT_OPTION;
   Status =
         XSpi_SetOptions(SpiInstancePtr, options); // Manual SS off
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
/*** u8 ALS_read(PmodALS* InstancePtr)
**
**   Parameters:
**      PmodALS *InstancePtr: the PmodALS device to communicate with
**
**   Return Value:
**      u8 light: Light level from PmodALS
**
**   Description:
**      Captures ambient light sensor data
*/
u8 ALS_read(PmodALS* InstancePtr) {
   u8 light[2];
   XSpi_Transfer(&InstancePtr->ALSSpi, light, light, 2);
   return (light[0] << 3) | (light[1] >> 5);
}
