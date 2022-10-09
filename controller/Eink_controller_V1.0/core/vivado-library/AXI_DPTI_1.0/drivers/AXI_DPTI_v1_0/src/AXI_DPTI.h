/******************************************************************************
 * @file AXI_DPTI.h
 * AXI DPTI header.
 *
 * @author Sergiu Arpadi
 *
 * @date 2016-Sep-20
 *
 * @copyright
 * (c) 2016 Copyright Digilent Incorporated
 * All Rights Reserved
 *
 * This program is free software; distributed under the terms of BSD 3-clause
 * license ("Revised BSD License", "New BSD License", or "Modified BSD License")
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
 *    of its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 * @desciption
 * Contains AXI DPTI definitions and prototypes function.
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who            Date         Changes
 * ----- -------------- ------------ -----------------------------------------------
 * 1.00  Sergiu Arpadi  2016-Sep-20  First release
 *
 * </pre>
 *
 *****************************************************************************/

#ifndef AXI_DPTI_H
#define AXI_DPTI_H

#ifdef __cplusplus
extern "C" {
#endif

/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

#define DPTI_LENGTH_REG_OFFSET 0
#define DPTI_CONTROL_REG_OFFSET 4
#define DPTI_STATUS_REG_OFFSET 8

#define DPTI_TO_STREAM 2
#define STREAM_TO_DPTI 1

#define DPTI_CR_RESET_MASK (1<<2)
#define DPTI_SR_REINIT_MASK (1<<1)
#define DPTI_SR_TX_LEN_EMPTY_MASK (1<<0)
#define DPTI_SR_RX_LEN_EMPTY_MASK (1<<16)


/************************** Function Prototypes ****************************/
 
XStatus DPTI_SimpleTransfer (u32 BaseAddress, u8 Direction, u32 TransferLength);
XStatus AXI_DPTI_Reg_SelfTest(u32 baseaddr);
XStatus DPTI_Reset(u32 BaseAddress);

#ifdef __cplusplus
}
#endif
#endif // AXI_DPTI_H
