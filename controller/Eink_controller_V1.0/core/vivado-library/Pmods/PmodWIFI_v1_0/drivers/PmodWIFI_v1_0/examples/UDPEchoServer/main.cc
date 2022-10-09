/******************************************************************************/
/*                                                                            */
/* UDPEchoServer -- A DEWFcK UDP Server application to demonstrate how to use */
/*                  the udpServer Class. This can be used in conjunction with */
/*                  UDPEchoClient.                                            */
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

/************************************************************************/
/*                                                                      */
/*              SET THESE VALUES FOR YOUR NETWORK                       */
/*                                                                      */
/************************************************************************/

// Internet assigned Static IP
IPv4 ipServer = {192,168,1,190}; // {0,0,0,0} for DHCP

unsigned short portServer = 44400;

// Specify the SSID
const char *szSsid = "myRouter";

// Select 1 for the security you want, or none for no security
#define USE_WPA2_PASSPHRASE
//#define USE_WPA2_KEY
//#define USE_WEP40
//#define USE_WEP104
//#define USE_WF_CONFIG_H

// modify the security key to what you have.
#if defined(USE_WPA2_PASSPHRASE)

   const char *szPassPhrase = "myPassword";
   #define WiFiConnectMacro() deIPcK.wfConnect(szSsid, szPassPhrase, &status)

#elif defined(USE_WPA2_KEY)

   WPA2KEY key = { 0x27, 0x2C, 0x89, 0xCC, 0xE9, 0x56, 0x31, 0x1E,
                   0x3B, 0xAD, 0x79, 0xF7, 0x1D, 0xC4, 0xB9, 0x05,
                   0x7A, 0x34, 0x4C, 0x3E, 0xB5, 0xFA, 0x38, 0xC2,
                   0x0F, 0x0A, 0xB0, 0x90, 0xDC, 0x62, 0xAD, 0x58 };
   #define WiFiConnectMacro() deIPcK.wfConnect(szSsid, key, &status)

#elif defined(USE_WEP40)

   const int iWEPKey = 0;
   WEP40KEY keySet = { 0xBE, 0xC9, 0x58, 0x06, 0x97,   // Key 0
                       0x00, 0x00, 0x00, 0x00, 0x00,   // Key 1
                       0x00, 0x00, 0x00, 0x00, 0x00,   // Key 2
                       0x00, 0x00, 0x00, 0x00, 0x00 }; // Key 3
   #define WiFiConnectMacro() deIPcK.wfConnect(szSsid, keySet, iWEPKey, &status)

#elif defined(USE_WEP104)

   const int iWEPKey = 0;
   WEP104KEY keySet = { 0x3E, 0xCD, 0x30, 0xB2, 0x55, 0x2D, 0x3C, 0x50, 0x52, 0x71, 0xE8, 0x83, 0x91,   // Key 0
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // Key 1
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // Key 2
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }; // Key 3
   #define WiFiConnectMacro() deIPcK.wfConnect(szSsid, keySet, iWEPKey, &status)

#elif defined(USE_WF_CONFIG_H)

   #define WiFiConnectMacro() deIPcK.wfConnect(0, &status)

#else // No security - OPEN

   #define WiFiConnectMacro() deIPcK.wfConnect(szSsid, &status)

#endif

//******************************************************************************************
//******************************************************************************************
//***************************** END OF CONFIGURATION ***************************************
//******************************************************************************************
//******************************************************************************************

typedef enum {
   NONE = 0,
   CONNECT,
   LISTEN,
   ISLISTENING,
   AVAILABLECLIENT,
   ACCEPTCLIENT,
   READ,
   WRITE,
   CLOSE,
   EXIT,
   DONE
} STATE;

STATE state = CONNECT;

unsigned tStart = 0;
unsigned tWait = 5000;

// Remember to give the UDP client a datagram cache
#define cUDPSockets 3
static UDPSocket rgUDPClient[cUDPSockets];
static UDPSocket *  pUdpSocket = NULL;
static UDPServer udpServer;

IPSTATUS status;

// A read buffer
byte rgbRead[1024];
int cbRead = 0;
int count = 0;
int i = 0;

void DemoInitialize();
void DemoRun();


int main(void) {
   Xil_ICacheEnable();
   Xil_DCacheEnable();

   xil_printf("WiFiUDPEchoServer 3.0\r\nConnecting to network...\r\n");
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
      case CONNECT:
         if (WiFiConnectMacro()) {
            xil_printf("Connection Created\r\n");
            deIPcK.begin(ipServer);
            state = LISTEN;
         } else if (IsIPStatusAnError(status)) {
            xil_printf("Unable to connection, status: %d\r\n", status);
            state = CLOSE;
         }
         break;

      // Say to listen on the port
      case LISTEN:
         if (deIPcK.udpStartListening(portServer, udpServer, &status)) {
            // Add our sockets
            for (i = 0; i < cUDPSockets; i++) {
               udpServer.addSocket(rgUDPClient[i]);
            }
            xil_printf("Started Listening\r\n");
            state = ISLISTENING;
         } else if (IsIPStatusAnError(status)) {
            xil_printf("Listening Error: 0x%X\r\n", status);
            state = EXIT;
         }
         break;

      // Not specifically needed, we could go right to AVAILABLECLIENT
      // but this is a nice way to print to the serial monitor that we are
      // actively listening.
      // Remember, this can have non-fatal failures, so check the status
      case ISLISTENING:
         if ((i = udpServer.isListening(&status)) > 0) {
            deIPcK.getMyIP(ipServer);
            xil_printf("Server started on %d.%d.%d.%d:%d\r\n", ipServer.u8[0],
                  ipServer.u8[1], ipServer.u8[2], ipServer.u8[3], portServer);
            xil_printf("%d Sockets listening on port: %d\r\n", i, portServer);
            state = AVAILABLECLIENT;
         } else if (IsIPStatusAnError(status)) {
            xil_printf("Lost IP connectivity, error: 0x%X\r\n", status);
            state = EXIT;
         }
         break;

      // Wait for a connection
      case AVAILABLECLIENT:
         if ((count = udpServer.availableClients()) > 0) {
            xil_printf("Got %d clients pending\r\n", count);
            state = ACCEPTCLIENT;
         }
         break;

      // Accept the connection
      case ACCEPTCLIENT:
         // Accept the client
         if ((pUdpSocket = udpServer.acceptClient()) != NULL) {
            xil_printf("Got a Connection\r\n");
            state = READ;
            tStart = (unsigned) SYSGetMilliSecond();
         }

         // This probably won't happen unless the connection is dropped
         // If it is, just release our socket and go back to listening
         else {
            state = CLOSE;
         }
         break;

      // Wait fot the read, but if too much time elapses (5 seconds)
      // we will just close the udpClient and go back to listening
      case READ:
         // See if we got anything to read
         if ((cbRead = pUdpSocket->available()) > 0) {
            cbRead = cbRead < (int) sizeof(rgbRead) ? cbRead : sizeof(rgbRead);
            cbRead = pUdpSocket->readDatagram(rgbRead, cbRead);

            xil_printf("Got %d bytes\r\n", cbRead);

            state = WRITE;
         }

         // If too much time elapsed between reads, close the connection
         else if ((((unsigned) SYSGetMilliSecond()) - tStart) > tWait) {
            state = CLOSE;
         }
         break;

      // Echo back the string
      case WRITE:
         rgbRead[cbRead] = 0;
         xil_printf("Writing datagram:\r\n%s\r\n", rgbRead);

         pUdpSocket->writeDatagram(rgbRead, cbRead);
         state = READ;
         tStart = (unsigned) SYSGetMilliSecond();
         break;

      // Close our udpClient and go back to listening
      case CLOSE:
         if (pUdpSocket != NULL) {
            pUdpSocket->close();
            udpServer.addSocket(*pUdpSocket);
         }
         xil_printf("Closing UdpClient and re-adding it to the server\r\n");
         state = ISLISTENING;
         break;

      // Something bad happen, just exit out of the program
      case EXIT:
         udpServer.close();
         for (i = 0; i < cUDPSockets; i++) {
            rgUDPClient[i].close();
         }
         xil_printf("Something went wrong, sketch is done.\r\n");
         state = DONE;
         break;

      // Do nothing in the loop
      case DONE:

      default:
         break;
      }

      // Every pass through loop(), keep the stack alive
      DEIPcK::periodicTasks();
   }
}
