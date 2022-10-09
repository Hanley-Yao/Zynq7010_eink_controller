/******************************************************************************
 * @file axi_ps2_intr.c
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
 * The implementation of the XPs2 component's static initialization
 * functionality.
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
/***************************** Include Files ********************************/

#include "axi_ps2.h"

/************************** Constant Definitions ****************************/

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

/************************** Variable Definitions ****************************/

/************************** Function Prototypes *****************************/

extern u32 axi_ps2_SendBuffer(axi_ps2 *InstancePtr);
extern u32 axi_ps2_ReceiveBuffer(axi_ps2 *InstancePtr);

/****************************************************************************/
/**
*
* This function sets the handler that will be called when an interrupt
* occurs in the driver. The purpose of the handler is to allow application
* specific processing to be performed.
*
* @param	InstancePtr is a pointer to the AxiPs2 instance to be worked on.
* @param	FuncPtr is the pointer to the callback function.
* @param	CallBackRef is the upper layer callback reference passed back
*		when the callback function is invoked.
*
* @return	None.
*
* @note
*
* There is no assert on the CallBackRef since the driver doesn't know what it
* is (nor should it)
*
*****************************************************************************/
void axi_ps2_SetHandler(axi_ps2 *InstancePtr, axi_ps2_Handler FuncPtr,
					 void *CallBackRef)
{
	/*
	 * Assert validates the input arguments
	 * CallBackRef not checked, no way to know what is valid
	 */
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(FuncPtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	InstancePtr->Handler = FuncPtr;
	InstancePtr->CallBackRef = CallBackRef;
}

/****************************************************************************/
/**
*
* This function is the interrupt handler for the PS/2 driver.
* It must be connected to an interrupt system by the user such that it is
* called when an interrupt for any PS/2 port occurs. This function does
* not save or restore the processor context such that the user must
* ensure this occurs.
*
* @param	InstancePtr contains a pointer to the instance of the PS/2 port
*		that the interrupt is for.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void axi_ps2_IntrHandler(axi_ps2 *InstancePtr)
{
	u32 IntrStatus;

	Xil_AssertVoid(InstancePtr != NULL);

	/*
	 * Read the interrupt status register to determine which
	 * interrupt is active.
	 */
	IntrStatus = axi_ps2_IntrGetStatus(InstancePtr);

	/*
	 * Clear the Interrupt Status Register
	 */
	axi_ps2_IntrClear(InstancePtr, IntrStatus);

	if (IntrStatus & (axi_ps2_IPIXR_RX_ERR | axi_ps2_IPIXR_RX_OVF)) {

		/*
		 * Call the application handler with the error code
		 */
		InstancePtr->Handler(InstancePtr->CallBackRef,
		IntrStatus & (axi_ps2_IPIXR_RX_ERR | axi_ps2_IPIXR_RX_OVF),
		InstancePtr->ReceiveBuffer.RequestedBytes -
		InstancePtr->ReceiveBuffer.RemainingBytes);
	}

	if (IntrStatus & (axi_ps2_IPIXR_TX_NOACK)) {

		/*
		 * Call the application handler with the error code
		 */
		InstancePtr->Handler(InstancePtr->CallBackRef,
		IntrStatus & (axi_ps2_IPIXR_TX_NOACK),
		InstancePtr->SendBuffer.RequestedBytes -
		InstancePtr->SendBuffer.RemainingBytes);
	}

	if (IntrStatus & axi_ps2_IPIXR_RX_FULL) {

		/*
		 * If there are bytes still to be received in the specified
		 * buffer go ahead and receive them
		 */
		if (InstancePtr->ReceiveBuffer.RemainingBytes != 0) {
				axi_ps2_ReceiveBuffer(InstancePtr);
		}

		/*
		 * If the last byte of a message was received then call the
		 * application handler, this code should not use an else from
		 * the previous check of the number of bytes to receive because
		 * the call to receive the buffer updates the bytes to receive
		 */
		if (InstancePtr->ReceiveBuffer.RemainingBytes == 0) {
				InstancePtr->Handler(InstancePtr->CallBackRef, axi_ps2_IPIXR_RX_FULL,
				InstancePtr->ReceiveBuffer.RequestedBytes -
				InstancePtr->ReceiveBuffer.RemainingBytes);
		}
	}

	if (IntrStatus & axi_ps2_IPIXR_TX_ACK) {

		/*
		 * If there are no bytes to be sent from the specified buffer
		 * then disable the transmit interrupt
		 */
		if (InstancePtr->SendBuffer.RemainingBytes == 0) {
			axi_ps2_IntrDisable(InstancePtr, axi_ps2_IPIXR_TX_ACK);

		/*
		 * Call the application handler to indicate the data has been
		 * sent
		 */
		InstancePtr->Handler(InstancePtr->CallBackRef, axi_ps2_IPIXR_TX_ACK,
				InstancePtr->SendBuffer.RequestedBytes -
				InstancePtr->SendBuffer.RemainingBytes);
		}

		/*
		 * Otherwise there is still more data to send in the specified
		 * buffer so go ahead and send it
		 */
		else {
			axi_ps2_SendBuffer(InstancePtr);
		}

	}

}

