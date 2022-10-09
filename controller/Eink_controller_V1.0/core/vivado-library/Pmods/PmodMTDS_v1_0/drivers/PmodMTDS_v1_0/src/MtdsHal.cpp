/************************************************************************/
/*																		*/
/*	MtdsHal.cpp	--	MTDS HAL Layer for Microblaze/Zynq					*/
/*																		*/
/************************************************************************/
/*	Author: 	Thomas Kappenman										*/
/*	Copyright 2016, Digilent, Inc. All rights reserved.					*/
/************************************************************************/
/*  Module Description: 												*/
/*																		*/
/*	This module contains the hardware abstraction layer implementation	*/
/*	for the MTDS library for use on the MPIDE and Arduino platforms.	*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	2016-10-1(TommyK): Created based on MtdsHal.cpp for Arduino			*/
/*	2016-10-30(SamB): Code/comment cleanup, change Init function name	*/
/*  12/20/2017(atangzwj): Replaced delay functions with sleep           */
/*																		*/
/************************************************************************/


/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "xparameters.h"
#include "xspi.h"
#include "xtmrctr.h"
XSpi MTDS_Spi;
XTmrCtr Timer;
XTmrCtr_Config Timer_Config =
{
	0,
	0,
#ifdef XPAR_CPU_CORE_CLOCK_FREQ_HZ
	XPAR_CPU_CORE_CLOCK_FREQ_HZ
#else
	100000000
#endif
};
XSpi_Config MTDSSPIConfig =
{
	0,
	XPAR_PMODMTDS_0_AXI_LITE_SPI_BASEADDR,
	1,
	0,
	1,
	8,
	0,
	0,
	0,
	0,
	0
};

#include	<stdint.h>
#include	"ProtoDefs.h"
#include	"mtds.h"
#include	"MtdsHal.h"
#include "sleep.h"

/* ------------------------------------------------------------ */
/*				Local Type Definitions							*/
/* ------------------------------------------------------------ */

/* Symbols used for initializing and operating the SPI controller.
*/
#define SPI_MODE0 ((0 << _SPICON_CKP)|(1 << _SPICON_CKE))		// CKP = 0 CKE = 1
#define SPI_MODE1 ((0 << _SPICON_CKP)|(0 << _SPICON_CKE))		// CKP = 0 CKE = 0
#define SPI_MODE2 ((1 << _SPICON_CKP)|(1 << _SPICON_CKE))		// CKP = 1 CKE = 1 
#define SPI_MODE3 ((1 << _SPICON_CKP)|(0 << _SPICON_CKE))		// CKP = 1 CKE = 0

/* ------------------------------------------------------------ */
/*				Global Variables								*/
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*				Local Variables									*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Forward Declarations							*/
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*				Procedure Definitions							*/
/* ------------------------------------------------------------ */
/***	MtdsHalInit(pinSel)
**
**	Parameters:
**		pinSel		- digital pin number of select pin
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		This function performs any system initialization required for the
**		platform. This can include initializing timers, settting up pin
**		direction, and so on. The pinSel parameter is specifically used in
**		the Arduino/MPIDE environment and may or may not be used on other
**		platforms.
*/

void MtdsHalInit(int pinSel) {

	XTmrCtr_CfgInitialize(&Timer, &Timer_Config, XPAR_PMODMTDS_0_AXI_LITE_TIMER_BASEADDR);
	XTmrCtr_SetOptions(&Timer, 0, XTC_AUTO_RELOAD_OPTION| XTC_CASCADE_MODE_OPTION);
	XTmrCtr_SetResetValue(&Timer, 0, 0);
	XTmrCtr_Reset(&Timer,0);
	XTmrCtr_Reset(&Timer,1);
	XTmrCtr_Start(&Timer, 0);
	Xil_Out32(XPAR_PMODMTDS_0_AXI_LITE_GPIO_BASEADDR+4, 0b11);//Set IntA and IntB to inputs
	Xil_Out32(XPAR_PMODMTDS_0_AXI_LITE_GPIO_BASEADDR+8, 0b111);
	Xil_Out32(XPAR_PMODMTDS_0_AXI_LITE_GPIO_BASEADDR+12, 0b000);//Set chip selects(ch2) to outputs
}

/* ------------------------------------------------------------ */
/***	MtdsHalEnableStatusPin(idPin
**
**	Parameters:
**		idPin		- status pin id number of pin to enable
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Enable the specified status pin. This means make it be an input.
**
**		When building for the Multi-Touch Display Shield, the pin numbers for
**		the status pins are defined in the MtdsHal.h header file. When building
**		for the PmodMtds, we have to compute the pin numbers based on the Pmod
**		connector the board is plugged into. We can get this as a constant offset
**		from the pin number of ch SPI CS pin, pinMtdsSel. For now, we assume that
**		if we are being built for a board with Pmod connectors, we are using the
**		PmodMtds.
*/

void MtdsHalEnableStatusPin(int idPin) {

	Xil_Out32(XPAR_PMODMTDS_0_AXI_LITE_GPIO_BASEADDR+4,0b11);//Set interrupts (ch1) as inputs

}

/* ------------------------------------------------------------ */
/***	MtdsHalGetStatusPin(idPin)
**
**	Parameters:
**		idPin		- id of status pin to read
**
**	Return Values:
**		Returns true if pin is high, false if pin is low
**
**	Errors:
**		none
**
**	Description:
**		Return the state of the specified status pin.
*/

bool MtdsHalGetStatusPin(int idPin) {

	return false;
}

/* ------------------------------------------------------------ */
/***	MtdsHalResetDisplay(pinSel)
**
**	Parameters:
**		pinSel		- digital pin number for SPI CS pin
**
**	Return Values:
**		Returns true if reset actually performed, false if not
**
**	Errors:
**		none
**
**	Description:
**		This function is used to reset the display board on hardware
**		and platforms where the display board can be reset. 
**		The Multi-Toucn	Display Shield doesn't support software controlled
**		reset and is automatically reset whenever the host board is reset.
**		The PmodMTDS doesn't get reset automatically and needs to be reset
**		under software control when the system initializes.
**		The pinSel parameter can be used to determine which pin needs to
**		be toggled to reset the display.
*/

bool MtdsHalResetDisplay(int pinSel) {

	return false;
}

/* ------------------------------------------------------------ */
/***	MtdsHalInitSpi(pspiInit, frq)
**
**	Parameters:
**		pspiInit		- indicator for the SPI port number
**		frq				- spi clock frequency to use
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		This function initializes the SPI port being used by the platform
**		for communications between the host and the display interface. Depending
**		on the platform, one of both of the paramters may be ignored.
*/

void MtdsHalInitSpi(uint32_t pspiInit, uint32_t frq) {

XSpi_CfgInitialize(&MTDS_Spi, &MTDSSPIConfig, XPAR_PMODMTDS_0_AXI_LITE_SPI_BASEADDR);
XSpi_SetOptions(&MTDS_Spi, (XSP_MASTER_OPTION) | XSP_MANUAL_SSELECT_OPTION);
XSpi_SetSlaveSelect(&MTDS_Spi, 1);
XSpi_Start(&MTDS_Spi);
XSpi_IntrGlobalDisable(&MTDS_Spi);

}

/* ------------------------------------------------------------ */
/***	MtdsHalEnableSlave(fEn)
**
**	Parameters:
**		fEn		- true to enable, false to disable
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Enable/Disable the SPI slave (display board).
*/

void MtdsHalEnableSlave(bool fEn) {

	if (fEn){
		Xil_Out32(XPAR_PMODMTDS_0_AXI_LITE_GPIO_BASEADDR+8, Xil_In32(XPAR_PMODMTDS_0_AXI_LITE_GPIO_BASEADDR+8)&0b011);
	}
	else{
		Xil_Out32(XPAR_PMODMTDS_0_AXI_LITE_GPIO_BASEADDR+8, Xil_In32(XPAR_PMODMTDS_0_AXI_LITE_GPIO_BASEADDR+8)|0b100);
	}
}

/* ------------------------------------------------------------ */
/***	MtdsHalSpiReady() 
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns true if the SPI port is ready to accept a byte
**
**	Errors:
**		none
**
**	Description:
**		Determine if the SPI port can accept a byte
*/

bool MtdsHalSpiReady() {

return XSpi_GetStatusReg(&MTDS_Spi)&&0b100;//TX_Empty bit
}

/* ------------------------------------------------------------ */
/***	MtdsHalPutSpiByte(bSnd)
**
**	Parameters:
**		bSnd		- byte to write to the SPI port
**
**	Return Values:
**		Returns the byte read from the SPI port
**
**	Errors:
**		none
**
**	Description:
**		Exchange a byte with the SPI slave device (display board)
*/

uint8_t MtdsHalPutSpiByte(uint8_t bSnd) {
	uint8_t	bRcv;

//XSpi_Transfer(&MTDS_Spi, &bSnd,&bRcv, 1);

    XSpi_WriteReg(MTDS_Spi.BaseAddr, XSP_DTR_OFFSET, bSnd);//Fill TX
	XSpi_SetControlReg(&MTDS_Spi, XSpi_GetControlReg(&MTDS_Spi)&~XSP_CR_TRANS_INHIBIT_MASK);//Start Transfer
	while ((XSpi_IntrGetStatus(&MTDS_Spi) & XSP_INTR_TX_EMPTY_MASK) == 0);//Wait until TX is empty
	XSpi_IntrClear(&MTDS_Spi,XSP_INTR_TX_EMPTY_MASK);//Clear TX Empty interrupt
	XSpi_SetControlReg(&MTDS_Spi, XSpi_GetControlReg(&MTDS_Spi) | XSP_CR_TRANS_INHIBIT_MASK);//Stop Transfer
    bRcv = XSpi_ReadReg(MTDS_Spi.BaseAddr, XSP_DRR_OFFSET);//Receive RX

	return bRcv;
}

/* ------------------------------------------------------------ */
/***	MtdsHalTmsElapsed()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the number of milliseconds elapsed since startup
**
**	Errors:
**		none
**
**	Description:
**		Returns the number of milliseconds that have elapsed since the host
**		started running. This is used for determining timeout for failed communications
**		between the host and the display device and for timing how long API functions
**		take to execute.
**		This function is not strictly required, and can always just return 0 if the
**		hardware resources aren't available to implement it. If it isn't implemented,
**		detection of lost communications between the host and the display board won't
**		work correctly and the host may lock up if communications isn't working reliably.
*/

uint32_t MtdsHalTmsElapsed() {

	return millis();
}

/* ------------------------------------------------------------ */
/***	MtdsHalTusElapsed()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the number of microseconds elapsed since reset
**
**	Errors:
**		none
**
**	Description:
**		Return the number of microseconds elapsed since reset. This is only used
**		to time how long MTDS commands take to execute, so if it isn't implemented
**		or isn't accurate the only problem will be that the API function that
**		returns the time for a command to execute won't work correctly.
*/

uint32_t MtdsHalTusElapsed() {

	return micros();
}

/* ------------------------------------------------------------ */
/*				XXXX Object Class Implementation				*/
/* ------------------------------------------------------------ */

/***	ProcName
**
**	Parameters:
**
**	Return Values:
**
**	Errors:
**
**	Description:
**
*/

/* ------------------------------------------------------------ */

/************************************************************************/

