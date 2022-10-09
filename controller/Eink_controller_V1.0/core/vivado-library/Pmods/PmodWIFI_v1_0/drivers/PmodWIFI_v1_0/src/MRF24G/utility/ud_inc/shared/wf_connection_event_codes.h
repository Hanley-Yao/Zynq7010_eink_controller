/*******************************************************************************
 MRF24WG Universal Driver Connection Event Codes.

  Summary: This module contains event codes specific to WiFi connections.

  Description: This module is an extension of wf_events.h, but specific to
               WiFi connection-related events
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


#ifndef __WF_CONNECTION_EVENT_CODES_H
#define __WF_CONNECTION_EVENT_CODES_H

#ifdef __cplusplus
extern "C" {
#endif


typedef enum t_connectionFailedEventStatus
{
    CF_JOIN_FAILURE                         = 2,
    CF_AUTHENTICATION_FAILURE               = 3,
    CF_ASSOCIATION_FAILURE                  = 4,
    CF_WEP_HANDSHAKE_FAILURE                = 5,
    CF_PSK_CALCULATION_FAILURE              = 6,
    CF_PSK_HANDSHAKE_FAILURE                = 7,
    CF_ADHOC_JOIN_FAILURE                   = 8,
    CF_SECURITY_MISMATCH_FAILURE            = 9,
    CF_NO_SUITABLE_AP_FOUND_FAILURE         = 10,
    CF_RETRY_FOREVER_NOT_SUPPORTED_FAILURE  = 11,
    CF_LINK_LOST                            = 12,
    CF_TKIP_MIC_FAILURE                     = 13,
    CF_RSN_MIXED_MODE_NOT_SUPPORTED         = 14,
    CF_RECV_DEAUTH                          = 15,
    CF_RECV_DISASSOC                        = 16,
    CF_WPS_FAILURE                          = 17,
    CF_P2P_FAILURE                          = 18,
    CF_LINK_DOWN                            = 19
} t_connectionFailedEventStatus;

typedef enum t_connectionLost
{
    CL_ASSOCIATION_FAILURE                  = 0,
    CL_BEACON_TIMEOUT                       = 1,
    CL_DEAUTH_RECEIVED                      = 2,
    CL_DISASSOCIATE_RECEIVED                = 3,
    CL_TKIP_MIC_FAILURE                     = 4,
    CL_LINK_DOWN                            = 5
} t_connectionLost;

typedef enum t_deauthDissaocReasonCode
{
    DD_UNSPECIFIED                          = 1,
    DD_PREV_AUTH_NOT_VALID                  = 2,
    DD_DEAUTH_LEAVING                       = 3,
    DD_DISASSOC_DUE_TO_INACTIVITY           = 4,
    DD_DISASSOC_AP_BUSY                     = 5,
    DD_CLASS2_FRAME_FROM_NONAUTH_STA        = 6,
    DD_CLASS3_FRAME_FROM_NONASSOC_STA       = 7,
    DD_DISASSOC_STA_HAS_LEFT                = 8,
    DD_STA_REQ_ASSOC_WITHOUT_AUTH           = 9,
    DD_INVALID_IE                           = 13,
    DD_MIC_FAILURE                          = 14,
    DD_4WAY_HANDSHAKE_TIMEOUT               = 15,
    DD_GROUP_KEY_HANDSHAKE_TIMEOUT          = 16,
    DD_IE_DIFFERENT                         = 17,
    DD_INVALID_GROUP_CIPHER                 = 18,
    DD_INVALID_PAIRWISE_CIPHER              = 19,
    DD_INVALID_AKMP                         = 20,
    DD_UNSUPP_RSN_VERSION                   = 21,
    DD_INVALID_RSN_IE_CAP                   = 22,
    DD_IEEE8021X_FAILED                     = 23,
    DD_CIPHER_SUITE_REJECTED                = 24
} t_deauthDissaocReasonCode;

typedef enum t_statusCode
{
    SC_UNSPECIFIED_FAILURE                  = 1,
    SC_CAPS_UNSUPPORTED                     = 10,
    SC_REASSOC_NO_ASSOC                     = 11,
    SC_ASSOC_DENIED_UNSPEC                  = 12,
    SC_NOT_SUPPORTED_AUTH_ALG               = 13,
    SC_UNKNOWN_AUTH_TRANSACTION             = 14,
    SC_CHALLENGE_FAIL                       = 15,
    SC_AUTH_TIMEOUT                         = 16,
    SC_AP_UNABLE_TO_HANDLE_NEW_STA          = 17,
    SC_ASSOC_DENIED_RATES                   = 18,
    SC_ASSOC_DENIED_NOSHORTPREAMBLE         = 19,
    SC_ASSOC_DENIED_NOPBCC                  = 20,
    SC_ASSOC_DENIED_NOAGILITY               = 21,
    SC_ASSOC_DENIED_NOSHORTTIME             = 25,
    SC_ASSOC_DENIED_NODSSSOFDM              = 26,
    SC_NOT_VALID_IE                         = 40,
    SC_NOT_VALID_GROUPCIPHER                = 41,
    SC_NOT_VALID_PAIRWISE_CIPHER            = 42,
    SC_NOT_VALID_AKMP                       = 43,
    SC_UNSUPPORTED_RSN_VERSION              = 44,
    SC_INVALID_RSN_IE_CAP                   = 45,
    SC_CIPHER_SUITE_REJECTED                = 46,
    SC_TIMEOUT                              = 47
} t_statusCode;

typedef enum t_wpsState
{
    EAP_EAPOL_START                         = 1,
    EAP_REQ_IDENTITY                        = 2,
    EAP_RSP_IDENTITY                        = 3,
    EAP_WPS_START                           = 4,
    EAP_RSP_M1                              = 5,
    EAP_REQ_M2                              = 6,
    EAP_RSP_M3                              = 7,
    EAP_REQ_M4                              = 8,
    EAP_RSP_M5                              = 9,
    EAP_REQ_M6                              = 10,
    EAP_RSP_M7                              = 11,
    EAP_REQ_M8                              = 12,
    EAP_RSP_DONE                            = 13,
    EAP_FAILURE                             = 14
} t_wpsState;

typedef enum t_wpsConfigError
{
    WPS_NOERR                               = 0,
    WPS_SESSION_OVERLAPPED                  = 1,
    WPS_DECRYPT_CRC_FAILURE                 = 2,
    WPS_MRF24WG_NOT_SUPPORTED               = 3,
    WPS_RETRY_FAILURE                       = 4,
    WPS_INVALID_MSG                         = 5,
    WPS_AUTH_FAILURE                        = 6,
    WPS_ASSOC_FAILURE                       = 7,
    WPS_MSG_TIMEOUT                         = 8,
    WPS_SESSION_TIMEOUT                     = 9,
    WPS_DEVPASSWD_AUTH_FAILURE              = 10,
    WPS_NO_CONN_TOREG                       = 11,
    WPS_MULTI_PBC_DETECTED                  = 12,
    WPS_EAP_FAILURE                         = 13,
    WPS_DEV_BUSY                            = 14,
    WPS_SETUP_LOCKED                        = 15
} t_wpsConfigError;

typedef enum t_p2pState
{
    P2P_IDLE                                = 0,
    P2P_SCAN                                = 1,
    P2P_LISTEN                              = 2,
    P2P_FIND                                = 3,
    P2P_START_FORMATION                     = 4,
    P2P_NEG_REQ_DONE                        = 5,
    P2P_WAIT_NEG_REQ_DONE                   = 6,
    P2P_WAIT_FORMATION_DONE                 = 7,
    P2P_INVITE                              = 8,
    P2P_PROVISION                           = 9,
    P2P_CLIENT                              = 10
} t_p2pState;

typedef enum t_p2pError
{
    WFD_SUCCESS                             = 0,
    WFD_INFO_CURRENTLY_UNAVAILABLE          = 1,
    WFD_INCOMPATIBLE_PARAMS                 = 2,
    WFD_LIMIT_REACHED                       = 3,
    WFD_INVALID_PARAMS                      = 4,
    WFD_UNABLE_TO_ACCOMMODATE               = 5,
    WFD_PREV_PROTOCOL_ERROR                 = 6,
    WFD_NO_COMMON_CHANNELS                  = 7,
    WFD_UNKNOWN_GROUP                       = 8,
    WFD_INCOMPATIBLE_PROV_METHOD            = 10,
    WFD_REJECTED_BY_USER                    = 11,
    WFD_NO_MEM                              = 12,
    WFD_INVALID_ACTION                      = 13,
    WFD_TX_FAILURE                          = 14,
    WFD_TIME_OUT                            = 15
} t_p2pError;


typedef struct
{
    uint8_t event;  // always WF_EVENT_CONNECTION_FAILED
    uint8_t status; // see t_connectionFailedEventStatus
} t_connectLost;

// used if status = WF_RECV_DEAUTH or WF_RECV_DISASSOC
typedef struct
{
    uint8_t event;  // always WF_EVENT_CONNECTION_FAILED
    uint8_t status; // see t_connectionFailedEventStatus (either WF_RECV_DEAUTH or WF_RECV_DISASSOC)
    uint8_t reason; // see t_deauthDisssocReasonCodes
} t_recvAuthDisassocFailureCodes;

// used if status = WF_AUTHENTICATION_FAILURE or WF_ASSOCIATION_FAILURE
typedef struct
{
    uint8_t event;  // always WF_EVENT_CONNECTION_FAILED
    uint8_t status; // see t_connectionFailedEventStatus (either WF_AUTHENTICATION_FAILURE or WF_ASSOCIATION_FAILURE)
    uint8_t reason; // see t_statusCodes;
} t_authAssocFailure;

// used if status = WF_WPS_FAILURE
typedef struct
{
    uint8_t event;          // always WF_EVENT_CONNECTION_FAILED
    uint8_t status;         // always WF_WPS_FAILURE
    uint8_t wpsState;       // see t_wpsState
    uint8_t wpsConfigErr;   // see t_wpsConfigErr
} t_wpsFailure;

// used if status = WF_P2P_FAILURE
typedef struct
{
    uint8_t event;          // always WF_EVENT_CONNECTION_FAILED
    uint8_t status;         // always WF_P2P_FAILURE
    uint8_t p2pState;       // see t_p2pState
    uint8_t p2pErr;         // see t_p2pErr
} t_p2pFailure;

typedef struct
{
    t_connectLost                   connectionLost;
    t_recvAuthDisassocFailureCodes  recvAuthDissaocFailure;
    t_authAssocFailure              authAssocFailure;
    t_wpsFailure                    wpsFailure;
    t_p2pFailure                    p2pFailure;
} t_connectionLostEvent;




#ifdef __cplusplus
}
#endif


#endif /* __WF_CONNECTION_EVENT_CODES_H */

