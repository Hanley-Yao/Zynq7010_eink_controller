

/***************************** Include Files *******************************/
#include "PWM.h"
#include "xil_io.h"

/************************** Function Definitions ***************************/

void PWM_Set_Period(u32 baseAddr, u32 clocks)
{
	Xil_Out32(baseAddr + PWM_AXI_PERIOD_REG_OFFSET, clocks);
}

void PWM_Set_Duty(u32 baseAddr, u32 clocks, u32 pwmIndex)
{
	Xil_Out32(baseAddr + PWM_AXI_DUTY_REG_OFFSET + (4*pwmIndex), clocks);
}

u32 PWM_Get_Period(u32 baseAddr)
{
	return Xil_In32(baseAddr + PWM_AXI_PERIOD_REG_OFFSET);
}

u32 PWM_Get_Duty(u32 baseAddr, u32 pwmIndex)
{
	return Xil_In32(baseAddr + PWM_AXI_DUTY_REG_OFFSET + (4*pwmIndex));
}

void PWM_Enable(u32 baseAddr)
{
	Xil_Out32(baseAddr + PWM_AXI_CTRL_REG_OFFSET, 1);
}

void PWM_Disable(u32 baseAddr)
{
	Xil_Out32(baseAddr + PWM_AXI_CTRL_REG_OFFSET, 0);
}
