/******************************************************************************/
/*                                                                            */
/* PmodACL.c -- PmodACL Driver Source                                         */
/*                                                                            */
/******************************************************************************/
/* Author: Thomas Kappenman                                                   */
/* Copyright 2016-2017, Digilent Inc.                                         */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains driver source for the PmodACL IP                        */
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


/***************************** Include Files *******************************/

#include "PmodACL.h"

/************************** Function Definitions ***************************/

XSpi_Config XSpi_ACLConfig =
{
   0,
   0,
   1,
   0,
   1,
   8,
   0,
   0,
   0,
   0,
   0
};

/* ------------------------------------------------------------ */
/*** void ACL_begin(PmodACL *InstancePtr, u32 GPIO_Address, u32 SPI_Address)
**
**   Parameters:
**      InstancePtr:  A PmodACL device to start
**      GPIO_Address: The Base address of the PmodACL GPIO
**      SPI_Address:  The Base address of the PmodACL SPI
**
**   Return Value:
**      none
**
**   Description:
**      Initialize the PmodACL.
*/
void ACL_begin(PmodACL *InstancePtr, u32 GPIO_Address, u32 SPI_Address) {
   InstancePtr->GPIO_addr = GPIO_Address;
   XSpi_ACLConfig.BaseAddress = SPI_Address;
   Xil_Out32(InstancePtr->GPIO_addr + 4, 0b11);
   ACL_SPIInit(&InstancePtr->ACLSpi);
}

/* ------------------------------------------------------------ */
/*** int ACL_SPIInit(XSpi *SpiInstancePtr)
**
**   Parameters:
**      SpiInstancePtr: A PmodACL SPI device to initialize
**
**   Return Value:
**      none
**
**   Description:
**      Initializes the PmodACL SPI.
*/
int ACL_SPIInit(XSpi *SpiInstancePtr) {
   int Status;
   XSpi_Config *ConfigPtr; /* Pointer to Configuration data */

   /*
    * Initialize the SPI driver so that it is  ready to use.
    */
   ConfigPtr = &XSpi_ACLConfig;
   if (ConfigPtr == NULL) {
      return XST_DEVICE_NOT_FOUND;
   }

   Status = XSpi_CfgInitialize(SpiInstancePtr, ConfigPtr,
         ConfigPtr->BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   u32 options = (XSP_MASTER_OPTION | XSP_CLK_ACTIVE_LOW_OPTION
         | XSP_CLK_PHASE_1_OPTION) | XSP_MANUAL_SSELECT_OPTION;
   Status = XSpi_SetOptions(SpiInstancePtr, options); // Manual SS off
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   Status = XSpi_SetSlaveSelect(SpiInstancePtr, 1);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   /*
    * Start the SPI driver so that the device is enabled.
    */
   XSpi_Start(SpiInstancePtr);

   /*
    * Disable Global interrupt to use polled mode operation
    */
   XSpi_IntrGlobalDisable(SpiInstancePtr);

   return XST_SUCCESS;

}

/* ------------------------------------------------------------ */
/*** void ACL_WriteSpi(PmodACL *InstancePtr, u8 reg, u8 *wData, int nData)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**      reg:         the starting register to write to
**      wData:       the data to write
**      nData:       the number of data bytes to write
**
**   Return Value:
**      none
**
**   Description:
**      Writes the byte array to the chip via SPI. It will write the first byte
**      into the specified register, then the next into the following register
**      until all of the data has been sent.
*/
void ACL_WriteSpi(PmodACL *InstancePtr, u8 reg, u8 *wData, int nData) {
   // As requested by documentation, first byte contains:
   //    bit 7 =    0 because is a write operation
   //    bit 6 =    1 if more than one bytes is written, 0 if a single byte is
   //               written
   //    bits 5-0 = the address
   u8 bytearray[nData + 1];
   int i;
   bytearray[0] = ((nData > 1) ? 0x40 : 0) | (reg & 0x3F);
   for (i = 0; i < nData; i++) {
      bytearray[i + 1] = wData[i];
   }
   XSpi_Transfer(&InstancePtr->ACLSpi, bytearray, 0, nData + 1);
}

/* ------------------------------------------------------------ */
/*** void ACL_ReadSpi(PmodACL *InstancePtr, u8 reg, u8 *rData, int nData)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**      reg:         the starting register to read from
**      rData:       the byte array to read into
**      nData:       the number of data bytes to read
**
**   Return Value:
**      none
**
**   Description:
**      Reads data in through SPI. It will read the first byte from the starting
**      register, then the next from the following register. Data is stored into
**      rData.
*/
void ACL_ReadSpi(PmodACL *InstancePtr, u8 reg, u8 *rData, int nData) {
   // As requested by documentation, first byte contains:
   //    bit 7 =    1 because is a read operation
   //    bit 6 =    1 if more than one bytes is written, 0 if a single byte is
   //               written
   //    bits 5-0 - the address
   u8 bytearray[nData + 1];
   int i;

   bytearray[0] = ((nData > 1) ? 0xC0 : 0x80) | (reg & 0x3F);
   XSpi_Transfer(&InstancePtr->ACLSpi, bytearray, bytearray, nData + 1);
   for (i = 0; i < nData; i++) {
      rData[i] = bytearray[i + 1];
   }
}

/* ------------------------------------------------------------ */
/*** void ACL_SetRegisterBits(PmodACL *InstancePtr, u8 reg, u8 mask, u8 fValue)
**
**   Parameters:
**      InstancePtr:      the PmodACL device to communicate with
**      bRegisterAddress: the address of the register whose bits are set
**      bMask:            the mask indicating which bits are affected
**      fValue:           1 if the bits are set or 0 if their bits are reset
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the value of some bits (corresponding to the bMask)
**      of a register (indicated by bRegisterAddress) to 1 or 0 (indicated by
**      fValue).
*/
void ACL_SetRegisterBits(PmodACL *InstancePtr, u8 reg, u8 mask, u8 fValue) {
   u8 regval;
   ACL_ReadSpi(InstancePtr, reg, &regval, 1);
   if (fValue)
      regval |= mask;
   else
      regval &= ~mask;
   ACL_WriteSpi(InstancePtr, reg, &regval, 1);
}

/* ------------------------------------------------------------ */
/*** u8 ACL_GetRegisterBits(PmodACL *InstancePtr, u8 bRegisterAddress,
**         u8 bMask)
**
**   Parameters:
**      InstancePtr:      the PmodACL device to communicate with
**      bRegisterAddress: the address of the register to read from
**      bMask:            the mask indicating which bits are read
**
**   Return Value:
**      a byte containing only the bits corresponding to the mask.
**
**   Description:
**      Returns a byte containing only the bits from a register (indicated by
**      bRegisterAddress), corresponding to the bMask mask.
*/
u8 ACL_GetRegisterBits(PmodACL *InstancePtr, u8 bRegisterAddress, u8 bMask) {
   u8 bRegValue;
   ACL_ReadSpi(InstancePtr, bRegisterAddress, &bRegValue, 1);
   return bRegValue & bMask;
}

/* ------------------------------------------------------------ */
/*** float ConvertReadingToValueG(PmodACL *InstancePtr, int16_t uiReading)
**
**   Parameters:
**      InstancePtr: the PmodACL device to get the G-range from
**      uiReading:   the 2 bytes containing the reading (in fact only 10 bits
**                   are used).
**
**   Return Value:
**      the value of the acceleration in "g" corresponding to the 10 bits
**      reading and the current g range
**
**   Description:
**      Converts the value from the 10 bit reading to the float value (in g)
**      corresponding to the acceleration, considering the current selected g
**      range.
*/
float ConvertReadingToValueG(PmodACL *InstancePtr, int16_t uiReading) {
   // Convert the accelerometer value to G's.
   // With 10 (ACL_NO_BITS) bits measuring over a +/- ng range we can find how
   // to convert by using the equation:
   //    Gs = Measurement Value * (G-range/(2^10))
   // m_dGRangeLSB is pre-computed in ACL_SetGRange
   float dResult = ((float) uiReading) * InstancePtr->m_dGRangeLSB;
   return dResult;
}

/* ------------------------------------------------------------ */
/*** float ACL_GetGRangeLSB(u8 bGRange)
**
**   Parameters:
**      bGRange: the parameter specifying the g range. Can be one of the
**               parameters in the following list
**                  0   ACL_PAR_GRANGE_PM2G Parameter g range : +/- 2g
**                  1   ACL_PAR_GRANGE_PM4G Parameter g range : +/- 4g
**                  2   ACL_PAR_GRANGE_PM8G Parameter g range : +/- 8g
**                  3   ACL_PAR_GRANGE_PM16G Parameter g range : +/- 16g
**
**   Return Value:
**      float - the value in "g" corresponding to the G range parameter, that
**              corresponds to 1 accelerometer LSB
**
**   Description:
**      Converts the parameter indicating the G range into the value that
**      corresponds to 1 accelerometer LSB.
**      For example ACL_PAR_GRANGE_PM8G: Range is 16g, accelerometer is on 10
**      bits, that corresponds to 16/(2^10). This constant is later used in
**      converting readings to acceleration values in g. (for example converts
**      ACL_PAR_GRANGE_PM8G into 8).
*/
float ACL_GetGRangeLSB(u8 bGRange) {
   float dGMaxValue = 0;
   float dResult;
   switch (bGRange) {
   case ACL_PAR_GRANGE_PM2G:
      dGMaxValue = 2;
      break;
   case ACL_PAR_GRANGE_PM4G:
      dGMaxValue = 4;
      break;
   case ACL_PAR_GRANGE_PM8G:
      dGMaxValue = 8;
      break;
   case ACL_PAR_GRANGE_PM16G:
      dGMaxValue = 16;
      break;
   }
   dResult = 2 * dGMaxValue / (float) (1 << ACL_NO_BITS);
   return dResult;
}

/* ------------------------------------------------------------ */
/*** void ACL_ReadAccelG(PmodACL *InstancePtr, float *dAclXg, float *dAclYg,
**         float *dAclZg)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**      dAclXg:      the output parameter that will receive acceleration on
**                      X-axis (in "g")
**      dAclYg:      the output parameter that will receive acceleration on
**                      Y-axis (in "g")
**      dAclZg:      the output parameter that will receive acceleration on
**                      Z-axis (in "g")
**
**   Return Value:
**      void
**
**   Description:
**      This function is the main function used for acceleration reading,
**      providing the 3 current acceleration values in "g".
**       - It reads simultaneously the acceleration on three axes in a buffer of
**         6 bytes using the ReadRegister function
**       - For each of the three axes, combines the two bytes in order to get a
**         10-bit value
**       - For each of the three axes, converts the 10-bit value to the value
**         expressed in "g", considering the currently selected g range
*/
void ACL_ReadAccelG(PmodACL *InstancePtr, float *dAclXg, float *dAclYg,
      float *dAclZg) {
   u16 rgwRegVals[3];
   ACL_ReadSpi(InstancePtr, ACL_REG_DATAX0, (u8 *) rgwRegVals, 6);
   *dAclXg = ConvertReadingToValueG(InstancePtr, rgwRegVals[0]);
   *dAclYg = ConvertReadingToValueG(InstancePtr, rgwRegVals[1]);
   *dAclZg = ConvertReadingToValueG(InstancePtr, rgwRegVals[2]);
}

/* ------------------------------------------------------------ */
/*** void ReadAccel(PmodACL *InstancePtr, int16_t *iAclX, int16_t *iAclY,
**      int16_t *iAclZ)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**      iAclX:       the output parameter that will receive acceleration on
**                      X-axis - 10 bits signed value
**      iAclY:       the output parameter that will receive acceleration on
**                      Y-axis - 10 bits signed value
**      iAclZ:       the output parameter that will receive acceleration on
**                      Z-axis - 10 bits signed value
**
**   Return Value:
**      None
**
**   Description:
**      This function provides the 3 "raw" 10-bit values read from the
**      accelerometer.
**       - It reads simultaneously the acceleration on three axes in a buffer of
**         6 bytes using the ReadRegister function
**       - For each of the three axes, combines the two bytes in order to get a
**         10-bit value
*/
void ReadAccel(PmodACL *InstancePtr, int16_t *iAclX, int16_t *iAclY,
      int16_t *iAclZ) {
   u16 rgwRegVals[3];
   ACL_ReadSpi(InstancePtr, ACL_REG_DATAX0, (u8 *) rgwRegVals, 6);
   *iAclX = rgwRegVals[0];
   *iAclY = rgwRegVals[1];
   *iAclZ = rgwRegVals[2];
}

/* ------------------------------------------------------------ */
/*** void ACL_SetMeasure(PmodACL *InstancePtr, u8 fMeasure)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**      fMeasure:    the value to be set for MEASURE bit of POWER_CTL register
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the MEASURE bit of POWER_CTL register. This toggles
**      between measurement and standby mode.
*/
void ACL_SetMeasure(PmodACL *InstancePtr, u8 fMeasure) {
   ACL_SetRegisterBits(InstancePtr, ACL_REG_POWER_CTL,
         ACL_MSK_POWER_CTL_MEASURE, fMeasure);
}

/* ------------------------------------------------------------ */
/*** u8 ACL_GetMeasure(PmodACL *InstancePtr)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**
**   Return Value:
**      The value of the MEASURE bit of POWER_CTL register
**
**   Description:
**      This function returns the value of MEASURE bit of POWER_CTL register.
*/
u8 ACL_GetMeasure(PmodACL *InstancePtr) {
   return (ACL_GetRegisterBits(InstancePtr, ACL_REG_POWER_CTL,
         ACL_MSK_POWER_CTL_MEASURE) != 0);
}

/* ------------------------------------------------------------ */
/*** void ACL_SetGRange(PmodACL *InstancePtr, u8 bGRangePar)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**      bGRangePar:  the parameter specifying the g range. Can be one of the
**                   parameters from the following list:
**                      0   ACL_PAR_GRANGE_PM2G Parameter g range : +/- 2g
**                      1   ACL_PAR_GRANGE_PM4G Parameter g range : +/- 4g
**                      2   ACL_PAR_GRANGE_PM8G Parameter g range : +/- 8g
**                      3   ACL_PAR_GRANGE_PM16G Parameter g range : +/- 16g
**
**   Return Value:
**      None
**
**   Description:
**      The function sets the appropriate g range bits in the DATA_FORMAT
**      register. The accepted argument values are between 0 and 3.
**
**      If the argument is within the accepted values range, it sets the g range
**      bits in DATA_FORMAT register and ACL_ERR_SUCCESS status is returned.
**
**      If value is outside this range no value is set.
*/
void ACL_SetGRange(PmodACL *InstancePtr, u8 bGRangePar) {
   InstancePtr->m_dGRangeLSB = ACL_GetGRangeLSB(bGRangePar);

   ACL_SetRegisterBits(InstancePtr, ACL_REG_DATA_FORMAT,
         ACL_MSK_DATA_FORMAT_RANGE0, (bGRangePar & 1));
   ACL_SetRegisterBits(InstancePtr, ACL_REG_DATA_FORMAT,
         ACL_MSK_DATA_FORMAT_RANGE1, (bGRangePar & 2) >> 1);
}

/* ------------------------------------------------------------ */
/*** u8 ACL_GetGRange(PmodACL *InstancePtr)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**
**   Return Value:
**      The value specifying the g Range parameter. Can be one of the values
**      from the following list
**         0   ACL_PAR_GRANGE_PM2G Parameter g range : +/- 2g
**         1   ACL_PAR_GRANGE_PM4G Parameter g range : +/- 4g
**         2   ACL_PAR_GRANGE_PM8G Parameter g range : +/- 8g
**         3   ACL_PAR_GRANGE_PM16G Parameter g range : +/- 16g
**
**   Description:
**      The function returns the value specifying the g range parameter. It
**      relies on the data in DATA_FORMAT register.
*/
u8 ACL_GetGRange(PmodACL *InstancePtr) {
   return ACL_GetRegisterBits(InstancePtr, ACL_REG_DATA_FORMAT,
         ACL_MSK_DATA_FORMAT_RANGE1 | ACL_MSK_DATA_FORMAT_RANGE0);
}

/* ------------------------------------------------------------ */
/*** void ACL_SetOffsetG(PmodACL *InstancePtr, u8 bAxisParam, float dOffset)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**      bAxisParam:  byte indicating the axis whose offset will be set. Can be
**                   one of:
**                      ACL_PAR_AXIS_X - indicating X-axis
**                      ACL_PAR_AXIS_Y - indicating Y-axis
**                      ACL_PAR_AXIS_Z - indicating Z-axis
**      dOffsetX:    the offset for X-axis in "g"
**
**   Return Value:
**      None
**
**   Description:
**      This function sets the specified axis offset, the value being given in
**      "g". The accepted argument values are between -2g and +2g.
**
**      If argument is within the accepted values range, its value is quantified
**      in the 8-bit offset register using a scale factor of 15.6 mg/LSB and
**      ACL_ERR_SUCCESS is returned.
**
**      If value is outside this range or if bAxisParam parameter is outside the
**      0 - 3 range, the function does nothing.
*/
void ACL_SetOffsetG(PmodACL *InstancePtr, u8 bAxisParam, float dOffset) {
   int8_t bOffsetVal = (u8) (dOffset / (float) ACL_CONV_OFFSET_G_LSB);
   switch (bAxisParam) {
   case ACL_PAR_AXIS_X:
      ACL_WriteSpi(InstancePtr, ACL_REG_OFSX, (u8 *) &bOffsetVal, 1);
      break;
   case ACL_PAR_AXIS_Y:
      ACL_WriteSpi(InstancePtr, ACL_REG_OFSY, (u8 *) &bOffsetVal, 1);
      break;
   case ACL_PAR_AXIS_Z:
      ACL_WriteSpi(InstancePtr, ACL_REG_OFSZ, (u8 *) &bOffsetVal, 1);
      break;
   }
}

/* ------------------------------------------------------------ */
/*** float ACL_GetOffsetG(PmodACL *InstancePtr, u8 bAxisParam)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**      bAxisParam:  byte indicating the axis whose acceleration will be read.
**                   Can be one of:
**                      ACL_PAR_AXIS_X - indicating X-axis
**                      ACL_PAR_AXIS_Y - indicating Y-axis
**                      ACL_PAR_AXIS_Z - indicating Z-axis
**
**   Return Value:
**      The offset for X-axis in "g".
**
**   Description:
**      This function returns the offset, in "g", for the specified axis.
**      It converts the 8-bit value quantified in the offset register into a
**      value expressed in "g", using a scale factor of 15.6 mg/LSB.
*/
float ACL_GetOffsetG(PmodACL *InstancePtr, u8 bAxisParam) {
   int8_t bOffsetVal;
   float dResult;
   switch (bAxisParam) {
   case ACL_PAR_AXIS_X:
      ACL_ReadSpi(InstancePtr, ACL_REG_OFSX, (u8*) &bOffsetVal, 1);
      break;
   case ACL_PAR_AXIS_Y:
      ACL_ReadSpi(InstancePtr, ACL_REG_OFSY, (u8*) &bOffsetVal, 1);
      break;
   case ACL_PAR_AXIS_Z:
      ACL_ReadSpi(InstancePtr, ACL_REG_OFSZ, (u8*) &bOffsetVal, 1);
      break;
   }
   dResult = (float) bOffsetVal * (float) ACL_CONV_OFFSET_G_LSB;
   return dResult;
}

/* ------------------------------------------------------------ */
/*** void ACL_CalibrateOneAxisGravitational(PmodACL *InstancePtr, u8 bAxisInfo)
**
**   Parameters:
**      InstancePtr: the PmodACL device to communicate with
**      bAxisInfo:   Parameter specifying axes orientation. Can be one of the
**                   following:
**         0   ACL_PAR_AXIS_XP - X-axis oriented in the gravitational direction
**         1   ACL_PAR_AXIS_XN - X-axis oriented opposite the gravitational
**                                  direction
**         2   ACL_PAR_AXIS_YP - Y-axis oriented in the gravitational direction
**         3   ACL_PAR_AXIS_YN - Y-axis oriented opposite the gravitational
**                                  direction
**         4   ACL_PAR_AXIS_ZP - Z-axis oriented in the gravitational direction
**         5   ACL_PAR_AXIS_ZN - Z-axis oriented opposite the gravitational
**                                  direction
**
**   Return Value:
**      None
**
**   Description:
**      The accepted argument values are between 0 and +5.
**      This function performs the calibration of the accelerometer by setting
**      the offset registers in the following manner:
**          Computes the correction factor that must be loaded in the offset
**          registers so that the acceleration readings are:
**              1 for the gravitational axis, if positive orientation
**             -1 for the gravitational axis, if negative orientation
**              0 for the other axes
**      The accepted argument values are between 0 and 5.
**      If the argument value is outside this range, the function does nothing.
**      The user should wait
*/
void ACL_CalibrateOneAxisGravitational(PmodACL *InstancePtr, u8 bAxisInfo) {
   // Perform calibration
   float dX, dSumX = 0, dY, dSumY = 0, dZ, dSumZ = 0;
   // Set the offset registers to 0
   // Put the device into standby mode to configure it.
   ACL_SetMeasure(InstancePtr, 0);
   ACL_SetOffsetG(InstancePtr, ACL_PAR_AXIS_X, 0);
   ACL_SetOffsetG(InstancePtr, ACL_PAR_AXIS_Y, 0);
   ACL_SetOffsetG(InstancePtr, ACL_PAR_AXIS_Z, 0);
   ACL_SetMeasure(InstancePtr, 1);

   // Read average acceleration on the three axes
   int idxAvg;

   int nCntMeasurements = 128;
   // Consume some readings
   for (idxAvg = 0; idxAvg < nCntMeasurements; idxAvg++) {
      ACL_ReadAccelG(InstancePtr, &dX, &dY, &dZ);
   }

   // Compute average values
   for (idxAvg = 0; idxAvg < nCntMeasurements; idxAvg++) {
      ACL_ReadAccelG(InstancePtr, &dX, &dY, &dZ);
      dSumX = dSumX + dX;
      dSumY = dSumY + dY;
      dSumZ = dSumZ + dZ;
   }

   dX = dSumX / nCntMeasurements;
   dY = dSumY / nCntMeasurements;
   dZ = dSumZ / nCntMeasurements;

   // Computes the correction that must be put in the offset registers so that
   // the acceleration readings are:
   //   1 for the gravitational axis, if positive
   //  -1 for the gravitational axis, if negative
   //   0 for the other axes
   switch (bAxisInfo) {
   case ACL_PAR_AXIS_XP:
      dX = 1.0 - dX;
      dY = 0.0 - dY;
      dZ = 0.0 - dZ;
      break;
   case ACL_PAR_AXIS_XN:
      dX = -1.0 - dX;
      dY = 0.0 - dY;
      dZ = 0.0 - dZ;
      break;
   case ACL_PAR_AXIS_YP:
      dY = 1.0 - dY;
      dX = 0.0 - dX;
      dZ = 0.0 - dZ;
      break;
   case ACL_PAR_AXIS_YN:
      dY = -1.0 - dY;
      dX = 0.0 - dX;
      dZ = 0.0 - dZ;
      break;
   case ACL_PAR_AXIS_ZP:
      dZ = 1.0 - dZ;
      dY = 0.0 - dY;
      dX = 0.0 - dX;
      break;
   case ACL_PAR_AXIS_ZN:
      dZ = -1.0 - dZ;
      dY = 0.0 - dY;
      dX = 0.0 - dX;
      break;
   }

   // Put the device into standby mode to configure it.
   ACL_SetMeasure(InstancePtr, 0);

   // Set the offset data to registers
   ACL_SetOffsetG(InstancePtr, ACL_PAR_AXIS_X, dX);
   ACL_SetOffsetG(InstancePtr, ACL_PAR_AXIS_Y, dY);
   ACL_SetOffsetG(InstancePtr, ACL_PAR_AXIS_Z, dZ);
   ACL_SetMeasure(InstancePtr, 1);
}
