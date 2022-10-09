/************************************************************************/
/*                                                                      */
/*	DHCP.c  This implements the DHCP code per RFC 2131                  */
/*          as part of the application Layer                            */
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
/*	Technecally DHCP is implemented at the application layer            */
/*	with hooks into the link layer                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	4/11/2013(KeithV): Created                                          */
/*                                                                      */
/************************************************************************/
#include "deIP.h"

static const char szIPInUse[] = "IP in Use";

/*****************************************************************************
  Function:
	bool DHCPIPv4(uint8_t rgbDHCPMem, uint32_t cbDHCPMem)

  Description:
        This starts the DHCP IPv4 acquition process.

  Parameters:
	pLLAdp:         The adaptor to get an IP for
        rgbDHCPMem:     A pointer to a buffer for DHCP to use
        cbDHCPMem:      The size of the buffer to use, must be greater than or equal to DHCPGetMemIPv4(0)
        hPMGR           Page manager to get the socket buffer from
        pStatus:        A pointer to a status variable to recieve the status of the process, may be NULL

  Returns:
        true if the DHCP has finished and you have an IP, call LLARPGetMyIP to get the IP
        false if still in process or an error occured, check status for an error
  ***************************************************************************/
bool DHCPInit(const LLADP * pLLAdp, void * rgbDHCPMem, uint32_t cbDHCPMem, HPMGR hPMGR, IPSTATUS * pStatus)
{
    UDPSOCKET *     pSocket = NULL;
    IPSTATUS        status = ipsSuccess;
    DHCPMEM *       pDHCPMem = (DHCPMEM *) rgbDHCPMem;

    if(pLLAdp == NULL)
    {
        status = ipsAdaptorMustBeSpecified;
    }
    else if(hPMGR == NULL)
    {
        status = ipsNoPMGRGiven;
    }
    else if(!(pLLAdp->dhcpState == dhcpDISABLED || pLLAdp->dhcpState == dhcpSTATICIP))
    {
        status = ipsDHCPCurrentlyInUse;
    }
    else if(ILIsIPv6(pLLAdp))
    {
        // don't support IPv6 yet
        status = ipssNotSupported;
    }
    else if(rgbDHCPMem == NULL)
    {
        status = ipsDHCPMemIsNULL;
    }
    else if(cbDHCPMem < DHCPMemSize)
    {
        status = ipsDHCPNotEnoughMem;
    }

    if(IsIPStatusAnError(status))
    {
        AssignStatusSafely(pStatus, status);
        return(false);
    }

    // clear the DCHP memory
    memset(pDHCPMem, 0, DHCPMemSize);

    // set up the IP stack, the frame gets setup automaticaly by other headers
    // and defaults to broadcast
    pDHCPMem->ipStack.headerOrder   = MACHINE_ORDER;
    pDHCPMem->ipStack.pLLAdp        = pLLAdp;
    pDHCPMem->ipStack.cbFrame       = sizeof(ETHERNETII_FRAME);
    pDHCPMem->ipStack.pFrameII      = &pDHCPMem->frameII;
    pDHCPMem->ipStack.pPayload      = NULL;
    pDHCPMem->ipStack.cbPayload     = 0;

/* TODO, IPv6 not implemented
    // now fill in the template IP Datagram
    if(pLLAdp->pNwAdp->pAdpInfo->fIPv6)
    {
        pDHCPMem->ipStack.etherType     = ethertypeIPv6;
    }
    else
*/
    {
        pDHCPMem->ipStack.etherType         = ethertypeIPv4;
        pDHCPMem->ipStack.protocol          = ippnUDP;

        pDHCPMem->ipStack.pIPv4Hdr          = &pDHCPMem->ipv4Hdr;
        pDHCPMem->ipStack.cbIPHeader        = sizeof(IPv4HDR);

        pDHCPMem->ipStack.pUDPHdr           = &pDHCPMem->udpHdr;
        pDHCPMem->ipStack.cbTranportHeader  = sizeof(UDPHDR);
    }

    // make the headers
    IPSConstructIpStackHeaders(&pDHCPMem->ipStack, NULL);


    // Now make a socket and listen
    pSocket = (UDPSOCKET*)UDPOpenWithSocket( pLLAdp,
                            &pDHCPMem->socket,
                            hPMGR,
                            &IPv4BROADCAST,
                            portBOOTPServer,
                            portBOOTPClient,
                            &status);

    if(IsIPStatusAnError(status))
    {
        AssignStatusSafely(pStatus, status);
        return(false);
    }
    else if(pSocket != &pDHCPMem->socket)
    {
        AssignStatusSafely(pStatus, ipsDHCPUnableToCreateUDPSocket);
        return(false);
    }

    // make sure our IP is zero
    ILSetMyIP(pLLAdp, &IPv4NONE);

    // point to the DHCP Memory
    ((LLADP *) pLLAdp)->pDHCPMem = pDHCPMem;

    // make sure we are in the Discover state
    ((LLADP *) pLLAdp)->dhcpState = dhcpStartDISCOVER;
     pDHCPMem->cTryDiscovery = 0;

    return(true);
}

bool DHCPIsDone(const LLADP * pLLAdp, IPSTATUS * pStatus)
{
    IPSTATUS    status  = IPStatusFromDHCPState(pLLAdp->dhcpState);
    bool        fRet    = false;

    if(pLLAdp->dhcpState == dhcpDISABLED)
    {
        status = ForceIPError(status);
    }
    else if(dhcpBOUND <= pLLAdp->dhcpState &&  pLLAdp->dhcpState <= dhcpSTATICIP)
    {
        fRet = true;
    }
    else if(dhcpSTATICIP < pLLAdp->dhcpState)
    {
        status = ipsDHCPUnknownState;
    }

    AssignStatusSafely(pStatus, status);
    return(fRet);
}

bool DHCPTerminate(const LLADP * pLLAdp)
{
    if(pLLAdp != NULL && pLLAdp->pDHCPMem != NULL)
    {
        ((LLADP *) pLLAdp)->dhcpState = dhcpDISABLED;

        if(IPSIsInUse(&pLLAdp->pDHCPMem->ipStack))
        {
            return(false);
        }

        UDPClose(&pLLAdp->pDHCPMem->socket);
        ((LLADP *) pLLAdp)->pDHCPMem = NULL;
    }

    return(true);
}

static bool DHCPSend(const LLADP * pLLAdp, bool fBroadcast, uint8_t flags)
{
    IPSTATUS status;
    const IPv4 * pIPv4Remote = fBroadcast ? &IPv4BROADCAST : &pLLAdp->ipGateway.ipv4;

    // really, this needs to already have been done by now
    // this is more of a check that it hasn't been done and I
    // need to do this BEFORE I update the pLLAdp->pDHCPMem->dgDHCP data
    if(IPSSetToMachineOrder(&pLLAdp->pDHCPMem->ipStack))
    {
        // clean out the old data (which has aready been checksumed
        pLLAdp->pDHCPMem->ipStack.pPayload  = NULL;
        pLLAdp->pDHCPMem->ipStack.cbPayload = 0;

        // see if we need broadcasts
        pLLAdp->pDHCPMem->dgDHCP.flags  = flags;

        // rebuild the ipStack
        if(IPSConstructIpStackHeaders(&pLLAdp->pDHCPMem->ipStack, NULL))
        {
            // now send the data out.
            // we call this and make sure we don't copy the datagram in the send so that the datagram
            // stays with the ipStack; but we must not tamper with the datagram until we get a response and
            // sent is finished.
            UDPRawSend(pLLAdp, &pLLAdp->pDHCPMem->ipStack, pIPv4Remote, portBOOTPServer, portBOOTPClient, (uint8_t *) &pLLAdp->pDHCPMem->dgDHCP, sizeof(DHCPDG) + cbDHCPOptions, false, &status);
            return(!IsIPStatusAnError(status));
        }
    }

    return(false);
}

static const uint8_t * DHCPFindOption(uint8_t option, const uint8_t * pbOptions, uint8_t cbOptions)
{
    uint8_t i = 0;

    while(i < cbOptions)
    {
        uint8_t cbOption = 0;

        // get the length of the option
        // look at 1 byte opitons first
        if(pbOptions[i] == dhcpOpPad || pbOptions[i] == dhcpOpEnd)
        {
            cbOption = 1;
        }

        // see if we have a length field
        else if((i+1) < cbOptions)
        {
            cbOption = 2 + pbOptions[i+1];
        }

        // this is if we were sent corrupt data, get out
        else
        {
            return(NULL);
        }

        // found the option we are looking for
        if((i+cbOption) <= cbOptions && option == pbOptions[i])
        {
            return(&pbOptions[i]);
        }

        // we clearly were NOT looking for the end option but hit it
        // so terminate so we don't iterate over the potentially large
        // number of padding 0s
        else if(pbOptions[i] == dhcpOpEnd)
        {
            return(NULL);
        }

        // go to the next option
        i += cbOption;
    }

    // didn't find anything over the whole area, and clearly didn't hit an end option
    // probably the data was corrupt.
    return(NULL);
}

static void DHCPSetUpParameters(const LLADP * pLLAdp, const DHCPDG * pDHCPDG, int8_t  cbOptions)
{
    const uint8_t * pbOp = NULL;

    // set my IP; we do memcopy because yiaddr may be unaligned
    memcpy((void *) &pLLAdp->ipMy.ipv4, &pDHCPDG->yiaddr, sizeof(IPv4));

    // see if I got mask and set it; if no mask, stick with the default
    if( (pbOp = DHCPFindOption(dhcpOpSubMask, pDHCPDG->options, cbOptions))  != NULL )
    {
        ILSetMySubmask(pLLAdp, &pbOp[2]);
    }

    // see if I got a gateway
    if( (pbOp = DHCPFindOption(dhcpOpRouter, pDHCPDG->options, cbOptions))  != NULL )
    {
        ILSetMyGateway(pLLAdp, &pbOp[2]);
    }
    // not sure what to do if I don't get a router IP, go with the server IP if no default was set
    else if(pLLAdp->ipGateway.ipv4.u32 == IPv4NONE.u32 || pLLAdp->ipGateway.ipv4.u32 == IPv4BROADCAST.u32)
    {
        ILSetMyGateway(pLLAdp, &pDHCPDG->siaddr);
    }

    // get my lease time
    if( (pbOp = DHCPFindOption(dhcpOpIPLeaseTime, pDHCPDG->options, cbOptions))  != NULL )
    {
        memcpy((void *) &pLLAdp->pDHCPMem->tsLease, &pbOp[2], sizeof(uint32_t));
        ExEndian(&pLLAdp->pDHCPMem->tsLease, sizeof(uint32_t));

// just a test, force a short lease time
//pLLAdp->pDHCPMem->tsLease = 150;

        // set up some default times if I don't get these RFC 2131 4.4.5
        pLLAdp->pDHCPMem->tsRenew   = pLLAdp->pDHCPMem->tsLease / 2;                                // .5 lease
        pLLAdp->pDHCPMem->tsReBind  = pLLAdp->pDHCPMem->tsLease - (pLLAdp->pDHCPMem->tsLease / 8);  // .875 lease
    }
    else
    {
        // set up the default lease times; forever
        pLLAdp->pDHCPMem->tsLease   = dhcpInfiniteLease;
        pLLAdp->pDHCPMem->tsRenew   = dhcpInfiniteLease;
        pLLAdp->pDHCPMem->tsReBind  = dhcpInfiniteLease;
    }

    // get my renew time
    if( (pbOp = DHCPFindOption(dhcpOpRenewalTime, pDHCPDG->options, cbOptions))  != NULL )
    {
        memcpy((void *) &pLLAdp->pDHCPMem->tsRenew, &pbOp[2], sizeof(uint32_t));
        ExEndian(&pLLAdp->pDHCPMem->tsRenew, sizeof(uint32_t));
    }

    // get my rebind time
    if( (pbOp = DHCPFindOption(dhcpOpReBindTime, pDHCPDG->options, cbOptions))  != NULL )
    {
        memcpy((void *) &pLLAdp->pDHCPMem->tsReBind, &pbOp[2], sizeof(uint32_t));
        ExEndian(&pLLAdp->pDHCPMem->tsReBind, sizeof(uint32_t));
    }

    // save away the DNS NS
    if( pLLAdp->pDNSMem != NULL && (pbOp = DHCPFindOption(dhcpOpDomainNameServer, pDHCPDG->options, cbOptions)) != NULL )
    {
        uint32_t i = 0;
        
        pLLAdp->pDNSMem->cDhcpNS = min((pbOp[1] / sizeof(IPv4)), pLLAdp->pDNSMem->dnsNSMax);

        for(i=0; i<pLLAdp->pDNSMem->cDhcpNS; i++)
        {
            DNSAddNS(pLLAdp, &pbOp[(2 + i * sizeof(IPv4))], i);
        }
    }
}

static void DHCPStateMachine(const LLADP * pLLAdp)
{
    // if there is nothing to look at, just return
    // static IP should make the pDHCPMem == 0;
    // Or if the stack is still in use, wait for it to send before continuing
    if(pLLAdp == NULL || pLLAdp->pDHCPMem == NULL || IPSIsInUse(&pLLAdp->pDHCPMem->ipStack) || !LLIsLinked(pLLAdp, NULL))
    {
        return;
    }

    // process the state we are in.
    switch(pLLAdp->dhcpState)
    {
        case dhcpRetryDISCOVER:
             pLLAdp->pDHCPMem->cTryDiscovery++;
             // fall thru

        case dhcpStartDISCOVER:

            // start from scratch to send the DISCOVER
            pLLAdp->pDHCPMem->tsLease = dhcpInitRetryTime;
            // fall thru

        // RFC 2131
        // client sends a discover request
        // try up to 4 times with a retry time of
        // exponetial backoff starting at 4s, randomaized +/-1 sec
        // total retransmit time is 60 seconds
        case dhcpDISCOVER:

            // if we are done trying, get out.
            if(pLLAdp->pDHCPMem->cTryDiscovery >= MAXDISCOVETRIES)
            {
                ((LLADP *) pLLAdp)->dhcpState = dhcpDISABLED;
                break;
            }

            // MUST do this before scewing with the dgDHCP or the checksum will not work out!
            // but we want to be back in machine order
            IPSSetToMachineOrder(&pLLAdp->pDHCPMem->ipStack);

           // erase the DHCP message and clear the options too; starting over from scratch
            memset(&pLLAdp->pDHCPMem->dgDHCP, 0, sizeof(DHCPDG) + cbDHCPOptions);

            // fill in the dhcp header for a discovery
            pLLAdp->pDHCPMem->dgDHCP.op                 = BOOTREQUEST;  // VVVV if we have no mask, we must tell DHCP to broadcast VVVV
            // pLLAdp->pDHCPMem->dgDHCP.flags              = DHCPREQUIREBROADCAST;  // done in DHCPSend()
            pLLAdp->pDHCPMem->dgDHCP.htype              = hwtypeEthernet;
            pLLAdp->pDHCPMem->dgDHCP.hlen               = sizeof(MACADDR);
            pLLAdp->pDHCPMem->dgDHCP.xid                = GetSysTick() + (((uint32_t) pLLAdp->pNwAdp->mac.u16[0]) << 16) + pLLAdp->pNwAdp->mac.u16[1] + pLLAdp->pNwAdp->mac.u16[2];        // quazi random number
 //           pLLAdp->pDHCPMem->dgDHCP.xid                = GetSysTick() + *((uint32_t *) &pLLAdp->pNwAdp->mac.u8[0]) + *((uint16_t *) &pLLAdp->pNwAdp->mac.u8[4]);        // quazi random number
 //           pLLAdp->pDHCPMem->dgDHCP.xid                = GetSysTick() + ((UNALIGNPTR *) &pLLAdp->pNwAdp->mac.u8[0])->u32 + ((UNALIGNPTR *) &pLLAdp->pNwAdp->mac.u8[4])->u16;        // quazi random number
            memcpy(pLLAdp->pDHCPMem->dgDHCP.chaddr, &pLLAdp->pNwAdp->mac, sizeof(MACADDR));
            pLLAdp->pDHCPMem->dgDHCP.MagicCookie.u32    = MAGICCOOKIE;

            // messageType option; do not exceed cbDHCPOptions (32) bytes
            pLLAdp->pDHCPMem->dgDHCP.options[0]         = dhcpOpMessageType;
            pLLAdp->pDHCPMem->dgDHCP.options[1]         = 1;
            pLLAdp->pDHCPMem->dgDHCP.options[2]         = (uint8_t) dhcpDISCOVER;

            // RFC says I should put in the max datagram size; which is the min size as well.
            // this is all the bigger my buffer is.
            pLLAdp->pDHCPMem->dgDHCP.options[3]         = dhcpOpMaxMessageSize;
            pLLAdp->pDHCPMem->dgDHCP.options[4]         = 2;
            pLLAdp->pDHCPMem->dgDHCP.options[5]         = (uint8_t) ((cbMinDHCPDGSize & 0x0000FF00) >> 8);
            pLLAdp->pDHCPMem->dgDHCP.options[6]         = (uint8_t) (cbMinDHCPDGSize & 0x000000FF);

            // END option
            pLLAdp->pDHCPMem->dgDHCP.options[7]        = dhcpOpEnd;

            // send it off
            if(DHCPSend(pLLAdp, true, DHCPREQUIREBROADCAST))
            {
                pLLAdp->pDHCPMem->tsStart = SYSGetSecond();
                ((LLADP *) pLLAdp)->dhcpState = dhcpOFFER;
            }
            
            // we really should not have failed, quit, something is seriously wrong
            else
            {
                ((LLADP *) pLLAdp)->dhcpState = dhcpDISABLED;
            }
            break;

        // server overs client an IP
        case dhcpOFFER:

            // server identification option
            if(UDPAvailable(&pLLAdp->pDHCPMem->socket) > sizeof(DHCPDG))
            {
                uint8_t rgbDataGram[cbMinDHCPDGSize];
                DHCPDG * pDHCPDG    = (DHCPDG *) rgbDataGram;
                uint32_t cbDataGram = UDPRead(&pLLAdp->pDHCPMem->socket, rgbDataGram, sizeof(rgbDataGram), NULL); 
                uint8_t  cbOptions  = cbDataGram > sizeof(DHCPDG) ? (uint8_t) (cbDataGram - sizeof(DHCPDG)) : 0;

                // check xid, see if this message is for me
                if( cbDataGram > sizeof(DHCPDG)                     &&
                    pLLAdp->pDHCPMem->dgDHCP.xid == pDHCPDG->xid    &&
                    pDHCPDG->MagicCookie.u32 == MAGICCOOKIE         &&
                    pDHCPDG->yiaddr.u32 != 0                        )
                {
                    const uint8_t * pbOpMsg = NULL;
                    const uint8_t * pbOpSId = NULL;

                    // see if this is an OFFER request
                    if( (pbOpMsg = DHCPFindOption(dhcpOpMessageType, pDHCPDG->options, cbOptions))  != NULL &&
                         pbOpMsg[2] == dhcpOFFER &&
                        (pbOpSId = DHCPFindOption(dhcpOpServerIdent, pDHCPDG->options, cbOptions))  != NULL )
                    {

                        // MUST do this before scewing with the dgDHCP or the checksum will not work out!
                        IPSSetToMachineOrder(&pLLAdp->pDHCPMem->ipStack);

                        // make our new REQUEST datagram
                        // The RFC says, if we put an option in the DISCOVER, I
                        // MUST duplicate those options in the REQUEST
                        // so we only need to add to the DISCOVER datagram

                        // we must set it up in this state because this is when I have
                        // the incoming datagram, so set it up now.
                        // we can also retransmit on the request without resetting up the DHCP datagram

                        // messageType option; do not exceed cbDHCPOptions (32) bytes
                        //pLLAdp->pDHCPMem->dgDHCP.options[0]         = dhcpOpMessageType;
                        //pLLAdp->pDHCPMem->dgDHCP.options[1]         = 1;
                        pLLAdp->pDHCPMem->dgDHCP.options[2]         = (uint8_t) dhcpREQUEST;

                        // RFC says I should put in the max datagram size; which is the min size as well.
                        // this is all the bigger my buffer is.
                        // This is the same as before, no need to define it again
                        //pLLAdp->pDHCPMem->dgDHCP.options[3]         = dhcpOpMaxMessageSize;
                        //pLLAdp->pDHCPMem->dgDHCP.options[4]         = 2;
                        //pLLAdp->pDHCPMem->dgDHCP.options[5]         = (uint8_t) ((cbMinDHCPDGSize & 0x0000FF00) >> 8);
                        //pLLAdp->pDHCPMem->dgDHCP.options[6]         = (uint8_t) (cbMinDHCPDGSize & 0x000000FF);

                        // identify the server I am responding too
                        pLLAdp->pDHCPMem->dgDHCP.options[7]         = dhcpOpServerIdent;
                        pLLAdp->pDHCPMem->dgDHCP.options[8]         = 4;
                        pLLAdp->pDHCPMem->dgDHCP.options[9]         = pbOpSId[2];
                        pLLAdp->pDHCPMem->dgDHCP.options[10]        = pbOpSId[3];
                        pLLAdp->pDHCPMem->dgDHCP.options[11]        = pbOpSId[4];
                        pLLAdp->pDHCPMem->dgDHCP.options[12]        = pbOpSId[5];

                        // the IP I am requesting
                        // this option needs to stay here as I do checks on the IP later
                        pLLAdp->pDHCPMem->dgDHCP.options[13]        = dhcpOpRequstIP;
                        pLLAdp->pDHCPMem->dgDHCP.options[14]        = 4;
                        pLLAdp->pDHCPMem->dgDHCP.options[15]        = pDHCPDG->yiaddr.u8[0];
                        pLLAdp->pDHCPMem->dgDHCP.options[16]        = pDHCPDG->yiaddr.u8[1];
                        pLLAdp->pDHCPMem->dgDHCP.options[17]        = pDHCPDG->yiaddr.u8[2];
                        pLLAdp->pDHCPMem->dgDHCP.options[18]        = pDHCPDG->yiaddr.u8[3];

                        // messageType option
                        pLLAdp->pDHCPMem->dgDHCP.options[19]        = dhcpOpParamRequestList;
                        pLLAdp->pDHCPMem->dgDHCP.options[20]        = 7;
                        pLLAdp->pDHCPMem->dgDHCP.options[21]        = dhcpOpSubMask;            // submask addr
                        pLLAdp->pDHCPMem->dgDHCP.options[22]        = dhcpOpRouter;             // gateway
                        pLLAdp->pDHCPMem->dgDHCP.options[23]        = dhcpOpDomainNameServer;   // list of DNS servers
                        pLLAdp->pDHCPMem->dgDHCP.options[24]        = dhcpOpIPLeaseTime;        // server must return
                        pLLAdp->pDHCPMem->dgDHCP.options[25]        = dhcpOpRenewalTime;        // default .5 lease
                        pLLAdp->pDHCPMem->dgDHCP.options[26]        = dhcpOpReBindTime;         // default .875 lease
                        pLLAdp->pDHCPMem->dgDHCP.options[27]        = dhcpOpHostName;           // Network Domain name

                        // END option
                        pLLAdp->pDHCPMem->dgDHCP.options[28]        = dhcpOpEnd;

                        // clear the rest of the options area
                        // must be set to the first unused option byte
                        memset(&pLLAdp->pDHCPMem->dgDHCP.options[29], 0, (cbDHCPOptions-29));

                        // we do not worry about relay agents; we broadcast! The relay agent needs
                        // to broadcast through to all of the orignal DHCP servers.

                        // use our lease time as our timeout/retry timer.
                        pLLAdp->pDHCPMem->tsStart = SYSGetSecond();
                        pLLAdp->pDHCPMem->tsLease = dhcpInitRetryTime;

                        // ((LLADP *) pLLAdp)->dhcpState = dhcpARP;
                        ((LLADP *) pLLAdp)->dhcpState = dhcpREQUEST;
                    }
                }
            }

            // check for timeout, reissue the request, does not count as a retry, probably a lost datagram
            if(pLLAdp->dhcpState == dhcpOFFER && SYSGetSecond() - pLLAdp->pDHCPMem->tsStart > pLLAdp->pDHCPMem->tsLease)
            {
                // back off factor of 2, required.
                pLLAdp->pDHCPMem->tsLease *= 2;

                // reissue the DISCOVER
                ((LLADP *) pLLAdp)->dhcpState = dhcpDISCOVER;

                // but no more than 60 seconds, but include the 60 second time
                if(pLLAdp->pDHCPMem->tsLease > dhcpMaxRetryTime)
                {
                    ((LLADP *) pLLAdp)->dhcpState = dhcpDISABLED;
                }
            }
            break;

        // client requests an IP
        case dhcpREQUEST:

            // send or resed the request
            if(DHCPSend(pLLAdp, true, DHCPREQUIREBROADCAST))
            {
                pLLAdp->pDHCPMem->tsStart = SYSGetSecond();
                ((LLADP *) pLLAdp)->dhcpState = dhcpACK;
            }
            else
            {
                ((LLADP *) pLLAdp)->dhcpState = dhcpDISABLED;
            }
            break;

        // server ack clients request
        case dhcpACK:
            if(UDPAvailable(&pLLAdp->pDHCPMem->socket) > sizeof(DHCPDG))
            {
                uint8_t rgbDataGram[cbMinDHCPDGSize];
                DHCPDG * pDHCPDG    = (DHCPDG *) rgbDataGram;
                uint32_t cbDataGram = UDPPeek(&pLLAdp->pDHCPMem->socket, rgbDataGram, sizeof(rgbDataGram), NULL);
                uint8_t  cbOptions  = cbDataGram > sizeof(DHCPDG) ? (uint8_t) (cbDataGram - sizeof(DHCPDG)) : 0;

                // is this really for me
                if( cbDataGram > sizeof(DHCPDG)                     &&
                    pLLAdp->pDHCPMem->dgDHCP.xid == pDHCPDG->xid    &&
                    pDHCPDG->MagicCookie.u32 == MAGICCOOKIE         &&
                    memcmp(&pDHCPDG->yiaddr, &pLLAdp->pDHCPMem->dgDHCP.options[15], sizeof(IPv4)) == 0)
                {
                    const uint8_t * pbOp = NULL;

                    // MUST do this before scewing with the dgDHCP or the checksum will not work out!
                    IPSSetToMachineOrder(&pLLAdp->pDHCPMem->ipStack);

                    // see if this is an OFFER request
                    if( (pbOp = DHCPFindOption(dhcpOpMessageType, pDHCPDG->options, cbOptions)) != NULL )
                    {
                        if(pbOp[2] == dhcpACK)
                        {

                            // stuff our IP away for awhile so we can do an ARP
                            //if the ARP fails, we must zero this out before restarting.
                            memcpy((void *) &pLLAdp->pDHCPMem->dgDHCP.ciaddr, &pDHCPDG->yiaddr, sizeof(IPv4));
                            ((LLADP *) pLLAdp)->dhcpState = dhcpARPWait;
                            
                            // this is our lease start time
                            pLLAdp->pDHCPMem->tsStart = SYSGetSecond();
                        }
                        // something went wrong, re-negotiate for something else
                        else if(pbOp[2] == dhcpNAK)
                        {
                             ((LLADP *) pLLAdp)->dhcpState = dhcpRetryDISCOVER;
                        }
                    }
                }
            }

            // check for timeout, reissue the request
            if(pLLAdp->dhcpState == dhcpACK && SYSGetSecond() - pLLAdp->pDHCPMem->tsStart > pLLAdp->pDHCPMem->tsLease)
            {
                // back off factor of 2, required.
                pLLAdp->pDHCPMem->tsLease *= 2;

                // but no more than 60 seconds, defined
                if(pLLAdp->pDHCPMem->tsLease <= dhcpMaxRetryTime)
                {
                    ((LLADP *) pLLAdp)->dhcpState = dhcpREQUEST;
                }

                // try an OFFER from someone else
                else
                {
                    ((LLADP *) pLLAdp)->dhcpState = dhcpRetryDISCOVER;
                }
            }

            break;

        // need to make sure the IP is not in use yet.
        case dhcpARPWait:
            {
                MACADDR     mac;
                IPSTATUS    status;

                // see if the IP is in use
                if(LLARPLookup(pLLAdp, &pLLAdp->pDHCPMem->dgDHCP.ciaddr, &mac, 1, &status))
                {
                    // not good if in use, we must decline this.
                    pLLAdp->pDHCPMem->dgDHCP.ciaddr.u32 = IPv4NONE.u32;
                    ((LLADP *) pLLAdp)->dhcpState = dhcpDECLINE;
                }

                else if(status == ipsARPFailedToResolve)
                {
                    // This is good, we can accept this
                    pLLAdp->pDHCPMem->dgDHCP.ciaddr.u32 = IPv4NONE.u32;
                    ((LLADP *) pLLAdp)->dhcpState = dhcpACCEPT;
                    
// test, for a decline to see that we send the decline packet and start over                 
//((LLADP *) pLLAdp)->dhcpState = dhcpDECLINE;
                }

                // really not a good result; indicates something is fundametally wrong
                // with the ARP system; just get out
                else if(IsIPStatusAnError(status))
                {
                    ((LLADP *) pLLAdp)->dhcpState = dhcpDISABLED;
                }

                // ARP should eventually return, we should not need a timeout
            }
        break;

        case dhcpACCEPT:

            // this should just pass immediately because on the ACK we did a Peek
            // and did not wipe out the UDP socket buffer; this data should still be there
            if(UDPAvailable(&pLLAdp->pDHCPMem->socket) > sizeof(DHCPDG))
            {
                uint8_t rgbDataGram[cbMinDHCPDGSize];
                DHCPDG * pDHCPDG    = (DHCPDG *) rgbDataGram;
                uint32_t cbDataGram = UDPRead(&pLLAdp->pDHCPMem->socket, rgbDataGram, sizeof(rgbDataGram), NULL);
                uint8_t  cbOptions  = cbDataGram > sizeof(DHCPDG) ? (uint8_t) (cbDataGram - sizeof(DHCPDG)) : 0;

                // is this really for me
                if( cbDataGram > sizeof(DHCPDG)                     &&
                    pLLAdp->pDHCPMem->dgDHCP.xid == pDHCPDG->xid    &&
                    pDHCPDG->MagicCookie.u32 == MAGICCOOKIE         &&
                    memcmp(&pDHCPDG->yiaddr, &pLLAdp->pDHCPMem->dgDHCP.options[15], sizeof(IPv4)) == 0)
                {
                    const uint8_t * pbOp = NULL;

                    // MUST do this before scewing with the dgDHCP or the checksum will not work out!
                    IPSSetToMachineOrder(&pLLAdp->pDHCPMem->ipStack);

                    // see if this is an OFFER request
                    if( (pbOp = DHCPFindOption(dhcpOpMessageType, pDHCPDG->options, cbOptions)) != NULL )
                    {
                        if(pbOp[2] == dhcpACK)
                        {
                            // set up all of our network parameters
                            DHCPSetUpParameters(pLLAdp, pDHCPDG, cbOptions);

                            ((LLADP *) pLLAdp)->dhcpState = dhcpBOUND;

                            // We should broadcast an ARP to announce our new IP/MAC RFC 2131 4.2.1
                            // remember we are doing an ARP, this is the ARP ipstack, not the DHCP ipstack
                            if(!IPSIsInUse(&pLLAdp->ipStack))
                            {
//                                pLLAdp->ipStack.pARPIPv4->macDest = MACNONE;
                                pLLAdp->ipStack.pARPIPv4->ipv4Dest.u32  = IPv4BROADCAST.u32;        // tell the world
//                                pLLAdp->ipStack.pARPIPv4->macSrc = pLLAdp->pNwAdp->mac;
                                pLLAdp->ipStack.pARPIPv4->ipv4Src.u32   = pLLAdp->ipMy.ipv4.u32;    // who I am
                                ((LLADP *) pLLAdp)->arpIPv4.operation   = arpopReply;               // as a replay
                                LLSend((IPSTACK *) &pLLAdp->ipStack, NULL);                         // send it
                            }
                        }

                        // something went wrong, start over
                        else if(pbOp[2] == dhcpNAK)
                        {
                             ((LLADP *) pLLAdp)->dhcpState = dhcpRetryDISCOVER;
                        }
                    }
                }
            }
            break;

        // client declines an offer
        case dhcpDECLINE:
            {
                // MUST do this before scewing with the dgDHCP or the checksum will not work out!
                IPSSetToMachineOrder(&pLLAdp->pDHCPMem->ipStack);

                // This IP is in use, so we need to tell the DHCP server
                // we can't use it, and then go back to DISCOVER for another attempt.

                // messageType option; do not exceed cbDHCPOptions (32) bytes
                //pLLAdp->pDHCPMem->dgDHCP.options[0]         = dhcpOpMessageType;
                //pLLAdp->pDHCPMem->dgDHCP.options[1]         = 1;
                pLLAdp->pDHCPMem->dgDHCP.options[2]         = (uint8_t) dhcpDECLINE;

                // move up Server ID
                memcpy(&pLLAdp->pDHCPMem->dgDHCP.options[3], &pLLAdp->pDHCPMem->dgDHCP.options[7], 6);

                // copy the IP I was requesting up.
                memcpy(&pLLAdp->pDHCPMem->dgDHCP.options[9], &pLLAdp->pDHCPMem->dgDHCP.options[13], 6);

                // put in an error message; REMEMBER, do not exceed 32 bytes in options total, so keep the message short!
                pLLAdp->pDHCPMem->dgDHCP.options[15]         = dhcpOpMessage;
                pLLAdp->pDHCPMem->dgDHCP.options[16]         = sizeof(szIPInUse) - 1;
                memcpy(&pLLAdp->pDHCPMem->dgDHCP.options[17], szIPInUse, sizeof(szIPInUse) - 1);

                // END option, This is the 26th byte; less than 32
                pLLAdp->pDHCPMem->dgDHCP.options[17+sizeof(szIPInUse)-1] = dhcpOpEnd;

                // clear the rest of the options area
                // must be set to the first unused option byte
                memset(&pLLAdp->pDHCPMem->dgDHCP.options[18+sizeof(szIPInUse)-1], 0, (cbDHCPOptions - (18+sizeof(szIPInUse)-1)));

                DHCPSend(pLLAdp, true, 0);
                ((LLADP *) pLLAdp)->dhcpState = dhcpRetryDISCOVER;
            }
             
            break;

        case dhcpBOUND:
            {
                uint32_t tCur = SYSGetSecond();
                uint32_t dtCur = tCur - pLLAdp->pDHCPMem->tsStart;
                
                // time to do something
                // RFC 2131 4.4.5
                if(dtCur >= pLLAdp->pDHCPMem->tsRenew)
                {
                    bool        fBroadcast      = false;

                    // we are done, lease is up
                    if(dtCur >= pLLAdp->pDHCPMem->tsLease)
                    {
                        // not sure what to do, we expired
                        // start over, get another IP from someone...
                        ((LLADP *) pLLAdp)->dhcpState = dhcpDISCOVER;
                    }

                    // we are in the rebind time, so send to broadcast
                    else if(dtCur >= pLLAdp->pDHCPMem->tsReBind)
                    {
                        dtCur = (pLLAdp->pDHCPMem->tsLease - pLLAdp->pDHCPMem->tsRenew) / 2;
                        dtCur = max(dtCur, DHCPMINRENEWTIME);
                        dtCur += pLLAdp->pDHCPMem->tsRenew;
                        pLLAdp->pDHCPMem->tsRenew = min(dtCur, pLLAdp->pDHCPMem->tsLease);
                        fBroadcast = true;
                    }

                    // we are in the renew time, unicast
                    else
                    {
                        dtCur = (pLLAdp->pDHCPMem->tsReBind - pLLAdp->pDHCPMem->tsRenew) / 2;
                        dtCur = max(dtCur, DHCPMINRENEWTIME);
                        dtCur += pLLAdp->pDHCPMem->tsRenew;
                        pLLAdp->pDHCPMem->tsRenew = min(dtCur, pLLAdp->pDHCPMem->tsReBind);
                    }

                    // MUST do this before scewing with the dgDHCP or the checksum will not work out!
                    if(IPSSetToMachineOrder(&pLLAdp->pDHCPMem->ipStack))
                    {
                        // Make a Renewal request
                        // Set IPs in the request pkt.
                        memcpy(&pLLAdp->pDHCPMem->dgDHCP.ciaddr, &pLLAdp->ipMy.ipv4,        sizeof(IPv4));
                        memcpy(&pLLAdp->pDHCPMem->dgDHCP.siaddr, &IPv4NONE,                 sizeof(IPv4));
                        memcpy(&pLLAdp->pDHCPMem->dgDHCP.giaddr, &IPv4NONE,                 sizeof(IPv4));
                        memcpy(&pLLAdp->pDHCPMem->dgDHCP.yiaddr, &IPv4NONE,                 sizeof(IPv4));

                        // messageType option; do not exceed cbDHCPOptions (32) bytes
                        //pLLAdp->pDHCPMem->dgDHCP.options[0]         = dhcpOpMessageType;
                        //pLLAdp->pDHCPMem->dgDHCP.options[1]         = 1;
                        pLLAdp->pDHCPMem->dgDHCP.options[2]         = (uint8_t) dhcpREQUEST;

                        // RFC says I should put in the max datagram size; which is the min size as well.
                        // this is all the bigger my buffer is.
                        // This is the same as before, no need to assign it again
                        //pLLAdp->pDHCPMem->dgDHCP.options[3]         = dhcpOpMaxMessageSize;
                        //pLLAdp->pDHCPMem->dgDHCP.options[4]         = 2;
                        //pLLAdp->pDHCPMem->dgDHCP.options[5]         = (uint8_t) ((cbMinDHCPDGSize & 0x0000FF00) >> 8);
                        //pLLAdp->pDHCPMem->dgDHCP.options[6]         = (uint8_t) (cbMinDHCPDGSize & 0x000000FF);

                        // messageType option
                        pLLAdp->pDHCPMem->dgDHCP.options[7]         = dhcpOpParamRequestList;
                        pLLAdp->pDHCPMem->dgDHCP.options[8]         = 7;
                        pLLAdp->pDHCPMem->dgDHCP.options[9]         = dhcpOpSubMask;            // submask addr
                        pLLAdp->pDHCPMem->dgDHCP.options[10]        = dhcpOpRouter;             // gateway
                        pLLAdp->pDHCPMem->dgDHCP.options[11]        = dhcpOpDomainNameServer;   // list of DNS servers
                        pLLAdp->pDHCPMem->dgDHCP.options[12]        = dhcpOpIPLeaseTime;        // server must return
                        pLLAdp->pDHCPMem->dgDHCP.options[13]        = dhcpOpRenewalTime;        // default .5 lease
                        pLLAdp->pDHCPMem->dgDHCP.options[14]        = dhcpOpReBindTime;         // default .875 lease
                        pLLAdp->pDHCPMem->dgDHCP.options[15]        = dhcpOpHostName;           // Network Domain name

                        // END option
                        pLLAdp->pDHCPMem->dgDHCP.options[16]        = dhcpOpEnd;

                        // clear the rest of the options area
                        // must be set to the first unused option byte
                        memset(&pLLAdp->pDHCPMem->dgDHCP.options[17], 0, (cbDHCPOptions-17));

                        if(DHCPSend(pLLAdp, fBroadcast, (fBroadcast ? DHCPREQUIREBROADCAST : 0)))
                        {
                            ((LLADP *) pLLAdp)->dhcpState = dhcpRENEW;
                        }
                    }
                }
            }
            break;

        case dhcpRENEW:
            {
                uint32_t tCur = SYSGetSecond();
                uint32_t dtCur = tCur - pLLAdp->pDHCPMem->tsStart;

                if(UDPAvailable(&pLLAdp->pDHCPMem->socket) > sizeof(DHCPDG))
                {
                    uint8_t rgbDataGram[cbMinDHCPDGSize];
                    DHCPDG * pDHCPDG    = (DHCPDG *) rgbDataGram;
                    uint32_t cbDataGram = UDPRead(&pLLAdp->pDHCPMem->socket, rgbDataGram, sizeof(rgbDataGram), NULL);
                    uint8_t  cbOptions  = cbDataGram > sizeof(DHCPDG) ? (uint8_t) (cbDataGram - sizeof(DHCPDG)) : 0;

                    // is this really for me
                    if( cbDataGram > sizeof(DHCPDG)                     &&
                        pLLAdp->pDHCPMem->dgDHCP.xid == pDHCPDG->xid    &&
                        pDHCPDG->MagicCookie.u32 == MAGICCOOKIE         &&
                        memcmp(&pLLAdp->pDHCPMem->dgDHCP.ciaddr, &pDHCPDG->yiaddr, sizeof(IPv4)) == 0)
                    {
                        const uint8_t * pbOp = NULL;

                        // MUST do this before scewing with the dgDHCP or the checksum will not work out!
                        IPSSetToMachineOrder(&pLLAdp->pDHCPMem->ipStack);

                        // see if this is an OFFER request
                        if( (pbOp = DHCPFindOption(dhcpOpMessageType, pDHCPDG->options, cbOptions)) != NULL )
                        {
                            // ACK, or unknown; go back to the bound state
                            // and wait for the next timeout
                            ((LLADP *) pLLAdp)->dhcpState = dhcpBOUND;

                            if(pbOp[2] == dhcpACK)
                            {
                                // reset our timer
                                pLLAdp->pDHCPMem->tsStart = SYSGetSecond();

                                // set up all of our network parameters
                                DHCPSetUpParameters(pLLAdp, pDHCPDG, cbOptions);
                            }

                            // if we actively get a NAK, get a new IP from someone else
                            else if(pbOp[2] == dhcpNAK)
                            {
                                // we had an IP for awhile, so we can do the full retry thing to get another one.
                                pLLAdp->pDHCPMem->cTryDiscovery = 0;
                                ((LLADP *) pLLAdp)->dhcpState = dhcpStartDISCOVER;
                            }
                        }
                    }
                }

                // If our wait time expired go back to the bound state
                // to try again
                 else if(dtCur >= pLLAdp->pDHCPMem->tsRenew)
                {
                            ((LLADP *) pLLAdp)->dhcpState = dhcpBOUND;
                }
            }
            break;

        // client is not using DHCP, uses statically assigned IP
        // I really shouldn't get here, so terminate to cause a clean up
        case dhcpDISABLED:
        case dhcpSTATICIP:
        default:
            DHCPTerminate(pLLAdp);
            break;
    }

    return;
}


void DHCPPeriodicTasks(void)
{
    const LLADP * pLLAdp = NULL;

    // walk all of the adpators and process each DHCP State
    while((pLLAdp = (LLADP*)FFNext(&ffptAdaptors, pLLAdp)) != NULL)
    {
        DHCPStateMachine(pLLAdp);
    }
}
