/******************************************************************************/
/*                                                                            */
/* WiFiScan -- Scans the network for all available routers and prints their   */
/*             parameters to the serial monitor                               */
/*                                                                            */
/******************************************************************************/
/* Author: Keith Vogel                                                        */
/* Copyright 2014, Digilent Inc.                                              */
/******************************************************************************/
/*
 *
 * Copyright (c) 2013-2014, Digilent <www.digilentinc.com>
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
/* Revision History:                                                          */
/*                                                                            */
/*    05/14/2014(KeithV):   Created                                           */
/*    08/09/2016(TommyK):   Modified to use Microblaze/Zynq                   */
/*    12/02/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    01/20/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

#include "PmodWIFI.h"
#include "xil_cache.h"

#ifdef __MICROBLAZE__
#define PMODWIFI_VEC_ID XPAR_INTC_0_PMODWIFI_0_VEC_ID
#else
#define PMODWIFI_VEC_ID XPAR_FABRIC_PMODWIFI_0_WF_INTERRUPT_INTR
#endif

#define MRFVERSION

typedef enum {
   NONE = 0,
   WIFISCAN,
   PRINTAPINFO,
   ERROR,
   STOP,
   DONE
} STATE;

STATE state = WIFISCAN;

IPSTATUS status = ipsSuccess;
int cNetworks = 0;
int iNetwork = 0;

void DemoInitialize();
void DemoRun();


int main(void) {
   Xil_ICacheEnable();
   Xil_DCacheEnable();

   xil_printf("Wifi Scan 3.0\r\n");

   state = WIFISCAN; //Scan WiFi first, verify WiFi connection
   DemoInitialize();
   DemoRun();
   return 0;
}

void DemoInitialize() {
   setPmodWifiAddresses(
      XPAR_PMODWIFI_0_AXI_LITE_SPI_BASEADDR,
      XPAR_PMODWIFI_0_AXI_LITE_WFGPIO_BASEADDR,
      XPAR_PMODWIFI_0_AXI_LITE_WFCS_BASEADDR,
      XPAR_PMODWIFI_0_S_AXI_TIMER_BASEADDR
   );
   setPmodWifiIntVector(PMODWIFI_VEC_ID);
}

void DemoRun() {
   while (1) {
      switch (state) {
      case WIFISCAN:
         if (deIPcK.wfScan(&cNetworks, &status)) {
            xil_printf("Scan Done, %d Networks Found\r\n", cNetworks);
            state = PRINTAPINFO;
            iNetwork = 0;
         } else if (IsIPStatusAnError(status)) {
            xil_printf("Scan Failed\r\n\n");
            state = ERROR;
         }
         break;

      case PRINTAPINFO:
         if (iNetwork < cNetworks) {
            SCANINFO scanInfo;
            uint32_t j = 0;

            if (deIPcK.getScanInfo(iNetwork, &scanInfo)) {
               xil_printf("\nScan info for index: %d\r\n", iNetwork);

               xil_printf("SSID: %s\r\n", scanInfo.ssid);

               xil_printf("BSSID / MAC: %02X\r\n", scanInfo.bssid);

               xil_printf("Channel: %d\r\n", scanInfo.channel);

               xil_printf("Signal Strength: %d\r\n", scanInfo.rssi);

               if (scanInfo.bssType == DEWF_INFRASTRUCTURE) {
                  xil_printf("Infrastructure Network\r\n");
               } else if (scanInfo.bssType == DEWF_ADHOC) {
                  xil_printf("AdHoc Network\r\n");
               } else {
                  xil_printf("Unknown Network Type\r\n");
               }
               xil_printf("Beacon Period: %d\r\n", scanInfo.beaconPeriod);
               xil_printf("dtimPeriod: %d\r\n", scanInfo.dtimPeriod);
               xil_printf("atimWindow: %d\r\n", scanInfo.atimWindow);
               xil_printf("Security info: WPA2  WPA  Preamble  Privacy  Reserved  Reserved  Reserved  IE\r\n");
               xil_printf(
                  "                %d    %d       %d        %d         %d         %d         %d      %d\r\n",
                  (scanInfo.apConfig & 0b10000000) >> 7,
                  (scanInfo.apConfig & 0b01000000) >> 6,
                  (scanInfo.apConfig & 0b00100000) >> 5,
                  (scanInfo.apConfig & 0b00010000) >> 4,
                  (scanInfo.apConfig & 0b00001000) >> 3,
                  (scanInfo.apConfig & 0b00000100) >> 2,
                  (scanInfo.apConfig & 0b00000010) >> 1,
                  (scanInfo.apConfig & 0b00000001)
               );

               xil_printf("Count of support bit rates: %d\r\n",
                     scanInfo.cBasicRates);

               for (j = 0; j < scanInfo.cBasicRates; j++) {
                  uint32_t rate = (scanInfo.basicRateSet[j] & 0x7F) * 500;
                  xil_printf("\tSupported Rate: %d kbps\r\n", rate);
               }
            } else {
               xil_printf("Unable to get scan info for iNetwork: %d\r\n",
                     iNetwork);
            }
            iNetwork++;
         } else {
            // This is MRF24 specific code
            // This will not run in all implementations
#if defined(MRFVERSION)
            t_deviceInfo dvInfo;
            WF_DeviceInfoGet(&dvInfo);

            xil_printf("\r\nDevice Info\r\n");
            xil_printf(
               "DeviceType: 0x%X Rom Version: 0x%X Patch Version: 0x%X\r\n\n",
               (int) dvInfo.deviceType, (int) dvInfo.romVersion,
               (int) dvInfo.patchVersion
            );
#endif
            state = STOP;
         }
         break;

      case ERROR:
         xil_printf("Status value: %d\r\n", status);
         state = STOP;
         break;

      case STOP:
         xil_printf("End of Demo\r\n");
         state = DONE;
         break;

      case DONE:

      default:
         break;

      }

      DEIPcK::periodicTasks();
   }
}
