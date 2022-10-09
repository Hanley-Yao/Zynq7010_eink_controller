
#ifndef MIPI_D_PHY_RX_H
#define MIPI_D_PHY_RX_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

#define MAJOR_VERSION (1)
#define MINOR_VERSION (0)
/****************** Register map ********************/
#define CR_OFFSET 0x0
#define VERSION_OFFSET 0xC 

/****************** Bit map ********************/
#define CR_ENABLE_MASK     0x2
#define CR_RESET_MASK      0x1
#define VERSION_MAJOR_MASK 0xFFFF0000
#define VERSION_MAJOR_SHIFT 16
#define VERSION_MINOR_MASK 0x0000FFFF
#define VERSION_MINOR_SHIFT 0
/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a MIPI_D_PHY_RX register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the MIPI_D_PHY_RXdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void MIPI_D_PHY_RX_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define MIPI_D_PHY_RX_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a MIPI_D_PHY_RX register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the MIPI_D_PHY_RX device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 MIPI_D_PHY_RX_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define MIPI_D_PHY_RX_mReadReg(BaseAddress, RegOffset) \
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
 * @param   baseaddr_p is the base address of the MIPI_D_PHY_RX instance to be worked on.
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
XStatus MIPI_D_PHY_RX_SelfTest(void * baseaddr_p);

#endif // MIPI_D_PHY_RX_H
