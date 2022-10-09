/********************************************************************************/
/*																				*/
/*	MtdsGdi.cpp	--	Implementation for MTDS GDI Functions						*/
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
/*	2015/10/05(GeneApperson): Split off from mtds.cpp							*/
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
/*				MTDS Object Class Implementation				*/
/* ------------------------------------------------------------ */
/***	MTDS::GetDisplayDs()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns a handle to the display DS object.
**
**	Errors:
**		none
**
**	Description:
**		Get a handle to the DS object used to talk to the physical display.
**		There is one distinguished DS that is set up when the display shield
**		is initialized that uses the bitmap associated with the physical
**		display as its drawing surface.
*/

HDS MTDS::GetDisplayDs() {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetDisplayDs, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the HDS.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	GetDs()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns an HDS for the next available DS in the cache
**
**	Errors:
**		Returns -1 if no DS is available in the cache.
**
**	Description:
**		Get the next available DS from the DS cache.
*/

HDS MTDS::GetDs() {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetDs, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the HDS.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::ReleaseDs(hds)
**
**	Parameters:
**		hds		- handle of the DS to release
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		This releases the specified DS back to the DS cache, or in the case
**		of the display DS, marks it as not busy.
*/

bool MTDS::ReleaseDs(HDS hds) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiReleaseDs, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::CreateBitmap(dxco, dyco, cbpp)
**
**	Parameters:
**		dxco		- requested bitmap width
**		dyco		- requested bitmap height
**		cbpp		- requested bitmap pixel format
**
**	Return Values:
**		Returns a handle to the created bitmap
**
**	Errors:
**		Returns -1 if unable to create the requested bitmap
**
**	Description:
**		Create a bitmap in the user memory on the display shield.
*/

HBMP MTDS::CreateBitmap(int16_t dxco, int16_t dyco, int16_t cbpp) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM3B prm;

	/* Send the command packet.
	*/
	prm.valB1 = dxco;
	prm.valB2 = dyco;
	prm.valB3 = cbpp;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiCreateBitmap, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the HBMP.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::DestroyBitmap(hbmp)
**
**	Parameters:
**		hbmp		- handle to the bitmap to destroy
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Destroy the specified user created bitmap.
*/

bool MTDS::DestroyBitmap(HBMP hbmp) {
	PRM1A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hbmp;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiDestroyBitmap, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return the status.
	*/
	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::GetDisplayBitmap()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns a handle to the display bitmap object.
**
**	Errors:
**		none
**
**	Description:
**		Get a handle to the bitmap object for the physical display.
*/

HBMP MTDS::GetDisplayBitmap() {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];

	/* Send the command packet.
	*/
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetDisplayBitmap, 0, 0, 0, 0);

	/* Check for error and return failure if so.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the HBMP.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::GetBitmapDimensions(hbmp, pbmpd)
**
**	Parameters:
**		hbmp		- handle to the bitmap to destroy
**		pbmpd		- pointer to bitmap dimensions structure to fill in
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Return the dimensions of the specified bitmap.
*/

bool MTDS::GetBitmapDimensions(HBMP hbmp, BMPD * pbmpd) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hbmp;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetBitmapDim, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	pbmpd->dxco = pret->valB1;
	pbmpd->dyco = pret->valB2;
	pbmpd->cbpp = pret->valB3;

	/* Return the status.
	*/
	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::StoreBitmap(szName, hbmp)
**
**	Parameters:
**		szName		- file name to store bitmap to
**		hbmp		- handle to the bitmap to store
**
**	Return Values:
**		Returns true if successful, false if not.
**
**	Errors:
**		Returns success or failure.
**
**	Description:
**		Store the specified bitmap into a file on the SD card with
**		the specified name.
*/

bool MTDS::StoreBitmap(char * szName, HBMP hbmp) {
	PRM1A1B prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!FCheckName((char *)szName, clsCmdGdi, cmdGdiStoreBitmap)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valA1 = hbmp;
	prm.valB1 = strlen((char *)szName)+1;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiStoreBitmap, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szName);

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
/***	MTDS::LoadBitmap(szName, hbmp)
**
**	Parameters:
**		szName		- file name to load bitmap from
**
**	Return Values:
**		Returns handle to the bitmap
**
**	Errors:
**		Returns 0 if error.
**
**	Description:
**		Load the specified bitmap from the specified file on the SD card.
*/

HBMP MTDS::LoadBitmap(char * szName) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A1B prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!FCheckName((char *)szName, clsCmdGdi, cmdGdiLoadBitmap)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valB1 = strlen((char *)szName)+1;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiLoadBitmap, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szName);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the HBMP.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::CreateSolidBrush(clr)
**
**	Parameters:
**		clr		- the requested color for the brush
**
**	Return Values:
**		Returns a handle to the created brush
**
**	Errors:
**		Returns -1 if unable to create the requested brush
**
**	Description:
**		Create a brush with the requested color.
*/

HBR MTDS::CreateSolidBrush(uint32_t clr) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A prm;

	/* Send the command packet.
	*/
	prm.valA1 = clr;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiCreateSolidBrush, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the HBR.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::CreatePatternBrush(ids, clrFg, clrBg)
**
**	Parameters:
**		ids		- identifier for the requested stock pattern
**		clrFg	- forground brush color
**		clrBg	- background brush color
**
**	Return Values:
**		Returns a handle to the created brush
**
**	Errors:
**		Returns -1 if unable to create the requested brush.
**
**	Description:
**		Create a brush of the requested pattern and the requested color.
*/

HBR MTDS::CreatePatternBrush(int16_t ids, uint32_t clrFg, uint32_t clrBg) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM2A1B prm;

	/* Send the command packet.
	*/
	prm.valB1 = ids;
	prm.valA1 = clrFg;
	prm.valA2 = clrBg;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiCreatePatternBrush, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the HBR.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::CreateCustomBrush(hbmp)
**
**	Parameters:
**		hbmp		- handle to bitmap specifying custom pattern
**
**	Return Values:
**		Returns a handle to the created brush
**
**	Errors:
**		Returns -1 if unable to create the requested brush
**
**	Description:
**		Create a brush using the specified bitmap for the pattern. The
**		bitmap must be at least 8x8 pixels in size. The 8x8 pixels of
**		the bitmap will be used for the brush pattern.
*/

HBR MTDS::CreateCustomBrush(HBMP hbmp) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hbmp;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiCreateCustomBrush, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the HBR.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTDS::DestroyBrush(hbr)
**
**	Parameters:
**		hbr		- handle of the brush to delete
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if error
**
**	Description:
**		Destroy the specified brush
*/

bool MTDS::DestroyBrush(HBR hbr) {
	PRM1A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hbr;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiDestroyBrush, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return the status.
	*/
	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::GetNearestColor(clr)
**
**	Parameters:
**		clr		- color to set map to nearest realizable color
**
**	Return Values:
**		Returns nearest realizable color
**
**	Errors:
**		Returns 0xFFFFFFFF if error
**
**	Description:
**		Convert the specified color value to the nearest realizable color on
**		the display hardware.
*/

uint32_t MTDS::GetNearestColor(uint32_t clr) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A prm;

	/* Send the command packet.
	*/
	prm.valA1 = clr;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetNearestColor, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0xFFFFFFFF;
	}

	/* Return success.
	*/
	return pret->valA1;
};

/* ------------------------------------------------------------ */
/***	MTDS::SetFgColor(hds, clr)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		clr		- color to set as the foreground color
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the specified color as the foreground color in the DS object
*/

bool MTDS::SetFgColor(HDS hds, uint32_t clr) {
	PRM2A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valA2 = clr;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetFgColor, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	return true;
};

/* ------------------------------------------------------------ */
/***	MTDS::GetFgColor(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the current foreground color for the specified DS
**
**	Errors:
**		Returns 0 if an error occurs, which corresponds to the color black.
**
**	Description:
**		Return the current foreground color for the specified display state object.
*/

uint32_t MTDS::GetFgColor(HDS hds) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetFgColor, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the color.
	*/
	return pret->valA1;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetBgColor(hds, clr)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		clr		- color to set as the background color
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the specified color as the current background color for the specified
**		display state object.
*/

bool MTDS::SetBgColor(HDS hds, uint32_t clr) {
	PRM2A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valA2 = clr;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetBgColor, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetBgColor(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the current background color
**
**	Errors:
**		Returns 0 if error occurs, which happens to be the color black
**
**	Description:
**		Return the current background color from the specified display state
**		object.
*/

uint32_t MTDS::GetBgColor(HDS hds) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetBgColor, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the color.
	*/
	return pret->valA1;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetTransColor(hds, clr)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		clr		- color to set as the transparency color
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the specified color as the current transparency color for the specified
**		display state object.
*/

bool MTDS::SetTransColor(HDS hds, uint32_t clr) {
	PRM2A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valA2 = clr;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetTransColor, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetTransColor(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the current transparency color
**
**	Errors:
**		Returns 0 if error occurs, which happens to be the color black
**
**	Description:
**		Return the current transparency color from the specified display state
**		object.
*/

uint32_t MTDS::GetTransColor(HDS hds) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetTransColor, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the color.
	*/
	return pret->valA1;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetIntensity(hds, ity)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		ity		- DrawBitmap intensity to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the specified value as the intensity to use for DrawBitmap(). This
**		defaults to 100%. Values less than 100 will cause the bitmap to be drawn
**		with reduced intensity. Values greater than 100 will cause the bitmap
**		to be drawn with increased intensity, intensity basically being the
**		relative brightness of the pixels. This is mostly useful for drawing
**		bitmaps with reduced intensity to "gray" them out. Drawing with an
**		intensity greater than 100 will cause many bitmaps to saturate to white
**		very quickly.
*/

bool MTDS::SetIntensity(HDS hds, int ity) {
	PRM1A1B prm;

	/* Check for out of range parameter.
	*/
	if (ity < 0) {
		clsLastError = clsCmdGdi;
		cmdLastError = cmdGdiSetIntensity;
		staLastError = staGdiBadParameter;
		return false;
	}

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = (uint16_t)ity;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetIntensity, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetIntensity(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the current DrawBitmap intensity
**
**	Errors:
**		Returns 0 if error occurs, which happens to be the color black
**
**	Description:
**		Return the current intensity used for DrawBitmap().
*/

int MTDS::GetIntensity(HDS hds) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetIntensity, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return -1;
	}

	/* Return the intensity.
	*/
	return (int)(pret->valB1);
}

/* ------------------------------------------------------------ */
/***	MTDS::SetPen(hds, pen)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		pen		- pen bit pattern to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the specified pattern as the current pen pattern for the
**		specified display state object.
*/

bool MTDS::SetPen(HDS hds, uint16_t pen) {
	PRM1A1B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = pen;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetPen, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetPen(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the current pen pattern
**
**	Errors:
**		Returns 0 if error occurs
**
**	Description:
**		Return the current pen pattern from the specified display state
**		object.
*/

uint16_t MTDS::GetPen(HDS hds) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetPen, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the color.
	*/
	return pret->valB1;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetBkMode(hds, bkReq)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		bkReq	- background mode to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the specified specified display state object to use the specified
**		background drawing mode.
*/

bool MTDS::SetBkMode(HDS hds, int bkReq) {
	PRM1A1B prm;

	if ((bkReq != bkOpaque) && (bkReq != bkTransparent)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = (uint16_t)(bkReq & 0xFFFF);

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetBkMode, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetBkMode(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the current background drawing mode
**
**	Errors:
**		Returns -1 if error occurs
**
**	Description:
**		Return the current background drawing mode from the specified 
**		display state object.
*/

int MTDS::GetBkMode(HDS hds) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetBkMode, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the color.
	*/
	return pret->valB1;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetDrwRop(hds, drw)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		drw		- requested line and text drawing ROP
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the specified value as the current raster-op for drawing
**		lines and text in the specified display state object.
*/

bool MTDS::SetDrwRop(HDS hds, int drw) {
	PRM1A1B prm;

	/* Make sure that the requested ROP is valid before we send it to the shield.
	*/
	if ((drw < drwBlack) || (drw > drwWhite)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = (uint16_t)(drw & 0xFFFF);

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetDrwRop, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetDrwRop(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the current ROP
**
**	Errors:
**		Returns -1 if error occurs.
**
**	Description:
**		Return the currently select raster-op for line and text drawing
**		from the specified display state object.
*/

int MTDS::GetDrwRop(HDS hds) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetDrwRop, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return -1;
	}

	/* Return the color.
	*/
	return pret->valB1;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetBrush(hds, hbr)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		hbr		- handle to the brush to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the specified brush as the background pattern for the specified
**		display state object.
*/

bool MTDS::SetBrush(HDS hds, HBR hbr) {
	PRM2A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valA2 = hbr;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetBrush, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetBrush(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the handle of the current brush
**
**	Errors:
**		Returns -1 if error occurs.
**
**	Description:
**		Returns the handle of the brush object selected as the current background
**		pattern in the specified display state object.
*/

HBR MTDS::GetBrush(HDS hds) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetBrush, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the color.
	*/
	return pret->valA1;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetFont(hds, hfnt)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		hfnt	- handle to the font to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the specified font for drawing text for the specified
**		display state object.
*/

bool MTDS::SetFont(HDS hds, HFNT hfnt) {
	PRM2A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valA2 = hfnt;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetFont, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetFont(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the handle of the current font
**
**	Errors:
**		Returns -1 if error occurs.
**
**	Description:
**		Returns the handle of the font object selected as the current font
**		in the specified display state object.
*/

HFNT MTDS::GetFont(HDS hds) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetFont, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the color.
	*/
	return pret->valA1;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetDrawingSurface(hds, hbmp)
**
**	Parameters:
**		hds		- handle to the drawing state object
**		hbmp	- handle to the bitmap to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the specified bitmap as the current drawing surface in the
**		specified display state object.
*/

bool MTDS::SetDrawingSurface(HDS hds, HBMP hbmp) {
	PRM2A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valA2 = hbmp;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetDrawingSurface, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetDrawingSurface(hds)
**
**	Parameters:
**		hds		- handle to the drawing state object
**
**	Return Values:
**		Returns the handle of the current bitmap
**
**	Errors:
**		Returns -1 if error occurs.
**
**	Description:
**		Returns the handle of the bitmap object selected as the current drawing
**		surface in the specified display state object.
*/

HBMP MTDS::GetDrawingSurface(HDS hds) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetDrawingSurface, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the color.
	*/
	return pret->valA1;
}

/* ------------------------------------------------------------ */
/***	MTDS::SetPixel(hds, xco, yco, clr)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		xco, yco	- corrdinate of pixel to set
**		clr			- color to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the pixel at the specified position to the specified value.
*/

bool MTDS::SetPixel(HDS hds, int16_t xco, int16_t yco, uint32_t clr) {
	PRM2A2B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valA2 = clr;
	prm.valB1 = xco;
	prm.valB2 = yco;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiSetPixel, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetPixel(hds, xco, yco)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		xco, yco	- corrdinate of pixel to set
**
**	Return Values:
**		Returns the color of the specified pixel
**
**	Errors:
**		Returns 0 if error.
**
**	Description:
**		Get the color of the pixel at the specified position.
*/

uint32_t MTDS::GetPixel(HDS hds, int16_t xco, int16_t yco) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A2B	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xco;
	prm.valB2 = yco;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetPixel, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the color.
	*/
	return pret->valA1;
}

/* ------------------------------------------------------------ */
/***	MTDS::GetCurPos(hds, ppnt)
**
**	Parameters:
**		hds		- handle to the display state object
**		ppnt	- pointer to PNT structure to receive the current position
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Return the current x,y position from the DS.
*/

bool MTDS::GetCurPos(HDS hds, PNT * ppnt) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetCurPos, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return the color.
	*/
	ppnt->xco = pret->valB1;
	ppnt->yco = pret->valB2;
	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::MoveTo(hds, xco, yco)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		xco, yco	- corrdinate to move to
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Move the current position in the specified display state object to
**		the specifiec x,y position.
*/

bool MTDS::MoveTo(HDS hds, int16_t xco, int16_t yco) {
	PRM1A2B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xco;
	prm.valB2 = yco;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiMoveTo, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::Line(hds, xco, yco)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		xco, yco	- corrdinate to draw to
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw a line from the current position to the specified position, using
**		the current pen, foreground color, background color and background drawing
**		mode, leaving the current position unchanged.
*/

bool MTDS::Line(HDS hds, int16_t xco, int16_t yco) {
	PRM1A2B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xco;
	prm.valB2 = yco;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiLine, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::LineTo(hds, xco, yco)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		xco, yco	- corrdinate to draw to
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw a line from the current position to the specified position, using
**		the current pen, foreground color, background color and background drawing
**		mode, updating the current position to be the endpoint of the line.
*/

bool MTDS::LineTo(HDS hds, int16_t xco, int16_t yco) {
	PRM1A2B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xco;
	prm.valB2 = yco;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiLineTo, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::PolyLine(hds, cpnt, rgpnt)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		cpnt		- number of point structures in rgpnt
**		rgpnt		- array of point structures give the vertices of the polyline
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw a series of lines from the current position to the specified position,
**		using the current pen, foreground color, background color and background drawing
**		mode, leaving the current position unchanged.
*/

bool MTDS::PolyLine(HDS hds, int cpnt, PNT * rgpnt) {
	PRM1A1B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = cpnt;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiPolyLine, sizeof(prm), (uint8_t *)&prm,
						cpnt*sizeof(PNT), (uint8_t *)rgpnt);

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
/***	MTDS::PolyLineTo(hds, cpnt, rgpnt)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		cpnt		- number of point structures in rgpnt
**		rgpnt		- array of point structures give the vertices of the polyline
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw a series of lines from the current position to the specified position,
**		using the current pen, foreground color, background color and background drawing
**		mode, updating the current position to be the endpoint of the last line segment
**		specified by rgpnt.
*/

bool MTDS::PolyLineTo(HDS hds, int cpnt, PNT * rgpnt) {
	PRM1A1B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = cpnt;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiPolyLineTo, sizeof(prm), (uint8_t *)&prm,
						cpnt*sizeof(PNT), (uint8_t *)rgpnt);

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
/***	MTDS::Arc(hds, xcoLeft, ycoTop, xcoRight, ycoBottom, xcoRad1, ycoRad1, xcoRad2, ycoRad2)
**
**	Parameters:
**		hds			- handle to the DS object
**		xcoLeft		- left side of bounding rectangle
**		ycoTop		- top side of bounding rectangle
**		xcoRight	- right side of bounding rectangle
**		ycoBottom	- bottom side of bounding rectangle
**		xcoRad1		- x coordinate of endpoint of first radial line
**		ycoRad1		- y coordinate of endpoint of first radial line
**		xcoRad2		- x coordinate of endpoint of second radial line
**		ycoRad2		- y coordinate of endpoint of second radial line
**
**	Return Value:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Draws an arc section of an ellipse. The arc drawn from the intersection
**		of the ellipse with the radial line defined by xcoRad1, ycoRad1, counterclockwise
**		to the point of intersection of the	elipse with the radial line defined by
**		xcoRad2, ycoRad2.
**		The current position is not modified.
*/

bool MTDS::Arc(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
			int16_t xcoRad1, int16_t ycoRad1, int16_t xcoRad2, int16_t ycoRad2) {

	PRM1A8B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xcoLeft;
	prm.valB2 = ycoTop;
	prm.valB3 = xcoRight;
	prm.valB4 = ycoBottom;
	prm.valB5 = xcoRad1;
	prm.valB6 = ycoRad1;
	prm.valB7 = xcoRad2;
	prm.valB8 = ycoRad2;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiArc, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::ArcTo(hds, xcoLeft, ycoTop, xcoRight, ycoBottom, xcoRad1, ycoRad1, xcoRad2, ycoRad2)
**
**	Parameters:
**		hds			- handle to the DS object
**		xcoLeft		- left side of bounding rectangle
**		ycoTop		- top side of bounding rectangle
**		xcoRight	- right side of bounding rectangle
**		ycoBottom	- bottom side of bounding rectangle
**		xcoRad1		- x coordinate of endpoint of first radial line
**		ycoRad1		- y coordinate of endpoint of first radial line
**		xcoRad2		- x coordinate of endpoint of second radial line
**		ycoRad2		- y coordinate of endpoint of second radial line
**
**	Return Value:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draws an arc section of an ellipse. The arc is drawn from the intersection
**		of the ellipse with the radial line defined by xcoRad1, ycoRad1, counterclockwise
**		to the point of intersection of the	elipse with the radial line defined by
**		xcoRad2, ycoRad2.
**		The current position is set to the last point drawn on the arc.
*/

bool MTDS::ArcTo(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
			int16_t xcoRad1, int16_t ycoRad1, int16_t xcoRad2, int16_t ycoRad2) {

	PRM1A8B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xcoLeft;
	prm.valB2 = ycoTop;
	prm.valB3 = xcoRight;
	prm.valB4 = ycoBottom;
	prm.valB5 = xcoRad1;
	prm.valB6 = ycoRad1;
	prm.valB7 = xcoRad2;
	prm.valB8 = ycoRad2;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiArcTo, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::Ellipse(hds, xcoLeft, ycoTop, xcoRight, ycoBottom)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		xcoLeft		- left side of bounding rectangle
**		ycoTop		- top side of bounding rectangle
**		xcoRight	- right side of bounding rectangle
**		ycoBottom	- bottom side of bounding rectangle
**
**	Return Value:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draws an ellipse tangent to the sides of the specified bounding rectangle.
**		The perimeter of the ellipse is drawn using the current pen, foreground
**		color, background color, and background drawing mode. The interior of the
**		ellipse if filled using the current brush and raster-op.
*/

bool MTDS::Ellipse(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom) {

	PRM1A4B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xcoLeft;
	prm.valB2 = ycoTop;
	prm.valB3 = xcoRight;
	prm.valB4 = ycoBottom;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiEllipse, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::Chord(hds, xcoLeft, ycoTop, xcoRight, ycoBottom, xcoRad1, ycoRad1, xcoRad2, ycoRad2)
**
**	Parameters:
**		hds			- handle to the DS object
**		xcoLeft		- left side of bounding rectangle
**		ycoTop		- top side of bounding rectangle
**		xcoRight	- right side of bounding rectangle
**		ycoBottom	- bottom side of bounding rectangle
**		xcoRad1		- x coordinate of endpoint of first radial line
**		ycoRad1		- y coordinate of endpoint of first radial line
**		xcoRad2		- x coordinate of endpoint of second radial line
**		ycoRad2		- y coordinate of endpoint of second radial line
**
**	Return Value:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draws a cord of an ellipse. The arc of the chord is drawn from the 
**		intersection of the ellipse with the radial line defined by xcoRad1,ycoRad.
**		It is drawn from there counterclockwise to the point of intersection of the
**		elipse with the radial line defined by xcoRad2, ycoRad2.
*/

bool MTDS::Chord(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
			int16_t xcoRad1, int16_t ycoRad1, int16_t xcoRad2, int16_t ycoRad2) {

	PRM1A8B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xcoLeft;
	prm.valB2 = ycoTop;
	prm.valB3 = xcoRight;
	prm.valB4 = ycoBottom;
	prm.valB5 = xcoRad1;
	prm.valB6 = ycoRad1;
	prm.valB7 = xcoRad2;
	prm.valB8 = ycoRad2;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiChord, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::Pie(hds, xcoLeft, ycoTop, xcoRight, ycoBottom, xcoRad1, ycoRad1, xcoRad2, ycoRad2)
**
**	Parameters:
**		hds			- handle to the DS object
**		xcoLeft		- left side of bounding rectangle
**		ycoTop		- top side of bounding rectangle
**		xcoRight	- right side of bounding rectangle
**		ycoBottom	- bottom side of bounding rectangle
**		xcoRad1		- x coordinate of endpoint of first radial line
**		ycoRad1		- y coordinate of endpoint of first radial line
**		xcoRad2		- x coordinate of endpoint of second radial line
**		ycoRad2		- y coordinate of endpoint of second radial line
**
**	Return Value:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draws a pie section of an ellipse. The arc of the pie is drawn from the 
**		intersection of the ellipse with the radial line defined by xcoRad1,ycoRad.
**		It is drawn from there counterclockwise to the point of intersection of the
**		elipse with the radial line defined by xcoRad2, ycoRad2.
*/

bool MTDS::Pie(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
			int16_t xcoRad1, int16_t ycoRad1, int16_t xcoRad2, int16_t ycoRad2) {

	PRM1A8B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xcoLeft;
	prm.valB2 = ycoTop;
	prm.valB3 = xcoRight;
	prm.valB4 = ycoBottom;
	prm.valB5 = xcoRad1;
	prm.valB6 = ycoRad1;
	prm.valB7 = xcoRad2;
	prm.valB8 = ycoRad2;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiPie, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::Rectangle(hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom)
**
**	Parameters:
**		hds			- handle to the DS object
**		xcoLeft		- left side of bounding rectangle
**		ycoTop		- top side of bounding rectangle
**		xcoRight	- right side of bounding rectangle
**		ycoBottom	- bottom side of bounding rectangle
**
**	Return Value:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw a filled rectangle. The perimeter is drawn using the current pen,
**		foreground color, background color, background drawing mode, and the
**		current line drawing raster op. The interior is filled using the current
**		brush.
*/

bool MTDS::Rectangle(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom) {
	PRM1A4B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xcoLeft;
	prm.valB2 = ycoTop;
	prm.valB3 = xcoRight;
	prm.valB4 = ycoBottom;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiRectangle, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::RoundRect(hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom)
**
**	Parameters:
**		hds			- handle to the DS object
**		xcoLeft		- left side of bounding rectangle
**		ycoTop		- top side of bounding rectangle
**		xcoRight	- right side of bounding rectangle
**		ycoBottom	- bottom side of bounding rectangle
**		dxcoWidth	- width of the ellipse used to draw the rounded corners
**		dycoHeight	- height of the ellipse used to draw the rounded corners
**
**	Return Value:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw a filled rectangle with rounded corners.
*/

bool MTDS::RoundRect(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
				int16_t dxcoWidth, int16_t dycoHeight) {

	PRM1A8B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xcoLeft;
	prm.valB2 = ycoTop;
	prm.valB3 = xcoRight;
	prm.valB4 = ycoBottom;
	prm.valB5 = dxcoWidth;
	prm.valB6 = dycoHeight;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiRoundRect, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::BitBlt(hdsDst, xcoDst, ycoDst, dxco, dyco, hdsSrc, xcoSrc, ycoSrc, rop)
**
**	Parameters:
**		hdsDst			- handle to the destination drawing state object
**		xcoDst, ycoDst	- upper left corner of destination rectangle
**		dxco, dyco		- width and height of the rectangle
**		hdsSrc			- handle to the source drawing state object
**		xcoSrc,ycoSrc	- upper left corner of source rectangle
**		rop				- raster-op to use for the operation
**
**	Return Values:
**		none
**
**	Errors:
**		returns true if successful, false if not
**
**	Description:
**		Combine the rectangle of pixels from the drawing surface bitmap associated
**		with hdsSrc with the pixels contained in the bitmap associated with hdsSrc
**		using the raster-op specified by rop to combine the pixel values.
**		The source rectangle will be clipped to the dimensions of the source bitmap,
**		the destination rectangle will be clipped to the dimensions of the destination
**		bitmap. Only the pixels that intersect these clipped rectangles are modified.
**		The hdsSrc and hdsDst can specify the same or differnet display state objects.
*/

bool MTDS::BitBlt(HDS hdsDst, int16_t xcoDst, int16_t ycoDst, int16_t dxco, int16_t dyco,
				HDS hdsSrc, int16_t xcoSrc, int16_t ycoSrc, uint16_t rop) {
	PRM1A4B1A3B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hdsDst;
	prm.valB1 = xcoDst;
	prm.valB2 = ycoDst;
	prm.valB3 = dxco;
	prm.valB4 = dyco;
	prm.valA2 = hdsSrc;
	prm.valB5 = xcoSrc;
	prm.valB6 = ycoSrc;
	prm.valB7 = rop;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiBitBlt, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::PatBlt(hds, xco, yco, dxco, dyco, rop)
**
**	Parameters:
**		hds			- handle to destination DS object
**		xco, yco	- upper left corner of rectangle
**		dxco, dyco	- width and height of rectangle
**		rop			- the ROP to use
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		This function will do a Blt of the specified rectangle and
**		the current brush
*/

bool MTDS::PatBlt(HDS hds, int16_t xco, int16_t yco, int16_t dxco, int16_t dyco, uint16_t rop) {
	PRM1A5B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = xco;
	prm.valB2 = yco;
	prm.valB3 = dxco;
	prm.valB4 = dyco;
	prm.valB5 = rop;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiPatBlt, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::DrawBitmap(hdsDst, xcoDst, ycoDst, dxco, dyco, hdsSrc, xcoSrc, ycoSrc)
**
**	Parameters:
**		hdsDst		- Handle to the DS containing the destination bitmap
**		xcoDst		- x position of left side of destination region
**		ycoDst		- y position of top side of the destination region
**		dxco		- width of the destination region
**		dyco		- height of the region
**		hdsDrc		- Handle to the DS containing source bitmap
**		xcoSrc		- x position of left side of source region
**		ycoSrc		- y position of top side of source region
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Copy pixels from the specified rectangle on the source bitmap to the
**		specified rectangle on the destination bitmap. This is different than
**		BitBlt in that it doesn't use a raster-op to combine source and
**		destination pixels. This function also pays attention to the current
**		background drawing mode and if bkTransparent is in effect, it does not
**		copy pixels from the source bitmap whose color matches the current
**		transparency color.
*/

bool MTDS::DrawBitmap(HDS hdsDst, int16_t xcoDst, int16_t ycoDst, int16_t dxco, int16_t dyco, HDS hdsSrc, int16_t xcoSrc, int16_t ycoSrc) {
	PRM1A4B1A2B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hdsDst;
	prm.valB1 = xcoDst;
	prm.valB2 = ycoDst;
	prm.valB3 = dxco;
	prm.valB4 = dyco;
	prm.valA2 = hdsSrc;
	prm.valB5 = xcoSrc;
	prm.valB6 = ycoSrc;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiDrawBitmap, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::GetTextExtent(hds, cchText, rgchText, ppnt)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		cchText		- count of characters in the array of characters
**		rgchText	- array of characters
**		ppnt		- pointer to PNT structure to receive the result
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		This function uses the specified array of characters and the currently
**		selected font in the display state object to determine the width and
**		height of the rectangle needed to hold the text when it has been
**		rendered.
*/

bool MTDS::GetTextExtent(HDS hds, int cchText, char * rgchText, PNT * ppnt) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A1B prm;

	/* Send the command packet.
	*/
	//M00TODO - error check string length
	prm.valA1 = hds;
	prm.valB1 = cchText;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiGetTextExtent, sizeof(prm), (uint8_t *)&prm,
						cchText, (uint8_t *)rgchText);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return success.
	*/
	ppnt->xco = pret->valB1;
	ppnt->yco = pret->valB2;
	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::TextOut(hds, szText)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		szText		- null terminated string of characters
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Render the specified text string using the currently selected font.
**		It will start at the current position in the DS. The current position
**		will be update to immediately following where the last character is
**		drawn. Embedded carriage contro (CR and LF) characters will be interpreted
**		to move the current position rather than being rendered. This allows
**		multi-line strings to be drawn.
*/

bool MTDS::TextOut(HDS hds, char * szText) {

	return TextOut(hds, strlen(szText), szText);

}

/* ------------------------------------------------------------ */
/***	MTDS::TextOut(hds, cchText, rgchText)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		cchText		- number of characters in the text array
**		rgchext		- array of characters
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Render the specified character array using the currently selected font.
**		It will start at the current position in the DS. The current position
**		will be update to immediately following where the last character is
**		drawn. Embedded carriage contro (CR and LF) characters will be interpreted
**		to move the current position rather than being rendered. This allows
**		multi-line strings to be drawn.
*/

bool MTDS::TextOut(HDS hds, int cchText, char * rgchText) {
	PRM1A1B prm;

	/* Send the command packet.
	*/
	//M00TODO - error check string length
	prm.valA1 = hds;
	prm.valB1 = cchText;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiTextOutCch, sizeof(prm), (uint8_t *)&prm,
						cchText, (uint8_t *)rgchText);

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
/***	MTDS::TextOut(hds, xco, yco, cchText, rgchText)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		xco,yco		- x,y position at which to start rendering
**		cchText		- number of characters in the text array
**		rgchext		- array of characters
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Render the specified character array using the currently selected font
**		starting at the specified position. The current position in the DS is
**		not modified. This function does not interpret embedded carriage control
**		characters. If they are defined by the font, they will be rendered.
*/

bool MTDS::TextOut(HDS hds, int16_t xco, int16_t yco, int cchText, char * rgchText) {
	PRM1A3B prm;

	/* Send the command packet.
	*/
	//M00TODO - error check string length
	prm.valA1 = hds;
	prm.valB1 = xco;
	prm.valB2 = yco;
	prm.valB3 = cchText;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiTextOutXcoYco, sizeof(prm), (uint8_t *)&prm,
						cchText, (uint8_t *)rgchText);

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
/*			Operations on Rectangles							*/
/* ------------------------------------------------------------ */
/***	MTDS::IsRectEmpty(prct)
**
**	Parameters:
**		prct		- pointer to the rectangle
**
**	Return Values:
**		returns true if the rectangle is empty, else false
**
**	Errors:
**		none
**
**	Description:
**		Return if all members of the rectangle are zero.
*/

bool MTDS::IsRectEmpty(RCT * prct) {

	if ((prct->xcoLeft >= prct->xcoRight) || (prct->ycoTop >= prct->ycoBottom)) {
		return true;
	}
	else {
		return false;
	}
}

/* ------------------------------------------------------------ */
/***	MTDS::IsRectEqual(prct1, prct2)
**
**	Parameters:
**		prct1		- pointer to first rectangle
**		prct2		- pointer to second rectangle
**
**	Return Values:
**		returns true if the rectangles are equal, else false
**
**	Errors:
**		none
**
**	Description:
**		Return true if the first rectangle is equal to the second rectangle.
*/

bool MTDS::IsRectEqual(RCT * prct1, RCT * prct2) {

	if ((prct1->xcoLeft  == prct2->xcoLeft)  && (prct1->ycoTop    == prct2->ycoTop) &&
		(prct1->xcoRight == prct2->xcoRight) && (prct1->ycoBottom == prct2->ycoBottom)) {
		return true;
	}
	else {
		return false;
	}
}

/* ------------------------------------------------------------ */
/***	MTDS::PointInRect(prct, xco, yco)
**
**	Parameters:
**		prct		- pointer to the rectangle
**		xco, yco	- the point to check
**
**	Return Values:
**		returns true if the specified point is within the rectangle
**
**	Errors:
**		none
**
**	Description:
**		Checks if the point is within the bounds of the rectangle. The
**		point being on the bounds is considered to be within the bounds
*/

bool MTDS::PointInRect(RCT * prct, int16_t xco, int16_t yco) {

	if ((xco < prct->xcoLeft) || (xco > prct->xcoRight)) {
		return false;
	}
	if ((yco < prct->ycoTop) || (yco > prct->ycoBottom)) {
		return false;
	}

	return true;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetRectEmpty(prct)
**
**	Parameters:
**		prct	- pointer to the rect
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Set all members of the rectangle to 0.
*/

void MTDS::SetRectEmpty(RCT * prct) {

	prct->xcoLeft = 0;
	prct->xcoRight = 0;
	prct->ycoTop = 0;
	prct->ycoBottom = 0;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetRect(prct, xcoL, ycoT, xcoR, ycoB)
**
**	Parameters:
**		prct	- pointer to the rectangle to set
**		xcoL	- left x
**		ycoT	- top y
**		xcoR	- right x
**		ycoB	- bottom y
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Initialize the specified RCT with the given values.
*/

void MTDS::SetRect(RCT * prct, int16_t xcoL, int16_t ycoT, int16_t xcoR, int16_t ycoB) {

	prct->xcoLeft = xcoL;
	prct->xcoRight = xcoR;
	prct->ycoTop = ycoT;
	prct->ycoBottom = ycoB;

}

/* ------------------------------------------------------------ */
/***	MTDS::SetRect(prctDst, prctSrc)
**
**	Parameters:
**		prctDst	- pointer to the rectangle to set
**		prctSrc	- pointer to rectangle for values to set
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Initialize rctDst to have the same values as rctSrc.
*/

void MTDS::SetRect(RCT * prctDst, RCT * prctSrc) {

	prctDst->xcoLeft   = prctSrc->xcoLeft;
	prctDst->xcoRight  = prctSrc->xcoRight;
	prctDst->ycoTop    = prctSrc->ycoTop;
	prctDst->ycoBottom = prctSrc->ycoBottom;

}

/* ------------------------------------------------------------ */
/***	MTDS::MoveRect(prct, dxco, dyco)
**
**	Parameters:
**		prct	- pointer to the rect
**		dxco	- amount to move in x
**		dyco	- amount to move in y
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Move the specified rectangle by the specified displacement
*/

void MTDS::MoveRect(RCT * prct, int16_t dxco, int16_t dyco) {

	prct->xcoLeft += dxco;
	prct->ycoTop += dyco;
	prct->xcoRight += dxco;
	prct->ycoBottom += dyco;

}

/* ------------------------------------------------------------ */
/***	MTDS::GrowRect(prct, dxco, dyco)
**
**	Parameters:
**		prct	- pointer to the rect
**		dxco	- amount to grow in x
**		dyco	- amount to grow in y
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Grow the rectangle by the specified amount, by adding the
**		displacement to its right and bottom.
*/

void MTDS::GrowRect(RCT * prct, int16_t dxco, int16_t dyco) {

	prct->xcoRight += dxco;
	prct->ycoBottom += dyco;

}

/* ------------------------------------------------------------ */
/***	MTDS::IntersectRect(prct, prctOne, prctTwo
**
**	Parameters:
**		prct		- pointer to RCt to receive intersection
**		prctOne		- first input rectangle
**		prctTwo		- second input rectangle
**
**	Return Values:
**		Returns true if the intersection is non-empty.
**
**	Errors:
**		none
**
**	Description:
**		Compute the intersection of the two specified rectangles.
*/

bool MTDS::IntersectRect(RCT * prct, RCT * prctOne, RCT * prctTwo) {

	/* xcoLeft = max(oneLeft, twoLeft)
	** xcoRight = min(oneRight, twoRight)
	*/
	prct->xcoLeft = (prctOne->xcoLeft > prctTwo->xcoLeft) ? prctOne->xcoLeft : prctTwo->xcoLeft;
	prct->xcoRight = (prctOne->xcoRight < prctTwo->xcoRight) ? prctOne->xcoRight : prctTwo->xcoRight;

	/* ycoTop = max(oneTop, twoTop)
	** ycoBottom = min(oneBottom, twoBottom)
	*/
	prct->ycoTop = (prctOne->ycoTop > prctTwo->ycoTop) ? prctOne->ycoTop : prctTwo->ycoTop;
	prct->ycoBottom = (prctOne->ycoBottom < prctTwo->ycoBottom) ? prctOne->ycoBottom : prctTwo->ycoBottom;

	/* If the rectangle is now inverted, it means that the intersection is empty.
	*/
	if (IsRectEmpty(prct)) {
		return false;
	}
	else {
		return true;
	}
}

/* ------------------------------------------------------------ */
/***	MTDS::UnionRect(prct, prctOne, prctTwo
**
**	Parameters:
**		prct		- pointer to RCt to receive union
**		prctOne		- first input rectangle
**		prctTwo		- second input rectangle
**
**	Return Values:
**		Returns true if the union is non-empty.
**
**	Errors:
**		none
**
**	Description:
**		Compute the union of the two specified rectangles.
*/

bool MTDS::UnionRect(RCT * prct, RCT * prctOne, RCT * prctTwo) {

	/* xcoLeft = min(one, two)
	** xcoRight = max(one, two)
	*/
	prct->xcoLeft = (prctOne->xcoLeft < prctTwo->xcoLeft) ? prctOne->xcoLeft : prctTwo->xcoLeft;
	prct->xcoRight = (prctOne->xcoRight > prctTwo->xcoRight) ? prctOne->xcoRight : prctTwo->xcoRight;

	/* ycoTop = min(one, two)
	** ycoBottom = max(one, two)
	*/
	prct->ycoTop = (prctOne->ycoTop < prctTwo->ycoTop) ? prctOne->ycoTop : prctTwo->ycoTop;
	prct->ycoBottom = (prctOne->ycoBottom > prctTwo->ycoBottom) ? prctOne->ycoBottom : prctTwo->ycoBottom;

	if (IsRectEmpty(prct)) {
		return false;
	}
	else {
		return true;
	}
}

/* ------------------------------------------------------------ */
/***	MTDS::FrameRect(hds, prct)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		prct		- pointer to RCT structure giving the rectangle
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw a border around the specified rectangle using the current pen pattern,
**		foreground color, background color and background drawing mode.
*/

bool MTDS::FrameRect(HDS hds, RCT * prct) {
	PRM1A4B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = prct->xcoLeft;
	prm.valB2 = prct->ycoTop;
	prm.valB3 = prct->xcoRight;
	prm.valB4 = prct->ycoBottom;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiFrameRect, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::FillRect(hds, prct, hbr)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		prct		- pointer to RCT structure giving the rectangle
**		hbr			- brush to use for the fill
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Fill the interior of the specified rectangle.
*/

bool MTDS::FillRect(HDS hds, RCT * prct, HBR hbr) {
	PRM1A4B1A prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = prct->xcoLeft;
	prm.valB2 = prct->ycoTop;
	prm.valB3 = prct->xcoRight;
	prm.valB4 = prct->ycoBottom;
	prm.valA2 = hbr;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiFillRect, sizeof(prm), (uint8_t *)&prm, 0, 0);

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
/***	MTDS::InvertRect(hds, prct)
**
**	Parameters:
**		hds			- handle to the drawing state object
**		prct		- pointer to RCT structure giving the rectangle
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Invert the pixels in the specified rectangle.
*/

bool MTDS::InvertRect(HDS hds, RCT * prct) {
	PRM1A4B prm;

	/* Send the command packet.
	*/
	prm.valA1 = hds;
	prm.valB1 = prct->xcoLeft;
	prm.valB2 = prct->ycoTop;
	prm.valB3 = prct->xcoRight;
	prm.valB4 = prct->ycoBottom;

	MtdsProcessCmdWr(clsCmdGdi, cmdGdiInvertRect, sizeof(prm), (uint8_t *)&prm, 0, 0);

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

