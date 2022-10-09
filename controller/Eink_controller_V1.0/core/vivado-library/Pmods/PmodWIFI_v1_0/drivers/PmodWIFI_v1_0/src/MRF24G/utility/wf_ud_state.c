/*******************************************************************************
 MRF24WG error checking

  Summary: Functions performing run-time error checking

  Description: Same as summary.

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

//==============================================================================
//                                  INCLUDES
//==============================================================================
#include <stdio.h>
#include <string.h>

#include "./ud_inc/shared/wf_universal_driver.h"
#include "./ud_inc/internal/wf_global_includes.h"

//==============================================================================
//                                  DEFINES
//==============================================================================
#define MAX_RTS_THRESHOLD   ((uint16_t)2347)


//==============================================================================
//                                  LOCAL GLOBALS
//==============================================================================
t_udState g_udState;

//==============================================================================
//                                  LOCAL FUNCTION PROTOTPYES
//==============================================================================
#if defined(WF_ERROR_CHECKING)
static uint32_t ValidateChannelList(uint8_t *p_channelList, uint8_t numChannels);
static uint32_t ValidateChannelsWithDomain(uint8_t *p_channelList, uint8_t numChannels, uint8_t domain);
static uint32_t ValidateSsid(uint8_t *p_ssid, uint8_t ssidLength);
static uint32_t CheckInfrastructureConnect(void);
static uint32_t CheckAdHocConnect(void);
static uint32_t CheckP2pConnect(void);
static bool isSsidDefined(void);
    #if defined(WF_USE_WPS_SECURITY)
        static uint32_t ValidateWpsPin(uint8_t *p_wpsPin);
        static uint32_t ValidateWpsChannelList(const uint8_t domain, const uint8_t *p_channelList, const uint8_t numChannels);
    #endif /* WF_USE_WPS_SECURITY */
#endif /* WF_ERROR_CHECKING */




//==============================================================================
void UdStateInit(void)
{
#if defined(WF_ERROR_CHECKING)
    uint8_t defaultChannelList[] = {1,2,3,4,5,6,7,8,9,10,11};
#endif

    memset(&g_udState, 0x00, sizeof(g_udState));

    UdSetInitInvalid();     // cleared after WF_Init() state machine complete
    UdSetConnectionState(CS_NOT_CONNECTED);
    UdSetRetryCount(DEFAULT_RETRY_COUNT);
    UdDisablePsPoll();

#if defined(WF_ERROR_CHECKING)
    UdSetSsid(NULL, 0);
    UdSetDomain(WF_DOMAIN_FCC);
    UdSetChannelList(defaultChannelList, sizeof(defaultChannelList));
    UdSetNetworkType(DEFAULT_NETWORK_TYPE);
    UdSetSecurityOpen();
#endif
}

void  UdEnablePsPoll(t_psPollContext *p_context)
{
    g_udState.psPollEnabled = true;
    memcpy(&g_udState.psPollContext, p_context, sizeof(t_psPollContext));
}

void UdDisablePsPoll(void)
{
    g_udState.psPollEnabled = false;
}

INLINE bool  UdisPsPollEnabled(void)
{
    return g_udState.psPollEnabled;
}

//==============================================================================
//==============================================================================
//
// All functions below this point are only used if WF_ERROR_CHECKING is defined
//
//==============================================================================
//==============================================================================

#if defined(WF_ERROR_CHECKING)

//==============================================================================
uint32_t UdSetDomain(uint8_t domain)
{
    uint32_t errorCode = UD_SUCCESS;

    // can't change domain unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        errorCode = UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
        goto errorExit;
    }

    if ((domain != WF_DOMAIN_FCC) && (domain != WF_DOMAIN_ETSI) && (domain != WF_DOMAIN_JAPAN))
    {
        UdSetDomainInvalid();
        errorCode = UD_ERROR_INVALID_WPS_PIN;
        goto errorExit;
    }
    else
    {
        UdSetDomainValid();
        g_udState.domain = domain;
    }

errorExit:
    return errorCode;
}

//==============================================================================
uint32_t UdSetSecurityOpen(void)
{
    // can't change security unless not connected
    if (UdGetConnectionState() == CS_NOT_CONNECTED)
    {
        UdSetSecurityValid();
        return UD_SUCCESS;
    }
    else
    {
        UdSetSecurityInvalid();
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }
}

//==============================================================================
uint32_t UdSetSecurityWep(t_wepContext *p_context)
{
    uint32_t errorCode = UD_SUCCESS;

    // can't change security unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        errorCode = UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
        goto errorExit;
    }

    if ((p_context->wepSecurityType != WF_SECURITY_WEP_40) && (p_context->wepSecurityType != WF_SECURITY_WEP_104))
    {
        errorCode = UD_ERROR_INVALID_WEP_SECURITY_TYPE;
        goto errorExit;
    }

    // if WEP-40
    if (p_context->wepSecurityType == WF_SECURITY_WEP_40)
    {
        // key must be 4 5-byte keys, or 20 bytes
        if (p_context->wepKeyLength != 20)
        {
            errorCode = UD_ERROR_WEP_40_KEY_INVALID_LENGTH;
            goto errorExit;
        }
    }
    // else WEP-104
    else
    {
        // key must be 4 13-byte keys, or 52 bytes
        if (p_context->wepKeyLength != 52)
        {
            errorCode = UD_ERROR_WEP_104_KEY_INVALID_LENGTH;
            goto errorExit;
        }
    }

    // WEP key index must be 0-3
    if (p_context->wepKeyIndex > 3)
    {
        errorCode = UD_ERROR_INVALID_WEP_KEY_INDEX;
        goto errorExit;
    }

    if ((p_context->wepKeyType != WF_SECURITY_WEP_SHAREDKEY) && (p_context->wepKeyType != WF_SECURITY_WEP_OPENKEY))
    {
        errorCode = UD_ERROR_INVALID_WEP_KEY_TYPE;
        goto errorExit;
    }

errorExit:
    if (errorCode == UD_SUCCESS)
    {
        UdSetSecurityValid();
        g_udState.securityType = p_context->wepSecurityType;
    }
    else
    {
        UdSetSecurityInvalid();
    }

    return errorCode;
}

//==============================================================================
uint32_t UdSetSecurityWpa(t_wpaContext *p_context)
{
    uint32_t errorCode = UD_SUCCESS;
    uint8_t securityType;
    uint8_t securityKeyLength;
    int i;

    securityKeyLength = p_context->keyInfo.keyLength;

    // can't change security unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        errorCode = UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
        goto errorExit;
    }

    // security type must be one of the WPA security types
    securityType = p_context->wpaSecurityType;
    if ((securityType < WF_SECURITY_WPA_WITH_KEY) || (securityType > WF_SECURITY_WPA_AUTO_WITH_PASS_PHRASE))
    {
        errorCode = UD_ERROR_INVALID_SECURITY_TYPE;
        goto errorExit;
    }

    //-----------------------------
    // if using WPA with binary key
    //----------------------------------
    if ((securityType == WF_SECURITY_WPA_WITH_KEY)       ||
        (securityType == WF_SECURITY_WPA2_WITH_KEY)      ||
        (securityType == WF_SECURITY_WPA_AUTO_WITH_KEY))
    {
        // binary key must be 64 hex digits (32 bytes)
        if (securityKeyLength != 32)
        {
            errorCode = UD_ERROR_INVALID_WPA_KEY_LENGTH;
            goto errorExit;
        }
    }
    //----------------------------------
    // else if using WPA with passphrase
    //----------------------------------
    if ((securityType == WF_SECURITY_WPA_WITH_PASS_PHRASE)       ||
        (securityType == WF_SECURITY_WPA2_WITH_PASS_PHRASE)      ||
        (securityType == WF_SECURITY_WPA_AUTO_WITH_PASS_PHRASE))
    {
        // ASCII key phrase must be between 8 and 63 bytes
        if ((securityKeyLength < 8) || (securityKeyLength > 63))
        {
            errorCode = UD_ERROR_INVALID_WPA_PASSPHRASE_LENGTH;
            goto errorExit;
        }

        // ASCII passphase characters must be printable (0x20 thru 0x7E)
        for (i = 0; i < securityKeyLength; ++i)
        {
            uint8_t tmp;
            tmp = p_context->keyInfo.key[i];
            if ((tmp < 0x20) || (tmp > 0x7e))
            {
                errorCode = UD_ERROR_INVALID_WPA_PASSPHRASE_CHARACTERS;
                goto errorExit;
            }
        }
    }

errorExit:
    if (errorCode == UD_SUCCESS)
    {
        UdSetSecurityValid();
        g_udState.securityType = p_context->wpaSecurityType;
    }
    else
    {
        UdSetSecurityInvalid();
    }

    return errorCode;
}

#if defined(WF_USE_WPS_SECURITY)
//==============================================================================
uint32_t UdSetSecurityWps(t_wpsContext *p_context)
{
    uint32_t errorCode = UD_SUCCESS;
    uint8_t  securityType;

    securityType = p_context->wpsSecurityType;

    // can't change security unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        errorCode = UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
        goto errorExit;
    }
#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
    if ((p_context->getPassPhrase != true) && (p_context->getPassPhrase != false))
    {
        errorCode = UD_ERROR_INVALID_GET_PASS_PHRASE;
        goto errorExit;
    }

    if (p_context->getPassPhrase == true)
    {
        if (p_context->p_keyInfo == NULL)
        {
            errorCode = UD_ERROR_NULL_PASS_PHRASE_INFO;
            goto errorExit;
        }
    }
#endif

    if (securityType == WF_SECURITY_WPS_PUSH_BUTTON)
    {
        // nothing to check here
    }
    //----------------------
    // else if using WPS PIN
    //----------------------
    else if (securityType == WF_SECURITY_WPS_PIN)
    {
        if (p_context->wpsPinLength != 8)
        {
            errorCode = UD_ERROR_WPS_PIN_LENGTH_INVALID;
            goto errorExit;
        }

        errorCode = ValidateWpsPin(p_context->wpsPin);
        if (errorCode != UD_SUCCESS)
        {
            goto errorExit;
        }
    }

errorExit:
    if (errorCode == UD_SUCCESS)
    {
        UdSetSecurityValid();
        g_udState.securityType = p_context->wpsSecurityType;
    }
    else
    {
        UdSetSecurityInvalid();
    }

    return errorCode;
}
#endif /* WF_USE_WPS_SECURITY */

//==============================================================================
uint32_t UdSetScanContext(t_scanContext *p_context)
{
    uint32_t errorCode = UD_SUCCESS;

    // can't change scan context unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }

    if ((p_context->scanType != WF_ACTIVE_SCAN) && (p_context->scanType != WF_PASSIVE_SCAN))
    {
        errorCode = UD_ERROR_INVALID_SCAN_TYPE;
        goto errorExit;
    }

errorExit:
    if (errorCode == UD_SUCCESS)
    {
        UdSetScanContextValid();
    }
    else
    {
        UdSetScanContextInvalid();
    }

    return errorCode;
}

//==============================================================================
uint32_t UdSetAdhocNetworkContext(t_adHocNetworkContext *p_context)
{
    uint32_t errorCode = UD_SUCCESS;

    // can't change scan context unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }

    if ((p_context->hiddenSsid != true) && (p_context->hiddenSsid != false))
    {
       errorCode = UD_ERROR_INVALID_HIDDEN_SSID;
       goto errorExit;
    }

    if (p_context->mode > WF_ADHOC_START_ONLY)
    {
        errorCode = UD_ERROR_INVALID_ADHOC_MODE;
        goto errorExit;
    }

errorExit:
    return errorCode;
}

//==============================================================================
uint32_t UdSetNetworkType(uint8_t networkType)
{
    // can't change channel list unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }

    if ((networkType < WF_MIN_NETWORK_TYPE) || (networkType > WF_MAX_NETWORK_TYPE))
    {
        UdSetNetworkTypeValid();
        return UD_INVALID_NETWORK_TYPE;
    }

    UdSetNetworkTypeValid();
    g_udState.networkType = networkType;
    return UD_SUCCESS;
}

//==============================================================================
uint32_t UdSetChannelList(uint8_t *p_channelList, uint8_t numChannels)
{
    uint32_t errorCode = UD_SUCCESS;

    // can't change channel list unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }

    errorCode = ValidateChannelList(p_channelList, numChannels);
    if (errorCode != UD_SUCCESS)
    {
        UdSetChannelListInvalid();
        return errorCode;
    }
    else
    {
        UdSetChannelListValid();
    }

    memset(g_udState.channelList, 0x00, sizeof(g_udState.channelList));
    memcpy(g_udState.channelList, p_channelList, numChannels);
    g_udState.numChannels = numChannels;

    return errorCode;
}

//==============================================================================
uint32_t UdSetSsid(uint8_t *p_ssid, uint8_t ssidLength)
{
    uint32_t errorCode;

    // can't change SSID unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }

    errorCode = ValidateSsid(p_ssid, ssidLength);
    if (errorCode != UD_SUCCESS)
    {
        UdSetSsidInvalid();
        return errorCode;
    }
    else
    {
        UdSetSsidValid();
        memset(g_udState.ssid, 0x00, sizeof(g_udState.ssid));
        memcpy(g_udState.ssid, p_ssid, ssidLength);
        g_udState.ssidLength = ssidLength;
    }

    return UD_SUCCESS;
}

//==============================================================================
uint32_t UdSetBssid(uint8_t *p_bssid)
{
    p_bssid = p_bssid; // avoid warning

    // can't change BSSID unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }
    else
    {
        return UD_SUCCESS;
    }
}

//==============================================================================
uint32_t UdSetRssi(uint8_t rssi)
{
    rssi = rssi; // avoid warning

    // can't change RSSI unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }
    else
    {
        return UD_SUCCESS;
    }
}

//==============================================================================
uint32_t UdSetRtsThreshold(uint16_t rtsThreshold)
{
    // can't change RSSI unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }

    if (rtsThreshold > MAX_RTS_THRESHOLD)
    {
        return UD_ERROR_INVALID_RTS_THRESHOLD;
    }

    return UD_SUCCESS;
}

//==============================================================================
uint32_t UdSetReconnectMode(uint8_t retryCount, uint8_t deauthAction, uint8_t beaconTimeout, uint8_t beaconTimeoutAction)
{
    uint32_t errorCode = UD_SUCCESS;

    if ((deauthAction != WF_ATTEMPT_TO_RECONNECT) && (deauthAction != WF_DO_NOT_ATTEMPT_TO_RECONNECT))
    {
        errorCode = UD_ERROR_INVALID_DEAUTH_PARAM;
        goto errorExit;
    }

    if ((beaconTimeoutAction != WF_ATTEMPT_TO_RECONNECT) && (beaconTimeoutAction != WF_DO_NOT_ATTEMPT_TO_RECONNECT))
    {
        errorCode = UD_ERROR_INVALID_BEACON_TIMEOUT_PARAM;
        goto errorExit;
    }

    // if no automatic retries
    if (retryCount == 0)
    {
        if ((deauthAction == WF_ATTEMPT_TO_RECONNECT) || (beaconTimeoutAction == WF_ATTEMPT_TO_RECONNECT))
        {
            errorCode = UD_ERROR_INVALID_RECONNECT_MODE;
        }
    }

errorExit:
    UdSetRetryCount(retryCount);
    return errorCode;
}

// called by WF_Connect
//==============================================================================
uint32_t UdCheckConnectionConfig(void)
{
    uint32_t errorCode = UD_SUCCESS;

    // first check the error bit mask; if any bits are set than an error
    // occurred previously and the connection process is stopped
    if (g_udState.errorState > 0)
    {
        errorCode = UD_ERROR_INVALID_CONFIG;
        goto errorExit;
    }

    if (UdGetNetworkType() == WF_NETWORK_TYPE_INFRASTRUCTURE)
    {
        errorCode = CheckInfrastructureConnect();
    }
    else if (UdGetNetworkType() == WF_NETWORK_TYPE_ADHOC)
    {
        errorCode = CheckAdHocConnect();
    }
    else // WF_NETWORK_TYPE_P2P
    {
        errorCode = CheckP2pConnect();
    }

errorExit:
    if (errorCode == UD_SUCCESS)
    {
        UdSetNetworkConfigValid();
    }
    else
    {
        UdSetNetworkConfigInvalid();
    }

    return errorCode;
}

//==============================================================================
uint32_t UdSetTxMode(uint8_t mode)
{
    // can't change SSID unless not connected
    if (UdGetConnectionState() != CS_NOT_CONNECTED)
    {
        return UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED;
    }

    if (mode > WF_TXMODE_LEGACY_RATES)
    {
        return UD_ERROR_INVALID_TX_MODE;
    }
    else
    {
        return UD_SUCCESS;
    }
}

//==============================================================================
uint32_t UdScan(uint8_t mode)
{
    if (mode > WF_SCAN_ALL)
    {
        return UD_ERROR_INVALID_SCAN_MODE;
    }
    else
    {
        return UD_SUCCESS;
    }
}

uint32_t udSetTxPowerMax(uint8_t maxTxPower)
{
    if ((maxTxPower < 9) || (maxTxPower > 18))
    {
        return UD_ERROR_INVALID_MAX_POWER;
    }
    else
    {
        return UD_SUCCESS;
    }
}

#if defined(WF_USE_HARDWARE_MULTICAST_FILTER)
uint32_t UdSetHwMulticastFilter(uint8_t multicastFilterId, uint8_t *p_multicastAddress)
{
    p_multicastAddress = p_multicastAddress;  // avoid warning
    
    if((multicastFilterId != WF_MULTICAST_FILTER_1) && (multicastFilterId != WF_MULTICAST_FILTER_2))
    {
        return UD_ERROR_INVALID_MULTICAST_FILTER_ID;
    }
    else
    {
        return UD_SUCCESS;
    }
}
#endif /* WF_USE_HARDWARE_MULTICAST_FILTER */

#if defined(WF_USE_SOFTWARE_MULTICAST_FILTER)
uint32_t UdSetSwMulticastFilter(t_swMulticastConfig *p_config)
{
    uint32_t errorCode = UD_SUCCESS;

    if (p_config->action > WF_MULTICAST_USE_FILTERS)
    {
        errorCode = UD_ERROR_INVALID_MULTICAST_ACTION;
        goto errorExit;
    }

    if ((p_config->filterId < WF_MULTICAST_FILTER_1) || (p_config->filterId > WF_MULTICAST_FILTER_16))
    {
        errorCode = UD_ERROR_INVALID_MULTICAST_FILTER_ID;
        goto errorExit;
    }

errorExit:
    return errorCode;
}
#endif /* WF_USE_SOFTWARE_MULTICAST_FILTER */


#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
uint32_t UdConvWpaPassphrase(t_wpaKeyInfo *p_keyInfo)
{

    // WPA passphrase must be between 8 and 63 bytes
    if ((p_keyInfo->keyLength < 8) || (p_keyInfo->keyLength > 63))
    {
        return UD_ERROR_INVALID_WPA_PASSPHRASE_LENGTH;
    }

    if (p_keyInfo->ssidLen > WF_MAX_SSID_LENGTH)
    {
        return UD_ERROR_SSID_TOO_LONG;
    }

    return UD_SUCCESS;
}
#endif /* WF_USE_HOST_WPA_KEY_CALCULATION */

#if defined(WF_USE_WPS_SECURITY)
uint32_t UdGetWpsCredentials(void)
{
    if ((g_udState.securityType != WF_SECURITY_WPS_PIN) || (g_udState.securityType != WF_SECURITY_WPS_PUSH_BUTTON))
    {
        return UD_ERROR_NOT_WPS_SECURITY;
    }
    else
    {
        return UD_SUCCESS;
    }
}
#endif /* WF_USE_WPS_SECURITY */

//==============================================================================
static uint32_t ValidateChannelList(uint8_t *p_channelList, uint8_t numChannels)
{
    uint32_t errorCode = UD_SUCCESS;
    int i;

    // if no channel list defined
    if ((p_channelList == NULL) || (numChannels == 0))
    {
        errorCode = UD_ERROR_NO_CHANNEL_LIST_DEFINED;
        goto errorExit;
    }

    if (numChannels > 14)
    {
        errorCode = UD_ERROR_EXCEEDED_MAX_CHANNELS;
        goto errorExit;
    }

    for (i = 0; i < numChannels; ++i)
    {
        if ((p_channelList[i] > 14) || (p_channelList[i] == 0))
        {
            errorCode = UD_INVALID_CHANNEL_NUMBER;
            goto errorExit;
        }
    }

errorExit:
    if (errorCode != UD_SUCCESS)
    {
        UdSetChannelListInvalid();
        return errorCode;
    }
    else
    {
        UdSetChannelListValid();
    }

    return errorCode;
}

//============================================================================
static uint32_t ValidateSsid(uint8_t *p_ssid, uint8_t ssidLength)
{
    uint32_t errorCode = UD_SUCCESS;

    // With the exception of WPS_PUSH_BUTTON an SSID must be defined.  This will
    // be checked when WF_Connect() is called.

    if (ssidLength > WF_MAX_SSID_LENGTH)
    {
        errorCode = UD_ERROR_SSID_TOO_LONG;
        goto errorExit;
    }
    
    // if SSID length > 0, but SSID string not defined
    if ((ssidLength > 0) && (p_ssid[0] == 0x00))
    {
        errorCode = UD_ERROR_SSID_BUFFER_EMPTY;
        goto errorExit;
    }

errorExit:
    if (errorCode == UD_SUCCESS)
    {
        UdSetSsidValid();
    }
    else
    {
        UdSetSsidInvalid();
    }

    return errorCode;
}

//============================================================================
static uint32_t CheckInfrastructureConnect(void)
{
    uint32_t errorCode = UD_SUCCESS;

    // ensure that all channels are within selected domain
    errorCode = ValidateChannelsWithDomain(g_udState.channelList, g_udState.numChannels, g_udState.domain);
    if (errorCode != UD_SUCCESS)
    {
        goto errorExit;
    }

    // if not using WPS (push-button or PIN)
    if ((g_udState.securityType != WF_SECURITY_WPS_PIN) || (g_udState.securityType != WF_SECURITY_WPS_PUSH_BUTTON))
    {
        // SSID must be defined
        if ( !isSsidDefined() )
        {
            errorCode = UD_ERROR_SSID_NOT_DEFINED;
            goto errorExit;
        }
    }
    // else WPS is being used
    else
    {
#if defined(WF_USE_WPS_SECURITY)
        // if using WPS PIN
        if (g_udState.securityType == WF_SECURITY_WPS_PIN)
        {
            // SSID must be defined when using WPS PIN
            if ( !isSsidDefined() )
            {
                errorCode = UD_ERROR_SSID_NOT_DEFINED;
                goto errorExit;
            }
        }
        // else using WPS Push-button
        else
        {
            // if in infrastructure mode using WPS Push-button, the SSID should be an empty string
            if (isSsidDefined())
            {
                errorCode = UD_ERROR_SSID_DEFINED;
                goto errorExit;
            }
        }

        errorCode = ValidateWpsChannelList(g_udState.domain, g_udState.channelList, g_udState.numChannels);
        if (errorCode != UD_SUCCESS)
        {
            goto errorExit;
        }
#endif /* WF_USE_WPS_SECURITY */
    }
errorExit:
    return errorCode;
}

//============================================================================
static uint32_t CheckAdHocConnect(void)
{
    uint32_t errorCode = UD_SUCCESS;
    // TODO: ps-poll not supported in Adhoc

    if ((g_udState.securityType != WF_SECURITY_OPEN)     &&
        (g_udState.securityType != WF_SECURITY_WEP_40)   &&
        (g_udState.securityType != WF_SECURITY_WEP_104))
    {
        errorCode = UD_ERROR_INVALID_WEP_SECURITY;
        goto errorExit;
    }

    if (g_udState.retryCount == WF_RETRY_FOREVER)
    {
        errorCode = UD_ERROR_INVALID_ADHOC_RETRY_COUNT;
        goto errorExit;
    }

errorExit:
    return errorCode;
}

//============================================================================
static uint32_t CheckP2pConnect(void)
{
    uint32_t errorCode = UD_SUCCESS;
    uint16_t channelBitMask = 0;
    int i;

    if (strcmp((char *)g_udState.ssid, "DIRECT-") != 0)
    {
        errorCode = UD_ERROR_INVALID_P2P_SSID;
        goto errorExit;
    }

    if (g_udState.numChannels != 3)
    {
        errorCode = UD_ERROR_INVALID_P2P_CHANNEL_LIST;
        goto errorExit;
    }

    for (i = 0; i < 3; ++i)
    {
        // set bit corresponding to channel number
        channelBitMask |= (0x00001 << g_udState.channelList[i]);
    }

    // Only bits corresponding to channels 1,6,11 should be set
    if (channelBitMask != 0x0842)
    {
        errorCode = UD_ERROR_INVALID_P2P_CHANNEL_LIST;
        goto errorExit;
    }

errorExit:
    return errorCode;
}


//============================================================================
static bool isSsidDefined(void)
{
    return (g_udState.ssidLength > 0);
}

//============================================================================
static uint32_t ValidateChannelsWithDomain(uint8_t *p_channelList, uint8_t numChannels, uint8_t domain)
{
    uint8_t maxChannel;
    uint8_t channel;
    int i;
    uint32_t errorCode = UD_SUCCESS;

    if (domain == WF_DOMAIN_FCC)
    {
        maxChannel = 11;
    }
    else if (domain == WF_DOMAIN_ETSI)
    {
        maxChannel = 13;
    }
    else
    {
        maxChannel = 14;
    }

     // validate that all channel numbers are within range and not equal to 0
    for (i = 0; i < numChannels; ++i)
    {
        channel = p_channelList[i];

        if (channel == 0)
        {
            errorCode = UD_ERROR_INVALID_CHANNEL_0;
            goto errorExit;
        }

        if (channel > maxChannel)
        {
            errorCode = UD_ERROR_CHANNEL_OUT_OF_RANGE;
            goto errorExit;
        }
    }

errorExit:
    if (errorCode == UD_SUCCESS)
    {
        UdSetChannelListValid();
    }
    else
    {
        UdSetChannelListInvalid();
    }

    return errorCode;
}

#if defined(WF_USE_WPS_SECURITY)
static uint32_t ValidateWpsPin(uint8_t *p_wpsPin)
{
    uint32_t pin = 0;
    uint32_t accum = 0;
    int i;
    uint32_t mult = 10000000;

    // convert 8-byte array of pin numbers to unsigned long
    for (i = 0; i < 8; ++i)
    {
        if (i < 7)
        {
            pin += (p_wpsPin[i] * mult);
            mult /= 10;
        }
        else
        {
            pin += p_wpsPin[i];
            break;
        }
    }

    // calculate checksum
    accum += 3 * ((pin / 10000000) % 10);
    accum += 1 * ((pin / 1000000) % 10);
    accum += 3 * ((pin / 100000) % 10);
    accum += 1 * ((pin / 10000) % 10);
    accum += 3 * ((pin / 1000) % 10);
    accum += 1 * ((pin / 100) % 10);
    accum += 3 * ((pin / 10) % 10);
    accum += 1 * ((pin / 1) % 10);

    // if checksum is valid
    if ((accum % 10) == 0)
    {
        UdSetSecurityValid();
        return UD_SUCCESS;
    }
    else
    {
        UdSetSecurityInvalid();
        return UD_ERROR_INVALID_WPS_PIN;
    }
}

static uint32_t ValidateWpsChannelList(const uint8_t domain, const uint8_t *p_channelList, const uint8_t numChannels)
{
    uint32_t errorCode = UD_SUCCESS;
    uint32_t channelBitMask = 0;
    uint32_t compareMask;
    int i;

    // for each channel in list
    for (i = 0; i < numChannels; ++i)
    {
        // set bit in mask corresponding to channel number (e.g. bit 1 for channel 1)
        channelBitMask |= (0x00000001 << p_channelList[i]);
    }
    channelBitMask >>= 1;  // there is no channel 0, so shift right by 1 bit for easier compare below

    if (domain == WF_DOMAIN_FCC)
    {
        compareMask = 0x000007ff;  // channels 1 thru 11 required
    }
    else if (domain == WF_DOMAIN_ETSI)
    {
        compareMask = 0x00001fff;  // channels 1 thru 13 required
    }
    else // JAPAN domain
    {
        compareMask = 0x00003fff;  // channels 1 thru 14 required
    }

    // for WPS, all channels in domain must be in channel list
    if (channelBitMask != compareMask)
    {
        errorCode = UD_ERROR_ALL_DOMAIN_CHANNELS_REQUIRED;
    }

    if (errorCode == UD_SUCCESS)
    {
        UdSetChannelListValid();
    }
    else
    {
        UdSetChannelListInvalid();
    }

    return errorCode;
}
#endif /* WF_USE_WPS_SECURITY */

#endif /* WF_ERROR_CHECKING */
