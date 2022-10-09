/*******************************************************************************
 MRF24WG power control

  Summary: Functions to controll MRF24WG power

  Description: Same as summary.
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

//==============================================================================
//                                  DEFINES
//==============================================================================
#define REG_ENABLE_LOW_POWER_MASK   ((uint16_t)(0x01))
#define REG_DISABLE_LOW_POWER_MASK  ((uint16_t)(0x00))

//==============================================================================
//                                  LOCAL DATA TYPES
//==============================================================================
/* Enumeration of valid values for WFSetPowerSaveMode() */
typedef enum
{
    PS_POLL_ENABLED = 0,    /* power save mode enabled  */
    PS_POLL_DISABLED        /* power save mode disabled */
} t_WFPsPwrMode;

typedef struct WFPwrModeReq
{
    uint8_t mode;
    uint8_t wake;
    uint8_t rcvDtims;
    uint8_t reserved;            /* pad byte */
} t_WFPwrModeReq;

//==============================================================================
//                                  LOCAL GLOBALS
//==============================================================================
static uint8_t g_powerSaveState = WF_PS_OFF;
static bool    g_reactivatePsPoll = false;

//==============================================================================
//                                  LOCAL FUNCTION PROTOTYPES
//==============================================================================
static void SendPowerModeMsg(t_WFPwrModeReq *p_powerMode);
static void PowerStateSet(uint8_t powerSaveState);
static INLINE void SetPsPollReactivate(void);
extern void SetListenInterval(uint16_t listenInterval);
extern void SetDtimInterval(uint16_t dtimInterval);

/*******************************************************************************
  Function:
    void WF_PsPollEnable(t_psPollContext *p_context)

  Summary:
    Enables PS Poll mode.

  Description:
    Enables PS Poll mode.  PS-Poll (Power-Save Poll) is a mode allowing for
    longer battery life.  The MRF24W coordinates with the Access Point to go
    to sleep and wake up at periodic intervals to check for data messages, which
    the Access Point will buffer.  The listenInterval in the Connection
    Algorithm defines the sleep interval.  By default, PS-Poll mode is disabled.

    When PS Poll is enabled, the WF Host Driver will automatically force the
    MRF24W to wake up each time the Host sends Tx data or a control message
    to the MRF24W.  When the Host message transaction is complete the
    MRF24W driver will automatically re-enable PS Poll mode.

    When the application is likely to experience a high volume of data traffic
    then PS-Poll mode should be disabled for two reasons:
    1. No power savings will be realized in the presence of heavy data traffic.
    2. Performance will be impacted adversely as the WiFi Host Driver
        continually activates and deactivates PS-Poll mode via SPI messages.

  Precondition:
    MACInit must be called first.

  Parameters:
    p_context -  pointer to ps poll context

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
void WF_PsPollEnable(t_psPollContext *p_context)
{
    t_WFPwrModeReq   pwrModeReq;

    // if not currently connected then return
    if(UdGetConnectionState() != CS_CONNECTED)
    {
        EventEnqueue(WF_EVENT_ERROR, UD_INVALID_PS_POLL_ERROR);
        return;
    }

    // save the Ps-Poll context
    UdEnablePsPoll(p_context);

    SetListenInterval(p_context->listenInterval);
    SetDtimInterval(p_context->dtimInterval);

    // fill in request structure and send message to MRF24WG
    pwrModeReq.mode     = PS_POLL_ENABLED;
    pwrModeReq.wake     = 0;
    pwrModeReq.rcvDtims = p_context->useDtim;
    SendPowerModeMsg(&pwrModeReq);

    WFConfigureLowPowerMode(WF_LOW_POWER_MODE_ON);

    if (p_context->useDtim)
    {
        PowerStateSet(WF_PS_PS_POLL_DTIM_ENABLED);
    }
    else
    {
        PowerStateSet(WF_PS_PS_POLL_DTIM_DISABLED);
    }
}

/*******************************************************************************
  Function:
    void WF_PsPollDisable(void)

  Summary:
    Disables PS-Poll mode.

  Description:
    Disables PS Poll mode.  The MRF24W will stay active and not go sleep.

  Precondition:
    MACInit must be called first.

  Parameters:
    None.

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
void WF_PsPollDisable(void)
{
    UdDisablePsPoll();

    t_WFPwrModeReq   pwrModeReq;

    pwrModeReq.mode     = PS_POLL_DISABLED;
    pwrModeReq.wake     = 1;
    pwrModeReq.rcvDtims = 1;
    SendPowerModeMsg(&pwrModeReq);

    WFConfigureLowPowerMode(WF_LOW_POWER_MODE_OFF);
    PowerStateSet(WF_PS_OFF);
}


/*******************************************************************************
  Function:
    void WFConfigureLowPowerMode(uint8_t action)

  Summary:
    Driver function to configure PS Poll mode.

  Description:
    This function is only used by the driver, not the application.  This
    function, other than at initialization, is only used when the application
    has enabled PS-Poll mode.  This function is used to temporarily deactivate
    PS-Poll mode when there is mgmt or data message tx/rx and then, when message
    activity has ceased, to again activate PS-Poll mode.

  Precondition:
    MACInit must be called first.

  Parameters:
    action - Can be either:
             * WF_LOW_POWER_MODE_ON
             * WF_LOW_POWER_MODE_OFF

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
void WFConfigureLowPowerMode(uint8_t action)
{
    uint16_t lowPowerStatusRegValue;

    //-------------------------------------
    // if activating PS-Poll mode on MRF24W
    //-------------------------------------
    if (action == WF_LOW_POWER_MODE_ON)
    {
//        dbgprintf("Enable PS\n");
        Write16BitWFRegister(WF_PSPOLL_H_REG, REG_ENABLE_LOW_POWER_MASK);
    }
    //---------------------------------------------------------------------------------------------
    // else deactivating PS-Poll mode on MRF24W (taking it out of low-power mode and waking it up)
    //---------------------------------------------------------------------------------------------
    else // action == WF_LOW_POWER_MODE_OFF
    {
//        dbgprintf("Disable PS\n");
        Write16BitWFRegister(WF_PSPOLL_H_REG, REG_DISABLE_LOW_POWER_MASK);

        /* poll the response bit that indicates when the MRF24W has come out of low power mode */
        do
        {
            // set the index register to the register we wish to read
            Write16BitWFRegister(WF_INDEX_ADDR_REG, WF_SCRATCHPAD_1_REG);

            // read register
            lowPowerStatusRegValue = Read16BitWFRegister(WF_INDEX_DATA_REG);
        } while (lowPowerStatusRegValue & REG_ENABLE_LOW_POWER_MASK);
    }
}

/*******************************************************************************
  Function:
    void WF_Hibernate()

  Summary:
    Puts the MRF24W into hibernate mode.

  Description:
    Enables Hibernate mode on the MRF24W, which effectively turns off the
    device for maximum power savings.

    MRF24W state is not maintained when it transitions to hibernate mode.
    To remove the MRF24W from hibernate mode call WF_Init().

 Parameters:
    None.

  Returns:
    None.

  Remarks:
  

  *****************************************************************************/
void WF_Hibernate(void)
{
    WF_GpioSetHibernate(WF_HIGH);
    PowerStateSet(WF_PS_HIBERNATE);
}


void WF_TxPowerMaxSet(uint8_t maxTxPower)
{
    (void)(maxTxPower);   // prevent unused warning
#if defined(WF_ERROR_CHECKING)
    uint32_t errorCode = udSetTxPowerMax(maxTxPower);
    if (errorCode != UD_SUCCESS)
    {
        EventEnqueue(WF_EVENT_ERROR, errorCode);
        return;
    }
#endif
}

void WF_TxPowerFactoryMaxGet(uint8_t *p_maxPower)
{
    *p_maxPower = GetFactoryMax();
}



static void SendPowerModeMsg(t_WFPwrModeReq *p_powerMode)
{
    uint8_t hdr[2];

    hdr[0] = WF_MGMT_REQUEST_TYPE;
    hdr[1] = WF_SET_POWER_MODE_SUBTYPE;

    SendMgmtMsg(hdr,
                sizeof(hdr),
               (uint8_t *)p_powerMode,
               sizeof(t_WFPwrModeReq));

    /* wait for mgmt response, free buffer after it comes in (no data to read) */
    WaitForMgmtResponse(WF_SET_POWER_MODE_SUBTYPE, FREE_MGMT_BUFFER);
}

/*******************************************************************************
  Function:
    void SetPowerSaveState(UINT8 powerSaveState)

  Summary:
    Sets the desired power save state of the MRF24W.

  Description:

  Precondition:
    MACInit must be called first.

  Parameters:
    powerSaveState - Value of the power save state desired.

    <table>
    Value                       Definition
    -----                       ----------
    WF_PS_HIBERNATE             MRF24W in hibernate state
    WF_PS_PS_POLL_DTIM_ENABLED  MRF24W in PS-Poll mode with DTIM enabled
    WF_PS_PS_POLL_DTIM_DISABLED MRF24W in PS-Poll mode with DTIM disabled
    WF_PS_OFF              MRF24W is not in any power-save state
    </table>

  Returns:
    None.

  Remarks:
    None.
  *****************************************************************************/
static void PowerStateSet(uint8_t powerSaveState)
{
    g_powerSaveState = powerSaveState;
}

INLINE void WF_PowerStateGet(uint8_t *p_powerState)
{
    *p_powerState = g_powerSaveState;
}

void EnsureWFisAwake(void)
{
    // if the application has enabled PS mode
    if ((g_powerSaveState == WF_PS_PS_POLL_DTIM_ENABLED) || (g_powerSaveState == WF_PS_PS_POLL_DTIM_DISABLED))
    {
        WFConfigureLowPowerMode(WF_LOW_POWER_MODE_OFF);     // wake up MRF24WG
        SetPsPollReactivate();                              // set flag to put it back in PS-Poll when appropriate
    }
}

static INLINE void SetPsPollReactivate(void)
{
    g_reactivatePsPoll = true;
}

INLINE bool isPsPollNeedReactivate(void)
{
    return g_reactivatePsPoll;
}

INLINE void ClearPsPollReactivate(void)
{
    g_reactivatePsPoll = false;
}
