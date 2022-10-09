/******************************************************************************/
/*                                                                            */
/* PmodGYRO.c -- Driver definitions for the PmodGYRO                          */
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

/***************************** Include Files *******************************/

#include "PmodGYRO.h"

/************************** Function Definitions ***************************/

XSpi_Config GYROConfig =
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
/*** GYRO_Int1Status
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     bool - If function executed successfully
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Reads the interrupt bit (bit 0) found at the base address of the GYRO
 **     and checks if the interrupt was triggered.
 */
GYRO_bool GYRO_Int1Status(PmodGYRO *InstancePtr) {
   //int 1 is bit 0
   int status = Xil_In32(InstancePtr->GPIO_Base_Addr);
   return (u8) (status & 0x01);
}

/* ------------------------------------------------------------ */
/*** GYRO_Int2Status
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     bool - If function executed successfully
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Reads the interrupt bit (bit 1) found at the base address of the GYRO
 **     and checks if the interrupt was triggered.
 */
GYRO_bool GYRO_Int2Status(PmodGYRO *InstancePtr) {
   //int 2 is bit 1
   int status = Xil_In32(InstancePtr->GPIO_Base_Addr);
   return (u8) ((status) & 0x02);
}

/* ------------------------------------------------------------ */
/*** GYRO_getX
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     xAxis - grabs the values from both L and H registers and returns the
 **     value.
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Reads from the L and H registers to get the current angular velocity in
 **     the X-Axis.
 */
int16_t GYRO_getX(PmodGYRO *InstancePtr) {
   uint8_t temp[2] = {0, 0};
   int16_t xAxis = 0;

   GYRO_ReadReg(InstancePtr, GYRO_OUT_X_L, temp, 2);

   xAxis = temp[0];
   xAxis |= (temp[1] << 8);

   return xAxis;
}

/* ------------------------------------------------------------ */
/*** GYRO_getY
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     yAxis - grabs the values from both L and H registers and returns the
 **     value.
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Reads from the L and H registers to get the current angular velocity in
 **     the Y-Axis.
 */
int16_t GYRO_getY(PmodGYRO *InstancePtr) {
   uint8_t temp[2] = { 0, 0 };
   int16_t yAxis = 0;

   GYRO_ReadReg(InstancePtr, GYRO_OUT_Y_L, temp, 2);

   yAxis = temp[0];
   yAxis |= (temp[1] << 8);

   return yAxis;
}

/* ------------------------------------------------------------ */
/*** GYRO_getZ
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     zAxis - grabs the values from both L and H registers and returns
 **             the value.
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Reads from the L and H registers to get the current angular velocity in
 **     the Z-Axis.
 */
int16_t GYRO_getZ(PmodGYRO *InstancePtr) {
   uint8_t temp[2] = { 0, 0 };
   int16_t zAxis = 0;

   GYRO_ReadReg(InstancePtr, GYRO_OUT_Z_L, temp, 2);

   zAxis = temp[0];
   zAxis |= (temp[1] << 8);

   return zAxis;
}

/* ------------------------------------------------------------ */
/*** GYRO_getTemp
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     temp - the current temperature reading
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Grabs the current temperature reading in Celsius and converts to
 **     Fahrenheit
 */
int8_t GYRO_getTemp(PmodGYRO *InstancePtr) {
   int8_t temp = 0;

   GYRO_ReadReg(InstancePtr, GYRO_OUT_TEMP, (uint8_t *) &temp, 1);

   temp = 44 - temp; // Celsius
   temp = 32 + (1.8 * temp); // Converts to Farenheit
   return temp;
}

/* ------------------------------------------------------------ */
/*** GYRO_getInt1Src
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     temp - used to store the value of interrupt register 1
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Returns the contents of Int 1 register
 */
uint8_t GYRO_getInt1Src(PmodGYRO *InstancePtr) {
   uint8_t temp = 0;

   GYRO_ReadReg(InstancePtr, GYRO_INT1_SRC, &temp, 1);

   return temp;
}

/* ------------------------------------------------------------ */
/*** GYRO_enableInt1
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Enables interrupt 1
 */
GYRO_bool GYRO_enableInt1(PmodGYRO *InstancePtr, uint8_t mode) {
   uint8_t temp = 0;

   GYRO_ReadReg(InstancePtr, GYRO_CTRL_REG3, &temp, 1);

   temp |= GYRO_REG3_I1_INT1;
   if (!GYRO_WriteReg(InstancePtr, GYRO_CTRL_REG3, &temp, 1))
      return 0;

   if (!GYRO_WriteReg(InstancePtr, GYRO_INT1_CFG, &mode, 1))
      return 0;

   return 1;
}

/* ------------------------------------------------------------ */
/*** GYRO_disableInt1
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Disables interrupt 1
 */
GYRO_bool GYRO_disableInt1(PmodGYRO *InstancePtr) {
   uint8_t temp = 0;

   GYRO_ReadReg(InstancePtr, GYRO_CTRL_REG3, &temp, 1);

   temp &= ~GYRO_REG3_I1_INT1;

   if (!GYRO_WriteReg(InstancePtr, GYRO_CTRL_REG3, &temp, 1))
      return 0;

   return 1;
}

/* ------------------------------------------------------------ */
/*** GYRO_enableInt2
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **     mode        - Interrupt mode
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Enables interrupt 2
 */
GYRO_bool GYRO_enableInt2(PmodGYRO *InstancePtr, uint8_t mode) {
   uint8_t temp = 0;

   GYRO_ReadReg(InstancePtr, GYRO_CTRL_REG3, &temp, 1);

   temp |= mode;

   if (!GYRO_WriteReg(InstancePtr, GYRO_CTRL_REG3, &temp, 1))
      return 0;

   return 1;
}

/* ------------------------------------------------------------ */
/*** GYRO_disableInt2
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Disables interrupt 2
 */
GYRO_bool GYRO_disableInt2(PmodGYRO *InstancePtr) {
   uint8_t temp = 0;

   GYRO_ReadReg(InstancePtr, GYRO_CTRL_REG3, &temp, 1);

   temp &= 0xF0;

   if (!GYRO_WriteReg(InstancePtr, GYRO_CTRL_REG3, &temp, 1))
      return 0;

   return 1;
}

/* ------------------------------------------------------------ */
/*** GYRO_setThsXL
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **     ths         - Threshold to set
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Sets the X-Axis Low threshold value
 */
GYRO_bool GYRO_setThsXL(PmodGYRO *InstancePtr, uint8_t ths) {
   return GYRO_WriteReg(InstancePtr, GYRO_INT1_TSH_XL, &ths, 1);
}

/* ------------------------------------------------------------ */
/*** GYRO_setThsXH
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **     ths         - Threshold to set
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Sets the X-Axis High threshold value
 */
GYRO_bool GYRO_setThsXH(PmodGYRO *InstancePtr, uint8_t ths) {
   return GYRO_WriteReg(InstancePtr, GYRO_INT1_TSH_XH, &ths, 1);
}

/* ------------------------------------------------------------ */
/*** GYRO_setThsYH
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **     ths         - Threshold to set
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Sets the Y-Axis High threshold value
 */
GYRO_bool GYRO_setThsYH(PmodGYRO *InstancePtr, uint8_t ths) {
   return GYRO_WriteReg(InstancePtr, GYRO_INT1_TSH_YH, &ths, 1);
}

/* ------------------------------------------------------------ */
/*** GYRO_setThsYL
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **     ths         - Threshold to set
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Sets the Y-Axis Low threshold value
 */
GYRO_bool GYRO_setThsYL(PmodGYRO *InstancePtr, uint8_t ths) {
   return GYRO_WriteReg(InstancePtr, GYRO_INT1_TSH_YL, &ths, 1);
}

/* ------------------------------------------------------------ */
/*** GYRO_setThsZH
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **     ths         - Threshold to set
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Sets the Z-Axis High threshold value
 */
GYRO_bool GYRO_setThsZH(PmodGYRO *InstancePtr, uint8_t ths) {
   return GYRO_WriteReg(InstancePtr, GYRO_INT1_TSH_ZH, &ths, 1);
}

/* ------------------------------------------------------------ */
/*** GYRO_setThsZL
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to send to
 **     ths         - Threshold to set
 **
 **  Return Value:
 **     bool - If successful
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Sets the Z-Axis Low threshold value
 */
GYRO_bool GYRO_setThsZL(PmodGYRO *InstancePtr, uint8_t ths) {
   return GYRO_WriteReg(InstancePtr, GYRO_INT1_TSH_ZL, &ths, 1);
}

/* ------------------------------------------------------------ */
/*** GYRO_begin
 **
 **  Parameters:
 **     InstancePtr: A PmodGYRO object to start
 **     SPI_Address: The Base address of the PmodGYRO SPI
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Initialize the PmodGYRO.
 */
GYRO_bool GYRO_begin(PmodGYRO *InstancePtr, u32 SPI_Address, u32 GPIO_Address) {
   uint8_t temp = 0;

   GYROConfig.BaseAddress = SPI_Address;
   InstancePtr->GPIO_Base_Addr = GPIO_Address;

   GYRO_SPIInit(&InstancePtr->GYROSpi);

   if (!GYRO_WriteReg(InstancePtr, GYRO_CTRL_REG3, &temp, 1)) {
      xil_printf("Control Reg not set.\n\r");
      return GYRO_false;
   }

   temp = GYRO_REG1_PD | GYRO_REG1_ZEN | GYRO_REG1_YEN | GYRO_REG1_XEN;
   if (!GYRO_WriteReg(InstancePtr, GYRO_CTRL_REG1, &temp, 1)) {
      xil_printf("More issues.\n\r");
      return GYRO_false;
   }
   // tell gpio tri-state to set int1 and int2 as inputs
   Xil_Out32(InstancePtr->GPIO_Base_Addr + 4, 0x03);
   return GYRO_true;
}

/* ------------------------------------------------------------ */
/*** GYRO_end(void)
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object to stop
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Stops the device
 */
void GYRO_end(PmodGYRO *InstancePtr) {
   XSpi_Stop(&InstancePtr->GYROSpi);
}

/* ------------------------------------------------------------ */
/*** GYRO_SPIInit
 **
 **  Parameters:
 **     XSpi *SpiInstancePtr - XSpi object to start
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Initializes the PmodGYRO SPI.
 */
int GYRO_SPIInit(XSpi *SpiInstancePtr) {
   int Status;

   Status = XSpi_CfgInitialize(SpiInstancePtr, &GYROConfig,
         GYROConfig.BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   Status = XSpi_SetOptions(SpiInstancePtr, (XSP_MASTER_OPTION
         | XSP_CLK_ACTIVE_LOW_OPTION | XSP_CLK_PHASE_1_OPTION)
         | XSP_MANUAL_SSELECT_OPTION);
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
/*** GYRO_Readbyte
 **
 **  Synopsis:
 **     byte = GYRO_Readbyte(&GYRO)
 **
 **  Parameters:
 **     PmodGYRO *InstancePtr - the PmodGYRO object to communicate with
 **
 **  Return Value:
 **     u8 byte - Byte read from XSpi
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Reads SPI
 */
u8 GYRO_ReadByte(PmodGYRO *InstancePtr) {
   u8 byte;
   XSpi_Transfer(&InstancePtr->GYROSpi, &byte, &byte, 1);
   return byte;
}

/* ------------------------------------------------------------ */
/*** GYRO_WriteByte
 **
 **  Parameters:
 **     InstancePtr - PmodGYRO object
 **     cmd         - Command to send
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Writes a single byte over SPI
 */
void GYRO_WriteByte(PmodGYRO *InstancePtr, u8 cmd) {
   XSpi_Transfer(&InstancePtr->GYROSpi, &cmd, NULL, 1);
}

/* ------------------------------------------------------------ */
/*** GYRO_WriteReg
 **
 **  Synopsis:
 **     GYRO_GYRO_WriteReg(&GYROobj, 0x3A, &bytearray, 5);
 **
 **  Parameters:
 **     InstancePtr - the PmodGYRO object to communicate with
 **     reg         - the starting register to write to
 **     wData       - the data to write
 **     nData       - the number of data bytes to write
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Writes the byte array to the chip via SPI. It will write the first byte
 **     into the specified register, then the next into the following register
 **     until all of the data has been sent.
 */
int GYRO_WriteReg(PmodGYRO *InstancePtr, u8 reg, u8 *wData, int nData) {
   // nData = 1
   // As requested by documentation, first byte contains:
   //    bit 7 = 0 because is a write operation
   //    bit 6 = 1 if more than one byte is written, 0 if one byte is written
   //    bits 5-0 - the address
   u8 bytearray[nData + 1];
   bytearray[0] = ((nData > 1) ? 0x40 : 0) | (reg & 0x3F);
   bytearray[1] = *wData;
   XSpi_Transfer(&InstancePtr->GYROSpi, bytearray, bytearray, nData + 1);

   return 1;
}

/* ------------------------------------------------------------ */
/*** GYRO_ReadReg
 **
 **  Synopsis:
 **     GYRO_ReadReg(&GYROobj, 0x3A, &bytearray, 5);
 **
 **  Parameters:
 **     InstancePtr - the PmodGYRO object to communicate with
 **     reg        - the starting register to read from
 **     rData     - the byte array to read into
 **     nData     - the number of data bytes to read
 **
 **  Return Value:
 **     None
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     Reads data in through SPI. It will read the first byte from the starting
 **     register, then the next from the following register. Data is stored into
 **     rData.
 */
void GYRO_ReadReg(PmodGYRO *InstancePtr, u8 reg, u8 *rData, int nData) {
   // As requested by documentation, first byte contains:
   //    bit 7 = 1 because is a read operation
   //    bit 6 = 1 if more than one byte is written, 0 if one byte is written
   //    bits 5-0 - the address
   u8 bytearray[nData + 1];

   bytearray[0] = ((nData > 1) ? 0xC0 : 0x80) | (reg & 0x3F);
   XSpi_Transfer(&InstancePtr->GYROSpi, bytearray, bytearray, nData + 1);
   memcpy(rData, &bytearray[1], nData);
}

/* ------------------------------------------------------------ */
/*** GYRO_SetRegisterBits
 **
 **  Synopsis:
 **     SetRegisterBits(&GYROobj, GYRO_ADR_POWER_CTL, bPowerControlMask,
 **           fValue);
 **
 **  Parameters:
 **     PmodGYRO *InstancePtr - the PmodGYRO object to communicate with
 **     u8 bRegisterAddress   - the address of the register whose bits are set
 **     u8 bMask              - the mask indicating which bits are affected
 **     u8 fValue             - 1 if the bits are set or 0 if their bits are
 **                             reset
 **
 **  Return Value:
 **     void
 **
 **  Errors:
 **     None
 **
 **  Description:
 **     This function sets the value of some bits (corresponding to the bMask)
 **     of a register (indicated by bRegisterAddress) to 1 or 0 (indicated by
 **     fValue).
 */
void GYRO_SetRegisterBits(PmodGYRO *InstancePtr, u8 reg, u8 mask,
   GYRO_bool fValue) {
   u8 regval;
   GYRO_ReadReg(InstancePtr, reg, &regval, 1);
   if (fValue)
      regval |= mask;
   else
      regval &= ~mask;
   GYRO_WriteReg(InstancePtr, reg, &regval, 1);
}

/* ------------------------------------------------------------ */
/*** GYRO_GetRegisterBits
 **
 **  Synopsis:
 **     return GetRegisterBits(&GYROobj, GYRO_ADR_BW_RATE, MSK_BW_RATE_RATE);
 **
 **  Parameters:
 **     InstancePtr      - the PmodGYRO object to communicate with
 **     bRegisterAddress - the address of the register whose bits are read
 **     bMask            - the mask indicating which bits are read
 **
 **
 **  Return Value:
 **     u8 - a byte containing only the bits corresponding to the mask.
 **
 **  Errors:
 **
 **
 **  Description:
 **     Returns a byte containing only the bits from a register (indicated by
 **     bRegisterAddress), corresponding to the bMask mask
 */
u8 GYRO_GetRegisterBits(PmodGYRO *InstancePtr, u8 bRegisterAddress, u8 bMask) {
   u8 bRegValue;
   GYRO_ReadReg(InstancePtr, bRegisterAddress, &bRegValue, 1);
   return bRegValue & bMask;
}
