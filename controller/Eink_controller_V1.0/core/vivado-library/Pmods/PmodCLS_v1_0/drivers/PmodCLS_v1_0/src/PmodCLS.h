/******************************************************************************/
/*                                                                            */
/* PmodCLS.h -- PmodCLS Example Projects                                      */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen                                                       */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains code for running a demonstration of the PmodCLS when    */
/* used with the PmodCLS IP core.                                             */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/15/2016(MikelSkreen): Created                                        */
/*    08/17/2017(jPeyron):     Updated                                        */
/*    11/03/2017(artvvb):      2016.4 Maintenance                             */
/*    02/12/2018(atangzwj):    Validated for Vivado 2017.4                    */
/*                                                                            */
/******************************************************************************/

#ifndef PMODCLS_H
#define PMODCLS_H


/****************** Include Files ********************/

#include "xil_types.h"
#include "xspi.h"
#include "xspi_l.h"
#include "xstatus.h"

/* ------------------------------------------------------------ */
/*                  Definitions                                 */
/* ------------------------------------------------------------ */

#define CLS_PAR_SPD_MAX            625000

// Commands for the display list
#define CLS_ESC                    0x1B
#define CLS_BRACKET                0x5B // [
#define CLS_CURSOR_POS_CMD         0x48 // H
#define CLS_CURSOR_SAVE_CMD        0x73 // s
#define CLS_CURSOR_RSTR_CMD        0x75 // u
#define CLS_DISP_CLR_CMD           0x6A // j
#define CLS_ERASE_INLINE_CMD       0x4B // K
#define CLS_ERASE_FIELD_CMD        0x4E // N
#define CLS_LSCROLL_CMD            0x40 // @
#define CLS_RSCROLL_CMD            0x41 // A
#define CLS_RST_CMD                0x2A // *
#define CLS_DISP_EN_CMD            0x65 // e
#define CLS_DISP_MODE_CMD          0x68 // h
#define CLS_CURSOR_MODE_CMD        0x63 // c
#define CLS_TWI_SAVE_ADDR_CMD      0x61 // a
#define CLS_BR_SAVE_CMD            0x62 // b
#define CLS_PRG_CHAR_CMD           0x70 // p
#define CLS_SAVE_RAM_TO_EEPROM_CMD 0x74 // t
#define CLS_LD_EEPROM_TO_RAM_CMD   0x6C // l
#define CLS_DEF_CHAR_CMD           0x64 // d
#define CLS_COMM_MODE_SAVE_CMD     0x6D // m
#define CLS_EEPROM_WR_EN_CMD       0x77 // w
#define CLS_CURSOR_MODE_SAVE_CMD   0x6E // n
#define CLS_DISP_MODE_SAVE_CMD     0x6F // o

/* ------------------------------------------------------------ */
/*                  Errors Definitions                          */
/* ------------------------------------------------------------ */

#define CLS_LCDS_ERR_SUCCESS           0 // Action completed successfully
#define CLS_LCDS_ERR_ARG_ROW_RANGE     1 // Argument not within 0, 2 range for
                                         // rows
#define CLS_LCDS_ERR_ARG_COL_RANGE     2 // Argument not within 0, 39 range
#define CLS_LCDS_ERR_ARG_ERASE_OPTIONS 3 // Argument not within 0, 2 range for
                                         // erase types
#define CLS_LCDS_ERR_ARG_BR_RANGE      4 // Argument not within 0, 6 range
#define CLS_LCDS_ERR_ARG_TABLE_RANGE   5 // Argument not within 0, 3 range for
                                         // table selection
#define CLS_LCDS_ERR_ARG_COMM_RANGE    6 // Argument not within 0, 7 range
#define CLS_LCDS_ERR_ARG_CRS_RANGE     7 // Argument not within 0, 2 range for
                                         // cursor modes
#define CLS_LCDS_ERR_ARG_DSP_RANGE     8 // Argument not within 0, 3 range for
                                         // display settings types
#define CLS_LCDS_ERR_ARG_POS_RANGE     9 // Argument not within 0, 7 range for
                                         // characters position in the memory

// Other defines used for library functions
#define CLS_MAX 150

/* ------------------------------------------------------------ */
/*                  Register Addresses Definitions              */
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*                  Bit Masks Definitions                       */
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*                  Parameters Definitions                      */
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*                  Procedure Declarations                      */
/* ------------------------------------------------------------ */

typedef struct PmodCLS {
   XSpi CLSSpi;
} PmodCLS;

u8 CLS_WriteStringAtPos(PmodCLS *InstancePtr, uint8_t idxRow, uint8_t idxCol,
      char *strLn);
void CLS_CursorModeSet(PmodCLS *InstancePtr, uint8_t setCursor,
      uint8_t setBlink);
void CLS_DisplayClear(PmodCLS *InstancePtr);
void CLS_DisplayMode(PmodCLS *InstancePtr, uint8_t charNumber);

void CLS_begin(PmodCLS *InstancePtr, u32 SPI_Address);
void CLS_end(PmodCLS *InstancePtr);
int CLS_SPIInit(XSpi *SpiInstancePtr);
u8 CLS_ReadByte(PmodCLS *InstancePtr);
void CLS_WriteByte(PmodCLS *InstancePtr, u8 cmd);
void CLS_WriteSpi(PmodCLS *InstancePtr, u8 *wData, int nData);
void CLS_ReadSPI(PmodCLS *InstancePtr, u8 *rData, int nData);

#endif // PMODCLS_H
