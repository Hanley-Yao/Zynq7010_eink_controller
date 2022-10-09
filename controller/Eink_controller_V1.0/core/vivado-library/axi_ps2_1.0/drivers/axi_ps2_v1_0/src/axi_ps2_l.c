/******************************************************************************
 * @file axi_ps2_l.c
 *
 * @author Sergiu Arpadi
 *
 * @date 2017-May-17
 *
 * @copyright
 * (c) 2017 Copyright Digilent Incorporated
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
 *
 * @desciption
 * This file contains low-level driver functions that can be used to access the
 * device.  The user should refer to the hardware device specification for more
 * details of the device operation.
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who            Date         Changes
 * ----- -------------- ------------ -----------------------------------------------
 * 1.00  Sergiu Arpadi  2017-May-17  First release
 *
 * </pre>
 *
 *****************************************************************************/

/***************************** Include Files *********************************/

#include "axi_ps2_l.h"

/************************** Constant Definitions *****************************/

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

/************************** Variable Definitions *****************************/

/****************************************************************************/
/**
*
* This function sends a data byte to PS/2. This function operates in the
* polling mode and blocks until the data has been put into the Transmit
* Data register.
*
* @param	BaseAddress contains the base address of the PS/2 port.
* @param	Data contains the data byte to be sent.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
void axi_ps2_SendByte(u32 BaseAddress, u8 Data) {

	while (!axi_ps2_IsTxEmpty(BaseAddress)) {
	}

	axi_ps2_WriteReg(BaseAddress, axi_ps2_TX_DATA_OFFSET, Data);
}

/****************************************************************************/
/**
*
* This function receives a byte from PS/2. It operates in the polling mode
* and blocks until a byte of data is received.
*
* @param	BaseAddress contains the base address of the PS/2 port.
*
* @return	The data byte received by PS/2.
*
* @note		None.
*
*****************************************************************************/
u32 axi_ps2_RecvByte(u32 BaseAddress)
{
	while (axi_ps2_IsRxEmpty(BaseAddress)) {
	}

	return axi_ps2_ReadReg(BaseAddress, axi_ps2_RX_DATA_OFFSET);

}
