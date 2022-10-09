/************************************************************************/
/*                                                                      */
/*      TCP.c  This TCP implementation                                  */
/*      as part of the Transport Layer                                  */
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
/*      Auxilary TCP functions to support the TCP implementation        */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*      9/12/2012(KeithV): Created                                      */
/*                                                                      */
/************************************************************************/
#include "deIP.h"

static uint16_t     g_nextTCPEphemeralPort  = portEphemeralFirst;
FFPT                g_ffptActiveTCPSockets = {NULL, NULL};

// the compiler will zero this, but it would be better if this were random and uninitialized
static uint32_t     cSeqNbrFixup;


static bool ExTCPOptions(TCPHDR * pTCPHdr)
{
    uint32_t    cbOptions = pTCPHdr->dataOffset * sizeof(uint32_t) - sizeof(TCPHDR);
    TCPOPTION * pOptions = (TCPOPTION *) (pTCPHdr + 1);

    if(pTCPHdr->dataOffset == (sizeof(TCPHDR) / sizeof(uint32_t)))
    {
        return(true);
    }
    else if(pTCPHdr->dataOffset < (sizeof(TCPHDR) / sizeof(uint32_t)))
    {
        return(false);
    }

    // run the options
    while(cbOptions > 0)
    {

        // if this is
        switch(pOptions->optionKind)
        {
            case tcpOpKdEndOfList:
                return(true);
                break;
                
            case tcpOpKdNoOperation:
                
                cbOptions--;
                pOptions = (TCPOPTION *) (((void *) pOptions) + 1);
                
                // there is no length, so just go to the next option
                continue;
                break;
                
            default:
                break;
        }

        // check the size to
        if(pOptions->length > cbOptions)
        {
            return(false);
        }

        switch(pOptions->optionKind)
        {
            case tcpOpKdMaxSegSize:
                ExEndian(pOptions->rgu16, sizeof(uint16_t));
                break;

            case tcpOpKdSAckMult:
            case tcpOpKdTimestamp:
                {
                    uint32_t i = 0;
                    uint32_t j = (pOptions->length-2) / sizeof(uint32_t);

                    for(i=0; i<j; i++)
                    {
                        ExEndian(&pOptions->rgu16[2*i], sizeof(uint32_t));
                    }
                }
                break;

            case tcpOpKdWindowScale:
            case tcpOpKdSAck:
            case tcpOpKdAltChksumReq:
            case tcpOpKdAltChksumData:
            default:
                break;
        }

        // go to the next option
        cbOptions -= pOptions->length;
        pOptions = (TCPOPTION *) (((void *) pOptions) + pOptions->length);
    }

    return(true);
}

uint32_t ExTCPHeader(IPSTACK * pIpStack, bool fStartsInMachineOrder)
{
    uint16_t sum    = ~(ippnTCP << 8);
    uint16_t cbT    = pIpStack->cbTranportHeader + pIpStack->cbPayload;

    // checksum of the psuedo header
    // remember dataOffset is a byte, so we don't care if in machine or  network order
    ExEndian(&cbT, sizeof(cbT));
    sum = CalculateChecksum(sum, &cbT, sizeof(cbT));
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

    // must put in network order, and do checksum
    if(fStartsInMachineOrder)
    {
        if(!ExTCPOptions(pIpStack->pTCPHdr))
        {
            return(ipsIpStackParsingError);
        }

        pIpStack->pTCPHdr->checksum = 0;    // set this to zero for calcluation
        ExEndian(&pIpStack->pTCPHdr->portSrc, sizeof(pIpStack->pTCPHdr->portSrc));
        ExEndian(&pIpStack->pTCPHdr->portDest, sizeof(pIpStack->pTCPHdr->portDest));

        ExEndian(&pIpStack->pTCPHdr->seqNbr, sizeof(pIpStack->pTCPHdr->seqNbr));
        ExEndian(&pIpStack->pTCPHdr->ackNbr, sizeof(pIpStack->pTCPHdr->ackNbr));

        ExEndian(&pIpStack->pTCPHdr->window, sizeof(pIpStack->pTCPHdr->window));
        ExEndian(&pIpStack->pTCPHdr->urgentPtr, sizeof(pIpStack->pTCPHdr->urgentPtr));

        sum = CalculateChecksum(sum, pIpStack->pTCPHdr, pIpStack->cbTranportHeader);
    }

    else
    {
        sum = CalculateChecksum(sum, pIpStack->pTCPHdr, pIpStack->cbTranportHeader);

        // switch order
        ExEndian(&pIpStack->pTCPHdr->portSrc, sizeof(pIpStack->pTCPHdr->portSrc));
        ExEndian(&pIpStack->pTCPHdr->portDest, sizeof(pIpStack->pTCPHdr->portDest));

        ExEndian(&pIpStack->pTCPHdr->seqNbr, sizeof(pIpStack->pTCPHdr->seqNbr));
        ExEndian(&pIpStack->pTCPHdr->ackNbr, sizeof(pIpStack->pTCPHdr->ackNbr));

        ExEndian(&pIpStack->pTCPHdr->window, sizeof(pIpStack->pTCPHdr->window));
        ExEndian(&pIpStack->pTCPHdr->urgentPtr, sizeof(pIpStack->pTCPHdr->urgentPtr));

        if(!ExTCPOptions(pIpStack->pTCPHdr))
        {
            return(ipsIpStackParsingError);
        }
    }

    // add the data
    pIpStack->pTCPHdr->checksum = CalculateChecksum(sum, pIpStack->pPayload, pIpStack->cbPayload);

    // RFC 768, if zero and outgoing, make all FFs
    if(fStartsInMachineOrder)
    {
        if(pIpStack->pTCPHdr->checksum == 0)
        {
            pIpStack->pTCPHdr->checksum = 0xFFFF;
        }
    }
    else if(pIpStack->pTCPHdr->checksum != 0)
    {
            return(ipsIpStackChecksumError);
    }

    return(ipsSuccess);
}

void TCPInitSockets(void)
{
    memset(&g_ffptActiveTCPSockets, 0, sizeof(g_ffptActiveTCPSockets));
    g_nextTCPEphemeralPort      = portEphemeralFirst;
//    cSeqNbrFixup                = 0;
}
void TCPAbortAllSockets(void)
{
    TCPSOCKET * pSocket = NULL;

    // look at all of the TCP sockets
    //we have to clean out the list, each time we remove
    // the first entry, the next point will get cleared because the socket
    // is set to zero, so the next is set to zero in the socket
    // so just iterate on the first entry until the list is empty
    while((pSocket = (TCPSOCKET*)FFNext(&g_ffptActiveTCPSockets, NULL)) != NULL)
    {
        TCPAbort(pSocket);
    }
}


uint16_t GetEphemeralPort(FFPT * pFFPT, uint16_t * pNextEphemeralPort)
{
    uint16_t    foundEphemeralPort = (*pNextEphemeralPort)++;
    SOCKET *    pSocket = NULL;

    // make sure this is within range
    if(foundEphemeralPort > portEphemeralLast)
    {
        foundEphemeralPort = portEphemeralFirst;
    }

    // check that this port is not in use
    while((pSocket = (SOCKET*)FFNext(pFFPT, pSocket)) != NULL)
    {
        uint16_t    portLocal = pSocket->portLocal;

        // this port is in use, try another one, start over
        if(foundEphemeralPort == portLocal)
        {
            foundEphemeralPort = (*pNextEphemeralPort)++;
            if(foundEphemeralPort > portEphemeralLast)
            {
                foundEphemeralPort = portEphemeralFirst;
            }

            // re-search the in use ports to make sure this is okay
            pSocket = NULL;
        }
    }

    // it is not possible to have as many sockets as ephemeral ports
    // so we won't loop forever, we will come out of the while loop
    return(foundEphemeralPort);
}

bool TCPIsInUse(const LLADP * pLLAdp, uint32_t portPair, const void * pIPvXDest)
{
    TCPSOCKET *     pSocket         = NULL;
    bool            fListenIP       = (memcmp(pIPvXDest, &IPListen, ILIPSize(pLLAdp)) == 0);

    while((pSocket = (TCPSOCKET*)FFNext(&g_ffptActiveTCPSockets, pSocket)) != NULL)
    {
        // check to see if this port pair is in active use along with the remote IP
        if(  portPair == pSocket->s.portPair            &&
            (memcmp(pIPvXDest, (void *) &pSocket->s.ipRemote, ILIPSize(pLLAdp)) == 0) )
        {
            // if this totally in use and a duplicate should not be put on the stack
            // however let there be mult listens but check that what we are listining on is the listing IP, not some specific target IP we are waiting for.
            if(pSocket->tcpState > tcpListen || (pSocket->tcpState == tcpListen && !fListenIP))
            {
                return(true);
            }
        }
    }

    return(false);
}

/*********************************************************************
 * Function:        uint32_t TCPGetSeqNumber(const LLADP * pLLAdp)
 *
 * Input:           pLLAdp:     The Adaptor *
 *
 * Returns:         A TCP sequence number to use.
 *
 * Note:            Offsets it by the IP address of the adaptor
 *                  Seq numbers are uniquie to port pair and IP; if the
 *                  IP changes, then we don't worry about old segements in the system
 *
 ********************************************************************/
uint32_t TCPGetSeqNumber(const LLADP * pLLAdp)
{
    return(SYSGetSeqNumber() + pLLAdp->ipMy.ipv4.u32 + cSeqNbrFixup);
}

/*********************************************************************
 * Function:        void TCPFixupSeqNumber(const LLADP * pLLAdp, uint32_t seqNbrMax)
 *
 * Input:           pLLAdp:     The Adaptor
 *                  seqNbrMax:  We need to make sure new seqNbrs are higher than this
 *
 * Returns:         Nothing
 *
 * Note:            The fixeup will be shared across all adaptors
 *                  because it really doesn't matter what he seqNbr is
 *                  as long as it gets larger per adaptor and connection
 *
 *                  This is called at the end of a connection, and seq numbers
 *                  are linear for about 4.77 hours (2^^32 * 4usec / 3600 = 4.77h)
 *                  MSL is 2min. and we need to keep the system clear for 2*MSL or
 *                  4 min. ( 240s / 4usec = 6X10+7 == TIMEWAITDELAY )
 *
 *                  What we are going to do is check to see if the seq number
 *                  from the closing socket is ahead of the system seq number
 *                  withing 2 * (2 * MSL) = 2 * TIMEWAITDELAY and if it is
 *                  we will fixup the system time to move the seq nbr generator
 *                  to a time beyond that so ensure that we don't issue a seq
 *                  on a new connection that could conflict with a seq number
 *                  issued on this connection.
 *
 ********************************************************************/
static void TCPFixupSeqNumber(const LLADP * pLLAdp, uint32_t seqNbrMax)
{
    // we are assuming right NOW is time 0, we must scale the incoming seq number to
    // right now time of 0 plus whatever it might be
    uint32_t seqNbrNormalized = seqNbrMax - TCPGetSeqNumber(pLLAdp);

    // if the normalized number is within our 2*TIMEWAITDELAY range, we assume the connection
    // is ahead  and we need to adjust the seq nbr generator to move beyond the current time.
    // remember if the current seq nbr generator is ahead, the substraction will yeild a neg
    // value, or in terms of an unsigned value, a very large value and will be outside of our
    // 2*TIMEWAITDELAY range.
    if(seqNbrNormalized < (2*TIMEWAITDELAY))
    {
        // seqNbrNormalized is how much ahead we are, lets move the seq nbr generator beyond that
        cSeqNbrFixup += seqNbrNormalized + 1;
    }
}

// this will free the socket if it can't open it
TCPSOCKET * TCPInitSocket(const LLADP * pLLAdp, TCPSOCKET * pSocketOpen, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus)
{
    IPSTATUS    status          = ipsSuccess;
    SMGR *      pSMGR           = NULL;
    uint32_t    cb              = 0;
    uint32_t    cPages          = 0;

    if(pSocketOpen == NULL)
    {
        AssignStatusSafely(pStatus, ipsSocketNULL);
        return(NULL);
    }
    else if(hPMGR == NULL)
    {
        AssignStatusSafely(pStatus, ipsNoPMGRGiven);
    }

    // find a port
    if(portLocal == portDynamicallyAssign)
    {
        portLocal = GetEphemeralPort(&g_ffptActiveTCPSockets, &g_nextTCPEphemeralPort);
    }

    // get the sequence number
    // we have to get this BEFORE we memset the socket
    // as the timewait may be the socket we are clearing.
    // also, if we are listening, we can only assign the sequence number
    // when we now our remote port and IP as to not duplicate and to watch seq numbers.
    if(portRemote != portListen)
    {
        SKTPORTPAIR portPair;    // remote, local
        portPair.portRemote =   portRemote;
        portPair.portLocal  =   portLocal;

        // worry about the 2MSL timewait issue, get an appropriate sequence number
        if(TCPIsInUse(pLLAdp, portPair.portPair, pIPvXDest))
        {
            AssignStatusSafely(pStatus, ipsPortPairAndIPAlreadyActive);
            return(NULL);
        }
    }

    // build the stream manager to point to the page handler
    // first build the stream to the RxStream and TxStream
    // Rx is the 1st
    pSocketOpen->hPMGR = hPMGR;
    
    // calculate the size of the 2 embedded streams and how to partition the socket stream, stream
    // the Rx is the first indirect stream follwed by the Tx indirect stream in the socket stream
    cb                      = (1 << ((PMGR *) hPMGR)->pf2PerPage);
    cPages                  = ((PMGR *) hPMGR)->cPages;
    pSocketOpen->cbRxSMGR   = GetSMGRSize(min(((cTCPRXPages * cb) - sizeof(SMGR)), cPages));
    pSocketOpen->cbTxSMGR   = GetSMGRSize(min(((cTCPTXPages * cb) - sizeof(SMGR)), cPages));
    cb                      = pSocketOpen->cbRxSMGR + pSocketOpen->cbTxSMGR;

    if(SMGRInit(&pSocketOpen->smgrRxTxBuff, cbMAXTCPSreamRecord, hPMGR) != (HSMGR) &pSocketOpen->smgrRxTxBuff)
    {
        status = ispOutOfMemory;
    }
    else if((pSMGR = (SMGR*)alloca(cb)) == NULL)
    {
        status = ispOutOfMemory;
    }
    else if(SMGRInit(pSMGR, pSocketOpen->cbRxSMGR, hPMGR) == NULL || SMGRInit((SMGR *) (((uint8_t *) pSMGR) + pSocketOpen->cbRxSMGR), pSocketOpen->cbTxSMGR, hPMGR) == NULL)
    {
        status = ispOutOfMemory;
    }
    else if(SMGRWrite(&pSocketOpen->smgrRxTxBuff, 0, pSMGR, cb) != cb)
    {
        status = ispOutOfMemory;
    }

    AssignStatusSafely(pStatus, status);
    if(IsIPStatusAnError(status))
    {
        SMGRFree((HSMGR) pSMGR);
        SMGRFree((HSMGR) (((uint8_t *) pSMGR) + pSocketOpen->cbRxSMGR));
        SMGRFree((HSMGR) &pSocketOpen->smgrRxTxBuff);
        IPSReleaseSocket(pSocketOpen);
        return(NULL);
    }

    // make the socket
    pSocketOpen->tcpState       = tcpAllocated;
    pSocketOpen->s.portLocal    = portLocal;
    pSocketOpen->s.portRemote   = portRemote;
    pSocketOpen->s.pLLAdp       = pLLAdp;
    memcpy(&pSocketOpen->s.ipRemote, pIPvXDest, ILIPSize(pLLAdp));

    // get a new seq nbr
    pSocketOpen->sndISS = TCPGetSeqNumber(pLLAdp);

    // max I will allow to come in. RFC 1122 4.2.2.6
    pSocketOpen->cbLocalMSS     = min((PMGRMaxAlloc(hPMGR) >> 2), (uint16_t) (LLGetMTUR(pLLAdp) - 20));

    // Jacobson rule
    pSocketOpen->RTTsa          = RTTsaINIT;
    pSocketOpen->RTTsv          = RTTsvINIT;
    pSocketOpen->tRTO_SET       = RTO(pSocketOpen);
    pSocketOpen->tRTOCur        = pSocketOpen->tRTO_SET;

    return(pSocketOpen);
}

void TCPResetSocket(TCPSOCKET *  pSocket)
{
    if(pSocket == NULL || pSocket->smgrRxTxBuff.pPMGR == NULL)
    {
        return;
    }

    // fixup the seq nbr generator to make sure we don't reissue seqnbr less than before in time
    TCPFixupSeqNumber(pSocket->s.pLLAdp, pSocket->sndISS + pSocket->sndNXT);

    // clean up the socket if we were not listening
    if(pSocket->tcpState != tcpSynReceivedWhileListening)
    {
        uint16_t    cb      = pSocket->cbRxSMGR + pSocket->cbTxSMGR;
        SMGR *      pSMGR   = (SMGR*)alloca(cb);

        // remove it from the listening list
        FFRemove(&g_ffptActiveTCPSockets, pSocket);

        // this works
//        pSocket->sndISS = 0;
//          pSocket->tcpState = tcpUnassigned;
//        pSocket->fSocketOpen = false;
        
        // if this does not pass, we will have a memory leak
        // the alloca should always work.
        // this frees the Rx and Tx socket buffers
        if(SMGRRead((HSMGR) &pSocket->smgrRxTxBuff, 0, pSMGR, cb) == cb)
        {
            SMGRFree((HSMGR) pSMGR);
            SMGRFree((HSMGR) (((uint8_t *) pSMGR) + pSocket->cbRxSMGR));
        }

        // free the pointer to the RxTx streams.
        SMGRFree((HSMGR) &pSocket->smgrRxTxBuff);

        // release it back to the global pool if we got it from there
        IPSReleaseSocket(pSocket);

        // clean the socket
        // I am assuming this will not break us anywhere.
        memset(pSocket, 0, sizeof(TCPSOCKET));

        return;
    }

    // if we were listening, go back to listening
    // restore the socket to the listening state
    pSocket->s.portRemote = portListen;
    memset(&pSocket->s.ipRemote, 0, sizeof(IPv4or6));
    memset(&pSocket->s.macRemote, 0, sizeof(MACADDR));
    pSocket->tcpState   = tcpListen;
    pSocket->sndISS     = 0;

    // initalize the socket info
    pSocket->sndISS         = TCPGetSeqNumber(pSocket->s.pLLAdp);
    pSocket->sndNXT         = 0;
    pSocket->sndUNA         = 0;
    pSocket->sndEND         = 0;
    pSocket->sndWND         = 0;
    pSocket->sndPSH         = 0;
//    pSocket->sndWL2     = 0;
    pSocket->sndUP          = 0;
    pSocket->sndRTTComplete = 0;
    
    pSocket->rcvIRS         = 0;
    // pSocket->rcvUNR     = 0;
    pSocket->rcvNXT         = 0;
    pSocket->rcvUP          = 0;
//    pSocket->rcvSeqAhead = 0;

    pSocket->fGotFin        = false;
    pSocket->fSocketOpen    = false;

    // Jacobson rule
    pSocket->RTTsa      = RTTsaINIT;
    pSocket->RTTsv      = RTTsvINIT;
    pSocket->tRTO_SET   = RTO(pSocket);
    pSocket->tRTOCur    = pSocket->tRTO_SET;

}

// only called for incoming packets
void TCPProcess(IPSTACK *  pIpStack)
{
    TCPSOCKET *     pSocketCur      = NULL;
    TCPSOCKET *     pSocketListen   = NULL;
    TCPSOCKET *     pSocketExact    = NULL;
    
    // see if this is directed to my IP
    if( !(  // this is not my IP address

        // my IPv4 address
        (!ILIsIPv6(pIpStack->pLLAdp) && pIpStack->pLLAdp->ipMy.ipv4.u32 == pIpStack->pIPv4Hdr->ipDest.u32)
                                    ||
        // my IPv6 addresss
        (memcmp(&pIpStack->pLLAdp->ipMy.ipv6, &pIpStack->pIPv6Hdr->ipDest, sizeof(IPv6)) == 0)     ))
    {
        // just get out if it is not for me
        return;
    }

    // look at all of the sockets
    while((pSocketCur = (TCPSOCKET*)FFNext(&g_ffptActiveTCPSockets, pSocketCur)) != NULL)
    {
        if( pSocketCur->tcpState > tcpListen   &&
            pIpStack->pTCPHdr->portPair == pSocketCur->s.portPair  &&

        // matches the remote IP
        ((!ILIsIPv6(pIpStack->pLLAdp) && pSocketCur->s.ipRemote.ipv4.u32 == pIpStack->pIPv4Hdr->ipSrc.u32)
                                    ||
        (memcmp(&pSocketCur->s.ipRemote.ipv6, &pIpStack->pIPv4Hdr->ipSrc, sizeof(IPv6)) == 0))   )

        {
            pSocketExact = pSocketCur;
            break;
        }
        else if(pSocketCur->tcpState    == tcpListen                    &&
                pSocketCur->s.portLocal == pIpStack->pTCPHdr->portDest  &&
                pIpStack->pTCPHdr->fSyn)
        {
            pSocketListen = pSocketCur;
        }
    }

    // see if we did not find an exact match
    // but we are listening
    if(pSocketExact == NULL)
    {
        pSocketExact = pSocketListen;
    }

    // a match to an active socket
    if(pSocketExact != NULL)
    {
        IPSUpdateARPEntry(pIpStack);
        memcpy(&pSocketExact->s.macRemote, &pIpStack->pFrameII->macSrc, sizeof(MACADDR));
        TCPStateMachine(pIpStack, pSocketExact, NULL);
    }

    // to no socket at all, this will cause a RST to be sent.
    else
    {
        TCPStateMachine(pIpStack, NULL, NULL);
    }
}

uint32_t TCPAddRxDataToSocket(TCPSOCKET * pSocket, uint32_t seqNbr, uint8_t * pb, uint32_t cb)
{
    SMGR *      pSMGR = (SMGR*)alloca(pSocket->cbRxSMGR);
    uint32_t    rcvNXT = pSocket->rcvNXT + SEQBOUNDARY;

    // seqNbr is tricky, it has been normalized to rcvIRS
    // and may be very close to rcvUNR which is typically 0
    // so if seqNbr is < rcvNXT it could be less than rcvUNR, or an unsigned less than 0
    // or for an unsigned, very large; which would give us a false large seqNbr.
    // the MAX segment we can get is 64K, so as long as we scale this down so at least seqNbr + 64K < 2^^32, we can do a compare
    // and see if seqNbr < rcvNXT reliably. SEQBOUNDARY is 0x80000000 which is half way into the linear uint32_t range
    // scale seqNbr and rcvNXT and we can do a reliable < check.
    // Rip off data we have already received
    seqNbr += SEQBOUNDARY;
    if(seqNbr < rcvNXT)
    {
        pb += (rcvNXT - seqNbr);
        cb -= (rcvNXT - seqNbr);
    }

    // get our stream pointer
    if(cb > 0 && pSMGR != NULL && (SMGRRead((HSMGR) &pSocket->smgrRxTxBuff, 0, pSMGR, pSocket->cbRxSMGR) == pSocket->cbRxSMGR))
    {
        // write as much data as we can to the stream
        cb  = SMGRWrite((HSMGR) pSMGR, SMGRcbStream(pSMGR), pb, cb);

        // add the bytes written to our rcvNXT pointer
        pSocket->rcvNXT += cb;

        // save away the table that is stored on the stack
        // this should not fail! It is a fixed size and already allocated
        SMGRWrite((HSMGR) &pSocket->smgrRxTxBuff, 0, pSMGR, pSocket->cbRxSMGR);

        return(cb);
    }

    return(0);
}

void TCPPeriodicTasks(void)
{
    TCPSOCKET * pSocketCur = (TCPSOCKET*)FFNext(&g_ffptActiveTCPSockets, NULL);

    // look at all of the active sockets
    // remember the TCPStateMachine may remove a socket when
    // closed and that could clear the socket and thus the next pointer
    // in the list and FFNext will just have a NULL as the next pointer 
    // after TCPStateMachine runs, so we need to get the next pointer
    // before we run the state machine
    while(pSocketCur != NULL)
    {
        TCPSOCKET * pSocketNext = (TCPSOCKET*)FFNext(&g_ffptActiveTCPSockets, pSocketCur);
        TCPStateMachine(NULL, pSocketCur, NULL);
        pSocketCur = pSocketNext;
    }
}

