/************************************************************************/
/*                                                                      */
/*  DEIPcK.cpp  The deIPcK base C++ wrapper class over the              */
/*              Digilent Embedded IP Stack (deIP) initially designed    */
/*              to support the chipKIT / MPIDE programming environment, */
/*              but can be used in any C++ environment                  */
/*                                                                      */
/************************************************************************/
/*  Author:     Keith Vogel                                             */
/*  Copyright 2013, Digilent Inc.                                       */
/************************************************************************/
/* DEIPcK deIP core network library
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
/*  Module Description:                                                 */
/*                                                                      */
/*      The base deIPcK C++ class wrapper for deIP                      */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*      11/20/2013(KeithV): Created                                     */
/*                                                                      */
/************************************************************************/
#include <DEIPcK.h>

DEIPcK::DEIPcK()
{
    _fBegun             = false;
    _pNwAdp             = NULL;
    _pLLAdp             = NULL;
}

bool DEIPcK::deIPInit(void)
{
     
    // if an adaptor has not been set, load the default one
    // as supplied by NetworkProfile.x
    // We only support 1 adaptor today in MPIDE, this can be changed.
    if(_pLLAdp == NULL)
    {
        //TODO: really think about this; won't this init ALL adaptors and kill other adaptors being used??
        // where should this be called? When we support multiple adaptors we need to move this to the constructor
        // but be careful that the constructors run in an appropriate order.
        IPSInit(NULL, 0, 0);
       
        if(_pNwAdp == NULL)
        {
            _pNwAdp = deIPGetAdaptor();
        }
        
        // add the adaptor to the link layer for processing.
        // again we only support 1 adaptor at this time
        _pLLAdp = LLAddAdaptor(_pNwAdp, rgbLLARPMem, cbARPMem, NULL);
    }

    return(_pLLAdp != NULL);
}

// Very important distinction; Linked means connected to the network
// it does NOT mean you have an IP address
// in the case of WiFi, to be linked you must have
// established an 802.11 connection because that means
// you are ON the network. Just initializing a WiFi module
// does NOT mean you are linked. You MUST be connected to the
// AP to be linked, you must be ON the network.
bool DEIPcK::isLinked(IPSTATUS * pStatus)
{
    return(_pLLAdp != NULL && LLIsLinked(_pLLAdp, pStatus));
}

/***	bool DEIPcK::begin(void)
**      bool DEIPcK::begin(const IPv4& ip)
**      bool DEIPcK::begin(const IPv4& ip, const IPv4& ipGateway)
**      bool DEIPcK::begin(const IPv4& ip, const IPv4& ipGateway, const IPv4& subnetMask)
**
**	Synopsis:   
**      This initializes the Ethernet hardware and the IP Stack
**      For both UDP and TCP. This will return immediately after 
**      hardware initialization and isInitialized should be called
**      if it is important to know that the stack is up and running.
**      usually it is not needed to explicity call isInitialized as most
**      other calls will just fail if IP is not initialized. The most common
**      time consuming feature is obtaining your network information from DHCP
**      and this could take several seconds to complete. DNS will not work
**      until DHCP has completed.
**
**	Parameters:
**      mac         The hardware address to use. If not specified or 6 zero's the chipKIT assigned MAC is used.
**      ip          The static IP address to use, if not specifed or all zero's, DHCP is used to get your IP address.
**      ipGateway   The ip address of the gateway to use. If not specifed ip[0]:ip[1]:0.1 is used. This is ignored if DHCP is used. 
**      subnetMask  The subnet mask of the local network, if not specified 255.255.255.0 is used. This is ignored if DHCP is used. 
**      ipDns1      1 of 2 DNS servers to specify, if not specifed ipGateway is used. This is ignored if DHCP is used.
**      ipDns2      The 2nd of 2 DNS servers to specify, if not specified 0.0.0.0 is used. This is ignored if DHCP is used;
**  
**	Return Values:
**      None
**
**	Errors:
**      None
**
**  Notes:
**
**      If Begin has already be called, then this returns immediately ignoring all inputs.
**      If End is called, then call Begin will set new IP parameters and re-initialize the IP stack.
*/
bool DEIPcK::begin()
{
    return(begin(IPv4NONE));
}
bool DEIPcK::begin(const IPv4& ip)
{
    IPv4 ipGateway = ip;
    ipGateway.u8[3] = 1;
    return(begin(ip, ipGateway));
}
bool DEIPcK::begin(const IPv4& ip, const IPv4& ipGateway)
{
    return(begin(ip, ipGateway, (IPv4) {255,255,255,0}));
}
bool DEIPcK::begin(const IPv4& ip, const IPv4& ipGateway, const IPv4& subnetMask)
{
    IPSTATUS status = ipsSuccess;

    // this is low level stuff that only gets done once.
    if(_fBegun || !deIPInit())
    {
        return(false);
    }

    _fBegun = true;

    // Initialize core stack layers (MAC, ARP, TCP, UDP) and
    // application modules (HTTP, SNMP, etc.)

    DNSInit(_pLLAdp, rgbDNSMem, cbDNSMem, hDhcpDnsNtpPMGR, &status);

    // if we are not to use DHCP; fill in what came in.
    if((ip.u8[0] | ip.u8[1] | ip.u8[2] | ip.u8[3]) != 0)
    {
        ILSetMyIP(_pLLAdp, ip.u8);
        ILSetMyGateway(_pLLAdp, ipGateway.u8);
        ILSetMySubmask(_pLLAdp, subnetMask.u8);
    }
    else
    {
        // we want start use DHCP
        DHCPInit(_pLLAdp, rgbDHCPMem, DHCPMemSize, hDhcpDnsNtpPMGR, &status);
   }

// move this to the secondsSinceEpoch because this will really hose up DNS lookup if time servers can't be obtained
//    SNTPv4Init(_pLLAdp, rgbSNTPv4Mem, SNTPv4MemSize, hDhcpDnsNtpPMGR, NULL, 0, &status);

    return(true);
}

/***	void DEIPcK::end(void)
**
**	Synopsis:   
**      Stops and releases the IP Stack and disables the Ethernet hardware.
**
**	Parameters:
**      None
**
**	Return Values:
**      None
**
**	Errors:
**      None
**
**  Notes:
**
**      This disables the Ethernet hardware. Begin can be called to re-initialize the hardware
**      and set new IP parameters.
*/
bool DEIPcK::end(void)
{
    if(_fBegun == false)
    {
        return(true);
    }
    else
    {
        bool fEnded = SNTPv4Terminate(_pLLAdp) && DNSTerminate(_pLLAdp) && DHCPTerminate(_pLLAdp);

        if(fEnded)
        {
            abortTCPServers();
            abortUDPServers();
            TCPAbortAllSockets();
            UDPCloseAllSockets();

            LLRemoveAdaptor(_pLLAdp);
            
            // everything is based on if the LinkLayer adaptor is there
            _pLLAdp = NULL;
            
            // do not do this because after and end
            // we need to still talk to the hardware for disconnects 
            // and ip address and stuff like that.
//            _pNwAdp = NULL;

            _fBegun = false;

            return(true);
        }
    }
    return(false);
}

void DEIPcK::abortTCPServers(void)
{
    FFLL *      pffllServer = NULL;

    // look at all of the server objects
    while((pffllServer = (FFLL *) FFNext(&TCPServer::_ffptPeriodTask, NULL)) != NULL)
    {
        TCPServer&  tcpServer = *((TCPServer *) (pffllServer->_this));      // for syntax sake
        
        tcpServer.close();
    }
}

void DEIPcK::abortUDPServers(void)
{
    FFLL *      pffllServer = NULL;

    // look at all of the server objects
    while((pffllServer = (FFLL *) FFNext(&UDPServer::_ffptPeriodTask, NULL)) != NULL)
    {
        UDPServer&  udpServer = *((UDPServer *) (pffllServer->_this));      // for syntax sake
        
        udpServer.close();
    }
}



/***	bool DEIPcK::isInitialized(void)
**      bool DEIPcK::isInitialized(DEIPcK::STATUS * pStatus)
**      bool DEIPcK::isInitialized(unsigned long msBlockMax)
**      bool DEIPcK::isInitialized(unsigned long msBlockMax, DEIPcK::STATUS * pStatus)
**
**	Synopsis:   
**      Indicates if the Ethernet hardware and IP stack are initialized.
**
**	Parameters:
**      pStatus     returns initialization progress status.
**      msBlockMax  Will cause isInitialized to block waiting for either successful initalization or 
**                      for the time to elapse. If not specified DEIPcK::_msDefaultTimeout is used.
**                      if you want to return immediately than DEIPcK::msImmediate should be specified.
**
**	Return Values:
**      TRUE    if the stack is initialized
**      FALSE   if the stack is still initializing.
**
**	Errors:
**      None
**
**  Notes:
**
**      In general, this will return false until DHCP has finished supplying 
**      the network information. If DHCP, this will return true pretty much immediately.
*/
bool DEIPcK::isIPReady(IPSTATUS * pStatus)
{
    return(_pLLAdp != NULL && ILIsIPNetworkReady(_pLLAdp, pStatus));
}
 
/***	unsigned long DEIPcK::secondsSinceEpoch(void)
**      unsigned long DEIPcK::secondsSinceEpoch(DEIPcK::STATUS * pStatus)
**
**	Synopsis:   
**
**      Returns the number of seconds since Epoch (Jan 1, 1970).
**
*
**	Parameters:
**      pStatus     A pointer to receive the status of the clock. If the clock is
**                  not initialized or DNS is not available the time returned is
**                  seconds since powerup (ipsTimeSincePowerUp), and not epoch time (ipsTimeSinceEpoch).
**              
**
**	Return Values:
**      The number since Jan 1 1970; or epoch
**
**	Errors:
**      Returns seconds since powerup if epoch time could not be obtained.
**          
*/
unsigned long DEIPcK::secondsSinceEpoch(IPSTATUS * pStatus)
{
    unsigned long   secEpoch = SNTPv4GetUNIXEpochTime(_pLLAdp);
    bool            fInit = secEpoch != 0;

    // dynamically initialize the timer service
    // don't run the time service if it is never needed
    if(_pLLAdp != NULL && _pLLAdp->pNTPMem == NULL)
    {
        SNTPv4Init(_pLLAdp, rgbSNTPv4Mem, SNTPv4MemSize, hDhcpDnsNtpPMGR, NULL, 0, NULL);
    }

    if(!fInit)
    {
        secEpoch = SYSGetSecond();
    }

    if(pStatus != NULL)
    {
        if(fInit)
        {
            *pStatus = ipsTimeSinceEpoch;
        }
        else
        {
            *pStatus = ipsTimeSincePowerUp;
        }
    }
    return(secEpoch);
}

/***	bool DEIPcK::getMyMac(MACADDR *pMAC)
**
**	Synopsis:   
**      Returns the currently active MAC address being used
**
**	Parameters:
**      pMAC    A pointer to a MAC variable to receive the MAC address
**
**	Return Values:
**      true    if the MAC address is valid
**      false   if the MAC address has not be set yet
**
**	Errors:
**      If returns false, the MAC address is not valid
**
**  Notes:
**
**      This value will not be accurate if the MAC/PHY, WiFi Module is not initialized
**      
*/
bool DEIPcK::getMyMac(MACADDR& mac)
{
    // get it set up if not already
    if(_pLLAdp != NULL)
    {
        LLGetMyMac(_pLLAdp, &mac);
        return(memcmp(&mac, &MACNONE, sizeof(MACADDR)) != 0);
    }
    return(false);
}

/***	bool DEIPcK::getMyIP(IPv4 *pIP)
**
**	Synopsis:   
**      Returns the currently active IP address being used
**
**	Parameters:
**      pIP    A pointer to an IPv4 variable to receive the IP address
**
**	Return Values:
**      true    if the IP address is valid
**      false   if the IP address has not be set yet
**
**	Errors:
**      If returns false, the IP address is not valid
**
**  Notes:
**
**      This value will not be accruate until the Ethernet and IP Stack is fully initialized 
**      
*/
bool DEIPcK::getMyIP(IPv4& ip)
{
    // get it set up if not already
    if(isIPReady())
    {
        ILGetMyIP(_pLLAdp, &ip);
        return(true);
    }
    return(false);
}

/***	bool DEIPcK::getGateway(IPv4 *pIPGateway)
**
**	Synopsis:   
**      Returns the currently active Gateway address being used
**
**	Parameters:
**      pIP    A pointer to an IPv4 variable to receive the IP address
**
**	Return Values:
**      true    if the IP address is valid
**      false   if the IP address has not be set yet
**
**	Errors:
**      If returns false, the IP address is not valid
**
**  Notes:
**
**      This value will not be accruate until the Ethernet and IP Stack is fully initialized 
**      
*/
bool DEIPcK::getGateway(IPv4& gateway)
{
    // get it set up if not already
    if(isIPReady())
    {
        ILGetMyGateway(_pLLAdp, &gateway);
        return(true);
    }
    return(false);
}

/***	bool DEIPcK::getSubnetMask(IPv4 *pSubnetMask)
**
**	Synopsis:   
**      Returns the currently active subnet Mask being used
**
**	Parameters:
**      pIP    A pointer to an IPv4 variable to receive the subnet mask
**
**	Return Values:
**      true    if the subnet mask is valid
**      false   if the subnet mask has not be set yet
**
**	Errors:
**      If returns false, the subnet mask is not valid
**
**  Notes:
**
**      This value will not be accruate until the Ethernet and IP Stack is fully initialized 
**      
*/
bool DEIPcK::getSubnetMask(IPv4& subnetMask)
{
    // get it set up if not already
    if(isIPReady())
    {
        ILGetMySubmask(_pLLAdp, &subnetMask);
        return(true);
    }
    return(false);
}

/***	bool DEIPcK::getDns(int index, IPv4& ipDNS)
**
**	Synopsis:   
**      Returns the currently active 1st DNS address being used
**
**	Parameters:
**      pIP    A pointer to an IPv4 variable to receive the IP address
**
**	Return Values:
**      true    if the IP address is valid
**      false   if the IP address has not be set yet
**
**	Errors:
**      If returns false, the IP address is not valid
**
**  Notes:
**
**      This value will not be accruate until the Ethernet and IP Stack is fully initialized 
**      
*/
bool DEIPcK::getDNS(int index, IPv4& ipDNS)
{
    // get it set up if not already
    if(_fBegun && ((uint32_t) index) < cDNSMax)
    {
        return(DNSGetNS(_pLLAdp, index, &ipDNS));
    }
    return(false);
}

bool DEIPcK::setDNS(int index, const IPv4& ipDNS)
{
    // get it set up if not already
    if(_fBegun && ((uint32_t) index)  < cDNSMax)
    {
        return(DNSAddNS(_pLLAdp, &ipDNS, index));
    }
    return(false);
}

/***	bool DEIPcK::isARPIpMacResolved(const IPv4& ip, MACADDR& mac)
**      bool DEIPcK::isARPIpMacResolved(const IPv4& ip, MACADDR& mac, unsigned long msBlockMax)
**
**	Synopsis:   
**      Checks to see if anyone responded with a MAC address for the requested IP
**
**	Parameters:
**      ip    The IP address of the MAC requested
**      pMAC    A pointer to a MAC variable to receive the MAC address
**      msBlockMax The maximum number of msec to wait before returning. By default _msDefaultTimeout is used.
**
**	Return Values:
**      true if the MAC address was obtained
**      false if nothing came back yet
**
**	Errors:
**      If the underlying Ethernet hardware is not initialized, this will return false    
**
**  Notes:
**
**      This is a blind request posted on the local area network
**      there is no guarantee that anyone will respond.
**      
*/
bool DEIPcK::resolveIPtoMAC(const IPv4& ip, MACADDR& mac, IPSTATUS * pStatus)
{
    if(isIPReady(pStatus))
    {
        return(LLARPLookup(_pLLAdp, &ip, &mac, ARPSendCount, pStatus));
    }
    return(false);
}

/***	bool DEIPcK::isDNSResolved(const char * szHostName, IPv4 * pIP)
**      bool DEIPcK::isDNSResolved(const char * szHostName, IPv4 * pIP, DEIPcK::STATUS * pStatus)
**      bool DEIPcK::isDNSResolved(const char * szHostName, IPv4 * pIP, unsigned long msBlockMax)
**      bool DEIPcK::isDNSResolved(const char * szHostName, IPv4 * pIP, unsigned long msBlockMax, DEIPcK::STATUS * pStatus)
**
**
**	Synopsis:   
**      Starts, and checs to see if a DNS lookup is finished.
**
**	Parameters:
**      szHostName  A pointer to a zero terminated string containing the hostname to lookup. This string must remain
**                      valid for the duration of the lookup.
**      pIP         A point to receive the resolved IP address representing the hostname.
**      pStatus     A point to receive the current status of the DNS lookup
**      msBlockMax  The maximum amount of time to wait attempting to lookup the DNS hostname before returning.
**                      Returning does not stop the DNS resolution, it only returns from the call. You can
**                      can call IsDNSResolved as many times as you want until the hostname is resolved, or 
**                      until the DNS engine returns an error.
**
**	Return Values:
**      true    if the DNS hostname was resolved to an IP and pIP is valid
**      false   if the DNS resolution is not finished, or an error occured (check pStatus).
**
**	Errors:
**      Check pStatus
**
**  Notes:
**
**      This attempt a DNS name lookup. If there are no DNS ip address specifed, this will fail
**      After a period of time, the underlying DNS will fail and you will get a DNSResolutionFailed
**      resolution failure. Just because msBlockMax has expired, does not mean that the resolution has failed.
**      
*/
bool DEIPcK::resolveDomainName(const char * szDomanName, IPv4& ip, IPSTATUS * pStatus)
{
    // make sure the network is initialized
    if(isIPReady(pStatus))
    {
        return(DNSResolve(_pLLAdp, (const uint8_t *) szDomanName, strlen(szDomanName), &ip, pStatus));
    }

    return(false);
}

/***	void DEIPcK::terminateDNS(void)
**
**	Synopsis:
**      Terminate any currently active DNS lookup.
**
**	Parameters:
**      None
**
**	Return Values:
**      None
**
**	Errors:
**      None
**
**  Notes:
**
**      This is brutal as it will terminate system lookups as well as any
**      you may have started. Only 1 DNS lookup may be in progress at a time
**      so unless you successfully started a DNS, this will blow away someone
**      else's lookup.
**
*/
void DEIPcK::terminateDNS(void)
{
    DNSAbort(_pLLAdp);
}

bool DEIPcK::resolveEndPoint(const char *szRemoteHostName, uint16_t remotePort, IPEndPoint& epRemote, IPSTATUS * pStatus)
{
    IPSTATUS        statusT         = ipsSuccess;

    if(ILIsIPNetworkReady(_pLLAdp, &statusT))
    {
        const uint8_t * pchDomainName   = NULL;
        uint32_t        cchDomainName   = 0;

        // parse domain name out of the URL and get the remote port based on protocol
        pchDomainName = DNSParseURL((const uint8_t *) szRemoteHostName, &cchDomainName, &epRemote.port);

        if(pchDomainName == NULL)
        {
            statusT = ipsDNSInvalidURL;
        }

        // see if we resolved
        else if(DNSResolve(_pLLAdp, pchDomainName, cchDomainName, &epRemote.ip, &statusT))
        {
            // set our port to the one passed in if specified
            if(remotePort != portUnassigned)
            {
                epRemote.port = remotePort;
            }
        }
    }

    AssignStatusSafely(pStatus, statusT);
    return(statusT == ipsSuccess);
}

bool DEIPcK::udpSetEndPoint(const IPv4& remoteIP, uint16_t remotePort, UDPSocket& udpSocket, uint16_t localPort, IPSTATUS * pStatus)
{
    IPSTATUS    status = ipsSuccess;

    // if we don't have a page manager, assign the default one
    if(udpSocket._hPMGR == NULL)
    {
        udpSocket._hPMGR = hNetworkPMGR;
    }

    if(udpSocket._hPMGR == NULL)
    {
        status = ipsNoPMGRGiven;
    }

    // it is a new connection to set up
    else if(udpSocket._pDEIPcK == NULL)
    {
       udpSocket. _classState = ipsNotInitialized;

        // set up the socket
        if(UDPOpenWithSocket(_pLLAdp, &udpSocket._socket, udpSocket._hPMGR, &remoteIP, remotePort, localPort, &status) == &udpSocket._socket)
        {
            udpSocket._pDEIPcK = this;
            udpSocket._epRemote.ip.ipv4 = remoteIP;
            udpSocket._epRemote.port = remotePort;
            udpSocket._localPort = localPort;
            udpSocket._classState = ipsSuccess;
        }
    }

    // see if this is the same socket
    else if(remoteIP.u32 != udpSocket._epRemote.ip.ipv4.u32 || remotePort != udpSocket._epRemote.port)
    {
        status = ipsInUse;
    }

    AssignStatusSafely(pStatus, status);
    return(status == ipsSuccess);
}

/***	bool TCPSocket::connect(const char *szRemoteHostName, unsigned short remotePort)
**      bool TCPSocket::connect(const IPv4& remoteIP, unsigned short remotePort)
**      bool TCPSocket::connect(const IPEndPoint& epRemote)
**      bool TCPSocket::connect(const IPv4& remoteIP, unsigned short remotePort, DEIPcK::STATUS * pStatus)
**      bool TCPSocket::connect(const char *szRemoteHostName, unsigned short remotePort, DEIPcK::STATUS * pStatus)
**      bool TCPSocket::connect(const IPEndPoint& epRemote, DEIPcK::STATUS * pStatus)
**
**
**	Synopsis:
**      Starts the connection process to connect a TCPSocket to a remote host.
**      In itself, this does not "finish" the connection, to determine if the
**      connection has successfully been made, IsConnected should be called.
**
**	Parameters:
**      szRemoteHostName    A pointer to a zero terminated string holding the hostname of the remote endpoint
**                              to connect to. This will call the underlying DNS service to resolve the hostname
**                              to an IPv4 address. If no DNS servers were specified or DHCP was not used to
**                              intialize DEIPcK, then the DNS lookup will fail. The hostname string must be valid
**                              until IsConnected succeeds, or a hard failure status is returned.
**                              IsStatusAnError can be used to identify a hard failure status
**
**      remotePort          The port on the remote machine you want to connect too.
**
**      remoteIP            The IPv4 address of the remote machine you want to connect to. This will
**                          call the underlying APR service to resolve the IP address to a MAC.
**
**      epRemote            A IPEndPoint containing the remote IPv4 address and remote port to connect to. This will
**                          call the underlying APR service to resolve the IP address to a MAC.
**
**      pStatus             A pointer to receive the connect status. This is a status and may not be a failure.
**                          Use IsStatusAnError to determine if this is a hard failure.
**
**
**	Return Values:
**      true                This will return true if a socket was allocated for the connection. It does not mean
**                          the connection was made, call IsConnected to see if the connection process is done.
**
**      false               A socket was not defined, false usually indicates a hard failure.
**
**	Errors:
**      None
**
**  Notes:
**
**      Call IsConnected to determine if the connection has been completed, or was lost.
**
*/
bool DEIPcK::tcpConnect(const char *szRemoteHostName, uint16_t remotePort, TCPSocket& tcpSocket, uint16_t localPort, IPSTATUS * pStatus)
{
    IPSTATUS status = ipsFailed;

    // if we don't have a page manager, assign the default one
    if(tcpSocket._hPMGR == NULL)
    {
        tcpSocket._hPMGR = hNetworkPMGR;
    }

    if(tcpSocket._hPMGR == NULL)
    {
        AssignStatusSafely(pStatus, ipsNoPMGRGiven);
        return(false);
    }
    else if(!ILIsIPNetworkReady(_pLLAdp, pStatus))
    {
        return(false);
    }

    switch(tcpSocket._classState)
    {
        case ipsNotInitialized:
            if(tcpListen <= tcpSocket._socket.tcpState && tcpSocket._socket.tcpState <= tcpEstablished)
            {
                status = ipsInUse;
                break;
            }

            tcpSocket._pDEIPcK = this;
            tcpSocket._localPort = localPort;
            tcpSocket._classState = ipsStartDNSResolving;

            // fall thru

        case ipsStartDNSResolving:

            // not done, get out
            if(!resolveEndPoint(szRemoteHostName, remotePort, tcpSocket._epRemote, &status))
            {
                break;
            }
            tcpSocket._classState = ipsStartEPConnect;

            // fall thru

        case ipsStartEPConnect:
        case ipsInUseW:
            return(tcpConnect(tcpSocket._epRemote, tcpSocket, localPort, pStatus));
            break;

        default:
            status = ispInvalidArgument;
            break;
    }

    AssignStatusSafely(pStatus, status);
    return(false);
}

bool DEIPcK::tcpConnect(const IPv4& remoteIP, uint16_t remotePort, TCPSocket& tcpSocket, uint16_t localPort, IPSTATUS * pStatus)
{
    IPSTATUS status = ipsFailed;

    // if we don't have a page manager, assign the default one
    if(tcpSocket._hPMGR == NULL)
    {
        tcpSocket._hPMGR = hNetworkPMGR;
    }

    if(tcpSocket._hPMGR == NULL)
    {
        AssignStatusSafely(pStatus, ipsNoPMGRGiven);
        return(false);
    }
    else if(!ILIsIPNetworkReady(_pLLAdp, pStatus))
    {
        return(false);
    }

    switch(tcpSocket._classState)
    {
        case ipsNotInitialized:
            if(tcpListen <= tcpSocket._socket.tcpState && tcpSocket._socket.tcpState <= tcpEstablished)
            {
                status = ipsInUse;
                break;
            }

            tcpSocket._pDEIPcK = this;
            tcpSocket._epRemote.ip.ipv4 = remoteIP;
            tcpSocket._epRemote.port = remotePort;
            tcpSocket._localPort = localPort;

            tcpSocket._classState = ipsStartEPConnect;

            // fall thru

        case ipsStartEPConnect:

            // check to see if this is me
            if(remoteIP.u32 != tcpSocket._epRemote.ip.ipv4.u32 || remotePort != tcpSocket._epRemote.port)
            {
                status = ipsInUse;
                break;
            }

            // the socket is just closing, no big deal, just wait for it to close
            else if(tcpSocket._socket.tcpState > tcpEstablished)
            {
                status = ipsInUseW;
                break;
            }

            // not good, someone is using this
            else if(tcpSocket._socket.tcpState >= tcpListen)
            {
                status = ipsInUse;
                break;
            }

            // try to open the socket
            else if(TCPOpenWithSocket(_pLLAdp, &tcpSocket._socket, tcpSocket._hPMGR, &tcpSocket._epRemote.ip, tcpSocket._epRemote.port, localPort, &status) != &tcpSocket._socket)
            {
                // something bad happened
                tcpSocket.close();
                break;
            }

            // we are in use, may not be establised, but just waiting to be established
            tcpSocket._classState = ipsInUseW;

            // fall thru

        case ipsInUseW:
            return(TCPIsEstablished(&tcpSocket._socket, pStatus));
            break;

        default:
            status = ispInvalidArgument;
            break;
    }

    AssignStatusSafely(pStatus, status);
    return(false);
}

bool DEIPcK::tcpStartListening(uint16_t listeningPort, TCPServer& tcpServer, IPSTATUS * pStatus)
{
    if(tcpServer._pDEIPcK != NULL || tcpServer._ffptInfo._pNext != NULL)
    {
        AssignStatusSafely(pStatus, ipsInUse);
        return(false);
    }

    tcpServer._pDEIPcK = this;
    tcpServer._listeningPort = listeningPort;
    FFInPacket(&TCPServer::_ffptPeriodTask, &tcpServer._ffptInfo);
    AssignStatusSafely(pStatus, ipsSuccess);
    return(true);
}

bool DEIPcK::udpStartListening(uint16_t listeningPort, UDPServer& udpServer, IPSTATUS * pStatus)
{
    if(udpServer._pDEIPcK != NULL || udpServer._ffptInfo._pNext != NULL)
    {
        AssignStatusSafely(pStatus, ipsInUse);
        return(false);
    }

    udpServer._pDEIPcK = this;
    udpServer._listeningPort = listeningPort;
    FFInPacket(&UDPServer::_ffptPeriodTask, &udpServer._ffptInfo);
    AssignStatusSafely(pStatus, ipsSuccess);
    return(true);
}

/***	void DEIPcK::periodicTasks(void)
**
**	Synopsis:
**      Executes needed periodic stack tasks. This should be run once thru the loop()
**      code to keep the stack alive.
**
**	Parameters:
**      None
**
**	Return Values:
**      None
**
**	Errors:
**      None
**
**  Notes:
**
**      This is a critical function and should be called often so incoming UDP/TCP
**      messages are not missed.
**
*/
void DEIPcK::periodicTasks(void)
{
    static bool fInPeriodicTasks = false;

    // do not recursively execute this function.
    if(fInPeriodicTasks)
    {
        return;
    }
    fInPeriodicTasks = true;

    UDPServer::periodicTask();
    TCPServer::periodicTask();
    IPSPeriodicTasks();

    fInPeriodicTasks = false;
}





