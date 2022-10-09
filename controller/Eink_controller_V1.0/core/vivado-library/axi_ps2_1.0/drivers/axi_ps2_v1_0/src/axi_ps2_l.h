/******************************************************************************
 * @file axi_ps2_l.h
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
 * This header file contains identifiers and low-level driver functions (or
 * macros) that can be used to access the device. The user should refer to the
 * hardware device specification for more details of the device operation.
 * High-level driver functions are defined in AxiPs2.h.
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
#ifndef AxiPs2_L_H /* prevent circular inclusions */
#define AxiPs2_L_H /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files ********************************/

#include "xil_types.h"
#include "xil_assert.h"
#include "xil_io.h"

/************************** Constant Definitions ****************************/

/**
 * PS/2 register offsets
 */
/** @name Register Map
 *
 * Register offsets for the AxiPs2 device.
 * @{
 */
#define axi_ps2_SRST_OFFSET		0x00000000 /**< Software Reset register */
#define axi_ps2_STATUS_OFFSET	0x00000004 /**< Status register */
#define axi_ps2_RX_DATA_OFFSET	0x00000008 /**< Receive Data register */
#define axi_ps2_TX_DATA_OFFSET	0x0000000C /**< Transmit Data register */
#define axi_ps2_GIER_OFFSET		0x00000010 /**< Global Interrupt Enable reg */
#define axi_ps2_IPISR_OFFSET	0x00000014 /**< Interrupt Status register */
#define axi_ps2_IPIER_OFFSET	0x00000018 /**< Interrupt Enable register */

/* @} */

/** @name Reset Register Bit Definitions
 *
 * @{
 */
#define axi_ps2_SRST_RESET		0x0000000A /**< Software Reset  */

/* @} */


/** @name Status Register Bit Positions
 *
 * @{
 */
#define axi_ps2_STATUS_RX_FULL	0x00000004 /**< Receive Full  */
#define axi_ps2_STATUS_TX_FULL	0x00000001 /**< Transmit Full  */
#define axi_ps2_STATUS_RX_EMPTY	0x00000008 /**< Receive Empty  */
//#define axi_ps2_STATUS_TX_EMPTY	0x00000002 /**< Transmit Full  */

/* @} */


/** @name PS/2 Device Interrupt Status/Enable Registers
 *
 * <b> Interrupt Status Register (IPISR) </b>
 *
 * This register holds the interrupt status flags for the PS/2 device.
 *
 * <b> Interrupt Enable Register (IPIER) </b>
 *
 * This register is used to enable interrupt sources for the PS/2 device.
 * Writing a '1' to a bit in this register enables the corresponding Interrupt.
 * Writing a '0' to a bit in this register disables the corresponding Interrupt.
 *
 * ISR/IER registers have the same bit definitions and are only defined once.
 * @{
 */
#define axi_ps2_IPIXR_WDT_TOUT	0x80000000 /**< Watchdog Timeout Interrupt */
#define axi_ps2_IPIXR_TX_NOACK	0x40000000 /**< Transmit No ACK Interrupt */
#define axi_ps2_IPIXR_TX_ACK	0x20000000 /**< Transmit ACK (Data) Interrupt */
#define axi_ps2_IPIXR_RX_OVF	0x10000000 /**< Receive Overflow Interrupt */
#define axi_ps2_IPIXR_RX_ERR	0x08000000 /**< Receive Error Interrupt */
#define axi_ps2_IPIXR_RX_FULL	0x04000000 /**< Receive Data Interrupt */

/**
 * Mask for all the Transmit Interrupts
 */
#define axi_ps2_IPIXR_TX_ALL	(axi_ps2_IPIXR_TX_NOACK | axi_ps2_IPIXR_TX_ACK)

/**
 * Mask for all the Receive Interrupts
 */
#define axi_ps2_IPIXR_RX_ALL	(axi_ps2_IPIXR_RX_OVF | axi_ps2_IPIXR_RX_ERR |  \
		axi_ps2_IPIXR_RX_FULL)

/**
 * Mask for all the Interrupts
 */
#define axi_ps2_IPIXR_ALL		(axi_ps2_IPIXR_TX_ALL | axi_ps2_IPIXR_RX_ALL |  \
		axi_ps2_IPIXR_WDT_TOUT)
/* @} */


/**
 * @name Global Interrupt Enable Register (GIER) mask(s)
 * @{
 */
#define axi_ps2_GIER_GIE_MASK	0x00000001 /**< Global interrupt enable */
/*@}*/

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

#define axi_ps2_In32  Xil_In32
#define axi_ps2_Out32 Xil_Out32

/****************************************************************************/
/**
* Read from the specified PS/2 device register.
*
* @param	BaseAddress contains the base address of the device.
* @param	RegOffset contains the offset from the 1st register of the
*		device to select the specific register.
*
* @return	The value read from the register.
*
* @note		C-Style signature:
*		u32 AxiPs2_ReadReg(u32 BaseAddress, u32 RegOffset);
*
******************************************************************************/
#define axi_ps2_ReadReg(BaseAddress, RegOffset) \
	axi_ps2_In32((BaseAddress) + (RegOffset))

/***************************************************************************/
/**
* Write to the specified PS/2 device register.
*
* @param	BaseAddress contains the base address of the device.
* @param	RegOffset contains the offset from the 1st register of the
*		device to select the specific register.
* @param	RegisterValue is the value to be written to the register.
*
* @return	None.
*
* @note		C-Style signature:
*		void AxiPs2_WriteReg(u32 BaseAddress, u32 RegOffset,
*				u32 RegisterValue);
******************************************************************************/
#define axi_ps2_WriteReg(BaseAddress, RegOffset, RegisterValue) \
	axi_ps2_Out32((BaseAddress) + (RegOffset), (RegisterValue))

/****************************************************************************/
/**
* This macro checks if the receiver is full (There is data in the receive data
* register).
*
* @param	BaseAddress contains the base address of the device.
*
* @return
*		- TRUE if there is receive data.
*		- FALSE if there is no receive data.
*
* @note		C-Style signature:
*		int AxiPs2_IsRxFull(u32 BaseAddress);
*
******************************************************************************/
#define axi_ps2_IsRxFull(BaseAddress) 					\
	(((axi_ps2_ReadReg(BaseAddress, axi_ps2_STATUS_OFFSET) & 		\
			axi_ps2_STATUS_RX_FULL)) ? TRUE : FALSE)

/****************************************************************************/
/**
* This macro checks if the receiver is empty.
*
* @param	BaseAddress contains the base address of the device.
*
* @return
*		- TRUE if there is receive data.
*		- FALSE if there is no receive data.
*
* @note		C-Style signature:
*		int AxiPs2_IsRxEmpty(u32 BaseAddress);
*
******************************************************************************/

#define axi_ps2_IsRxEmpty(BaseAddress) 					\
	(((axi_ps2_ReadReg(BaseAddress, axi_ps2_STATUS_OFFSET) & 		\
			axi_ps2_STATUS_RX_EMPTY)) ? TRUE : FALSE)

/****************************************************************************/
/**
* This macro checks if the transmitter is empty.
*
* @param	BaseAddress contains the base address of the device.
*
* @return
*		- TRUE if the transmitter is not full and data can be sent.
*		- FALSE if the transmitter is full.
*
* @note		C-Style signature:
*		int AxiPs2_IsTxEmpty(u32 BaseAddress);
*
******************************************************************************/
#define axi_ps2_IsTxEmpty(BaseAddress) 				     \
	((axi_ps2_ReadReg(BaseAddress, axi_ps2_STATUS_OFFSET ) & 		     \
			axi_ps2_STATUS_TX_FULL) ? FALSE: TRUE)

/************************** Variable Definitions ****************************/

/************************** Function Prototypes *****************************/

void axi_ps2_SendByte(u32 BaseAddress, u8 Data);
u32 axi_ps2_RecvByte(u32 BaseAddress);

/****************************************************************************/

#ifdef __cplusplus
}
#endif

#endif

