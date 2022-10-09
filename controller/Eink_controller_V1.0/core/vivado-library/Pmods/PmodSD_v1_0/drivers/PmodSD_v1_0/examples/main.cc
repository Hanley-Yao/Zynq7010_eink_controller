/******************************************************************************/
/*                                                                            */
/* main.cc -- Demo program for the PmodSD IP                                  */
/*                                                                            */
/******************************************************************************/
/* Author: Thomas Kappenman                                                   */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/*
*
* Copyright (c) 2013-2016, Digilent <www.digilentinc.com>
* Contact Digilent for the latest version.
*
* This program is free software; distributed under the terms of
* BSD 3-clause license ("Revised BSD License", "New BSD License", or "Modified BSD License")
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1.    Redistributions of source code must retain the above copyright notice, this
*        list of conditions and the following disclaimer.
* 2.    Redistributions in binary form must reproduce the above copyright notice,
*        this list of conditions and the following disclaimer in the documentation
*        and/or other materials provided with the distribution.
* 3.    Neither the name(s) of the above-listed copyright holder(s) nor the names
*        of its contributors may be used to endorse or promote products derived
*        from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo creates a file in your SD card and writes to it                  */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    08/10/2016(TommyK):   Created                                           */
/*    01/20/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#include "PmodSD.h"
#include "xil_cache.h"
#include "xil_printf.h"


void DemoInitialize();
void DemoRun();


int main(void) {
   Xil_ICacheEnable();
   Xil_DCacheEnable();

   DemoInitialize();
   DemoRun();
   return 0;
}

void DemoInitialize() {

}

void DemoRun() {
   DXSPISDVOL disk(XPAR_PMODSD_0_AXI_LITE_SPI_BASEADDR,
         XPAR_PMODSD_0_AXI_LITE_SDCS_BASEADDR);
   DFILE file;

   // The drive to mount the SD volume to.
   // Options are: "0:", "1:", "2:", "3:", "4:"
   static const char szDriveNbr[] = "0:";

   FRESULT fr;
   u32 bytesWritten = 0;
   u32 bytesRead, totalBytesRead;
   u8 buff[12], *buffptr;

   xil_printf("PmodSD Demo Launched\r\n");
   // Mount the disk
   DFATFS::fsmount(disk, szDriveNbr, 1);

   xil_printf("Disk mounted\r\n");

   fr = file.fsopen("newfile.txt", FA_WRITE | FA_CREATE_ALWAYS);
   if (fr == FR_OK) {
      xil_printf("Opened newfile.txt\r\n");
      fr = file.fswrite("It works!!!", 12, &bytesWritten);
      if (fr == FR_OK)
         xil_printf("Write successful\r\n");
      else
         xil_printf("Write failed\r\n");
      fr = file.fsclose();
      if (fr == FR_OK)
         xil_printf("File close successful\r\n");
      else
         xil_printf("File close failed\r\n");
   } else {
      xil_printf("Failed to open file to write to\r\n");
   }

   fr = file.fsopen("newfile.txt", FA_READ);
   if (fr == FR_OK) {
      buffptr = buff;
      totalBytesRead = 0;
      do {
         fr = file.fsread(buffptr, 1, &bytesRead);
         buffptr++;
         totalBytesRead += bytesRead;
      } while (totalBytesRead < 12 && fr == FR_OK);

      if (fr == FR_OK) {
         xil_printf("Read successful:");
         buff[totalBytesRead] = 0;
         xil_printf("'%s'\r\n", buff);
      } else {
         xil_printf("Read failed\r\n");
      }
   } else {
      xil_printf("Failed to open file to read from\r\n");
   }

   while (1);
}
