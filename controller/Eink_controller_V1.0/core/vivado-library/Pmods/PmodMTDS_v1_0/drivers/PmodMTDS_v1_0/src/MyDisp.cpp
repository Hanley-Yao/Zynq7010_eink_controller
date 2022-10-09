/********************************************************************************/
/*																				*/
/*	MyDisp.cpp	--	Simple User Library for Multi-Touch Display Shield			*/
/*																				*/
/********************************************************************************/
/*	Author: 	Gene Apperson													*/
/*	Copyright 2016, Digilent, Inc. All rights reserved.							*/
/********************************************************************************/
/*  Module Description: 														*/
/*																				*/
/*	Implementation for the simple user library for the Digilent Multi-Touch		*/
/*	Display Shield. This library provides a simplified access model for use of	*/
/*	the display shield firmware via the standard MTDS library. It uses the MTDS	*/
/*	library for all access to the display shield functions. It puts a simple	*/
/*	wrapper on top of some of the functions of the MTDS library.				*/
/*																				*/
/********************************************************************************/
/*  Revision History:															*/
/*																				*/
/*	2016-03-25(GeneA): created.													*/
/*  12/20/2017(atangzwj): Replaced delay functions with sleep                   */
/*																				*/
/********************************************************************************/


/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#if defined(__SIM__)
#include	<stdlib.h>
#include	<string.h>
#else
#endif

#include	<stdint.h>
#include	<string.h>

#include	"MyDisp.h"
#include "sleep.h"

/* ------------------------------------------------------------ */
/*				Local Type Definitions							*/
/* ------------------------------------------------------------ */

//#define __MTDSTRACE__

/* ------------------------------------------------------------ */
/*				Global Variables								*/
/* ------------------------------------------------------------ */

MYDISP	mydisp;

extern MTDS mtds;

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
/*				MyDisp Object Class Implementation				*/
/* ------------------------------------------------------------ */
/***	MYDISP::MYDISP()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Default constructor. Initializes the object.
*/

MYDISP::MYDISP() {

	fInitialized = false;
	idBtnTrack = -1;
	hdsDisp = 0;
	hdsBlt = 0;
	hbrFg = 0;
	ityCur = 100;

}

/* ------------------------------------------------------------ */
/***	MYDISP::~MYDISP()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Default destructor. Cleans up the object.
*/

MYDISP::~MYDISP() {

}

/* ------------------------------------------------------------ */
/***	MYDISP::begin()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns true if successful, false if not.
**
**	Errors:
**		Returns false if error initializing.
**
**	Description:
**		Initialize the library for use. This initializes internal state of the
**		interface object and initializes the underlying MTDS library for
**		access to the display device.
*/

bool MYDISP::begin() {
	HBMP	hbmp;
	int		cntInit;
	int		ibtn;
	int		ifng;

	/* If we have already been initialized successfully, just return true;
	*/
	if (fInitialized) {
		return fInitialized;
	}

	/* Attempt to initialize the MTDS library.
	*/
	cntInit = 10;
	while (true) {
		if (mtds.begin()) {
			break;
		}

		if (--cntInit <= 0) {
			return false;
		}

#if !defined(__SIM__)
		sleep(1);
#endif
	}

	/* Get the DS objects that we will use and set up the default values.
	*/
	if ((hdsDisp = mtds.GetDs()) == 0) {
		return false;
	}
	hbmp = mtds.GetDisplayBitmap();
	mtds.SetDrawingSurface(hdsDisp, hbmp);

	if ((hdsBlt = mtds.GetDs()) == 0) {
		mtds.ReleaseDs(hdsDisp);
		return false;
	}

	idBtnTrack = -1;
	clrFg = clrWhite;
	clrBg = clrBlack;
	clrTr = clrBlack;
	bkCur = bkOpaque;
	penCur = penSolid;
	ityCur = 100;

	mtds.SetFgColor(hdsDisp, clrFg);
	mtds.SetBgColor(hdsDisp, clrBg);
	mtds.SetTransColor(hdsDisp, clrTr);
	hbrFg = mtds.CreateSolidBrush(clrFg);
	mtds.SetPen(hdsDisp, penCur);
	mtds.SetDrwRop(hdsDisp, drwCopyPen);
	mtds.SetBkMode(hdsDisp, bkCur);
	mtds.SetFont(hdsDisp, hfntConsole);
	mtds.SetIntensity(hdsDisp, ityCur);

	/* Initialize the button array.
	*/
	for (ibtn = 0; ibtn < NUM_BUTTONS; ibtn++) {
		rgbtn[ibtn].fs = 0;
		rgbtn[ibtn].hbmpUp = 0;
		rgbtn[ibtn].hbmpDn = 0;
		rgbtn[ibtn].hbmpBg = 0;
	}

	/* Initialize the finger activity array.
	*/
	for (ifng = 0; ifng < 2; ifng++) {
		rgfng[ifng].st = FINGER_UP;
		rgfng[ifng].x = -1;
		rgfng[ifng].y = -1;
	}

	fInitialized = true;
	return fInitialized;

}

/* ------------------------------------------------------------ */
/***	MYDISP::end()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Releases all resources used by the library and terminates access to
**		the display device.
*/

void MYDISP::end() {
	int		ibtn;

	if (hbrFg != 0) {
		mtds.DestroyBrush(hbrFg);
		hbrFg = 0;
	}

	for (ibtn = 0; ibtn < NUM_BUTTONS; ibtn++) {
		deleteButton(ibtn);
	}

	mtds.ReleaseDs(hdsDisp);
	mtds.ReleaseDs(hdsBlt);

	mtds.end();
	fInitialized = false;

}

/* ------------------------------------------------------------ */
/***	MYDISP::setPen(pen)
**
**	Parameters:
**		pen		- pen pattern set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the specified pattern as the current pen.
*/

bool MYDISP::setPen(uint16_t pen) {

	/* Set the specified color as the current foreground color.
	*/
	penCur = pen;
	return mtds.SetPen(hdsDisp, penCur);

}

/* ------------------------------------------------------------ */
/***	MYDISP::setForeground(clr)
**
**	Parameters:
**		clr		- foreground color to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the specified color as the current foreground color. This is also used
**		to fill shapes such as rectangles, so also create a solid brush of the
**		specified color and set it as the current brush.
*/

bool MYDISP::setForeground(uint32_t clr) {
	HBR		hbrT;

	/* Destroy the current foreground color brush before we create the new one.
	*/
	if ((hbrT = mtds.CreateSolidBrush(clr)) == 0) {
		return false;
	}
	mtds.DestroyBrush(hbrFg);
	hbrFg = hbrT;

	/* Set the specified color as the current foreground color.
	*/
	clrFg = clr;
	return mtds.SetFgColor(hdsDisp, clrFg);

}

/* ------------------------------------------------------------ */
/***	MYDISP::setBackground(clr)
**
**	Parameters:
**		clr		- background color to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the specified color as the current background color.
*/

bool MYDISP::setBackground(uint32_t clr) {

	/* Set the specified color as the current background color.
	*/
	clrBg = clr;
	return mtds.SetBgColor(hdsDisp, clrBg);

}

/* ------------------------------------------------------------ */
/***	MYDISP::setTransparency(fTrans)
**
**	Parameters:
**		fTrans		- true for background transparent, false for background opaque
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the background transparency mode.
*/

bool MYDISP::setTransparency(bool fTrans) {

	bkCur = fTrans ? bkTransparent : bkOpaque;
	return mtds.SetBkMode(hdsDisp, bkCur);
}

/* ------------------------------------------------------------ */
/***	MYDISP::setTransparency(fTrans, clr)
**
**	Parameters:
**		fTrans		- true for background transparent, false for background opaque
**		clr			- transparency color to set.
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the background transparency mode and the transparency color.
*/

bool MYDISP::setTransparency(bool fTrans, uint32_t clr) {

	clrTr = clr;
	mtds.SetTransColor(hdsDisp, clr);
	return setTransparency(fTrans);
}

/* ------------------------------------------------------------ */
/***	MYDISP::setIntensity(ity)
**
**	Parameters:
**		ity		- intensity value to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the bitmap drawing intensity value.
*/

bool MYDISP::setIntensity(int ity) {

	/* Set the specified color as the current background color.
	*/
	ityCur = ity;
	return mtds.SetIntensity(hdsDisp, ityCur);

}

/* ------------------------------------------------------------ */
/***	MYDISP::drawLine(x1, y1, x2, y2)
**
**	Parameters:
**		x1,y1		- starting point of line
**		x2,y2		- ending point of line
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw a line between the specified points using the current parameters
**		set in the display DS.
*/

bool MYDISP::drawLine(int x1, int y1, int x2, int y2) {

	if (!mtds.MoveTo(hdsDisp, (int16_t)x1, (int16_t)y1)) {
		return false;
	}
	return mtds.LineTo(hdsDisp, (int16_t)x2, (int16_t)y2);

}

/* ------------------------------------------------------------ */
/***	MYDISP::drawArc(x1, y1, x2, y2, xr1, yr1, xr2, yr2)
**
**	Parameters:
**		x1, y1		- upper left corner of bounding rectangle
**		x2, y2		- lower right corner of bounding rectangle
**		xr1, yr1	- endpoint of radial line giving start angle
**		xr2, yr2	- endpont of radial line giving end angle
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw the specified arc using the properties currently selected into the
**		display DS.
*/

bool MYDISP::drawArc(int x1, int y1, int x2, int y2, int xr1, int yr1, int xr2, int yr2) {

	return mtds.Arc(hdsDisp, (int16_t)x1, (int16_t)y1, (int16_t)x2, (int16_t)y2, 
						(int16_t)xr1, (int16_t)yr1, (int16_t)xr2, (int16_t)yr2);

}

/* ------------------------------------------------------------ */
/***	MYDISP::drawRectangle(fill, x1, y1, x2, y2)
**
**	Parameters:
**		fill		- true to fill, false to just draw outline
**		x1, y1		- upper left corner of rectangle
**		x2, y2		- lower right corner of rectangle
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw and fill the specified rectangle. If fill is specified, it is filled
**		with the solid brush corresponding to the currently selected foreground color.
**		The perimeter is drawn using the current pen. If a NULL pen is selected, no
**		perimeter is drawn.
*/

bool MYDISP::drawRectangle(bool fill, int x1, int y1, int x2, int y2) {

	if (fill) {
		mtds.SetBrush(hdsDisp, hbrFg);
	}
	else {
		mtds.SetBrush(hdsDisp, hbrNull);
	}

	return mtds.Rectangle(hdsDisp, (int16_t)x1, (int16_t)y1, (int16_t)x2, (int16_t)y2);

}

/* ------------------------------------------------------------ */
/***	MYDISP::drawEllipse(fill, x1, y1, x2, y2)
**
**	Parameters:
**		fill		- true to fill, false to just draw outline
**		x1, y1		- upper left corner of bounding rectangle
**		x2, y2		- lower right corner of bounding rectangle
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw and optionally fill the specified ellipse.
*/

bool MYDISP::drawEllipse(bool fill, int x1, int y1, int x2, int y2) {

	if (fill) {
		mtds.SetBrush(hdsDisp, hbrFg);
	}
	else {
		mtds.SetBrush(hdsDisp, hbrNull);
	}

	return mtds.Ellipse(hdsDisp, (int16_t)x1, (int16_t)y1, (int16_t)x2, (int16_t)y2);

}

/* ------------------------------------------------------------ */
/***	MYDISP::drawText(txt, x, y)
**
**	Parameters:
**		txt		- array of characters to draw
**		x, y	- coordinate of origin of the text
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Draw the specified string of characters at the specified location. The string
**		is drawn using the currently selected font, foreground and background colors.
**		The text origin corresponds to the upper left corner of the bounding box around
**		the text.
*/

bool MYDISP::drawText(char * txt, int x, int y) {
	int		cch;

	cch = strlen(txt);
	return mtds.TextOut(hdsDisp, (int16_t)x, (int16_t)y, cch, txt);

}

/* ------------------------------------------------------------ */
/***	MYDISP::drawImage(name, x, y)
**
**	Parameters:
**		name		- filename of the bitmap file to draw
**		x, y		- position of where to draw the bitmap
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		This function will load a bitmap file from the SD card and draw it at the
**		specified location. The bitmap is discarded after being drawn.
*/

bool MYDISP::drawImage(char * name, int x, int y) {
	HBMP	hbmp;

	if ((hbmp = mtds.LoadBitmap(name)) == 0) {
		/* Unable to load the bitmap.
		*/
#if !defined(__SIM__)
#if defined(__MTDSTRACE__)
		Serial.print("!drawImage ");
		Serial.println(mtds.GetLastError(), HEX);
#endif
#endif
		return false;
	}

	/* We loaded the bitmap successfully. Get its dimensions and then blt it
	** to the display at the requested location.
	*/
	drawImage(hbmp, x, y);
	mtds.DestroyBitmap(hbmp);

	return true;

}

/* ------------------------------------------------------------ */
/***	MYDISP::drawImage(hbmp, x, y)
**
**	Parameters:
**		name		- filename of the bitmap file to draw
**		x, y		- position of where to draw the bitmap
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		This function will draw the specified bitmap at the specified location.
*/

bool MYDISP::drawImage(HBMP hbmp, int x, int y) {
	BMPD	bmpd;

	if (!mtds.GetBitmapDimensions(hbmp, &bmpd)) {
		return false;
	}
	mtds.SetDrawingSurface(hdsBlt, hbmp);
	mtds.DrawBitmap(hdsDisp, (int16_t)x, (int16_t)y, bmpd.dxco, bmpd.dyco,
					hdsBlt, 0, 0);

	return true;

}

/* ------------------------------------------------------------ */
/***	loadImage(name)
**
**	Parameters:
**		name		- character string giving file name for image file
**
**	Return Values:
**		Returns the handle to the loaded bitmap
**
**	Errors:
**		Returns 0 if the bitmap can't be loaded into memory
**
**	Description:
**		This function will read the specified image file and load it into
**		memory as an internal, device-dependent bitmap.
*/

HBMP MYDISP::loadImage(char * name) {
	HBMP		hbmp;

	if ((hbmp = mtds.LoadBitmap(name)) == 0) {
		/* Unable to load the bitmap.
		*/
#if !defined(__SIM__)
#if defined(__MTDSTRACE__)
		Serial.print("!loadImage ");
		Serial.println(mtds.GetLastError(), HEX);
#endif
#endif
		return 0;
	}

	return hbmp;

}

/* ------------------------------------------------------------ */
/***	MYDISP::createButton(id, name, x, y)
**
**	Parameters:
**		id		- button ID
**		name	- name of bitmap file used to draw button
**		x, y	- origin of the button
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**
*/

bool MYDISP::createButton(int id, char * name, int x, int y) {
	HBMP	hbmp;

	/* Check that the ID is in range and the requested button record isn't already
	** in use.
	*/
	if ((id < 0) || (id >= NUM_BUTTONS) || ((rgbtn[id].fs & fsBtnAlloc) != 0)) {
		return false;
	}

	/* Load the bitmap used to render the button.
	*/
	if ((hbmp = mtds.LoadBitmap(name)) == 0) {
#if !defined(__SIM__)
#if defined(__MTDSTRACE__)
		Serial.print("!createButton ");
		Serial.println(mtds.GetLastError(), HEX);
#endif
#endif
		return false;
	}

	/* Create the button.
	*/
	return createButton(id, hbmp, 0, x, y);

}

/* ------------------------------------------------------------ */
/***	MYDISP::createButton(id, name1, name2, x, y)
**
**	Parameters:
**		id		- button ID
**		name1	- name of bitmap file for display in untouched state
**		name2	- name of bitmap file for dispaly in touched state (optional)
**		x, y	- origin of the button
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**
*/

bool MYDISP::createButton(int id, char * name1, char * name2, int x, int y) {
	HBMP	hbmp1;
	HBMP	hbmp2;

	/* Check that the ID is in range and the requested button record isn't already
	** in use.
	*/
	if ((id < 0) || (id >= NUM_BUTTONS) || ((rgbtn[id].fs & fsBtnAlloc) != 0)) {
		return false;
	}

	hbmp1 = 0;
	hbmp2 = 0;

	/* Load the bitmaps used to render the button.
	** The first bitmap is used to render the button in the UP state.
	*/
	if ((hbmp1 = mtds.LoadBitmap(name1)) == 0) {
#if !defined(__SIM__)
#if defined(__MTDSTRACE__)
		Serial.print("!createButton ");
		Serial.println(mtds.GetLastError(), HEX);
#endif
#endif
		goto lErrorExit;
	}

	/* The second bitmap is used to render the button in the DOWN state.
	*/
	if ((hbmp2 = mtds.LoadBitmap(name2)) == 0) {
#if !defined(__SIM__)
#if defined(__MTDSTRACE__)
		Serial.print("!createButton ");
		Serial.println(mtds.GetLastError(), HEX);
#endif
#endif
		goto lErrorExit;
	}

	return createButton(id, hbmp1, hbmp2, x, y);

	/* Error occured. Clean up and get out.
	*/
lErrorExit:
	if (hbmp1 != 0) {
		mtds.DestroyBitmap(hbmp1);
	}
	if (hbmp2 != 0) {
		mtds.DestroyBitmap(hbmp2);
	}
	return false;
}

/* ------------------------------------------------------------ */
/***	MYDISP::createButton(id, hbmp1, hbmp2, x, y)
**
**	Parameters:
**		id		- button ID
**		name1	- name of bitmap file for display in untouched state
**		name2	- name of bitmap file for dispaly in touched state (optional)
**		x, y	- origin of the button
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**
*/

bool MYDISP::createButton(int id, HBMP hbmp1, HBMP hbmp2, int x, int y) {
	BMPD	bmpd;

	/* Check that the ID is in range and the requested button record isn't already
	** in use.
	*/
	if ((id < 0) || (id >= NUM_BUTTONS) || ((rgbtn[id].fs & fsBtnAlloc) != 0)) {
		return false;
	}

	rgbtn[id].fs = 0;
	rgbtn[id].hbmpUp = hbmp1;
	rgbtn[id].hbmpDn = hbmp2;

	/* We use the button-up bitmap to establish the button dimensions.
	*/
	if (!mtds.GetBitmapDimensions(rgbtn[id].hbmpUp, &bmpd)) {
		goto lErrorExit;
	}

	/* Create the bitmap used to hold the background behind the button so that we
	** can erase it later.
	*/
	if ((rgbtn[id].hbmpBg = mtds.CreateBitmap(bmpd.dxco, bmpd.dyco, bmpd.cbpp)) == 0) {
		goto lErrorExit;
	}

	/* Set up the rest of the button member data.
	*/
	rgbtn[id].rct.xcoLeft = x;
	rgbtn[id].rct.ycoTop  = y;
	rgbtn[id].rct.xcoRight = x + bmpd.dxco - 1;
	rgbtn[id].rct.ycoBottom = y + bmpd.dyco - 1;
	rgbtn[id].dxco = bmpd.dxco;
	rgbtn[id].dyco = bmpd.dyco;

	rgbtn[id].fs |= fsBtnAlloc;

	return true;

	/* Error occured. Clean up and get out.
	*/
lErrorExit:
	DeleteBtnBitmaps(id);
	return false;
}

/* ------------------------------------------------------------ */
/***	MYDISP::deleteButton(id)
**
**	Parameters:
**		id		- button identifier for button to delete
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Free any resources associated with the specified button.
*/

bool MYDISP::deleteButton(int id) {

	/* Check that the button ID is in the allowed range and that the button being
	** deleted is actually allocated.
	*/
	if ((id < 0) || (id >= NUM_BUTTONS) || ((rgbtn[id].fs & fsBtnAlloc) == 0)) {
		return false;
	}

	/* Release any bitmaps associated with this button and then mark the button
	** as not being allocated.
	*/
	DeleteBtnBitmaps(id);
	rgbtn[id].fs = 0;

	return true;

}

/* ------------------------------------------------------------ */
/***	MYDISP::enableButton(id, fEn)
**
**	Parameters:
**		id		- button identifier
**		fEn		- button show state, true=enabled, false=disabled
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Activate the button and draw it in its current touched state
*/

bool MYDISP::enableButton(int id, bool fEn) {

	/* Check that the button ID is valid and that the button is actually in use.
	*/
	if ((id < 0) || (id >= NUM_BUTTONS) || ((rgbtn[id].fs & fsBtnAlloc) == 0)) {
		return false;
	}

	/* Mark the button as being enabled or disabled as requested.
	*/
	if (fEn) {
		/* Grab the background behind the button for use later in erasing the button.
		*/
		if ((rgbtn[id].fs & fsBtnEnabled) == 0) {
			/* Only grab the background if the button isn't already enabled. In some cases
			** the user needs to be able to enable a button that is already enabled and we
			** don't want to overwrite the saved background data when that occurs.
			*/
			mtds.SetDrawingSurface(hdsBlt, rgbtn[id].hbmpBg);
			mtds.BitBlt(hdsBlt, 0, 0, rgbtn[id].dxco, rgbtn[id].dyco,
							hdsDisp, rgbtn[id].rct.xcoLeft, rgbtn[id].rct.ycoTop, ropSrcCopy);
		}

		/* Mark the button as being enabled and clear its last known drawing state.
		*/
		rgbtn[id].fs |= fsBtnEnabled;
		rgbtn[id].fs &= ~(fsBtnImageUp|fsBtnImageDn);
	}
	else {
		/* Mark the button as being disabled.
		*/
		rgbtn[id].fs &= ~fsBtnEnabled;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MYDISP::drawButton(id, st)
**
**	Parameters:
**		id		- button identifier
**		st		- button state to draw: BUTTON_UP, BUTTON_DOWN or BUTTON_ERASE
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Update the visible state of the button as specified
*/

bool MYDISP::drawButton(int id, int st) {

	/* Check that the button ID is valid and that the button is actually in use.
	*/
	if ((id < 0) || (id >= NUM_BUTTONS) || ((rgbtn[id].fs & fsBtnAlloc) == 0)) {
		return false;
	}

	/* Check that the button is enabled. We only draw enabled buttons.
	*/
	if ((rgbtn[id].fs & fsBtnEnabled) == 0) {
		return true;
	}

	/* See what appearance we are being requested to draw.
	*/
	switch(st) {
		case BUTTON_UP:
			/* If the button is already drawn in the "up" state, don't draw it again.
			*/
			if ((rgbtn[id].fs & fsBtnImageUp) == 0) {
				/* Erase the background before drawing the button.
				*/
				mtds.SetDrawingSurface(hdsBlt, rgbtn[id].hbmpBg);
				mtds.BitBlt(hdsDisp, rgbtn[id].rct.xcoLeft, rgbtn[id].rct.ycoTop,
									rgbtn[id].dxco, rgbtn[id].dyco,
									hdsBlt, 0, 0, ropSrcCopy);

				/* Draw the button in the up/un-pressed state by drawing the UP bitmap
				** on the display.
				*/
				mtds.SetDrawingSurface(hdsBlt, rgbtn[id].hbmpUp);
				mtds.SetIntensity(hdsDisp, 100);
				mtds.DrawBitmap(hdsDisp, rgbtn[id].rct.xcoLeft, rgbtn[id].rct.ycoTop,
									 rgbtn[id].dxco, rgbtn[id].dyco,
									 hdsBlt, 0, 0);
				mtds.SetIntensity(hdsDisp, ityCur);
			}

			/* Mark that it is drawn in the up state.
			*/
			rgbtn[id].fs &= ~(fsBtnImageUp|fsBtnImageDn);
			rgbtn[id].fs |= fsBtnImageUp;
			break;

		case BUTTON_DOWN:
			/* If the button has already been drawn in the "down" state, don't draw it
			** again.
			*/
			if ((rgbtn[id].fs & fsBtnImageDn) == 0) {
				/* Erase the background before drawing the button.
				*/
				mtds.SetDrawingSurface(hdsBlt, rgbtn[id].hbmpBg);
				mtds.BitBlt(hdsDisp, rgbtn[id].rct.xcoLeft, rgbtn[id].rct.ycoTop,
									rgbtn[id].dxco, rgbtn[id].dyco,
									hdsBlt, 0, 0, ropSrcCopy);

				/* Draw the button in the down/pressed state.
				*/
				if (rgbtn[id].hbmpDn == 0) {
					mtds.SetDrawingSurface(hdsBlt, rgbtn[id].hbmpUp);
					mtds.SetIntensity(hdsDisp, 50);
				}
				else {
					mtds.SetDrawingSurface(hdsBlt, rgbtn[id].hbmpDn);
					mtds.SetIntensity(hdsDisp, 100);
				}
				mtds.DrawBitmap(hdsDisp, rgbtn[id].rct.xcoLeft, rgbtn[id].rct.ycoTop,
									rgbtn[id].dxco, rgbtn[id].dyco,
									hdsBlt, 0, 0);
				mtds.SetIntensity(hdsDisp, ityCur);
			}

			/* Mark that it is drawn in the down state.
			*/
			rgbtn[id].fs &= ~(fsBtnImageUp|fsBtnImageDn);
			rgbtn[id].fs |= fsBtnImageDn;		
			break;

		case BUTTON_ERASE:
			/* Erase the button by drawing the background bitmap saved when
			** the button was enabled.
			*/
			mtds.SetDrawingSurface(hdsBlt, rgbtn[id].hbmpBg);
			mtds.BitBlt(hdsDisp, rgbtn[id].rct.xcoLeft, rgbtn[id].rct.ycoTop,
								rgbtn[id].dxco, rgbtn[id].dyco,
								hdsBlt, 0, 0, ropSrcCopy);

			rgbtn[id].fs &= ~(fsBtnImageUp|fsBtnImageDn);
			break;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MYDISP::isEnabled(id)
**
**	Parameters:
**		id		- button identifier
**
**	Return Values:
**		Returns true if the specified button is enabled, else false
**
**	Errors:
**		none
**
**	Description:
**		Return the enabled state of the specified button.
*/

bool MYDISP::isEnabled(int id) {

	if ((id >= 0) && (id < NUM_BUTTONS)) {
		if (((rgbtn[id].fs & fsBtnAlloc) != 0) &&
			((rgbtn[id].fs & fsBtnEnabled) != 0)) {
			return true;
		}
	}

	return false;
}

/* ------------------------------------------------------------ */
/***	MYDISP::isTouched(id)
**
**	Parameters:
**		id		- button identifier
**
**	Return Values:
**		Returns true if the specified button is visible and being touched
**
**	Errors:
**		none
**
**	Description:
**		Return the "touched" state of the specified button.
*/

bool MYDISP::isTouched(int id) {

	if ((id >= 0) && (id < NUM_BUTTONS)) {
		if (((rgbtn[id].fs & fsBtnAlloc) != 0) && 
			((rgbtn[id].fs & fsBtnEnabled) != 0) &&
			((rgbtn[id].fs & fsBtnTouched) != 0)) {
			return true;
		}
	}

	return false;
}

/* ------------------------------------------------------------ */
/***	MYDISP::getFinger(id, fng)
**
**	Parameters:
**		id		- finger number
**		fng		- pointer to structure to receive finger data
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Return last know touch activity for the specified finger
*/

bool MYDISP::getFinger(int id, MDFNG * fng) {

	/* Check for valid finger number.
	*/
	if ((id < 0) || (id >= NUM_FINGERS)) {
		return false;
	}

	fng->st = rgfng[id].st;
	fng->x  = rgfng[id].x;
	fng->y  = rgfng[id].y;

	return true;

}

/* ------------------------------------------------------------ */
/***	MYDISP::getButton()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the ID of the last button "pressed" or -1 if no button has been pressed
**
**	Errors:
**		none
**
**	Description:
**		Scan the array of buttons to find the first one with the fsBtnActivated bit set
**		in the flags. If one is found, clear the bit and return its ID.
*/

int MYDISP::getButton() {
	int		ibtn;

	for (ibtn = 0; ibtn < NUM_BUTTONS; ibtn++) {
		if ((rgbtn[ibtn].fs & fsBtnActivated) != 0) {
			rgbtn[ibtn].fs &= ~fsBtnActivated;
			return ibtn;
		}
	}

	return -1;

}

/* ------------------------------------------------------------ */
/***	MYDISP::checkTouch()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		This function is the executive for maintaining the library state with
**		regard to touch operations in the user interface. It polls the message
**		queue for any touch messages, consumes them, maintaining the current
**		state of the buttons and such based on the touch events seen.
*/

void MYDISP::checkTouch() {
	MTCH		mtch;
	int			idBtn;

	/* See if there is anything in the event queue.
	*/
	if (!fInitialized || mtds.GetMsgStatus() == 0) {
		/* Nothing in the queue, so we're done.
		*/
		return;
	}

	/* There is something in the queue. See what we have.
	*/
	mtds.GetMsg((MEVT *)&mtch);
#if !defined(__SIM__)
#if defined(__MTDSTRACE__)
	Serial.print("MTCH: tms = ");
	Serial.print(mtch.tms, DEC);
	Serial.print(" hwin = ");
	Serial.print(mtch.hwin, HEX);
	Serial.print(" msg = ");
	Serial.println(mtch.msg, HEX);
	Serial.print("  xco = ");
	Serial.print(mtch.xco, DEC);
	Serial.print(" yco = ");
	Serial.print(mtch.yco, DEC);
	Serial.print(" wgt = ");
	Serial.print(mtch.wgt, DEC);
	Serial.print(" spd = ");
	Serial.println(mtch.spd, DEC);
#endif
#endif

	if ((mtch.msg < msgFingerFirst) || (mtch.msg > msgFingerLast)) {
		/* This library assumes that there is not anything of interest in the queue
		** other than touch messages. It throws away any messages seen except
		** touch messages.
		*/
		return;
	}

	/* It is a touch message.
	** First, update the finger tracking structures.
	*/
	if ((mtch.msg >= msgFinger1Down) && (mtch.msg <= msgFinger1Up)) {
		rgfng[0].x = mtch.xco;
		rgfng[0].y = mtch.yco;
		if (mtch.msg == msgFinger1Down) {
			rgfng[0].st = FINGER_DOWN;
		}
		else if (mtch.msg == msgFinger1Move) {
			rgfng[0].st = FINGER_MOVE;
		}
		else {
			rgfng[0].st = FINGER_UP;
		}
	}

	if ((mtch.msg >= msgFinger2Down) && (mtch.msg <= msgFinger2Up)) {
		rgfng[1].x = mtch.xco;
		rgfng[1].y = mtch.yco;
		if (mtch.msg == msgFinger2Down) {
			rgfng[1].st = FINGER_DOWN;
		}
		else if (mtch.msg == msgFinger2Move) {
			rgfng[1].st = FINGER_MOVE;
		}
		else {
			rgfng[1].st = FINGER_UP;
		}
	}

	/* Check if we are currently tracking finger 1 for button press activity.
	*/
	if (idBtnTrack == -1) {
		/* We're not currently tracking, If this is a finger 1 down message, we may need
		** to start tracking for a button press.
		*/
		if (mtch.msg == msgFinger1Down) {
			if ((idBtn = IdBtnFromXcoYco(mtch.xco, mtch.yco)) != -1) {
				/* We have a finger down over a button, so start tracking for a button
				** press on this button.
				*/
				idBtnTrack = idBtn;
				rgbtn[idBtnTrack].fs |= fsBtnTouched;
			}
		}
	}
	else {
		/* We are currently tracking finger 1. Check that the finger is still over the
		** button.
		*/
		if (mtch.msg == msgFinger1Move) {
			if (!mtds.PointInRect(&(rgbtn[idBtnTrack].rct), mtch.xco, mtch.yco)) {
				/* The finger has moved off of the button, stop tracking it.
				*/
				rgbtn[idBtnTrack].fs &= ~fsBtnTouched;
				idBtnTrack = -1;
			}
		}
		else if (mtch.msg == msgFinger1Up) {
			if (mtds.PointInRect(&(rgbtn[idBtnTrack].rct), mtch.xco, mtch.yco)) {
				/* Finger up over the button, so indicate that the button has been
				** activated.
				*/
				rgbtn[idBtnTrack].fs |= fsBtnActivated;
			}
			rgbtn[idBtnTrack].fs &= ~fsBtnTouched;
			idBtnTrack = -1;
		}
	}

}

/* ------------------------------------------------------------ */
/*				Private Helper Functions						*/
/* ------------------------------------------------------------ */
/***	MYDISP::IdBtnFromXcoYco(xco, yco)
**
**	Parameters:
**		xco, yco	- point to hit-test against the button array.
**
**	Return Values:
**		Returns a button ID or -1 if no button satisfies the test
**
**	Errors:
**		none
**
**	Description:
**		This function will check the button array and return the ID of the first 
**		visible button that contains the specified coordinate. It returns -1 if
**		no visible button contains the specified coordinate.
*/

int MYDISP::IdBtnFromXcoYco(int16_t xco, int16_t yco) {
	int		ibtn;

	for (ibtn = 0; ibtn < NUM_BUTTONS; ibtn++) {
		if (((rgbtn[ibtn].fs & fsBtnAlloc) != 0) && ((rgbtn[ibtn].fs & fsBtnEnabled) != 0)) {
			if (mtds.PointInRect(&(rgbtn[ibtn].rct), xco, yco)) {
				return ibtn;
			}
		}
	}

	return -1;

}

/* ------------------------------------------------------------ */
/***	MYDISP::DeleteBtnBitmaps(id)
**
**	Parameters:
**		id		- button id
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Deletes any bitmaps associated with the specified button.
*/

void MYDISP::DeleteBtnBitmaps(int id) {

	if (rgbtn[id].hbmpUp != 0) {
		mtds.DestroyBitmap(rgbtn[id].hbmpUp);
		rgbtn[id].hbmpUp = 0;
	}

	if (rgbtn[id].hbmpDn != 0) {
		mtds.DestroyBitmap(rgbtn[id].hbmpDn);
		rgbtn[id].hbmpDn = 0;
	}

	if (rgbtn[id].hbmpBg != 0) {
		mtds.DestroyBitmap(rgbtn[id].hbmpBg);
		rgbtn[id].hbmpBg = 0;
	}
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

