/************************************************************************/
/*                                                                      */
/*  OledGrph.c  --  OLED Display Graphics Routines                      */
/*                                                                      */
/************************************************************************/
/*  Author:     Gene Apperson                                           */
/*  Copyright 2011, Digilent Inc.                                       */
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
/*  Module Description:                                                 */
/*                                                                      */
/*  This module contains the implementation of the graphics functions   */
/*  for the OLED display driver.                                        */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*  06/03/2011(GeneA): created                                          */
/*  06/20/2016(ArtVVB): edited for PmodOLED IP                          */
/*                                                                      */
/************************************************************************/


/* ------------------------------------------------------------ */
/*              Include File Definitions                        */
/* ------------------------------------------------------------ */

#include "PmodOLED.h"

/* ------------------------------------------------------------ */
/*              Local Type Definitions                          */
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*              Local Variables                                 */
/* ------------------------------------------------------------ */

extern const u8 rgbFillPat[];

/* ------------------------------------------------------------ */
/*              Forward Declarations                            */
/* ------------------------------------------------------------ */

void GrphMoveDown   (PmodOLED *InstancePtr);
void GrphMoveUp     (PmodOLED *InstancePtr);
void GrphMoveRight  (PmodOLED *InstancePtr);
void GrphMoveLeft   (PmodOLED *InstancePtr);
u8   GrphRopSet     (u8 bPix, u8 bDsp, u8 mskPix);
u8   GrphRopOr      (u8 bPix, u8 bDsp, u8 mskPix);
u8   GrphRopAnd     (u8 bPix, u8 bDsp, u8 mskPix);
u8   GrphRopXor     (u8 bPix, u8 bDsp, u8 mskPix);
int  GrphClampXco   (int xco);
int  GrphClampYco   (int yco);
int  GrphGrphAbs    (int foo);

/* ------------------------------------------------------------ */
/*              Procedure Definitions                           */
/* ------------------------------------------------------------ */
/***    OLED_MoveTo
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      xco         - x coordinate
**      yco         - y coordinate
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Set the current graphics drawing position.
*/
void OLED_MoveTo(PmodOLED *InstancePtr, int xco, int yco)
{
    OLED *OledPtr = &(InstancePtr->OLEDState);

    /* Clamp the specified coordinates to the display surface
    */
    xco = GrphClampXco(xco);
    yco = GrphClampYco(yco);

    /* Save the current position.
    */
    OledPtr->xcoOledCur = xco;
    OledPtr->ycoOledCur = yco;

    /* Compute the display access parameters corresponding to
    ** the specified position.
    */
    OledPtr->pbOledCur = &OledPtr->rgbOledBmp[((yco/8) * ccolOledMax) + xco];
    OledPtr->bnOledCur = yco & 7;

}

/* ------------------------------------------------------------ */
/*              Procedure Definitions                           */
/* ------------------------------------------------------------ */
/***    GrphAbs
**
**  Parameters:
**      foo         - an integer
**
**  Return Value:
**      the absolute value of foo
**
**  Errors:
**      none
**
**  Description:
**      absolute value function
*/
int GrphAbs(int foo)
{
    return (foo < 0) ? (foo * -1) : (foo);
}

/* ------------------------------------------------------------ */
/***    OLED_GetPos
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      pxco    - variable to receive x coordinate
**      pyco    - variable to receive y coordinate
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Fetch the current graphics drawing position
*/
void OLED_GetPos(PmodOLED *InstancePtr, int *pxco, int *pyco)
{
    *pxco = InstancePtr->OLEDState.xcoOledCur;
    *pyco = InstancePtr->OLEDState.ycoOledCur;
}

/* ------------------------------------------------------------ */
/***    OLED_SetDrawColor
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      clr     - drawing color to set
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Set the foreground color used for pixel draw operations.
*/
void OLED_SetDrawColor(PmodOLED *InstancePtr, u8 clr)
{
    InstancePtr->OLEDState.clrOledCur = clr & 0x01;
}

/* ------------------------------------------------------------ */
/***    OLED_GetStdPattern
**
**  Parameters:
**      ipat        - index to standard fill pattern
**
**  Return Value:
**      returns a pointer to the standard fill pattern
**
**  Errors:
**      returns pattern 0 if index out of range
**
**  Description:
**      Return a pointer to the byte array for the specified
**      standard fill pattern.
*/
u8 *OLED_GetStdPattern(int ipat)
{
    return rgbFillPat + 8*ipat;
}

/* ------------------------------------------------------------ */
/***    OLED_SetFillPattern
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      pbPat   - pointer to the fill pattern
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Set a pointer to the current fill pattern to use. A fill
**      pattern is an array of 8 bytes.
*/
void OLED_SetFillPattern(PmodOLED *InstancePtr, u8 *pbPat)
{
    InstancePtr->OLEDState.pbOledPatCur = pbPat;
}

/* ------------------------------------------------------------ */
/***    OLED_SetDrawMode
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      mod     - drawing mode to select
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Set the specified mode as the current drawing mode.
*/
void OLED_SetDrawMode(PmodOLED *InstancePtr, int mod)
{
    OLED *OledPtr = &(InstancePtr->OLEDState);
    OledPtr->modOledCur = mod;

    switch(mod) {
        case    modOledSet:
            OledPtr->pfnDoRop = GrphRopSet;
            break;

        case    modOledOr:
            OledPtr->pfnDoRop = GrphRopOr;
            break;

        case    modOledAnd:
            OledPtr->pfnDoRop = GrphRopAnd;
            break;

        case    modOledXor:
            OledPtr->pfnDoRop = GrphRopXor;
            break;

        default:
            OledPtr->modOledCur = modOledSet;
            OledPtr->pfnDoRop = GrphRopSet;
    }
}

/* ------------------------------------------------------------ */
/***    OLED_GetDrawMode
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**
**  Return Value:
**      returns current drawing mode
**
**  Errors:
**      none
**
**  Description:
**      Get the current drawing mode
*/
int OLED_GetDrawMode(PmodOLED *InstancePtr)
{
    return InstancePtr->OLEDState.modOledCur;
}

/* ------------------------------------------------------------ */
/***    OLED_DrawPixel
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Set the pixel at the current drawing location to the
**      specified value.
*/
void OLED_DrawPixel(PmodOLED *InstancePtr)
{
    OLED   *OledPtr = &(InstancePtr->OLEDState);
    uint8_t bPix    = OledPtr->clrOledCur << OledPtr->bnOledCur;
    uint8_t bDsp    = *(OledPtr->pbOledCur);
    uint8_t mskPix  = 1 << OledPtr->bnOledCur;

    *(OledPtr->pbOledCur) = (*(OledPtr->pfnDoRop))(bPix, bDsp, mskPix);
}

/* ------------------------------------------------------------ */
/***    OLED_GetPixel
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**
**  Return Value:
**      returns pixel value at current drawing location
**
**  Errors:
**      none
**
**  Description:
**      Return the value of the pixel at the current drawing location
*/
u8 OLED_GetPixel(PmodOLED *InstancePtr)
{
    uint8_t bOledCur = *(InstancePtr->OLEDState.pbOledCur);
    uint8_t mask = (1 << InstancePtr->OLEDState.bnOledCur);
    return (bOledCur & mask) != 0 ? 1 : 0;
}

/* ------------------------------------------------------------ */
/***    OLED_LineTo
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      xco         - x coordinate
**      yco         - y coordinate
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Draw a line from the current position to the specified
**      position.
*/

void OLED_LineTo(PmodOLED *InstancePtr, int xco, int yco)
{
    int    err;
    int    del;
    int    lim;
    int    cpx;
    int    dxco;
    int    dyco;
    void (*pfnMajor)();
    void (*pfnMinor)();
    OLED  *OledPtr = &(InstancePtr->OLEDState);

    /* Clamp the point to be on the display.
    */
    xco = GrphClampXco(xco);
    yco = GrphClampYco(yco);

    /* Determine which octant the line occupies
    */
    dxco = xco - OledPtr->xcoOledCur;
    dyco = yco - OledPtr->ycoOledCur;
    if (GrphAbs(dxco) >= GrphAbs(dyco)) {
        /* Line is x-major
        */
        lim = GrphAbs(dxco);
        del = GrphAbs(dyco);
        if (dxco >= 0) {
            pfnMajor = GrphMoveRight;
        }
        else {
            pfnMajor = GrphMoveLeft;
        }

        if (dyco >= 0) {
            pfnMinor = GrphMoveDown;
        }
        else {
            pfnMinor = GrphMoveUp;
        }
    }
    else {
        /* Line is y-major
        */
        lim = GrphAbs(dyco);
        del = GrphAbs(dxco);
        if (dyco >= 0) {
            pfnMajor = GrphMoveDown;
        }
        else {
            pfnMajor = GrphMoveUp;
        }

        if (dxco >= 0) {
            pfnMinor = GrphMoveRight;
        }
        else {
            pfnMinor = GrphMoveLeft;
        }
    }

    /* Render the line. The algorithm is:
    **      Write the current pixel
    **      Move one pixel on the major axis
    **      Add the minor axis delta to the error accumulator
    **      if the error accumulator is greater than the major axis delta
    **          Move one pixel in the minor axis
    **          Subtract major axis delta from error accumulator
    */
    err = lim/2;
    cpx = lim;
    while (cpx > 0) {
        OLED_DrawPixel(InstancePtr);
        (*pfnMajor)();
        err += del;
        if (err > lim) {
            err -= lim;
            (*pfnMinor)();
        }
        cpx -= 1;
    }

    /* Update the current location variables.
    */
    OledPtr->xcoOledCur = xco;
    OledPtr->ycoOledCur = yco;
}

/* ------------------------------------------------------------ */
/***    OLED_DrawRect
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      xco     - x coordinate of other corner
**      yco     - y coordinate of other corner
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Draw a rectangle bounded by the current location and
**      the specified location.
*/

void OLED_DrawRect(PmodOLED *InstancePtr, int xco, int yco)
{
    OLED *OledPtr = &(InstancePtr->OLEDState);
    int     xco1;
    int     yco1;

    /* Clamp the point to be on the display.
    */
    xco = GrphClampXco(xco);
    yco = GrphClampYco(yco);

    xco1 = OledPtr->xcoOledCur;
    yco1 = OledPtr->ycoOledCur;
    OLED_LineTo(InstancePtr, xco, yco1);
    OLED_LineTo(InstancePtr, xco, yco);
    OLED_LineTo(InstancePtr, xco1, yco);
    OLED_LineTo(InstancePtr, xco1, yco1);
}

/* ------------------------------------------------------------ */
/***    OledFillRect
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      xco     - x coordinate of other corner
**      yco     - y coordinate of other corner
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Fill a rectangle bounded by the current location and
**      the specified location.
*/

void OLED_FillRect(PmodOLED *InstancePtr, int xco, int yco)
{
    int xcoLeft;
    int xcoRight;
    int ycoTop;
    int ycoBottom;
    int ibPat;
    u8 *pbCur;
    u8 *pbLeft;
    int xcoCur;
    u8  bTmp;
    u8  mskPat;
    OLED *OledPtr = &(InstancePtr->OLEDState);

    /* Clamp the point to be on the display.
    */
    xco = GrphClampXco(xco);
    yco = GrphClampYco(yco);

    /* Set up the four sides of the rectangle.
    */
    if (OledPtr->xcoOledCur < xco) {
        xcoLeft = OledPtr->xcoOledCur;
        xcoRight = xco;
    }
    else {
        xcoLeft = xco;
        xcoRight = OledPtr->xcoOledCur;
    }

    if (OledPtr->ycoOledCur < yco) {
        ycoTop = OledPtr->ycoOledCur;
        ycoBottom = yco;
    }
    else {
        ycoTop = yco;
        ycoBottom = OledPtr->ycoOledCur;
    }

    while (ycoTop <= ycoBottom) {
        /* Compute the address of the left edge of the rectangle for this
        ** stripe across the rectangle.
        */
        pbLeft = &(OledPtr->rgbOledBmp)[((ycoTop/8) * ccolOledMax) + xcoLeft];

        /* Generate a mask to preserve any low bits in the byte that aren't
        ** part of the rectangle being filled.
        */
        mskPat = (1 << (ycoTop & 0x07)) - 1;

        /* Combine with a mask to preserve any upper bits in the byte that aren't
        ** part of the rectangle being filled.
        ** This mask will end up not preserving any bits for bytes that are in
        ** the middle of the rectangle vertically.
        */
        if ((ycoTop / 8) == (ycoBottom / 8)) {
            mskPat |= ~((1 << ((ycoBottom&0x07)+1)) - 1);
        }                                           
        ibPat = xcoLeft & 0x07;     //index to first pattern byte
        xcoCur = xcoLeft;
        pbCur = pbLeft;

        /* Loop through all of the bytes horizontally making up this stripe
        ** of the rectangle.
        */
        while (xcoCur <= xcoRight) {
            *pbCur = (*(OledPtr->pfnDoRop))(*(OledPtr->pbOledPatCur+ibPat), *pbCur, ~mskPat);
            xcoCur += 1;
            pbCur += 1;
            ibPat += 1;
            if (ibPat > 7) {
                ibPat = 0;
            }
        }
        /* Advance to the next horizontal stripe.
        */
        ycoTop = 8*((ycoTop/8)+1);
    }
}

/* ------------------------------------------------------------ */
/***    OLED_GetBmp
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      dxco        - width of bitmap
**      dyco        - height of bitmap
**      pbBits      - pointer to the bitmap bits    
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      This routine will get the bits corresponding to the
**      rectangle implied by the current location and the
**      specified width and height. The buffer specified
**      by pbBits must be large enough to hold the resulting
**      bytes.
*/

void OLED_GetBmp(PmodOLED *InstancePtr, int dxco, int dyco, u8 * pbBits)
    {
    int   xcoLeft;
    int   xcoRight;
    int   ycoTop;
    int   ycoBottom;
    u8   *pbDspCur;
    u8   *pbDspLeft;
    u8   *pbBmpCur;
    u8   *pbBmpLeft;
    int   xcoCur;
    int   bnAlign;
    u8    mskEnd;
    u8    bTmp;
    OLED *OledPtr = &(InstancePtr->OLEDState);
    /* Set up the four sides of the source rectangle.
    */
    xcoLeft = OledPtr->xcoOledCur;
    xcoRight = xcoLeft + dxco;
    if (xcoRight >= ccolOledMax) {
        xcoRight = ccolOledMax - 1;
    }

    ycoTop = OledPtr->ycoOledCur;
    ycoBottom = ycoTop + dyco;
    if (ycoBottom >= crowOledMax) {
        ycoBottom = crowOledMax - 1;
    }

    bnAlign = ycoTop & 0x07;
    pbDspLeft = &(OledPtr->rgbOledBmp)[((ycoTop/8) * ccolOledMax) + xcoLeft];
    pbBmpLeft = pbBits;

    while (ycoTop < ycoBottom) {
        if ((ycoTop / 8) == ((ycoBottom-1) / 8)) {
            mskEnd = ((1 << (((ycoBottom-1)&0x07)+1)) - 1);
        }
        else {
            mskEnd = 0xFF;
        }
                                            
        xcoCur = xcoLeft;
        pbDspCur = pbDspLeft;
        pbBmpCur = pbBmpLeft;

        /* Loop through all of the bytes horizontally making up this stripe
        ** of the rectangle.
        */
        if (bnAlign == 0) {
            while (xcoCur < xcoRight) {
                *pbBmpCur = (*pbDspCur) & mskEnd;
                xcoCur += 1;
                pbBmpCur += 1;
                pbDspCur += 1;
            }
        }
        else {
            while (xcoCur < xcoRight) {
                bTmp = *pbDspCur;
                bTmp = *(pbDspCur+ccolOledMax);
                *pbBmpCur = ((*pbDspCur >> bnAlign) |
                            ((*(pbDspCur+ccolOledMax)) << (8-bnAlign))) & mskEnd;
                xcoCur += 1;
                pbBmpCur += 1;
                pbDspCur += 1;
            }
        }

        /* Advance to the next horizontal stripe.
        */
        ycoTop += 8;
        pbDspLeft += ccolOledMax;
        pbBmpLeft += dxco;
    }
}

/* ------------------------------------------------------------ */
/***    OLED_PutBmp
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      dxco        - width of bitmap
**      dyco        - height of bitmap
**      pbBits      - pointer to the bitmap bits    
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      This routine will put the specified bitmap into the display
**      buffer at the current location.
*/

void OLED_PutBmp(PmodOLED *InstancePtr, int dxco, int dyco, u8 * pbBits)
    {
    int   xcoLeft;
    int   xcoRight;
    int   ycoTop;
    int   ycoBottom;
    u8   *pbDspCur;
    u8   *pbDspLeft;
    u8   *pbBmpCur;
    u8   *pbBmpLeft;
    int   xcoCur;
    u8    bDsp;
    u8    bBmp;
    u8    mskEnd;
    u8    mskUpper;
    u8    mskLower;
    int   bnAlign;
    int   fTop;
    u8    bTmp;
    OLED *OledPtr = &(InstancePtr->OLEDState);
    /* Set up the four sides of the destination rectangle.
    */
    xcoLeft = OledPtr->xcoOledCur;
    xcoRight = xcoLeft + dxco;
    if (xcoRight >= ccolOledMax) {
        xcoRight = ccolOledMax - 1;
    }

    ycoTop = OledPtr->ycoOledCur;
    ycoBottom = ycoTop + dyco;
    if (ycoBottom >= crowOledMax) {
        ycoBottom = crowOledMax - 1;
    }

    bnAlign = ycoTop & 0x07;
    mskUpper = (1 << bnAlign) - 1;
    mskLower = ~mskUpper;
    pbDspLeft = &(OledPtr->rgbOledBmp)[((ycoTop/8) * ccolOledMax) + xcoLeft];
    pbBmpLeft = pbBits;
    fTop = 1;

    while (ycoTop < ycoBottom) {
        /* Combine with a mask to preserve any upper bits in the byte that aren't
        ** part of the rectangle being filled.s
        ** This mask will end up not preserving any bits for bytes that are in
        ** the middle of the rectangle vertically.
        */
        if ((ycoTop / 8) == ((ycoBottom-1) / 8)) {
            mskEnd = ((1 << (((ycoBottom-1)&0x07)+1)) - 1);
        }
        else {
            mskEnd = 0xFF;
        }
        if (fTop) {
            mskEnd &= ~mskUpper;
        }
                                            
        xcoCur = xcoLeft;
        pbDspCur = pbDspLeft;
        pbBmpCur = pbBmpLeft;

        /* Loop through all of the bytes horizontally making up this stripe
        ** of the rectangle.
        */
        if (bnAlign == 0) {
            while (xcoCur < xcoRight) {
                *pbDspCur = (*(OledPtr->pfnDoRop))(*pbBmpCur, *pbDspCur, mskEnd);
                xcoCur += 1;
                pbDspCur += 1;
                pbBmpCur += 1;
            }
        }
        else {
            while (xcoCur < xcoRight) {
                bBmp = ((*pbBmpCur) << bnAlign);
                if (!fTop) {
                    bBmp |= ((*(pbBmpCur - dxco) >> (8-bnAlign)) & ~mskLower);
                }
                bBmp &= mskEnd;
                *pbDspCur = (*(OledPtr->pfnDoRop))(bBmp, *pbDspCur, mskEnd);
                xcoCur += 1;
                pbDspCur += 1;
                pbBmpCur += 1;
            }
        }

        /* Advance to the next horizontal stripe.
        */
        ycoTop = 8*((ycoTop/8)+1);
        pbDspLeft += ccolOledMax;
        pbBmpLeft += dxco;
        fTop = 0;
    }
}

/* ------------------------------------------------------------ */
/***    OLED_DrawChar
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      ch          - character to write to display
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Write the specified character to the display at the current
**      cursor position and advance the cursor.
*/

void OLED_DrawChar(PmodOLED *InstancePtr, char ch)
{
    u8   *pbFont;
    u8   *pbBmp;
    int   ib;
    OLED *OledPtr = &(InstancePtr->OLEDState);

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

    OLED_PutBmp(InstancePtr, OledPtr->dxcoOledFontCur, OledPtr->dycoOledFontCur, pbFont);

    OledPtr->xcoOledCur += OledPtr->dxcoOledFontCur;

}

/* ------------------------------------------------------------ */
/***    OLED_DrawString
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**      sz          - pointer to the null terminated string
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Write the specified null terminated character string to the
**      display and advance the cursor.
*/

void OLED_DrawString(PmodOLED *InstancePtr, char * sz)
{
    while (*sz != '\0') {
        OLED_DrawChar(InstancePtr, *sz);
        sz += 1;
    }
}

/* ------------------------------------------------------------ */
/*              Internal Support Routines                       */
/* ------------------------------------------------------------ */
/***    GrphRopSet
**
**  Parameters:
**
**  Return Value:
**
**  Errors:
**
**  Description:
**
*/

u8 GrphRopSet(u8 bPix, u8 bDsp, u8 mskPix)
{
    return (bDsp & ~mskPix) | (bPix & mskPix);
}

/* ------------------------------------------------------------ */
/***    GrphRopOr
**
**  Parameters:
**
**  Return Value:
**
**  Errors:
**
**  Description:
**
*/

u8 GrphRopOr(u8 bPix, u8 bDsp, u8 mskPix)
{
    return bDsp | (bPix & mskPix);
}

/* ------------------------------------------------------------ */
/***    GrphRopAnd
**
**  Parameters:
**
**  Return Value:
**
**  Errors:
**
**  Description:
**
*/

u8 GrphRopAnd(u8 bPix, u8 bDsp, u8 mskPix)
{
    return bDsp & (bPix & mskPix);
}

/* ------------------------------------------------------------ */
/***    GrphRopXor
**
**  Parameters:
**
**  Return Value:
**
**  Errors:
**
**  Description:
**
*/

u8 GrphRopXor(u8 bPix, u8 bDsp, u8 mskPix)
{
    return bDsp ^ (bPix & mskPix);
}

/* ------------------------------------------------------------ */
/***    GrphMoveUp
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Updates global variables related to current position on the
**      display.
*/

void GrphMoveUp(PmodOLED *InstancePtr)
{
    OLED *OledPtr = &(InstancePtr->OLEDState);

    /* Go up one bit position in the current byte.
    */
    OledPtr->bnOledCur -= 1;

    /* If we have gone off the end of the current byte
    ** go up 1 page.
    */
    if (OledPtr->bnOledCur < 0) {
        OledPtr->bnOledCur = 7;
        OledPtr->pbOledCur -= ccolOledMax;
        /* If we have gone off of the top of the display,
        ** go back down.
        */
        if (OledPtr->pbOledCur < OledPtr->rgbOledBmp) {
            OledPtr->pbOledCur += ccolOledMax;
        }
    }
}

/* ------------------------------------------------------------ */
/***    GrphMoveDown
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Updates global variables related to current position on the
**      display.
*/

void GrphMoveDown(PmodOLED *InstancePtr)
{
    OLED *OledPtr = &(InstancePtr->OLEDState);
    /* Go down one bit position in the current byte.
    */
    OledPtr->bnOledCur += 1;

    /* If we have gone off the end of the current byte,
    ** go down one page in the display memory.
    */
    if (OledPtr->bnOledCur > 7) {
        OledPtr->bnOledCur = 0;
        OledPtr->pbOledCur += ccolOledMax;
        /* If we have gone off the end of the display memory
        ** go back up a page.
        */
        if (OledPtr->pbOledCur >= OledPtr->rgbOledBmp + cbOledDispMax) {
            OledPtr->pbOledCur -= ccolOledMax;
        }
    }
}

/* ------------------------------------------------------------ */
/***    GrphMoveLeft
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Updates global variables related to current position on the
**      display.
*/

void GrphMoveLeft(PmodOLED *InstancePtr)
{
    OLED *OledPtr = &(InstancePtr->OLEDState);
    /* Are we at the left edge of the display already
    */
    if (((OledPtr->pbOledCur - OledPtr->rgbOledBmp) & (ccolOledMax-1)) == 0) {
        return;
    }

    /* Not at the left edge, so go back one byte.
    */
    OledPtr->pbOledCur -= 1;
}

/* ------------------------------------------------------------ */
/***    GrphMoveRight
**
**  Parameters:
**      InstancePtr - pointer to SPI handler and OLED data
**
**  Return Value:
**      none
**
**  Errors:
**      none
**
**  Description:
**      Updates global variables related to current position on the
**      display.
*/

void GrphMoveRight(PmodOLED *InstancePtr)
{
    OLED *OledPtr = &(InstancePtr->OLEDState);
    /* Are we at the right edge of the display already
    */
    if (((OledPtr->pbOledCur - OledPtr->rgbOledBmp) & (ccolOledMax-1)) == (ccolOledMax-1)) {
        return;
    }

    /* Not at the right edge, so go forward one byte
    */
    OledPtr->pbOledCur += 1;
}

/* ------------------------------------------------------------ */
/***    GrphClampXco
**
**  Parameters:
**      xco     - x value to clamp
**
**  Return Value:
**      Returns clamped x value
**
**  Errors:
**      none
**
**  Description:
**      This routine forces the x value to be on the display.
*/

int GrphClampXco(int xco)
{
    if (xco < 0) {
        xco = 0;
    }
    if (xco >= ccolOledMax) {
        xco = ccolOledMax-1;
    }

    return xco;

}

/* ------------------------------------------------------------ */
/***    GrphClampYco
**
**  Parameters:
**      yco     - y value to clamp
**
**  Return Value:
**      Returns clamped y value
**
**  Errors:
**      none
**
**  Description:
**      This routine forces the y value to be on the display.
*/

int GrphClampYco(int yco)
{
    if (yco < 0) {
        yco = 0;
    }
    if (yco >= crowOledMax) {
        yco = crowOledMax-1;
    }

    return yco;
}

/* ------------------------------------------------------------ */

/************************************************************************/

