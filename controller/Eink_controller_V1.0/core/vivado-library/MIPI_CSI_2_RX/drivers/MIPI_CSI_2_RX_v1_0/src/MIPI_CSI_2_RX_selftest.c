
/***************************** Include Files *******************************/
#include "MIPI_CSI_2_RX.h"
#include "xparameters.h"
#include "stdio.h"
#include "xil_io.h"

/************************** Constant Definitions ***************************/
#define READ_WRITE_MUL_FACTOR 0x10

/************************** Function Definitions ***************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the MIPI_CSI_2_RXinstance to be worked on.
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
XStatus MIPI_CSI_2_RX_Reg_SelfTest(void * baseaddr_p)
{
	u32 baseaddr;
   u32 version;
   
   baseaddr = (u32) baseaddr_p;
   
   version = MIPI_CSI_2_RX_mReadReg(baseaddr, VERSION_OFFSET);
   
   if (!(((version & VERSION_MAJOR_MASK) >> VERSION_MAJOR_SHIFT == MAJOR_VERSION) &&
        ((version & VERSION_MINOR_MASK) >> VERSION_MINOR_SHIFT == MINOR_VERSION)))
   {
     return XST_FAILURE;
   }
   
   return XST_SUCCESS;
}
