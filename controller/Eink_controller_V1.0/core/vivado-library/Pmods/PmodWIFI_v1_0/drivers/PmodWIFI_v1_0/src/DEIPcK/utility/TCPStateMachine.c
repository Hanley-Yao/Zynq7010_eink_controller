/************************************************************************/
/*                                                                      */
/*	TCPStateMachine.c  This the RFC 793 TCP State Machine               */
/*                                                          		    */
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
/*	To understand this module, go get a copy of RFC 793                 */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	12/13/2012(KeithV): Created                                         */
/*                                                                      */
/************************************************************************/
#include "deIP.h"

// foward references to local functions
static bool TCPCheckForRST(IPSTACK *  pIpStack, TCPSOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus);
static void TCPProcessSYN(IPSTACK *  pIpStack, TCPSOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus);
static void TCPProcessACK(IPSTACK *  pIpStack, TCPSOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus);
static bool TCPCheckForReTransmit(IPSTACK *  pIpStack, TCPSOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus);
static bool TCPProcessTxSocketBuffers(IPSTACK * pIpStack, TCPSOCKET * pSocket, uint32_t tCur, int32_t * pcbSend);
static IPSTACK * TCPFlushSocketAndFIN(IPSTACK * pIpStack, TCPSOCKET * pSocket, uint32_t tCur, int32_t * pcbSend);
static void UpdateSaSv(TCPSOCKET *  pSocket, int32_t rtt);

/*********************************************************************
 * Function:        void TCPStateMachine(IPSTACK *   pIpStack, SOCKET *  pSocket, IPSTATUS * pStatus)
 *
 * Input:           pIpStack    If data came in on the adaptor, the
 *                              this contains the incoming segment.
 *
 *                  pSocket     The socket to be processessed. All active sockets are process on each loop,
 *                              so the pStack can easily be NULL if no data come in on the adaptor.
 *                              The pSocket can be NULL if data came in on the adaptor for our IP
 *                              but did not match any active or listin port.
 *
 *
 *
 * Output:          pStatus An optional status variable to recieve the status/error of the function
 *
 * Returns:         None
 *
 * Note:            This is the fundamental implementation of the RFC 793 / 1122 TCPIP state machine.
 *
 ********************************************************************/
void TCPStateMachine(IPSTACK *   pIpStack, TCPSOCKET *  pSocket, IPSTATUS * pStatus)
{
    IPSTATUS        status          = ipsSuccess;
    int32_t         cbTCPSeg        = 0;
    int32_t         cbOptions       = 0;
    uint32_t        tCur            = SYSGetMilliSecond();

    // If we got a stack, we got something coming in.
    // this is just not a TCP stack maintanience call.
    if(pIpStack != NULL)
    {
        /************************************************************************************/
        /************************************************************************************/
        /*********************************   PROCESS ACK    *********************************/
        /************************************************************************************/
        /************************************************************************************/
        TCPProcessACK(pIpStack, pSocket, tCur, pStatus);
        
        /************************************************************************************/
        /************************************************************************************/
        /*********************************   PROCESS RESETS *********************************/
        /************************************************************************************/
        /************************************************************************************/

        // if a RST was sent, get out of the TCP state machine
        if(TCPCheckForRST(pIpStack, pSocket, tCur, pStatus))
        {
            pIpStack = IPSRelease(pIpStack);
            return;
        }

        /************************************************************************************/
        /************************************************************************************/
        /*********************************   PROCESS SYN    *********************************/
        /************************************************************************************/
        /************************************************************************************/
        TCPProcessSYN(pIpStack, pSocket, tCur, pStatus);

        /************************************************************************************/
        /************************************************************************************/
        /*************************   SAVE PAYLOAD DATA IN SOCKET    *************************/
        /************************************************************************************/
        /************************************************************************************/

        // TCPCheckForRST does SEQ checking, so we should just process any data that comes in
        if(pIpStack->cbPayload > 0 && tcpListen <= pSocket->tcpState && pSocket->tcpState <= tcpClosing)
        {
            // if we got data, we need to ACK it.
            if(pSocket->cNeedAck < 15)
            {
                pSocket->cNeedAck++;
            }

            // add the data to our socket.
            TCPAddRxDataToSocket(pSocket, pIpStack->pTCPHdr->seqNbr, (u8*)pIpStack->pPayload, pIpStack->cbPayload);
        }
    }   // end of that we got an IpStack

    /************************************************************************************/
    /************************************************************************************/
    /*********************************   RETRANSMIT    **********************************/
    /************************************************************************************/
    /************************************************************************************/
    if(TCPCheckForReTransmit(pIpStack, pSocket, tCur, pStatus))
    {
        pIpStack = IPSRelease(pIpStack);
        return;
    }

    /************************************************************************************/
    /************************************************************************************/
    /***************************** TCP  STATE MACHINE    ********************************/
    /************************************************************************************/
    /************************************************************************************/
    switch(pSocket->tcpState)
    {
        // listen -> synRecieved -> established
        case tcpListen:         // only looking for a syn


            // We are looking for a SYN to connect
            if(pIpStack != NULL && pIpStack->pTCPHdr->fSyn)
            {
                uint32_t    cbOptions       = 0;

                // fix up our socket with the attaching data
                pSocket->tcpState       =   tcpSynReceivedWhileListening;       // no longer listening
                pSocket->s.portRemote   =   pIpStack->pTCPHdr->portSrc;

                if(ILIsIPv6(pSocket->s.pLLAdp))
                {
                    memcpy(&pSocket->s.ipRemote.ipv6, &pIpStack->pIPv6Hdr->ipSrc, sizeof(IPv6));
                }
                else
                {
                    memcpy(&pSocket->s.ipRemote.ipv4, &pIpStack->pIPv4Hdr->ipSrc, sizeof(IPv4));
                }

                // because I can't be sure that they sent me the MSS option, I need to blow away their
                //IpStack and get my own where I know I will have the 4 bytes for the options.
                pIpStack = IPSRelease(pIpStack);

                // this will always get me a new IpStack, but I may be out so if it
                // fails I need to clean up; it is the best I can do with no resources
                if((pIpStack = TCPCreateSyn(pSocket, &cbOptions, &status)) != NULL)
                {
                    // set up for the transmit
                    cbTCPSeg                        = 1;    // a SYN is 1 byte long.
                    cbOptions                       = cbOptions;
                    pSocket->tLastAck               = tCur;
                    pSocket->sndISS                 = TCPGetSeqNumber(pSocket->s.pLLAdp);
                }

                // reset the socket to the listening state; wait for another SYN
                // maybe then we will have IpStack resources to accept the connection
                else
                {
                    TCPResetSocket(pSocket);
                }
            }           
            break;

        case tcpSynSent:

            // we are waiting for a SYN
            if(pIpStack != NULL && pIpStack->pTCPHdr->fSyn)
            {
                // it is allowable that we get a SYN without an ACK
                // if we get a SYN, we must ACK their SYN at least
                pIpStack = IPSRefresh(pIpStack, pSocket->s.pLLAdp, &status);
            
                // moing to the SynRecieved state
                // there we will check to see if we got the ACK to our SYN
                pSocket->tcpState   = tcpSynReceived;                
            }
            else
            {
                // safe to release a NULL stack
                pIpStack = IPSRelease(pIpStack);
            }
            break;

        case tcpSynReceivedWhileListening: // just to remember that it came from a Listening state
        case tcpSynReceived:               // only looking for an ack

            // RFC 793 section 3.4 figure 8
            // At this point, I am just waiting for an ACK
            // to my SYN. I could have either been in the syn packet return at the tcpSynSent
            // or just waiting for an ACK, even with data in it.
            // I just want my ACK!
            if(pSocket->sndUNA < pSocket->sndNXT)
            {
                // otherwise he did not ack our SYN, so just toss and wait for the SYN ACK
                pIpStack = IPSRelease(pIpStack);
                break;
            }

            // before we go to established, set all of our send
            // indexes to the front of the buffer
            // this absolutely safe because we know pSocket->sndNXT == 1
            // because this implementation will NOT send data on the SYN, in fact
            // this implementation will NOT send data until we are in the established state
            // so I know the only value of sndNXT is the SYN, which is 1
            // now we need to set sndNXT to zero, because that will point the to the beginning of our snd buffer.
            pSocket->sndISS     += pSocket->sndNXT;         
            pSocket->sndRTTComplete = 0;    // we are just going to restart the timer
            pSocket->sndNXT     = 0;
            pSocket->sndUNA     = 0;
            pSocket->sndUP      = 0;
            pSocket->sndEND     = 0;
            pSocket->sndPSH     = 0;
            pSocket->cTxUntilPause = CNTPAUSESEND;

            pSocket->tcpState   = tcpEstablished;

            // fall into establish

       case tcpEstablished:

            // we have an incoming FIN, process it.
            if(pIpStack != NULL && pIpStack->pTCPHdr->fFin)
            {
                // this can get very tricky. But if the sender is in a retransmit state
                // where he is sending me SEQ NBR before where I actually am, but then just
                // decided to close the connection, the FIN would come in on a SEQ NBR too
                // early.
                // we know we are sending an ack out
                pIpStack = IPSRefresh(pIpStack, pSocket->s.pLLAdp, pStatus);

                // say we received the fin
                pSocket->rcvNXT++;
                pSocket->fGotFin = true;

                // we can send the fin with the ack if we have no data to flush
                if( pSocket->sndNXT == pSocket->sndEND)
                {
                    pSocket->tcpState       = tcpLastAck;
                    cbTCPSeg                = 1;
                    pIpStack->pTCPHdr->fFin = true;
                }

                // otherwise we must wait to flush the data in our buffers first
                else
                {
                    pSocket->tcpState = tcpCloseWait;
                }
            }

            // We always want to call TCPProcessTxSocketBuffers
            // it will check to see if we need to send something
            // It will also do congestion control.
            // always refress the stack, it will use the existing one if we have one
            // or get one if we do not have one. If we are not to send we will
            // release the aquired pIpStack.
            else if(    ((pIpStack = IPSRefresh(pIpStack, pSocket->s.pLLAdp, pStatus)) != NULL)      &&
                        !TCPProcessTxSocketBuffers(pIpStack, pSocket, tCur, &cbTCPSeg)       )
            {
                pIpStack = IPSRelease(pIpStack);
            }
            break;

        // This is where we go if we get a FIN from them
        // We need to flush our data and then send a FIN to  them
        case tcpCloseWait:
            
             if((pIpStack = TCPFlushSocketAndFIN(IPSRefresh(pIpStack, pSocket->s.pLLAdp, &status), pSocket, tCur, &cbTCPSeg)) != NULL  &&
                pIpStack->pTCPHdr->fFin )
            {
                pSocket->tcpState           = tcpLastAck;
            }
            break;

        // just waiting for them to ack our fin.
        case tcpLastAck:

            // We got the ACK to our FIN; we are DONE
            if(pIpStack != NULL && pSocket->sndUNA == pSocket->sndNXT)
            {
                pSocket->tcpState = tcpWaitUserClose;
            }

            // always releaset the stack as we have nothing to send back
            pIpStack = IPSRelease(pIpStack);
            break;

        // This is the queing of the close until we flush our data
        case tcpFinWait1:

            // not really expecting this, but we could just get their FIN while we are closeing.
            // so just ACK their FIN and then pretend we got this during the established state
            // and go to the CloseWaiting state to flush our Tx buffer and send our FIN
            if(pIpStack != NULL && pIpStack->pTCPHdr->fFin)
            {
                pIpStack = IPSRefresh(pIpStack, pSocket->s.pLLAdp, pStatus);

                // say we received the fin
                pSocket->rcvNXT++;
                pSocket->fGotFin = true;
                pSocket->tcpState = tcpCloseWait;
            }

            // otherwise continue to flush our Tx buffer
            else if((pIpStack = TCPFlushSocketAndFIN(IPSRefresh(pIpStack, pSocket->s.pLLAdp, &status), pSocket, tCur, &cbTCPSeg)) != NULL  &&
                pIpStack->pTCPHdr->fFin )
            {
                // This is the fin packet
                // go wait for their ACK and FIN
                pSocket->tcpState   = tcpFinWait2;
            }
            break;

        // we MUST get an ack to our fin
        // the question is, do we also get a fin from them?
        case tcpFinWait2:
            if(pIpStack != NULL)
            {
                // We got the fIN; all we have to do is ack it and we are done
                if(pIpStack->pTCPHdr->fFin)
                {
                    pSocket->rcvNXT++;
                    pSocket->fGotFin = true;
                    pIpStack = IPSRefresh(pIpStack, pSocket->s.pLLAdp, pStatus);

                    // we got the ACT to our FIN; we are done
                    if(pSocket->sndUNA == pSocket->sndNXT)
                    {
                        pSocket->tcpState       = tcpWaitUserClose;
                    }

                    // otherwise we have to wait for them to ACK our FIN
                    else
                    {
                        pSocket->tcpState       = tcpLastAck;
                    }
                }

                // we only got an ack, but make sure this is the ack to our fin
                else if(pSocket->sndUNA == pSocket->sndNXT)
                {
                    // do not send an ack, just for an ack; we only want to ack the final fIN
                    pIpStack = IPSRelease(pIpStack);
                    pSocket->tcpState       = tcpClosing;

                    // now in this state sndUNA == sndNXT and out connection
                    // is in a stable state that will wait forever. But clearly
                    // we are not going to wait forever to get the final FIN
                    // so set our time and in the tcpClosing if we wait too long
                    // we will send a RST and clean up the socket.
                    pSocket->tLastAck       = tCur;
                }

                // we are still waiting for the ack of our fin
                else
                {
                    pIpStack = IPSRelease(pIpStack);
                }
            }
            break;

        case tcpClosing:
            // we never got their fin, we are waiting for it
            if(pIpStack != NULL)
            {
                // We got the FIN; all we have to do is ACK it and we are done
                if(pIpStack->pTCPHdr->fFin)
                {
                    pSocket->rcvNXT++;
                    pSocket->fGotFin = true;
                    pIpStack = IPSRefresh(pIpStack, pSocket->s.pLLAdp, pStatus);
                    pSocket->tcpState       = tcpWaitUserClose;
                }

                // otherwise keep waiting, for their FIN
                else
                {
                    pIpStack = IPSRelease(pIpStack);
                }
            }
            break;

        case tcpWaitUserClose:
            pIpStack = IPSRelease(pIpStack);

            // spin until the user explicitly closes the socket
            // this will keep the data for the user to completely read
            if(pSocket->fSocketOpen == false)
            {
                pSocket->tcpState = tcpClosed;
            }
            break;

        // Shut the socket down
        case tcpClosed:
            pIpStack = IPSRelease(pIpStack);
            TCPResetSocket(pSocket);                  
            break;

        default:
            pIpStack = IPSRelease(pIpStack);
            status = ipsUnknowTCPState;
            if(pSocket != NULL)
            {
                pSocket->tcpState = tcpUnassigned;
                TCPResetSocket(pSocket);
            }
            break;
    }

    if(pIpStack != NULL && !IsIPStatusAnError(status))
    {
        TCPTransmit(pIpStack, pSocket, cbTCPSeg, cbOptions, true, tCur, &status);
    }

    AssignStatusSafely(pStatus, status);
    return;
}

/*********************************************************************
 * Function:        bool TCPCheckForRST(IPSTACK *  pIpStack, SOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus)
 *
 * Input:           pIpStack    If data came in on the adaptor, the
 *                              this contains the incoming segment.
 *
 *                  pSocket     The socket to be processessed. All active sockets are process on each loop,
 *                              so the pStack can easily be NULL if no data come in on the adaptor.
 *                              The pSocket can be NULL if data came in on the adaptor for our IP
 *                              but did not match any active or listin port.
 *
 *                  tCur        The time when we entered the TCP State machine
 *
 *
 *
 * Output:          pStatus An optional status variable to recieve the status/error of the function
 *
 * Returns:         true if process and error and the TCP state machine should exit, false if there were no errors.
 *
 * Note:            This a preprocessor on the incoming segment and socket
 *                  It makes sure that things look good, or it send a RST or ACK
 *                  or cleans up the socket according to the requirements of the RFCs.
 *
 ********************************************************************/
static bool TCPCheckForRST(IPSTACK *  pIpStack, TCPSOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus)
{
    bool    fAck    = false;
    TCPSOCKET  socket;
    
    // most common error code
    AssignStatusSafely(pStatus, ipsTCPRSTPkt);

    // this should not happen
    if(pIpStack == NULL)
    {
        return(true);
    }

    // If we are going to send reset, it will
    // be on a created dummy socket because we must
    // control so much of the values it it.
    memset(&socket, 0, sizeof(socket));

    // here is a very special case. Somebody is attempting to connect to a socket (port) that does not exist
    // it is either not listening or established; we must send a reset
    // RFC 793 Reset Generation point 1.

    // Point 1, the socket is closed or not in any kind of active state
    if(pSocket == NULL)
    {
        // do nothing, but don't process
        if(pIpStack->pTCPHdr->fRst)
        {
            return(true);
        }
        if(pIpStack->pTCPHdr->fAck)
        {
            // <SEQ=SEG.ACK><CTL=RST>
            socket.sndISS   = pIpStack->pTCPHdr->ackNbr;
        }
        else
        {
            // <SEQ=0><ACK=SEG.SEQ+SEG.LEN><CTL=RST,ACK>
            socket.sndISS   = 0;
            socket.rcvIRS   = pIpStack->pTCPHdr->seqNbr + pIpStack->cbPayload;
            fAck            = true;
            
            // add the syn if a syn came in
            if(pIpStack->pTCPHdr->fSyn)
            {
                socket.rcvIRS++;
            }
        }
    }

    else
    {

        switch(pSocket->tcpState)
        {
            case tcpListen:
                if(pIpStack->pTCPHdr->fRst)
                {
                    // discard as a bad segement
                    return(true);
                }

                // we shouldn't get an ACK when listening
                else if(pIpStack->pTCPHdr->fAck)
                {
                    // <SEQ=SEG.ACK><CTL=RST>
                    socket.sndISS   = pIpStack->pTCPHdr->ackNbr + pSocket->sndISS;;
                }

                // we expect to see a SYN without an ACK
                // so this is a good segment
                else if(pIpStack->pTCPHdr->fSyn)
                {
                    // we would typically do priority checking here
                    // but we have no prioity.

                    // otherwise this is a good segment.
                    AssignStatusSafely(pStatus, ipsSuccess);
                    return(false);
                }
                // on a listen, the only thing we should get is a SYN
                else
                {
                    // Not sure exactly how I woudl get here
                    // no RST, no ACK, no SYN; what is that?
                    AssignStatusSafely(pStatus, ipsUnknowTCPState);
                    return(true);
                }
                break;

            case tcpSynSent:
            case tcpSynReceivedWhileListening:          // the Listen sent the SYN, so we are waiting for a ACK on the SYN sent by the listen
            case tcpSynReceived:
                if(pIpStack->pTCPHdr->fAck)
                {
                    // if the ACK is in range and
                    // really this means pIpStack->pTCPHdr->ackNbr == (pSocket->sndISS + 1)
                    // if the ackNbr is less than sndISS, because of scaling it will be really big (as we are unsigned, so neg is big positive),
                    // in fact so big outside of sndNXT
                    // the assumption is that our sndISS is still at its orignial base value, and until we get a SYN this is true.
                    if(0 < pIpStack->pTCPHdr->ackNbr && pIpStack->pTCPHdr->ackNbr <= pSocket->sndNXT)
                    {
                        if(pIpStack->pTCPHdr->fRst)
                        {
                            // We are being told to shut down and reset
                            TCPResetSocket(pSocket);
                            return(true);
                        }

                        // otherwise, this is a good packet
                        // fall thru to the next check
                    }

                    // we are out of range, send a RST
                    else if(!pIpStack->pTCPHdr->fRst)
                    {
                        // <SEQ=SEG.ACK><CTL=RST>
                        socket.sndISS   = pIpStack->pTCPHdr->ackNbr + pSocket->sndISS;

                        // break out to process the reset
                        break;
                    }

                    // got a RST, so don't respond
                    else
                    {
                        return(true);
                    }
                }

                // random reset with no ACK, just ignore and return
                else if(pIpStack->pTCPHdr->fRst)
                {
                    
                    // MAC OS / Safari is very bad, they will
                    // start a connection and then not ACK my SYN
                    // the will just send a RST; bad bad Safari, they need
                    // to send the ACK with it, they started the connection
                    // if this is the correct seqNbr, remove the socket
                    if(pIpStack->pTCPHdr->seqNbr == pSocket->rcvNXT)
                    {
                        TCPResetSocket(pSocket);
                    }

                    return(true);
                }

                // Things look good, now we need to check
                // sequence number, but onthe SynSent state we
                // sequence number yet to check, so just say the packet it good
                if(pSocket->tcpState == tcpSynSent)
                {
                    AssignStatusSafely(pStatus, ipsSuccess);
                    return(false);
                }

                // otherwise, fall through and check the sequence number

            default:

                if( tcpSynReceivedWhileListening    <=  pSocket->tcpState  &&
                    pSocket->tcpState               <=  tcpLastAck          )
                {
                    // check to see if their seq number is within my recieve window
//                    if( (   rcvTOP(pSocket) > pSocket->rcvNXT                                   &&
                    if( (   pIpStack->pTCPHdr->seqNbr <= pSocket->rcvNXT                        &&   // I don't allow out of order seq numbers.
                              pSocket->rcvNXT <= (pIpStack->pTCPHdr->seqNbr + pIpStack->cbPayload) )
                                        ||
//                        (   rcvTOP(pSocket) == pSocket->rcvNXT                                  &&
                        (   pIpStack->pTCPHdr->seqNbr == pSocket->rcvNXT                        &&
                            pIpStack->cbPayload == 0                                            ))

                     {
                        // if we are asked to reset, then reset the socket
                        if(pIpStack->pTCPHdr->fRst)
                        {
                            // We are being told to shut down and reset
                            TCPResetSocket(pSocket);
                            return(true);
                        }
                        else
                        {
                            // a good segment, process it
                            AssignStatusSafely(pStatus, ipsSuccess);
                            return(false);
                        }
                    }

                    // out of range SEQ, we send an ACK with the right stuff in it.
                    // this will send an dup ACK where seq == sndRCV and segLen == 0.
                    // another common condition if they retransmit a packet that I already recieved, I will ACK it.
                    else if(!pIpStack->pTCPHdr->fRst)
                    {
//                        IPSTACK *  pIpStack2 = IPSRefresh(NULL, pSocket->s.pLLAdp, pStatus);
//                        TCPTransmit(pIpStack2, pSocket, 0, 0, true, tCur, pStatus);
//                        pIpStack2 = IPSRelease(pIpStack2);

//                        if(pIpStack->pTCPHdr->seqNbr > pSocket->rcvNXT)
//                        {
//                            pSocket->rcvSeqAhead = pIpStack->pTCPHdr->seqNbr;
//                        }

                        // <SEQ=SND.NXT><ACK=RCV.NXT><CTL=ACK>
                        pIpStack = IPSRefresh(pIpStack, pSocket->s.pLLAdp, pStatus);
                        TCPTransmit(pIpStack, pSocket, 0, 0, true, tCur, pStatus);

                        AssignStatusSafely(pStatus, ipsSeqOutOfBoundsACKResponse);
                        return(true);
                    }
                }

                AssignStatusSafely(pStatus, ipsUnknowTCPState);
                return(true);
                break;
        }
    }

    // if we got here, we know we are sending a RST
    socket.s.pLLAdp = pIpStack->pLLAdp;

    // do this before refreshing (swapping). That is because
    // the order in the stack is opposite of the order in the socket
    // this is so the LL can just do a uint32_t compare on the pair and match
    socket.s.portPair = pIpStack->pTCPHdr->portPair;

    // prepare to send the response
    // this will always pass as we know we have an IpStack
    IPSRefresh(pIpStack, pIpStack->pLLAdp, pStatus);

    // make a dummy socket with IP and port
    if(ILIsIPv6(pIpStack->pLLAdp))
    {
        memcpy(&socket.s.ipRemote.ipv6, &pIpStack->pIPv6Hdr->ipDest, sizeof(IPv6));
    }
    else
    {
        memcpy(&socket.s.ipRemote.ipv4, &pIpStack->pIPv4Hdr->ipDest, sizeof(IPv4));
    }

    // say this is a reset
    pIpStack->pTCPHdr->fRst = true;

    // send the reset with no ACK
    TCPTransmit(pIpStack, &socket, 0, 0, fAck, tCur, pStatus);

    AssignStatusSafely(pStatus, ipsConnectionOutofSyncSendRST);
    return(true);
}

/*********************************************************************
 * Function:        void TCPProcessSYN(IPSTACK *  pIpStack, SOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus)
 *
 * Input:           pIpStack    If data came in on the adaptor, the
 *                              this contains the incoming segment.
 *
 *                  pSocket     The socket to be processessed. All active sockets are process on each loop,
 *                              so the pStack can easily be NULL if no data come in on the adaptor.
 *                              The pSocket can be NULL if data came in on the adaptor for our IP
 *                              but did not match any active or listin port.
 *
 *                  tCur        The time when we entered the TCP State machine
 *
 *
 *
 * Output:          pStatus An optional status variable to recieve the status/error of the function
 *
 * Returns:         None
 *
 * Note:            This process an incoming SYN, it should be valid as
 *                  TCPCheckForRST should have killed all invalid stuff
  *
 ********************************************************************/
static void TCPProcessSYN(IPSTACK *  pIpStack, TCPSOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus)
{
    UNUSED(tCur);
    AssignStatusSafely(pStatus, ipsSuccess);

    // Process a SYN
    // Error checking for a bad SYN should have been done in TCPCheckForRST
    if(pIpStack->pTCPHdr->fSyn)
    {
        // and only if the syn makes sense; get the info out of the syn packet
        // I have to undo what I did when I normalized the number;
        // by adding 1 to the sequence nbr, we are acking the syn without changing the indexing
        // in our receive buffers.
        pSocket->rcvIRS                 = pIpStack->pTCPHdr->seqNbr + 1;    // init it

        // process options
        // RFC 1122 4.2.2.6, Should have MSS option
        pSocket->cbRemoteEffMSS = 0;               // init it so not to have bogus stuff from a prev bad SYN
        if(pIpStack->pTCPHdr->dataOffset > sizeof(TCPHDR)/sizeof(uint32_t))
        {
            TCPOPTION * pOption         = (TCPOPTION *) (pIpStack->pTCPHdr+1);
            uint32_t    cbOptionsT      = pIpStack->pTCPHdr->dataOffset * sizeof(uint32_t) - sizeof(TCPHDR);

            // run the options
            while(cbOptionsT > 0)
            {
                // if this is
                switch(pOption->optionKind)
                {
                    case tcpOpKdEndOfList:
                        cbOptionsT = 0;
                        continue;
                        break;

                    case tcpOpKdNoOperation:

                        cbOptionsT--;
                        pOption = (TCPOPTION *) (((void *) pOption) + 1);

                        // there is no length, so just go to the next option
                        continue;
                        break;

                    default:
                        break;
                }

                // check the size to see if there is an option
                if(pOption->length > cbOptionsT)
                {
                    break;
                }

                switch(pOption->optionKind)
                {
                    case tcpOpKdMaxSegSize:
                        pSocket->cbRemoteEffMSS    = pOption->rgu16[0];
                        break;

                    case tcpOpKdSAckMult:
                    case tcpOpKdTimestamp:
                    case tcpOpKdWindowScale:
                    case tcpOpKdSAck:
                    case tcpOpKdAltChksumReq:
                    case tcpOpKdAltChksumData:
                    default:
                        break;
                }

                // go to the next option
                cbOptionsT -= pOption->length;
                pOption = (TCPOPTION *) (((void *) pOption) + pOption->length);
            }
        }

        // all we want to do is check to see if we got a cbRemoteMMS or not
        // and if not, set it to the defualt
        // no options setting the size, so use what I am specifying.
        if(pSocket->cbRemoteEffMSS == 0)
        {
            pSocket->cbRemoteEffMSS        = 536; // RFC 1122 4.2.2.6 the default value
        }

        // now following the instructions of RFC 1122 4.2.2.6
        // we don't send options on anything but the syn, so we don't have to include that.
        pSocket->cbRemoteEffMSS = min((uint16_t) (pSocket->cbRemoteEffMSS + 20), (uint16_t) LLGetMTUS(pSocket->s.pLLAdp)) - sizeof(TCPHDR);
    }
}

/*********************************************************************
 * Function:        void TCPProcessACK(IPSTACK *  pIpStack, SOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus)
 *
 * Input:           pIpStack    If data came in on the adaptor, the
 *                              this contains the incoming segment.
 *
 *                  pSocket     The socket to be processessed. All active sockets are process on each loop,
 *                              so the pStack can easily be NULL if no data come in on the adaptor.
 *                              The pSocket can be NULL if data came in on the adaptor for our IP
 *                              but did not match any active or listin port.
 *
 *                  tCur        The time when we entered the TCP State machine
 *
 *
 *
 * Output:          pStatus An optional status variable to recieve the status/error of the function
 *
 * Returns:         None
 *
 * Note:            This process an incoming ACK, it should be valid as
 *                  TCPCheckForRST should have killed all invalid stuff
  *
 ********************************************************************/
static void TCPProcessACK(IPSTACK *  pIpStack, TCPSOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus)
{
    AssignStatusSafely(pStatus, ipsSuccess);

    // check to make sure we can process and ACK
    if(pIpStack == NULL || pSocket == NULL)
    {
        return;
    }

    // normalize our seq numbers
    pIpStack->pTCPHdr->ackNbr -= pSocket->sndISS;
    pIpStack->pTCPHdr->seqNbr -= pSocket->rcvIRS;

    // process the ACK; we always process ACKs
    // Error checking for a bad ACK should have been done in TCPCheckForRST
    if( pIpStack->pTCPHdr->fAck)
    {

        // do some round trip calculations, RFC 793 3.7
        // if the incoming message spans our complete time, then take the round trip time.
        // we are in the window of what we are waiting for
        // karns says, only update if we didn't retransmit
        if(pSocket->cRetransmit == 0 && pSocket->sndUNA < pSocket->sndRTTComplete && pSocket->sndRTTComplete <= pIpStack->pTCPHdr->ackNbr)
        {
            // RFC 973 3.7 says ALPHA .8 - .9
            // we pick .875 which is (1-1/8)
            // the equation is SRTT = (ALPHA * SRTT) + ((1-ALPHA) *RTT)
            // replace ALPHA with (1-1/8) we have
            // SRTT = ((1-1/8) * SRTT) + ((1-(1-1/8)) * RTT)
            // SRTT = ((SRTT - SRTT/8) + (RTT/8)
            // SRTT = SRTT + RTT/8 - SRTT/8
            // this is on a ms time base, we could go to zero, but lets set a lower bound of 2 ms
            //pSocket->SRTT       = max(2, SRTT(pSocket->SRTT, (tCur - pSocket->tSndRTTStart)));

            // All fine and dandy, but Jacobson has a different rule
            UpdateSaSv(pSocket, (tCur - pSocket->tSndRTTStart));

            // but here we do Karn's rule
            pSocket->tRTO_SET   = RTO(pSocket);
        }


        // No matter what, we better understand when we need to
        // reset our round trip timers
        if(pIpStack->pTCPHdr->ackNbr >= pSocket->sndRTTComplete)
        {
            pSocket->tRTOCur        = pSocket->tRTO_SET;
            pSocket->cRetransmit    = 0;
            pSocket->sndRTTComplete = pIpStack->pTCPHdr->ackNbr;
        }

        // only take the ack if in range
        // This is very critical, and very complex
        // typically the ack needs to be between sendUNA and sndNXT, however
        // when we retransmit we reset both sndUNA and sndNXT to lower values and the other
        // side might start saying hey I got that already and the ack will be greater than sndNXT
        // so we really need to check to see if the ack came in between snd UNA and sndEND
        // and we have to adjust sendNXT to the ack if the ack is above sndNXT
        // also, if we get an dup ack, the otherside may be giving us a new window size and we
        // want to pick up that info, so process dup ack's that is sndUNA == ack.
        if( pSocket->sndUNA <= pIpStack->pTCPHdr->ackNbr &&
            (pIpStack->pTCPHdr->ackNbr <= pSocket->sndNXT || pIpStack->pTCPHdr->ackNbr <= pSocket->sndEND))
//        if(pSocket->sndUNA <= pIpStack->pTCPHdr->ackNbr && pIpStack->pTCPHdr->ackNbr <= pSocket->sndNXT)
        {

            // if this is a fast retransmit request, which is when the other side
            // keeps sending us an ack over and over again at the same value
            if( pSocket->sndUNA == pIpStack->pTCPHdr->ackNbr )  // if we have seen this ack before
            {
                if( pSocket->sndNXT > pSocket->sndUNA   &&      // if he is not caught up to us
                    pIpStack->cbPayload == 0            &&      // and this isn't just an ack coming in with data
                    !pIpStack->pTCPHdr->fFin            &&      // and is not a fin as a fin is logical payload length of 1
                    pSocket->cSameAck < 15)                     // do not want to overflow the counter and wrap
                {
                    pSocket->cSameAck++;
                }
            }
            else
            {
                // update my unacked ack location
                pSocket->cSameAck = 0;
                pSocket->cTxUntilPause = CNTPAUSESEND;
                pSocket->sndUNA = pIpStack->pTCPHdr->ackNbr;
            }

            // this should ONLY happen when we retransmit
            // our sndNXT was backed off to the retransmit point, but the otherside
            // actually acked us that he did in fact get it. So we need to restore our sndNXT
            // or as a result of a zero probe window request
            // which sends a byte to the otherside when he may not be able to accept it; which puts us in
            // an automatic retransmit condtions; so in this case the sndNXT is brought back
            if(pSocket->sndUNA > pSocket->sndNXT || pSocket->cZWndProbe > 0)
            {
                pSocket->sndNXT = pSocket->sndUNA;
                pSocket->cSameAck = 0;
                pSocket->cTxUntilPause = CNTPAUSESEND;
            }

//            if(pSocket->sndUNA >= pSocket->rcvSeqAhead)
//            {
//                pSocket->rcvSeqAhead = pSocket->sndUNA;
//            }

            // if we get ANY ACK, we are getting responses from the remote
            // so we can hold off any retransmits; reset and recalculate the new retran times
            pSocket->tLastAck   = tCur;

            // see if we have moved ahead of our flush point, if so; put the flush point
            // at the UNA location and track at the lower limit so compares are valid
            if(pSocket->sndUNA > pSocket->sndPSH)
            {
                pSocket->sndPSH = pSocket->sndUNA;
            }

            // see if we have moved ahead of our flush point, if so; put the flush point
            // at the UNA location and track at the lower limit so compares are valid
            if(pSocket->sndUNA > pSocket->sndUP)
            {
                pSocket->sndUP = pSocket->sndUNA;
            }

            // update how many bytes I can send
            // that would be realive to the ack that just came in
            // ack + window - sndNXT
            if((pIpStack->pTCPHdr->ackNbr + pIpStack->pTCPHdr->window) > pSocket->sndNXT)
            {
                pSocket->sndWND = pIpStack->pTCPHdr->ackNbr + pIpStack->pTCPHdr->window - pSocket->sndNXT;
                pSocket->cZWndProbe = 0;
            }
            else
            {
                pSocket->sndWND = 0;
            }
        }
    }
}

/*********************************************************************
 * Function:        bool TCPCheckForReTransmit(IPSTACK *  pIpStack, SOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus)
 *
 * Input:           pIpStack    If data came in on the adaptor, the
 *                              this contains the incoming segment.
 *
 *                  pSocket     The socket to be processessed. All active sockets are process on each loop,
 *                              so the pStack can easily be NULL if no data come in on the adaptor.
 *                              The pSocket can be NULL if data came in on the adaptor for our IP
 *                              but did not match any active or listin port.
 *
 *                  tCur        The time when we entered the TCP State machine
 *
 *
 *
 * Output:          pStatus An optional status variable to recieve the status/error of the function
 *
 * Returns:         true if we want to exit the TCP state machine, false if we want to stay in the state machine.
 *
 * Note:            If too much time has gone by, we may need to retransmit data that did not get acked.
 *                  SYN and FIN are ugly to retransmit; particularly SYNs
 *
 ********************************************************************/
static bool TCPCheckForReTransmit(IPSTACK *  pIpStack, TCPSOCKET * pSocket, uint32_t tCur, IPSTATUS * pStatus)
{
    AssignStatusSafely(pStatus, ipsSuccess);

    // only worry if the remote is not up to date.
    if(pSocket->sndUNA < pSocket->sndNXT)
    {
        // if it has been so long as we exceed the MSL
        // we need to send a reset and kill the connection
        
        // 2 way to interpret the RFC, 2 Min total, or
        // 2 min from last attempt. 2 min from last attempt will 
        // give a total time of over 6 min before giving up
        // that is too long. So lets say 2 min total

//        if(tCur - pSocket->tLastAck >= TCPMSL)
        if(tCur - pSocket->tSndRTTStart >= TCPMSL)
        {
            if((pIpStack = IPSRefresh(pIpStack, pSocket->s.pLLAdp, pStatus)) != NULL)
            {
                pIpStack->pTCPHdr->fRst = true;

                // we want the otherside to accept our reset if they get it, it must
                // be in a range of their recieve window. We really don't know how many
                // packets they have sent me and I missed; or how many they have missed.
                // However, the best guess is what he last ACKed to me. After all, I am
                // waiting for an ACK that I never got, so I can assume his last ACK is where
                // his rcvNXT is, so I will set my sndNXT to the last thing he ACKed
                pSocket->sndNXT = pSocket->sndUNA;

                // don't call TCPTransmitRST, that assumes we have a valid IpStack and no socket
                // here we have the a valid socket, but may not have a valid IpStack.
                TCPTransmit(pIpStack, pSocket, 0, 0, true, tCur, pStatus);

                // clean up the socket and release it.
                TCPResetSocket(pSocket);
                AssignStatusSafely(pStatus, ipsNoACKinMSLTime);
                return(true);
            }
        }

        // Now just set our sndNext back and send those packets again.
        else if(tCur - pSocket->tLastAck >= pSocket->tRTOCur || pSocket->cSameAck >= cDupAckFastRetransmit)
        {
            IPSTATUS status;

            // we are clearly retransmitting.
            AssignStatusSafely(pStatus, ipsRetransmit);
            pSocket->cSameAck = 0;
            
            // Only pretend to retransmit if we are not connected
            // but don't actually retransmit, and don't timeout either
            if(!TCPIsConnected(pSocket, &status))
            {

                // by making sure cRetranmit is > 0, then
                // because of the Karn algorithm, round trip time will ignored
                // if we are already retransmitting, just keep our count where it is
                if(pSocket->cRetransmit == 0) pSocket->cRetransmit++;

                // Last Ack is used for connection timeout
                // if we reset it, the connection will not timeout
                // but we only want to do this if the connection loss
                // is not permanent.
                pSocket->tLastAck = tCur;

                // if we permanently lost the connection
                // we have to close the socket and clean up
                if(IsIPStatusAnError(status))
                {
                    pSocket->tcpState = tcpWaitUserClose;
                    AssignStatusSafely(pStatus, status);

                    pSocket->sndWND +=  pSocket->sndNXT - pSocket->sndUNA;
                    pSocket->sndUNA = pSocket->sndNXT;

                    // go ahead and process this.
                    return(false);
                }

                // just pretend we retransmitted.
                return(true);
            }

            // set up for our next timeout time
            // We are required to exponetially grow
            // but eventually we will max out
            if(pSocket->tRTO_SET < 0x80000000)
            {
                pSocket->tRTO_SET   =   (pSocket->tRTO_SET << 1);

                // now add this on to the current time as tLastAck has not moved
                // and is == to tRTOCur
                // and we need to wait the new amount above what time has already past
                pSocket->cRetransmit++;
            }

            // set up for our next delay
            pSocket->tLastAck   = tCur;
            pSocket->tRTOCur    = pSocket->tRTO_SET;

            // resend data because we did not see the ack
            pSocket->sndNXT = pSocket->sndUNA;
            
            // Don't send any more data until we see an ACK
            // this is because the retransmit could be for one out of seq packet
            // and we don't want to redump everything, we may wish to move forward to his ACK
            // if he can handle out of sequence packets and will jump forward beyond
            // just this one missing packet. This will prevent retransmitting unneeded data on the wire
            pSocket->cTxUntilPause = 1;

            // if we need to resent the SYN, then do that.
            // this is very difficult as CreateSyn resets a bunch of stuff and requires ARP to succeed. Typically ARP will succeed because the
            // syn just came in and set up our ARP table an we will find the IP quickly. However, times out are bad as the ARP table can expire
            if(pSocket->tcpState == tcpSynSent  ||  pSocket->tcpState == tcpSynReceivedWhileListening || pSocket->tcpState == tcpSynReceived)
            {
                uint32_t cbOptions  = 0;

                // resend the syn
                IPSRelease(pIpStack);        // get rid of the old IpStack; if any

                // It would be really nice if we could bet that the sender sent me an IpStack big enough to put my 4 bytes of options in
                // but we can't depend on that, so we must get a new IpStack where we know we have the space, but that means we will
                // be doing an ARP lookup on the IP AND all of our timers will be reinit. We must deal with all of this. But the SYN
                // is our only IpStack that REQUIRES the options. Also, this will be sent until I get my ACK!
                TCPTransmit(TCPCreateSyn(pSocket, &cbOptions, pStatus), pSocket, 1, cbOptions, (pSocket->tcpState == tcpSynReceivedWhileListening || pSocket->tcpState == tcpSynReceived), tCur, pStatus);

                // very obscure thing going on here. Typically the TCPTrasmit would set this value; however, if we "failed" to transmit then this does not get set
                // and then sendNext == sndUNA and we will go into the established state; which is wrong. Send may fail specifically if ARP fails; as in the remote goes away.
                // what happens is that TCPCreateSyn creates a new IpStack and is NOT based on the incoming IpStack, so our MAC set and must be looked up through the IP address
                // after 1 min, the ARP table expires and an ARP is done, if there is no response, then I fail the ARP which will fail the transmit which will not advance the sndNXT.
                // So even in the face of an APR failure / transmit failure; just set the sndNXT to 1, we will loop until the MSL timeout and then attempt to send a RST
                // IF I can do an ARP. But at least we will recover the socket on timeout and no enter the established state.
                pSocket->sndNXT         = 1;
                AssignStatusSafely(pStatus, ipsRetransmit);
                return(true);
            }

            // resend a FIN from them closing
            else if(pSocket->tcpState == tcpCloseWait  ||  pSocket->tcpState == tcpLastAck)
            {
                pSocket->tcpState = tcpCloseWait;   // retransmit unacked data too
            }

            // resend a FIN from us closing
            else if (pSocket->tcpState == tcpFinWait1 || pSocket->tcpState == tcpFinWait2)
            {
                pSocket->tcpState = tcpFinWait1;    // retransmit unacked data too
            }
        }
    }
    
    // else we are caught up and we are in a stable state
    // see if we need to ping the other side
    else if(pSocket->cRetransmit == 0)
    {
        bool fSendAck = false;
        bool fSendRst = false;

        // these are stable states that the connection can be open forever
        // as we are current on their ACK. However, this can also keep the
        // socket open forever even if they drop off the earth, so do
        // something for socket garbage collection.
        switch(pSocket->tcpState)
        {

            // not sure what to do here, maybe they want the socket to
            // stay open forever, we need to have somekind of parameter to set here
            case tcpEstablished:

//                if(pSocket->rcvSeqAhead >= pSocket->rcvNXT && (tCur - pSocket->tLastAck) >= 10)
//                {
//                    fSendAck = true;
//                }
                break;

            // if we send a FIN, and they ACKed our FIN
            // we expect them to send a FIN eventually.
            case tcpClosing:

                // abort the socket if I don't get data or a FIN in a reasonable time
                if(tCur - pSocket->tLastAck >= max(TCPMAXHALFCLOSE, (pSocket->tRTOCur << 1)))
                {
                    fSendRst = true;
                    fSendAck = true;
                }
                break;

            default:
                break;
        }

        // Send and ACK to wake up the otherside and get with the program!
        if(fSendAck && (pIpStack = IPSRefresh(pIpStack, pSocket->s.pLLAdp, pStatus)) != NULL)
        {
            // reset if asked to reset
            pIpStack->pTCPHdr->fRst = fSendRst;

            // Send an ACK
            // here we have the a valid socket, but may not have a valid IpStack.
            TCPTransmit(pIpStack, pSocket, 0, 0, true, tCur, pStatus);

            // garbage collect the socket
            if(fSendRst)
            {
                // clean up the socket and release it.
                TCPResetSocket(pSocket);
                AssignStatusSafely(pStatus, ipsNoACKinMSLTime);
            }

            return(true);
        }
    }

    // we want to go into the TCP state machine
    return(false);
}

/*********************************************************************
 * Function:        bool TCPTransmit(IPSTACK *  pIpStack, SOCKET * pSocket, int32_t cbSend, int32_t cbOptions, bool fAck, uint32_t tCur, IPSTATUS * pStatus)
 *
 * Input:           pIpStack    The IpStack populated with what needs to be sent
 *
 *                  pSocket     The socket that the data is going out on.
 *
 *                  cbSend      The number of bytes we are sending
 *                              This is usually cbPayload, however SYNs and FINs are a count of 1 even if the payload is zero
 *
 *                  cbOptions   How many bytes are in the options field in the TCPHDR. Usually this is 4 for a SYN
 *
 *                  fAck        Almost always true except for initial SYNs and some RSTs
 *
 *                  tCur        Current time in ms of when the state machine was called. Used as current time.
 *
 * Output:          pStatus An optional status variable to recieve the status/error of the function
 *
 * Returns:         true is the send succeeded, false otherwise
 *
 * Note:            This is the generic TCP Send routine that tracks our SEQNbr and
 *                  makes sure the data is sent on the sockets port
 *                  and will create proper ACKs if requested.
 *                  It also updates the counts in the TCPHDR to what is being sent.
 *
 ********************************************************************/
bool TCPTransmit(IPSTACK *  pIpStack, TCPSOCKET * pSocket, int32_t cbSend, int32_t cbOptions, bool fAck, uint32_t tCur, IPSTATUS * pStatus)
{
    IPSTATUS        status = ipsSuccess;

    if(pIpStack == NULL)
    {
        status = ipsIpStackNULL;
    }
    else if(pSocket == NULL)
    {
        status =  ipsSocketNULL;
    }

    if(status != ipsSuccess)
    {
        AssignStatusSafely(pStatus, status);
        return(false);
    }

    pIpStack->pTCPHdr->portSrc      = pSocket->s.portLocal;
    pIpStack->pTCPHdr->portDest     = pSocket->s.portRemote;

    pIpStack->pTCPHdr->seqNbr       = pSocket->sndISS + pSocket->sndNXT;

    // this is a keep alive, trying to wake up the other side.
    if(cbSend == -1)
    {
        pIpStack->pTCPHdr->seqNbr--;
        cbSend = 0;
        fAck = true;
    }

    pIpStack->pTCPHdr->fAck         = fAck;
    pIpStack->pTCPHdr->ackNbr       = pSocket->rcvIRS + pSocket->rcvNXT;

    // as per RFC 1122 4.2.3.3

    if(pSocket->hPMGR != NULL)
    {
        pIpStack->pTCPHdr->window       = min((PMGRMaxFree(pSocket->hPMGR) >> 2), pSocket->cbLocalMSS);
    }
    else
    {
        pIpStack->pTCPHdr->window       = pSocket->cbLocalMSS;
    }

    pIpStack->cbTranportHeader          = sizeof(TCPHDR) + cbOptions;
    pIpStack->pTCPHdr->dataOffset       = pIpStack->cbTranportHeader / sizeof(uint32_t);

    if(ILIsIPv6(pSocket->s.pLLAdp))
    {
        pIpStack->pIPv6Hdr->cbPayload   = pIpStack->cbPayload;
        memcpy(&pIpStack->pIPv6Hdr->ipDest, &pSocket->s.ipRemote.ipv6, sizeof(IPv6));
    }
    else
    {
        pIpStack->pIPv4Hdr->cbTotal     = sizeof(IPv4HDR) + pIpStack->cbTranportHeader + pIpStack->cbPayload;
        memcpy(&pIpStack->pIPv4Hdr->ipDest, &pSocket->s.ipRemote.ipv4, sizeof(IPv4));
    }

    ILSend(pIpStack, &status);
    if(!IsIPStatusAnError(status))
    {
        pSocket->tLastSnd = tCur;
        if(fAck)
        {
            pSocket->cNeedAck = 0;
        }

        // count how many sends left we have from the last ACK
        if(cbSend > 0 && pSocket->cTxUntilPause > 0)
        {
            pSocket->cTxUntilPause--;
        }

        // start of a new calculation for RTT; RFC 793 3.7
        // we redo this with RFC 1122 4.2.2.15
        // and looking at Karn's / Jacobson's Algorithm
        // we have completed this round trip, so lets start another one
        if(pSocket->sndRTTComplete == pSocket->sndUNA)
        {
            pSocket->tSndRTTStart   = tCur;        // start round trip time
            pSocket->sndRTTComplete = pSocket->sndNXT + cbSend;
        }

        // when the remote was caught up, than last ack could
        // be a really old time, so lets update for something
        // reasonable. But make sure we are not in a retransmit condition.
        if(pSocket->sndUNA == pSocket->sndNXT  &&  pSocket->cRetransmit == 0)
        {
            pSocket->tLastAck   = tCur;
        }

        // update the next snd pointer
        pSocket->sndNXT += cbSend;

        // we have used some of their send window
        // so lets update the send window amount
        // so we don't overrun them
        if((int32_t) pSocket->sndWND >= cbSend)
        {
            pSocket->sndWND -= cbSend;
        }
        else
        {
            pSocket->sndWND = 0; 
        }
    }

    AssignStatusSafely(pStatus, status);
    return(status == ipsSuccess);
}

/*********************************************************************
 * Function:        bool TCPProcessTxSocketBuffers(IPSTACK * pIpStack, SOCKET * pSocket, bool fForceAck, uint32_t tCur, int32_t * pcbSend)
 *
 * Input:           pIpStack    If data came in on the adaptor, the
 *                              this contains the incoming segment.
 *
 *                  pSocket     The socket to be processessed. All active sockets are process on each loop,
 *                              so the pStack can easily be NULL if no data come in on the adaptor.
 *                              The pSocket can be NULL if data came in on the adaptor for our IP
 *                              but did not match any active or listin port.
 *
 *                  fForceAck   This forces us to send at least an ACK, and data to if we have it.
 *
 *                  tCur        The time when we entered the TCP State machine
 *
 *
 *
 * Output:          pcbSend The number of bytes we are sending
 *
 * Returns:         true if we need to send some data even if that is only an ACK, false is not data needs sent
 *
 * Note:
 *      IMPORTANT, this call can NOT be made after a FIN is sent as sndNXT will be sndEND+1, above the range of anything valid
 *      HOWEVER, this call is only made during the tcpEstablished,tcpFinWait1 and tcpCloseWait states; which is before the FIN.
 *      IF a retransmit occurs, the sndNXT is backed off by at least 1 (otherwise there would be no need for the retransmit) and
 *      sndNXT will be below sndEND and all is okay.
 *
 ********************************************************************/
static bool TCPProcessTxSocketBuffers(IPSTACK * pIpStack, TCPSOCKET * pSocket, uint32_t tCur, int32_t * pcbSend)
{
    bool fForceAck = false;

    // we must have our pointers
    if(pIpStack == NULL || pSocket == NULL || pcbSend == NULL)
    {
        return(false);
    }

    // now calculate how much data we can send
    // the min of what we want to send, or to the end of the buffer
    // this could come up zero
    *pcbSend = pSocket->sndEND - pSocket->sndNXT;
    // and than and what we were told is the max we can put over the network (from options).
    *pcbSend = min(*pcbSend, pSocket->cbRemoteEffMSS);

    // if enough time has elapsed and they have a zero window
    // we need to probe them for a new window size; send a zero window probe
    // we do not want to do this very often, so the MAX against our MAXFLUSH
    // we want to be reduce this as much as possible but not skip it completely
    // we do this against the lastAck and not lastSend because the last ack is the
    // the last time he told us a window size
    if( pSocket->sndWND == 0                                                &&  // zero window
        (tCur - pSocket->tLastAck) >= (MAXFLUSH << pSocket->cZWndProbe)     &&  // time has elapsed
        *pcbSend > 0 )                                                          // we have something to send
    {
        if(pSocket->cZWndProbe < 15)
        {
            pSocket->cZWndProbe++; // just want to back off on asking
        }
        *pcbSend = 1;               // only send 1 byte
        fForceAck = true;
    }

    // don't send any data if we are to pause
    else if(pSocket->cTxUntilPause == 0)
    {
        *pcbSend = 0;
    }
    
    // send as much as we can
    else
    {
        *pcbSend = min(*pcbSend, (int32_t) pSocket->sndWND);
    }

    // check to see if we need to force an ack
    fForceAck = fForceAck 
            
        // if we have data to send and we are attempting to close, send data each time.
        || ((pSocket->tcpState > tcpEstablished) && (*pcbSend > 0))

        // we are only allowed to delay skipping ACKs once
        // if we need 2 ACKs, we must ack now
        || (pSocket->cNeedAck > 1)

        // Unfortunately, even if we only have 1 ACK to respond to
        // if we wait too long the other side will retransmit, and we don't want that to happen
        // Retransmit time is a calculated and conservative time, so this is probably too long to wait for the ACK
        // let's back off on retransmit time and make sure we ACK before they retransmit.
        // On init, retransmit times are long, so lets make sure we are quick enough to retransmit even with init RTO.
        // so put the ACK out at least as fast as MAXFLUSH
        // Also, before we have establish an RTT time, immdiately ACK if we go any ack request.
        || ((pSocket->cNeedAck > 0) && ((pSocket->cRTT < cRTTINVALID) || ((tCur - pSocket->tLastSnd) >= min(MAXFLUSH, (pSocket->tRTOCur/2)))));

    // if we have data to send, lets think about sending it.
    if(*pcbSend > 0)
    {
        // see if we have a push, we must send now
        pIpStack->pTCPHdr->fPsh = (pSocket->sndPSH > pSocket->sndNXT);

        // give that we have data to send, do we send it now or wait
        // check to see if we are to push right now
        fForceAck = fForceAck || pIpStack->pTCPHdr->fPsh

            // if there is a big enough data in the socket, send it now
            || (*pcbSend >= (pSocket->cbRemoteEffMSS / 4))

            // We want to throttle small packet transmits, like a bunch of 1 byte packets
            // so if someone is writing a bunch of little bytes to the socket we want to
            // let some accumulate before transmitting, however, we don't want to wait
            // forever before pushing this out. This is independent of our round trip time.
            || ((tCur - pSocket->tLastSnd) >= MAXFLUSH);

        // send the packet if we are to send it.
        if(fForceAck)
        {
            SMGR *  pSMGR = (SMGR*)alloca(pSocket->cbTxSMGR);

            if(pSMGR != NULL && (SMGRRead((HSMGR) &pSocket->smgrRxTxBuff, pSocket->cbRxSMGR, pSMGR, pSocket->cbTxSMGR) == pSocket->cbTxSMGR))
            {
                // clean up our snd pointers and scale to sendUNA
                bool fScaled = TCPScaleSndIndexes(pSocket, pSMGR);

                // see if we get the payload space
                if(((*pcbSend) = IPSGetPayloadFromAdaptor(pIpStack, *pcbSend)) > 0)
                {
                    // read the data
                    *pcbSend  = SMGRRead((HSMGR) pSMGR, pSocket->sndNXT,  pIpStack->pPayload, *pcbSend);
                    pIpStack->cbPayload = *pcbSend;

                }

                // this is somewhat complicated, if we failed to get a payload we can swamp
                // the heap with empty IpStacks with no payload, and then we can't take either
                // incoming or outgoing packets. So we can just refuse to send the data until
                // more space opens up. But.... what if we need to send an ACK and we don't. We
                // can send an ACK without a payload, if we kill the whole packet we will kill the required
                // ACK. But..... chances are the reason we ran out of space is because somebody is sending /recieving
                // a ton of data. Usually we can send data faster than the adaptor can take it, so sending is usually the
                // problem, and if the adaptor is behind, there are lots of ACKs in the send queue. If we are recieving
                // a ton of data so fast we can't keep up... well we are in trouble anyway as eventually we will get too
                // far behind no matter if we send our ACK or not. So, since the only recoverable condition is that
                // we are sending too quickly, not sending the ACK is probably not a loss. If we don't have room for the
                // data, just skip the send no matter what the need is to send the ACK.
                else
                {
                    fForceAck = false;
                }

                // save away the table that is stored on the stack
                // this should not fail! It is a fixed size and already allocated
                // HOWEVER, we only did a READ, so the stream has not changed, no need to write back
                // unless we did scaling of the sndUNA, then it did change.
                if(fScaled)
                {
                    SMGRWrite((HSMGR) &pSocket->smgrRxTxBuff, pSocket->cbRxSMGR, pSMGR, pSocket->cbTxSMGR);
                }
            }
        }
    }

    // we don't need to update the sendNXT pointer because that
    // will happen if we actually send it
    return(fForceAck);
}

bool TCPScaleSndIndexes(TCPSOCKET * pSocket, SMGR *  pSMGR)
{
    if(pSocket->sndUNA > 0)
    {
        /************************************************************************************/
        /**************************   SCALE SEND INDEXES    *********************************/
        /************************************************************************************/
        // Keep ourselves scaled at the bottom of the uint32_t so we can do linear compares
        // we can remove all Tx data that has been ACK'ed.
        SMGRMoveEnd((HSMGR) pSMGR, pSocket->sndUNA, SMGRAtBegining);

        pSocket->sndISS             += pSocket->sndUNA;
        pSocket->sndNXT             -= pSocket->sndUNA;
        pSocket->sndEND             -= pSocket->sndUNA;
        pSocket->sndPSH             -= pSocket->sndUNA;
        pSocket->sndUP              -= pSocket->sndUNA;
        pSocket->sndRTTComplete     -= pSocket->sndUNA;

        // make UNA the bottom
        pSocket->sndUNA             =  0;

        return(true);
    }

    return(false);
}

/*********************************************************************
 * Function:        IPSTACK * TCPFlushSocketAndFIN(IPSTACK * pIpStack, SOCKET * pSocket, uint32_t tCur, int32_t * pcbSend)
 *
 * Input:           pIpStack    If data came in on the adaptor, the
 *                              this contains the incoming segment.
 *
 *                  pSocket     The socket to be processessed. All active sockets are process on each loop,
 *                              so the pStack can easily be NULL if no data come in on the adaptor.
 *                              The pSocket can be NULL if data came in on the adaptor for our IP
 *                              but did not match any active or listin port.
 *
 *                  tCur        The time when we entered the TCP State machine
 *
 *
 *
 * Output:          pcbSend The number of bytes we are sending
 *
 * Returns:         An IPSTACK with either data to be transmitted, or a FIN segement. If NULL it means
 *                  you passed an IPSTACK of NULL Keep calling this
 *                  until you get a FIN packet.
 *
 * Note:
 *
 *
 ********************************************************************/
static IPSTACK * TCPFlushSocketAndFIN(IPSTACK * pIpStack, TCPSOCKET * pSocket, uint32_t tCur, int32_t * pcbSend)
{

    // we must have our pointers
    if(pIpStack == NULL || pSocket == NULL || pcbSend == NULL)
    {
        return(NULL);
    }

    // if we have sent everything.
    // send a FIN

    // you might think this needs to be sndEND == sndNXT
    // but some IP stack will just close if they see a FIN, even if they
    // missed packet before the FIN, so make sure they got everything.
    if(pSocket->sndEND == pSocket->sndUNA)
    {
        *pcbSend                    = 1;
        pIpStack->pTCPHdr->fFin     = true;
    }
    // otherwise keep sending data
    else if(!TCPProcessTxSocketBuffers(pIpStack, pSocket, tCur, pcbSend))
    {
        // now continue to flush data
        pIpStack = IPSRelease(pIpStack);
    }

    return(pIpStack);
}

/*********************************************************************
 * Function:        IPSTACK * TCPCreateSyn(SOCKET * pSocket, uint32_t * pcbOptions, IPSTATUS * pStatus)
 *
 * Input:           pSocket     The socket to create the SYN packet for.
 *
 * Output:
 *                  pcbOptions  This is the number of additonal bytes in the TCPHDR for the options field.
 *                              this is more than just what goes in cbSend, as the TCPHDR needs to know this as well
 *                              to skip around the header as the options are part of the header.
 *
 *                  pStatus An optional status variable to recieve the status/error of the function
 *
 * Returns:         A new IPSTACK with the SYN already to go. Or NULL if an IPSTACK could
 *                  not be obtained or on error.
 *
 * Note:            This is used by TCPOpen, so it can't be static. This is a very limited
 *                  function and focuses on getting an IPSTACK and putting in the MSS option.
 *
 *
 ********************************************************************/
IPSTACK * TCPCreateSyn(TCPSOCKET * pSocket, uint32_t * pcbOptions, IPSTATUS * pStatus)
{
    TCPOPTION * pOption     = NULL;
    IPSTACK *   pIpStack    = NULL;

    if ((pIpStack = IPSRefresh(NULL, pSocket->s.pLLAdp, pStatus)) != NULL )
    {
        pIpStack->pTCPHdr->fSyn         = true;

        // put in an MSS option
        pOption                         = (TCPOPTION *) (pIpStack->pTCPHdr+1);
        pOption->optionKind             = tcpOpKdMaxSegSize;
        pOption->length                 = 4;
        pOption->rgu16[0]               = pSocket->cbLocalMSS;

        *pcbOptions                     = pOption->length;

//        pSocket->tSndRTTStart           = SYSGetMilliSecond();

        return(pIpStack);
    }
    return(NULL);
}

/*********************************************************************
 * Function:        void UpdateSaSv(SOCKET *  pSocket, int32_t rtt)
 *
 * Input:           pSocket     The socket to calculate the new Jacobson values on
 *
 *                  rtt         The current Round-Trip-Time
 *
 * Returns:         Nothing
 *
 * Note:            You should only call this with a valid rtt
 *                  that is you must apply Karn's skip on retransmit
 *
 ********************************************************************/
static void UpdateSaSv(TCPSOCKET *  pSocket, int32_t rtt)
{
    int32_t err = 0;

    // we don't ever want a RTT of zero
    // we could easily have an RTT of less than 1ms, so say 1ms.
    if(rtt == 0) rtt = 1;

    // Err = m - a, sa = 2^^3*a, m = rtt, a = average RTT
    // Err = m - a
    err = rtt - (pSocket->RTTsa >> 3);

    // sa = sa + err; sa = 2^^3*a
    // 2^^3*a = 2^^3*a + Err
    pSocket->RTTsa += err;

    // |err|
    if(err < 0)
    {
        err *= -1;
    }

    // sv = sv - (|err| - v); sv = 2^^2*v
    // 2^^2*v = 2^^2*v + (|Err| - v)
    pSocket->RTTsv += (err - (pSocket->RTTsv >> 2));

    // if the error is greater than 2 * the average,
    // remember sa is 8 * average,
    // then say we don't have a valid RTT and we should ACK
    // immediately after data comes in.
    if(err > (pSocket->RTTsa >> 2))
    {
        pSocket->cRTT = 0;
    }
    else if(pSocket->cRTT < cRTTINVALID)
    {
        pSocket->cRTT++;
    }
}
