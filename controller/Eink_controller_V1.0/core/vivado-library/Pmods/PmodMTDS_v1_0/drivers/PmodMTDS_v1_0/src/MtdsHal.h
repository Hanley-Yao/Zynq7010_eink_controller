/************************************************************************/
/*																		*/
/*	MtdsHal.h	--	Declarations for MTDS Library HAL Layer				*/
/*																		*/
/************************************************************************/
/*	Author:		Thomas Kappenman										*/
/*	Copyright 2016, Digilent Inc. All rights reserved.					*/
/************************************************************************/
/*  File Description:													*/
/*																		*/
/*	This header file defines the hardware abstraction layer interface	*/
/*	used by the MTDS library. This is the version for use on the MPIDE	*/
/*	and Arduino platforms, as well as the internal simulator for		*/
/*	display device firmware development.								*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	2016-10-01(TommyK): created											*/
/*	2016-10-30(SamB): Code/comment cleanup, change Init function name	*/
/*  12/20/2017(atangzwj): Removed delay functions, restored micros      */
/*                        function                                      */
/*																		*/
/************************************************************************/

#if !defined(_MTDSHAL_H_)
#define _MTDSHAL_H_

#include	<stdint.h>
#include "xparameters.h"
#include "xtmrctr.h"

/* ------------------------------------------------------------ */
/*					Miscellaneous Declarations					*/
/* ------------------------------------------------------------ */

#define	_SPI_BASE		0

/* Define digital pin numbers used by the hardware interface.
** The "standard" CS pin is taken from the symbol SS defined in the board variant
** header file for the selected board. This corresponds to the CS pin for the "default"
** SPI port, which is the one used by the standard SPI library.
** The "alternate" CS pin is supported on the Multi-Touch Display Shield when the CS
** select jumper is in the "alt" position. There is no alt CS pin on the PmodMTDS.
*/

extern XTmrCtr Timer;
static uint32_t mic_delta;
static uint32_t mil_delta;
static uint32_t mil_cnt;
static uint32_t mic_cnt;

int inline millis(){
	uint32_t c = XTmrCtr_ReadReg(Timer.BaseAddress, 0, XTC_TCR_OFFSET)/100000;
	if (c<mil_delta){
		mil_cnt+=0xFFFFFFFF-mil_delta+c;
	}
	else{
		mil_cnt+=c-mil_delta;
	}
	mil_delta=c;
	return mil_cnt;
}
int inline micros(){
	u32 c=XTmrCtr_ReadReg(Timer.BaseAddress, 0, XTC_TCR_OFFSET)/100;
	if (c<mic_delta){
		mic_cnt+=0xFFFFFFFF-mic_delta+c;
	}
	else{
		mic_cnt+=c-mic_delta;
	}
	mic_delta=c;
	return mic_cnt;
}

#define	pinMtdsSelStd		1				// standard SPI SS pin
#define	pinMtdsSelAlt		2				// alternate SPI SS pin


/* Pins available to be used for status between shield and host.
** These pins are labeled HOST_INTA and HOST_INTB on the Multi-Touch Display Shield
** schematic, but are not actually used as interrupt pins. They are available as general
** purpose status pins between the host and the shield. Their use is not required by the
** shield firmware or the MTDS library.
*/
#define	pinMtdsIntA			7		// touch panel message status pin
#define	pinMtdsIntB			3		// shield ready status pin

/* Default SPI clock frequency
*/
//TODO: This value is not required for FPGA designs, but it should be fixed to be accurate
#define	frqMtdsSpiDefault	4000000


/* ------------------------------------------------------------ */
/*					General Type Declarations					*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Object Class Declarations					*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Variable Declarations						*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */

void		MtdsHalInit(int pinSel);
void		MtdsHalEnableStatusPin(int idPin);
bool		MtdsHalGetStatusPin(int idPin);
bool		MtdsHalResetDisplay(int pinSel);
void		MtdsHalInitSpi(uint32_t pspiInit, uint32_t frq);
void		MtdsHalEnableSlave(bool fEn);
bool		MtdsHalSpiReady();
uint8_t		MtdsHalPutSpiByte(uint8_t bSnd);
uint32_t	MtdsHalTmsElapsed();
void		MtdsHalDelayMs(uint32_t tmsDelay);
uint32_t	MtdsHalTusElapsed();
void		MtdsHalDelayUs(uint32_t usDelay);

/* ------------------------------------------------------------ */

#endif		// _MTDSHAL_H_

/************************************************************************/
