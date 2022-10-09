/*******************************************************************************
 MRF24WG Universal Driver Timer Stub Functions

  Summary: This module contains Timer functions needed by the Universal Driver.

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
#include <p32xxxx.h>
#include "../ud_inc/shared/wf_universal_driver.h"
#include "../../../DEIPcK/utility/System.h"

//==============================================================================
//                                  LOCAL GLOBALS
//==============================================================================
//static volatile uint32_t g_msCounter; // incremented each timer interrupt


#if 0
/*****************************************************************************
  Function:
    uint32_t WF_TimerInit(void);

  Summary:
    Configures a timer that increments a 32-bit counter every 1ms.

  Description:
    Called by Universal Driver during initialization to start a 1ms timer that
    will be used for various reasons.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_TimerInit(void)
{
    g_msCounter = 0;  // counter value that will be incremented every 1ms

    // Running with an 80MHz clock, so with prescaler at 64 the timer will
    // increment every (1/80MHz / 64), or 800nS.  With the load value set to
    // 1250 the timer interrupt will occur every (1250 * 800nS), or 1ms.

    // Configure Timer1 (16-bit timer) to increment every 1ms
    T1CONbits.TON   = 0;    // stop Timer1
    T1CONbits.TCKPS = 2;    // 1:64 prescale
    PR1             = 1250; // 16-bit period match value
    TMR1            = 0;    // clear the timer value

    // Enable Timer1 interrupt
    IPC1bits.T1IP = 2;                // Interrupt priority 2 (low)
    IFS0CLR       = _IFS0_T1IF_MASK;  // clear Timer1 interrupt
    IEC0SET       = _IEC0_T1IE_MASK;  // enable Timer1 interrupt

    // Start Timer1
    T1CONbits.TON = 1;
} 

/*****************************************************************************
  Function:
    uint32_t WF_TimerRead();

  Summary:
    Called by the Universal Driver for various timing operations.

  Description:
    Returns the current value of the 1ms timer.

 Parameters:
    None

  Returns:
    Current value of 1ms timer

  Remarks:
    None
*****************************************************************************/
uint32_t WF_TimerRead(void)
{
    uint32_t retValue;
    
    IEC0CLR = _IEC0_T1IE_MASK;  // Disable Timer1 interrupt
    retValue = g_msCounter;     // safely read the counter value
    IEC0SET = _IEC0_T1IE_MASK;  // Enable Timer1 interrupt

    return retValue;
}

/*****************************************************************************
  Function:
    Timer1 Interrupt Routine

  Summary:
    Executes every 1ms

  Description:
    This interrupt occurs every 1ms.  The interrupt simply increments the global
    32-bit counter and clears itself.

 Parameters:
    None

  Returns:
    None

  Remarks:
    None
*****************************************************************************/
void __attribute((interrupt(ipl2), vector(_TIMER_1_VECTOR), nomips16)) _Timer1Interrupt(void)
{
    ++g_msCounter;              // bump 1ms counter
    IFS0CLR = _IFS0_T1IF_MASK; 	// clear interrupt
}
#endif 


/*****************************************************************************
  Function:
    uint32_t WF_TimerInit(void);

  Summary:
    Configures a timer that increments a 32-bit counter every 1ms.

  Description:
    Called by Universal Driver during initialization to start a 1ms timer that
    will be used for various reasons.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_TimerInit(void)
{
}

/*****************************************************************************
  Function:
    uint32_t WF_TimerRead();

  Summary:
    Called by the Universal Driver for various timing operations.

  Description:
    Returns the current value of the 1ms timer.

 Parameters:
    None

  Returns:
    Current value of 1ms timer

  Remarks:
    None
*****************************************************************************/
uint32_t WF_TimerRead(void)
{
    return(SYSGetMilliSecond());
}
