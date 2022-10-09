/******************************************************************************/
/*                                                                            */
/* PmodACL.h -- PmodACL Driver Definitions                                    */
/*                                                                            */
/******************************************************************************/
/*                                                                            */
/* Author: Thomas Kappenman                                                   */
/* Copyright 2016-2017, Digilent Inc.                                         */
/*                                                                            */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains driver definitions for the PmodACL IP                   */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    03/23/2016(TKappenman): Created                                         */
/*    08/15/2016(jpeyron):    Sleep and Zynq include fixes                    */
/*    08/11/2017(artvvb):     Validated for Vivado 2015.4                     */
/*    02/17/2018(atangzwj):   Validated for Vivado 2017.4                     */
/*                                                                            */
/******************************************************************************/

#ifndef PMODACL_H
#define PMODACL_H

/****************** Include Files ********************/

#include "xil_types.h"
#include "xspi.h"
#include "xspi_l.h"
#include "xstatus.h"

/* ------------------------------------------------------------ */
/*                  Definitions                                 */
/* ------------------------------------------------------------ */
#define ACL_NO_BITS           10
#define ACL_I2C_ADDR          0x1D
#define ACL_CONV_OFFSET_G_LSB (15.6 * 0.001) // Convert offset (g) to LSB,
                                             // 15.6 mg/LSB

/* ------------------------------------------------------------ */
/*                  Register Addresses Definitions              */
/* ------------------------------------------------------------ */

#define ACL_REG_DEVID         0x00
#define ACL_REG_OFSX          0x1E
#define ACL_REG_OFSY          0x1F
#define ACL_REG_OFSZ          0x20
#define ACL_REG_DUR           0x21
#define ACL_REG_LATENT        0x22
#define ACL_REG_WINDOW        0x23
#define ACL_REG_THRESH_ACT    0x24
#define ACL_REG_THRESH_INACT  0x25
#define ACL_REG_TIME_INACT    0x26
#define ACL_REG_ACT_INACT_CTL 0x27
#define ACL_REG_THRESH_FF     0x28
#define ACL_REG_TIME_FF       0x29
#define ACL_REG_BW_RATE       0x2C
#define ACL_REG_POWER_CTL     0x2D
#define ACL_REG_INT_ENABLE    0x2E
#define ACL_REG_INT_MAP       0x2F
#define ACL_REG_INT_SOURCE    0x30
#define ACL_REG_DATA_FORMAT   0x31
#define ACL_REG_DATAX0        0x32
#define ACL_REG_DATAX1        0x33
#define ACL_REG_DATAY0        0x34
#define ACL_REG_DATAY1        0x35
#define ACL_REG_DATAZ0        0x36
#define ACL_REG_DATAZ1        0x37
#define ACL_REG_FIFO_CTL      0x38
#define ACL_REG_FIFO_STATUS   0x39

/* ------------------------------------------------------------ */
/*                  Bit Masks Definitions                       */
/* ------------------------------------------------------------ */

#define ACL_MSK_POWER_CTL_MEASURE  1<<3
#define ACL_MSK_DATA_FORMAT_RANGE0 1<<0
#define ACL_MSK_DATA_FORMAT_RANGE1 1<<1

/* ------------------------------------------------------------ */
/*                  Parameters Definitions                      */
/* ------------------------------------------------------------ */

#define ACL_PAR_ACCESS_DSPI0 0
#define ACL_PAR_ACCESS_DSPI1 1
#define ACL_PAR_ACCESS_DSPI2 2
#define ACL_PAR_ACCESS_I2C   10
#define ACL_PAR_GRANGE_PM2G  0
#define ACL_PAR_GRANGE_PM4G  1
#define ACL_PAR_GRANGE_PM8G  2
#define ACL_PAR_GRANGE_PM16G 3
#define ACL_PAR_AXIS_XP      0
#define ACL_PAR_AXIS_XN      1
#define ACL_PAR_AXIS_YP      2
#define ACL_PAR_AXIS_YN      3
#define ACL_PAR_AXIS_ZP      4
#define ACL_PAR_AXIS_ZN      5
#define ACL_PAR_AXIS_X       0
#define ACL_PAR_AXIS_Y       1
#define ACL_PAR_AXIS_Z       2

/* ------------------------------------------------------------ */
/*                  Procedure Declarations                      */
/* ------------------------------------------------------------ */

typedef struct PmodACL {
   XSpi ACLSpi;
   u32 GPIO_addr;
   float m_dGRangeLSB;
} PmodACL;

void ACL_begin(PmodACL *InstancePtr, u32 GPIO_Address, u32 SPI_Address);
int ACL_SPIInit(XSpi *SpiInstancePtr);

void ACL_WriteSpi(PmodACL *InstancePtr, u8 reg, u8 *wData, int nData);
void ACL_ReadSpi(PmodACL *InstancePtr, u8 reg, u8 *rData, int nData);
void ACL_SetRegisterBits(PmodACL *InstancePtr, u8 reg, u8 mask, u8 fValue);
u8 ACL_GetRegisterBits(PmodACL *InstancePtr, u8 bRegisterAddress, u8 bMask);

float ACL_ConvertReadingToValueG(PmodACL *InstancePtr, int16_t uiReading);
float ACL_GetGRangeLSB(uint8_t bGRange);
void ACL_ReadAccelG(PmodACL *InstancePtr, float *dAclXg, float *dAclYg,
      float *dAclZg);
void ACL_ReadAccel(PmodACL *InstancePtr, int16_t *iAclX, int16_t *iAclY,
      int16_t *iAclZ);
void ACL_SetMeasure(PmodACL *InstancePtr, u8 fMeasure);
u8 ACL_GetMeasure(PmodACL *InstancePtr);
void ACL_SetGRange(PmodACL *InstancePtr, u8 bGRangePar);
u8 ACL_GetGRange(PmodACL *InstancePtr);
void ACL_SetOffsetG(PmodACL *InstancePtr, u8 bAxisParam, float dOffset);
float ACL_GetOffsetG(PmodACL *InstancePtr, u8 bAxisParam);
void ACL_CalibrateOneAxisGravitational(PmodACL *InstancePtr, u8 bAxisInfo);

#endif // PMODACL_H
