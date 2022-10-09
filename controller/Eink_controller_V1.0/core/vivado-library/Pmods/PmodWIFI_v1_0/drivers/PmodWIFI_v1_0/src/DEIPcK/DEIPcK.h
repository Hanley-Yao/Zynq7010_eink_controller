/************************************************************************/
/*                                                                      */
/*  DEIPcK.h    The deIPcK C++ wrapper classes over the                 */
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
/*  Primary header file for the deIPcK C++ wrapper classes over deIP    */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*      11/20/2013(KeithV): Created                                     */
/*                                                                      */
/************************************************************************/
#ifndef _DEIPCK_H
#define _DEIPCK_H

#ifdef _DEWFCK_H
#error DEIPcK.h must be included before DEWFcK.h
#endif

#ifdef __cplusplus
#include "WProgram.h"
extern "C" {
    #include "utility/deIP.h"
}
#include <NetworkProfile.x>

// Unique IP STATUS codes for deIPcK and deWFcK
#define ipsNetworkNotInitialized    ForceIPError(MakeDEIPcKStatus(10))
#define ipsNetworkInitialized       MakeDEIPcKStatus(11)
#define ipsInvalidOperation         ForceIPError(MakeDEIPcKStatus(12))
#define ipsTimeSincePowerUp         MakeDEIPcKStatus(20)
#define ipsTimeSinceEpoch           MakeDEIPcKStatus(21)
#define ipsNotConnected             ForceIPError(IPStatusFromTCPState(tcpClosed))
#define ipsStartEPConnect           MakeDEIPcKStatus(30)
#define ipsStartDNSResolving        MakeDEIPcKStatus(31)
#define ipsStartConnect             MakeDEIPcKStatus(32)
#define ipsWaitingConnect           MakeDEIPcKStatus(33)
#define ipsWaitingReConnect         MakeDEIPcKStatus(34)
#define ipsLostConnect              ForceIPError(MakeDEIPcKStatus(50))
#define ipsConnectionAlreadyDefined ForceIPError(MakeDEIPcKStatus(51))
#define ipsSocketError              ForceIPError(MakeDEIPcKStatus(52))
#define ipsNeedToCallStartListening ForceIPError(MakeDEIPcKStatus(80))
#define ipsNeedToResumeListening    ForceIPError(MakeDEIPcKStatus(81))
#define ipsAlreadyStarted           ForceIPError(MakeDEIPcKStatus(82))
#define ipsAlreadyListening         ForceIPError(MakeDEIPcKStatus(83))
#define ipsListening                MakeDEIPcKStatus(84)
#define ipsNoPendingClients         MakeDEIPcKStatus(89)
#define ipsIndexOutOfBounds         ForceIPError(MakeDEIPcKStatus(90))
#define ipsAcquiringSocket          MakeDEIPcKStatus(111)
#define ipsFinalizing               MakeDEIPcKStatus(112)

#define ipsScanning                 MakeDEIPcKStatus(200)

typedef struct FFLL_T
{
    void *     _pNext;     // used as part of the link list when added to the server class
    void *     _this;      // A pointer to myself, so I know who I am when I come off the list
} FFLL;

class TCPSocket {
private:

    FFLL _ffptInfo;

    // this is used in the connect state machine, it is not an error state.
    IPSTATUS        _classState;
    HPMGR           _hPMGR;
    TCPSOCKET       _socket;
    class DEIPcK *  _pDEIPcK;

    uint16_t        _localPort;
    IPEndPoint      _epRemote;

    TCPSocket(TCPSocket& tcpSocket);
    TCPSocket&  operator=(TCPSocket& tcpSocket) {return(tcpSocket);}

    // private methods
    void clear(bool fConstruct);

public:
    TCPSocket();
    ~TCPSocket();

    bool setSocketMem(HPMGR hPMGR);
    void close(void);

    // call this to see if you can write
    bool isEstablished(IPSTATUS * pStatus)
    {
        return(TCPIsEstablished(&_socket, pStatus));
    }
    bool isEstablished(void)
    {
        return(isEstablished(NULL));
    }

    // call this if you can read
    // you will be connected as you shut down the connection
    // so you may have stuff to read
    bool isConnected(IPSTATUS * pStatus)
    {
        return(TCPIsConnected(&_socket, pStatus));
    }
    bool isConnected(void)
    {
        return(isConnected(NULL));
    }

    void discardReadBuffer(void);
    size_t available(void);

    int peekByte(void);
    int peekByte(size_t index);

    size_t peekStream(byte *rgbPeek, size_t cbPeekMax);
    size_t peekStream(byte *rgbPeek, size_t cbPeekMax, size_t index);
 
    int readByte(void);
    size_t readStream(byte *rgbRead, size_t cbReadMax);
 
    int writeByte(byte bData);                      
    int writeByte(byte bData, IPSTATUS * pStatus);

    size_t writeStream(const byte *rgbWrite, size_t cbWrite);                            
    size_t writeStream(const byte *rgbWrite, size_t cbWrite, IPSTATUS * pStatus);

    void flush(void) {TCPFlush(&_socket);}
 
    bool getRemoteEndPoint(IPEndPoint& epRemote);
    bool getLocalEndPoint(IPEndPoint& epLocal);
    bool getRemoteMAC(MACADDR& remoteMAC);

    friend class DEIPcK;
    friend class TCPServer;
};

// it is intentional that this does NOT inherit from Print.
class UDPSocket {
private:

    FFLL _ffptInfo;

    // this is used in the connect state machine, it is not an error state.
    IPSTATUS        _classState;
    HPMGR           _hPMGR;
    UDPSOCKET       _socket;
    class DEIPcK *  _pDEIPcK;

    uint16_t        _localPort;
    IPEndPoint      _epRemote;

    // to prevent copies
    UDPSocket&  operator=(UDPSocket& udpSocket) {return(udpSocket);};
    UDPSocket(UDPSocket& udpSocket);

    // private methods
    void clear(bool fConstruct);

public:
    UDPSocket();
    ~UDPSocket();

    bool setSocketMem(HPMGR hPMGR);
    void close(void);

    void discardDatagram(void);

    size_t available(void);

    int peekByte(void);
    int peekByte(size_t index);

    size_t peekDatagram(byte *rgbPeek, size_t cbPeekMax);
    size_t peekDatagram(byte *rgbPeek, size_t cbPeekMax, size_t index);

    size_t readDatagram(byte *rgbRead, size_t cbReadMax);
    long int writeDatagram(const byte *rgbWrite, size_t cbWrite);

    bool getRemoteEndPoint(IPEndPoint& epRemote);
    bool getLocalEndPoint(IPEndPoint& epLocal);
    bool getRemoteMAC(MACADDR& remoteMAC);

    friend class DEIPcK;
    friend class UDPServer;
};

class TCPServer {
private:

    static FFPT     _ffptPeriodTask;        // the list of all servers currentlying listening

    FFLL _ffptInfo;

    // The list of sockets added to this server
    FFPT            _ffptSockets;

    class DEIPcK *  _pDEIPcK;               // which adaptor owns us
    unsigned short  _listeningPort;         // the port we are listening on
     
    // to prevent copies
    TCPServer(TCPServer& tcpServer);
    TCPServer&  operator=(TCPServer& tcpServer) {return(tcpServer);}

    void construct(void);
    void clear(void);

    static void periodicTask(void);

public:
    TCPServer();
    ~TCPServer();

    bool addSocket(TCPSocket& tcpSocket, IPSTATUS * pStatus);
    bool addSocket(TCPSocket& tcpSocket)
    {
        return(addSocket(tcpSocket, NULL));
    }

    void close(void);

    int availableClients(int& cListening, int& cWaiting, IPSTATUS * pStatus);

    int availableClients(void)
    {
        int cListening;
        int cWaiting;
        return(availableClients(cListening, cWaiting, NULL));
    }
    int availableClients(IPSTATUS * pStatus)
    {
        int cListening;
        int cWaiting;
        return(availableClients(cListening, cWaiting, pStatus));
    }
    int availableClients(int& cWaiting)
    {
        int cListening;
        return(availableClients(cListening, cWaiting, NULL));
    }
    int availableClients(int& cWaiting, IPSTATUS * pStatus)
    {
        int cListening;
        return(availableClients(cListening, cWaiting, pStatus));
    }
    int isListening(void)
    {
        int cListening;
        int cWaiting;
        availableClients(cListening, cWaiting, NULL);
        return(cListening);
    }
    int isListening(IPSTATUS * pStatus)
    {
        int cListening;
        int cWaiting;
        availableClients(cListening, cWaiting, pStatus);
        return(cListening);
    }

    // We can get errors, you passed me a NULL, or an opened TCPSocket, or index out of range.
    TCPSocket * acceptClient(int index);
    TCPSocket * acceptClient(void)
    {
        return(acceptClient(0));
    }

    bool getAvailableClientsRemoteEndPoint(IPEndPoint& epRemote, int index);
    bool getAvailableClientsRemoteEndPoint(IPEndPoint& epRemote)
    {
        return(getAvailableClientsRemoteEndPoint(epRemote, 0));
    }

    bool getListeningEndPoint(IPEndPoint& epLocal);

    friend class DEIPcK;
};

class UDPServer {
private:

    static FFPT     _ffptPeriodTask;        // the list of all servers currentlying listening

    FFLL _ffptInfo;

    // The list of sockets added to this server
    FFPT            _ffptSockets;

    class DEIPcK *  _pDEIPcK;               // which adaptor owns us
    unsigned short  _listeningPort;         // the port we are listening on

    // to prevent copies
    UDPServer(UDPServer& udpServer);
    UDPServer&  operator=(UDPServer& udpServer) {return(udpServer);}

    void construct(void);
    void clear(void);

    static void periodicTask(void);

public:
    UDPServer();
    ~UDPServer();

    bool addSocket(UDPSocket& udpSocket, IPSTATUS * pStatus);
    bool addSocket(UDPSocket& udpSocket)
    {
        return(addSocket(udpSocket, NULL));
    }

    void close(void);

    int availableClients(int& cListening, IPSTATUS * pStatus);

    int availableClients(void)
    {
        int cListening;
        return(availableClients(cListening, NULL));
    }
    int availableClients(IPSTATUS * pStatus)
    {
        int cListening;
        return(availableClients(cListening, pStatus));
    }
    int availableClients(int& cListening)
    {
        return(availableClients(cListening, NULL));
    }

    int isListening(void)
    {
        int cListening;
        availableClients(cListening, NULL);
        return(cListening);
    }
    int isListening(IPSTATUS * pStatus)
    {
        int cListening;
        availableClients(cListening, pStatus);
        return(cListening);
    }

    // We can get errors, you passed me a NULL, or an opened UDPSocket, or index out of range.
    UDPSocket * acceptClient(int index);
    UDPSocket * acceptClient(void)
    {
        return(acceptClient(0));
    }

    bool getAvailableClientsRemoteEndPoint(IPEndPoint& epRemote, int index);
    bool getAvailableClientsRemoteEndPoint(IPEndPoint& epRemote)
    {
        return(getAvailableClientsRemoteEndPoint(epRemote, 0));
    }

    bool getListeningEndPoint(IPEndPoint& epLocal);

    friend class DEIPcK;
};

class DEIPcK
{
private:

    // this will init by the compiler by default to zero because it is a static
    // I would initialize except only const can be initialized; and I have no constructor on a static class
    bool            _fBegun;
    const NWADP *   _pNwAdp;
    const LLADP *   _pLLAdp;

    virtual const NWADP * deIPGetAdaptor(void) = 0;

public:

    // Unofficial and --probably-- safe to use for personal use
    // these ports are within the range of the IANA controled ports.
    // But for the most part these have not been registered
    // as of 12/9/2011. Each range is 1000 ports.
    // Use at your own risk as these can be registered at any time.
    // Be aware that there are also many unofficial ports withing the IANA range.
    static const unsigned short iPersonalPorts35 = 35000;
    static const unsigned short iPersonalPorts38 = 38000;
    static const unsigned short iPersonalPorts39 = 39000;
    static const unsigned short iPersonalPorts44 = 44000;
    static const unsigned short iPersonalPorts45 = 45000;
    static const unsigned short iPersonalPorts46 = 46000;

    DEIPcK();
    
    virtual bool deIPInit(void);

    bool begin(void);
    bool begin(const IPv4& ip);
    bool begin(const IPv4& ip, const IPv4& ipGateway);
    bool begin(const IPv4& ip, const IPv4& ipGateway, const IPv4& subnetMask);

    bool end(void);

    bool isLinked(IPSTATUS * pStatus);
    bool isLinked(void)
    {
        return(isLinked(NULL));
    }

    bool isIPReady(IPSTATUS * pStatus);
    bool isIPReady(void)
    {
        return(isIPReady(NULL));
    }

    unsigned long secondsSinceEpoch(IPSTATUS * pStatus);
    unsigned long secondsSinceEpoch(void)
    {
        return(secondsSinceEpoch(NULL));
    }

    bool getMyMac(MACADDR& mac);
    bool getMyIP(IPv4& ip);
    bool getGateway(IPv4& gateway);
    bool getSubnetMask(IPv4& subnetMask);
    bool getDNS(int index, IPv4& ipDNS);
    bool setDNS(int index, const IPv4& ipDNS);
    unsigned long getcDhcpNS(void)
    {
            return(DNScNS(_pLLAdp));
    }

    unsigned long getcMaxDNS(void)
    {
            return(DNScMaxNS(_pLLAdp));
    }

    bool resolveIPtoMAC(const IPv4& ip, MACADDR& mac, IPSTATUS * pStatus);
    bool resolveIPtoMAC(const IPv4& ip, MACADDR& mac)
    {
        return(resolveIPtoMAC(ip, mac, NULL));
    }

    bool resolveDomainName(const char * szDomanName, IPv4& ip, IPSTATUS * pStatus);
    bool resolveDomainName(const char * szDomanName, IPv4& ip)
    {
        return(resolveDomainName(szDomanName, ip, NULL));
    }
    void terminateDNS(void);

    bool resolveEndPoint(const char *szRemoteHostName, uint16_t remotePort, IPEndPoint& epRemote, IPSTATUS * pStatus);
    bool resolveEndPoint(const char *szRemoteHostName, uint16_t remotePort, IPEndPoint& epRemote)
    {
        return(resolveEndPoint(szRemoteHostName, remotePort, epRemote, NULL));
    }
    void terminateResolveEndPoint(void)
    {
        terminateDNS();
    }

    bool udpSetEndPoint(const IPv4& remoteIP, uint16_t remotePort, UDPSocket& udpSocket, uint16_t localPort, IPSTATUS * pStatus);
    bool udpSetEndPoint(const IPv4& remoteIP, uint16_t remotePort, UDPSocket& udpSocket, uint16_t localPort)
    {
        return(udpSetEndPoint(remoteIP, remotePort, udpSocket, localPort, NULL));
    }
    bool udpSetEndPoint(IPEndPoint& epRemote, UDPSocket& udpSocket, uint16_t localPort, IPSTATUS * pStatus)
    {
        return(udpSetEndPoint(epRemote.ip.ipv4, epRemote.port, udpSocket, localPort, pStatus));
    }
    bool udpSetEndPoint(IPEndPoint& epRemote, UDPSocket& udpSocket, uint16_t localPort)
    {
        return(udpSetEndPoint(epRemote.ip.ipv4, epRemote.port, udpSocket, localPort, NULL));
    }

    bool tcpConnect(const char *szRemoteHostName, uint16_t remotePort, TCPSocket& tcpSocket, uint16_t localPort, IPSTATUS * pStatus);

    bool tcpConnect(const char *szRemoteHostName, TCPSocket& tcpSocket)
    {
        return(tcpConnect(szRemoteHostName, portUnassigned, tcpSocket, portDynamicallyAssign, NULL));
    }
    bool tcpConnect(const char *szRemoteHostName, TCPSocket& tcpSocket, IPSTATUS * pStatus)
    {
        return(tcpConnect(szRemoteHostName, portUnassigned, tcpSocket, portDynamicallyAssign, pStatus));
    }

    bool tcpConnect(const char *szRemoteHostName, TCPSocket& tcpSocket, uint16_t localPort)
    {
        return(tcpConnect(szRemoteHostName, portUnassigned, tcpSocket, localPort, NULL));
    }
    bool tcpConnect(const char *szRemoteHostName, TCPSocket& tcpSocket, uint16_t localPort, IPSTATUS * pStatus)
    {
        return(tcpConnect(szRemoteHostName, portUnassigned, tcpSocket, localPort, pStatus));
    }

    bool tcpConnect(const char *szRemoteHostName, uint16_t remotePort, TCPSocket& tcpSocket)
    {
        return(tcpConnect(szRemoteHostName, remotePort, tcpSocket, portDynamicallyAssign, NULL));
    }
    bool tcpConnect(const char *szRemoteHostName, uint16_t remotePort, TCPSocket& tcpSocket, IPSTATUS * pStatus)
    {
        return(tcpConnect(szRemoteHostName, remotePort, tcpSocket, portDynamicallyAssign, pStatus));
    }

    bool tcpConnect(const char *szRemoteHostName, uint16_t remotePort, TCPSocket& tcpSocket, uint16_t localPort)
    {
        return(tcpConnect(szRemoteHostName, remotePort, tcpSocket, localPort, NULL));
    }

    bool tcpConnect(const IPv4& remoteIP, uint16_t remotePort, TCPSocket& tcpSocket, uint16_t localPort, IPSTATUS * pStatus);

    bool tcpConnect(const IPv4& remoteIP, uint16_t remotePort, TCPSocket& tcpSocket)
    {
        return(tcpConnect(remoteIP, remotePort, tcpSocket, portDynamicallyAssign, NULL));
    }
    bool tcpConnect(const IPv4& remoteIP, uint16_t remotePort, TCPSocket& tcpSocket, IPSTATUS * pStatus)
    {
        return(tcpConnect(remoteIP, remotePort, tcpSocket, portDynamicallyAssign, pStatus));
    }

    bool tcpConnect(const IPv4& remoteIP, uint16_t remotePort, TCPSocket& tcpSocket, uint16_t localPort)
    {
        return(tcpConnect(remoteIP, remotePort, tcpSocket, localPort, NULL));
    }

    bool tcpConnect(const IPEndPoint& epRemote, TCPSocket& tcpSocket)
    {
        return(tcpConnect(epRemote.ip.ipv4, epRemote.port, tcpSocket, portDynamicallyAssign, NULL));
    }
    bool tcpConnect(const IPEndPoint& epRemote, TCPSocket& tcpSocket, IPSTATUS * pStatus)
    {
        return(tcpConnect(epRemote.ip.ipv4, epRemote.port, tcpSocket, portDynamicallyAssign, pStatus));
    }

    bool tcpConnect(const IPEndPoint& epRemote, TCPSocket& tcpSocket, uint16_t localPort)
    {
        return(tcpConnect(epRemote.ip.ipv4, epRemote.port, tcpSocket, localPort, NULL));
    }

    bool tcpConnect(const IPEndPoint& epRemote, TCPSocket& tcpSocket, uint16_t localPort, IPSTATUS * pStatus)
    {
        return(tcpConnect(epRemote.ip.ipv4, epRemote.port, tcpSocket, localPort, pStatus));
    }

    bool tcpStartListening(uint16_t listeningPort, TCPServer& tcpServer, IPSTATUS * pStatus);

    bool tcpStartListening(uint16_t listeningPort, TCPServer& tcpServer)
    {
        return(tcpStartListening(listeningPort, tcpServer, NULL));
    }
    void abortTCPServers(void);

    bool udpStartListening(uint16_t listeningPort, UDPServer& udpServer, IPSTATUS * pStatus);

    bool udpStartListening(uint16_t listeningPort, UDPServer& udpServer)
    {
        return(udpStartListening(listeningPort, udpServer, NULL));
    }
    
    void abortUDPServers(void);

    static void periodicTasks(void);

    friend class TCPSocket;
    friend class UDPSocket;
    friend class TCPServer;
    friend class UDPServer;
    friend class DEWFcK;
};


// ****************************************************************************
// ****************************************************************************
// ******** Only include in C++/DEIPcK files, not core C deIP files ***********
// ****************************************************************************
// ****************************************************************************

extern uint8_t  rgbLLARPMem[];              // ARP mem
extern uint32_t cbARPMem;                   // how big the ARP mem is

extern uint8_t  rgbDNSMem[];                // DNS mem
extern uint32_t cbDNSMem;                   // number of bytes of dns memory
extern uint32_t cDNSMax;                    // the max number of DNS servers in the list

extern uint8_t  rgbAdpHeap[];               // ipStack mem
extern uint8_t  rgbDHCPMem[];               // DHCP mem
extern uint8_t  rgbSNTPv4Mem[];             // SNTP mem
extern uint8_t  rgbDhcpDnsNtpPageMGR[];     // UDP socket buffer space shared DHCP / DNS / SNTP

extern HRRHEAP  hRRAdpHeap;                 // handle to ipStack in memory Round Robin Heap
extern HPMGR    hNetworkPMGR;               // handle to Socket mem page manager
extern HPMGR    hDhcpDnsNtpPMGR;            // handle to shared DHCP / DNS / SNTP mem page mgr

#include <AdaptorClass.h>

#ifdef DEIPINCLUDECODEHERE

    // Specifies how big the ARP Cache should be. Should be at least 2 more like 5 or more
    // this is defined when the Link Layer Adaptor is created.
    #ifndef cARPEntries
    #define cARPEntries 10
    #endif
    uint32_t cbARPMem = LLGetIPv4ARPMemSize(cARPEntries);
    uint8_t  rgbLLARPMem[LLGetIPv4ARPMemSize(cARPEntries)];

    // Define how many DNS servers we will support and reserve the space for it
    #ifndef cDNSServers
    #define cDNSServers 4
    #endif
    uint32_t cbDNSMem = DNSMemorySize(cDNSServers);
    uint32_t cDNSMax = cDNSServers;
    uint8_t  rgbDNSMem[DNSMemorySize(cDNSServers)];


    // this needs to be big enough for an ipStack, plus some payloads of 576 or more
    // this is used by the adaptor and must be defined when getting the adaptor
    #ifndef cbAdpHeap
    #define cbAdpHeap   4096
    #endif
    uint8_t rgbAdpHeap[cbAdpHeap];
    HRRHEAP hRRAdpHeap = RRHPInit(rgbAdpHeap, cbAdpHeap);

    // DHCP / DNS / SNTP RAM page manager
    // the page manager set aside for use for the system DHCP, DNS, NTP UDP socket buffers
    // 512 byte page manager 1<<6 = 64 * 15 = 960
    // Here is how we got 15 pages. DHCP are big packets very close to 576 bytes, required
    // packet to be sent by a router. DHCP is typically 548 bytes; often. So 576 / 65 = 9 pages.
    // Each service (DHCP, DNS, SNTP) requires a page for the indirect streams, so 3 more. And because a page can wrap
    // and the start of a page could be unsued, each of the 3 services could need an extra page, so 3 more.
    // a total of 9+3+3 = 15 pages.
    #define pfDhcpDnsNtp        6   // 1<<6 == 64 byte pages
    #define cPagesDhcpDnsNtp    15  // 15 pages
    #define cbrgbDhcpDnsNtpPageMGR RAMGetPMGRSize(cPagesDhcpDnsNtp, pfDhcpDnsNtp)
    uint8_t  rgbDHCPMem[DHCPMemSize];
    uint8_t  rgbSNTPv4Mem[SNTPv4MemSize];
    uint8_t  rgbDhcpDnsNtpPageMGR[cbrgbDhcpDnsNtpPageMGR];
    HPMGR    hDhcpDnsNtpPMGR = RAMCreatePageMGR(rgbDhcpDnsNtpPageMGR, cbrgbDhcpDnsNtpPageMGR, cPagesDhcpDnsNtp, pfDhcpDnsNtp);

#endif  // place code

#endif

#endif  // _DEIPCK_H
