/******************************************************************************
 * @file axi_ps2.h
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
 * The Xilinx axi_ps2 driver supports the Xilinx PS/2 device which has a Processor
 * Local Bus Interface (PLB).
 *
 * <b> Driver Description</b>
 *
 * The device driver enables higher layer software (e.g., an application) to
 * communicate to the PS/2 device. Apart from transmission and reception of data
 * the driver also handles configuration of the device. A single device driver
 * can support multiple PS/2 devices.
 *
 * This driver supports the following features:
 *    - Polled mode
 *    - Interrupt mode
 *
 * The driver defaults to polled mode at initialization such that interrupts
 * must be enabled if desired by the user.
 *
 * The axi_ps2_Send() and axi_ps2_Recv() APIs, are provided in the driver to
 * allow data to be sent and received respectively. They are designed to be used
 * in polled or interrupt modes.
 *
 * <b>Initialization & Configuration</b>
 *
 * To Initialize the PS/2 device using the driver, the user needs to first call
 * the axi_ps2_LookupConfig() API, followed by the axi_ps2_CfgInitialize() API.
 * axi_ps2_LookupConfig API returns the Configuration structure pointer which
 * is passed as a parameter to the axi_ps2_CfgInitialize function.
 * axi_ps2_CfgInitialize does the initialization of the PS/2 device.
 *
 * The PS2 device is reset when the driver is initialized.
 *
 * <b>Interrupts</b>
 *
 * An interrupt is generated for any of the following conditions :
 *    - Data in the receiver
 *    - Any receive status error detected
 *    - Data byte transmitted
 *    - Any transmit status error detected
 *
 * In order to use interrupts, it is necessary for the user to connect the
 * driver interrupt handler, axi_ps2_IntrHandler(), to the interrupt system of
 * the application. This function does not save and restore the processor
 * context such that the user must provide it. A handler must be set for the
 * driver such that the handler is called when the interrupts occur. The
 * handler is called from interrupt context and is designed to allow application
 * specific processing to be performed.
 *
 * The interrupts are enabled by calling the axi_ps2_IntrEnable() API.
 *
 * <b> Threads</b>
 *
 * This driver is not thread safe. Any needs for threads or thread mutual
 * exclusion must be satisfied by the layer above this driver.
 *
 * <b> Asserts</b>
 *
 * Asserts are used within all Xilinx drivers to enforce constraints on argument
 * values. Asserts can be turned off on a system-wide basis by defining, at
 * compile time, the NDEBUG identifier. By default, asserts are turned on and it
 * is recommended that users leave asserts on during development.
 *
 * <b> Building the driver</b>
 *
 * The axi_ps2 driver is composed of several source files. This allows the user
 * to build and link only those parts of the driver that are necessary.
 * <br><br>
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
#ifndef axi_ps2_H /* prevent circular inclusions */
#define axi_ps2_H /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files ********************************/

#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "axi_ps2_l.h"

/************************** Constant Definitions ****************************/
//#define 		XPAR_AXI_PS2_0_DEVICE_ID
//#define 		XPAR_AXI_PS2_0_BASEADDR
/**************************** Type Definitions ******************************/

/**
 * This typedef contains configuration information for the device
 */
typedef struct {
	u16 DeviceId;		/**< Unique ID of device */
	u32 BaseAddress;	/**< Base address of device */
} axi_ps2_Config;

/**
 * The following data type is used to manage the buffers that are handled
 * when sending and receiving data in the interrupt mode
 */
typedef struct {
	u8 *NextBytePtr;	/**< Pointer to the Transmit/Receive Buffer */
	u32 RequestedBytes; 	/**< Total Number of Bytes to be
					Transmitted/Received */
	u32 RemainingBytes; 	/**< Remaining Bytes to be
					Transmitted/Received */
} axi_ps2_Buffer;

/*****************************************************************************/
/**
 * This data type defines a handler which the application must define
 * when using interrupt mode. The handler will be called from the driver in an
 * interrupt context to handle application specific processing.
 *
 * @param 	CallBackRef is a callback reference passed in by the upper layer
 *		when setting the handler, and is passed back to the upper layer
 * 		when the handler is called.
 * @param 	IntrMask is a bit mask of the interrupt status indicating why
 *		the handler is being called.
 * @param 	NumBytes contains the number of bytes sent or received at the
 * 		time of the call.
 *
 *****************************************************************************/
typedef void (*axi_ps2_Handler)(void *CallBackRef, u32 IntrMask, u32 NumBytes);

/**
 * The PS/2 driver instance data. The user is required to allocate a
 * variable of this type for every PS/2 device in the system.
 * If the last byte of a message was received then call the application
 * handler, this code should not use an else from the previous check of
 * the number of bytes to receive because the call to receive the buffer
 * updates the bytes to receive.
 * A pointer to a variable of this type is then passed to the driver API
 * functions
 */
typedef struct {

	axi_ps2_Config Ps2Config;   /**< Instance of the config structure */
	u32 IsReady;		 /**< Device is initialized and ready */

	axi_ps2_Buffer SendBuffer;   /**< Buffer for sending data */
	axi_ps2_Buffer ReceiveBuffer;/**< Buffer for receiving data */

	axi_ps2_Handler Handler;	 /**< Interrupt handler callback */
	void *CallBackRef;	/**< Callback reference for interrupt handler */
} axi_ps2;

/***************** Macros (Inline Functions) Definitions ********************/

/****************************************************************************/
/**
* Reset the PS/2 port.
*
* @param	InstancePtr is a pointer to the axi_ps2 instance to be worked on.
*
* @return	None.
*
* @note		C-Style signature:
*		void axi_ps2_Reset(axi_ps2 *InstancePtr);
*
******************************************************************************/
#define axi_ps2_Reset(InstancePtr) 					\
	axi_ps2_WriteReg((InstancePtr)->Ps2Config.BaseAddress, 		\
			axi_ps2_SRST_OFFSET, axi_ps2_SRST_RESET);

/****************************************************************************/
/**
* Read the PS/2 status register.
*
* @param	InstancePtr is a pointer to the axi_ps2 instance to be worked on.
*
* @return	The value read from the register.
*
* @note		C-Style signature:
*		u32 axi_ps2_GetStatus(axi_ps2 *InstancePtr);
*
******************************************************************************/
#define axi_ps2_GetStatus(InstancePtr) \
	axi_ps2_ReadReg((InstancePtr)->Ps2Config.BaseAddress, axi_ps2_STATUS_OFFSET)

/****************************************************************************/
/**
*
* Enable the global Interrupt in the Global Interrupt Enable Register.
* Interrupts enabled using axi_ps2_IntrEnable() will not occur until the global
* interrupt enable bit is set by using this function.
*
* @param	InstancePtr is a pointer to the axi_ps2 instance to be worked on.
*
* @return	None.
*
* @note		C-Style signature:
*		void axi_ps2_IntrGlobalEnable(axi_ps2 *InstancePtr);
*
******************************************************************************/
#define axi_ps2_IntrGlobalEnable(InstancePtr) 				\
	axi_ps2_WriteReg((InstancePtr)->Ps2Config.BaseAddress,		\
			axi_ps2_GIER_OFFSET, axi_ps2_GIER_GIE_MASK)


/****************************************************************************/
/**
*
* Disable the global Interrupt in the Global Interrupt Enable Register.
*
* @param	InstancePtr is a pointer to the axi_ps2 instance to be worked on.
*
* @return	None.
*
* @note		C-Style signature:
*		void axi_ps2_IntrGlobalDisable(axi_ps2 *InstancePtr);
*
******************************************************************************/
#define axi_ps2_IntrGlobalDisable(InstancePtr) 				\
	axi_ps2_WriteReg((InstancePtr)->Ps2Config.BaseAddress, 		\
			axi_ps2_GIER_OFFSET, 0x0)


/****************************************************************************/
/**
*
* Enable the specified Interrupts in the IP Interrupt Enable Register.
*
* @param	InstancePtr is a pointer to the axi_ps2 instance to be worked on.
* @param	EnableMask is the bitmask of the interrupts to be enabled.
*		Bit positions of 1 will be enabled. Bit positions of 0 will
*		keep the previous setting. This mask is formed by OR'ing
*		axi_ps2_IPIXR_* bits defined in axi_ps2_l.h.
*
* @return	None.
*
* @note		C-Style signature:
*		void axi_ps2_IntrEnable(axi_ps2 *InstancePtr, u32 EnableMask);
*
******************************************************************************/
#define axi_ps2_IntrEnable(InstancePtr, EnableMask) 			       \
	axi_ps2_WriteReg((InstancePtr)->Ps2Config.BaseAddress, axi_ps2_IPIER_OFFSET, \
		axi_ps2_ReadReg((InstancePtr)->Ps2Config.BaseAddress, 	       \
				axi_ps2_IPIER_OFFSET) | (EnableMask & axi_ps2_IPIXR_ALL ))

/****************************************************************************/
/**
*
* Disable the specified Interrupts in the IP Interrupt Enable Register.
*
* @param	InstancePtr is a pointer to the axi_ps2 instance to be worked on.
* @param	DisableMask is the bitmask of the interrupts to be disabled.
*		Bit positions of 1 will be disabled. Bit positions of 0 will
*		keep the previous setting. This mask is formed by OR'ing
*		axi_ps2_IPIXR_* bits defined in axi_ps2_l.h.
*
* @return	None.
*
* @note		C-Style signature:
*		void axi_ps2_IntrDisable(axi_ps2 *InstancePtr, u32 DisableMask);
*
******************************************************************************/
#define axi_ps2_IntrDisable(InstancePtr, DisableMask) 			      \
	axi_ps2_WriteReg((InstancePtr)->Ps2Config.BaseAddress, axi_ps2_IPIER_OFFSET,\
		axi_ps2_ReadReg((InstancePtr)->Ps2Config.BaseAddress, 	      \
				axi_ps2_IPIER_OFFSET) & (~ (DisableMask & axi_ps2_IPIXR_ALL )))

/****************************************************************************/
/**
*
* This function returns the enabled interrupts. Use the axi_ps2_IPIXR_*_MASK
* constants defined in axi_ps2_l.h to interpret the returned value.
*
* @param	InstancePtr is a pointer to the axi_ps2 instance to be worked on.
*
* @return 	Enabled interrupts in a 32-bit format.
*
* @note		C-Style signature:
*		u32 axi_ps2_IntrGetEnabled(InstancePtr);
*
******************************************************************************/
#define axi_ps2_IntrGetEnabled(InstancePtr) 				\
	(axi_ps2_ReadReg((InstancePtr)->Ps2Config.BaseAddress, axi_ps2_IPIER_OFFSET))


/****************************************************************************/
/**
*
* Read the interrupt status register.
*
* @param	InstancePtr is a pointer to the axi_ps2 instance to be worked on.
*
* @return	The value read from the register.
*
* @note		C-Style signature:
*		u32 axi_ps2_IntrGetStatus(axi_ps2 *InstancePtr);
*
******************************************************************************/
#define axi_ps2_IntrGetStatus(InstancePtr) \
	axi_ps2_ReadReg((InstancePtr)->Ps2Config.BaseAddress, axi_ps2_IPISR_OFFSET)


/****************************************************************************/
/**
*
* Clear the pending interrupts in the Interrupt Status Register.
*
* @param	InstancePtr is a pointer to the axi_ps2 instance to be worked on.
* @param	ClearMask is the Bitmask for interrupts to be cleared.
*		A "1" clears the interrupt.
*
* @return	None.
*
* @note		C-Style signature:
*		void axi_ps2_IntrClear(axi_ps2 *InstancePtr, u32 ClearMask);
*
******************************************************************************/
#define axi_ps2_IntrClear(InstancePtr, ClearMask) \
	axi_ps2_WriteReg((InstancePtr)->Ps2Config.BaseAddress, axi_ps2_IPISR_OFFSET,\
		axi_ps2_IntrGetStatus(InstancePtr) | (ClearMask & axi_ps2_IPIXR_ALL ))


/************************** Function Prototypes *****************************/

/*
 * Initialization functions in axi_ps2_sinit.c
 */
axi_ps2_Config *axi_ps2_LookupConfig(u16 DeviceId);

/*
 * Functions is axi_ps2.c
 */
int axi_ps2_CfgInitialize(axi_ps2 *InstancePtr, axi_ps2_Config *Config,
				u32 EffectiveAddr);
u32 axi_ps2_Send(axi_ps2 *InstancePtr, u8 *BufferPtr, u32 NumBytes);
u32 axi_ps2_Recv(axi_ps2 *InstancePtr, u8 *BufferPtr, u32 NumBytes);

/*
 * Functions in axi_ps2_intr.c
 */
void axi_ps2_SetHandler(axi_ps2 *InstancePtr, axi_ps2_Handler FuncPtr,
				void *CallBackRef);
void axi_ps2_IntrHandler(axi_ps2 *InstancePtr);

/*
 * Functions in axi_ps2_selftest.c
 */
int axi_ps2_SelfTest(axi_ps2 *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif			/* end of protection macro */

