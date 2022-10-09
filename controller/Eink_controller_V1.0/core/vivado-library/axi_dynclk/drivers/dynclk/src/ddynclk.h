/*
 * ddynclk.h
 *
 *  Created on: Dec 4, 2017
 *      Author: ROGyorgE
 */

#ifndef DDYNCLK_H_
#define DDYNCLK_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "xil_types.h"
#include "xil_io.h"
#include "xstatus.h"

#define DDYNCLK_CTRL          0x0
#define DDYNCLK_STATUS        0x4
#define DDYNCLK_CLK_L         0x8
#define DDYNCLK_FB_L          0x0C
#define DDYNCLK_FB_H_CLK_H    0x10
#define DDYNCLK_DIV           0x14
#define DDYNCLK_LOCK_L        0x18
#define DDYNCLK_FLTR_LOCK_H   0x1C
#define DDYNCLK_REF_CLK_FREQ  0x20


#define DDynClk_ReadReg(BaseAddress, RegOffset) \
		Xil_In32((BaseAddress) + ((u32)RegOffset))

#define DDynClk_WriteReg(BaseAddress, RegOffset, Data) 	\
		Xil_Out32((BaseAddress) + ((u32)RegOffset), (u32)(Data))

/**
 * This typedef contains configuration information for a DynClk instance
 */
typedef struct {
	u16 DeviceId;		/* DeviceId is the unique ID of the DynClk core */
	UINTPTR BaseAddress;	/* BaseAddress is the physical base address
				  *  of the core's registers */
} DDynClk_Config;

typedef struct {
	DDynClk_Config Config;	//Hardware Configuration
	u32 freq;
	u32 RefClkFreqHz;
	u32 IsReady;		// Core and the driver instance are initialized
} DDynClk;

/************************** Function Prototypes ****************************/
DDynClk_Config* DDynClk_LookupConfig(u16 DeviceId);
int DDynClk_CfgInitialize(DDynClk *InstancePtr, DDynClk_Config *CfgPtr,
			UINTPTR EffectiveAddr);
int DDynClk_Disable(DDynClk *InstancePtr);
int DDynClk_Enable(DDynClk *InstancePtr);
int DDynClk_SetRate(DDynClk *InstancePtr, uint32_t RateInHz);
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the AXI_DYNCLK instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus DDynClk_SelfTest(void * baseaddr_p);

#ifdef __cplusplus
}
#endif

#endif /* DDYNCLK_H_ */
