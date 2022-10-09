/******************************************************************************
 * @file axi_ps2.c
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
 * This file contains the functions for the PS/2 driver.
 * Refer to the header file AxiPs2.h for more detailed information.
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

static void axi_ps2_StubHandler(void *CallBackRef, u32 IntrMask, u32 ByteCount);

u32 axi_ps2_SendBuffer(axi_ps2 *InstancePtr);

u32 axi_ps2_ReceiveBuffer(axi_ps2 *InstancePtr);

/****************************************************************************/
/**
*
* Initializes a specific PS/2 instance such that it is ready to be used.
* The default operating mode of the driver is polled mode.
*
* @param	InstancePtr is a pointer to the AxiPs2 instance to be worked on.
* @param	ConfigPtr is a reference to a structure containing information
*		about a specific PS/2 device.
* @param	EffectiveAddr is the device base address in the virtual memory
*		address space. If address translation is not used then the
*		physical address is passed. Unexpected errors may occur if the
*		address mapping is changed after this function is invoked.
*
* @return
*		- XST_SUCCESS if initialization is successful
*
* @note		The PS/2 device will be reset and all the interrupts
*		are disabled as a part of the initialization.
*
*****************************************************************************/
int axi_ps2_CfgInitialize(axi_ps2 *InstancePtr, axi_ps2_Config *ConfigPtr,
						u32 EffectiveAddr)
{
	/*
	 * Assert validates the input arguments
	 */
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(ConfigPtr != NULL);

	/*
	 * Setup the data that is from the configuration information
	 */
	InstancePtr->Ps2Config.BaseAddress = EffectiveAddr;

	/*
	 * Initialize the instance data to some default values and setup a
	 * default handler
	 */
	InstancePtr->Handler = axi_ps2_StubHandler;

	InstancePtr->SendBuffer.NextBytePtr = NULL;
	InstancePtr->SendBuffer.RemainingBytes = 0;
	InstancePtr->SendBuffer.RequestedBytes = 0;

	InstancePtr->ReceiveBuffer.NextBytePtr = NULL;
	InstancePtr->ReceiveBuffer.RemainingBytes = 0;
	InstancePtr->ReceiveBuffer.RequestedBytes = 0;

	/*
	 * Reset the PS/2 Hardware
	 */
	axi_ps2_Reset(InstancePtr);

	/*
	 * Indicate the instance is now ready to use, initialized without error
	 */
	InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

	return XST_SUCCESS;
}

/****************************************************************************/
/**
*
* This functions sends the specified buffer of data to the PS/2 port in either
* polled or interrupt driven modes. This function is non-blocking such that it
* will return before the data has been sent through PS/2. If the port is busy
* sending data, it will return and indicate that zero bytes were sent.
*
* In polled mode, this function will only send 1 byte which is as much data
* as the transmitter can buffer. The application may need to call it
* repeatedly to send a buffer.
*
* In interrupt mode, this function will start sending the specified buffer and
* then the interrupt handler of the driver will continue sending data until the
* buffer has been sent. A callback function, as specified by the application,
* will be called to indicate the completion of sending the buffer.
*
* @param	InstancePtr is a pointer to the AxiPs2 instance to be worked on.
* @param	BufferPtr is pointer to a buffer of data to be sent.
* @param	NumBytes contains the number of bytes to be sent. A value of
*		zero will stop a previous send operation that is in progress in
*		interrupt mode.
*
* @return	The number of bytes actually sent.
*
* @note
*
* The number of bytes is not asserted so that this function may be called with
* a value of zero to stop an operation that is already in progress.
* <br><br>
* This function modifies shared data such that there may be a need for mutual
* exclusion in a multithreaded environment
*
*****************************************************************************/
u32 axi_ps2_Send(axi_ps2 *InstancePtr, u8 *BufferPtr, u32 NumBytes)
{
	u32 BytesSent;

	/*
	 * Assert validates the input arguments
	 */
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(BufferPtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/*
	 * Enter a critical region by disabling the PS/2 transmit interrupts to
	 * allow this call to stop a previous operation that may be interrupt
	 * driven, only stop the transmit interrupt since this critical region
	 * is not really exited in the normal manner
	 */
	axi_ps2_IntrDisable(InstancePtr, axi_ps2_IPIXR_TX_ALL);

	/*
	 * Setup the specified buffer to be sent by setting the instance
	 * variables so it can be sent with polled or interrupt mode
	 */
	InstancePtr->SendBuffer.RequestedBytes = NumBytes;
	InstancePtr->SendBuffer.RemainingBytes = NumBytes;
	InstancePtr->SendBuffer.NextBytePtr = BufferPtr;

	/*
	 * Send the buffer and return the number of bytes sent
	 */
	BytesSent = axi_ps2_SendBuffer(InstancePtr);

	/*
	 * The critical region is not exited in this function because of the way
	 * the transmit interrupts work. The other function called enables the
	 * transmit interrupt such that this function can't restore a value to
	 * the interrupt enable register and does not need to exit the critical
	 * region
	 */
	return BytesSent;
}


/****************************************************************************/
/**
*
* This function will attempt to receive a specified number of bytes of data
* from PS/2 and store it into the specified buffer. This function is
* designed for either polled or interrupt driven modes. It is non-blocking
* such that it will return if no data was received by the PS/2 port.
*
* In polled mode, this function will only receive 1 byte which is as much
* data as the receiver can buffer. The application may need to call it
* repeatedly to receive a buffer. Polled mode is the default mode of operation
* for the driver.
*
* In interrupt mode, this function will start receiving and then the interrupt
* handler of the driver will continue receiving data until the buffer has been
* received. A callback function, as specified by the application, will be called
* to indicate the completion of receiving the buffer or when any receive errors
* or timeouts occur. Interrupt mode must be enabled.
*
* @param	InstancePtr is a pointer to the AxiPs2 instance to be worked on.
* @param	BufferPtr is pointer to buffer for data to be received into.
* @param	NumBytes is the number of bytes to be received. A value of zero
*		will stop a previous receive operation that is in progress in
*		interrupt mode.
*
* @return	The number of bytes received.
*
* @note
*
* The number of bytes is not asserted so that this function may be called with
* a value of zero to stop an operation that is already in progress.
*
*****************************************************************************/
u32 axi_ps2_Recv(axi_ps2 *InstancePtr, u8 *BufferPtr, u32 NumBytes)
{
	u32 ReceivedCount;

	/*
	 * Assert validates the input arguments
	 */
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(BufferPtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/*
	 * Setup the specified buffer to be sent by setting the instance
	 * variables so it can be sent with polled or interrupt mode
	 */
	InstancePtr->ReceiveBuffer.RequestedBytes = NumBytes;
	InstancePtr->ReceiveBuffer.RemainingBytes = NumBytes;
	InstancePtr->ReceiveBuffer.NextBytePtr = BufferPtr;

	/*
	 * Receive the data from PS/2 and return the number of bytes
	 * received
	 */
	ReceivedCount = axi_ps2_ReceiveBuffer(InstancePtr);

	return ReceivedCount;
}

/****************************************************************************/
/**
*
* This function sends a buffer that has been previously specified by setting
* up the instance variables of the instance. This function is designed to be
* an internal function for the AxiPs2 component such that it may be called
* from a shell function that sets up the buffer or from an interrupt handler.
*
* This function sends the specified buffer of data to the PS/2 port in either
* polled or interrupt driven modes. This function is non-blocking such that
* it will return before the data has been sent.
*
* In a polled mode, this function will only send 1 byte which is as much data
* transmitter can buffer. The application may need to call it repeatedly to
* send a buffer.
*
* In interrupt mode, this function will start sending the specified buffer and
* then the interrupt handler of the driver will continue until the buffer
* has been sent. A callback function, as specified by the application, will
* be called to indicate the completion of sending the buffer.
*
* @param	InstancePtr is a pointer to the AxiPs2 instance to be worked on.
*
* @return	NumBytes is the number of bytes actually sent.
*
* @note		None.
*
*****************************************************************************/
u32 axi_ps2_SendBuffer(axi_ps2 *InstancePtr)
{
	u32 SentCount = 0;

	/*
	 * If the transmitter is empty send one byte of data
	 */
	if (axi_ps2_IsTxEmpty(InstancePtr->Ps2Config.BaseAddress)) {
		axi_ps2_SendByte(InstancePtr->Ps2Config.BaseAddress,
		  		InstancePtr->SendBuffer.NextBytePtr[SentCount]);

		xil_printf("\r\nsending %x ",InstancePtr->SendBuffer.NextBytePtr[SentCount]);
		SentCount = 1;
	}

	/*
	 * Update the buffer to reflect the bytes that were sent from it
	 */
	InstancePtr->SendBuffer.NextBytePtr += SentCount;
	InstancePtr->SendBuffer.RemainingBytes -= SentCount;

	/*
	 * If interrupts are enabled as indicated by the receive interrupt, then
	 * enable the transmit interrupt
	 */
	if (axi_ps2_IntrGetEnabled(InstancePtr) & axi_ps2_IPIXR_RX_FULL)
	{
		axi_ps2_IntrEnable(InstancePtr, (axi_ps2_IPIXR_TX_ALL));
	}

	return SentCount;
}

/****************************************************************************/
/**
*
* This function receives a buffer that has been previously specified by setting
* up the instance variables of the instance. This function is designed to be
* an internal function for the AxiPs2 component such that it may be called
* from a shell function that sets up the buffer or from an interrupt handler.
*
* This function will attempt to receive a specified number of bytes of data
* from PS/2 and store it into the specified buffer. This function is
* designed for either polled or interrupt driven modes. It is non-blocking
* such that it will return if there is no data received.
*
* In polled mode, this function will only receive 1 byte which is as much
* data as the receiver can buffer. The application may need to call it
* repeatedly to receive a buffer. Polled mode is the default mode of operation
* for the driver.
*
* In interrupt mode, this function will start receiving and then the interrupt
* handler of the driver will continue until the buffer has been received. A
* callback function, as specified by the application, will be called to indicate
* the completion of receiving the buffer or when any receive errors or timeouts
* occur. Interrupt mode must be enabled by enabling the interrupts using the
* AxiPs2_IntrEnable() and AxiPs2_IntrGlobalEnable() API's.
*
* @param	InstancePtr is a pointer to the AxiPs2 instance to be worked on.
*
* @return	The number of bytes received.
*
* @note		None.
*
*****************************************************************************/
u32 axi_ps2_ReceiveBuffer(axi_ps2 *InstancePtr)
{
	u32 ReceivedCount = 0;

	/*
	 * Loop until there is no more data buffered by the PS/2 receiver or the
	 * specified number of bytes has been received
	 */
	while (ReceivedCount < InstancePtr->ReceiveBuffer.RemainingBytes) {
		/*
		 * If there is data ready to be read , then put the next byte
		 * read into the specified buffer
		 */
		if (!axi_ps2_IsRxEmpty(InstancePtr->Ps2Config.BaseAddress)) {
		       InstancePtr->ReceiveBuffer.NextBytePtr[ReceivedCount++] = axi_ps2_RecvByte(InstancePtr->Ps2Config.BaseAddress);
		}

		/*
		 * There is no more data buffered, so exit such that this
		 * function does not block waiting for data
		 */
		else {
			break;
		}
	}

	/*
	 * Update the receive buffer to reflect the number of bytes that were
	 * received
	 */
	InstancePtr->ReceiveBuffer.NextBytePtr += ReceivedCount;
	InstancePtr->ReceiveBuffer.RemainingBytes -= ReceivedCount;

	return ReceivedCount;
}

/****************************************************************************/
/**
*
* This function is a stub handler that is the default handler such that if the
* application has not set the handler when interrupts are enabled, this
* function will be called. The function interface has to match the interface
* specified for a handler even though none of the arguments are used.
*
* @param	CallBackRef is unused by this function.
* @param	IntrMask is unused by this function.
* @param	ByteCount is unused by this function.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void axi_ps2_StubHandler(void *CallBackRef, u32 IntrMask, u32 ByteCount)
{
	/*
	 * Assert always occurs since this is a stub and should never be called
	 */
	Xil_AssertVoidAlways();
}

