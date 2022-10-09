/************************************************************************/
/*                                                                      */
/*	DNS.h  This implements the DNS code per RFC 2131                    */
/*          as part of the Application Layer                            */
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
/*	Technecally DNS is implemented at the application layer             */
/*	and depends on UDP                                                  */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	4/11/2013(KeithV): Created                                          */
/*                                                                      */
/************************************************************************/

#ifndef DNS_H
#define	DNS_H

#ifdef	__cplusplus
extern "C" {
#endif

#define dnsWaitForRetry     4000        // in ms
#define DNSMINTRY           4           // the min number of DNS attempts
#define DNScLL              10          // how many labels to look at in a DNS name
#define DNSiInvalid         255         // the DNS index is invalid


// RFC 1035 2.3.4 & 4.2.1; MAX size of things
#define DNSMAXDOMANLABEL    63
#define DNSMAXDOMANNAME     255
#define DNSMAXUDPSIZE       512

// the first byte of a label in a DNS name.
// max lenght of a lable is 2^6 = 64 but by definition is only 63
// if top 2 bits set the 6 bits and the next byte is an offset
// from the begining of the datagram for the next label
#define DNSLBLOPCB          0b00
#define DNSLBLOPR1          0b01        // undefined
#define DNSLBLOPR2          0b10        // undefined
#define DNSLBLOPPTR         0b11
#define DNSLBLPTRMASK       0xC0

// DNS Header QR 1 bit field RFC 6195 2.1
#define DNSQRQUERY          0b0
#define DNSQRRESPONSE       0b1

// DNS Header OpCode 4 bit field RFC 6195 2.2
#define DNSOPQUERY          0x0
#define DNSOPIQUERY         0x1
#define DNSOPSTATUS         0x2
// 0x3 unassigned
#define DNSOPNOTIFY         0x4
#define DNSOPUPDATE         0x5
// 6-15 unassigned

// DNS Header 4 bit RCODE field RFC 6195 2.3
#define DNSRCODENoError     0x0
#define DNSRCODEFormErr     0x1
#define DNSRCODEServFail    0x2
#define DNSRCODENXDomain    0x3
#define DNSRCODENotImp      0x4
#define DNSRCODERefused     0x5
#define DNSRCODEYXDomain    0x6
#define DNSRCODEYXRRSet     0x7
#define DNSRCODENXRRSet     0x8
#define DNSRCODENotAuth     0x9
#define DNSRCODENotZone     0xA
// 0xB - 0xF unassigned    
// See RFC 2671, 2845, 2930 for extended RCODEs above 4 bits; not interesting here

// TYPES and QTYPES 16 bits RFC 1035 3.2.2
#define DNSTYPEA            1   // Host address IPv4
#define DNSTYPENS           2   // a Name Server
#define DNSTYPEMD           3   // Mail Destination (obsolete, use MX)
#define DNSTYPEMF           4   // Mail Forwarder (obsolete, use MX)
#define DNSTYPECNAME        5   // Canonical NAME for an alias
#define DNSTYPESOA          6   // Start Of zone fo Authority
#define DNSTYPEMB           7   // Experimental MailBox domain name
#define DNSTYPEMG           8   // Experimental Mail Group member
#define DNSTYPEMR           9   // Experimental Mail Rename Domain name
#define DNSTYPENULL         10  // Experimental NULL RR
#define DNSTYPEWKS          11  // Well Known Service description
#define DNSTYPEPTR          12  // domain name PonTeR
#define DNSTYPEHINFO        13  // Host INFOrmation
#define DNSTYPEMINFO        14  // Mailbox or Mail INFOrmation
#define DNSTYPEMX           15  // Mail eXchange
#define DNSTYPETXT          16  // TeXT string
#define DNSTYPEAAAA         28  // Host address IPv6

// these are only QTYPES..... Used only Queries RFC 1035 3.2.3
#define DNSQTYPEAXFR        252 // request to transfer an entire zone
#define DNSQTYPEMAILB       253 // request for mailbox-related records (MB, MG or MR)
#define DNSQTYPEMAILA       254 // request for mail agent RRS (Obsolete, use MX)
#define DNSQTYPEALL         255 // a request for everything you got

// CLASSES, and QCLASSES RFC 6195 3.2
// 0 is reserved
#define DNSCLASSIN          1   // The Internet
//#define DNSCLASSCS          2   // CSNET (obsolete, don't use); available
#define DNSCLASSCH          3   // CHAOS class
#define DNSCLASSHS          4   // Hesiod; S. Dyer, F. Hsu, "Hesiod", Project Athena Technical Plan - Name Service, April 1987, version 1.9.

// QCLASSES ONLY
#define DNSQCLASSNONE       254 // no class
#define DNSQCLASSANY        255 // Any Class

// these are DNS response records in the DNS Datagram
// you must keep these in order as I use them as indexes relative to DNSRRQD
#define DNSRRQD             1
#define DNSRRAN             2
#define DNSRRNS             3
#define DNSRRAR             4

// the trick is, if the ID has the high bit in the high byte set and the high bit in the low byte not set,
// it is machine order, otherwise it is in network order
#define DNSIsInMachineOrder(_pDNSDG)        ((_pDNSDG)->dnsHdr.Z == 1)
#define DNSSetToMachineOrder(_pDNSDG)       {((_pDNSDG)->dnsHdr.Z = 1);}
#define DNSToggleOrder(_pDNSDG)             {((_pDNSDG)->dnsHdr.Z ^= 1);}

// the order of RRs in a DNS message RFC 1035 4.1
// Header -- not reall an RR
// Question
// Answer
// Authority
// Additional

#pragma pack(push,1)

/*
 * we have to deal with the pointer type in machine order as it is 2 bytes vs 1, so the first byte will always have the 0xC0 bits set
typedef struct DNSLBL_T
{
        struct
        {
            unsigned    cb  : 6;
            unsigned    op  : 2;
        } len;                          // compiler bug, I must name it or it would let me have the flexible struct follow
    uint8_t stLabel[];
} DNSLBL;
*/
    
typedef struct DNSQRR_T
{
//    DNSLBL      NAME[];               // variable length, we must parse past it.
    uint16_t    TYPE;
    uint16_t    CLASS;
} DNSQRR;

typedef struct DNSRR_T
{
//    DNSLBL      NAME[];               // variable length, we must parse past it.
    uint16_t    TYPE;
    uint16_t    CLASS;
    uint32_t    TTL;
    uint16_t    RDLENGTH;
    uint8_t     RDATA[];
} DNSRR;

// RFC 1035 4.1.1
typedef struct DNSHDR_T
{
    uint16_t            ID;

    // very tricky ordering, we want this to all be in correct order, network order
    // if you are on a little endian machine, 16 bits will get swapped on 8 bit boundaries
    // so lets define this as 2 8 bit items so the order will be controlled byte by byte.
    // First bit is the lowest bit in the byte, so low to high in bit order.
    // this should work on both little and big endian machines without needing to swap
    struct {
        unsigned        RD      : 1;        // Recurive data requested
        unsigned        TC      : 1;        // Truncated data
        unsigned        AA      : 1;        // Authoritative Record
        unsigned        Opcode  : 4;        // Typically Query == 0
        unsigned        QR      : 1;        // Query == 0 , Response == 1
    };

    // keep this as a second and seperate 8 bit byte structure; so it is the higher byte
    struct {
        unsigned        RCODE   : 4;        // Return Code
        unsigned        CD      : 1;        // Checking Disabled
        unsigned        AD      : 1;        // Authenticated Data
        unsigned        Z       : 1;        // Zero; This is overloaded, if zero is not zero, it is in machine order
        unsigned        RA      : 1;        // Recursive query support available
    };
    
    uint16_t            QDCOUNT;            // question RRs
    uint16_t            ANCOUNT;            // answer RRs
    uint16_t            NSCOUNT;            // Name Server RRs  (Authority)
    uint16_t            ARCOUNT;            // Additional RRs
} DNSHDR;

typedef struct DNSDG_T
{
    DNSHDR      dnsHdr;
    uint8_t     rrRecords[];
} DNSDG;

#pragma pack(pop)

#define DNSSTATE            uint8_t
#define dnsUninit           0
#define dnsReady            1
#define dnsSend             2
#define dnsReadySend        3
#define dnsWaiting          4
#define dnsWaitTry          5
#define dnsRedirect         10

typedef struct DNSMEM_T
{
    DNSSTATE        dnsState;
    uint8_t         cTry;
    uint8_t         iDNSCur;
    uint8_t         iDNSWorks;
    uint8_t         cDhcpNS;
    uint8_t         dnsNSMax;
    uint16_t        cbDNSDG;
    uint32_t        tStart;
    uint32_t        tTimeout;
    const uint8_t * pchDomainName;
    uint32_t        cchDomainName;
    IPv4or6         ip;
    UDPSOCKET       socket;
    union
    {
        struct
        {
            DNSHDR          dnsHdr;
            uint8_t         rgbDNSData[DNSMAXUDPSIZE-sizeof(DNSHDR)];
        };
        DNSDG               dnsDG;
    };
    IPv4or6         dnsNS[];
} DNSMEM;

void DNSPeriodicTasks(void);

#ifdef	__cplusplus
}
#endif  // __cplusplus
#endif	// DNS_H

