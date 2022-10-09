/********************************************************************************/
/*																				*/
/*	MyDisp.h	--	Simple User Library for Multi-Touch Display Shield			*/
/*																				*/
/********************************************************************************/
/*	Author:		Gene Apperson													*/
/*	Copyright 2016, Digilent Inc. All rights reserved.							*/
/********************************************************************************/
/*  File Description:															*/
/*																				*/
/*	Interface declarations for the simple user libary for the Multi-Touch		*/
/*	Display Shield by Digilent, Inc. This library provides a simplified access	*/
/*	model for use of the MTDS firmware. It uses and depends upon the main MTDS	*/
/*	library for access to the shield. This library puts a simplified wrapper on	*/
/*	top of some of the functions in the MTDS library.							*/
/*																				*/
/********************************************************************************/
/*  Revision History:															*/
/*																				*/
/*	2016-03-25(GeneA): created													*/
/*																				*/
/********************************************************************************/

#if !defined(_MYDISP_H_)
#define	_MYDISP_H_

#include <stdint.h>
#include <mtds.h>

/* ------------------------------------------------------------ */
/*					Public Declarations							*/
/* ------------------------------------------------------------ */

#define	verMyDispMajor		1
#define	verMyDispMinor		1

/* Declarations that are part of the library user interface.
*/
#if defined(__AVR__)
#define	NUM_BUTTONS		12	//AVR devices don't have very much RAM, so not as many buttons
							// can be defined.
#else
#define	NUM_BUTTONS		32
#endif
#define	NUM_FINGERS		2

#define	FINGER_UP		0
#define	FINGER_DOWN		1
#define FINGER_MOVE		2

#define	BUTTON_UP		0
#define	BUTTON_DOWN		1
#define	BUTTON_ERASE	2

struct MDFNG {
	uint16_t	st;			// last finger activity
	int16_t		x;			// finger x coordinate
	int16_t		y;			// finger y coordinate
};

/* ------------------------------------------------------------ */
/*					Private Declarations						*/
/* ------------------------------------------------------------ */

/* Declarations of symbols used internal to the library.
*/
#define	fsBtnActivated	0x0001		// button has been activated
#define	fsBtnTrans		0x0002		// button is to be drawn with transparency
#define	fsBtnScale		0x0004		// button is to be drawn with pixel brightness scaling
#define	fsBtnTouched	0x0010		// there is a finger within the button bounding rect
#define	fsBtnImageUp	0x0020		// button is currently drawn up
#define	fsBtnImageDn	0x0040		// button is currently drawn down
#define	fsBtnEnabled	0x4000		// button is active
#define	fsBtnAlloc		0x8000		// button is allocated

/* ------------------------------------------------------------ */
/*					Object Class Declarations					*/
/* ------------------------------------------------------------ */

class	MYDISP;
extern	MYDISP	mydisp;

struct MDBTN {
	uint32_t	fs;				// button state
	HBMP		hbmpUp;			// bitmap to draw button in up (untouched) state
	HBMP		hbmpDn;			// bitmap to draw button in down (touched) state
	HBMP		hbmpBg;			// bitmap for button background used to erase button
	RCT			rct;			// button region on the display
	uint32_t	clrTrans;		// background transparency color to use
	uint16_t	sclPix;			// pixel brightness to use
	int16_t		dxco;			// bitmap width
	int16_t		dyco;			// bitmap height
};

class MYDISP {
private:
	bool		fInitialized;
	int			idBtnTrack;		// button currently being tracked for button press
	HDS			hdsDisp;
	HDS			hdsBlt;
	HBR			hbrFg;
	uint32_t	clrFg;
	uint32_t	clrBg;
	uint32_t	clrTr;
	uint16_t	penCur;
	uint16_t	bkCur;			// current background transparency mode
	int			ityCur;
	MDFNG		rgfng[2];
	MDBTN		rgbtn[NUM_BUTTONS];

	void		DeleteBtnBitmaps(int id);
	int			IdBtnFromXcoYco(int16_t xco, int16_t yco);

public:
			MYDISP();
		   ~MYDISP();
	bool	begin();
	void	end();

	/* Setup and status functions.
	*/
	bool		displayOn(bool fEn)				{ return mtds.SetDisplayEnable(fEn ? 1 : 0); };
	bool		clearDisplay(uint32_t clr)		{ return mtds.ClearDisplay(clr); };
	bool		setBacklight(int val)			{ return mtds.SetDisplayBacklight((uint32_t)val); };
	HDS			displayHds()					{ return hdsDisp; };
	bool		setPen(uint16_t pen);
	bool		setForeground(uint32_t clr);
	bool		setBackground(uint32_t clr);
	bool		setTransparency(bool fTrans);
	bool		setTransparency(bool fTrans, uint32_t clr);
	bool		setIntensity(int ity);
	bool		setFont(int idFont);
	HBMP		loadImage(char * name);
	bool		deleteImage(HBMP hbmp)			{ return mtds.DestroyBitmap(hbmp); };

	/* Basic graphics drawing functions.
	*/
	bool		setPixel(int x, int y, uint32_t clr)
							{ return mtds.SetPixel(hdsDisp, (int16_t)x, (int16_t)y, clr); };
	uint32_t	getPixel(int x, int y)
							{ return mtds.GetPixel(hdsDisp, (int16_t)x, (int16_t)y); };
	bool		drawLine(int x1, int y1, int x2, int y2);
	bool		drawArc(int x1, int y1, int x2, int y2,	int xr1, int yr1, int xr2, int yr2);
	bool		drawRectangle(bool fill, int x1, int y1, int x2, int y2);
	bool		drawEllipse(bool fill, int x1, int y1, int x2, int y2);
	bool		drawImage(char * name, int x, int y);
	bool		drawImage(HBMP hbmp, int x, int y);
	bool		drawText(char * txt, int x, int y);

	/* User interface management fuctions.
	*/
	bool		createButton(int id, char * name, int x, int y);
	bool		createButton(int id, char * name1, char * name2, int x, int y);
	bool		createButton(int id, HBMP hbmp1, HBMP hbmp2, int x, int y);
	bool		deleteButton(int id);
	bool		enableButton(int id, bool fEn);
	bool		drawButton(int id, int st);
	bool		isEnabled(int id);
	bool		isTouched(int id);
	bool		getFinger(int num, MDFNG * fng);
	int			getButton();
	void		checkTouch();
};

/* ------------------------------------------------------------ */
/*					Variable Declarations						*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */

#endif		// _MYDISP_H_

/********************************************************************************/
