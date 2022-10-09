/******************************************************************************/
/*                                                                            */
/* PmodNAV.c -- Driver for the PmodNAV using SPI                              */
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
/* PmodNAV.                                                                   */
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

/***************************** Include Files *******************************/

#include "PmodNAV.h"
#include "sleep.h"

XSpi_Config NAVConfig = {
   0, // u16 DeviceId
   0, // u32 BaseAddress - load in NAV_begin
   1, // int HasFifos
   0, // u32 SlaveOnly - master mode
   3, // u8  NumSlaveBits - three slave devices
   8, // u8  DataWidth
   0, // u8  SpiMode
   0, // u8  AxiInterface - AXI-Lite
   0, // u32 AxiFullBaseAddress
   0, // u8  XipMode
   0  // u8  Use_Startup
};

/* ------------------------------------------------------------ */
/*** void NAV_DevTerm(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - the PmodNav device to terminate
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**  Description:
**      Shuts down the Nav hardware
*/
void NAV_DevTerm(PmodNAV *InstancePtr) {
   // Shuts down the accel and gyro instruments
   NAV_InitAG(InstancePtr, 0, NAV_ACL_GYRO_MODE_INST_AG);
   // Shuts down the magnetometer instrument
   NAV_InitMAG(InstancePtr, 0);
   // Shuts down the altimeter instrument
   NAV_InitALT(InstancePtr, 0);
}

/* ------------------------------------------------------------ */
/*** void NAV_begin(PmodNAV *InstancePtr, u32 GPIO_Address, u32 SPI_Address,
**         u32 CpuClockFreqHz)
**
**   Parameters:
**      InstancePtr    - instance of the PmodNAV
**      GPIO_Address   - address of the PmodNAV GPIO controller
**      SPI_Address    - address of the PmodNAV SPI controller
**      CpuClockFreqHz - frequency of the CPU clock, required for functionality
**                       in MicroBlaze
**
**  Return Value:
**      None
**
**  Errors:
**      None
**
**  Description:
**      Initializes the SPI interface and the global variables of the library.
**      This function must be called before any other functions in the library
**      are called.
*/
void NAV_begin(PmodNAV *InstancePtr, u32 GPIO_Address, u32 SPI_Address) {
   InstancePtr->GPIO_addr = GPIO_Address;
   NAVConfig.BaseAddress = SPI_Address;
   NAVConfig.NumSlaveBits = 3;

   // Set NAV_DRDY_M and NAV_INT pins as inputs
   // 0b1111 for input 0b0000 for output, 0b0001 for pin1 in pin 2 out etc.
   Xil_Out32(InstancePtr->GPIO_addr + 4, 0b11);

   // Initialize the SPI device
   NAV_SPIInit(&InstancePtr->NAVSpi);

   // Get initial ranges
   // The startup range for the accelerometer is +/- 2g, which corresponds to a
   // LSB value of 0.061mg/LSB
   InstancePtr->m_GRangeLSB = NAV_GetXLRangeLSB(NAV_ACL_PAR_XL_2G);

   // The startup range for the gyro is +/- 245dps, which corresponds to a LSB
   // value of 8.75mdps/LSB
   InstancePtr->m_DPSRangeLSB = NAV_GetGRangeLSB(NAV_GYRO_PAR_G_245DPS);

   // The startup range for the magnetometer is +/- 4Gauss, which corresponds to
   // a LSB value of 0.14mGauss/LSB
   InstancePtr->m_GaussRangeLSB = NAV_GetMAGRangeLSB(NAV_MAG_PAR_MAG_4GAUSS);
}

/* ------------------------------------------------------------ */
/*** int NAV_SPIInit(XSpi *SpiInstancePtr)
**
**   Parameters:
**      SpiInstancePtr - pointer to the SPI controller in PmodNAV
**
**   Return Value:
**      Status - returns whether function was successful or failed
**
**   Errors:
**      None
**
**   Description:
**      Initializes the PmodNAV SPI.
*/
int NAV_SPIInit(XSpi *SpiInstancePtr) {
   int Status;

   Status = XSpi_CfgInitialize(SpiInstancePtr, &NAVConfig,
         NAVConfig.BaseAddress);
   if (Status != XST_SUCCESS)
      return XST_FAILURE;

   u32 options = XSP_MASTER_OPTION | XSP_CLK_ACTIVE_LOW_OPTION
         | XSP_CLK_PHASE_1_OPTION;
   Status = XSpi_SetOptions(SpiInstancePtr, options);
   if (Status != XST_SUCCESS)
      return XST_FAILURE;

   // Select no slave
   Status = XSpi_SetSlaveSelect(SpiInstancePtr, 0b000);
   if (Status != XST_SUCCESS)
      return XST_FAILURE;

   // Start the SPI driver so that the device is enabled.
   XSpi_Start(SpiInstancePtr);

   // Disable Global interrupt to use polled mode operation
   XSpi_IntrGlobalDisable(SpiInstancePtr);

   return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/*** void NAV_end(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Performs the power off sequences, floats all pins and releases the PIC32
**      resources used by the Nav interface.
*/
void NAV_end(PmodNAV *InstancePtr) {
   NAV_DevTerm(InstancePtr);
   InstancePtr->m_GRangeLSB = 0;
   InstancePtr->m_DPSRangeLSB = 0;
   InstancePtr->m_GaussRangeLSB = 0;
}

/* ------------------------------------------------------------ */
/*** void NAV_Init(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function initializes all the instruments by calling the specific
**      init functions for each of them
**
**      Default operating mode for Accelerometer and Gyroscope is ACL+GYRO.
*/
void NAV_Init(PmodNAV *InstancePtr) {
   // Enable only acl work mode or gyro and acl work mode;
   NAV_InitAG(InstancePtr, 1, NAV_ACL_GYRO_MODE_INST_AG);
   // Init mag instrument
   NAV_InitMAG(InstancePtr, 1);
   // Init alt instrument
   NAV_InitALT(InstancePtr, 1);
}

/* ------------------------------------------------------------ */
/*** void NAV_GetData(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function calls the read functions of all the instruments and
**      updates the global variables with new data
*/
void NAV_GetData(PmodNAV *InstancePtr) {
   NAV_ReadAccelG(
      InstancePtr,
      &(InstancePtr->acclData.X),
      &(InstancePtr->acclData.Y),
      &(InstancePtr->acclData.Z)
   );
   NAV_ReadGyroDps(
      InstancePtr,
      &(InstancePtr->gyroData.X),
      &(InstancePtr->gyroData.Y),
      &(InstancePtr->gyroData.Z)
   );
   NAV_ReadMagGauss(InstancePtr);
   usleep(10);
   NAV_ReadPressurehPa(InstancePtr);
   usleep(10);
   NAV_ReadTempC(InstancePtr);
}

/* ------------------------------------------------------------ */
/*** void NAV_InitALT(PmodNAV *InstancePtr, bool fInit)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      fInit       - enables the instrument for initialization or disables it
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Initializes the barometer/altimeter instrument with the following
**      settings:
**         set active mode and 7Hz ODR rate, in register NAV_ALT_CTRL_REG1,
**         block data update active.
*/
void NAV_InitALT(PmodNAV *InstancePtr, bool fInit) {
   if (fInit) {
      // Clean start
      NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG1, 0x00);
      usleep(5000);
      // Set active the device and ODR to 7Hz
      NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG1, 0xA4);
      usleep(5000);
      // Increment address during multiple byte access disabled
      NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG2, 0x00);
      usleep(5000);
      // No modification to interrupt sources
      NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG4, 0x00);
      usleep(5000);
   } else {
      // Power down the instrument
      NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG1, 0x00);
   }
}

/* ------------------------------------------------------------ */
/*** void NAV_InitAG(PmodNAV *InstancePtr, bool fInit, u8 bModeSel)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      fInit       - select initialization or disabling of the device
**      bModeSel    - work mode for the two instruments, Accelerometer and
**                    Gyroscope: ACL only or ACL+GYRO.
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Initializes the accelerometer only or both the accelerometer and
**      gyroscope instruments with the following settings:
**         for ACL mode:
**            Enable all three axes in NAV_ACL_CTRL_REG5_XL register, set 10 Hz
**            ODR in NAV_ACL_CTRL_REG6_XL register
**         for ACL+GYRO:
**            set 10Hz ODR in NAV_GYRO_CTRL_REG1_G register and
**            NAV_ACL_CTRL_REG6_XL, thus enabling the Gyroscope functionality as
**            well; enable the output of all three axes.
**
*/
void NAV_InitAG(PmodNAV *InstancePtr, bool fInit, u8 bModeSel) {
   if (fInit) {
      if (bModeSel == NAV_ACL_MODE_INST_A) {
         // Enable all three axes
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG5_XL, 0x38);
         // Set 10Hz odr for accelerometer
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG6_XL, 0x20);
      } else if (bModeSel == NAV_ACL_GYRO_MODE_INST_AG) {
         // Enable all three axes
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG5_XL, 0x38);
         // Set 10Hz odr for accel when used together with gyro
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG6_XL, 0x20);
         // Set 10Hz rate for Gyro
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_GYRO_CTRL_REG1_G, 0x20);
         // Enable the axes outputs for Gyro
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_GYRO_CTRL_REG4, 0x38);
      }
   } else {
      if (bModeSel == NAV_ACL_MODE_INST_A) {
         // Power down accel
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG5_XL, 0x00);
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG6_XL, 0x00);
      } else if (bModeSel == NAV_ACL_GYRO_MODE_INST_AG) {
         // Power down both the accel and gyro instruments
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG5_XL, 0x00);
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG6_XL, 0x00);
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_IMU_CTRL_REG9, 0x00);

         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_GYRO_CTRL_REG4, 0x00);
         NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_GYRO_CTRL_REG1_G, 0x00);
      }
   }
}

/* ------------------------------------------------------------ */
/*** void NAV_InitMAG(PmodNAV *InstancePtr, bool fInit)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      fInit       - enables the instrument for initialization or disables it
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Initializes the magnetometer instrument with the following settings:
**         set medium performance mode 10H ODR, in register NAV_MAG_CTRL_REG1_M
**         disable I2C and enable SPI read and write operations, set the
**         operating mode to continuous in NAV_MAG_CTRL_REG3_M register.
*/
void NAV_InitMAG(PmodNAV *InstancePtr, bool fInit) {
   if (fInit) {
      // Set medium performance mode for x and y and 10Hz ODR for MAG,
      NAV_WriteSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_CTRL_REG1_M, 0x30);
      // Set scale to +-4Gauss
      NAV_WriteSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_CTRL_REG2_M, 0);
      // Disable I2C and enable SPI read and write operations,
      // Set the operating mode to continuous conversion
      NAV_WriteSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_CTRL_REG3_M, 0x00);
      // Set medium performance mode for z axis
      NAV_WriteSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_CTRL_REG4_M, 0x04);
      // Continuous update of output registers
      NAV_WriteSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_CTRL_REG5_M, 0x00);
   } else {
      // Power down the instrument
      NAV_WriteSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_CTRL_REG3_M, 0x03);
   }
}

/* ------------------------------------------------------------ */
/*** void NAV_GetDeviceID(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function gets the device id for all the instruments, updates the
**      DEV_ID structure members
*/
void NAV_GetDeviceID(PmodNAV *InstancePtr) {
   NAV_ReadRegister(InstancePtr, NAV_INST_AG, NAV_ACL_GYRO_WHO_AM_I, 1,
         &(InstancePtr->idData.ag));
   NAV_ReadRegister(InstancePtr, NAV_INST_MAG, NAV_ACL_GYRO_WHO_AM_I, 1,
         &(InstancePtr->idData.mag));
   NAV_ReadRegister(InstancePtr, NAV_INST_ALT, NAV_ACL_GYRO_WHO_AM_I, 1,
         &(InstancePtr->idData.alt));
}

/*--------------------------------------------------------------*/
/*  SPI Specific Functions                                      */
/*--------------------------------------------------------------*/

/* ------------------------------------------------------------ */
/*** void NAV_WriteSPI(PmodNAV *InstancePtr, u8 bInst, u8 bAddr, u8 bVal)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst       - instrument Chip Select: Accelerometer/Gyroscope,
**                    Magnetometer or Altimeter selection
**      bAddr       - address to write to via SPI
**      bVal        - byte to be written to SPI
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Sends one byte to SPI.
*/
void NAV_WriteSPI(PmodNAV *InstancePtr, u8 bInst, u8 bAddr, u8 bVal) {
   u8 recv[2];

   recv[0] = bAddr | 0x00;
   recv[1] = bVal;

   // Select a slave
   XSpi_SetSlaveSelect(&InstancePtr->NAVSpi, bInst);

   // Transfer SPI data
   XSpi_Transfer(&InstancePtr->NAVSpi, recv, recv, 2);

   // Set chip select high
   XSpi_SetSlaveSelect(&InstancePtr->NAVSpi, 0b000);
}

/* ------------------------------------------------------------ */
/*** u8 NAV_ReadSPI(PmodNAV *InstancePtr, u8 bInst, u8 bAddr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst       - instrument Chip Select: Accelerometer/Gyro, Magnetometer
**                    or Altimeter selection
**      bAddr       - address byte to be read from via SPI
**
**   Return Value:
**      uint8_t - Returns a byte read as a result of the SPI transfer
**
**   Errors:
**      None
**
**   Description:
**      Receives one byte to SPI.
*/
u8 NAV_ReadSPI(PmodNAV *InstancePtr, u8 bInst, u8 bAddr) {
   u8 recv[2];

   recv[0] = bAddr | 0x80;
   recv[1] = 0;

   // Select a slave
   XSpi_SetSlaveSelect(&InstancePtr->NAVSpi, bInst);

   // Transfer SPI data
   XSpi_Transfer(&InstancePtr->NAVSpi, recv, recv, 2);

   XSpi_SetSlaveSelect(&InstancePtr->NAVSpi, 0b000);

   return recv[1];
}

/* ------------------------------------------------------------ */
/*** void NAV_WriteRegister(PmodNAV *InstancePtr, uint8_t bInst, uint8_t bAddr,
**         uint8_t bCntBytes, uint8_t *pData)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst       - instrument Chip Select to be used: Accelerometer/Gyro,
**                    Magnetometer or Altimeter
**      bAddr       - register address to start writing bytes to
**      bCntBytes   - number of bytes to be written via SPI interface
**      pData       - pointer to the 16 bit data array to be written
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Sends bCntBytes bytes to SPI, to be written in register having
**      consecutive addresses, starting with bAddr.
*/
void NAV_WriteRegister(PmodNAV *InstancePtr, uint8_t bInst, uint8_t bAddr,
      uint8_t bCntBytes, uint8_t *pData) {
   u8 recv[bCntBytes + 1];
   int i = 0;

   for (i = 0; i < bCntBytes; i++) {
      recv[i + 1] = pData[i];
   }

   // Add write bit
   if (bInst == NAV_INST_AG)
      recv[0] = bAddr | 0x00;
   else
      recv[0] = bAddr | 0x40;

   // Select a slave
   XSpi_SetSlaveSelect(&InstancePtr->NAVSpi, bInst);

   // Transfer SPI data
   XSpi_Transfer(&InstancePtr->NAVSpi, recv, recv, bCntBytes + 1);

   // Set chip select high
   XSpi_SetSlaveSelect(&InstancePtr->NAVSpi, 0b000);
}

/* ------------------------------------------------------------ */
/*** void NAV_ReadRegister(PmodNAV *InstancePtr, uint8_t bInst, uint8_t bAddr, uint8_t bCntBytes, uint8_t *pData)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst       - instrument Chip Select to be used: Accelerometer/Gyro,
**                    Magnetometer or Altimeter
**      bAddr       - register address to start reading bytes from
**      bCntBytes   - number of bytes to be read
**      pData       - pointer to the 16 bit data array to be read
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      Reads bCntBytes bytes from device via SPI, from register having
**      consecutive addresses, starting with bAddr.
*/
void NAV_ReadRegister(PmodNAV *InstancePtr, uint8_t bInst, uint8_t bAddr,
      uint8_t bCntBytes, uint8_t *pData) {
   u8 recv[bCntBytes + 1];
   int i = 0;

   for (i = 0; i < bCntBytes; i++) {
      recv[i + 1] = 0;
   }

   // Add write bit
   if (bInst == NAV_INST_AG)
      recv[0] = bAddr | 0x80;
   else
      recv[0] = bAddr | 0xC0;

   // Select a slave
   XSpi_SetSlaveSelect(&InstancePtr->NAVSpi, bInst);

   XSpi_Transfer(&InstancePtr->NAVSpi, recv, recv, bCntBytes + 1);

   // Set chip select high
   XSpi_SetSlaveSelect(&InstancePtr->NAVSpi, 0b000);

   for (i = 0; i < bCntBytes; i++) {
      pData[i] = recv[i + 1];
   }
}

/* ------------------------------------------------------------ */
/*** void NAV_SetBitsInRegister(PmodNAV *InstancePtr, u8 bInst, u8 bRegAddr,
**         u8 bMask, u8 bValue, u8 startBit)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst       - instrument selection for chip select: AG/MAG/ALT
**      bRegAddr    - the address of the register whose bits are set
**      bMask       - the mask indicating which bits are affected
**      bValue      - the byte containing bits values
**      startBit    - start bit of the bits group to be set in register
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function sets the value of some bits (corresponding to the bMask)
**      of a register (indicated by bRegAddr) to the value of the corresponding
**      bits from another byte (indicated by bValue) starting from the position
**      indicated by startBit.
*/
void NAV_SetBitsInRegister(PmodNAV *InstancePtr, u8 bInst, u8 bRegAddr,
      u8 bMask, u8 bValue, u8 startBit) {
   u8 bRegValue, shiftedValue;
   shiftedValue = (bValue << startBit);
   NAV_ReadRegister(InstancePtr, bInst, bRegAddr, 1, &bRegValue);
   // Register value: mask out the bits from the mask
   bRegValue &= ~bMask;
   // Value: mask out the values outside the mask
   shiftedValue &= bMask;
   // Combine the value with the masked register value
   bRegValue |= (shiftedValue & bMask);
   NAV_WriteRegister(InstancePtr, bInst, bRegAddr, 1, &bRegValue);
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetBitsInRegister(PmodNAV *InstancePtr, u8 bInst, u8 bRegAddr,
**         u8 startBit, u8 noBits)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst       - instrument selection for chip select: AG/MAG/ALT
**      bRegAddr    - the address of the register whose bits are set
**      startBit    - start bit of the bits group to be set in register
**      noBits      - number of bits starting from start bit, to be read
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function gets the value of some bits (given by the startBts and
**      noBits parameters) of a register (indicated by bRegisterAddress).
*/
u8 NAV_GetBitsInRegister(PmodNAV *InstancePtr, u8 bInst, u8 bRegAddr,
      u8 startBit, u8 noBits) {
   u8 bRegValue, bResult, bMask;
   NAV_ReadRegister(InstancePtr, bInst, bRegAddr, 1, &bRegValue);
   bMask = ((1 << noBits) - 1) << startBit;
   bResult = (bRegValue & bMask) >> startBit;

   return bResult;
}

/* ------------------------------------------------------------ */
/*** void NAV_SetRegisterBits(PmodNAV *InstancePtr, u8 bInst, u8 bRegAddr,
**         u8 bMask, bool fValue)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst       - instrument selection for chip select: AG/MAG/ALT
**      bRegAddr    - the address of the register whose bits are set
**      bMask       - the mask indicating which bits are affected
**      fValue      - 1 if the bits are set or 0 if their bits are reset
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function sets the value of some bits (corresponding to the bMask)
**      of a register (indicated by bRegAddr) to 1 or 0 (indicated by fValue).
*/
void NAV_SetRegisterBits(PmodNAV *InstancePtr, u8 bInst, u8 bRegAddr, u8 bMask,
      bool fValue) {
   u8 bRegValue;
   NAV_ReadRegister(InstancePtr, bInst, bRegAddr, 1, &bRegValue);
   if (fValue) {
      // Set 1 value to the values that are 1 in the mask
      bRegValue |= bMask;
   } else {
      // Set 0 value to the values that are 1 in the mask
      bRegValue &= ~bMask;
   }
   NAV_WriteRegister(InstancePtr, bInst, bRegAddr, 1, &bRegValue);
}

/*-------------------------------------------------------------*/
/*  Accelerometer Specific Functions                           */
/*-------------------------------------------------------------*/
/* ------------------------------------------------------------ */
/*** void NAV_ReadAccel(PmodNAV *InstancePtr, s16 *X, s16 *Y, s16 *Z)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      X - the x component of the 3d vector being captured
**      Y - the y component of the 3d vector being captured
**      Z - the z component of the 3d vector being captured
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function captures raw accelerometer data over SPI
*/
void NAV_ReadAccel(PmodNAV *InstancePtr, s16 *X, s16 *Y, s16 *Z) {
   u8 iAclX_L, iAclX_H, iAclY_L, iAclY_H, iAclZ_L, iAclZ_H;
   u8 rgwRegVals[6];
   // Reads the bytes using the incrementing address functionality of the device
   NAV_ReadRegister(InstancePtr, NAV_INST_AG, NAV_ACL_OUT_X_L_XL, 6,
         (uint8_t *) rgwRegVals);
   iAclX_L = rgwRegVals[0];
   iAclX_H = rgwRegVals[1];
   iAclY_L = rgwRegVals[2];
   iAclY_H = rgwRegVals[3];
   iAclZ_L = rgwRegVals[4];
   iAclZ_H = rgwRegVals[5];
   // Combines the read values for each axis to obtain the 16-bit values
   *X = (s16) (((s16) iAclX_H << 8) | iAclX_L);
   *Y = (s16) ((s16) iAclY_H << 8) | iAclY_L;
   *Z = (s16) ((s16) iAclZ_H << 8) | iAclZ_L;
}

/* ------------------------------------------------------------ */
/*** void NAV_ReadAccelG(PmodNAV *InstancePtr, float *X, float *Y, float *Z)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      &AclXg      - the output parameter that will receive acceleration on
**                    X-axis (in "g")
**      &AclYg      - the output parameter that will receive acceleration on
**                    Y-axis (in "g")
**      &AclZg      - the output parameter that will receive acceleration on
**                    Z-axis (in "g")
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function is the main function used for reading accelerometer
**      values, providing the 3 current accelerometer values in g.
**      For each of the three values, converts the 16-bit value to the value
**      expressed in g, considering the currently selected g range.
*/
void NAV_ReadAccelG(PmodNAV *InstancePtr, float *X, float *Y, float *Z) {
   int16_t AclX, AclY, AclZ;
   AclX = 0;
   AclY = 0;
   AclZ = 0;

   NAV_ReadAccel(InstancePtr, &AclX, &AclY, &AclZ);
   *X = NAV_ConvertReadingToValueG(InstancePtr, AclX);
   *Y = NAV_ConvertReadingToValueG(InstancePtr, AclY);
   *Z = NAV_ConvertReadingToValueG(InstancePtr, AclZ);
}

/* ------------------------------------------------------------ */
/*** float NAV_ConvertReadingToValueG(PmodNAV *InstancePtr, s16 rawVal)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      rawVal      - the 2 bytes containing the reading.
**
**   Return Values:
**      float - the value of the acceleration in "g" corresponding to the 16
**              bits reading and the current g range
**
**   Errors:
**      None
**
**   Description:
**      Converts the value from the 16 bits reading to the float value (in g)
**      corresponding to the acceleration, considering the current selected g
**      range.
*/
float NAV_ConvertReadingToValueG(PmodNAV *InstancePtr, s16 rawVal) {
   // Convert the accelerometer value to G's.
   float dResult = ((float) rawVal) * InstancePtr->m_GRangeLSB;
   return dResult;
}

/* ------------------------------------------------------------ */
/*** void NAV_SetRangeXL(PmodNAV *InstancePtr, u8 bRangeXL)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bRangeXL    - the parameter specifying the g range. Can be one of the
**                    parameters from the following list:
**                       0   NAV_ACL_PAR_XL_2G   Parameter g range : +/- 2g
**                       1   NAV_ACL_PAR_XL_4G   Parameter g range : +/- 4g
**                       2   NAV_ACL_PAR_XL_8G   Parameter g range : +/- 8g
**                       3   NAV_ACL_PAR_XL_16G  Parameter g range : +/- 16g
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the appropriate g range bits in the
**      NAV_ACL_CTRL_REG6_XL register.
*/
void NAV_SetRangeXL(PmodNAV *InstancePtr, u8 bRangeXL) {
   InstancePtr->m_GRangeLSB = NAV_GetXLRangeLSB(bRangeXL);
   NAV_SetBitsInRegister(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG6_XL,
         NAV_ACL_MSK_RANGE_XL, bRangeXL, 3);
}

/* ------------------------------------------------------------ */
/*** float NAV_GetXLRangeLSB(u8 bRangeXL)
**
**   Parameters:
**      bRangeXL - the parameter specifying the g range. Can be one of the
**                 parameters from the following list:
**                    0   NAV_ACL_PAR_XL_2G   Parameter g range : +/- 2g
**                    1   NAV_ACL_PAR_XL_4G   Parameter g range : +/- 4g
**                    2   NAV_ACL_PAR_XL_8G   Parameter g range : +/- 8g
**                    3   NAV_ACL_PAR_XL_16G  Parameter g range : +/- 16g
**
**
**   Return Value:
**      float - the corresponding value of one LSB unit according to the range set
**
**   Errors:
**      None
**
**   Description:
**      The function computes the range LSB based on the set range parameter.
**      The argument values are between 0 and 3. If the argument is within the
**      accepted values range, it selects the range LSB value for further
**      computations of the "g" value. If value is outside this range, the
**      default value is set.
*/
float NAV_GetXLRangeLSB(u8 bRangeXL) {
   float gRangeLSB;
   switch (bRangeXL) {
   case NAV_ACL_PAR_XL_2G:
      gRangeLSB = 0.000061;
      break;
   case NAV_ACL_PAR_XL_4G:
      gRangeLSB = 0.000122;
      break;
   case NAV_ACL_PAR_XL_8G:
      gRangeLSB = 0.000244;
      break;
   case NAV_ACL_PAR_XL_16G:
      gRangeLSB = 0.000732;
      break;
   default:
      gRangeLSB = 0.000061;
      break;
   }
   return gRangeLSB;
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetRangeXL(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      uint8_t - returns the previously selected range from
**                NAV_ACL_CTRL_REG6_XL register. The return value is one of:
**                   0   NAV_ACL_PAR_XL_2G   Parameter g range: +/- 2g
**                   1   NAV_ACL_PAR_XL_4G   Parameter g range: +/- 4g
**                   2   NAV_ACL_PAR_XL_8G   Parameter g range: +/- 8g
**                   3   NAV_ACL_PAR_XL_16G  Parameter g range: +/- 16g
**
**   Errors:
**      None
**
**   Description:
**      The function reads the g range bits in the NAV_ACL_CTRL_REG6_XL register
**      and computes the range to be provided to the user. The accepted argument
**      values are between 0 and 3. If the value is not a valid one, the default
**      value for range is set
*/
u8 NAV_GetRangeXL(PmodNAV *InstancePtr) {
   u8 readRange, gRange;
   readRange = NAV_GetBitsInRegister(InstancePtr, NAV_INST_AG,
         NAV_ACL_CTRL_REG6_XL, 3, 2);
   switch (readRange) {
   case NAV_ACL_PAR_XL_2G:
      gRange = 2;
      break;
   case NAV_ACL_PAR_XL_4G:
      gRange = 4;
      break;
   case NAV_ACL_PAR_XL_8G:
      gRange = 8;
      break;
   case NAV_ACL_PAR_XL_16G:
      gRange = 16;
      break;
   default:
      gRange = 2;
      break;
   }
   return gRange;
}

/* ------------------------------------------------------------ */
/*** u8 NAV_DataAvailableXL(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      uint8_t - returns the data available status in NAV_ALIAS_STATUS_REG
**                register, for Accelerometer
**
**   Errors:
**      None
**
**   Description:
**      The function reads the NAV_ALIAS_STATUS_REG register and returns the
**      data available bit in it(1 or 0)
*/
u8 NAV_DataAvailableXL(PmodNAV *InstancePtr) {
   u8 status;
   NAV_ReadRegister(InstancePtr, NAV_INST_AG, NAV_ALIAS_STATUS_REG, 1, &status);
   return (status & (1 << 0));
}

/* ------------------------------------------------------------ */
/*** void NAV_ConfigIntXL(PmodNAV *InstancePtr, u8 bIntGen, bool aoi,
**         bool latch)
**
**   Parameters:
**      InstancePtr - Instance of PmodNAV
**      bIntGen     - The parameter indicating the interrupt generator. Can be
**                    one of the parameters from the following list
**                       NAV_ACL_MSK_XLIE_XL   1<<0
**                       NAV_ACL_MSK_XHIE_XL   1<<1
**                       NAV_ACL_MSK_YLIE_XL   1<<2
**                       NAV_ACL_MSK_YHIE_XL   1<<3
**                       NAV_ACL_MSK_ZLIE_XL   1<<4
**                       NAV_ACL_MSK_ZHIE_XL   1<<5
**                       NAV_ACL_MSK_GEN_6D    1<<6
**      aoi         - parameter indicating whether the interrupt generators are
**                    or-ed or and-ed together
**                       aoi 0  the interrupts are or-ed together
**                       aoi 1  the interrupts are and-ed together
**      latch       - parameter that sets or not the latch interrupt request
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function configures the interrupt register NAV_ACL_INT_GEN_CFG_XL
**      setting the interrupt generator. Sets the interrupt events to or-ed or
**      and-ed. Sets the interrupt event to be latched or not.
*/
void NAV_ConfigIntXL(PmodNAV *InstancePtr, u8 bIntGen, bool aoi, bool latch) {
   uint8_t temp = bIntGen;
   // Interrupt events are or-ed or and-ed
   if (aoi) {
      temp |= 0x80;
   }
   NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_INT_GEN_CFG_XL, temp);
   temp = 0;

   temp = NAV_ReadSPI(InstancePtr, NAV_INST_AG, NAV_ACL_GYRO_CTRL_REG4);
   // Latched interrupt enable is set in NAV_ACL_GYRO_CTRL_REG4 register
   if (latch) {
      temp |= 0x02;
   }
   NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_GYRO_CTRL_REG4, temp);
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetIntSrcXLG(PmodNAV *InstancePtr, u8 bInstMode)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInstMode   - parameter selecting between the two instruments, Accelerometer and Gyroscope:
**                       NAV_ACL_MODE_INST_A         0 - Accelerometer mode
**                       NAV_ACL_GYRO_MODE_INST_AG   1 - Gyroscope
**   Return Value:
**      uint8_t - returns the content of the NAV_ACL_INT_GEN_SRC_XL or
**                NAV_GYRO_INT_GEN_SRC_G, depending of bInstMode parameter
**
**   Errors:
**      None
**
**   Description:
**      The function returns the source of interrupt for either Accelerometer or
**      Gyroscope instruments.
*/
u8 NAV_GetIntSrcXLG(PmodNAV *InstancePtr, u8 bInstMode) {
   u8 intSrc;
   if (bInstMode == NAV_ACL_MODE_INST_A) {
      intSrc = NAV_ReadSPI(InstancePtr, NAV_INST_AG, NAV_ACL_INT_GEN_SRC_XL);
      // Check if the IA_XL (interrupt active) bit is set
      if (intSrc & (1 << 6)) {
         return intSrc;
      }
      intSrc &= 0x3F;
   }

   else if (bInstMode == NAV_ACL_GYRO_MODE_INST_AG) {
      intSrc = NAV_ReadSPI(InstancePtr, NAV_INST_AG, NAV_GYRO_INT_GEN_SRC_G);
      // Check if the IA_G (interrupt active) bit is set
      if (intSrc & (1 << 6)) {
         return intSrc;
      }
      intSrc &= 0x3F;
   }

   // Get rid of non return warning
   return -1;
}

/* ------------------------------------------------------------ */
/*** void NAV_SetIntThresholdXL(PmodNAV *InstancePtr, float thValX, float thValY, float thValZ, u8 intDuration, bool wait)
**
**   Parameters:
**      InstancePtr            - instance of PmodNAV
**      thValX, thValY, thValZ - Parameters containing the threshold value on
**                               each axis
**      intDuration            - parameter indicating the duration of the
**                               enter/exit interrupt
**      wait                   - parameter enabling or disabling the wait time
**                               before exiting the interrupt routine.
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the interrupt threshold for each axis and also the
**      duration of the enter/exit interrupt. Enables or disables the wait on
**      duration before exiting interrupt.
*/
void NAV_SetIntThresholdXL(PmodNAV *InstancePtr, float thValX, float thValY,
      float thValZ, u8 intDuration, bool wait) {
   u8 bthValX, bthValY, bthValZ;
   // Converts the float value in g to raw accel data to be written in
   // INT_GEN_THS_X/Y/Z_XL registers
   bthValX = (u8) (thValX / (InstancePtr->m_GRangeLSB));
   bthValY = (u8) (thValY / (InstancePtr->m_GRangeLSB));
   bthValZ = (u8) (thValZ / (InstancePtr->m_GRangeLSB));

   NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_INT_GEN_THS_X_XL, bthValX);
   NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_INT_GEN_THS_Y_XL, bthValY);
   NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_INT_GEN_THS_Z_XL, bthValZ);

   // Write duration and wait to NAV_ACL_INT_GEN_DUR_XL register
   u8 temp;
   temp = (intDuration & 0x7F);
   if (wait)
      temp |= 0x80;
   NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_ACL_INT_GEN_DUR_XL, temp);
}

/*-------------------------------------------------------------*/
/*  Gyro specific functions                                    */
/*-------------------------------------------------------------*/

/* ------------------------------------------------------------ */
/*** void NAV_ReadGyro(PmodNAV *InstancePtr, s16 *GX, s16 *GY, s16 *GZ)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      &GX         - the output parameter that will receive gyro value on
**                    X-axis - 16 bits value
**      &GY         - the output parameter that will receive gyro value on
**                    Y-axis - 16 bits value
**      &GZ         - the output parameter that will receive gyro value on
**                    Z-axis - 16 bits value
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function provides the 3 "raw" 16-bit values read from the gyro.
**        - It reads simultaneously the gyro value on three axes in a buffer of
**          6 bytes using the ReadRegister function
**        - For each of the three axes, combines the two bytes in order to get
**          a 16-bit value
*/
void NAV_ReadGyro(PmodNAV *InstancePtr, s16 *GX, s16 *GY, s16 *GZ) {
   u8 iGX_L, iGX_H, iGY_L, iGY_H, iGZ_L, iGZ_H;
   u8 rgwRegVals[6];
   // Reads the bytes using the incrementing address functionality of the device.
   NAV_ReadRegister(InstancePtr, NAV_INST_AG, NAV_GYRO_OUT_X_L_G, 6,
         (u8 *) rgwRegVals);
   iGX_L = rgwRegVals[0];
   iGX_H = rgwRegVals[1];
   iGY_L = rgwRegVals[2];
   iGY_H = rgwRegVals[3];
   iGZ_L = rgwRegVals[4];
   iGZ_H = rgwRegVals[5];
   // Combines the read values for each axis to obtain the 16-bits values
   *GX = (s16) ((s16) iGX_H << 8) | iGX_L;
   *GY = (s16) ((s16) iGY_H << 8) | iGY_L;
   *GZ = (s16) ((s16) iGZ_H << 8) | iGZ_L;
}

/* ------------------------------------------------------------ */
/*  void NAV_ReadGyroDps(PmodNAV *InstancePtr, float *X, float *Y, float *Z)
**
**  Parameters:
**      InstancePtr - instance of PmodNAV
**      &GXdps      - the output parameter that will receive gyro values on
**                    X-axis (in "dps")
**      &GYdps      - the output parameter that will receive gyro values on
**                    Y-axis (in "dps")
**      &GZdps      - the output parameter that will receive gyro values on
**                    Z-axis (in "dps")
**
**  Return Values:
**      None
**
**  Errors:
**      None
**
**  Description:
**      This function is the main function used for gyro values reading,
**      providing the 3 current gyro values in dps. For each of the three
**      values, converts the 16-bit raw value to the value expressed in dps,
**      considering the currently selected dps range.
*/
void NAV_ReadGyroDps(PmodNAV *InstancePtr, float *X, float *Y, float *Z) {
   s16 GX, GY, GZ;

   NAV_ReadGyro(InstancePtr, &GX, &GY, &GZ);
   *X = NAV_ConvertReadingToValueDPS(InstancePtr, GX);
   *Y = NAV_ConvertReadingToValueDPS(InstancePtr, GY);
   *Z = NAV_ConvertReadingToValueDPS(InstancePtr, GZ);
}

/* ------------------------------------------------------------ */
/*** float NAV_ConvertReadingToValueDPS(PmodNAV *InstancePtr, s16 rawVal)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      rawVal      - the 2 bytes containing the reading.
**
**   Return Values:
**      float - the value of the gyro in "dps" corresponding to the 16 bits
**              reading and the current dps range
**
**   Errors:
**      None
**
**   Description:
**      Converts the value from the 16 bits reading to the float value (in dps)
**      corresponding to the degrees value, considering the current selected dps
**      range.
**
*/
float NAV_ConvertReadingToValueDPS(PmodNAV *InstancePtr, s16 rawVal) {
   // Convert the gyro value to dps.
   float dResult = ((s16) rawVal) * (InstancePtr->m_DPSRangeLSB);
   return dResult;
}

/* ------------------------------------------------------------ */
/*** float NAV_GetGRangeLSB(uint8_t bRangeG)
**
**   Parameters:
**      bRangeG - the parameter specifying the dps range. Can be one of the
**                parameters from the following list:
**                   0   NAV_GYRO_PAR_G_245DPS  Parameter dps range : +/- 245dps
**                   1   NAV_GYRO_PAR_G_500DPS  Parameter dps range : +/- 500dps
**                   3   NAV_GYRO_PAR_G_2kDPS   Parameter dps range : +/- 2kdps
**
**   Return Value:
**      float - corresponding value of one LSB unit according to the range set
**
**   Errors:
**      None
**
**   Description:
**      The function computes the range LSB based on the set range parameter.
**      The accepted argument values are between 0 and 3. If the argument is
**      within the accepted values range, it selects the range LSB value for
**      further computations of the "dps" value. If value is outside this range,
**      the default value is set.
*/
float NAV_GetGRangeLSB(uint8_t bRangeG) {
   float gRangeLSB;
   switch (bRangeG) {
   case NAV_GYRO_PAR_G_245DPS:
      gRangeLSB = 0.00875;
      break;
   case NAV_GYRO_PAR_G_500DPS:
      gRangeLSB = 0.0175;
      break;
   case NAV_GYRO_PAR_G_2kDPS:
      gRangeLSB = 0.07;
      break;
   default:
      gRangeLSB = 0.00875;
      break;
   }
   return gRangeLSB;
}

/* ------------------------------------------------------------ */
/*** void NAV_SetRangeG(PmodNAV *InstancePtr, u8 bRangeG)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bGRangeG    - the parameter specifying the dps range. Can be one of the
**                    parameters from the following list:
**                      0 NAV_GYRO_PAR_G_245DPS Parameter dps range: +/- 245dps
**                      1 NAV_GYRO_PAR_G_500DPS Parameter dps range: +/- 500dps
**                      3 PAR_G_2000DPS         Parameter dps range: +/- 2000dps
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the appropriate dps range bits in the
**      NAV_GYRO_CTRL_REG1_G register.
*/
void NAV_SetRangeG(PmodNAV *InstancePtr, u8 bRangeG) {
   InstancePtr->m_DPSRangeLSB = NAV_GetGRangeLSB(bRangeG);
   NAV_SetBitsInRegister(InstancePtr, NAV_INST_AG, NAV_GYRO_CTRL_REG1_G,
         NAV_GYRO_MSK_RANGE_G, bRangeG, 3);
}

/* ------------------------------------------------------------ */
/*** float NAV_GetRangeG(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      float - returns the previously selected range from NAV_GYRO_CTRL_REG1_G
**              register. The return value is one of:
**                 0 NAV_GYRO_PAR_G_245DPS Parameter dps range: +/- 245dps
**                 1 NAV_GYRO_PAR_G_500DPS Parameter dps range: +/- 500dps
**                 3 PAR_G_2000DPS         Parameter dps range: +/- 2000dps
**   Errors:
**      None
**
**   Description:
**      The function reads the g range bits in the NAV_GYRO_CTRL_REG1_G register
**      and computes the range to be provided to the user. If the value is not a
**      valid one, the default value for range is set
*/
float NAV_GetRangeG(PmodNAV *InstancePtr) {
   u16 readRange, gRange;
   readRange = NAV_GetBitsInRegister(InstancePtr, NAV_INST_AG,
         NAV_GYRO_CTRL_REG1_G, 3, 2);
   switch (readRange) {
   case NAV_GYRO_PAR_G_245DPS:
      gRange = 245;
      break;
   case NAV_GYRO_PAR_G_500DPS:
      gRange = 500;
      break;
   case NAV_GYRO_PAR_G_2kDPS:
      gRange = 2000;
      break;
   default:
      gRange = 245;
      break;
   }
   return gRange;
}

/* ------------------------------------------------------------ */
/*** u8 NAV_DataAvailableG(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      uint8_t - returns the data available status in NAV_ALIAS_STATUS_REG
**                register, for gyro
**
**   Errors:
**      None
**
**   Description:
**      The function reads the NAV_ALIAS_STATUS_REG register and returns the
**      data available bit in it
*/
u8 NAV_DataAvailableG(PmodNAV *InstancePtr) {
   uint8_t status;
   NAV_ReadRegister(InstancePtr, NAV_INST_AG, NAV_ALIAS_STATUS_REG, 1, &status);
   return ((status & (1 << 1)) >> 1);
}

/* ------------------------------------------------------------ */
/*** void NAV_ConfigIntG(PmodNAV *InstancePtr, u8 bIntGen, bool aoi, bool latch)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bIntGen     - The parameter indicating the interrupt generator. Can be
**                    one of the parameters from the following list
**                       NAV_GYRO_MSK_XLIE_G   1<<0
**                       NAV_GYRO_MSK_XHIE_G   1<<1
**                       NAV_GYRO_MSK_YLIE_G   1<<2
**                       NAV_GYRO_MSK_YHIE_G   1<<3
**                       NAV_GYRO_MSK_ZLIE_G   1<<4
**                       NAV_GYRO_MSK_ZHIE_G   1<<5
**      aoi         - parameter indicating whether the interrupt generators are
**                    or-ed or and-ed together
**                       aoi 0  the interrupts are or-ed together
**                       aoi 1  the interrupts are and-ed together
**      latch       - parameter that sets or not the latch interrupt request
**                       latch 0 interrupt requests are not latched
**                       latch 1 interrupt requests are latched
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function configures the interrupt register NAV_GYRO_INT_GEN_CFG_G
**      setting the interrupt generator. Sets the interrupt events to or-ed or
**      and-ed. Sets the interrupt event to be latched or not.
*/
void NAV_ConfigIntG(PmodNAV *InstancePtr, u8 bIntGen, bool aoi, bool latch) {
   u8 temp = bIntGen;
   if (aoi)
      temp |= 0x80;
   if (latch)
      temp |= 0x40;
   NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_GYRO_INT_GEN_CFG_G, temp);
}

/* ------------------------------------------------------------ */
/*** void NAV_SetIntThresholdG(PmodNAV *InstancePtr, float thVal, u16 axis,
**         bool drCntMode, u8 intDuration, bool wait)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      thVal       - Parameters containing the threshold value for one of the
**                    axes
**      axis        - parameter indicating the axis for which the threshold is
**                    set. It can be one of the following values:
**                       NAV_IMU_X_AXIS   0
**                       NAV_IMU_Y_AXIS   1
**                       NAV_IMU_Z_AXIS   2
**      drCntMode   - counter mode for interrupt
**      intDuration - parameter indicating the duration of the enter/exit
**                    interrupt
**      wait        - parameter enabling or disabling the wait time before
**                    exiting the interrupt routine.
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the interrupt threshold for the selected axis, the
**      counter mode for interrupt and also the duration of the enter/exit
**      interrupt. Enables or disables the wait on duration before exiting
**      interrupt.
*/
void NAV_SetIntThresholdG(PmodNAV *InstancePtr, float thVal, u16 axis,
      bool drCntMode, u8 intDuration, bool wait) {
   u8 buffer[2];
   u16 bthVal;

   // Convert the float value in g to raw accel data to be written in
   // INT_GEN_THS_XH/XL/YH/YL/ZH/ZL_G registers
   bthVal = (u16) (thVal / (InstancePtr->m_DPSRangeLSB));
   // Split bytes
   buffer[0] = (bthVal & 0x7F00) >> 8;
   buffer[1] = (bthVal & 0x00FF);
   switch (axis) {
   case NAV_IMU_X_AXIS:
      // Set the first bit, decrement or reset counter mode for interrupt
      buffer[0] |= drCntMode << 8;
      NAV_WriteSPI(InstancePtr, NAV_INST_AG,
            NAV_GYRO_INT_GEN_THS_XH_G + (axis * 2), buffer[0]);
      NAV_WriteSPI(InstancePtr, NAV_INST_AG,
            NAV_GYRO_INT_GEN_THS_XH_G + 1 + (axis * 2), buffer[1]);
      break;
   case NAV_IMU_Y_AXIS:
      NAV_WriteSPI(InstancePtr, NAV_INST_AG,
            NAV_GYRO_INT_GEN_THS_XH_G + (axis * 2), buffer[0]);
      NAV_WriteSPI(InstancePtr, NAV_INST_AG,
            NAV_GYRO_INT_GEN_THS_XH_G + 1 + (axis * 2), buffer[1]);
      break;
   case NAV_IMU_Z_AXIS:
      NAV_WriteSPI(InstancePtr, NAV_INST_AG,
            NAV_GYRO_INT_GEN_THS_XH_G + (axis * 2), buffer[0]);
      NAV_WriteSPI(InstancePtr, NAV_INST_AG,
            NAV_GYRO_INT_GEN_THS_XH_G + 1 + (axis * 2), buffer[1]);
      break;
   default:
      break;
   }
   // Write duration and wait to NAV_GYRO_INT_GEN_DUR_G
   u8 temp;
   temp = (intDuration & 0x7F);
   if (wait)
      temp |= 0x80;
   NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_GYRO_INT_GEN_DUR_G, temp);
}

/* ------------------------------------------------------------ */
/*** void NAV_ConfigInt(PmodNAV *InstancePtr, u8 bIntPin, u8 bIntGenMask,
**         u8 bActiveType, u8 bOutputType)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bIntPin     - The parameter indicating the INT pin number, INT1 or INT2.
**                    Can be one of the parameters from the following list
**                       0   NAV_INT_PIN_1
**                       1   NAV_INT_PIN_2
**
**      bIntGenMask - the events that trigger the interrupt. Can be one or more
**                    (OR-ed) parameters from the following list
**                       NAV_ACL_GYRO_MSK_INT1_IG_G        1<<7
**                       MSK_INT_IG_XL                     1<<6
**                       MSK_INT_FSS5                      1<<5
**                       MSK_INT_OVR                       1<<4
**                       MSK_INT_FTH                       1<<3
**                       MSK_INT_Boot                      1<<2
**                       NAV_ALT_MSK_INT_DRDY_G            1<<1
**                       NAV_ALT_MSK_INT_DRDY_XL           1<<0    Overrun
**
**                       NAV_ACL_GYRO_MSK_INT2_INACT       1<<7
**                       NAV_ACL_GYRO_MSK_INT2_FSS5        1<<5
**                       NAV_ACL_GYRO_MSK_INT2_OVR         1<<4
**                       NAV_ACL_GYRO_MSK_INT2_FTH         1<<3
**                       NAV_ACL_GYRO_MSK_INT2_DRDY_TEMP   1<<2
**                       NAV_ACL_GYRO_MSK_INT2_DRDY_G      1<<1
**                       NAV_ACL_GYRO_MSK_INT2_DRDY_XL     1<<0
**
**      bActiveType - The parameter indicating the interrupt pin is active high
**                    or low. Can be one of the parameters from the following
**                    list
**                       0   NAV_PAR_INT_ACTIVEHIGH
**                       1   NAV_PAR_INT_ACTIVELOW
**      bOutputType - The parameter indicating the interrupt pin is set pushpull
**                    or opendrain. Can be one of the parameters from the
**                    following list
**                       0   NAV_PAR_INT_PUSHPULL
**                       1   NAV_PAR_INT_OPENDRAIN
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the interrupt generator on one of the INT1 or INT2
**      pins. Also sets the active type of the interrupt and the output type
*/
void NAV_ConfigInt(PmodNAV *InstancePtr, u8 bIntPin, u8 bIntGenMask,
      u8 bActiveType, u8 bOutputType) {
   // Set interrupt pin generator
   if (bIntPin == NAV_INT_PIN_1) {
      NAV_SetRegisterBits(InstancePtr, NAV_INST_AG, NAV_ACL_GYRO_INT1_CTRL,
            bIntGenMask, 1);

   } else if (bIntPin == NAV_INT_PIN_2) {
      NAV_SetRegisterBits(InstancePtr, NAV_INST_AG, NAV_ACL_GYRO_INT2_CTRL,
            bIntGenMask, 1);
   }
   // Configure NAV_IMU_CTRL_REG8
   uint8_t temp;
   temp = NAV_ReadSPI(InstancePtr, NAV_INST_AG, NAV_IMU_CTRL_REG8);
   // Set interrupt active low or high
   if (bActiveType == NAV_PAR_INT_ACTIVELOW) {
      temp |= (1 << 5);
   } else {
      temp &= ~(1 << 5);
   }
   // Set output type to pushpull or opendrain
   if (bOutputType == NAV_PAR_INT_PUSHPULL) {
      temp &= ~(1 << 4);
   } else {
      temp |= (1 << 4);
   }
   NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_IMU_CTRL_REG8, temp);
}

/*-------------------------------------------------------------*/
/*  Magmetometer specific functions                            */
/*-------------------------------------------------------------*/

/*** void NAV_ReadMag(PmodNAV *InstancePtr, s16 *MagX, s16 *MagY, s16 *MagZ)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      &MagX       - the output parameter that will receive magnetometer value
**                    on X axis - 16 bits value
**      &MagY       - the output parameter that will receive magnetometer value
**                    on Y-axis - 16 bits value
**      &MagZ       - the output parameter that will receive magnetometer value
**                    on Z-axis - 16 bits value
**
**   Return Values:
**      None
**
**   Errors:
**      None
**
**   Description:
**      This function provides the 3 "raw" 16-bit values read from the
**      magnetometer.
**       - It reads simultaneously the magnetic field value on three axes in a
**         buffer of 6 bytes using the ReadRegister function
**       - For each of the three axes, combines the two bytes in order to get a
**         16-bit value
*/
void NAV_ReadMag(PmodNAV *InstancePtr, s16 *MagX, s16 *MagY, s16 *MagZ) {
   u8 iMagX_L, iMagX_H, iMagY_L, iMagY_H, iMagZ_L, iMagZ_H;
   u8 status;
   u8 rgwRegVals[6];
   do {
      NAV_ReadRegister(InstancePtr, NAV_INST_MAG, NAV_MAG_STATUS_REG_M, 1,
            &status);
   } while ((status & 0x08) == 0);

   // Reads the bytes using the incrementing address functionality of the device
   NAV_ReadRegister(InstancePtr, NAV_INST_MAG, NAV_MAG_OUT_X_L_M, 6,
         (u8 *) rgwRegVals);
   iMagX_L = rgwRegVals[0];
   iMagX_H = rgwRegVals[1];
   iMagY_L = rgwRegVals[2];
   iMagY_H = rgwRegVals[3];
   iMagZ_L = rgwRegVals[4];
   iMagZ_H = rgwRegVals[5];
   // Combines the read values for each axis to obtain the 16-bits values
   *MagX = ((s16) iMagX_H << 8) | iMagX_L;
   *MagY = ((s16) iMagY_H << 8) | iMagY_L;
   *MagZ = ((s16) iMagZ_H << 8) | iMagZ_L;
}
/* ------------------------------------------------------------ */
/*** void NAV_ReadMagGauss(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Values:
**      InstancePtr->MagData - the vector representation of the magnetometer
**                             reading in gauss
**
**   Errors:
**      None
**
**   Description:
**      This function is the main function used for magnetic field values
**      reading, providing the 3 current magnetometer values in. For each of the
**      three values, converts the 16-bit raw value to the value expressed in
**      gauss, considering the currently selected Gauss range.
*/
void NAV_ReadMagGauss(PmodNAV *InstancePtr) {
   s16 MagX, MagY, MagZ;
   NAV_ReadMag(InstancePtr, &MagX, &MagY, &MagZ);
   InstancePtr->magData.X = NAV_ConvertReadingToValueGauss(InstancePtr, MagX);
   InstancePtr->magData.Y = NAV_ConvertReadingToValueGauss(InstancePtr, MagY);
   InstancePtr->magData.Z = NAV_ConvertReadingToValueGauss(InstancePtr, MagZ);
}

/* ------------------------------------------------------------ */
/*** float NAV_ConvertReadingToValueGauss(PmodNAV *InstancePtr, s16 rawVal)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      rawVal      - the 2 bytes containing the raw reading.
**
**   Return Values:
**      float - the value of the magnetic field in "gauss" corresponding to the
**              16 bits reading and the currently selected range
**
**   Errors:
**      None
**
**   Description:
**      Converts the value from the 16 bits reading to the float value (in
**      gauss) corresponding to the magnetic field value, considering the
**      current selected gauss range.
*/
float NAV_ConvertReadingToValueGauss(PmodNAV *InstancePtr, s16 rawVal) {
   float dResult = ((float) rawVal) * InstancePtr->m_GaussRangeLSB;
   return dResult;
}

/* ------------------------------------------------------------ */
/*** void NAV_SetRangeMAG(PmodNAV *InstancePtr, u8 bRangeMAG)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bRangeMAG   - the parameter specifying the g range. Can be one of the
**                    parameters from the following list:
**                       0   NAV_MAG_PAR_MAG_4GAUSS  Parameter g range: +/- 4g
**                       1   NAV_MAG_PAR_MAG_8GAUSS  Parameter g range: +/- 8g
**                       2   NAV_MAG_PAR_MAG_12GAUSS Parameter g range: +/- 12g
**                       3   NAV_MAG_PAR_MAG_16GAUSS Parameter g range: +/- 16g
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the appropriate gauss range bits in the
**      NAV_MAG_CTRL_REG2_M register.
*/
void NAV_SetRangeMAG(PmodNAV *InstancePtr, u8 bRangeMAG) {
   InstancePtr->m_GaussRangeLSB = NAV_GetMAGRangeLSB(bRangeMAG);
   NAV_SetBitsInRegister(InstancePtr, NAV_INST_MAG, NAV_MAG_CTRL_REG2_M,
         NAV_MAG_MSK_RANGE_MAG, bRangeMAG, 5);
}

/* ------------------------------------------------------------ */
/*** float NAV_GetMAGRangeLSB(uint8_t bRangeMAG)
**
**   Parameters:
**      uint8_t bRangeMAG - the parameter specifying the gauss range. Can be one
**                          of the parameters from the following list:
**                0   NAV_MAG_PAR_MAG_4GAUSS  Parameter gauss range: +/- 4gauss
**                1   NAV_MAG_PAR_MAG_8GAUSS  Parameter gauss range: +/- 8gauss
**                2   NAV_MAG_PAR_MAG_12GAUSS Parameter gauss range: +/- 12gauss
**                3   NAV_MAG_PAR_MAG_16GAUSS Parameter gauss range: +/- 16gauss
**
**   Return Value:
**      float - returns the LSB unit value specific for each available range
**
**   Errors:
**      None
**
**   Description:
**      The function computes the range LSB based on the bRangeMAG parameter.
**      The accepted argument values are between 0 and 3. If the argument is
**      within the accepted values range, it selects the range LSB value for
**      further computations of the "gauss" value. If value is outside this
**      range, the default value is set.
*/
float NAV_GetMAGRangeLSB(uint8_t bRangeMAG) {
   float gRangeLSB;
   switch (bRangeMAG) {
   case NAV_MAG_PAR_MAG_4GAUSS:
      gRangeLSB = 0.00014;
      break;
   case NAV_MAG_PAR_MAG_8GAUSS:
      gRangeLSB = 0.00029;
      break;
   case NAV_MAG_PAR_MAG_12GAUSS:
      gRangeLSB = 0.00043;
      break;
   case NAV_MAG_PAR_MAG_16GAUSS:
      gRangeLSB = 0.00058;
      break;
   default:
      gRangeLSB = 0.00014;
      break;
   }
   return gRangeLSB;
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetRangeMAG(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      uint8_t - returns the previously set range value
**                The return value is one of:
**                   0   NAV_MAG_PAR_MAG_4GAUSS    Parameter g range: +/- 4g
**                   1   NAV_MAG_PAR_MAG_8GAUSS    Parameter g range: +/- 8g
**                   2   NAV_MAG_PAR_MAG_12GAUSS   Parameter g range: +/- 12g
**                   3   NAV_MAG_PAR_MAG_16GAUSS   Parameter g range: +/- 16g
**
**   Errors:
**      None
**
**   Description:
**      The function reads the gauss range bits in the NAV_MAG_CTRL_REG2_M
**      register and computes the range to be provided to the user. If value is
**      outside this range, the default value is set
*/
u8 NAV_GetRangeMAG(PmodNAV *InstancePtr) {
   u8 readRange, gRange;
   readRange = NAV_GetBitsInRegister(InstancePtr, NAV_INST_MAG,
         NAV_MAG_CTRL_REG2_M, 5, 2);
   switch (readRange) {
   case NAV_MAG_PAR_MAG_4GAUSS:
      gRange = 4;
      break;
   case NAV_MAG_PAR_MAG_8GAUSS:
      gRange = 8;
      break;
   case NAV_MAG_PAR_MAG_12GAUSS:
      gRange = 12;
      break;
   case NAV_MAG_PAR_MAG_16GAUSS:
      gRange = 16;
      break;
   default:
      gRange = 4;
      break;
   }
   return gRange;
}

/* ------------------------------------------------------------ */
/*** u8 NAV_DataAvailableMAG(PmodNAV *InstancePtr, u8 axis)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      axis        - parameter indicating the axis for which the data
**                    availability is checked. It can be one of the values:
**                       NAV_IMU_X_AXIS   0
**                       NAV_IMU_Y_AXIS   1
**                       NAV_IMU_Z_AXIS   2
**
**   Return Value:
**       uint8_t - returns the data available status in NAV_MAG_STATUS_REG_M
**                 register, for the selected axis
**
**   Errors:
**      None
**
**   Description:
**      The function reads the NAV_MAG_STATUS_REG_M register and returns the
**      data available bit in it(1 or 0), for each of the axes
**
*/
u8 NAV_DataAvailableMAG(PmodNAV *InstancePtr, u8 axis) {
   u8 status;
   NAV_ReadRegister(InstancePtr, NAV_INST_MAG, NAV_MAG_STATUS_REG_M, 1,
         &status);
   return ((status & (1 << axis)) >> axis);
}

/* ------------------------------------------------------------ */
/*** void NAV_ConfigIntMAG(PmodNAV *InstancePtr, u8 bIntGen, u8 bActiveType,
**         bool latch)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bIntGen     - interrupt generator sources. It can be one of the
**                    following:
**                       NAV_MAG_MSK_ZIEN_MAG   1<<5
**                       NAV_MAG_MSK_YIEN_MAG   1<<6
**                       NAV_MAG_MSK_XIEN_MAG   1<<7
**      bActiveType - interrupt active low or high parameter:
**                       NAV_PAR_INT_ACTIVEHIGH      0
**                       NAV_PAR_INT_ACTIVELOW       1
**      latch       - parameter indicating the interrupt event is latched or not
**  Return Value:
**      None
**
**  Errors:
**      None
**  Description:
**      The function configures the interrupts for magnetometer instruments. It
**      sets the interrupt generator for the three axes. It sets the active
**      level, low or high for the interrupt event. It enables/disables the
**      interrupt latching
**
*/
void NAV_ConfigIntMAG(PmodNAV *InstancePtr, u8 bIntGen, u8 bActiveType,
      bool latch) {
   // Mask out non-generator bits (0-4)
   u8 config = (bIntGen & 0xE0);
   // IEA bit is 0 for active-low, 1 for active-high.
   if (bActiveType == NAV_PAR_INT_ACTIVEHIGH)
      config |= (1 << 2);
   // IEL bit is 0 for latched, 1 for not-latched
   if (!latch)
      bIntGen |= (1 << 1);
   // As long as we have at least 1 generator, enable the interrupt
   if (bIntGen != 0)
      config |= (1 << 0);

   NAV_WriteSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_INT_CFG_M, config);
}

/* ------------------------------------------------------------ */
/*** void NAV_SetIntThresholdM(PmodNAV *InstancePtr, float thVal)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      thVal - the threshold value set to all axes
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the interrupt threshold for the magnetometer
**      instrument
*/
void NAV_SetIntThresholdM(PmodNAV *InstancePtr, float thVal) {
   u8 buffer[2];
   u16 bthVal;
   // Converts the float value in gauss to raw magnetic field data to be written
   // in NAV_MAG_INT_THS_L/NAV_MAG_INT_THS_H registers
   bthVal = (u16) (thVal / (InstancePtr->m_GaussRangeLSB));
   // Split bytes
   // Make sure the first bit of the High byte is 0, for correct functionality
   // of the device
   buffer[0] = (bthVal & 0x7F00) >> 8;
   buffer[1] = (bthVal & 0x00FF);
   NAV_WriteSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_INT_THS_H, buffer[0]);
   NAV_WriteSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_INT_THS_L, buffer[1]);
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetIntSrcMAG(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      uint8_t - returns the interrupt sources for magnetometer instrument,
**                after reading NAV_MAG_INT_SRC_M register
**
**   Errors:
**      None
**
**   Description:
**      The function returns the source of interrupt for magnetometer instrument.
**
*/
u8 NAV_GetIntSrcMAG(PmodNAV *InstancePtr) {
   u8 intSrc;
   intSrc = NAV_ReadSPI(InstancePtr, NAV_INST_MAG, NAV_MAG_INT_SRC_M);
   // Check if the INT (interrupt active) bit is set
   if (intSrc & (1 << 0)) {
      return (intSrc);   // & 0xFE);
   }
   intSrc &= 0xFE;
   // Get rid of end of function warning
   return intSrc;
}

/*-------------------------------------------------------------*/
/*  Altimeter specific functions                               */
/*-------------------------------------------------------------*/

/*** int NAV_ReadPressure(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Values:
**      int - returns the raw measured pressure value later used for converting
**            it in hPa
**
**   Errors:
**      None
**
**   Description:
**      This function provides the 3 "raw" 16-bit values read from the barometer
**      instrument.
**       - It reads the pressure value from the low, middle and high registers
**         using the ReadRegister function
**       - Combines the three registers to obtain a 24-bit value for the
**         pressure
**      The value of the 3 bytes is right justified within the returned 32 bit
**      value.
*/
int NAV_ReadPressure(PmodNAV *InstancePtr) {
   u8 iPress_XL, iPress_L, iPress_H;
   u8 rgwRegVals[3];
   int dataPress = 0;
   NAV_ReadRegister(InstancePtr, NAV_INST_ALT, NAV_ALT_PRESS_OUT_XL, 3,
         (u8 *) rgwRegVals);
   iPress_XL = rgwRegVals[0];
   iPress_L = rgwRegVals[1];
   iPress_H = rgwRegVals[2];
   dataPress = (iPress_H << 16) | iPress_L << 8 | iPress_XL;
   return dataPress;
}

/* ------------------------------------------------------------ */
/*** void NAV_ReadPressurehPa(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Values:
**      float - returns the value of measured pressure in hPa
**
**   Errors:
**      None
**
**   Description:
**      This function provides the pressure in hPa
**
*/
void NAV_ReadPressurehPa(PmodNAV *InstancePtr) {
   int dataRawFull;
   dataRawFull = NAV_ReadPressure(InstancePtr);
   // Check if there is a negative value
   if (dataRawFull & 0x00800000) {
      dataRawFull |= 0xFF000000;
   }

   InstancePtr->hPa = ((float)dataRawFull / 4096.0);
}

/* ------------------------------------------------------------ */
/*** void NAV_ReadTempC(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Values:
**      InstancePtr->tempC - the function returns the value of the read
**                           temperature in degrees Celsius via the PmodNAV
**                           device
**
**   Errors:
**      None
**
**   Description:
**      The formula used is taken from the same technical note as for pressure.
**      T = 42.5 + TempRaw *1/480, where 480 LSB
*/
void NAV_ReadTempC(PmodNAV *InstancePtr) {
   u8 rgwRegVals[2], tempL, tempH;
   NAV_ReadRegister(InstancePtr, NAV_INST_ALT, NAV_ALT_TEMP_OUT_L, 2,
         (u8 *) rgwRegVals);
   tempL = rgwRegVals[0];
   tempH = rgwRegVals[1];
   s16 temp = (s16) (tempH << 8 | tempL);
   // Datasheet formula used for converting to temperature in degrees Celsius
   // from raw values
   InstancePtr->tempC = 42.5 + (temp * 0.002083);
}

/* ------------------------------------------------------------ */
/*** u8 NAV_TempAvailableALT(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      uint8_t - returns the temperature available status in
**                NAV_ALIAS_STATUS_REG register, for altimeter
**
**   Errors:
**      None
**
**   Description:
**      The function reads the NAV_ALIAS_STATUS_REG register and returns the
**      temperature available bit in it(1 or 0)
*/
u8 NAV_TempAvailableALT(PmodNAV *InstancePtr) {
   u8 status;
   NAV_ReadRegister(InstancePtr, NAV_INST_ALT, NAV_ALIAS_STATUS_REG, 1,
         &status);
   return (status & (1 << 0));
}

/* ------------------------------------------------------------ */
/*** u8 NAV_DataAvailableALT(PmodNAV *InstancePtr)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**
**   Return Value:
**      uint8_t - returns the data available status in NAV_ALIAS_STATUS_REG
**                register, for altimeter
**
**   Errors:
**      None
**
**   Description:
**      The function reads the NAV_ALIAS_STATUS_REG register and returns the
**      data available bit in it(1 or 0)
*/
u8 NAV_DataAvailableALT(PmodNAV *InstancePtr) {
   u8 status;
   NAV_ReadRegister(InstancePtr, NAV_INST_ALT, NAV_ALIAS_STATUS_REG, 1,
         &status);
   return ((status & (1 << 1)) >> 1);
}

/* ------------------------------------------------------------ */
/*** void NAV_ConfigIntALT(PmodNAV *InstancePtr, u8 bIntGen, u8 bActiveType,
**         u8 bOutputType, u8 dataSignalVal, bool intEnable, bool latch,
**         u8 intLevel)
**
**   Parameters:
**      InstancePtr   - instance of PmodNAV
**      bIntGen       - interrupt generator sources. It can be one of the
**                      following:
**                         NAV_ALT_MSK_INT_F_EMPTY 1<<3
**                         NAV_ALT_MSK_INT_F_FTH   1<<2
**                         NAV_ALT_MSK_INT_F_OVR   1<<1
**                         NAV_ALT_MSK_INT_DRDY    1<<0
**      bActiveType   - interrupt active low or high parameter:
**                         NAV_PAR_INT_ACTIVEHIGH   0
**                         NAV_PAR_INT_ACTIVELOW    1
**      dataSignalVal - INT_S bits value, representing the interrupt
**                      configurations, data signal, pressure high, low, or
**                      high, and low it can be one of the following:
**                         NAV_ALT_MSK_INT_P_HIGH       0x01
**                         NAV_ALT_MSK_INT_P_LOW        0x02
**                         NAV_ALT_MSK_INT_P_LOW_HIGH   0x03
**      intEnable     - enable interrupts parameter
**      bOutputType   - output type parameter, one of the following:
**                         NAV_PAR_INT_OPENDRAIN   1
**                         NAV_PAR_INT_PUSHPULL    0
**      latch         - parameter indicating the interrupt event is latched or
**                      not
**      intLevel      - set the level active interrupt for differential pressure
**                      value, on high or low
**                         NAV_ALT_MSK_INT_LEVEL_HIGH   1<<0
**                         NAV_ALT_MSK_INT_LEVEL_LOW    1<<1
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function configures the interrupts for altimeter instruments. It
**      sets the interrupt generator for the three axes. It sets the active
**      level, low or high for the interrupt event, interrupt configurations,
**      output type. It enables/disables the interrupt latching.
*/
void NAV_ConfigIntALT(PmodNAV *InstancePtr, u8 bIntGen, u8 bActiveType,
      u8 bOutputType, u8 dataSignalVal, bool intEnable, bool latch,
      u8 intLevel) {
   // Enable interrupts in NAV_ALT_CTRL_REG1 register
   NAV_SetRegisterBits(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG1,
         NAV_ALT_MSK_DIFF_EN_ALT, intEnable);
   // Mask out the reserved bits in NAV_ALT_CTRL_REG3 register
   uint8_t config = (bIntGen & 0xC3);
   // INT_H_L bit is 1 for active-low, 0 for active-high.
   if (bActiveType == NAV_PAR_INT_ACTIVELOW) {
      config |= (1 << 7);
   }
   // PP_OD bit is 1 for open drain, 0 for push pull.
   if (bOutputType == NAV_PAR_INT_OPENDRAIN) {
      config |= (1 << 6);
   }
   config |= dataSignalVal;
   NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG3, config);
   config = bIntGen;
   NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG4, config);
   if (!latch)
      config |= (1 << 2);
   config |= intLevel;
   NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_INTERRUPT_CFG, config);
}

/* ------------------------------------------------------------ */
/*** void NAV_SetIntThresholdALT(PmodNAV *InstancePtr, float thVal)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      thVal       - the interrupt threshold parameter for alt instrument
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the interrupt threshold for the altimeter instrument
*/
void NAV_SetIntThresholdALT(PmodNAV *InstancePtr, float thVal) {
   u8 buffer[2];
   u16 bthVal;
   // Converts the float value in gauss to raw magnetic field data to be written
   // in NAV_MAG_INT_THS_L/NAV_MAG_INT_THS_H registers
   bthVal = (u16) (thVal * 4096);
   // Split bytes
   // Make sure the first bit of the High byte is 0, for correct functionality
   // of the device
   buffer[0] = (bthVal & 0xFF00) >> 8;
   buffer[1] = (bthVal & 0x00FF);
   NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_THS_P_H, buffer[0]);
   NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_THS_P_L, buffer[1]);
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetIntSrcALT(PmodNAV *InstancePtr)
**
**   Parameters:
**     InstancePtr - instance of PmodNAV
**
**   Return Value:
**     uint8_t - parameter storing the interrupt source register content
**
**   Errors:
**      None
**
**   Description:
**      The function gets the interrupt sources by reading the
**      NAV_ALT_INT_SOURCE register
*/
u8 NAV_GetIntSrcALT(PmodNAV *InstancePtr) {
   u8 intSrc;
   intSrc = NAV_ReadSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_INT_SOURCE);

   // Check if the INT (interrupt active) bit is set
   if (intSrc & (1 << 2)) {
      return intSrc;
   }
   return 0;
}

/*-------------------------------------------------------------*/
/*  Common Functions                                           */
/*-------------------------------------------------------------*/

/* ------------------------------------------------------------ */
/*** void NAV_SetODR(PmodNAV *InstancePtr, u8 bInstMode, u8 odrVal)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInstMode   - parameter representing the instrument to be affected
**      odrVal      - the parameter specifying the ODR value for each
**                    instrument. Can be one of the parameters from the
**                    following list:
**         ----for Accelerometer
**            0   NAV_ACL_ODR_XL_PWR_DWN   Parameter ODR value: power down the
**                                                              device
**            1   NAV_ACL_ODR_XL_10_HZ     Parameter ODR value: 10 Hz
**            2   NAV_ACL_ODR_XL_50_HZ     Parameter ODR value: 50 Hz
**            3   NAV_ACL_ODR_XL_119_HZ    Parameter ODR value: 119 Hz
**            4   NAV_ACL_ODR_XL_238_HZ    Parameter ODR value: 238 Hz
**            5   NAV_ACL_ODR_XL_476_HZ    Parameter ODR value: 476 Hz
**            6   NAV_ACL_ODR_XL_952_HZ    Parameter ODR value: 952 Hz
**            7   NAV_ACL_ODR_XL_NA        Parameter ODR value: not defined
**         ----for Gyro
**            0   NAV_GYRO_ODR_G_PWR_DWN   Parameter ODR value: power down the
**                                                              device
**            1   NAV_GYRO_ODR_G_14_9HZ    Parameter ODR value: 14.9 Hz
**            2   NAV_GYRO_ODR_G_59_5HZ    Parameter ODR value: 59.5 Hz
**            3   NAV_GYRO_ODR_G_119HZ     Parameter ODR value: 119 Hz
**            4   NAV_GYRO_ODR_G_238HZ     Parameter ODR value: 238 Hz
**            5   NAV_GYRO_ODR_G_476HZ     Parameter ODR value: 476 Hz
**            6   NAV_GYRO_ODR_G_952HZ     Parameter ODR value: 952 Hz
**            7   NAV_GYRO_ODR_G_NA        Parameter ODR value: not defined
**         ----for Magnetometer
**            0   NAV_MAG_ODR_M_0_625HZ   Parameter ODR value: 0.625 HZ
**            1   NAV_MAG_ODR_M_1_25HZ    Parameter ODR value: 1.25 Hz
**            2   NAV_MAG_ODR_M_2_5HZ     Parameter ODR value: 2.5 Hz
**            3   NAV_MAG_ODR_M_5HZ       Parameter ODR value: 5 Hz
**            4   NAV_MAG_ODR_M_10HZ      Parameter ODR value: 10 Hz
**            5   NAV_MAG_ODR_M_20HZ      Parameter ODR value: 20 Hz
**            6   NAV_MAG_ODR_M_40HZ      Parameter ODR value: 40 Hz
**            7   NAV_MAG_ODR_M_80HZ      Parameter ODR value: 80 HZ
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the ODR value for the selected instrument, in the
**      corresponding register. The argument values are between 0 and 7.
*/
void NAV_SetODR(PmodNAV *InstancePtr, u8 bInstMode, u8 odrVal) {
   switch (bInstMode) {
   case NAV_ACL_MODE_INST_A:
      // Set ODR for accelerometer instrument when used in single mode
      NAV_SetBitsInRegister(InstancePtr, NAV_INST_AG, NAV_ACL_CTRL_REG6_XL,
            NAV_ACL_MSK_ODR_XL, odrVal, 5);
      break;
   case NAV_ACL_GYRO_MODE_INST_AG:
      // Set ODR for gyro and accel instruments when used together
      NAV_SetBitsInRegister(InstancePtr, NAV_INST_AG, NAV_GYRO_CTRL_REG1_G,
            NAV_GYRO_MSK_ODR_G, odrVal, 5);
      break;
   case NAV_MAG_MODE_INST_MAG:
      // Set ODR for magnetometer instrument
      NAV_SetBitsInRegister(InstancePtr, NAV_INST_MAG, NAV_ACL_CTRL_REG6_XL,
            NAV_MAG_MSK_ODR_MAG, odrVal, 3);
      break;
   case NAV_ALT_MODE_INST_ALT:
      // Set ODR for altimeter instrument
      NAV_SetBitsInRegister(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG1,
            NAV_ALT_MSK_ODR_ALT, odrVal, 4);
      break;
   default:
      break;
   }
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetODRRaw(PmodNAV *InstancePtr, u8 bInstMode)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInstMode   - parameter representing the instrument to be affected
**
**   Return Value:
**      uint8_t - returns the ODR raw value for the selected instrument,
**                expressed in hex
**                It can be one of the values:
**         -----for Accelerometer
**            0   NAV_ACL_ODR_XL_PWR_DWN  Parameter ODR value: power down the
**                                                             device
**            1   NAV_ACL_ODR_XL_10_HZ    Parameter ODR value: 10 Hz
**            2   NAV_ACL_ODR_XL_50_HZ    Parameter ODR value: 50 Hz
**            3   NAV_ACL_ODR_XL_119_HZ   Parameter ODR value: 119 Hz
**            4   NAV_ACL_ODR_XL_238_HZ   Parameter ODR value: 238 Hz
**            5   NAV_ACL_ODR_XL_476_HZ   Parameter ODR value: 476 Hz
**            6   NAV_ACL_ODR_XL_952_HZ   Parameter ODR value: 952 Hz
**            7   NAV_ACL_ODR_XL_NA       Parameter ODR value: not defined
**         ----for Gyro
**            0   NAV_GYRO_ODR_G_PWR_DWN  Parameter ODR value: power down the
**                                                             device
**            1   NAV_GYRO_ODR_G_14_9HZ   Parameter ODR value: 14.9 Hz
**            2   NAV_GYRO_ODR_G_59_5HZ   Parameter ODR value: 59.5 Hz
**            3   NAV_GYRO_ODR_G_119HZ    Parameter ODR value: 119 Hz
**            4   NAV_GYRO_ODR_G_238HZ    Parameter ODR value: 238 Hz
**            5   NAV_GYRO_ODR_G_476HZ    Parameter ODR value: 476 Hz
**            6   NAV_GYRO_ODR_G_952HZ    Parameter ODR value: 952 Hz
**            7   NAV_GYRO_ODR_G_NA       Parameter ODR value: not defined
**         ----for Magnetometer
**            0   NAV_MAG_ODR_M_0_625HZ   Parameter ODR value: 0.625 HZ
**            1   NAV_MAG_ODR_M_1_25HZ    Parameter ODR value: 1.25 Hz
**            2   NAV_MAG_ODR_M_2_5HZ     Parameter ODR value: 2.5 Hz
**            3   NAV_MAG_ODR_M_5HZ       Parameter ODR value: 5 Hz
**            4   NAV_MAG_ODR_M_10HZ      Parameter ODR value: 10 Hz
**            5   NAV_MAG_ODR_M_20HZ      Parameter ODR value: 20 Hz
**            6   NAV_MAG_ODR_M_40HZ      Parameter ODR value: 40 Hz
**            7   NAV_MAG_ODR_M_80HZ      Parameter ODR value: 80 HZ
**
**   Errors:
**      None
**
**   Description:
**      The function sets the ODR value for the selected instrument.
*/
u8 NAV_GetODRRaw(PmodNAV *InstancePtr, u8 bInstMode) {
   u8 getODR;
   switch (bInstMode) {
   case NAV_ACL_MODE_INST_A:
      getODR = NAV_GetBitsInRegister(InstancePtr, NAV_INST_AG,
            NAV_ACL_CTRL_REG6_XL, 5, 3);
      break;
   case NAV_ACL_GYRO_MODE_INST_AG:
      getODR = NAV_GetBitsInRegister(InstancePtr, NAV_INST_AG,
            NAV_GYRO_CTRL_REG1_G, 5, 3);
      break;
   case NAV_MAG_MODE_INST_MAG:
      getODR = NAV_GetBitsInRegister(InstancePtr, NAV_INST_MAG,
            NAV_ACL_CTRL_REG6_XL, 3, 3);
      break;
   case NAV_ALT_MODE_INST_ALT:
      getODR = NAV_GetBitsInRegister(InstancePtr, NAV_INST_ALT,
            NAV_ALT_CTRL_REG1, 4, 3);
      break;
   default:
      break;
   }
   return getODR;
}

/* ------------------------------------------------------------ */
/*** float NAV_GetODR(PmodNAV *InstancePtr, u8 bInstMode)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInstMode   - parameter representing the instrument to be affected
**
**   Return Value:
**      float - returns the ODR value of the selected instrument, as a numeric
**              value corresponding to the bits reading from the corresponding
**              register.
**
**   Errors:
**      None
**
**   Description:
**      The function returns the ODR value of the selected instrument, as a
**      numeric value corresponding to the bits from each instrument ODR
**      register
*/
float NAV_GetODR(PmodNAV *InstancePtr, u8 bInstMode) {
   u8 odrRead;
   float odrFinal;
   if (bInstMode == NAV_ACL_MODE_INST_A) {
      odrRead = NAV_GetODRRaw(InstancePtr, NAV_ACL_MODE_INST_A);
      switch (odrRead) {
      case NAV_ACL_ODR_XL_PWR_DWN:
         odrFinal = 0;
         break;
      case NAV_ACL_ODR_XL_10HZ:
         odrFinal = 10;
         break;
      case NAV_ACL_ODR_XL_50HZ:
         odrFinal = 50;
         break;
      case NAV_ACL_ODR_XL_119HZ:
         odrFinal = 119;
         break;
      case NAV_ACL_ODR_XL_238HZ:
         odrFinal = 238;
         break;
      case NAV_ACL_ODR_XL_476HZ:
         odrFinal = 476;
         break;
      case NAV_ACL_ODR_XL_952HZ:
         odrFinal = 952;
         break;
      case NAV_ACL_ODR_XL_NA:
         odrFinal = -1;
         break;
      default:
         odrFinal = 0;
         break;
      }
   }
   // Get odr for accel+gyro
   else if (bInstMode == NAV_ACL_GYRO_MODE_INST_AG) {
      odrRead = NAV_GetODRRaw(InstancePtr, NAV_ACL_GYRO_MODE_INST_AG);
      switch (odrRead) {
      case NAV_GYRO_ODR_G_PWR_DWN:
         odrFinal = 0;
         break;
      case NAV_GYRO_ODR_G_14_9HZ:
         odrFinal = 14.9;
         break;
      case NAV_GYRO_ODR_G_59_5HZ:
         odrFinal = 59.5;
         break;
      case NAV_GYRO_ODR_G_119HZ:
         odrFinal = 119;
         break;
      case NAV_GYRO_ODR_G_238HZ:
         odrFinal = 238;
         break;
      case NAV_GYRO_ODR_G_476HZ:
         odrFinal = 476;
         break;
      case NAV_GYRO_ODR_G_952HZ:
         odrFinal = 952;
         break;
      case NAV_GYRO_ODR_G_NA:
         odrFinal = -1;
         break;
      default:
         odrFinal = 0;
         break;
      }
   }
   // Get odr for magnetometer
   else if (bInstMode == NAV_MAG_MODE_INST_MAG) {
      odrRead = NAV_GetODRRaw(InstancePtr, NAV_MAG_MODE_INST_MAG);
      switch (odrRead) {
      case NAV_MAG_ODR_M_0_625HZ:
         odrFinal = 0.625;
         break;
      case NAV_MAG_ODR_M_1_25HZ:
         odrFinal = 1.25;
         break;
      case NAV_MAG_ODR_M_2_5HZ:
         odrFinal = 2.5;
         break;
      case NAV_MAG_ODR_M_5HZ:
         odrFinal = 5;
         break;
      case NAV_MAG_ODR_M_10HZ:
         odrFinal = 10;
         break;
      case NAV_MAG_ODR_M_20HZ:
         odrFinal = 20;
         break;
      case NAV_MAG_ODR_M_40HZ:
         odrFinal = 40;
         break;
      case NAV_MAG_ODR_M_80HZ:
         odrFinal = 80;
         break;
      default:
         odrFinal = 10;
         break;
      }
   }
   // Get odr for altimeter
   else if (bInstMode == NAV_ALT_MODE_INST_ALT) {
      odrRead = NAV_GetODRRaw(InstancePtr, NAV_ALT_MODE_INST_ALT);
      switch (odrRead) {
      case NAV_ALT_ODR_ALT_ONE_SHOT:
         odrFinal = 0;
         break;
      case NAV_ALT_ODR_ALT_1HZ:
         odrFinal = 1;
         break;
      case NAV_ALT_ODR_ALT_7HZ:
         odrFinal = 7;
         break;
      case NAV_ALT_ODR_ALT_12_5HZ:
         odrFinal = 12.5;
         break;
      case NAV_ALT_ODR_ALT_25HZ:
         odrFinal = 25;
         break;
      default:
         odrFinal = 0;
         break;
      }
   } else {
      odrFinal = -1;
   }
   return odrFinal;
}

/*-------------------------------------------------------------*/
/*  FIFO Functions                                             */
/*-------------------------------------------------------------*/

/* ------------------------------------------------------------ */
/*** void NAV_FIFOEnable(PmodNAV *InstancePtr, u8 bInst, bool fEnable)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst - parameter for selecting one of the instruments: AG or ALT
**      fEnable - the parameter used to enable or disable the FIFO
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function enables or disables FIFO by writing FIFO_EN bit in
**      NAV_IMU_CTRL_REG9 register for Accel/Gyro, or NAV_ALT_CTRL_REG2 for
**      Altimeter instrument
*/
void NAV_FIFOEnable(PmodNAV *InstancePtr, u8 bInst, bool fEnable) {
   u8 temp;
   switch (bInst) {
   case NAV_INST_AG:
      NAV_ReadRegister(InstancePtr, NAV_INST_AG, NAV_IMU_CTRL_REG9, 1, &temp);
      if (fEnable)
         temp |= (1 << 1);
      else
         temp &= ~(1 << 1);
      NAV_WriteSPI(InstancePtr, NAV_INST_AG, NAV_IMU_CTRL_REG9, temp);
      break;
   case NAV_INST_ALT:
      NAV_ReadRegister(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG2, 1, &temp);
      if (fEnable)
         temp |= (1 << 6);
      else
         temp &= ~(1 << 6);
      NAV_WriteSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_CTRL_REG2, temp);
      break;
   default:
      break;
   }
}

/* ------------------------------------------------------------ */
/*** void NAV_SetFIFO(PmodNAV *InstancePtr, u8 bInst, u8 parFIFOMode,
**         u8 FIFOThreshold)
**
**   Parameters:
**      InstancePtr   - instance of PmodNAV
**      bInst         - parameter for selecting one of the instruments
**      parFIFOMode   - the parameter specifying the FIFO mode for each
**                      instrument. Can be one of the parameters from the
**                      following list:
**   ----for Accelerometer and Gyroscope instruments, when working
**       together
**                                                     Parameter FIFO mode value
**      0   NAV_ACL_GYRO_FIFO_MODE_XL_G_BYPASS            bypass
**      1   NAV_ACL_GYRO_FIFO_MODE_XL_G_FIFO              FIFO normal
**      3   NAV_ACL_GYRO_FIFO_MODE_XL_G_CONTINUOUS_FIFO   continuous to FIFO
**      4   NAV_ACL_GYRO_FIFO_MODE_XL_G_BYPASS_CONTINUOUS bypass to continuous
**      6   NAV_ACL_GYRO_FIFO_MODE_XL_G_CONTINUOUS        continuous
**
**   ----for Altimeter instrument
**      0   NAV_ALT_FIFO_MODE_ALT_BYPASS                  bypass
**      1   NAV_ALT_FIFO_MODE_ALT_FIFO                    FIFO normal
**      2   NAV_ALT_FIFO_MODE_ALT_STREAM                  stream mode
**      3   NAV_ALT_FIFO_MODE_ALT_STREAM_TO_FIFO          stream to FIFO
**      4   NAV_ALT_FIFO_MODE_ALT_BYPASS_TO_STREAM        bypass to stream
**      6   NAV_ALT_FIFO_MODE_ALT_MEAN                    mean mode
**      7   NAV_ALT_FIFO_MODE_ALT_BYPASS_TO_FIFO          bypass to FIFO mode
**
**      FIFOThreshold - FIFO threshold level setting. Can be one of the
**                      parameters from the following list:
**   ----for Accelerometer and Gyro instruments, when working together. Any
**       value from 0-0x1F is acceptable
**      0           Parameter FIFO mean mode value: 0 samples
**      .
**      .
**      .
**      32          Parameter FIFO mean mode value: 32 samples
**
**   ----for Altimeter instrument
**                                               Parameter FIFO mean mode value
**      0   NAV_ALT_FIFO_MODE_MEAN_ALT_2SAMPLES   2 samples
**      1   NAV_ALT_FIFO_MODE_MEAN_ALT_4SAMPLES   4 samples
**      2   NAV_ALT_FIFO_MODE_MEAN_ALT_8SAMPLES   8 samples
**      3   NAV_ALT_FIFO_MODE_MEAN_ALT_16SAMPLES 16 samples
**      4   NAV_ALT_FIFO_MODE_MEAN_ALT_32SAMPLES 32 samples
**
**   Return Value:
**      None
**
**   Errors:
**      None
**
**   Description:
**      The function sets the FIFO control mode and threshold in FIFO_CTRL
**      register for the accel+gyro instruments and for altimeter instrument.
**      The magnetometer instrument does not contain FIFO
*/
void NAV_SetFIFO(PmodNAV *InstancePtr, u8 bInst, u8 parFIFOMode,
      u8 FIFOThreshold) {
   switch (bInst) {
   case NAV_INST_AG:
      NAV_SetBitsInRegister(InstancePtr, NAV_INST_AG, NAV_IMU_FIFO_CTRL,
            NAV_IMU_MSK_FIFO_CTL_MODE, parFIFOMode, 5);
      NAV_SetBitsInRegister(InstancePtr, NAV_INST_AG, NAV_IMU_FIFO_CTRL,
            NAV_IMU_MSK_FIFO_THS, FIFOThreshold, 0);
      break;
   case NAV_INST_ALT:
      NAV_SetBitsInRegister(InstancePtr, NAV_INST_ALT, NAV_ALT_FIFO_CTRL,
            NAV_ALT_MSK_FIFO_CTL_MODE, parFIFOMode, 5);
      NAV_SetBitsInRegister(InstancePtr, NAV_INST_ALT, NAV_ALT_FIFO_CTRL,
            NAV_ALT_MSK_FIFO_THS, FIFOThreshold, 0);
      break;
   default:
      break;
   }
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetFIFOMode(PmodNAV *InstancePtr, u8 bInst)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst - instrument to select
**
**   Return Value:
**      uint8_t - returns the FIFO mode bits from FIFO_CTRL register for either
**                Accel/Gyro or Altimeter instrument
**                Can be one of the parameters from the following list:
**   ----for Accelerometer and Gyro instruments, when working together
**                                                     Parameter FIFO mode value
**      0   NAV_ACL_GYRO_FIFO_MODE_XL_G_BYPASS            bypass
**      1   NAV_ACL_GYRO_FIFO_MODE_XL_G_FIFO              FIFO normal
**      3   NAV_ACL_GYRO_FIFO_MODE_XL_G_CONTINUOUS_FIFO   continuous to FIFO
**      4   NAV_ACL_GYRO_FIFO_MODE_XL_G_BYPASS_CONTINUOUS bypass to continuous
**      6   NAV_ACL_GYRO_FIFO_MODE_XL_G_CONTINUOUS        continuous
**
**   ----for Altimeter instrument
**                                                 Parameter FIFO mode value
**      0   NAV_ALT_FIFO_MODE_ALT_BYPASS           bypass
**      1   NAV_ALT_FIFO_MODE_ALT_FIFO             FIFO normal
**      2   NAV_ALT_FIFO_MODE_ALT_STREAM           stream mode
**      3   NAV_ALT_FIFO_MODE_ALT_STREAM_TO_FIFO   stream to FIFO
**      4   NAV_ALT_FIFO_MODE_ALT_BYPASS_TO_STREAM bypass to stream
**      6   NAV_ALT_FIFO_MODE_ALT_MEAN             mean mode
**      7   NAV_ALT_FIFO_MODE_ALT_BYPASS_TO_FIFO   bypass to FIFO mode
**
**  Errors:
**      None
**
**  Description:
**      The function reads the FIFO mode bits in the FIFO_CTRL register for
**      accel and gyro and Altimeter instruments and returns their value.
*/
u8 NAV_GetFIFOMode(PmodNAV *InstancePtr, u8 bInst) {
   u8 getFIFO;
   switch (bInst) {
   case NAV_INST_AG:
      getFIFO = NAV_GetBitsInRegister(InstancePtr, NAV_INST_AG,
            NAV_IMU_FIFO_CTRL, 5, 3);
      break;
   case NAV_INST_ALT:
      getFIFO = NAV_GetBitsInRegister(InstancePtr, NAV_INST_ALT,
            NAV_ALT_FIFO_CTRL, 5, 3);
      break;
   default:
      break;
   }
   return getFIFO;
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetFIFOThs(PmodNAV *InstancePtr, u8 bInst)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst       - parameter for selecting one of the instruments
**
**   Return Value
**      uint8_t - specifies the FIFO mean number of samples for each instrument.
**                Can be one of the parameters from the following list:
**      ----for Accelerometer and Gyroscope instruments, when working together
**         0           Parameter FIFO mode mean value: 0 samples
**         .
**         .
**         .
**         32          Parameter FIFO mode mean value: 32 samples
**      ----for Altimeter instrument
**                                               Parameter FIFIO mean mode value
**         0   NAV_ALT_FIFO_MODE_MEAN_ALT_2SAMPLES  2 samples
**         1   NAV_ALT_FIFO_MODE_MEAN_ALT_4SAMPLES  4 samples
**         2   NAV_ALT_FIFO_MODE_MEAN_ALT_8SAMPLES  8 samples
**         3   NAV_ALT_FIFO_MODE_MEAN_ALT_16SAMPLES 16 samples
**         4   NAV_ALT_FIFO_MODE_MEAN_ALT_32SAMPLES 32 samples
**
**  Errors:
**      None
**
**  Description:
**      The function returns the FIFO mean/threshold mode bits in FIFO_CTRL
**      register for the accel+gyro instruments or for altimeter instrument.
**      The magnetometer instrument does not contain FIFO
*/
u8 NAV_GetFIFOThs(PmodNAV *InstancePtr, u8 bInst) {
   u8 bFifoThs;
   switch (bInst) {
   case NAV_INST_AG:
      bFifoThs = NAV_GetBitsInRegister(InstancePtr, NAV_INST_AG,
            NAV_IMU_FIFO_CTRL, 0, 5);
      break;
   case NAV_INST_ALT:
      bFifoThs = NAV_GetBitsInRegister(InstancePtr, NAV_INST_ALT,
            NAV_ALT_FIFO_CTRL, 0, 5);
      break;
   default:
      break;
   }
   return bFifoThs;
}

/* ------------------------------------------------------------ */
/*** u8 NAV_GetFIFOStatus(PmodNAV *InstancePtr, u8 bInst)
**
**   Parameters:
**      InstancePtr - instance of PmodNAV
**      bInst       - instrument to select
**
**   Return Value:
**      uint8_t - returns the FIFO status NAV_ALT_FIFO_STATUS or
**      NAV_IMU_FIFO_SRC register, depending on the selected instrument
**
**   Errors:
**      None
**
**   Description:
**      The function reads the NAV_IMU_FIFO_SRC register for Accelerometer and
**      Gyroscope and NAV_ALT_FIFO_STATUS register for Altimeter instrument and
**      returns their value.
*/
u8 NAV_GetFIFOStatus(PmodNAV *InstancePtr, u8 bInst) {
   u8 getFIFOSts;
   switch (bInst) {
   case NAV_INST_AG:
      getFIFOSts = NAV_ReadSPI(InstancePtr, NAV_INST_AG, NAV_IMU_FIFO_SRC);
      break;
   case NAV_INST_ALT:
      getFIFOSts = NAV_ReadSPI(InstancePtr, NAV_INST_ALT, NAV_ALT_FIFO_STATUS);
      break;
   default:
      break;
   }
   return getFIFOSts;
}
