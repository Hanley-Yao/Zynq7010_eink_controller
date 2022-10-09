/************************************************************************/
/*																		*/
/*	UDP.c  UDP implementation                						    */
/*          as part of the Transport Layer                              */
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
/*	UDP Transport layer implementation                 				    */
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	9/12/2012(KeithV): Created											*/
/*																		*/
/************************************************************************/
#include "deIP.h"

static FFPT         g_ffptListeningUDPSockets = {NULL, NULL};
static uint16_t     g_nextUDPEphemeralPort = portEphemeralFirst;

uint32_t ExUDPHeader(IPSTACK * pIpStack, bool fStartsInMachineOrder)
{
    uint16_t sum = ~(ippnUDP << 8);

    // checksum of the psuedo header
    if(ILIsIPv6(pIpStack->pLLAdp))
    {
        sum = CalculateChecksum(sum, &pIpStack->pIPv6Hdr->ipSrc, sizeof(IPv6));
        sum = CalculateChecksum(sum, &pIpStack->pIPv6Hdr->ipDest, sizeof(IPv6));
    }
    else
    {
        sum = CalculateChecksum(sum, &pIpStack->pIPv4Hdr->ipSrc, sizeof(IPv4));
        sum = CalculateChecksum(sum, &pIpStack->pIPv4Hdr->ipDest, sizeof(IPv4));
    }

    // must put in network order, and do check sum
    if(fStartsInMachineOrder)
    {
        pIpStack->pUDPHdr->checksum = 0;    // set this to zero for calcluation
        ExEndian(&pIpStack->pUDPHdr->portSrc, sizeof(pIpStack->pUDPHdr->portSrc));
        ExEndian(&pIpStack->pUDPHdr->portDest, sizeof(pIpStack->pUDPHdr->portDest));
        ExEndian(&pIpStack->pUDPHdr->cbHdrData, sizeof(pIpStack->pUDPHdr->cbHdrData));
        sum = CalculateChecksum(sum, pIpStack->pUDPHdr, sizeof(UDPHDR));

        // must do the size twice because we have this in the psuedo header as well
        sum = CalculateChecksum(sum, &pIpStack->pUDPHdr->cbHdrData, sizeof(pIpStack->pUDPHdr->cbHdrData));
    }
    else
    {
        sum = CalculateChecksum(sum, pIpStack->pUDPHdr, sizeof(UDPHDR));

        // must do the size twice because we have this in the psuedo header as well
        sum = CalculateChecksum(sum, &pIpStack->pUDPHdr->cbHdrData, sizeof(pIpStack->pUDPHdr->cbHdrData));

        // switch order
        ExEndian(&pIpStack->pUDPHdr->portSrc, sizeof(pIpStack->pUDPHdr->portSrc));
        ExEndian(&pIpStack->pUDPHdr->portDest, sizeof(pIpStack->pUDPHdr->portDest));
        ExEndian(&pIpStack->pUDPHdr->cbHdrData, sizeof(pIpStack->pUDPHdr->cbHdrData));
    }

    // add the data
    pIpStack->pUDPHdr->checksum = CalculateChecksum(sum, pIpStack->pPayload, pIpStack->cbPayload);

    // RFC 768, if zero and outgoing, make all FFs
    if(fStartsInMachineOrder)
    {
        if(pIpStack->pUDPHdr->checksum == 0)
        {
            pIpStack->pUDPHdr->checksum = 0xFFFF;
        }
    }
    else if(pIpStack->pUDPHdr->checksum != 0)
    {
        return(ipsIpStackChecksumError);
    }

    return(ipsSuccess);
}

void UDPInitSockets(void)
{
    memset(&g_ffptListeningUDPSockets, 0, sizeof(g_ffptListeningUDPSockets));
    g_nextUDPEphemeralPort = portEphemeralFirst;
}

void UDPCloseAllSockets(void)
{
    UDPSOCKET * pSocket = NULL;

    // go until you empty the list.
    while((pSocket = (UDPSOCKET*)FFNext(&g_ffptListeningUDPSockets, NULL)) != NULL)
    {
        UDPClose(pSocket);
    }
}

bool UDPRawSend(const LLADP * pLLAdp, IPSTACK *   pIpStack, const void * pIPvXDest, uint16_t portDest, uint16_t portSrc, const uint8_t * pDatagram, uint32_t cbDatagram, bool fFreeDatagramImmediately, IPSTATUS * pStatus)
{   
    bool        fRet        = false;
    IPSTATUS    status      = ipsSuccess;

    if(pLLAdp == NULL)
    {
        status = ipsAdaptorMustBeSpecified;
    }
    else if(pIpStack == NULL)
    {
        status = ipsIpStackNULL;
    }
    else if(pIPvXDest == NULL)
    {
        status = ipsIPAddressIsNull;
    }
    else if(pDatagram == NULL)
    {
        status = ipsUDPNullDatagram;
    }
    
    // sometimes we want to keep the actual buffer we passed in the IpStack
    // because we will later want to reuse it and don't want it copied and freed
    // the downside is, we have to know that the send is complete somehow; typically
    // would do this if you don't reuse the buffer until we get a response from the
    // remote and thus know we must have sent the datagram already.
    // this is typically NOT the way we would use this, but DHCP Does this extensively
    else if(!fFreeDatagramImmediately)
    {
        pIpStack->pPayload = (void *) pDatagram;
    }
    else if(IPSGetPayloadFromAdaptor(pIpStack, cbDatagram) == cbDatagram)
    {
        // this is ugly to have to copy the data but somewhat required
        // the problem is, when we send we may need to wait while an APR is proformed and that
        // will require that the pDatagram be constant, however on return from this funciton
        // the application may immediately reuse the memory to construct the next datagram
        memcpy(pIpStack->pPayload, pDatagram, cbDatagram);
    }
    else
    {
        status = ispOutOfMemory;
    }

    if(IsIPStatusAnError(status))
    {
        AssignStatusSafely(pStatus, status);
        return(false);
    }

    pIpStack->pUDPHdr->portSrc         	= portSrc;
    pIpStack->pUDPHdr->portDest        	= portDest;
    pIpStack->pUDPHdr->cbHdrData       	+= cbDatagram;
    pIpStack->cbPayload               	= cbDatagram;

    if(ILIsIPv6(pLLAdp))
    {
        pIpStack->pIPv6Hdr->cbPayload	= pIpStack->cbPayload;
        memcpy(&pIpStack->pIPv6Hdr->ipDest, pIPvXDest, sizeof(IPv6));
    }
    else
    {
        pIpStack->pIPv4Hdr->cbTotal += pIpStack->cbPayload;
        memcpy(&pIpStack->pIPv4Hdr->ipDest, pIPvXDest, sizeof(IPv4));
    }

    fRet = ILSend(pIpStack, pStatus);

    return(fRet);
}

HSOCKET UDPOpenWithSocket(const LLADP * pLLAdp, UDPSOCKET * pSocket, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus)
{
//    uint32_t    portPair    = 0;
    IPSTATUS    status      = ipsSuccess;
    SMGR *      pSMGR       = NULL;
    uint32_t    cb          = 0;

    if(pLLAdp == NULL)
    {
        status = ipsAdaptorMustBeSpecified;
    }
    else if(pSocket == NULL)
    {
        status = ipsSocketNULL;
    }
    else if(hPMGR == NULL)
    {
        status = ipsNoPMGRGiven;
    }
    else if(pIPvXDest == NULL)
    {
        status = ipsIPAddressIsNull;
    }
    // get the local port
    else if(portLocal == portDynamicallyAssign)
    {
        portLocal = GetEphemeralPort(&g_ffptListeningUDPSockets, &g_nextUDPEphemeralPort);
    }

    AssignStatusSafely(pStatus, status);
    if(IsIPStatusAnError(status))
    {
        return(NULL);
    }

    // build the stream manager to point to the page handler
    // first build the stream to the RxStream
    pSocket->hPMGR = hPMGR;
    if(SMGRInit(&pSocket->smgrRxBuff, cbMAXUDPSreamRecord, hPMGR) != (HSMGR) &pSocket->smgrRxBuff)
    {
        status = ispOutOfMemory;
    }
    else if((pSMGR = (SMGR*)alloca((cb = GetSMGRSize(((PMGR *) hPMGR)->cPages)))) == NULL)
    {
        status = ispOutOfMemory;
    }
    else if(SMGRInit(pSMGR, cb, hPMGR) == NULL)
    {
        status = ispOutOfMemory;
    }
    else if(SMGRWrite(&pSocket->smgrRxBuff, 0, pSMGR, cb) != cb)
    {
        status = ispOutOfMemory;
    }

    AssignStatusSafely(pStatus, status);
    if(IsIPStatusAnError(status))
    {
        SMGRFree((HSMGR) pSMGR);
        SMGRFree((HSMGR) &pSocket->smgrRxBuff);
        return(NULL);
    }

    pSocket->s.pLLAdp         = pLLAdp;
    pSocket->s.portRemote     = portRemote;
    pSocket->s.portLocal      = portLocal;

    memcpy(&pSocket->s.ipRemote, pIPvXDest, ILIPSize(pLLAdp));

    pSocket->cbRxSMGR       = cb;

    // put on the listening list.
    FFInPacket(&g_ffptListeningUDPSockets, pSocket);

    // return the socket
    return(pSocket);
}

HSOCKET UDPOpen(const LLADP * pLLAdp, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus)
{
    UDPSOCKET *  pSocket = (UDPSOCKET *) IPSGetSocketFromSocketHeap();

    if(UDPOpenWithSocket(pLLAdp, pSocket, hPMGR, pIPvXDest, portRemote, portLocal, pStatus) == NULL)
    {
        IPSReleaseSocket((TCPSOCKET *) pSocket);
        return(NULL);
    }

    return(pSocket);
}

void UDPClose(HSOCKET hSocket)
{
    UDPSOCKET *     pSocket     = (UDPSOCKET *) hSocket;
    UDPSOCKET *     pSocketCur  = NULL;

    // loop thru all listening sockets looking for this one
    while((pSocketCur = (UDPSOCKET*)FFNext(&g_ffptListeningUDPSockets, pSocketCur)) != NULL)
    {
        // see if we found it
        if(pSocket == pSocketCur)
        {
            SMGR *      pSMGR = (SMGR*)alloca(pSocket->cbRxSMGR);

            // remove it from the listening list
            FFRemove(&g_ffptListeningUDPSockets, pSocket);

            if(pSMGR != NULL && (SMGRRead((HSMGR) &pSocket->smgrRxBuff, 0, pSMGR, pSocket->cbRxSMGR) == pSocket->cbRxSMGR))
            {
                // free the datastream
                SMGRFree((HSMGR) pSMGR);
                // don't need to write back because these pages are all getting freed as well
            }

            // free what is in the socket as well
            // this is why we don't have to write back
            SMGRFree((HSMGR) &pSocket->smgrRxBuff);

            // clear the socket
            IPSReleaseSocket((TCPSOCKET *) pSocket);
            return;
        }
    }

    return;
}

static uint32_t UDPProcessRx(IPSTACK * pIpStack, UDPSOCKET * pSocket)
{
    SMGR *      pSMGR = (SMGR*)alloca(pSocket->cbRxSMGR);
    uint32_t    cbRet = 0;

    if(pIpStack->cbPayload > 0 && pSMGR != NULL && (SMGRRead((HSMGR) &pSocket->smgrRxBuff, 0, pSMGR, pSocket->cbRxSMGR) == pSocket->cbRxSMGR))
    {
        uint32_t iEnd = SMGRcbStream(pSMGR);

        // put in the size prefex
        uint32_t cbWritten = SMGRWrite((HSMGR) pSMGR, iEnd, &pIpStack->cbPayload, sizeof(uint16_t));

        // put in the data
        cbWritten += SMGRWrite((HSMGR) pSMGR, iEnd + cbWritten, pIpStack->pPayload, pIpStack->cbPayload);

        // check to see that we wrote everything.
        if(cbWritten == (pIpStack->cbPayload + sizeof(uint16_t)))
        {
            if(pSocket->cbNextDataGram == 0)
            {
                pSocket->cbNextDataGram = pIpStack->cbPayload;
            }
            cbRet = pIpStack->cbPayload;
        }

        // we failed to save, so discard the datagram and put the stream back to where it was
        else
        {
            SMGRMoveEnd((HSMGR) pSMGR, iEnd, SMGRAtEnding);
        }

        // save away the table that is stored on the stack
        // this should not fail! It is a fixed size and already allocated
        SMGRWrite((HSMGR) &pSocket->smgrRxBuff, 0, pSMGR, pSocket->cbRxSMGR);
    }

    return(cbRet);
}

void UDPProcess(IPSTACK * pIpStack)
{
    UDPSOCKET *     pSocketCur          = NULL;
    UDPSOCKET *     pSocketListen       = NULL;
    UDPSOCKET *     pSocketAnyRemoteIP  = NULL;
    UDPSOCKET *     pSocketExact        = NULL;
    bool            fBroadcast          = false;
    bool            fMyIP               = ILIsIPv6(pIpStack->pLLAdp) ?
                                            ILIsMyIP(pIpStack->pLLAdp, &pIpStack->pIPv6Hdr->ipDest, &fBroadcast) :
                                            ILIsMyIP(pIpStack->pLLAdp, &pIpStack->pIPv4Hdr->ipDest, &fBroadcast);

    // see if this is directed to my IP
    if( !fMyIP )
    {
        return;
    }

    // look at all listening sockets to see if the ports and remote IP match
    while((pSocketCur = (UDPSOCKET*)FFNext(&g_ffptListeningUDPSockets, pSocketCur)) != NULL)
    {
        // make sure we have consistant IPs
        if(ILIsIPv6(pSocketCur->s.pLLAdp) == ILIsIPv6(pIpStack->pLLAdp))
        {
            // listening socket, only check local port, remote port/IP will be set
            if( pSocketCur->s.portRemote == portListen &&
                pSocketCur->s.portLocal == pIpStack->pUDPHdr->portDest )
            {
                pSocketListen = pSocketCur;
            }

            // all connected sockets
            else if(pIpStack->pUDPHdr->portPair == pSocketCur->s.portPair)
            {
                // this is an IPv4 address
                if(!ILIsIPv6(pIpStack->pLLAdp))
                {
                    // exact match
                    if(pSocketCur->s.ipRemote.ipv4.u32 == pIpStack->pIPv4Hdr->ipSrc.u32)
                    {
                        pSocketExact = pSocketCur;
                        break;
                    }

                    // this is only supported for DHCP IPv4
                    else if(pSocketCur->s.ipRemote.ipv4.u32 == UDPAnyRemoteIPv4.u32)
                    {
                        pSocketAnyRemoteIP = pSocketCur;
                    }
                }

                // else an IPv6 address
                else
                {
                    // exact match
                    if(memcmp(&pSocketCur->s.ipRemote.ipv6, &pIpStack->pIPv6Hdr->ipSrc, sizeof(IPv6)) == 0)
                    {
                        pSocketExact = pSocketCur;
                        break;
                    }
                }
            }
        }
    }

    // a match to an active socket
    if(pSocketExact == NULL)
    {
        if(pSocketAnyRemoteIP != NULL)
        {
            pSocketExact = pSocketAnyRemoteIP;
        }
        else if(pSocketListen != NULL)
        {
            pSocketExact = pSocketListen;

            pSocketExact->s.portRemote = pIpStack->pUDPHdr->portSrc;

            if(ILIsIPv6(pSocketExact->s.pLLAdp))
            {
                memcpy(&pSocketExact->s.ipRemote.ipv6, &pIpStack->pIPv6Hdr->ipSrc, sizeof(IPv6));
            }
            else
            {
                pSocketExact->s.ipRemote.ipv4.u32 = pIpStack->pIPv4Hdr->ipSrc.u32;
            }
        }
    }

    // no match to anything, get out.
    if(pSocketExact == NULL)
    {
        return;
    }

    // update our ARP table
    IPSUpdateARPEntry(pIpStack);
    memcpy(&pSocketExact->s.macRemote, &pIpStack->pFrameII->macSrc, sizeof(MACADDR));

    // Receive the UDP input data
    UDPProcessRx(pIpStack, pSocketExact);
}

void UDPDiscard(HSOCKET hSocket)
{
    UDPSOCKET *     pSocket     = (UDPSOCKET *) hSocket;

    if(pSocket != NULL)
    {
        SMGR *  pSMGR = (SMGR*)alloca(pSocket->cbRxSMGR);

        if(pSMGR != NULL && (SMGRRead((HSMGR) &pSocket->smgrRxBuff, 0, pSMGR, pSocket->cbRxSMGR) == pSocket->cbRxSMGR))
        {
            uint32_t iEnd = SMGRcbStream(pSMGR);

            SMGRMoveEnd((HSMGR) pSMGR, iEnd, SMGRAtBegining);

            // save away the table that is stored on the stack
            // this should not fail! It is a fixed size and already allocated
            SMGRWrite((HSMGR) &pSocket->smgrRxBuff, 0, pSMGR, pSocket->cbRxSMGR);
        }
    }
}

uint32_t UDPAvailable(HSOCKET hSocket)
{
    UDPSOCKET *     pSocket     = (UDPSOCKET *) hSocket;

    if(pSocket == NULL || pSocket->s.portRemote == portListen || pSocket->s.portRemote == portInvalid)
    {
        return(0);
    }

    return(pSocket->cbNextDataGram);
}

static uint32_t UDPPeekSMGR(UDPSOCKET * pSocket, HSMGR pSMGR, uint16_t index, uint8_t * pbRead, uint16_t cbRead, IPSTATUS * pStatus)
{
    uint32_t    cb = 0;

    if(pSocket == NULL)
    {
        AssignStatusSafely(pStatus, ipsSocketNULL);
        return(0);
    }
    else if(pbRead == NULL || cbRead == 0)
    {
        AssignStatusSafely(pStatus, ipsBufferNotDefined);
        return(0);
    }
    else if(pSocket->s.portRemote == portListen || pSocket->s.portRemote == portInvalid)
    {
        AssignStatusSafely(pStatus, ipsSocketNotResolved);
        return(0);
    }

    cb = min((pSocket->cbNextDataGram - index), cbRead);
    if(cb > 0 && SMGRRead((HSMGR) pSMGR, (sizeof(uint16_t) + index), pbRead, cb) == cb)
    {
        return(cb);
    }

    return(0);
}

uint32_t UDPPeekIdx(HSOCKET hSocket, uint32_t index, uint8_t * pbRead, uint16_t cbRead, IPSTATUS * pStatus)
{
    UDPSOCKET *     pSocket     = (UDPSOCKET *) hSocket;

    if(pSocket != NULL)
    {
        SMGR *  pSMGR = (SMGR*)alloca(pSocket->cbRxSMGR);

        if(pSMGR != NULL && (SMGRRead((HSMGR) &pSocket->smgrRxBuff, 0, pSMGR, pSocket->cbRxSMGR) == pSocket->cbRxSMGR))
        {
            // because we are only READing, no need to update the stream tables
            return(UDPPeekSMGR(pSocket, (HSMGR) pSMGR, index, pbRead, cbRead, pStatus));
        }
    }

    return(0);
}

uint32_t UDPRead(HSOCKET hSocket, uint8_t * pbRead, uint16_t cbRead, IPSTATUS * pStatus)
{
    UDPSOCKET *     pSocket     = (UDPSOCKET *) hSocket;

    uint32_t cb = 0;

    if(pSocket != NULL)
    {
        SMGR *  pSMGR = (SMGR*)alloca(pSocket->cbRxSMGR);

        if(pSMGR != NULL && (SMGRRead((HSMGR) &pSocket->smgrRxBuff, 0, pSMGR, pSocket->cbRxSMGR) == pSocket->cbRxSMGR))
        {
            cb = UDPPeekSMGR(pSocket, (HSMGR) pSMGR, 0, pbRead, cbRead, pStatus);

            // if this is the whole datagram
            // note, the > part should never happen, cb should always
            // be cb <= pSocket->cbNextDataGram and this condition
            // should be cb == pSocket->cbNextDataGram; but should somehow
            // > happen, this will offer some correction
            if(cb >= pSocket->cbNextDataGram)
            {
                // move the begining to the next datagram
                SMGRMoveEnd((HSMGR) pSMGR, cb + sizeof(uint16_t), SMGRAtBegining);

                // read the next 2 bytes for the datagarm size if it exists
                if(SMGRRead((HSMGR) pSMGR, 0, &pSocket->cbNextDataGram, sizeof(uint16_t)) != sizeof(uint16_t))
                {
                    pSocket->cbNextDataGram = 0;
                }
            }

            // otherwise it is a partial datagram read
            else
            {
                // move the begining to after what we read, but leave room to
                // write the remaining datagram size
                SMGRMoveEnd((HSMGR) pSMGR, cb, SMGRAtBegining);

                // update the remaining datagram size
                pSocket->cbNextDataGram -= cb;
                SMGRWrite((HSMGR) pSMGR, 0, &pSocket->cbNextDataGram, sizeof(uint16_t));
            }

            // save away the table that is stored on the stack
            // this should not fail! It is a fixed size and already allocated
            SMGRWrite((HSMGR) &pSocket->smgrRxBuff, 0, pSMGR, pSocket->cbRxSMGR);
        }
    }

    return(cb);
}

bool UDPSend(HSOCKET hSocket, const uint8_t * pbDatagram, uint16_t cbDatagram, IPSTATUS * pStatus)
{
    UDPSOCKET * pSocket     = (UDPSOCKET *) hSocket;
    IPSTACK *   pIpStack    = NULL;

    if(pSocket->s.portRemote == portListen || pSocket->s.portRemote == portInvalid)
    {
        AssignStatusSafely(pStatus, ipsSocketNotResolved);
        return(false);
    }
    else if((pIpStack = IPSGetIpStackFromAdaptor(pSocket->s.pLLAdp, ippnUDP, pStatus)) == NULL)
    {
        return(false);
    }
    else if(UDPRawSend(pSocket->s.pLLAdp, pIpStack, (void *) &pSocket->s.ipRemote, pSocket->s.portRemote,  pSocket->s.portLocal, pbDatagram, cbDatagram, true, pStatus))
    {
         return(true);
    }
    else
    {
        IPSRelease(pIpStack);
        return(false);
    }
}

