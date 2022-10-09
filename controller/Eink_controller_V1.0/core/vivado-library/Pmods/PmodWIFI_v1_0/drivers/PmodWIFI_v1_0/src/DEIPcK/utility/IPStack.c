/************************************************************************/
/*                                                                      */
/*  IpStack.c   Managment of the IPSTACK data structure                 */
/*              used to deal with the IP datagram and payload           */
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
/*  Module Description: 												*/
/*																		*/
/*	Code supporting adaptors to help build a frame for transmission  	*/
/*	or reception.   													*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	7/3/2012(KeithV): Created											*/
/*																		*/
/************************************************************************/

#include "deIP.h"
static HRRHEAP          g_hSocketHeap = NULL;

#if defined(__MICROBLAZE__)||defined(__arm__)
const IPv4 IPv4BROADCAST  = {{0xFF, 0xFF, 0xFF, 0xFF}};
const IPv4 IPv4NONE       = {{0x00, 0x00, 0x00, 0x00}};    // RFC xxx
const IPv6 IPv6NONE       = {{0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}};    // RFC xxx
#else
const IPv4 IPv4BROADCAST  = {.u8 = {0xFF, 0xFF, 0xFF, 0xFF}};
const IPv4 IPv4NONE       = {.u8 = {0x00, 0x00, 0x00, 0x00}};    // RFC xxx
const IPv6 IPv6NONE       = {.u8 = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}};    // RFC xxx
#endif

/*****************************************************************************
  Function:
	bool IPSInitScratchMemory(uint8_t pSMem, uint32_t cbSMem)

  Description:
        Creates a heap to be used to get some scratch memory for use with sockets
        In particular it will set up memory for sockets, ipStacks and Page manager headers.
        You MUST use IPGetScratchMemorySize(cEstSockets) to get the size needed for this

  Parameters:
	pSMem:      A pointer to the memory to use
        cbSMem:     How many bytes the memory is; must use IPGetScratchMemorySize(cEstSockets)

  Returns:
        None

  ***************************************************************************/
bool IPSInit(uint8_t * pScratchMem, uint32_t cbScratchMem, uint32_t cEstSockets)
{
    uint32_t cbSocketHeap = IPSGetSocketHeapSize(cEstSockets);

    // somewhere in the C only stack we need to init the board
    // this may be the wrong place to do it.
#if !defined(MPIDE)
    static bool fCallBoardInit = true;
    if(fCallBoardInit)
    {
        InitBoard();
        fCallBoardInit = false;
    }
#endif

    if(pScratchMem != NULL)
    {
        if(g_hSocketHeap != NULL || cbSocketHeap > cbScratchMem)
        {
            return(false);
        }

        g_hSocketHeap = RRHPInit(pScratchMem, cbSocketHeap);

        if(g_hSocketHeap == NULL)
        {
            IPSClearSocketHeap();
            return(false);
        }
    }

    // we do not want to define a default socket memory
    else
    {
        IPSClearSocketHeap();
    }

    LLInitAdaptorList();
    UDPInitSockets();
    TCPInitSockets();

    return(true);
}

void IPSClearSocketHeap(void)
{
    RRHPTerminate(g_hSocketHeap);
    g_hSocketHeap = NULL;
}

TCPSOCKET * IPSGetSocketFromSocketHeap(void)
{
    return((TCPSOCKET*)RRHPAlloc(g_hSocketHeap, sizeof(TCPSOCKET)));
}

void IPSReleaseSocket(TCPSOCKET * pSocket)
{
    if(pSocket != NULL)
    {
        RRHPFree(g_hSocketHeap, pSocket);
    }
}

uint16_t IPSGetPayloadFromAdaptor(IPSTACK * pIpStack, uint16_t cbAlloc)
{
    if(pIpStack != NULL)
    {

        // clean up the current payload
        if(pIpStack->pPayload != NULL)
        {
            // see if we can just use the current payload
            if(cbAlloc <= pIpStack->cbPayload)
            {
                memset(pIpStack->pPayload, 0, pIpStack->cbPayload);
                pIpStack->cbPayload = cbAlloc;
            }
            else if(pIpStack->fFreePayloadToAdp)
            {
                RRHPFree(pIpStack->pLLAdp->pNwAdp->hAdpHeap, pIpStack->pPayload);
            }

            pIpStack->pPayload = NULL;
            pIpStack->cbPayload = 0;
        }

        if( cbAlloc > pIpStack->cbPayload &&
            (pIpStack->pPayload = RRHPAlloc(pIpStack->pLLAdp->pNwAdp->hAdpHeap, cbAlloc)) != NULL)
        {
            pIpStack->cbPayload = cbAlloc;
            pIpStack->fFreePayloadToAdp = true;
        }

        return(pIpStack->cbPayload);
    }

    return(0);
}

IPSTACK * IPSGetIpStackFromAdaptor(const LLADP * pLLAdp, uint32_t type, IPSTATUS * pStatus)
{
    uint8_t * pIpStackBuff = NULL;
    IPSTACK * pIpStack = NULL;

    if(pLLAdp == NULL)
    {
        AssignStatusSafely(pStatus, ipsAdaptorMustBeSpecified);
        return(NULL);
    }
    else if(pLLAdp->pNwAdp->hAdpHeap == NULL)
    {
        AssignStatusSafely(pStatus, ispOutOfMemory);
        return(NULL);
    }

    if((pIpStackBuff = (u8*)RRHPAlloc(pLLAdp->pNwAdp->hAdpHeap, IPStackEntrySize)) == NULL)
    {
        AssignStatusSafely(pStatus, ipsIpStackAllInUse);
        return(NULL);
    }

    if((pIpStack = IPSInitIpStack(pLLAdp, pIpStackBuff, type)) == NULL)
    {
        AssignStatusSafely(pStatus, ipsUnsupportedTransportProtocol);
        RRHPFree(pLLAdp->pNwAdp->hAdpHeap, pIpStackBuff);
        return(NULL);
    }

    AssignStatusSafely(pStatus, ipsSuccess);
    return(pIpStack);
}

IPSTACK * IPSInitIpStack(const LLADP * pLLAdp, void * pIpStackBuff, uint32_t type)
{
    IPSTACK * pIpStack = (IPSTACK *) pIpStackBuff;

    // nothing open
    if(pIpStackBuff == NULL)
    {
        return(NULL);
    }

    // take this one
    // build it up to a default IPSTACK with pointers set in
    // we are clearing more than the IPSTACK, we are clearing all of the
    // following space for the headers.
    memset(pIpStackBuff, 0, IPStackEntrySize);

    pIpStack->fFreeIpStackToAdp     = true;

    pIpStack->headerOrder           = MACHINE_ORDER;
    pIpStack->pLLAdp                = pLLAdp;

    pIpStack->pFrameII              = (ETHERNETII_FRAME*)(((void *) pIpStack) + sizeof(IPSTACK));
    pIpStack->cbFrame               = sizeof(ETHERNETII_FRAME);

    pIpStack->pIPHeader             = (((void *) pIpStack->pFrameII) + sizeof(ETHERNETII_FRAME));

    if(ILIsIPv6(pLLAdp))
    {
        pIpStack->etherType         = ethertypeIPv6;
        pIpStack->cbIPHeader        = sizeof(IPv6HDR);
        pIpStack->pTransportHeader  = (pIpStack->pIPHeader + sizeof(IPv6HDR));
    }
    else
    {
        pIpStack->etherType         = ethertypeIPv4;
        pIpStack->cbIPHeader        = sizeof(IPv4HDR);
        pIpStack->pTransportHeader  = (pIpStack->pIPHeader + sizeof(IPv4HDR));
    }

    switch(type)
    {
        case ippnICMP:
            pIpStack->pTransportHeader	= NULL;
            pIpStack->cbTranportHeader 	= 0;
            pIpStack->protocol          = ippnICMP;
            break;

        case ippnTCP:
            pIpStack->cbTranportHeader 	= sizeof(TCPHDR);
            pIpStack->protocol          = ippnTCP;
            break;

        case ippnUDP:
            pIpStack->cbTranportHeader 	= sizeof(UDPHDR);
            pIpStack->protocol          = ippnUDP;
            break;

        case ethertypeARP:
            pIpStack->pTransportHeader	= NULL;
            pIpStack->cbTranportHeader 	= 0;
            pIpStack->pIPHeader         = NULL;
            pIpStack->cbIPHeader        = 0;
            pIpStack->etherType         = ethertypeARP;
            break;

        default:
            return(NULL);
    }

    // put some defaults in
    // from here in, the IPSTACK values could be wrong, but we are putting something in.
    pIpStack->pPayload                  = NULL;
    pIpStack->cbPayload                 = 0;

    // build up the stack and headers with defaults
    // broadcast MAC and IP
    // protocol assumes TCP, but that can be changed later.
    // this should be an assert, it should never fail as this is
    // built from scratch and there should be no errors
    if(!IPSConstructIpStackHeaders(pIpStack, NULL))
    {
        return(NULL);
    }

    return(pIpStack);
}

IPSTACK *  IPSRelease(IPSTACK * pIpStack)
{
    if(pIpStack != NULL)
    {
        // the only way fHeldBySend can be set is if we
        // did a LLSend and it is on the wait for send stack
        // will be released automatically when the send is done
        // If it is on the send stack, we do not do anything.

        if(!IPSIsInUse(pIpStack))
        {
            // if we actually free something, then and only then clear the pointers
            // This payload may be resused in things like ARP; but are not allocated in the scratch heap
            if(pIpStack->fFreePayloadToAdp)
            {
                pIpStack->fFreePayloadToAdp = false;
                RRHPFree(pIpStack->pLLAdp->pNwAdp->hAdpHeap, pIpStack->pPayload);
                pIpStack->pPayload = NULL;
                pIpStack->cbPayload = 0;
            }

            if(pIpStack->fFreeIpStackToAdp)
            {
                pIpStack->fFreeIpStackToAdp = false;
                RRHPFree(pIpStack->pLLAdp->pNwAdp->hAdpHeap, pIpStack);
            }
        }
    }

    return(NULL);
}

IPSTACK *  IPSRefresh(IPSTACK * pIpStack, const LLADP * pLLAdp, IPSTATUS * pStatus)
{
    AssignStatusSafely(pStatus, ipsSuccess);
    if(pIpStack == NULL)
    {
        pIpStack = IPSGetIpStackFromAdaptor(pLLAdp, ippnTCP, pStatus);
    }
    else
    {
        pIpStack =  IPSSwapSrcAndDest(pIpStack);        
    }

    if(pIpStack != NULL)
    {
        // the payload may have a pointer in it that we are going to clear
        // that pointer may or may not be from the heap; but if it is not from
        // the heap, the pointer will be outside of the heap ranage and be ignored
        // by the heap manager with no damage.
        if(pIpStack->fFreePayloadToAdp)
        {
            RRHPFree(pIpStack->pLLAdp->pNwAdp->hAdpHeap, pIpStack->pPayload);
        }
        pIpStack->cbPayload             = 0;
        pIpStack->pPayload              = NULL;

        switch(pIpStack->protocol)
        {
            case ippnUDP:
                pIpStack->pUDPHdr->cbHdrData    = sizeof(UDPHDR);
                pIpStack->pUDPHdr->checksum     = 0;
                break;

            case ippnTCP:
                pIpStack->pTCPHdr->u16Flags     = 0;
                pIpStack->pTCPHdr->dataOffset   = sizeof(TCPHDR)/sizeof(uint32_t);
                pIpStack->pTCPHdr->urgentPtr    = 0;
                pIpStack->pTCPHdr->checksum     = 0;
                break;

            default:
                break;
        }
    }

    return(pIpStack);
}


// this puts to order and fills in all of the stack pointers
// payload must at least point to the frame
// or it must already be parsed, it can just change order
bool IPSParseToOrder(IPSTACK * pIpStack, uint32_t Order)
{
    uint32_t        state               = ipsIpStackNotParsed;
    const bool      fInMachineOrder     = (pIpStack->headerOrder == MACHINE_ORDER);
    const bool      fSwitchingOrder     = (pIpStack->headerOrder != Order);
    bool            fInMachineOrderT    = fInMachineOrder;
    uint16_t        cbT                 = 0;
    uint16_t        etpnT               = 0;
     
    // see if we are already done.
    if(pIpStack->fFrameIsParsed && !fSwitchingOrder)
    {
        return(true);
    }

    while(state != ipsSuccess)
    {
        switch(state)
        {

            // in the first state we must get the frame info
            case ipsIpStackNotParsed:

                fInMachineOrderT = fInMachineOrder;

                // if parsed, just get our size
                if(pIpStack->fFrameIsParsed)
                {
                    cbT = pIpStack->cbFrame;
                }

                // if not parsed, what we are parsing is in the payload pointer
                else
                {
                    pIpStack->pFrameII  = (ETHERNETII_FRAME *) pIpStack->pPayload;
                    cbT = pIpStack->cbPayload;
                }

                // if we are switching order
                if(fSwitchingOrder)
                {
                    cbT = ExEthernetFrameHeader(pIpStack->pFrameII, cbT, fInMachineOrderT);
                    fInMachineOrderT = !fInMachineOrder;
                }

                if(cbT < sizeof(ETHERNETII_FRAME))
                {
                    state = ipsIpStackParsingError;
                    break;
                }

                pIpStack->etherType = pIpStack->pFrameII->etherType;
                if(!fInMachineOrderT)
                {
                    ExEndian(&pIpStack->etherType, sizeof(ETHERTYPE));
                }
                
                pIpStack->fIEEE802Frame = IsIEEE802(pIpStack->etherType);
                if(pIpStack->fIEEE802Frame)
                {
                    if(cbT < sizeof(ETHERNET_802_FRAME))
                    {
                        state = ipsIpStackParsingError;
                        break;
                    }

                    pIpStack->etherType = pIpStack->pFrame802->snap.etherType;
                    if(!fInMachineOrderT)
                    {
                        ExEndian(&pIpStack->etherType, sizeof(ETHERTYPE));
                    }
                    pIpStack->cbFrame = sizeof(ETHERNET_802_FRAME);
                }
                else
                {
                    pIpStack->cbFrame = sizeof(ETHERNETII_FRAME);
                }
    
                // update payload and state
                if(!pIpStack->fFrameIsParsed)
                {
                    pIpStack->pPayload  += pIpStack->cbFrame;
                    pIpStack->cbPayload -= pIpStack->cbFrame;
                }

                // go to the next state
                state = pIpStack->etherType;    
                break;
    
            case ethertypeIPv4:

                // if parsed, just get our size
                if(pIpStack->fFrameIsParsed)
                {
                    cbT = pIpStack->cbIPHeader;
                }

                // if not parsed, what we are parsing is in the payload pointer
                else
                {
                    pIpStack->pIPv4Hdr  = (IPv4HDR *) pIpStack->pPayload;
                    cbT = pIpStack->cbPayload;
                }

                if(cbT < sizeof(IPv4HDR))
                {
                    state = ipsIpStackParsingError;
                    break;
                }

                // no Endian to worry on this one, it is only a byte long
                pIpStack->cbIPHeader = pIpStack->pIPv4Hdr->cdwHeader * sizeof(uint32_t);

                if(pIpStack->cbIPHeader > cbT)
                {
                    state = ipsIpStackParsingError;
                    break;
                }

                if(!pIpStack->fFrameIsParsed)
                {
                    uint16_t cbTotal = pIpStack->pIPv4Hdr->cbTotal;

                    pIpStack->protocol = pIpStack->pIPv4Hdr->protocol;
                    if(!fInMachineOrder)
                    {
                       ExEndian(&cbTotal, sizeof(uint16_t));
                    }

                    if(cbTotal > pIpStack->cbPayload)
                    {
                        state = ipsIpStackParsingError;
                        break;
                    }

                    pIpStack->pPayload      += pIpStack->cbIPHeader;

                    // this is very important, we must truncate junk at the end of the payload
                    // cbTotal MUST come from what is specified in the header, and cbPayload MUST
                    // represent the value that cbTotal defines (less the IP header as that is part of cbTotal).
                    // this MUST be an "=" calculation NOT a -= cbIPHeader!
                    pIpStack->cbPayload     = cbTotal - pIpStack->cbIPHeader;
                }
 
                if(fSwitchingOrder)
                {
                    cbT = ExILIPv4Header(pIpStack->pIPv4Hdr, pIpStack->cbIPHeader, fInMachineOrder);
                    
                    // if we are coming from network order
                    // and switching to machine order
                    // and the checksum is not zero, we had a checksum error
                    // that will be the only error that will cause cbT != sizeof(IPv4HDR)
                    if(cbT != sizeof(IPv4HDR))
                    {
                        state = ipsIpStackChecksumError;
                        break;
                    }
                }

                state = pIpStack->protocol;
                break;   

            case ippnUDP:
                state = ipsSuccess;
                
                // parse out the UDP header
                if(!pIpStack->fFrameIsParsed)
                {
                    pIpStack->pUDPHdr  = (UDPHDR *) pIpStack->pPayload;
                    pIpStack->cbTranportHeader = sizeof(UDPHDR);
                    cbT = pIpStack->pUDPHdr->cbHdrData;
                    if(!fInMachineOrder)
                    {
                        ExEndian(&cbT, sizeof(cbT));  
                    }

                    if(cbT < pIpStack->cbPayload)
                    {
                        state = ipsIpStackParsingError;
                        break;
                    }
                    pIpStack->pPayload += sizeof(UDPHDR);
                    pIpStack->cbPayload = cbT - sizeof(UDPHDR);
                }

                // put in proper order and calculate the checksum
                if(fSwitchingOrder)
                {
                    state = ExUDPHeader(pIpStack, fInMachineOrder);
                }
                break;

            case ippnTCP:
                state = ipsSuccess;

                // parse out the TCP header
                if(!pIpStack->fFrameIsParsed)
                {
                    pIpStack->pTCPHdr  = (TCPHDR *) pIpStack->pPayload;
                    pIpStack->cbTranportHeader = pIpStack->pTCPHdr->dataOffset * sizeof(uint32_t);

                    if(pIpStack->cbTranportHeader > pIpStack->cbPayload)
                    {
                        state = ipsIpStackParsingError;
                        break;
                    }
                    pIpStack->pPayload += pIpStack->cbTranportHeader;
                    pIpStack->cbPayload -= pIpStack->cbTranportHeader;
                }

                // put in proper order and calculate the checksum
                if(fSwitchingOrder)
                {
                    state = ExTCPHeader(pIpStack, fInMachineOrder);
                }
                break;

            case ippnICMP:
                if(fSwitchingOrder)
                {
                    cbT =  ExICMP(pIpStack->pPayload, pIpStack->cbPayload, fInMachineOrder);
                    if(cbT != pIpStack->cbPayload)
                    {
                        state = ipsIpStackParsingError;
                        break;
                    }

                    // see if we got a checksum error
                    // because this is the payload, do not make it a hard error
                    if(!fInMachineOrder && pIpStack->pICMPHdr->checksum != 0)
                    {
                        pIpStack->ipss = ipssChecksumError;
                    }
                }
                state = ipsSuccess;
                break;

            case ethertypeARP:
 
                // unfortunately the adaptor may give me a bigger buffer than I think I need.
                if(pIpStack->cbPayload < sizeof(ARPIPv4))
                {
                    state = ipsIpStackParsingError;
                    break;
                }

                etpnT = pIpStack->pARPIPv4->etherType;
                if(!fInMachineOrder)
                {
                    ExEndian(&etpnT, sizeof(etpnT));
                }

                if(etpnT != ethertypeIPv4)
                {
                    state = ipsIpStackNotSupportedPkt;
                    break;
                }

                // get the payload set to the correct size as the adaptor may give us too many bytes with junk at the end
                pIpStack->cbPayload = sizeof(ARPIPv4);
                cbT = sizeof(ARPIPv4);
                if(fSwitchingOrder)
                {
                    cbT = ExARPDatagram(pIpStack->pARPIPv4, pIpStack->cbPayload, fInMachineOrder);
                }

                if(cbT == sizeof(ARPIPv4))
                {
                     state = ipsSuccess;
                }
                else
                {
                   state = ipsIpStackParsingError;
                }
                break;

            case ipsIpStackChecksumError:
                pIpStack->ipss = ipssChecksumError;
                pIpStack->fFrameIsParsed = false;
                return(false);
                break;

            case ipsIpStackParsingError:
                pIpStack->ipss = ipssCorruptPkt;
                pIpStack->fFrameIsParsed = false;
                return(false);
                break;
 
            case ethertypeIPv6:                 // TODO
            case ipsIpStackNotSupportedPkt:
            default:
                pIpStack->ipss = ipssNotSupported;
                pIpStack->fFrameIsParsed = false;
                return(false);
                break;
        }
    }

    if(fSwitchingOrder)
    {
        pIpStack->headerOrder = ~pIpStack->headerOrder;
    }   
    pIpStack->fFrameIsParsed = true;
    return(true);
}

static bool IPSSetFrame(IPSTACK * pIpStack, IPSTATUS * pStatus)
{

    if(pIpStack->cbFrame != sizeof(ETHERNETII_FRAME))
    {
        AssignStatusSafely(pStatus, ipsInvalidFrameSize);
        return(false);
    }

    pIpStack->pFrameII->etherType = pIpStack->etherType;
    pIpStack->fIEEE802Frame     = false;

    // put my MAC address in. 
    memcpy(&pIpStack->pFrameII->macSrc, &pIpStack->pLLAdp->pNwAdp->mac, sizeof(MACADDR));

    // put in the broadcast address, this will be filled in at the last min before
    // transmission when we do a ARP lookup for the IP
    memcpy(&pIpStack->pFrameII->macDest, &MACBROADCAST, sizeof(MACADDR));

    AssignStatusSafely(pStatus, ipsSuccess);
    return(true);
}

// does not calculate checksum; this is calculated when we got to network order
static bool IPSSetHeader(IPSTACK * pIpStack, IPSTATUS * pStatus)
{
    if(ILIsIPv6(pIpStack->pLLAdp))
    {
        memset(pIpStack->pIPv6Hdr, 0, sizeof(IPv6HDR));
        AssignStatusSafely(pStatus, ipsIpStackNotSupportedPkt);
        return(false);
    }
    else
    {
        if(pIpStack->cbIPHeader < sizeof(IPv4HDR))
        {
            AssignStatusSafely(pStatus, ipsInvalidIPv4HedearSize);
            return(false);;
        }

        // Per RFC 791
        pIpStack->cbIPHeader            = sizeof(IPv4HDR);
        pIpStack->pIPv4Hdr->version     = 4;                    
        pIpStack->pIPv4Hdr->cdwHeader   = sizeof(IPv4HDR) / 4;                
        pIpStack->pIPv4Hdr->cbTotal     = sizeof(IPv4HDR) + pIpStack->cbTranportHeader + pIpStack->cbPayload;                
        pIpStack->pIPv4Hdr->ident       = 0; 
        pIpStack->pIPv4Hdr->u16         = 0; 
        pIpStack->pIPv4Hdr->timeToLive  = TIME_TO_LIVE;
        pIpStack->pIPv4Hdr->protocol    = pIpStack->protocol;     // typically ippnICMP, ippnTCP, ippnUDP
        pIpStack->pIPv4Hdr->hdrChecksum = 0;            // for calculations, this is set to 0, RFC 791
        pIpStack->pIPv4Hdr->ipSrc.u32   = pIpStack->pLLAdp->ipMy.ipv4.u32;
        pIpStack->pIPv4Hdr->ipDest.u32  = IPv4BROADCAST.u32; 

        // TODO: Process options
        pIpStack->fOptionPresent        = false;

        return(true);
    }

    AssignStatusSafely(pStatus, ipsIpStackParsingError);
    return(false);
}

// this fills in all of the headers if you have the pointers set up in the stack.
bool IPSConstructIpStackHeaders(IPSTACK * pIpStack, IPSTATUS * pStatus)
{

    bool fRet       = false;
    IPSTATUS status = ipsSuccess;

    if(IPSIsInUse(pIpStack))
    {
        status = ipsIpStackInUse;
    }

    else if(pIpStack->headerOrder != MACHINE_ORDER)
    {
        status = ipsIpStackNotInMachineOrder;
    }

    // check we have our pointers and sizes
    else if(pIpStack->pTransportHeader != NULL && pIpStack->pIPHeader == NULL)
    {
        status = ipsIPv4HedearRequired;
    }

    else if(pIpStack->pFrameII == NULL)
    {
        status = ipsFrameHeaderRequired; 
    }  
 
    else
    {
        fRet = true;
    }

    // make the transport header
    if(fRet && pIpStack->pTransportHeader != NULL)
    {
        switch(pIpStack->protocol)
        {
            case ippnUDP:
                pIpStack->pUDPHdr->cbHdrData       	= sizeof(UDPHDR);
                break;

            case ippnTCP:
                pIpStack->pTCPHdr->dataOffset = sizeof(TCPHDR) / sizeof(uint32_t);
                break;

            default:
                status = ipsUnsupportedTransportProtocol;
                fRet = false;
                break;
        }
    }

    // make the IP header
    if(fRet && pIpStack->pIPHeader != NULL)
    {
        fRet = IPSSetHeader(pIpStack, &status);
    }

    // There is always a frame, make the frame
    if(fRet)
    {
        fRet = IPSSetFrame(pIpStack, &status);
    }

    // put our return codes in
    AssignStatusSafely(pStatus, status);
    if(fRet)
    {
        pIpStack->fFrameIsParsed    = true;
        pIpStack->ipss = ipssNone;
        return(true);
    }
    else
    {
        pIpStack->ipss = ipssCorruptPkt;
        return(false);
    } 
}

// this should work for both MACHINE and NETWORK ORDER
IPSTACK *  IPSSwapSrcAndDest(IPSTACK * pIpStack)
{
    if(pIpStack == NULL ||  !pIpStack->fFrameIsParsed)
    {
        return(NULL);
    }

    switch(pIpStack->protocol)
    {
        // it doesn't matter if this is TCP or UDP header,
        // they both start with the src and dest port.
        case ippnTCP:
        case ippnUDP:
            {
            uint16_t portT              = pIpStack->pUDPHdr->portSrc;
            pIpStack->pUDPHdr->portSrc  = pIpStack->pUDPHdr->portDest;
            pIpStack->pUDPHdr->portDest = portT;
            }
            break;

        // there is no trans port header, nothing to do
        case ippnNone:
            break;

        case ippnICMP:
            break;
            
        default:
            return(NULL);
            break;
    }

    switch(pIpStack->etherType)
    {
        case ethertypeIPv4:
            {
            IPv4    ipv4;

            // something to think about. The RFC we must use the same IP in a transaction
            // If our IP changed, we will be responding with the OLD IP as the RFC says to do
            // however, we will never recieve another packet again because our listening will
            // be on a different IP and a RST will have to be sent.
            // so we need to just switch IPs, not use my current IP if it had changed receiving this.
            ipv4.u32 = pIpStack->pIPv4Hdr->ipSrc.u32;
            pIpStack->pIPv4Hdr->ipSrc.u32 = pIpStack->pIPv4Hdr->ipDest.u32;
            pIpStack->pIPv4Hdr->ipDest.u32 = ipv4.u32;
            }
            break;

        case ethertypeIPv6:
            {
            IPv6    ipv6;

            // same comment as ethertypeIPv4 applies
            memcpy(&ipv6, &pIpStack->pIPv6Hdr->ipSrc, sizeof(IPv6));
            memcpy(&pIpStack->pIPv6Hdr->ipSrc, &pIpStack->pIPv6Hdr->ipDest, sizeof(IPv6));
            memcpy(&pIpStack->pIPv6Hdr->ipDest, &ipv6, sizeof(IPv6));
            }
            break;

        case ethertypeARP:
            // we need to flip the src and dest macs in the ARP packet
            memcpy(&pIpStack->pARPIPv4->macDest, &pIpStack->pARPIPv4->macSrc, sizeof(MACADDR));
            // but we want to make sure we return our mac (get rid of broadcast)
            memcpy(&pIpStack->pARPIPv4->macSrc, &pIpStack->pLLAdp->pNwAdp->mac, sizeof(MACADDR));

            // we need to flip the src and dest IPs in the ARP packet
            memcpy(&pIpStack->pARPIPv4->ipv4Dest, &pIpStack->pARPIPv4->ipv4Src, sizeof(IPv4));
            // lets make sure we always return our IP
            memcpy(&pIpStack->pARPIPv4->ipv4Src, &pIpStack->pLLAdp->ipMy.ipv4, sizeof(IPv4));
            break;

        case ethertypeNone:
            break;

        default:
            return(NULL);
            break;
    }

    // swap the Frame MAC, doesn't matter if 802 header or not as the
    // frame always starts with the Mac addresses
    if(pIpStack->pFrameII != NULL)
    {
            // alwasy make the src my MAC as the dest might have been a boardcast to me.
            memcpy(&pIpStack->pFrameII->macDest, &pIpStack->pFrameII->macSrc, sizeof(MACADDR));
            // always make sure we return our Mac address
            memcpy(&pIpStack->pFrameII->macSrc, &pIpStack->pLLAdp->pNwAdp->mac, sizeof(MACADDR));
    }

    return(pIpStack);
}

bool IPSUpdateARPEntry(IPSTACK * pIpStack)
{
    switch(pIpStack->etherType)
    {
        case ethertypeIPv4:
            return(LLUpdateARPEntry(pIpStack->pLLAdp, &pIpStack->pIPv4Hdr->ipSrc, &pIpStack->pFrameII->macSrc));
            break;

        case ethertypeIPv6:
            return(LLUpdateARPEntry(pIpStack->pLLAdp, &pIpStack->pIPv6Hdr->ipSrc, &pIpStack->pFrameII->macSrc));
            break;

        default:
            break;
    }
    return(false);
}

void IPSPeriodicTasks(void)
{
    static uint32_t fRecursion = false;

    // we want to be able to safely call periodicTasks from anywhere
    // so don't allow recursion.
    if(fRecursion)
    {
        return;
    }
    fRecursion = true;

    SYSPeriodicTasks();
    LLPeriodicTasks();
    ILPeriodicTasks();
    TCPPeriodicTasks();
    DHCPPeriodicTasks();
    DNSPeriodicTasks();
    SNTPPeriodicTasks();

    fRecursion = false;
}

