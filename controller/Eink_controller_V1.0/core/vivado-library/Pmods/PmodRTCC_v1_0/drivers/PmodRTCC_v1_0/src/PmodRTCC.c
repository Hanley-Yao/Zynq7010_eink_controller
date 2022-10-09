/******************************************************************************/
/*                                                                            */
/* PmodRTCC.c -- PmodRTCC Driver Source                                       */
/*                                                                            */
/******************************************************************************/
/* Author: Lynn England                                                       */
/* Copyright 2016-17, Digilent Inc.                                           */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains definitions for the Pmod Real Time Clock & Calendar     */
/* driver.                                                                    */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    12/08/2016(lengland): Created                                           */
/*    08/07/2017(artvvb):   Validated for Vivado 2015.4                       */
/*    02/10/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodRTCC.h"

/************************** Function Definitions ***************************/

XIic_Config RTCC_Config =
{
   0,
   0,
   0,
   2
};

/* ------------------------------------------------------------ */
/*** void RTCC_begin(PmodRTCC *InstancePtr, u32 IIC_Address)
**
**   Parameters:
**      InstancePtr:  A PmodRTCC device to start
**      IIC_Address:  The Base address of the PmodRTCC IIC
**      Chip_Address: 7 bit Pmod device address
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Initialize the PmodRTCC.
*/
void RTCC_begin(PmodRTCC *InstancePtr, u32 IIC_Address, u8 Chip_Address) {
   RTCC_Config.BaseAddress = IIC_Address;
   InstancePtr->chipAddr = Chip_Address;

   RTCC_IICInit(&InstancePtr->RTCCIic);

   XIic_SetAddress(&InstancePtr->RTCCIic, XII_ADDR_TO_SEND_TYPE,
         InstancePtr->chipAddr);
}

/* ------------------------------------------------------------ */
/*** RTCC_IICInit
**
**   Parameters:
**      none
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Initializes the PmodRTCC IIC.
**
*/
u32 RTCC_IICInit(XIic *IicInstancePtr) {
   XStatus Status;

   Status = XIic_CfgInitialize(IicInstancePtr, &RTCC_Config,
         RTCC_Config.BaseAddress);
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
/*** void RTCC_ReadIIC(PmodRTCC *InstancePtr, u8 reg, u8 *Data, int nData)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to initialize
**      reg         - Register to read from
**      Data        - Pointer to recieve buffer
**      nData       - Number of data values to read
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Reads nData data bytes from register reg
**
*/
void RTCC_ReadIIC(PmodRTCC *InstancePtr, u8 reg, u8 *Data, int nData) {
   XStatus Status;
   Status = XIic_Start(&InstancePtr->RTCCIic);
   if (Status != XST_SUCCESS) {
      return;
   }

   XIic_Send(InstancePtr->RTCCIic.BaseAddress, InstancePtr->chipAddr, &reg, 1,
         XII_REPEATED_START_OPTION);
   InstancePtr->currentRegister = reg;

   Status = XIic_Recv(InstancePtr->RTCCIic.BaseAddress, InstancePtr->chipAddr,
         Data, nData, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->RTCCIic);
   if (Status != XST_SUCCESS) {
      return;
   }
}

/* ------------------------------------------------------------ */
/*** void RTCC_WriteIIC(PmodRTCC *InstancePtr, u8 reg, u8 *Data, int nData)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to initialize
**      reg         - Register to send to
**      Data        - Pointer to data buffer to send
**      nData       - Number of data values to send
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Writes nData data bytes to chosen register
*/
void RTCC_WriteIIC(PmodRTCC *InstancePtr, u8 reg, u8 *Data, int nData) {
   u8 out[10];
   out[0] = reg;
   out[1] = *Data;
   XStatus Status;

   if (InstancePtr->currentRegister != reg) {
      InstancePtr->currentRegister = reg;
   }

   Status = XIic_Start(&InstancePtr->RTCCIic);
   if (Status != XST_SUCCESS) {
      return;
   }

   XIic_Send(InstancePtr->RTCCIic.BaseAddress, InstancePtr->chipAddr, out,
         nData + 1, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->RTCCIic);
   if (Status != XST_SUCCESS) {
      return;
   }
}

// This function starts the RTCC_TARGET_RTCC
void RTCC_startClock(PmodRTCC *InstancePtr) {
   u8 data = 0;
   RTCC_ReadIIC(InstancePtr, 0, &data, 1);

   data = (data | 0x80);

   RTCC_WriteIIC(InstancePtr, 0, &data, 1);
}

// This function stops the RTCC_TARGET_RTCC
void RTCC_stopClock(PmodRTCC *InstancePtr) {
   u8 data = 0;
   RTCC_ReadIIC(InstancePtr, 0, &data, 1);

   data = (data & 0x7F);
   RTCC_WriteIIC(InstancePtr, 0, &data, 1);
}

/*** void RTCC_enableAlarm(PmodRTCC *InstancePtr, RTCC_Target dest, u8 config)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_ALM0 for alarm 0
**                    RTCC_TARGET_ALM1 for alarm 1
**      config      - alarm configuration:
**                    RTCC_ALM_POL - MPF outputs high when alarm is triggered
**                    NONE                       - seconds match
**                    RTCC_ALMC0                 - minutes match
**                    RTCC_ALMC1                 - hours match
**                    RTCC_ALMC1 | ALMC0         - matches on day at midnight
**                    RTCC_ALMC2                 - date match
**                    RTCC_ALMC2 | ALMC1 | ALMC0 - seconds, minutes, hour, day,
**                                                 date, and month match
**   Return Value:
**      None
**
**   Description:
**      This function enables and configures the dest alarm.
*/
void RTCC_enableAlarm(PmodRTCC *InstancePtr, RTCC_Target dest, u8 config) {
   u8 data = 0;
   u8 rgbAlmCfg[2];

   RTCC_ReadIIC(InstancePtr, 7, &data, 1);

   // Set enable bit and alarm config register address depending on the
   // destination
   switch (dest) {
   case RTCC_TARGET_ALM0:
      // Set ALM0 enable bit
      data = (data | 0x10);
      // Alarm config register address
      rgbAlmCfg[0] = 0x0D;
      break;
   case RTCC_TARGET_ALM1:
      // Set ALM1 enable bit
      data = (data | 0x20);
      // Alarm config register address
      rgbAlmCfg[0] = 0x14;
      break;
   default:
      return;
   }

   RTCC_WriteIIC(InstancePtr, 7, &data, 1);
   RTCC_ReadIIC(InstancePtr, rgbAlmCfg[0], &data, 1);

   rgbAlmCfg[1] = ((data & 0x07) | (config & 0xF0));

   RTCC_WriteIIC(InstancePtr, rgbAlmCfg[0], &rgbAlmCfg[1], 1);
}

/*** void RTCC_disableAlarm(PmodRTCC *InstancePtr, RTCC_Target dest)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_ALM0 for alarm 0
**                    RTCC_TARGET_ALM1 for alarm 1
**
**   Return Value:
**      None
**
**
**   Description:
**      This function disables the dest alarm and clears the alarm interrupt
**      flag for that alarm.
*/
void RTCC_disableAlarm(PmodRTCC *InstancePtr, RTCC_Target dest) {
   u8 data;

   // Clear the alarm interrupt flag
   RTCC_alarmOff(InstancePtr, dest);

   RTCC_ReadIIC(InstancePtr, 7, &data, 1);

   // Clear enable bit depending on the destination
   switch (dest) {
   case RTCC_TARGET_ALM0:
      data = (data & 0xEF);
      break;
   case RTCC_TARGET_ALM1:
      data = (data & 0xDF);
      break;
   default:
      return;
   }

   // Configure alarm
   RTCC_WriteIIC(InstancePtr, 7, &data, 1);
}

/*** void RTCC_alarmOff(PmodRTCC *InstancePtr, RTCC_Target dest)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_ALM0 for alarm 0
**                    RTCC_TARGET_ALM1 for alarm 1
**
**   Return Value:
**      None
**
**   Description:
**      This function clears the alarm interrupt flag for the chosen alarm.
*/
void RTCC_alarmOff(PmodRTCC *InstancePtr, RTCC_Target dest) {
   u8 rgbFlag[2];
   u8 data;

   // Set alarm flag address depending on the destination
   switch (dest) {
   case RTCC_TARGET_ALM0:
      rgbFlag[0] = 0x0D;
      break;
   case RTCC_TARGET_ALM1:
      rgbFlag[0] = 0x14;
      break;
   default:
      return;
   }

   RTCC_ReadIIC(InstancePtr, rgbFlag[0], &data, 1);

   // Clear interrupt flag
   rgbFlag[1] = data & 0xF7;

   RTCC_WriteIIC(InstancePtr, rgbFlag[0], &rgbFlag[1], 1);
}

/*** u8 RTCC_checkFlag(PmodRTCC *InstancePtr, RTCC_Target src)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      src         - RTCC_TARGET_ALM0 for alarm 0
**                    RTCC_TARGET_ALM1 for alarm 1
**
**   Return Value:
**      unsigned int - 1 - alarm triggered
**                     0 - alarm not triggered
**
**   Description:
**      This function checks if the chosen alarm has been triggered.
*/
u8 RTCC_checkFlag(PmodRTCC *InstancePtr, RTCC_Target src) {
   u8 rgbFlag[2];
   u8 data;

   // Set alarm flag address depending on the destination
   switch (src) {
   case RTCC_TARGET_ALM0:
      rgbFlag[0] = 0x0D;
      break;
   case RTCC_TARGET_ALM1:
      rgbFlag[0] = 0x14;
      break;
   default:
      return 0;
   }
   RTCC_ReadIIC(InstancePtr, rgbFlag[0], &data, 1);

   // Check the for the Alarm Interrupt Flag
   if ((data & 0x08) == 0x08) {
      // Alarm triggered
      return 1;
   } else {
      // Alarm not triggered
      return 0;
   }
}

// This function enables battery backup
void RTCC_enableVbat(PmodRTCC *InstancePtr) {
   u8 data;

   RTCC_ReadIIC(InstancePtr, 3, &data, 1);
   data = (data | 0x08);
   RTCC_WriteIIC(InstancePtr, 3, &data, 1);
}

// This function clears the power failure status bit
void RTCC_clearPWRFAIL(PmodRTCC *InstancePtr) {
   u8 data;

   RTCC_ReadIIC(InstancePtr, 3, &data, 1);
   data = (data & 0xEF);
   RTCC_WriteIIC(InstancePtr, 3, &data, 1);
}

// This function disables backup battery mode
void RTCC_disableVbat(PmodRTCC *InstancePtr) {
   u8 data;

   RTCC_ReadIIC(InstancePtr, 3, &data, 1);
   data = (data & 0x37);
   RTCC_WriteIIC(InstancePtr, 3, &data, 1);
}

/*** u8 RTCC_getSec(PmodRTCC *InstancePtr, RTCC_Target src)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      src         - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**         ** RTCC_TARGET_PWRU and RTCC_TARGET_PWRD does not have the second
**            parameter
**   Return Value:
**      uint8_t - second in hexadecimal
**
**   Description:
**      This function returns the second of the source
*/
u8 RTCC_getSec(PmodRTCC *InstancePtr, RTCC_Target src) {
   u8 bSecBuffer = 0;
   u8 bSec;

   // Set address of the second register depending on the source
   switch (src) {
   case RTCC_TARGET_RTCC:
      bSec = 0x00;
      break;
   case RTCC_TARGET_ALM0:
      bSec = 0x0A;
      break;
   case RTCC_TARGET_ALM1:
      bSec = 0x11;
      break;
   default:
      return 0xFF; // ERROR Invalid Source
   }

   RTCC_ReadIIC(InstancePtr, bSec, &bSecBuffer, 1);
   // Return valid bits
   return (bSecBuffer & 0x7F);
}

/*** u8 RTCC_getMin(PmodRTCC *InstancePtr, RTCC_Target src)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      src         - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**                    RTCC_TARGET_PWRD - Power-down time-stamp
**                    RTCC_TARGET_PWRU - Power-up time-stamp
**
**   Return Value:
**      uint8_t - minute in hexadecimal
**
**   Description:
**      This function returns the minute of the source
*/
u8 RTCC_getMin(PmodRTCC *InstancePtr, RTCC_Target src) {
   u8 bMinBuffer = 0;
   u8 bMin;

   // Set address of the minute register depending on the source
   switch (src) {
   case RTCC_TARGET_RTCC:
      bMin = 0x01;
      break;
   case RTCC_TARGET_ALM0:
      bMin = 0x0B;
      break;
   case RTCC_TARGET_ALM1:
      bMin = 0x12;
      break;
   case RTCC_TARGET_PWRD:
      bMin = 0x18;
      break;
   case RTCC_TARGET_PWRU:
      bMin = 0x1C;
      break;
   default:
      return 0xFF; // ERROR Invalid Source
   }

   RTCC_ReadIIC(InstancePtr, bMin, &bMinBuffer, 1);
   // Return valid bits
   return (bMinBuffer & 0x7F);
}

/*** u8 RTCC_getHour(PmodRTCC *InstancePtr, RTCC_Target src)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      src         - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**                    RTCC_TARGET_PWRD - Power-down time-stamp
**                    RTCC_TARGET_PWRU - Power-up time-stamp
**
**   Return Value:
**      uint8_t - hour in hexadecimal
**
**   Description:
**      This function returns the hour of the source
*/
u8 RTCC_getHour(PmodRTCC *InstancePtr, RTCC_Target src) {
   u8 bHourBuffer = 0;
   u8 bHour;

   // Set address of the hour register depending on the source
   switch (src) {
   case RTCC_TARGET_RTCC:
      bHour = 0x02;
      break;
   case RTCC_TARGET_ALM0:
      bHour = 0x0C;
      break;
   case RTCC_TARGET_ALM1:
      bHour = 0x13;
      break;
   case RTCC_TARGET_PWRD:
      bHour = 0x19;
      break;
   case RTCC_TARGET_PWRU:
      bHour = 0x1D;
      break;
   default:
      return 0xFF; // ERROR Invalid Source
   }

   RTCC_ReadIIC(InstancePtr, bHour, &bHourBuffer, 1);

   // Return valid bits
   // Hour is in 12 hour format
   if ((bHourBuffer & 0x40) == 0x40) {
      return (bHourBuffer & 0x1F);
   // Hour is in 24 hour format
   } else {
      return (bHourBuffer & 0x3F);
   }
}

/*** u8 RTCC_getAmPm(PmodRTCC *InstancePtr, RTCC_Target src)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      src         - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**                    RTCC_TARGET_PWRD - Power-down time-stamp
**                    RTCC_TARGET_PWRU - Power-up time-stamp
**
**   Return Value:
**      uint8_t - 0 - RTCC_AM
**                1 - RTCC_PM
**
**   Description:
**      This function returns AM/PM for the source. This function should
**      only be used when the hour is in 12 hour format.
*/
RTCC_AMPM RTCC_getAmPm(PmodRTCC *InstancePtr, RTCC_Target src) {
   u8 bHourBuffer = 0;
   u8 bHour;

   // Set address of the hour register depending on the source
   switch (src) {
   case RTCC_TARGET_RTCC:
      bHour = 0x02;
      break;
   case RTCC_TARGET_ALM0:
      bHour = 0x0C;
      break;
   case RTCC_TARGET_ALM1:
      bHour = 0x13;
      break;
   case RTCC_TARGET_PWRD:
      bHour = 0x19;
      break;
   case RTCC_TARGET_PWRU:
      bHour = 0x1D;
      break;
   default:
      return 0xFF; // ERROR Invalid Source
   }

   RTCC_ReadIIC(InstancePtr, bHour, &bHourBuffer, 1);

   if ((bHourBuffer & 0x20) == 0) {
      return RTCC_AM;
   } else {
      return RTCC_PM;
   }
}

/*** u8 RTCC_getDay(PmodRTCC *InstancePtr, RTCC_Target src)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      src         - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**                    RTCC_TARGET_PWRD - Power-down time-stamp
**                    RTCC_TARGET_PWRU - Power-up time-stamp
**
**   Return Value:
**      uint8_t - day in hexadecimal
**
**   Description:
**      This function returns the day of the source
*/
u8 RTCC_getDay(PmodRTCC *InstancePtr, RTCC_Target src) {
   u8 bDayBuffer = 0;
   u8 bDay;

   // Set address of the day register depending on the source
   switch (src) {
   case RTCC_TARGET_RTCC:
      bDay = 0x03;
      break;
   case RTCC_TARGET_ALM0:
      bDay = 0x0D;
      break;
   case RTCC_TARGET_ALM1:
      bDay = 0x14;
      break;
   case RTCC_TARGET_PWRD:
      bDay = 0x1B;
      break;
   case RTCC_TARGET_PWRU:
      bDay = 0x1F;
      break;
   default:
      return 0xFF; // ERROR Invalid Source
   }

   RTCC_ReadIIC(InstancePtr, bDay, &bDayBuffer, 1);

   // Return valid bits
   if (src == RTCC_TARGET_PWRD || src == RTCC_TARGET_PWRU) {
      return ((bDayBuffer & 0xE0) >> 5);
   } else {
      return (bDayBuffer & 0x07);
   }
}

/*** u8 RTCC_getDate(PmodRTCC *InstancePtr, RTCC_Target src)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      src         - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**                    RTCC_TARGET_PWRD - Power-down time-stamp
**                    RTCC_TARGET_PWRU - Power-up time-stamp
**
**   Return Value:
**      uint8_t - date in hexadecimal
**
**   Description:
**      This function returns the date of the source
*/
u8 RTCC_getDate(PmodRTCC *InstancePtr, RTCC_Target src) {
   u8 bDateBuffer = 0;
   u8 bDate;

   // Set address of the date register depending on the source
   switch (src) {
   case RTCC_TARGET_RTCC:
      bDate = 0x04;
      break;
   case RTCC_TARGET_ALM0:
      bDate = 0x0E;
      break;
   case RTCC_TARGET_ALM1:
      bDate = 0x15;
      break;
   case RTCC_TARGET_PWRD:
      bDate = 0x1A;
      break;
   case RTCC_TARGET_PWRU:
      bDate = 0x1E;
      break;
   default:
      return 0xFF; // ERROR Invalid Source
   }

   RTCC_ReadIIC(InstancePtr, bDate, &bDateBuffer, 1);
   return (bDateBuffer & 0x3F);
}

/*** u8 RTCC_getMonth(PmodRTCC *InstancePtr, RTCC_Target src)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      src         - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**                    RTCC_TARGET_PWRD - Power-down time-stamp
**                    RTCC_TARGET_PWRU - Power-up time-stamp
**
**   Return Value:
**      uint8_t - month in hexadecimal
**
**   Description:
**      This function returns the month of the source
*/
u8 RTCC_getMonth(PmodRTCC *InstancePtr, RTCC_Target src) {
   u8 bMonthBuffer = 0;
   u8 bMonth;

   // Set address of the month register depending on the source
   switch (src) {
   case RTCC_TARGET_RTCC:
      bMonth = 0x05;
      break;
   case RTCC_TARGET_ALM0:
      bMonth = 0x0F;
      break;
   case RTCC_TARGET_ALM1:
      bMonth = 0x16;
      break;
   case RTCC_TARGET_PWRD:
      bMonth = 0x1B;
      break;
   case RTCC_TARGET_PWRU:
      bMonth = 0x1F;
      break;
   default:
      return 0xFF; // ERROR Invalid Source
   }

   RTCC_ReadIIC(InstancePtr, bMonth, &bMonthBuffer, 1);
   return (bMonthBuffer & 0x1F);
}

/*** u8 RTCC_getYear(PmodRTCC *InstancePtr)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**
**   Return Value:
**      uint8_t - year in hexadecimal
**
**   Description:
**      This function returns the year of the RTCC_TARGET_RTCC.
**
**   Notes:
**      The year register is only available for the RTCC_TARGET_RTCC.
*/
u8 RTCC_getYear(PmodRTCC *InstancePtr) {
   u8 bYearBuffer = 0;
   RTCC_ReadIIC(InstancePtr, 6, &bYearBuffer, 1);
   return (bYearBuffer & 0xFF);
}

/*** void RTCC_setSec(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**      value       - desired value for the second in HEX 0x00-0x59
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the second register of the target with the value.
*/
void RTCC_setSec(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value) {
   u8 rgbSec[2];
   rgbSec[1] = value;
   u8 data;

   // Set address of the second register depending on the destination
   switch (dest) {
   case RTCC_TARGET_RTCC:
      rgbSec[0] = 0x00;
      RTCC_ReadIIC(InstancePtr, rgbSec[0], &data, 1);
      if ((data & 0x80) == 0x80) {
         // Preserve configuration bits
         rgbSec[1] = (rgbSec[1] | 0x80);
      }
      break;
   case RTCC_TARGET_ALM0:
      rgbSec[0] = 0x0A;
      break;
   case RTCC_TARGET_ALM1:
      rgbSec[0] = 0x11;
      break;
   default: // Should not enter
      return;
   }

   RTCC_WriteIIC(InstancePtr, rgbSec[0], &rgbSec[1], 1);
}

/*** void RTCC_setMin(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**      value       - desired value for the minute in HEX 0x00-0x59
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the minute of the dest with the value.
*/
void RTCC_setMin(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value) {
   u8 rgbMin[2];

   rgbMin[1] = value;

   // Validate minute 0x00-0x59
   if (value > 0x59) {
      return;
   }

   // Set address of the minute register depending on the destination
   switch (dest) {
   case RTCC_TARGET_RTCC:
      rgbMin[0] = 0x01;
      break;
   case RTCC_TARGET_ALM0:
      rgbMin[0] = 0x0B;
      break;
   case RTCC_TARGET_ALM1:
      rgbMin[0] = 0x12;
      break;
   default: // Should not enter
      return;
   }

   RTCC_WriteIIC(InstancePtr, rgbMin[0], &rgbMin[1], 1);
}

/*** void RTCC_setHour12(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value,
**         u8 ampm)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**      value       - desired value for the hour in 12 hour format.
**                    The value should be represented in HEX and should be
**                    between 0x01-0x12
**      ampm        -  RTCC_AM
**                     RTCC_PM
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the hour of the dest with the value in 12 hour format
*/
void RTCC_setHour12(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value,
      RTCC_AMPM ampm) {
   u8 rgbHour[2];
   u8 data;

   // validate hour 0x01-0x12
   if (value > 0x12 || value < 0x01) {
      return;
   }

   // Set address of the hour register depending on the destination
   switch (dest) {
   case RTCC_TARGET_RTCC:
      rgbHour[0] = 0x02;
      break;
   case RTCC_TARGET_ALM0:
      rgbHour[0] = 0x0C;
      break;
   case RTCC_TARGET_ALM1:
      rgbHour[0] = 0x13;
      break;
   default: // Should not enter
      return;
   }

   // Set the format bit (0x40) to 12 hr format
   // Set ampm bit if PM
   if (ampm == RTCC_PM) {
      rgbHour[1] = value | 0x60;
   } else {
      rgbHour[1] = value | 0x40;
   }

   RTCC_WriteIIC(InstancePtr, rgbHour[0], &rgbHour[1], 1);

   RTCC_ReadIIC(InstancePtr, 2, &data, 1);
}

/*** void RTCC_setHour24(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**      value       - desired value for the hour in 24 hour format.
**                    The value should be represented in HEX and should be
**                    between 0x00-0x23
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the hour of the destination with the value in 24 hour
**      format
*/
void RTCC_setHour24(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value) {
   u8 rgbHour[2];

   // Validate hour 0x00-0x23
   if (value > 0x23)
      return;

   // Set address of the hour register depending on the destination
   switch (dest) {
   case RTCC_TARGET_RTCC:
      rgbHour[0] = 0x02;
      break;
   case RTCC_TARGET_ALM0:
      rgbHour[0] = 0x0C;
      break;
   case RTCC_TARGET_ALM1:
      rgbHour[0] = 0x13;
      break;
   default: // Should not enter
      return;
   }

   rgbHour[1] = value;

   RTCC_WriteIIC(InstancePtr, rgbHour[0], &rgbHour[1], 1);
}

/*** void RTCC_setDay(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**      value       - desired value for the day in HEX 0x01-0x07
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the day of the dest with the value.
*/
void RTCC_setDay(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value) {
   u8 rgbDay[2];
   u8 data;

   // Validate day 0x01-0x07
   if (value > 0x07 || value < 0x01)
      return;

   // Set address of the day register depending on the destination
   switch (dest) {
   case RTCC_TARGET_RTCC:
      rgbDay[0] = 0x03;
      break;
   case RTCC_TARGET_ALM0:
      rgbDay[0] = 0x0D;
      break;
   case RTCC_TARGET_ALM1:
      rgbDay[0] = 0x14;
      break;
   default: // Should not enter
      return;
   }

   RTCC_ReadIIC(InstancePtr, rgbDay[0], &data, 1);

   // Reserve the control bits
   rgbDay[1] = ((value & 0x07) | (data & 0xF8));

   RTCC_WriteIIC(InstancePtr, rgbDay[0], &rgbDay[1], 1);
}

/*** void RTCC_setDate(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**      value       - desired value for the date in HEX 0x01-0x31
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the date of the dest with the value.
*/
void RTCC_setDate(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value) {
   u8 rgbDate[2];
   rgbDate[1] = value;

   // Validate date 0x01-0x31
   if (value > 0x31 || value < 0x01)
      return;

   // Set address of the date register depending on the destination
   switch (dest) {
   case RTCC_TARGET_RTCC:
      rgbDate[0] = 0x04;
      break;
   case RTCC_TARGET_ALM0:
      rgbDate[0] = 0x0E;
      break;
   case RTCC_TARGET_ALM1:
      rgbDate[0] = 0x15;
      break;
   default: // Should not enter
      return;
   }
   RTCC_WriteIIC(InstancePtr, rgbDate[0], &rgbDate[1], 1);
}

/*** void RTCC_setMonth(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      dest        - RTCC_TARGET_RTCC - real-time clock
**                    RTCC_TARGET_ALM0 - Alarm 0
**                    RTCC_TARGET_ALM1 - Alarm 1
**      value       - desired value for the month in HEX 0x01-0x12
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the month of the dest with the value.
*/
void RTCC_setMonth(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value) {
   u8 rgbMonth[2];
   rgbMonth[1] = value;

   // Validate month 0x01-0x12
   if (value > 0x12 || value < 0x01) {
      return;
   }

   // Set address of the month register depending on the destination
   switch (dest) {
   case RTCC_TARGET_RTCC:
      rgbMonth[0] = 0x05;
      break;
   case RTCC_TARGET_ALM0:
      rgbMonth[0] = 0x0F;
      break;
   case RTCC_TARGET_ALM1:
      rgbMonth[0] = 0x16;
      break;
   default: // Should not enter
      return;
   }
   RTCC_WriteIIC(InstancePtr, rgbMonth[0], &rgbMonth[1], 1);
}

/*** void RTCC_setYear(PmodRTCC *InstancePtr, u8 value)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**      value       - desired value for the year in HEX 0x00-0x99
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the year of the RTCC_TARGET_RTCC with the value.
**      The year parameter is only available for the RTCC_TARGET_RTCC.
*/
void RTCC_setYear(PmodRTCC *InstancePtr, u8 value) {
   u8 rgbYear[2];
   rgbYear[1] = value;
   rgbYear[0] = 0x06;

   // Validate year 0x00-0x99
   if (value > 0x99)
      return;

   RTCC_WriteIIC(InstancePtr, rgbYear[0], &rgbYear[1], 1);
}

/*** u8 RTCC_checkVbat(PmodRTCC *InstancePtr)
**
**   Parameters:
**      InstancePtr - PmodRTCC device to use
**
**   Return Value:
**      data - 0 or 1, the state of VBATEN
**
**   Description:
**      This function returns the state of the VBATEN control bit, which
**      determines where the RTCC draws it's power from.
*/
u8 RTCC_checkVbat(PmodRTCC *InstancePtr) {
   u8 data;

   RTCC_ReadIIC(InstancePtr, 3, &data, 1);
   data = (data & 0x08) >> 3;
   return data;
}
