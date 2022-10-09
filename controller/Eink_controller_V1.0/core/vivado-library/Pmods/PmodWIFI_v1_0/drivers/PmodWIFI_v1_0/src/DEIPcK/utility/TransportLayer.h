/************************************************************************/
/*																		*/
/*	TransportLayer.h Header file for the network transport layer        */
/*          including UDP / TCP headers and sockets                     */
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
/*  Module Description: 												*/
/*																		*/
/*	UDP / TCP Transport layer definitions             				    */
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	9/12/2012(KeithV): Created											*/
/*																		*/
/************************************************************************/
#ifndef _TRANSPORT_LAYER_H_
#define _TRANSPORT_LAYER_H_

#include "deIP.h"

#define TCPMSL              120000ul                    // RFC 793 Section 3.3, 2 MIN
#define TCPMAXHALFCLOSE     5000ul                      // If we are in a half closed state waiting for the other side to ACK, this is the max time before sending a reset

#define cbTCPOptionSpace    16      // must be a mult of 4; this is how much space is reserved for option in a TCP Header for the pool space

// this is based off of the 2 usec seq clock, NOT the ms clock.
// RFC 793 defines the wait time as 2 * the MSL (4 min); adjusted to the 4 usec seq clock.
#define TIMEWAITDELAY   (2 * TCPMSL * 250)      

//Be careful in interpreting the following parameters. There are 2 algorithms to
// worry with, the original RFC 793 AND the later Karn & Jacobson.
// we are currently doing Karn & Jacobson

// these are in millseconds
#define MAXFLUSH    250ul   // How often will we force a flush, even if we don't get a flush request. This is also the MAX delayed ACK time RFC 1122 4.2.3.2
#define RTTsaINIT   3000ul  // RFC 1122 4.2.3.1 says 3 seconds for SRTT; or our average RTT
#define RTTsvINIT   2625ul  // RFC 1122 4.2.3.1 says 3 seconds for SRTT

// Where BETA 1.3 - 2; Karn & Jacobson say use 2
#define RTO(s) ((s->RTTsa >> 3) + s->RTTsv)

// the original RFC 793 RTO parameters
//#define RTO(srtt) (min(RTOUBOUND, (max(RTOLBOUND, (2 * (srtt))))))
// RFC 793 3.7; RTO = min[UBOUND, max[LBOUND, (BETA*SRTT)]];
//#define RTOLBOUND   250                         // RFC 793 3.7 suggests a lower retransmit timeout (RTO) of 1 second but RFC 1122 4.2.3.1. says fraction of secs.
//#define RTOUBOUND   240000                      // RFC 793 3.7 suggests an upper retransmit timeout (RTO) of 1 min. but RFC 1122 4.2.3.1 says 240sec
//#define SRTTINIT    3000                        // RFC 1122 4.2.3.1 says 3 seconds for SRTT
// RFC 973 3.7 says ALPHA .8 - .9
// we pick .875 which is (1-1/8) (Karn's and Jacobson)
// the equation is SRTT = (ALPHA * SRTT) + ((1-ALPHA) *RTT)
// replace ALPHA with (1-1/8) we have
// SRTT = ((1-1/8) * SRTT) + ((1-(1-1/8)) * RTT)
// SRTT = ((SRTT - SRTT/8) + (RTT/8)
// SRTT = SRTT + RTT/8 - SRTT/8
//#define SRTT(srtt, rtt) (srtt + (rtt >> 3) - (srtt >> 3))

// Anything 30 min. earlier than the current time is considered before the current time.
// this is a scaling factor so we can see if within a relative time is something happened before or after the
// current time.
#define TIMEWAITBEFORE  (30ul * 60ul * 250000ul)

typedef uint16_t TCPSTATE;

// look at the state machine, the order of these values is VERY important.
#define tcpUnassigned                   0       // The socket is available
#define tcpAllocated                    1       // In use, probably being set up
#define tcpInvalid                      2       // This is an invalid socket
#define tcpListen                       10      // passive open, Wait for their SYN and data, we send SYN
#define tcpSynSent                      11      // We sent a SYN, wait for their SYN and data
#define tcpSynReceivedWhileListening    12      // same as tcpSynReceived, except we got here from the listening state; needed for reset
#define tcpSynReceived                  13      // ACK their SYN, wait for ACK of otcpSynReceivedur SYN
#define tcpEstablished                  14      // data and their FIN
#define tcpFinWait1                     15      // we flush and send FIN
#define tcpFinWait2                     16      // wait for ack of FIN
#define tcpCloseWait                    17      // Got their FIN, ACK and flush our data, send our FIN
#define tcpClosing                      18      // Wait for their FIN, we ACK
#define tcpLastAck                      19      // Wait for ACK of our FIN
#define tcpWaitUserClose                20      // Hold removing the socket until the user closes it, he may want to read data
#define tcpClosed                       21      // Cleans up and releases the socket

typedef uint8_t TCPOPTIONKIND;
#define tcpOpKdEndOfList        0
#define tcpOpKdNoOperation      1
#define tcpOpKdMaxSegSize       2
#define tcpOpKdWindowScale      3
#define tcpOpKdSAck             4
#define tcpOpKdSAckMult         5
#define tcpOpKdTimestamp        8
#define tcpOpKdAltChksumReq     14
#define tcpOpKdAltChksumData    15

#pragma pack(push,1)

// I would really like this to be a union typedef
// but because I want to use it as an unnamed union in other structures
// I have to make it a #define as unnamed structures are not supported
// before the C11 compiler spec.
#define     PORTPAIR                    \
    union                               \
    {                                   \
        uint32_t        portPair;       \
        struct                          \
        {                               \
            uint16_t    portSrc;        \
            uint16_t    portDest;       \
        };                              \
    };

typedef struct UDPHDR_T
{
    PORTPAIR;
    uint16_t cbHdrData;
    uint16_t checksum;
} UDPHDR;

#if 0
// the pseudo header for calculating checksums
// acutally not used, it is here for documentation reasons.
typedef struct PSUDPHDRv4_T
{
    IPv4        ipSrc;
    IPv4        ipDest;
    uint8_t     ippn;           // 17, 0x11, ippnUDP
    uint8_t     zero;
    uint16_t    cbHdrData;
    UDPHDR      udpHdr;
} PSUDPHDRv4;

// the pseudo header for calculating checksums
// acutally not used, it is here for documentation reasons.
typedef struct PSUDPHDRv6_T
{
    IPv6        ipSrc;
    IPv6        ipDest;
    uint8_t     ippn;           // 17, 0x11, ippnUDP
    uint8_t     zero;
    uint16_t    cbHdrData;
    UDPHDR      udpHdr;
} PSUDPHDRv6;
#endif

typedef struct TCPHDR_T
{
    PORTPAIR;
    uint32_t            seqNbr;
    uint32_t            ackNbr;
    union
    {
        uint16_t	u16Flags;
        struct
        {
            unsigned	reserved	: 4;
            unsigned	dataOffset	: 4;
            unsigned	fFin		: 1;
            unsigned 	fSyn		: 1;
            unsigned 	fRst		: 1;
            unsigned	fPsh		: 1;
            unsigned	fAck		: 1;
            unsigned	fUrg		: 1;
            unsigned	fECN		: 1;
            unsigned	fCWR		: 1;
        };
    };
    uint16_t            window;
    uint16_t            checksum;
    uint16_t            urgentPtr;
} TCPHDR;

typedef struct TCPOPTION_T
{
    TCPOPTIONKIND   optionKind;
    uint8_t         length;
    uint16_t        rgu16[];
} TCPOPTION;

#pragma pack(pop)

typedef union
{
    struct
    {
        uint16_t        portRemote;
        uint16_t        portLocal;          // if this is zero, the socket is not in use
    };
    uint32_t            portPair;
} SKTPORTPAIR;

typedef struct
{
    IPv4or6         ip;
    uint16_t        port;
} IPEndPoint;

typedef void * HSOCKET;

typedef struct SOCKET_T
{
    struct SOCKET_T *       pNextSocket;
    const struct LLADP_T *  pLLAdp;

    IPv4or6                 ipRemote;

    // we do not want to use PORTPAIR here
    // because we switch src (remote) and Dest (local)
    // so we can do a straight out compare of portPair and
    // see if this is the socket required for the incoming datagram
    union
    {
        uint32_t            portPair;
        struct
        {
            uint16_t        portRemote;
            uint16_t        portLocal;          // if this is zero, the socket is not in use
        };
    };

    // not strictly needed, but useful information
    MACADDR macRemote;
} SOCKET;


// This is how you calculate how big of a socket buffer we can support
// We have a stream buffer in the socket, it is a fixed size stream that points
// to another stream that points to the socket buffers. So the stream handle
// in the socket is really an indirect stream to the socket buffer stream
// since the stream in the socket is fixed, the stream it points to is bounded
// which then limits the max size of our socket buffer.
// streams are based on an underlying page manager and the page size
// can range from 32 bytes to 32 Kbytes. If max size socket buffer is calculated by
// ((cPage * cbPage) - sizeof(SMGR)) * cbPage.
// so if we have a pagemanger that supports 64 byte pages, and we reserve
// room for 9 pages in our socket; we could support a max socket buffer of
// ((9 * 64) - 13) * 64 = 36,032 in our socket buffer

#define cTCPRXPages 9
#define cTCPTXPages 9

// now because TCP has both a RX and TX buffer, we need to provide room for both
// indirect streams.
#define cbMAXTCPSreamRecord GetSMGRSize(cTCPTXPages + cTCPRXPages)

// The socket
typedef struct TCPSOCKET_T
{
    SOCKET                  s;

    // THIS IS THE TCB AREA, TAKEN FROM RFC 793

    //  receive info
    uint32_t                rcvIRS;         // ack number; RX
//    uint32_t                rcvUNR;         // unread part of the buffer, This is our sliding base; reading the buffer slides this down; this is always zero
    uint32_t                rcvNXT;         // End of active stuff to read
    uint32_t                rcvUP;          // receive urgent pointer
//    uint32_t                rcvSeqAhead;    // sequence number ahead of what we expect.
 
    // transmit info
    uint32_t                sndISS;         // seq number; TX
    uint32_t                sndUNA;         // What we have sent, yet is unacked by the remote host, This is our sliding base; acks slide this down
    uint32_t                sndNXT;         // The next place I am going to send
    uint32_t                sndEND;         // The end of what we actively need to send.
    uint32_t                sndWND;         // The number of bytes I can send to the remote host; nothing to do with what I have ready to send
    uint32_t                sndPSH;         // segment sequence number to flush to (push)
//    uint32_t                sndWL2;         // This is the sndWND position when we get an updated window size; not need as we can use sndUNA
    uint32_t                sndUP;          // send urgent pointer
    uint32_t                sndRTTComplete; // when I get an ACK >= to this, than I know thisis my round trip time.

    // Round Trip and retry timers
    uint32_t                tLastSnd;       // the last time we sent any packet
    uint32_t                tLastAck;       // the last time we got an Ack from the remote, or watch an RTO (Retransmit TimeOut)

    struct
    {
        unsigned            fSocketOpen         : 1;    // If true the socket is in use and has not been closed by the user
        unsigned            fGotFin             : 1;    // did I recieve the FIN or not
        unsigned            pad                 : 6;    // padding
    };

    uint8_t                 cZWndProbe;         // How many times we have retransmitted a zero window probe
    uint8_t                 cRTT;               // if cRTT is less than 10, RTT is not valid
    uint8_t                 cNeedAck;           // How many incoming data payloads come it that we need to ACK; We allow 1 outstanding ACK, but not 2
    uint8_t                 cTxUntilPause;      // how many sends until we pause sending waiting for an ACK
    uint8_t                 cSameAck;           // count of identical ACK coming in
    uint8_t                 cRetransmit;        // How many times we have retransmitted
    uint8_t                 pad2;               // padding

    int32_t                 RTTsa;          // See Jacobson's algorithms
    int32_t                 RTTsv;          // See Jacobson's algorithms
    uint32_t                tRTOCur;        // Current Round-Trip Timeout
    uint32_t                tRTO_SET;       // Karn's Round-Trip Set time
    uint32_t                tSndRTTStart;   // when we started measuring

#if 0
    // DEBUG VARIABLES, this can be removed.
    bool                fZWndProbe;
#endif
    
    // stuff not specifically taken from the RFC 793, but needed
    TCPSTATE                tcpState;
    uint16_t                cbLocalMSS;
    uint16_t                cbRemoteEffMSS;

    // this is really a stream to a stream
    // we copy this on the stack to get to the actual stream.
    // GetSMGRSize(((PMGR *) hPMGR)->cPages)    // this is the length of each individual indirect stream. same as cbRxSMGR and cbTxSMGR
    uint16_t                cbRxSMGR;       // first in the indirect stream; this is the actual length of the data stream, how much to alloca for the stream
    uint16_t                cbTxSMGR;       // second in the indirect stream; this is the actual length of the data stream, how much to alloca for the stream
    HPMGR                   hPMGR;
    union
    {
        SMGR    smgrRxTxBuff;
        uint8_t rgStreamData[cbMAXTCPSreamRecord];
    };
} TCPSOCKET;

#define SEQBOUNDARY             (0x80000000ul)  // Half way into out uint32_t linear range for a less than test.
#define cRTTINVALID             8               // how many round trip measurments before the RTT is accurate, 8 is what J&K says
#define cDupAckFastRetransmit   3               // you think this might be 2, but NetMon reports this on 3 dup acks
#define CNTPAUSESEND            3               // don't flood the network with unacked sends

// the data layout  is
// socket poll struct
// array of
//      socket
//      RxBuff
//      TxBuff
typedef struct SOCKETPOOL_T
{
    struct SOCKETPOOL_T *   pPoolNext;
    uint32_t                cSocket;
    uint16_t                cbRxBuff;
    uint16_t                cbTxBuff;
} SOCKETPOOL;


// we support a max of 32K datagram buffer (if a 64 byte page size is used)
// see the comment on TCP on socket buffer size calculations
#define cUDPRXPages 9
#define cbMAXUDPSreamRecord    GetSMGRSize(cUDPRXPages)
typedef struct UDPSOCKET_T
{
    SOCKET                  s;
    
    // nunber of bytes in the next datagram
    // datagrams can not be more than 65K so the uint16_t is good
    uint16_t                cbNextDataGram;

    // this is really a stream to a stream
    // we copy the actual datagram stream structure on the stack to get to the data
    // this puts a non-fixed size datagram stream in the page memory.
    uint16_t                cbRxSMGR;       // the size of the actual stream datastructure pointing to the datagram
    HPMGR                   hPMGR;          // the page manager in use
    union
    {
        SMGR    smgrRxBuff;                 // a stream to a stream to the datagram
        uint8_t rgStreamData[cbMAXUDPSreamRecord];  // fixed size, we know this is big enough to point to the in memory stream
    };

} UDPSOCKET;


// UDP internal fuctions
uint32_t ExUDPHeader(IPSTACK * pIpStack, bool fStartsInMachineOrder);
void UDPProcess(IPSTACK *   pIpStack);
HSOCKET UDPOpenWithSocket(const LLADP * pLLAdp, UDPSOCKET * pSocket, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus);
bool UDPRawSend(const LLADP * pLLAdp, IPSTACK * pIpStack, const void * pIPvXDest, uint16_t portDest, uint16_t portSrc, const uint8_t * pDatagram, uint32_t cbDatagram, bool fFreeDatagramImmediately, IPSTATUS * pStatus);
void UDPInitSockets(void);

// TCP internal functions
uint32_t ExTCPHeader(IPSTACK * pIpStack, bool fStartsInMachineOrder);
void TCPPeriodicTasks(void);

// calls used by the state machine and other places
void TCPStateMachine(IPSTACK *   pIpStack, TCPSOCKET *  pSocket, IPSTATUS * pStatus);
bool TCPTransmit(IPSTACK *  pIpStack, TCPSOCKET * pSocket, int32_t cbSend, int32_t cbOptions, bool fAck, uint32_t tCur, IPSTATUS * pStatus);
uint32_t TCPAddRxDataToSocket(TCPSOCKET * pSocket, uint32_t seqNbr, uint8_t * pb, uint32_t cb);
IPSTACK * TCPCreateSyn(TCPSOCKET * pSocket, uint32_t * pcbOptions, IPSTATUS * pStatus);
bool TCPIsInUse(const LLADP * pLLAdp, uint32_t portPair, const void * pIPvXDest);
uint32_t TCPGetSeqNumber(const LLADP * pLLAdp);
void TCPResetSocket(TCPSOCKET *  pSocket);
void TCPProcess(IPSTACK *  pIpStack);
bool TCPScaleSndIndexes(TCPSOCKET * pSocket, SMGR *  pSMGR);

#define TCPGetSocketEntrySize(_cbRxBuff, _cbTxBuff) ((sizeof(TCPSOCKET) + _cbRxBuff + _cbTxBuff + sizeof(uint32_t) - 1) & ~(sizeof(uint32_t) - 1))
#define TCPGetSocketPoolSize(_cSockets, _cbRxBuff, _cbTxBuff) ((uint32_t) ((_cSockets * TCPGetSocketEntrySize(_cbRxBuff, _cbTxBuff)) + sizeof(SOCKETPOOL)))
#define TCPState(_pSocket) ((_pSocket == NULL) ? (tcpInvalid) : (_pSocket->tcpState))
void TCPInitSockets(void);
const SOCKETPOOL * TCPAddSocketPool(uint32_t cbRxBuff, uint32_t cbTxBuff, void * pSocketPool, uint32_t cbSocketPool, IPSTATUS * pStatus);
HSOCKET TCPOpenWithSocket(const LLADP * pLLAdp, TCPSOCKET * pSocket, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus);
TCPSOCKET * TCPInitSocket(const LLADP * pLLAdp, TCPSOCKET * pSocketOpen, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus);
uint16_t GetEphemeralPort(FFPT * pFFPT, uint16_t * pNextEphemeralPort);

// the actively listening TCP sockets
extern FFPT  g_ffptActiveTCPSockets;

#endif // _TRANSPORT_LAYER_H_
