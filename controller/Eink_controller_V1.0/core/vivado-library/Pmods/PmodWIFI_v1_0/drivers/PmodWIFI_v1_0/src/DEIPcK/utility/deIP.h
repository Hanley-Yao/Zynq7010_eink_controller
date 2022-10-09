/************************************************************************/
/*																		*/
/*	deIP.h          This is the primary header file for the             */
/*                  Digilent Embedded Internet Protocol stack           */
/*																		*/
/************************************************************************/
/*  Author:     Keith Vogel                                             */
/*  Copyright 2013, Digilent Inc.                                       */
/************************************************************************/
/* deIP core network library
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
/*	Defines datastructures for the deIP stack                           */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	7/10/2012(KeithV): Created                                          */
/*                                                                      */
/************************************************************************/
#ifndef _NETWORK_DEIP_H_
#define _NETWORK_DEIP_H_

#ifdef	__cplusplus
extern "C" {
#endif

#include "System.h"

/************************************************************************/
/*                                                                      */
/*  IPSTATUS  status codes                                              */
/*                                                                      */
/************************************************************************/

// status codes
#define IPSTATUS                    uint32_t
#define ipsSuccess                  0x00000000
#define ipsFailed                   0x10000000
#define IsIPStatusAnError(a)        (((a) & ipsFailed) == ipsFailed)
#define ForceIPError(a)             ((a) | ipsFailed)
#define ForceIPStatus(a)            ((a) & ~ipsFailed)
#define AssignStatusSafely(a, b)    {if((a) != NULL) *(a) = b;}

#define DEIPcKStatusBase        0x0E000000
#define MakeDEIPcKStatus(_a)    ((_a) | DEIPcKStatusBase)

// 00000001 -> 00007FFF; Adaptor status; specific to adaptor
// 10000001 -> 10007FFF; Adaptor errors; specific to adaptor
// NOTE TO ADAPTOR AUTHORS
// These defines are used by all adaptors, make them name unique
// so if more than one adaptor is included they don't collide in the name space

// 00010001 -> 00010FFF; ARP Link Layer status
#define ipsARPPending                       0x00010001
#define ipsARPExistingIndex                 0x00010002
#define ipsARPBestNewIndex                  0x00010003
#define ipsARPExpired                       0x00010004

// 10010001 -> 10010FFF; ARP Link Layer errors
#define ipsARPCacheNotModuloOfEntrySize     0x10010001
#define ipsARPFailedToResolve               0x10010002
#define ipsARPNoCacheEntriesAvailable       0x10010003

// 00011001 -> 0001FFFF; Link Layer status
#define ipsDHCPPending                      0x00011001

// 10011001 -> 1001FFFF; Link Layer errors
#define ipsAtLeastOneARPEntryIsNeeded       0x10011001
#define ipsAdpMemIsNULL                     0x10011002
#define ipsInvalidFrameSize                 0x10011003
#define ipsFrameHeaderRequired              0x10011004
#define ipsNoDefaultAdaptorExists           0x10011005
#define ipsAdaptorMustBeSpecified           0x10011006
#define ipsIPNotSetup                       0x10011007

// 00020001 -> 00020FFF; ICMP Internet Layer status
// 10020001 -> 10020FFF; ICMP Internet Layer errors

// 00021001 -> 0002FFFF; Internet Layer status
// 10021001 -> 1002FFFF; Internet Layer errors
#define ipsInvalidIPv4HedearSize            0x10021001
#define ipsIPv4HedearRequired               0x10021002
#define ipsIPv6NotSupported                 0x10020003


// 00050001 -> 0005FFFF; Transport Layer status
// 10050001 -> 1005FFFF; Transport Layer errors
#define ipsUnsupportedTransportProtocol     0x10050001
#define ipsIPAddressIsNull                  0x10050002

// 00060001 -> 0006FFFF; Socket Transport Layer status
#define ipsSocketFull                       0x00060001
#define ipsAllSocketsInUse                  0x00060001

// 10060001 -> 1006FFFF; Socket Transport Layer errors
#define ipsInvalidSocketPoolSize            0x10060001
#define ipsNoSocketsAvailable               0x10060002
#define ipsPortAlreadyInUse                 0x10060003
#define ipsSocketNULL                       0x10060004
#define ipsTCBTimeExpired                   0x10060005
#define ipsSocketNotInUse                   0x10060006
#define ipsPortPairAndIPAlreadyActive       0x10060007
#define ipsSocketNotResolved                0x10060008

// 00070001 -> 0007FFFF; UDP Transport Layer status
// 10070001 -> 1007FFFF; UDPTransport Layer errors
#define ipsUDPNoCacheGiven                  0x10070001
#define ipsUDPCacheNotBigEnough             0x10070002
#define ipsUDPUnableToCreateSocket          0x10070003
#define ipsUDPNullDatagram                  0x10070004

// 00080001 -> 0008EFFF; TCP Transport Layer status
#define ipsUnexpectedSyn                    0x00080001
#define ipsIncomingPktOutOfOrder            0x00080002
#define ipsCloseAlreadyIssued               0x00080003
#define ipsInvalidRst                       0x00080004
#define ipsRetransmit                       0x10080005

// 10080001 -> 1008EFFF; TCPTransport Layer errors
#define ipsUnknowTCPState                   0x10080001
#define ipsTCPRSTPkt                        0x10080002
#define ipsSeqOutOfBoundsACKResponse        0x10080003
#define ipsConnectionOutofSyncSendRST       0x10080004
#define ipsNoACKinMSLTime                   0x10080005
#define ipsFailedToReadStreamBuffer         0x10080006

// These are special in that discribe the tcpState as a status
// the range is from 0008F000 -> 0008FFFF;
#define ipsTCPStatusState                   0x0008E000
#define IPStatusFromTCPState(_tcpState)     (ipsTCPStatusState | _tcpState)

// These are special in that discribe the tcpState as an error
// the range is from 1008F000 -> 1008FFFF;
#define ipsTCPErrorState                    0x1008E000
#define TCPStateFromStatus(s)               (s & 0x00000FFF)
#define IPErrorFromTCPState(_tcpState)      (ipsTCPErrorState | _tcpState)

// 00090001 -> 0009FFFF; DHCP status

// 10090001 -> 1009FFFF; DHCP errors
#define ipsDHCPNotEnoughMem                 0x10090001
#define ipsDHCPMemIsNULL                    0x10090002
#define ipsDHCPUnknownState                 0x10090003
#define ipsDHCPUnableToCreateUDPSocket      0x10090004
#define ipsDHCPCurrentlyInUse               0x10090005

#define ipsDHCPStatus                       0x0009E000
#define DHCPStateFromStatus(s)              (s & 0x00000FFF)
#define IPStatusFromDHCPState(_dhcpState)   (ipsDHCPStatus | _dhcpState)

// 000A0001 -> 000AFFFF; DNS status
#define ipsDNSIsResolving                   0x000A0001
#define ipsDNSIsInUse                       0x000A0002

// 100A0001 -> 100AFFFF; DNS errors
#define ipsDNSNotEnoughMem                  0x100A0001
#define ipsDNSMemIsNULL                     0x100A0002
#define ipsDNSIsNotInitialized              0x100A0003
#define ipsDNSAlreadyInitialized            0x100A0004
#define ipsDNSUnknownState                  0x100A0005
#define ipsDNSUnableToCreateUDPSocket       0x100A0006
#define ipsDomainNameIsNULL                 0x100A0008
#define ipsIPIsNULL                         0x100A0009
#define ipsDNSInvalidName                   0x100A000A
#define ipsDNSFailedToResolve               0x100A000B
#define ipsDNSInvalidURL                    0x100A000C

#define ipsDNSStatus                        0x000AE000
#define DNSStateFromStatus(s)               (s & 0x00000FFF)
#define IPStatusFromDNSState(_dnsState)     (ipsDNSStatus | _dnsState)


// 000B0001 -> 000BFFFF; NTP time status
// 100B0001 -> 100BEFFF; NPT time errors
#define ipsNTPMemoryNull                    0x100B0001
#define ipsNTPMemoryTooSmall                0x100B0002
#define ipsNoNTPServers                     0x100B0003


// 000E0001 -> 000EFFFF; IPSTACK status
// 100E0001 -> 100EFFFF; IPSTACK errors
#define ipsIpStackInUse                     0x100E0001
#define ipsIpStackNotInMachineOrder         0x100E0002
#define ipsIpStackNotInNetworkOrder         0x100E0003
#define ipsIpStackParsingError              0x100E0004
#define ipsIpStackNotParsed                 0x100E0005
#define ipsIpStackNotSupportedPkt           0x100E0006
#define ipsIpStackChecksumError             0x100E0007
#define ipsIpStackAllInUse                  0x100E0008
#define ipsIpStackNULL                      0x100E0009

// 0F000001 -> 0F00FFFF; general status
#define ipsTimeoutW                         0x0F000001
#define ipsPending                          0x0F000002
#define ipsInUseW                           0x0F000004

// 1F000001 -> 1F00FFFF; general errors
#define ipsTimeout                          0x1F000001
#define ipsBufferNotDefined                 0x1F000002
#define ipsNotSupported                     0x1F000003
#define ipsInUse                            0x1F000004
#define ispInvalidArgument                  0x1F000005
#define ispTooManyAttempts                  0x1F000006
#define ispOutOfMemory                      0x1F000007
#define ipsNoPMGRGiven                      0x1F000008
#define ipsNoHeapGiven                      0x1F000009
#define ipsNullAdaptor                      0x1F00000A
#define ipsNotInitialized                   0x1F00000B
#define ipsNoSMGRGiven                      0x1F00000C

// the master IP PacKT structure that is passed down through the layers
// the adaptor will ultimately assemble the 

// IPStack Parsing Status, max 4 bits (15)
#define ipssNone            0       // parsed just fine
#define ipssDiscarded       1       // the ip datagram was discarded
#define ipssNotSupported    2       // the ip datagram type is not supported   
#define ipssCorruptPkt      4       // Unable to parse the pkt    
#define ipssIncompleteParse 5       // Not everything was parsed
#define ipssChecksumError   6       // The checksum did not work out
#define ipssPendingIPOp     7       // An operation is pending on the stack item
#define ipssARPFailed       8       // ARP Failed the lookup

// If fFrameIsParsed, all fields are filled in and there is no requirement
// that the headers or data be assigned in contiguous memory.
// However if fFrameIsParsed is false, then the whole datagram must be in
// contiguous memory and pointed by the pFrameII, this then can be parsed
// if pFrameII is NULL, it is an unassigned IPSTACK structure, pFrameIsParsed must be NULL
// if IsIpStackInUse, then you must not touch the buffer until the adaptor releases it back
// to you via the IsSendDone(). If fReleaseRead is true, you must return the buffer to the
// adaptor for reuse by calling DoneWithReadBuff().
#pragma pack(push,1)                    // we want to have control over this structure

/************************************************************************/
/*                                                                      */
/*  Type defines                                                        */
/*                                                                      */
/************************************************************************/
#define IPPN            uint8_t
#define ETHERTYPE       uint16_t

// RFC 791
typedef struct TOS_T
{
    union
    {
        uint8_t         u8;
        struct
        {
            unsigned    ce          : 1;
            unsigned    ect         : 1;
            unsigned    dscp        : 6;        // RFC 2474
        };
        struct
        {

            unsigned reserved       : 2;
            unsigned reliability    : 1;
            unsigned throughput     : 1;
            unsigned delay          : 1;
            unsigned precedence     : 3;
        };
    };
} TOS;

// When an adaptor sets up an IPSTACK, it must provide the memory for the IPSTACK
// and set the cbPayload, pPayload and headerOrder Values

// When an IPSTACK is created by the applicaiton it must allocate enough space for alll
// of the headers completely cleared, and all values set except"
// fFrameIsParsed, fHeldBySend, paddingA, pIpStackNext
// fFrameIsParsed will be set when you "Set the IPSTACK";
// protocolType, etherType, and pLLAdp (adaptor), fOptionPresent
typedef struct IPSTACK_T
{
    // pointers for use in the link layer; These must be aligned!
    // this is an internally used next pointer, do not use
    // this must be the frist item in the structure
    struct IPSTACK_T *                  pIpStackNext;
    const struct LLADP_T *              pLLAdp;

    // info about the IPSTACK structure
    union
    {
        struct
        {
            bool                        fFrameIsParsed      : 1;    // if NOT, than the frame points to the whole datagram
            bool                        fIEEE802Frame       : 1;    // this is an IEEE 802 frame
            bool                        fWaitingOtherInfo   : 1;    // Waiting for some other operation to compilete, like and ARP
            bool                        fOptionPresent      : 1;    // There are options in the IP Header
            bool                        fOwnedByAdp         : 1;    // the buffer is in use by the adaptor send routine
            bool                        fFreeIpStackToAdp   : 1;    // the IPSTACK must be released back to the adaptor
            bool                        fFreePayloadToAdp   : 1;    // the payload was allocated seperately from the IPStack
            unsigned                    headerOrder         : 1;    // network (Big Endian) or machine order (?? Endian)
            unsigned                    ipss                : 4;    // IPStack Parsing Status
            unsigned                                        : 4;    // bits for the adaptor to use
         };
        uint16_t                        ipsFlags;                   // make it easy to clear flags
    };

    // Frame Header
    uint16_t                            cbFrame;
    union
    {
        struct ETHERNETII_FRAME_T *     pFrameII;
        struct ETHERNET_802_FRAME_T *   pFrame802;
    };

    // IP Header
    ETHERTYPE                           etherType;
    uint16_t                            cbIPHeader;
    union
    {
        void *                          pIPHeader;
        struct IPv4HDR_T *              pIPv4Hdr;
        struct IPv6HDR_T *              pIPv6Hdr;
    };

    // Transport Header
    IPPN                                protocol;
    TOS                                 tos;
    uint16_t                            cbTranportHeader;
    union
    {
        void *                          pTransportHeader;
        struct UDPHDR_T *               pUDPHdr;
        struct TCPHDR_T *               pTCPHdr;
    }; 

    // Payload data
    uint16_t                            padPL;
    uint16_t                            cbPayload;
    union
    {
        void *                          pPayload;
        uint8_t *                       pbPayload;
        struct ETHERNETII_FRAME_T *     pFramePl;
        struct ARPIPv4_T *              pARPIPv4;
        struct DHCPDG_T *               pDHCPDataGram;
        struct ICMPHDR_T *              pICMPHdr;
        struct ICMPING_T *              pICMPPing;
        struct ICMPT0_T *               pICMP0;
        struct ICMPT3_T *               pICMP3;
        struct ICMPT4_T *               pICMP4;
        struct ICMPT5_T *               pICMP5;
        struct ICMPT8_T *               pICMP8;
        struct ICMPT11_T *              pICMP11;
        struct ICMPT12_T *              pICMP12;
        struct ICMPT13_T *              pICMP13;
        struct ICMPT14_T *              pICMP14;
        struct ICMPT15_T *              pICMP15;
        struct ICMPT16_T *              pICMP16;
    };
} IPSTACK;

// structure for casting unaligned pointers.
typedef struct UNALIGNPTR_T
{
    union
    {
        uint16_t    u16;
        int16_t     i16;
        uint32_t    u32;
        int32_t     i32;
    };
} UNALIGNPTR;

#define UNUSED(x) (void)(x)

#pragma pack(pop)

#include "HeapMgr.h"
#include "InternetLayer.h"
#include "LinkLayer.h"
#include "ICMP.h"
#include "TransportLayer.h"
#include "DHCP.h"
#include "DNS.h"
#include "Adaptor.h"
#include "IPStack.h"
#include "SNTPv4.h"

// IPStack, system level stuff
bool IPSInit(uint8_t * pSocketMem, uint32_t cbSocketMem, uint32_t cEstSocketsT);
void IPSClearSocketHeap(void);
void IPSPeriodicTasks(void);

// LinkLayer
#define LLIsLinked(_pLLAdp, _pStatus) ((_pLLAdp)->pNwAdp->IsLinked(_pStatus))
const LLADP * LLAddAdaptor(const NWADP *pNwAdp, void * pAdpMem, uint32_t cbAdpMem, IPSTATUS * pStatus);
const LLADP * LLGetDefaultAdaptor(void);
bool LLRemoveAdaptor(const LLADP * pLLAdp);
#define LLGetIPv4ARPMemSize(_cArpEntries) (sizeof(LLADP) + (_cArpEntries * sizeof(LLARP)))
bool LLARPLookup(const LLADP * pLLAdp, const void * pIPRequest, MACADDR * pMacAddr, uint32_t cSend, IPSTATUS * pStatus);
#define LLIsBroadcastMAC(_pIpStack) (memcmp(&_pIpStack->pFrameII->macDest, &MACBROADCAST, sizeof(MACADDR)) == 0)
#define LLGetMyMac(_pLLAdp, _pMac) memcpy((void *) (_pMac), (void *) &(_pLLAdp)->pNwAdp->mac, sizeof(MACADDR))

// Internet Layer
#define ILIsIPv6(_pLLAdp) ((_pLLAdp)->pNwAdp->fIPv6)
#define ILIPSize(_pLLAdp) (ILIsIPv6(_pLLAdp) ? sizeof(IPv6) : sizeof(IPv4))
#define ILIsIPNetworkReady(_pLLAdp, _pStatus) (LLIsLinked(_pLLAdp, _pStatus) && ILIsIPSetup(_pLLAdp, _pStatus))
#define ILIsBroadcastIP(_pIpStack) ((ILIsIPv6(_pIpStack->pLLAdp)) ? false : (((_pIpStack->pLLAdp->submask.ipv4.u32 | _pIpStack->pIPv4Hdr->ipDest.u32) == 0xFFFFFFFF) && (_pIpStack->pIPv4Hdr->ipDest.u8[0] != 127)))
bool ILIsMyIP(const LLADP * pLLAdp, const void * pIP, bool * pfBroadcast);
bool ILIsIPSetup(const LLADP * pLLAdp, IPSTATUS * pStatus);

bool ILSetMyIP(const LLADP * pLLAdp, const void * pMyIP);
bool ILSetIP(const LLADP * pLLAdp, const void * pIP, void * pIPModify);
#define ILSetMyGateway(_pLLAdp, _pMyGateway) ILSetIP(_pLLAdp, _pMyGateway, (void *) &(_pLLAdp)->ipGateway)
#define ILSetMySubmask(_pLLAdp, _pMySubmask) ILSetIP(_pLLAdp, _pMySubmask, (void *) &(_pLLAdp)->submask)

#define ILGetIP(_pLLAdp, _pIPLocation, _pIP) memcpy((void *) (_pIP), (void *) (_pIPLocation), ILIPSize(_pLLAdp))
#define ILGetMyIP(_pLLAdp, _pMyIP) ILGetIP(_pLLAdp, &(_pLLAdp)->ipMy, _pMyIP)
#define ILGetMyGateway(_pLLAdp, _pMyGateway) ILGetIP(_pLLAdp, &(_pLLAdp)->ipGateway, _pMyGateway)
#define ILGetMySubmask(_pLLAdp, _pMySubmask) ILGetIP(_pLLAdp, &(_pLLAdp)->submask, _pMySubmask)

// Transport Layer

#define portUnassigned          0x0000
#define portDynamicallyAssign   0x0000
#define portListen              0x0000
#define portReservedPort        0x0000
#define portInvalid             0xFFFF
#define portMaxPort             0xFFFF

// Official UDP + TCP Port Ranges
#define portWellKnownPorts      1                   // start of well known ports
#define portRegisteredPorts     1024                // end of well known, start of registered ports
#define portEphemeralFirst      49152               // end of registered ports, start of emphemeral ports
#define portEphemeralLast       (portInvalid-1)     // the last of the valid ports

// Here are some common well know ports.
// This is not an exhaustive list by any means!
#define portFTPDataPort         20
#define portFTPControlPort      21
#define portTelnetPort          23
#define portSMTPPort            25
#define portDNSServer           53
#define portBOOTPServer         67
#define portBOOTPClient         68
#define portTFTPPort            69
#define portRebootPort          69      // Microchip overloaded this port for reboot
#define portGopherPort          70
#define portHTTPPort            80
#define portNTPPort             123

//#define IPv4BROADCAST       ((const IPv4) {0xFF, 0xFF, 0xFF, 0xFF})    // RFC xxx
//#define IPv4NONE            ((const IPv4) {0x00, 0x00, 0x00, 0x00})    // RFC xxx
//#define IPv6NONE            ((const IPv6) {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00})    // RFC xxx
extern const IPv4 IPv4BROADCAST;
extern const IPv4 IPv4NONE;     
extern const IPv6 IPv6NONE;     
#define IPListen            IPv6NONE
#define IPv4Listen          IPv4NONE
#define IPv6Listen          IPv6NONE
#define UDPAnyRemoteIPv4    IPv4BROADCAST

#define SKTGetRemoteIPv4(_h, _pRemoteIP) *((IPv4 *) _pRemoteIP) = (((_h) == NULL) ? (*(((IPv4 *) (&IPv4NONE)))) : (*((IPv4 *) &(((SOCKET *) (_h))->ipRemote.ipv4))))
#define SKTGetRemotePort(_h) (((_h) == NULL) ? portUnassigned : (((SOCKET *) (_h))->portRemote))
#define SKTGetRemoteMAC(_h, _pRemoteMAC) memcpy(_pRemoteMAC, (((_h) == NULL) ? (&MACNONE) : (&(((SOCKET *) (_h))->macRemote))), sizeof(MACADDR))
#define SKTGetLocalPort(_h) (((_h) == NULL) ? portUnassigned : (((SOCKET *) (_h))->portLocal))

// UDP user level calls
HSOCKET UDPOpen(const LLADP * pLLAdp, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus);
void UDPClose(HSOCKET hSocket);
void UDPCloseAllSockets(void);
uint32_t UDPAvailable(HSOCKET hpSocket);
uint32_t UDPPeekIdx(HSOCKET hSocket, uint32_t index, uint8_t * pbRead, uint16_t cbRead, IPSTATUS * pStatus);
#define UDPPeek(_hSocket, _pv, _cb, _pStatus) UDPPeekIdx(_hSocket, 0, _pv, _cb, _pStatus)
uint32_t UDPRead(HSOCKET hSocket, uint8_t * pbRead, uint16_t cbRead, IPSTATUS * pStatus);
bool UDPSend(HSOCKET hSocket, const uint8_t * pbDatagram, uint16_t cbDatagram, IPSTATUS * pStatus);
void UDPDiscard(HSOCKET hSocket);

// TCP
// RFC 793 TCP calls; User level calls
HSOCKET TCPOpen(const LLADP * pLLAdp, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus);
void TCPClose(HSOCKET hSocket, IPSTATUS * pStatus);
bool TCPIsConnected(HSOCKET hSocket, IPSTATUS * pStatus);
bool TCPIsEstablished(HSOCKET hSocket, IPSTATUS * pStatus);
IPSTATUS TCPStatus(HSOCKET hSocket);
uint32_t TCPAvailable(HSOCKET hSocket, IPSTATUS * pStatus);
uint32_t TCPPeekIdx(HSOCKET hSocket, uint32_t index, void * pv, uint32_t cb, IPSTATUS * pStatus);
#define TCPPeek(_hSocket, _pv, _cb, _pStatus) TCPPeekIdx(_hSocket, 0, _pv, _cb, _pStatus)
uint32_t TCPRead(HSOCKET hSocket, void * pv, uint32_t cb, IPSTATUS * pStatus);
uint32_t TCPWrite(HSOCKET hSocket, const void * pv, uint32_t cbReq, IPSTATUS * pStatus);
void TCPDiscard(HSOCKET hSocket);
void TCPFlush(HSOCKET hSocket);
void TCPAbort(HSOCKET hSocket);
void TCPAbortAllSockets(void);

// DHCP RFC1531, RFC 2131, RFC 1533
#define DHCPMemSize (sizeof(DHCPMEM))
bool DHCPInit(const LLADP * pLLAdp, void * rgbDHCPMem, uint32_t cbDHCPMem, HPMGR hPMGR, IPSTATUS * pStatus);
bool DHCPTerminate(const LLADP * pLLAdp);
bool DHCPIsDone(const LLADP * pLLAdp, IPSTATUS * pStatus);

// DNS stuff
#define DNSMemorySize(_cdnsNS)  (sizeof(DNSMEM) + _cdnsNS * sizeof(IPv4or6))
bool DNSInit(const LLADP * pLLAdp, void * rgbDNSMem, uint32_t cbDNSMem, HPMGR hPMGR, IPSTATUS * pStatus);
bool DNSTerminate(const LLADP * pLLAdp);
bool DNSResolve(const LLADP * pLLAdp, const uint8_t * szDomainName, uint32_t cchDomanName, void * pIPvX, IPSTATUS * pStatus);
#define DNSIsBusy(_pLLAdp) ((_pLLAdp == NULL || _pLLAdp->pDNSMem == NULL) ? true : (_pLLAdp->pDNSMem->dnsState != dnsReady))
const uint8_t * DNSParseURL(uint8_t const * const szURL, uint32_t * pcbDomainName, uint16_t * pPort);
void DNSAbort(const LLADP * pLLAdp);
bool DNSAddNS(const LLADP * pLLAdp, const void * pIPvX, uint32_t index);
bool DNSGetNS(const LLADP * pLLAdp, uint32_t index, void * pIPvX);
#define DNScNS(_pLLAdp) ((_pLLAdp == NULL || _pLLAdp->pDNSMem == NULL) ? 0 : _pLLAdp->pDNSMem->cDhcpNS)
#define DNScMaxNS(_pLLAdp) ((_pLLAdp == NULL || _pLLAdp->pDNSMem == NULL) ? 0 : _pLLAdp->pDNSMem->dnsNSMax)

// SNTPv4 Stuff
bool SNTPv4Init(const LLADP * pLLAdp, void * rgbSNTPvMem, uint32_t cbSNTPv4Mem, HPMGR hPMGR, uint8_t const * const * const rgpServers, uint32_t cServers, IPSTATUS * pStatus);
uint32_t SNTPv4GetNTPEpochTime(const LLADP * pLLAdp);
uint32_t SNTPv4GetUNIXEpochTime(const LLADP * pLLAdp);
bool SNTPv4Terminate(const LLADP * pLLAdp);

#ifdef	__cplusplus
}
#endif

#endif // _NETWORK_DEIP_H_