/*******************************************************************************
 MRF24WG External Interrupt Stub Functions

  Summary: Functions to control MRF24WG External Interrupt.

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
//#include <NetworkProfile.x>

#include "xgpio.h"
#include "../../../DEIPcK/utility/System.h"

#ifdef XPAR_XINTC_NUM_INSTANCES
 #include "xintc.h"
 #define INTC		XIntc
 #define INTC_HANDLER	XIntc_InterruptHandler
#else
 #include "xscugic.h"
 #define INTC		XScuGic
 #define INTC_HANDLER	XScuGic_InterruptHandler
#endif

INTC intc;

extern u32 WF_E_INT_VECTOR;
extern u32 WF_GPIO_BASEADDRESS;

XGpio WF_XGpio;

XGpio_Config XGpioConfig =
{
	0,
	0,
	1,
	0

};

void WF_Interrupt(void){
	XGpio_InterruptClear(&WF_XGpio, 1);
	u8 level=(Xil_In32(WF_GPIO_BASEADDRESS)&1);
	if (!level){//If low
		WF_EintHandler();           // call Univeral Driver handler function
	}
}

/*****************************************************************************
  Function:
    void WF_EintInit(void);

  Summary:
    Configure host processor external interrupt.  This line is asserted low by
    MRF24WG.

  Description:
    Called by Universal Driver during initialization.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_EintInit(void)
{
	int Result;
	Xil_ExceptionDisable();
	XGpio_CfgInitialize(&WF_XGpio, &XGpioConfig, WF_GPIO_BASEADDRESS);
#ifdef XPAR_XINTC_NUM_INSTANCES
	INTC *IntcInstancePtr = &intc;
	/*
	 * Initialize the interrupt controller driver so that it's ready to use.
	 * specify the device ID that was generated in xparameters.h
	 */
	Result = XIntc_Initialize(IntcInstancePtr, XPAR_INTC_0_DEVICE_ID);
	if (Result!=XST_SUCCESS){
		xil_printf("ERROR:Interrupt Controller not initialized.\r\n");
		return;
	}
	/* Hook up interrupt service routine */
	XIntc_Connect(IntcInstancePtr, WF_E_INT_VECTOR,
		      (Xil_ExceptionHandler)WF_Interrupt, 0);

	/* Enable the interrupt vector at the interrupt controller */

	XIntc_Enable(IntcInstancePtr, WF_E_INT_VECTOR);

	/*
	 * Start the interrupt controller such that interrupts are recognized
	 * and handled by the processor
	 */
	Result = XIntc_Start(IntcInstancePtr, XIN_REAL_MODE);
	if (Result!=XST_SUCCESS){
		xil_printf("ERROR:Interrupt Controller not started.\r\n");
		return;
	}
	XGpio_InterruptEnable(&WF_XGpio, 1);
	XGpio_InterruptGlobalEnable(&WF_XGpio);

#endif
#ifdef XPAR_SCUGIC_0_DEVICE_ID
	INTC *IntcInstancePtr = &intc;
	XScuGic_Config *IntcConfig;

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	IntcConfig = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
	if (NULL == IntcConfig) {
		return;
	}

	Result = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
					IntcConfig->CpuBaseAddress);
	if (Result!=XST_SUCCESS){
		xil_printf("ERROR:Interrupt Controller not initialized.\r\n");
		return;
	}

	XScuGic_SetPriorityTriggerType(IntcInstancePtr, WF_E_INT_VECTOR,
					0xA0, 0x3);

	/*
	 * Connect the interrupt handler that will be called when an
	 * interrupt occurs for the device.
	 */
	Result = XScuGic_Connect(IntcInstancePtr, WF_E_INT_VECTOR,
				 (Xil_ExceptionHandler)WF_Interrupt, NULL);
	if (Result!=XST_SUCCESS){
		xil_printf("ERROR:Interrupt Controller not connected.\r\n");
		return;
	}

	/*
	 * Enable the interrupt for the GPIO device.
	 */
	XScuGic_Enable(IntcInstancePtr, WF_E_INT_VECTOR);

	XGpio_InterruptEnable(&WF_XGpio, 1);
	XGpio_InterruptGlobalEnable(&WF_XGpio);



#endif

	/*
	 * Initialize the exception table and register the interrupt
	 * controller handler with the exception table
	 */
	Xil_ExceptionInit();

	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			 (Xil_ExceptionHandler)INTC_HANDLER, IntcInstancePtr);

	/* Enable non-critical exceptions */
	Xil_ExceptionEnable();
	return;
}



/*****************************************************************************
  Function:
    void WF_EintEnable(void);

  Summary:
    Enables the MRF24WG external interrupt

  Description:
    Called by Universal Driver during normal operations to enable the MRF24WG
    external interrupt.  
 
    Note: When using level-triggered interrupts it is possible that host MCU
          could miss a falling edge; this can occur because during normal
          operations as the Universal Driver disables the external interrupt for
          short periods.  If the MRF24WG asserts the interrupt line while the
          interrupt is disabled the falling edge won't be detected.  So, a
          check must be made to determine if an interrupt is pending; if so, the
          interrupt must be forced.

          This is not an issue for level-triggered interrupts.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_EintEnable(void)
{
	u32 Mask;
    
    // if interrupt line is low, then PIC32 may have missed the falling edge
    // while the interrupt was disabled.
	u8 edge=(Xil_In32(WF_GPIO_BASEADDRESS)&1);
	if(edge==0){//INT pin low

#ifdef XPAR_SCUGIC_0_DEVICE_ID
		Mask = 0x00000001U << (WF_E_INT_VECTOR % 32U);

		XScuGic_DistWriteReg(&intc, (u32)XSCUGIC_PENDING_SET_OFFSET + ((WF_E_INT_VECTOR / 32U) * 4U), Mask);
#else
		if (!Xil_In32(WF_GPIO_BASEADDRESS+0x120)){
			Xil_Out32(WF_GPIO_BASEADDRESS+0x120, 1);
		}
		Mask=Xil_In32(XPAR_INTC_0_BASEADDR+4);
		Xil_Out32(XPAR_INTC_0_BASEADDR+4, Mask|1<<WF_E_INT_VECTOR);
#endif
	}
	else{//Int pin high
		XGpio_InterruptClear(&WF_XGpio, 1);
	}

	XGpio_InterruptGlobalEnable(&WF_XGpio);//Enable GPIO Global Interrupts
}

/*****************************************************************************
  Function:
    void WF_EintDisable(void);

  Summary:
    Disables the MRF24WG external interrupt

  Description:
    Called by Universal Driver during normal operations to disable the MRF24WG
    external interrupt.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_EintDisable(void)
{
	XGpio_InterruptGlobalDisable(&WF_XGpio);//Disable GPIO Global Interrupts
}

/*****************************************************************************
  Function:
    bool WF_isEintDisabled(void);

  Summary:
    Determines if the external interrupt is disabled

  Description:
    Called by Universal Driver during normal operations to check if the current
    state of the external interrupt is disabled.

 Parameters:
    None

  Returns:
    True if interrupt is disabled, else False

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
bool WF_isEintDisabled(void)
{
	return (Xil_In32(WF_GPIO_BASEADDRESS+0x11C)&0x8000)>>15;//Enable GPIO Global Interrupts;
}

/*****************************************************************************
  Function:
    bool WF_isEintPending(void);

  Summary:
    Determines if the external interrupt is pending.

  Description:
    Called by Universal Driver during normal operations to check if an external
    interrupt is pending.

 Parameters:
    None

  Returns:
    True if interrupt is pending, else False

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
bool WF_isEintPending(void)
{
    // if interrupt line is low, but interrupt request has not occurred
//    return(((WF_INT_IO == 0) && (WIFI_INT_IF == 0)));
	return XGpio_InterruptGetStatus(&WF_XGpio);
}


/*****************************************************************************
  Function:
    void _WFInterrupt(void);

  Summary:
    MRF24WG external interrupt handler

  Description:
    This interrupt handler should:
        1) ensure the interrupt is disabled upon exit (Universal Driver will reenable it)
        1) clear the interrupt
        2) call WFEintHandler()

 Parameters:
    None

  Returns:
    None

  Remarks:
    None
*****************************************************************************/
/*#if defined(__PIC32MZXX__)
void __attribute((interrupt(WF_IPL_ISR), at_vector(WF_INT_VEC), nomips16)) _WFInterrupt(void)
#else
void __attribute((interrupt(WF_IPL_ISR), vector(WF_INT_VEC), nomips16)) _WFInterrupt(void)
#endif
{
    // clear EINT
//    WIFI_IFSxCLR = WIFI_INT_MASK;        // clear the interrupt
//    WIFI_IECxCLR = WIFI_INT_MASK;        // disable external interrupt
    WF_EintHandler();           // call Univeral Driver handler function
}*/


