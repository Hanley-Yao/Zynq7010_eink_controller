/*******************************************************************************
 MRF24WG Initialization

  Summary: Contains functions pertaining Universal Driver and MRF24WG
           initialization.

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

extern uint32_t SYSGetMilliSecond(void);

//==============================================================================
//                                  CONSTANTS
//==============================================================================
// MRF24WG reset state machine states
enum
{
    MRF24WG_RESET_START                = 0,
    MRF24WG_RESET_WAIT_FOR_HW_RESET    = 1,
    MRF24WG_RESET_WAIT_FOR_MRF24W_INIT = 2,
    MRF24WG_RESET_FAILED               = 3,
    MRF24WG_RESET_SUCCESSFUL           = 4,
};

#define WF_INT_DISABLE ((uint8_t)0)
#define WF_INT_ENABLE  ((uint8_t)1)


//==============================================================================
//                                  LOCAL GLOBALS
//==============================================================================
uint8_t g_mrf24wgResetState;

//==============================================================================
//                                  LOCAL FUNCTION PROTOTYPES
//==============================================================================
static void     Init_Interrupts(void);
static void     HostInterrupt2RegInit(uint16_t hostIntMaskRegMask, uint8_t  state);
static void     HostInterruptRegInit(uint8_t hostIntrMaskRegMask, uint8_t state);
static uint32_t CompleteInitialization(void);

extern void WF_SetTxDataConfirm(uint8_t state);

/*****************************************************************************
  Function:
    void WF_Init(void)

  Summary:
    Initializes the MRF24WG for operations

  Description:
    Must be called before any other WiFi API calls.  This function starts the
    initialization sequence, which is in two stages:
        Stage 1: the actions in this function
        Stage 2: waiting for the MRF24WG reset and initialization to complete.

    Stage 2 occurs in the ChipResetStateMachine() function which is called from
    WF_Task.  When Stage 2 completes, the WF_INITIALIZATION_EVENT occurs.

 Parameters:
    None

  Returns:
    None

  Remarks:
    None
*****************************************************************************/
void WF_Init(void)
{
    uint32_t    tStart = 0;

    UdStateInit();      // initialize internal state machine
    
    WF_SpiInit();       // initialize the SPI interface
    WF_GpioInit();      // initialize HIBERNATE and RESET I/O lines
    WF_TimerInit();     // initialize and start the 1ms timer
    EventQInit();       // initialize WiFi event queue

    // take chip out of hibernate and out of reset; must be done before calling ResetPll()
    WF_GpioSetHibernate(WF_HIGH);  // Toggle the module into and then out of hibernate
    tStart = SYSGetMilliSecond();
    while(SYSGetMilliSecond() - tStart <= 2);
    WF_GpioSetHibernate(WF_LOW);
    tStart = SYSGetMilliSecond();
    while(SYSGetMilliSecond() - tStart <= 300);


    WF_GpioSetReset(WF_LOW);       // Toggle the module into and out of reset
    tStart = SYSGetMilliSecond();
    while(SYSGetMilliSecond() - tStart <= 2);
    WF_GpioSetReset(WF_HIGH);
    tStart = SYSGetMilliSecond();
    while(SYSGetMilliSecond() - tStart <= 5);


    // MRF24WG silicon work-around -- needed for A1 silicon to initialize PLL values correctly
    ResetPll();

    ClearMgmtConfirmMsg();    // no mgmt response messages received
    
    g_mrf24wgResetState = MRF24WG_RESET_START;

}

/*****************************************************************************
  Function:
    void ChipResetStateMachine(void)

  Summary:
    State machine to complete the MRF24WG initialization sequence.

  Description:
    Called from WF_Task().  Cycles thru the states needed to perform the MRF24WG
    module reset and initialization.  Upon the state machine completing, it
    triggers the WF_INITIALIZATION_EVENT.

 Parameters:
    None

  Returns:
    None

  Remarks:
    None
*****************************************************************************/
void ChipResetStateMachine(void)
{
   uint32_t elapsedTime;
   uint16_t value;
   static uint32_t startTime;
   uint16_t errorCode;

    switch (g_mrf24wgResetState)
    {
        //--------------------
        case MRF24WG_RESET_START:
        //--------------------
            UdSetInitInvalid(); // init not valid until it gets through this state machine

            // clear the power bit to disable low power mode on the MRF24W
            Write16BitWFRegister(WF_PSPOLL_H_REG, 0x0000);

            // Set HOST_RESET bit in register to put device in reset
            Write16BitWFRegister(WF_HOST_RESET_REG, Read16BitWFRegister(WF_HOST_RESET_REG) | WF_HOST_RESET_MASK);

            // Clear HOST_RESET bit in register to take device out of reset
            Write16BitWFRegister(WF_HOST_RESET_REG, Read16BitWFRegister(WF_HOST_RESET_REG) & ~WF_HOST_RESET_MASK);

            startTime = WF_TimerRead();
            g_mrf24wgResetState = MRF24WG_RESET_WAIT_FOR_HW_RESET;
            break;

        //--------------------------------
        case MRF24WG_RESET_WAIT_FOR_HW_RESET:
        //--------------------------------
            Write16BitWFRegister(WF_INDEX_ADDR_REG, WF_HW_STATUS_REG);
            value = Read16BitWFRegister(WF_INDEX_DATA_REG);
            if ((value & WF_HW_STATUS_NOT_IN_RESET_MASK) == WF_HW_STATUS_NOT_IN_RESET_MASK)
            {
                if (value == 0xffff)
                {
                    // typically read all 1's when SPI not connected
                    EventEnqueue(WF_EVENT_INITIALIZATION, WF_INIT_ERROR_SPI_NOT_CONNECTED);
                    g_mrf24wgResetState = MRF24WG_RESET_FAILED;
                }
                else
                {
                    startTime = WF_TimerRead();
                    g_mrf24wgResetState = MRF24WG_RESET_WAIT_FOR_MRF24W_INIT;
                }
            }
            // else still waiting
            else
            {
                // if timed out waiting for MRF24WG to come out of reset
                elapsedTime = GetElapsedTime(startTime, WF_TimerRead());
                if (elapsedTime > 1000) // 1000
                {
                    EventEnqueue(WF_EVENT_INITIALIZATION, WF_INIT_ERROR_RESET_TIMEOUT);
                    g_mrf24wgResetState = MRF24WG_RESET_FAILED;
                }
            }
            break;

        //-----------------------------------
        case MRF24WG_RESET_WAIT_FOR_MRF24W_INIT:
        //-----------------------------------
            // read FIFO byte count; if > 0 than MRF24WG reset complete
            value = Read16BitWFRegister(WF_HOST_WFIFO_BCNT0_REG) & 0x0fff;;  // read FIFO byte count
            if (value > 0)
            {
                // generate event
                errorCode = CompleteInitialization();
                if (errorCode == 0)
                {
                    UdSetInitValid();
                    EventEnqueue(WF_EVENT_INITIALIZATION, WF_INIT_SUCCESSFUL); // signal init successful event
                    g_mrf24wgResetState = MRF24WG_RESET_SUCCESSFUL;
                }
                else
                {
                    EventEnqueue( ((uint8_t)errorCode >> 16), (uint32_t)errorCode);
                    g_mrf24wgResetState = MRF24WG_RESET_FAILED;
                }
            }
            // else still waiting
            else
            {
                // if timed out waiting for MRF24WG init
                elapsedTime = GetElapsedTime(startTime, WF_TimerRead());
                if (elapsedTime > 2000) // 2000ms
                {
                    // generate event
                    EventEnqueue(WF_EVENT_INITIALIZATION, WF_INIT_ERROR_INIT_TIMEOUT);
                    g_mrf24wgResetState = MRF24WG_RESET_FAILED;
                }
            }
            break;

        //------------------------
        case MRF24WG_RESET_FAILED:
        //------------------------
            break;  // just stay in this state until the next reset

        //----------------------------
        case MRF24WG_RESET_SUCCESSFUL:
        //----------------------------
            break;  // just stay in this state until the next reset

    } // end switch
 }


/*****************************************************************************
  Function:
    uint32_t CompleteInitialization(void)

  Summary:
    Completes the MRF24WG intitialization after the MRF24WG has been reset and is
    ready for operations.
 
  Description:
    Called from ChipResetStateMachine().

 Parameters:
    None

  Returns:
    0 if successful, else the upper 16-bits contains the event type and the lower
    16 bits contains the event data

  Remarks:
    None
*****************************************************************************/
static uint32_t CompleteInitialization(void)
{
    t_deviceInfo deviceInfo;
    uint32_t errorCode = UD_SUCCESS;

    Init_Interrupts();                              // Initialize MRF24WG interrupts
    RawInit();                                      // initialize RAW driver
    WFEnableMRF24WB0MMode();                        // legacy, but still needed
    WF_DeviceInfoGet(&deviceInfo);                   // get MRF24WG module version numbers
    if (deviceInfo.deviceType == WF_UNKNOWN_DEVICE)
    {
        errorCode = (((uint32_t)WF_EVENT_ERROR << 16) | (uint32_t)UD_ERROR_UNKNOWN_DEVICE);
    }
    else if (deviceInfo.deviceType == WF_MRF24WB_DEVICE)
    {
        errorCode = (((uint32_t)WF_EVENT_ERROR << 16) | (uint32_t)UD_ERROR_MRF24WB_NOT_SUPPORTED);
    }

    WF_SetTxDataConfirm(WF_DISABLED);     // Disable Tx Data confirms (from the MRF24W) 
    WF_CPCreate();                        // create a connection profile, get its ID and store it

    WF_PsPollDisable();
    ClearPsPollReactivate();

#if defined(WF_USE_SOFTWARE_MULTICAST_FILTER)
    EnableSWMulticastFilter();
#endif

    return errorCode;
}


/*****************************************************************************
  Function:
    void Init_Interrupts(void)

  Summary:
    Initializes interrupts generated by MRF24WG module

  Description:
    None

 Parameters:
    None

  Returns:
    None

  Remarks:
    None
*****************************************************************************/
static void Init_Interrupts(void)
{
    uint8_t  mask8;
    uint16_t mask16;

    // disable the interrupts gated by the 16-bit host int register
    HostInterrupt2RegInit(WF_HOST_2_INT_MASK_ALL_INT, (uint16_t)WF_INT_DISABLE);

    // disable the interrupts gated the by main 8-bit host int register
    HostInterruptRegInit(WF_HOST_INT_MASK_ALL_INT, WF_INT_DISABLE);

    // Initialize the External Interrupt for the MRF24W allowing the MRF24W to interrupt
    // the Host from this point forward.
    WF_EintInit();
    WF_EintEnable();

    // enable the following MRF24W interrupts in the INT1 8-bit register
    mask8 = (WF_HOST_INT_MASK_FIFO_1_THRESHOLD |     // Mgmt Rx Msg interrupt
             WF_HOST_INT_MASK_FIFO_0_THRESHOLD |     // Data Rx Msg interrupt
             WF_HOST_INT_MASK_RAW_0_INT_0      |     // RAW0 Move Complete (Data Rx) interrupt
             WF_HOST_INT_MASK_RAW_1_INT_0      |     // RAW1 Move Complete (Data Tx) interrupt
             WF_HOST_INT_MASK_INT2);                 // Interrupt 2 interrupt                  
    HostInterruptRegInit(mask8, WF_INT_ENABLE);

    // enable the following MRF24W interrupts in the INT2 16-bit register
    mask16 = (WF_HOST_INT_MASK_RAW_2_INT_0     |    // RAW2 Move Complete (Mgmt Rx) interrupt
              WF_HOST_INT_MASK_RAW_3_INT_0     |    // RAW3 Move Complete (Mgmt Tx) interrupt
              WF_HOST_INT_MASK_RAW_4_INT_0     |    // RAW4 Move Complete (Scratch) interrupt
              WF_HOST_INT_MASK_RAW_5_INT_0     |    // RAW5 Move Complete (Scratch) interrupt 
              WF_HOST_INT_MASK_MAIL_BOX_0_WRT);     // MRF24WG assertion interrupt
    HostInterrupt2RegInit(mask16, WF_INT_ENABLE);

}

/*****************************************************************************
 * FUNCTION: HostInterrupt2RegInit
 *
 * RETURNS: N/A
 *
 * PARAMS:
 *      hostIntrMaskRegMask - The bit mask to be modified.
 *      state               - One of WF_INT_DISABLE, WF_INT_ENABLE where
 *                             Disable implies clearing the bits and enable sets
 *                             the bits.
 *
 *
 *  NOTES: Initializes the 16-bit Host Interrupt register on the WiFi device with the
 *          specified mask value either setting or clearing the mask register as
 *          determined by the input parameter state.
 *****************************************************************************/
static void HostInterrupt2RegInit(uint16_t hostIntMaskRegMask, uint8_t  state)
{
    uint16_t int2MaskValue;

    /* Host Int Register is a status register where each bit indicates a specific event  */
    /* has occurred. In addition, writing a 1 to a bit location in this register clears  */
    /* the event.                                                                        */

    /* Host Int Mask Register is used to enable those events activated in Host Int Register */
    /* to cause an interrupt to the host                                                    */

    /* read current state of int2 mask reg */
    int2MaskValue = Read16BitWFRegister(WF_HOST_INTR2_MASK_REG);

    /* if caller is disabling a set of interrupts */
    if (state == WF_INT_DISABLE)
    {
        /* zero out that set of interrupts in the interrupt mask copy */
        int2MaskValue &= ~hostIntMaskRegMask;
    }
    /* else caller is enabling a set of interrupts */
    else
    {
        /* set to 1 that set of interrupts in the interrupt mask copy */
        int2MaskValue |= hostIntMaskRegMask;
    }

    /* write out new interrupt mask value */
    Write16BitWFRegister(WF_HOST_INTR2_MASK_REG, int2MaskValue);

    /* ensure that pending interrupts from those updated interrupts are cleared */
    Write16BitWFRegister(WF_HOST_INTR2_REG, hostIntMaskRegMask);

}

/*****************************************************************************
 * FUNCTION: HostInterruptRegInit
 *
 * RETURNS: N/A
 *
 * PARAMS:
 *      hostIntrMaskRegMask - The bit mask to be modified.
 *      state -  one of WF_EXINT_DISABLE, WF_EXINT_ENABLE where
 *                Disable implies clearing the bits and enable sets the bits.
 *
 *
 *  NOTES: Initializes the 8-bit Host Interrupt register on the MRF24W with the
 *      specified mask value either setting or clearing the mask register
 *      as determined by the input parameter state.  The process requires
 *      2 spi operations which are performed in a blocking fashion.  The
 *      function does not return until both spi operations have completed.
 *****************************************************************************/
static void HostInterruptRegInit(uint8_t hostIntrMaskRegMask, uint8_t state)
{
    uint8_t hostIntMaskValue;

    /* Host Int Register is a status register where each bit indicates a specific event  */
    /* has occurred. In addition, writing a 1 to a bit location in this register clears  */
    /* the event.                                                                        */

    /* Host Int Mask Register is used to enable those events activated in Host Int Register */
    /* to cause an interrupt to the host                                                    */

    /* read current state of Host Interrupt Mask register */
    hostIntMaskValue = Read8BitWFRegister(WF_HOST_MASK_REG);

    /* if caller is disabling a set of interrupts */
    if (state == WF_INT_DISABLE)
    {
        /* zero out that set of interrupts in the interrupt mask copy */
        hostIntMaskValue = (hostIntMaskValue & ~hostIntrMaskRegMask);
    }
    /* else caller is enabling a set of interrupts */
    else
    {
        /* set to 1 that set of interrupts in the interrupt mask copy */
        hostIntMaskValue = (hostIntMaskValue & ~hostIntrMaskRegMask) | hostIntrMaskRegMask;
    }

    /* write out new interrupt mask value */
    Write8BitWFRegister(WF_HOST_MASK_REG, hostIntMaskValue);

    /* ensure that pending interrupts from those updated interrupts are cleared */
    Write8BitWFRegister(WF_HOST_INTR_REG, hostIntrMaskRegMask);
}
