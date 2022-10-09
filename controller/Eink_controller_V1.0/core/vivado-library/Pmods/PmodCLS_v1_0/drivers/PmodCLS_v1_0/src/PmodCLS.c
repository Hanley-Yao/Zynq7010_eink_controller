/******************************************************************************/
/*                                                                            */
/* PmodCLS.c -- PmodCLS Example Projects                                      */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen                                                       */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains code for running a demonstration of the PmodCLS when    */
/* used with the PmodCLS IP core.                                             */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/15/2016(MikelSkreen): Created                                        */
/*    08/17/2017(jPeyron):     Updated                                        */
/*    11/03/2017(artvvb):      2016.4 Maintenance                             */
/*    02/12/2018(atangzwj):    Validated for Vivado 2017.4                    */
/*                                                                            */
/******************************************************************************/


/***************************** Include Files ****************************/

#include "PmodCLS.h"


/************************** Function Definitions ************************/
XSpi_Config CLSConfig =
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

/* --------------------------------------------------------------------*/
/** CLS_DisplayMode
**
**  Parameters:
**     charNumber - parameter for selecting the wrapping type of the line: to 16
**                  or 40 characters
**
**  Return Value:
**     None
**
**  Errors:
**     None
**
**  Description:
**     This function wraps the line at 16 or 40 characters
-----------------------------------------------------------------------*/
void CLS_DisplayMode(PmodCLS *InstancePtr, uint8_t charNumber) {
   uint8_t dispMode16[] = {CLS_ESC, CLS_BRACKET, '0', CLS_DISP_MODE_CMD};
   uint8_t dispMode40[] = {CLS_ESC, CLS_BRACKET, '1', CLS_DISP_MODE_CMD};
   if (charNumber == 1) {
      CLS_WriteSpi(InstancePtr, dispMode16, 4); // Wrap line at 16 characters
   } else {
      CLS_WriteSpi(InstancePtr, dispMode40, 4); // Wrap line at 40 characters
   }
}

/* --------------------------------------------------------------------*/
/** CLS_CursorModeSet
**
**  Parameters:
**     setCursor - boolean parameter through which the cursor is set on or off
**     setBlink  - boolean parameter through which the blink option is set on or
**                 off
**
**  Return Value:
**     None
**
**  Errors:
**     None
**
**  Description:
**     This function turns the cursor and the blinking option on or off,
**     according to the user's selection.
-----------------------------------------------------------------------*/
void CLS_CursorModeSet(PmodCLS *InstancePtr, uint8_t setCursor,
      uint8_t setBlink) {
   uint8_t cursorOff[] = {CLS_ESC, CLS_BRACKET, '0', CLS_CURSOR_MODE_CMD};
   uint8_t cursorOnBlinkOff[] =
         {CLS_ESC, CLS_BRACKET, '1', CLS_CURSOR_MODE_CMD};
   uint8_t cursorBlinkOn[] = {CLS_ESC, CLS_BRACKET, '2', CLS_CURSOR_MODE_CMD};
   if (setCursor == 0) {
      // Send the command for both display and blink off
      CLS_WriteSpi(InstancePtr, cursorOff, 4);
   } else if ((setCursor == 1) && (setBlink == 0)) {
      // Send the command for display on and blink off
      CLS_WriteSpi(InstancePtr, cursorOnBlinkOff, 4);
   } else {
      // Send the command for display and blink on
      CLS_WriteSpi(InstancePtr, cursorBlinkOn, 4);
   }
}

/* ------------------------------------------------------------------- */
/** CLS_DisplayClear
**
**  Parameters:
**     None
**
**  Return Value:
**     None
**
**  Errors:
**     None
**
**  Description:
**     This function clears the display and returns the cursor home
-----------------------------------------------------------------------*/
void CLS_DisplayClear(PmodCLS *InstancePtr) {
   u8 dispClr[] = {CLS_ESC, CLS_BRACKET, '0', CLS_DISP_CLR_CMD};
   // Clear the display and returns the cursor home
   CLS_WriteSpi(InstancePtr, dispClr, 4);
}

/*---------------------------------------------------------------------*/
/** void CLS_begin(PmodCLS *InstancePtr, u32 SPI_Address)
**
**  Parameters:
**     InstancePtr: A PmodCLS object to start
**     SPI_Address: The Base address of the PmodCLS SPI
**
**  Return Value:
**     None
**
**  Errors:
**     None
**
**  Description:
**     Initialize the PmodCLS.
-----------------------------------------------------------------------*/
void CLS_begin(PmodCLS *InstancePtr, u32 SPI_Address) {
   CLSConfig.BaseAddress = SPI_Address;
   CLS_SPIInit(&InstancePtr->CLSSpi);
}

/*---------------------------------------------------------------------*/
/** CLS_end(void)
**
**  Parameters:
**     InstancePtr - PmodCLS object to stop
**
**  Return Value:
**     None
**
**  Errors:
**     None
**
**  Description:
**     Stops the device
-----------------------------------------------------------------------*/
void CLS_end(PmodCLS *InstancePtr) {
   XSpi_Stop(&InstancePtr->CLSSpi);
}

/*---------------------------------------------------------------------*/
/** CLS_SPIInit
**
**  Parameters:
**     InstancePtr - the PmodCLS object to communicate with
**
**  Return Value:
**     None
**
**  Errors:
**     None
**
**  Description:
**     Initializes the PmodCLS SPI.
-----------------------------------------------------------------------*/
int CLS_SPIInit(XSpi *SpiInstancePtr) {
   int Status;

   Status = XSpi_CfgInitialize(SpiInstancePtr, &CLSConfig,
         CLSConfig.BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   u32 options = XSP_MASTER_OPTION | XSP_MANUAL_SSELECT_OPTION;
   Status = XSpi_SetOptions(SpiInstancePtr, options);
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
/** CLS_Readbyte
**
**  Parameters:
**     InstancePtr - the PmodCLS object to communicate with
**
**  Return Value:
**     byte - Byte read from XSpi
**
**  Errors:
**     None
**
**  Description:
**     Reads a single byte over SPI
-----------------------------------------------------------------------*/
u8 CLS_ReadByte(PmodCLS *InstancePtr) {
   u8 byte;
   XSpi_Transfer(&InstancePtr->CLSSpi, &byte, &byte, 1);
   return byte;
}

/* ------------------------------------------------------------ */
/** CLS_WriteByte
**
**  Parameters:
**     InstancePtr - PmodCLS object to send to
**     cmd         - Command to send
**
**  Return Value:
**     None
**
**  Errors:
**     None
**
**  Description:
**     Writes a single byte over SPI
 -----------------------------------------------------------------------*/
void CLS_WriteByte(PmodCLS *InstancePtr, u8 cmd) {
   XSpi_Transfer(&InstancePtr->CLSSpi, &cmd, NULL, 1);
}

/* ------------------------------------------------------------ */
/** CLS_WriteSpi
**
**  Parameters:
**     PmodCLS *InstancePtr - the PmodCLS object to communicate with
**     u8 reg               - the starting register to write to
**     u8 *wData            - the data to write
**     int nData            - the number of data bytes to write
**
**  Return Value:
**     None
**
**  Errors:
**     None
**
**  Description:
**     Writes the byte array to the chip via SPI.
-----------------------------------------------------------------------*/
void CLS_WriteSpi(PmodCLS *InstancePtr, u8 *wData, int nData) {
   XSpi_Transfer(&InstancePtr->CLSSpi, wData, 0, nData);
}

/* --------------------------------------------------------------------*/
/** uint8_t  CLS_WriteStringAtPos
**
**  Parameters:
**     idxLine - the line where the string is written: 0 or 1
**     idxPos  - the start column for the string to be written:0 to 39
**     strLn   - the string to be written
**
**  Return Value:
**     u8 - CLS_LCDS_ERR_SUCCESS - The action completed successfully
**        - a combination of the following errors(OR-ed):
**        - CLS_LCDS_ERR_ARG_COL_RANGE - The argument is not within 0, 39 range
**        - CLS_LCDS_ERR_ARG_ROW_RANGE - The argument is not within 0, 2 range
**
**  Errors:
**     see returned values
**
**  Description:
**     This function writes a string at a specified position
**
-----------------------------------------------------------------------*/
u8 CLS_WriteStringAtPos(PmodCLS *InstancePtr, uint8_t idxRow, uint8_t idxCol,
      char *strLn) {

   uint8_t bResult = CLS_LCDS_ERR_SUCCESS;
   if (idxRow > 2) {
      bResult |= CLS_LCDS_ERR_ARG_ROW_RANGE;
   }
   if (idxCol > 39) {
      bResult |= CLS_LCDS_ERR_ARG_COL_RANGE;
   }
   if (bResult == CLS_LCDS_ERR_SUCCESS) {
      // Separate the position digits in order to send them, useful when the
      // position is greater than 10
      uint8_t firstDigit = idxCol % 10;
      uint8_t secondDigit = idxCol / 10;
      uint8_t length = strlen(strLn);
      uint8_t lengthToPrint = length + idxCol;
      uint8_t stringToSend[] = { CLS_ESC, CLS_BRACKET, idxRow + '0', ';',
            secondDigit + '0', firstDigit + '0', CLS_CURSOR_POS_CMD };
      if (lengthToPrint > 40) {
         // Truncate the length of the string
         // If it's greater than the positions number of a line
         length = 40 - idxCol;
      }
      CLS_WriteSpi(InstancePtr, (u8*) stringToSend, 7);
      CLS_WriteSpi(InstancePtr, (u8*) strLn, length);
   }
   return bResult;
}


/*---------------------------------------------------------------------*/
/** CLS_ReadSpi
**
**  Synopsis:
**     CLS_ReadSpi(&CLSobj, 0x3A, &bytearray, 5);
**
**  Parameters:
**     PmodCLS *InstancePtr - the PmodCLS object to communicate with
**     u8 reg               - the starting register to read from
**     u8 *rData            - the byte array to read into
**     int nData            - the number of data bytes to read
**
**  Return Value:
**     None
**
**  Errors:
**     None
**
**  Description:
**     Reads data in through SPI. Data is stored into rData.
-----------------------------------------------------------------------*/
void CLS_ReadSpi(PmodCLS *InstancePtr, u8 *rData, int nData) {
   u8 bytearray[nData];

   XSpi_Transfer(&InstancePtr->CLSSpi, bytearray, bytearray, nData);
   memcpy(rData, &bytearray[0], nData);
}
