/******************************************************************************
 * @file axi_ps2_selftest.c
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
 * This file contains a diagnostic self test function for the AxiPs2 driver.
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

/*****************************************************************************/
/**
*
* Run a self-test on the driver/device. The test
*	- Writes a value into the Interrupt Enable register and reads it back
*	for comparison.
*
* @param	InstancePtr is a pointer to the AxiPs2 instance.
*
* @return
*		- XST_SUCCESS if the value read from the Interrupt Enable
*		register is the same as the value written.
*		- XST_FAILURE otherwise
*
* @note		None.
*
******************************************************************************/
int axi_ps2_SelfTest(axi_ps2 *InstancePtr)
{
	int Status = XST_SUCCESS;
	u32 IeRegister;
	u32 GieRegister;

	/*
	 * Assert the argument
	 */
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);


	/*
	 * Save a copy of the Global Interrupt Enable register
	 * and Interrupt Enable register before writing them so
	 * that they can be restored.
	 */
	GieRegister = axi_ps2_ReadReg(InstancePtr->Ps2Config.BaseAddress,
			axi_ps2_GIER_OFFSET);
	IeRegister = axi_ps2_IntrGetEnabled(InstancePtr);

	/*
	 * Disable the Global Interrupt so that enabling the interrupts
	 * won't affect the user.
	 */
	axi_ps2_IntrGlobalDisable(InstancePtr);

	/*
	 * Enable the Transmit interrupts and then verify that the
	 * register reads back correctly.
	 */
	axi_ps2_WriteReg(InstancePtr->Ps2Config.BaseAddress,
			axi_ps2_IPIER_OFFSET, axi_ps2_IPIXR_TX_ALL);
	if (axi_ps2_ReadReg(InstancePtr->Ps2Config.BaseAddress,
			axi_ps2_IPIER_OFFSET) != axi_ps2_IPIXR_TX_ALL) {
		Status = XST_FAILURE;
	}

	/*
	 * Restore the IP Interrupt Enable Register to the value before
	 * the test.
	 */
	axi_ps2_WriteReg(InstancePtr->Ps2Config.BaseAddress,
			axi_ps2_IPIER_OFFSET, IeRegister);

	/*
	 * Restore the Global Interrupt Register to the value before the
	 * test.
	 */
	axi_ps2_WriteReg(InstancePtr->Ps2Config.BaseAddress,
			axi_ps2_GIER_OFFSET, GieRegister);

	/*
	 * Return the test result.
	 */
	return Status;
}
