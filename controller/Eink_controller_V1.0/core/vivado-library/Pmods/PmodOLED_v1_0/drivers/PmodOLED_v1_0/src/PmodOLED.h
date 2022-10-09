/******************************************************************************/
/*                                                                            */
/* PmodOLED.h -- Header for PmodOLED IP Drivers and Library                   */
/*                                                                            */
/******************************************************************************/
/* Author: Thomas Kappenman                                                   */
/* Copyright 2015, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* Contains drivers and library functions for use with a PmodOLED             */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    04/19/2016(TommyK):   Created                                           */
/*    06/30/2016(ArtVVB):   Updated for PmodOLED IP Drivers                   */
/*    12/15/2016(jPeyron):  Edited for better use for OnboardOLED in as well  */
/*                          as inverting the white and black                  */
/*    08/25/2017(ArtVVB):   Validated for Vivado 2015.4                       */
/*    02/17/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PmodOLED_H
#define PmodOLED_H

/****************** Include Files ********************/

#include "xil_types.h"
#include "xstatus.h"
#include "xspi_l.h"
#include "xspi.h"

/* ------------------------------------------------------------ */
/*                  Definitions                                 */
/* ------------------------------------------------------------ */

#define OledColMax  128 // Number of columns in the display
#define OledRowMax  32  // Number of rows in the display
#define OledPageMax 4   // Number of display pages
#define OledModeSet 0   // Set pixel drawing mode
#define OledModeOr  1   // or pixels drawing mode
#define OledModeAnd 2   // and pixels drawing mode
#define OledModeXor 3   // xor pixels drawing mode

#define cbOledDispMax 512 // Max number of bytes in display buffer

#define ccolOledMax 128 // Number of display columns
#define crowOledMax 32  // Number of display rows
#define cpagOledMax 4   // Number of display memory pages

#define cbOledChar     8    // Font glyph definitions is 8 bytes long
#define chOledUserMax  0x20 // Number of character defs in user font table
#define cbOledFontUser (chOledUserMax*cbOledChar)

/* Graphics drawing modes.
*/
#define modOledSet 0
#define modOledOr  1
#define modOledAnd 2
#define modOledXor 3

typedef struct OLED {
   u8 rgbOledBmp[cbOledDispMax];

   /* Coordinates of current pixel location on the display. The origin is at the
   ** upper left of the display. X increases to the right and Y increases going
   ** down.
   */
   int xcoOledCur;
   int ycoOledCur;

   u8 *pbOledCur;    // Address of byte corresponding to current location
   int bnOledCur;    // Bit number of bit corresponding to current location
   u8 clrOledCur;    // Drawing color to use
   u8 *pbOledPatCur; // Current fill pattern
   int fOledCharUpdate;

   int dxcoOledFontCur;
   int dycoOledFontCur;

   u8 *pbOledFontCur;
   u8 *pbOledFontUser;

   u8 (*pfnDoRop)(u8 bPix, u8 bDsp, u8 mskPix);
   int modOledCur;

   int xchOledCur;
   int ychOledCur;

   int xchOledMax;
   int ychOledMax;

   u8 *pbOledFontExt;

   u8 rgbOledFontUser[cbOledFontUser];
} OLED;

typedef struct PmodOLED {
   u32 GPIO_addr;
   XSpi OLEDSpi;
   OLED OLEDState;
} PmodOLED;

extern XSpi_Config OLEDConfig;

void OLED_Begin              (PmodOLED *InstancePtr, u32 GPIO_Address, u32 SPI_Address, u8 orientation, u8 invert);
void OLED_End                (PmodOLED *InstancePtr);
int  OLED_SPIInit            (XSpi *SPIInstancePtr);
u8   OLED_ReadByte           (PmodOLED *InstancePtr);
void OLED_WriteByte          (PmodOLED *InstancePtr, u8 cmd);
void OLED_WriteSPI           (PmodOLED *InstancePtr, u8 reg, u8 *wData, int nData);
void OLED_ReadSPI            (PmodOLED *InstancePtr, u8 reg, u8 *rData, int nData);
void OLED_SetRegisterBits    (PmodOLED *InstancePtr, u8 reg, u8 mask, u8 fValue);
u8   OLED_GetRegisterBits    (PmodOLED *InstancePtr, u8 bRegisterAddress, u8 bMask);
void OLED_SetGPIOBits        (PmodOLED *InstancePtr, u8 mask, u8 fValue);
void OLED_SetGPIOTristateBits(PmodOLED *InstancePtr, u8 mask, u8 fValue);

/* ------------------------------------------------------------ */
/*                  OLED Driver Procedure Declarations          */
/* ------------------------------------------------------------ */

void OLED_ClearBuffer(PmodOLED *InstancePtr);
void OLED_Init       (PmodOLED *InstancePtr, u32 GPIO_Address, u32 SPI_Address,
                           u8 orientation, u8 invert);
void OLED_Term       (PmodOLED *InstancePtr);
void OLED_DisplayOn  (PmodOLED *InstancePtr);
void OLED_DisplayOff (PmodOLED *InstancePtr);
void OLED_Clear      (PmodOLED *InstancePtr);
void OLED_Update     (PmodOLED *InstancePtr);

/* ------------------------------------------------------------ */
/*                  OLED Graph Procedure Declarations           */
/* ------------------------------------------------------------ */

void OLED_SetDrawColor  (PmodOLED *InstancePtr, u8 clr);
void OLED_SetDrawMode   (PmodOLED *InstancePtr, int mod);
int  OLED_GetDrawMode   (PmodOLED *InstancePtr);
u8  *OLED_GetStdPattern (int ipat);
void OLED_SetFillPattern(PmodOLED *InstancePtr, u8 *pbPat);

void OLED_MoveTo        (PmodOLED *InstancePtr, int xco, int yco);
void OLED_GetPos        (PmodOLED *InstancePtr, int *pxco, int *pyco);
void OLED_DrawPixel     (PmodOLED *InstancePtr);
u8   OLED_GetPixel      (PmodOLED *InstancePtr);
void OLED_LineTo        (PmodOLED *InstancePtr, int xco, int yco);
void OLED_DrawRect      (PmodOLED *InstancePtr, int xco, int yco);
void OLED_FillRect      (PmodOLED *InstancePtr, int xco, int yco);
void OLED_GetBmp        (PmodOLED *InstancePtr, int dxco, int dyco, u8 *pbBmp);
void OLED_PutBmp        (PmodOLED *InstancePtr, int dxco, int dyco, u8 *pbBmp);
void OLED_DrawChar      (PmodOLED *InstancePtr, char ch);
void OLED_DrawString    (PmodOLED *InstancePtr, char *sz);

/* ------------------------------------------------------------ */
/*                  OLED Char Procedure Declarations            */
/* ------------------------------------------------------------ */

void OLED_SetCursor    (PmodOLED *InstancePtr, int xch, int ych);
void OLED_GetCursor    (PmodOLED *InstancePtr, int *pxcy, int *pych);
int  OLED_DefUserChar  (PmodOLED *InstancePtr, char ch, u8 *pbDef);
void OLED_SetCharUpdate(PmodOLED *InstancePtr, int f);
int  OLED_GetCharUpdate(PmodOLED *InstancePtr);
void OLED_PutChar      (PmodOLED *InstancePtr, char ch);
void OLED_PutString    (PmodOLED *InstancePtr, char *sz);

#endif // PmodOLED_H
