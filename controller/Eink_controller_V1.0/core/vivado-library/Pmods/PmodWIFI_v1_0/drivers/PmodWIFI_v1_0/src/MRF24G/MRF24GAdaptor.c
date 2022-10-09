/************************************************************************/
/*                                                                      */
/*	MRF24GAdaptor.c This implements a Nework adaptor                    */
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
/*	A WiFi Network adaptor using the Microchip Universal Driver     */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	5/31/2013(KeithV): Created                                      */
/*                                                                      */
/************************************************************************/
#include "MRF24GAdaptor.h"

extern          WFMRFD         wfmrf24;
static t_wpaKeyInfo wpaKeyInfoG;


static bool IsInitialized(IPSTATUS * pStatus)
{
    // we ONLY DO THIS ONCE
    static bool fInitSetup = false;

    AssignStatusSafely(pStatus, wfmrf24.priv.initStatus);
    
    // Run the task because we might not be in the Adaptor yet
    WF_Task();

    if(!fInitSetup && wfmrf24.priv.initStatus == (InitMask | WF_INIT_SUCCESSFUL))
    {
        uint8_t channels[] = {};
        t_scanContext scanContext = {WF_ACTIVE_SCAN, 1, 200, 400, 20};

        WF_RegionalDomainSet(WF_DOMAIN_FCC);
        WF_NetworkTypeSet(WF_NETWORK_TYPE_INFRASTRUCTURE);
        WF_ChannelListSet(channels, sizeof(channels));
        WF_ReconnectModeSet(3, WF_ATTEMPT_TO_RECONNECT, 40, WF_ATTEMPT_TO_RECONNECT);
        WF_ScanContextSet(&scanContext);

        // fixup the MAC
        if(memcmp(&wfmrf24.adpMRF24G.mac, &MACNONE, sizeof(MACADDR)) == 0)
        {
            WF_MacAddressGet((uint8_t *) &wfmrf24.adpMRF24G.mac);
        }
        else
        {
            WF_MacAddressSet((uint8_t *) &wfmrf24.adpMRF24G.mac);
        }

        // set up the hardware filters
        //WF_SetHwMultiCastFilter(WF_MULTICAST_FILTER_1, (uint8_t *) &wfmrf24.adpMRF24G.mac);
        WF_SetHwMultiCastFilter(WF_MULTICAST_FILTER_2, (uint8_t *) &MACNONE);

        // we are done
        fInitSetup = true;
    }
    return(wfmrf24.priv.initStatus == (InitMask | WF_INIT_SUCCESSFUL));
}


// Linked means, connected to the network
// just being initialized is NOT being linked!
// we must be connected to the AP to be linked
static bool IsLinked(IPSTATUS * pStatus)
{
    IPSTATUS    status = wfmrf24.priv.connectionStatus;

    if(!IsInitialized(pStatus))
    {
        return(false);
    }

    AssignStatusSafely(pStatus, status);

    // Alternative way, but slower than polling the event data
    //     void WF_ConnectionStateGet(uint8_t *p_state);
    // This is faster and gives the same result
    return(status == ipsSuccess);
}

static bool Send(IPSTACK * pIpStack, IPSTATUS * pStatus)
{
    AssignStatusSafely(pStatus, ipsSuccess);
    pIpStack->fOwnedByAdp = true;
    FFInPacket(&wfmrf24.priv.ffptWrite, pIpStack);
    return(true);
}

static bool SendNextIpStack(void)
{

    // get the next stack to send if we have one
    if(wfmrf24.priv.pIpStackBeingTx == NULL)
    {
        wfmrf24.priv.pIpStackBeingTx = (IPSTACK*)FFOutPacket(&wfmrf24.priv.ffptWrite);
    }

    // try and send it.
    if(wfmrf24.priv.pIpStackBeingTx != NULL)
    {
        IPSTACK *   pIPStack = wfmrf24.priv.pIpStackBeingTx;
        int16_t     cbTotal = pIPStack->cbFrame + pIPStack->cbIPHeader + pIPStack->cbTranportHeader + pIPStack->cbPayload;

        if(WF_TxPacketAllocate(cbTotal))
        {

            // always have a frame, alwasy FRAME II (we don't support 802.3 outgoing frames; this is typical)
            WF_TxPacketCopy((uint8_t *) pIPStack->pFrameII, pIPStack->cbFrame);

            // IP Header
            if(pIPStack->cbIPHeader > 0)
            {
                WF_TxPacketCopy((uint8_t *) pIPStack->pIPHeader, pIPStack->cbIPHeader);
            }

            // Transport Header (TCP/UDP)
            if(pIPStack->cbTranportHeader > 0)
            {
                WF_TxPacketCopy((uint8_t *) pIPStack->pTransportHeader, pIPStack->cbTranportHeader);
            }

            // Payload / ARP / ICMP
            if(pIPStack->cbPayload > 0)
            {
                WF_TxPacketCopy((uint8_t *) pIPStack->pPayload, pIPStack->cbPayload);
            }

            // transmit
            WF_TxPacketTransmit(cbTotal);

            // we sent it, clean up
            pIPStack->fOwnedByAdp = false;
            IPSRelease(pIPStack);
            wfmrf24.priv.pIpStackBeingTx = NULL;

            return(true);
        }
        else
        {
            return(false);
        }
    }

    return(true);
}

static IPSTACK * Read(IPSTATUS * pStatus)
{
    IPSTACK *   pIpStack = (IPSTACK*)FFOutPacket(&wfmrf24.priv.ffptRead);

    if(pIpStack != NULL)
    {
        pIpStack->fOwnedByAdp = false;
    }

    AssignStatusSafely(pStatus, ipsSuccess);
    return(pIpStack);
}
static void Disconnect(void)
{
    uint8_t connectionState = WF_CSTATE_NOT_CONNECTED;
    
    if(!wfmrf24.priv.fMRFBusy)
    {   
        WF_ConnectionStateGet(&connectionState);

        switch(connectionState)
        {
            // normal case at dropping the AP
            case WF_CSTATE_CONNECTED_INFRASTRUCTURE:
            case WF_CSTATE_CONNECTED_ADHOC:
                WF_Disconnect();
                wfmrf24.priv.fMRFBusy = false;
                break;

            // this is an ugly case, we could be in the middle of trying
            // to reconnect and we MUST NOT disconnect or we could
            // put the firmware into a locked up state
            // so instead just say we are busy and when the connect attempts
            // the connect will wait until it is done being busy
            // however this should never happen as we set the busy state when
            // we entered either of these states in the event stub
            case WF_CSTATE_CONNECTION_IN_PROGRESS:
            case WF_CSTATE_RECONNECTION_IN_PROGRESS:
                wfmrf24.priv.fMRFBusy = true;
                break;

            default:
                break;
        }
    }

    // in all cases want to pretend at least the we disconnected.
    wfmrf24.priv.connectionStatus = ForceIPStatus((InitMask | WF_EVENT_INITIALIZATION));
}

static bool IsInitNotLinked(IPSTATUS * pStatus)
{
    if(wfmrf24.priv.fMRFBusy)
    {
        AssignStatusSafely(pStatus, ipsInUseW);
        return(false);
    }
    else if(wfmrf24.priv.connectionStatus != ForceIPStatus((InitMask | WF_EVENT_INITIALIZATION)))
    {
        AssignStatusSafely(pStatus, ipsInUse);
        return(false);

    }
    else if(!IsInitialized(pStatus))
    {
        return(false);
    }

    // we are not busy and we are in the initialize state and we have
    // not connected. However, in the past, we may have attempted a disconnect while
    // during a reconnect, so lets just make sure we are disconnected
    Disconnect();

    return(true);
}

// this code is not complete or tested; 
// The problem is, we can only handle calling MRF init once, if
// we lose the fundamental connection to the MRF at this time we must MCLR.
//
// At some point in the future we may wish to make close diconnect the MRF as well
// we would then want to reset the fInitSetup in Initialize()
// we would also have to loop until the MRF successfully disconnected from the AP so we
// can safely drop the connection to the MRF.
static bool Close(void)
{
    // Disconnect will not break the connection to the MRF
    // it will only drop the connection to the AP
    Disconnect();
    return(true);
}

static bool StartScan(WFSCANMODE filter, IPSTATUS * pStatus)
{
    if(IsInitialized(pStatus) && wfmrf24.priv.connectionStatus == ForceIPStatus((InitMask | WF_EVENT_INITIALIZATION)))
    {
        wfmrf24.priv.fMRFBusy = true;
        wfmrf24.priv.cScanResults = -1;
        WF_Scan(filter);
        AssignStatusSafely(pStatus, ipsPending);
    }
    return(true);
}

static bool IsScanDone(int32_t * pcAP)
{
    *pcAP = wfmrf24.priv.cScanResults;
    return(!wfmrf24.priv.fMRFBusy);
}

static bool GetScanResult(int32_t index, SCANINFO *pScanResult)
{
    if(0 <= index && index < wfmrf24.priv.cScanResults)
    {
        WF_ScanResultGet(index, (t_scanResult *) pScanResult);
        return(true);
    }
    return(false);
}

// must loop on connect until a connect
static bool Connect(SECURITY security, const uint8_t * szSsid, const void * pvPkt, int iKey, bool fPICKeyCalc, IPSTATUS * pStatus)
{
    t_wepContext wep;
    t_wpaContext wpa;
    t_wpsContext wps;

    if(!IsInitialized(pStatus))
    {
        return(false);
    }
    else if(szSsid == NULL || (security != DEWF_SECURITY_OPEN && pvPkt == NULL))
    {
        AssignStatusSafely(pStatus, ispInvalidArgument);
    }
    else if(IsInitNotLinked(pStatus))
    {
        // set the SSID
        WF_SsidSet((uint8_t *) szSsid, (uint8_t) strlen((char *) szSsid));

        switch(security)
        {
            case DEWF_SECURITY_OPEN:
                WF_SecurityOpenSet();
                break;

            case DEWF_SECURITY_WEP_40:
                wep.wepSecurityType     = security;                 // WF_SECURITY_WEP_40 or WF_SECURITY_WEP_104
                wep.wepKeyIndex         = iKey;                     // 0 thru 3
                wep.wepKeyLength        = sizeof(WEP40KEY);         // number of bytes pointed to by p_wepKey
                memcpy(wep.wepKey, pvPkt, sizeof(WEP40KEY));        // array containing WEP binary security key (4 5-byte keys for WEP-40, 4 13-byte keys for WEP-104)
                wep.wepKeyType          = WF_SECURITY_WEP_OPENKEY;  // WF_SECURITY_WEP_OPENKEY (default) or WF_SECURITY_WEP_SHAREDKEY
                WF_SecurityWepSet(&wep);
                break;

            case DEWF_SECURITY_WEP_104:
                wep.wepSecurityType     = security;                 // WF_SECURITY_WEP_40 or WF_SECURITY_WEP_104
                wep.wepKeyIndex         = iKey;                     // 0 thru 3
                wep.wepKeyLength        = sizeof(WEP104KEY);        // number of bytes pointed to by p_wepKey
                memcpy(wep.wepKey, pvPkt, sizeof(WEP104KEY));       // array containing WEP binary security key (4 5-byte keys for WEP-40, 4 13-byte keys for WEP-104)
                wep.wepKeyType          = WF_SECURITY_WEP_OPENKEY;  // WF_SECURITY_WEP_OPENKEY (default) or WF_SECURITY_WEP_SHAREDKEY
                WF_SecurityWepSet(&wep);
                break;

            case DEWF_SECURITY_WPA_WITH_PASS_PHRASE:
            case DEWF_SECURITY_WPA2_WITH_PASS_PHRASE:
            case DEWF_SECURITY_WPA_AUTO_WITH_PASS_PHRASE:
                wpa.wpaSecurityType     = security;                 // WF_SECURITY_WPA_WITH_KEY, WF_SECURITY_WPA_WITH_PASS_PHRASE, WF_SECURITY_WPA2_WITH_KEY, WF_SECURITY_WPA2_WITH_PASS_PHRASE,WF_SECURITY_WPA_AUTO_WITH_KEY, WF_SECURITY_WPA_AUTO_WITH_PASS_PHRASE
                wpa.keyInfo.keyLength   = strlen((const char*)pvPkt);            // number of bytes in binary key (always 32) or passphrase
                memcpy(wpa.keyInfo.key, pvPkt, wpa.keyInfo.keyLength);  // binary key or passphrase
                wpa.keyInfo.ssidLen     = strlen((char *) szSsid);           // number of bytes in SSID
                memcpy(wpa.keyInfo.ssid, szSsid, wpa.keyInfo.ssidLen);  // ssid

#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
                if(fPICKeyCalc)
                {
                    // this is very ugly as it holds the PIC
                    // for 4 seconds
                    WF_WpaConvPassphraseToKey(&wpa.keyInfo);    // not sure how to check for errors
                    wpa.wpaSecurityType--;                      // go to the KEY form of the type
                }
#endif /* WF_USE_HOST_WPA_KEY_CALCULATION */

                WF_SecurityWpaSet(&wpa);
                break;

            case DEWF_SECURITY_WPA_WITH_KEY:
            case DEWF_SECURITY_WPA2_WITH_KEY:
            case DEWF_SECURITY_WPA_AUTO_WITH_KEY:
                wpa.wpaSecurityType     = security;                             // WF_SECURITY_WPA_WITH_KEY, WF_SECURITY_WPA_WITH_PASS_PHRASE, WF_SECURITY_WPA2_WITH_KEY, WF_SECURITY_WPA2_WITH_PASS_PHRASE,WF_SECURITY_WPA_AUTO_WITH_KEY, WF_SECURITY_WPA_AUTO_WITH_PASS_PHRASE
                wpa.keyInfo.keyLength   = sizeof(WPA2KEY);                      // number of bytes in binary key (always 32) or passphrase
                memcpy(wpa.keyInfo.key, pvPkt, sizeof(WPA2KEY));               // binary key or passphrase
                wpa.keyInfo.ssidLen     = strlen((char *) szSsid);                       // number of bytes in SSID
                memcpy(wpa.keyInfo.ssid, szSsid, wpa.keyInfo.ssidLen);          // ssid
                WF_SecurityWpaSet(&wpa);
                break;

            case DEWF_SECURITY_WPS_PUSH_BUTTON:
                wps.wpsPinLength = WF_WPS_PIN_LENGTH;               // should always be 8
                memcpy(wps.wpsPin, pvPkt, WF_WPS_PIN_LENGTH);     // if using WF_SECURITY_WPS_PIN then pointer to 8-digit pin
                // fall thru

            case DEWF_SECURITY_WPS_PIN:
                wps.wpsSecurityType = security;                    // WF_SECURITY_WPS_PUSH_BUTTON or WF_SECURITY_WPS_PIN
    #if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
                wps.getPassPhrase = fPICKeyCalc;                    // calculate key in PIC32(true) or on MRF (false)
                memset(&wpaKeyInfoG, 0, sizeof(t_wpaKeyInfo));
                wps.p_keyInfo = &wpaKeyInfoG;                       // pointer to where the Universal driver will store passphrase info (must be global memory)
    #endif /* WF_USE_HOST_WPA_KEY_CALCULATION */
                WF_SecurityWpsSet(&wps);
                break;

            default:
                AssignStatusSafely(((IPSTATUS *) pStatus), ispInvalidArgument);
                return(false);
                break;
        }
        wfmrf24.priv.fMRFBusy = true;
        WF_Connect();
    }

    return(IsLinked(pStatus));
}

static void WF_PowerStateGetT(uint8_t *p_powerState)
{
    WF_PowerStateGet(p_powerState);
}

static void MRF24PeriodicTasks(void)
{
    IPSTATUS status;
    
    SendNextIpStack();
    
    // if initialization has started, we want to finish
    IsInitialized(&status);     // this will call WF_Task();)
//     WF_Task();
}

WFMRFD wfmrf24 =
{
    {
        MRF24G_NWA_VERSION,
        false,
        MRF24G_NWA_MTU_RX,
        MRF24G_NWA_MIN_TX_MTU,
#if defined(__MICROBLAZE__)||defined(__arm__)
        {{0x00, 0x00, 0x00, 0x00, 0x00, 0x00}},
#else
		{.u8 = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00}},
#endif
        NULL,
        MRF24PeriodicTasks,
        IsLinked,
        IsLinked,
        Send,
        Read,
        Close,
    },
    {
        IsInitialized,
        Connect,
        Disconnect,
        StartScan,
        IsScanDone,
        GetScanResult,
    },
    {
        WF_ConnectionStateGet,
        WF_RegionalDomainSet,
        WF_SsidSet,
        WF_NetworkTypeSet,
        WF_ChannelListSet,
        WF_ReconnectModeSet,
        WF_SecurityOpenSet,
        WF_SecurityWepSet,
        WF_SecurityWpaSet,
        WF_PsPollEnable,
        WF_PsPollDisable,
        WF_Hibernate,
        WF_PowerStateGetT,
        WF_TxPowerFactoryMaxGet,
        WF_TxPowerMaxSet,
        WF_DeviceInfoGet,
        WF_MacStatsGet,
        WF_TxPacketAllocate,
        WF_TxPacketCopy,
        WF_TxPacketTransmit,
        WF_ProcessRxPacket,
        WF_RxPacketLengthGet,
        WF_RxPacketCopy,
        WF_RxPacketDeallocate,
        WF_MacAddressSet,
        WF_MacAddressGet,
        WF_ScanContextSet,
        WF_AdhocContextSet,
        WF_TxModeSet,
        WF_BssidSet,
        WF_RssiSet,
        WF_RtsThresholdSet,
        WF_LinkDownThresholdSet,

    // multicast filter functions
#if defined(WF_USE_HARDWARE_MULTICAST_FILTER)
        WF_SetHwMultiCastFilter,
#endif /* WF_USE_HARDWARE_MULTICAST_FILTER */

#if defined(WF_USE_SOFTWARE_MULTICAST_FILTER)
        WF_SwMulticastFilterSet,
#endif /* WF_USE_SOFTWARE_MULTICAST_FILTER */

#if defined(WF_USE_WPS_SECURITY)
        WF_SecurityWpsSet,
        WF_WpsCredentialsGet,
#endif /* WF_USE_WPS_SECURITY */

#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
        WF_WpaConvPassphraseToKey,
        WF_WpsKeyGenerate,
#endif /* WF_USE_HOST_WPA_KEY_CALCULATION */
    },
    {
        {NULL, NULL},
        {NULL, NULL},
        NULL,
        ForceIPStatus((InitMask | WF_INIT_ERROR_SPI_NOT_CONNECTED)),
        ForceIPStatus((InitMask | WF_EVENT_INITIALIZATION)),
        -1,
        false,
        0x00,
        0x00000000,
    },
};

const NWADP * GetMRF24GAdaptor(MACADDR *pUseThisMac, HRRHEAP hAdpHeap, IPSTATUS * pStatus)
{
    if(hAdpHeap == NULL)
    {
        AssignStatusSafely(pStatus, ipsNoHeapGiven);
        return(NULL);
    }

    AssignStatusSafely(pStatus, ipsSuccess);
    wfmrf24.priv.initStatus = ForceIPStatus((InitMask | WF_INIT_ERROR_SPI_NOT_CONNECTED));
    wfmrf24.priv.connectionStatus = ForceIPStatus((InitMask | WF_EVENT_INITIALIZATION));
    wfmrf24.priv.cScanResults = -1;
    wfmrf24.adpMRF24G.hAdpHeap = hAdpHeap;
    wfmrf24.priv.pIpStackBeingTx = NULL;
    memset(&wfmrf24.priv.ffptRead, 0, sizeof(FFPT));
    memset(&wfmrf24.priv.ffptWrite, 0, sizeof(FFPT));

    // save away our MAC
    if(pUseThisMac != NULL)
    {
        memcpy(&wfmrf24.adpMRF24G.mac, pUseThisMac, sizeof(MACADDR));
    }
    else
    {
        memcpy(&wfmrf24.adpMRF24G.mac, &MACNONE, sizeof(MACADDR));
    }

    WF_Init();
    return(&wfmrf24.adpMRF24G);
}

const NWWF * GetMRF24WF(void)
{
    return(&wfmrf24.wfMRF24G);
}

const WFMRF * GetMRF24GFunc(void)
{
    return(&wfmrf24.funcMRF24G);
}
