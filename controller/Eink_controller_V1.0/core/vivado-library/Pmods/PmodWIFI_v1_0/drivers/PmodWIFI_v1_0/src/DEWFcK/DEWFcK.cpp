/************************************************************************/
/*																		*/
/*	DEWFcK.cpp      Defines the core C++ class for WiFi support         */
/*                  with the deIPck network libraries                   */
/*																		*/
/************************************************************************/
/*  Author:     Keith Vogel                                             */
/*  Copyright 2013, Digilent Inc.                                       */
/************************************************************************/
/* deIPcK core WiFi library
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
/*	Defines the core C++ class for WiFi support                         */
/*  with the deIPck network libraries                                   */
/*																		*/
/*	This is not the WiFi adaptor, this defines the minimal class	    */
/*	for WiFi support													*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	10/19/2011(KeithV): Created											*/
/*																		*/
/************************************************************************/
#include <DEIPcK.h>
#include <DEWFcK.h>

DEWFcK::DEWFcK()
{
    _pNwWF = NULL;
}

bool  DEWFcK::setWF(const NWWF * pNwWF)
{
    if(_pNwWF == NULL)
    {
        _pNwWF  = pNwWF;
    }
    else
    {
        return(false);
    }

    return(_pNwWF != NULL);
}

bool DEWFcK::deIPInit(void)
{
    if(_pNwWF == NULL && DEIPcK::deIPInit())
    {
        setWF(deWFGetWF());
    }

    return(_pNwWF != NULL  && DEIPcK::deIPInit());
}

bool DEWFcK::isWFInitialized(void)
{
    return(isWFInitialized(NULL));
}
bool DEWFcK::isWFInitialized(IPSTATUS * pStatus)
{
    if(_pNwWF == NULL)
    {
        deIPInit();
    }
    return(_pNwWF != NULL && _pNwWF->IsInitialized(pStatus));
}

/*****************************************************************************
  Function:
    int DEWFcK::connect(int connectionID)
    int DEWFcK::connect(int connectionID, DEIPcK::STATUS * pStatus)
    int DEWFcK::connect(const char * szSsid)
    int DEWFcK::connect(const char * szSsid, DEIPcK::STATUS * pStatus)
    int DEWFcK::connect(const char * szSsid, WEP40KEY& keySet, int iKey)
    int DEWFcK::connect(const char * szSsid, WEP40KEY& keySet, int iKey, DEIPcK::STATUS * pStatus)
    int DEWFcK::connect(const char * szSsid, WEP104KEY& keySet, int iKey)
    int DEWFcK::connect(const char * szSsid, WEP104KEY& keySet, int iKey, DEIPcK::STATUS * pStatus)
    int DEWFcK::connect(const char * szSsid, const char * szPassPhrase)
    int DEWFcK::connect(const char * szSsid, const char * szPassPhrase, DEIPcK::STATUS * pStatus)
    int DEWFcK::connect(const char * szSsid, WPA2KEY& key)
    int DEWFcK::connect(const char * szSsid, WPA2KEY& key, DEIPcK::STATUS * pStatus)
    int DEWFcK::connect(SECURITY security, const char * szSsid, const char * szPassPhrase)
    int DEWFcK::connect(SECURITY security, const char * szSsid, const char * szPassPhrase, DEIPcK::STATUS * pStatus)
    int DEWFcK::connect(SECURITY security, const char * szSsid, const byte * rgbKey, int cbKey, int iKey)
    int DEWFcK::connect(SECURITY security, const char * szSsid, const byte * rgbKey, int cbKey, int iKey, DEIPcK::STATUS * pStatus)

  Description:
	Sets up a connection to the WiFi AP

  Parameters:
    connectionID    - The connection ID or Profile already stored on the MRF24WB0M to use. If 0 is specified the default parameters as in WF_Config.h are used.
    security        - One of the security key types as defined in the DEWFcK::SECURITY enum type.
    szSsid          - A zero terminate string of the WiFi SSID to connect to.
    rgbKey          - an array of bytes that contains the key information. This may have characters or a string if appropriate for the sercurity type used.
    cbKey           - The number of bytes in rgbKey.
    keySet          - The 4 WEP keysets, if WEP40 or WEP104 is used.
    iKey            - 0 based index into the WEP key set to specify the key to use
    key             - The WPA(2) key (32 bytes).
    szPassPhrase    - The WPA(2) passphrase if a key is not used
    pStatus         - A point to a DEIPcK::STATUS to return the status of the connect process.
  
  Returns:
	The connection/Profile ID that is in use. If 0 is returned the connection process failed.

  Remarks:
    This method returns immediately and the connection process is started. Some form of isConnected should be called to determine if the connection is made
    If the WPA(2) key must be calculated, this process will start and will typically take 30 seconds to complete.

 ***************************************************************************/
bool DEWFcK::wfConnect(const char * szSsid)
{
    return(wfConnect(szSsid, (IPSTATUS *) NULL));
}
bool DEWFcK::wfConnect(const char * szSsid, IPSTATUS * pStatus)
{
    return(wfConnect(DEWF_SECURITY_OPEN, szSsid, NULL, 0, pStatus));
}

bool DEWFcK::wfConnect(const char * szSsid, WEP40KEY& keySet, int iKey)
{
    return(wfConnect(szSsid, keySet, iKey, NULL));
}
bool DEWFcK::wfConnect(const char * szSsid, WEP40KEY& keySet, int iKey, IPSTATUS * pStatus)
{
    return(wfConnect(DEWF_SECURITY_WEP_40, szSsid, (const byte *) &keySet, iKey, pStatus));
}

bool DEWFcK::wfConnect(const char * szSsid, WEP104KEY& keySet, int iKey)
{
    return(wfConnect(szSsid, keySet, iKey, NULL));
}
bool DEWFcK::wfConnect(const char * szSsid, WEP104KEY& keySet, int iKey, IPSTATUS * pStatus)
{
    return(wfConnect(DEWF_SECURITY_WEP_104, szSsid, (const byte *) &keySet, iKey, pStatus));
}

bool DEWFcK::wfConnect(const char * szSsid, const char * szPassPhrase)
{
    return(wfConnect(szSsid, szPassPhrase, NULL));
}
bool DEWFcK::wfConnect(const char * szSsid, const char * szPassPhrase, IPSTATUS * pStatus)
{
    return(wfConnect(DEWF_SECURITY_WPA2_WITH_PASS_PHRASE, szSsid, (const byte *) szPassPhrase, 0, pStatus));
}

bool DEWFcK::wfConnect(const char * szSsid, WPA2KEY& key)
{
    return(wfConnect(szSsid, key, NULL));
}
bool DEWFcK::wfConnect(const char * szSsid, WPA2KEY& key, IPSTATUS * pStatus)
{
    return(wfConnect(DEWF_SECURITY_WPA2_WITH_KEY, szSsid, (const byte *) &key, 0, pStatus));
}

bool DEWFcK::wfConnect(SECURITY security, const char * szSsid, const char * szPassPhrase)
{
    return(wfConnect(security, szSsid, szPassPhrase, NULL));
}
bool DEWFcK::wfConnect(SECURITY security, const char * szSsid, const char * szPassPhrase, IPSTATUS * pStatus)
{
    return(wfConnect(security, szSsid, (const byte *) szPassPhrase, 0, pStatus));
}

bool DEWFcK::wfConnect(SECURITY security, const char * szSsid, const byte * rgbKey, int iKey)
{
    return(wfConnect(security, szSsid, rgbKey, iKey, NULL));
}
bool DEWFcK::wfConnect(SECURITY security, const char * szSsid, const byte * rgbKey, int iKey, IPSTATUS * pStatus)
{
    IPSTATUS status = ipsFailed;

    deIPInit();

    if(isWFInitialized(&status))
    {
        switch(_wfState)
        {
            case idle:
            case scanReady:
            case keygenReady:
            case connecting:
                if(_pNwWF->Connect(security, (const uint8_t *) szSsid, rgbKey, iKey, true, &status))
                {
                    _wfState = connected;
                }
                else if(IsIPStatusAnError(status))
                {
                    _wfState = idle;
                }
                break;

            default:
                status = ipsInvalidOperation;
                break;
        }
    }

    AssignStatusSafely(pStatus, status);
    return(_wfState == connected);
}

/*****************************************************************************
  Function:
    void DEWFcK::disconnect(int conID)
 
  Description:
	Drops the connection to the AP

  Parameters:
    conID    - Disconnects the WiFi and frees the connection profile if it is an in memory profile
  
  Returns:
	NONE

  Remarks:

 ***************************************************************************/
void DEWFcK::wfDisconnect(void)
{
    if(_pNwWF != NULL)
    {
        _pNwWF->Disconnect();
        _wfState = idle;
    }
}

/*****************************************************************************
  Function:
    bool DEWFcK::beginScan(void)
    bool DEWFcK::beginScan(WFSCAN scanType)
    bool DEWFcK::beginScan(int connectionID)
    bool DEWFcK::beginScan(int connectionID, WFSCAN scanType)
 
  Description:
	Scan for a WiFi SSID based on profile or connection ID.

  Parameters:
    connectionID    - Scan for the network defined by the specifed profile, or all networks if 0/WF_SCAN_ALL is specified or omitted
    scanType        - WF_ACTIVE_SCAN or WF_PASSIVE_SCAN or WF_PASSIVE_SCAN if omitted
  
  Returns:
	True if the the scan got started, false if not.. usually becasue an invalid connectionID was given.

  Remarks:
    We have to wait for a scan to finish before we can do any other hardware stuff, so this is a harsh call
    in that once connected this can cause problems or the connection can cause problem for this
    That is why once we are conneced, this call will fail, we can't run it.

 ***************************************************************************/
bool DEWFcK::wfScan(WFSCAN scanType, int * pcNetworks, IPSTATUS * pStatus)
{
    // make sure we are initialized
    deIPInit();

    if(isWFInitialized(pStatus))
    {

        switch(_wfState)
        {
            case idle:
            case scanReady:
            case keygenReady:
                if(_pNwWF->StartScan(scanType, pStatus))
                {
                    _wfState = scanning;
                }
                break;

            case scanning:
               if(_pNwWF->IsScanDone((int32_t *) pcNetworks))
               {
                    AssignStatusSafely(pStatus, ipsSuccess);
                    _wfState = scanReady;
                    return(true);
               }
               else
               {
                    AssignStatusSafely(pStatus, ipsScanning);
               }
               break;

            default:
                AssignStatusSafely(pStatus, ipsInvalidOperation);
                break;
        }
    }

    return(false);
}

/*****************************************************************************
  Function:
    bool DEWFcK::getScanInfo(int iNetwork, SCANINFO * pscanInfo)

    Description:
	    Returns the the AP (router) info for the specifed network scanned.

  Parameters:
    iNetwork      - a zero based index that is less than the number of networks returned by isScanDone.
    pscanInfo     - A point to a SCANINFO to return the AP (router) information.

  Returns:
	True if the AP information is returned, false if there is no information or the scan is not done.

  Remarks:
    This may be called at any time after isScanDone succeeds
 ***************************************************************************/
bool DEWFcK::getScanInfo(int iNetwork, SCANINFO * pscanInfo)
{
    if(isWFInitialized(NULL) && _wfState == scanReady)
    {
        if(_pNwWF->GetScanResult(iNetwork, pscanInfo))
        {
            // put in a NULL terminator if we have room
            if(pscanInfo->ssidLen < DEWF_MAX_SSID_LENGTH)
            {
                pscanInfo->ssid[pscanInfo->ssidLen] = '\0';
            }
            return(true);
        }
    }

    return(false);
}

