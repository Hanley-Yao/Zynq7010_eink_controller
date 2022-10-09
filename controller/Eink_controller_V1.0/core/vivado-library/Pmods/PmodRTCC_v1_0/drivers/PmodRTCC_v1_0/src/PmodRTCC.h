/******************************************************************************/
/*                                                                            */
/* PmodRTCC.h -- Declaration for PmodRTCC Driver                              */
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

#ifndef PMODRTCC_H
#define PMODRTCC_H

/* ------------------------------------------------------------ */
/*                  Include Files                               */
/* ------------------------------------------------------------ */

#include "xiic.h"
#include "xiic_l.h"
#include "xil_types.h"
#include "xstatus.h"

/* ------------------------------------------------------------ */
/*                  Definitions                                 */
/* ------------------------------------------------------------ */

typedef struct PmodRTCC {
   XIic RTCCIic;
   u8 chipAddr;
   u8 currentRegister;
} PmodRTCC;

typedef enum RTCC_Target {
   RTCC_TARGET_RTCC = 0, // Real-time clock
   RTCC_TARGET_ALM0,     // Alarm 0
   RTCC_TARGET_ALM1,     // Alarm 1
   RTCC_TARGET_PWRD,     // Power-down time-stamp
   RTCC_TARGET_PWRU      // Power-up time-stamp
} RTCC_Target;

typedef enum RTCC_AMPM {
   RTCC_AM = 0,
   RTCC_PM
} RTCC_AMPM;

/* ------------------------------------------------------------ */
/*                  Bit Mask Definitions                        */
/* ------------------------------------------------------------ */

// Alarm configuration bits
#define RTCC_ALM_POL 0x80
#define RTCC_ALMC2   0x40
#define RTCC_ALMC1   0x20
#define RTCC_ALMC0   0x10

/* ------------------------------------------------------------ */
/*                  Procedure Declarations                      */
/* ------------------------------------------------------------ */

void RTCC_begin(PmodRTCC *InstancePtr, u32 IIC_Address, u8 Chip_Address);
u32  RTCC_IICInit(XIic *IicInstancePtr);
void RTCC_ReadIIC(PmodRTCC *InstancePtr, u8 reg, u8 *Data, int nData);
void RTCC_WriteIIC(PmodRTCC *InstancePtr, u8 reg, u8 *Data, int nData);
void RTCC_clearPWRFAIL(PmodRTCC *InstancePtr);
void RTCC_startClock(PmodRTCC *InstancePtr);
void RTCC_stopClock(PmodRTCC *InstancePtr);

void RTCC_enableAlarm(PmodRTCC *InstancePtr, RTCC_Target dest, u8 config);
void RTCC_disableAlarm(PmodRTCC *InstancePtr, RTCC_Target dest);
void RTCC_alarmOff(PmodRTCC *InstancePtr, RTCC_Target dest);
u8   RTCC_checkFlag(PmodRTCC *InstancePtr, RTCC_Target src);

void RTCC_enableVbat(PmodRTCC *InstancePtr);
void RTCC_disableVbat(PmodRTCC *InstancePtr);
u8   RTCC_checkVbat(PmodRTCC *InstancePtr);

u8 RTCC_getSec(PmodRTCC *InstancePtr, RTCC_Target src);
u8 RTCC_getMin(PmodRTCC *InstancePtr, RTCC_Target src);
u8 RTCC_getHour(PmodRTCC *InstancePtr, RTCC_Target src);
u8 RTCC_getDay(PmodRTCC *InstancePtr, RTCC_Target src);
u8 RTCC_getDate(PmodRTCC *InstancePtr, RTCC_Target src);
u8 RTCC_getMonth(PmodRTCC *InstancePtr, RTCC_Target src);
u8 RTCC_getYear(PmodRTCC *InstancePtr);
RTCC_AMPM RTCC_getAmPm(PmodRTCC *InstancePtr, RTCC_Target src);

void RTCC_setSec(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value);
void RTCC_setMin(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value);
void RTCC_setHour12(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value,
      RTCC_AMPM ampm);
void RTCC_setHour24(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value);
void RTCC_setDay(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value);
void RTCC_setDate(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value);
void RTCC_setMonth(PmodRTCC *InstancePtr, RTCC_Target dest, u8 value);
void RTCC_setYear(PmodRTCC *InstancePtr, u8 value);

#endif // PMODRTCC_H
