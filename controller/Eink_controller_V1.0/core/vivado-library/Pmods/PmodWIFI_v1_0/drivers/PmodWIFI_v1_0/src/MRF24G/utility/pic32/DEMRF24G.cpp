/************************************************************************/
/*                                                                      */
/*  DEMRF24G.cpp    The Digilent WIFI static class For the chipKIT      */
/*                  software compatible product line. This includes the */
/*                  Arduino compatible chipKIT boards as well as        */
/*                  the Digilent Cerebot cK boards.                     */
/*                                                                      */
/************************************************************************/
/*  Author: Keith Vogel                                                 */
/*          Copyright 2013, Digilent Inc.                               */
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
/*      This the Static DEWFcK Class implementation file                */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*  10/16/2013 (KeithV): Created                                        */
/*                                                                      */
/************************************************************************/
#include <DEIPcK.h>

#include "utility/ud_inc/shared/wf_universal_driver.h"

const NWADP * DEMRF24::deIPGetAdaptor(void)
{
    // get our pins set up
    WF_HIBERNATE_IO     = 0;
    WF_HIBERNATE_TRIS   = 0;

    WF_RESET_IO         = 0;
    WF_RESET_TRIS       = 0;

    // Enable the WiFi
    WF_CS_IO            = 1;
    WF_CS_TRIS          = 0;

    WF_INT_TRIS         = 1;

    // register our interrupt vectors
    setIntVector(WF_INT_VEC, _WFInterrupt);
    setIntPriority(WF_INT_VEC, 3, 0);

    return(GetMRF24GAdaptor(NULL, hRRAdpHeap, NULL));
}

const NWWF * DEMRF24::deWFGetWF()
{
    return(GetMRF24WF());
}

// this should be safe to call at any time
bool DEMRF24::wpaCalPSK(const char * szSsid, const char * szPassphrase, WPA2KEY& wpaKey)
{
    t_wpaKeyInfo wpaInfo;

    if( szSsid != NULL &&
        szPassphrase != NULL &&
        (wpaInfo.ssidLen = strlen(szSsid)) <= WF_MAX_SSID_LENGTH &&
        (wpaInfo.keyLength = strlen(szPassphrase)) <= WF_MAX_PASSPHRASE_LENGTH )
    {

        memcpy(wpaInfo.ssid, szSsid, wpaInfo.ssidLen);
        memcpy(wpaInfo.key, szPassphrase, wpaInfo.keyLength);

        WF_WpaConvPassphraseToKey(&wpaInfo);

        memcpy(wpaKey.rgbKey, wpaInfo.key, sizeof(WPA2KEY));

        return(true);
    }

    return(false);
}

