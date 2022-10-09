/******************************************************************************/
/*                                                                            */
/* main.c -- PmodACL Example Project                                          */
/*                                                                            */
/******************************************************************************/
/* Author: Thomas Kappenman                                                   */
/* Copyright 2016-2017, Digilent Inc.                                         */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This file contains code for running a demonstration of the PmodACL when    */
/* used with the PmodACL IP core.                                             */
/*                                                                            */
/* X, Y, and Z acceleration data in units of g are printed to a serial        */
/* terminal application ten times per second. Baud rates to set up this       */
/* connection should be 115200 for a Zynq device and whatever the AXI         */
/* IP is configured for a MicroBlaze device - typically 9600 or 115200 Baud.  */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    03/23/2016(TKappenman): Created                                         */
/*    08/15/2016(jpeyron):    Sleep and Zynq include fixes                    */
/*    08/11/2017(artvvb):     Validated for Vivado 2015.4                     */
/*    11/02/2017(artvvb):     2016.4 Maintenance                              */
/*    02/17/2018(atangzwj):   Validated for Vivado 2017.4                     */
/*                                                                            */
/******************************************************************************/

#include <stdio.h>
#include "PmodACL.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xparameters.h"

void DemoInitialize();
void DemoRun();
void DemoCleanup();
void EnableCaches();
void DisableCaches();

PmodACL acl;

int main(void) {
   DemoInitialize();
   DemoRun();
   DemoCleanup();
   return 0;
}

void DemoInitialize() {
   EnableCaches();
   xil_printf("ACL Demo Initializing");
   ACL_begin(&acl, XPAR_PMODACL_0_AXI_LITE_GPIO_BASEADDR,
         XPAR_PMODACL_0_AXI_LITE_SPI_BASEADDR);
   ACL_SetMeasure(&acl, 0);
   ACL_SetGRange(&acl, ACL_PAR_GRANGE_PM4G);
   ACL_SetMeasure(&acl, 1);
   ACL_CalibrateOneAxisGravitational(&acl, ACL_PAR_AXIS_ZP);
   sleep(1); // After calibration, some delay is required for the new settings
             // to take effect.
}

void DemoRun() {
   float x, y, z;

   xil_printf("ACL Demo Launched");

   while (1) {
      ACL_ReadAccelG(&acl, &x, &y, &z);
      printf("X=%f\tY=%f\tZ=%f\n\r", x, y, z);
      usleep(100000);
   }
}

void DemoCleanup() {
   DisableCaches();
}

void EnableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheEnable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheEnable();
#endif
#endif
}

void DisableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheDisable();
#endif
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheDisable();
#endif
#endif
}
