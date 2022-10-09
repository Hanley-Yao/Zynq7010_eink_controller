/*******************************************************************************
 MRF24WG External Interrupt Stub Functions

  Summary: Functions to control MRF24WG External Interrupt.

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
// board-specific includes
#include <NetworkProfile.x>
#include "../ud_inc/shared/wf_universal_driver.h"

/*****************************************************************************
  Function:
    void WF_EintInit(void);

  Summary:
    Configure host processor external interrupt.  This line is asserted low by
    MRF24WG.

  Description:
    Called by Universal Driver during initialization.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_EintInit(void)
{
    WIFI_IECxCLR = WIFI_INT_MASK;       // disable INT1 interrupt

    // configure INT1 pin
    WF_INT_IO       = 1;                // set the level of I/O pin high to deassert interrupt (no pullup on board)
    WF_INT_TRIS     = 1;                // configure pin as an input
    WIFI_INT_EDGE   = 0;                // falling edge triggered

    // ensure the interrupt is cleared
    WIFI_IFSxCLR    = WIFI_INT_MASK;    // clear INT1IF bit (clears any pending interrupt)

    // set INT1 interrupt priority and subpriority fields (INT1IP and INT1IS fields)
//    IPC1CLR    = 0xFF000000;      // first clear priority and subpriority fields
//    IPC1SET    = 0x0C000000;      // set INT1 priority=3, subpriority=0
    WIFI_IPC_IP = WF_IPL;           // set priority=3
    WIFI_IPC_IS = WF_SUB_IPL;       // sub priority=0

    // enable the interrupt
    WIFI_IECxSET    = WIFI_INT_MASK;      // enable INT1
}

/*****************************************************************************
  Function:
    void WF_EintEnable(void);

  Summary:
    Enables the MRF24WG external interrupt

  Description:
    Called by Universal Driver during normal operations to enable the MRF24WG
    external interrupt.  
 
    Note: When using level-triggered interrupts it is possible that host MCU
          could miss a falling edge; this can occur because during normal
          operations as the Universal Driver disables the external interrupt for
          short periods.  If the MRF24WG asserts the interrupt line while the
          interrupt is disabled the falling edge won't be detected.  So, a
          check must be made to determine if an interrupt is pending; if so, the
          interrupt must be forced.

          This is not an issue for level-triggered interrupts.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_EintEnable(void)
{
    // PIC32 uses level-triggered interrupts, so it is possible the Universal Driver
    // may have temporarily disabled the external interrupt, and then missed the 
    // falling edge when the MRF24WG asserted the interrupt line.  The code below
    // checks for this condition and forces the interrupt if needed.
    
    // if interrupt line is low, then PIC32 may have missed the falling edge
    // while the interrupt was disabled.
    if ( WF_INT_IO == 0 )
    {
        // Need to force the interrupt for two reasons:
        //   1) there is an event that needs to be serviced
        //   2) MRF24WG won't generate another falling edge until the interrupt
        //      is processed.
        WIFI_IFSxSET = WIFI_INT_MASK; // this will force the INT1 interrupt as soon as we
                             // we enabled it below.
    }

    /* enable the external interrupt */
    WIFI_IECxSET = WIFI_INT_MASK;
}

/*****************************************************************************
  Function:
    void WF_EintDisable(void);

  Summary:
    Disables the MRF24WG external interrupt

  Description:
    Called by Universal Driver during normal operations to disable the MRF24WG
    external interrupt.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_EintDisable(void)
{
    WIFI_IECxCLR = WIFI_INT_MASK;
}

/*****************************************************************************
  Function:
    bool WF_isEintDisabled(void);

  Summary:
    Determines if the external interrupt is disabled

  Description:
    Called by Universal Driver during normal operations to check if the current
    state of the external interrupt is disabled.

 Parameters:
    None

  Returns:
    True if interrupt is disabled, else False

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
bool WF_isEintDisabled(void)
{
    return (WIFI_INT_IE == 0);
}

/*****************************************************************************
  Function:
    bool WF_isEintPending(void);

  Summary:
    Determines if the external interrupt is pending.

  Description:
    Called by Universal Driver during normal operations to check if an external
    interrupt is pending.

 Parameters:
    None

  Returns:
    True if interrupt is pending, else False

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
bool WF_isEintPending(void)
{
    // if interrupt line is low, but interrupt request has not occurred
    return(((WF_INT_IO == 0) && (WIFI_INT_IF == 0)));
}


/*****************************************************************************
  Function:
    void _WFInterrupt(void);

  Summary:
    MRF24WG external interrupt handler

  Description:
    This interrupt handler should:
        1) ensure the interrupt is disabled upon exit (Universal Driver will reenable it)
        1) clear the interrupt
        2) call WFEintHandler()

 Parameters:
    None

  Returns:
    None

  Remarks:
    None
*****************************************************************************/
#if defined(__PIC32MZXX__)
void __attribute((interrupt(WF_IPL_ISR), at_vector(WF_INT_VEC), nomips16)) _WFInterrupt(void)
#else
void __attribute((interrupt(WF_IPL_ISR), vector(WF_INT_VEC), nomips16)) _WFInterrupt(void)
#endif
{
    // clear EINT
    WIFI_IFSxCLR = WIFI_INT_MASK;        // clear the interrupt
    WIFI_IECxCLR = WIFI_INT_MASK;        // disable external interrupt
    WF_EintHandler();           // call Univeral Driver handler function
}


