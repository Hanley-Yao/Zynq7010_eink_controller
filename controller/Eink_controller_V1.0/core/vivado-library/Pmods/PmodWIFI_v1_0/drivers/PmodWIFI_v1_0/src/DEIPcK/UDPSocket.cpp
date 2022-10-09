 /************************************************************************/
/*                                                                      */
/*  UDPSocket.cpp   The C++ wrapper class for the deIP UDP socket class */
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
/*      This implements the UDPSocket Class                             */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*      11/20/2011(KeithV): Created                                     */
/*                                                                      */
/************************************************************************/
#include "DEIPcK.h"

/***	UDPSocket Constructors
**
**  Notes:
**      
**      This is made private so the user must supply a datagram cache buffer
**
*/
UDPSocket::UDPSocket()
{
    clear(true);
}
void UDPSocket::clear(bool fConstruct)
{
    _classState = ipsNotInitialized;
    _pDEIPcK = NULL;
    _localPort = portUnassigned;
    memset(&_epRemote, 0, sizeof(IPEndPoint));

    // do not screw with any link lists out there
    if(fConstruct)
    {
        _ffptInfo._pNext = NULL;
        _ffptInfo._this = this;
        memset(&_socket, 0, sizeof(UDPSOCKET));     // we are closing nicely, keep the socket until it closes

        // unfortunately, we can't control when constructors are run, so we don't know if hNetworkPMGR has been initialized yet
        // don't mess with this on a close, because once set, we can continue to use it
        _hPMGR = NULL;
    }
}

bool UDPSocket::setSocketMem(HPMGR hPMGR)
{
    if(_classState == ipsNotInitialized)
    {
        _hPMGR = hPMGR;
        return(true);
    }
    return(false);
}

/***	UDPSocket Destructor
**
**  Notes:
**      
**      Terminates the UDPSocket and free all resources (socket).
**      The user supplied datagram cache is no longer needed.
**
*/
UDPSocket::~UDPSocket()
{
    close();
}

/***	void UDPSocket::close(void)
**
**	Synopsis:   
**      Closes the socket and clears the UDPSocket instance;
**      Returns the instance to a just constructed state releasing
**      all resources except the user supplied datagram cache buffer
**      which will be reused if SetEndPoint is called again.
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
**      Returns the UDPSocket instance to
**      a state just as if the instance had just been
**      constructed. The user supplied datagram cache
**      should still be kept valid.
**
*/
void UDPSocket::close(void)
{
    if(_classState != ipsNotInitialized)
    {
        // UDPDiscard only takes the most recent datagram away
        // we want to clear all datagrams
        while(UDPAvailable(&_socket))
        {
            // clean out the buffer
            UDPDiscard(&_socket);
        }

        // release the resources back to stack
        UDPClose(&_socket);
    }

    // reset our member variables
    clear(false);
 }

/***	void UDPSocket::discardDatagram(void)
**
**	Synopsis:   
**      Throws out the next datagram (if any) in the
**      datagram cache.
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
**
*/
void UDPSocket::discardDatagram(void)
{
    // proabaly do not want to call periodictasks or run the stack
    // kind of want to keep things static if someone is flushing
    // however, if Avaiable is called, periodicTasks will be called.
    UDPDiscard(&_socket);
}

/***	int UDPSocket::available(void)
**
**	Synopsis:   
**      Returns the number of bytes in the next available datagram
**
**	Parameters:
**      None
**
**	Return Values:
**      The actual number of bytes available in the datagram ready for reading, 0 if no datagrams are in the cache
**
**	Errors:
**      None
**
**  Notes:
**
**      If you read a partial datagram on a previous ReadDatagram, this call will return the
**      number of unread bytes in the remaining datagram. If other datagrams are in the cache, they
**      will not be visible until the previous datagram is read and removed from the cache.
**
*/
size_t UDPSocket::available(void)
{
    return((unsigned int) UDPAvailable(&_socket));
}

/***	int UDPSocket::PeekByte(void)
**      int UDPSocket::peekByte(size_t index)
**
**	Synopsis:   
**      Gets the indicated byte from the datagram without removing the byte from the datagram.
**
**	Parameters:
**      index   Zero based index of the byte within the datagram to return, should be less than what Available returns
**
**
**	Return Values:
**      The actual byte, casted to an integer. -1 is returned if no byte was returned or an error occured.
**
**	Errors:
**
**  Notes:
**
*/
int UDPSocket::peekByte(void)
{
    return(peekByte(0));
}
int UDPSocket::peekByte(size_t index)
{
    byte rgb[1];

    if(peekDatagram(rgb, sizeof(rgb), index) == 1)
    {
        return((int) ((unsigned int) rgb[0]));
    }
    else
    {
        return(-1);
    }
}

/***	int UDPSocket::peekDatagram(byte *rgbPeek, size_t cbPeekMax)
**      int UDPSocket::peekDatagram(byte *rgbPeek, size_t cbPeekMax, size_t index)
**
**	Synopsis:   
**      Gets an array of bytes from the datagram without removing the bytes from the datagram.
**
**	Parameters:
**      rgbPeek     A pointer to a buffer to receive the bytes.
**
**      cbPeekMax   The maximum size of rgbPeek
**
**      index       Zero based index of where in the datagram to start copying bytes from.
**
**	Return Values:
**      The actual number of bytes coped. 0 is returned if no bytes were copied or an error occured.
**
**	Errors:
**      Index out of bounds, or no bytes available, this is specified by a return of 0.
**
**  Notes:
**
**
*/
size_t UDPSocket::peekDatagram(byte *rgbPeek, size_t cbPeekMax)
{
    return(peekDatagram(rgbPeek, cbPeekMax, 0));
}
size_t UDPSocket::peekDatagram(byte *rgbPeek, size_t cbPeekMax, size_t index)
{
    return(UDPPeekIdx(&_socket, index, rgbPeek, cbPeekMax, NULL));
}

/***	int UDPSocket::readDatagram(byte *rgbRead, size_t cbReadMax)
**
**	Synopsis:   
**      Reads an array of bytes from the datagram (and removes the bytes from the datagram)
**
**	Parameters:
**      rgbRead     A pointer to a buffer to receive the bytes.
**
**      cbReadMax   The maximum size of rgbPeek
**
**	Return Values:
**      The actual number of bytes read. 0 is returned if no bytes were read.
**
**	Errors:
**      No bytes to read.
**
**  Notes:
**
*/
size_t UDPSocket::readDatagram(byte *rgbRead, size_t cbReadMax)
{
    // read the bytes from the cache
    // you must specify an iIndex of 0! Otherwise the I can't remove the bytes
    return(UDPRead(&_socket, rgbRead, cbReadMax, NULL));
}

/***	int UDPSocket::writeDatagram(const byte *rgbWrite, size_t cbWrite)
**
**
**	Synopsis:   
**      Writes the buffer out as a datagram and sends it to the instances remote endpoint
**
**	Parameters:
**      rgbWrite     A pointer to an array of bytes that composes the datagram
**
**      cbWrite     The number of bytes in the datagram.
**
**	Return Values:
**      The number of bytes actually written. 0 is returned if no bytes were written or an error occured.
**
**	Errors:
**
**  Notes:
**
**      Because Udp is a datagram protocol, this always transmits the buffer immediately
**      as a complete datagram.
**
*/
long int UDPSocket::writeDatagram(const byte *rgbWrite, size_t cbWrite)
{
    return(UDPSend(&_socket, rgbWrite, cbWrite, NULL));
}

/***	bool UDPSocket::getRemoteEndPoint(IPEndPoint *pRemoteEP)
**
**	Synopsis:   
**      Gets the remote endpoint as resolved
**
**	Parameters:
**      pRemoteEP  A pointer to an IPEndPoint to receive the remote endpoint information.
**
**	Return Values:
**      true    The remote endpoint was returned.
**      false   The remote endpoint is not known, usually because resolution failed
**
**	Errors:
**      None
**
**  Notes:
**
**      If false is returned, then *pRemoteEP will be garbage.
**
*/
bool UDPSocket::getRemoteEndPoint(IPEndPoint& epRemote)
{
    SKTGetRemoteIPv4(&_socket, &epRemote.ip);
    epRemote.port = SKTGetRemotePort(&_socket);
    return(true);
}

/***	bool UDPSocket::getLocalEndPoint(IPEndPoint *pLocalEP)
**
**	Synopsis:   
**      Gets the endpoint for this socket. It will be the local machines IP address
**      and the port that this machine will use to talk to the remote machine.
**
**	Parameters:
**      pLocalEP  A pointer to an IPEndPoint to receive the local endpoint information.
**
**	Return Values:
**      true    The local endpoint was returned.
**      false   The local endpoint is not known, usually because the endpoint was not set up yet.
**
**	Errors:
**      None
**
**  Notes:
**
**      If false is returned, then *pLocalEP will be garbage.
**
*/
bool UDPSocket::getLocalEndPoint(IPEndPoint& epLocal)
{
    ILGetMyIP(_socket.s.pLLAdp, &epLocal.ip);
    epLocal.port = SKTGetLocalPort(&_socket);
    return(true);
}

/***	bool UDPSocket::getRemoteMAC(MACADDR *pRemoteMAC)
**
**	Synopsis:   
**      Gets the MAC address of the remote endpoint
**
**	Parameters:
**      pRemoteMAC  A pointer to a MAC to receive the remote MAC address
**
**	Return Values:
**      true    The remote MAC was returned.
**      false   The remote MAC is not known, usually because resolution failed
**
**	Errors:
**      None
**
**  Notes:
**
**      If false is returned, then *pRemoteMAC will be garbage.
**
**      This is the MAC address as returned by ARP, it will be the actual MAC address
**      for any machine on the local area netowrk, but will typically be the MAC address
**      of your router if the remote connection is not local to your network.
**
*/
bool UDPSocket::getRemoteMAC(MACADDR& remoteMAC)
{
    SKTGetRemoteMAC(&_socket, &remoteMAC);
    return((memcmp(&remoteMAC, &MACNONE, sizeof(MACADDR)) != 0));
}


