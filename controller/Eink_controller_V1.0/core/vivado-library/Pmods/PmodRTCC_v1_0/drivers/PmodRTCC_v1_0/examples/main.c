/******************************************************************************/
/*                                                                            */
/* main.c -- PmodRTCC Example Project                                         */
/*                                                                            */
/******************************************************************************/
/* Author: Lynn England                                                       */
/* Copyright 2016-17, Digilent Inc.                                           */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains an example usage of the Pmod Real Time Clock & Calendar */
/*                                                                            */
/* The RTCC date and time are set to specified values. The two alarms are set */
/* to trigger 30 seconds and one minute after the  RTCC is initialized. After */
/* initialization, the date and time are printed out over UART once per       */
/* second.                                                                    */
/*                                                                            */
/* Messages from the demo can be received over a micro-USB cable connected to */
/* your PC by properly configuring a serial terminal application to connect   */
/* to the board's UART port with no parity bit, 8 bit data, and a Baud rate   */
/* depending on your board and design. If you are using a Zynq device, the    */
/* Baud rate will be 115200. If you are using a MicroBlaze system, the Baud   */
/* rate will depend on the configuration of the AXI UARTLite IP, typically    */
/* 9600 or 115200 baud.                                                       */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    12/08/2016(lengland): Created                                           */
/*    08/07/2017(artvvb):   Validated for Vivado 2015.4                       */
/*    11/02/2017(artvvb):   2016.4 Maintenance                                */
/*    02/10/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodRTCC.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xparameters.h"

/*************************** Type Declarations *****************************/

// Struct containing each field of the RTCC's time registers represented in
// 8-bit binary coded decimal - 0x30 in the minute field represents 30 minutes.
typedef struct RTCC_Time {
   u8 second;
   u8 minute;
   u8 hour;
   u8 ampm;
   u8 day;
   u8 date;
   u8 month;
   u8 year;
} RTCC_Time;

/************************** Global Declarations ****************************/

// Which weekday starts this array is arbitrary, as long as it stays the same
// when you set and read the day
const char *weekdays[7] = {
   "Monday",
   "Tuesday",
   "Wednesday",
   "Thursday",
   "Friday",
   "Saturday",
   "Sunday"
};

// If RTCC is already set, change 1 to 0
#define SET_RTCC 1

PmodRTCC myDevice;

/************************** Function Declarations ***************************/

// Core demo functions
void DemoRun();
void DemoInitialize(u8 mode);
void DemoCleanup();
void EnableCaches();
void DisableCaches();

// Additional demo functions to manage the driver
RTCC_Time GetTime(PmodRTCC *InstancePtr, RTCC_Target src);
RTCC_Time IncrementTime(RTCC_Time time, int delta_seconds);
void SetTime(PmodRTCC *InstancePtr, RTCC_Target dest, RTCC_Time val);
void PrintTime(RTCC_Target src);
u8 bcd2int(u8 data);
u8 int2bcd(u8 data);

/************************** Function Definitions ****************************/

int main() {
   DemoInitialize(SET_RTCC);
   DemoRun();
   DemoCleanup();
   return 0;
}


/** void DemoInitialize()
**
**  Description:
**     This function initializes the demo, initializes the RTCC clock if power
**     has failed or if told to, sets up the two alarms on the device to trigger
**     30 seconds and 60 seconds from the current time, and prints the status of
**     each of the RTCC's time fields.
*/
void DemoInitialize(u8 mode) {
   RTCC_Time time;

   EnableCaches();

   RTCC_begin(&myDevice, XPAR_PMODRTCC_0_AXI_LITE_IIC_BASEADDR, 0x6F);

   // Print the power-fail time-stamp
   xil_printf("Lost Power at: ");
   PrintTime(RTCC_TARGET_PWRD);
   xil_printf("\r\n");

   xil_printf("Power was back at: ");
   PrintTime(RTCC_TARGET_PWRU);
   xil_printf("\r\n");

   if (!RTCC_checkVbat(&myDevice) || mode) {
      // Set the real time clock to Tuesday 2/6/18 12:24:36 PM
      RTCC_stopClock(&myDevice);

      time.second = 0x36;
      time.minute = 0x24;
      time.hour   = 0x12;
      time.ampm   = RTCC_PM;
      time.day    = 0x01;
      time.date   = 0x06;
      time.month  = 0x02;
      time.year   = 0x18;

      time = IncrementTime(time, 0); // TEST
      SetTime(&myDevice, RTCC_TARGET_RTCC, time);

      RTCC_startClock(&myDevice);
      xil_printf("The time has been set \r\n");
      // Set vbat high
      RTCC_enableVbat(&myDevice);
   } else {
      time = GetTime(&myDevice, RTCC_TARGET_RTCC);
   }

   // Sset alarm 0 for 30 seconds from now
   time = IncrementTime(time, 30);
   SetTime(&myDevice, RTCC_TARGET_ALM0, time);

   // Sset alarm 1 for 1 minute from now
   time = IncrementTime(time, 30);
   SetTime(&myDevice, RTCC_TARGET_ALM1, time);

   // Pprint current time
   xil_printf("Current time is: ");
   PrintTime(RTCC_TARGET_RTCC);
   xil_printf("\r\n");

   // Print alarm 0
   xil_printf("Alarm 0 is set to : ");
   PrintTime(RTCC_TARGET_ALM0);
   xil_printf("\r\n");

   // Print alarm 1
   xil_printf("Alarm 1 is set to : ");
   PrintTime(RTCC_TARGET_ALM1);
   xil_printf("\r\n");

   // Enables alarm 0
   // Set configuration bits to:
   //    RTCC_ALM_POL | RTCC_ALMC2 | RTCC_ALMC1 | RTCC_ALMC0
   // This will drive the MPF pin high when the alarm triggered
   // It also sets the alarm to be triggered when the alarm matches
   // Seconds, Minutes, Hour, Day, Date, Month of the RTCC
   RTCC_enableAlarm(&myDevice, RTCC_TARGET_ALM0,
         RTCC_ALM_POL | RTCC_ALMC2 | RTCC_ALMC1 | RTCC_ALMC0);

   // Enable alarm 1
   // Set configuration bits to RTCC_ALM_POL
   // This will drive the MPF pin high when the alarm triggered
   // It also sets the alarm to be triggered when the alarm matches
   // Seconds of the RTCC
   RTCC_enableAlarm(&myDevice, RTCC_TARGET_ALM1,
         RTCC_ALM_POL | RTCC_ALMC2 | RTCC_ALMC1 | RTCC_ALMC0);

   // Enable back up battery
   RTCC_enableVbat(&myDevice);

   RTCC_clearPWRFAIL(&myDevice);
}

/** void DemoRun()
**
**  Description:
**     This function prints the current time over UART once per second, and
**     tells the user if one of the alarms has been triggered
*/
void DemoRun() {
   while (1) {
      sleep(1);

      // Print current time
      xil_printf("Current time is : ");
      PrintTime(RTCC_TARGET_RTCC);
      xil_printf("\r\n");

      // Check if alarm 0 is triggered
      if (RTCC_checkFlag(&myDevice, RTCC_TARGET_ALM0)) {
         // Alarm 0 has been triggered
         xil_printf("ALARM 0!!!");
         // Disable alarm 0
         RTCC_disableAlarm(&myDevice, RTCC_TARGET_ALM0);
         xil_printf("\r\n");
      }

      // Check if alarm 1 is triggered
      if (RTCC_checkFlag(&myDevice, RTCC_TARGET_ALM1)) {
         // Alarm 1 has been triggered
         xil_printf("ALARM 1!!!");
         // Disable alarm
         RTCC_disableAlarm(&myDevice, RTCC_TARGET_ALM1);
         xil_printf("\r\n");
      }
   }
}

/** RTCC_Time GetTime(PmodRTCC *InstancePtr, RTCC_Target src)
**
**  Parameters:
**     InstancePtr - the target device to retrieve data from
**     src         - RTCC_TARGET_RTCC - real-time clock
**                   RTCC_TARGET_ALM0 - Alarm 0
**                   RTCC_TARGET_ALM1 - Alarm 1
**                   RTCC_TARGET_PWRD - power-down time-stamp
**                   RTCC_TARGET_PWRU - power-up time-stamp
**
**  Return Value:
**     val - the contents of all time registers in the target area
**
**  Description:
**     This function retrieves the contents of one of the Pmod RTCC's time areas
*/
RTCC_Time GetTime(PmodRTCC *InstancePtr, RTCC_Target src) {
   RTCC_Time val;

   if (src != RTCC_TARGET_PWRD && src != RTCC_TARGET_PWRU) {
      val.second = RTCC_getSec(&myDevice, src);
   }

   val.minute = RTCC_getMin(&myDevice, src);
   val.hour   = RTCC_getHour(&myDevice, src);
   val.ampm   = RTCC_getAmPm(&myDevice, src);
   val.day    = RTCC_getDay(&myDevice, src);
   val.date   = RTCC_getDate(&myDevice, src);
   val.month  = RTCC_getMonth(&myDevice, src);

   if (src == RTCC_TARGET_RTCC) {
      val.year = RTCC_getYear(&myDevice);
   } else {
      val.year = 0;
   }

   return val;
}

/** void SetTime(PmodRTCC *InstancePtr, RTCC_Target src, RTCC_Time val)
**
**  Parameters:
**     InstancePtr - the target device to retrieve data from
**     src         - RTCC_TARGET_RTCC - real-time clock
**                   RTCC_TARGET_ALM0 - Alarm 0
**                   RTCC_TARGET_ALM1 - Alarm 1
**                   RTCC_TARGET_PWRD - power-down time-stamp
**                   RTCC_TARGET_PWRU - power-up time-stamp
**     val         - container for the time data to be written into the target
**                   area's registers
**
**  Return Value:
**     None
**
**  Description:
**     This function writes data into each of the registers of one of the
**     PmodRTCC's time fields
*/
void SetTime(PmodRTCC *InstancePtr, RTCC_Target dest, RTCC_Time val) {
   if (dest != RTCC_TARGET_PWRD && dest != RTCC_TARGET_PWRU) {
      RTCC_setSec(&myDevice, dest, val.second);
   }

   RTCC_setMin(&myDevice, dest, val.minute);
   RTCC_setHour12(&myDevice, dest, val.hour, val.ampm);
   RTCC_setDay(&myDevice, dest, val.day);
   RTCC_setDate(&myDevice, dest, val.date);
   RTCC_setMonth(&myDevice, dest, val.month);

   if (dest == RTCC_TARGET_RTCC) {
      RTCC_setYear(&myDevice, val.year);
   }
}

/** void PrintTime(RTCC_Target src)
**
**  Description:
**     This function prints the current time over UART, formatted to the
**     equivalent of "Monday 1/1/00 01:00:00 AM"
*/
void PrintTime(RTCC_Target src) {
   RTCC_Time time;

   // Fetch the time from the device
   time = GetTime(&myDevice, src);

   xil_printf("%s %x/%x", weekdays[time.day], time.month, time.date);

   // Year is only available for the RTCC
   if (src == RTCC_TARGET_RTCC) {
      xil_printf("/%02x", time.year);
   }

   xil_printf(" %x:%02x", time.hour, time.minute);

   // Second is not supported by the power fail registers
   if (src != RTCC_TARGET_PWRD && src != RTCC_TARGET_PWRU) {
      xil_printf(":%02x", time.second);
   }

   if (time.ampm) {
      xil_printf(" PM");
   } else {
      xil_printf(" AM");
   }
}

/** RTCC_Time IncrementTime(RTCC_Time time, int delta_seconds)
**
**  Parameters:
**     time          - container for time data
**     delta_seconds - how many seconds to increment time forward by
**
**  Return:
**     result - time data incremented forward
**
**  Description:
**     This function steps the time parameter forward by delta_seconds,
**     returning the result after ensuring that all modified fields are in the
**     proper range.
**
**  Errors:
**     This function will return the time parameter if requested to cross the
**     midnight/noon boundary.
*/
RTCC_Time IncrementTime(RTCC_Time time, int delta_seconds) {
   RTCC_Time result;
   int temp;
   result = time;
   temp = bcd2int(result.second) + delta_seconds;
   result.second = int2bcd(temp % 60);          // Convert seconds
   temp = bcd2int(result.minute) + temp / 60;   // Carry seconds -> minutes
   result.minute = int2bcd(temp % 60);          // Convert minutes
   temp = bcd2int(result.hour) + temp / 60 - 1; // Carry minutes -> hours
   result.hour = int2bcd((temp % 12) + 1);      // Convert hours
   return result;
}

/** u8 bcd2int(u8 data)
**
**  Description:
**     This function converts 8 bit binary coded decimal numbers to 8 bit
**     unsigned integers.
*/
u8 bcd2int(u8 data) {
   return ((data >> 4) * 10) + (data & 0xF);
}

/** u8 bcd2int(u8 data)
**
**  Description:
**     This function converts 8 bit unsigned integers to 8 bit binary coded
**     decimal numbers.
**
**  Notes:
**     This function will lose data if requested to convert numbers larger than
**     99. However, numbers in this range are not needed for operating the RTCC.
*/
u8 int2bcd(u8 data) {
   return (((data / 10) & 0xF) << 4) + ((data % 10) & 0xF);
}

void DemoCleanup() {
   DisableCaches();
}

void EnableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheEnable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheEnable();
#endif
#endif
}

void DisableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheDisable();
#endif
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheDisable();
#endif
#endif
}
