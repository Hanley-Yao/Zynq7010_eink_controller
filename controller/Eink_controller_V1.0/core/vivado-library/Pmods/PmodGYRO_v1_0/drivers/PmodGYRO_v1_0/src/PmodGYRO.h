/******************************************************************************/
/*                                                                            */
/* PmodGYRO.h -- Driver definitions for the PmodGYRO                          */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodGYRO IP from Digilent.          */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/15/2016(MikelS):   Created                                           */
/*    10/02/2017(atangzwj): Validated for Vivado 2015.4                       */
/*    02/17/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODGYRO_H
#define PMODGYRO_H

/************ Include Files ************/

#include "xil_types.h"
#include "xstatus.h"
#include "xspi_l.h"
#include "xspi.h"


/************ Macro Definitions ************/

// bool type definition
#define GYRO_bool u8
#define GYRO_true 1
#define GYRO_false 0

// Register Addresses
#define GYRO_WHO_AM_I      0x0F
#define GYRO_CTRL_REG1     0x20
#define GYRO_CTRL_REG2     0x21
#define GYRO_CTRL_REG3     0x22
#define GYRO_CTRL_REG4     0x23
#define GYRO_CTRL_REG5     0x24
#define GYRO_REFERENCE     0x25
#define GYRO_OUT_TEMP      0x26
#define GYRO_STATUS_REG    0x27
#define GYRO_OUT_X_L       0x28
#define GYRO_OUT_X_H       0x29
#define GYRO_OUT_Y_L       0x2A
#define GYRO_OUT_Y_H       0x2B
#define GYRO_OUT_Z_L       0x2C
#define GYRO_OUT_Z_H       0x2D
#define GYRO_FIFO_CTRL_REG 0x2E
#define GYRO_FIFO_SRC_REG  0x2F
#define GYRO_INT1_CFG      0x30
#define GYRO_INT1_SRC      0x31
#define GYRO_INT1_TSH_XH   0x32
#define GYRO_INT1_TSH_XL   0x33
#define GYRO_INT1_TSH_YH   0x34
#define GYRO_INT1_TSH_YL   0x35
#define GYRO_INT1_TSH_ZH   0x36
#define GYRO_INT1_TSH_ZL   0x37
#define GYRO_INT1_DURATION 0x38

// CTRL_REG1
#define GYRO_REG1_DR1 0x80
#define GYRO_REG1_DR0 0x40
#define GYRO_REG1_BW1 0x20
#define GYRO_REG1_BW0 0x10
#define GYRO_REG1_PD  0x08
#define GYRO_REG1_ZEN 0x04
#define GYRO_REG1_YEN 0x02
#define GYRO_REG1_XEN 0x01

// CTRL_REG3
#define GYRO_REG3_I1_INT1   0x80
#define GYRO_REG3_I1_BOOT   0x40
#define GYRO_REG3_H_LACTIVE 0x20
#define GYRO_REG3_PP_OD     0x10
#define GYRO_REG3_I2_DRDY   0x08
#define GYRO_REG3_I2_WTM    0x04
#define GYRO_REG3_I2_ORUN   0x02
#define GYRO_REG3_I2_EMPTY  0x01

// GYRO_INT1_CFG
#define GYRO_INT1_ANDOR 0x80
#define GYRO_INT1_LIR   0x40
#define GYRO_INT1_ZHIE  0x20
#define GYRO_INT1_ZLIE  0x10
#define GYRO_INT1_YHIE  0x08
#define GYRO_INT1_YLIE  0x04
#define GYRO_INT1_XHIE  0x02
#define GYRO_INT1_XLIE  0x01


/************ Type Definitions ************/

typedef struct PmodGYRO {
   XSpi GYROSpi;
   int Base_Addr;
   int GPIO_Base_Addr;
} PmodGYRO;


/************ Function Prototypes ************/

GYRO_bool GYRO_Int1Status(PmodGYRO *InstancePtr);
GYRO_bool GYRO_Int2Status(PmodGYRO *InstancePtr);

int16_t GYRO_getX(PmodGYRO *InstancePtr);
int16_t GYRO_getY(PmodGYRO *InstancePtr);
int16_t GYRO_getZ(PmodGYRO *InstancePtr);
int8_t GYRO_getTemp(PmodGYRO *InstancePtr);
uint8_t GYRO_getInt1Src(PmodGYRO *InstancePtr);
GYRO_bool GYRO_enableInt1(PmodGYRO *InstancePtr, uint8_t mode);
GYRO_bool GYRO_disableInt1(PmodGYRO *InstancePtr);
GYRO_bool GYRO_enableInt2(PmodGYRO *InstancePtr, uint8_t mode);
GYRO_bool GYRO_setThsXL(PmodGYRO *InstancePtr, uint8_t ths);
GYRO_bool GYRO_setThsXH(PmodGYRO *InstancePtr, uint8_t ths);
GYRO_bool GYRO_setThsYL(PmodGYRO *InstancePtr, uint8_t ths);
GYRO_bool GYRO_setThsYH(PmodGYRO *InstancePtr, uint8_t ths);
GYRO_bool GYRO_setThsZL(PmodGYRO *InstancePtr, uint8_t ths);
GYRO_bool GYRO_setThsZH(PmodGYRO *InstancePtr, uint8_t ths);

GYRO_bool GYRO_begin(PmodGYRO* InstancePtr, u32 SPI_Address, u32 GPIO_Address);
void GYRO_end(PmodGYRO* InstancePtr);
int GYRO_SPIInit(XSpi *SpiInstancePtr);
void GYRO_WriteByte(PmodGYRO* InstancePtr, u8 cmd);
int GYRO_WriteReg(PmodGYRO* InstancePtr, u8 reg, u8 *wData, int nData);
u8 GYRO_ReadByte(PmodGYRO* InstancePtr);
void GYRO_ReadReg(PmodGYRO* InstancePtr, u8 reg, u8 *rData, int nData);
void GYRO_SetRegisterBits(PmodGYRO* InstancePtr, u8 reg, u8 mask,
      GYRO_bool fValue);
u8 GYRO_GetRegisterBits(PmodGYRO* InstancePtr, u8 bRegisterAddress, u8 bMask);

#endif // PMODGYRO_H
