/*************************************************************************/
/*                                                                       */
/*     PmodAD5.c --     PmodAD5 Driver Source							 */
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

/***************************** Include Files *******************************/

#include "PmodAD5.h"



/************************** Function Definitions ***************************/
XSpi_Config AD5Config =
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
/***	void AD1_begin(PmodAD5* InstancePtr, u32 BaseAddress)
**
**	Parameters:
**		InstancePtr: A PmodAD5 object to start
**		BaseAddress: The base address of the PmodAD5 AXI_LITE_SAMPLE interface
**
**	Description:
**		Initialize the PmodAD5 device - note that the AD5 IP is free-running, and this function just prepares the driver for use.
**		Also calls AD5_WriteConfig which configures the AD5 for a gain of 1 and set to differential.
*/
void AD5_begin(PmodAD5* InstancePtr, u32 SPI_Address)
{
	  AD5Config.BaseAddress = SPI_Address;
	   AD5_SPIInit(&InstancePtr->AD5Spi);
	   AD5_WriteConfig(InstancePtr);

}


/* ------------------------------------------------------------ */
/***    AD5_end(void)
 **
 **      Parameters:
 **              InstancePtr - PmodAd5 object to stop
 **
 **      Return Value:
 **              none
 **
 **      Errors:
 **              none
 **
 **      Description:
 **              Stops the device
 */
void AD5_end(PmodAD5* InstancePtr) {
   XSpi_Stop(&InstancePtr->AD5Spi);
}

/* ------------------------------------------------------------ */
/***    AD5_SPIInit
 **
 **     Parameters:
 **             none
 **
 **     Return Value:
 **             none
 **
 **     Errors:
 **             none
 **
 **     Description:
 **             Initializes the PmodAD5 SPI.
 */
int AD5_SPIInit(XSpi *SpiInstancePtr) {
   int Status;

   Status = XSpi_CfgInitialize(SpiInstancePtr, &AD5Config,
         AD5Config.BaseAddress);
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
/***   AD5_readData
 **
 **     Synopsis:
 **            AD5_readData(PmodAD5* InstancePtr);
 **
 **     Parameters:
 **             PmodAD5* InstancePtr - the PmodAD5 object to communicate with
 **
 **     Return Value:
 **             none
 **
 **     Errors:
 **             none
 **
 **     Description:
 **             Reads data in through SPI. It sends the first byte to the communication register which sets communication to read for
 **             the next 3 bytes.
 **             Data is stored into data1, data2 and data3.
 */
void AD5_readData(PmodAD5* InstancePtr) {
   u8 bytes[4];
   bytes[0]= 0x58; //first byte is sent to the communication register which sets communication to
   //reading the next 3 bytes from the Data register

   InstancePtr->data1 = 0;
   InstancePtr->data2 = 0;
   InstancePtr->data3 = 0;
   XSpi_Transfer(&InstancePtr->AD5Spi, bytes, bytes, 4);


     InstancePtr->data1 = bytes[1];
     InstancePtr->data2 = bytes[2];
     InstancePtr->data3 = bytes[3];

}
/* ------------------------------------------------------------ */
/***   AD5_WriteConfig
 **
 **     Synopsis:
 **            AD5_WriteConfig(PmodAD5* InstancePtr);
 **
 **     Parameters:
 **             PmodAD5* InstancePtr - the PmodAD5 object to communicate with
 **
 **     Return Value:
 **             none
 **
 **     Errors:
 **             none
 **
 **     Description:
 **             writes data to the configuration register through SPI. It sends the first byte to the communication
 **             register which sets communication to write for the next 3 bytes.
 **             gain is set to 1 and in differential mode
 */
void AD5_WriteConfig(PmodAD5* InstancePtr)
{
    u8 bytes[4];
    bytes[0] = 0x10; //first byte is sent to the communication register which sets communication to
     //writing the next 3 bytes to the Configuration register

    //gain is set to 1 and in differential mode
    bytes[1] = 0x00;
    bytes[2] = 0x01;
    bytes[3] = 0x10;


        XSpi_Transfer(&InstancePtr->AD5Spi, bytes, bytes, 4);

  }

/* ------------------------------------------------------------ */
/***   AD5_DataToVoltage
 **
 **     Synopsis:
 **            AD5_DataToVoltage(PmodAD5* InstancePtr);
 **
 **     Parameters:
 **             PmodAD5* InstancePtr - the PmodAD5 object to communicate with
 **
 **     Return Value:
 **             none
 **
 **     Errors:
 **             none
 **
 **     Description:
 **             Combines the 3 bytes into a unsigned long integer and then converts the digital data into a float voltage value
 */

float AD5_DataToVoltage(PmodAD5* InstancePtr)  {
  float voltage = 0;
//  char mGain = 0;
  float mVref = 2.5;
//  char mPolarity = 0;
  int PGAGain = 1;
  unsigned long rawdata=0;

  //combining the 3 byte data to one unsigned long integer
  rawdata = InstancePtr->data1;
  rawdata = rawdata * 256 +InstancePtr->data2;
  rawdata = rawdata * 256 + InstancePtr->data3;

 //converting from digital data to voltage
  voltage = (((float)rawdata / (float)8388608) - (float)1) * (mVref / (float)PGAGain);

  return(voltage);
}

