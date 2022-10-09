/******************************************************************************/
/*                                                                            */
/* PmodAMP2.c -- Definitions for the PmodAMP2 library                         */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/* Copyright 2017, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file defines the AMP2 library functions to initialize, start, and     */
/* stop the IP core.                                                          */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    04/26/2017(ArtVVB):   Validated                                         */
/*    02/10/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodAMP2.h"

/**************************** Global Variables *****************************/

XTmrCtr_Config tmr_config = {
   0,
   0,
   100000000
};

XGpio_Config gpio_config = {
   0,
   0,
   0,
   0
};

/************************** Function Definitions ***************************/

/* ------------------------------------------------------------ */
/*** void AMP2_begin(PmodAMP2 *InstancePtr, u32 PwmBaseAddress,
**         u32 GpioBaseAddress, u32 TmrBaseAddress)
**
**   Parameters:
**      InstancePtr:     A PmodAMP2 object to initialize
**      PwmBaseAddress:  The base address of the PmodAMP2 PWM
**      GpioBaseAddress: The base address of the PmodAMP2 GPIO
**      TmrBaseAddress:  The base address of the PmodAMP2 Timer
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Initialize the PmodAMP2.
*/
void AMP2_begin(PmodAMP2 *InstancePtr, u32 PwmBaseAddress, u32 GpioBaseAddress,
      u32 TmrBaseAddress) {
   InstancePtr->PWM_BaseAddress = PwmBaseAddress;
   AMP2_gpioSetup(&InstancePtr->gpio, GpioBaseAddress);

   if (XST_SUCCESS != AMP2_timerSetup(&InstancePtr->timer, TmrBaseAddress)) {
      xil_printf("timer setup failed\n\r");
   }

   PWM_Set_Period(InstancePtr->PWM_BaseAddress, AMP2_PWM_PERIOD);
   PWM_Set_Duty(InstancePtr->PWM_BaseAddress, 0, 0);
}

/* ------------------------------------------------------------ */
/*** void AMP2_timerSetup(XTmrCtr *TmrInstancePtr, u32 TmrBaseAddress)
**
**   Parameters:
**      TmrInstancePtr: The PmodAMP2's AXI Timer object
**      TmrBaseAddress: The base address of the PmodAMP2 Timer
**
**   Return Value:
**      status: XST_SUCCESS if initialization was successful, failure code otherwise
**
**   Errors:
**      none
**
**   Description:
**      Initialize the PmodAMP2 Timer IP.
*/
int AMP2_timerSetup(XTmrCtr *TmrInstancePtr, u32 TmrBaseAddress) {
//   int status;
//   status = XTmrCtr_Initialize(TmrInstancePtr, TmrDeviceID);

   tmr_config.BaseAddress = TmrBaseAddress;
   XTmrCtr_CfgInitialize(TmrInstancePtr, &tmr_config, tmr_config.BaseAddress);

//   if(status != XST_SUCCESS) {
//      return XST_FAILURE;
//   }

   XTmrCtr_SetResetValue(TmrInstancePtr, 0, 0xFFFFFFFF - AMP2_PWM_PERIOD);
   XTmrCtr_SetOptions(TmrInstancePtr, 0,
   XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION);
   return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/*** void AMP2_gpioSetup(XGpio *GpioInstancePtr, u32 GpioBaseAddress)
**
**   Parameters:
**      GpioInstancePtr: The PmodAMP2's AXI Gpio object
**      GpioBaseAddress: The base address of the PmodAMP2 Gpio
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Initialize the PmodAMP2 GPIO IP.
*/
void AMP2_gpioSetup(XGpio *GpioInstancePtr, u32 GpioBaseAddress) {
   gpio_config.BaseAddress = GpioBaseAddress;
   XGpio_CfgInitialize(GpioInstancePtr, &gpio_config, gpio_config.BaseAddress);

   XGpio_SetDataDirection(GpioInstancePtr, 1, 0x0);
   XGpio_DiscreteWrite(GpioInstancePtr, 1, 0x5);
}

/* ------------------------------------------------------------ */
/*** void AMP2_stop(PmodAMP2 *InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodAMP2 object to halt
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Stops the timer and PWM of the AMP2
*/
void AMP2_stop(PmodAMP2 *InstancePtr) {
   XTmrCtr_Stop(&InstancePtr->timer, 0);
   PWM_Disable(InstancePtr->PWM_BaseAddress);
}

/* ------------------------------------------------------------ */
/*** void AMP2_start(PmodAMP2 *InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodAMP2 object to start
**
**   Return Value:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Starts the timer and PWM of the AMP2
*/
void AMP2_start(PmodAMP2 *InstancePtr) {
   XTmrCtr_Reset(&InstancePtr->timer, 0);
   XTmrCtr_Start(&InstancePtr->timer, 0);
   PWM_Enable(InstancePtr->PWM_BaseAddress);
}
