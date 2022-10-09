/************************************************************************/
/*																		*/
/*	ICMP.h  This defined ICMP messages that are implemented             */
/*          as part of the Internet Layer                               */
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
/*	ICPM Internet Layer implementation             				        */
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	8/14/2012(KeithV): Created	                            			*/
/*																		*/
/************************************************************************/
#ifndef _ICMP_H_
#define _ICMP_H_

#pragma pack(push,1)

typedef uint8_t ICMPTYPE;

#define icmpTypeEchoReply               0
#define icmpTypeDestinationUnreachable  3    
#define icmpTypeSourceQuench            4   
#define icmpTypeRedirect                5    
#define icmpTypeEcho                    8    
#define icmpTypeTimeExceeded            11   
#define icmpTypeParameterProblem        12   
#define icmpTypeTimestamp               13    
#define icmpTypeTimestampReply          14   
#define icmpTypeInformationRequest      15   
#define icmpTypeInformationReply        16  

typedef uint8_t ICMPCODE;

#define icmpCode0EchoReply                          0

#define icmpCode3NetUnreachable                     0
#define icmpCode3HostUnreachable                    1
#define icmpCode3ProtocolUnreachable                2
#define icmpCode3PortUnreachable                    3
#define icmpCode3FragmentationNeeded                4
#define icmpCode3SourceRouteFailed                  5

#define icmpCode4QuenchMessage                      0

#define icmpCode5RedirectNetworkDatagrams           0
#define icmpCode5RedirectHostDatagrams              1 
#define icmpCode5RedirectNetworkTOSDatagrams        2
#define icmpCode5RedirectHostTOSDatagrams           3

#define icmpCode8EchoRequest                        0

#define icmpCode11TimeToLiveExceed                  0
#define icmpCode11FragmentReassemblyTimeExceeded    1

#define icmpCode12PointerIndicatesError             0

#define icmpCode13TimestampMessage                  0
#define icmpCode14TimestampReply                    0

#define icmpCode15InfoRequest                       0
#define icmpCode16InfoReply                         0


typedef struct ICMPHDR_T
{
    ICMPTYPE    icmpType;
    ICMPCODE    code;
    uint16_t    checksum;
} ICMPHDR;

typedef struct ICMPING_T
{
    ICMPHDR     hdr;
    uint16_t    identifier;
    uint16_t    sequence;
    uint8_t     rgbData[];
} ICMPING;                      // type 0 & 8

typedef ICMPING ICMPT0;

typedef struct ICMPT3_T
{
    ICMPHDR     hdr;
    uint32_t    unused;
    IPv4HDR     ipHdr;
    uint8_t     rgbData[64];
} ICMPT3;

typedef ICMPT3 ICMPT4;

typedef struct ICMPT5_T
{
    ICMPHDR     hdr;
    IPv4        ipGatewayAddress;
    IPv4HDR     ipHdr;
    uint8_t     rgbData[64];
} ICMPT5;

typedef ICMPING ICMPT8;

typedef ICMPT3 ICMPT11;

typedef struct ICMPT12_T
{
    ICMPHDR     hdr;
    uint8_t     pointer;
    uint8_t     unused[3];
    IPv4HDR     ipHdr;
    uint8_t     rgbData[64];
} ICMPT12;

typedef struct ICMPT13_T
{
    ICMPHDR     hdr;
    uint16_t    identifier;
    uint16_t    sequence;
    uint32_t    orgTimestamp;
    uint32_t    RxTimestamp;
    uint32_t    TxTimestamp;
} ICMPT13;

typedef ICMPT13 ICMPT14;

typedef struct ICMPT15_T
{
    ICMPHDR     hdr;
    uint16_t    identifier;
    uint16_t    sequence;
} ICMPT15;                      // type 0 & 8

typedef ICMPT15 ICMPT16;

#pragma pack(pop)

// ICMP calls in the Internet Layer
uint32_t ExICMP(void * pv, uint32_t cb, bool fStartsInMachineOrder);
void ICMPv4Process(IPSTACK * pIpStack);
bool ICMPv4Send(const LLADP * pLLAdp, IPv4 * pIPv4Dest, void * pICMPDgm, uint32_t cbICMPDgm, IPSTATUS * pStatus);

#endif //_ICMP_H_