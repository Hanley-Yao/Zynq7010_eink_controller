/*******************************************************************************
 MRF24WG Connection profile functions

  Summary: Contains functions pertaining to WiFi connection profile

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
#include <stdio.h>
#include "./ud_inc/shared/wf_universal_driver.h"
#include "./ud_inc/internal/wf_global_includes.h"

//==============================================================================
//                                  CONSTANTS
//==============================================================================

/*-------------------------------------------------------------*/
/* Connection Profile Element ID?s                             */
/* Used in conjunction with the WF_CP_SET_ELEMENT_SUBTYPE and  */
/* WF_CP_GET_ELEMENT_SUBTYPE message subtypes                  */
/*-------------------------------------------------------------*/
typedef enum tCPElementIds
{
    WF_CP_ELEMENT_ALL               = 0,  /* sends all elements in CP struct (not used)*/
    WF_CP_ELEMENT_SSID              = 1,
    WF_CP_ELEMENT_BSSID             = 2,
    WF_CP_ELEMENT_SECURITY          = 3,
    WF_CP_ELEMENT_NETWORK_TYPE      = 4,
    WF_CP_ELEMENT_ADHOC_BEHAVIOR    = 5,
    WF_CP_ELEMENT_WEP_KEY_INDEX     = 6,
    WF_CP_ELEMENT_SSID_TYPE         = 7,
    WF_CP_ELEMENT_WEPKEY_TYPE       = 8,
    WF_CP_ELEMENT_UPDATE_PMK        = 9,
    WF_CP_ELEMENT_READ_WPS_CRED     = 10
} tCPElementIds;

//==============================================================================
//                                  LOCAL DATA TYPES
//==============================================================================
/* header format for response to CP Get Element message */
typedef struct cpElementResponseStruct
{
    t_mgmtMsgRxHdr   mgmtHdr;                /* normal 4-byte hdr for all mgmt responses */
    uint8_t          profileId;
    uint8_t          elementId;
    uint8_t          elementDataLength;
    /* element data follows */
} t_cPElementResponseHdr;

//==============================================================================
//                                  LOCAL FUNCTION PROTOTYPES
//==============================================================================
static void LowLevel_CPSetElement(uint8_t elementId,
                                  uint8_t *p_elementData,
                                  uint8_t elementDataLength);

static void LowLevel_CPGetElement(uint8_t elementId,
                                  uint8_t *p_elementData,
                                  uint8_t elementDataLength,
                                  bool    dataReadAction);

static void WF_SetSecurity(uint8_t securityType,
                           uint8_t wepKeyIndex,
                           uint8_t *p_securityKey,
                           uint8_t securityKeyLength);

//==============================================================================
//                                  LOCAL GLOBALS
//==============================================================================
static uint8_t g_cpid;

#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
static t_wpaKeyInfo *g_p_wpaKeyInfo ;
#endif




INLINE uint8_t GetCpid(void)
{
    return g_cpid;
}

/*******************************************************************************
  Function:
    void WF_CPCreate(uint8_t *p_CpId)

  Summary:
    Creates a Connection Profile on the MRF24W.

  Description:
    Requests the MRF24W to create a Connection Profile (CP), assign it an ID,
    and set all the elements to default values.  The ID returned by this function
    is used in other connection profile functions.  A maximum of 2 Connection
    Profiles can exist on the MRF24W.

  Precondition:
    MACInit must be called first.

  Parameters:
    p_CpId - Pointer to where Connection Profile ID will be written.  If
              function fails, the CP ID will be set to 0xff.

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
void WF_CPCreate(void)
{
    uint8_t  hdr[2];

    g_cpid = 0xff; 

    hdr[0] = WF_MGMT_REQUEST_TYPE;
    hdr[1] = WF_CP_CREATE_PROFILE_SUBTYPE;

    SendMgmtMsg(hdr,
                sizeof(hdr),
                NULL,            /* no data */
                0);              /* no data */

    /* wait for MRF24W management response, read data, free response after read */
    WaitForMgmtResponseAndReadData(WF_CP_CREATE_PROFILE_SUBTYPE,
                                   1,                             /* num data bytes to read          */
                                   MGMT_RESP_1ST_DATA_BYTE_INDEX, /* read starting at index 4        */
                                   &g_cpid);                      /* write data here                 */
}

/*******************************************************************************
  Function:
    void WF_SsidSet(uint8_t *p_ssid, uint8_t *p_ssidLength)

  Summary:
    Sets the SSID for the specified Connection Profile ID.

  Description:
    Sets the SSID and SSID Length elements in the Connection Profile.  Note that
    an Access Point can have either a visible or hidden SSID.  If an Access Point
    uses a hidden SSID then an active scan must be used (see scanType field in the
    Connection Algorithm).

  Precondition:
    MACInit must be called first.

  Parameters:
    p_ssid - Pointer to the SSID string
    ssidLength - Number of bytes in the SSID

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
void WF_SsidSet(uint8_t *p_ssid,  uint8_t ssidLength)
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = UdSetSsid(p_ssid, ssidLength);
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif
    LowLevel_CPSetElement(WF_CP_ELEMENT_SSID,   /* Element ID                   */
                          p_ssid,               /* pointer to element data      */
                          ssidLength);          /* number of element data bytes */
}

/*******************************************************************************
  Function:
    void WF_SsidGet(uint8_t *p_ssid, uint8_t *p_ssidLength)

  Summary:
    Gets the SSID for the specified Connection Profile ID.

  Description:
    Gets the SSID and SSID Length elements in the Connection Profile.

  Precondition:
    None

  Parameters:
    p_ssid - Pointer to the SSID string
    ssidLength - Pumber of bytes in the SSID

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
void WF_SsidGet(uint8_t *p_ssid, uint8_t *p_ssidLength)
{
    t_cPElementResponseHdr  mgmtHdr;

    /* Request SSID, but don't have this function read data or free response buffer.       */
    LowLevel_CPGetElement( WF_CP_ELEMENT_SSID,    /* Element ID                            */
                          NULL,                   /* ptr to element data (not used here    */
                          0,                      /* num data bytes to read (not used here */
                          false);                 /* no read, leave response mounted       */

    /* At this point, management response is mounted and ready to be read.                 */
    /* Set raw index to 0, read normal 4 byte header plus the next 3 bytes, these will be: */
    /*   profile id             [4]                                                        */
    /*   element id             [5]                                                        */
    /*   element data length    [6]                                                        */
    RawRead(RAW_MGMT_RX_ID, 0, sizeof(t_cPElementResponseHdr), (uint8_t *)&mgmtHdr);

    /* extract SSID length and write to caller */
    *p_ssidLength = mgmtHdr.elementDataLength;

    /* copy SSID name to callers buffer */
    RawRead(RAW_MGMT_RX_ID, sizeof(t_cPElementResponseHdr), *p_ssidLength, p_ssid);

    /* free management buffer */
    DeallocateMgmtRxBuffer();
}

/*******************************************************************************
  Function:
    void WF_NetworkTypeSet(uint8_t networkType)

  Summary:
    Sets the network for the specified Connection Profile ID.

  Description:
    Sets the Network Type element a Connection Profile.  Allowable values are:
    * WF_NETWORK_TYPE_INFRASTRUCTURE
    * WF_NETWORK_TYPE_ADHOC

  Precondition:

  Parameters:
    networkType - Type of network to create (infrastructure or adhoc)

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
void WF_NetworkTypeSet(uint8_t networkType)
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode;

    errorCode = UdSetNetworkType(networkType);
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif

    LowLevel_CPSetElement(WF_CP_ELEMENT_NETWORK_TYPE,   /* Element ID                   */
                          &networkType,                 /* pointer to element data      */
                          1);                           /* number of element data bytes */
}

/*******************************************************************************
  Function:
    WF_SsidTypeSet(bool hidden)

  Summary:
    Sets the SSID type

  Description:
    Sets the SSID type element in the Connection Profile.
    ***** This is valid only when we create AdHoc network.

  Precondition:
    MACInit must be called first.

  Parameters:
    CpId -- Connection Profile ID
    hidden -- True or False

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
void WF_SsidTypeSet(bool hidden)
{
    LowLevel_CPSetElement(WF_CP_ELEMENT_SSID_TYPE,  /* Element ID                   */
                          (uint8_t *)&hidden,       /* pointer to element data      */
                          1);                       /* number of element data bytes */

}


void WF_SecurityOpenSet()
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = UdSetSecurityOpen();
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif
    
    WF_SetSecurity(WF_SECURITY_OPEN, 0, NULL, 0);
}

//============================================================================
void WF_SecurityWepSet(t_wepContext* p_context)
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode;

    errorCode = UdSetSecurityWep(p_context);
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif /* WF_ERROR_CHECKING */

    WF_SetSecurity(p_context->wepSecurityType,
                   p_context->wepKeyIndex,
                   p_context->wepKey,
                   p_context->wepKeyLength);
}

//============================================================================
void WF_SecurityWpaSet(t_wpaContext* p_context)
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode;

    errorCode = UdSetSecurityWpa(p_context);
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif /* WF_ERROR_CHECKING */

    WF_SetSecurity(p_context->wpaSecurityType,
                   0, // not used
                   p_context->keyInfo.key,
                   p_context->keyInfo.keyLength);
}

#if defined(WF_USE_WPS_SECURITY)
//============================================================================
void WF_SecurityWpsSet(t_wpsContext *p_context)
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = UdSetSecurityWps(p_context);
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif /* WF_ERROR_CHECKING */

    WF_SetSecurity(p_context->wpsSecurityType,
                   0,
                   p_context->wpsPin,
                   p_context->wpsPinLength);

#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
    // if host wants the host to calculate a binary key from a possible WPS-PSK passphrase
    if (p_context->getPassPhrase == true)
    {
        // tell MRF24WG to send wpa-psk passphrase back to host (if AP using WPA passphrase)
        YieldPassPhraseToHost();
        
        // save pointer to passphrase info block
        g_p_wpaKeyInfo = p_context->p_keyInfo;
    }
#endif /* WF_USE_HOST_WPA_KEY_CALCULATION */
}
#endif /* WF_USE_WPS_SECURITY */


#if defined(WF_USE_HOST_WPA_KEY_CALCULATION)
t_wpaKeyInfo * GetWpsPassPhraseInfo(void)
{
   return g_p_wpaKeyInfo;
}

//============================================================================
void WF_WpsKeyGenerate(void)
{
    // create the binary key
    WF_WpaConvPassphraseToKey(g_p_wpaKeyInfo);

    // send it to MRF24WG
    SetPSK(g_p_wpaKeyInfo->key);
}

#endif /* WF_USE_HOST_WPA_KEY_CALCULATION */

//============================================================================
void WF_BssidSet(uint8_t *p_bssid)
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = UdSetBssid(p_bssid);
    if (errorCode != UD_SUCCESS)
    {
        return;
    }

#endif
    LowLevel_CPGetElement(WF_CP_ELEMENT_BSSID,   // Element ID
                          p_bssid,               // pointer to element data
                          WF_BSSID_LENGTH,       // number of element data bytes
                          true);                 // read data, free buffer after read
}


// called from SetAdhocContext().  Error checking performed there
void SetHiddenSsid(bool hiddenSsid)
{
    LowLevel_CPSetElement(WF_CP_ELEMENT_SSID_TYPE, // Element ID
                          (uint8_t *)&hiddenSsid,  // pointer to element data
                          1);                      // number of element data bytes
}

// called from SetAdhocContext().  Error checking performed there
void SetAdHocMode(uint8_t mode)
{
    LowLevel_CPSetElement(WF_CP_ELEMENT_ADHOC_BEHAVIOR,  // Element ID
                          &mode,                         // pointer to element data
                          1);                            // number of element data bytes
}

/*******************************************************************************
  Function:
    void WF_CPSetSecurity(UINT8 securityType,
                          UINT8 wepKeyIndex,
                          UINT8 *p_securityKey,
                          UINT8 securityKeyLength)

  Summary:
    Sets the security for the specified Connection Profile.

  Description:
    Configures security for a Connection Profile.

    <table>
    Security                                Key         Length
    --------                                ---         ------
    WF_SECURITY_OPEN                        N/A         N/A
    WF_SECURITY_WEP_40                      hex         4, 5 byte keys
    WF_SECURITY_WEP_104                     hex         4, 13 byte keys
    WF_SECURITY_WPA_WITH_KEY                hex         32 bytes
    WF_SECURITY_WPA_WITH_PASS_PHRASE        ascii       8-63 ascii characters
    WF_SECURITY_WPA2_WITH_KEY               hex         32 bytes
    WF_SECURITY_WPA2_WITH_PASS_PHRASE       ascii       8-63 ascii characters
    WF_SECURITY_WPA_AUTO_WITH_KEY           hex         32 bytes
    WF_SECURITY_WPA_AUTO_WITH_PASS_PHRASE   ascii       8-63 ascii characters
    </table>

  Precondition:
    MACInit must be called first.

  Parameters:
    securityType      - Value corresponding to the security type desired.
    wepKeyIndex       - 0 thru 3 (only used if security type is WF_SECURITY_WEP_40 or
                         WF_SECURITY_WEP_104)
    p_securityKey     - Binary key or passphrase (not used if security is
                         WF_SECURITY_OPEN)
    securityKeyLength - Number of bytes in p_securityKey (not used if security
                         is WF_SECURITY_OPEN)

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
static void WF_SetSecurity(uint8_t securityType,
                           uint8_t wepKeyIndex,
                           uint8_t *p_securityKey,
                           uint8_t securityKeyLength)
{
    uint8_t  hdrBuf[7];
    uint8_t  *p_key;

    /* Write out header portion of msg */
    hdrBuf[0] = WF_MGMT_REQUEST_TYPE;           /* indicate this is a mgmt msg     */
    hdrBuf[1] = WF_CP_SET_ELEMENT_SUBTYPE;      /* mgmt request subtype            */
    hdrBuf[2] = GetCpid();                      /* Connection Profile ID           */
    hdrBuf[3] = WF_CP_ELEMENT_SECURITY;         /* Element ID                      */

    /* Next to header bytes are really part of data, but need to put them in header      */
    /* bytes in order to prepend to security key                                         */
    hdrBuf[5] = securityType;
    hdrBuf[6] = wepKeyIndex;

    /* if security is open (no key) or WPS push button method */
    if ((securityType == WF_SECURITY_OPEN || securityType == WF_SECURITY_WPS_PUSH_BUTTON))
    {
        hdrBuf[4]         = 2;      /* Only data is security type and wep index */
        p_key             = NULL;
        securityKeyLength = 0;
    }
    /* else security is selected, so need to send key */
    else
    {
        hdrBuf[4] = 2 + securityKeyLength;  /* data is security type + wep index + key */
        p_key     = p_securityKey;
    }

    SendMgmtMsg(hdrBuf,              /* msg header which includes the security type and WEP index)    */
                sizeof(hdrBuf),      /* msg header length                                             */
                p_key,               /* msg data (security key), can be NULL                          */
                securityKeyLength);  /* msg data length (will be 0 if p_securityKey is NULL)          */

    /* wait for mgmt response, free after it comes in, don't need data bytes */
    WaitForMgmtResponse(WF_CP_SET_ELEMENT_SUBTYPE, FREE_MGMT_BUFFER);
}

#if defined(WF_USE_WPS_SECURITY)
void WF_WpsCredentialsGet(t_wpsCredentials *p_cred)
{
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = UdGetWpsCredentials();
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif
    LowLevel_CPGetElement(WF_CP_ELEMENT_READ_WPS_CRED,    // Element ID
                          (uint8_t *)p_cred,              // pointer to element data
                          sizeof(*p_cred),                // number of element data bytes
                          true);                          // read data, free buffer after read
}
#endif /* WF_USE_WPS_SECURITY */


/*******************************************************************************
  Function:    
    void LowLevel_CPSetElement(uint8_t elementId,
                               uint8_t *p_elementData,
                               uint8_t elementDataLength)

  Summary:
    Set an element of the connection profile on the MRF24W.

  Description:
    All Connection Profile 'Set Element' functions call this function to 
    construct the management message.  The caller must fix up any endian issues 
    prior to calling this function.

  Precondition:
    MACInit must be called first.

  Parameters:
    elementId - Element that is being set
    p_elementData - Pointer to element data
    elementDataLength - Number of bytes pointed to by p_elementData

  Returns:
    None.
      
  Remarks:
    None.
  *****************************************************************************/
void LowLevel_CPSetElement(uint8_t elementId,
                           uint8_t *p_elementData,
                           uint8_t elementDataLength)
{
    uint8_t  hdrBuf[5];
    
    /* Write out header portion of msg */
    hdrBuf[0] = WF_MGMT_REQUEST_TYPE;       /* indicate this is a mgmt msg     */
    hdrBuf[1] = WF_CP_SET_ELEMENT_SUBTYPE;  /* mgmt request subtype            */     
    hdrBuf[2] = g_cpid;                     /* Connection Profile ID           */
    hdrBuf[3] = elementId;                  /* Element ID                      */
    hdrBuf[4] = elementDataLength;          /* number of bytes of element data */
    
    SendMgmtMsg(hdrBuf,              /* msg header        */
                sizeof(hdrBuf),      /* msg header length */
                p_elementData,       /* msg data          */
                elementDataLength);  /* msg data length   */
    
    /* wait for mgmt response, free after it comes in, don't need data bytes */
    WaitForMgmtResponse(WF_CP_SET_ELEMENT_SUBTYPE, FREE_MGMT_BUFFER);

}    

/*******************************************************************************
  Function:    
    static void LowLevel_CPGetElement(uint8_t elementId,
                                      uint8_t *p_elementData,
                                      uint8_t elementDataLength,
                                      bool    dataReadAction)

  Summary:
    Get an element of the connection profile on the MRF24W.

  Description:
    All Connection Profile 'Get Element' functions call this function to 
    construct the management message.  The caller must fix up any endian issues 
    prior to calling this function.

  Precondition:
    MACInit must be called first.

  Parameters:
    elementId - Element that is being read
    p_elementData - Pointer to where element data will be written
    elementDataLength - Number of element data bytes that will be read
    dataReadAction - If TRUE then read data per paramters and free mgmt 
                      response buffer. If FALSE then return after response 
                      received, do not read any data as the caller will do that, 
                      and don't free buffer, as caller will do that as well.

  Returns:
    None.
      
  Remarks:
    None.
  *****************************************************************************/
static void LowLevel_CPGetElement(uint8_t elementId,
                                  uint8_t *p_elementData,
                                  uint8_t elementDataLength,
                                  bool    dataReadAction)
{
    uint8_t  hdrBuf[4];
      
    hdrBuf[0] = WF_MGMT_REQUEST_TYPE;          /* indicate this is a mgmt msg     */
    hdrBuf[1] = WF_CP_GET_ELEMENT_SUBTYPE;  /* mgmt request subtype            */     
    hdrBuf[2] = g_cpid;                       /* Connection Profile ID           */
    hdrBuf[3] = elementId;                  /* Element ID                      */

    SendMgmtMsg(hdrBuf,              /* msg header        */
                sizeof(hdrBuf),      /* msg header length */
                NULL,                /* msg data          */
                0);                  /* msg data length   */
  
    if (dataReadAction == (uint8_t)true)
    {
        /* wait for mgmt response, read desired data, and then free response buffer */
        WaitForMgmtResponseAndReadData(WF_CP_GET_ELEMENT_SUBTYPE, 
                                       elementDataLength,                   /* num data bytes to read                */
                                       sizeof(t_cPElementResponseHdr),      /* index of first byte of element data   */
                                       p_elementData);                      /* where to write element data           */
    }
    else
    {
        /* wait for mgmt response, don't read any data bytes, do not release mgmt buffer */
        WaitForMgmtResponse(WF_CP_GET_ELEMENT_SUBTYPE, DO_NOT_FREE_MGMT_BUFFER);
    }                                                    
}
