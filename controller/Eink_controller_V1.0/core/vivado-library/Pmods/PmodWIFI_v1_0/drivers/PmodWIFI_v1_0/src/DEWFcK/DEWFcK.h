/************************************************************************/
/*																		*/
/*	DWFIck.h        Defines the core C++ class for WiFi support         */
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
#ifndef _DEWFCK_H
#define  _DEWFCK_H

#ifndef _DEIPCK_H
    #error DEIPcK.h must be included before DEWFcK.h
#endif

#ifdef __cplusplus

class DEWFcK : public DEIPcK
{
private:
    typedef enum
    {
        idle = 0,
        scanReady,
        keygenReady,
        scanning,
        keygen,
        connecting,
        connected,
    } WFSTATE;

    const NWWF *    _pNwWF;
    WFSTATE         _wfState;

    virtual const NWWF * deWFGetWF() = 0;

public:
    const static int    INVALID_CONNECTION_ID = 0;

    DEWFcK();

    virtual bool deIPInit(void);
    bool  setWF(const NWWF * pNwWF);

    bool isWFInitialized(void);
    bool isWFInitialized(IPSTATUS * pStatus);

    bool wfConnect(const char * szSsid);                                                                        // no security
    bool wfConnect(const char * szSsid, IPSTATUS * pStatus);                                                    // no security
    bool wfConnect(const char * szSsid, WEP40KEY& keySet, int iKey);                                            // WEP 40
    bool wfConnect(const char * szSsid, WEP40KEY& keySet, int iKey, IPSTATUS * pStatus);                        // WEP 40
    bool wfConnect(const char * szSsid, WEP104KEY& keySet, int iKey);                                           // WEP 104
    bool wfConnect(const char * szSsid, WEP104KEY& keySet, int iKey, IPSTATUS * pStatus);                       // WEP 104
    bool wfConnect(const char * szSsid, const char * szPassPhrase);                                             // WPA2
    bool wfConnect(const char * szSsid, const char * szPassPhrase, IPSTATUS * pStatus);                         // WPA2
    bool wfConnect(const char * szSsid, WPA2KEY& key);                                                          // WPA2
    bool wfConnect(const char * szSsid, WPA2KEY& key, IPSTATUS * pStatus);                                      // WPA2
    bool wfConnect(SECURITY security, const char * szSsid, const char * szPassPhrase);                          // explicit
    bool wfConnect(SECURITY security, const char * szSsid, const char * szPassPhrase, IPSTATUS * pStatus);      // explicit
    bool wfConnect(SECURITY security, const char * szSsid, const byte * rgbKey, int iKey);                      // explicit
    bool wfConnect(SECURITY security, const char * szSsid, const byte * rgbKey, int iKey, IPSTATUS * pStatus);  // explicit

    void wfDisconnect(void);
 
    bool wfScan(WFSCAN scanType, int * pcNetworks, IPSTATUS * pStatus);
    bool wfScan(int * pcNetworks)
    {
        return(wfScan(DEWF_PASSIVE_SCAN, pcNetworks, NULL));
    }
    bool wfScan(WFSCAN scanType, int * pcNetworks)
    {
        return(wfScan(scanType, pcNetworks, NULL));
    }
    bool wfScan(int * pcNetworks, IPSTATUS * pStatus)
    {
        return(wfScan(DEWF_PASSIVE_SCAN, pcNetworks, pStatus));
    }

    bool getScanInfo(int iNetwork, SCANINFO * pscanInfo);
};

#endif  // __cplusplus

#endif  //  _DEWFCK_H
