/******************************************************************************/
/*                                                                            */
/* PmodGPS.h -- Driver definitions for the PmodGPS                            */
/*                                                                            */
/******************************************************************************/
/* Author: Thomas Kappenman                                                   */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodGPS IP from Digilent            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    04/17/2016(tom21091): Created                                           */
/*    10/13/2017(atangzwj): Validated for Vivado 2015.4                       */
/*    11/04/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    01/29/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODGPS_H
#define PMODGPS_H

/************ Include Files ************/

#include "xil_types.h"
#include "xstatus.h"
#include "xuartns550.h"
#include "xuartns550_l.h"


/************ Macro Definitions ************/

#define GPS_bool u32

#define GPS_MAX_SIZE 128


/************ Type Definitions ************/

typedef enum {
   GPS_INVALID = 0,
   GPS_GGA, // Time, position, and fix type data
   GPS_GLL, // Lat/Long data
   GPS_GSA, // Operating mode, active satellites, DOP values
   GPS_GSV, // Satellites in view, satellite ID nums, elevation, azimuth,
            // SNR values
   GPS_RMC, // Recommended minimum navigation information
   GPS_VTG  // course and speed relative to ground
} GPS_NMEA;

typedef struct GPS_SATELLITE_T {
   int ID;  // Satellite ID
   int ELV; // Satellite Elevation in degrees (90° max)
   int AZM; // Satellite Azimuth, degrees from true north (0° to 359°)
   int SNR; // Satellite Signal to noise ratio, 0-99 dB
} GPS_SATELLITE;

typedef struct GPS_GGA_DATA_T {
   char UTC[11];     // UTC Time
   char LAT[14];     // Latitude
   char NS;          // North or south indicator
   char LONG[15];    // Longitude
   char EW;          // East or west indicator
   char PFI;         // Position fixed indicator
   char NUMSAT[3];   // Number of satellites used
   char HDOP[5];     // HDOP
   char ALT[10];     // MSL Altitude
   char AUNIT;       // Units
   char GSEP[5];     // Geoidal Separation
   char GUNIT;       // Units
   char AODC[11];    // Age of Diff. Corr.
   char CHECKSUM[3]; // Checksum
} GPS_GGA_DATA;

typedef struct GPS_GLL_DATA_T {
   char LAT[14];     // Latitude
   char NS;          // North or south indicator
   char LONG[15];    // Longitude
   char EW;          // East or west indicator
   char UTC[11];     // UTC Time
   char ACTIVE;      // Active or void data
   char MODE;
   char CHECKSUM[3]; // Checksum
} GPS_GLL_DATA;

typedef struct GPS_GSA_DATA_T {
   char MODE1; // 'M' for manual- forced to operate in 2D or 3D mode
               // 'A' for 2D automatic- switches automatically b/w 2D/3D
   char MODE2; //  1 - fix not available
               //  2 - 2D (<4SVs used)
               //  3 - 3D(>=4 SVs used)

   char SAT1[3];     // Satellite Used (SV) (channel 1)
   char SAT2[3];     // Satellite Used (SV) (channel 2)
   char SAT3[3];     // Satellite Used (SV) (channel 3)
   char SAT4[3];     // Satellite Used (SV) (channel 4)
   char SAT5[3];     // Satellite Used (SV) (channel 5)
   char SAT6[3];     // Satellite Used (SV) (channel 6)
   char SAT7[3];     // Satellite Used (SV) (channel 7)
   char SAT8[3];     // Satellite Used (SV) (channel 8)
   char SAT9[3];     // Satellite Used (SV) (channel 9)
   char SAT10[3];    // Satellite Used (SV) (channel 10)
   char SAT11[3];    // Satellite Used (SV) (channel 11)
   char SAT12[3];    // Satellite Used (SV) (channel 12)
   char PDOP[4];     // Positional dilution of precision
   char HDOP[4];     // Horizontal dilution of precision
   char VDOP[4];     // Vertical Dilution of precision
   char CHECKSUM[3]; // checksum
} GPS_GSA_DATA;

typedef struct GPS_GSV_DATA_T {
   int NUMM;              // Number of messages
   int MESNUM;            // Message number
   int SATVIEW;           // Satellites in view
   GPS_SATELLITE SAT[15]; // Satellite info
   char CHECKSUM[3];      // checksum
} GPS_GSV_DATA;

typedef struct GPS_RMC_DATA_T {
   char UTC[11];     // UTC Time
   char STAT;        // Status: A = data valid, V = data not valid
   char LAT[14];     // Latitude
   char NS;          // N/S indicator
   char LONG[14];    // Longitude
   char EW;          // E/W indicator
   char SOG[10];     // Speed over ground (knots)
   char COG[7];      // Course over ground (degrees)
   char DATE[7];     // Date
   char MVAR[7];     // Magnetic Variation (degrees)
   char MVARDIR;     // Magnetic Variation direction
   char MODE;        // A: Autonomous mode
                     // D: Differential mode
                     // E: Estimated mode
   char CHECKSUM[3]; //checksum
} GPS_RMC_DATA;

typedef struct GPS_VTG_DATA_T {
   char COURSE_T[7]; // measured heading
   char REF_T;       // True (T)
   char COURSE_M[7]; // measured heading
   char REF_M;       // Magnetic (M)
   char SPD_N[7];    // Measured speed (knots)
   char UNIT_N;      // Knots (N)
   char SPD_KM[7];   // Measured speed (km/h)
   char UNIT_KM;     // km/hr (K)
   char MODE;        // A: Autonomous mode
                     // D: Differential mode
                     // E: Estimated mode
   char CHECKSUM[3]; // checksum
} GPS_VTG_DATA;

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a PMODGPS register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the PMODGPSdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 *      void PMODGPS_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define PMODGPS_mWriteReg(BaseAddress, RegOffset, Data) \
        Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a PMODGPS register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the PMODGPS device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 *      u32 PMODGPS_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define PMODGPS_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the PMODGPS instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus PMODGPS_Reg_SelfTest(void * baseaddr_p);

typedef struct PmodGPS {
   u32 GPIO_addr;
   GPS_GGA_DATA GGAdata;
   GPS_GLL_DATA GLLdata;
   GPS_GSA_DATA GSAdata;
   GPS_GSV_DATA GSVdata;
   GPS_RMC_DATA RMCdata;
   GPS_VTG_DATA VTGdata;
   XUartNs550 GPSUart;
   volatile GPS_bool ping;
   char recv[600];
   GPS_NMEA last_Sentence;
   u32 periph_clk;
} PmodGPS;


/************ Function Prototypes ************/

int GPS_UARTInit(XUartNs550 *UartInstancePtr);
int GPS_changeBaud(PmodGPS *InstancePtr, int baud);
u8 GPS_getChecksum(char *message);
int GPS_setUpdateRate(PmodGPS *InstancePtr, int milli_interval);
int GPS_setModes(PmodGPS *InstancePtr, u8 GGA, u8 GLL, u8 GSA, u8 GSV, u8 RMC,
      u8 VTG);
GPS_bool GPS_getSentence(PmodGPS *InstancePtr, char *output);

void GPS_begin(PmodGPS *InstancePtr, u32 GPIO_Address, u32 UART_Address,
      u32 Peripheral_Clk);
void GPS_HostInit(PmodGPS *InstancePtr);
int GPS_readPPSpin(PmodGPS *InstancePtr);
int GPS_read3DFpin(PmodGPS *InstancePtr);
GPS_bool GPS_getData(PmodGPS *InstancePtr);
GPS_bool GPS_formatSentence(PmodGPS *InstancePtr);

GPS_bool GPS_isFixed(PmodGPS *InstancePtr);
char *GPS_getLatitude(PmodGPS *InstancePtr);
char *GPS_getLongitude(PmodGPS *InstancePtr);
char *GPS_getDate(PmodGPS *InstancePtr);
double GPS_getAltitude(PmodGPS *InstancePtr);
char *GPS_getAltitudeString(PmodGPS *InstancePtr);
double GPS_getTime(PmodGPS *InstancePtr);
int GPS_getNumSats(PmodGPS *InstancePtr);
double GPS_getPDOP(PmodGPS *InstancePtr);
double GPS_getSpeedKnots(PmodGPS *InstancePtr);
double GPS_getSpeedKM(PmodGPS *InstancePtr);
double GPS_getHeading(PmodGPS *InstancePtr);
GPS_SATELLITE *GPS_getSatelliteInfo(PmodGPS *InstancePtr);

GPS_GGA_DATA GPS_getGGA(PmodGPS *InstancePtr);
GPS_GSA_DATA GPS_getGSA(PmodGPS *InstancePtr);
GPS_GSV_DATA GPS_getGSV(PmodGPS *InstancePtr);
GPS_RMC_DATA GPS_getRMC(PmodGPS *InstancePtr);
GPS_VTG_DATA GPS_getVTG(PmodGPS *InstancePtr);

GPS_NMEA GPS_chooseMode(char recv[GPS_MAX_SIZE]);
int GPS_formatGGA(PmodGPS *InstancePtr, char *data_array);
int GPS_formatGLL(PmodGPS *InstancePtr, char *data_array);
int GPS_formatGSA(PmodGPS *InstancePtr, char *data_array);
int GPS_formatGSV(PmodGPS *InstancePtr, char *data_array);
int GPS_formatRMC(PmodGPS *InstancePtr, char *data_array);
int GPS_formatVTG(PmodGPS *InstancePtr, char *data_array);
void GPS_formatCOORDS(char *coords);

int GPS_SetupInterruptSystem(PmodGPS *InstancePtr, u32 interruptDeviceID,
      u32 interruptID);
void GPS_intHandler(PmodGPS *InstancePtr, u32 Event, unsigned int EventData);

#endif // PMODGPS_H
