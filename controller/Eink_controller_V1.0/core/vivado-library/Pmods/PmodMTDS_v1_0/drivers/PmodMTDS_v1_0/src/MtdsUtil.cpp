/********************************************************************************/
/*																				*/
/*	mtds.cpp	--	Digilent Multi-Touch Display Shield Library					*/
/*																				*/
/********************************************************************************/
/*	Author: 	Gene Apperson													*/
/*	Copyright 2015, Digilent, Inc. All rights reserved.							*/
/********************************************************************************/
/*  Module Description: 														*/
/*																				*/
/*																				*/
/********************************************************************************/
/*  Revision History:															*/
/*																				*/
/*	2015/08/03(GeneApperson): Created											*/
/*																				*/
/********************************************************************************/

#define	OPT_BOARD_INTERNAL

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include	<stdlib.h>
#include	<string.h>

#include	<stdint.h>

#include	"ProtoDefs.h"
#include	"mtds.h"
#include	"MtdsCore.h"
#include	"MtdsHal.h"

/* ------------------------------------------------------------ */
/*				Local Type Definitions							*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Global Variables								*/
/* ------------------------------------------------------------ */

extern CHDR *	pchdrMtdsCmd;
extern RHDR *	prhdrMtdsRet;
extern uint8_t	rgbMtdsRetVal[cbRetValInit];

/* ------------------------------------------------------------ */
/*				Local Variables									*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Forward Declarations							*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Procedure Definitions							*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				MTDS Object Class Implementation				*/
/* ------------------------------------------------------------ */
/***	MTDS::FInitSystem()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Initialize the device firmware on the display device.
*/

bool MTDS::FInitDisplay() {

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilInit, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::GetVersionInfo(pvfino)
**
**	Parameters:
**		pvinfo		- Pointer to VINFO structure to fill in with version information
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Return version information about the library, display device firmware and display
**		device type.
*/

bool MTDS::GetVersionInfo(VINFO * pvinfo) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetFirmwareVersion, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Unpack the message from the return value packet.
	*/
	pvinfo->verLibMajor = verMtdsMajor;
	pvinfo->verLibMinor = verMtdsMinor;
	pvinfo->verFwMajor = pret->valB1;
	pvinfo->verFwMinor = pret->valB2;
	pvinfo->typDisplay = pret->valB3;
	pvinfo->verDisplay = pret->valB4;

	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::GetLastError(pcls, pcmd)
**
**	Parameters:
**		pcls	- pointer to variable to receive command class of last error
**		pcmd	- pointer to variable to receive command of last error
**
**	Return Values:
**		returns error status code of last error
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Return information about the last error that occured in processing
**		a command.
*/

uint8_t	MTDS::GetLastError(uint8_t * pcls, uint8_t * pcmd) {

	if (pcls != 0) {
		*pcls = clsLastError;
	}

	if (pcmd != 0) {
		*pcmd = cmdLastError;
	}

	return staLastError;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetDisplayEnable(st)
**
**	Parameters:
**		st		- display enable state to set (stDspOn or stDspOff)
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Enable/disable the display.
*/

bool MTDS::SetDisplayEnable(uint32_t st) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = st;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilSetDspEnable, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::GetDisplayEnable()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the enable state of the display
**
**	Errors:
**		Returns 0 if error
**
**	Description:
**		Returns the enable/disable state of the display.
*/

uint32_t MTDS::GetDisplayEnable() {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetDspEnable, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the display enable state.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetDisplayOrientation(dso)
**
**	Parameters:
**		dso		- display orientation to set (dsoPortrait or dsoLandscape)
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Sets the orientation of the display.
*/

bool MTDS::SetDisplayOrientation(uint32_t dso) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = dso;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilSetDspOrientation, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::GetDisplayOrientation()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the orientation of the display
**
**	Errors:
**		Returns 0 if error
**
**	Description:
**		Returns the orientation of the display.
*/

uint32_t MTDS::GetDisplayOrientation() {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetDspOrientation, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the display enable state.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetDisplayBacklight(val)
**
**	Parameters:
**		val		- display backlight brightness to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the display backlight brightness.
*/

bool MTDS::SetDisplayBacklight(uint32_t val) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = val;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilSetDspBacklight, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::GetDisplayBacklight()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the current backlight brightness of the display
**
**	Errors:
**		Returns 0 if error
**
**	Description:
**		Returns the current brightness of the display backlight.
*/

uint32_t MTDS::GetDisplayBacklight() {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetDspBacklight, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the display enable state.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetBacklightMode(val)
**
**	Parameters:
**		val		- backlight dimming mode to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns previous mode if successful, 0 if not
**
**	Description:
**		Set the display backlight brightness.
*/

uint32_t MTDS::SetBacklightMode(uint32_t val) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = val;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilSetBacklightMode, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the previous backlight mode.
	*/
	return pret->valA1;
}

/* ------------------------------------------------------------ */
/***	MTDS::ClearDisplay(clr)
**
**	Parameters:
**		clr			- color to fill display
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Clear the display to the specified color.
*/

bool MTDS::ClearDisplay(uint16_t clr) {
	PRM1B	prm;

	/* Send the command packet.
	*/
	prm.valB1 = clr;
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilClearDisplay, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::EnableStatusPin(idPin, fEn)
**
**	Parameters:
**		idPin		- identifier for the status pin to enable/disable
**		fEn			- enable/disable state to set (0=disable, !0=enable)
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Enable/disable the specified status pin. The status pins are an optional part of
**		the hardware interface spec and may or may not be supported. An attempt to enable
**		a non-supported status pin will fail, with an error code of staUtilNotSupported.
**		When supported, status pin A is set when there are touch messages in the message
**		queue.
**		When supported, status pin B is used internally as part of the communications
**		protocol between the host and the display hardware and its use can reduce some
**		of the communications overhead.
*/

bool MTDS::EnableStatusPin(int idPin, int fEn) {
	PRM2B	prm;

	/* If we are enabling the pin, ensure the pin on the host side is an input.
	*/
	if (fEn) {
		MtdsHalEnableStatusPin(idPin);
	}

	/* Send the command packet.
	*/
	prm.valB1 = idPin;
	prm.valB2 = fEn;
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilEnableStatusPin, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetStatusPin(idPin, st)
**
**	Parameters:
**		idPin		- identifier for the status pin to enable/disable
**		st			- on/off state to set (0=off, !0=on)
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
*/

bool MTDS::SetStatusPin(int idPin, int st) {
	PRM2B	prm;

	/* Send the command packet.
	*/
	prm.valB1 = idPin;
	prm.valB2 = st;
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilSetStatusPin, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetTchSensitivity(val)
**
**	Parameters:
**		val		- touch panel sensitivity to set (1-7)
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the touch panel sensitivity as specified.
*/

bool MTDS::SetTchSensitivity(uint32_t val) {
	PRM1A	prm;

	if ((val < 1) || (val > 7)) {
		clsLastError = clsCmdUtil;
		cmdLastError = cmdUtilSetTchSensitivity;
		staLastError = staUtilBadParameter;
		return false;
	}

	/* Send the command packet.
	*/
	prm.valA1 = val;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilSetTchSensitivity, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::GetTchSensitivity()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the current touch panel sensitivity (1 - 7)
**
**	Errors:
**		Returns 0 if error
**
**	Description:
**		Returns the current sensitivity setting for the touch panel.
*/

uint32_t MTDS::GetTchSensitivity() {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetTchSensitivity, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the touch panel sensitivity setting.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetTchMoveDelta(dxco, dyco)
**
**	Parameters:
**		dxco	- threshold delta in x direction for touch move
**		dyco	- threshold delta in y direction for touch move
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the threshold delta for touch move events. A finger move less than the
**		specified delta will not generate a finger move message.
*/

bool MTDS::SetTchMoveDelta(int16_t dxco, int16_t dyco) {
	PRM2B	prm;

	/* Send the command packet.
	*/
	prm.valB1 = dxco;
	prm.valB2 = dyco;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilSetTchMoveDelta, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::GetTchMoveDelta(pdxco, pdyco)
**
**	Parameters:
**		pdxco	- pointer to variable to receive touch dxco threshold
**		pdyco	- pointer to variable to receive touch dyco threshold
**
**	Return Values:
**		Returns the current touch panel finger move threshold delta values
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Returns the current finger move delta thresholds for the touch panel.
*/

bool MTDS::GetTchMoveDelta(int16_t * pdxco, int16_t * pdyco) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetTchMoveDelta, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return the touch panel threshold settings.
	*/
	if (pdxco != 0) {
		*pdxco = pret->valB1;
	}
	if (pdyco != 0) {
		*pdyco = pret->valB2;
	}
	return true;

}

/* ------------------------------------------------------------ */
/***	DS::GetMsgStatus()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the event status flags
**
**	Errors:
**		None
**
**	Description:
**		Query the shield for the status of the event system.
*/

uint32_t MTDS::GetMsgStatus() {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetMsgStatus, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the event status flags.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::ClearMsgQueue()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Clear and reset the event queue on the shield.
*/

bool MTDS::ClearMsgQueue() {

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilClearMsgQueue, 0, 0, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::PeekMsg(pevt)
**
**	Parameters:
**		pevt		- pointer to structure to receive the event
**
**	Return Values:
**		Returns error status
**
**	Errors:
**		Returns true if successful, false if error
**
**	Description:
**		Read the next event from the event queue without removing it
**		from the queue.
*/

bool MTDS::PeekMsg(MEVT * pevt) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilPeekMsg, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Unpack the message from the return value packet.
	*/
	pevt->tms = pret->valA1;
	pevt->hwin = pret->valA2;
	pevt->msg = (pret->valA3 >> 16) & 0xFFFF;
	pevt->val1 = pret->valA3 & 0xFFFF;
	pevt->val2 = pret->valA4;

	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::GetMsg(pevt)
**
**	Parameters:
**		pevt		- pointer to structure to receive the event
**
**	Return Values:
**		Returns error status
**
**	Errors:
**		Returns true if successful, false if error
**
**	Description:
**		Read the next event from the event queue removing it
**		from the queue.
*/

bool MTDS::GetMsg(MEVT * pevt) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetMsg, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Unpack the message from the return value packet.
	*/
	pevt->tms = pret->valA1;
	pevt->hwin = pret->valA2;
	pevt->msg = (pret->valA3 >> 16) & 0xFFFF;
	pevt->val1 = pret->valA3 & 0xFFFF;
	pevt->val2 = pret->valA4;

	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::PostMst(pevt)
**
**	Parameters:
**		pevt		- pointer to event structure to send
**
**	Return Values:
**		Returns error status
**
**	Errors:
**		Returns true if successful, false if error
**
**	Description:
**		Put the specified event at the end of the queue
*/

bool MTDS::PostMsg(MEVT * pevt) {
	PRM4A		prm;

	/* Send the command packet.
	*/
	prm.valA1 = pevt->tms;
	prm.valA2 = pevt->hwin;
	prm.valA3 = (pevt->msg << 16) + pevt->val1;
	prm.valA4 = pevt->val2;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilPostMsg, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::PushMsg(pevt)
**
**	Parameters:
**		pevt		- pointer to event structure to send
**
**	Return Values:
**		Returns error status
**
**	Errors:
**		Returns true if successful, false if error
**
**	Description:
**		Put the specified event at the head of the queue
*/

bool MTDS::PushMsg(MEVT * pevt) {
	PRM4A		prm;

	/* Send the command packet.
	*/
	prm.valA1 = pevt->tms;
	prm.valA2 = pevt->hwin;
	prm.valA3 = (pevt->msg << 16) + pevt->val1;
	prm.valA4 = pevt->val2;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilPushMsg, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::GetMemStatus(pmstat)
**
**	Parameters:
**		pmstat		- pointer to memory status structure
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Get memory heap status information from the shield. The shield will do a consistency
**		check on the heap and return the heap consistency status in the mrStat field. The
**		other fields will only be filled in if the heap status is mrMtdsOk.
*/

bool MTDS::GetMemStatus(MSTAT * pmstat) {

	/* Send the command packet.
	*/
	mtds.MtdsProcessCmdRd(clsCmdUtil, cmdUtilGetMemStatus, 0, 0, sizeof(MSTAT), (uint8_t *)pmstat);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetMemMode(mm)
**
**	Parameters:
**		mm		- memory heap operating mode to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the memory manager search and compaction operating modes.
*/

bool MTDS::SetMemMode(uint32_t	mm) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = mm;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilSetMemMode, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::GetFreeMem()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns amount of free space in memory pool
**
**	Errors:
**		Returns 0 if there is a heap consistency error
**
**	Description:
**		Get the number of free bytes available in the memory pool. The returned value
**		is a lower bound on the actual amount of free memory. If the free memory space
**		is fragmented, the returned value will be low.
*/

uint32_t MTDS::GetFreeMem() {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetFreeMem, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the free memory size.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::AllocMem(cbReq)
**
**	Parameters:
**		cbReq		- initial size for the memory object
**
**	Return Values:
**		Returns the memory handle for the allocated object
**
**	Errors:
**		Returns 0 if error
**
**	Description:
**		Allocate a memory object of the requested size from the heap on the shield.
**		The requested value specifies the initial size. The size can grow if necessary
**		as writes are done on the memory object.
*/

HMEM MTDS::AllocMem(uint32_t cbReq) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = cbReq;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilAllocMem, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the memory handle.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::GetMemSize(hmem)
**
**	Parameters:
**		hmem	- handle to memory block
**
**	Return Values:
**		Returns the current size of the specified memory object
**
**	Errors:
**		Returns 0 if there is a heap consistency error
**
**	Description:
**		Return the size of the specified memory block.
*/

uint32_t MTDS::GetMemSize(HMEM hmem) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hmem;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetMemSize, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the free memory size.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::FreeMem(hmem)
**
**	Parameters:
**		hmem		- handle of the memory object to free
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Free the specified memory object.
*/

bool MTDS::FreeMem(HMEM hmem) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hmem;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilFreeMem, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::ReadMem(hmem, ibRead, cbRead, rgbBuf, pcbRes)
**
**	Parameters:
**		hmem		- memory object handle
**		ibRead		- byte index within the object at which to start reading
**		cbRead		- number of bytes to read
**		rgbBuf		- buffer to receive bytes read
**		pcbRes		- pointer to variable to receive actual number of bytes read
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Read the specified number of bytes from the specified memory object. The
**		number of byte read will be less than requested if it would extend past the
**		end of the memory object.
*/

bool MTDS::ReadMem(HMEM hmem, uint32_t ibRead, uint32_t cbRead, uint8_t * rgbBuf, uint32_t * pcbRes) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM3A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hmem;
	prm.valA2 = ibRead;
	prm.valA3 = cbRead;

	mtds.MtdsProcessCmdRd(clsCmdUtil, cmdUtilReadMem, sizeof(prm), (uint8_t *)&prm, cbRead, rgbBuf);

	*pcbRes = pret->valA1;

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::WriteMem(hmem, ibWrite, cbWrite, rgbBuf, pcbRes)
**
**	Parameters:
**		hmem		- memory object handle
**		ibWrite		- byte index within the object at which to start writing
**		cbWrite		- number of bytes to write
**		rgbBuf		- buffer containing bytes to write
**		pcbRes		- pointer to variable to receive actual number of bytes written
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Write the specified number of bytes to the specified memory object. The memory
**		object will be resized as necessary to contain the bytes being written. The
**		number of byte written will be less than requested if it is not possible to grow
**		the memory object to contain them.
*/

bool MTDS::WriteMem(HMEM hmem, uint32_t ibWrite, uint32_t cbWrite, uint8_t * rgbBuf, uint32_t * pcbRes) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM3A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hmem;
	prm.valA2 = ibWrite;
	prm.valA3 = cbWrite;

	mtds.MtdsProcessCmdWr(clsCmdUtil, cmdUtilWriteMem, sizeof(prm), (uint8_t *)&prm, cbWrite, rgbBuf);

	*pcbRes = pret->valA1;

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return the file handle.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetDateTime(pdtm)
**
**	Parameters:
**		pdtm		- pointer to date/time structure to set
**
**	Return Values:
**		Returns error status
**
**	Errors:
**		Returns true if successful, false if error
**
**	Description:
**		Set the display devices clock to the specified date and time
*/

bool MTDS::SetDateTime(DTM * pdtm) {
	PRM6B		prm;

	/* Send the command packet.
	*/
	prm.valB1 = pdtm->sec;
	prm.valB2 = pdtm->min;
	prm.valB3 = pdtm->hour;
	prm.valB4 = pdtm->day;
	prm.valB5 = pdtm->month;
	prm.valB6 = pdtm->year;

	MtdsProcessCmdWr(clsCmdUtil, cmdUtilSetDateTime, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::GetDateTime(pdtm)
**
**	Parameters:
**		pdtm		- pointer to date time structure to receive data
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Get the current date and time from the display device.
*/

bool MTDS::GetDateTime(DTM * pdtm) {
	RET6B *	pret = (RET6B *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdUtil, cmdUtilGetDateTime, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Unpack the message from the return value packet.
	*/
	pdtm->sec   = pret->valB1;
	pdtm->min   = pret->valB2;
	pdtm->hour  = pret->valB3;
	pdtm->day   = pret->valB4;
	pdtm->month = pret->valB5;
	pdtm->year  = pret->valB6;

	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::FirmwareUpdate(szName)
**
**	Parameters:
**		szName	- pointer to buffer containing file name string
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		This passes the parameters for a firmware update to the
**		display system and then launches the update process. This
**		returns success if the update was launched successfully.
**		This does not mean that the update has completed successfully.
**		The update process will still be running when this returns.
**		Call GetUpdateStatus() to track the progress of the firmware
**		update.
*/

bool MTDS::FirmwareUpdate(char * szName) {
	PRM1B	prm;
	uint8_t	chn;

	/* Error check that the file name length is acceptable.
	*/
	if (strlen(szName) > cchUpdName) {
		clsLastError = clsCmdUtil;
		cmdLastError = cmdUtilBeginUpdate;
		staLastError = staUtilBadParameter;
		return false;
	}

	/* Send the command packet.
	*/
	prm.valB1 = strlen(szName)+1;

	mtds.MtdsProcessCmdWr(clsCmdUtil, cmdUtilBeginUpdate, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szName);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* The device accepted the BeginUpdate command. Now, tell it to launch the updater.
	*/
	chn = MtdsBeginUpdate();
	if (chn != chnStaSuccess) {
		staLastError = staCmdInternalError;
		return false;
	}

	/* Return success.
	*/
	return true;


}

/* ------------------------------------------------------------ */
/***	MTDS::GetUpdateStatus()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the current state of the firmware update process.
**
**	Errors:
**		The return status code indicates the error state.
**
**	Description:
**		Send a chnCmdRead command to the device. The byte that comes
**		back indicates where in the update process it is.
*/

uint8_t MTDS::GetUpdateStatus() {
	return MtdsQueryUpdate();
}

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

/********************************************************************************/

