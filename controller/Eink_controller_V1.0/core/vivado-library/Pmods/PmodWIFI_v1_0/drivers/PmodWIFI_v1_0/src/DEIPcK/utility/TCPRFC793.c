/************************************************************************/
/*                                                                      */
/*	TCPRFC793.c  This the RFC 793 implementation of TCP                 */
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
/*	                                                                    */
/*	To understand this module, go get a copy of RFC 793                 */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	10/9/2012(KeithV): Created                                          */
/*                                                                      */
/************************************************************************/
#include "deIP.h"

/*****************************************************************************
  Function:
	bool TCPIsEstablished(SOCKET * pSocket, IPSTATUS * pStatus)

  Description:
        This is sort of like TCPIsConnected except it is for the established state. Think
        of being connected as being in the process of getting or closing a connection and being established.
        Established is a fully connected duplex condtion where both sides are ready to send and receive data.

  Parameters:
	pSocket:        The socket to see if it is in the established state
        pStatus:        A pointer to a status variable to recieve the status of the connection
                        This may be NULL if you don't care about the status

  Returns:
        true if the connection is established and you can send/write data,
        false if the conneciton is not established
  ***************************************************************************/
bool TCPIsEstablished(HSOCKET hSocket, IPSTATUS * pStatus)
{
    IPSTATUS    status;

    TCPIsConnected(hSocket, &status);
    AssignStatusSafely(pStatus, status);
    return(status == IPStatusFromTCPState(tcpEstablished));
}

/*****************************************************************************
  Function:
	bool TCPIsConnected(SOCKET * pSocket, IPSTATUS * pStatus)

  Description:
        This is sort of like TCPIsEstablished except it is for any connected state. Think
        of being connected as being in the process of getting or closing a connection and being established.
        Established is a fully connected duplex condtion where both sides are ready to send and receive data.

  Parameters:
	pSocket:        The socket to see if it is in the established state
        pStatus:        A pointer to a status variable to recieve the status of the connection
                        This may be NULL if you don't care about the status

  Returns:
        true if the connection is in the process of connecting, half or full duplex
        connection, or in the process of closing but not yet closed.
        false if the conneciton is not in any kind of active condition.
  ***************************************************************************/
bool TCPIsConnected(HSOCKET hSocket, IPSTATUS * pStatus)
{
    TCPSOCKET * pSocket = (TCPSOCKET *) hSocket;
    IPSTATUS    status  = ipsUnknowTCPState;

    // check to see if we are even connected
    if(pSocket == NULL)
    {
        AssignStatusSafely(pStatus, ipsSocketNULL);
        return(false);
    }

    // Otherwise, what is our state?
    switch(pSocket->tcpState)
    {
        case tcpListen:
        case tcpSynSent:
        case tcpSynReceivedWhileListening:
        case tcpSynReceived:
        case tcpEstablished:
        case tcpFinWait1:
        case tcpFinWait2:
        case tcpCloseWait:
        case tcpClosing:
        case tcpLastAck:
            status = IPStatusFromTCPState(pSocket->tcpState);
            break;

        case tcpWaitUserClose:
            if(TCPAvailable(pSocket, NULL) > 0)
            {
                status = IPStatusFromTCPState(pSocket->tcpState);
            }
            else
            {
                status = IPErrorFromTCPState(pSocket->tcpState);
            }
            break;

        case tcpUnassigned:
        case tcpAllocated:
        case tcpInvalid:
        case tcpClosed:
            status = IPErrorFromTCPState(pSocket->tcpState);
            break;

        default:
            status = ipsUnknowTCPState;
            break;
    }

    AssignStatusSafely(pStatus, status);
    if(IsIPStatusAnError(status))
    {
        return(false);
    }
    else if(!ILIsIPNetworkReady(pSocket->s.pLLAdp, &status))
    {
        AssignStatusSafely(pStatus, status);
        return(false);
    }
    else if(pSocket->tcpState == tcpListen)
    {
        return(false);
    }

    return(true);
}

/*****************************************************************************
  Function:
	PSTATUS TCPStatus(SOCKET * pSocket)

  Description:
        This returns the TCP state as know by the TCP state machine as either a status or errror. If
        the TCP is connected, it will be a status, if the TCP is not connected it will be an error.
        Use TCPStateFromStatus(s) to get the TCP state

  Parameters:
	pSocket:        The socket to see if it is in the established state

  Returns:
        The TCP state as a status or error code.

   ***************************************************************************/
IPSTATUS TCPStatus(HSOCKET hSocket)
{
    TCPSOCKET * pSocket = (TCPSOCKET *) hSocket;
    IPSTATUS    status = ipsFailed;

    if(pSocket == NULL)
    {
        return(ipsSocketNULL);
    }

    switch(pSocket->tcpState)
    {
        case tcpUnassigned:
        case tcpAllocated:
        case tcpInvalid:
        case tcpClosed:
            status = IPErrorFromTCPState(pSocket->tcpState);
            break;

        case tcpListen:
        case tcpSynSent:
        case tcpSynReceivedWhileListening:
        case tcpSynReceived:
        case tcpEstablished:
        case tcpFinWait1:
        case tcpFinWait2:
        case tcpCloseWait:
        case tcpClosing:
        case tcpLastAck:
        case tcpWaitUserClose:
           status = IPStatusFromTCPState(pSocket->tcpState);
           break;

        default:
            status = ipsUnknowTCPState;
            break;
    }

    return(status);
}

/*****************************************************************************
  Function:
	SOCKET * TCPOpen(const LLADP * pLLAdp, const SOCKETPOOL * pSocketPool, void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus)

  Summary:
        Opens a Socket for both Client and Server. If portRemote == 0
        The socket is opened for listening.

  Description:

  Precondition:

  Parameters:
	pLLAdp -        The adaptor to use
        hPMGR -         A handle to the page manager to create the socket stream.
        pIPvXDest -     The Dest IP to connect to if a client, ignored for a server open and may be NULL
        portRemote -    The remote port to connect to if Client, MUST be 0 if this is a server open for listen
        portLocal -     Local port to use, one will be assigned if zero
        pStatus -       A pointer to a status variable to recieve the status of the open, This may be NULL

  Returns:
        The Socket if opened, NULL on failure
  ***************************************************************************/
HSOCKET TCPOpen(const LLADP * pLLAdp, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus)
{
    TCPSOCKET * pSocket = IPSGetSocketFromSocketHeap();

    return(TCPOpenWithSocket(pLLAdp, pSocket, hPMGR, pIPvXDest, portRemote, portLocal, pStatus));

}

/*****************************************************************************
  Function:
	SOCKET * TCPOpen(const LLADP * pLLAdp, const SOCKETPOOL * pSocketPool, void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus)

  Summary:
        Opens a Socket for both Client and Server. If portRemote == 0
        The socket is opened for listening.

  Description:

  Precondition:

  Parameters:
	pLLAdp -        The adaptor to use
        pSocket -       A pointer to the socket to use
        hPMGR -         A handle to the page manager to create the socket stream.
        pIPvXDest -     The Dest IP to connect to if a client, ignored for a server open and may be NULL
        portRemote -    The remote port to connect to if Client, MUST be 0 if this is a server open for listen
        portLocal -     Local port to use, one will be assigned if zero
        pStatus -       A pointer to a status variable to recieve the status of the open, This may be NULL

  Returns:
        The Socket if opened, NULL on failure
  ***************************************************************************/
HSOCKET TCPOpenWithSocket(const LLADP * pLLAdp, TCPSOCKET * pSocket, HPMGR hPMGR, const void * pIPvXDest, uint16_t portRemote, uint16_t portLocal, IPSTATUS * pStatus)
{
    IPSTATUS    status      = ipsSuccess;
    IPSTACK *   pIpStack    = NULL;
    uint32_t    cbOptions   = 0;

    // make sure pIPvXDest points to something
    if(portRemote == 0 || pIPvXDest == NULL)
    {
        pIPvXDest = &IPv6NONE;
    }

    if(pSocket == NULL)
    {
        AssignStatusSafely(pStatus, ipsNoSocketsAvailable);
        return(NULL);
    }

    else if(pLLAdp == NULL)
    {
        status = ipsAdaptorMustBeSpecified;
    }

    // if this is a client open
    else if(    (pSocket = TCPInitSocket(pLLAdp, pSocket, hPMGR, pIPvXDest, portRemote, portLocal, &status)) != NULL  &&
                portRemote != portListen  &&
                (pIpStack = TCPCreateSyn(pSocket, &cbOptions, &status)) != NULL)
    {
        pSocket->tcpState               = tcpSynSent;
        pSocket->tLastAck               = SYSGetMilliSecond();

        // start the connection process
        TCPTransmit(pIpStack, pSocket, 1, cbOptions, false, SYSGetMilliSecond(), &status);
    }
    
    // else this is a server open / or an error getting the socket which we will abort below in the error check
    else if(pSocket != NULL)
    {
        pSocket->tcpState               = tcpListen;
    }

    // we got an error somewhere; clean up
    if(IsIPStatusAnError(status))
    {
        if(pSocket != NULL)
        {
            pSocket->tcpState = tcpUnassigned;
            TCPResetSocket(pSocket);
        }
        IPSRelease(pIpStack);
        pSocket = NULL;
        AssignStatusSafely(pStatus, status);
        return(NULL);
    }

    // put on the listening list.
    FFInPacket(&g_ffptActiveTCPSockets, pSocket);

    pSocket->fSocketOpen = true;
    AssignStatusSafely(pStatus, status);
    return((HSOCKET) pSocket);
 }

/*****************************************************************************
  Function:
	void TCPClose(SOCKET *  pSocket, IPSTATUS * pStatus)

  Description:
        This politely closes a socket, making sure no data is lost

  Parameters:
	pSocket:        The socket to close, it is always safe to close, closed sockets.
        pStatus:        A pointer to a status variable to recieve the state of the socket as a status

  Returns:
        None

  ***************************************************************************/
void TCPClose(HSOCKET hSocket, IPSTATUS * pStatus)
{
    TCPSOCKET * pSocket = (TCPSOCKET *) hSocket;

    if(pSocket == NULL)
    {
        AssignStatusSafely(pStatus, ipsSocketNULL);
        return;
    }

    switch(TCPState(pSocket))
    {
        case  tcpListen:
            // closes, releases the socket so it can be used again
            pSocket->tcpState = tcpClosed;
            break;

        case  tcpSynSent:
            // we do not update sndEND when we send a sndNXT, but we do update the sndNXT
            // this is because a syn is a phantom byte and we don't want to point beyond zero
            // in our output buffers and attempt to send a garbabe byte.
            // but in order to terminate properly we need sndNXT == sndEND or we will loop
            // attempting to send bytes from out buffer that we don't have to send
            pSocket->sndNXT = pSocket->sndEND;  // we may have sent a syn and sndNXT > sndEND
            pSocket->tcpState = tcpWaitUserClose;
            break;

        case  tcpSynReceived:
        case  tcpSynReceivedWhileListening:
            pSocket->sndNXT = pSocket->sndEND;  // we may have sent a syn and sndNXT > sndEND
            // fall thru

        case  tcpEstablished:
            pSocket->tcpState = tcpFinWait1;
            break;

        case  tcpFinWait1:
        case  tcpFinWait2:
        case  tcpCloseWait:
        case  tcpClosing:
        case  tcpLastAck:
        case  tcpInvalid:
        case  tcpUnassigned:
        case  tcpAllocated:
        case  tcpClosed:
        case  tcpWaitUserClose:
        default:
            break;
    }
    pSocket->fSocketOpen = false;

    // get the status
    AssignStatusSafely(pStatus, IPStatusFromTCPState(pSocket->tcpState));
}

/*****************************************************************************
  Function:
	uint32_t TCPSend(SOCKET *  pSocket, const void * pv, uint32_t cb, IPSTATUS * pStatus)

  Description:
         Stuff data into the socket to be sent on the next regularly scheduled send. Because of congestion
         control, this may take up to a fraction of a second to send. If you want it to go out immediately
         then call TCPFlush on the socket immediately after this call.

  Parameters:
	pSocket:        The socket to send the data on

        pv:             a pointer to a buffer of data to send

        cbReq:          The number of bytes to send.

        pStatus:        A pointer to a status variable to recieve the state of the send

  Returns:
        Number of bytes actually sent, could be less than requested if the socket is full.

  ***************************************************************************/
uint32_t TCPWrite(HSOCKET hSocket, const void * pv, uint32_t cbReq, IPSTATUS * pStatus)
{
    TCPSOCKET * pSocket = (TCPSOCKET *) hSocket;
    uint32_t    cb      = 0;

    if(pSocket == NULL)
    {
        AssignStatusSafely(pStatus, ipsSocketNULL);
        return(0);
    }

    // we can only write data if we are in the established state
    if(TCPIsEstablished(pSocket, pStatus))
    {
        SMGR *  pSMGR = (SMGR*)alloca(pSocket->cbTxSMGR);

        if(cbReq > 0 && pSMGR != NULL && (SMGRRead((HSMGR) &pSocket->smgrRxTxBuff, pSocket->cbRxSMGR, pSMGR, pSocket->cbTxSMGR) == pSocket->cbTxSMGR))
        {

            // This may seem like an odd place to do this, but I will update the sndUNA pointers here
            // I do this here instead of in the ACK processing because I do not want to take the time to open up the
            // stream in the ACK process, I just want to update the sndUNA pointer and move on. The downside of this is that
            // we may hold some pages longer than we need, but before I take MORE memory in the write, I will free those pages
            // which is why I will do that here before we WRITE our data below.
            TCPScaleSndIndexes(pSocket, pSMGR);

            // after we have scaled our pointers and potentially released some memory, we can
            // write as much data as we can to the stream
            cb  = SMGRWrite((HSMGR) pSMGR, SMGRcbStream(pSMGR), pv, cbReq);
            pSocket->sndEND += cb;

            // save away the table that is stored on the stack
            // this should not fail! It is a fixed size and already allocated
            SMGRWrite((HSMGR) &pSocket->smgrRxTxBuff, pSocket->cbRxSMGR, pSMGR, pSocket->cbTxSMGR);
        }
    }

    return(cb);
}

/*****************************************************************************
  Function:
	void TCPFlush(SOCKET *  pSocket)

  Description:
        Causes any outstanding data in the socket to be transmitted as fast as possible without delay.

  Parameters:
	pSocket:        The socket to flush

  Returns:
         None

  ***************************************************************************/
void TCPFlush(HSOCKET hSocket)
{
    TCPSOCKET * pSocket = (TCPSOCKET *) hSocket;

    if(pSocket != NULL)
    {
        // say we need to push everything we have in the out going buffer.
        pSocket->sndPSH = pSocket->sndEND;
    }
}

/*****************************************************************************
  Function:
	uint32_t TCPAvailable(SOCKET *  pSocket, IPSTATUS * pStatus)

  Description:
            Returns the number of unread bytes in the socket receive buffer

  Parameters:
	pSocket:        The socket to get the number of unread bytes
        pStatus:        A pointer to a status variable to recieve the state of the socket as a status

  Returns:
        Number of unread bytes in the socket, or zero

  ***************************************************************************/
uint32_t TCPAvailable(HSOCKET hSocket, IPSTATUS * pStatus)
{
    TCPSOCKET * pSocket = (TCPSOCKET *) hSocket;
    uint32_t    rcvNXT  = 0;

    if(pSocket == NULL)
    {
        AssignStatusSafely(pStatus, ipsSocketNULL);
        return(0);
    }

    AssignStatusSafely(pStatus, IPStatusFromTCPState(pSocket->tcpState));

    switch(TCPState(pSocket))
    {
        // get rid of the FIN that is in the count
        case  tcpEstablished:
        case  tcpSynReceived:
        case  tcpSynReceivedWhileListening:
        case  tcpCloseWait:
        case  tcpLastAck:
        case  tcpWaitUserClose:
        case  tcpFinWait1:
        case  tcpFinWait2:
        case  tcpClosing:
            rcvNXT = pSocket->rcvNXT;
            if(pSocket->fGotFin)
            {
                rcvNXT--;
            }
            break;

        case  tcpListen:
        case  tcpSynSent:
        case  tcpInvalid:
        case  tcpUnassigned:
        case  tcpAllocated:
        case  tcpClosed:
        default:
            return(0);
            break;
    }

    // how much can we read
    return(rcvNXT);
}

/*****************************************************************************
  Function:
	uint32_t TCPPeekSMGR(TCPSOCKET * pSocket, HSMGR pSMGR, uint8_t * pbRead, uint16_t cbRead, IPSTATUS * pStatus)

  Description:
        Reads bytes out of the receive buffer but does not move the unread pointer,
        peek or receive will return the same data.

  Parameters:
	pSocket:        The socket to read the bytes from
        pSMGR:          pointer to an open stream
        pbRead:         A buffer to receive the data
        cbRead:         Max size of the buffer to receive the data
        pStatus:        A pointer to a status variable to recieve the state of the socket as a status

  Returns:
        Number of bytes read

  ***************************************************************************/
static uint32_t TCPPeekSMGR(TCPSOCKET * pSocket, HSMGR pSMGR, uint16_t index, uint8_t * pbRead, uint16_t cbRead, IPSTATUS * pStatus)
{
    int32_t    cb = 0;
    IPSTATUS status = ipsSuccess;

    if(pSocket == NULL)
    {
        status = ipsSocketNULL;
    }
    else if(pbRead == NULL || cbRead == 0)
    {
        status =  ipsBufferNotDefined;
    }
    else if(pSocket->s.portRemote == portListen || pSocket->s.portRemote == portInvalid)
    {
        status =  ipsSocketNotResolved;
    }
    else if(pSMGR == NULL)
    {
        status = ipsNoSMGRGiven;
    }
    else
    {
        cb = SMGRRead((HSMGR) pSMGR, index, pbRead, min((SMGRcbStream(pSMGR) - index), cbRead));
    }

    AssignStatusSafely(pStatus, status);
    return(cb);
}

/*****************************************************************************
  Function:
	uint32_t TCPPeek(SOCKET *  pSocket, void * pv, uint32_t cb, IPSTATUS * pStatus)

  Description:
        Reads bytes out of the receive buffer but does not move the unread pointer,
        peek or receive will return the same data.

  Parameters:
	hSocket:        The socket to read the bytes from
        index:          Number of bytes in to start the peek
        pbRead:         A buffer to receive the data
        cbRead:         Max size of the buffer to receive the data
        pStatus:        A pointer to a status variable to recieve the state of the socket as a status

  Returns:
        Number of bytes read

  ***************************************************************************/
uint32_t TCPPeekIdx(HSOCKET hSocket, uint32_t index, void * pbRead, uint32_t cbRead, IPSTATUS * pStatus)
{
    TCPSOCKET *     pSocket     = (TCPSOCKET *) hSocket;
    IPSTATUS        status      = ipsSocketNULL;

    if(pSocket != NULL && pSocket->cbRxSMGR > 0)
    {
        SMGR *  pSMGR = (SMGR*)alloca(pSocket->cbRxSMGR);

        if(SMGRRead((HSMGR) &pSocket->smgrRxTxBuff, 0, pSMGR, pSocket->cbRxSMGR) == pSocket->cbRxSMGR)
        {
            // because we are only READing, no need to update the stream tables
            return(TCPPeekSMGR(pSocket, (HSMGR) pSMGR, (uint16_t) index, (u8*)pbRead, cbRead, pStatus));
        }
        status = ipsFailedToReadStreamBuffer;
    }

    AssignStatusSafely(pStatus, status);
    return(0);
}

/*****************************************************************************
  Function:
	uint32_t TCPRead(SOCKET *  pSocket, void * pv, uint32_t cb, IPSTATUS * pStatus)

  Description:
        Reads bytes out of the receive buffer. We call this receive instead of read because RFC 793 calls it receive.

  Parameters:
	pSocket:        The socket to read the bytes from
        pv:             A buffer to receive the data
        cb:             Max size of the buffer to receive the data
        pStatus:        A pointer to a status variable to recieve the state of the socket as a status

  Returns:
        Number of bytes read

  ***************************************************************************/
uint32_t TCPRead(HSOCKET hSocket, void * pbRead, uint32_t cbRead, IPSTATUS * pStatus)
{
    TCPSOCKET *     pSocket     = (TCPSOCKET *) hSocket;
    IPSTATUS        status      = ipsSocketNULL;
    uint32_t cb = 0;

    if(pSocket != NULL && pSocket->cbRxSMGR > 0)
    {
        SMGR *  pSMGR = (SMGR*)alloca(pSocket->cbRxSMGR);

        if(SMGRRead((HSMGR) &pSocket->smgrRxTxBuff, 0, pSMGR, pSocket->cbRxSMGR) == pSocket->cbRxSMGR)
        {
            cb = TCPPeekSMGR(pSocket, (HSMGR) pSMGR, 0, (u8*)pbRead, cbRead, &status);

            if(cb > 0)
            {
                // move the begining to after what we read
                SMGRMoveEnd((HSMGR) pSMGR, cb, SMGRAtBegining);

                // apply the read bytes to our base
                pSocket->rcvIRS += cb;

                // and now fix up to the base
                pSocket->rcvNXT -= cb;
                pSocket->rcvUP  -= cb;
//                pSocket->rcvSeqAhead -= cb;
            }

            // save away the table that is stored on the stack
            // this should not fail! It is a fixed size and already allocated
            SMGRWrite((HSMGR) &pSocket->smgrRxTxBuff, 0, pSMGR, pSocket->cbRxSMGR);
        }
        else
        {
            status = ipsFailedToReadStreamBuffer;
        }
    }

    AssignStatusSafely(pStatus, status);
    return(cb);
}

/*****************************************************************************
  Function:
	void TCPDiscard(SOCKET *  pSocket)

  Description:
        Discards all unread bytes in the sockets receive buffer.

  Parameters:
	hSocket:        The socket to clear the receive buffer from

  Returns:
        None

  ***************************************************************************/
void TCPDiscard(HSOCKET hSocket)
{
    TCPSOCKET *     pSocket     = (TCPSOCKET *) hSocket;

    if(pSocket != NULL && pSocket->cbRxSMGR > 0)
    {
        SMGR *  pSMGR = (SMGR*)alloca(pSocket->cbRxSMGR);

        if(SMGRRead((HSMGR) &pSocket->smgrRxTxBuff, 0, pSMGR, pSocket->cbRxSMGR) == pSocket->cbRxSMGR)
        {
            uint32_t iEnd = SMGRcbStream(pSMGR);

            // clear the stream by moving to the end
            SMGRMoveEnd((HSMGR) pSMGR, iEnd, SMGRAtBegining);

            // pretend like we read it
            // apply the read bytes to our base
            pSocket->rcvIRS += pSocket->rcvNXT;

            // and now fix up to the base
            pSocket->rcvNXT = 0;
            pSocket->rcvUP  = 0;
            
//            if(pSocket->rcvSeqAhead >= pSocket->rcvNXT)
//            {
//                pSocket->rcvSeqAhead -= pSocket->rcvNXT;
//            }
//            else
//            {
//                pSocket->rcvSeqAhead = 0;
//            }

            // save away the table that is stored on the stack
            // this should not fail! It is a fixed size and already allocated
            SMGRWrite((HSMGR) &pSocket->smgrRxTxBuff, 0, pSMGR, pSocket->cbRxSMGR);
        }
    }
}

/*****************************************************************************
  Function:
	void TCPAbort(SOCKET * pSocket)

  Description:
    Abruptly and non in a friendly way aborts the connection right now. It does
    send a reset to the remote; but that is it.

  Parameters:
	pSocket:        The socket to abort

  Returns:
        None

  ***************************************************************************/
void TCPAbort(HSOCKET hSocket)
{
    TCPSOCKET * pSocket = (TCPSOCKET *) hSocket;

    // just return.
    if(pSocket == NULL)
    {
        return;
    }
    // send the reset
    // RFC 793, these are the states to send a reset.
    if(tcpSynReceived <= pSocket->tcpState && pSocket->tcpState <= tcpCloseWait)
    {
        IPSTACK * pIpStack = IPSRefresh(NULL, pSocket->s.pLLAdp, NULL);

        // <SEQ=SND.NXT><CTL=RST>
        // clear so there is a zero ACK
        pSocket->rcvIRS = 0;
        pSocket->rcvNXT = 0;

        // say this is a reset
        pIpStack->pTCPHdr->fRst = true;

        // send the reset with no ACK
        TCPTransmit(pIpStack, pSocket, 0, 0, false, SYSGetMilliSecond(), NULL);

        // when we are done, free the stack
        IPSRelease(pIpStack);
    }

    // we do not want to put this back on the listenging queue.
    // we pretty much just want to clean up
    pSocket->tcpState = tcpUnassigned;
    TCPResetSocket(pSocket);

    return;
}
