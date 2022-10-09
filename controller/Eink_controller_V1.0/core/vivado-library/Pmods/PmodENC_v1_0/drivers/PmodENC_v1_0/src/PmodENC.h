/******************************************************************************/
/*                                                                            */
/* PmodENC.h -- Header file for Pmod Encoder driver library                   */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains definitions for the driver and library for the Pmod     */
/* rotary shaft encoder.                                                      */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    04/19/2016(TommyK):   Created                                           */
/*    06/10/2016(ArtVVB):   Adapted for PmodENC                               */
/*    02/13/2017(ArtVVB):   Validated for 2015.4                              */
/*    10/25/2017(ArtVVB):   Validated for 2016.4                              */
/*    02/13/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PmodENC_H
#define PmodENC_H

/****************** Include Files ********************/

#include "xil_io.h"
#include "xil_types.h"
#include "xstatus.h"

/******************* Definitions *********************/

#define ENC_GPIO_PIN_A   0x1
#define ENC_GPIO_PIN_B   0x2
#define ENC_GPIO_PIN_BTN 0x4
#define ENC_GPIO_PIN_SWT 0x8

typedef struct PmodENC {
   u32 GPIO_addr;
} PmodENC;

void ENC_begin(PmodENC *InstancePtr, u32 GPIO_Address);
u32 ENC_getState(PmodENC *InstancePtr);
int ENC_getRotation(u32 state, u32 laststate);
int ENC_switchOn(u32 state);
int ENC_buttonPressed(u32 state);

#endif // PmodENC_H
