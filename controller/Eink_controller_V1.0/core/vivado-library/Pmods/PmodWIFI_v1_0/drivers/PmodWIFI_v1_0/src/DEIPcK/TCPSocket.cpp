/************************************************************************/
/*                                                                      */
/*  TCPSocket.cpp   The C++ wrapper class for the deIP TCP socket class */
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
/*      Implements the TCPSocket Class                                  */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*      11/20/2011(KeithV): Created                                     */
/*                                                                      */
/************************************************************************/
#include "DEIPcK.h"

/***	TCPSocket Constructors
**
**  Notes:
**      
**      Just initializes an empty, not connected TCPSocket instance
**
*/
TCPSocket::TCPSocket()
{
    clear(true);
}
void TCPSocket::clear(bool fConstruct)
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
        memset(&_socket, 0, sizeof(TCPSOCKET));     // we are closing nicely, keep the socket until it closes

        // unfortunately, we can't control when constructors are run, so we don't know if hNetworkPMGR has been initialized yet
        // don't mess with this on a close, because once set, we can continue to use it
        _hPMGR = NULL;
    }
}

bool TCPSocket::setSocketMem(HPMGR hPMGR)
{
    if(_classState == ipsNotInitialized)
    {
        _hPMGR = hPMGR;
        return(true);
    }
    return(false);
}

/***	TCPSocket Destructor
**
**  Notes:
**      
**      Terminates the instance, releasing all resources
**
*/
TCPSocket::~TCPSocket()
{
    close();
}

/***	void TCPSocket::close(void)
**
**	Synopsis:   
**      Closes the socket and clears the TCPSocket instance;
**      Returns the instance to a just constructed state releasing
**      all resources.
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
**      Returns the TCPSocket instance to
**      a state just as if the instance had just been
**      constructed. It also, Close the connection if
**      if it is still active.
**
*/
void TCPSocket::close(void)
{
    if(_classState != ipsNotInitialized)
    {
        // clean out the buffer
        TCPDiscard(&_socket);

        // release the resources back to stack
        TCPClose(&_socket, NULL);
    }

    // reset our member variables
    clear(false);
 }

/***	void TCPSocket::discardReadBuffer(void)
**
**	Synopsis:   
**      Empties (flushes) the input (read) buffer.
**      All bytes are discarded.
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
**      This call is safe to make without checking the connection status.
**
*/
void TCPSocket::discardReadBuffer(void)
{
    TCPDiscard(&_socket);
}

/***	int TCPSocket::available(void)
**
**	Synopsis:   
**      Returns the number of bytes available for reading.
**
**	Parameters:
**      None
**
**	Return Values:
**      The actual number of bytes available in the socket ready for reading, 0 if none or the connection is lost.
**
**	Errors:
**      None
**
**  Notes:
**
**      This call is safe to make without checking the connection status.
**
*/
size_t TCPSocket::available(void)
{
    return(TCPAvailable(&_socket, NULL));
}

/***	int TCPSocket::peekByte(void)
**      int TCPSocket::peekByte(size_t index)
**
**	Synopsis:   
**      Gets the indicated byte from the socket buffer without removing the byte from the socket.
**
**	Parameters:
**      index   Zero based index of the byte withing the socket to return, should be less than what Available returns
**
**      pStatus A pointer to receive the status of the call, usually the connection status, or an index out of bounds error.
**
**	Return Values:
**      The actual byte, casted to an integer. -1 is returned if no byte was returned or an error occured.
**
**	Errors:
**      Index out of bounds, or a connection error.
**
**  Notes:
**
**      This call is safe to make without checking the connection status.
**
*/
int TCPSocket::peekByte(void)
{
    return(peekByte(0));
}
int TCPSocket::peekByte(size_t index)
{
    int32_t    value = 0;

    if(((((int32_t) available()) - ((int32_t) index)) > 0) && (TCPPeekIdx(&_socket, index, &value, 1, NULL) == 1))
    {
        return(value);
    }

     return(-1);
}

/***	int TCPSocket::peekStream(byte *rgbPeek, size_t cbPeekMax, size_t index)
**      int TCPSocket::peekStream(byte *rgbPeek, size_t cbPeekMax)
**
**	Synopsis:   
**      Gets an array of bytes from the socket buffer without removing the bytes from the socket.
**
**	Parameters:
**      rgbPeek     A pointer to a buffer to receive the bytes.
**
**      cbPeekMax   The maximum size of rgbPeek
**
**      index       Zero based index of where in the socket buffer to start copying bytes from.
**
**      pStatus A pointer to receive the status of the call, usually the connection status, or an index out of bounds error.
**
**	Return Values:
**      The actual number of bytes coped. 0 is returned if no bytes were copied or an error occured.
**
**	Errors:
**      Index out of bounds, or a connection error.
**
**  Notes:
**
**      This call is safe to make without checking the connection status.
**
*/
size_t TCPSocket::peekStream(byte *rgbPeek, size_t cbPeekMax)
{
    return(peekStream(rgbPeek, cbPeekMax, 0));
}
size_t TCPSocket::peekStream(byte *rgbPeek, size_t cbPeekMax, size_t index)
{
    int32_t cbReady = (((int32_t) available()) - ((int32_t) index));

    if(cbReady > 0 )
    {
        cbReady = cbReady < (int32_t) cbPeekMax ? cbReady : cbPeekMax;
        return(TCPPeekIdx(&_socket, index, rgbPeek, cbReady, NULL));
    }

    return(0);
}

/***	int TCPSocket::readByte(void)
**
**	Synopsis:   
**      Reads the next available byte out of the socket buffer (removing the byte from the socket)
**
**	Parameters:
**
**      pStatus A pointer to receive the status of the call, usually the connection status.
**
**	Return Values:
**      The actual byte, casted to an integer. -1 is returned if no byte was returned or an error occured.
**
**	Errors:
**      Nothing to read, or a connection error.
**
**  Notes:
**
**      This call is safe to make without checking the connection status.
**
*/
int TCPSocket::readByte(void)
{
    byte bData = 0;

    // this will run the stack tasks
    if(available() > 0  && TCPRead(&_socket, &bData, 1, NULL) )
    {
        return((int) bData);
    }

    return(-1);
}

/***	int TCPSocket::readStream(byte *rgbRead, size_t cbReadMax)
**
**	Synopsis:   
**      Reads an array of bytes from the socket buffer (and removes the bytes from the socket)
**
**	Parameters:
**      rgbRead     A pointer to a buffer to receive the bytes.
**
**      cbReadMax   The maximum size of rgbPeek
**
**      pStatus A pointer to receive the status of the call, usually the connection status.
**
**	Return Values:
**      The actual number of bytes read. 0 is returned if no bytes were read or an error occured.
**
**	Errors:
**      No bytes to read, or a connection error.
**
**  Notes:
**
**      This call is safe to make without checking the connection status.
**
*/
size_t TCPSocket::readStream(byte *rgbRead, size_t cbReadMax)
{
    size_t cbReady = 0;

    if( (cbReady = available()) > 0 )
    {
        cbReady = cbReady < cbReadMax ? cbReady : cbReadMax;
        return(TCPRead(&_socket, rgbRead, cbReady, NULL));
    }

    return(0);
}

/***	int TCPSocket::writeByte(byte bData)
**      int TCPSocket::writeByte(byte bData, DEIPcK::STATUS * pStatus)
**
**	Synopsis:   
**      Write a byte out on the TcpIP connection
**
**	Parameters:
**      bData     the byte to write out.
**
**      pStatus A pointer to receive the status of the call, usually the connection status.
**
**	Return Values:
**      1 if the byte was written. 0 is returned if no bytes were written or an error occured.
**
**	Errors:
**      connection status.
**
**  Notes:
**
**      This call is safe to make without checking the connection status.
**
**      This is a very costly call to make as the byte is flushed out on to the wire.
**      No caching of intermediate written bytes are done because it is impossible to know if
**      the caller only wants to write 1 byte, or has a sequence to write. If more than 1 byte
**      is to be put on the wire in one packet, Write should be used.
**
*/
int TCPSocket::writeByte(byte bData)
{
    return((int) writeStream(&bData, 1, NULL));
}                      
int TCPSocket::writeByte(byte bData, IPSTATUS * pStatus)
{
    return((int) writeStream(&bData, 1, pStatus));
}

/***	int TCPSocket::writeStream(const byte *rgbWrite, size_t cbWrite)
**      int TCPSocket::writeStream(const byte *rgbWrite, size_t cbWrite, DEIPcK::STATUS * pStatus)
**
**
**	Synopsis:   
**      Write an array of bytes out on the TcpIP connection
**
**	Parameters:
**      rgbWrite     A pointer to an array of bytes to write out.
**
**      cbWrite     The number of bytes to write out.
**
**      msBlockMax  The maximum amount of time that should be spent attempting to write out the buffer.
**                      Typically this parameter is not needed and the default value can be used.
**                      However, if writing a buffer larger than the internal TcpIP socket buffer,
**                      multiple writes will be used to write the whole buffer out and this could take
**                      some time depending on the speed of the network and the size of the array.
**                      If the timeout occurs before all of the bytes are written, the number of bytes
**                      actually written will be returned to the caller and Write will have to be
**                      called again to write out the un-written bytes.
**
**      pStatus     A pointer to receive the status of the call, usually the connection status.
**
**	Return Values:
**      The number of bytes actually written. 0 is returned if no bytes were written or an error occured.
**
**	Errors:
**      connection status or a write timeout.
**
**  Notes:
**
**      This call is safe to make without checking the connection status.
**
**      Each write will flush the array as a whole to the network.
**      Multiple write may occur if the array is larger than the socket buffer.
**
*/
size_t TCPSocket::writeStream(const byte *rgbWrite, size_t cbWrite)
{
    return(writeStream(rgbWrite, cbWrite, NULL));
}                      
size_t TCPSocket::writeStream(const byte *rgbWrite, size_t cbWrite, IPSTATUS * pStatus)
{
    // make sure we are Connected
    // this will also run the stack
    if(TCPIsEstablished(&_socket, pStatus))
    {
        return(TCPWrite(&_socket, rgbWrite, cbWrite, pStatus));
    }

    return(0);
}

/***	bool TCPSocket::getRemoteMAC(MAC *pRemoteMAC)
**
**	Synopsis:   
**      Gets the MAC address of the remote endpoint
**
**	Parameters:
**      pRemoteMAC  A pointer to a MAC to receive the remote MAC address
**
**	Return Values:
**      true    The remote MAC was returned.
**      false   The remote MAC is not known, usually because the connection was not set up yet.
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
bool TCPSocket::getRemoteMAC(MACADDR& remoteMAC)
{
    if(!TCPIsConnected(&_socket, NULL))
    {
        return(false);
    }

    SKTGetRemoteMAC(&_socket, &remoteMAC);
    return((memcmp(&remoteMAC, &MACNONE, sizeof(MACADDR)) != 0));
}

/***	bool TCPSocket::getRemoteEndPoint(IPEndPoint *pRemoteEP)
**
**	Synopsis:   
**      Gets the endpoint for the remote connection
**
**	Parameters:
**      pRemoteEP  A pointer to an IPEndPoint to receive the remote endpoint information.
**
**	Return Values:
**      true    The remote endpoint was returned.
**      false   The remote endpoint is not known, usually because the connection was not set up yet.
**
**	Errors:
**      None
**
**  Notes:
**
**      If false is returned, then *pRemoteEP will be garbage.
**
**      If true it will be the remote endpoint information even for machines not on the local area network.
**
*/
bool TCPSocket::getRemoteEndPoint(IPEndPoint& epRemote)
{
    if(!TCPIsConnected(&_socket, NULL))
    {
        return(false);
    }
    SKTGetRemoteIPv4(&_socket, &epRemote.ip);
    epRemote.port = SKTGetRemotePort(&_socket);

    return(true);
}

/***	bool TCPSocket::getLocalEndPoint(IPEndPoint *pLocalEP)
**
**	Synopsis:   
**      Gets the endpoint for this connection. It will be the local machines IP address
**      and the port by this machine to talk to the remote machine.
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
bool TCPSocket::getLocalEndPoint(IPEndPoint& epLocal)
{
    if(!TCPIsConnected(&_socket, NULL))
    {
        return(false);
    }
    ILGetMyIP(_socket.s.pLLAdp, &epLocal.ip);
    epLocal.port = SKTGetLocalPort(&_socket);

    return(true);
}


