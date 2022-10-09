/********************************************************************************/
/*																				*/
/*	mtds.h	--	Digilent Multi-Touch Display Shield Library Declarations		*/
/*																				*/
/********************************************************************************/
/*	Author:		Gene Apperson													*/
/*	Copyright 2015, Digilent, Inc. All rights reserved.							*/
/********************************************************************************/
/*  File Description:															*/
/*																				*/
/*																				*/
/********************************************************************************/
/*  Revision History:															*/
/*																				*/
/*	2015/08/03(GeneApperson): Created											*/
/*																				*/
/********************************************************************************/

#if !defined(_MTDS_H_)
#define _MTDS_H_

#include	<stdint.h>
#include	"MtdsDefs.h"
#include	"MtdsHal.h"

/* ------------------------------------------------------------ */
/*					Miscellaneous Declarations					*/
/* ------------------------------------------------------------ */

/* Define types of object handles used by the system.
*/
#define	mskHandleSig		0xFF000000		// mask to extract handle signature

#define	sigHmem				0xA9000000		// signature for memory handle
#define sigHdir				0xB0000000		// signature for directory handle
#define sigHfile			0xB1000000		// signature for file handle
#define	sigHds				0xC0000000		// signature for DS handle
#define	sigHbmp				0xC1000000		// signature for bitmap handle
#define	sigHbr				0xC2000000		// signature for brush handle
#define	sigHfnt				0xC3000000		// signature for font handle
#define	sigHwin				0xC4000000		// signature for a window handle

#define	sigHbmpStock	0x00100000
#define	sigHbrStock		0x00200000
#define	sigHfntStock	0x00300000
#define	sigHwinStock	0x00400000

#define	hwinDesktop			(sigHwin + sigHwinStock + 0)

/* ------------------------------------------------------------ */
/*				Data Structure Declarations						*/
/* ------------------------------------------------------------ */

struct VINFO {
	uint16_t	verLibMajor;		// library major version number
	uint16_t	verLibMinor;		// library minor version number
	uint16_t	verFwMajor;			// display board firmware major version number
	uint16_t	verFwMinor;			// display board firmware minor version number
	uint16_t	typDisplay;			// display board type
	uint16_t	verDisplay;			// display board revision number
};

/* ------------------------------------------------------------ */
/*					Object Class Declarations					*/
/* ------------------------------------------------------------ */

class MTDS;
class MTFS;
class MTWS;
extern MTDS mtds;

class MTDS {
	friend class MTFS;
	friend class MTWS;

private:
	bool		fInitialized;
	uint8_t		clsLastError;
	uint8_t		cmdLastError;
	uint8_t		staLastError;
	uint32_t	tusElapsed;
	bool		fUpdating;

protected:

	bool	MtdsSyncChannel();
	void	MtdsProcessCmdWr(uint8_t cls, uint8_t cmd, uint16_t cbParam, uint8_t * pbParam, 
								uint16_t cbData, uint8_t * pbData);
	void	MtdsProcessCmdRd(uint8_t cls, uint8_t cmd, uint16_t cbParam, uint8_t * pbParam, 
								uint16_t cbData, uint8_t * pbData);
	bool	FCheckName(char * sz, uint8_t cls, uint8_t cmd);
	bool	FBeginUpdate();

public:
				MTDS();
			   ~MTDS();
	bool		begin();
	bool		begin(int pinSel, uint32_t frqSpi);
	void		end();

	/* General control and status functions.
	*/
	bool		FInitialized()			{ return fInitialized; };
	bool		FInitDisplay();
	bool		GetVersionInfo(VINFO * pvinfo);
	uint8_t		GetLastError()			{ return staLastError; };
	uint8_t		GetLastError(uint8_t * pcls, uint8_t * pcmd);
	uint32_t	GetElapsedTime()		{ return tusElapsed; };
	bool		EnableStatusPin(int idPin, int fEn);
	bool		GetStatusPin(int idPin);
	bool		SetStatusPin(int idPin, int st);
	bool		SetDisplayEnable(uint32_t st);
	uint32_t	GetDisplayEnable();
	bool		SetDisplayOrientation(uint32_t dso);
	uint32_t	GetDisplayOrientation();
	bool		SetDisplayBacklight(uint32_t val);
	uint32_t	GetDisplayBacklight();
	uint32_t	SetBacklightMode(uint32_t val);
	bool		ClearDisplay(uint16_t clr);
	bool		SetTchSensitivity(uint32_t val);
	uint32_t	GetTchSensitivity();
	bool		SetTchMoveDelta(int16_t dxco, int16_t dyco);
	bool		GetTchMoveDelta(int16_t * pdxco, int16_t * pdyco);
	uint32_t	GetMsgStatus();
	bool		ClearMsgQueue();
	bool		PeekMsg(MEVT * pevt);
	bool		GetMsg(MEVT * pevt);
	bool		PostMsg(MEVT * pevt);
	bool		PushMsg(MEVT * pevt);
	uint32_t	GetFreeMem();
	bool		GetMemStatus(MSTAT * pmstat);
	bool		SetMemMode(uint32_t mm);
	HMEM		AllocMem(uint32_t cbReq);
	uint32_t	GetMemSize(HMEM hmem);
	bool		FreeMem(HMEM hmem);
	bool		ReadMem(HMEM hmem, uint32_t ibRead, uint32_t cbRead, uint8_t * rgbBuf, uint32_t * pcbRes);
	bool		WriteMem(HMEM hmem, uint32_t ibWrite, uint32_t cbWrite, uint8_t * rgbBuf, uint32_t * pcbRes);
	bool		FirmwareUpdate(char * szName);
	uint8_t		GetUpdateStatus();
	bool		SetDateTime(DTM * pdtm);
	bool		GetDateTime(DTM * pdtm);

	/* GDI graphics functions
	*/
	HDS			GetDisplayDs();
	HDS			GetDs();
	bool		ReleaseDs(HDS hds);

	HBMP		CreateBitmap(int16_t dxco, int16_t dyco, int16_t cbpp);
	bool		DestroyBitmap(HBMP hbmp);
	bool		GetBitmapDimensions(HBMP hbmp, BMPD * pbmpd);
	HBMP		GetDisplayBitmap();
	HBR			CreateSolidBrush(uint32_t clr);
	HBR			CreatePatternBrush(int16_t ids, uint32_t clrFg, uint32_t clrBg);
	HBR			CreateCustomBrush(HBMP hbmp);
	bool		DestroyBrush(HBR hbrDel);

	uint32_t	GetNearestColor(uint32_t clr);
	bool		SetFgColor(HDS hds, uint32_t clr);
	uint32_t	GetFgColor(HDS hds);
	bool		SetBgColor(HDS hds, uint32_t clr);
	uint32_t	GetBgColor(HDS hds);
	bool		SetTransColor(HDS hds, uint32_t clr);
	uint32_t	GetTransColor(HDS hds);
	bool		SetIntensity(HDS hds, int ity);
	int			GetIntensity(HDS hds);
	bool		SetPen(HDS hds, uint16_t pen);
	uint16_t	GetPen(HDS hds);
	bool		SetBkMode(HDS hds, int bkReq);
	int			GetBkMode(HDS hds);
	bool		SetDrwRop(HDS hds, int drwReq);
	int			GetDrwRop(HDS hds);
	bool		SetBrush(HDS hds, HBR hbrReq);
	HBR			GetBrush(HDS hds);
	bool		SetFont(HDS hds, HFNT hfntReq);
	HFNT		GetFont(HDS hds);
	bool		SetDrawingSurface(HDS hds, HBMP hbmp);
	HBMP		GetDrawingSurface(HDS hds);

	bool		StoreBitmap(char * szName, HBMP hbmp);
	HBMP		LoadBitmap(char * szName);
	bool		SndBitmap(char * szName, uint8_t * pbmp);
	bool		RcvBitmap(char * szName, int cbMax, uint8_t * pbmp);
	bool		StoreFont(char * szName, HFNT hfnt);
	HFNT		LoadFont(char * szName);

	bool		SetPixel(HDS hds, int16_t xco, int16_t yco, uint32_t clr);
	uint32_t	GetPixel(HDS hds, int16_t xco, int16_t yco);
	bool		GetCurPos(HDS hds, PNT * ppnt);
	bool		MoveTo(HDS hds, int16_t xco, int16_t yco);
	bool		MoveTo(HDS hds, PNT * ppnt)			{ return MoveTo(hds, ppnt->xco, ppnt->yco); };
	bool		Line(HDS hds, int16_t xco, int16_t yco);
	bool		Line(HDS hds, PNT * ppnt)			{ return Line(hds, ppnt->xco, ppnt->yco); };
	bool		LineTo(HDS hds, int16_t xco, int16_t yco);
	bool		LineTo(HDS hds, PNT * ppnt)			{ return LineTo(hds, ppnt->xco, ppnt->yco); };
	bool		PolyLine(HDS hds, int cpnt, PNT * rgpnt);
	bool		PolyLineTo(HDS hds, int cpnt, PNT * rgpnt);
	bool		Arc(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
							int16_t xcoRad1, int16_t ycoRad1, int16_t xcoRad2, int16_t ycoRad2);
	bool		ArcTo(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
							int16_t xcoRad1, int16_t ycoRad1, int16_t xcoRad2, int16_t ycoRad2);
	bool		Ellipse(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom);
	bool		Chord(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
							int16_t xcoRad1, int16_t ycoRad1, int16_t xcoRad2, int16_t ycoRad2);
	bool		Pie(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
							int16_t xcoRad1, int16_t ycoRad1, int16_t xcoRad2, int16_t ycoRad2);
	bool		Rectangle(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom);
	bool		RoundRect(HDS hds, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom,
							int16_t dxcoWidth, int16_t dycoHeight);

	bool		TextOut(HDS hds, char * szText);
	bool		TextOut(HDS hds, int cchText, char * rgchText);
	bool		TextOut(HDS hds, int16_t xco, int16_t yco, int cchText, char * rgchText);
	bool		GetTextExtent(HDS hds, int cchText, char * rgchText, PNT * pntExtent);

	bool		BitBlt(HDS hdsDst, int16_t xcoDst, int16_t ycoDst, int16_t dxco, int16_t dyco, HDS hdsSrc, int16_t xcoSrc, int16_t ycoSrc, uint16_t rop);
	bool		PatBlt(HDS hdsDst, int16_t xco, int16_t yco, int16_t dxco, int16_t dyco, uint16_t rop);
	bool		DrawBitmap(HDS hdsDst, int16_t xcoDst, int16_t ycoDst, int16_t dxco, int16_t dyco, HDS hdsSrc, int16_t xcoSrc, int16_t ycoSrc);

	bool		IsRectEmpty(RCT * prct);
	bool		IsRectEqual(RCT * prct1, RCT * prct2);
	bool		PointInRect(RCT * prct, int16_t xco, int16_t yco);
	bool		PointInRect(RCT * prct, PNT pnt)	{ return PointInRect(prct, pnt.xco, pnt.yco); };
	void		SetRectEmpty(RCT * prct);
	void		SetRect(RCT * prct, int16_t xcoLeft, int16_t ycoTop, int16_t xcoRight, int16_t ycoBottom);
	void		SetRect(RCT * prctDst, RCT * prctSrc);
	void		MoveRect(RCT * prct, int16_t dxco, int16_t dyco);
	void		GrowRect(RCT * prct, int16_t dxco, int16_t dyco);
	bool		IntersectRect(RCT * prctDst, RCT * prctOne, RCT * prctTwo);
	bool		UnionRect(RCT * prctDst, RCT * prctOne, RCT * prctTwo);
	bool		FrameRect(HDS hds, RCT * prct);
	bool		FillRect(HDS hds, RCT * prct, HBR hbr);
	bool		InvertRect(HDS hds, RCT * prct);
};

/* File system API interface class.
*/
class MTFS {
private:

public:
	uint8_t		GetLastError()									{ return mtds.GetLastError(); };
	uint8_t		GetLastError(uint8_t * pcls, uint8_t * pcmd)	{ return mtds.GetLastError(pcls, pcmd); };
	uint32_t	GetElapsedTime()								{ return mtds.GetElapsedTime(); };
	bool		MountFs(bool fMount, bool fDelay);
	bool		GetFreeSpace(uint32_t * pdwFree);
	bool		SetCurrentDir(char * szDir);
	bool		GetCurrentDir(int cbMax, char * szDir);
	bool		SetVolumeLabel(char * szVol);
	bool		GetVolumeLabel(int cbMax, char * szVol);
	bool		CreateDir(char * szDir);
	HDIR		OpenDir(char * szDir);
	bool		ReadDir(HDIR hdir, FINF * pfinf);
	bool		CloseDir(HDIR hdir);
	bool		FileStat(char * szFile, FINF * pfinf);
	HFIL		OpenFile(char * szFile, uint8_t md);
	bool		CloseFile(HFIL fh);
	bool		ReadFile(HFIL fh, uint8_t * rgbBuf, uint32_t cbRead, uint32_t * pcbRes);
	bool		WriteFile(HFIL fh, uint8_t * rgbBuf, uint32_t cbWrite, uint32_t * pcbRes);
	bool		SyncFile(HFIL fh);
	bool		TruncateFile(HFIL fh);
	bool		SetFilePointer(HFIL fh, uint32_t off);
	bool		GetFilePointer(HFIL fh, uint32_t * poff);
	bool		DeleteFile(char * szFile);
	bool		RenameFile(char * szOld, char * szNew);
	bool		SetFileAttrib(char * szFile, uint8_t attrib, uint8_t mask);
	bool		SetFileTime(char * szFile, FINF * pfinf);
	bool		GetFileSize(HFIL fh, uint32_t * pcb);
	bool		Feof(HFIL fh);
	int			Ferr(HFIL fh);
};

/* Windowing system API interface class
*/
class MTWS {
private:

public:
	uint8_t		GetLastError()									{ return mtds.GetLastError(); };
	uint8_t		GetLastError(uint8_t * pcls, uint8_t * pcmd)	{ return mtds.GetLastError(pcls, pcmd); };
	uint32_t	GetElapsedTime()								{ return mtds.GetElapsedTime(); };
	HWIN		CreateWindow(HWIN hwinParent, uint16_t wcls, uint32_t wstl, int16_t xco, int16_t yco, int16_t dxco, int16_t dyco);
	bool		DestroyWindow(HWIN hwin);
	bool		CloseWindow(HWIN hwin);
	bool		ShowWindow(HWIN hwin, bool fShow);
	bool		SetPosition(HWIN hwin, int16_t xco, int16_t yco);
	bool		SetSize(HWIN hwin, int16_t dxco, int16_t dyco);
	bool		GetWindowPos(HWIN hwin, int16_t * pxco, int16_t * pyco, int16_t * pdxco, int16_t * pdyco);
	bool		MoveWindow(HWIN hwin, uint16_t wmv, int16_t xco, int16_t yco, int16_t dxco, int16_t dyco);
	HDS			BeginUpdate(HWIN hwin);
	bool		EndUpdate(HWIN hwin);
	bool		DrawBorder(HWIN hwin);
	HDS			BeginNcUpdate(HWIN hwin);
	bool		EndNcUpdate(HWIN hwin);
	bool		SetWindowId(HWIN hwin, uint32_t id);
	uint32_t	GetWindowId(HWIN hwin);
	bool		SetWindowTitle(HWIN hwin, char * szTitle);
	bool		GetWindowTitle(HWIN, uint32_t cchMax, char * sz);
	bool		SetWindowValue(HWIN, uint32_t val);
	bool		GetWindowValue(HWIN hwin, uint32_t * pval);
	bool		SetWindowString(HWIN hwin, uint32_t cch, char * sz);
	bool		GetWindowString(HWIN hwin, uint32_t cchBuf, uint32_t * pcchRet,
														uint32_t * pcchMax,	char * rgch);
	bool		GetWindowRect(HWIN, RCT * prct);
	bool		GetClientRect(HWIN hwin, RCT * prct);
};

/* ------------------------------------------------------------ */
/*					Variable Declarations						*/
/* ------------------------------------------------------------ */

extern MTDS		mtds;
extern MTFS		mtfs;
extern MTWS		mtws;

/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */

#endif	// _MTDS_H_

/********************************************************************************/
