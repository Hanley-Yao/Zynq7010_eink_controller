/************************************************************************/
/*                                                                      */
/*  TCPServer.cpp   The C++ wrapper class for the deIP TCP server class */
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
/*      Implements the TCPServer Class                                  */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*      11/20/2011(KeithV): Created                                     */
/*                                                                      */
/************************************************************************/
#include "DEIPcK.h"

FFPT TCPServer::_ffptPeriodTask = {NULL, NULL};

/***	TCPServer Constructors
**
**  Notes:
**      
**      Initialize a new TCPServer Instance and specify
**      maximum number of sockets that it will use.
**      Only 1 socket is listening at a time on the port
**      however there may be many sockets pending and accept.
**      Once all sockets are consumed by unaccepted clients
**      TCPServer will stop listening on the port until
**      a client is accepted and a socket opens up.
**
*/
TCPServer::TCPServer()
{
    clear();
}

/***	TCPServer Destructor
**
**  Notes:
**      
**    Shuts down all sockets and releases all resources  
**      
**
*/
TCPServer::~TCPServer()
{
    close();
}

void TCPServer::clear(void)
{
    _ffptInfo._pNext = NULL;
    _ffptInfo._this = this;
    _pDEIPcK = NULL;
    _listeningPort = portUnassigned;
    memset(&_ffptSockets, 0, sizeof(FFPT));
}

/***	void TCPServer::close(void)
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
**      Returns the TCPServer instance to
**      a state just as if the instance had just been
**      constructed. It also, Close all connections
**      and releases all resources (sockets).
**
*/
void TCPServer::close(void)
{
    FFLL * pffll = NULL;

    // pull this off the listening list
    FFRemove(&_ffptPeriodTask, &_ffptInfo);

    // close and sockets added to the server
    while((pffll = (FFLL *) FFOutPacket(&_ffptSockets)) != NULL)
    {
        ((TCPSocket *) (pffll->_this))->close();
    }
    
    clear();
}

bool TCPServer::addSocket(TCPSocket& tcpSocket, IPSTATUS * pStatus)
{
    // if we don't have a page manager, assign the default one
    if(tcpSocket._hPMGR == NULL)
    {
        tcpSocket._hPMGR = hNetworkPMGR;
    }

    if(tcpSocket._hPMGR == NULL)
    {
        AssignStatusSafely(pStatus, ipsNoPMGRGiven);
        return(false);
    }
    else if(_pDEIPcK == NULL)
    {
        AssignStatusSafely(pStatus, ipsNotInitialized);
        return(false);
    }
    else if(tcpSocket._pDEIPcK != NULL)
    {
        AssignStatusSafely(pStatus, ipsInUse);
        return(false);
    }

    // add it to the list of sockets to listen on
    FFInPacket(&_ffptSockets, &tcpSocket._ffptInfo);
    tcpSocket._pDEIPcK = _pDEIPcK;
    return(true);
}

/***	int TCPServer::availableClients(void)
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
**      This is the workhorse of the TCPServer Class
**      It will update pending clients if a connection is detected
**      It will attempt to start listening if a socket comes avalialbe for listening
**      It will clean up disconnected clients
*/
int TCPServer::availableClients(int& cListening, int& cWaiting, IPSTATUS * pStatus)
{
    int cAvailable = 0;
    cWaiting = 0;
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
            TCPSocket& tcpSocket = *((TCPSocket *) (pffllSocket->_this));   // for syntax sake

            if(TCPIsEstablished(&tcpSocket._socket, NULL))
            {
                cAvailable++;
            }
            else if(TCPIsConnected(&tcpSocket._socket, NULL))
            {
                cWaiting++;
            }
            else if(tcpSocket._socket.tcpState == tcpListen)
            {
                cListening++;
            }
         }
    }

    return(cAvailable);
}

/***	bool TCPServer::acceptClient(TCPSocket * pTCPSocket)
**      bool TCPServer::acceptClient(TCPSocket * pTCPSocket, int index)
**      bool TCPServer::acceptClient(TCPSocket * pTCPSocket, DEIPcK::STATUS * pStatus)
**      bool TCPServer::acceptClient(TCPSocket * pTCPSocket, int index, DEIPcK::STATUS * pStatus)
**
**	Synopsis:   
**      Removes a pending TCPSocket by accepting it from the server.
**
**	Parameters:
**      pTCPSocket  A pointer to a newly constructed client TCPSocket
**
**      index       This is the zero based index of the client you want to accept. index must be less
**                      than what AvailableClients.
**
**      pStatus     A pointer to receive the status of AcceptClient
**      
**	Return Values:
**      true if the TCPSocket was returned
**      false if the TCPSocket could not be created
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
// We can get errors, you passed me a NULL, or an opened TCPSocket, or index out of range.
TCPSocket *  TCPServer::acceptClient(int index)
{
    FFLL *      pffllSocket = NULL;
    int         c = 0;

    while((pffllSocket = (FFLL *) FFNext(&_ffptSockets, pffllSocket)) != NULL)
    {
        TCPSocket& tcpSocket = *((TCPSocket *) (pffllSocket->_this));   // for syntax sake

        if(TCPIsEstablished(&tcpSocket._socket, NULL) && c == index)
        {
            FFRemove(&_ffptSockets, pffllSocket);
            tcpSocket._classState = ipsInUseW;
            return(&tcpSocket);
        }
    }

    return(NULL);
}
   
/***	bool TCPServer::getAvailableClientsRemoteEndPoint(IPEndPoint *pRemoteEP, int index)
**      bool TCPServer::getAvailableClientsRemoteEndPoint(IPEndPoint *pRemoteEP, MAC * pRemoteMAC, int index)
**
**	Synopsis:   
**      Returns endpoint information about a TCPSocket waiting to be accepted.
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
bool TCPServer::getAvailableClientsRemoteEndPoint(IPEndPoint& epRemote, int index)
{
    FFLL *      pffllSocket = NULL;
    int         c = 0;

    while((pffllSocket = (FFLL *) FFNext(&_ffptSockets, pffllSocket)) != NULL)
    {
        TCPSocket& tcpSocket = *((TCPSocket *) (pffllSocket->_this));   // for syntax sake

        if(TCPIsEstablished(&tcpSocket._socket, NULL) && c == index)
        {
            return(tcpSocket.getRemoteEndPoint(epRemote));
        }
    }

    return(false);
}

/***	bool TCPServer::getListeningEndPoint(IPEndPoint *pListeningEP)
**
**	Synopsis:   
**      Gets the endpoint that the server is listening on.
**      This is both the IP and port the server is on.
**
**	Parameters:
**      pLocalEP  A pointer to an IPEndPoint to receive the local endpoint information.
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
bool TCPServer::getListeningEndPoint(IPEndPoint& epLocal)
{
    if(_pDEIPcK != NULL && ILIsIPSetup(_pDEIPcK->_pLLAdp, NULL))
    {
        ILGetMyIP(_pDEIPcK->_pLLAdp, &epLocal.ip);
        epLocal.port = _listeningPort;
        return(true);
    }

    return(false);
}

void TCPServer::periodicTask(void)
{
    FFLL *      pffllServer = NULL;

    // look at all of the server objects
    while((pffllServer = (FFLL *) FFNext(&_ffptPeriodTask, pffllServer)) != NULL)
    {
        FFLL *      pffllSocket = NULL;
        TCPServer&  tcpServer = *((TCPServer *) (pffllServer->_this));      // for syntax sake

        if(ILIsIPSetup(tcpServer._pDEIPcK->_pLLAdp, NULL))
        {
            while((pffllSocket = (FFLL *) FFNext(&tcpServer._ffptSockets, pffllSocket)) != NULL)
            {
                TCPSocket& tcpSocket = *((TCPSocket *) (pffllSocket->_this));   // for syntax sake

                // start listening on available sockets
                if(tcpSocket._classState == ipsNotInitialized && tcpSocket._socket.tcpState < tcpInvalid)
                {
                    // get this listening
                    if(TCPOpenWithSocket(tcpSocket._pDEIPcK->_pLLAdp, &tcpSocket._socket, tcpSocket._hPMGR, &IPListen, portListen, tcpServer._listeningPort, NULL) == &tcpSocket._socket)
                    {
                        if(tcpSocket._socket.tcpState == tcpListen)
                        {
                            tcpSocket._classState = ipsListening;
                        }
                    }
                }
            }
        }
    }
}
