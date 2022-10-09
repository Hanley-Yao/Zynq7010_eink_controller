/******************************************************************************/
/*                                                                            */
/* PmodTMP3.c -- PmodTMP3 Library                                             */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains code for running a demonstration of the PmodTMP3 when   */
/* used with the PmodTMP3 IP core.                                            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/09/2016(ABrown):   Created                                           */
/*    05/08/2017(jPeyron):  Updated                                           */
/*    11/10/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    01/13/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodTMP3.h"

/************************** Function Definitions ***************************/

XIic_Config TMP3_Config =
{
   0,
   0,
   0,
   2
};

/* ------------------------------------------------------------ */
/*** void TMP3_begin(PmodTMP3 *InstancePtr, u32 IIC_Address, u8 Chip_Address)
**
**   Parameters:
**      InstancePtr:  A PmodTMP3 object to start
**      IIC_Address:  The Base address of the PmodTMP3 IIC
**      Chip_Address: 7 bit Pmod device address
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Initialize the PmodTMP3.
*/
void TMP3_begin(PmodTMP3 *InstancePtr, u32 IIC_Address, u8 Chip_Address) {
   TMP3_Config.BaseAddress = IIC_Address;
   InstancePtr->chipAddr = Chip_Address;
   TMP3_IICInit(&InstancePtr->TMP3Iic);
   XIic_SetAddress(&InstancePtr->TMP3Iic, XII_ADDR_TO_SEND_TYPE,
         InstancePtr->chipAddr);
}

/* ------------------------------------------------------------ */
/*** void TMP3_end(PmodTMP3 *InstancePtr)
**
**   Parameters:
**      InstancePtr: PmodTMP3 object to stop
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Stops the device
*/
void TMP3_end(PmodTMP3 *InstancePtr) {
   XIic_Stop(&InstancePtr->TMP3Iic);
}

/* ------------------------------------------------------------ */
/*** int TMP3_IICInit(XIic *IicInstancePtr)
**
**   Parameters:
**      none
**
**   Return Value:
**      none
**
**   Errors:
**		none
**
**   Description:
**      Initializes the PmodTMP3 IIC.
*/

int TMP3_IICInit(XIic *IicInstancePtr) {
   int Status;

   Status = XIic_CfgInitialize(IicInstancePtr, &TMP3_Config,
         TMP3_Config.BaseAddress);
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
/*** void TMP3_ReadIIC(PmodTMP3 *InstancePtr, u8 reg, u8 *Data, int nData)
**
**   Parameters:
**      InstancePtr: PmodTMP3 object to initialize
**      reg:         Register to read from
**      Data:        Pointer to receive buffer
**      nData:       Number of data values to read
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Reads nData data bytes from register reg
*/
void TMP3_ReadIIC(PmodTMP3 *InstancePtr, u8 reg, u8 *Data, int nData) {
   int Status;
   Status = XIic_Start(&InstancePtr->TMP3Iic);
   if (Status != XST_SUCCESS) {
      return;
   }
   if (InstancePtr->currentRegister != reg) {

      XIic_Send(InstancePtr->TMP3Iic.BaseAddress, InstancePtr->chipAddr, &reg,
            1, XII_REPEATED_START_OPTION);
      InstancePtr->currentRegister = reg;
   }
   XIic_Recv(InstancePtr->TMP3Iic.BaseAddress, InstancePtr->chipAddr, Data,
         nData, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->TMP3Iic);
   if (Status != XST_SUCCESS) {
      return;
   }
}

/* ------------------------------------------------------------ */
/*** void TMP3_WriteIIC(PmodTMP3 *InstancePtr, u8 reg, u8 *Data, int nData)
**
**   Parameters:
**      InstancePtr: PmodTMP3 object to initialize
**      reg:         Register to send to
**      Data:        Pointer to data buffer to send
**      nData:       Number of data values to send
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Writes nData data bytes to register reg
*/
void TMP3_WriteIIC(PmodTMP3 *InstancePtr, u8 reg, u8 *Data, int nData) {
   u8 out[10];
   out[0] = reg;
   out[1] = *Data;
   int Status;

   if (InstancePtr->currentRegister != reg) {
      InstancePtr->currentRegister = reg;
   }
   Status = XIic_Start(&InstancePtr->TMP3Iic);
   if (Status != XST_SUCCESS) {
      return;
   }
   XIic_Send(InstancePtr->TMP3Iic.BaseAddress, InstancePtr->chipAddr, out,
         nData + 1, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->TMP3Iic);
   if (Status != XST_SUCCESS) {
      return;
   }
}

/* ------------------------------------------------------------ */
/*** void TMP3_config(PmodTMP3 *InstancePtr, u8 configuration)
**
**   Parameters:
**      InstancePtr:   A PmodTMP3 object to start
**      configuration: 8 bit TMP3 configuration code, refer to "Configuration
**                     settings" under Bit Masks in header for details
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Configures the PmodTMP3's Microchip TCN75A. Does not need to be called on startup.
*/
void TMP3_config(PmodTMP3 *InstancePtr, u8 configuration) {
   u8 buf[1];
   buf[0] = configuration;
   TMP3_WriteIIC(InstancePtr, TMP3_REG_CONFIG, buf, 1);
}

/* ------------------------------------------------------------ */
/*** double TMP3_getTemp(PmodTMP3 *InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodTMP3 object to start
**
**   Return Value:
**      tempResult: Current temperature seen by the TMP3 in degrees Celsius.
**
**   Errors:
**      none
**
**   Description:
**      Requests and returns the temperature off of the PmodTMP3
*/
double TMP3_getTemp(PmodTMP3 *InstancePtr) {
   double tempResult;
   u16 uResult = 0;
   int wResult = 0;
   u8 buf[2] = {0};

   // Read temperature register into buf
   TMP3_ReadIIC(InstancePtr, TMP3_REG_TEMP, buf, 2);

   uResult = buf[1] | (buf[0] << 8);
   if ((buf[0] & 0x80) == 0) {
      // Result is positive
      wResult = (int) uResult;
   } else {
      // Result negative -- two's complement
      wResult = -1 * (int) (~uResult + 1);
   }

   // 9 bit resolution has 0.5 *C resolution, stored in the uppermost 9 bits of
   // the buffer
   tempResult = (double) wResult / 256.0;

   return tempResult;
}

/* ------------------------------------------------------------ */
/*** double TMP3_FtoC(double tempF)
**
**   Parameters:
**      tempF: a temperature value in degrees Fahrenheit
**
**   Return Value:
**      tempC: a temperature value in degrees Celsius
**
**   Errors:
**      none
**
**   Description:
**      Converts temperature in Fahrenheit to Celsius
*/
double TMP3_FtoC(double tempF) {
   double tempC;

   tempC = (tempF - 32.0) / 1.8;

   return tempC;
}

/* ------------------------------------------------------------ */
/*** double TMP3_CtoF(double tempC)
**
**   Parameters:
**      tempC: a temperature value in degrees Celsius
**
**   Return Value:
**      tempF: a temperature value in degrees Fahrenheit
**
**   Errors:
**      none
**
**   Description:
**      Converts temperature in Celsius to Fahrenheit
*/
double TMP3_CtoF(double tempC) {
   double tempF;

   tempF = (tempC * 1.8) + 32.0;

   return tempF;
}
