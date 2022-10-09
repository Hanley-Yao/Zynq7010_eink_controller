/******************************************************************************/
/*                                                                            */
/* main.c -- Demo for the PmodNAV using SPI and UART                          */
/*                                                                            */
/******************************************************************************/
/* Author: Samuel Lowe, Arthur Brown                                          */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/*
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains a demo to be used with the PmodNAV. Accelerometer,      */
/* Magnetometer, Temperature, and Barometric Pressure data is captured over a */
/* SPI interface and displayed over UART.                                     */
/*                                                                            */
/* This application configures UART 16550 to baud rate 9600.                  */
/* PS7 UART (Zynq) is not initialized by this application, since bootrom/bsp  */
/* configures it to baud rate 115200                                          */
/*                                                                            */
/*  ------------------------------------------------                          */
/*  | UART TYPE   BAUD RATE                        |                          */
/*  ------------------------------------------------                          */
/*    Uartns550   9600                                                        */
/*    Uartlite    Configurable only in HW design                              */
/*    ps7_uart    115200 (configured by bootrom/bsp)                          */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    11/16/2016(SamL):     Created                                           */
/*    03/16/2017(ArtVVB):   Completed & Validated                             */
/*    11/01/2017(ArtVVB):   2016.4 Maintenance                                */
/*    02/20/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/
/* Problems:                                                                  */
/*                                                                            */
/* In order to include "math.h" you must include m in compiler settings.      */
/* See https://www.xilinx.com/support/answers/52971.html                      */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include <stdio.h>
#include "math.h"
#include "PmodNAV.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xparameters.h"

/*************************** Global Variables ******************************/

PmodNAV nav;

/********************* Function Forward Declarations ***********************/

void NavDemo_Initialize(void);
void NavDemo_Run(void);
void NavDemo_Cleanup(void);

float NavDemo_ComputePref(float hPa, float altitudeMeters);
float NavDemo_ConvPresToAltF(float Pref, float hPa);
float NavDemo_ConvPresToAltM(float Pref, float hPa);

float NavDemo_ConvTempCToTempF(float tempC);
float NavDemo_ConvFeetToMeters(float feet);
float NavDemo_ConvMetersToFeet(float meters);

float NavDemo_AngleInXY(NAV_RectCoord r);
float NavDemo_DegreesFromVertical(NAV_RectCoord r);
float NavDemo_ScalarProjection(NAV_RectCoord orient, NAV_RectCoord r);

void NavDemo_EnableCaches(void);
void NavDemo_DisableCaches(void);

/***************************** Function Definitions ************************/

int main(void) {
   NavDemo_Initialize();
   NavDemo_Run();
   NavDemo_Cleanup();
   return 0;
}

/*** void NavDemo_Initialize()
**
**   Parameters:
**      None
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function initializes the hardware used in the demo and starts a
**      PmodNAV driver device
*/
void NavDemo_Initialize(void) {
    NavDemo_EnableCaches();
    xil_printf("Pmod Nav Demo Initializing...\n\r");
    NAV_begin ( // intialize the PmodNAV driver device
        &nav,
        XPAR_PMODNAV_0_AXI_LITE_GPIO_BASEADDR,
        XPAR_PMODNAV_0_AXI_LITE_SPI_BASEADDR
    );
    xil_printf("Pmod Nav Demo Initialized\n\r");
    NAV_Init(&nav); // initialize the connection with each spi slave
}

/*** void NavDemo_Run(void)
**
**   Parameters:
**      None
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**  Description:
**      This function encapsulates the PmodNAV demo, capturing data from each
**      part on the PmodNAV and displaying it over a UART connection
*/
void NavDemo_Run(void) {
   float Pref,
         tempF,
         dps,
         magXYd,
         alt;
    char *compass[8] = {"North", "North-East", "East", "South-East", "South",
          "South-West", "West", "North-West"};
    char *str;
    // Set the known altitude as reference for future measurements of altitude
    // Uncomment the below line to improve accuracy of the altimeter device by
    // specifying the known altitude for your current location

   printf("Pmod Nav Demo Started\n\r");
   NAV_ReadPressurehPa(&nav);
   alt = NavDemo_ConvFeetToMeters(175.0); // altitude for Seattle, WA in meters
   Pref = NavDemo_ComputePref(nav.hPa, alt);
   usleep(100000);
   while(1){
      NAV_GetDeviceID(&nav);

      printf("Device IDs\n\r");
      printf(
         "A/G ID:%d  MAG ID:%d  ALT ID:%d\n\r\n\r",
         nav.idData.ag,
         nav.idData.mag,
         nav.idData.alt
      );

      NAV_GetData(&nav);

      printf(
         "Accelerometer G values    X:%.2f G, Y:%.2f G, Z:%.2f G\n\r",
         nav.acclData.X,
         nav.acclData.Y,
         nav.acclData.Z
      );

      printf(
         "    %.2f degrees from vertical\n\r",
         NavDemo_DegreesFromVertical(nav.acclData)
      );
      // Format and serial print the data read from accelerometer instrument,
      // stored in acclData variables and expressed in G

      printf(
         "Gyro dps values   X:%.2f dps, Y:%.2f dps, Z:%.2f dps\n\r",
         nav.gyroData.X,
         nav.gyroData.Y,
         nav.acclData.Z
      );
      dps = NavDemo_ScalarProjection(nav.acclData, nav.gyroData);
      if (dps < -4) // Remove some noise around 0
         str = "Clockwise";
      else if (dps > 4)
        str = "Counter-Clockwise";
      else
         str = "Marginal";
      printf("    rotating about vertical at %6.2f dps (%s)\n\r", dps, str);
      // Format and serial print the data read from Gyro instrument, stored in
      // gyroData variables and expressed in degrees per second

      printf(
         "Magnetometer Gauss values   X:%.2f Gauss, Y:%.2f Gauss, Z:%.2f Gauss \
                \n\r",
         nav.magData.X,
         nav.magData.Y,
         nav.magData.Z
      );
      // Format and serial print the data read from magnetometer instrument,
      // stored in magData variables and expressed in Gauss

      magXYd = NavDemo_AngleInXY(nav.magData);
      str = compass[(int)((magXYd + 22.5) / 45.0) % 8];
      // Get appropriate compass string - North is centered on 0 degrees
      printf("    Heading in Degrees: %.2f   Y Direction: %s\n\r", magXYd, str);

      printf("Pressure: %.1f hPa\n\r", nav.hPa);
      alt = NavDemo_ConvPresToAltF(Pref, nav.hPa);
      printf("Altitude: %.1f feet\n\r", alt);

      tempF = NavDemo_ConvTempCToTempF(nav.tempC);
      printf("Temperature: %.2f degrees Celsius\n\r", nav.tempC);
      printf("             %.2f degrees Fahrenheit\n\r", tempF);
      xil_printf("\n\r\n\r");

      usleep(500000);
    }
}

/*** void NavDemo_Cleanup(void)
**
**   Parameters:
**      None
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function closes the PmodNAV device and ends the demo
*/
void NavDemo_Cleanup(void) {
   NAV_end(&nav);
   NavDemo_DisableCaches();
}

/*** float NavDemo_ComputePref(float hPa, float altitudeMeters)
**
**   Parameters:
**      hPa            - a reading of the current pressure
**      altitudeMeters - the parameter used to calibrate the altitude computing,
**                       is considered known for the wanted location
**
**   Return Values:
**      Pref - the reference pressure in hPa
**
**   Errors:
**      None
**
**   Description:
**      This function provides the reference pressure computed with a known
**      altitude for the given location it performs a pressure reading, then
**      computes the reference pressure using the altitude parameter.
**
**      It needs to be called once for the correct operation of the altitude
**      function, all the following pressure readings are affected by it. This
**      This is needed because the current altitude is also affected by the
**      current sea level air pressure, while the barometric pressure formula
**      used to compute altitude is considering the sea level pressure constant
**      at all times.
*/
float NavDemo_ComputePref(float hPa, float altitudeMeters) {
   float altitudeFeet = NavDemo_ConvMetersToFeet(altitudeMeters);
   float temp = 1 - (altitudeFeet / 145366.45);
   temp = hPa / (powf(temp, 1.0 / 0.190284));
   return temp;
}

/*** float NavDemo_ConvPresToAltM(float hPa)
**
**   Parameters:
**      float hPa - parameter representing the value of pressure in hPa
**
**   Return Values:
**      float altMeters - it returns the current altitude based on the measured
**                        pressure and the previously computed reference
**                        pressure
**
**   Errors:
**      None
**
**   Description:
**      This function calls the ConvPresToAltF function to obtain the altitude
**      in feet. Then it converts it to meters.
**      The Pref is computed once and used for further calculations of the
**      altitude.
*/
float NavDemo_ConvPresToAltM(float Pref, float hPa) {
   return NavDemo_ConvPresToAltF(Pref, hPa) * 0.3048;
}

/*** float NavDemo_ConvPresToAltF(float Pref, float hPa)
**
**   Parameters:
**      float Pref - pressure reference
**      float hPa  - parameter representing the value of pressure in hPa
**
**   Return Values:
**      float altFeet - returns the value of the altitude in feet
**
**   Errors:
**      None
**
**   Description:
**      This function converts the provided pressure to altitude (in feet) using
**      the previously computed Pref as reference pressure.
**
**      The calculation of altitude is based on the following formula:
**      Altitude_ft = (1-pow(*Pressure_mb/1013.25,0.190284))*145366.45
*/
float NavDemo_ConvPresToAltF(float Pref, float hPa) {
   return ((1 - pow(hPa / Pref, 0.190284)) * 145366.45);
}

/*** float NavDemo_ConvTempCToTempF(float tempC)
**
**   Parameters:
**      tempC - parameter representing the value of temperature expressed in
**              degrees Celsius
**
**   Return Values:
**      float - returns the value of the temperature in degrees Fahrenheit
**
**   Errors:
**      None
**
**   Description:
**      This function performs the conversion from Celsius to Fahrenheit degrees
**      and returns the value of temperature in F
**
*/
float NavDemo_ConvTempCToTempF(float tempC) {
   return 32 + (tempC * 1.8);
}

/*** float NavDemo_ConvFeetToMeters(float feet)
**
**   Parameters:
**      feet - a distance in feet
**
**   Return Values:
**      float - returns the parameter feet converted to meters
**
**   Errors:
**
**   Description:
**      This function performs the conversion from units of feet to meters
*/
float NavDemo_ConvFeetToMeters(float feet) {
   return feet * 0.3048;
}

/*** float NavDemo_ConvMetersToFeet(float meters)
**
**   Parameters:
**      meters - a distance in meters
**
**   Return Values:
**      float - returns the parameter meters converted to feet
**
**   Errors:
**
**   Description:
**      This function performs the conversion from units of meters to feet
*/
float NavDemo_ConvMetersToFeet(float meters) {
   return meters * 3.28084;
}

/*** float NavDemo_AngleInXY(NAV_RectCoord r)
**
**   Parameters:
**      r - the vector in rectangular coordinates to be converted to polar
**
**   Return Value:
**      p - returns the polar coordinate representation of the vector r
**          projected onto the XY plane
**
**   Errors:
**      None
**
**   Description:
**      The function computes the degrees the vector r is rotated about the
**      Z-axis from the vector (X=1,0,0)
*/
float NavDemo_AngleInXY(NAV_RectCoord r) {
   float d;
   if (r.X == 0)
      d = (r.Y < 0) ? 90 : 0;
   else
      d = atan2f(r.Y, r.X) * 180 / M_PI;
   if (d > 360)
      d -= 360;
   else if (d < 0)
      d += 360;
   return d;
}

/*** float NavDemo_DegreesFromVertical(NAV_RectCoord r)
**
**   Parameters:
**      r - the xyz vector to be operated upon
**
**   Return Value:
**      float - the angle in degrees between the vector r and the unit Z vector.
**
**   Errors:
**      None
**
**  Description:
**      The function computes the angle in degrees between the vector r and the
**      vector (0,0,Z=1)
*/
float NavDemo_DegreesFromVertical(NAV_RectCoord r) {
   // Determine the magnitude of the vector r.
   float rM = sqrtf(powf(r.X, 2) + powf(r.Y, 2) + powf(r.Z, 2));
   if (rM == 0)
      return 0.0;
   return acosf(r.Z / rM) * (180.0 / M_PI);
}

/*** float NavDemo_ScalarProjection(NAV_RectCoord orient, NAV_RectCoord r)
**
**   Parameters:
**      orient   - the xyz vector
**      rotation - the xyz vector
**
**   Return Value:
**      float - the angle in degrees between the vector r and the unit Z vector.
**
**   Errors:
**      None
**
**   Description:
**      This function returns the scalar projection of the r vector onto the
**      orient vector. This can be used with gyroscope and accelerometer data to
**      determine rotation of the PmodNAV about true vertical.
*/
float NavDemo_ScalarProjection(NAV_RectCoord orient, NAV_RectCoord r) {
   float oM = sqrtf(powf(orient.X, 2) + powf(orient.Y, 2) + powf(orient.Z, 2));
   return (r.X * orient.X + r.Y * orient.Y + r.Z * orient.Z) / oM;
}

/*** void NavDemo_EnableCaches(void)
**
**   Parameters:
**      None
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function enables the instruction and/or data caches on
**      architectures that require them
*/
void NavDemo_EnableCaches(void) {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheEnable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheEnable();
#endif
#endif
}

/*** void NavDemo_DisableCaches(void)
**
**   Parameters:
**      None
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function disables the instruction and/or data caches on
**      architectures that require them
*/
void NavDemo_DisableCaches(void) {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheDisable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheDisable();
#endif
#endif
}
