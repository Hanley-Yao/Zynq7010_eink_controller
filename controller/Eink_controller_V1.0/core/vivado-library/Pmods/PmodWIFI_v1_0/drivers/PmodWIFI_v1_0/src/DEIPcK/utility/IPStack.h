/************************************************************************/
/*                                                                      */
/*  IpStack.h   Managment of the IPSTACK data structure                 */
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
#ifndef _IPSTACK_H_
#define _IPSTACK_H_

// IPSTACK stuff
#define IPSIsInUse(a)    (((a)->fOwnedByAdp == true) || ((a)->fWaitingOtherInfo == true))
#define IPSSetToNetworkOrder(a) IPSParseToOrder(a, NETWORK_ORDER)
#define IPSSetToMachineOrder(a) IPSParseToOrder(a, MACHINE_ORDER)

#define IPStackEntrySize (((sizeof(IPSTACK) + sizeof(ETHERNETII_FRAME) + sizeof(IPv6HDR) + sizeof(TCPHDR) + cbTCPOptionSpace + sizeof(uint32_t) - 1)) & ~(sizeof(uint32_t) - 1))
#define IPSGetSocketHeapSize(_cEstSockets) (sizeof(RRHEAP) + (_cEstSockets * (SYSAdjToDerefSize(sizeof(TCPSOCKET)) + sizeof(RRHE))))
#define IPSGetIPStackHeapSize(_cEstSockets, _cbEstSize) (sizeof(RRHEAP) + (_cEstSockets * (SYSAdjToDerefSize(_cbEstSize) + SYSAdjToDerefSize(IPStackEntrySize) + (2 * sizeof(RRHE)))))

IPSTACK * IPSGetIpStackFromAdaptor(const LLADP * pLLAdp, uint32_t type, IPSTATUS * pStatus);
uint16_t IPSGetPayloadFromAdaptor(IPSTACK * pIpStack, uint16_t cbAlloc);
IPSTACK * IPSInitIpStack(const LLADP * pLLAdp, void * pIpStackBuff, uint32_t type);

#define IPSGetSocketMemorySize(_cEstSockets) (IPSGetSocketHeapSize(_cEstSockets))

TCPSOCKET * IPSGetSocketFromSocketHeap(void);
void IPSReleaseSocket(TCPSOCKET * pSocket);

IPSTACK * IPSRelease(IPSTACK * pIpStack);
IPSTACK *  IPSRefresh(IPSTACK * pIpStack, const LLADP * pLLAdp, IPSTATUS * pStatus);
IPSTACK *  IPSSwapSrcAndDest(IPSTACK * pIpStack);

bool IPSConstructIpStackHeaders(IPSTACK * pIpStack, IPSTATUS * pStatus);
bool IPSParseToOrder(IPSTACK * pIpStack, uint32_t Order);
bool IPSUpdateARPEntry(IPSTACK * pIpStack);

#endif // _IPSTACK_H_
