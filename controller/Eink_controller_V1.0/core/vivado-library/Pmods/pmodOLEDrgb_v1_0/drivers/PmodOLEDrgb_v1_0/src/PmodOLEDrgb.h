/******************************************************************************/
/*                                                                            */
/* PmodOLEDrgb.h -- Interface Declarations for PmodOLEDrgb.c                  */
/*                                                                            */
/******************************************************************************/
/* Author: Cristian Fatu, Thomas Kappenman                                    */
/* Copyright 2015, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This header file contains the object class declarations and other          */
/* interface declarations need to use the PmodOLEDrgb display on any          */
/* MicroBlaze/Zynq design                                                     */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    07/20/2015(CristianF): created                                          */
/*    04/19/2015(TommyK):    Adapted for use with Microblaze/Zynq .c designs  */
/*    08/25/2017(artvvb):    added OLEDrgb_sleep                              */
/*    11/11/2017(atangzwj):  Validated for Vivado 2016.4                      */
/*    02/17/2018(atangzwj):  Validated for Vivado 2017.4                      */
/*                                                                            */
/******************************************************************************/

#ifndef PMODOLEDRGB_H
#define PMODOLEDRGB_H

/************ Include Files ************/

#include "xil_types.h"
#include "xspi.h"
#include "xspi_l.h"
#include "xstatus.h"


/************ Macro Definitions ************/

#define OLEDRGB_WIDTH  96
#define OLEDRGB_HEIGHT 64

#define OLEDRGB_CHARBYTES    8    // Number of bytes in a glyph
#define	OLEDRGB_USERCHAR_MAX 0x20 // Number of character defs in user font
                                    // table
#define OLEDRGB_CHARBYTES_USER (OLEDRGB_USERCHAR_MAX*OLEDRGB_CHARBYTES)
                               // Number of bytes in user font table

#define CMD_DRAWLINE                 0x21
#define CMD_DRAWRECTANGLE            0x22
#define CMD_COPYWINDOW               0x23
#define CMD_DIMWINDOW                0x24
#define CMD_CLEARWINDOW              0x25
#define CMD_FILLWINDOW               0x26
#define DISABLE_FILL                 0x00
#define ENABLE_FILL                  0x01
#define CMD_CONTINUOUSSCROLLINGSETUP 0x27
#define CMD_DEACTIVESCROLLING        0x2E
#define CMD_ACTIVESCROLLING          0x2F

#define CMD_SETCOLUMNADDRESS           0x15
#define CMD_SETROWADDRESS              0x75
#define CMD_SETCONTRASTA               0x81
#define CMD_SETCONTRASTB               0x82
#define CMD_SETCONTRASTC               0x83
#define CMD_MASTERCURRENTCONTROL       0x87
#define CMD_SETPRECHARGESPEEDA         0x8A
#define CMD_SETPRECHARGESPEEDB         0x8B
#define CMD_SETPRECHARGESPEEDC         0x8C
#define CMD_SETREMAP                   0xA0
#define CMD_SETDISPLAYSTARTLINE        0xA1
#define CMD_SETDISPLAYOFFSET           0xA2
#define CMD_NORMALDISPLAY              0xA4
#define CMD_ENTIREDISPLAYON            0xA5
#define CMD_ENTIREDISPLAYOFF           0xA6
#define CMD_INVERSEDISPLAY             0xA7
#define CMD_SETMULTIPLEXRATIO          0xA8
#define CMD_DIMMODESETTING             0xAB
#define CMD_SETMASTERCONFIGURE         0xAD
#define CMD_DIMMODEDISPLAYON           0xAC
#define CMD_DISPLAYOFF                 0xAE
#define CMD_DISPLAYON                  0xAF
#define CMD_POWERSAVEMODE              0xB0
#define CMD_PHASEPERIODADJUSTMENT      0xB1
#define CMD_DISPLAYCLOCKDIV            0xB3
#define CMD_SETGRAySCALETABLE          0xB8
#define CMD_ENABLELINEARGRAYSCALETABLE 0xB9
#define CMD_SETPRECHARGEVOLTAGE        0xBB
#define CMD_SETVVOLTAGE                0xBE

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a PMODOLEDRGB register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the PMODOLEDRGBdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void PMODOLEDRGB_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define PMODOLEDRGB_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a PMODOLEDRGB register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the PMODOLEDRGB device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 PMODOLEDRGB_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define PMODOLEDRGB_mReadReg(BaseAddress, RegOffset) \
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
 * @param   baseaddr_p is the base address of the PMODOLEDRGB instance to be
 *          worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus
 *
 */
XStatus PMODOLEDRGB_Reg_SelfTest(void *baseaddr_p);


/************ Type Definitions ************/

typedef struct {
   u32 GPIO_addr;
   XSpi OLEDSpi;

   u8 *pbOledrgbFontCur;
   u8 *pbOledrgbFontUser;
   u8 rgbOledrgbFontUser[OLEDRGB_CHARBYTES_USER];
   int dxcoOledrgbFontCur;
   int dycoOledrgbFontCur;
   uint16_t m_FontColor, m_FontBkColor;
   int xchOledCur;
   int ychOledCur;

   int xchOledrgbMax;
   int ychOledrgbMax;
} PmodOLEDrgb;


/************ Function Prototypes ************/

void OLEDrgb_begin(PmodOLEDrgb *InstancePtr, u32 GPIO_Address, u32 SPI_Address);
void OLEDrgb_end(PmodOLEDrgb *InstancePtr);

void OLEDrgb_DrawPixel(PmodOLEDrgb *InstancePtr, u8 c, u8 r,
      uint16_t pixelColor);
void OLEDrgb_DrawLine(PmodOLEDrgb *InstancePtr, u8 c1, u8 r1, u8 c2, u8 r2,
      uint16_t lineColor);
void OLEDrgb_DrawRectangle(PmodOLEDrgb *InstancePtr, u8 c1, u8 r1, u8 c2, u8 r2,
      uint16_t lineColor, u8 bFill, uint16_t fillColor);
void OLEDrgb_Clear(PmodOLEDrgb *InstancePtr);
void OLEDrgb_DrawBitmap(PmodOLEDrgb *InstancePtr, u8 c1, u8 r1, u8 c2, u8 r2,
      u8 *pBmp);

void OLEDrgb_SetCursor(PmodOLEDrgb *InstancePtr, int xch, int ych);
void OLEDrgb_GetCursor(PmodOLEDrgb *InstancePtr, int *pxch, int *pych);
int OLEDrgb_DefUserChar(PmodOLEDrgb *InstancePtr, char ch, u8 *pbDef);
void OLEDrgb_DrawGlyph(PmodOLEDrgb *InstancePtr, char ch);
void OLEDrgb_PutChar(PmodOLEDrgb *InstancePtr, char ch);
void OLEDrgb_PutString(PmodOLEDrgb *InstancePtr, char *sz);
void OLEDrgb_SetFontColor(PmodOLEDrgb *InstancePtr, uint16_t fontColor);
void OLEDrgb_SetFontBkColor(PmodOLEDrgb *InstancePtr, uint16_t fontBkColor);
void OLEDrgb_SetCurrentFontTable(PmodOLEDrgb *InstancePtr, u8 *pbFont);
void OLEDrgb_SetCurrentUserFontTable(PmodOLEDrgb *InstancePtr, u8 *pbUserFont);
void OLEDrgb_AdvanceCursor(PmodOLEDrgb *InstancePtr);
void OLEDrgb_SetScrolling(PmodOLEDrgb *InstancePtr, u8 scrollH, u8 scrollV,
      u8 rowAddr, u8 rowNum, u8 timeInterval);
void OLEDrgb_EnableScrolling(PmodOLEDrgb *InstancePtr, u8 fEnable);
void OLEDrgb_EnablePmod(PmodOLEDrgb *InstancePtr, u8 fEnable);
void OLEDrgb_EnableBackLight(PmodOLEDrgb *InstancePtr, u8 fEnable);
void OLEDrgb_Copy(PmodOLEDrgb *InstancePtr, u8 c1, u8 r1, u8 c2, u8 r2, u8 c3,
      u8 r3);
void OLEDrgb_Dim(PmodOLEDrgb *InstancePtr, u8 c1, u8 r1, u8 c2, u8 r2);
void OLEDrgb_HostInit(PmodOLEDrgb *InstancePtr);
void OLEDrgb_HostTerm(PmodOLEDrgb *InstancePtr);
void OLEDrgb_DevInit(PmodOLEDrgb *InstancePtr);
void OLEDrgb_DevTerm(PmodOLEDrgb *InstancePtr);

int OLEDrgb_SPIInit(XSpi *SpiInstancePtr);
void OLEDrgb_WriteSPICommand(PmodOLEDrgb *InstancePtr, u8 cmd);
void OLEDrgb_WriteSPI(PmodOLEDrgb *InstancePtr, u8 *pCmd, int nCmd, u8 *pData,
      int nData);
uint16_t OLEDrgb_BuildHSV(u8 hue, u8 sat, u8 val);
uint16_t OLEDrgb_BuildRGB(u8 R, u8 G, u8 B);

u8 OLEDrgb_ExtractRFromRGB(uint16_t wRGB);
u8 OLEDrgb_ExtractGFromRGB(uint16_t wRGB);
u8 OLEDrgb_ExtractBFromRGB(uint16_t wRGB);

#endif // PMODOLEDRGB_H
