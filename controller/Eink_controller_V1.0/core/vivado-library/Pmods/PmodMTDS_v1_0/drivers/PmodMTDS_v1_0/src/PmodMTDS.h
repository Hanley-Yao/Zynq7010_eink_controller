
#ifndef PmodMTDS_H
#define PmodMTDS_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xspi_l.h"
#include "xspi.h"

/* ------------------------------------------------------------ */
/*					Definitions									*/
/* ------------------------------------------------------------ */
#define bool u8
#define true 1
#define false 0



typedef struct PmodMTDS{
	u32 GPIO_addr;
	XSpi MTDSSpi;
}PmodMTDS;

	
	void MTDS_begin(PmodMTDS* InstancePtr, u32 GPIO_Address, u32 SPI_Address);
	void MTDS_end(PmodMTDS* InstancePtr);
	int MTDS_SPIInit(XSpi *SPIInstancePtr);
	u8 MTDS_ReadByte(PmodMTDS* InstancePtr);
	void MTDS_WriteByte(PmodMTDS* InstancePtr, u8 cmd);
	void MTDS_WriteSPI(PmodMTDS* InstancePtr, u8 reg, u8 *wData, int nData);
	void MTDS_ReadSPI(PmodMTDS* InstancePtr, u8 reg, u8 *rData, int nData);
	void MTDS_SetRegisterBits(PmodMTDS* InstancePtr, u8 reg, u8 mask, bool fValue);
	u8 MTDS_GetRegisterBits(PmodMTDS* InstancePtr, u8 bRegisterAddress, u8 bMask);






#endif // PmodMTDS_H
