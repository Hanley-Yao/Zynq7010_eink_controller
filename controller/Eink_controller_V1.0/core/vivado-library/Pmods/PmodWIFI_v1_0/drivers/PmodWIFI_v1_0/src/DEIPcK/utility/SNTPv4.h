/************************************************************************/
/*                                                                      */
/*	SNTPv4.c    Implements SNTPv4 RFC 4330 a strict subset              */
/*                  of NTPv4 RFC 5905                                   */
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
/*	SNTPv4 time server                                                  */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	10/17/2013(KeithV): Created                                         */
/*                                                                      */
/************************************************************************/
#ifndef _SNTPV4_H_
#define _SNTPV4_H_

#pragma pack(push,1)

#define NTPEPOCHOFFSET          0           // First day of NTP time Jan-1-1900
#define UNIXEPOCHOFFSET         2208988800  // First day of UNIX time Jan-1-1970
#define UTCEPOCHOFFSET          2272060800  // First day of UTC time Jan-1-1972
#define LAST20THCENTRYOFFSET    3155587200  // Last day of 20th century time DEC-31-1999; see RFC 5905 (no sure last sec, or begin of last day)
#define NTPERA1OFFSET           63104       // First day of NTP Era 1 time Feb-8-2036; uint32_t wrap; see RFC 5905

#define ntpModeReserved         0
#define ntpModeSymActive        1
#define ntpModeSymPassive       2
#define ntpModeClient           3
#define ntpModeServer           4
#define ntpModeBroadcast        5
#define ntpModeNTPControl       6
#define ntpModePrivate          7

#define ntpLiNoWarning          0
#define ntpLiLastMin61Sec       1
#define ntpLiLastMin59Sec       2
#define ntpLiUnknown            3

#define ntpStratumKissODeath            0
#define ntpStratumPrimaryServer         1
#define ntpStratumSecondaryServerStart  2
#define ntpStratumSecondaryServerEnd    15
#define ntpStratumUnsynchronized        16

// clock sources found as 4 byte chars in the Ref ID field
#define ntpClockSrcGOES     "GOES"  // Geosynchronous Orbit Environment Satellite
#define ntpClockSrcGPS      "GPS"   // Global Position System
#define ntpClockSrcGAL      "GAL"   // Galileo Positioning System
#define ntpClockSrcPPS      "PPS"   // Generic pulse-per-second
#define ntpClockSrcIRIG     "IRIG"  // Inter-Range Instrumentation Group
#define ntpClockSrcWWVB     "WWVB"  // LF Radio WWVB Ft. Collins, CO 60 kHz
#define ntpClockSrcDCF      "DCF"   // LF Radio DCF77 Mainflingen, DE 77.5 kHz
#define ntpClockSrcHBG      "HBG"   // LF Radio HBG Prangins, HB 75 kHz
#define ntpClockSrcMSF      "MSF"   // LF Radio MSF Anthorn, UK 60 kHz
#define ntpClockSrcJJY      "JJY"   // LF Radio JJY Fukushima, JP 40 kHz, Saga, JP 60 kHz
#define ntpClockSrcLORC     "LORC"  // MF Radio LORAN C station, 100 kHz
#define ntpClockSrcTDF      "TDF"   // MF Radio Allouis, FR 162 kHz
#define ntpClockSrcCHU      "CHU"   // HF Radio CHU Ottawa, Ontario
#define ntpClockSrcWWV      "WWV"   // HF Radio WWV Ft. Collins, CO
#define ntpClockSrcWWVH     "WWVH"  // HF Radio WWVH Kauai, HI
#define ntpClockSrcNIST     "NIST"  // NIST telephone modem
#define ntpClockSrcACTS     "ACTS"  // NIST telephone modem
#define ntpClockSrcUSNO     "USNO"  // USNO telephone modem
#define ntpClockSrcPTB      "PTB"   // European telephone modem

// if the stratum == ntpStratumKissODeath, these codes can be found as 4 byte char in the Ref ID
#define ntpKodACST          "ACST"  // The association belongs to a unicast server.
#define ntpKodAUTH          "AUTH"  // Server authentication failed.
#define ntpKodAUTO          "AUTO"  // Autokey sequence failed.
#define ntpKodBCST          "BCST"  // The association belongs to a broadcast server.
#define ntpKodCRYP          "CRYP"  // Cryptographic authentication or identification failed.
#define ntpKodDENY          "DENY"  // Access denied by remote server.
#define ntpKodDROP          "DROP"  // Lost peer in symmetric mode.
#define ntpKodRSTR          "RSTR"  // Access denied due to local policy.
#define ntpKodINIT          "INIT"  // The association has not yet synchronized for the first time.
#define ntpKodMCST          "MCST"  // The association belongs to a dynamically discovered server.
#define ntpKodNKEY          "NKEY"  // No key found. Either the key was never installed or is not trusted.
#define ntpKodRATE          "RATE"  // Rate exceeded. The server has temporarily denied access because the client exceeded the rate threshold.
#define ntpKodRMOT          "RMOT"  // Alteration of association from a remote host running ntpdc.
#define ntpKodSTEP          "STEP"  // A step change in system time has occurred, but the association has not yet resynchronized.

typedef struct NTPV4HDRTIME_T
{
    uint32_t    cSeconds;
    uint32_t    secFraction;
} NTPV4HDRTIME;                 // headers only use the 64 bit form

typedef struct NTPV4_T
{
    union
    {
        uint8_t         flags;
        struct
        {
            unsigned    mode    : 3;
            unsigned    vn      : 3;
            unsigned    li      : 2;
        };
    };
    uint8_t             stratum;
    uint8_t             poll;
    int8_t              precision;
    int32_t             rootDelay;
    uint32_t            rootDispersion;
    union
    {
        uint8_t         rgchRefId[4];
        IPv4            ipSynSource;
    };
    NTPV4HDRTIME        refTimeStamp;
    NTPV4HDRTIME        orgTimeStamp;
    NTPV4HDRTIME        recTimeStamp;
    NTPV4HDRTIME        transmitTimeStamp;
//  uint32_t            Extension[];                // optional
//  uint32_t            keyId;                      // optional
//  uint128_t           messageDigest;              // optional
} NTPV4;

// taken from RFC 5905
#define ntpPORT         123     // NTP port number
#define ntpVERSION      4       // NTP version number
// #define ntpTOLERANCE 15e-6   // frequency tolerance PHI (s/s)
#define ntpMINPOLL      4       // minimum poll exponent (16 s)
#define ntpMAXPOLL      17      // maximum poll exponent (36 h)
#define ntpMAXDISP      16      // maximum dispersion (16 s)
// #define ntpMINDISP   .005    // minimum dispersion increment (s)
#define ntpMAXDIST      1       // distance threshold (1 s)
#define ntpMAXSTRAT     16      // maximum stratum number

// redef of values more approprate for coding
#define ntpMINPOLLSEC   16      // minimum poll in sec (16 s)
#define ntpMAXPOLLSEC   129600  // maximum poll in sec (36 h)
#define ntpMINDISPMSEC  5       // minimum dispersion increment in msec

#define ntpPOLLSEC      1800    // the poll rate we use (every half hour)
#define ntpACQUIRESEC   30      // the poll rate we use if we are still trying to acquire the initial time
//#define ntpPOLLSEC      30    // the poll rate we use (every half hour)

#define ntpDefaultServerList {(uint8_t const * const) "0.us.pool.ntp.org", (uint8_t const * const) "1.us.pool.ntp.org", (uint8_t const * const) "2.us.pool.ntp.org", (uint8_t const * const) "3.us.pool.ntp.org"}

#pragma pack(pop)

typedef enum
{
    sntpUninitialized,
    sntpResolveServerName,
    sntpWaitResponse,
    sntpStartWait,
    sntpWait,
} SNTPSTATE;


typedef struct NTPMEM_T
{
    SNTPSTATE               sntpState;
    uint8_t const * const *  ppNTPServers;
    uint32_t                iServerNext;
    uint16_t                cNTPServers;
    uint16_t                cAttempt;
    uint32_t                tStart;
    NTPV4                   ntpv4Request;
    NTPV4                   ntpv4Response;
    uint32_t                tCorrection;
    IPSTACK                 ntpIpStack;
    uint8_t                 rgbIpStackExBuff[IPStackEntrySize-sizeof(IPSTACK)];
    UDPSOCKET               socket;
} NTPMEM;

#define SNTPv4MemSize  (sizeof(NTPMEM))

void SNTPPeriodicTasks(void);

#endif // _SNTPV4_H_