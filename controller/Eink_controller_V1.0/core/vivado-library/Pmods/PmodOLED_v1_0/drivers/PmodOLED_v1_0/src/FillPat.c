
/************************************************************************/
/*																		*/
/*	FillPat.c	--	Pattern Table for Area Fill							*/
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
/*	This module contains the data definitions for an set of8x8 pixel	*/
/*	patterns used for area fill.										*/
/*																		*/
/*	This pattern table is defined for a display where each byte 		*/
/*	represents 8 vertical pixels and consecutive bytes give adjacent	*/
/*	sets of 8 vertical pixels progressing to the right across the		*/
/*	display. This is rotated 90 degrees from the conventional video		*/
/*	display orientation.												*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	06/08/2011(GeneA): created											*/
/*																		*/
/************************************************************************/

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include <inttypes.h>

/* ------------------------------------------------------------ */
/*				Global Variables								*/
/* ------------------------------------------------------------ */

const uint8_t rgbFillPat[] = {
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	// 0x00
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,	// 0x01
	0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, // 0x02
	0x11, 0x44, 0x00, 0x11, 0x44, 0x00, 0x11, 0x44,	// 0x03
	0x92, 0x45, 0x24, 0x92, 0x45, 0x24, 0x92, 0x45,	// 0x04
	0x49, 0x92, 0x24, 0x49, 0x92, 0x24, 0x49, 0x92, // 0x05
	0x22, 0x11, 0x22, 0x00, 0x22, 0x11, 0x22, 0x00,	// 0x06
	0x11, 0x22, 0x11, 0x00, 0x11, 0x22, 0x11, 0x00	// 0x07
};

/* ------------------------------------------------------------ */

/************************************************************************/

