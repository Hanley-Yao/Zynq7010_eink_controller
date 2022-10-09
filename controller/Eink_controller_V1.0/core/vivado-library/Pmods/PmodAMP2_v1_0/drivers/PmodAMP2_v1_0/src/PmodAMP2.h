/******************************************************************************/
/*                                                                            */
/* PmodAMP2.h -- Declaration for the PmodAMP2 library                         */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file declares the AMP2 library functions.                             */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    04/26/2017(ArtVVB):   Validated                                         */
/*    02/10/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PMODAMP2_H
#define PMODAMP2_H

/****************** Include Files ********************/

#include "PWM.h"
#include "xgpio.h"
#include "xtmrctr.h"

/******************* Definitions *********************/

#define AMP2_PWM_PERIOD 4096

typedef struct {
   XTmrCtr timer;
   XGpio gpio;
   u32 PWM_BaseAddress;
} PmodAMP2;

void AMP2_begin(PmodAMP2 *InstancePtr, u32 PwmBaseAddress, u32 GpioBaseAddress,
      u32 TmrBaseAddress);
int  AMP2_timerSetup(XTmrCtr *TmrInstancePtr, u32 TmrBaseAddress);
void AMP2_gpioSetup(XGpio *GpioInstancePtr, u32 GpioBaseAddress);

void AMP2_stop(PmodAMP2 *InstancePtr);
void AMP2_start(PmodAMP2 *InstancePtr);

#endif /* PMODAMP2_H_ */
