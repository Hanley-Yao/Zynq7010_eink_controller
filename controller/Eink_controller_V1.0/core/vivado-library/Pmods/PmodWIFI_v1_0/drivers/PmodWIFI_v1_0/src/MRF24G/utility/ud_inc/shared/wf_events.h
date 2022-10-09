/*******************************************************************************
 MRF24WG event definitions

  Summary: This module contains defines used to define WiFi events

  Description: None
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

#ifndef __WF_EVENTS_H
#define __WF_EVENTS_H

#ifdef __cplusplus
extern "C" {
#endif

 
//-----------------------------------------------------------------------
// Event Types -- corresponds to eventType parameter in WF_ProcessEvent()
//-----------------------------------------------------------------------
typedef enum t_eventType
{
    // initialization event
    WF_EVENT_INITIALIZATION              = 0,    // Results of calling WF_Init()

    // connection events
    WF_EVENT_CONNECTION_SUCCESSFUL       = 1,
    WF_EVENT_CONNECTION_FAILED           = 2,
    WF_EVENT_CONNECTION_TEMPORARILY_LOST = 3,
    WF_EVENT_CONNECTION_PERMANENTLY_LOST = 4,
    WF_EVENT_CONNECTION_REESTABLISHED    = 5,

    // WiFi scan event
    WF_EVENT_SCAN_RESULTS_READY          = 6,

    // WPS WPA-PSK key calculation needed
    WF_WPS_EVENT_KEY_CALCULATION_REQUEST = 8,    // Key calculation is required

    // error events
    WF_EVENT_ERROR                       = 50,   // Universal Driver error has occurred
    WF_EVENT_MRF24WG_MODULE_ASSERT       = 52   // MRF24WG module has asserted
} t_eventType;


// WF_INITIALIZATION_EVENT -- eventData values
//--------------------------------------------
typedef enum t_wfInitEventErrors
{
    WF_INIT_SUCCESSFUL                 = 0,    // MRF24WG initialization successful
    WF_INIT_ERROR_SPI_NOT_CONNECTED    = 1,    // appears that the MRF24WG SPI interface is not connected
    WF_INIT_ERROR_RESET_TIMEOUT        = 2,    // timed out waiting for MRF24WG to come out of reset
    WF_INIT_ERROR_INIT_TIMEOUT         = 3    // timed out waiting for MRF24WG to initialize after reset
} t_wfInitEventErrors;


// WF_EVENT_ERROR -- eventData values
//-----------------------------------
typedef enum t_udEventErrors
{
    UD_SUCCESS = 0,

    // this block of error codes are returned from the MRF24WG in the result field
    // of a managment response message and should not be changed.
    MGMT_RESP_SUCCESS                                              = 1,
    MGMT_RESP_ERROR_INVALID_SUBTYPE                                = 2,
    MGMT_RESP_ERROR_OPERATION_CANCELLED                            = 3,
    MGMT_RESP_ERROR_FRAME_END_OF_LINE_OCCURRED                     = 4,
    MGMT_RESP_ERROR_FRAME_RETRY_LIMIT_EXCEEDED                     = 5,
    MGMT_RESP_ERROR_EXPECTED_BSS_VALUE_NOT_IN_FRAME                = 6,
    MGMT_RESP_ERROR_FRAME_SIZE_EXCEEDS_BUFFER_SIZE                 = 7,
    MGMT_RESP_ERROR_FRAME_ENCRYPT_FAILED                           = 8,
    MGMT_RESP_ERROR_INVALID_PARAM                                  = 9,
    MGMT_RESP_ERROR_AUTH_REQ_ISSUED_WHILE_IN_AUTH_STATE            = 10,
    MGMT_RESP_ERROR_ASSOC_REQ_ISSUED_WHILE_IN_ASSOC_STATE          = 11,
    MGMT_RESP_ERROR_INSUFFICIENT_RESOURCES                         = 12,
    MGMT_RESP_ERROR_TIMEOUT_OCCURRED                               = 13,
    MGMT_RESP_ERROR_BAD_EXCHANGE_ENCOUNTERED_IN_FRAME_RECEPTION    = 14,
    MGMT_RESP_ERROR_AUTH_REQUEST_REFUSED                           = 15,
    MGMT_RESP_ERROR_ASSOCIATION_REQUEST_REFUSED                    = 16,
    MGMT_RESP_ERROR_PRIOR_MGMT_REQUEST_IN_PROGRESS                 = 17,
    MGMT_RESP_ERROR_NOT_IN_JOINED_STATE                            = 18,
    MGMT_RESP_ERROR_NOT_IN_ASSOCIATED_STATE                        = 19,
    MGMT_RESP_ERROR_NOT_IN_AUTHENTICATED_STATE                     = 20,
    MGMT_RESP_ERROR_SUPPLICANT_FAILED                              = 21,
    MGMT_RESP_ERROR_UNSUPPORTED_FEATURE                            = 22,
    MGMT_RESP_ERROR_REQUEST_OUT_OF_SYNC                            = 23,
    MGMT_RESP_ERROR_CP_INVALID_ELEMENT_TYPE                        = 24,
    MGMT_RESP_ERROR_CP_INVALID_PROFILE_ID                          = 25,
    MGMT_RESP_ERROR_CP_INVALID_DATA_LENGTH                         = 26,
    MGMT_RESP_ERROR_CP_INVALID_SSID_LENGTH                         = 27,
    MGMT_RESP_ERROR_CP_INVALID_SECURITY_TYPE                       = 28,
    MGMT_RESP_ERROR_CP_INVALID_SECURITY_KEY_LENGTH                 = 29,
    MGMT_RESP_ERROR_CP_INVALID_WEP_KEY_ID                          = 30,
    MGMT_RESP_ERROR_CP_INVALID_NETWORK_TYPE                        = 31,
    MGMT_RESP_ERROR_CP_INVALID_ADHOC_MODE                          = 32,
    MGMT_RESP_ERROR_CP_INVALID_SCAN_TYPE                           = 33,
    MGMT_RESP_ERROR_CP_INVALID_CP_LIST                             = 34,
    MGMT_RESP_ERROR_CP_INVALID_CHANNEL_LIST_LENGTH                 = 35,
    MGMT_RESP_ERROR_NOT_CONNECTED                                  = 36,
    MGMT_RESP_ERROR_ALREADY_CONNECTING                             = 37,
    MGMT_RESP_ERROR_DISCONNECT_FAILED                              = 38,
    MGMT_RESP_ERROR_NO_STORED_BSS_DESCRIPTOR                       = 39,
    MGMT_RESP_ERROR_INVALID_MAX_POWER                              = 40,
    MGMT_RESP_ERROR_CONNECTION_TERMINATED                          = 41,
    MGMT_RESP_ERROR_HOST_SCAN_NOT_ALLOWED                          = 42,
    MGMT_RESP_ERROR_INVALID_WPS_PIN                                = 44,
    // end of mgmt response error code block

    UD_ERROR_MGMT_RESPONSE_TIMEOUT           = 50,     // timed out waiting for mgmt response msg
    UD_ERROR_MGMT_BUFFER_ALLOCATION_FAILED   = 51,     // allocation should have worked, but failed
    UD_ERROR_RAW_RX_MOUNT_FAILED             = 52,     // notified of Rx msg (mgmt or data), but length was 0
    UD_ERROR_RAW_SET_INDEX_OUT_OF_BOUNDS     = 53,     // trying to set raw index past end of raw window
    UD_ERROR_RAW_GET_BYTE_OUT_OF_BOUNDS      = 54,     // trying to read past end of raw window
    UD_ERROR_RAW_SET_BYTE_OUT_OF_BOUNDS      = 55,     // trying to write past end of raw window
    UD_ERROR_INVALID_MGMT_TYPE               = 56,     // unknown mgmt msg type was received
    UD_ERROR_INVALID_MGMT_SUBTYPE            = 57,     // unexpected mgmt confirm subtype received
    UD_ERROR_UNKNOWN_DEVICE                  = 58,     // Unknown device (not an MRF24WG)
    UD_ERROR_MRF24WB_NOT_SUPPORTED           = 59,     // MRF24WB not supported, only MRF24WG supported
    UD_ERROR_RAW_INTERRUPT_TIMEOUT           = 60,     // Timed out waiting for raw move complete interrupt
    UD_ERROR_UNKNOWN_EVENT_TYPE              = 61,     // Unknown event type received from MRF24WG
    UD_ERROR_BAD_PARAM_IN_CONN_LOST_EVENT    = 62,     // Unknown param in WF_EVENT_CONNECTION_LOST_SUBTYPE event

    UD_ERROR_INVALID_DOMAIN                  = 100,     // Domain parameter is invalid
    UD_ERROR_SSID_BUFFER_EMPTY               = 101,     // SSID length > 0, but SSID string is empty
    UD_ERROR_SSID_NOT_DEFINED                = 103,     // An SSID is required for this connection mode
    UD_ERROR_SSID_TOO_LONG                   = 104,     // SSID cannot be longer than 32 characters
    UD_ERROR_NO_CHANNEL_LIST_DEFINED         = 105,     // p_channelList parameter is not valid
    UD_ERROR_INVALID_CHANNEL_0               = 106,     // cannot have a channel number of 0
    UD_ERROR_EXCEEDED_MAX_CHANNELS           = 107,     // Cannot have more than 14 channels in channel list
    UD_INVALID_CHANNEL_NUMBER                = 108,     // Channel list has an invalid channel number
    UD_ERROR_CHANNEL_OUT_OF_RANGE            = 109,     // Channel number too large for selected domain
    UD_ERROR_ALL_DOMAIN_CHANNELS_REQUIRED    = 110,     // when using WPS, the channel list must contain all legal channels in domain
    UD_INVALID_NETWORK_TYPE                  = 111,     // Invalid network type
    UD_ERROR_INVALID_SECURITY_TYPE           = 112,     // Invalid security type
    UD_ERROR_WEP_40_KEY_INVALID_LENGTH       = 113,     // WEP-40 key must be 4 5-byte keys, or 20 bytes
    UD_ERROR_WEP_104_KEY_INVALID_LENGTH      = 114,     // WEP-104 key must be 4 13-byte keys, or 52 bytes
    UD_ERROR_INVALID_WEP_KEY_INDEX           = 115,     // WEP key index must be between and 0 and 3
    UD_ERROR_INIT_NOT_DONE                   = 116,     // Trying to connect, but WF_Init() either not called or not finished
    UD_ERROR_INVALID_CONFIG                  = 117,     // A previous error event occurred that prevents a connection
    UD_ERROR_INVALID_WPA_KEY_LENGTH          = 118,     // WPA/WPA2 binary key length is invalid (must be 32 bytes)
    UD_ERROR_INVALID_WPA_PASSPHRASE_LENGTH   = 119,     // WPA/WPA2 ASCII passphrase must be between 8 and 63 characters
    UD_ERROR_INVALID_WPA_PASSPHRASE_CHARACTERS = 120,   // Passphrase characters must be printable
    UD_ERROR_WPS_PIN_LENGTH_INVALID          = 121,     // WPS PIN must be 7 digits + checksum, or a total of 8 digits
    UD_ERROR_INVALID_WPS_PIN                 = 122,     // WPS pin does not have a valid checksum in the 8th digit
    UD_ERROR_SSID_DEFINED                    = 123,     // For instrastructure mode using WPS push-button, SSID must be empty
                                                        //  string with length of 0
    UD_ERROR_INVALID_WEP_SECURITY            = 124,     // AdHoc only supports open or WEP security
    UD_ERROR_INVALID_ADHOC_RETRY_COUNT       = 125,     // using WF_RETRY_FOREVER, not recommended for AdHoc networks
    UD_ERROR_INVALID_P2P_SSID                = 126,     // When network type is WF_NETWORK_TYPE_P2P, SSID must be "DIRECT-"
    UD_ERROR_INVALID_P2P_CHANNEL_LIST        = 127,     // When network type is WF_NETWORK_TYPE_P2P, channel list must be 1,6,11
    UD_ERROR_INVALID_DEAUTH_PARAM            = 128,     // UdSetReconnectMode(), deauthAction param invalid
    UD_ERROR_INVALID_BEACON_TIMEOUT_PARAM    = 129,     // UdSetReconnectMode(), beaconTimeoutAction param invalid
    UD_ERROR_INVALID_RECONNECT_MODE          = 130,     // UdSetReconnectMode(), can't have retry count of 0 and attempt to reconnect
    UD_ERROR_DISCONNECT_NOT_ALLOWED          = 131,     // WF_Disconnect() not allowed, MRF24WG either trying to reconnect or has no connection
    UD_ERROR_ONLY_VALID_WHEN_NOT_CONNECTED   = 132,     // Can only perform this action when not connected
    UD_ERROR_INVALID_WEP_SECURITY_TYPE       = 133,     // t_wepContext has an invalid WEP security type
    UD_ERROR_INVALID_WEP_KEY_TYPE            = 134,     // t_wepContext has an invalid key type
    UD_ERROR_INVALID_WPA_SECURITY_TYPE       = 135,     // t_wpaContext has an invalid WPA security type
    UD_ERROR_INVALID_SCAN_TYPE               = 136,     // WF_ScanContextSet(), scanType parameter is invalid
    UD_ERROR_INVALID_HIDDEN_SSID             = 137,     // SetAdhocContext(), hiddenSsid param must be true or false
    UD_ERROR_INVALID_ADHOC_MODE              = 138,     // SetAdhocContext(), mode param invalid
    UD_ERROR_INVALID_TX_MODE                 = 139,     // WF_TxModeSet(), invalid mode param
    UD_ERROR_INVALID_RTS_THRESHOLD           = 140,     // WF_SetRtsTheshold(), invalid rtsThreshold param
    UD_ERROR_SCAN_NOT_ALLOWED                = 141,     // WF_Scan() not allowed in midst of connection or connection retry
    UD_ERROR_INVALID_SCAN_MODE               = 142,     // WF_Scan(), invalid scanMode param
    UD_ERROR_INVALID_MAX_POWER               = 143,     // WF_SetTxPowerMax, maxTxPower param out of range
    UD_ERROR_INVALID_MULTICAST_FILTER_ID     = 144,     // t_swMulticastConfig(), or WF_SwMulticastFilterSet(); invalid Multicast filter ID paramter
    UD_ERROR_INVALID_MULTICAST_ACTION        = 145,     // WF_SwMulticastFilterSet(), invalid action parameter
    UD_ERROR_INVALID_GET_PASS_PHRASE         = 146,     // WF_SetSecurityWps(), getPassphrase param must be true or false
    UD_ERROR_NULL_PASS_PHRASE_INFO           = 148,     // WF_SetSecurityWps(), illegal null pointer for p_wpsPassPhraseInfo param
    UD_ERROR_PASSPHRASE_WPA_NOT_SUPPORTED    = 149,     // UdSetSecurityWpa(), passphrase not supported without defining WF_USE_HOST_WPA_KEY_CALCULATION
    UD_ERROR_NOT_WPS_SECURITY                = 150,     // WF_GetWpsCredentials(), invalid to call this if not using WPS security
    UD_ERROR_RAW_TX_ALLOC_FAILED             = 151,     // AllocateDataTxBuffer(); unable to allocate memory for tx packet
    UD_INVALID_PS_POLL_ERROR                 = 152,     // Cannot enable PS-Poll mode until after WiFi connection complete.
    UD_INVALID_DATA_MSG                      = 153,     // Internal driver error (should never happen).
    UD_TX_ALLOCATION_FAILED                  = 154      // AllocateDataTxBuffer failed
} t_udEventErrors;

#ifdef __cplusplus
}
#endif



#endif /* __WF_EVENTS_H */


