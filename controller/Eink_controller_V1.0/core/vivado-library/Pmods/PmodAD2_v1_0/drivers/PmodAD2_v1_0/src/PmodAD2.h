/******************************************************************************/
/*                                                                            */
/* PmodAD2.h -- Driver definitions for the PmodAD2                            */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodAD2 IP from Digilent            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/13/2016(artvvb):   Created                                           */
/*    08/21/2017(artvvb):   Validated for Vivado 2015.4                       */
/*    02/10/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODAD2_H
#define PMODAD2_H

/****************** Include Files ********************/
#include "xiic.h"
#include "xiic_l.h"
#include "xil_types.h"
#include "xparameters.h"
#include "xstatus.h"

/* ------------------------------------------------------------ */
/*                  Definitions                                 */
/* ------------------------------------------------------------ */

#define AD2_IIC_ADDR 0x28

/* ------------------------------------------------------------ */
/*                  Bit Mask Definitions                        */
/* ------------------------------------------------------------ */

#define AD2_CONFIG_CH3             0x80
#define AD2_CONFIG_CH2             0x40
#define AD2_CONFIG_CH1             0x20
#define AD2_CONFIG_CH0             0x10
#define AD2_CONFIG_REF_SEL         0x08
#define AD2_CONFIG_FLTR            0x04
#define AD2_CONFIG_BIT_TRIAL_DELAY 0x02
#define AD2_CONFIG_SAMPLE_DELAY    0x01

#define AD2_DEFAULT_CONFIG (AD2_CONFIG_CH0 | AD2_CONFIG_CH1 | AD2_CONFIG_CH2 \
                                 | AD2_CONFIG_CH3)

#define AD2_DATA_MASK    0xFFF
#define AD2_CHANNEL_BIT  12
#define AD2_CHANNEL_MASK 0x3000

/* ------------------------------------------------------------ */
/*                  Procedure Declarations                      */
/* ------------------------------------------------------------ */

typedef struct PmodAD2 {
   XIic AD2Iic;
   u8 chipAddr;
} PmodAD2;

void AD2_begin(PmodAD2 *InstancePtr, u32 IIC_Address, u8 Chip_Address);
XStatus AD2_IICInit(XIic *IicInstancePtr);

XStatus AD2_ReadConv(PmodAD2 *InstancePtr, u16 *dataPtr);
XStatus AD2_WriteConfig(PmodAD2 *InstancePtr, u8 configuration);

#endif // PMODAD2_H
