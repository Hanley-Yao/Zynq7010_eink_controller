/*******************************************************************************
 MRF24WG Stub Functions

  Summary: This module contains prototypes for stub functions.

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

#ifndef __WF_STUBS_H
#define __WF_STUBS_H

#ifdef __cplusplus
extern "C" {
#endif


//== I/O Stub Function Protypes ========================================
//   Located in wf_io_stub.c
void WF_GpioInit(void);
void WF_IOSetChipSelect(uint8_t level);
void WF_GpioSetHibernate(uint8_t level);
void WF_GpioSetReset(uint8_t level);

//== MRF24WG SPI Stub Function Protypes ========================================
//   Located in wf_spi_stub.c
void WF_SpiInit(void);
void WF_SpiEnableChipSelect(void);
void WF_SpiDisableChipSelect(void);
void WF_SpiTxRx(const uint8_t *p_txBuf, uint16_t txLength, uint8_t *p_rxBuf, uint16_t rxLength);

//== MRF24WG External Interrupt Stub Function Protypes =========================
//   Located in wf_eint_stub.c
void WF_EintInit(void);
void WF_EintEnable(void);
void WF_EintDisable(void);
bool WF_isEintDisabled(void);
bool WF_isEintPending(void);
void WF_EintHandler(void);


//== MRF24WG 1ms Timer Stub Function Protypes ==================================
//   Located in wf_timer_stub.c
void     WF_TimerInit(void);
uint32_t WF_TimerRead(void);
uint64_t WF_TimerReadr(void);

//== MRF24WG Event Handler Stub Function Protypes ==============================
// Located in wf_event_stub.c
void WF_ProcessEvent(uint8_t eventType, uint32_t eventData);

#ifdef __cplusplus
}
#endif


#endif /* __WF_STUBS_H */

