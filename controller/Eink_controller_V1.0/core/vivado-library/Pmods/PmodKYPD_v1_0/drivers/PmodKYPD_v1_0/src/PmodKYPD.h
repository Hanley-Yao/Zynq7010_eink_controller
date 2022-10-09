/******************************************************************************/
/*                                                                            */
/* PmodKYPD.h -- Driver definitions for the Pmod Keypad                       */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen                                                       */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This library contains the definitions of the Pmod Keypad device and the    */
/* functions used to control it.                                              */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/08/2016(MikelS):   Created                                           */
/*    08/17/2017(artvvb):   Validated for Vivado 2015.4                       */
/*    08/30/2017(artvvb):   Validated for Vivado 2016.4                       */
/*                          Added Multiple keypress error detection           */
/*    01/27/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODKYPD_H
#define PMODKYPD_H

/****************************** Include Files ***************************/

#include "xil_io.h"
#include "xstatus.h"
#include "xil_types.h"

/**************************** Type Definitions **************************/

typedef struct PmodKYPD {
   u32 GPIO_addr;
   u8 keytable[16];
   u32 keytable_loaded;
} PmodKYPD;

#define KYPD_NO_KEY     0
#define KYPD_SINGLE_KEY 1
#define KYPD_MULTI_KEY  2

/************************** Function Definitions ************************/

void KYPD_begin(PmodKYPD *InstancePtr, u32 GPIO_Address);
void KYPD_loadKeyTable(PmodKYPD *InstancePtr, u8 keytable[16]);
void KYPD_setCols(PmodKYPD *InstancePtr, u32 cols);
u32 KYPD_getRows(PmodKYPD *InstancePtr);
u16 KYPD_getKeyStates(PmodKYPD *InstancePtr);
u32 KYPD_getKeyPressed(PmodKYPD *InstancePtr, u16 keystate, u8 *cptr);

#endif // PmodKYPD_H
