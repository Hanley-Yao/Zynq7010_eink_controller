/******************************************************************************/
/*                                                                            */
/* HYGROI2C.c -- Definition for HYGROI2C library                              */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file defines functions for HYGROI2C                                   */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    01/30/2017(ArtVVB):   Created                                           */
/*	  02/21/2017(ArtVVB):   Validated                                         */
/*    11/08/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    02/17/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodHYGRO.h"

/************************** Function Definitions ***************************/

XIic_Config HYGRO_Config =
{
   0,
   0,
   0,
   2
};

XTmrCtr_Config HYGRO_TimerConfig =
{
   0,
   0,
   0
};

static void StatusHandler(PmodHYGRO *InstancePtr);

/* ------------------------------------------------------------ */
/*** void HYGRO_begin(PmodHYGRO *InstancePtr, u32 IIC_Address, u8 Chip_Address,
**         u32 Timer_Address, UINTPTR Timer_DeviceId, u32 Timer_SysClockFreqHz)
**
**   Parameters:
**      InstancePtr: A PmodHYGRO object to start
**      IIC_Address: The Base address of the PmodHYGRO IIC
**      Chip_Address: 7 bit Pmod device address
**      Timer_Address: The Base address of the PmodHYGRO Timer
**      Timer_DeviceID: The Device ID of the PmodHYGRO
**      Timer_SysClockFreqHz: The clock frequency of the AXI bus
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Initialize the PmodHYGRO.
*/
void HYGRO_begin(PmodHYGRO *InstancePtr, u32 IIC_Address, u8 Chip_Address,
      u32 Timer_Address, UINTPTR Timer_DeviceId, u32 Timer_SysClockFreqHz) {
   u16 config = HYGRO_CONFIG_DEFAULT & ~(HYGRO_CONFIG_MODE);
   u8 bytes[2] = {(config >> 8) & 0xff, config & 0xff};

   HYGRO_Config.BaseAddress = IIC_Address;
   InstancePtr->chipAddr = Chip_Address;
   InstancePtr->clockFreqHz = Timer_SysClockFreqHz;

   HYGRO_TimerConfig.DeviceId = Timer_DeviceId;
   HYGRO_TimerConfig.BaseAddress = Timer_Address;
   HYGRO_TimerConfig.SysClockFreqHz = Timer_SysClockFreqHz;

   HYGRO_TimerInit(&InstancePtr->HYGROTimer, &HYGRO_TimerConfig);
   HYGRO_IICInit(&InstancePtr->HYGROIic);
   HYGRO_WriteIIC(InstancePtr, HYGRO_CONFIG, bytes, 2);

   HYGRO_DelayMillis(InstancePtr, 15);
}

/* ------------------------------------------------------------ */
/*** void HYGRO_TimerInit(XTmrCtr *TimerInstancePtr,
**         XTmrCtr_Config *TimerConfigPtr)
**
**   Parameters:
**      TimerInstancePtr: An AXI Timer object to initialize
**      TimerConfigPtr: A Timer configuration object containing information about the Timer to be initialized
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Initialize the PmodHYGRO's AXI Timer IP core.
*/
void HYGRO_TimerInit(XTmrCtr *TimerInstancePtr,
      XTmrCtr_Config *TimerConfigPtr) {
   XTmrCtr_CfgInitialize(TimerInstancePtr, TimerConfigPtr,
         TimerConfigPtr->BaseAddress);
   XTmrCtr_InitHw(TimerInstancePtr);
   XTmrCtr_Initialize(TimerInstancePtr, TimerConfigPtr->DeviceId);
   XTmrCtr_SetResetValue(TimerInstancePtr, 0, 0);
}

/* ------------------------------------------------------------ */
/*** void HYGRO_DelayMillis(PmodHYGRO *InstancePtr, u32 millis)
**
**   Parameters:
**      InstancePt - PmodHYGRO object containing AXI Timer for measuring delay
**      millis     - number of milliseconds to delay
**
**   Return Value:
**      None
**
**   Errors:
**      no error check on millis bounds, large delays (greater than approx 50
**      secs) might not work as expected
**
**   Description:
**      delays the program for millis milliseconds.
*/
void HYGRO_DelayMillis(PmodHYGRO *InstancePtr, u32 millis) {
	XTmrCtr* TimerInstancePtr = &InstancePtr->HYGROTimer;
	u32 done_after_ticks = millis * (InstancePtr->clockFreqHz / 1000);
	XTmrCtr_Reset(TimerInstancePtr, 0);
	XTmrCtr_Start(TimerInstancePtr, 0);
	while (XTmrCtr_GetValue(TimerInstancePtr, 0) < done_after_ticks);
	XTmrCtr_Stop(TimerInstancePtr, 0);
}

/* ------------------------------------------------------------ */
/*** int HYGRO_IICInit(XIic *IicInstancePtr)
**
**   Parameters:
**      IicInstancePtr: the IIC object to initialize
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Initializes the PmodHYGRO IIC.
*/

int HYGRO_IICInit(XIic *IicInstancePtr){
	int Status;

	Status = XIic_CfgInitialize(IicInstancePtr, &HYGRO_Config,
	      HYGRO_Config.BaseAddress);
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
/*** void HYGRO_ReadIIC(PmodHYGRO *InstancePtr, u8 reg, u8 *Data, int nData,
**         u32 conversion_delay_ms)
**
**   Parameters:
**      InstancePtr         - PmodHYGRO object to initialize
**      reg                 - Register to read from
**      Data                - Pointer to recieve buffer
**      nData               - Number of data values to read
**      conversion_delay_ms - Number of milliseconds to wait for the PmodHYGRO
**                            to finish converting data - if 0, no wait.
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Reads nData data bytes from register reg
*/
void HYGRO_ReadIIC(PmodHYGRO *InstancePtr, u8 reg, u8 *Data, int nData,
      u32 conversion_delay_ms) {
   int Status;
   Status = XIic_Start(&InstancePtr->HYGROIic);
   if (Status != XST_SUCCESS) {
      return;
   }
   if (InstancePtr->currentRegister != reg) {
      XIic_Send(InstancePtr->HYGROIic.BaseAddress, InstancePtr->chipAddr, &reg,
            1, XII_REPEATED_START_OPTION);
      InstancePtr->currentRegister = reg;
   }

   if (conversion_delay_ms > 0)
      HYGRO_DelayMillis(InstancePtr, conversion_delay_ms);

   XIic_Recv(InstancePtr->HYGROIic.BaseAddress, InstancePtr->chipAddr, Data,
         nData, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->HYGROIic);
   if (Status != XST_SUCCESS) {
      return;
   }
}

/* ------------------------------------------------------------ */
/*** void HYGRO_WriteIIC(PmodHYGRO *InstancePtr, u8 reg, u8 *Data, int nData)
**
**   Parameters:
**      InstancePtr - PmodHYGRO object to initialize
**      reg         - Register to send to
**      Data        - Pointer to data buffer to send
**      nData       - Number of data values to send
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Writes nData data bytes to register reg
*/
void HYGRO_WriteIIC(PmodHYGRO *InstancePtr, u8 reg, u8 *Data, int nData) {
   u8 out[10];
   u8 i;
   int Status;

   out[0] = reg;

   for (i = 0; i < nData && i + 1 < 10; i++) {
      out[i + 1] = Data[i];
   }

   if (InstancePtr->currentRegister != reg) {
      InstancePtr->currentRegister = reg;
   }

   Status = XIic_Start(&InstancePtr->HYGROIic);
   if (Status != XST_SUCCESS) {
      return;
   }

   XIic_Send(InstancePtr->HYGROIic.BaseAddress, InstancePtr->chipAddr, out,
         nData + 1, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->HYGROIic);
   if (Status != XST_SUCCESS) {
      return;
   }
}

static void StatusHandler(PmodHYGRO *InstancePtr) {
   xil_printf("status\r\n");
}

/* ------------------------------------------------------------ */
/*** float HYGRO_getTemperature(PmodHYGRO *InstancePtr)
**
**   Synopsis:
**      getTemperature(&myDevice);
**
**   Parameters:
**      PmodHYGRO *InstancePtr - a PmodHYGRO object to get data from
**
**   Return Values:
**      float deg_c - the temperature reading in degrees Celsius
**
**   Errors:
**      modify to manage read failures
**
**   Description:
**      This function captures a temperature reading from the PmodHYGRO.
*/
float HYGRO_getTemperature(PmodHYGRO *InstancePtr) {
   u8 bytes[2];
   float deg_c;

   // Conversion time for temperature at 14 bit resolution is 6.35 ms
   HYGRO_ReadIIC(InstancePtr, HYGRO_TEMP, bytes, 2, 7);
   deg_c = 256.0 * bytes[0] + 1.0 * bytes[1];
   deg_c /= 65536.0;
   deg_c *= 160.0;
   deg_c -= 40.0; // Conversion provided in reference manual
   return deg_c;
}

/* ------------------------------------------------------------ */
/*** float HYGRO_getHumidity(PmodHYGRO *InstancePtr)
**
**   Synopsis:
**      getHumidity(&myDevice);
**
**   Parameters:
**      PmodHYGRO *InstancePtr - a PmodHYGRO object to get data from
**
**   Return Values:
**      float per_rh - the humidity reading in percent relative humidity.
**
**   Errors:
**      modify to manage read failures
**
**   Description:
**      This function captures a humidity reading from the PmodHYGRO.
*/
float HYGRO_getHumidity(PmodHYGRO *InstancePtr) {
   u8 bytes[2];
   float per_rh;

   // Conversion time for humidity at 14 bit resolution is 6.35 ms
   HYGRO_ReadIIC(InstancePtr, HYGRO_HUM, bytes, 2, 7);
   per_rh = 256.0 * bytes[0] + 1.0 * bytes[1];
   per_rh /= 65536.0;
   per_rh *= 100.0; // Conversion provided in reference manual
   return per_rh;
}

/* ------------------------------------------------------------ */
/*** float HYGRO_tempF2C(float deg_f)
**
**   Synopsis:
**      HYGRO_tempF2C(deg_f);
**
**   Parameters:
**      float deg_f - the temperature in degrees Fahrenheit
**
**   Return Values:
**      float deg_c - the temperature in degrees Celsius
**
**   Errors:
**
**   Description:
**      This function converts a Fahrenheit temperature to Celsius
*/
float HYGRO_tempF2C(float deg_f) {
   return (deg_f - 32) / 1.8;
}

/* ------------------------------------------------------------ */
/*** float HYGRO_tempC2F(float deg_c)
**
**   Synopsis:
**      HYGRO_tempC2F(deg_c);
**
**   Parameters:
**      float deg_c - the temperature in degrees celsius
**
**   Return Values:
**      float deg_f - the temperature in degrees fahrenheit
**
**   Errors:
**
**   Description:
**      This function converts a Celsius temperature to fahrenheit
**
*/
float HYGRO_tempC2F(float deg_c) {
   return deg_c * 1.8 + 32;
}
