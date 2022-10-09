/******************************************************************************/
/*                                                                            */
/* PWM_Analyzer.h -- Driver definitions for the PWM_Analyzer IP               */
/*                                                                            */
/******************************************************************************/
/* Author: Arvin Tang                                                         */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PWM_Analyzer IP from Digilent.      */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    09/12/2017(atangzwj): Created                                           */
/*                                                                            */
/******************************************************************************/

#ifndef PWM_ANALYZER_H
#define PWM_ANALYZER_H


/************ Include Files ************/

#include "xil_types.h"
#include "xstatus.h"


/************ Macro Definitions ************/

// Register offsets for PWM_Analyzer's AXI GPIO registers
#define PWM_ANALYZER_OFF_TIME_OFFSET 0
#define PWM_ANALYZER_ON_TIME_OFFSET  4
#define PWM_ANALYZER_PERIOD_OFFSET   8


/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a PWM_ANALYZER register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the PWM_ANALYZERdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void PWM_ANALYZER_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define PWM_ANALYZER_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a PWM_ANALYZER register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the PWM_ANALYZER device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 PWM_ANALYZER_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define PWM_ANALYZER_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the PWM_ANALYZER instance to be worked on.
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
XStatus PWM_ANALYZER_Reg_SelfTest(void * baseaddr_p);


/************ Function Prototypes ************/

u32 PWM_Analyzer_GetDutyCycle_percent(u32 baseAddr);

double PWM_Analyzer_GetDutyCycle_decFrac(u32 baseAddr);

/****** Data in milliseconds (ms) ******/
u32 PWM_Analyzer_GetOffTime_ms(u32 baseAddr, int clk_freq);

u32 PWM_Analyzer_GetOnTime_ms(u32 baseAddr, int clk_freq);

u32 PWM_Analyzer_GetPeriod_ms(u32 baseAddr, int clk_freq);

/****** Data in microseconds (us) ******/
u32 PWM_Analyzer_GetOffTime_us(u32 baseAddr, int clk_freq);

u32 PWM_Analyzer_GetOnTime_us(u32 baseaddr, int clk_freq);

u32 PWM_Analyzer_GetPeriod_us(u32 baseAddr, int clk_freq);

/****** Data in nanoseconds (ns) ******/
u32 PWM_Analyzer_GetOffTime_ns(u32 baseAddr, int clk_freq);

u32 PWM_Analyzer_GetOnTime_ns(u32 baseAddr, int clk_freq);

u32 PWM_Analyzer_GetPeriod_ns(u32 baseAddr, int clk_freq);

/****** Data in clock edges ******/
u32 PWM_Analyzer_GetOffTime_clkEdges(u32 baseAddr);

u32 PWM_Analyzer_GetOnTime_clkEdges(u32 baseAddr);

u32 PWM_Analyzer_GetPeriod_clkEdges(u32 baseAddr);

#endif // PWM_ANALYZER_H
