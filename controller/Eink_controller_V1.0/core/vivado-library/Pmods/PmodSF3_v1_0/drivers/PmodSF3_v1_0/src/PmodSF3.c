/******************************************************************************/
/*                                                                            */
/* PmodSF3.c -- PmodSF3 Driver Header                                         */
/*                                                                            */
/******************************************************************************/
/* Author: Andrew Holzer                                                      */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains function definitions for the PmodSF3 driver.            */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    ??/??/????(AHolzer):  Created                                           */
/*    07/26/2017(ArtVVB):   Refactored and Validated                          */
/*    03/16/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *********************************/

#include "PmodSF3.h"

/************************** Variable Definitions *****************************/

static volatile int TransferInProgress;

// This variable tracks any errors that occur during interrupt processing
static int ErrorCount;

/*
 * Byte offset value written to Flash. This need to be redefined for writing
 * different patterns of data to the Flash device.
 */

XSpi_Config XSpi_SF3Config = {
   0,
   0,
   1,
   0,
   1,
   8,
   2,
   0,
   0,
   0,
   0
};

/*****************************************************************************
* This function initializes the SF3 device and attaches and enables it's SPI
* interrupt
*
* @param    InstancePtr is a pointer to the instance of the SF3 device.
* @param    ivt is the interrupt vector table containing the SF3 SPI handler as
*              it's first element.
* @param    SPI_Address is the base address of the SF3 SPI device.
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     None
*
******************************************************************************/
XStatus SF3_begin(PmodSF3 *InstancePtr, INTC *IntcPtr, const ivt_t ivt[],
      u32 SPI_Address) {
   XStatus Status;

   XSpi_SF3Config.BaseAddress = SPI_Address;

   // Initialize SPI
   Status = SF3_SpiInit(&InstancePtr->SF3Spi);
   if (Status != XST_SUCCESS) {
      xil_printf("\r\nError initializing SPI");
      return XST_FAILURE;
   }
   // Enable all interrupts in our interrupt vector table
   // Make sure all driver instances using interrupts are initialized first
   EnableInterrupts(IntcPtr, &ivt[0], 1);

   XSpi_IntrGlobalEnable(&InstancePtr->SF3Spi);

   return XST_SUCCESS;
}

/*****************************************************************************
* This function initializes the SPI and performs a self test to ensure that the
* HW was set correctly
*
* @param    SpiPtr is a pointer to the instance of the SPI device.
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     None
*
******************************************************************************/
XStatus SF3_SpiInit(XSpi *SpiPtr) {
   XStatus Status;
   XSpi_Config *ConfigPtr;

   Xil_AssertNonvoid(SpiPtr != NULL);

   ConfigPtr = &XSpi_SF3Config;
   if (ConfigPtr == NULL) {
      return XST_DEVICE_NOT_FOUND;
   }

   Status = XSpi_CfgInitialize(SpiPtr, ConfigPtr, ConfigPtr->BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   // Set the handler for the SPI that is called from the interrupt context
   XSpi_SetStatusHandler(SpiPtr, SpiPtr, (XSpi_StatusHandler) SF3_SpiHandler);

   Status = XSpi_SetOptions(SpiPtr,
         (XSP_MASTER_OPTION | XSP_MANUAL_SSELECT_OPTION));
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   Status = XSpi_SetSlaveSelect(SpiPtr, 1);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   // Start the SPI driver, enabling the device
   Status = XSpi_Start(SpiPtr);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   return XST_SUCCESS;
}

/******************************************************************************
* This function enables writes to the Winbond Serial Flash memory.
*
* @param    InstancePtr is a pointer to the instance of the PmodSF3 device.
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     None
*
******************************************************************************/
XStatus SF3_FlashWriteEnable(PmodSF3 *InstancePtr) {
   XStatus Status;
   u8 Buffer[SF3_WRITE_ENABLE_BYTES];

   Status = SF3_WaitForFlashReady(InstancePtr);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   Buffer[0] = SF3_COMMAND_WRITE_ENABLE;

   TransferInProgress = TRUE;
   Status = XSpi_Transfer(&InstancePtr->SF3Spi, Buffer, NULL,
         SF3_WRITE_ENABLE_BYTES);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   while (TransferInProgress)
      ;
   if (ErrorCount != 0) {
      ErrorCount = 0;
      return XST_FAILURE;
   }

   return XST_SUCCESS;
}

/*****************************************************************************
* This function writes the data to the specified locations in the Serial Flash
* memory.
*
* @param    InstancePtr is a pointer to the instance of the PmodSF3 device.
* @param    Addr is the address in the Buffer, where to write the data.
* @param    ByteCount is the number of bytes to be written.
* @param    WriteCmd selects which command to use to write with.
* @param    BufferPtr is the pointer to a data buffer
*              (minimum size ByteCount + SF3_WRITE_EXTRA_BYTES).
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     The Buffer at BufferPtr is moved forward by the number of command bytes used
*
******************************************************************************/
XStatus SF3_FlashWrite(PmodSF3 *InstancePtr, u32 Addr, u32 ByteCount,
      u8 WriteCmd, u8 **BufferPtr) {
   XStatus Status;

   Status = SF3_WaitForFlashReady(InstancePtr);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   // Prepare the buffer with write command data
   (*BufferPtr)[0] = WriteCmd;
   (*BufferPtr)[1] = (u8) (Addr >> 16);
   (*BufferPtr)[2] = (u8) (Addr >> 8);
   (*BufferPtr)[3] = (u8) (Addr);

   TransferInProgress = TRUE;
   Status = XSpi_Transfer(&InstancePtr->SF3Spi, *BufferPtr, NULL,
         (ByteCount + SF3_WRITE_EXTRA_BYTES));

   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   while (TransferInProgress)
      ;

   // BufferPtr should point to the beginning of the data written
   *BufferPtr += 4;

   if (ErrorCount != 0) {
      ErrorCount = 0;
      return XST_FAILURE;
   }

   return XST_SUCCESS;
}

/*****************************************************************************
* This function reads the data from the Serial Flash Memory.
*
* @param    InstancePtr is a pointer to the instance of the PmodSF3 device.
* @param    Addr is the starting address in the Flash Memory from which the data
*              is to be read.
* @param    ByteCount is the number of bytes to be read.
* @param    ReadCmd selects which command to use to read with.
* @param    BufferPtr is a pointer to the buffer which data is to be read into,
*              expected size of ByteCount + DummyBytes(ReadCmd).
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     None
*
******************************************************************************/
XStatus SF3_FlashRead(PmodSF3 *InstancePtr, u32 Addr, u32 ByteCount, u8 ReadCmd,
      u8 **BufferPtr) {
   XStatus Status;
   u32 DummyBytes;

   Status = SF3_WaitForFlashReady(InstancePtr);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   // Prepare the buffer with the command data
   (*BufferPtr)[0] = ReadCmd;
   (*BufferPtr)[1] = (u8) (Addr >> 16);
   (*BufferPtr)[2] = (u8) (Addr >> 8);
   (*BufferPtr)[3] = (u8) (Addr);

   // Select the number of additional bytes required before data is passed
   // depending on the command
   switch (ReadCmd) {
   case SF3_COMMAND_DUAL_READ:
   case SF3_COMMAND_DUAL_IO_READ:
      DummyBytes = SF3_DUAL_READ_DUMMY_BYTES;
      break;
   case SF3_COMMAND_QUAD_IO_READ:
      DummyBytes = SF3_QUAD_IO_READ_DUMMY_BYTES;
      break;
   case SF3_COMMAND_QUAD_READ:
      DummyBytes = SF3_QUAD_READ_DUMMY_BYTES;
      break;
   default:
      DummyBytes = 0;
      break;
   }

   TransferInProgress = TRUE;
   Status = XSpi_Transfer(&InstancePtr->SF3Spi, *BufferPtr, *BufferPtr,
         (ByteCount + DummyBytes + SF3_READ_MIN_EXTRA_BYTES));
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   while (TransferInProgress)
      ;

   // Increment the pointer forward to the beginning of data
   *BufferPtr += DummyBytes + SF3_READ_MIN_EXTRA_BYTES;

   if (ErrorCount != 0) {
      ErrorCount = 0;
      return XST_FAILURE;
   }

   return XST_SUCCESS;
}

/*****************************************************************************
* This function erases the entire contents of the Micron Serial Flash device.
*
* @param    InstancePtr is a pointer to the instance of the PmodSF3 device.
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     The erased bytes will read as 0xFF.
*
******************************************************************************/
XStatus SF3_BulkErase(PmodSF3 *InstancePtr) {
   XStatus Status;
   u8 Buffer[SF3_BULK_ERASE_BYTES];

   Status = SF3_WaitForFlashReady(InstancePtr);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   Buffer[0] = SF3_COMMAND_BULK_ERASE;

   TransferInProgress = TRUE;
   Status = XSpi_Transfer(&InstancePtr->SF3Spi, Buffer, NULL,
         SF3_BULK_ERASE_BYTES);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   while (TransferInProgress)
      ;
   if (ErrorCount != 0) {
      ErrorCount = 0;
      return XST_FAILURE;
   }

   return XST_SUCCESS;
}

/******************************************************************************
* This function erases the contents of an entire 64KB sector.
*
* @param    InstancePtr is a pointer to the instance of the PmodSF3 device.
* @param    Addr is the address of the first byte in the sector to be erased.
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     None
*
******************************************************************************/
XStatus SF3_SectorErase(PmodSF3 *InstancePtr, u32 Addr) {
   XStatus Status;
   u8 Buffer[SF3_SECTOR_ERASE_BYTES];

   Status = SF3_WaitForFlashReady(InstancePtr);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   Buffer[0] = SF3_COMMAND_SECTOR_ERASE;
   Buffer[1] = (u8) (Addr >> 16);
   Buffer[2] = (u8) (Addr >> 8);
   Buffer[3] = (u8) (Addr);

   TransferInProgress = TRUE;
   Status = XSpi_Transfer(&InstancePtr->SF3Spi, Buffer, NULL,
         SF3_SECTOR_ERASE_BYTES);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   while (TransferInProgress)
      ;
   if (ErrorCount != 0) {
      ErrorCount = 0;
      return XST_FAILURE;
   }

   return XST_SUCCESS;
}

/******************************************************************************
* This function captures the status register of the SF3 and stores it in
* InstancePtr->Status.
*
* @param    InstancePtr is a pointer to the instance of the PmodSF3 device.
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     This function reads the status register of the Buffer and waits
*           until the WIP bit of the status register becomes 0.
*
******************************************************************************/
XStatus SF3_GetStatus(PmodSF3 *InstancePtr) {
   XStatus Status;

   u8 Buffer[SF3_STATUS_READ_BYTES];

   Buffer[0] = SF3_COMMAND_READ_STATUSREG;

   TransferInProgress = TRUE;
   Status = XSpi_Transfer(&InstancePtr->SF3Spi, Buffer, Buffer,
         SF3_STATUS_READ_BYTES);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   while (TransferInProgress)
      ;
   if (ErrorCount != 0) {
      ErrorCount = 0;
      return XST_FAILURE;
   }

   InstancePtr->Status = Buffer[1];

   return XST_SUCCESS;
}

/******************************************************************************
* This function waits until the serial Flash is ready to accept next command.
*
* @param    InstancePtr is a pointer to the instance of the PmodSF3 device.
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     This function reads the status register of the Buffer and waits
*           until the WIP bit of the status register becomes 0.
*
******************************************************************************/
XStatus SF3_WaitForFlashReady(PmodSF3 *InstancePtr) {
   XStatus Status;
   u8 StatusReg;

   while (1) {
      /*
       * Get the Status REgister. The status register content is
       * stored at the second byte pointed by the ReadBuffer.
       */
      Status = SF3_GetStatus(InstancePtr);
      if (Status != XST_SUCCESS) {
         return XST_FAILURE;
      }

      /*
       * Check to see if the flash is ready to accept the next command.
       * If so, break and return successfully;
       */
      StatusReg = InstancePtr->Status;
      if ((StatusReg & 0x01) == 0) {
         break;
      }
   }

   return XST_SUCCESS;
}

/*****************************************************************************
* This function reads the ID register of the serial Flash
*
* @param    InstancePtr is a pointer to the instance of the PmodSF3 device.
*
* @return   XST_SUCCESS if successful else XST_FAILURE.
*
* @note     None
*
******************************************************************************/
XStatus SF3_ReadID(PmodSF3 *InstancePtr) {
   XStatus Status;
   int i;
   u8 Buffer[SF3_ID_READ_BYTES];

   Buffer[0] = SF3_COMMAND_READ_ID;

   TransferInProgress = TRUE;
   Status = XSpi_Transfer(&InstancePtr->SF3Spi, Buffer, Buffer, 20);

   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   while (TransferInProgress)
      ;
   if (ErrorCount != 0) {
      ErrorCount = 0;
      return XST_FAILURE;
   }

   for (i = 0; i < 20; i++)
      xil_printf("\r\nID=%x", Buffer[i]);

   return XST_SUCCESS;
}

/*****************************************************************************
* This function is the handler which performs processing for the SPI driver.
* It is called from an interrupt context such that the amount of processing
* performed should be minimized. It is called when a transfer of SPI data
* completes or an error occurs.
*
* This handler provides an example of how to handle SPI interrupts and
* is application specific.
*
* @param    CallBackRef is the upper layer callback reference passed back
*           when the callback function is invoked.
* @param    StatusEvent is the event that just occurred.
* @param    ByteCount is the number of bytes transferred up until the event
*           occurred.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
void SF3_SpiHandler(void *CallBackRef, u32 StatusEvent,
      unsigned int ByteCount) {
   TransferInProgress = FALSE;

   if (StatusEvent != XST_SPI_TRANSFER_DONE) {
      ErrorCount++;
   }
}
