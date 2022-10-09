/******************************************************************************/
/*                                                                            */
/* PmodCOLOR.h -- Driver definitions for the PmodCOLOR                        */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodCOLOR IP from Digilent          */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    10/10/2017(artvvb):   Created                                           */
/*    11/08/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    02/03/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODCOLOR_H
#define PMODCOLOR_H

/****************************** Include Files *********************************/

#include "xiic.h"
#include "xiic_l.h"
#include "xil_types.h"
#include "xstatus.h"

/**************************** Type Definitions ********************************/

typedef struct PmodCOLOR {
   XIic Iic;
   u32 GpioBaseAddr;
   u8 ChipAddr;
   u8 CurrentReg;
} PmodCOLOR;

typedef struct {
   u16 r, g, b, c;
} COLOR_Data;

/************************** Register Definitions ******************************/

typedef enum {
   COLOR_RegENABLE  = 0x00, // Enables states and interrupts
   COLOR_RegATIME,          // RGBC time
   COLOR_RegWTIME   = 0x03, // Wait time
   COLOR_RegAILTL,          // Clear interrupt low threshold low byte
   COLOR_RegAILTH,          // Clear interrupt low threshold high byte
   COLOR_RegAIHTL,          // Clear interrupt high threshold low byte
   COLOR_RegAIHTH,          // Clear interrupt high threshold high byte
   COLOR_RegPERS    = 0x0C, // Interrupt persistence filter
   COLOR_RegCONFIG,         // Configuration
   COLOR_RegCONTROL = 0x0F, // Control
   COLOR_RegID      = 0x12, // Device ID
   COLOR_RegSTATUS,         // Device status
   COLOR_RegCDATAL,         // Clear data low byte
   COLOR_RegCDATAH,         // Clear data high byte
   COLOR_RegRDATAL,         // Red data low byte
   COLOR_RegRDATAH,         // Red data high byte
   COLOR_RegGDATAL,         // Green data low byte
   COLOR_RegGDATAH,         // Green data high byte
   COLOR_RegBDATAL,         // Blue data low byte
   COLOR_RegBDATAH          // Blue data high byte
} COLOR_Reg;

#define COLOR_REG_ENABLE_PON_MASK 0x01
#define COLOR_REG_ENABLE_RGBC_INIT_MASK 0x02

#define COLOR_CMD_REPEAT_MASK (0x80)
#define COLOR_CMD_AUTO_INC_MASK (0xA0)

/***************************Function Definitions ******************************/

void COLOR_Begin(PmodCOLOR *InstancePtr, u32 IicBaseAddr, u32 GpioBaseAddr,
      u8 IicChipAddr);
void COLOR_ReadIIC(PmodCOLOR *InstancePtr, u8 reg, u8 *Data, int nData);
void COLOR_WriteIIC(PmodCOLOR *InstancePtr, u8 reg, u8 *Data, int nData);
void COLOR_SetLED(PmodCOLOR *InstancePtr, u32 NewState);
u32 COLOR_GetINT(PmodCOLOR *InstancePtr);
void COLOR_SetENABLE(PmodCOLOR *InstancePtr, u8 bits);
u32 COLOR_IsBusy(PmodCOLOR *InstancePtr);
COLOR_Data COLOR_GetData(PmodCOLOR *InstancePtr);
u8 COLOR_GetID(PmodCOLOR *InstancePtr);

#endif // PMODCOLOR_H
