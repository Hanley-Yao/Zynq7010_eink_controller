/******************************************************************************/
/*                                                                            */
/* PmodNAV.h -- Driver for the PmodNAV using SPI                              */
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
/* This file contains library to be used in XIlinx SDK to interface with the  */
/* PmodNAV - adapted from Monica I's chipkit Lib                              */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    11/16/2016(SamL):     Created                                           */
/*    03/16/2017(ArtVVB):   Completed & Validated                             */
/*    11/01/2017(ArtVVB):   2016.4 Maintenance                                */
/*    03/06/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PmodNAV_H
#define PmodNAV_H

/****************** Include Files ********************/

#include "xil_types.h"
#include "xspi.h"
#include "xspi_l.h"
#include "xstatus.h"

/****************** Definitions ********************/

#define bool u8
#define true 1
#define false 0

#define NAV_ACT_THS              0B00000100
#define NAV_ACT_DUR              0B00000101
#define NAV_ACL_INT_GEN_CFG_XL   0B00000110
#define NAV_ACL_INT_GEN_THS_X_XL 0B00000111
#define NAV_ACL_INT_GEN_THS_Y_XL 0B00001000
#define NAV_ACL_INT_GEN_THS_Z_XL 0B00001001
#define NAV_ACL_INT_GEN_DUR_XL   0B00001010
#define NAV_GYRO_REFERENCE_G     0B00001011
#define NAV_ACL_GYRO_INT1_CTRL   0B00001100
#define NAV_ACL_GYRO_INT2_CTRL   0B00001101

#define NAV_ACL_GYRO_WHO_AM_I    0B00001111
#define NAV_GYRO_CTRL_REG1_G     0B00010000
#define NAV_GYRO_CTRL_REG2_G     0B00010001
#define NAV_GYRO_CTRL_REG3_G     0B00010010
#define NAV_GYRO_ORIENT_CFG_G    0B00010011
#define NAV_GYRO_INT_GEN_SRC_G   0B00010100
#define NAV_OUT_TEMP_L           0B00010101
#define NAV_OUT_TEMP_H           0B00010110
#define NAV_ACL_GYRO_STATUS_REG  0B00010111
#define NAV_GYRO_OUT_X_L_G       0B00011000
#define NAV_GYRO_OUT_X_H_G       0B00011001
#define NAV_GYRO_OUT_Y_L_G       0B00011010
#define NAV_GYRO_OUT_Y_H_G       0B00011011
#define NAV_GYRO_OUT_Z_L_G       0B00011100
#define NAV_GYRO_OUT_Z_H_G       0B00011101
#define NAV_ACL_GYRO_CTRL_REG4   0B00011110
#define NAV_ACL_CTRL_REG5_XL     0B00011111
#define NAV_ACL_CTRL_REG6_XL     0B00100000
#define NAV_ACL_CTRL_REG7_XL     0B00100001
#define NAV_IMU_CTRL_REG8        0B00100010
#define NAV_IMU_CTRL_REG9        0B00100011
#define NAV_ACL_GYRO_CTRL_REG10  0B00100100

#define NAV_ACL_INT_GEN_SRC_XL   0B00100110
#define NAV_ALIAS_STATUS_REG     0B00100111
#define NAV_ACL_OUT_X_L_XL       0B00101000
#define NAV_ACL_OUT_X_H_XL       0B00101001
#define NAV_ACL_OUT_Y_L_XL       0B00101010
#define NAV_ACL_OUT_Y_H_XL       0B00101011
#define NAV_ACL_OUT_Z_L_XL       0B00101100
#define NAV_ACL_OUT_Z_H_XL       0B00101101
#define NAV_IMU_FIFO_CTRL         0B00101110
#define NAV_IMU_FIFO_SRC          0B00101111
#define NAV_GYRO_INT_GEN_CFG_G    0B00110000
#define NAV_GYRO_INT_GEN_THS_XH_G 0B00110001
#define NAV_GYRO_INT_GEN_THS_XL_G 0B00110010
#define NAV_GYRO_INT_GEN_THS_YH_G 0B00110011
#define NAV_GYRO_INT_GEN_THS_YL_G 0B00110100
#define NAV_GYRO_INT_GEN_THS_ZH_G 0B00110101
#define NAV_GYRO_INT_GEN_THS_ZL_G 0B00110110
#define NAV_GYRO_INT_GEN_DUR_G    0B00110111

#define NAV_MAG_OFFSET_X_REG_L_M  0B00000101
#define NAV_MAG_OFFSET_X_REG_H_M  0B00000110
#define NAV_MAG_OFFSET_Y_REG_L_M  0B00000111
#define NAV_MAG_OFFSET_Y_REG_H_M  0B00001000
#define NAV_MAG_OFFSET_Z_REG_L_M  0B00001001
#define NAV_MAG_OFFSET_Z_REG_H_M  0B00001010

#define NAV_MAG_WHO_AM_I_M        0B00001111

#define NAV_MAG_CTRL_REG1_M       0B00100000
#define NAV_MAG_CTRL_REG2_M       0B00100001
#define NAV_MAG_CTRL_REG3_M       0B00100010
#define NAV_MAG_CTRL_REG4_M       0B00100011
#define NAV_MAG_CTRL_REG5_M       0B00100100

#define NAV_MAG_STATUS_REG_M      0B00100111
#define NAV_MAG_OUT_X_L_M         0B00101000
#define NAV_MAG_OUT_X_H_M         0B00101001
#define NAV_MAG_OUT_Y_L_M         0B00101010
#define NAV_MAG_OUT_Y_H_M         0B00101011
#define NAV_MAG_OUT_Z_L_M         0B00101100
#define NAV_MAG_OUT_Z_H_M         0B00101101

#define NAV_MAG_INT_CFG_M         0B00110000
#define NAV_MAG_INT_SRC_M         0B00110001
#define NAV_MAG_INT_THS_L         0B00110010
#define NAV_MAG_INT_THS_H         0B00110011

#define NAV_ALT_REF_P_XL          0B00001000
#define NAV_ALT_REF_P_L           0B00001001
#define NAV_ALT_REF_P_H           0B00001010
#define NAV_ALT_WHO_AM_I          0B00001111
#define NAV_ALT_RES_CONF          0B00010000

#define NAV_ALT_CTRL_REG1         0B00100000
#define NAV_ALT_CTRL_REG2         0B00100001
#define NAV_ALT_CTRL_REG3         0B00100010
#define NAV_ALT_CTRL_REG4         0B00100011
#define NAV_ALT_INTERRUPT_CFG     0B00100100
#define NAV_ALT_INT_SOURCE        0B00100101

#define NAV_ALT_STATUS_REG        0B00100111
#define NAV_ALT_PRESS_OUT_XL      0B00101000
#define NAV_ALT_PRESS_OUT_L       0B00101001
#define NAV_ALT_PRESS_OUT_H       0B00101010
#define NAV_ALT_TEMP_OUT_L        0B00101011
#define NAV_ALT_TEMP_OUT_H        0B00101100

#define NAV_ALT_FIFO_CTRL         0B00101110
#define NAV_ALT_FIFO_STATUS       0B00101111
#define NAV_ALT_THS_P_L           0B00110000
#define NAV_ALT_THS_P_H           0B00110001

#define NAV_ALT_RPDS_L            0B00111001
#define NAV_ALT_RPDS_H            0B00111010

//masks for spi chip select and gpio pins
#define NAV_INST_AG  0b001
#define NAV_INST_MAG 0b010
#define NAV_INST_ALT 0b100
#define NAV_INT      0b01
#define NAV_DRDY_M   0b10

#define NAV_ACL_MODE_INST_A       0
#define NAV_ACL_GYRO_MODE_INST_AG 1
#define NAV_MAG_MODE_INST_MAG     2
#define NAV_ALT_MODE_INST_ALT     3

#define NAV_INT_PIN_1             0
#define NAV_INT_PIN_2             1

#define NAV_ACL_PAR_XL_2G         0
#define NAV_ACL_PAR_XL_4G         2
#define NAV_ACL_PAR_XL_8G         3
#define NAV_ACL_PAR_XL_16G        1
#define NAV_GYRO_PAR_G_245DPS     0
#define NAV_GYRO_PAR_G_500DPS     1
#define NAV_GYRO_PAR_G_2kDPS      3
#define NAV_MAG_PAR_MAG_4GAUSS    0
#define NAV_MAG_PAR_MAG_8GAUSS    1
#define NAV_MAG_PAR_MAG_12GAUSS   2
#define NAV_MAG_PAR_MAG_16GAUSS   3

#define NAV_PAR_INT_ACTIVEHIGH    0
#define NAV_PAR_INT_ACTIVELOW     1
#define NAV_PAR_INT_PUSHPULL      0
#define NAV_PAR_INT_OPENDRAIN     1
#define NAV_PAR_EXT_INT0          0
#define NAV_PAR_EXT_INT1          1
#define NAV_PAR_EXT_INT2          2
#define NAV_PAR_EXT_INT3          3
#define NAV_PAR_EXT_INT4         4

#define NAV_ACL_GYRO_FIFO_MODE_XL_G_BYPASS            0
#define NAV_ACL_GYRO_FIFO_MODE_XL_G_FIFO              1
#define NAV_ACL_GYRO_FIFO_MODE_XL_G_CONTINUOUS_FIFO   3
#define NAV_ACL_GYRO_FIFO_MODE_XL_G_BYPASS_CONTINUOUS 4
#define NAV_ACL_GYRO_FIFO_MODE_XL_G_CONTINUOUS        6

#define NAV_ALT_FIFO_MODE_ALT_BYPASS           0
#define NAV_ALT_FIFO_MODE_ALT_FIFO             1
#define NAV_ALT_FIFO_MODE_ALT_STREAM           2
#define NAV_ALT_FIFO_MODE_ALT_STREAM_TO_FIFO   3
#define NAV_ALT_FIFO_MODE_ALT_BYPASS_TO_STREAM 4
#define NAV_ALT_FIFO_MODE_ALT_MEAN             6
#define NAV_ALT_FIFO_MODE_ALT_BYPASS_TO_FIFO   7

#define NAV_ALT_FIFO_MODE_MEAN_ALT_2SAMPLES  0B00001
#define NAV_ALT_FIFO_MODE_MEAN_ALT_4SAMPLES  0B00011
#define NAV_ALT_FIFO_MODE_MEAN_ALT_8SAMPLES  0B00111
#define NAV_ALT_FIFO_MODE_MEAN_ALT_16SAMPLES 0B01111
#define NAV_ALT_FIFO_MODE_MEAN_ALT_32SAMPLES 0B11111

#define NAV_ACL_NO_BITS  16
#define NAV_IMU_X_AXIS   0
#define NAV_IMU_Y_AXIS   1
#define NAV_IMU_Z_AXIS   2
#define NAV_IMU_ALL_AXIS 3
//#define NAV_PI           3.1415

#define NAV_ACL_MSK_RANGE_XL      0x18
#define NAV_GYRO_MSK_RANGE_G      0x18
#define NAV_MAG_MSK_RANGE_MAG     0x60
#define NAV_ACL_MSK_ODR_XL        0xE0
#define NAV_GYRO_MSK_ODR_G        0xE0
#define NAV_MAG_MSK_ODR_MAG       0x1C
#define NAV_ALT_MSK_ODR_ALT       0x70
#define NAV_IMU_MSK_FIFO_CTL_MODE 0xE0
#define NAV_ALT_MSK_FIFO_CTL_MODE 0xE0
#define NAV_IMU_MSK_FIFO_THS      0x1F
#define NAV_ALT_MSK_FIFO_THS      0x1F

#define NAV_ACL_GYRO_MSK_INT1_IG_G      1<<7
#define NAV_ACL_GYRO_MSK_INT1_IG_XL     1<<6
#define NAV_ACL_GYRO_MSK_INT1_FSS5      1<<5
#define NAV_ACL_GYRO_MSK_INT1_OVR       1<<4
#define NAV_ACL_GYRO_MSK_INT1_FTH       1<<3
#define NAV_ACL_GYRO_MSK_INT1_Boot      1<<2
#define NAV_ACL_GYRO_MSK_INT1_DRDY_G    1<<1
#define NAV_ACL_GYRO_MSK_INT1_DRDY_XL   1<<0

#define NAV_ACL_GYRO_MSK_INT2_INACT     1<<7
#define NAV_ACL_GYRO_MSK_INT2_FSS5      1<<5
#define NAV_ACL_GYRO_MSK_INT2_OVR       1<<4
#define NAV_ACL_GYRO_MSK_INT2_FTH       1<<3
#define NAV_ACL_GYRO_MSK_INT2_DRDY_TEMP 1<<2
#define NAV_ACL_GYRO_MSK_INT2_DRDY_G    1<<1
#define NAV_ACL_GYRO_MSK_INT2_DRDY_XL   1<<0

#define NAV_ACL_MSK_XLIE_XL             1<<0
#define NAV_ACL_MSK_XHIE_XL             1<<1
#define NAV_ACL_MSK_YLIE_XL             1<<2
#define NAV_ACL_MSK_YHIE_XL             1<<3
#define NAV_ACL_MSK_ZLIE_XL             1<<4
#define NAV_ACL_MSK_ZHIE_XL             1<<5
#define NAV_ACL_MSK_GEN_6D              1<<6

#define NAV_GYRO_MSK_XLIE_G             1<<0
#define NAV_GYRO_MSK_XHIE_G             1<<1
#define NAV_GYRO_MSK_YLIE_G             1<<2
#define NAV_GYRO_MSK_YHIE_G             1<<3
#define NAV_GYRO_MSK_ZLIE_G             1<<4
#define NAV_GYRO_MSK_ZHIE_G             1<<5

#define NAV_MAG_MSK_ZIEN_MAG            1<<5
#define NAV_MAG_MSK_YIEN_MAG            1<<6
#define NAV_MAG_MSK_XIEN_MAG            1<<7

#define NAV_ALT_MSK_DIFF_EN_ALT         1<<3

#define NAV_ALT_MSK_INT_P_HIGH          0x01
#define NAV_ALT_MSK_INT_P_LOW           0x02
#define NAV_ALT_MSK_INT_P_LOW_HIGH      0x03

// int configurations for Altimeter
#define NAV_ALT_MSK_INT_F_EMPTY         1<<3
#define NAV_ALT_MSK_INT_F_FTH           1<<2
#define NAV_ALT_MSK_INT_F_OVR           1<<1
#define NAV_ALT_MSK_INT_DRDY            1<<0

#define NAV_ALT_MSK_INT_LEVEL_HIGH      1<<0
#define NAV_ALT_MSK_INT_LEVEL_LOW       1<<1

#define NAV_GYRO_ODR_G_PWR_DWN   0
#define NAV_GYRO_ODR_G_14_9HZ    1
#define NAV_GYRO_ODR_G_59_5HZ    2
#define NAV_GYRO_ODR_G_119HZ     3
#define NAV_GYRO_ODR_G_238HZ     4
#define NAV_GYRO_ODR_G_476HZ     5
#define NAV_GYRO_ODR_G_952HZ     6
#define NAV_GYRO_ODR_G_NA        7

// ODR defined values for Accelerometer
#define NAV_ACL_ODR_XL_PWR_DWN   0
#define NAV_ACL_ODR_XL_10HZ      1
#define NAV_ACL_ODR_XL_50HZ      2
#define NAV_ACL_ODR_XL_119HZ     3
#define NAV_ACL_ODR_XL_238HZ     4
#define NAV_ACL_ODR_XL_476HZ     5
#define NAV_ACL_ODR_XL_952HZ     6
#define NAV_ACL_ODR_XL_NA        7

// ODR defined values for magnetometer
#define NAV_MAG_ODR_M_0_625HZ    0
#define NAV_MAG_ODR_M_1_25HZ     1
#define NAV_MAG_ODR_M_2_5HZ      2
#define NAV_MAG_ODR_M_5HZ        3
#define NAV_MAG_ODR_M_10HZ       4
#define NAV_MAG_ODR_M_20HZ       5
#define NAV_MAG_ODR_M_40HZ       6
#define NAV_MAG_ODR_M_80HZ       7

#define NAV_ALT_ODR_ALT_ONE_SHOT 0
#define NAV_ALT_ODR_ALT_1HZ      1
#define NAV_ALT_ODR_ALT_7HZ      2
#define NAV_ALT_ODR_ALT_12_5HZ   3
#define NAV_ALT_ODR_ALT_25HZ     4

typedef struct {
   float X;
   float Y;
   float Z;
} NAV_RectCoord;

typedef struct {
   u8 ag;
   u8 mag;
   u8 alt;
} NAV_ID;

typedef struct {
   u32 GPIO_addr;
   XSpi NAVSpi;
   // From chipKit
   u8 prtSel;
   u8 m_SSPin;
   float m_GRangeLSB;
   float m_DPSRangeLSB;
   float m_GaussRangeLSB;

   NAV_RectCoord acclData;
   NAV_RectCoord gyroData;
   NAV_RectCoord magData;
   NAV_ID idData;
   float hPa;
   float tempC;
} PmodNAV;

// Basic SPI writes and reads
void NAV_DevTerm();

// Library internal functions used to compute the data using the corresponding
// range and LSB values
float NAV_GetGRangeLSB(uint8_t bRangeG);

//---- Basic device control functions.
void NAV_begin(PmodNAV* InstancePtr, u32 GPIO_Address, u32 SPI_Address);
int NAV_SPIInit(XSpi *InstancePtr);
void NAV_end(PmodNAV* InstancePtr);
void NAV_Init(PmodNAV* InstancePtr);
void NAV_GetData(PmodNAV* InstancePtr);
void NAV_InitALT(PmodNAV* InstancePtr, bool fInit);
void NAV_InitAG(PmodNAV* InstancePtr, bool fInit, u8 bModeSel);
void NAV_InitMAG(PmodNAV* InstancePtr, bool fInit);
void NAV_GetDeviceID(PmodNAV* InstancePtr);

//---- SPI specific functions

// Read and write SPI specific functions - read and write one byte via SPI
void NAV_WriteSPI(PmodNAV* InstancePtr, u8 bInst, u8 bAddr, u8 bVal);
u8 NAV_ReadSPI(PmodNAV* InstancePtr, u8 bInst, u8 bAddr);

void NAV_WriteRegister(PmodNAV* InstancePtr, u8 bInst, u8 bAddr, u8 bCntBytes,
      u8 *pData);
void NAV_ReadRegister(PmodNAV* InstancePtr, u8 bInst, u8 bAddr, u8 bCntBytes,
      u8 *pData);

void NAV_SetBitsInRegister(PmodNAV* InstancePtr, u8 bInst, u8 bRegAddr,
      u8 bMask, u8 bValue, u8 startBit);
u8 NAV_GetBitsInRegister(PmodNAV* InstancePtr, u8 bInst, u8 bRegAddr,
      u8 startBit, u8 noBits);
void NAV_SetRegisterBits(PmodNAV* InstancePtr, u8 bInst, u8 bRegAddr, u8 bMask,
      bool fValue);

//---- Accelerometer specific functions
void NAV_ReadAccel(PmodNAV* InstancePtr, s16* X, s16* Y, s16*Z);
void NAV_ReadAccelG(PmodNAV* InstancePtr, float* X, float* Y, float*Z);
float NAV_ConvertReadingToValueG(PmodNAV* InstancePtr, s16 rawVal);
void NAV_SetRangeXL(PmodNAV* InstancePtr, u8 bRangeXL);
float NAV_GetXLRangeLSB(u8 bRangeXL);
u8 NAV_GetRangeXL(PmodNAV* InstancePtr);
u8 NAV_DataAvailableXL(PmodNAV* InstancePtr);
void NAV_ConfigIntXL(PmodNAV* InstancePtr, u8 bIntGen, bool aoi, bool latch);
u8 NAV_GetIntSrcXLG(PmodNAV* InstancePtr, u8 bInstMode);
void NAV_SetIntThresholdXL(PmodNAV* InstancePtr, float thValX, float thValY,
      float thValZ, u8 intDuration, bool wait);

//---- Gyro specific functions
void NAV_ReadGyro(PmodNAV* InstancePtr, s16* GX, s16* GY, s16* GZ);
void NAV_ReadGyroDps(PmodNAV* InstancePtr, float *X, float *Y, float *Z);
float NAV_ConvertReadingToValueDPS(PmodNAV* InstancePtr, s16 rawVal);
void NAV_SetRangeG(PmodNAV* InstancePtr, u8 bRangeG);
float NAV_GetRangeG(PmodNAV* InstancePtr);
u8 NAV_DataAvailableG(PmodNAV* InstancePtr);
void NAV_ConfigIntG(PmodNAV* InstancePtr, u8 bIntGen, bool aoi, bool latch);
void NAV_SetIntThresholdG(PmodNAV* InstancePtr, float thVal, u16 axis,
      bool drCntMode, u8 intDuration, bool wait);
//configure INT1 and INT2 pins and use external interrupts functions
void NAV_ConfigInt(PmodNAV* InstancePtr, u8 bIntPin, u8 bIntGenMask,
      u8 bActiveType, u8 bOutputType);
// TODO void NAV_ConfigIntForExternalIntUse(u8 bIntPin, u8 bParExtIntNo,
//            u8 bIntGenMask, void (*pfIntHandler)(), uint8_t bActiveType,
//            uint8_t bOutputType);

//---- Magmetometer specific functions
void NAV_ReadMag(PmodNAV* InstancePtr, s16 *MagX, s16 *MagY, s16 *MagZ);
void NAV_ReadMagGauss(PmodNAV* InstancePtr);
float NAV_ConvertReadingToValueGauss(PmodNAV* InstancePtr, s16 rawVal);
void NAV_SetRangeMAG(PmodNAV* InstancePtr, u8 bRangeMAG);
float NAV_GetMAGRangeLSB(u8 bRangeMAG);
u8 NAV_GetRangeMAG(PmodNAV* InstancePtr);
u8 NAV_DataAvailableMAG(PmodNAV* InstancePtr, u8 axis);
void NAV_ConfigIntMAG(PmodNAV* InstancePtr, u8 bIntGen, u8 bActiveType,
      bool latch);
void NAV_SetIntThresholdM(PmodNAV* InstancePtr, float thVal);
u8 NAV_GetIntSrcMAG(PmodNAV* InstancePtr);

//---- Altimeter functions
int NAV_ReadPressure(PmodNAV* InstancePtr);
void NAV_ReadPressurehPa(PmodNAV* InstancePtr);
void NAV_ReadTempC(PmodNAV* InstancePtr);
u8 NAV_TempAvailableALT(PmodNAV* InstancePtr);
u8 NAV_DataAvailableALT(PmodNAV* InstancePtr);
void NAV_ConfigIntALT(PmodNAV* InstancePtr, u8 bIntGen, u8 bActiveType,
      u8 bOutputType, u8 dataSignalVal, bool intEnable, bool latch, u8 intLevel);
void NAV_SetIntThresholdALT(PmodNAV* InstancePtr, float thVal);
u8 NAV_GetIntSrcALT(PmodNAV* InstancePtr);

//---- Common functions
void NAV_SetODR(PmodNAV* InstancePtr, u8 bInstMode, u8 odrVal);
u8 NAV_GetODRRaw(PmodNAV* InstancePtr, u8 bInstMode);
float NAV_GetODR(PmodNAV* InstancePtr, u8 bInstMode);
void NAV_usleep(PmodNAV *InstancePtr, int micros);

//---- FIFO specific functions
void NAV_FIFOEnable(PmodNAV* InstancePtr, u8 bInst, bool fEnable);
void NAV_SetFIFO(PmodNAV* InstancePtr, u8 bInst, u8 parFIFOMode,
      u8 FIFOThreshold);
u8 NAV_GetFIFOMode(PmodNAV* InstancePtr, u8 bInst);
u8 NAV_GetFIFOThs(PmodNAV* InstancePtr, u8 bInst);
u8 NAV_GetFIFOStatus(PmodNAV* InstancePtr, u8 bInst);

#endif // PmodNAV_H
