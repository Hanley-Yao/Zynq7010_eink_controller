/************************************************************************/
/*																		*/
/*	ICMP.c  This ICMP messages code that is implemented                 */
/*          as part of the Internet Layer                               */
/*																		*/
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
/*	ICPM Internet Layer implementation             				        */
/*																		*/
/************************************************************************/
/*  Module Description: 												*/
/*																		*/
/*	ICPM Internet Layer implementation             				        */
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	8/14/2012(KeithV): Created - Pretty much only Ping support          */
/*																		*/
/************************************************************************/
#include "deIP.h"


static void ExICMP0(void * pv, bool fStartsInMachineOrder)
{
    UNUSED(fStartsInMachineOrder);

    // indentifier
    ExEndian(pv, sizeof(uint16_t));
    pv += sizeof(uint16_t);

    // sequence
    ExEndian(pv, sizeof(uint16_t));
}

#if defined(ToBeImplemented)

static void ExICMP3(void * pv, bool fStartsInMachineOrder)
{
    UNUSED(pv);
    UNUSED(fStartsInMachineOrder);
}

static void ExICMP5(void * pv, bool fStartsInMachineOrder)
{
    UNUSED(pv);
    UNUSED(fStartsInMachineOrder);
}

static void ExICMP12(void * pv, bool fStartsInMachineOrder)
{
    UNUSED(pv);
    UNUSED(fStartsInMachineOrder);
}

static void ExICMP13(void * pv, bool fStartsInMachineOrder)
{
    UNUSED(pv);
    UNUSED(fStartsInMachineOrder);
}

static void ExICMP15(void * pv, bool fStartsInMachineOrder)
{
    UNUSED(pv);
    UNUSED(fStartsInMachineOrder);
}
#endif

uint32_t ExICMP(void * pv, uint32_t cb, bool fStartsInMachineOrder)
{
    ICMPHDR *   pICMPHdr    = (ICMPHDR*)pv;
    ICMPTYPE    icmpType;
    
    uint32_t    cbRet       = 0;

    if(cb < sizeof(ICMPHDR)) return(0);

    if(fStartsInMachineOrder)
    {
        pICMPHdr->checksum = 0;
        icmpType = pICMPHdr->icmpType;
        ExEndian(&pICMPHdr->icmpType, sizeof(pICMPHdr->icmpType));
    }
    else
    {
        // checksum should be 0, otherwise there is an error.
        pICMPHdr->checksum = CalculateChecksum(0, pv, cb);
        ExEndian(&pICMPHdr->icmpType, sizeof(pICMPHdr->icmpType));
        icmpType = pICMPHdr->icmpType;
    }
    ExEndian(&pICMPHdr->code, sizeof(pICMPHdr->code));

    switch(icmpType)
    {
        case icmpTypeEcho:                  
        case icmpTypeEchoReply:
            if(cb < sizeof(ICMPT0)) return(0);
            ExICMP0(pv + sizeof(ICMPHDR), fStartsInMachineOrder);
            cbRet = cb; // don't know the length of the data, must trust what came in.
            break;
   
        case icmpTypeDestinationUnreachable:
        case icmpTypeSourceQuench:          
        case icmpTypeRedirect:              
        case icmpTypeTimeExceeded:          
        case icmpTypeParameterProblem:      
        case icmpTypeTimestamp:             
        case icmpTypeTimestampReply:        
        case icmpTypeInformationRequest:    
        case icmpTypeInformationReply:      
        default:
            return(0);
    }

    if(fStartsInMachineOrder)
    {
        // already in proper order
        pICMPHdr->checksum = CalculateChecksum(0, pv, cbRet);
    }

    return(cbRet);
}


void ICMPv4Process(IPSTACK * pIpStack)
{

    switch(pIpStack->pICMPHdr->icmpType)
    {
        case icmpTypeEcho:

            // We are going to resuse this inboud packet as the outbound one
            // RFC 792 says swap source and destination change type code

            // set type to reply
            pIpStack->pICMPHdr->icmpType = icmpTypeEchoReply;

            // swap source and dest
            IPSSwapSrcAndDest(pIpStack);

            // now send it
            // Don't care about errors
            ILSend(pIpStack, NULL);

            break;

        case icmpTypeEchoReply:
        case icmpTypeDestinationUnreachable:
        case icmpTypeSourceQuench:          
        case icmpTypeRedirect:              
        case icmpTypeTimeExceeded:          
        case icmpTypeParameterProblem:      
        case icmpTypeTimestamp:             
        case icmpTypeTimestampReply:        
        case icmpTypeInformationRequest:    
        case icmpTypeInformationReply:      
        default:
            return;
    }
}

bool ICMPv4Send(const LLADP * pLLAdp, IPv4 * pIPv4Dest, void * pICMPDgm, uint32_t cbICMPDgm, IPSTATUS * pStatus)
{
	IPSTACK * pIpStack;

	if( (pIpStack = IPSGetIpStackFromAdaptor(pLLAdp, ippnICMP, pStatus)) == NULL)
	{
		return(false);
	}

   	pIpStack->cbPayload          	= cbICMPDgm;
   	pIpStack->pPayload             	= pICMPDgm;

  	pIpStack->pICMPHdr->checksum 	= 0;

	pIpStack->pIPv4Hdr->cbTotal		+= cbICMPDgm;
	pIpStack->pIPv4Hdr->ipDest.u32	= pIPv4Dest->u32;

    return(ILSend(pIpStack, pStatus));
}
   
