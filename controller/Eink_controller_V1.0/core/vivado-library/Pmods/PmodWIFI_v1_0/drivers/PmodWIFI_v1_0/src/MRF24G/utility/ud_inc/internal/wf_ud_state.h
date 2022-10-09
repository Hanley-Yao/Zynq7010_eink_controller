/*******************************************************************************
 MRF24WG Universal Driver Error Checking

  Summary: This module contains error checking definitions

  Description: This module is an extension of wf_events.h, but specific to
               WiFi connection-related events
*******************************************************************************/

/* MRF24WG0M Universal Driver
*
* Copyright (c) 2012-2013, Microchip <www.microchip.com>
* Contact Microchip for the latest version.
*
* This program is free software; distributed under the terms of BSD
* license:
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
#include "../shared/wf_universal_driver.h"

#ifndef __WF_UD_STATE_H
#define __WF_UD_STATE_H

#ifdef __cplusplus
extern "C" {
#endif

//==============================================================================
//                                  CONSTANTS
//==============================================================================

#define DEFAULT_RETRY_COUNT         (3)
#define DEFAULT_SECURITY_TYPE       WF_SECURITY_OPEN
#define DEFAULT_NETWORK_TYPE        WF_NETWORK_TYPE_INFRASTRUCTURE

// bit masks for errorState field
#define INIT_INVALID                ((uint32_t)0x00000001)
#define CHANNEL_LIST_INVALID        ((uint32_t)0x00000002)
#define DOMAIN_INVALID              ((uint32_t)0x00000004)
#define SSID_INVALID                ((uint32_t)0x00000008)
#define RETRY_COUNT_INVALID         ((uint32_t)0x00000010)
#define SECURITY_TYPE_INVALID       ((uint32_t)0x00000020)
#define NETWORK_TYPE_INVALID        ((uint32_t)0x00000040)
#define NETWORK_CONFIG_INVALID      ((uint32_t)0x00000080)
#define SCAN_CONTEXT_INVALID        ((uint32_t)0x00000100)



typedef enum t_internalConnectionState
{
    CS_NOT_CONNECTED           = 0,
    CS_CONNECTION_IN_PROGRESS  = 1,
    CS_CONNECTED               = 2,
} t_internalConnectionState;

//==============================================================================
//                                  DATA TYPES
//==============================================================================
typedef struct udStateStruct
{
    uint32_t        errorState;    // bit mask
    uint8_t         connectionState;
    uint8_t         retryCount;
    bool            psPollEnabled;
    t_psPollContext psPollContext;
    
#if defined(WF_ERROR_CHECKING)
    uint8_t domain;
    uint8_t networkType;
    uint8_t securityType;
    uint8_t ssid[WF_MAX_SSID_LENGTH];
    uint8_t ssidLength;
    uint8_t channelList[WF_MAX_CHANNEL_LIST_LENGTH];
    uint8_t numChannels;
#endif

} t_udState;


//==============================================================================
//                                  GLOBALS
//==============================================================================
extern t_udState g_udState;  // only accessed via macros from external modules


//==============================================================================
//                                  MACROS
//==============================================================================

#define udGetDomain()                   g_udState.domain
#define UdGetNetworkType()              g_udState.networkType
#define UdSetRetryCount(c)              g_udState.retryCount = c
#define UdGetGetryCount()               g_udState.retryCount
#define UdSetConnectionState(s)         g_udState.connectionState = s
#define UdGetConnectionState()          g_udState.connectionState
#define UdGetSecurityType()             g_udState.securityType

//==============================================================================
//                                  ERROR BITMAP MACROS
//==============================================================================
#define UdSetInitInvalid()              g_udState.errorState |= INIT_INVALID
#define UdSetInitValid()                g_udState.errorState &= ~INIT_INVALID
#define UdIsInitValid()                 ((g_udState.errorState & INIT_INVALID) == 0)

#define UdSetDomainInvalid()            g_udState.errorState |= DOMAIN_INVALID
#define UdSetDomainValid()              g_udState.errorState &= ~DOMAIN_INVALID

#define UdSetChannelListInvalid()       g_udState.errorState |= CHANNEL_LIST_INVALID
#define UdSetChannelListValid()         g_udState.errorState &= ~CHANNEL_LIST_INVALID

#define UdSetSsidInvalid()              g_udState.errorState |= SSID_INVALID
#define UdSetSsidValid()                g_udState.errorState &= ~SSID_INVALID

#define UdSetSecurityInvalid()          g_udState.errorState |= SECURITY_TYPE_INVALID
#define UdSetSecurityValid()            g_udState.errorState &= ~SECURITY_TYPE_INVALID

#define UdSetNetworkTypeInvalid()       g_udState.errorState |= NETWORK_TYPE_INVALID
#define UdSetNetworkTypeValid()         g_udState.errorState &= ~NETWORK_TYPE_INVALID

#define UdSetNetworkConfigInvalid()     g_udState.errorState |= NETWORK_CONFIG_INVALID
#define UdSetNetworkConfigValid()       g_udState.errorState &= ~NETWORK_CONFIG_INVALID

#define UdSetScanContextInvalid()       g_udState.errorState |= SCAN_CONTEXT_INVALID
#define UdSetScanContextValid()         g_udState.errorState &= ~SCAN_CONTEXT_INVALID

//==============================================================================
//                                  FUNCTION PROTOTYPES
//==============================================================================

void  UdStateInit(void);
void  UdEnablePsPoll(t_psPollContext *p_context);
void  UdDisablePsPoll(void);
INLINE bool  UdisPsPollEnabled(void);

#if defined(WF_ERROR_CHECKING)
    uint32_t UdSetDomain(uint8_t domain);
    uint32_t UdSetChannelList(uint8_t *p_channelList, uint8_t numChannels);
    uint32_t UdSetSsid(uint8_t *p_ssid, uint8_t ssidLength);
    uint32_t UdSetNetworkType(uint8_t networkType);
    uint32_t UdSetSecurityOpen(void);
    uint32_t UdSetSecurityWep(t_wepContext *p_context);
    uint32_t UdSetSecurityWpa(t_wpaContext *p_context);
#if defined(WF_USE_WPS_SECURITY)
    uint32_t UdSetSecurityWps(t_wpsContext *p_context);
#endif
    uint32_t UdCheckConnectionConfig(void);
    uint32_t UdSetReconnectMode(uint8_t retryCount, uint8_t deauthAction, uint8_t beaconTimeout, uint8_t beaconTimeoutAction);
    uint32_t UdSetScanContext(t_scanContext *p_context);
    uint32_t UdSetAdhocNetworkContext(t_adHocNetworkContext *p_context);
    uint32_t UdSetTxMode(uint8_t mode);
    uint32_t UdSetBssid(uint8_t *p_bssid);
    uint32_t UdSetRssi(uint8_t rssi);
    uint32_t UdSetRtsThreshold(uint16_t rtsThreshold);
    uint32_t UdScan(uint8_t mode);
    uint32_t udSetTxPowerMax(uint8_t maxTxPower);

#if defined(WF_USE_HARDWARE_MULTICAST_FILTER)
    uint32_t UdSetHwMulticastFilter(uint8_t multicastFilterId, uint8_t *p_multicastAddress);
#endif

#if defined(WF_USE_SOFTWARE_MULTICAST_FILTER)
uint32_t UdSetSwMulticastFilter(t_swMulticastConfig *p_config);
#endif
    
#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
    uint32_t UdConvWpaPassphrase(t_wpaKeyInfo *p_passPhrase);
#endif

uint32_t UdGetWpsCredentials(void);

#endif /* WF_ERROR_CHECKING */

#ifdef __cplusplus
}
#endif


#endif /* __WF_UD_STATE_H */
