/************************************************************************/
/*                                                                      */
/*      WiFiScan                                                        */
/*                                                                      */
/*      Scans the network for all available routers                     */
/*      and prints their parameters to the Serial Monitor               */
/*                                                                      */
/************************************************************************/
/*    Author:     Keith Vogel                                           */
/*    Copyright 2013, Digilent Inc.                                     */
/************************************************************************/
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
/************************************************************************/
/*  Revision History:                                                   */
/*    5/14/2014 (KeithV): Created                                       */
/************************************************************************/
/************************************************************************/
/*                       Supported hardware:                            */
/*                                                                      */
/*  uC32 with a WiFiShield                                              */
/*  WF32                                                                */
/*  WiFIRE                                                              */
/*                                                                      */
/************************************************************************/
/************************************************************************/
/*                                                                      */
/*    Network Hardware libraries                                        */
/*    INCLUDE ONLY ONE                                                  */
/*                                                                      */
/************************************************************************/
// You MUST select 1 and ONLY 1 of the following hardware libraries
// they are here so that MPIDE will put the lib path on the compiler include path.
#include <MRF24G.h>                         // This is for the MRF24WGxx on a pmodWiFi or WiFiShield
//#include <IM8720PHY.h>                      // This is for the the Internal MAC and SMSC 8720 PHY

/************************************************************************/
/*    Network libraries                                                 */
/************************************************************************/
// The base network library
// this is a required library
// Do not comment out this library
#include <DEIPcK.h>

//  -----  COMMENT THIS OUT IF YOU ARE NOT USING WIFI  -----
#include <DEWFcK.h>

//************************************************************************
//************************************************************************
//**************** END OF LIBRARY CONFIGURATION **************************
//************************************************************************
//************************************************************************

#define MRFVERSION

typedef enum
{
    NONE = 0,
    WIFISCAN,
    PRINTAPINFO,
    ERROR,
    STOP,
    DONE
} STATE;

STATE state = WIFISCAN;

IPSTATUS status = ipsSuccess;
int  cNetworks = 0;
int iNetwork = 0;

void setup() {

    Serial.begin(9600);

    Serial.println("Start of Sketch");
    Serial.println("WiFiScan 3.0");
    Serial.println("Digilent, Copyright 2014");
    Serial.println("");

    state = WIFISCAN;          // Scan WiFi First, verify the WiFi connection
    Serial.println("Start WiFi Scan");
    cNetworks = 0;
}

void loop() 
{
    switch(state)
    {
        case WIFISCAN:
            if(deIPcK.wfScan(&cNetworks, &status))
            {
                Serial.print("Scan Done, ");
                Serial.print(cNetworks, DEC);
                Serial.println(" Networks Found");
                state = PRINTAPINFO;
                iNetwork = 0;
            }
            else if(IsIPStatusAnError(status))
            {
                Serial.println("Scan Failed");
                Serial.println("");
                state = ERROR;
            }
            break;

        case PRINTAPINFO:
            if(iNetwork < cNetworks)
            {
                SCANINFO scanInfo;
                uint32_t j = 0;

                if(deIPcK.getScanInfo(iNetwork, &scanInfo))
                {
                    Serial.println("");
                    Serial.print("Scan info for index: ");
                    Serial.println(iNetwork, DEC);

                    Serial.print("SSID: ");
                    for(j=0; j<scanInfo.ssidLen; j++)
                    {
                        Serial.print((char) scanInfo.ssid[j]);
                    }
                    Serial.println();

                    Serial.print("BSSID / MAC: ");
                    for(j=0; j<sizeof(scanInfo.bssid); j++)
                    {
                        if(scanInfo.bssid[j] < 16)
                        {
                            Serial.print(0, HEX);
                        }
                        Serial.print(scanInfo.bssid[j], HEX);
                    }
                    Serial.println("");

                    Serial.print("Channel: ");
                    Serial.println(scanInfo.channel, DEC);

                    Serial.print("Signal Strength: ");
                    Serial.println(scanInfo.rssi, DEC);

                    if(scanInfo.bssType == DEWF_INFRASTRUCTURE)
                    {
                        Serial.println("Infrastructure Network");
                    }
                    else if(scanInfo.bssType == DEWF_ADHOC)
                    {
                        Serial.println("AdHoc Network");
                    }
                    else
                    {
                        Serial.println("Unknown Network Type");
                    }

                    Serial.print("Beacon Period: ");
                    Serial.println(scanInfo.beaconPeriod, DEC);

                    Serial.print("dtimPeriod: ");
                    Serial.println(scanInfo.dtimPeriod, DEC);

                    Serial.print("atimWindow: ");
                    Serial.println(scanInfo.atimWindow, DEC);

                    Serial.println("Secuity info: WPA2  WPA  Preamble  Privacy  Reserved  Reserved  Reserved  IE");
                      Serial.print("                ");
                      Serial.print((scanInfo.apConfig & 0b10000000) >> 7, DEC);
                                       Serial.print("    ");
                                       Serial.print((scanInfo.apConfig & 0b01000000) >> 6, DEC);
                                            Serial.print("       ");
                                            Serial.print((scanInfo.apConfig & 0b00100000) >> 5, DEC);
                                                    Serial.print("        ");
                                                    Serial.print((scanInfo.apConfig & 0b00010000) >> 4, DEC);
                                                             Serial.print("         ");
                                                             Serial.print((scanInfo.apConfig & 0b00001000) >> 3, DEC);
                                                                       Serial.print("         ");
                                                                        Serial.print((scanInfo.apConfig & 0b00000100) >> 2, DEC);
                                                                                 Serial.print("         ");
                                                                                 Serial.print((scanInfo.apConfig & 0b00000010) >> 1, DEC);
                                                                                           Serial.print("      ");
                                                                                           Serial.println((scanInfo.apConfig & 0b00000001), DEC);

                    Serial.print("Count of support bit rates: ");
                    Serial.println(scanInfo.cBasicRates, DEC);    

                    for(j=0; j<scanInfo.cBasicRates; j++)
                    {
                        uint32_t rate = (scanInfo.basicRateSet[j] & 0x7F) * 500;
                        Serial.print("\tSupported Rate: ");
                        Serial.print(rate, DEC);
                        Serial.println(" kbps");
                    }
                }
                else
                {
                    Serial.print("Unable to get scan info for iNetwork: ");
                    Serial.println(iNetwork, DEC);
                }

                iNetwork++;
            }
            else
            {            
// this is MRF24 specific code
// this will not run in all implemenations
#if defined(MRFVERSION)
                t_deviceInfo dvInfo;
                WF_DeviceInfoGet(&dvInfo);

                Serial.println("");
                Serial.println("Device Info");
                Serial.print("DeviceType: 0x");
                Serial.print((int) dvInfo.deviceType, HEX);
                Serial.print(" Rom Version: 0x");
                Serial.print((int) dvInfo.romVersion, HEX);
                Serial.print(" Patch Version: 0x");
                Serial.println((int) dvInfo.patchVersion, HEX);
#endif
                Serial.println("");
                state = STOP;
            }
            break;

        case ERROR:
            Serial.print("Status value: ");
            Serial.println(status, DEC);
            state = STOP;
            break;

        case STOP:
            Serial.println("End of Sketch");
            state = DONE;
            break;

        case DONE:
        default:
            break;

    }

    DEIPcK::periodicTasks();
}


