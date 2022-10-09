/******************************************************************************/
/*                                                                            */
/* PmodAD2.c -- Driver source for the PmodAD2                                 */
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

/***************************** Include Files *******************************/

#include "PmodAD2.h"

/************************** Function Definitions ***************************/

XIic_Config AD2_Config =
{
   0,
   0,
   0,
   2
};

/* ------------------------------------------------------------ */
/*** void AD2_begin(PmodAD2 *InstancePtr, u32 IIC_Address)
**
**   Parameters:
**      InstancePtr:  A PmodAD2 device to start
**      IIC_Address:  The base address of the PmodAD2 AXI IIC
**      Chip_Address: 7 bit Pmod IIC device address
**
**   Return Value:
**      none
**
**   Description:
**      Initializes the PmodAD2 device
*/
void AD2_begin(PmodAD2 *InstancePtr, u32 IIC_Address, u8 Chip_Address) {
   AD2_Config.BaseAddress = IIC_Address;
   InstancePtr->chipAddr = Chip_Address;
   AD2_IICInit(&InstancePtr->AD2Iic);
   XIic_SetAddress(&InstancePtr->AD2Iic, XII_ADDR_TO_SEND_TYPE,
         InstancePtr->chipAddr);
}

/* ------------------------------------------------------------ */
/*** AD2_IICInit
**
**   Parameters:
**      IicInstancePtr: PmodAD2 AXI IIC device to initialize
**
**   Return Value:
**      Success or failure status
**
**   Description:
**      Initializes the PmodAD2 AXI IIC device
*/
XStatus AD2_IICInit(XIic *IicInstancePtr) {
   int Status;

   Status = XIic_CfgInitialize(IicInstancePtr, &AD2_Config,
         AD2_Config.BaseAddress);
   if (Status != XST_SUCCESS) {
      return Status;
   }

   // Start the IIC driver so that the device is enabled.
   XIic_Start(IicInstancePtr);

   // Disable Global interrupt to use polled mode operation
   XIic_IntrGlobalDisable(IicInstancePtr);

   return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/*** XStatus AD2_ReadConv(PmodAD2 *InstancePtr, u16 *dataPtr)
**
**   Parameters:
**      InstancePtr: PmodAD2 device to initialize
**      dataPtr:     Pointer to return data address
**
**   Return Value:
**      Success or failure status
**      Conversion result and channel number at dataPtr
**
**   Description:
**      Reads 2 data bytes from conversion register
*/
XStatus AD2_ReadConv(PmodAD2 *InstancePtr, u16 *dataPtr) {
   int Status;
   u8 buf[2];

   Status = XIic_Start(&InstancePtr->AD2Iic);
   if (Status != XST_SUCCESS) {
      return Status;
   }

   XIic_Recv(InstancePtr->AD2Iic.BaseAddress, InstancePtr->chipAddr, buf, 2,
         XIIC_STOP);

   *dataPtr = (buf[0] << 8) | buf[1];

   Status = XIic_Stop(&InstancePtr->AD2Iic);
   if (Status != XST_SUCCESS) {
      return Status;
   }

   return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/*** XStatus AD2_WriteConfig(PmodAD2 *InstancePtr, u8 configuration)
**
**   Parameters:
**      InstancePtr:   PmodAD2 device to initialize
**      configuration: Value to load into the AD2 configuration register
**                     Bit definitions are defined as AD2_CONFIG_* in PmodAD2.h
**
**   Return Value:
**      Success or failure status
**
**   Description:
**      Writes the configuration into the AD2 config register
*/
XStatus AD2_WriteConfig(PmodAD2 *InstancePtr, u8 configuration) {
   int Status;

   Status = XIic_Start(&InstancePtr->AD2Iic);
   if (Status != XST_SUCCESS) {
      return Status;
   }

   XIic_Send(InstancePtr->AD2Iic.BaseAddress, InstancePtr->chipAddr,
         &configuration, 1, XIIC_STOP);

   Status = XIic_Stop(&InstancePtr->AD2Iic);

   return Status;
}
