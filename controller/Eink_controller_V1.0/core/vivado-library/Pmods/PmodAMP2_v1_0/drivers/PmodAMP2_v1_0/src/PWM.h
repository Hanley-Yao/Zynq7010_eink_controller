
#ifndef PWM_H
#define PWM_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

#define PWM_AXI_CTRL_REG_OFFSET 0
#define PWM_AXI_PERIOD_REG_OFFSET 8
#define PWM_AXI_DUTY_REG_OFFSET 64


/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a PWM register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the PWMdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void PWM_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define PWM_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a PWM register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the PWM device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 PWM_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define PWM_mReadReg(BaseAddress, RegOffset) \
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
 * @param   baseaddr_p is the base address of the PWM instance to be worked on.
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
XStatus PWM_Reg_SelfTest(void * baseaddr_p);

void PWM_Set_Period(u32 baseAddr, u32 clocks);
void PWM_Set_Duty(u32 baseAddr, u32 clocks, u32 pwmIndex);
u32 PWM_Get_Period(u32 baseAddr);
u32 PWM_Get_Duty(u32 baseAddr, u32 pwmIndex);
void PWM_Enable(u32 baseAddr);
void PWM_Disable(u32 baseAddr);

#endif // PWM_H
