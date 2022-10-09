/******************************************************************************/
/*                                                                            */
/* PmodCOLOR.c -- Driver definitions for the PmodCOLOR                        */
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

/***************************** Include Files *******************************/

#include "PmodCOLOR.h"

/************************** Function Definitions ***************************/

XIic_Config COLOR_IicConfig =
{
   0,
   0,
   0,
   2
};

/* ------------------------------------------------------------ */
/*    void COLOR_Begin(PmodCOLOR *InstancePtr, u32 IicBaseAddr,
 **         u32 GpioBaseAddr, u8 IicChipAddr)
 **
 **   Parameters:
 **      InstancePtr:  A PmodCOLOR object to start
 **      GpioBaseAddr: The Base address of the PmodCOLOR GPIO
 **      IicBaseAddr:  The Base address of the PmodCOLOR IIC
 **      IicChipAddr:  The chip address of the PmodCOLOR IIC (usually 0x29)
 **
 **   Return Value:
 **      none
 **
 **   Errors:
 **      none
 **
 **   Description:
 **      Initialize the PmodCOLOR.
 */
void COLOR_Begin(PmodCOLOR *InstancePtr, u32 IicBaseAddr, u32 GpioBaseAddr,
      u8 IicChipAddr) {
   XStatus Status;

   COLOR_IicConfig.BaseAddress = IicBaseAddr;
   InstancePtr->ChipAddr = IicChipAddr;
   InstancePtr->GpioBaseAddr = GpioBaseAddr;

   Xil_Out32((INTPTR) (InstancePtr->GpioBaseAddr + 4), 0x1);
   Xil_Out32((INTPTR) InstancePtr->GpioBaseAddr, 0x0);

   Status = XIic_CfgInitialize(&InstancePtr->Iic, &COLOR_IicConfig,
         COLOR_IicConfig.BaseAddress);
   if (Status != XST_SUCCESS) {
      return;
   }

   XIic_IntrGlobalDisable(&InstancePtr->Iic);
   XIic_SetAddress(&InstancePtr->Iic, XII_ADDR_TO_SEND_TYPE,
         InstancePtr->ChipAddr);
}

/* ------------------------------------------------------------ */
/*    void COLOR_ReadIIC(PmodCOLOR *InstancePtr, u8 reg, u8 *Data, int nData)
 **
 **   Parameters:
 **      InstancePtr: A PmodCOLOR object to read from
 **      reg:         The register address to begin reading from
 **      Data:        The buffer to place read data into
 **      nData:       The number of bytes to attempt to read
 **
 **     Return Value:
 **        none
 **
 **     Errors:
 **        none
 **
 **     Description:
 **        Read data from the PmodCOLOR. Note that in order to read registers,
 **        WriteIIC will need to be called to set up the transaction.
 */
void COLOR_ReadIIC(PmodCOLOR *InstancePtr, u8 reg, u8 *Data, int nData) {
   int Status;
   Status = XIic_Start(&InstancePtr->Iic);
   if (Status != XST_SUCCESS) {
      return;
   }
   if (InstancePtr->CurrentReg != reg) {
      XIic_Send(InstancePtr->Iic.BaseAddress, InstancePtr->ChipAddr, &reg, 1,
            XII_REPEATED_START_OPTION);
      InstancePtr->CurrentReg = reg;
   }
   XIic_Recv(InstancePtr->Iic.BaseAddress, InstancePtr->ChipAddr, Data, nData,
         XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->Iic);
}

/* ------------------------------------------------------------ */
/*    void COLOR_WriteIIC(PmodCOLOR *InstancePtr, u8 reg, u8 *Data, int nData)
 **
 **   Parameters:
 **      InstancePtr: A PmodCOLOR object to write to
 **      reg:         The register address to begin writing from
 **      Data:        The buffer containing bytes to be written
 **      nData:       The number of bytes to attempt to write
 **
 **   Return Value:
 **      none
 **
 **   Errors:
 **      none
 **
 **   Description:
 **      Write data to the PmodCOLOR.
 */
void COLOR_WriteIIC(PmodCOLOR *InstancePtr, u8 reg, u8 *Data, int nData) {
   u8 out[nData + 1];
   out[0] = reg;
   int Status, i;

   for (i = 0; i < nData; i++) {
      out[i + 1] = Data[i];
   }

   if (InstancePtr->CurrentReg != reg) {
      InstancePtr->CurrentReg = reg;
   }
   Status = XIic_Start(&InstancePtr->Iic);
   if (Status != XST_SUCCESS) {
      return;
   }

   XIic_Send(InstancePtr->Iic.BaseAddress, InstancePtr->ChipAddr, out,
         nData + 1, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->Iic);
}

/* ------------------------------------------------------------ */
/*    void COLOR_SetLED(PmodCOLOR *InstancePtr, u32 NewState)
 **
 **   Parameters:
 **      InstancePtr: A PmodCOLOR object to start
 **      NewState:    The value to set the LED_EN GPIO pin to, 1 or 0
 **
 **   Return Value:
 **      none
 **
 **   Errors:
 **      none
 **
 **   Description:
 **      Set the PmodCOLOR LED state
 */
void COLOR_SetLED(PmodCOLOR *InstancePtr, u32 NewState) {
   Xil_Out32((INTPTR) InstancePtr->GpioBaseAddr, (NewState & 0x1) << 1);
}

/* ------------------------------------------------------------ */
/*    u32 COLOR_GetINT(PmodCOLOR *InstancePtr)
 **
 **   Parameters:
 **      InstancePtr: A PmodCOLOR object to use
 **
 **   Return Value:
 **      The state of the ~INT GPIO pin, 1 or 0
 **
 **   Errors:
 **      none
 **
 **   Description:
 **      Reads the state of the PmodCOLOR interrupt GPIO
 */
u32 COLOR_GetINT(PmodCOLOR *InstancePtr) {
   return Xil_In32((INTPTR) InstancePtr->GpioBaseAddr) & 0x1;
}

/* ------------------------------------------------------------ */
/*    COLOR_Data COLOR_GetData(PmodCOLOR *InstancePtr)
 **
 **   Parameters:
 **      InstancePtr: A PmodCOLOR object to use
 **
 **   Return Value:
 **      16 bit Clear/Red/Green/Blue color channel values
 **
 **   Errors:
 **      none
 **
 **   Description:
 **      Retrieves a data packet from the PmodCOLOR
 */
COLOR_Data COLOR_GetData(PmodCOLOR *InstancePtr) {
   u8 reg = {COLOR_CMD_AUTO_INC_MASK | COLOR_RegCDATAL};
   COLOR_Data data;
   u8 buffer[8];
   XIic_Send(InstancePtr->Iic.BaseAddress, InstancePtr->ChipAddr, &reg, 1,
         XII_REPEATED_START_OPTION);
   XIic_Recv(InstancePtr->Iic.BaseAddress, InstancePtr->ChipAddr, buffer, 8,
         XIIC_STOP);
   data.c = (buffer[1] << 8) | buffer[0];
   data.r = (buffer[3] << 8) | buffer[2];
   data.g = (buffer[5] << 8) | buffer[4];
   data.b = (buffer[7] << 8) | buffer[6];
   return data;
}

/* ------------------------------------------------------------ */
/*    u8 COLOR_GetID(PmodCOLOR *InstancePtr)
 **
 **   Parameters:
 **      InstancePtr: A PmodCOLOR object to use
 **
 **   Return Value:
 **      The contents of the device ID register on the PmodCOLOR, 0x44 or 0x10
 **
 **   Errors:
 **      none
 **
 **   Description:
 **      Retrieves the PmodCOLOR's device ID
 */
u8 COLOR_GetID(PmodCOLOR *InstancePtr) {
   u8 bytes[1] = {0}, reg = COLOR_CMD_AUTO_INC_MASK | COLOR_RegID;
   XIic_Send(InstancePtr->Iic.BaseAddress, InstancePtr->ChipAddr, &reg, 1,
         XII_REPEATED_START_OPTION);
   XIic_Recv(InstancePtr->Iic.BaseAddress, InstancePtr->ChipAddr, bytes, 1,
         XIIC_STOP);
   return bytes[0];
}

/* ------------------------------------------------------------ */
/*    void COLOR_SetENABLE(PmodCOLOR *InstancePtr, u8 bits)
 **
 **   Parameters:
 **      InstancePtr: A PmodCOLOR object to use
 **      bits: The byte to write
 **
 **   Return Value:
 **      none
 **
 **   Errors:
 **      none
 **
 **   Description:
 **      Sets the contents of the PmodCOLOR's ENABLE register, used in the
 **      power up and initialization process
 */
void COLOR_SetENABLE(PmodCOLOR *InstancePtr, u8 bits) {
   u8 bytes[2] =
   {
      COLOR_CMD_REPEAT_MASK | COLOR_RegENABLE,
      bits
   };

   XIic_Send(InstancePtr->Iic.BaseAddress, InstancePtr->ChipAddr, bytes, 2,
         XIIC_STOP);
}

/* ------------------------------------------------------------ */
/*    u32 COLOR_IsBusy(PmodCOLOR *InstancePtr)
 **
 **   Parameters:
 **      InstancePtr: A PmodCOLOR object to use
 **
 **   Return Value:
 **      Whether the Pmod COLOR IIC device is busy or not, TRUE or FALSE
 **
 **   Errors:
 **      none
 **
 **   Description:
 **      Tests whether the Pmod COLOR IIC device is busy or not
 */
u32 COLOR_IsBusy(PmodCOLOR *InstancePtr) {
   return XIic_IsIicBusy(&InstancePtr->Iic);
}
