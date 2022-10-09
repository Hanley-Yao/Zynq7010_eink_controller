/************************************************************************/
/*                                                                      */
/*	InternetLayer.c This implements the Internet or IP layer            */
/*                  as specified by RFC 1122                            */
/*                                                                      */
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
/*  Module Description:                                                 */
/*                                                                      */
/*	Code supporting the link layer                                      */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	8/15/2012(KeithV): Created                                          */
/*                                                                      */
/************************************************************************/

#include "deIP.h"
static FFPT ffptIpStackArpWaitList = {NULL, NULL};

int32_t ExILIPv4Header(void * pv, uint32_t cb, bool fStartsInMachineOrder)
{
    IPv4HDR *   pIPv4Hdr    = (IPv4HDR *) pv;

    union
    {
        uint16_t    u16;
        uint8_t     pb[2];
    } uhl;

    if(fStartsInMachineOrder)
    {
        // we do this because if we are making an outbound packet, set the time to live
        // and we have to do this before we calculate the checksum
        pIPv4Hdr->timeToLive  = TIME_TO_LIVE;

        // just ensure the checksum starts out to be zero for our calculation
        pIPv4Hdr->hdrChecksum = 0;
    }
    else
    {
        // checksum should be zero, otherwise there is an error
        pIPv4Hdr->hdrChecksum = CalculateChecksum(0, pv, cb);
    }

    // if there is a checksum error
    if(pIPv4Hdr->hdrChecksum != 0)
    {
        return(0);
    }

    ExEndian(&pIPv4Hdr->cbTotal, sizeof(pIPv4Hdr->cbTotal));
    ExEndian(&pIPv4Hdr->ident, sizeof(pIPv4Hdr->ident));

    if(fStartsInMachineOrder)
    {
        // TODO: not sure how to deal with the fragment offset; we may have to deal with it in machine order and exchange it
        uhl.u16 = pIPv4Hdr->fragOffset;     // this is more complicated than it seems because a shift of 3 must happen
        pIPv4Hdr->frag5     = uhl.pb[1];    // this will truncate the top 3 bits.
        pIPv4Hdr->frag8     = uhl.pb[0];    // this moves all 8 bits.

        // already in proper order
        pIPv4Hdr->hdrChecksum = CalculateChecksum(0, pv, cb);
    }
    else
    {
        uhl.pb[0] = pIPv4Hdr->frag8;
        uhl.pb[1] = pIPv4Hdr->frag5;
        pIPv4Hdr->fragOffset = uhl.u16;

        // don't worry about the checksum because it is supposed to be zero in machine order
    }

    return(sizeof(IPv4HDR));
}

static void ILAddToWaitList(IPSTACK * pIpStack)
{
    if(!IPSIsInUse(pIpStack))
    {
        pIpStack->fWaitingOtherInfo = true;
        pIpStack->ipss = ipssPendingIPOp;
        FFInPacket(&ffptIpStackArpWaitList, pIpStack);
    }   
}

static void ILRemoveFromWaitList(IPSTACK * pIpStack)
{
    if(pIpStack != NULL)
    {
        pIpStack->ipss = ipssNone;
        pIpStack->fWaitingOtherInfo = false;
        FFRemove(&ffptIpStackArpWaitList, pIpStack);
    }
}

static bool ILQueWaitSend(IPSTACK * pIpStack, IPSTATUS * pStatus)
{
    IPSTATUS status;
    bool fRet = false;

    // if this is a DHCP communication, we don't need our IP set up yet
    if(pIpStack->protocol == ippnUDP && pIpStack->pUDPHdr->portPair == (portBOOTPClient | (portBOOTPServer << 16)))
    {
        fRet = LLIsLinked(pIpStack->pLLAdp, &status);
    }

    // but normally we need an IP set up; so don't even get anywhere until the IP is set up.
    else
    {
        fRet = ILIsIPNetworkReady(pIpStack->pLLAdp, &status);
    }

    // now find the destination IP
    if(fRet && !ILIsBroadcastIP(pIpStack) && LLIsBroadcastMAC(pIpStack))
    {
        if(ILIsIPv6(pIpStack->pLLAdp))
        {
            fRet = LLARPLookup(pIpStack->pLLAdp, &pIpStack->pIPv6Hdr->ipDest, &pIpStack->pFrameII->macDest, ARPSendCount, &status);
        }
        else
        {
            fRet = LLARPLookup(pIpStack->pLLAdp, &pIpStack->pIPv4Hdr->ipDest, &pIpStack->pFrameII->macDest, ARPSendCount, &status);
        }
    }

    // success, go send it
    if(fRet)
    {
        // take it off of the wait list
        ILRemoveFromWaitList(pIpStack);          // safe to do if not on list

        // put in the source IP
        if(ILIsIPv6(pIpStack->pLLAdp))
        {
            memcpy(&pIpStack->pIPv6Hdr->ipSrc, &pIpStack->pLLAdp->ipMy.ipv6, sizeof(IPv6));
        }
        else
        {
            pIpStack->pIPv4Hdr->ipSrc.u32 = pIpStack->pLLAdp->ipMy.ipv4.u32;
        }

        // send it off
        fRet = LLSend(pIpStack, &status);
    }

    // otherwise on hard failure we have to recoupe
    else if(IsIPStatusAnError(status))
    {
        ILRemoveFromWaitList(pIpStack);
        pIpStack->ipss = ipssARPFailed;
    }

    // make sure we are on the wait list
    else 
    {
        ILAddToWaitList(pIpStack);              // safe to add many times
    }

    AssignStatusSafely(pStatus, status);
    return(fRet);
}

static void ILProcessWaitList(void)
{
    IPSTACK *  pIpStackCur    = NULL;

    while((pIpStackCur = (IPSTACK*)FFNext(&ffptIpStackArpWaitList, pIpStackCur)) != NULL)
    {
        // process and try to send
        ILQueWaitSend(pIpStackCur, NULL);
    }
}

bool ILIsMyIP(const LLADP * pLLAdp, const void * pIP, bool * pfBroadcast)
{
    if(pfBroadcast != NULL) *pfBroadcast = false;

    // is this even an IPv4?
    if(ILIsIPv6(pLLAdp))
    {
        if(memcmp(&pLLAdp->ipMy.ipv6, &pIP, sizeof(IPv6)) == 0)
        {
            return(true);
        }
        else
        {
            return(false);
        }
    }
    else
    {
        // exact match
        if(pLLAdp->ipMy.ipv4.u32 == ((IPv4 *) pIP)->u32)
        {
            return(true);
        }
        // broadcast match
        else if((((IPv4 *) pIP)->u32 | pLLAdp->submask.ipv4.u32) == IPv4BROADCAST.u32)
        {
            if(pfBroadcast != NULL) *pfBroadcast = true;
            return(true);
        }
        //no match
        else
        {
            return(false);
        }
    }
}

bool ILSetIP(const LLADP * pLLAdp, const void * pIP, void * pIPModify)
{
    if(pLLAdp != NULL && pIP != NULL && pIPModify != NULL)
    {
        memcpy(pIPModify, pIP, ILIPSize(pLLAdp));
        return(true);
    }

    return(false);
}

bool ILSetMyIP(const LLADP * pLLAdp, const void * pMyIP)
{
    if(ILSetIP(pLLAdp, pMyIP, (void *) &pLLAdp->ipMy))
    {
        if(memcmp(&pLLAdp->ipMy, &IPv6NONE, ILIPSize(pLLAdp)) == 0)
        {
            ((LLADP *) pLLAdp)->dhcpState = dhcpDISABLED;
        }
        else
        {
            ((LLADP *) pLLAdp)->dhcpState = dhcpSTATICIP;
        }
        return(true);
    }

    return(false);
}

bool ILIsIPSetup(const LLADP * pLLAdp, IPSTATUS * pStatus)
{
    bool        fRet    = false;
    IPSTATUS    status  = ipsSuccess;

    if(pLLAdp->dhcpState < dhcpSTARTPending)
    {
        status  = ipsIPNotSetup;
    }
    else if(pLLAdp->dhcpState < dhcpSTARTConnected)
    {
        status  = ipsDHCPPending;
    }
    else if(pLLAdp->dhcpState < dhcpENDStates)
    {
        fRet = true;
    }
    else
    {
        status  = ipsDHCPUnknownState;
    }

    AssignStatusSafely(pStatus, status);
    return(fRet);
}

bool ILSend(IPSTACK * pIpStack, IPSTATUS * pStatus)
{
    bool fRet = false;

    // must be parsed
    if(!pIpStack->fFrameIsParsed)
    {
        AssignStatusSafely(pStatus, ipsIpStackNotParsed);
    }

    // can't be in use
    else if(IPSIsInUse(pIpStack))
    {
        AssignStatusSafely(pStatus, ipsIpStackInUse);
    }

    // RFC 1122
    // TODO: in the future we need to look up adaptors for the BEST match
    // We would replace with LLGetBestAdaptor
    else if(pIpStack->pLLAdp == NULL && (pIpStack->pLLAdp = LLGetDefaultAdaptor()) == NULL )
    {
        AssignStatusSafely(pStatus, ipsNoDefaultAdaptorExists);
    }
    
    // not a broadcast IP, but a broadcast MAC, look up the MAC
    else 
    {
        fRet = ILQueWaitSend(pIpStack, pStatus);
    }

    return(fRet);
}

void ILPeriodicTasks(void)
{
    ILProcessWaitList();
}
