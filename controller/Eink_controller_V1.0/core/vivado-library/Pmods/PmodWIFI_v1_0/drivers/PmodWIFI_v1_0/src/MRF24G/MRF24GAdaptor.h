/************************************************************************/
/*                                                                      */
/*	MRF24GAdaptor.h This implements a Nework adaptor                    */
/*	for the MRF24WG0MA                                                  */
/*                                                                      */
/************************************************************************/
/*	Author: 	Keith Vogel                                             */
/*	Copyright 2013, Digilent Inc.                                       */
/************************************************************************/
/* 
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
/*	A WiFi Network adaptor using the Microchip Universal Driver         */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	5/31/2013(KeithV): Created                                          */
/*                                                                      */
/************************************************************************/


#ifndef MRF24GADAPTOR_H
#define	MRF24GADAPTOR_H

#ifdef	__cplusplus
extern "C" {
#endif

#include "../DEIPcK/utility/deIP.h"
#include "./utility/ud_inc/shared/wf_universal_driver.h"

// there are a lot of MRF24 Universal driver errors, here are some of the error masks
// for each of the various sections
#define UDMask      0x00001000
#define InitMask    0x00002000
#define CFMask      0x00003000
#define CLMask      0x00004000
#define DDMask      0x00005000
#define SCMask      0x00006000
#define EAPMask     0x00007000
#define WPSMask     0x00008000
#define P2PMask     0x00009000
#define WFDMask     0x0000A000

// 00000001 -> 0000FFFF; Adaptor status; specific to adaptor



// 10000001 -> 1000FFFF; Adaptor errors; specific to adaptor

#define WFNbrAllocFails 10

#define MRF24G_NWA_VERSION          0x01000101
#define MRF24G_NWA_MTU_RX_FRAME     1536
#define MRF24G_NWA_MTU_RX           1500
#define MRF24G_NWA_MIN_TX_MTU       TCP_EMTU_S

typedef struct WFMRF_T
{
//    bool (* IsInitialized)(IPSTATUS * pStatus);
//    bool (* Connect)(const uint8_t * szSSID, const void * pSecurityPkt, bool fPICKeyCalc, IPSTATUS * pStatus);
//    void (* Disconnect)(void);
//    bool (* StartScan)(t_scanMode filter, IPSTATUS * pStatus);
//    bool (* IsScanDone)(int32_t * pcAP);
//    bool (* GetScanResult)(int32_t index, t_scanResult *pScanResult);

    void (* ConnectionStateGet)(uint8_t *p_state);

    void (* RegionalDomainSet)(uint8_t regionalDomain);
    void (* SsidSet)(uint8_t *p_ssid,  uint8_t ssidLength);
    void (* NetworkTypeSet)(uint8_t networkType);
    void (* ChannelListSet)(uint8_t *p_channelList, uint8_t numChannels);
    void (* ReconnectModeSet)(uint8_t retryCount, uint8_t deauthAction, uint8_t beaconTimeout, uint8_t beaconTimeoutAction);

    // WiFi security functions
    //------------------------
    void (* SecurityOpenSet)(void);
    void (* SecurityWepSet)(t_wepContext *p_context);
    void (* SecurityWpaSet)(t_wpaContext *p_context);

    // Power-save mode (PS-Poll)
    //--------------------------
    void (* PsPollEnable)(t_psPollContext *p_context);
    void (* PsPollDisable)(void);
    void (* Hibernate)(void);
    void (* PowerStateGet)(uint8_t *p_powerState);


    // Maximum Tx power functions
    //---------------------------
    void (* TxPowerFactoryMaxGet)(uint8_t *p_maxTPower);
    void (* TxPowerMaxSet)(uint8_t maxTxPower);

    // WiFi status functions
    //----------------------
    void (* DeviceInfoGet)(t_deviceInfo *p_deviceInfo);
    void (* MacStatsGet)(t_macStats *p_stats);

    // data tx functions
    //------------------
    bool (* TxPacketAllocate)(uint16_t bytesNeeded);
    void (* TxPacketCopy)(uint8_t *p_buf, uint16_t length);
    void (* TxPacketTransmit)(uint16_t packetSize);

    // data rx functions
    //------------------
    void (* ProcessRxPacket)(void);
    uint16_t (* RxPacketLengthGet)(void);
    void (* RxPacketCopy)(uint8_t *p_buf, uint16_t len);
    void (* RxPacketDeallocate)(void);

    // Miscellaneous functions
    //------------------------
    void (* MacAddressSet)(uint8_t *p_macAddress);
    void (* MacAddressGet)(uint8_t *p_macAddress);

    // Advanced functions.  These are not typically needed because the MRF24WG
    // defaults suffice for most applications.
    //------------------------------------------------------------------------
    void (* ScanContextSet)(t_scanContext *p_context);
    void (* AdhocContextSet)(t_adHocNetworkContext *p_context);
    void (* TxModeSet)(uint8_t mode);
    void (* BssidSet)(uint8_t *p_bssid);
    void (* RssiSet)(uint8_t rssi);
    void (* RtsThresholdSet)(uint16_t rstThreshold);
    void (* LinkDownThresholdSet)(uint8_t threshold);

    // multicast filter functions
#if defined(WF_USE_HARDWARE_MULTICAST_FILTER)
        void (* SetHwMultiCastFilter)(uint8_t multicastFilterId, uint8_t multicastAddress[WF_MAC_ADDRESS_LENGTH]);
#endif /* WF_USE_HARDWARE_MULTICAST_FILTER */

#if defined(WF_USE_SOFTWARE_MULTICAST_FILTER)
        void (* SwMulticastFilterSet)(t_swMulticastConfig *p_config);
#endif /* WF_USE_SOFTWARE_MULTICAST_FILTER */

#if defined(WF_USE_WPS_SECURITY)
        void (* SecurityWpsSet)(t_wpsContext *p_context);
        void (* WpsCredentialsGet)(t_wpsCredentials *p_cred);
#endif /* WF_USE_WPS_SECURITY */

#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
        void (* WpaConvPassphraseToKey)(t_wpaKeyInfo *p_keyInfo);
        void (* WpsKeyGenerate)(void);
#endif /* WF_USE_HOST_WPA_KEY_CALCULATION */

} WFMRF;

typedef struct WFMRFP_T
{
    FFPT                    ffptRead;
    FFPT                    ffptWrite;
    IPSTACK *               pIpStackBeingTx;
    IPSTATUS    volatile    initStatus;
    IPSTATUS    volatile    connectionStatus;
    int32_t     volatile    cScanResults;
    bool        volatile    fMRFBusy;      // scan, key gen, connect
    uint8_t     volatile    lastEventType;
    uint32_t    volatile    lastEventData;
} WFMRFP;

typedef struct WFMRFD_T
{
    NWADP   adpMRF24G;
    NWWF    wfMRF24G;
    WFMRF   funcMRF24G;
    WFMRFP  priv;
} WFMRFD;

void __attribute__((interrupt(),nomips16)) _WFInterrupt(void);
const NWADP * GetMRF24GAdaptor(MACADDR *pUseThisMac, HRRHEAP hAdpHeap, IPSTATUS * pStatus);
const NWWF *  GetMRF24WF(void);
const WFMRF * GetMRF24GFunc(void);

#ifdef	__cplusplus
}
#endif

#endif	/* MRF24GADAPTOR_H */

