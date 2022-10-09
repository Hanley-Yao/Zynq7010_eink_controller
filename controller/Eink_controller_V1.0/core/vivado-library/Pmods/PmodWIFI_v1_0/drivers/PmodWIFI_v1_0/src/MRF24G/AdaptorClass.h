/************************************************************************/
/*                                                                      */
/*  AdaptorClass.h  MRF24-G Adaptor specific code                       */
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
/*      This MRF24-G Adaptor specific code                              */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*  10/16/2012(KeithV): Created                                         */
/*                                                                      */
/************************************************************************/
#ifndef MRF24G_AC
#define MRF24G_AC

#include <DEIPcK.h>
#include <DEWFcK.h>

#ifdef __cplusplus

#define WPACALPSK

class DEMRF24 : public DEWFcK
{
private:
    virtual const NWADP * deIPGetAdaptor(void);
    virtual const NWWF *  deWFGetWF();

public:
    bool wpaCalPSK(const char * szSsid, const char * szPassphrase, WPA2KEY& wpaKey);
};

extern DEMRF24 deIPcK;

// this is to init the code and is place in DEIPcK.cpp
// it is specific for the default adaptor we are using
#ifdef DEIPINCLUDECODEHERE

DEMRF24 deIPcK;

// RAM Page Manager constants for the default socket buffers
// 512 byte page manager 1<<6 = 64 * 128 = 8192
#ifndef pfSocketBuffer
#define pfSocketBuffer 6            // 1<<6 == 64 byte pages
#endif

#ifndef cPagesSocketBuffer
#define cPagesSocketBuffer 128      // 128 pages
#endif
#define cbrgbSocketBufferPageMGR RAMGetPMGRSize(cPagesSocketBuffer, pfSocketBuffer)

#if (cPagesSocketBuffer > 254)
#error cPagesSocketBuffer can not be greater than 254
#endif

// this is the default socket space
// 8K page manager 1<<6 = 64 * 128 = 8,192
// this is the default
uint8_t rgbRamSocketBufferPageMGR[cbrgbSocketBufferPageMGR];
HPMGR hNetworkPMGR = RAMCreatePageMGR(rgbRamSocketBufferPageMGR, sizeof(rgbRamSocketBufferPageMGR), cPagesSocketBuffer, pfSocketBuffer);

#endif

#endif // C++

#endif // MRF24G_AC
