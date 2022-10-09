/******************************************************************************/
/*                                                                            */
/* PmodGPS.c -- Driver definitions for the PmodGPS                            */
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

/***************************** Include Files *******************************/

#include <stdio.h>
#include <stdlib.h>
#include "PmodGPS.h"


/************************** Function Definitions ***************************/

XUartNs550_Config GPS_Config =
{
   0,
   0,
   0,
   9600 // Default Baud rate
};

/* ------------------------------------------------------------ */
/*  GPS_begin(PmodGPS *InstancePtr, u32 GPIO_Address, u32 UART_Address)
 **
 **    Parameters:
 **       InstancePtr:    A PmodGPS object to start
 **       GPIO_Address:   The Base address of the PmodGPS GPIO
 **       UART_Address:   The Base address of the PmodGPS UART
 **       Peripheral_Clk: Frequency (Hz) of the PmodGPS IP's clock
 **
 **    Return Value:
 **       none
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Initialize the PmodGPS.
 */
void GPS_begin(PmodGPS *InstancePtr, u32 GPIO_Address, u32 UART_Address,
      u32 Peripheral_Clk) {
   InstancePtr->periph_clk = Peripheral_Clk;
   InstancePtr->GPIO_addr = GPIO_Address;
   GPS_Config.BaseAddress = UART_Address;
   GPS_Config.InputClockHz = Peripheral_Clk;
   Xil_Out32(InstancePtr->GPIO_addr + 4, 0x3); // Set 3DF and PPS to inputs
   GPS_UARTInit(&InstancePtr->GPSUart);
   GPS_changeBaud(InstancePtr, 115200); // Set baud rate to 115200
   GPS_setModes(InstancePtr, 1, 1, 1, 1, 1, 1);
}

/* ------------------------------------------------------------ */
/*  GPS_changeBaud()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to configure
 **       baud:        Desired baud rate to set the PmodGPS to
 **
 **    Return Value:
 **       1 if successful, 0 if invalid baud
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Changes the baud rate of the PmodGPS, then the XUartNs550
 **       controller
 */
int GPS_changeBaud(PmodGPS *InstancePtr, int baud) {
   char *message;

   u32 i = 0;
   switch (baud) {
   case 4800:
      message = "$PMTK251,4800*14\r\n";
      break;
   case 9600:
      message = "$PMTK251,9600*17\r\n";
      break;
   case 14400:
      message = "$PMTK251,14400*29\r\n";
      break;
   case 19200:
      message = "$PMTK251,19200*22\r\n";
      break;
   case 38400:
      message = "$PMTK251,38400*27\r\n";
      break;
   case 57600:
      message = "$PMTK251,57600*2C\r\n";
      break;
   case 115200:
      message = "$PMTK251,115200*1F\r\n";
      break;
   default:
      return XST_FAILURE;
      break;
   }
   while (i < strlen(message)) {
      i += XUartNs550_Send(&InstancePtr->GPSUart, (u8*) message + i,
            strlen(message) - i);
      while (XUartNs550_IsSending(&InstancePtr->GPSUart));
   }
   XUartNs550_SetBaud(InstancePtr->GPSUart.BaseAddress, InstancePtr->periph_clk,
         baud);

   return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/*  GPS_setUpdateRate()
 **
 **    Parameters:
 **       InstancePtr:    PmodGPS object to configure
 **       milli_interval: Desired millisecond interval to receive messages
 **
 **    Return Value:
 **       1
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Sets the frequency that the PmodGPS sends sentences.
 **       100ms - 10seconds
 */
int GPS_setUpdateRate(PmodGPS *InstancePtr, int milli_interval) {
   char message[20] = {0};
   u32 i = 0;
   u8 checksum;
   if (milli_interval > 10000 || milli_interval < 100)
      return XST_FAILURE;
   sprintf(message, "$PMTK220,%d*", milli_interval);
   checksum = GPS_getChecksum(message);
   sprintf(message, "$PMTK220,%d*%X\r\n", milli_interval, checksum);
   while (i < strlen(message)) {
      i += XUartNs550_Send(&InstancePtr->GPSUart, (u8*) message + i,
            strlen(message) - i);
      while (XUartNs550_IsSending(&InstancePtr->GPSUart));
   }
   return XST_SUCCESS;

}

/* ------------------------------------------------------------ */
/*  GPS_setModes()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to configure
 **       GLL:         GPS pings per GLL message
 **       RMC:         GPS pings per RMC message
 **       VTG:         GPS pings per VTG message
 **       GGA:         GPS pings per GGA message
 **       GSA:         GPS pings per GSA message
 **       GSV:         GPS pings per GSV message
 **
 **    Return Value:
 **       1
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Configures which messages are sent by the GPS:
 **          1 = Every ping
 **          2 = Every two pings, up to 5
 */
int GPS_setModes(PmodGPS *InstancePtr, u8 GGA, u8 GLL, u8 GSA, u8 GSV, u8 RMC,
      u8 VTG) {
   char message[52] = {0};
   u32 i = 0;
   u8 checksum;
   sprintf(message, "$PMTK314,%d,%d,%d,%d,%d,%d,0,0,0,0,0,0,0,0,0,0,0,0,0*",
         GLL, RMC, VTG, GGA, GSA, GSV);
   checksum = GPS_getChecksum(message);
   sprintf(message,
         "$PMTK314,%d,%d,%d,%d,%d,%d,0,0,0,0,0,0,0,0,0,0,0,0,0*%X\r\n", GLL,
         RMC, VTG, GGA, GSA, GSV, checksum);
   if (*message) {
      while (i < strlen(message)) {
         i += XUartNs550_Send(&InstancePtr->GPSUart, (u8*) message + i,
               strlen(message) - i);
         while (XUartNs550_IsSending(&InstancePtr->GPSUart));
      }
   }
   if (VTG)
      InstancePtr->last_Sentence = 6;
   else if (RMC)
      InstancePtr->last_Sentence = 5;
   else if (GSA)
      InstancePtr->last_Sentence = 3;
   else if (GLL)
      InstancePtr->last_Sentence = 2;
   else if (GGA)
      InstancePtr->last_Sentence = 1;

   return 1;
}

/* ------------------------------------------------------------ */
/*  GPS_getChecksum()
 **
 **    Parameters:
 **       message: The NMEA sentence to calculate the checksum from
 **
 **    Return Value:
 **       checksum of the message
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Calculates the checksum for the input sentence
 */
u8 GPS_getChecksum(char *message) {
   char *temp = message + 1; // Skip the $
   u8 checksum = 0;
   while (*temp != '*') {
      checksum ^= *temp;
      temp++;
   }
   return checksum;
}

/* ------------------------------------------------------------ */
/*  GPS_UARTInit
 **
 **    Parameters:
 **       UartInstancePtr: The XUartNs550 object to initialize
 **
 **    Return Value:
 **       0 if success, 1 if failure
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Initializes the PmodGPS UART.
 */
int GPS_UARTInit(XUartNs550 *UartInstancePtr) {
   int Status;
   u16 Options;
   Status = XUartNs550_CfgInitialize(UartInstancePtr, &GPS_Config,
         GPS_Config.BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }
   Options = XUN_OPTION_FIFOS_ENABLE;
   XUartNs550_SetOptions(UartInstancePtr, Options);
   return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/*  GPS_readPPSpin()
 **
 **  Parameters:
 **    InstancePtr: PmodGPS object to read from
 **
 **  Return Value:
 **    PPS input - Ping per second
 **
 **  Errors:
 **    none
 **
 **  Description:
 **    Reads the 3DF pin
 */
int GPS_readPPSpin(PmodGPS *InstancePtr) {
   return Xil_In32(InstancePtr->GPIO_addr) & 0x2;
}

/* ------------------------------------------------------------ */
/*  GPS_read3DFpin()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to read from
 **
 **    Return Value:
 **       3DF input
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Reads the 3DF pin
 */
int GPS_read3DFpin(PmodGPS *InstancePtr) {
   return Xil_In32(InstancePtr->GPIO_addr) & 0x1;
}

/* ------------------------------------------------------------ */
/*  GPS_getData()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to get data from
 **
 **    Return Value:
 **       1 if data was received successfully, 0 if not
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       For use in POLLED MODE ONLY
 **       Does a read of data. finishes when a value of decimal 10 (ASCII <LF>)
 **       is detected. Checks to see if it is the last sentence and returns if
 **       yes.
 */
GPS_bool GPS_getData(PmodGPS *InstancePtr) {
   int count = 0;
   GPS_NMEA mode = GPS_INVALID;
   unsigned int ReceivedCount = 0;
   u16 options = XUartNs550_GetOptions(&InstancePtr->GPSUart);
   if (options & XUN_OPTION_DATA_INTR)
      return 0; // If in interrupt mode, return 0
   if (ReceivedCount += XUartNs550_Recv(&InstancePtr->GPSUart,
         (u8*) InstancePtr->recv + ReceivedCount, GPS_MAX_SIZE)) {
      // If there is a sentence
      while (1) {
         while ((InstancePtr->recv[ReceivedCount - 1] != '\n')) {
            ReceivedCount += XUartNs550_Recv(&InstancePtr->GPSUart,
                  (u8*) InstancePtr->recv + ReceivedCount, GPS_MAX_SIZE);
         }
         InstancePtr->recv[ReceivedCount] = '\0';
         mode = GPS_chooseMode(InstancePtr->recv + count);
         if (mode == InstancePtr->last_Sentence) {
            break;
         }
         count = ReceivedCount;
         ReceivedCount += XUartNs550_Recv(&InstancePtr->GPSUart,
               (u8*) InstancePtr->recv + ReceivedCount, GPS_MAX_SIZE);
      }
   } else {
      return 0;
   }

   InstancePtr->ping = TRUE;
   return 1;
}

/* ------------------------------------------------------------ */
/*  GPS_getSentence()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to read from
 **       output:      A pointer to where the string will be stored
 **
 **    Return Value:
 **       True if sentence received, false if not
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Attempts to read a single sentence through UART
 */
GPS_bool GPS_getSentence(PmodGPS *InstancePtr, char *output) {
   int ReceivedCount = 0;
   if (ReceivedCount += XUartNs550_Recv(&InstancePtr->GPSUart,
         (u8*) output + ReceivedCount, 1)) { // If there is a sentence
      while (output[ReceivedCount - 1] != '\n') {
         ReceivedCount += XUartNs550_Recv(&InstancePtr->GPSUart,
               (u8*) output + ReceivedCount, 1);
      }
      return 1;
   } else
      return 0;
}

/* ------------------------------------------------------------ */
/*  GPS_formatSentence()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to read from
 **
 **    Return Value:
 **       bool
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Parses the GPS NMEA sentence stored in InstancePtr->recv
 */
GPS_bool GPS_formatSentence(PmodGPS *InstancePtr) {
   int i = 0;
   GPS_NMEA mode = GPS_INVALID;
   // Reset ping now that we are about to parse the last sentence
   InstancePtr->ping = 0;
   while (1) {
      mode = GPS_chooseMode(InstancePtr->recv + i);
      switch (mode) {
      case (GPS_GGA):
         i += GPS_formatGGA(InstancePtr, InstancePtr->recv + i);
         if (InstancePtr->last_Sentence == GPS_GGA)
            return 1;
         break;
      case (GPS_GLL):
         i += GPS_formatGLL(InstancePtr, InstancePtr->recv + i);
         if (InstancePtr->last_Sentence == GPS_GLL)
            return 1;
         break;
      case (GPS_GSA):
         i += GPS_formatGSA(InstancePtr, InstancePtr->recv + i);
         if (InstancePtr->last_Sentence == GPS_GSA)
            return 1;
         break;
      case (GPS_GSV):
         i += GPS_formatGSV(InstancePtr, InstancePtr->recv + i);
         if (InstancePtr->last_Sentence == GPS_GSV)
            return 1;
         break;
      case (GPS_RMC):
         i += GPS_formatRMC(InstancePtr, InstancePtr->recv + i);
         if (InstancePtr->last_Sentence == GPS_RMC)
            return 1;
         break;
      case (GPS_VTG):
         i += GPS_formatVTG(InstancePtr, InstancePtr->recv + i);
         if (InstancePtr->last_Sentence == GPS_VTG)
            return 1;
         break;
      case (GPS_INVALID):
         return 0;
         break;
      }
   }

   return 1;
}

/* ------------------------------------------------------------ */
/*  GPS_isFixed()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to read from
 **
 **    Return Value:
 **       bool PFI
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Returns a true if PFI is 1, else 0
 */
GPS_bool GPS_isFixed(PmodGPS *InstancePtr) {
   return (GPS_bool) ((int) (InstancePtr->GGAdata.PFI - '0') == 1
         || (int) (InstancePtr->GGAdata.PFI - '0') == 2);
}

/* ------------------------------------------------------------ */
/*  getLatitude(), getLongitude()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to read from
 **
 **    Return Value:
 **       A string containing the data requested
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Get functions for several data members in string form
 */
char *GPS_getLatitude(PmodGPS *InstancePtr) {
   return InstancePtr->GGAdata.LAT;
}

char *GPS_getLongitude(PmodGPS *InstancePtr) {
   return InstancePtr->GGAdata.LONG;
}

/* ------------------------------------------------------------ */
/*  getAltitudeString()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to read from
 **
 **    Return Value:
 **       A string containing the altitude with appended units
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Gets altitude and returns its value with units in string form
 */
char *GPS_getAltitudeString(PmodGPS *InstancePtr) {
   static char temp[12];
   sprintf(temp, "%s %c", InstancePtr->GGAdata.ALT, InstancePtr->GGAdata.AUNIT);
   return temp;
}

/* ------------------------------------------------------------ */
/*  getDate()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to read from
 **
 **    Return Value:
 **       A string containing the date in correct format
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Formats the date and returns it as a char string
 */
char *GPS_getDate(PmodGPS *InstancePtr) {

   static char date[8];
   date[0] = InstancePtr->RMCdata.DATE[2];
   date[1] = InstancePtr->RMCdata.DATE[3];
   date[2] = '/';
   date[3] = InstancePtr->RMCdata.DATE[0];
   date[4] = InstancePtr->RMCdata.DATE[1];
   date[5] = '/';
   date[6] = InstancePtr->RMCdata.DATE[4];
   date[7] = InstancePtr->RMCdata.DATE[5];
   strcat(date, "\0");
   return date;
}

/* ------------------------------------------------------------ */
/*  getTime(), getNumSats(), getPDOP(), getAltitude(), getSpeedKnots(),
 ** getSpeedKM(), getHeading()
 **
 **    Parameters:
 **       none
 **
 **    Return Value:
 **       The data in the structs in either integer or double form
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Get functions for several items in the PmodGPS structs. These values
 **       are converted to integers or doubles before being returned.
 */
double GPS_getTime(PmodGPS *InstancePtr) {
   return atof(InstancePtr->GGAdata.UTC);
}

int GPS_getNumSats(PmodGPS *InstancePtr) {
   return atoi(InstancePtr->GGAdata.NUMSAT);
}

double GPS_getPDOP(PmodGPS *InstancePtr) {
   return atof(InstancePtr->GSAdata.PDOP);
}

double GPS_getAltitude(PmodGPS *InstancePtr) {
   return atof(InstancePtr->GGAdata.ALT);
}

double GPS_getSpeedKnots(PmodGPS *InstancePtr) {
   return atof(InstancePtr->VTGdata.SPD_N);
}

double GPS_getSpeedKM(PmodGPS *InstancePtr) {
   return atof(InstancePtr->VTGdata.SPD_KM);
}

double GPS_getHeading(PmodGPS *InstancePtr) {
   return atof(InstancePtr->VTGdata.COURSE_T);
}

/* ------------------------------------------------------------ */
/*  chooseMode()
 **
 **    Parameters:
 **       char recv[GPS_MAX_SIZE]
 **
 **    Return Value:
 **       NMEA mode: The format of the sentence, for use in deciding
 **       which struct to format into
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Reads the third, fourth, and fifth character in the sentence, and
 **       outputs an NMEA mode.
 */
GPS_NMEA GPS_chooseMode(char recv[]) {
   GPS_NMEA mode = GPS_INVALID;
   while (recv[0] != '$' && recv[0] != '\0')
      recv--; //If not at beginning of sentence, go back
   if (((recv[0]) != '$') || ((recv[1]) != 'G') || ((recv[2]) != 'P'))
      return GPS_INVALID;
   if (((recv[3]) == 'G') && ((recv[4]) == 'G') && (recv[5] == 'A')) {
      mode = GPS_GGA;
   } else if (((recv[3]) == 'G') && ((recv[4]) == 'L') && (recv[5] == 'L')) {
      mode = GPS_GLL;
   } else if (((recv[3]) == 'G') && ((recv[4]) == 'S') && (recv[5] == 'A')) {
      mode = GPS_GSA;
   } else if (((recv[3]) == 'G') && ((recv[4]) == 'S') && (recv[5] == 'V')) {
      mode = GPS_GSV;
   } else if (((recv[3]) == 'R') && ((recv[4]) == 'M') && (recv[5] == 'C')) {
      mode = GPS_RMC;
   } else if (((recv[3]) == 'V') && ((recv[4]) == 'T') && (recv[5] == 'G')) {
      mode = GPS_VTG;
   }
   return mode;
}

/* ------------------------------------------------------------ */
/*  getSatelliteInfo()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to read from
 **
 **    Return Value:
 **       The array of SATELLITE structs in GSVdata
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       A get function for the SATELLITE structs containing satellite info.
 */
GPS_SATELLITE *GPS_getSatelliteInfo(PmodGPS *InstancePtr) {
   if (InstancePtr->GSVdata.SAT)
      return InstancePtr->GSVdata.SAT;
   else
      return 0;
}

/* ------------------------------------------------------------ */
/*  formatGGA()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to store data into
 **       data_array:  an array to the data to be formatted
 **
 **    Return Value:
 **       The offset from the beginning of data_array
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Formats a mode's data into elements in a struct.
 **       NOTE: ',' will separate all values
 */
int GPS_formatGGA(PmodGPS *InstancePtr, char *data_array) {
   enum cases {
      UTC, LAT, NS, LONG, EW, PFI, NUMSAT, HDOP, ALT, AUNIT, GSEP, GUNIT, AODC
   };
   enum cases datamember = UTC;
   char *start_ptr;
   char *end_ptr = data_array + 7; // Set end_ptr after message ID ("$GPGGA,")
   GPS_bool flag = 1;
   char COORDbuf[14] = {0};
   char checksum[3] = {0};

   while (flag) {
      start_ptr = end_ptr;

      while (*end_ptr != ',' && (*(end_ptr + 1) != 10) && *end_ptr != '*'
            && *end_ptr != '$')
         end_ptr++; // Increment ptr until a comma is found
      if (*end_ptr == '$') {
         return end_ptr - data_array;
      }
      if (*end_ptr == 10 || *(end_ptr + 1) == 10
            || (*end_ptr == '*' && *(end_ptr - 1) == ',')) { // End reached
         flag = 0;
         break;
      }

      switch (datamember) {
      case UTC:
         memcpy(InstancePtr->GGAdata.UTC, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GGAdata.UTC[end_ptr - start_ptr] = '\0'; // End null char
         datamember = LAT;
         break;
      case LAT:
         memcpy(COORDbuf, start_ptr, (end_ptr - start_ptr));
         if (*COORDbuf) {
            GPS_formatCOORDS(COORDbuf);
            strcpy(InstancePtr->GGAdata.LAT, COORDbuf);
            memset(COORDbuf, 0, sizeof(COORDbuf));
         }

         datamember = NS;
         break;
      case NS:
         if (*start_ptr != ',') {
            InstancePtr->GGAdata.NS = *start_ptr;
            strncat(InstancePtr->GGAdata.LAT, start_ptr, 1);
         }
         datamember = LONG;
         break;
      case LONG:
         memcpy(COORDbuf, start_ptr, (end_ptr - start_ptr));
         if (*COORDbuf) {
            GPS_formatCOORDS(COORDbuf);
            strcpy(InstancePtr->GGAdata.LONG, COORDbuf);\
            memset(COORDbuf, 0, sizeof(COORDbuf));
         }
         datamember = EW;
         break;
      case EW:
         if (*start_ptr != ',') {
            InstancePtr->GGAdata.EW = *start_ptr;
            strncat(InstancePtr->GGAdata.LONG, start_ptr, 1);
         }
         datamember = PFI;
         break;
      case PFI:
         if (*start_ptr != ',')
            InstancePtr->GGAdata.PFI = *start_ptr;
         datamember = NUMSAT;
         break;
      case NUMSAT:
         memcpy(InstancePtr->GGAdata.NUMSAT, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GGAdata.NUMSAT[end_ptr - start_ptr] = '\0';
         datamember = HDOP;
         break;
      case HDOP:
         memcpy(InstancePtr->GGAdata.HDOP, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GGAdata.HDOP[end_ptr - start_ptr] = '\0';
         datamember = ALT;
         break;
      case ALT:
         memcpy(InstancePtr->GGAdata.ALT, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GGAdata.ALT[end_ptr - start_ptr] = '\0';
         datamember = AUNIT;
         break;
      case AUNIT:
         if (*start_ptr != ',')
            InstancePtr->GGAdata.AUNIT = *start_ptr;
         datamember = GSEP;
         break;
      case GSEP:
         memcpy(InstancePtr->GGAdata.GSEP, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GGAdata.GSEP[end_ptr - start_ptr] = '\0';
         datamember = GUNIT;
         break;
      case GUNIT:
         if (*start_ptr != ',')
            InstancePtr->GGAdata.GUNIT = *start_ptr;
         datamember = AODC;
         break;
      case AODC:
         memcpy(InstancePtr->GGAdata.AODC, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GGAdata.AODC[end_ptr - start_ptr] = '\0';
         flag = 0;
         break;
      }
      end_ptr++; // Increment past the last comma
   }
   // Get checksum
   while (*(end_ptr) != 10)
      end_ptr++;
   checksum[0] = *(end_ptr - 3);
   checksum[1] = *(end_ptr - 2);
   checksum[2] = 0;
   memcpy(InstancePtr->GGAdata.CHECKSUM, checksum, 3);
   return end_ptr - data_array + 1;
}

/* ------------------------------------------------------------ */
/*  GPS_formatGLL()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to store data into
 **       data_array:  an array to the data to be formatted
 **
 **    Return Value:
 **       The offset from the beginning of data_array
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Formats a mode's data into elements in a struct.
 **       NOTE: ',' will separate all values
 */
int GPS_formatGLL(PmodGPS *InstancePtr, char *data_array) {
   enum cases {
      LAT, NS, LONG, EW, TIME, ACTIVE, MODE
   };
   enum cases datamember = LAT;
   char *start_ptr;
   char *end_ptr = data_array + 7; // Set end_ptr after message ID ("$GPGGA,")
   GPS_bool flag = 1;
   char COORDbuf[14] = {0};
   char checksum[3] = {0};

   while (flag) {
      start_ptr = end_ptr;

      while (*end_ptr != ',' && (*(end_ptr + 1) != 10) && *end_ptr != '*'
            && *end_ptr != '$')
         end_ptr++; // Increment ptr until a comma is found
      if (*end_ptr == '$') {
         return end_ptr - data_array;
      }
      if (*end_ptr == 10 || *(end_ptr + 1) == 10
            || (*end_ptr == '*' && *(end_ptr - 1) == ',')) { // End reached
         flag = 0;
         break;
      }

      switch (datamember) {
      case LAT:
         memcpy(COORDbuf, start_ptr, (end_ptr - start_ptr));
         if (*COORDbuf) {
            GPS_formatCOORDS(COORDbuf);
            strcpy(InstancePtr->GLLdata.LAT, COORDbuf);
            memset(COORDbuf, 0, sizeof(COORDbuf));
         }

         datamember = NS;
         break;
      case NS:
         if (*start_ptr != ',') {
            InstancePtr->GLLdata.NS = *start_ptr;
            strncat(InstancePtr->GLLdata.LAT, start_ptr, 1);
         }
         datamember = LONG;
         break;
      case LONG:
         memcpy(COORDbuf, start_ptr, (end_ptr - start_ptr));
         if (*COORDbuf) {
            GPS_formatCOORDS(COORDbuf);
            strcpy(InstancePtr->GLLdata.LONG, COORDbuf);\
            memset(COORDbuf, 0, sizeof(COORDbuf));
         }
         datamember = EW;
         break;
      case EW:
         if (*start_ptr != ',') {
            InstancePtr->GLLdata.EW = *start_ptr;
            strncat(InstancePtr->GLLdata.LONG, start_ptr, 1);
         }
         datamember = TIME;
         break;
      case TIME:
         memcpy(InstancePtr->GLLdata.UTC, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GLLdata.UTC[end_ptr - start_ptr] = '\0'; // End null char
         datamember = ACTIVE;
         break;
      case ACTIVE:
         if (*start_ptr != ',')
            InstancePtr->GLLdata.ACTIVE = *start_ptr;
         datamember = MODE;
         break;
      case MODE:
         if (*start_ptr != ',')
            InstancePtr->GLLdata.MODE = *start_ptr;
         flag = 0;
         break;

      }
      end_ptr++; // Increment past the last comma
   }

   // Get checksum
   while (*(end_ptr) != 10)
      end_ptr++;
   checksum[0] = *(end_ptr - 3);
   checksum[1] = *(end_ptr - 2);
   checksum[2] = 0;
   memcpy(InstancePtr->GLLdata.CHECKSUM, checksum, 3);
   return end_ptr - data_array + 1;
}

/* ------------------------------------------------------------ */
/*  GPS_formatGSA()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to store data into
 **       data_array:  an array to the data to be formatted
 **
 **    Return Value:
 **       The offset from the beginning of data_array
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Formats a mode's data into elements in a struct.
 */
int GPS_formatGSA(PmodGPS *InstancePtr, char *data_array) {
   enum cases {
      MODE1,
      MODE2,
      SAT1,
      SAT2,
      SAT3,
      SAT4,
      SAT5,
      SAT6,
      SAT7,
      SAT8,
      SAT9,
      SAT10,
      SAT11,
      SAT12,
      PDOP,
      HDOP,
      VDOP
   };
   enum cases datamember = MODE1;
   char *start_ptr;
   char *end_ptr = data_array + 7; // Set end_ptr after message ID ("$GPGGA,")
   GPS_bool flag = 1;
   char checksum[3] = {0};

   while (flag) {
      start_ptr = end_ptr;

      while (*end_ptr != ',' && (*(end_ptr + 1) != 10) && *end_ptr != '*'
            && *end_ptr != '$')
         end_ptr++; // Increment ptr until a comma is found
      if (*end_ptr == '$') {
         return end_ptr - data_array;
      }
      if (*end_ptr == 10 || *(end_ptr + 1) == 10
            || (*end_ptr == '*' && *(end_ptr - 1) == ',')) { // End reached
         flag = 0;
         break;
      }
      switch (datamember) {
      case MODE1:
         if (*start_ptr != ',')
            InstancePtr->GSAdata.MODE1 = *start_ptr;
         datamember = MODE2;
         break;
      case MODE2:
         if (*start_ptr != ',')
            InstancePtr->GSAdata.MODE2 = *start_ptr;
         datamember = SAT1;
         break;
      case SAT1:
         memcpy(InstancePtr->GSAdata.SAT1, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT1[end_ptr - start_ptr] = '\0'; // End null char
         datamember = SAT2;
         break;
      case SAT2:
         memcpy(InstancePtr->GSAdata.SAT2, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT2[end_ptr - start_ptr] = '\0'; // End null char
         datamember = SAT3;
         break;
      case SAT3:
         memcpy(InstancePtr->GSAdata.SAT3, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT3[end_ptr - start_ptr] = '\0'; // End null char
         datamember = SAT4;
         break;
      case SAT4:
         memcpy(InstancePtr->GSAdata.SAT4, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT4[end_ptr - start_ptr] = '\0'; // End null char
         datamember = SAT5;
         break;
      case SAT5:
         memcpy(InstancePtr->GSAdata.SAT5, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT5[end_ptr - start_ptr] = '\0'; // End null char
         datamember = SAT6;
         break;
      case SAT6:
         memcpy(InstancePtr->GSAdata.SAT6, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT6[end_ptr - start_ptr] = '\0'; // End null char
         datamember = SAT7;
         break;
      case SAT7:
         memcpy(InstancePtr->GSAdata.SAT7, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT7[end_ptr - start_ptr] = '\0'; // End null char
         datamember = SAT8;
         break;
      case SAT8:
         memcpy(InstancePtr->GSAdata.SAT8, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT8[end_ptr - start_ptr] = '\0'; // End null char
         datamember = SAT9;
         break;
      case SAT9:
         memcpy(InstancePtr->GSAdata.SAT9, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT9[end_ptr - start_ptr] = '\0'; // End null char
         datamember = SAT10;
         break;
      case SAT10:
         memcpy(InstancePtr->GSAdata.SAT10, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT10[end_ptr - start_ptr] = '\0';
         datamember = SAT11;
         break;
      case SAT11:
         memcpy(InstancePtr->GSAdata.SAT11, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT11[end_ptr - start_ptr] = '\0';
         datamember = SAT12;
         break;
      case SAT12:
         memcpy(InstancePtr->GSAdata.SAT12, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.SAT12[end_ptr - start_ptr] = '\0';
         datamember = PDOP;
         break;
      case PDOP:
         memcpy(InstancePtr->GSAdata.PDOP, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.PDOP[end_ptr - start_ptr] = '\0';
         datamember = HDOP;
         break;
      case HDOP:
         memcpy(InstancePtr->GSAdata.HDOP, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.HDOP[end_ptr - start_ptr] = '\0';
         datamember = VDOP;
         break;
      case VDOP:
         memcpy(InstancePtr->GSAdata.VDOP, start_ptr, (end_ptr - start_ptr));
         InstancePtr->GSAdata.VDOP[end_ptr - start_ptr] = '\0';
         flag = 0;
         break;
      }
      end_ptr++; //Increment past the last comma

   } // end of while

   // Get checksum
   while (*(end_ptr) != 10)
      end_ptr++;
   checksum[0] = *(end_ptr - 3);
   checksum[1] = *(end_ptr - 2);
   checksum[2] = 0;
   memcpy(InstancePtr->GSAdata.CHECKSUM, checksum, 3);
   return end_ptr - data_array + 1;
}

/* ------------------------------------------------------------ */
/*  GPS_formatGSV()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to store data into
 **       data_array:  an array to the data to be formatted
 **
 **    Return Value:
 **       The offset from the beginning of data_array
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Formats GSV messages into their corresponding structs.
 */
int GPS_formatGSV(PmodGPS *InstancePtr, char *data_array) {
   enum cases {
      NUMM,
      MESNUM,
      SATVIEW,
      SATID1,
      ELV1,
      AZM1,
      SNR1,
      SATID2,
      ELV2,
      AZM2,
      SNR2,
      SATID3,
      ELV3,
      AZM3,
      SNR3,
      SATID4,
      ELV4,
      AZM4,
      SNR4
   };
   enum cases datamember = NUMM;
   char *start_ptr;
   char *end_ptr = data_array + 7; // Set end_ptr after message ID ("$GPGGA,")
   GPS_bool flag = 1;
   char checksum[3] = {0};
   int mesnum = 0;
   char buffer[4];

   while (flag) {
      start_ptr = end_ptr;

      while (*end_ptr != ',' && (*(end_ptr + 1) != 10) && *end_ptr != '*'
            && *end_ptr != '$')
         end_ptr++; // Increment ptr until a comma is found
      if (*end_ptr == '$') {
         return end_ptr - data_array;
      }
      if (*end_ptr == 10 || *(end_ptr + 1) == 10
            || (*end_ptr == '*' && *(end_ptr - 1) == ',')) { // End reached
         flag = 0;
         break;
      }
      switch (datamember) {
      case NUMM:
         if (*start_ptr != ',')
            InstancePtr->GSVdata.NUMM = (int) (*start_ptr - '0');
         datamember = MESNUM;
         break;
      case MESNUM:
         if (*start_ptr != ',') {
            InstancePtr->GSVdata.MESNUM = (int) (*start_ptr - '0');
            mesnum = InstancePtr->GSVdata.MESNUM;
         }
         datamember = SATVIEW;
         break;
      case SATVIEW:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SATVIEW = atoi(buffer);
         datamember = SATID1;
         break;
      case SATID1:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4].ID = atoi(buffer);
         datamember = ELV1;
         break;
      case ELV1:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4].ELV = atoi(buffer);
         datamember = AZM1;
         break;
      case AZM1:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4].AZM = atoi(buffer);
         datamember = SNR1;
         break;
      case SNR1:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4].SNR = atoi(buffer);
         datamember = SATID2;
         break;
      case SATID2:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 1].ID = atoi(buffer);
         datamember = ELV2;
         break;
      case ELV2:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 1].ELV = atoi(buffer);
         datamember = AZM2;
         break;
      case AZM2:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 1].AZM = atoi(buffer);
         datamember = SNR2;
         break;
      case SNR2:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 1].SNR = atoi(buffer);
         datamember = SATID3;
         break;
      case SATID3:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 2].ID = atoi(buffer);
         datamember = ELV3;
         break;
      case ELV3:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 2].ELV = atoi(buffer);
         datamember = AZM3;
         break;
      case AZM3:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 2].AZM = atoi(buffer);
         datamember = SNR3;
         break;
      case SNR3:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 2].SNR = atoi(buffer);
         datamember = SATID4;
         break;
      case SATID4:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 3].ID = atoi(buffer);
         datamember = ELV4;
         break;
      case ELV4:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 3].ELV = atoi(buffer);
         datamember = AZM4;
         break;
      case AZM4:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 3].AZM = atoi(buffer);
         datamember = SNR4;
         break;
      case SNR4:
         memcpy(buffer, start_ptr, (end_ptr - start_ptr));
         buffer[end_ptr - start_ptr] = '\0'; // End null char
         InstancePtr->GSVdata.SAT[(mesnum - 1) * 4 + 3].SNR = atoi(buffer);
         flag = 0;
         break;
      }
      end_ptr++;
   } // end of while

   //Get checksum
   while (*(end_ptr) != 10)
      end_ptr++;
   checksum[0] = *(end_ptr - 3);
   checksum[1] = *(end_ptr - 2);
   checksum[2] = 0;
   memcpy(InstancePtr->GSVdata.CHECKSUM, checksum, 3);
   return end_ptr - data_array + 1;
}

/* ------------------------------------------------------------ */
/*  GPS_formatRMC()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to store data into
 **       data_array:  an array to the data to be formatted
 **
 **    Return Value:
 **       The offset from the beginning of data_array
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Formats a mode's data into elements in a struct.
 */
int GPS_formatRMC(PmodGPS *InstancePtr, char *data_array) {
   enum cases {
      UTC, STAT, LAT, NS, LONG, EW, SOG, COG, DATE, MVAR, MVARDIR, MODE
   };
   enum cases datamember = UTC;
   char *start_ptr;
   char *end_ptr = data_array + 7; // Set end_ptr after message ID ("$GPGGA,")
   GPS_bool flag = 1;
   char checksum[3] = { 0 };

   while (flag) {
      start_ptr = end_ptr;

      while (*end_ptr != ',' && (*(end_ptr + 1) != 10) && *end_ptr != '*'
            && *end_ptr != '$')
         end_ptr++; // Increment ptr until a comma is found
      if (*end_ptr == '$') {
         return end_ptr - data_array;
      }
      if (*end_ptr == 10 || *(end_ptr + 1) == 10
            || (*end_ptr == '*' && *(end_ptr - 1) == ',')) { // End reached
         flag = 0;
         break;
      }
      switch (datamember) {
      case UTC:
         memcpy(InstancePtr->RMCdata.UTC, start_ptr, (end_ptr - start_ptr));
         InstancePtr->RMCdata.UTC[end_ptr - start_ptr] = '\0'; // End null char
         datamember = STAT;
         break;
      case STAT:
         if (*start_ptr != ',')
            InstancePtr->RMCdata.STAT = *start_ptr;
         datamember = LAT;
         break;
      case LAT:
         memcpy(InstancePtr->RMCdata.LAT, start_ptr, (end_ptr - start_ptr));
         InstancePtr->RMCdata.LAT[end_ptr - start_ptr] = '\0'; // End null char
         datamember = NS;
         break;
      case NS:
         if (*start_ptr != ',')
            InstancePtr->RMCdata.NS = *start_ptr;
         datamember = LONG;
         break;
      case LONG:
         memcpy(InstancePtr->RMCdata.LONG, start_ptr, (end_ptr - start_ptr));
         InstancePtr->RMCdata.LONG[end_ptr - start_ptr] = '\0'; // End null char
         datamember = EW;
         break;
      case EW:
         if (*start_ptr != ',')
            InstancePtr->RMCdata.EW = *start_ptr;
         datamember = SOG;
         break;
      case SOG:
         memcpy(InstancePtr->RMCdata.SOG, start_ptr, (end_ptr - start_ptr));
         InstancePtr->RMCdata.SOG[end_ptr - start_ptr] = '\0'; // End null char
         datamember = COG;
         break;
      case COG:
         memcpy(InstancePtr->RMCdata.COG, start_ptr, (end_ptr - start_ptr));
         InstancePtr->RMCdata.COG[end_ptr - start_ptr] = '\0'; // End null char
         datamember = DATE;
         break;
      case DATE:
         memcpy(InstancePtr->RMCdata.DATE, start_ptr, (end_ptr - start_ptr));
         InstancePtr->RMCdata.DATE[end_ptr - start_ptr] = '\0'; // End null char
         datamember = MVAR;
         break;
      case MVAR:
         memcpy(InstancePtr->RMCdata.MVAR, start_ptr, (end_ptr - start_ptr));
         InstancePtr->RMCdata.MVAR[end_ptr - start_ptr] = '\0'; // End null char
         datamember = MVARDIR;
         break;
      case MVARDIR:
         if (*start_ptr != ',')
            InstancePtr->RMCdata.MVARDIR = *start_ptr;
         datamember = MODE;
         break;
      case MODE:
         if (*start_ptr != ',')
            InstancePtr->RMCdata.MODE = *start_ptr;
         flag = 0;
         break;
      }
      end_ptr++;
   } // end of while

   // Get checksum
   while (*(end_ptr) != 10)
      end_ptr++;
   checksum[0] = *(end_ptr - 3);
   checksum[1] = *(end_ptr - 2);
   checksum[2] = 0;
   memcpy(InstancePtr->RMCdata.CHECKSUM, checksum, 3);
   return end_ptr - data_array + 1;
}

/* ------------------------------------------------------------ */
/*  GPS_formatVTG()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to store data into
 **       data_array:  an array to the data to be formatted
 **
 **    Return Value:
 **       The offset from the beginning of data_array
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Formats a mode's data into elements in a struct.
 */
int GPS_formatVTG(PmodGPS *InstancePtr, char *data_array) {
   enum cases {
      COURSE_T,
      REF_T,
      COURSE_M,
      REF_M,
      SPD_N,
      UNIT_N,
      SPD_KM,
      UNIT_KM,
      MODE,
      CHECKSUM
   };
   enum cases datamember = COURSE_T;
   char *start_ptr;
   char *end_ptr = data_array + 7; // Set end_ptr after message ID ("$GPGGA,")
   GPS_bool flag = 1;
   char checksum[3] = { 0 };

   while (flag) {
      start_ptr = end_ptr;

      while (*end_ptr != ',' && (*(end_ptr + 1) != 10) && *end_ptr != '*'
            && *end_ptr != '$')
         end_ptr++; // Increment ptr until a comma is found
      if (*end_ptr == '$') {
         return end_ptr - data_array;
      }
      if (*end_ptr == 10 || *(end_ptr + 1) == 10
            || (*end_ptr == '*' && *(end_ptr - 1) == ',')) { // End reached
         flag = 0;
         break;
      }
      // Choose where to put this data
      switch (datamember) {
      case COURSE_T:
         memcpy(InstancePtr->VTGdata.COURSE_T, start_ptr,
               (end_ptr - start_ptr));
         InstancePtr->VTGdata.COURSE_T[end_ptr - start_ptr] = '\0'; // Null char
         datamember = REF_T;
         break;
      case REF_T:
         if (*start_ptr != ',')
            InstancePtr->VTGdata.REF_T = *start_ptr;
         datamember = COURSE_M;
         break;
      case COURSE_M:
         memcpy(InstancePtr->VTGdata.COURSE_M, start_ptr,
               (end_ptr - start_ptr));
         InstancePtr->VTGdata.COURSE_M[end_ptr - start_ptr] = '\0';
         datamember = REF_M;
         break;
      case REF_M:
         if (*start_ptr != ',')
            InstancePtr->VTGdata.REF_M = *start_ptr;
         datamember = SPD_N;
         break;
      case SPD_N:
         memcpy(InstancePtr->VTGdata.SPD_N, start_ptr, (end_ptr - start_ptr));
         InstancePtr->VTGdata.SPD_N[end_ptr - start_ptr] = '\0';
         datamember = UNIT_N;
         break;
      case UNIT_N:
         if (*start_ptr != ',')
            InstancePtr->VTGdata.UNIT_N = *start_ptr;
         datamember = SPD_KM;
         break;
      case SPD_KM:
         memcpy(InstancePtr->VTGdata.SPD_KM, start_ptr, (end_ptr - start_ptr));
         InstancePtr->VTGdata.SPD_KM[end_ptr - start_ptr] = '\0';
         datamember = UNIT_KM;
         break;
      case UNIT_KM:
         if (*start_ptr != ',')
            InstancePtr->VTGdata.UNIT_KM = *start_ptr;
         datamember = MODE;
         break;
      case MODE:
         if (*start_ptr != ',')
            InstancePtr->VTGdata.MODE = *start_ptr;
         datamember = CHECKSUM;
         flag = 0;
         break;
      case CHECKSUM:
         while (*(end_ptr) != 10)
            end_ptr++;
         checksum[0] = *(end_ptr - 3);
         checksum[1] = *(end_ptr - 2);
         checksum[2] = 0;
         memcpy(InstancePtr->VTGdata.CHECKSUM, checksum, 3);
         return end_ptr - data_array + 1;
         break;
      }
      end_ptr++;
   } // end of while
   return 0;
}

/* ------------------------------------------------------------ */
/*  char *GPS_formatCOORDS()
 **
 **    Parameters:
 **       coords: the un-formatted decimal representation of latitude or
 **               longitude
 **
 **    Return Value:
 **       Correctly formatted coordinates in degrees, minutes, and seconds
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       Formats a set of coordinates of the form XXXX.XXXX or XXXXX.XXXX
 **       into XX[X]°XX'XX.XX"
 */
void GPS_formatCOORDS(char *coords) {
   if (!*coords)
      return;

   char *coordsstart = coords;
   int degmin = atol(strtok(coords, "."));
   int deg = degmin / 100;
   degmin %= 100;
   float sec = atol(strtok(NULL, " \0"));
   sec = sec * 6 / 1000;
   sprintf(coordsstart, "%d°%d'%.1f\"", deg, degmin, sec);

   return;
}

/* ------------------------------------------------------------ */
/*  GPS_intHandler()
 **
 **    Parameters:
 **       InstancePtr: PmodGPS object to get data from
 **       Event:       Describes the UART interrupt type
 **       EventData:   Describes how many bytes were sent/received
 **
 **    Return Value:
 **       none
 **
 **    Errors:
 **       none
 **
 **    Description:
 **       XUartNs550 Interrupt that receives sentences until the last one
 **       is received
 */

void GPS_intHandler(PmodGPS *InstancePtr, u32 Event, unsigned int EventData) {
   if (Event == XUN_EVENT_RECV_DATA) {
      // Start receiving new sentence
      XUartNs550_Recv(&InstancePtr->GPSUart, (u8*) InstancePtr->recv, 600);
   }
   if (Event == XUN_EVENT_RECV_TIMEOUT) { // Triggers every 8 bytes
      if (InstancePtr->recv[EventData - 1] == '\n') { // If end of sentence
         if (GPS_chooseMode(&InstancePtr->recv[EventData - 1])
               == InstancePtr->last_Sentence) { // Check if it is last sentence
            InstancePtr->recv[EventData] = '\0'; // Terminate string
            XUartNs550_Recv(&InstancePtr->GPSUart, (u8*) InstancePtr->recv,
                  600); // Request a new sentence (resets it)
            // Set ping variable for use outside of the interrupt
            InstancePtr->ping = TRUE;
         }
      }
   }
   if (Event == XUN_EVENT_RECV_ERROR) {
      xil_printf("%d error\r\n", EventData);
   }
}
