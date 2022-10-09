/************************************************************************/
/*                                                                      */
/*	SNTPv4.c    Implements SNTPv4 RFC 4330 a strict subset              */
/*                  of NTPv4 RFC 5905                                   */
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
/*	SNTPv4 time server                                                  */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	10/17/2013(KeithV): Created                                         */
/*                                                                      */
/************************************************************************/

#include "deIP.h"

// buffers to use for the time service
static uint8_t const * const rgNTPServers[] = ntpDefaultServerList;

bool SNTPv4Init(const LLADP * pLLAdp, void * rgbSNTPvMem, uint32_t cbSNTPv4Mem, HPMGR hPMGR, uint8_t const * const * const rgpServers, uint32_t cServers, IPSTATUS * pStatus)
{
    IPSTATUS    status  = ipsSuccess;
    NTPMEM *    pNTPMem = (NTPMEM *) rgbSNTPvMem;
    HSOCKET     hUDP    = NULL;

    if(pLLAdp == NULL)
    {
        status = ipsNullAdaptor;
    }
    else if(pLLAdp->pNTPMem != NULL)
    {
        status = ipsNTPMemoryNull;
    }
    else if(rgbSNTPvMem == NULL || cbSNTPv4Mem < SNTPv4MemSize)
    {
        status = ipsNTPMemoryTooSmall;
    }
    else if(hPMGR == NULL)
    {
        status = ipsNoPMGRGiven;
    }

    if(IsIPStatusAnError(status))
    {
        AssignStatusSafely(pStatus, status);
    }
    memset(rgbSNTPvMem, 0, cbSNTPv4Mem);
    
    // this is only to make sure the data looks valid
    // we will reinit again later when we need to use it.
    // this is so I can terminate with a valid ipStack
    IPSInitIpStack(pLLAdp, &pNTPMem->ntpIpStack, ippnUDP);

    pNTPMem->ppNTPServers = rgpServers;
    pNTPMem->cNTPServers = cServers;

    // set up the default servers if none specified
    if(rgpServers == NULL)
    {
        pNTPMem->ppNTPServers = rgNTPServers;
        pNTPMem->cNTPServers = sizeof(rgNTPServers) / sizeof(uint8_t *);
    }

    // we have no servers to ask
    if(pNTPMem->cNTPServers == 0)
    {
        AssignStatusSafely(pStatus, ipsNoNTPServers);
        return(false);
    }

    // common for all sntp packets
    pNTPMem->ntpv4Request.vn   = ntpVERSION;        // version 4
    pNTPMem->ntpv4Request.mode = ntpModeClient;     // client mode

    // Now make a socket and listen
    hUDP = UDPOpenWithSocket(pLLAdp,
                            &pNTPMem->socket,
                            hPMGR,
                            &UDPAnyRemoteIPv4,
                            ntpPORT,
                            portDynamicallyAssign,
                            pStatus);

    if(hUDP == NULL)
    {
        return(false);
    }

    pNTPMem->iServerNext    = 0;
    pNTPMem->sntpState      = sntpResolveServerName;
    pNTPMem->cAttempt       = 0;
    pNTPMem->tCorrection    = 0;

    // put this in my adpator
    ((LLADP *) pLLAdp)->pNTPMem = pNTPMem;
    return(true);
}

bool SNTPv4Terminate(const LLADP * pLLAdp)
{
    if(pLLAdp != NULL && pLLAdp->pNTPMem != NULL)
    {
        pLLAdp->pNTPMem->sntpState = sntpUninitialized;
        if(IPSIsInUse(&pLLAdp->pNTPMem->ntpIpStack))
        {
            return(false);
        }

        UDPClose(&pLLAdp->pNTPMem->socket);
        ((LLADP *) pLLAdp)->pNTPMem = NULL;
    }

    return(true);
}

uint32_t SNTPv4GetNTPEpochTime(const LLADP * pLLAdp)
{
    if(pLLAdp == NULL || pLLAdp->pNTPMem == NULL)
    {
        return(0);
    }

    // if the time has not been acquired, keep trying to get it
    else if(pLLAdp->pNTPMem->tCorrection == 0)
    {

        // this is for the impatient, if you keep asking for the
        // time, and you can't seem to get the time, then keep 
        // trying with different servers. This will consume the DNS
        // service each time you call for the time, if the time has
        // not been acquired.
        if(pLLAdp->pNTPMem->sntpState == sntpWait)
        {
            // try another server; right now, do not wait for the timeout
            pLLAdp->pNTPMem->sntpState  = sntpResolveServerName;
        }
        return(0);
    }

    return(SYSGetSecond() + pLLAdp->pNTPMem->tCorrection);
}

uint32_t SNTPv4GetUNIXEpochTime(const LLADP * pLLAdp)
{
    uint32_t unixTime = SNTPv4GetNTPEpochTime(pLLAdp);

    if(unixTime == 0)
    {
        return(0);
    }
    return(unixTime - 2208988800ul);
}


static void SNTPv4StateMachine(const LLADP * pLLAdp)
{
    IPSTATUS            status = ipsSuccess;
    IPv4                ipServer;
    uint8_t const *     szServer = NULL;
    uint32_t            cbDatagram = 0;

    if(pLLAdp == NULL || pLLAdp->pNTPMem == NULL || IPSIsInUse(&pLLAdp->pNTPMem->ntpIpStack) || !ILIsIPSetup(pLLAdp, NULL))
    {
        return;
    }

    switch(pLLAdp->pNTPMem->sntpState)
    {
        case sntpResolveServerName:

            // if too many attempts, just wait
            if(pLLAdp->pNTPMem->cAttempt == pLLAdp->pNTPMem->cNTPServers)
                {
                    pLLAdp->pNTPMem->sntpState  = sntpStartWait;
                    break;
                }

            // Resolve the next NTP server to try
            szServer = pLLAdp->pNTPMem->ppNTPServers[pLLAdp->pNTPMem->iServerNext];
            if(DNSResolve(pLLAdp, szServer, (uint32_t) strlen((const char *) szServer), &ipServer, &status))
            {
                IPSTACK * pIpStack  = IPSInitIpStack(pLLAdp, &pLLAdp->pNTPMem->ntpIpStack, ippnUDP);

                // next time, use the next server
                pLLAdp->pNTPMem->iServerNext = (pLLAdp->pNTPMem->iServerNext + 1) % pLLAdp->pNTPMem->cNTPServers;

                // set up our UDP packet
                pLLAdp->pNTPMem->tStart     = SYSGetSecond();
                if(pLLAdp->pNTPMem->tCorrection == 0)
                {
                    pLLAdp->pNTPMem->ntpv4Request.orgTimeStamp.cSeconds = 0;
                }
                else
                {
                    pLLAdp->pNTPMem->ntpv4Request.orgTimeStamp.cSeconds = pLLAdp->pNTPMem->tStart + pLLAdp->pNTPMem->tCorrection;
                }


                // for now assume we will fail to send; which will cause us to
                // wait for our next attempt.
                pLLAdp->pNTPMem->sntpState  = sntpStartWait;

                // send it out
                if(pIpStack != NULL)
                {
                    // set the time to live to the maximum it can go on the WAN
                    pIpStack->pIPv4Hdr->timeToLive = ntpMAXDIST;
                    ExEndian(&pLLAdp->pNTPMem->ntpv4Request.orgTimeStamp.cSeconds, sizeof(uint32_t));
                    if(UDPRawSend(pLLAdp, pIpStack, &ipServer, ntpPORT, SKTGetLocalPort(&pLLAdp->pNTPMem->socket), (uint8_t *) &pLLAdp->pNTPMem->ntpv4Request, sizeof(NTPV4), false, &status))
                    {
                        // here is where we succeed.
                        pLLAdp->pNTPMem->sntpState  = sntpWaitResponse;
                    }
                    else
                    {
                        IPSRelease(pIpStack);
                    }
                }
            }
            else if(IsIPStatusAnError(status))
            {
                // go to the next server
                pLLAdp->pNTPMem->cAttempt++;
                pLLAdp->pNTPMem->iServerNext = (pLLAdp->pNTPMem->iServerNext + 1) % pLLAdp->pNTPMem->cNTPServers;
                pLLAdp->pNTPMem->tStart     = SYSGetSecond();
                pLLAdp->pNTPMem->sntpState  = sntpStartWait;
            }
            break;

        case sntpWaitResponse:
            // see if any data is in the socket.
            if((cbDatagram = UDPAvailable(&pLLAdp->pNTPMem->socket)) > 0)
            {
                if(UDPRead(&pLLAdp->pNTPMem->socket, (uint8_t *) &pLLAdp->pNTPMem->ntpv4Response, sizeof(NTPV4), &status) >= sizeof(NTPV4))
                {
                    NTPV4 * pResponse = &pLLAdp->pNTPMem->ntpv4Response;

                    ExEndian(&pResponse->recTimeStamp.cSeconds, sizeof(uint32_t));
                    ExEndian(&pResponse->transmitTimeStamp.cSeconds, sizeof(uint32_t));
//                    ExEndian(&pResponse->orgTimeStamp.cSeconds, sizeof(uint32_t));
                    
                    // only because sometimes we don't get the original time back in the response
                    // so recalcuate it from what we put in
                    pResponse->orgTimeStamp.cSeconds = pLLAdp->pNTPMem->tStart + pLLAdp->pNTPMem->tCorrection;

                    if( pResponse->mode == ntpModeServer
                                            &&
                        pResponse->stratum >= ntpStratumPrimaryServer
                                            &&
                        pResponse->stratum <= ntpStratumSecondaryServerEnd )
                    {

                        // calculate the correction factor
                        pLLAdp->pNTPMem->tCorrection +=
                            ((uint32_t) (((((int64_t) pResponse->recTimeStamp.cSeconds) - pResponse->orgTimeStamp.cSeconds) +
                            (((int64_t) pResponse->transmitTimeStamp.cSeconds) - (SYSGetSecond() + pLLAdp->pNTPMem->tCorrection))) / 2));
                        pLLAdp->pNTPMem->sntpState  = sntpStartWait;
                    }
                }
                
                // not a datagram I am expecting, or clear the rest of the datagram
                if(UDPAvailable(&pLLAdp->pNTPMem->socket) > 0)
                {
                    UDPDiscard(&pLLAdp->pNTPMem->socket);
                }
            }

            // timeout on this guy, try the next server
            else if((SYSGetSecond() - pLLAdp->pNTPMem->tStart) >= (4*ntpMAXDIST))
            {
                // go to the next server
                pLLAdp->pNTPMem->cAttempt++;
                pLLAdp->pNTPMem->iServerNext = (pLLAdp->pNTPMem->iServerNext + 1) % pLLAdp->pNTPMem->cNTPServers;
                pLLAdp->pNTPMem->sntpState  = sntpResolveServerName;
            }
            break;
            
        case sntpStartWait:
            // initialize the wait and start over on attempts
            pLLAdp->pNTPMem->cAttempt   = 0;
            pLLAdp->pNTPMem->tStart = SYSGetSecond();
            pLLAdp->pNTPMem->sntpState  = sntpWait;
            break;
            
        case sntpWait:
            // wait
            if((SYSGetSecond() - pLLAdp->pNTPMem->tStart) >= (pLLAdp->pNTPMem->tCorrection == 0 ? ntpACQUIRESEC : ntpPOLLSEC))
            {
                // now try again
                pLLAdp->pNTPMem->sntpState  = sntpResolveServerName;
            }
            break;

        case sntpUninitialized:
        default:
            break;
    }
}

void SNTPPeriodicTasks(void)
{
    const LLADP * pLLAdp = NULL;

    // walk all of the adpators and process each DHCP State
    while((pLLAdp = (LLADP*)FFNext(&ffptAdaptors, pLLAdp)) != NULL)
    {
        if(pLLAdp->pNTPMem != NULL)
        {
            SNTPv4StateMachine(pLLAdp);
        }
    }
}
