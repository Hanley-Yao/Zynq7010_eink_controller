/*******************************************************************************
 MRF24WG Data Tx/Rx 

  Summary: Contains functions pertaining to WiFi data Tx/Rx

  Description: Contains functions that allocate and deallocate Tx/Rx data messages
               as well as functions that perform Tx/Rx processing.
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

#define WF_TX_PREAMBLE_SIZE (4)
#define ETHER_HEADER_SIZE   (16)    // 6 bytes dest address, 6 bytes src address, 2 bytes for type field
#define ENC_PREAMBLE_OFFSET (14)

//==============================================================================
//                                  LOCAL DATA TYPES
//==============================================================================
typedef struct
{
    uint8_t type;
    uint8_t subType;
} t_rxPreamble;

//==============================================================================
//                                  LOCAL GLOBALS
//==============================================================================
// will be overwriting the ethernet header source address with the snap header
const uint8_t snapHdr[6] = {SNAP_VAL, SNAP_VAL, SNAP_CTRL_VAL, SNAP_TYPE_VAL, SNAP_TYPE_VAL, SNAP_TYPE_VAL};
bool g_HostRAWPacketRx;


INLINE void SignalPacketRx(void)
{
    g_HostRAWPacketRx = true;
}

INLINE bool isPacketRx(void)
{
    return g_HostRAWPacketRx;
}

INLINE void ClearPacketRx(void)
{
    g_HostRAWPacketRx = false;
}

// called from WiFi_Task
void  RxPacketCheck(void)
{
    if (isPacketRx())
    {
        ClearPacketRx();
        WF_ProcessRxPacket();
    }
}

// packetSize includes the ethernet header bytes
bool WF_TxPacketAllocate(uint16_t packetSize)
{
    bool result = false;
    uint32_t startTime;

    EnsureWFisAwake();

    startTime = WF_TimerRead();
    while ( GetElapsedTime(startTime, WF_TimerRead()) < 20)
    {
        // allocate an extra 4 bytes for WiFi message preamble
        result = AllocateDataTxBuffer(packetSize + WF_TX_PREAMBLE_SIZE);
        if (result == true)
        {
            // set the RAW index at 4 to leave room for internal 4 byte header.  Ethernet
            // packet data starts at index 4.
            RawSetIndex(RAW_DATA_TX_ID, 4);
            result = true;
            break;
        }
    }

    return result;
}

void WF_TxPacketCopy(uint8_t *p_buf, uint16_t length)
{
   RawSetByte(RAW_DATA_TX_ID, p_buf, length);
}

void WF_TxPacketTransmit(uint16_t packetSize)
{
    /* create internal preamble */
    uint8_t txDataPreamble[4] = {WF_DATA_REQUEST_TYPE, WF_STD_DATA_MSG_SUBTYPE, 1, 0};

    EnsureWFisAwake();

    // write out internal preamble, starting at index 0 in the raw window
    RawWrite(RAW_DATA_TX_ID, 0, sizeof(txDataPreamble), txDataPreamble);

    // overwrite the Ethernet source address in Tx packet with SNAP header 
    // (starts at index 10 within packet, after 4 bytes of preamble and 6 bytes of dest address)
    RawWrite(RAW_DATA_TX_ID, sizeof(txDataPreamble) + WF_MAC_ADDRESS_LENGTH, SNAP_SIZE, snapHdr);

    // Notify WiFi device that there is a transmit frame to send.  The frame will
    // be automatically deallocated after RF transmission is completed.
    RawMove(RAW_DATA_TX_ID, RAW_MAC, false, packetSize + sizeof(txDataPreamble));

    // this raw window is logically no longer mounted.  The WiFi chip will
    // automatically deallocate after RF transmission.
    SetRawDataWindowState(RAW_DATA_TX_ID, WF_RAW_UNMOUNTED);
}

uint16_t WF_RxPacketLengthGet(void)
{
    uint16_t len;
    t_rxPreamble rxPreamble;

    /* Mount Read FIFO to RAW Rx window.  Allows use of RAW engine to read rx data packet. */
    /* Function call returns number of bytes in the data packet.                           */
    len = RawMountRxBuffer(RAW_DATA_RX_ID);

    // TODO: length must never be 0

    // read the data frame internal preamble (type and subtype) to verify that we did, in
    // fact, mount an Rx data packet.  This read auto-increments the raw index to the first
    // actual data byte in the frame.
    RawGetByte(RAW_DATA_RX_ID, (uint8_t *)&rxPreamble, sizeof(t_rxPreamble));
    if (rxPreamble.type != WF_DATA_RX_INDICATE_TYPE)
    {
        EventEnqueue(WF_EVENT_ERROR, UD_INVALID_DATA_MSG);
        return 0;
    }

    // set raw pointer to start of 802.11 payload (start of Ethernet packet)
    RawSetIndex(RAW_DATA_RX_ID, sizeof(t_rxPreamble) + ENC_PREAMBLE_OFFSET);
    
    // now that buffer mounted it is safe to reenable interrupts, which were left disabled
    // in the WiFi interrupt handler.
    WF_EintEnable();

    return len - sizeof(t_rxPreamble) - ENC_PREAMBLE_OFFSET;
}

void WF_RxPacketDeallocate(void)
{
    DeallocateDataRxBuffer();
}

void WF_RxPacketCopy(uint8_t *p_buf, uint16_t length)
{
    RawGetByte(RAW_DATA_RX_ID, p_buf, length);
}

