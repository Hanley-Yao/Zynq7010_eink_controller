/************************************************************************/
/*                                                                      */
/*    WebServer.cpp                                                     */
/*                                                                      */
/*    A chipKIT WiFi HTTP Web Server implementation                     */
/*    This sketch is designed to work with web browsers                 */
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
/*    2/1/2013(KeithV): Created                                         */
/************************************************************************/
#define INCLUDE_SERVER_DATA
#include    "HTTPServer.h"

#define CBDATETIME          32
#define TooMuchTime()       (SYSGetMilliSecond() - tStartTimeOut > cSecTimeout * 1000)
#define RestartTimer()      tStartTimeOut = SYSGetMilliSecond()
#define SetTimeout(cSec)    {cSecTimeout = cSec;}

#define cSecFastRest        10
#define cSecDefault         30
#define cSecInitRest        30
#define cSecIncRest         30
#define cSecMaxRest         600

static uint32_t cSecTimeout = cSecDefault;
static uint32_t tStartTimeOut = 0;
static uint32_t cSecRest = cSecInitRest;

static IPv4         ipMy;
static IPv4         rgTempDNS[8];

typedef enum 
{
    // enumerate these number to make sure we match the host
    // sending these commands
    NONE = 0,
    STARTSTATE,
    WIFISCAN,
    PRINTAPINFO,
    WIFICALPSK,
    WIFICONNECTWITHKEY,
    WIFICONNECT,
    LINKED,
    DYNAMICIPBEGIN,
    STATICIPBEGIN,
    ENDPASS1,
    INITIALIZE,
    WAITFORTIME,
    GETNETADDRESSES,
    PRINTADDRESSES,
    MAKESTATICIP,
    PRINTWIFICONFIG,
    STARTLISTENING,
    LISTENING,
    NOTLISTENING,
    CHECKING,
    RESTARTNOW,
    RESTARTREST,
    TERMINATE,
    SHUTDOWN,
    RESTFORAWHILE,
    TRYAGAIN,
    DONOTHING,
    REBOOT,
    SOFTMCLR,
    MCLRWAIT,
    WAITFORTIMEOUT,
    ERROR    
} STATECMD;

#if defined(USING_WIFI)
WPA2KEY wpa2Key;
STATECMD state = WIFISCAN;              // Scan WiFi First
// STATECMD state = WIFICONNECT;        // No WiFi Scan
#else
static STATECMD state = DYNAMICIPBEGIN;
#endif

// Start with DHCP to get our addresses
// then restart with a static IP
// this is the initial state machine starting point.
STATECMD stateNext = RESTARTREST;
STATECMD stateTimeOut = RESTARTREST;

static IPSTATUS status = ipsSuccess;
unsigned int epochTime = 0;

// scan variables
int  cNetworks = 0;
int iNetwork = 0;

//******************************************************************************************
//******************************************************************************************
//*****************************  Supported TcpClients  *************************************
//******************************************************************************************
//******************************************************************************************

// and our server instance
static uint32_t iNextClientToProcess = 0;
static uint32_t cWorkingClients = 0;
static TCPServer tcpServer;
static TCPSocket rgTCPClient[cMaxSocketsToListen];
static CLIENTINFO rgClient[cMaxSocketsToListen];
static char szTemp[256];            // needs to be long enough to take a WiFi Security key printed out.

/***    void ServerSetup()
 *
 *    Parameters:
 *          None
 *              
 *    Return Values:
 *          None
 *
 *    Description: 
 *    
 *      Initialized the Web Server Network parameters
 *      
 *      
 * ------------------------------------------------------------ */
void ServerSetup(void) 
{
    uint32_t i = 0;

    // Set the LED off, for not initialized
    //pinMode(PIN_LED_SAFE, OUTPUT);
    SetLED(SLED::NOTREADY);     

#if defined(USING_WIFI)
    state = WIFISCAN;          // Scan WiFi First, verify the WiFi connection
    xil_printf("Start WiFi Scan\r\n");
    RestartTimer();
    cNetworks = 0;
#else
    state = DYNAMICIPBEGIN;         // just start with the wired network
#endif

    SetTimeout(cSecDefault);
    stateNext = RESTARTREST;
    stateTimeOut = RESTARTREST;
    RestartTimer();

    cSecRest = cSecInitRest;

    // make sure no clients appear to be in use
    for(i=0; i<cMaxSocketsToListen; i++)
    {
        rgClient[i].pTCPClient = NULL;
        rgTCPClient[i].close();
    }
    cWorkingClients = 0;

    // initialize our temp DNS array
    // initialize them all to the Google NS
    // that way there is something in all of the slots
    // this will get over written if DHCP is used.
    for(i=0; i<sizeof(rgTempDNS)/sizeof(IPv4); i++)
    {
        if((i % 2) == 0)
        {
            rgTempDNS[i].u32 = 0x04040808; // Google public DNS server
        }
        else
        {
            rgTempDNS[i].u32 = 0x08080808; // Google public DNS server
        }
    }

    // now put in the ones that were requested
    memcpy(rgTempDNS, rgIpDNS, min(sizeof(rgTempDNS), sizeof(rgIpDNS)));

    if(sizeof(rgIpDNS) < sizeof(rgTempDNS))
    {
        rgTempDNS[sizeof(rgIpDNS)/sizeof(IPv4)] = ipGateway;
    }
 }

/***    void ProcessServer()
 *
 *    Parameters:
 *          None
 *              
 *    Return Values:
 *          None
 *
 *    Description: 
 *    
 *      This is the main server loop. It:
 *          1. Scans for WiFi connections
 *          2. Connects to a WiFi by SSID
 *          3. Optionally creates a server IP on the detected subnet and dynamically assigns DNS and subnets.
 *          4. Or uses the static IP you assign; then you must supply DNS and subnet
 *          5. Starts listening on the supplied server port.
 *          6. Accepts client connections
 *          7. Schedules the processing on client connections in a round robin yet fashion (cooperative execution).
 *          8. Automatically restart if the network goes down
 *      
 *      This illistrates how to write a state machine like loop
 *      so that the PeriodicTask is called everytime through the loop
 *      so the stack stay alive and responsive.
 *
 *      In the loop we listen for a request, verify it to a limited degree
 *      and then broadcast the Magic Packet to wake the request machine.
 *      
 * ------------------------------------------------------------ */
void ProcessServer(void)
{   
    uint32_t i               = 0;

  // see if we exceeded our timeout value.
  // then just be done and close the socket 
  // by default, a closed client is never connected
  // so it is safe to call isConnected() even if it is closed 
  if(stateTimeOut != NONE && TooMuchTime())
  {
	  xil_printf("Timeout occured\r\n");
    state = stateTimeOut;
    stateTimeOut = NONE;
    stateNext = RESTARTREST;
  }

  switch(state)
  {    

#if defined(USING_WIFI)

        case WIFISCAN:
            if(deIPcK.wfScan(&cNetworks, &status))
            {
            	xil_printf("Scan Done, %d Networks Found\r\n", cNetworks);
                state = PRINTAPINFO;
                RestartTimer();
                iNetwork = 0;
            }
            else if(IsIPStatusAnError(status))
            {
            	xil_printf("Scan Failed\r\n\n");
                state = WIFICONNECT;
                RestartTimer();
            }
            break;

        case PRINTAPINFO:
            if(iNetwork < cNetworks)
            {
                SCANINFO scanInfo;
                uint32_t j = 0;

// this is MRF24 specific code
// this will not run in all implemenations
#if MRFVERSION
                {
                    t_deviceInfo dvInfo;
                    WF_DeviceInfoGet(&dvInfo);

                    Serial.println("Device Info");
                    Serial.print("DeviceType: 0x");
                    Serial.print((int) dvInfo.deviceType, HEX);
                    Serial.print(" Rom Version: 0x");
                    Serial.print((int) dvInfo.romVersion, HEX);
                    Serial.print(" Patch Version: 0x");
                    Serial.println((int) dvInfo.patchVersion, HEX);
               }
#endif

                if(deIPcK.getScanInfo(iNetwork, &scanInfo))
                {
                	xil_printf("\r\nScan info for index: %d\r\n", iNetwork);

                	xil_printf("SSID: %s\r\n", scanInfo.ssid);

                    xil_printf("\r\nBSSID / MAC: ");
                    for(j=0; j<sizeof(scanInfo.bssid); j++)
                    {
                        if(scanInfo.bssid[j] < 16)
                        {
                        	xil_printf("0");
                        }
                        xil_printf("%X",scanInfo.bssid[j]);
                    }

                    xil_printf("\r\nChannel: %d\r\nSignal Strength: %d\r\n", scanInfo.channel, scanInfo.rssi);

                    if(scanInfo.bssType == DEWF_INFRASTRUCTURE)
                    {
                    	xil_printf("Infrastructure Network\r\n");
                    }
                    else if(scanInfo.bssType == DEWF_ADHOC)
                    {
                    	xil_printf("AdHoc Network\r\n");
                    }
                    else
                    {
                    	xil_printf("Unknown Network Type\r\n");
                    }

                    xil_printf("Beacon Period: %d\r\ndtimPeriod: %d\r\natimWindow: %d\r\n", scanInfo.beaconPeriod, scanInfo.dtimPeriod, scanInfo.atimWindow);


                    xil_printf("Security info: WPA2  WPA  Preamble  Privacy  Reserved  Reserved  Reserved  IE\r\n");
                    xil_printf("                %d    %d       %d        %d         %d         %d         %d      %d\r\n",(scanInfo.apConfig & 0b10000000) >> 7,(scanInfo.apConfig & 0b01000000) >> 6,(scanInfo.apConfig & 0b00100000) >> 5,(scanInfo.apConfig & 0b00010000) >> 4,(scanInfo.apConfig & 0b00001000) >> 3,(scanInfo.apConfig & 0b00000100) >> 2,(scanInfo.apConfig & 0b00000010) >> 1,(scanInfo.apConfig & 0b00000001));
//                      Serial.print((scanInfo.apConfig & 0b10000000) >> 7, DEC);
//                                       Serial.print("    ");
//                                       Serial.print((scanInfo.apConfig & 0b01000000) >> 6, DEC);
//                                            Serial.print("       ");
//                                            Serial.print((scanInfo.apConfig & 0b00100000) >> 5, DEC);
//                                                    Serial.print("        ");
//                                                    Serial.print((scanInfo.apConfig & 0b00010000) >> 4, DEC);
//                                                             Serial.print("         ");
//                                                             Serial.print((scanInfo.apConfig & 0b00001000) >> 3, DEC);
//                                                                       Serial.print("         ");
//                                                                        Serial.print((scanInfo.apConfig & 0b00000100) >> 2, DEC);
//                                                                                 Serial.print("         ");
//                                                                                 Serial.print((scanInfo.apConfig & 0b00000010) >> 1, DEC);
//                                                                                           Serial.print("      ");
//                                                                                           Serial.println((scanInfo.apConfig & 0b00000001), DEC);

                    xil_printf("Count of support bit rates: %d\r\n", scanInfo.cBasicRates);
                    xil_printf("Supported Rates: ");
                    for( j= 0; j< scanInfo.cBasicRates; j++)
                    {
                        uint32_t rate = (scanInfo.basicRateSet[j] & 0x7F) * 500;
                        xil_printf("\t%d kbps", rate);
                    }
                    xil_printf("\r\n");
                }
                else
                {
                	xil_printf("Unable to get scan info for iNetwork: %d\r\n", iNetwork);
                }

                iNetwork++;
            }
            else
            {
                
            	xil_printf("\n");
            
// not all WiFi adpators support calculating the PSK key for you
// however, if it does then we can caculate it, print it out and then
// then we know what it is and can connect with a key.
#if defined(USE_WPA2_PASSPHRASE) && defined(WPACALPSK)
                state = WIFICALPSK;
                xil_printf("Calculating PSK\r\n");
#else
                state = WIFICONNECT;
                xil_printf("Connecting to WiFi Network\r\n");
                xil_printf("Wait up to 40 seconds to establish the connection\r\n");
#endif

            }
            RestartTimer();
            break;

#if defined(USE_WPA2_PASSPHRASE) && defined(WPACALPSK)
    case WIFICALPSK:
        {
            if(deIPcK.wpaCalPSK(szSsid, szPassPhrase, wpa2Key))
            {

                GetNumb(wpa2Key.rgbKey, sizeof(wpa2Key), ':', szTemp);

                xil_printf("PSK value: %s\r\n", szTemp);
                state = WIFICONNECTWITHKEY;

                RestartTimer();
            }
        }
        break;
#endif

        case WIFICONNECTWITHKEY:

            if(deIPcK.wfConnect(szSsid, wpa2Key, &status))
            {
            	xil_printf("WiFi Connection Established\r\n");
                state = DYNAMICIPBEGIN;
                RestartTimer();
            }
            else if(IsIPStatusAnError(status))
            {
            	xil_printf("Unable to get a WiFi connection with key\r\n");
                state = ERROR;
                RestartTimer();
            }
            break;

        case WIFICONNECT:
     
            if(WiFiConnectMacro())
            {
            	xil_printf("WiFi Connection Created\r\n");
                state = DYNAMICIPBEGIN;
                RestartTimer();
            }
            else if(IsIPStatusAnError(status))
            {
            	xil_printf("Unable to get a WiFi connection\r\n");
                state = ERROR;
                RestartTimer();
            }
            break;

#endif // USING_WIFI

    case DYNAMICIPBEGIN:

        // if I don't have a static IP, then 
        // dynamically connect and calcuate our IP.
        if(ipMyStatic.u32 == 0)
        {
        	xil_printf("Dynamic begin\r\n");

            // ultimately I want to to have a static IP address 
            // but first I want to get my network addresses from DHCP
            // so to start, lets use DHCP
            deIPcK.begin();
            state = LINKED;
        }

        // otherwise go directly to the static begin
        else
        {
            state = STATICIPBEGIN;
        }

        RestartTimer();
        break;

    case STATICIPBEGIN: 
        
    	xil_printf("Static begin\r\n");

        // start again with static IP addresses
        deIPcK.begin(ipMyStatic, ipGateway, subnetMask);

        // assign the DNS servers
        // these were either init in setup, or redone after DCHP
        {
            uint32_t cDNS = min((sizeof(rgTempDNS)/sizeof(IPv4)), deIPcK.getcMaxDNS());

            for(i=0; i < cDNS; i++)
            {
                deIPcK.setDNS(i, rgTempDNS[i]);
            }
        }

        state = LINKED;
        RestartTimer();
        break;

        case LINKED:
            if(deIPcK.isLinked(&status))
            {
            	xil_printf("Is Linked to the physical network\r\nLink status: 0x%X\r\n", status);

                state = INITIALIZE;
                cSecRest = cSecInitRest;
                RestartTimer();
            }
            else if(IsIPStatusAnError(status))
            {
            	xil_printf("WiFi not connected\r\n");
                state = RESTARTREST;
                RestartTimer();
            }
            break;

    case INITIALIZE:

        // wait for initialization of the internet engine to complete
        if(deIPcK.isIPReady(&status))
            {
        	xil_printf("Network Initialized\r\n");
                state = GETNETADDRESSES;
                SetLED(SLED::WORKING);
                RestartTimer();
            }
        else if(IsIPStatusAnError(status))
            {
        	xil_printf("Not Initialized\r\n");
                state = ERROR;
                RestartTimer();
            }
        break;

    case GETNETADDRESSES:
        
        // at this point we know we are initialized and
        // I can get my network address as assigned by DHCP
        // I want to save them so I can restart with them
        // there is no reason for this to fail

        // This is also called during the static IP begin
        // just to get in sync with what the underlying system thinks we have.
        deIPcK.getMyIP(ipMy);
        deIPcK.getGateway(ipGateway);
        deIPcK.getSubnetMask(subnetMask);

        if(ipMyStatic.u32 == 0)
        {
            state = MAKESTATICIP;
        }
        else
        {
            stateTimeOut = PRINTADDRESSES;
            state = WAITFORTIME;
        }

        RestartTimer();
        break;
    
    case MAKESTATICIP:

        // build the requested IP for this subnet
        ipMyStatic = ipGateway;
        ipMyStatic.u8[3] = localStaticIP;

        // make sure what we built is in fact on our subnet
        if(localStaticIP != 0 && (ipMyStatic.u32 & subnetMask.u32) == (ipGateway.u32 & subnetMask.u32))
        {
            // if so, restart the IP stack and
            // use our static IP  
            state = ENDPASS1;
        }

        // if not just use our dynamaically assigned IP
        else
        {
            // otherwise just continue with our DHCP assiged IP
            ipMyStatic = ipMy;
            stateTimeOut = PRINTADDRESSES;
            state = WAITFORTIME;
        }
        RestartTimer();
        break;

    case ENDPASS1:

        SetLED(SLED::NOTREADY);

        {
            uint32_t cDNS = min(deIPcK.getcDhcpNS(), (sizeof(rgTempDNS)/sizeof(IPv4)));

            // save away the DNS servers
            // get the DHCP ones
            for(i=0; i < cDNS; i++)
            {
                deIPcK.getDNS(i, rgTempDNS[i]);
            }

            // get the ones we specified
            for(; i < ((sizeof(rgIpDNS)/sizeof(IPv4)) + cDNS) && i < (sizeof(rgTempDNS)/sizeof(IPv4)); i++)
            {
                rgTempDNS[i] = rgIpDNS[i - cDNS];
            }

            // put in our gateway
            if(i < (sizeof(rgTempDNS)/sizeof(IPv4)))
            {
                    rgTempDNS[i] = ipGateway;
            }
        }

        // this is probably not neccessary but good
        // practice to make sure our instances are closed
        // before shutting down the Internet stack
        for(i=0; i<cMaxSocketsToListen; i++)
        {
            rgTCPClient[i].close();
            rgClient[i].pTCPClient = NULL;
        }
        tcpServer.close();
        
        // terminate our internet engine
        deIPcK.end();

        // if we were asked to shut down the WiFi channel as well, then disconnect
        // we should be careful to do this after DNETcK:end().
#if defined(USING_WIFI) && defined(RECONNECTWIFI)
        // disconnect the WiFi, this will free the connection ID as well.
        DWIFIcK::disconnect(conID);
        state = WIFICONNECTWITHKEY;
#else
        state = STATICIPBEGIN;
#endif 

        stateTimeOut = RESTARTREST;
        RestartTimer();
        break;

    case WAITFORTIME:
#ifndef NOTIME
        epochTime = deIPcK.secondsSinceEpoch(&status);
        if(status == ipsTimeSinceEpoch)
        {
            GetDayAndTime(epochTime, szTemp);
            Serial.println(szTemp);
            state = PRINTADDRESSES;
            RestartTimer();
        }
#else
        state = PRINTADDRESSES;
        RestartTimer();
#endif
        break;

    case PRINTADDRESSES:

    	xil_printf("\r\n");

        {
            IPv4    ip;
            MACADDR mac;

            deIPcK.getMyIP(ip);
            GetIP(ip, szTemp);
            xil_printf("My %s\r\n", szTemp);

            deIPcK.getGateway(ip);
            GetIP(ip, szTemp);
            xil_printf("Gateway %s\r\n", szTemp);

            deIPcK.getSubnetMask(ip);
            GetNumb(ip.u8, 4, '.', szTemp);
            xil_printf("Subnet mask: %s\r\n", szTemp);

            // print out all of the DNS servers
            for(i=0; i<deIPcK.getcMaxDNS(); i++)
            {
                deIPcK.getDNS(i, ip);
                GetIP(ip, szTemp);
                xil_printf("Dns %d: %s\r\n", i, szTemp);
            }

            deIPcK.getMyMac(mac);
            GetMAC(mac, szTemp);
            xil_printf("My %s\r\n\n", szTemp);
        }

        stateTimeOut = RESTARTREST;
        RestartTimer();
        state = STARTLISTENING;
        break;

    case STARTLISTENING:   
        // we know we are initialized, and our broadcast UdpClient is ready
        // we should just be able to start listening on our TcpIP port
        tcpServer.close();
        if(deIPcK.tcpStartListening(listeningPort, tcpServer))
        {
            for(int i = 0; i < cMaxSocketsToListen; i++)
            {
                tcpServer.addSocket(rgTCPClient[i]);
            }
        }
        state = LISTENING;
        RestartTimer();
        break;

    // this will timeout if we don't start listening
    case LISTENING:
        if((i = tcpServer.isListening(&status)) > 0)
        {          
            IPEndPoint  ep;

            tcpServer.getListeningEndPoint(ep);
            GetIP(ep.ip.ipv4, szTemp);

            xil_printf("%d Sockets Listening on %s: %d\r\n", i, szTemp, ep.port);
            state = CHECKING;
            SetLED(SLED::READY);
            stateTimeOut = NONE;
            
            // reset the rest time
            // things are looking good
            cSecRest = cSecInitRest;
        }
        
        // something bad happened
        else if(IsIPStatusAnError(status))
        {
            state = NOTLISTENING;
            RestartTimer();
        }
        break;
 
    case NOTLISTENING:

        // get the listening error and do something about it
        SetLED(SLED::NOTREADY);
        xil_printf("Not Listening\r\n");

        // the assumption is that the IP Stack is okay
        // we will wait at listening until things get going again
        state = LISTENING;
        stateTimeOut = RESTARTREST;

        // see if the IP stack is still running
        if(deIPcK.isIPReady(&status))
        {
            // still not listening, only reason is that we
            // have no sockets available. However, some may have been
            // added but just haven't finished closing yet
            if(tcpServer.isListening() == 0)
            {
            	xil_printf("All sockets in use, waiting for more sockets\r\n");
            }
        }

        // lost the IP Stack, restart
        else if(IsIPStatusAnError(status))
        {
        	xil_printf("Lost IP Stack, error: 0x%X\r\nRestarting IP Stack\r\n", status);
            cSecRest = cSecFastRest;
            state = RESTARTREST;
            RestartTimer();
        }

        // not fatal loss of the IP stack, maybe reconnecting to WiFi
        else
        {
        	xil_printf("Non-fatal loss if IP Stack, status: 0x%X\r\nWaiting reconnect\r\n", status);
        }

        xil_printf("\r\n");
        RestartTimer();
        break;

    case CHECKING:

        // just some debug code to see how sockets reclaim
        {
            static int cSockets = 0;
            int cListening = tcpServer.isListening();

            if(cSockets != cListening)
            {
                cSockets = cListening;
                xil_printf("Listening Sockets = %d\r\n", cListening);
            }
        }

        if(tcpServer.availableClients() > 0)
        {            
            // find an open client
            // process the next client to be processed
            i = iNextClientToProcess;
            do {
                if(rgClient[i].pTCPClient == NULL)
                {
                    // clear the packet
                    memset(&rgClient[i], 0, sizeof(CLIENTINFO));
                    if((rgClient[i].pTCPClient = tcpServer.acceptClient()) != NULL)
                    {                        
                    	xil_printf("Got a client: 0x%X\r\n", &rgClient[i]);
 
                        // set the timer so if something bad happens with the client
                        // we won't hang, also we don't need to check errors on the client
                        // becasue we will just timeout if there is an error
                        RestartTimer();   
                    }
                    else
                    {
                    	xil_printf("Failed to get client\r\n");
                    }
                    break;
                }
                ++i %=  cMaxSocketsToListen;
            } while(i != iNextClientToProcess);
        }
        else if(tcpServer.isListening() == 0)
        {
            state = NOTLISTENING;
        }
        break;
      
    case RESTARTNOW:
        stateTimeOut = NONE;
        stateNext = TRYAGAIN;
        state = SHUTDOWN;
        break;

    case TERMINATE:
        stateTimeOut = NONE;
        stateNext = DONOTHING;
        state = SHUTDOWN;
        break;

    case REBOOT:
        stateTimeOut = NONE;
        stateNext = MCLRWAIT;
        state = SHUTDOWN;
        break;

    case RESTARTREST:
        stateTimeOut = NONE;
        stateNext = RESTFORAWHILE;
        state = SHUTDOWN;
        break;

    case SHUTDOWN:  // nobody should call this but TEMINATE and RESTARTREST
 
        SetLED(SLED::NOTREADY);

        xil_printf("Shutting down\r\n");

        // this is probably not neccessary but good
        // practice to make sure our instances are closed
        // before shutting down the Internet stack
        for(i=0; i<cMaxSocketsToListen; i++)
        {
            rgTCPClient[i].close();
            rgClient[i].pTCPClient = NULL;
        }
        tcpServer.close();
        
        // terminate our internet engine
        deIPcK.end();

#if defined(USING_WIFI)
        // disconnect the WiFi, this will free the connection ID as well.
        deIPcK.wfDisconnect();
#endif

        // make sure we don't hit our timeout code
        stateTimeOut = NONE;
        state = stateNext;
        stateNext = RESTARTREST;
        break;

    case RESTFORAWHILE:
        {
            static bool fFirstEntry = true;
            static bool fPrintCountDown = true;
            static unsigned int tRestingStart = 0;
            uint32_t tCur = SYSGetMilliSecond();

            if(fFirstEntry)
            {
                fFirstEntry = false;
                fPrintCountDown = true;
                xil_printf("Resting for %d seconds\r\n", cSecRest);

                tRestingStart = tCur;
                stateTimeOut = NONE;
            }

            // see if we are done resting
            else if((tCur - tRestingStart) >= (cSecRest * 1000))
            {
                fFirstEntry = true;
                fPrintCountDown = true;

                xil_printf("Done resting\r\n");

                cSecRest += cSecIncRest;
                if(cSecRest > cSecMaxRest) cSecRest = cSecMaxRest;

                SetTimeout(cSecDefault);
                state = TRYAGAIN;
             }

            // see if we should print out a countdown time
            else if(((tCur - tRestingStart) % 10000) == 0)
            {
                if(fPrintCountDown)
                {
                	xil_printf("%d seconds until restart\r\n", cSecRest - ((tCur - tRestingStart)/1000));
                    fPrintCountDown = false;
                }
            }

            // so we will print the countdown at the next interval
            else
            {
                fPrintCountDown = true;
            }
        }
        break;

    case TRYAGAIN:
        stateNext = RESTARTREST;
        stateTimeOut = RESTARTREST;
#if defined(USING_WIFI)
#if defined(USE_WPA2_PASSPHRASE) && defined(WPACALPSK)
        state = WIFICONNECTWITHKEY;
#else
        state = WIFICONNECT;
#endif
#else
        state = STATICIPBEGIN;
#endif 
        RestartTimer();
        break;

    case DONOTHING:
        stateTimeOut = NONE;
        stateNext = DONOTHING;
        break;

    case WAITFORTIMEOUT:
        break;

    case MCLRWAIT:
        stateTimeOut = SOFTMCLR;
        state = WAITFORTIMEOUT;
        SetTimeout(1);
        RestartTimer();
        break;

    case SOFTMCLR:
        //executeSoftReset(RUN_SKETCH_ON_BOOT);
        stateTimeOut = NONE;
        stateNext = DONOTHING;
        break;

    case ERROR:
    default:
        SetLED(SLED::NOTREADY);
        xil_printf("Hard Error status 0x%X occurred.\r\n", status);
        stateTimeOut = NONE;
        state = RESTARTREST;
        break;
    }
  
    // process only 1 of the clients in a round robin fashion.
    cWorkingClients = 0;
    i = iNextClientToProcess;
    do {
        if(rgClient[i].pTCPClient != NULL)
        {
            cWorkingClients++;
            SetLED(SLED::WORKING);
            switch(ProcessClient(&rgClient[i]))
            {
                case GCMD::RESTART:
                    state = RESTARTNOW;
                    break;

                case GCMD::TERMINATE:
                    state = TERMINATE;
                    break;

                case GCMD::REBOOT:
                    state = REBOOT;
                    break;

                // done with this socket
                case GCMD::ADDSOCKET:
                    tcpServer.addSocket(*(rgClient[i].pTCPClient));
                    rgClient[i].pTCPClient = NULL;
                    break;

                case GCMD::CONTINUE:
                case GCMD::READ:
                case GCMD::WRITE:  
                case GCMD::DONE:  
                default:
                    break;
            }
            iNextClientToProcess = (i + 1) % cMaxSocketsToListen;
            break;
        }
        ++i %=  cMaxSocketsToListen;
    } while(i != iNextClientToProcess);

    // select our LED state for the next pass
    if(cWorkingClients > 0)
    {
        SetLED(SLED::WORKING);
    }
    else if(tcpServer.isListening() > 0)
    {
        // if we are in the checking state
        // and the count went to zero
        // go back to the listening state to print we are listening
        if(state == CHECKING && GetLEDState() == SLED::WORKING)
        {
            state = LISTENING;
        }
        SetLED(SLED::READY);
    }
    else
    {
        SetLED(SLED::NOTREADY);
    }

    // Keep the Ethernet stack alive
    DEIPcK::periodicTasks();
    SetLED(SLED::PROCESS);
}

