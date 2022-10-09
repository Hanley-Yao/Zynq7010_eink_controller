/************************************************************************/
/*																		*/
/*	OLED_Char.c	--	Character Output Routines for OLED Display			*/
/*																		*/
/************************************************************************/
/*	Author: 	Gene Apperson											*/
/*	Copyright 2011, Digilent Inc.										*/
/************************************************************************/
/*
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
/************************************************************************/
/*  Module Description: 												*/
/*																		*/
/*	This module contains the implementations of the 'character mode'	*/
/*	functions. These functions treat the graphics display as a 4 row	*/
/*	by 16 column character display.										*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	06/01/2011(GeneA): created											*/
/*	06/20/2016(ArtVVB): edited for PmodOLED IP							*/
/*																		*/
/************************************************************************/


/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "PmodOLED.h"

/* ------------------------------------------------------------ */
/*				Local Variables									*/
/* ------------------------------------------------------------ */

extern const uint8_t rgbFillPat[];

/* ------------------------------------------------------------ */
/*				Forward Declarations							*/
/* ------------------------------------------------------------ */

void	OLED_DrawGlyph(PmodOLED *InstancePtr, char ch);
void	OLED_AdvanceCursor(PmodOLED *InstancePtr);

/* ------------------------------------------------------------ */
/*				Procedure Definitions							*/
/* ------------------------------------------------------------ */
/***	OLED_SetCursor
**
**	Parameters:
**		InstancePtr - pointer to SPI handler and OLED data
**	    InstancePtr - pointer to PmodOLED
**		xch			- horizontal character position
**		ych			- vertical character position
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Set the character cursor position to the specified location.
**		If either the specified X or Y location is off the display, it
**		is clamped to be on the display.
*/

void OLED_SetCursor(PmodOLED *InstancePtr, int xch, int ych)
{
	OLED *OledPtr = &(InstancePtr->OLEDState);
	/* Clamp the specified location to the display surface
	*/
	if (xch >= OledPtr->xchOledMax) {
		xch = OledPtr->xchOledMax-1;
	}

	if (ych >= OledPtr->ychOledMax) {
		ych = OledPtr->ychOledMax-1;
	}

	/* Save the given character location.
	*/
	OledPtr->xchOledCur = xch;
	OledPtr->ychOledCur = ych;

	/* Convert the character location to a frame buffer address.
	*/
	OLED_MoveTo(InstancePtr, xch*OledPtr->dxcoOledFontCur, ych*OledPtr->dycoOledFontCur);
}

/* ------------------------------------------------------------ */
/***	OLED_GetCursor
**
**	Parameters:
**		InstancePtr - pointer to SPI handler and OLED data
**		pxch		- pointer to variable to receive horizontal position
**		pych		- pointer to variable to receive vertical position
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Fetch the current cursor position
*/

void OLED_GetCursor(PmodOLED *InstancePtr, int *pxch, int *pych)
{
	*pxch = InstancePtr->OLEDState.xchOledCur;
	*pych = InstancePtr->OLEDState.ychOledCur;
}

/* ------------------------------------------------------------ */
/***	OLED_DefUserChar
**
**	Parameters:
**		InstancePtr - pointer to SPI handler and OLED data
**		ch			- character code to define
**		pbDef		- definition for the character
**
**	Return Value:
**		none
**
**	Errors:
**		Returns TRUE if successful, FALSE if not
**
**	Description:
**		Give a definition for the glyph for the specified user
**		character code. User definable character codes are in
**		the range 0x00 - 0x1F. If the code specified by ch is
**		outside this range, the function returns false.
*/

int OLED_DefUserChar(PmodOLED *InstancePtr, char ch, uint8_t *pbDef)
{
	uint8_t *pb;
	int		 ib;
	OLED 	*OledPtr = &(InstancePtr->OLEDState);

	if (ch < chOledUserMax) {
		pb = OledPtr->pbOledFontUser + ch * cbOledChar;
		for (ib = 0; ib < cbOledChar; ib++) {
			*pb++ = *pbDef++;
		}
		return 1;
	}
	else {
		return 0;
	}
}

/* ------------------------------------------------------------ */
/***	OLED_SetCharUpdate
**
**	Parameters:
**		InstancePtr - pointer to SPI handler and OLED data
**		f			- enable/disable automatic update
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Set the character update mode. This determines whether
**		or not the display is automatically updated after a
**		character or string is drawn. A non-zero value turns
**		automatic updating on.
*/

void OLED_SetCharUpdate(PmodOLED *InstancePtr, int f)
{
	InstancePtr->OLEDState.fOledCharUpdate = (f != 0) ? 1 : 0;
}

/* ------------------------------------------------------------ */
/***	OLED_GetCharUpdate
**
**	Parameters:
**		InstancePtr - pointer to SPI handler and OLED data
**
**	Return Value:
**		returns current character update mode
**
**	Errors:
**		none
**
**	Description:
**		Return the current character update mode.
*/

int OLED_GetCharUpdate(PmodOLED *InstancePtr)
{
	return InstancePtr->OLEDState.fOledCharUpdate;
}

/* ------------------------------------------------------------ */
/***	OLED_PutChar
**
**	Parameters:
**		InstancePtr - pointer to SPI handler and OLED data
**		ch			- character to write to display
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Write the specified character to the display at the current
**		cursor position and advance the cursor.
*/

void OLED_PutChar(PmodOLED *InstancePtr, char ch)
{

	OLED_DrawGlyph(InstancePtr, ch);
	OLED_AdvanceCursor(InstancePtr);
	if (InstancePtr->OLEDState.fOledCharUpdate) {
		OLED_Update(InstancePtr);
	}
}

/* ------------------------------------------------------------ */
/***	OLED_PutString
**
**	Parameters:
**		InstancePtr - pointer to SPI handler and OLED data
**		sz		- pointer to the null terminated string
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Write the specified null terminated character string to the
**		display and advance the cursor.
*/

void OLED_PutString(PmodOLED *InstancePtr, char *sz)
{
	while (*sz != '\0') {
		OLED_DrawGlyph(InstancePtr, *sz);
		OLED_AdvanceCursor(InstancePtr);
		sz += 1;
	}
	if (InstancePtr->OLEDState.fOledCharUpdate) {
		OLED_Update(InstancePtr);
	}
}

/* ------------------------------------------------------------ */
/***	OLED_DrawGlyph
**
**	Parameters:
**		InstancePtr - pointer to SPI handler and OLED data
**		ch		- character code of character to draw
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Renders the specified character into the display buffer
**		at the current character cursor location. This does not
**		affect the current character cursor location or the 
**		current drawing position in the display buffer.
*/

void OLED_DrawGlyph(PmodOLED *InstancePtr, char ch)
{
	uint8_t *pbFont;
	uint8_t *pbBmp;
	int		 ib;
	OLED 	*OledPtr = &(InstancePtr->OLEDState);

	if ((ch & 0x80) != 0) {
		return;
	}

	if (ch < chOledUserMax) {
		pbFont = OledPtr->pbOledFontUser + ch*cbOledChar;
	}
	else if ((ch & 0x80) == 0) {
		pbFont = OledPtr->pbOledFontCur + (ch-chOledUserMax) * cbOledChar;
	}

	pbBmp = OledPtr->pbOledCur;

	for (ib = 0; ib < OledPtr->dxcoOledFontCur; ib++) {
		*pbBmp++ = *pbFont++;
	}

}

/* ------------------------------------------------------------ */
/***	OLED_AdvanceCursor
**
**	Parameters:
**		InstancePtr - pointer to SPI handler and OLED data
**
**	Return Value:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Advance the character cursor by one character location,
**		wrapping at the end of line and back to the top at the
**		end of the display.
*/

void OLED_AdvanceCursor(PmodOLED *InstancePtr)
{
	OLED *OledPtr = &(InstancePtr->OLEDState);

	OledPtr->xchOledCur += 1;
	if (OledPtr->xchOledCur >= OledPtr->xchOledMax) {
		OledPtr->xchOledCur = 0;
		OledPtr->ychOledCur += 1;
	}
	if (OledPtr->ychOledCur >= OledPtr->ychOledMax) {
		OledPtr->ychOledCur = 0;
	}

	OLED_SetCursor(InstancePtr, OledPtr->xchOledCur, OledPtr->ychOledCur);
}

/* ------------------------------------------------------------ */
/***	ProcName
**
**	Parameters:
**
**	Return Value:
**
**	Errors:
**
**	Description:
**
*/

/* ------------------------------------------------------------ */

/************************************************************************/

