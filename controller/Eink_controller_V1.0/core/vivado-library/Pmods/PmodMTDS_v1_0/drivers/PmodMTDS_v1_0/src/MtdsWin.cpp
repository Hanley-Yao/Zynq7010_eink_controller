/********************************************************************************/
/*																				*/
/*	MtdsWin.cpp	--	Implementation for MTDS Windowing System Object Class		*/
/*																				*/
/********************************************************************************/
/*	Author: 	Gene Apperson													*/
/*	Copyright 2015, Digilent Inc. All rights reserved.							*/
/********************************************************************************/
/*  Module Description: 														*/
/*																				*/
/*																				*/
/********************************************************************************/
/*  Revision History:															*/
/*																				*/
/*	2015-10-13(GeneApperson): created											*/
/*																				*/
/********************************************************************************/


/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include	<stdlib.h>
#include	<string.h>

#include	<stdint.h>

#include	"ProtoDefs.h"
#include	"mtds.h"
#include	"MtdsCore.h"

/* ------------------------------------------------------------ */
/*				Local Type Definitions							*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Global Variables								*/
/* ------------------------------------------------------------ */

extern CHDR *	pchdrMtdsCmd;
extern RHDR *	prhdrMtdsRet;
extern uint8_t	rgbMtdsRetVal[cbRetValInit+sizeof(RHDR)];

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
/*				MTFS Object Class Implementation				*/
/* ------------------------------------------------------------ */
/***	MTWS::CreateWindow(hwinParent, wcls, wstl, xco, yco, dxco, dyco)
**
**	Parameters:
**		hwinParent	- handle to the parent window (or 0 for a top level window)
**		wcls		- window class
**		wstl		- window style bits
**		xco, yco	- origin of client area of window
**		dxco, dyco	- dimensions of client area of window
**
**	Return Values:
**		Returns HWIN if successful
**
**	Errors:
**		Returns 0 if failure.
**
**	Description:
**		Create a window with the specified attributes and return its handle.
*/

HWIN MTWS::CreateWindow(HWIN hwinParent, uint16_t wcls, uint32_t wstl, 
							int16_t xco, int16_t yco, int16_t dxco, int16_t dyco) {

	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM4A8B	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwinParent;
	prm.valA2 = 0;
	prm.valA3 = 0;
	prm.valA4 = wstl;
	prm.valB1 = wcls;
	prm.valB2 = xco;
	prm.valB3 = yco;
	prm.valB4 = dxco;
	prm.valB5 = dyco;

	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinCreateWindow, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return success.
	*/
	return pret->valA1;


}

/* ------------------------------------------------------------ */
/***	MTWS::CloseWindow(hwin)
**
**	Parameters:
**		hwin		- handle to the window
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Deactivate the specified window and prepare it for being destroyed.
*/

bool MTWS::CloseWindow(HWIN hwin) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinCloseWindow, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::DestroyWindow(hwin)
**
**	Parameters:
**		hwin		- handle to the window
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Remove the specified window from the system.
*/

bool MTWS::DestroyWindow(HWIN hwin) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinDestroyWindow, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::ShowWindow(hwin, fShow)
**
**	Parameters:
**		hwin		- handle to the window
**		fShow		- true to show the window, false to hide the window
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Show or hide the specified window
*/

bool MTWS::ShowWindow(HWIN hwin, bool fShow) {
	PRM1A1B	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valB1 = fShow ? 1 : 0;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinShowWindow, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::SetPosition(hwin, xco, yco)
**
**	Parameters:
**		hwin		- handle to the window
**		xco, yco	- new window origin
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Set the window origin to the new position.
*/

bool MTWS::SetPosition(HWIN hwin, int16_t xco, int16_t yco) {
	PRM1A2B	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valB1 = xco;
	prm.valB2 = yco;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinSetPosition, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::SetSize(hwin, dxco, dyco)
**
**	Parameters:
**		hwin		- handle to the window
**		dxco, dyco	- new window size
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Set the window size to the new values.
*/

bool MTWS::SetSize(HWIN hwin, int16_t dxco, int16_t dyco) {
	PRM1A2B	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valB1 = dxco;
	prm.valB2 = dyco;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinSetSize, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::MoveWindow(hwin, wmv, xco, yco, dxco, dyco)
**
**	Parameters:
**		hwin		- handle to the window
**		wmv			- mask to indicate which portions of the window size and position to change
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Move or resize the specified window
*/

bool MTWS::MoveWindow(HWIN hwin, uint16_t wmv, int16_t xco, int16_t yco, int16_t dxco, int16_t dyco) {
	PRM1A5B	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valB1 = wmv;
	prm.valB2 = xco;
	prm.valB3 = yco;
	prm.valB4 = dxco;
	prm.valB5 = dyco;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinMoveWindow, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::GetWindowPos(hwin, pxco, pyco, pdxco, pdyco)
**
**	Parameters:
**		hwin		- handle to the window
**		pxco, pyco	- pointers to variables to receive window position
**		pdxco, pdyco - pointer to variables to receive window size
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Return the current position and size of the window
*/

bool MTWS::GetWindowPos(HWIN hwin, int16_t * pxco, int16_t * pyco, int16_t * pdxco, int16_t * pdyco) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinGetWindowPos, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	if (pxco != 0) {
		*pxco = pret->valB1;
	}
	if (pyco != 0) {
		*pyco = pret->valB2;
	}
	if (pdxco != 0) {
		*pdxco = pret->valB3;
	}
	if (pdyco != 0) {
		*pdyco = pret->valB4;
	}

	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::GetWindowRect(hwin, prct)
**
**	Parameters:
**		hwin		- handle to the window
**		prct		- pointer to RCT to receive window rectangle
**
**	Return Values:
**		none
**
**	Errors:
**		Returns status code
**
**	Description:
**		Return the bounding rectangle of the window
*/

bool MTWS::GetWindowRect(HWIN hwin, RCT * prct) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinGetWindowRect, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	prct->xcoLeft = pret->valB1;
	prct->ycoTop = pret->valB2;
	prct->xcoRight = pret->valB3;
	prct->ycoBottom = pret->valB4;

	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::GetClientRect(hwin, prct)
**
**	Parameters:
**		hwin		- handle to the window
**		prct		- pointer to RCT to receive window rectangle
**
**	Return Values:
**		none
**
**	Errors:
**		Returns status code
**
**	Description:
**		Return the bounding rectangle of the window
*/

bool MTWS::GetClientRect(HWIN hwin, RCT * prct) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinGetClientRect, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	prct->xcoLeft = pret->valB1;
	prct->ycoTop = pret->valB2;
	prct->xcoRight = pret->valB3;
	prct->ycoBottom = pret->valB4;

	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::BeginUpdate(hwin)
**
**	Parameters:
**		hwin		- handle to the window
**
**	Return Values:
**		Returns a DS handle for updating the window
**
**	Errors:
**		Returns 0 if error.
**
**	Description:
**		Prepare to draw on the client area of the specified window.
*/

HDS MTWS::BeginUpdate(HWIN hwin) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinBeginUpdate, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return success.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTWS::EndUpdate(hwin)
**
**	Parameters:
**		hwin		- handle to the window
**
**	Return Values:
**		Returns a DS handle for updating the window
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		End drawing on the client area of the specified window.
*/

bool MTWS::EndUpdate(HWIN hwin) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinEndUpdate, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::DrawBorder(hwin)
**
**	Parameters:
**		hwin		- handle to the window
**
**	Return Values:
**		Returns a DS handle for updating the window
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Draw the non-client areas of the window.
*/

bool MTWS::DrawBorder(HWIN hwin) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinDrawBorder, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::BeginNcUpdate(hwin)
**
**	Parameters:
**		hwin		- handle to the window
**
**	Return Values:
**		Returns a DS handle for updating the window
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Prepare to draw on the non-client area of the specified window.
*/

HDS MTWS::BeginNcUpdate(HWIN hwin) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinBeginNcUpdate, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return success.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTWS::EndNcUpdate(hwin)
**
**	Parameters:
**		hwin		- handle to the window
**
**	Return Values:
**		Returns a DS handle for updating the window
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		End drawing on the non-client area of the specified window.
*/

bool MTWS::EndNcUpdate(HWIN hwin) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinEndNcUpdate, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::SetWindowId(hwin, id)
**
**	Parameters:
**		hwin		- handle to the window
**		id			- window identifier to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Set the window identifier to the specified value.
*/

bool MTWS::SetWindowId(HWIN hwin, uint32_t id) {
	PRM2A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valA2 = id;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinSetWindowId, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::GetWindowId(hwin)
**
**	Parameters:
**		hwin		- handle to the window
**
**	Return Values:
**		Returns the window identifier
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Get the window identifier for the specified window.
*/

uint32_t MTWS::GetWindowId(HWIN hwin) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinGetWindowId, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return success.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTWS::SetWindowTitle(hwin, szTitle)
**
**	Parameters:
**		hwin		- handle to the window
**		szTitle		- window title string to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Set the window title to the specified value.
*/

bool MTWS::SetWindowTitle(HWIN hwin, char * szTitle) {
	PRM1A1B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valB1 = cchTitleMax;

	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinSetWindowTitle, sizeof(prm), (uint8_t *)&prm,
						cchTitleMax, (uint8_t *)szTitle);

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
/***	MTWS::GetWindowTitle(hwin, cchMax, szTitle)
**
**	Parameters:
**		hwin		- handle to the window
**		cchMax		- maximum number of characters to return
**		szTitle		- buffer to receive window title string
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Get the window title from the specified window.
*/

bool MTWS::GetWindowTitle(HWIN hwin, uint32_t cchMax, char * szTitle) {
	PRM2A	prm;

	if (cchMax > cchTitleMax) {
		cchMax = cchTitleMax;
	}

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valA2 = cchMax;

	mtds.MtdsProcessCmdRd(clsCmdWin, cmdWinGetWindowTitle, sizeof(prm), (uint8_t *)&prm,
							cchMax, (uint8_t *)szTitle);

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
/***	MTWS::SetWindowValue(hwin, val)
**
**	Parameters:
**		hwin		- handle to the window
**		id			- window value to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Set the window value to the specified value.
*/

bool MTWS::SetWindowValue(HWIN hwin, uint32_t val) {
	PRM2A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valA2 = val;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinSetWindowValue, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::GetWindowValue(hwin, pval)
**
**	Parameters:
**		hwin		- handle to the window
**		pval		- pointer to the variable to receive the window value
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Get the window value for the specified window.
*/

bool MTWS::GetWindowValue(HWIN hwin, uint32_t * pval) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinGetWindowValue, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	*pval = pret->valA1;
	return true;

}

/* ------------------------------------------------------------ */
/***	MTWS::SetWindowString(hwin, cch, rgch)
**
**	Parameters:
**		hwin		- handle to the window
**		cch			- number of characters to send
**		rgch		- window string to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Store the specified string into the specified window.
*/

bool MTWS::SetWindowString(HWIN hwin, uint32_t cch, char * rgch) {
	PRM2A	prm;

	if (cch > cchWindowStringMax) {
		cch = cchWindowStringMax;
	}
		
	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valA2 = cch;

	mtds.MtdsProcessCmdWr(clsCmdWin, cmdWinSetWindowString, sizeof(prm), (uint8_t *)&prm,
						cch, (uint8_t *)rgch);

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
/***	MTWS::GetWindowString(hwin, cchBuf, pcchRet, pcchMax, rgch)
**
**	Parameters:
**		hwin		- handle to the window
**		cchBuf		- maximum number of characters to return
**		pcchRet		- pointer to variable to receive number of bytes returned
**		pcchMax		- pointer to variable to receive total length of the window string
**		rgch		- buffer to receive the window string
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error.
**
**	Description:
**		Get the window title from the specified window.
*/

bool MTWS::GetWindowString(HWIN hwin, uint32_t cchBuf, uint32_t * pcchRet, uint32_t * pcchMax, char * rgch) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM2A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hwin;
	prm.valA2 = cchBuf;

	mtds.MtdsProcessCmdRd(clsCmdWin, cmdWinGetWindowString, sizeof(prm), (uint8_t *)&prm,
							cchBuf, (uint8_t *)rgch);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	if (pcchRet != 0) {
		*pcchRet = pret->valA1;
	}
	if (pcchMax != 0) {
		*pcchMax = pret->valA2;
	}

	return true;

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

/********************************************************************************/

