/*******************************************************************************
 MRF24WG Connection algorithm functions

  Summary: Contains functions pertaining to WiFi Connection algorithms

  Description: Contains functions that connect, disconnect, get connection status,
               set reconnection mode, and convert a WPA passphrase to a binary key.
*******************************************************************************/

/* MRF24WG0M Universal Driver
*
* Copyright (c) 2012-2013, Microchip <www.microchip.com>
* Contact Microchip for the latest version.
*
* This program is free software; distributed under the terms of BSD
* license:
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


//==============================================================================
//                                  INCLUDES
//==============================================================================
#include "./ud_inc/shared/wf_universal_driver.h"
#include "./ud_inc/internal/wf_global_includes.h"

#include <stdio.h>
#include <string.h>

//==============================================================================
//                                  LOCAL DATA TYPES
//==============================================================================

/* header format for response to CA Get Element message */
typedef struct caElementResponseStruct
{
    t_mgmtMsgRxHdr    mgmtHdr;                /* normal 4-byte hdr for all mgmt responses */
    uint8_t           elementId;              /* index 4 */
    uint8_t           elementDataLength;      /* index 5 */
    /* element data follows */
} tCAElementResponseHdr;

//==============================================================================
//                                  LOCAL FUNCTION PROTOTYPES
//==============================================================================
static void LowLevel_CASetElement(uint8_t elementId,
                                  uint8_t *p_elementData,
                                  uint8_t elementDataLength);

#if 0
static void LowLevel_CAGetElement(uint8_t elementId,
                                  uint8_t *p_elementData,
                                  uint8_t elementDataLength,
                                  bool    dataReadAction);
#endif

//==============================================================================
//                                  GLOBAL FUNCTION PROTOTYPES
//==============================================================================
// did not want to create header file for one function
extern void pbkdf2_sha1(const char *passphrase, const char *ssid, uint16_t ssid_len,
                        uint16_t iterations, uint8_t *buf, uint16_t buflen);


/*******************************************************************************
  Function:
    void WF_Connect()

  Summary:
    Commands the MRF24WB0MA/B or MRF24WG0MA/B to start a connection.

  Description:
    Directs the Connection Manager to scan for and connect to a WiFi network.
    This function does not wait until the connection attempt is successful, but
    returns immediately.  See WF_ProcessEvent for events that can occur as a
    result of a connection attempt being successful or not.

    Note that if the Connection Profile being used has WPA or WPA2 security
    enabled and is using a passphrase, the connection manager will first
    calculate the PSK key, and then start the connection process.  The key
    calculation can take up to 30 seconds.

  Precondition:
    MACInit must be called first.

  Parameters:
    CpId - If this value is equal to an existing Connection Profile�s ID than
            only that Connection Profile will be used to attempt a connection to
            a WiFi network.
            If this value is set to WF_CM_CONNECT_USING_LIST then the
            connectionProfileList will be used to connect, starting with the
            first Connection Profile in the list.

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
void WF_Connect(void)
{
    uint8_t  hdrBuf[4];

#if defined(WF_ERROR_CHECKING)
    {
        uint32_t errorCode;

        errorCode = UdCheckConnectionConfig();
        if (errorCode != UD_SUCCESS)
        {
            EventEnqueue(WF_EVENT_ERROR, errorCode);
            return;
        }
    }
#endif /* WF_ERROR_CHECKING */

    /* Write out header portion of msg (which is whole msg, there is no data) */
    hdrBuf[0] = WF_MGMT_REQUEST_TYPE;    /* indicate this is a mgmt msg     */
    hdrBuf[1] = WF_CM_CONNECT_SUBYTPE;   /* mgmt request subtype            */
    hdrBuf[2] = GetCpid();
    hdrBuf[3] = 0;

    SendMgmtMsg(hdrBuf,
                sizeof(hdrBuf),
                NULL,
                0);

    /* wait for mgmt response, free after it comes in, don't need data bytes */
    WaitForMgmtResponse(WF_CM_CONNECT_SUBYTPE, FREE_MGMT_BUFFER);
}

/*******************************************************************************
  Function:
    void WF_ReconnectModeSet(uint8_t retryCount, uint8_t deauthAction, uint8_t beaconTimeout, uint8_t beaconTimeoutAction);

  Summary:
    Controls how the MRF24WG handles reconnection in the event of a beacon timeout
    or a deauthentication from the AP.

  Description:
     The host application has two basic options with respect to controlling how the
     MRF24WG handles a loss of WiFi connection.
        1) MRF24WG informs the host and automatically retries N times (or forever)
           to regain the connection
        2) MRF24WG simply informas the host application that the connection has
           been lost; it does not automatically try to regain the connection.
           Instead, it is up to the host to reestablish the connection.

  Parameters:
    retryCount    -- the number of times the MRF24WG should try to regain a connection:
                      0     -- Do not try to regain the connection (simply report event to host application)
                      1:254 -- number of times to try to regain the connection
                      255   -- Retry forever (WF_RETRY_FOREVER)

    deauthAction  -- WF_ATTEMPT_TO_RECONNECT or WF_DO_NOT_ATTEMPT_TO_RECONNECT

    beaconTimeOut -- Number of missed beacons before MRF24WG designates the
                     connection as lost:
                      0 -- MRF24WG will NOT monitor the beacon timeout condition
                            and will not indicate this condition to Host
                      1:255 -- number of missed beacons before connection declared lost

    beaconTimeoutAction -- WF_ATTEMPT_TO_RECONNECT or WF_DO_NOT_ATTEMPT_TO_RECONNECT
 
  Returns:
    None

  Remarks:
    If this function is not called, the MRF2WG default is the equivalent of:
        WF_SetReconnectMode(3, WF_ATTEMPT_TO_RECONNECT, 0, WF_DO_NOT_ATTEMPT_TO_RECONNECT);
        
    Examples of different scenarios are below.

    Example 1: MRF24WG should not do any connection retries and only report deauth events to host:
                 WF_SetReconnectMode(0, WF_DO_NOT_ATTEMPT_TO_RECONNECT, 0, WF_DO_NOT_ATTEMPT_TO_RECONNECT);

    Example 2: MRF24WG should not do any connection retries, but report deauth and beacon timeout events to host.
               Beacon timeout should be 5 beacon periods:
                 WF_SetReconnectMode(0, WF_DO_NOT_ATTEMPT_TO_RECONNECT, 5, WF_DO_NOT_ATTEMPT_TO_RECONNECT);

    Example 3: MRF24WG should ignore beacon timeouts, but attempt to reconnect 3 times if a deauth occurs:
                WF_SetReconnectMode(3, WF_ATTEMPT_TO_RECONNECT, 0, WF_DO_NOT_ATTEMPT_TO_RECONNECT);

    Example 4: MRF24WG should not do any connection retries if a deauth occcurs, but retry 3 times if a beacon
               timeout of 4 beacon periods occur:
                WF_SetReconnectMode(3, WF_DO_NOT_ATTEMPT_TO_RECONNECT, 4, WF_ATTEMPT_TO_RECONNECT);

    Example 5: MRF24WG should retry forever if either a deauth or beacon timeout occurs (beacon timeout is
               3 beacon periods):
                WF_SetReconnectMode(WF_RETRY_FOREVER, WF_ATTEMPT_TO_RECONNECT, 3, WF_ATTEMPT_TO_RECONNECT);

  *****************************************************************************/
void WF_ReconnectModeSet(uint8_t retryCount, uint8_t deauthAction, uint8_t beaconTimeout, uint8_t beaconTimeoutAction)
{
#if defined(WF_ERROR_CHECKING)
    {
        uint32_t errorCode;

        errorCode = UdSetReconnectMode(retryCount, deauthAction, beaconTimeout, beaconTimeoutAction);
        if (errorCode != UD_SUCCESS)
        {
            EventEnqueue(WF_EVENT_ERROR, errorCode);
            return;
        }
    }
#endif /* WF_ERROR_CHECKING */

    LowLevel_CASetElement(WF_CA_ELEMENT_LIST_RETRY_COUNT,       // Element ID
                          &retryCount,                          // pointer to element data
                          sizeof(retryCount));                  // number of element data bytes

    LowLevel_CASetElement(WF_CA_ELEMENT_DEAUTH_ACTION,          // Element ID
                          &deauthAction,                        // pointer to element data
                          sizeof(deauthAction));                // number of element data bytes

    LowLevel_CASetElement(WF_CA_ELEMENT_BEACON_TIMEOUT,         // Element ID
                          &beaconTimeout,                       // pointer to element data
                          sizeof(beaconTimeout));               // number of element data bytes

    LowLevel_CASetElement(WF_CA_ELEMENT_BEACON_TIMEOUT_ACTION,  // Element ID
                          &beaconTimeoutAction,                 // pointer to element data
                          sizeof(beaconTimeoutAction));         // number of element data bytes

}

/*******************************************************************************
  Function:
    UINT16 WF_Disconnect(void)

  Summary:
    Commands the MRF24WG to close any open connections and/or to cease attempting
    to connect.

  Description:
    Directs the Connection Manager to close any open connection or connection
    attempt in progress.  No further attempts to connect are taken until
    WF_Connect() is called.

  Precondition:
    

  Parameters:
    None.

  Returns:
    None

  Remarks:
    None.
  *****************************************************************************/
void WF_Disconnect(void)
{
    uint8_t  hdrBuf[2];
    uint8_t   connectionState; // not used, but required for function call

    /* WARNING !!! :
    * Disconnect is allowed only in connected state.
    * If module FW is in the midst of connection (or reconnection) process, then
    * disconnect can hammer connection process, and furthermore it may cause
    * fatal failure in module FW operation. 
    */

    // verify it is OK to issue a disconnect command
    WF_ConnectionStateGet(&connectionState);
    if ((connectionState != WF_CSTATE_CONNECTED_INFRASTRUCTURE) && (connectionState != WF_CSTATE_CONNECTED_ADHOC))
    {
        EventEnqueue(WF_EVENT_ERROR, UD_ERROR_DISCONNECT_NOT_ALLOWED);
        return;
    }

    hdrBuf[0] = WF_MGMT_REQUEST_TYPE;
    hdrBuf[1] = WF_CM_DISCONNECT_SUBYTPE;

    SendMgmtMsg(hdrBuf,
                sizeof(hdrBuf),
                NULL,
                0);

    /* wait for mgmt response, free after it comes in, don't need data bytes */
    WaitForMgmtResponse(WF_CM_DISCONNECT_SUBYTPE, FREE_MGMT_BUFFER);

    UdSetConnectionState(CS_NOT_CONNECTED);
}


/*******************************************************************************
  Function:
    void WF_ChannelListSet(uint8_t *p_channelList, uint8_t numChannels)

  Summary:
    Sets the channel list.

  Description:
    Sets the Channel List used by the Connection Algorithm.

  Precondition:
    MACInit must be called first.

  Parameters:
    p_channelList - Pointer to channel list.
    numChannels   - Number of channels in p_channelList.  If set to 0, the
                     MRF24W will use all valid channels for the current
                     regional domain.

  Returns:
    None.

  Remarks:
    None.
 *****************************************************************************/
void WF_ChannelListSet(uint8_t *p_channelList, uint8_t numChannels)
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode;

    errorCode = UdSetChannelList(p_channelList, numChannels);
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif
    
    LowLevel_CASetElement(WF_CA_ELEMENT_CHANNEL_LIST,  /* Element ID                   */
                          p_channelList,               /* pointer to element data      */
                          numChannels);                /* number of element data bytes */
}

void WF_ScanContextSet(t_scanContext *p_context)
{
    uint16_t tmp;

#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = UdSetScanContext(p_context);
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif

    LowLevel_CASetElement(WF_CA_ELEMENT_SCANTYPE,           // Element ID
                          &p_context->scanType,             // pointer to element data
                          sizeof(p_context->scanType));     // number of element data bytes

    LowLevel_CASetElement(WF_CA_ELEMENT_SCAN_COUNT,
                          &p_context->scanCount,
                          sizeof(p_context->scanCount));

    tmp = htons(p_context->minChannelTime);
    LowLevel_CASetElement(WF_CA_ELEMENT_MIN_CHANNEL_TIME,
                          (uint8_t *)&tmp,
                          sizeof(tmp));

    tmp = htons(p_context->maxChannelTime);
    LowLevel_CASetElement(WF_CA_ELEMENT_MAX_CHANNEL_TIME,
                          (uint8_t *)&tmp,
                          sizeof(tmp));

    tmp = htons(p_context->probeDelay);
    LowLevel_CASetElement(WF_CA_ELEMENT_PROBE_DELAY,
                          (uint8_t *)&tmp,
                          sizeof(tmp));
}

void WF_AdhocContextSet(t_adHocNetworkContext *p_context)
{
    uint16_t tmp;

#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = UdSetAdhocNetworkContext(p_context);
    if (errorCode != UD_SUCCESS)
    {
        return;
    }
#endif

    SetHiddenSsid(p_context->hiddenSsid);

    tmp = htons(p_context->beaconPeriod);
    LowLevel_CASetElement(WF_CA_ELEMENT_BEACON_PERIOD,  // Element ID
                          (uint8_t *)&tmp,              // pointer to element data
                          sizeof(tmp));                 // number of element data bytes

    SetAdHocMode(p_context->mode);
}

void WF_RssiSet(uint8_t rssi)
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = UdSetRssi(rssi);
    if (errorCode != UD_SUCCESS)
    {
        return;
    }
#endif
    LowLevel_CASetElement(WF_CA_ELEMENT_RSSI,   // Element ID
                          &rssi,                // pointer to element data
                          sizeof(rssi));        // number of element data bytes 
}


/*******************************************************************************
  Function:
    void WF_CheckConnectionState(UINT8 *p_state, UINT8 *p_currentCpId)

  Summary:
    Returns the current connection state.

  Description:
    Returns the current connection state.

  Parameters:
    p_state - Pointer to location where connection state will be written

  Returns:
    None.

  Remarks:
    Response msg is actually two bytes, the second byte being the Connection Profile ID.
    Since this is not being used, set msgData to a 1-byte array.  
  *****************************************************************************/
void WF_ConnectionStateGet(uint8_t *p_state)
{
    uint8_t  hdrBuf[2];
    uint8_t  msgData[1];

    hdrBuf[0] = WF_MGMT_REQUEST_TYPE;
    hdrBuf[1] = WF_CM_GET_CONNECTION_STATUS_SUBYTPE;

    SendMgmtMsg(hdrBuf,
                sizeof(hdrBuf),
                NULL,
                0);

    // wait for mgmt response, read data, free after read
    WaitForMgmtResponseAndReadData(WF_CM_GET_CONNECTION_STATUS_SUBYTPE,
                                   sizeof(msgData),                  // num data bytes to read          
                                   MGMT_RESP_1ST_DATA_BYTE_INDEX,    // only used if num data bytes > 0
                                   msgData);                         // only used if num data bytes > 0

    *p_state = msgData[0]; // connection state
}



#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
/*******************************************************************************
  Function:
    void WF_WpaConvPassphraseToKey(t_wpaKeyInfo *p_wpaPhrase)

  Summary:
    Converts the input WPA/WPA2 passphrase to a 32-byte binary key

  Description:
    None

  Parameters:
    p_keyInfo -- structure containing the ASCII WPA passphrase

  Returns:
    When this function completes the input structure field p_keyInfo->key[] will
    have been overwritten with the 32-byte binary key.  In addtion, the input
    structure field p_keyInfo->keyLength will be set to 32.

  Remarks:
    Called needs to be aware that two of the input fields will be overwritten
    with the result of the conversion.
  *****************************************************************************/
void WF_WpaConvPassphraseToKey(t_wpaKeyInfo *p_keyInfo)
{
    uint8_t binaryKey[WF_WPA_KEY_LENGTH];
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = UdConvWpaPassphrase(p_keyInfo);
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif
    p_keyInfo->key[p_keyInfo->keyLength] = '\0';   // make sure passphrase is terminated

    // generate the binary key
    pbkdf2_sha1((const char *)p_keyInfo->key,
                (const char *)p_keyInfo->ssid,
                p_keyInfo->ssidLen,
                4096,
                binaryKey, // binary key will be written to this field
                32);

    // overwrite the passphrase with binary key
    memcpy(p_keyInfo->key, binaryKey, WF_WPA_KEY_LENGTH);

    // overwrite the length with the length of the binary key (always 32)
    p_keyInfo->keyLength = WF_WPA_KEY_LENGTH;
}



#endif /* WF_USE_HOST_WPA_KEY_CALCULATION */

void SetListenInterval(uint16_t listenInterval)
{

    /* correct endianness before sending message */
    listenInterval = htons(listenInterval);
    LowLevel_CASetElement(WF_CA_ELEMENT_LISTEN_INTERVAL,    /* Element ID                   */
                         (uint8_t *)&listenInterval,        /* pointer to element data      */
                          sizeof(listenInterval));          /* number of element data bytes */
}

void SetDtimInterval(uint16_t dtimInterval)
{
    /* correct endianness before sending message */
    dtimInterval = htons(dtimInterval);

    LowLevel_CASetElement(WF_CA_ELEMENT_DTIM_INTERVAL,    /* Element ID                   */
                          (uint8_t *)&dtimInterval,       /* pointer to element data      */
                          sizeof(dtimInterval));          /* number of element data bytes */
}


/*******************************************************************************
  Function:
    static void LowLevel_CASetElement(uint8_t elementId,
                                      uint8_t *p_elementData,
                                      uint8_t elementDataLength)

  Summary:
    Set an element of the connection algorithm on the MRF24W.

  Description:
    Low-level function to send the appropriate management message to the
    MRF24W to set the Connection Algorithm element.

  Precondition:
    MACInit must be called first.

  Parameters:
    elementId - Element that is being set
    p_elementData - Pointer to element data
    elementDataLength - Number of bytes pointed to by p_elementData

  Returns:
    None.

  Remarks:
    All Connection Algorithm 'Set Element' functions call this function
    to construct the management message.  The caller must fix up any endian
    issues prior to calling this function.
 *****************************************************************************/
static void LowLevel_CASetElement(uint8_t elementId,
                                  uint8_t *p_elementData,
                                  uint8_t elementDataLength)
{
    uint8_t  hdrBuf[4];

    hdrBuf[0] = WF_MGMT_REQUEST_TYPE;           /* indicate this is a mgmt msg     */
    hdrBuf[1] = WF_CA_SET_ELEMENT_SUBTYPE;      /* mgmt request subtype            */
    hdrBuf[2] = elementId;                      /* Element ID                      */
    hdrBuf[3] = elementDataLength;              /* number of bytes of element data */

    SendMgmtMsg(hdrBuf,
                sizeof(hdrBuf),
                p_elementData,
                elementDataLength);

    /* wait for mgmt response, free after it comes in, don't need data bytes */
    WaitForMgmtResponse(WF_CA_SET_ELEMENT_SUBTYPE, FREE_MGMT_BUFFER);
}

#if 0
/*******************************************************************************
  Function:
    static void LowLevel_CAGetElement(uint8_t elementId,
                                      uint8_t *p_elementData,
                                      uint8_t elementDataLength,
                                      uint8_t dataReadAction)

  Summary:
    Get an element of the connection algorithm on the MRF24W.

  Description:
    Low-level function to send the appropriate management message to the
    MRF24W to get the Connection Algorithm element.

  Precondition:
    MACInit must be called first.

  Parameters:
    elementId - Element that is being read
    p_elementData - Pointer to where element data will be written
    elementDataLength - Number of element data bytes that will be read
    dataReadAction - If TRUE then read data per paramters and free mgmt response buffer.
                      If FALSE then return after response received, do not read any data as the
                      caller will do that, and don't free buffer, as caller will do that as well.

  Returns:
    None.

  Remarks:
    All Connection Algorithm 'Get Element' functions call this function to
    construct the management message.  The caller must fix up any endian issues
    after getting the data from this function.
 *****************************************************************************/
static void LowLevel_CAGetElement(uint8_t elementId,
                                  uint8_t *p_elementData,
                                  uint8_t elementDataLength,
                                  bool    dataReadAction)
{
    uint8_t  hdrBuf[4];

    hdrBuf[0] = WF_MGMT_REQUEST_TYPE;       /* indicate this is a mgmt msg     */
    hdrBuf[1] = WF_CA_GET_ELEMENT_SUBTYPE;  /* mgmt request subtype            */
    hdrBuf[2] = elementId;                  /* Element ID                      */
    hdrBuf[3] = 0;                          /* not used                        */

    SendMgmtMsg(hdrBuf,
                sizeof(hdrBuf),
                NULL,
                0);

    if (dataReadAction == true)
    {
        /* wait for mgmt response, read desired data, and then free response buffer */
        WaitForMgmtResponseAndReadData(WF_CA_GET_ELEMENT_SUBTYPE,
                                       elementDataLength,                   /* num data bytes to read                */
                                       sizeof(tCAElementResponseHdr),       /* index of first byte of element data   */
                                       p_elementData);                      /* where to write element data           */
    }
    else
    {
        /* wait for mgmt response, don't read any data bytes, do not release mgmt buffer */
        WaitForMgmtResponse(WF_CA_GET_ELEMENT_SUBTYPE, DO_NOT_FREE_MGMT_BUFFER);
    }
}
#endif

