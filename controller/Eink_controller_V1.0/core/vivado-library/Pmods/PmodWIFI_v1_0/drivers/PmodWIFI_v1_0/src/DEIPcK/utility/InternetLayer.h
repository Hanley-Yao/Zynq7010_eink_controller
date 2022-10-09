/************************************************************************/
/*																		*/
/*	InternetLayer.h This is implementation to the Internet Layer        */
/*                  also known as the IP Layer                          */
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
/*	Internet Layer implementation                 				        */
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	7/3/2012(KeithV): Created											*/
/*																		*/
/************************************************************************/
#ifndef _INTERNET_LAYER_H_
#define _INTERNET_LAYER_H_

#define TCP_EMTU_S          576     // RFC 791
#define TIME_TO_LIVE        0x80    // How long an IP packet is to survive in the internet

// RFC 790 Assigned Numbers, IP protocol numbers
#define ippnNone                        0 
#define ippnICMP                        1
#define ippnUnassigned2                 2 
#define ippnGateway2Gateway             3 
#define ippnCMCCGatewayMM               4 
#define ippnST                          5 
#define ippnTCP                         6 
#define ippnUCL                         7 
#define ippnUnassigned8                 8 
#define ippnSecure                      9 
#define ippnBBNRCCMon                   10 
#define ippnNVP                         11 
#define ippnPUP                         12 
#define ippnPluribus                    13 
#define ippnTelenet                     14 
#define ippnXNET                        15 
#define ippnChaos                       16 
#define ippnUDP                         17 
#define ippnMultiplexing                18 
#define ippnDCN                         19 
#define ippnTAC                         20 
#define ippnUnassigned21To62            21
#define ippnAnyLocalNetwork             63 
#define ippnSATNETEXPAK                 64 
#define ippnMITSubnetSupport            65
#define ippnUnassigned66To68            66
#define ippnSATNETMon                   69
#define ippnUnassigned70                70
#define ippnInternetPacketCoreUtility   71 
#define ippnUnassigned72To75            72
#define ippnBackroomSATNETM             76
#define ippnUnassigned77                77
#define ippnWIDEBANDMon                 78
#define ippnWIDEBANDEXPAK               79
#define ippnUnassigned80To254           80
#define ippnReserved255                 255

// RFC 791, IP Header Options definitions
#define ipdOptClassControl          0
#define ipdOptClassDebug            2

// all options are of the control class except the Timestamp
// see RFC 791
#define ipdOptNbrEndOfOptionList    0       // no more bytes
#define ipdOptNbrNoOperation        1       // no more bytes
#define ipdOptNbrSecurity           2       // length is 11 bytes, header inclusive
#define ipdOptNbrLooseSrcRouting    3       // var length
#define ipdOptNbrInternetTimestamp  4       // var length, class 2
#define ipdOptNbrUnassignedA        5
#define ipdOptNbrUnassignedB        6
#define ipdOptNbrRecordRoute        7       // var length
#define ipdOptNbrStreamID           8       // 4 bytes, header inclusive
#define ipdOptNbrStrictSrcRouting   9       // var length

#pragma pack(push,1)

typedef struct IPDOPT_T
{
    // the first byte may be the only thing relevent in the options.
    union
    {
        uint8_t         option;
        struct
        {
            unsigned    optionNbr               : 5;
            unsigned    classT                  : 2;
            unsigned    fCopiedToAllFragments   : 1;
        };
    };

    // but we know if options are present the header will have
    // at least 32 bits total, so we can specify the length
    // even if not used
    uint8_t     cbOptions;      // this is inclusive of the opitons header (cbData + 2)

    // variable length data
    // because if options are present the IP header will be at least padded
    // out 32 bits, we make the array 2 bytes long so sizeof(IPDOPT)
    // will work out to 32 bits. However, if cbOptions is longer than
    // 4 bytes (2 + 2 in header), we will just over-reference the array 
    // to the actual length of the options.
    uint8_t     opitonData[2];
} IPDOPT;

#if !defined(DONOTDEFINEIPV4)
// if the network field is zero, it means the local network
typedef struct IPv4_T
{
    union
    {
        uint8_t     u8[4];
        uint16_t    u16[2]; 
        uint32_t    u32;
        struct
        {
            unsigned    zero        : 1;
            unsigned    network     : 7;
            unsigned    local       : 24; 
        } classA;
        struct
        {
            unsigned    oneZero     : 2;
            unsigned    network     : 14;
            unsigned    local       : 16;  
        } classB;
        struct
        {
            unsigned    oneOneZero  : 3;    // 1-1-1 would be extended addressing.
            unsigned    network     : 21;
            unsigned    local       : 8;  
        } classC;
    };
} IPv4;
#endif

typedef struct IPv6_T
{
    union
    {
       uint8_t         u8[16];
       uint16_t        u16[8];
       uint32_t        u32[4];
    };
} IPv6;

typedef union IPv4or6_T
{
    IPv4    ipv4;
    IPv6    ipv6;
} IPv4or6;

// RFC 791
typedef struct IPv4HDR_T
{
    struct
    {
        unsigned    cdwHeader           : 4;
        unsigned    version             : 4;
    };
    TOS             tos;
    uint16_t        cbTotal;
    uint16_t        ident;              // used for framentation reassembly
    union
    {
        uint16_t        u16;            // TODO: check that this is the right order or if we need to exchange!!!
        struct
        {
            unsigned    fragOffset      : 13;   // this is a particularly tricky one
            unsigned    mf              : 1;
            unsigned    df              : 1;
            unsigned    pad1            : 1;
        };
        struct
        {
            unsigned    frag8   : 8;
            unsigned    frag5   : 5;
            unsigned    pad3    : 3;
        };
    };
    uint8_t         timeToLive;
    IPPN            protocol;
    uint16_t        hdrChecksum;
    IPv4            ipSrc;
    IPv4            ipDest;         
} IPv4HDR;

typedef struct IPv6HDR_T
{
    struct
    {
        unsigned    flow        : 20; 
        TOS         tos;
        unsigned    version     : 4;
    };
    uint16_t        cbPayload;
    IPPN            protocol;
    uint8_t         hopLimit;
    IPv6            ipSrc;
    IPv6            ipDest;         
} IPv6HDR;

#pragma pack(pop)

int32_t ExILIPv4Header(void * pv, uint32_t cb, bool fStartsInMachineOrder);
void ILPeriodicTasks(void);
bool ILSend(IPSTACK * pIpStack, IPSTATUS * pStatus);

#endif // _INTERNET_LAYER_H_
