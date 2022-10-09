/************************************************************************/
/*																		*/
/*	MtdsDefs.h	--	Declarations for Interface Types and Symbols		*/
/*																		*/
/************************************************************************/
/*	Author:		Gene Apperson											*/
/*	Copyright 2015, Digilent Inc. All rights reserved.					*/
/************************************************************************/
/*  File Description:													*/
/*																		*/
/*	This header file contains the definitions for the various symbols	*/
/*	and data types used in the Multi-Touch Display Shield system. These	*/
/*	values are used by the MTDS library that runs on the host system	*/
/*	board and are used by the firmware running on the shield.			*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	2015-10-05(GeneA): Created											*/
/*																		*/
/************************************************************************/

#if !defined(_MTDSDEFS_H_)
#define	_MTDSDEFS_H_

#include <stdint.h>

/* ------------------------------------------------------------ */
/*					Configuration Values						*/
/* ------------------------------------------------------------ */

/* Symbols defining size limits.
*/
#define	cchNameMax			250		// maximum length of a file name in file system
#define	cchTitleMax			32		// maximum length of window title
#define	cchWindowStringMax	128		// maximum length of window string

/* ------------------------------------------------------------ */
/*				Miscellaneous API Declarations					*/
/* ------------------------------------------------------------ */

/* Standard color values.
*/
#define	clrBlack		0x00000000ul
#define	clrDkGray		0x00606060ul
#define	clrMedGray		0x00808080ul
#define	clrLtGray		0x00C0C0C0ul
#define	clrWhite		0x00FFFFFFul
#define	clrRed			0x00FF0000ul
#define	clrDkRed		0x00800000ul
#define	clrGreen		0x0000FF00ul
#define	clrDkGreen		0x00008000ul
#define	clrBlue			0x000000FFul
#define	clrDkBlue		0x00000080ul
#define	clrYellow		0x00FFFF00ul
#define	clrDkYellow		0x00808000ul
#define	clrCyan			0x0000FFFFul
#define	clrDkCyan		0x00008080ul
#define	clrMagenta		0x00FF00FFul
#define	clrDkMagenta	0x00800080ul
#define	clrLtBlueGray	0x00B8B8FFul
#define	clrMedBlueGray	0x007878FFul

#define COLOR(r,g,b)	(uint32_t)( (((r) & 0xFF) << 16) | (((g) & 0xFF) << 8) | ((b) & 0xFF) )
#define	GetRed(clr)		(((clr) >> 16) & 0x000000FF)
#define	GetGreen(clr)	(((clr) >> 8)  & 0x000000FF)
#define	GetBlue(clr)	((clr) & 0x000000FF)

/* Standard pen values
*/
#define	penNull			0x0000
#define	penSolid		0xFFFF
#define	penDash			0xC3C3
#define	penDot			0x9999
#define	penDashDot		0xF18F
#define	penDashDotDash	0xE667
#define	penDashDotDot	0xC663

/* Handles for stock brushes.
*/
#define	hbrNull			(sigHbr + sigHbrStock + 0)
#define	hbrWhite		(sigHbr + sigHbrStock + 1)
#define	hbrLtGray		(sigHbr + sigHbrStock + 2)
#define	hbrMedGray		(sigHbr + sigHbrStock + 3)
#define	hbrDkGray		(sigHbr + sigHbrStock + 4)
#define	hbrBlack		(sigHbr + sigHbrStock + 5)
#define	hbrRed			(sigHbr + sigHbrStock + 6)
#define	hbrGreen		(sigHbr + sigHbrStock + 7)
#define	hbrBlue			(sigHbr + sigHbrStock + 8)
#define	hbrLtBlueGray	(sigHbr + sigHbrStock + 9)
#define	hbrMedBlueGray	(sigHbr + sigHbrStock + 10)

/* Hatch styles for hatch brushes
*/
#define	idpsHorizontal	0		// horizontal lines
#define	idpsVertical	1		// vertical lines
#define	idpsFwDiagonal	2		// diagnoal lines down and right
#define	idpsBkDiagonal	3		// diagonal lines up and left
#define	idpsCross		4		// cross pattern of horizonal and vertical
#define	idpsDiagCross	5		// cross pattern of Fw and Bk diagonal
#define	idpsChecker		6
#define	idpsBlock		7
#define	idpsHalfTone	8

#define	idpsMic			0
#define	idpsMac			8

/* Stock fonts.
*/
#define hfntConsole		(sigHfnt + sigHfntStock + 0)
#define	hfntXSmall		(sigHfnt + sigHfntStock + 1)
#define	hfntSmall		(sigHfnt + sigHfntStock + 2)
#define	hfntMedium		(sigHfnt + sigHfntStock + 3)
#define	hfntLarge		(sigHfnt + sigHfntStock + 4)
#define	hfntXLarge		(sigHfnt + sigHfntStock + 5)

/* Raster operations for use with BitBlt and PatBlt
*/
#define	opnRopPat				0x8000
#define	opnRopDst				0x4000
#define	opnRopSrc				0x2000
#define	mskRopId				0x00FF

#define	ropBlack				(0)							// 0
#define	ropWhite				(1)							// 1
#define	ropSrc					(2  + opnRopSrc)			// S
#define	ropSrcNot				(3  + opnRopSrc)			// ~S
#define	ropDst					(4  + opnRopDst)			// D
#define	ropDstNot				(5  + opnRopDst)			// ~D
#define	ropSrcDstAnd			(6  + opnRopSrc+opnRopDst)	// S & D
#define	ropSrcDstOr				(7  + opnRopSrc+opnRopDst)	// S | D
#define	ropSrcDstXor			(8  + opnRopSrc+opnRopDst)	// S ^ D
#define	ropSrcDstAndNot			(9  + opnRopSrc+opnRopDst)	// ~(S & D)
#define	ropSrcDstOrNot			(10 + opnRopSrc+opnRopDst)	// ~(S | D)
#define	ropSrcDstXorNot			(11 + opnRopSrc+opnRopDst)	// ~(S ^ D)
#define	ropSrcDstNotAnd			(12 + opnRopSrc+opnRopDst)	// S & ~D
#define	ropSrcNotDstAnd			(13 + opnRopSrc+opnRopDst)	// ~S & D
#define	ropSrcDstNotOr			(14 + opnRopSrc+opnRopDst)	// S | ~D
#define	ropSrcNotDstOr			(15 + opnRopSrc+opnRopDst)	// ~S | D
#define	ropPat					(16 + opnRopPat)			// P
#define	ropPatNot				(17 + opnRopPat)			// ~P
#define	ropPatDstAnd			(18 + opnRopDst+opnRopPat)	// P & D
#define	ropPatDstOr				(19 + opnRopDst+opnRopPat)	// P | D
#define	ropPatDstXor			(20 + opnRopDst+opnRopPat)	// P ^ D
#define	ropPatDstAndNot			(21 + opnRopDst+opnRopPat)	// ~(P & D)
#define	ropPatDstOrNot			(22 + opnRopDst+opnRopPat)	// ~(P | D)
#define	ropPatDstXorNot			(23 + opnRopDst+opnRopPat)	// ~(P ^ D)
#define	ropPatNotDstAnd			(24 + opnRopDst+opnRopPat)	// ~P & D
#define	ropPatDstNotAnd			(25 + opnRopDst+opnRopPat)	// P & ~D
#define	ropPatNotDstOr			(26 + opnRopDst+opnRopPat)	// ~P | D
#define	ropPatDstNotOr			(27 + opnRopDst+opnRopPat)	// P | ~D
#define	ropPatSrcAnd			(28 + opnRopSrc+opnRopPat)	// P & S
#define	ropPatSrcOr				(29 + opnRopSrc+opnRopPat)	// P | S
#define	ropPatSrcXor			(30 + opnRopSrc+opnRopPat)	// P ^ S
#define	ropPatSrcNotOrDstOr		(31 + opnRopSrc+opnRopDst+opnRopPat)	// (P | ~S) | D

#if defined(DEAD)
#define	ropDstClrForeground		32		// F
#define	ropDstClrBackground		33		// B
#define	ropSrcAdd				34		// S + D
#define	ropSrcAddSat			35		// CEIL(S+D, max value for color component)
#define	ropSrcSub				36		// S - D
#define	ropSrcSubSat			37		// FLOOR(S-D, 0)
#endif

#define	ropMac	31

#define ropNotSrcErase			ropSrcDstOrNot
#define	ropNotSrcCopy			ropSrcNot
#define	ropSrcErase				ropSrcDstNotAnd
#define	ropDstInvert			ropDstNot
#define	ropPatInvert			ropPatDstXor
#define	ropSrcInvert			ropSrcDstXor
#define	ropSrcAnd				ropSrcDstAnd
#define	ropMergePaint			ropSrcNotDstOr
#define	ropMergeCopy			ropPatSrcAnd
#define	ropSrcCopy				ropSrc
#define	ropSrcPaint				ropSrcDstOr
#define	ropPatCopy				ropPat
#define	ropPatPaint				ropPatSrcNotOrDstOr

#define	ropSrcXor				ropSrcDstXor
#define	ropSrcNand				ropSrcDstAndNot
#define	ropSrcNor				ropSrcDstOrNot
#define	ropSrcXnor				ropSrcDstXorNot

/* Drawing mode raster operations for use with line and text drawing.
*/
#define	drwBlack				0		// 0
#define	drwPenDstOrNot			1		// ~(P | D)
#define	drwPenNotDstAnd			2		// ~P & D
#define	drwPenNot				3		// ~P
#define	drwPenDstNotAnd			4		// P & ~D
#define	drwDstNot				5		// ~D
#define	drwPenDstXor			6		// P ^ D
#define	drwPenDstAndNot			7		// ~(P & D)
#define	drwPenDstAnd			8		// P & D
#define	drwPenDstXorNot			9		// ~(P ^ D)
#define	drwDst					10		// D
#define	drwPenNotDstOr			11		// ~P | D
#define	drwPen					12		// P
#define	drwPenDstNotOr			13		// P | ~D
#define	drwPenDstOr				14		// P | D
#define	drwWhite				15		// 1

/* Synonyms for the above drwing mode raster operations. These are the names
** used in Microsoft Windows.
*/
#define	drwNotOrPen				drwPenDstOrNot		// ~(P | D)
#define	drwAndNotPen			drwPenNotDstAnd		// ~P & D
#define	drwCopyNotPen			drwPenNot			// ~P
#define	drwAndPenNot			drwPenDstNotAnd		// P & ~D
#define	drwNot					drwDstNot			// ~D
#define	drwXorPen				drwPenDstXor		// P ^ D
#define	drwNotAndPen			drwPenDstAndNot		// ~(P & D)
#define	drwAndPen				drwPenDstAnd		// P & D
#define	drwNotXorPen			drwPenDstXorNot		// ~(P ^ D)
#define	drwNop					drwDst				// D
#define	drwOrNotPen				drwPenNotDstOr		// ~P | D
#define	drwCopyPen				drwPen				// P
#define	drwOrPenNot				drwPenDstNotOr		// P | ~D
#define	drwOrPen				drwPenDstOr			// P | D

/* Background drawing mode for line and text drawing.
*/
#define	bkOpaque		1
#define	bkTransparent	2

/* Font spacing types.
*/
#define	spfMono			0		// mono-spaced font
#define	spfProp			1		// proportional spaced font

/* Display orientation.
*/
#define	dsoPortrait		1		// display is in portrait orientation
#define	dsoLandscape	2		// display is in landscape orientation

/* Display backlight brightness control mode
*/
#define	dbmPwm			1		// PWM mode for backlight brightness control
#define	dbmDbc			2		// digital brightness control for backlight brightness

/* Message system symbol declarations.
*/
#define	msgUserFirst		0x8000

/* Messages for touch events.
*/
#define	msgFingerFirst		0x0010
#define	msgFinger1Down		0x0010		// finger began touching the touch panel
#define	msgFinger1Move		0x0011
#define	msgFinger1Up		0x0012
#define	msgFinger2Down		0x0013
#define	msgFinger2Move		0x0014
#define	msgFinger2Up		0x0015
#define	msgFinger3Down		0x0016
#define	msgFinger3Move		0x0017
#define	msgFinger3Up		0x0018
#define	msgFinger4Down		0x0019
#define	msgFinger4Move		0x001A
#define	msgFinger4Up		0x001B
#define	msgFinger5Down		0x001C
#define	msgFinger5Move		0x001D
#define	msgFinger5Up		0x001E
#define	msgFingerLast		0x001E

/* Event types for timer events
*/
#define	msgTimerFirst		0x0001
#define	msgTimerElapsed		0x0001			// specified time has elapsed
#define	msgTimerLast		0x000F

/* Windowing System Symbols
*/
/* Window and control classes.
*/
#define	wclsUser			0
#define	wclsPushButton		0x8001
#define	wclsCheckBox		0x8002
#define	wclsRadioButton		0x8003
#define	wclsScrollBar		0x8004
#define	wclsSlider			0x8005
#define	wclsTextStatic		0x8006
#define	wclsTextBox			0x8007
#define	wclsTextEdit		0x8008
#define	wclsList			0x8009
#define	wclsMenuBar			0x800A
#define	wclsDesktop			0x8FFF

/* Window style definitions.
** The upper 16 bits are for generic window styles. The lower 16 bits are for control
** specific styles for control windows.
*/
#define	wstlEnabled			0x80000000
#define	wstlGroup			0x40000000		// beginning of a window group
#define	wstlVisible			0x20000000		// window is visible
#define	wstlChild			0x08000000
#define	wstlClipChildren	0x04000000
#define	wstlClibSiblings	0x02000000
#define	wstlTitleBar		0x00800000		// window has a title bar
#define	wstlMenuBar			0x00400000		// window has a menu bar
#define	wstlSysMenu			0x00200000		// window has a system menu in the title bar
#define	wstlCloseBox		0x00100000		// window has a close box in the title bar
#define	wstlThickBorder		0x00020000
#define	wstlThinBorder		0x00010000

/* Move window options.
*/
#define	wmvSetPosition		0x0001
#define	wmvSetSize			0x0002
#define	wmvCopyBits			0x0004

#define	idwinInvalid		0xFFFFFFFF

/* Symbols related to hardware features.
*/
#define	idPinStatusA		1				// hardware status pin A
#define	idPinStatusB		2				// hardware status pin B

/* ------------------------------------------------------------ */
/*				Data Type Declarations							*/
/* ------------------------------------------------------------ */

/* Declarations for handle types used by the system.
*/
typedef uint32_t HMEM;			// handle to a memory object in shield memory
typedef uint32_t HDIR;			// handle to an open directory on disk
typedef uint32_t HFIL;			// handle to an open file on disk
typedef uint32_t HDS;			// handle for a display state object
typedef uint32_t HBMP;			// handle to a bitmap object
typedef uint32_t HBR;			// handle to a brush object
typedef uint32_t HFNT;			// handle to a font object
typedef uint32_t HWIN;			// handle to a window object

/* Declarations for GDI graphics data structures.
*/
typedef uint32_t CLR;

struct PNT {
	int16_t		xco;
	int16_t		yco;
};

struct LINE {
	int16_t		xcoStart;
	int16_t		ycoStart;
	int16_t		xcoEnd;
	int16_t		ycoEnd;
};

struct RCT {
	int16_t		xcoLeft;
	int16_t		ycoTop;
	int16_t		xcoRight;
	int16_t		ycoBottom;
};

struct BMPD {
	int16_t		dxco;			// bitmap width in pixels
	int16_t		dyco;			// bitmap height in pixels
	int16_t		cbpp;			// number of bits per pixel
};

#pragma pack(push, 1)
struct DTM {
	uint16_t		sec;			// time in seconds
	uint16_t		min;			// time in minutes
	uint16_t		hour;			// time in hours
	uint16_t		day;			// day of month
	uint16_t		month;			// month
	uint16_t		year;			// year
};
#pragma pack(pop)

/* Declarations for event system data structures.
*/
/* Generic event structure.
*/
#pragma pack(push, 1)
struct MEVT {
	uint32_t	tms;			// time stamp of the event
	HWIN		hwin;			// window handle for message recipient
	uint16_t	msg;			// message id
	uint16_t	val1;
	uint32_t	val2;
};
#pragma pack(pop)

/* Touch event structure.
*/
#pragma pack(push, 1)
struct MTCH {
	uint32_t	tms;			// time stamp of the event
	HWIN		hwin;			// window handle for message recipient
	uint16_t	msg;			// message id
	int16_t		xco;
	int16_t		yco;
    uint8_t     wgt;
    uint8_t     spd;
};
#pragma pack(pop)

/* File Info Structure
*/
#pragma pack(push, 1)
struct FINF {
	uint32_t	cbFile;			// file size
	uint16_t	date;			// last modification date
	uint16_t	time;			// last modification time
	uint8_t		attrib;			// file attributes
	uint8_t		rgchName[13];	// file name in 8.3 format
	char		szName[cchNameMax+1];	// long file name
};
#pragma pack(pop)

/* File access modes
*/
#define	mdMtdsRead			0x01
#define	mdMtdsWrite			0x02
#define	mdMtdsOpenExisting	0x00
#define	mdMtdsOpenAlways	0x10
#define	mdMtdsCreateNew		0x04
#define	mdMtdsCreateAlways	0x08

/* File attributes
*/
#define	atMtdsReadOnly		0x01	// file is read only
#define	atMtdsHidden		0x02	// file is hidden
#define	atMtdsSystem		0x04	// file is a system file
#define	atMtdsVolume		0x08	// volume label
#define	atMtdsDirectory		0x10	// directory entry
#define	atMtdsArchive		0x20	// file has been modified

/* shield memory access declarations.
*/
#define	mmFindFirst			0x0000
#define	mmFindNext			0x0001
#define	mmCompactFull		0x0000
#define	mmCompactPartial	0x0002

struct MSTAT {
	uint32_t	mrStat;			// heap consistency check status
	uint32_t	chmemTotal;		// total number of memory handles available
	uint32_t	chmemAlloc;		// number of memory handles allocated
	uint32_t	chmemLock;		// number of locked memory handles
	uint32_t	cmblkTotal;		// total number of blocks in memory pool
	uint32_t	cbAlloc;		// number of bytes in allocated memory blocks
	uint32_t	cbFree;			// number of bytes in free memory blocks
};

#define	mrMtdsOk			0	// memory heap is internally consistent
#define	mrMtdsOverrun		1	// consistency check ran past end of the heap
#define	mrMtdsBacklink		2	// backpointer from memory block to handle broken
#define	mrMtdsOrphan		3	// there is an orphaned memory block with no owning handle
#define	mrMtdsCrosslink		4	// backpointer and handle pointer don't agree
#define	mrMtdsLock			5	// lock count and lock state inconsistent
#define	mrMtdsFreeLock		10	// a free block has its lock bit set
#define	mrMtdsFreeLink		11	// a free memory block has a backlink to a memory handle

/* ------------------------------------------------------------ */

#endif		// _MTDSDEFS_H

/************************************************************************/
