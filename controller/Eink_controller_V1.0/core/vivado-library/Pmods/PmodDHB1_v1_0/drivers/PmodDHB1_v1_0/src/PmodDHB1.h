/******************************************************************************/
/*                                                                            */
/* PmodDHB1.h -- Driver definitions for the PmodDHB1                          */
/*                                                                            */
/******************************************************************************/
/* Author: Arvin Tang                                                         */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodDHB1 IP from Digilent           */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    09/13/2017(atangzwj): Created                                           */
/*    02/03/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#ifndef PmodDHB1_H
#define PmodDHB1_H

/************ Include Files ************/

#include "xil_types.h"


/************ Type Definitions ************/

typedef struct PmodDHB1 {
   u32 GPIO_addr;
   u32 PWM_addr;
   u32 PWM_per;
} PmodDHB1;


/************ Function Prototypes ************/

void DHB1_begin(PmodDHB1 *InstancePtr, u32 GPIO_Address, u32 PWM_Address,
      u32 Clk_Freq, u32 PWM_Per);

void DHB1_motorEnable(PmodDHB1 *InstancePtr);

void DHB1_motorDisable(PmodDHB1 *InstancePtr);

void DHB1_setDirs(PmodDHB1 *InstancePtr, u8 dir1, u8 dir2);

void DHB1_setDir1(PmodDHB1 *InstancePtr, u8 dir1);

void DHB1_setDir2(PmodDHB1 *InstancePtr, u8 dir2);

void DHB1_setMotorSpeeds(PmodDHB1 *InstancePtr, u8 m1, u8 m2);

void DHB1_setMotor1Speed(PmodDHB1 *InstancePtr, u8 m1);

void DHB1_setMotor2Speed(PmodDHB1 *InstancePtr, u8 m2);

#endif // PmodDHB1_H
