
/***************************** Include Files *******************************/
#include "ddynclk.h"
#include "xparameters.h"
#include "stdio.h"
#include "xil_io.h"

/************************** Constant Definitions ***************************/

/************************** Function Definitions ***************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the DDynClk instance to be worked on.
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
XStatus DDynClk_SelfTest(void * baseaddr_p)
{
	u32 baseaddr;
	baseaddr = (u32) baseaddr_p;
	
	if (0 == DDynClk_ReadReg(baseaddr, DDYNCLK_REF_CLK_FREQ))
	  return XST_FAILURE;

	return XST_SUCCESS;
}
