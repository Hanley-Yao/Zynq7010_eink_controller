/******************************************************************************/
/*                                                                            */
/* PmodCMPS2.c -- Driver definitions for the PmodCMPS2                        */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodCMPS2 IP from Digilent.         */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    10/02/2017(artvvb):   Created                                           */
/*    02/17/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodCMPS2.h"

/************************** Configuration Struct ***************************/

XIic_Config CMPS2_Config =
{
   0, // DeviceId - unloaded & unused
   0, // BaseAddress - unloaded
   0, // Has10BitAddr - false
   2  // GpOutWidth - 2
};

/************************** Function Definitions ***************************/

/* ------------------------------------------------------------ */
/*** void CMPS2_begin(PmodCMPS2 *InstancePtr, u32 IIC_Address, u8 Chip_Address)
**
**   Parameters:
**      InstancePtr:  A PmodCMPS2 object to start
**      IIC_Address:  The Base address of the PmodCMPS2 IIC
**      Chip_Address: 7 bit Pmod device address
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Initialize the PmodCMPS2.
*/
void CMPS2_begin(PmodCMPS2 *InstancePtr, u32 IIC_Address, u8 Chip_Address) {
   CMPS2_Config.BaseAddress = IIC_Address;
   InstancePtr->chipAddr = Chip_Address;
   CMPS2_IICInit(&InstancePtr->CMPS2Iic);
   XIic_SetAddress(&InstancePtr->CMPS2Iic, XII_ADDR_TO_SEND_TYPE,
         InstancePtr->chipAddr);
}

/* ------------------------------------------------------------ */
/*** CMPS2_IICInit
**
**   Parameters:
**      none
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Initializes the PmodCMPS2 IIC.
*/
int CMPS2_IICInit(XIic *IicInstancePtr) {
   int Status;

   Status = XIic_CfgInitialize(IicInstancePtr, &CMPS2_Config,
         CMPS2_Config.BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   /*
    * Start the IIC driver so that the device is enabled.
    */
   XIic_Start(IicInstancePtr);

   /*
    * Disable Global interrupt to use polled mode operation
    */
   XIic_IntrGlobalDisable(IicInstancePtr);

   return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/*** CMPS2_ReadIIC
**
**   Parameters:
**      InstancePtr: PmodCMPS2 object to read from
**      reg:         Register to read from
**      Data:        Pointer to receive buffer
**      nData        Number of data values to read
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Reads nData data bytes from register reg
*/
void CMPS2_ReadIIC(PmodCMPS2 *InstancePtr, u8 reg, u8 *Data, int nData) {
   int Status;
   Status = XIic_Start(&InstancePtr->CMPS2Iic);
   if (Status != XST_SUCCESS) {
      return;
   }
   if (InstancePtr->currentRegister != reg) {
      XIic_Send(InstancePtr->CMPS2Iic.BaseAddress, InstancePtr->chipAddr, &reg,
            1, XII_REPEATED_START_OPTION);
      InstancePtr->currentRegister = reg;
   }

   XIic_Recv(InstancePtr->CMPS2Iic.BaseAddress, InstancePtr->chipAddr, Data,
         nData, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->CMPS2Iic);
}

/* ------------------------------------------------------------ */
/*** CMPS2_WriteIIC
**
**   Parameters:
**      InstancePtr: PmodCMPS2 object to write to
**      reg:         Register to send to
**      Data:        Pointer to data buffer to send
**      nData:       Number of data values to send
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Writes nData data bytes to register reg
*/
void CMPS2_WriteIIC(PmodCMPS2 *InstancePtr, u8 reg, u8 *Data, int nData) {
   u8 out[nData + 1];
   int i;
   int Status;

   out[0] = reg;
   for (i = 0; i < nData; i++)
      out[i + 1] = Data[i];

   if (InstancePtr->currentRegister != reg) {
      InstancePtr->currentRegister = reg;
   }

   Status = XIic_Start(&InstancePtr->CMPS2Iic);
   if (Status != XST_SUCCESS) {
      return;
   }

   XIic_Send(InstancePtr->CMPS2Iic.BaseAddress, InstancePtr->chipAddr, out,
         nData + 1, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->CMPS2Iic);
   if (Status != XST_SUCCESS) {
      return;
   }
}

/* ------------------------------------------------------------ */
/*** CMPS2_GetData
**
**   Parameters:
**      InstancePtr: PmodCMPS2 object to capture from
**
**   Return Value:
**      CMPS2_DataPacket - 16 bit x, y, and z axis magnetometer data
**
**   Errors:
**      none
**
**   Description:
**      Captures data from the first six registers of the CMPS2
*/
CMPS2_DataPacket CMPS2_GetData(PmodCMPS2 *InstancePtr) {
   CMPS2_DataPacket packet;
   u8 data;

   data = CMPS2_INTCONREG0_TAKEMEAS_MASK;
   CMPS2_WriteIIC(InstancePtr, CMPS2_INTCONREG0_REG, &data, 1);

   do {
      CMPS2_ReadIIC(InstancePtr, CMPS2_STATUS_REG, &data, 1);
   } while ((data & CMPS2_STATUS_MEASDONE_MASK) == 0);

   CMPS2_ReadIIC(InstancePtr, 0x00, (u8*) (&packet), 6);

   return packet;
}

/* ------------------------------------------------------------ */
/*** CMPS2_SetSensor
**
**   Parameters:
**      InstancePtr: PmodCMPS2 object to set up
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Charges the magnetometer sensor
*/
void CMPS2_SetSensor(PmodCMPS2 *InstancePtr) {
   u8 data = CMPS2_INTCONREG0_SETSENSOR_MASK;
   CMPS2_WriteIIC(InstancePtr, CMPS2_INTCONREG0_REG, &data, 1);
}

/* ------------------------------------------------------------ */
/*** CMPS2_SetSensor
**
**   Parameters:
**      InstancePtr: PmodCMPS2 object to set up
**      res:         output resolution to set, 0, 1, 2, or 3
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Selects one of 4 possible resolution options, see page 8 of Memsic
**      MMC3416xPJ data sheet
*/
void CMPS2_SetOutputResolution(PmodCMPS2 *InstancePtr, u8 res) {
   u8 data = res & 0x03;
   CMPS2_WriteIIC(InstancePtr, CMPS2_INTCONREG1_REG, &data, 1);
}
