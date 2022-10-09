/******************************************************************************/
/*                                                                            */
/* PmodMAXSONAR.c -- Driver definitions for the PmodMAXSONAR                  */
/*                                                                            */
/******************************************************************************/
/* Author: Arvin Tang                                                         */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodMAXSONAR IP from Digilent       */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    10/18/2017(atangzwj): Created                                           */
/*    01/20/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/************ Include Files ************/

#include "PmodMAXSONAR.h"
#include "xil_io.h"


/************ Function Definitions ************/

/*
 * void MAXSONAR_begin(PmodMAXSONAR *InstancePtr, u32 GPIO_Addr, u32 clk_freq)
 * -----------------------------------------------------------------------------
 * Parameters:
 *    InstancePtr: Pointer to a PmodMAXSONAR object to initialize
 *    GPIO_Addr:   Base address of PmodMAXSONAR GPIO register
 *    clk_freq:    Clock frequency of the PmodMAXSONAR IP
 *
 * Return:
 *    void
 *
 * Description:
 *    Initialize the PmodMAXSONAR IP
 */
void MAXSONAR_begin(PmodMAXSONAR *InstancePtr, u32 GPIO_Address, u32 clk_freq) {
   InstancePtr->GPIO_addr = GPIO_Address;
   InstancePtr->ClockFreq = clk_freq;
}

/*
 * u32 MAXSONAR_getDistance(PmodMAXSONAR *InstancePtr)
 * -----------------------------------------------------------------------------
 * Parameters:
 *    InstancePtr: Pointer to a PmodMAXSONAR object to interact with
 *
 * Return:
 *    Distance to object detected by PmodMAXSONAR (in inches)
 *
 * Description:
 *    Return distance to object detected by PmodMAXSONAR, rounded to the nearest
 *    integer
 */
u32 MAXSONAR_getDistance(PmodMAXSONAR *InstancePtr) {
   u64 clk_edges = (u64) Xil_In32(InstancePtr->GPIO_addr + 4);
   u32 dist_10x = (u32) (clk_edges * 10000000 / InstancePtr->ClockFreq / 147);
   return (dist_10x + 5) / 10;
}
