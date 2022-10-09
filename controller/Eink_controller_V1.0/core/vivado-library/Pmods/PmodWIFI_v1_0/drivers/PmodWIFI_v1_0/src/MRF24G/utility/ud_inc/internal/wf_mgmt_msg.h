/*******************************************************************************
 MRF24WG Universal Driver Management Messages

  Summary: This module contains management message defintions

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


#ifndef __WF_MGMT_MSG_H
#define __WF_MGMT_MSG_H

#ifdef __cplusplus
extern "C" {
#endif

#define WF_MAX_TX_MGMT_MSG_SIZE         (128)
#define MGMT_RESP_1ST_DATA_BYTE_INDEX   (4)  /* first data byte of Mgmt response starts at index 4 */

enum
{
    DO_NOT_FREE_MGMT_BUFFER = 0,
    FREE_MGMT_BUFFER        = 1,
};



/*----------------------------------------------*/
/* Management Message Request/Response Subtypes */
/*----------------------------------------------*/
typedef enum
{
    /* Misc subtypes */
    WF_SCAN_SUBTYPE                             = 1,
    WF_JOIN_SUBTYPE                             = 2,
    WF_AUTH_SUBTYPE                             = 3,
    WF_ASSOC_SUBTYPE                            = 4,
    WF_DISCONNECT_SUBTYPE                       = 5,
    WF_DISASOCC_SUBTYPE                         = 6,
    WF_SET_POWER_MODE_SUBTYPE                   = 7,
    WF_SET_PM_KEY_SUBTYPE                       = 8,
    WF_SET_WEP_MAP_SUBTYPE                      = 9,
    WF_SET_WEP_KEY_SUBTYPE                      = 10,
    WF_SET_TEMP_KEY_SUBTYPE                     = 11,
    WF_CALC_PSK_KEY_SUBTYPE                     = 12,
    WF_SET_WEP_KEY_ID_SUBTYPE                   = 13,
    WF_CONFIG_KEY_SPACE_SUBTYPE                 = 14,
    WF_SET_PARAM_SUBTYPE                        = 15,
    WF_GET_PARAM_SUBTYPE                        = 16,
    WF_ADHOC_CONNECT_SUBTYPE                    = 17,
    WF_ADHOC_START_SUBTYPE                      = 18,

    /* Connection Profile Message Subtypes */
    WF_CP_CREATE_PROFILE_SUBTYPE                = 21,
    WF_CP_DELETE_PROFILE_SUBTYPE                = 22,
    WF_CP_GET_ID_LIST_SUBTYPE                   = 23,
    WF_CP_SET_ELEMENT_SUBTYPE                   = 24,
    WF_CP_GET_ELEMENT_SUBTYPE                   = 25,

    /* Connection Algorithm Message Subtypes */
    WF_CA_SET_ELEMENT_SUBTYPE                   = 26,
    WF_CA_GET_ELEMENT_SUBTYPE                   = 27,

    /* Connnection Manager Message Subtypes */
    WF_CM_CONNECT_SUBYTPE                       = 28,
    WF_CM_DISCONNECT_SUBYTPE                    = 29,
    WF_CM_GET_CONNECTION_STATUS_SUBYTPE         = 30,

    WF_SCAN_START_SUBTYPE                       = 31,
    WF_SCAN_GET_RESULTS_SUBTYPE                 = 32,

    WF_CM_INFO_SUBTYPE                          = 33,

    WF_SCAN_FOR_IE_SUBTYPE                      = 34,  /* not yet supported */
    WF_SCAN_IE_GET_RESULTS_SUBTYPE              = 35,  /* not yet supported */

    WF_CM_GET_CONNECTION_STATISTICS_SUBYTPE     = 36,  /* not yet supported so moved here for now */
    WF_NUM_REQUEST_SUBTYPES

} tMgmtMsgSubtypes;

// parameter message subtypes
typedef enum
{
    PARAM_MAC_ADDRESS                   = 1,       /* the device MAC address (6 bytes)                              */
    PARAM_REGIONAL_DOMAIN               = 2,       /* the device Regional Domain (1 byte)                           */
    PARAM_RTS_THRESHOLD                 = 3,       /* the RTS byte threshold 256 - 2347 (2 bytes)                   */
    PARAM_LONG_FRAME_RETRY_LIMIT        = 4,       /* the long Frame Retry limit  (1 byte)                          */
    PARAM_SHORT_FRAME_RETRY_LIMIT       = 5,       /* the short Frame Retry limit (1 byte)                          */
    PARAM_TX_LIFETIME_TU                = 6,       /* the Tx Request lifetime in TU's 0 - 4194303 (4 bytes)         */
    PARAM_RX_LIFETIME_TU                = 7,       /* the Rx Frame lifetime in TU's 0 - 4194303 (4 bytes)           */
    PARAM_SUPPLICANT_ON_OFF             = 8,       /* boolean 1 = on 0 = off (1 byte)                               */
    PARAM_CONFIRM_DATA_TX_REQ           = 9,       /* boolean 1 = on 0 = off (1 byte)                               */
    PARAM_MASTER_STATE                  = 10,      /* master state of the MAC using enumerated values (1 byte)      */
    PARAM_HOST_ALERT_BITS               = 11,      /* a bit field which enables/disables various asynchronous       */
                                                   /*   indications from the MAC to the host (2 bytes)              */
    PARAM_NUM_MISSED_BEACONS            = 12,      /* number of consecutive beacons MAC can miss before it          */
                                                   /*   considers the network lost (1 byte)                         */
    PARAM_DIFS_AND_EIFS                 = 13,      /* delay intervals in usec DIFS and EIFS ( 2 * 2 bytes)          */
    PARAM_TX_POWER                      = 14,      /* max and min boundaries for Tx power (2 * 2 bytes)             */
    PARAM_DEFAULT_DEST_MAC_ADDR         = 15,      /* stores a persistant destination MAC address for small         */
                                                   /*   Tx Requests (6 bytes)                                       */
    PARAM_WPA_INFO_ELEMENT              = 16,      /* stores a WPA info element (IE) in 802.11 IE format.  Used     */
                                                   /*   in Assoc Request and Supplicant exchange (3 - 258 bytes)    */
    PARAM_RSN_INFO_ELEMENT              = 17,      /* stores a RSN info element (IE) in 802.11 IE format.  Used     */
                                                   /*   in Assoc Request and Supplicant exchange (3 - 258 bytes)    */
    PARAM_ON_OFF_RADIO                  = 18,      /* bool to force a radio state change 1 = on 0 = off (1 byte)    */
    PARAM_COMPARE_ADDRESS               = 19,      /* A MAC address used to filter received frames                  */
                                                   /*   (sizeof(tAddressFilterInput) = 8 bytes)                     */
    PARAM_SUBTYPE_FILTER                = 20,      /* Bitfield used to filter received frames based on type and     */
                                                   /* sub-type (sizeof(tAddressFilterInput) = 4 bytes)              */
    PARAM_ACK_CONTROL                   = 21,      /* Bitfield used to control the type of frames that cause ACK    */
                                                   /*   responses (sizeof(tAckControlInput) = 4 bytes)              */
    PARAM_STAT_COUNTERS                 = 22,      /* Complete set of statistics counters that are maintained by    */
                                                   /*   the MAC                                                     */
    PARAM_TX_THROTTLE_TABLE             = 23,      /* Custom Tx Rate throttle table to be used to control tx Rate   */
    PARAM_TX_THROTTLE_TABLE_ON_OFF      = 24,      /* A boolean to enable/disable use of the throttle Table and a   */
                                                   /*   tx rate to use if the throttle table is disabled            */
    PARAM_TX_CONTENTION_ARRAY           = 25,      /* Custom Retry contention ladder used for backoff calculation   */
                                                   /*   prior to a Tx attempt                                       */
    PARAM_SYSTEM_VERSION                = 26,      /* 2 byte representation of a version number for the ROM and     */
                                                   /*  Patch                                                        */
    PARAM_STATUE_INFO                   = 27,      /* MAC State information                                         */
    PARAM_SECURITY_CONTROL              = 28,      /* 2 byte data structure to enable/disable encryption            */
    PARAM_FACTORY_SET_TX_MAX_POWER      = 29,      /* gets the factory-set tx max power level                       */
    PARAM_MRF24WB0M                     = 30,      /* a set enables MRF24WB0M Mode, a get gets the version          */
    PARAM_CONNECT_CONTEXT               = 31,      /* gets current connection status                                */
    PARAM_WICOM_MODE                    = 32,      /* a set enables WiCom mode                                      */
    PARAM_WPA_TIMEOUT                   = 33,      /* configure 4 way handshaking transaction timeout               */
    PARAM_TX_MODE                       = 34,      /* choose tx mode                                                */
    PARAM_ENABLE_DEBUG_PRINT            = 35,      /* enable WPS / P2P debug prints                                 */
    PARAM_BROADCAST_PROBE_RESPONSE      = 36,      /* enable broadcast probe response                               */
    PARAM_LINK_DOWN_THRESHOLD           = 37,      /* sets link down threshold                                      */
    PARAM_STACK_VERSION                 = 38,      /* notifies stack version to RF FW                               */
    PARAM_SET_PSK                       = 39,      /* set psk                                                       */
    PARAM_YIELD_PASSPHRASE_TOHOST       = 40,      /* forces module FW to send passphrase to host in WPS            */
    PARAM_USE_SW_MULTICAST_FILTER       = 41       /* force to use sw multicast filter instead of hw filter         */

} tWFParam;

/*-------------------------------------------------------------*/
/* Connection Algorithm Element ID?s                           */
/* Used in conjunction with the WF_CA_SET_ELEMENT_SUBTYPE and  */
/* WF_CA_GET_ELEMENT_SUBTYPE message subtypes                  */
/*-------------------------------------------------------------*/
typedef enum
{
    WF_CA_ELEMENT_ALL                          = 0,
    WF_CA_ELEMENT_SCANTYPE                     = 1,
    WF_CA_ELEMENT_RSSI                         = 2,
    WF_CA_ELEMENT_CP_LIST                      = 3,
    WF_CA_ELEMENT_LIST_RETRY_COUNT             = 4,
    WF_CA_ELEMENT_EVENT_NOTIFICATION_ACTION    = 5,
    WF_CA_ELEMENT_BEACON_TIMEOUT_ACTION        = 6,
    WF_CA_ELEMENT_DEAUTH_ACTION                = 7,
    WF_CA_ELEMENT_CHANNEL_LIST                 = 8,
    WF_CA_ELEMENT_LISTEN_INTERVAL              = 9,
    WF_CA_ELEMENT_BEACON_TIMEOUT               = 10,
    WF_CA_ELEMENT_SCAN_COUNT                   = 11,
    WF_CA_ELEMENT_MIN_CHANNEL_TIME             = 12,
    WF_CA_ELEMENT_MAX_CHANNEL_TIME             = 13,
    WF_CA_ELEMENT_PROBE_DELAY                  = 14,
    WF_CA_ELEMENT_DTIM_INTERVAL                = 15,
    WF_CA_ELEMENT_BEACON_PERIOD                = 16
} tCAElementIds;

/*-------------------------------------------*/
/* Connection Manager Event Message Subtypes */
/* (Used in Mgmt Indicate messages)          */
/*-------------------------------------------*/
typedef enum t_mgmtIndicateSubtypes
{
    WF_EVENT_CONNECTION_ATTEMPT_STATUS_SUBTYPE = 6,
    WF_EVENT_CONNECTION_LOST_SUBTYPE           = 7,
    WF_EVENT_CONNECTION_REESTABLISHED_SUBTYPE  = 8,
    WF_EVENT_KEY_CALCULATION_REQUEST_SUBTYPE   = 9,
    WF_EVENT_SCAN_RESULTS_READY_SUBTYPE        = 11,
    WF_EVENT_SCAN_IE_RESULTS_READY_SUBTYPE     = 12,
} t_mgmtIndicateSubtypes;

/* event values for index 2 of WF_CONNECTION_ATTEMPT_STATUS_EVENT_SUBTYPE */
#define CONNECTION_ATTEMPT_SUCCESSFUL    ((uint8_t)1)   /* if not 1 then failed to connect and info field is error code */
#define CONNECTION_ATTEMPT_FAILED        ((uint8_t)2)

/* event values for index 2 of WF_EVENT_CONNECTION_LOST_SUBTYPE */
#define CONNECTION_TEMPORARILY_LOST      ((uint8_t)1)
#define CONNECTION_PERMANENTLY_LOST      ((uint8_t)2)
#define CONNECTION_REESTABLISHED         ((uint8_t)3)


/* This structure describes the format of the first four bytes of all */
/* mgmt response messages received from the MRF24W                 */
typedef struct mgmtRxHdrStruct
{
    uint8_t  type;          /* always 0x02                  */
    uint8_t  subtype;       /* mgmt msg subtype             */
    uint8_t  result;        /* 1 if success, else failure   */
    uint8_t  macState;      /* not used                     */

} t_mgmtMsgRxHdr;

typedef struct mgmtIndicateHdrStruct
{
    uint8_t type;       /* always WF_MGMT_INDICATE_MSG_TYPE (2) */
    uint8_t subType;    /* event type                           */
} t_mgmtIndicateHdr;


void WF_CPCreate(void);
INLINE void SignalMgmtMsgRx();
void SendMgmtMsg(uint8_t *p_header, uint8_t headerLength, uint8_t *p_data, uint8_t dataLength);
void WaitForMgmtResponse(uint8_t expectedSubtype, uint8_t freeAction);
void WaitForMgmtResponseAndReadData(uint8_t expectedSubtype, uint8_t numDataBytes, uint8_t startIndex, uint8_t *p_data);

INLINE void ClearMgmtConfirmMsg(void);

#ifdef __cplusplus
}
#endif

#endif /* __WF_MGMT_MSG_H */

