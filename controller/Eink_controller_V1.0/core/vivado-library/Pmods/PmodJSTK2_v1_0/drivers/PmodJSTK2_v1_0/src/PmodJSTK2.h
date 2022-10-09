/******************************************************************************/
/*                                                                            */
/* PmodJSTK2.c -- Driver definitions for the PmodJSTK2                        */
/*                                                                            */
/******************************************************************************/
/* Author: Samuel Lowe`                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodJSTK2 IP from Digilent          */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*   06/01/2016(SamL):     Created                                            */
/*   08/10/2017(ArtVVB):   Validated for Vivado 2015.4                        */
/*   11/02/2017(atangzwj): Validated for Vivado 2016.4                        */
/*   01/24/2018(atangzwj): Validated for Vivado 2017.4                        */
/*                                                                            */
/******************************************************************************/

#ifndef PMODJSTK2_H
#define PMODJSTK2_H

/************ Include Files ************/

#include "xil_types.h"
#include "xstatus.h"
#include "xspi_l.h"
#include "xspi.h"


/************ Macro Definitions ************/

// Define PmodJSTK2 SPI commands
#define JSTK2_mskCmd              0xFC

#define JSTK2_cmdGetRaw           0x00

#define JSTK2_cmdSetLed           0x80
#define JSTK2_cmdSetLedOn         (cmdSetLed | 0x01)
#define JSTK2_cmdSetLedOff        (cmdSetLed)

#define JSTK2_cmdSetLedRGB        0x84

#define JSTK2_cmdSetInversion     0x88
#define JSTK2_cmdSetInversionX    (JSTK2_cmdSetInversion | 0x02)
#define JSTK2_cmdSetInversionY    (JSTK2_cmdSetInversion | 0x01)
#define JSTK2_cmdSetInversionOff  (cmdSetInversion)

#define JSTK2_cmdGetPosition      0xC0

#define JSTK2_cmdGetStatus        0xF0
#define JSTK2_cmdGetFirmwareVer   0xF1

#define JSTK2_cmdGetCalXMin       0xE0
#define JSTK2_cmdGetCalXMax       0xE1
#define JSTK2_cmdGetCalYMin       0xE2
#define JSTK2_cmdGetCalYMax       0xE3
#define JSTK2_cmdGetCalXCenMin    0xE4
#define JSTK2_cmdGetCalXCenMax    0xE5
#define JSTK2_cmdGetCalYCenMin    0xE6
#define JSTK2_cmdGetCalYCenMax    0xE7

#define JSTK2_cmdCalibrate        0xA4

#define JSTK2_cmdSetCalXMin       0xA8
#define JSTK2_cmdSetCalXMax       0xA9
#define JSTK2_cmdSetCalYMin       0xAA
#define JSTK2_cmdSetCalYMax       0xAB
#define JSTK2_cmdSetCalXCenMin    0xAC
#define JSTK2_cmdSetCalXCenMax    0xAD
#define JSTK2_cmdSetCalYCenMin    0xAE
#define JSTK2_cmdSetCalYCenMax    0xAF
#define JSTK2_cmdSetCalXMinMax    0xB0
#define JSTK2_cmdSetCalYMinMax    0xB1
#define JSTK2_cmdSetCalXCenMinMax 0xB2
#define JSTK2_cmdSetCalYCenMinMax 0xB3

#define JSTK2_cmdWriteFlash       0xB8
#define JSTK2_cmdRldFromFlash     0xBC

#define JSTK2_cbSndMax            16

/* Bit mask definitions */

// Define the bit positions used in a status packet.
#define JSTK2_bnCalibrating  7
#define JSTK2_bnLastCal      6
#define JSTK2_bnLastFWS      5
#define JSTK2_bnLastFRS      4
#define JSTK2_bnInvertX      1
#define JSTK2_bnInvertY      0

#define JSTK2_bitCalibrating (1 << JSTK2_bnCalibrating)
#define JSTK2_bitLastCal     (1 << JSTK2_bnLastCal)
#define JSTK2_bitLastFWS     (1 << JSTK2_bnLastFWS)
#define JSTK2_bitLastFRS     (1 << JSTK2_bnLastFRS)
#define JSTK2_bitInvertX     (1 << JSTK2_bnInvertX)
#define JSTK2_bitInvertY     (1 << JSTK2_bnInvertY)

// Define bit positions used in fsButtons.
#define JSTK2_bnExtpkt       7
#define JSTK2_bnTrigger      1
#define JSTK2_bnJstk         0

#define JSTK2_bitExtpkt      (1 << JSTK2_bnExtpkt)
#define JSTK2_bitTrigger     (1 << JSTK2_bnTrigger)
#define JSTK2_bitJstk        (1 << JSTK2_bnJstk)


/************ Type Definitions ************/

// Device Definition
typedef struct PmodJSTK2 {
   XSpi SpiDevice;
   u32 GpioAddr;
} PmodJSTK2;

// Data Type
typedef struct JSTK2_DataPacket {
   u16 XData;
   u16 YData;
   u8 Jstk;
   u8 Trigger;
} JSTK2_DataPacket;

typedef struct JSTK2_Position {
   u8 XData;
   u8 YData;
} JSTK2_Position;


/************ Function Prototypes ************/

void JSTK2_begin(PmodJSTK2* InstancePtr, u32 SPI_Address, u32 GPIO_Address);
void JSTK2_end(PmodJSTK2* InstancePtr);
int JSTK2_SPIInit(XSpi* SpiInstancePtr);

void JSTK2_setLedRGB(PmodJSTK2* InstancePtr, u8 red, u8 blue, u8 green);

u8 JSTK2_getBtns(PmodJSTK2* InstancePtr);
u8 JSTK2_getX(PmodJSTK2* InstancePtr);
u8 JSTK2_getY(PmodJSTK2* InstancePtr);

JSTK2_DataPacket JSTK2_getDataPacket(PmodJSTK2* InstancePtr);
JSTK2_Position JSTK2_getPosition(PmodJSTK2* InstancePtr);

u8 JSTK2_getStatus(PmodJSTK2* InstancePtr);

void JSTK2_setInversion(PmodJSTK2* InstancePtr, u8 invX, u8 invY);

void JSTK2_startFlashReload(PmodJSTK2* InstancePtr);
void JSTK2_startFlashWrite(PmodJSTK2* InstancePtr);

// Calibration functions
void JSTK2_startCalibration(PmodJSTK2* InstancePtr);

u16 JSTK2_getCalXMin(PmodJSTK2* InstancePtr);
u16 JSTK2_getCalXMax(PmodJSTK2* InstancePtr);
u16 JSTK2_getCalYMin(PmodJSTK2* InstancePtr);
u16 JSTK2_getCalYMax(PmodJSTK2* InstancePtr);
u16 JSTK2_getCalXCenMin(PmodJSTK2* InstancePtr);
u16 JSTK2_getCalXCenMax(PmodJSTK2* InstancePtr);
u16 JSTK2_getCalYCenMin(PmodJSTK2* InstancePtr);
u16 JSTK2_getCalYCenMax(PmodJSTK2* InstancePtr);

void JSTK2_setCalXMin(PmodJSTK2* InstancePtr, u16 XMinCal);
void JSTK2_setCalXMax(PmodJSTK2* InstancePtr, u16 XMaxCal);
void JSTK2_setCalYMin(PmodJSTK2* InstancePtr, u16 YMinCal);
void JSTK2_setCalYMax(PmodJSTK2* InstancePtr, u16 YMaxCal);
void JSTK2_setCalXCenMin(PmodJSTK2* InstancePtr, u16 XCenMinCal);
void JSTK2_setCalXCenMax(PmodJSTK2* InstancePtr, u16 XCenMaxCal);
void JSTK2_setCalYCenMin(PmodJSTK2* InstancePtr, u16 YCenMinCal);
void JSTK2_setCalYCenMax(PmodJSTK2* InstancePtr, u16 YCenMaxCal);
void JSTK2_setCalXMinMax(PmodJSTK2* InstancePtr, u16 XMinCal, u16 XMaxCal);
void JSTK2_setCalYMinMax(PmodJSTK2* InstancePtr, u16 YMinCal, u16 YMaxCal);
void JSTK2_setCalXCenMinMax(PmodJSTK2* InstancePtr, u16 XCenMinCal,
      u16 XCenMaxCal);
void JSTK2_setCalYCenMinMax(PmodJSTK2* InstancePtr, u16 YCenMinCal,
      u16 YCenMaxCal);

// Utility functions
void JSTK2_getData(PmodJSTK2* InstancePtr, u8* recv, u8 nData);
void JSTK2_delay(PmodJSTK2* InstancePtr, int micros);

#endif // PMODJSTK2_H
