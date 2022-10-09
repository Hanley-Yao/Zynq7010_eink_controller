/************************************************************************/
/*																		*/
/*	Adaptor.h       This is the interface to a Network Adaptor          */
/*                  or a device driver interface to the specific        */
/*					network hardware.                                 	*/
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
/*	Defines what an adaptor must support                 				*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	7/3/2012(KeithV): Created											*/
/*																		*/
/************************************************************************/
#ifndef _NETWORK_ADAPTOR_H_
#define _NETWORK_ADAPTOR_H_

// NetWork ADaPtor
// TBD: Does Init need a hardware specific struct to be passed down, like what register to enable the PHY?
typedef struct NWADP_T 
{
    uint32_t            version;
    bool                fIPv6;
    uint32_t            cbRxMTU_R;
    uint32_t            cbTxMTU_S;
    MACADDR             mac;
    HRRHEAP             hAdpHeap;
    void                (* PeriodicTask)(void);                                 // Task to run, can be NULL if not needed
    bool                (* IsLinked)(IPSTATUS * pStatus);                       // returns true if the Adaptor is linked to the physical network
    bool                (* IsReadyToSend)(IPSTATUS * pStatus);                  // TODO: Never used: returns if the adaptor is ready to send something
    bool                (* Send)(IPSTACK * pIPStack, IPSTATUS * pStatus);       // returns if the send succeeded.
    IPSTACK *           (* Read)(IPSTATUS * pStatus);                           // Get input data, a no copy return of the buffer
    bool                (* Close)(void);                                        // Close the Adaptor.
} NWADP;

#define DEWF_MAX_SSID_LENGTH  32
#define DEWF_BSSID_LENGTH     6
#define DEWF_MAX_NUM_RATES    8
#define DEWF_SCAN_ALL         0xff
#define DEWF_MAX_PASS_PHRASE  64

#define WFSCANMODE uint32_t

typedef enum
{
    DEWF_INFRASTRUCTURE = 1,
    DEWF_ADHOC = 2
} NETWKTYPE;

typedef enum
{
    DEWF_ACTIVE_SCAN  = 1,
    DEWF_PASSIVE_SCAN = 2,
} WFSCAN;

typedef enum
{
    DEWF_SECURITY_OPEN                         = 0,
    DEWF_SECURITY_WEP_40                       = 1,
    DEWF_SECURITY_WEP_104                      = 2,
    DEWF_SECURITY_WPA_WITH_KEY                 = 3,
    DEWF_SECURITY_WPA_WITH_PASS_PHRASE         = 4,
    DEWF_SECURITY_WPA2_WITH_KEY                = 5,
    DEWF_SECURITY_WPA2_WITH_PASS_PHRASE        = 6,
    DEWF_SECURITY_WPA_AUTO_WITH_KEY            = 7,
    DEWF_SECURITY_WPA_AUTO_WITH_PASS_PHRASE    = 8,
    DEWF_SECURITY_WPS_PUSH_BUTTON              = 9,
    DEWF_SECURITY_WPS_PIN                      = 10,
    DEWF_MAX_SECURITY_TYPE                     = 10
} SECURITY;

#pragma pack(push,1) 

// WPA and WPA2 KEY, used for both
typedef struct
{
    uint8_t rgbKey[32];
} WPA2KEY;

typedef struct
{
    union
    {
        uint8_t rgbKey[5];
        int8_t  asciiKey[5];
    } key[4];
} WEP40KEY;

typedef struct
{
    union
    {
        uint8_t rgbKey[13];
        int8_t  asciiKey[13];
    } key[4];
} WEP104KEY;

#pragma pack(pop)

typedef struct
{
    uint8_t      bssid[DEWF_BSSID_LENGTH];    // Network BSSID value
    uint8_t      ssid[DEWF_MAX_SSID_LENGTH];  // Network SSID value

    /**
      Access point configuration
      <table>
        Bit 7       Bit 6       Bit 5       Bit 4       Bit 3       Bit 2       Bit 1       Bit 0
        -----       -----       -----       -----       -----       -----       -----       -----
        WPA2        WPA         Preamble    Privacy     Reserved    Reserved    Reserved    IE
      </table>

      <table>
      IE         1 if AP broadcasting one or more Information Elements, else 0
      Privacy    0 : AP is open (no security)
                 1: AP using security,  if neither WPA and WPA2 set then security is WEP.
      Preamble   0: AP transmitting with short preamble
                 1: AP transmitting with long preamble
      WPA        Only valid if Privacy is 1.
                   0: AP does not support WPA
                   1: AP supports WPA
      WPA2       Only valid if Privacy is 1.
                   0: AP does not support WPA2
                   1: AP supports WPA2
      </table>
      */
    uint8_t    apConfig;
    uint8_t    reserved;
    uint16_t   beaconPeriod; // Network beacon interval
    uint16_t   atimWindow; // Only valid if bssType = WF_INFRASTRUCTURE

    /*
      List of Network basic rates.  Each rate has the following format:

      Bit 7
        * 0: rate is not part of the basic rates set
        * 1: rate is part of the basic rates set

      Bits 6:0
        Multiple of 500kbps giving the supported rate.  For example, a value of 2
        (2 * 500kbps) indicates that 1mbps is a supported rate.  A value of 4 in
        this field indicates a 2mbps rate (4 * 500kbps).
      */
    uint8_t      basicRateSet[DEWF_MAX_NUM_RATES];
    uint8_t      rssi;                                  // Signal strength of received frame beacon or probe response
    uint8_t      cBasicRates;                           // Number of valid rates in basicRates
    uint8_t      dtimPeriod;                            // Part of TIM element
    uint8_t      bssType;                               // WF_INFRASTRUCTURE or WF_ADHOC
    uint8_t      channel;                               // Channel number
    uint8_t      ssidLen;                               // Number of valid characters in ssid
} SCANINFO;




typedef struct NWWF_T
{
    bool (* IsInitialized)(IPSTATUS * pStatus);
    bool (* Connect)(SECURITY security, const uint8_t * szSsid, const void * pvPkt, int iKey, bool fPICKeyCalc, IPSTATUS * pStatus);
    void (* Disconnect)(void);
    bool (* StartScan)(WFSCANMODE filter, IPSTATUS * pStatus);
    bool (* IsScanDone)(int32_t * pcAP);
    bool (* GetScanResult)(int32_t index, SCANINFO *pScanInfo);    
} NWWF;

#endif  // _NETWORK_ADAPTOR_H_