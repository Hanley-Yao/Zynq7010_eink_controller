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

#include "MRF24GAdaptor.h"

static void OutputMrf24wgAssertInfo(uint32_t eventData);
extern          WFMRFD         wfmrf24;

/*****************************************************************************
  Function:
    void WF_ProcessEvent(uint8_t eventType, uint32_t eventData);

  Summary:
    Called by Universal Driver to inform application of MRF24WG events.

  Description:
    Various events are reported to the application via this function callback.
    The application should take appropriate action based on the event.

    Example 1) After WF_Init() is called, no other WiFI functions can be called,
               other than calling WF_Task(), until the WF_EVENT_INITIALIZATION
               occurs with eventData = WF_INIT_SUCCESSFUL.

    Example 2) If the WiFi connection is temporarily lost the application should
               not be sending messages until the WiFi connection is restored.
               If DHCP is being used, then, after the connection is restored, a
               new DHCP request should be initiated.

 Parameters:
    eventType -- type of event
    eventData -- data associated with event; not always used.

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_ProcessEvent(uint8_t eventType, uint32_t eventData)
{
    wfmrf24.priv.fMRFBusy = FALSE;
    wfmrf24.priv.lastEventType = eventType;
    wfmrf24.priv.lastEventData = eventData;
    
    switch (eventType)
    {
        case WF_EVENT_INITIALIZATION:
            if(eventData == WF_INIT_SUCCESSFUL)
            {
                wfmrf24.priv.initStatus = ForceIPStatus((InitMask | eventData));
            }
            else
            {
                wfmrf24.priv.initStatus = ForceIPError((InitMask | eventData));
            }
            break;

        case WF_EVENT_CONNECTION_SUCCESSFUL:
            wfmrf24.priv.connectionStatus = ipsSuccess;
            break;

        case WF_EVENT_CONNECTION_TEMPORARILY_LOST:
            wfmrf24.priv.connectionStatus = ForceIPStatus((CLMask | eventData));
            wfmrf24.priv.fMRFBusy = true;   // don't do anything during the reconnect!
            break;

        case WF_EVENT_CONNECTION_REESTABLISHED:
            wfmrf24.priv.connectionStatus = ipsSuccess;
            break;

        case WF_EVENT_CONNECTION_PERMANENTLY_LOST:
            wfmrf24.priv.connectionStatus = ForceIPError((CLMask | eventData));
            break;

        case WF_EVENT_CONNECTION_FAILED:
            wfmrf24.priv.connectionStatus = ForceIPError((CFMask | eventData));
            break;
        
        case WF_EVENT_SCAN_RESULTS_READY:
            wfmrf24.priv.cScanResults = eventData;
            break;

#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
        case WF_WPS_EVENT_KEY_CALCULATION_REQUEST:
            WF_WpsKeyGenerate(); // can be called here or later, but must be called
                                 // to complete WPS connection
            wfmrf24.priv.fMRFBusy = TRUE;   // wait for connection status or error.
            break;
#endif /* WF_USE_HOST_WPA_KEY_CALCULATION */

        case WF_EVENT_MRF24WG_MODULE_ASSERT:
            OutputMrf24wgAssertInfo(eventData);
            break;

        // if we get an event error, it will be in
        // the last eventData
        case WF_EVENT_ERROR:
        default:
            break;
    }

}

/*****************************************************************************
  Function:
    void WF_ProcessRxPacket(void);

  Summary:
    Called by Universal Driver to notify application of incoming packet.

  Description:
    None
 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_ProcessRxPacket(void)
{
    uint16_t cbPkt = WF_RxPacketLengthGet();

    if(cbPkt > 0)
    {
        IPSTACK * pIpStack = RRHPAlloc(wfmrf24.adpMRF24G.hAdpHeap, cbPkt + sizeof(IPSTACK));
        if(pIpStack != NULL)
        {

            // fill in info about the frame data
            pIpStack->fFrameIsParsed    = FALSE;
            pIpStack->fFreeIpStackToAdp = TRUE;
            pIpStack->headerOrder       = NETWORK_ORDER;
            pIpStack->pPayload          = ((uint8_t *) pIpStack) + sizeof(IPSTACK);
            pIpStack->cbPayload         = cbPkt;

            WF_RxPacketCopy(pIpStack->pPayload, pIpStack->cbPayload);
            WF_RxPacketDeallocate();

            pIpStack->fOwnedByAdp = true;
            FFInPacket(&wfmrf24.priv.ffptRead, pIpStack);
        }

        // if we know we can never allocate this packet, then just drop it
        else
        {
            WF_RxPacketDeallocate();
        }
    }
}

static void OutputMrf24wgAssertInfo(uint32_t assertInfo)
{
    (void)(assertInfo); // prevent unused warning
    while(TRUE);
}
