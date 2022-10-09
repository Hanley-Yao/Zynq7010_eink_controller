/******************************************************************************
 * @file AXI_DPTI.c
 * AXI DPTI driver.
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
 * Contains AXI DPTI transfer request function.
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who            	Date         Changes
 * ----- -------------- 	------------ -----------------------------------------------
 * 1.00  Sergiu Arpadi  	2016-Sep-20  First release
 * 1.10  Thomas Kappenman	2020-Apr-28  Removed blocking call
 * </pre>
 *
 *****************************************************************************/

/***************************** Include Files *******************************/
#include "AXI_DPTI.h"
#include "xil_io.h"

/************************** Function Definitions ***************************/
XStatus DPTI_SimpleTransfer (u32 BaseAddress, u8 Direction, u32 TransferLength)
{
	u32 txLengthEmptyFlag, rxLengthEmptyFlag, StsReg, timeout=0;

	if (TransferLength > 8388607)
		return XST_FAILURE; // length is not a valid number
	else
	{
		StsReg = Xil_In32 (BaseAddress + DPTI_STATUS_REG_OFFSET);
		txLengthEmptyFlag = (StsReg & DPTI_SR_TX_LEN_EMPTY_MASK);
		rxLengthEmptyFlag = (StsReg & DPTI_SR_RX_LEN_EMPTY_MASK);

//		while (rxLengthEmptyFlag == 0 || txLengthEmptyFlag == 0)
//			{
//				StsReg = Xil_In32 (BaseAddress + DPTI_STATUS_REG_OFFSET);
//				txLengthEmptyFlag = (StsReg & DPTI_SR_TX_LEN_EMPTY_MASK);
//				rxLengthEmptyFlag = (StsReg & DPTI_SR_RX_LEN_EMPTY_MASK);
//				timeout ++;
//				if(timeout >= 1000000)return XST_FAILURE;
//			}

//		if (rxLengthEmptyFlag == 1 && txLengthEmptyFlag == 1){

		Xil_Out32(BaseAddress + DPTI_CONTROL_REG_OFFSET, 0);

		if (Direction == 1){
			Xil_Out32(BaseAddress + DPTI_CONTROL_REG_OFFSET, STREAM_TO_DPTI);
		}

		if (Direction == 2){
			Xil_Out32(BaseAddress + DPTI_CONTROL_REG_OFFSET, DPTI_TO_STREAM);
		}

		Xil_Out32 (BaseAddress + DPTI_LENGTH_REG_OFFSET, TransferLength);
//		}
//		else {
//			xil_printf("DPTI_SimpleTransfer: Transfer already in progress.");
//			return XST_FAILURE;
//		}

	}

	return XST_SUCCESS;

}

XStatus DPTI_Reset(u32 BaseAddress){
	Xil_Out32(BaseAddress+ DPTI_CONTROL_REG_OFFSET, DPTI_CR_RESET_MASK);
	Xil_Out32(BaseAddress+ DPTI_LENGTH_REG_OFFSET, 0);
	Xil_Out32(BaseAddress+ DPTI_CONTROL_REG_OFFSET, 0);
	return XST_SUCCESS;
}
