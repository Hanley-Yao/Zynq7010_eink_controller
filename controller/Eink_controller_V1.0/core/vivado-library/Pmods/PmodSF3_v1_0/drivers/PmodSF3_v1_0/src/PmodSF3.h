/******************************************************************************/
/*                                                                            */
/* PmodSF3.h -- PmodSF3 Driver Header                                         */
/*                                                                            */
/******************************************************************************/
/* Author: Andrew Holzer                                                      */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains driver prototypes, types, and macros for the PmodSF3    */
/* driver source.	                                                          */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    ??/??/????(AHolzer):  Created                                           */
/*    07/26/2017(ArtVVB):   Refactored and Validated                          */
/*    03/16/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODSF3_H_
#define PMODSF3_H_

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/

#include "intc.h"
#include "xspi.h"
#include "xstatus.h"

#define SF3_MANUFACTURER_ID 0x20

#define SF3_COMMAND_PAGE_PROGRAM 	0x02 // Page program command
#define SF3_COMMAND_QUAD_WRITE 		0x32 // Quad Input Fast Program
#define SF3_COMMAND_RANDOM_READ 	0x03 // Random read command
#define SF3_COMMAND_DUAL_READ		0x3B // Dual Output Fast Read
#define SF3_COMMAND_DUAL_IO_READ	0xBB // Dual IO Fast Read
#define SF3_COMMAND_QUAD_READ		0x6B // Quad Output Fast Read
#define SF3_COMMAND_QUAD_IO_READ	0xEB // Quad IO Fast Read
#define SF3_COMMAND_WRITE_ENABLE 	0x06 // Write Enable command
#define SF3_COMMAND_SECTOR_ERASE	0xD8 // Sector Erase command
#define SF3_COMMAND_BULK_ERASE		0xC7 // Bulk Erase command
#define SF3_COMMAND_READ_STATUSREG 	0x05 // Status read command
#define SF3_COMMAND_READ_ID 		0x9E // ID read command
#define SF3_COMMAND_WRITE_STATUSREG 0x01 // Status write command

/*
 * These definitions specify the EXTRA bytes in each of the command
 * transactions. This count includes the Command byte, address bytes and any
 * don't care bytes needed.
 */
#define SF3_WRITE_EXTRA_BYTES 	 4
#define SF3_READ_MIN_EXTRA_BYTES 4
#define SF3_READ_MAX_EXTRA_BYTES 9
#define SF3_WRITE_ENABLE_BYTES 	 1
#define SF3_SECTOR_ERASE_BYTES	 4
#define SF3_BULK_ERASE_BYTES	 1
#define SF3_STATUS_READ_BYTES	 2
#define SF3_STATUS_WRITE_BYTES	 2
#define SF3_ID_READ_BYTES		 20

// Flash not busy mask in the status register of the flash device
#define SF3_FLASH_SR_IS_READY_MASK 0x01

// Number of bytes per page in the flash device
#define SF3_PAGE_SIZE 				256

#define SF3_PAGES_PER_SUBSECTOR		16
#define SF3_SUBSECTORS_PER_SECTOR	16
#define SF3_NUM_SECTORS				8192
#define SF3_MAX_ADDRESS 			0x1FFFFFF

// Address of the page to perform erase, write and read operations.
#define SF3_FLASH_TEST_ADDRESS	0x004000

/*
 * The following definitions specify the number of dummy bytes to ignore in the
 * data read from the flash, through various Read commands. This is apart from
 * the dummy bytes returned in response to the command and address transmitted.
 */
/*
 * After transmitting dual Read command and address on DIO0, the quad spi device
 * configures DIO0 and DIO1 in input mode and receives data on both DIO0 and
 * DIO1 for 8 dummy clock cycles. So we end up with 16 dummy bits in DRR. The
 * same logic applies to Quad read command, so we end up with 4 dummy bytes in
 * that case
 */
#define SF3_DUAL_READ_DUMMY_BYTES 2
#define SF3_QUAD_READ_DUMMY_BYTES 4

#define SF3_DUAL_IO_READ_DUMMY_BYTES 2
#define SF3_QUAD_IO_READ_DUMMY_BYTES 5

typedef struct PmodSF3 {
   XSpi SF3Spi;
   INTC sIntc;
   u8 Status;
} PmodSF3;

/************************** Function Prototypes ******************************/
XStatus SF3_begin(PmodSF3 *InstancePtr, INTC *IntcPtr, const ivt_t ivt[],
      u32 SPI_Address);
XStatus SF3_SpiInit(XSpi *SpiPtr);
XStatus SF3_FlashWriteEnable(PmodSF3 *InstancePtr);
XStatus SF3_FlashWrite(PmodSF3 *InstancePtr, u32 Addr, u32 ByteCount,
      u8 WriteCmd, u8 **BufferPtr);
XStatus SF3_FlashRead(PmodSF3 *InstancePtr, u32 Addr, u32 ByteCount, u8 ReadCmd,
      u8 **BufferPtr);
XStatus SF3_BulkErase(PmodSF3 *InstancePtr);
XStatus SF3_SectorErase(PmodSF3 *InstancePtr, u32 Addr);
XStatus SF3_GetStatus(PmodSF3 *InstancePtr);
XStatus SF3_WaitForFlashReady(PmodSF3 *InstancePtr);
XStatus SF3_ReadID(PmodSF3 *InstancePtr);

void SF3_SpiHandler(void *CallBackRef, u32 StatusEvent, unsigned int ByteCount);

#ifdef __cplusplus
}
#endif
#endif /* PMODSF3_H_ */
