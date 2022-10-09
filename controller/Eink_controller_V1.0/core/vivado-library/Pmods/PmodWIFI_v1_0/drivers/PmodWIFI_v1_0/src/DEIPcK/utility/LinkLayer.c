/************************************************************************/
/*                                                                      */
/*	LinkLayer.c     The implementation of the IP linklayer          */
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
/*	Code supporting the link layer                                  */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	7/3/2012(KeithV): Created                                       */
/*                                                                      */
/************************************************************************/

#include "deIP.h"


#if defined(__MICROBLAZE__)||defined(__arm__)
const MACADDR MACBROADCAST   = {{0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}};    // RFC 894
const MACADDR MACNONE        = {{0x00, 0x00, 0x00, 0x00, 0x00, 0x00}};    // RFC 894
#else
const MACADDR MACBROADCAST   = {.u8 = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}};    // RFC 894
const MACADDR MACNONE        = {.u8 = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00}};    // RFC 894
#endif

static FFPT             ffptInputIpStack    = {NULL, NULL};

// needed in DHCP and DNS modules
FFPT                    ffptAdaptors        = {NULL, NULL};

int32_t ExEthernetFrameHeader(void * pv, uint32_t cb, bool fStartsInMachineOrder)
{
    uint8_t *               pb          = (u8*)pv;
    bool                    f802        = false;
    ETHERNETII_FRAME *      pFrameII    = (ETHERNETII_FRAME *) pb;
    ETHERNET_802_FRAME *    pFrame802   = (ETHERNET_802_FRAME *) pb;
    int32_t                 cbRet       = 0;

    // we MUST point to something
    if(pb == NULL  ||  cb < sizeof(ETHERNETII_FRAME))
    {
        return(0);
    }
    cbRet = sizeof(ETHERNETII_FRAME);

    // just advance the pointers with no copy
    pb += sizeof(pFrameII->macDest) + sizeof(pFrameII->macSrc);

    if(fStartsInMachineOrder)
    {
        f802 = IsIEEE802(pFrameII->length);
    }

    ExEndian(pb, sizeof(pFrameII->etherType));
    pb += sizeof(pFrameII->etherType);

    if(!fStartsInMachineOrder)
    {
        f802 = IsIEEE802(pFrameII->length);
    }

   // do IEEE 802 stuff if 802 frame
    if(f802)
    {

        if(cb < sizeof(ETHERNET_802_FRAME))
        {
            return(0);
        }
        cbRet = sizeof(ETHERNET_802_FRAME);

        // dsap, ssap, control
        pb += 3;

        ExEndian(pb, sizeof(pFrame802->snap.orgCode));
        pb += sizeof(pFrame802->snap.orgCode);

        ExEndian(pb, sizeof(pFrame802->snap.etherType));
        pb += sizeof(pFrame802->snap.etherType);
    }

    return(cbRet);
}

int32_t ExARPDatagram(void * pv, uint32_t cb, bool fStartsInMachineOrder)
{
    uint8_t *   pb      = (u8*)pv;
    int32_t     cbRet   = -1;
    ARPIPv4 *   pARPv4  = (ARPIPv4 *) pb;
    ETHERTYPE   et      = ethertypeIPv4;

    // we MUST point to something
    if(pb == NULL || cb < sizeof(ARPIPv4))
    {
        return(0);
    }

    ExEndian(pb, sizeof(pARPv4->hwType));
    pb += sizeof(pARPv4->hwType);

    if(fStartsInMachineOrder)
    {
        et = pARPv4->etherType;
    }

    ExEndian(pb, sizeof(pARPv4->etherType));
    pb += sizeof(pARPv4->etherType);

    if(!fStartsInMachineOrder)
    {
        et = pARPv4->etherType;
    }

    // Length of hardware address + length of protocol address
    //pb += 2;

    // ExEndian(pb, sizeof(pARPv4->operation));
    // pb += sizeof(pARPv4->operation);
    // Length of hardware address + length of protocol address & operation
    pb += 4;

    pb += sizeof(pARPv4->macSrc);

    switch(et)
    {
        case ethertypeIPv4:
            pb   += sizeof(pARPv4->ipv4Src) + sizeof(pARPv4->macDest) + sizeof(pARPv4->ipv4Dest);
            cbRet = sizeof(ARPIPv4);
            break;

        case ethertypeIPv6:
        default:
            return(0);
            break;
        }

    return(cbRet);
}

bool LLSend(IPSTACK * pIpStack, IPSTATUS * pStatus)
{
    bool fRet = false;

    // put in network order
    IPSSetToNetworkOrder(pIpStack);

    // try and send it to the adaptor
    fRet = pIpStack->pLLAdp->pNwAdp->Send(pIpStack, pStatus);

    return(fRet);
}

static bool LLArpSend(LLADP * pLLAdp, LLARP * pLLArp)
{
    // if we shouldn't even be attempting this
    if(pLLArp->arpState != arpStatePending)
    {
        return(false);
    }

    // need to know what the current time is for the
    // failed time, or the retry time
    pLLArp->tStamp = SYSGetMilliSecond();
    if(pLLArp->cRetriesLeft == 0)
    {
        pLLArp->arpState = arpStateFailed;
        return(false);
    }

    // see if this is being held, if it is, we can't put the arp request out yet.
    // so expire the retry time so it will automatically be put on the list for retry
    else if(pLLAdp->ipStack.fOwnedByAdp)
    {
        pLLArp->tStamp  -= ARPRetryTime;
        return(true);
    }

    // alway use whatever is the latest for my IP address
    // remember, we need to fill in both, the dest because we might
    // have been waiting for the ipstack to come available from a previous ARP
    // and the src because our IP address may have changed.
    if(ILIsIPv6(pLLAdp))
    {
        // TODO
    }
    else
    {
        memcpy(&pLLAdp->ipStack.pARPIPv4->ipv4Dest, &pLLArp->ip.ipv4, sizeof(IPv4));        // who I am looking for
        memcpy(&pLLAdp->ipStack.pARPIPv4->ipv4Src, &pLLAdp->ipMy.ipv4, sizeof(IPv4));       // me, who it is from
    }
    pLLAdp->arpIPv4.operation       = arpopRequest;         // We may be using this as a reply, in DHCP. so Always set this as a request

    // now send it
    pLLArp->cRetriesLeft--;
    return(LLSend((IPSTACK *) &pLLAdp->ipStack, NULL));
}

void LLArpServiceTimers(const LLADP * pLLAdp)
{
    uint32_t    i;
    uint32_t    tCur = SYSGetMilliSecond();

    for(i=0; i<pLLAdp->cLLArp; i++)
    {
        switch(pLLAdp->arLLArp[i].arpState)
        {
            case arpStateFailed:

                // after a while we need to recheck to see that the IP was not reassigned
                // and if it previously failed, we need to open this up for a retry.
                if((tCur - pLLAdp->arLLArp[i].tStamp) >= ARPExpiredTime)
                {
                    pLLAdp->arLLArp[i].arpState = arpStateExpired;
                }
                break;

            case arpStateValid:

                // after a while we need to recheck to see that the IP was not reassigned
                // and if it previously failed, we need to open this up for a retry.
                if((tCur - pLLAdp->arLLArp[i].tStamp) >= ARPValidTime)
                {
                    pLLAdp->arLLArp[i].arpState = arpStateExpired;
                }
                break;

            case arpStatePending:

                // if our time has expired
                if((tCur - pLLAdp->arLLArp[i].tStamp) >= ARPRetryTime)
                {
                    LLArpSend((LLADP *) pLLAdp, &pLLAdp->arLLArp[i]);
                }
                break;
    
            default:
                break;
        }    
    }
}

void LLInitAdaptorList(void)
{
    memset(&ffptAdaptors, 0, sizeof(ffptAdaptors));
}

const LLADP * LLAddAdaptor(const NWADP *pNwAdp, void * pAdpMem, uint32_t cbAdpMem, IPSTATUS * pStatus)
{
    LLADP *     pLLAdp      = (LLADP *) pAdpMem;

    // do some error checkikng
    if(pAdpMem == NULL)
    {
        AssignStatusSafely(pStatus, ipsAdpMemIsNULL);
    }
    else if(cbAdpMem < LLGetIPv4ARPMemSize(1))
    {
        AssignStatusSafely(pStatus, ipsAtLeastOneARPEntryIsNeeded);
    }

    // clear the memory
    memset(pAdpMem, 0, cbAdpMem);

    // set up the adaptor
    pLLAdp->arLLArp = (LLARP *) (pAdpMem + sizeof(LLADP));
    pLLAdp->cLLArp  = (cbAdpMem - sizeof(LLADP)) / sizeof(LLARP);

    // save away the adaptor
    pLLAdp->pNwAdp = pNwAdp;

    pLLAdp->ipStack.pLLAdp              = pLLAdp;
    pLLAdp->ipStack.cbFrame             = sizeof(ETHERNETII_FRAME);
    pLLAdp->ipStack.pFrameII            = &pLLAdp->broadcastFrameII;
    pLLAdp->ipStack.etherType           = ethertypeARP;
 
    // now fill in the template IP Datagram
    if(ILIsIPv6(pLLAdp))
    {
        // not implemented yet, an ICMPv6 packet
    }
    else
    {
        // set up the IP Datagram
        pLLAdp->arpIPv4.hwType          = hwtypeEthernet;
        pLLAdp->arpIPv4.etherType       = ethertypeIPv4;
        pLLAdp->arpIPv4.cbhType         = sizeof(MACADDR);
        pLLAdp->arpIPv4.cbpType         = sizeof(IPv4);
        pLLAdp->arpIPv4.operation       = arpopRequest;

        // set our mac address
        memcpy(&pLLAdp->arpIPv4.macSrc, &pNwAdp->mac, sizeof(MACADDR));
        memcpy(&pLLAdp->arpIPv4.macDest, &MACNONE, sizeof(MACADDR));

        // do not set IP addresses
        // leave ip source as zero
        // leave ip dest as zero

        // set the ARP request up as the payload
        pLLAdp->ipStack.cbPayload       = sizeof(ARPIPv4);
        pLLAdp->ipStack.pARPIPv4        = &pLLAdp->arpIPv4;
    }

    // Make the IPSTACK
    IPSConstructIpStackHeaders(&pLLAdp->ipStack, NULL);
    IPSSetToNetworkOrder(&pLLAdp->ipStack);

    // now add this to the Adpator list
    FFInPacket(&ffptAdaptors, pLLAdp);

    AssignStatusSafely(pStatus, ipsSuccess);
    return(pLLAdp);
}

bool LLRemoveAdaptor(const LLADP * pLLAdp)
{
    // we can unlink it for our list so no more
    // input will be associated to this adaptor
    // find it in the list
    FFRemove(&ffptAdaptors, (void *) pLLAdp);

    // the actual IPStacks may still be in use
    // so before clearing the heap, check that
    // everything is free

    return(true);
}

const LLADP * LLGetDefaultAdaptor(void)
{
    // for now, lets put the default adaptor in slot zero
    // maybe in the future we have to do something smarter
    return((LLADP*)FFNext(&ffptAdaptors, NULL));
}

uint32_t LLGetMTUR(const LLADP * pLLAdp)
{
    return(pLLAdp->pNwAdp->cbRxMTU_R);
}

uint32_t LLGetMTUS(const LLADP * pLLAdp)
{
    return(pLLAdp->pNwAdp->cbTxMTU_S);
}

static bool LLFindARPEntry(const LLADP * pLLAdp, const void * pIPRequest, uint32_t *piUse, IPSTATUS * pStatus)
{
    uint32_t    i       = 0;
    uint32_t    tCur    = GetSysTick();
    uint32_t    iQuality        = 0xFFFFFFFF;
    uint32_t    tOldest         = 0;
    uint32_t    tDelta          = 0;
    IPSTATUS    status  = ipsFailed;

    //*piUse = pLLAdp->cLLArp;

    // check to see if this is within our subnet, if not; switch it out for the gateway
//    if((((IPv4 *) pIPRequest)->u32 & pLLAdp->submask.ipv4.u32) != (pLLAdp->ipGateway.ipv4.u32 & pLLAdp->submask.ipv4.u32))
//    {
//        pIPRequest = &pLLAdp->ipGateway.ipv4;
//    }

    // check to see if we have it in the list
    for((*piUse)=0; (*piUse)<pLLAdp->cLLArp; (*piUse)++)
    {
        // see if this is our entry
        if( (pLLAdp->arLLArp[(*piUse)].arpState !=  arpStateUnUsed)   &&
           ((!ILIsIPv6(pLLAdp) && (pLLAdp->arLLArp[(*piUse)].ip.ipv4.u32 == ((IPv4 *) pIPRequest)->u32)) ||
           (ILIsIPv6(pLLAdp) && memcmp(&pLLAdp->arLLArp[(*piUse)].ip.ipv6, pIPRequest, sizeof(IPv6)) == 0))    )
        {
            switch(pLLAdp->arLLArp[(*piUse)].arpState)
            {
                case arpStateValid:
                    status = ipsSuccess;
                     break;

                case arpStatePending:
                    status = ipsARPPending;
                    break;
        
                case arpStateFailed:
                    status = ipsARPFailedToResolve;
                    break;
        
                // we have to send an ARP request!
               case arpStateExpired:
               default:
                    status = ipsARPExistingIndex;
                    break;
            }

            AssignStatusSafely(pStatus, status);
            return(true);
        }
    }

    // if we got here, we do not have this IP in the list
    // and we must fine a best entry to use

    // We don't want duplicates in our ARP Cache, so only go looking for
    // a new ARP entry to use if we did not find an IP entry in the cache already.
 
    for(i=0; i<pLLAdp->cLLArp; i++)
    {

        // tDelta is ONLY truely valid for the the wrap time of the
        // SysTick value. This could be as little as 107s on an 80MHz PIC32
        // but we only use the oldest time as a secondary selector to keep us from thrashing
        // on a slot. If the time delay is more than the wrap time of the clock, we may
        // thrash once, but it will not be a sustained thrashing.
        tDelta = tCur - pLLAdp->arLLArp[i].tStamp;

        switch(pLLAdp->arLLArp[i].arpState)
        {
            // This is a totally open slot, a great choice
            // quality number == 0, the best!
            case arpStateUnUsed:
                *piUse = i;
                i = pLLAdp->cLLArp;             // get out
                iQuality = 0;                   // The best quality
                break;

            // this is a pretty good choice, but get the oldest one
            // quality number == 100
            case arpStateFailed:
                if(100 <= iQuality || (100 == iQuality && tDelta > tOldest))
                {
                    iQuality = 100;
                    *piUse = i;
                }
                break;

            // this might get reused, so I want to hold on to the 
            // slot if possible
            // quality number == 200
            case arpStateExpired:
                if(200 <= iQuality || (200 == iQuality && tDelta > tOldest))
                {
                    iQuality = 200;
                    *piUse = i;
                }
               break;

            // really bad choice, but I'd rather wipe it out
            // than not have a slot to get what I know someone wants right
            // NOW, lets make sure it is the oldest one.
            // quality number == 1000
            case arpStateValid:
                if(1000 <= iQuality || (1000 == iQuality && tDelta > tOldest))
                {
                    iQuality = 1000;
                    *piUse = i;
                }
                break;

            // I would rather return an error, than wipe out this entry
            // we are in the process of getting something, so don't take it away
            case arpStatePending:
            default:
                break;
    
        } 

        // we selected a new entry, so save our oldest time.
        if(*piUse == i)
        {                         
            tOldest = tDelta;
        } 
    }
 
    if(*piUse != pLLAdp->cLLArp)
    {
        AssignStatusSafely(pStatus, ipsARPBestNewIndex);
        return(true);
    }

    AssignStatusSafely(pStatus, ipsARPNoCacheEntriesAvailable);
    return(false);
}

// it is important that the ARP list has no duplicate IPs in there.
static LLARP * LLGetARPEntry(const LLADP * pLLAdp, const void * pIPRequest, IPSTATUS * pStatus)
{
    uint32_t    iUse    = pLLAdp->cLLArp;
    IPSTATUS    status  = ipsFailed;
    
    if(!LLFindARPEntry(pLLAdp, pIPRequest,&iUse, &status))
    {
        AssignStatusSafely(pStatus, status);
        return(NULL);
    }

    // we at least got an entry in the table to use
    switch(status)
    {
        // we are going to have to make a request
        // if this entry is not our IP, we must set it up that way
        case ipsARPBestNewIndex:
        default:
            if(ILIsIPv6(pLLAdp))
            {  
                memcpy(&pLLAdp->arLLArp[iUse].ip.ipv6, pIPRequest, sizeof(IPv6));
            }
            else
            {    
                memcpy(&pLLAdp->arLLArp[iUse].ip.ipv4, pIPRequest, sizeof(IPv4));
            }  

        // now that the ARP entry is set up for this IP, we can
        // fall through as if the entry was already set up for our IP

        case ipsARPExistingIndex:
      
            // Fill in things about this cache slot
            pLLAdp->arLLArp[iUse].arpState      = arpStateExpired;
            pLLAdp->arLLArp[iUse].tStamp        = 0;
            pLLAdp->arLLArp[iUse].cRetriesLeft  = 0;

            // we have made an entry, make it look like it is expired
            status = ipsARPExpired;
            break;

        case ipsSuccess:
        case ipsARPPending:
        case ipsARPFailedToResolve:
            // do nothing
            break;
    }  

    // just sent the request out, so we are pending
    AssignStatusSafely(pStatus, status);
    return(&pLLAdp->arLLArp[iUse]); 
}

bool LLARPLookup(const LLADP * pLLAdp, const void * pIPRequest, MACADDR * pMacAddr, uint32_t cSend, IPSTATUS * pStatus)
{
    IPSTATUS    status;
    LLARP * pLLArp = NULL;

    // make sure we have the the latest stuff
    // don't do this as we will get into recursion in Process TCP/UDP/....
    // we don't want to recurs and this is a heavy routine, so just let periodic tasks
    // do the job.
//    LLPeriodicTasks();

    if(!ILIsIPv6(pLLAdp))
    {

        //if this is MY IP, return MY mac
        if(pLLAdp->ipMy.ipv4.u32 == ((IPv4 *) pIPRequest)->u32)
        {
            LLGetMyMac(pLLAdp, pMacAddr);
            return(true);
        }

        // if off subnet point at gateway IP then call LLGETARPEntry
        // check to see if this is within our subnet, if not; switch it out for the gateway
        if((((IPv4 *) pIPRequest)->u32 & pLLAdp->submask.ipv4.u32) != (pLLAdp->ipGateway.ipv4.u32 & pLLAdp->submask.ipv4.u32))
        {
            pIPRequest = &pLLAdp->ipGateway.ipv4;
        }
    }

    // look in the table
    pLLArp = LLGetARPEntry(pLLAdp, pIPRequest, &status);

    if(pLLArp != NULL)
    {
        switch(status)
        {

            // all is good, load the MAC
            case ipsSuccess:
                memcpy(pMacAddr, &pLLArp->mac, sizeof(MACADDR));
                break;

            // we have to go get it.
            case ipsARPExpired:
                // Fill in things about this cache slot
                pLLArp->arpState      = arpStatePending;
                pLLArp->cRetriesLeft  = cSend;
            
                // send the packet
                status = arpStatePending;
                LLArpSend((LLADP *) pLLAdp, pLLArp);
                break;
        }
    }

    // just sent the request out, so we are pending
    AssignStatusSafely(pStatus, status);  
    return(status == ipsSuccess); 
}
bool LLUpdateARPEntry(const LLADP * pLLAdp, const void * pIP, const MACADDR * pMac)
{
    IPSTATUS    status  = ipsSuccess;
    LLARP *     pLLArp  = LLGetARPEntry(pLLAdp, pIP, &status);
    
    if(pLLArp != NULL)
    {    
        // fill in the MAC
        memcpy(&pLLArp->mac, pMac, sizeof(MACADDR));

        // we now have it as valid and the time
        pLLArp->arpState        = arpStateValid;
        pLLArp->tStamp          = SYSGetMilliSecond();
        pLLArp->cRetriesLeft    = 0;
        status  = ipsSuccess;
        return(true);
    }    
    
    return(false);
}

// this all comes from the adaptor, so I know it is not my ARP IPSTACK in the LLAdp.
static void ARPProcess(IPSTACK * pIpStack)
{
    // we know this is an IPv4 arp packet
    // if this is for me, then process the arp packet
    if(pIpStack->pLLAdp->ipMy.ipv4.u32 == pIpStack->pARPIPv4->ipv4Dest.u32)
    {
        // always update our arp table with the known good IP/MAC mapping
        // don't care if this fails or not, we are just updating the ARP table.
        LLUpdateARPEntry(pIpStack->pLLAdp, &pIpStack->pARPIPv4->ipv4Src, &pIpStack->pARPIPv4->macSrc);

        // now do operation specific requests
        switch(pIpStack->pARPIPv4->operation)
        {
            // send a replay
            case arpopRequest:

                // only respond if we have an IP
                if(pIpStack->pLLAdp->dhcpState >= dhcpSTARTConnected)
                {
                    // if this was a request, lets reply
                    pIpStack->pARPIPv4->operation = arpopReply;

                    // switch everything back to him
                    if(IPSSwapSrcAndDest(pIpStack))
                    {
                        LLSend(pIpStack, NULL);
                    }
                }
                break;

            case arpopReply:
            default:
                // do nothing
                break;
        }
    }
    
    // if this is a broadcast ARP replay, pick it up and put it in our cache as this is a broadcast advertise
    else if(    ((pIpStack->pARPIPv4->ipv4Dest.u32 | pIpStack->pLLAdp->submask.ipv4.u32) == IPv4BROADCAST.u32)   &&
                pIpStack->pARPIPv4->operation == arpopReply                                                     )
    {
        LLUpdateARPEntry(pIpStack->pLLAdp, &pIpStack->pARPIPv4->ipv4Src, &pIpStack->pARPIPv4->macSrc);
    }
}

static void LLManagementTask(void)
{
    IPSTACK *   pIpStack    = NULL;
    const LLADP *     pLLAdpCur   = NULL;

    // now see if we have any data coming in
    while((pLLAdpCur = (LLADP*)FFNext(&ffptAdaptors, pLLAdpCur)) != NULL)
    {
        // only look at connected adaptors
        if(pLLAdpCur->pNwAdp != NULL)
        {

            // process any addaptor tasks
            if(pLLAdpCur->pNwAdp->PeriodicTask != NULL)
            {
                pLLAdpCur->pNwAdp->PeriodicTask();
            }

            // if there is data, process it.
            while( (pIpStack = pLLAdpCur->pNwAdp->Read(NULL)) != NULL)
            {
                // set what adaptor this came in on
                pIpStack->pLLAdp = pLLAdpCur;

                // If it was NOT to me, or NOT boardcasted to me, discard
                if( !(  (memcmp(&pIpStack->pFramePl->macDest, &MACBROADCAST, sizeof(MACADDR))                   == 0)   ||
                        (memcmp(&pIpStack->pFramePl->macDest, &pIpStack->pLLAdp->pNwAdp->mac, sizeof(MACADDR))  == 0)   )
                                                    ||
                        // if it came from a broadcast MAC, discard.
                        (memcmp(&pIpStack->pFramePl->macSrc, &MACBROADCAST, sizeof(MACADDR)) == 0)                      )
                {
                    IPSRelease(pIpStack);
                }

                // this must be a frame in Network order
                // see if we can parse the packet, if not, discard it.
                // we could delay this until we take it off of the stack
                // if we are concerned at the speed of this routine
                else if(!IPSParseToOrder(pIpStack, MACHINE_ORDER))
                {
                    IPSRelease(pIpStack);
                }

                // it is ours, and it parsed, put it on the read queue
                else
                {
                    FFInPacket(&ffptInputIpStack, pIpStack);
                }
            }

            // we know the adaptor is active, so
            // update all of the arp timers.
            LLArpServiceTimers(pLLAdpCur);
        }
    }
}

void LLPeriodicTasks(void)
{
    IPSTACK *   pIpStack = NULL;

    //  read our input
    LLManagementTask();

    while((pIpStack = (IPSTACK*)FFOutPacket(&ffptInputIpStack)) != NULL)
    {
        // if we are not bound, we have no business responding to this
        // however, for DHCP to work, we must let UDP packet through.
        if(pIpStack->pLLAdp->dhcpState < dhcpSTARTConnected && !(pIpStack->etherType == ethertypeIPv4 && pIpStack->protocol == ippnUDP))
        {
            IPSRelease(pIpStack);
            continue;
        }

        // It has already been parsed and we know it is for us
        // let's see what we have.

        // so we have a packet to process
        switch(pIpStack->etherType)
        {
            // process an ARP Request, or response
            case ethertypeARP:
                ARPProcess(pIpStack);
                break;

            case ethertypeIPv4:

                switch(pIpStack->protocol)
                {
                    case ippnICMP:
                        ICMPv4Process(pIpStack);
                        break;

                    case ippnTCP:
                        TCPProcess(pIpStack);
                        break;

                    case ippnUDP:
                        UDPProcess(pIpStack);
                        break;
                }
                break;
            
            case ethertypeIPv6:
            default:
                break;

        }
              
        // done with the packet; If this is being held for a send
        // the read won't be released until the send is complete.
        IPSRelease(pIpStack);
    }  
}

