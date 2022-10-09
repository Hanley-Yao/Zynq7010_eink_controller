/******************************************************************************/
/*                                                                            */
/* PmodACL2.h -- Driver definitions for the Pmod ACL2                         */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen                                                       */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains a basic library in order to interface with the PmodACL2 */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    04/19/2016(MikelS):   Created                                           */
/*    08/24/2017(artvvb):   Validated for Vivado 2015.4                       */
/*    02/03/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PmodACL2_H
#define PmodACL2_H

/****************** Include Files ********************/

#include "xil_types.h"
#include "xspi.h"
#include "xspi_l.h"
#include "xstatus.h"

/* ------------------------------------------------------------ */
/*                  Definitions                                 */
/* ------------------------------------------------------------ */

/*  Register Addresses  */
#define ACL2_PART_ID_REG        0x02
#define ACL2_X_DATA_REG         0x08
#define ACL2_Y_DATA_REG         0x09
#define ACL2_Z_DATA_REG         0x0A
#define ACL2_STATUS_REG         0x0B
#define ACL2_FIFO_ENTRIES_L_REG 0x0C
#define ACL2_FIFO_ENTRIES_H_REG 0x0D
#define ACL2_XDATA_L_REG        0x0E
#define ACL2_XDATA_H_REG        0x0F
#define ACL2_YDATA_L_REG        0x10
#define ACL2_YDATA_H_REG        0x11
#define ACL2_ZDATA_L_REG        0x12
#define ACL2_ZDATA_H_REG        0x13
#define ACL2_TEMP_L_REG         0x14
#define ACL2_TEMP_H_REG         0x15
#define ACL2_SOFT_RESET_REG     0x1F
#define ACL2_THRESH_ACT_L_REG   0x20
#define ACL2_THRESH_INACT_L_REG 0x23
#define ACL2_THRESH_INACT_H_REG 0x24
#define ACL2_TIME_INACT_L_REG   0x25
#define ACL2_TIME_INACT_H_REG   0x26
#define ACL2_ACT_INACT_CTL_REG  0x27
#define ACL2_FIFO_CONTROL_REG   0x28
#define ACL2_FIFO_SAMPLES_REG   0x29
#define ACL2_INTMAP1_REG        0x2A
#define ACL2_INTMAP2_REG        0x2B
#define ACL2_FILTER_CTL_REG     0x2C
#define ACL2_POWER_CTL_REG      0x2D
#define ACL2_SELF_TEST_REG      0x2E

/*  Bit Masks  */
#define ACL2_STATUS_DATA_READY_MASK     0x01
#define ACL2_STATUS_FIFO_READY_MASK     0x02
#define ACL2_STATUS_FIFO_WATERMARK_MASK 0x04
#define ACL2_STATUS_FIFO_OVERRUN_MASK   0x08
#define ACL2_STATUS_ACT_MASK            0x10
#define ACL2_STATUS_INACT_MASK          0x20
#define ACL2_STATUS_AWAKE_MASK          0x40
#define ACL2_STATUS_ERR_USER_REGS_MASK  0x80

/*  Command Bytes  */
#define ACL2_READ      0x0B // Command byte for reading from ACL2
#define ACL2_WRITE     0x0A // Command byte for writing to ACL2
#define ACL2_FIFO_READ 0x0D // Command byte for reading from ACL2 FIFO buffer

/*  Initialization Parameters  */
#define ACL2_FREE_FALL_THRESH   0x96 // Sets free-fall detection threshold to
                                     //    600mg
#define ACL2_INACT_STILL_THRESH 0xFA // Sets still motion reference threshold to
                                     //    1g
#define ACL2_FREE_FALL_TIME     0x03 // Sets free-fall detection time to 30ms
#define ACL2_INACT_STILL_TIME_L 0x10 // Lower half of 10 second still time
#define ACL2_INACT_STILL_TIME_H 0x27 // Upper half of 10 second still time
#define ACL2_REF_INACT_ENABLE   0x0C // Enable referenced inactivity detection
#define ACL2_SET_INACT_INTERUPT 0x20 // Sets the inactivity interrupt to the
                                     //    interrupt 1 pin
#define ACL2_SENSOR_RANGE_8     0x83 // Sets sensor range to 8g with 100Hz ODR
#define ACL2_SENSOR_RANGE_4     0x43 // Sets sensor range to 4g with 100Hz ODR
#define ACL2_SENSOR_RANGE_2     0x03 // Sets sensor range to 2g with 100Hz ODR
#define ACL2_BEGIN_MEASURE      0x02 // Begins measurement

/*   GPIO Register Offsets  */
#define ACL2_GPIO_CS_CHANNEL_DATA_OFFSET    0
#define ACL2_GPIO_CS_CHANNEL_TRIS_OFFSET    4
#define ACL2_GPIO_INT_CHANNEL_DATA_OFFSET   8
#define ACL2_GPIO_INT_CHANNEL_TRIS_OFFSET  12

/* ------------------------------------------------------------ */
/*                  Object Class Declarations                   */
/* ------------------------------------------------------------ */

typedef struct ACL2_SamplePacket {
   int XData;
   int YData;
   int ZData;
} ACL2_SamplePacket;

typedef struct PmodACL2 {
   XSpi ACL2Spi;
   u32  GPIO_addr;
   u8   range;
} PmodACL2;

/* ------------------------------------------------------------ */
/*                  Function Prototypes                         */
/* ------------------------------------------------------------ */

void ACL2_begin(PmodACL2 *InstancePtr, u32 GPIO_Address, u32 SPI_Address);
void ACL2_configure(PmodACL2 *InstancePtr);
void ACL2_end(PmodACL2 *InstancePtr);
XStatus ACL2_SPIInit(XSpi *SpiInstancePtr);

void ACL2_ReadSpi(PmodACL2 *InstancePtr, u8 reg, u8 *rData, int nData);
void ACL2_WriteSpi(PmodACL2 *InstancePtr, u8 reg, u8 *wData, int nData);

ACL2_SamplePacket ACL2_getSample(PmodACL2 *InstancePtr);

void ACL2_reset(PmodACL2 *InstancePtr);
void ACL2_updateRange(PmodACL2 *InstancePtr);

float ACL2_DataToG(PmodACL2 *InstancePtr, int data);
void ACL2_setRange(PmodACL2 *InstancePtr, int newRange);

u8 ACL2_getStatus(PmodACL2 *InstancePtr);
int ACL2_getData(PmodACL2 *InstancePtr, u8 start_reg);

#endif // PmodACL2_H
