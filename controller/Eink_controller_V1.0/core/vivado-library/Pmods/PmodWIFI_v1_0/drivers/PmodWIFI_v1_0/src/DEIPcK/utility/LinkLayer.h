/************************************************************************/
/*                                                                      */
/*      LinkLayer.h The implementation of the IP linklayer              */
/*                  as specified by RFC 1122                            */
/*                                                                      */
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
/*      Code supporting the link layer                                  */
/*      See RFC 894, 1042 and 1122 for requrements                      */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	7/3/2012(KeithV): Created                                       */
/*                                                                      */
/************************************************************************/
#ifndef _LINK_LAYER_H_
#define _LINK_LAYER_H_

#define ARPSendCount        3                           // a guess; gives use 3 requests total (initial + retries)
#define ARPRetryTime        1000                        // RFC 1122, 1 second
#define ARPValidTime        60000                       // RFC 1122, 60 seconds
#define ARPExpiredTime      5000                        // No guidance... let just say an ARP will be expired for 5 seconds

#pragma pack(push,1)

typedef struct MACADDR_T
{
    union
    {
        uint8_t     u8[6];
        uint16_t    u16[3]; 
     };
} MACADDR;

//#define MACBROADCAST    ((MACADDR) {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF})    // RFC 894
//#define MACNONE         ((MACADDR) {0x00, 0x00, 0x00, 0x00, 0x00, 0x00})    // RFC 894
extern const MACADDR MACBROADCAST;
extern const MACADDR MACNONE;     

#define ethertypeNone               0x0000
#define ethertypeUniversalPacket    0x0200
#define ethertypeIPv4               0x0800
#define ethertypeARP                0x0806
#define ethertypeWOL                0x0842
#define ethertypeSYN3               0x1337
#define ethertypeTRILL              0x22F3
#define ethertypeDECnet4            0x6003
#define ethertypeRARP               0x8035
#define ethertypeAppleTalk          0x809B
#define ethertypeAARP               0x80F3
#define ethertypeVLAN               0x8100
#define ethertypeIPX                0x8137
#define ethertypeNovell             0x8138
#define ethertypeSNMP               0x814C
#define ethertypeQNX                0x8204
#define ethertypeIPv6               0x86DD
#define ethertypeMacControl         0x8808
#define ethertypeSlowProtocol       0x8809
#define ethertypeCobraNet           0x8819
#define ethertypeMPLSunicast        0x8847
#define ethertypeMPLSmulticast      0x8848
#define ethertypePPPoEdiscover      0x8863
#define ethertypePPPoEsession       0x8864
#define ethertypeNLBheartbeat       0x886F
#define ethertypeJumboFrame         0x8870
#define ethertypeHomePlugMME        0x887B
#define ethertypeEAPoverLAN         0x888E
#define ethertypePROFNET            0x8892
#define ethertypeHyperSCSI          0x889A
#define ethertypeATA                0x88A2
#define ethertypeEtherCAT           0x88A4
#define ethertypeProviderBridging   0x88A8
#define ethertypePowerlink          0x88AB
#define ethertypeLLDP               0x88CC
#define ethertypeSercos3            0x88CD
#define ethertypeCircuitEmulation   0x88D8
#define ethertypeHomePlugAVMME      0x88E1
#define ethertypeMediaRedundancy    0x88E3
#define ethertypeMacSecurity        0x88E5
#define ethertypePrecisionTime      0x88F7
#define ethertypeCFM                0x8902
#define ethertypeFibreChannel       0x8906
#define ethertypeFCoEinit           0x8914
#define ethertypeConfitTest         0x9000
#define ethertypeQinQ               0x9100
#define ethertypeLLT                0xCAFE

// is this an IEEE802 frame
#define IsIEEE802(a)    (((uint16_t) a) <= 1500)    // RFC 1122

typedef struct ETHERNETII_FRAME_T
{
//  uint8_t     preamble[7];        // 7 bytes of 0x55, Adaptor must provide
//  uint8_t     startOfFrame;       // 1 byte of 0xD5,  Adaptor must provide
    MACADDR     macDest;            // destination address
    MACADDR     macSrc;             // source address
//  uint32_t    tag;                // optional 802.1Q tag, not supported, we MUST discard etherTypes of ethertypeVLAN
    union
    {
        ETHERTYPE   etherType;      // see ETHERTYPEs, must have a value greater than 1536 (0x600), and is an ethernet frame II
        uint16_t    length;         // if  IsIEEE802(length), ie, etherType <= 1500 (0x5DC), this is an IEEE802 frame
    };
//  uint8_t     payload[];          // 46 (no .Q1 tag) - 1500 bytes; RFC 894, usually an IP, ICMP or ARP datagram
//  uint32_t    crc_32;             // The CRC-32 is at the end of the payload, so that has to be handled outside of this struct
//  uint8_t     interFrameGap[12];  // needs to be all zeros, Adaptor must provide
} ETHERNETII_FRAME;                 // RFC 894 and RFC 1122; also known as the MAC header

// note CRC-32 => divisor 1 0000 0100 1100 0001 0001 1101 1011 0111 => 0x1 04C1 1DB7
// It is a requirement of the Adaptor to add all padding and calcuate the CRC.

// as defined by RFC 1042 For IEEE 802 etherenet frame
typedef struct LLC802_T
{
    uint8_t     dsap;               // we only support 0xAA or 0xAB (170d or 171d); RFC 1042
    uint8_t     ssap;               // we only support 0xAA or 0xAB (170d or 171d); RFC 1042
    uint8_t     control;            // we only support control type 3; RFC 1042
} LLC802;                           // IEEE 802.2; RFC 1042

typedef struct
{
    uint8_t     orgCode[3];             // we only support all zeros; RFC 1042
    ETHERTYPE   etherType;              // see ETHERTYPEs 
} SNAP802;                              // IEEE 802.2; RFC 1042

typedef struct ETHERNET_802_FRAME_T
{
    ETHERNETII_FRAME    macHdr;
    LLC802              llc; 
    SNAP802             snap; 
//  uint8_t             payload[];          // 46 (no .Q1 tag) - 1500 bytes; RFC 894, usually an IP, ICMP or ARP datagram
//  uint32_t            crc_32;             // The CRC-32 is at the end of the payload, so that has to be handled outside of this struct
//  uint8_t             interFrameGap[12];  // needs to be all zeros, Adaptor must provide
} ETHERNET_802_FRAME;

#define ARPOP   uint8_t
#define arpopRequest    1
#define arpopReply      2

#define hwtypeEthernet  1

// ARP IPv4 payload to an ethernet frame; etherType == ethertypeIPv4
typedef struct ARPIPv4_T
{
    uint16_t    hwType;             // hardware type, We only support Type 1 (hwtypeEthernet); RFC 1122
    ETHERTYPE   etherType;          // protocol type, shared with EtherType, this is ethertypeIPv4
    uint8_t     cbhType;            // for hardware types of MAC, this is 6
    uint8_t     cbpType;            // for protocol IPv4 = 4;
    uint8_t     operationPad;       // so we don't have to reverse this, this value is either 1 or 2, so the high byte is always zero
    ARPOP       operation;          // 1 = request, 2 = reply; arpopRequest / arpopReply
    MACADDR     macSrc;             // hardware sender
    IPv4        ipv4Src;            // senders IPv4 address
    MACADDR     macDest;            // hardware intended reciever
    IPv4        ipv4Dest;           // reciever IPv4 address
} ARPIPv4;

#define  ARPSTATE uint16_t
#define arpStateUnUsed          0
#define arpStatePending         20
#define arpStateValid           30
#define arpStateExpired         40
#define arpStateFailed          1000

// make sure the size of this struct is a mult of 4
typedef struct LLARP_T
{
    ARPSTATE                arpState;       // this is Mult 16
    uint16_t                cRetriesLeft;   // this is Mult 32      
    uint32_t                tStamp;
    MACADDR                 mac;
    IPv4or6                 ip;
} LLARP;

#pragma pack(pop)

// make sure the size of this struct is a mult of 4; keep it outside of pack(push,1)
typedef struct LLADP_T
{
    struct LLADP_T *        pLLAdpNext;     // next in the adaptor pool, this must be first in the struct
    const struct NWADP_T *  pNwAdp;         // this will fault if not DWORD aligned
    
    uint8_t                 cLLArp;         // how many ARP entries we have
    uint8_t                 dhcpState;      // dns state
    uint16_t                pad;
 
    // the following is used for the ARP tables
    LLARP *                 arLLArp;
    IPSTACK                 ipStack;            // a presetup stack
    ETHERNETII_FRAME        broadcastFrameII;   // a presetup broadcast frame, in NETWORK ORDER
    ARPIPv4                 arpIPv4;            // reusable Arp packet

    struct DHCPMEM_T *      pDHCPMem;
    struct DNSMEM_T *       pDNSMem;
    struct NTPMEM_T *       pNTPMem;        // time service

    // some network paramaters
    IPv4or6                 ipMy;
    IPv4or6                 submask;
    IPv4or6                 ipGateway;
} LLADP;


void LLInitAdaptorList(void);
int32_t ExEthernetFrameHeader(void * pv, uint32_t cb, bool fStartsInMachineOrder);
int32_t ExARPDatagram(void * pv, uint32_t cb, bool fStartsInMachineOrder);
void LLPeriodicTasks(void);
bool LLUpdateARPEntry(const LLADP * pLLAdp, const void * pIP, const MACADDR * pMac);
uint32_t LLGetMTUR(const LLADP * pLLAdp);
uint32_t LLGetMTUS(const LLADP * pLLAdp);
bool LLSend(IPSTACK * pIpStack, IPSTATUS * pStatus);

extern FFPT ffptAdaptors;

#endif // _LINK_LAYER_H_