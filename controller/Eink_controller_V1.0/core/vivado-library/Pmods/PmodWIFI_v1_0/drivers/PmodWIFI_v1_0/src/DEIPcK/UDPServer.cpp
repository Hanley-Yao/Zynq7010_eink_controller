/************************************************************************/
/*                                                                      */
/*  UDPServer.cpp   The C++ wrapper class for the deIP UDP server class */
/*                                                                      */
/************************************************************************/
/*  Author:     Keith Vogel                                             */
/*  Copyright 2013, Digilent Inc.                                       */
/************************************************************************/
/* DEIPcK deIP core network library
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
/*      Implements the UDPServer Class                                  */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*      12/10/2013(KeithV): Created                                     */
/*                                                                      */
/************************************************************************/
#include "DEIPcK.h"

FFPT UDPServer::_ffptPeriodTask = {NULL, NULL};

/***	UDPServer Constructors
**
**  Notes:
**
**      Initialize a new UDPServer Instance and specify
**      maximum number of sockets that it will use.
**      Only 1 socket is listening at a time on the port
**      however there may be many sockets pending and accept.
**      Once all sockets are consumed by unaccepted clients
**      UDPServer will stop listening on the port until
**      a client is accepted and a socket opens up.
**
*/
UDPServer::UDPServer()
{
    clear();
}

/***	UDPServer Destructor
**
**  Notes:
**
**    Shuts down all sockets and releases all resources
**
**
*/
UDPServer::~UDPServer()
{
    close();
}

void UDPServer::clear(void)
{
    _ffptInfo._pNext = NULL;
    _ffptInfo._this = this;
    _pDEIPcK = NULL;
    _listeningPort = portUnassigned;
    memset(&_ffptSockets, 0, sizeof(FFPT));
}

/***	void UDPServer::close(void)
**
**	Synopsis:
**      Stops Listening and closes all unaccepted sockets/connections
**      and clears everything back to it's originally constructed state.
**
**	Parameters:
**      None
**
**	Return Values:
**      None
**
**	Errors:
**      None
**
**  Notes:
**
**      Returns the UDPServer instance to
**      a state just as if the instance had just been
**      constructed. It also, Close all connections
**      and releases all resources (sockets).
**
*/
void UDPServer::close(void)
{
    FFLL * pffll = NULL;

    // pull this off the listening list
    FFRemove(&_ffptPeriodTask, &_ffptInfo);

    // close and sockets added to the server
    while((pffll = (FFLL *) FFOutPacket(&_ffptSockets)) != NULL)
    {
        ((UDPSocket *) (pffll->_this))->close();
    }

    clear();
}

bool UDPServer::addSocket(UDPSocket& udpSocket, IPSTATUS * pStatus)
{
    // if we don't have a page manager, assign the default one
    if(udpSocket._hPMGR == NULL)
    {
        udpSocket._hPMGR = hNetworkPMGR;
    }

    if(udpSocket._hPMGR == NULL)
    {
        AssignStatusSafely(pStatus, ipsNoPMGRGiven);
        return(false);
    }
    else if(_pDEIPcK == NULL)
    {
        AssignStatusSafely(pStatus, ipsNotInitialized);
        return(false);
    }
    else if(udpSocket._pDEIPcK != NULL)
    {
        AssignStatusSafely(pStatus, ipsInUse);
        return(false);
    }

    // add it to the list of sockets to listen on
    FFInPacket(&_ffptSockets, &udpSocket._ffptInfo);
    udpSocket._pDEIPcK = _pDEIPcK;
    return(true);
}

/***	int UDPServer::availableClients(void)
**
**	Synopsis:
**      Checks to see how many pending clients are availabe to be accepted.
**
**	Parameters:
**      None
**
**	Return Values:
**      The number of waiting TCPSockets to be accepted.
**
**	Errors:
**      None
**
**  Notes:
**
**      This is the workhorse of the UDPServer Class
**      It will update pending clients if a connection is detected
**      It will attempt to start listening if a socket comes avalialbe for listening
**      It will clean up disconnected clients
*/
int UDPServer::availableClients(int& cListening, IPSTATUS * pStatus)
{
    int cAvailable = 0;
    cListening = 0;

    FFLL *      pffllSocket = NULL;

   if(_pDEIPcK == NULL)
   {
       AssignStatusSafely(pStatus, ipsNotInitialized);
       return(0);
   }

    if(ILIsIPNetworkReady(_pDEIPcK->_pLLAdp, pStatus))
    {
        while((pffllSocket = (FFLL *) FFNext(&_ffptSockets, pffllSocket)) != NULL)
        {
            UDPSocket& udpSocket = *((UDPSocket *) (pffllSocket->_this));   // for syntax sake

            if(udpSocket.available() > 0)
            {
                cAvailable++;
            }
            else if(udpSocket._socket.s.ipRemote.ipv4.u32 == IPv4Listen.u32)
            {
                cListening++;
            }
        }
    }
    return(cAvailable);
}

/***	bool UDPServer::acceptClient(UDPSocket * pTCPSocket)
**      bool UDPServer::acceptClient(UDPSocket * pTCPSocket, int index)
**      bool UDPServer::acceptClient(UDPSocket * pTCPSocket, DEIPcK::STATUS * pStatus)
**      bool UDPServer::acceptClient(UDPSocket * pTCPSocket, int index, DEIPcK::STATUS * pStatus)
**
**	Synopsis:
**      Removes a pending UDPSocket by accepting it from the server.
**
**	Parameters:
**      pTCPSocket  A pointer to a newly constructed client UDPSocket
**
**      index       This is the zero based index of the client you want to accept. index must be less
**                      than what AvailableClients.
**
**      pStatus     A pointer to receive the status of AcceptClient
**
**	Return Values:
**      true if the UDPSocket was returned
**      false if the UDPSocket could not be created
**
**	Errors:
**      None
**
**  Notes:
**
**     This call should be made immediately after AvailableClients or GetAvailableClientsRemoteEndPoint.
**      Do not run PeriodicTasks between AvailableClients and this call because the client count could change.
**      In order to keep the indexes within the range of AvailableClients and consistent with what GetAvailableClientsRemoteEndPoint
**      returned, do not run AvailableClients or PeriodicTasks inbetween them. That is, do not run any stack task as that
**      would change the AvailableClients count and order.
**
*/
// We can get errors, you passed me a NULL, or an opened UDPSocket, or index out of range.
UDPSocket *  UDPServer::acceptClient(int index)
{
    FFLL *      pffllSocket = NULL;
    int         c = 0;

    while((pffllSocket = (FFLL *) FFNext(&_ffptSockets, pffllSocket)) != NULL)
    {
        UDPSocket& udpSocket = *((UDPSocket *) (pffllSocket->_this));   // for syntax sake

        if(udpSocket.available() > 0 && c == index)
        {
            FFRemove(&_ffptSockets, pffllSocket);
            udpSocket._classState = ipsInUseW;
            return(&udpSocket);
        }
    }

    return(NULL);
}

/***	bool UDPServer::getAvailableClientsRemoteEndPoint(IPEndPoint *pRemoteEP, int index)
**      bool UDPServer::getAvailableClientsRemoteEndPoint(IPEndPoint *pRemoteEP, MAC * pRemoteMAC, int index)
**
**	Synopsis:
**      Returns endpoint information about a UDPSocket waiting to be accepted.
**
**	Parameters:
**      pRemoteEP  A pointer to an IPEndPoint to receive the remote endpoint information for the client
**                  waiting to be accepted. This may be NULL if you don't want the info
**
**      pRemoteMAC  A pointer to a MAC to receive the remote MAC address of the client waiting to be accepted.
**                      This will be the MAC address as known by ARP and will only have MAC address of machines
**                      on your local area network. If the IP is not local, the MAC will most probably be the MAC
**                      of your router. This may be NULL if you don't want the info
**
**     index        This is a zero based index and must be less than what AvailableClients returns. It
**                      selects the Client within the server list that you want remote endpoint information on.
**
**	Return Values:
**      true    The local endpoint was returned.
**      false   An error occured, most likely your index was out of range
**
**	Errors:
**      None
**
**  Notes:
**
**      This allows you to determine if you want to accept this endpoint before removing it from
**      the server. It allows you to accept other clients first and out of order.
**
**      This call should be made immediately after AvailableClients and immediately before
**      AcceptClient so that the servers pending list does not change due to another connection.
**
*/
bool UDPServer::getAvailableClientsRemoteEndPoint(IPEndPoint& epRemote, int index)
{
    FFLL *      pffllSocket = NULL;
    int         c = 0;

    while((pffllSocket = (FFLL *) FFNext(&_ffptSockets, pffllSocket)) != NULL)
    {
        UDPSocket& udpSocket = *((UDPSocket *) (pffllSocket->_this));   // for syntax sake

        if(udpSocket.available() > 0 && c == index)
        {
            return(udpSocket.getRemoteEndPoint(epRemote));
        }
    }

    return(false);
}

/***	bool UDPServer::getListeningEndPoint(IPEndPoint *pListeningEP)
**
**	Synopsis:
**      Gets the endpoint that the server is listening on.
**      This is both the IP and port the server is on.
**
**	Parameters:
**      epLocal  A pointer to an IPEndPoint to receive the local endpoint information.
**
**	Return Values:
**      true    The local endpoint was returned.
**      false   The local endpoint is not known, usually because the connection was not set up yet.
**
**	Errors:
**      None
**
**  Notes:
**
**      If false is returned, then *pLocalEP will be garbage.
**
*/
bool UDPServer::getListeningEndPoint(IPEndPoint& epLocal)
{
    if(_pDEIPcK != NULL && ILIsIPSetup(_pDEIPcK->_pLLAdp, NULL))
    {
        ILGetMyIP(_pDEIPcK->_pLLAdp, &epLocal.ip);
        epLocal.port = _listeningPort;
        return(true);
    }

    return(false);
}

/***	void UDPServer::periodicTask(void)
**
**	Synopsis:
**      Gets the endpoint that the server is listening on.
**      This is both the IP and port the server is on.
**
**	Parameters:
**          None
**
**	Return Values:
**          None
**
**	Errors:
**          None
**
**  Notes:
**
**      This will open up any new sockets for listening
**
*/
void UDPServer::periodicTask(void)
{
    FFLL *      pffllServer = NULL;

    // look at all of the server objects
    while((pffllServer = (FFLL *) FFNext(&_ffptPeriodTask, pffllServer)) != NULL)
    {
        FFLL *      pffllSocket = NULL;
        UDPServer&  udpServer = *((UDPServer *) (pffllServer->_this));      // for syntax sake

        if(ILIsIPSetup(udpServer._pDEIPcK->_pLLAdp, NULL))
        {
            while((pffllSocket = (FFLL *) FFNext(&udpServer._ffptSockets, pffllSocket)) != NULL)
            {
                UDPSocket& udpSocket = *((UDPSocket *) (pffllSocket->_this));   // for syntax sake

                // start listening on available sockets
                if(udpSocket._classState == ipsNotInitialized)
                {
                    // get this listening
                    if(UDPOpenWithSocket(udpSocket._pDEIPcK->_pLLAdp, &udpSocket._socket, udpSocket._hPMGR, &IPListen, portListen, udpServer._listeningPort, NULL) == &udpSocket._socket)
                    {
                        udpSocket._classState = ipsListening;
                    }
                }
            }
        }
    }
}
