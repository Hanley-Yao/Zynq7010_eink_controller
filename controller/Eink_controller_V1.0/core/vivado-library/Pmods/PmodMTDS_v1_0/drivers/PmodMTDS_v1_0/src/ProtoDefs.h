/********************************************************************************/
/*																				*/
/*	ProtoDef.h	--	Display Shield Communications Protocol Definitions			*/
/*																				*/
/********************************************************************************/
/*	Author:		Gene Apperson													*/
/*	Copyright 2015, Digilent Inc. All rights reserved.							*/
/********************************************************************************/
/*  File Description:															*/
/*																				*/
/*	This header file describes the communications protocol used by the Digilent	*/
/*	Multi-Touch Display Shield library for communications between the host		*/
/*	microcontroller board and the on-board processor on the display shield.		*/
/*																				*/
/*	Communications between the host processor and the display shield processor	*/
/*	is via an SPI port. The host sends command and data packets to the display	*/
/*	shield processor and the display shield processor sends status and data		*/
/*	packets back to the host via the SPI interface. There is also an interrupt	*/
/*	pin that the display shield uses to signal to the host that there is some	*/
/*	event of significance has happened.											*/
/*																				*/
/*	A command packet has the following format:									*/
/*		Packet class byte (e.g. cldCmdGdi)										*/
/*		Command byte (e.g. cmdGdiGetDs)									*/
/*		word giving byte count of parameters									*/
/*		command parameters (this will always be an even number of bytes)		*/
/*																				*/
/*	A return value packet has the following format:								*/
/*		Packet class byte (e.g. clsStaGdi)										*/
/*		Command byte that this is the return value for (e.g. CmdGdiGetDs)		*/
/*		Status code byte														*/
/*		Byte giving byte count of return values									*/
/*		return values (this will always be and even number of bytes)			*/
/*																				*/
/********************************************************************************/
/*  Revision History:															*/
/*																				*/
/* 2015/08/03(GeneA): created													*/
/* 2015/08/15(GeneA): added definitions for firmware updater					*/
/*																				*/
/********************************************************************************/

#if !defined(_PROTODEFS_H_)
#define _PROTODEFS_H_

/* ------------------------------------------------------------ */
/*				Data Size Declarations							*/
/* ------------------------------------------------------------ */

#define	cbChdrDataMax		32			// maximum number of command packet parameter bytes
#define	cbRhdrDataMax		16			// maximum number of return value bytes
#define	cbDhdrDataInMax		512			// maximum payload for data in packet
#define	cbDhdrDataOutMax	512			// maximum payload for data out packet
#define	cchUpdName			31			// maximum length of filename for firmware update file

/* ------------------------------------------------------------ */
/*				General Symbol Declarations						*/
/* ------------------------------------------------------------ */

#define	typBrdMtds		1			// board type for Multi-Touch Display Shield
#define	typBrdPmodMtds	2			// board bype for PmodMTDS

/* ------------------------------------------------------------ */
/*					Data Structure Declarations					*/
/* ------------------------------------------------------------ */

struct FWV {
	uint16_t	verFwMajor;				// firmware major version number
	uint16_t	verFwMinor;				// firmware minor version number
	uint16_t	typBoard;				// display board type
	uint16_t	verBoard;				// display board version
};

#pragma pack(push, 1)
struct UPDHDR {
	uint8_t		rgchIdent[4];			// magic sequence to identify firmware update file
	uint16_t	verFwMajor;				// firmware update major version number
	uint16_t	verFwMinor;				// firmware update minor version number
	uint16_t	typBoard;				// firmware board type
	uint16_t	uwPad;
	uint32_t	dwPad;
	uint32_t	cbBfImage;				// byte count of bootloader image
	uint32_t	offBfImage;				// file offset of bootloader memory image
	uint32_t	chkBfImage;				// check value for bootloader image
	uint32_t	pbBfFlash;				// flash memory start address of bootloader image
	uint32_t	cbPfImage;				// byte count of program flash image
	uint32_t	offPfImage;				// file offset of program flash image
	uint32_t	chkPfImage;				// check value for program flash image
	uint32_t	pbPfFlash;				// flash memory start address of program flash image
};
#pragma pack(pop)

/* ------------------------------------------------------------ */
/*					Packet Class Declarations					*/
/* ------------------------------------------------------------ */

/* The upper 2 bits of a packet tell what general kind of packet it is.
** This allows 64 subclass types for packets.
*/
#define	mskPacketCls		0xC0

#define	clsProtoChan		0x00			// SPI comm channel bytes
#define	clsPacketCmd		0x40			// command out packet
#define	clsPacketSta		0x80			// status in packet
#define	clsPacketData		0xC0			// data packet

/* The clsProtoChan values are used for single byte transmit and receive values
** rather than packets. These are used to drive the communications channel rather
** than to begin packets.
*/
#define	chnCmdIdle		(clsProtoChan + 0x00)
#define	chnCmdRead		(clsProtoChan + 0x01)       // read next byte from a packet
#define	chnCmdStart		(clsProtoChan + 0x02)       // tell firmware applccation to start running
#define	chnCmdSync		(clsProtoChan + 0x03)       // begin sync with device
#define	chnCmdResume	(clsProtoChan + 0x04)       // resume after aborted command
#define	chnCmdUpdate	(clsProtoChan + 0x05)       // launch firmware updater

#define	chnStaIdle		(clsProtoChan + 0x20)		// shield can accept command
#define	chnStaBusy		(clsProtoChan + 0x21)		// shield is busy processing a command
#define	chnStaDone		(clsProtoChan + 0x22)		// shield has finished processing command
#define	chnStaReady		(clsProtoChan + 0x23)		// ready to receive data out packet
#define	chnStaAbort		(clsProtoChan + 0x24)		// shield requests to abort current command
#define	chnStaSync		(clsProtoChan + 0x25)		// shield response to channel sync request
#define	chnStaStartup	(clsProtoChan + 0x26)		// shield hasn't compeleted startup init
#define	chnStaUpdate	(clsProtoChan + 0x27)		// indicates firmware being updated
#define	chnStaNak		(clsProtoChan + 0x2F)		// shield detected protocol error

/* These channel status codes are used internally by the mtds library code and aren't
** actually sent over the SPI interface.
*/
#define	chnStaSuccess	(clsProtoChan + 0x30)		// no error
#define	chnStaClsError	(clsProtoChan + 0x31)		// unexpected byte for packet class
#define	chnStaTimeout	(clsProtoChan + 0x3E)		// timeout waiting for shield to respond
#define	chnStaDataSize	(clsProtoChan + 0x3F)		// cb field in packet header out of range

/* Command packet classes.
*/
#define	clsCmdUtil		(clsPacketCmd + 1)		// utility command packet
#define	clsCmdGdi		(clsPacketCmd + 2)		// graphics system command packet
#define	clsCmdWin		(clsPacketCmd + 3)		// windowing system command packet
#define	clsCmdFs		(clsPacketCmd + 4)		// file system comamnd packet

/* Status packet classes
*/
#define	clsStaUtil		(clsPacketSta + 1)		// utility status packet
#define	clsStaGdi		(clsPacketSta + 2)		// graphics system status packet
#define	clsStaWin		(clsPacketSta + 3)		// windowing system status packet
#define	clsStaFs		(clsPacketSta + 4)		// file system status packet

/* Data packet classes.
*/
#define	clsDataIn		(clsPacketData + 0)		// Data In packet (shield to host)
#define	clsDataOut		(clsPacketData + 1)		// Data Out packet (host to shield)

/* ------------------------------------------------------------ */
/*					Command Code Declarations					*/
/* ------------------------------------------------------------ */

/* Utility subsystem command codes.
*/
#define	cmdUtilReadStatusPacket		0x01		// read status packet from last command
#define	cmdUtilInit					0x02        // Initialize firmware
#define	cmdUtilGetFirmwareVersion	0x03		// return firmware version number
#define	cmdUtilSetDspEnable			0x04		// enable/disable the display
#define	cmdUtilGetDspEnable			0x05		// return the enable state of the display
#define	cmdUtilSetDspOrientation	0x06		// set display to portrait/landscape orientation
#define	cmdUtilGetDspOrientation	0x07
#define	cmdUtilSetDspBacklight		0x08		// set the backlight brightness
#define	cmdUtilGetDspBacklight		0x09		// return backlight brightness
#define	cmdUtilSetBacklightMode		0x0A		// set backlight dimming mode
#define	cmdUtilClearDisplay			0x0B		// clear the display to specified color
#define	cmdUtilEnableStatusPin		0x0C		// enable/disable the specified status pin
#define	cmdUtilSetTchSensitivity	0x0D
#define	cmdUtilGetTchSensitivity	0x0E
#define	cmdUtilSetTchMoveDelta		0x0F
#define	cmdUtilGetTchMoveDelta		0x10
#define	cmdUtilGetMsgStatus			0x11		// read event status flags
#define	cmdUtilClearMsgQueue		0x12		// clear the event queue
#define	cmdUtilPeekMsg				0x13		// read first msg leaving it on the queue
#define	cmdUtilGetMsg				0x14		// read first msg from the msg queue
#define	cmdUtilPostMsg				0x15		// write msg to the end of the msg queue
#define	cmdUtilPushMsg				0x16		// write msg to the head of the msg queue
#define	cmdUtilGetMemStatus			0x17		// get memory status information
#define	cmdUtilSetMemMode			0x18		// set memory manager search and compact modes
#define	cmdUtilGetFreeMem			0x19		// return amount of free memory in heap
#define	cmdUtilAllocMem				0x1A		// allocate a memory block
#define	cmdUtilGetMemSize			0x1B		// return current size of memory block
#define	cmdUtilFreeMem				0x1C		// free an allocated memory block
#define	cmdUtilReadMem				0x1D		// read bytes from a memory block
#define	cmdUtilWriteMem				0x1E		// write bytes to a memory block
#define	cmdUtilBeginUpdate			0x1F		// pass parameters and set up for firmware update
#define	cmdUtilSetDateTime			0x20		// set the current date and time
#define	cmdUtilGetDateTime			0x21		// get the current date and time

#define	cmdUtilSetStatusPin			0x80		//DEBUG
#define	cmdUtilEnd					0xFF

/* Graphics system command codes.
*/
#define	cmdGdiGetDisplayDs			0x01		// get HDS for display
#define	cmdGdiGetDs					0x02		// get generic HDS
#define	cmdGdiReleaseDs				0x03		// release HDS when no longer needed
#define	cmdGdiCreateSolidBrush		0x04		// create brush with a solid color
#define	cmdGdiCreatePatternBrush	0x05		// create brush using predefined pattern
#define	cmdGdiCreateCustomBrush		0x06		// create brush using bitmap
#define	cmdGdiDestroyBrush			0x07		// delete brush when no longer needed
#define	cmdGdiGetDisplayBitmap		0x08		// get HBMP for display
#define	cmdGdiCreateBitmap			0x09		// create off-screen bitmap
#define	cmdGdiDestroyBitmap			0x0A		// delete off-screen bitmap when no longer needed
#define	cmdGdiStoreBitmap			0x0B		// write bitmap to file on SD card
#define	cmdGdiLoadBitmap			0x0C		// load bitmap from file on SD card
#define	cmdGdiSndBitmap				0x0D		// transfer bitmap from host to shield
#define	cmdGdiRcvBitmap				0x0E		// transfer bitmap from shield to host

#define	cmdGdiSetFgColor			0x10		// set foreground color in DS
#define	cmdGdiGetFgColor			0x11		// return current foreground color from DS
#define	cmdGdiSetBgColor			0x12		// set background color in DS
#define	cmdGdiGetBgColor			0x13		// return current background color from DS
#define	cmdGdiSetTransColor			0x14		// set transparency color in DS
#define	cmdGdiGetTransColor			0x15		// return current transparency color from DS
#define	cmdGdiSetIntensity			0x16		// set DrawBitmap intensity
#define	cmdGdiGetIntensity			0x17		// return current DrawBitmap intensity
#define	cmdGdiSetPen				0x18		// set pen pattern in DS
#define	cmdGdiGetPen				0x19		// return current pen pattern from DS
#define	cmdGdiSetBkMode				0x1A		// set the background drawing mode in DS
#define	cmdGdiGetBkMode				0x1B		// return current background drawing mode from DS
#define	cmdGdiSetDrwRop				0x1C		// set the line/text raster-op in DS
#define	cmdGdiGetDrwRop				0x1D		// return current line/text raster-op from DS
#define	cmdGdiSetBrush				0x1E		// set brush pattern HBR in DS
#define	cmdGdiGetBrush				0x1F		// get current brush pattern HBR from DS
#define	cmdGdiSetFont				0x20		// set HFNT of current text font in DS		
#define	cmdGdiGetFont				0x21		// return HFNT of current text font from DS
#define	cmdGdiSetDrawingSurface		0x22		// set HBMP to use in DS
#define	cmdGdiGetDrawingSurface		0x23		// get HBMP of current bitmap in DS
#define	cmdGdiFrameRect				0x24		// draw border of specified rectangle
#define	cmdGdiFillRect				0x25		// fill interior of specified rectangle
#define	cmdGdiInvertRect			0x26		// invert color of interior of specified rectangle
#define	cmdGdiGetNearestColor		0x27		// get nearest realizable color to specified color
#define	cmdGdiCreateFont			0x28		// create a custom font
#define	cmdGdiDestroyFont			0x29		// delete a custom font when not needed
#define	cmdGdiStoreFont				0x2A		// store a custom font to SD card
#define	cmdGdiLoadFont				0x2B		// load a custom font from SD card
#define	cmdGdiSndFont				0x2C		// transfer custom font from host to shield
#define	cmdGdiRcvFont				0x2D		// transfer custom font from shield to host
#define	cmdGdiGetFontSize			0x2E		// get number of bytes required to contain font

#define	cmdGdiSetPixel				0x30
#define	cmdGdiGetPixel				0x31
#define	cmdGdiGetCurPos				0x32
#define	cmdGdiMoveTo				0x33
#define	cmdGdiLine					0x34
#define	cmdGdiLineTo				0x35
#define	cmdGdiPolyLine				0x36
#define	cmdGdiPolyLineTo			0x37
#define	cmdGdiArc					0x38
#define	cmdGdiArcTo					0x39
#define	cmdGdiEllipse				0x3A
#define	cmdGdiChord					0x3B
#define	cmdGdiPie					0x3C
#define	cmdGdiRectangle				0x3D
#define	cmdGdiRoundRect				0x3E

#define	cmdGdiTextOutCch			0x40
#define	cmdGdiTextOutXcoYco			0x41
#define	cmdGdiGetTextExtent			0x42

#define	cmdGdiBitBlt				0x48
#define	cmdGdiPatBlt				0x49
#define	cmdGdiDrawBitmap			0x4A

#define	cmdGdiGetBitmapSize			0x50		// return bytes needed to contain bitmap
#define	cmdGdiGetBitmapDim			0x51		// return bitmap dimensions

#define	cmdGdiMax	(cmdGdiGetBitmapDim+1)

/* Windowing system commands.
*/
#define	cmdWinCreateWindow			0x01
#define	cmdWinDestroyWindow			0x02
#define	cmdWinCloseWindow			0x03
#define	cmdWinShowWindow			0x04
#define	cmdWinSetPosition			0x05
#define	cmdWinSetSize				0x06
#define	cmdWinMoveWindow			0x07
#define	cmdWinGetWindowPos			0x08
#define	cmdWinBeginUpdate			0x09
#define	cmdWinEndUpdate				0x0A
#define	cmdWinDrawBorder			0x0B
#define	cmdWinBeginNcUpdate			0x0C
#define	cmdWinEndNcUpdate			0x0D
#define	cmdWinSetWindowId			0x0E
#define	cmdWinGetWindowId			0x0F
#define	cmdWinSetWindowTitle		0x10
#define	cmdWinGetWindowTitle		0x11
#define	cmdWinSetWindowValue		0x12
#define	cmdWinGetWindowValue		0x13
#define	cmdWinSetWindowString		0x14
#define	cmdWinGetWindowString		0x15
#define	cmdWinGetWindowRect			0x16
#define	cmdWinGetClientRect			0x17

/* File system command codes.
*/
#define	cmdFsMount					0x01		// mount a file system on the external drive
#define	cmdFsGetFreeSpace			0x02		// get free space on the volume
#define	cmdFsSetCurDrive			0x03		// set current drive
#define	cmdFsSetCurDir				0x04		// set current working directory
#define	cmdFsGetCurDir				0x05		// get current working directory
#define	cmdFsSetLabel				0x06		// set the volume label
#define	cmdFsGetlabel				0x07		// get the volume label
#define	cmdFsMkdir					0x08		// create a subdirectory
#define	cmdFsOpenDir				0x09		// open a subdirectory for read
#define	cmdFsReadDir				0x0A		// read next item from open directory
#define	cmdFsCloseDir				0x0B		// close an open directory
#define	cmdFsStat					0x0C		// check existence of file or directory
#define	cmdFsOpen					0x0D		// open a file
#define	cmdFsClose					0x0E		// close an open file
#define	cmdFsRead					0x0F		// read from an open file
#define	cmdFsWrite					0x10		// write to an open file
#define	cmdFsSync					0x11		// synchronize file being written
#define	cmdFsTruncate				0x12		// truncate file being written
#define	cmdFsSeek					0x13		// position file pointer
#define	cmdFsTell					0x14		// return current file pointer
#define	cmdFsDelete					0x15		// delete a file or directory
#define	cmdFsRename					0x16		// rename a file or directory
#define	cmdFsSetAttrib				0x17		// change file attributes
#define	cmdFsSetTime				0x18		// change file timestamp
#define	cmdFsSize					0x19		// return file size
#define	cmdFsFeof					0x1A		// return if at EOF
#define	cmdFsErr					0x1B		// return last error on file handle
#define	cmdFsSetFname				0x1C		// utility command to set a file name for later

/* ------------------------------------------------------------ */
/*					Status Code Declarations					*/
/* ------------------------------------------------------------ */

/* The success code for all command packets is 0x00.
*/
#define	staCmdSuccess				0x00		// general, command completed successfully

/* Generic error codes start with 0x80. Subsystem specific error codes start with 0x01.
*/
#define	staCmdError					0x80		// general error code
#define	staCmdNotSupported			0x81		// unknown command
#define	staCmdOutOfMemory			0x82		// memory heap exhausted
#define	staCmdInternalError			0x83		// general internal error
#define	staCmdSync					0x84		// unable to sync communications with display
#define	staCmdReserved				0xFF		// reserved for other uses

/* Utility system status codes.
*/
#define	staUtilBadParameter			0x01		// invalid parameter to command
#define	staUtilNotSupported			0x02		// requested feature not supported
#define	staUtilEventCacheExhausted	0x03		// no free event elements available
#define	staUtilInvalidMemoryHandle	0x04		// bad memory handle passed to a memory function

/* Graphics system status codes.
*/
#define	staGdiBadParameter			0x01
#define	staGdiBadDataLength			0x02		// data packet incorrect length for command
#define	staGdiInvalidDs				0x03		// invalid DS handle
#define	staGdiInvalidBrush			0x04		// invalid brush handle
#define	staGdiInvalidFont			0x05		// invalid font handle
#define	staGdiInvalidBitmap			0x06		// invalid bitmap handle
#define	staGdiFormatNotSupported	0x07		// bitmap file format not supported
#define	staGdiDiskError				0x08		// disk hard error
#define	staGdiFileNotFound			0x09		// unable to open file
#define	staGdiFileCreateError		0x0A		// unable to create specified file
#define	staGdiFileReadError			0x0B		// error reading from file
#define	staGdiFileWriteError		0x0C		// error writing to the file
#define	staGdiFileDataError			0x0D		// internal inconsistency in file data

/* Windowing system status codes
*/
#define	staWinBadParameter			0x01		// bad parameter to command
#define	staWinInvalidHwin			0x02		// bad window handle
#define	staWinBadDataLength			0x03		// invalid parameter length
#define	staWinNoString				0x04		// no window string available
#define	staWinDsPoolExhausted		0x05		// no free DS available
#define	staWinHwinNotFound			0x06		// requested window not found

/* File system status codes
*/
#define	staFsDiskError				0x01		// disk hardware error
#define	staFsInternalError			0x02		// internal error in file system manager
#define	staFsNotReady				0x03		// physical drive not ready
#define	staFsFileNotFound			0x04		// unable to find the requested file
#define	staFsPathNotFound			0x05		// specified path not found
#define	staFsInvalidName			0x06		// path name not well formed
#define	staFsAccessDenied			0x07		// access denied for directory full
#define	staFsExist					0x08		// access prohibited
#define	staFsInvalidObject			0x09		// file/directory object invalid (internal error)
#define	staFsWriteProtect			0x0A		// physical drive is write protected
#define	staFsInvalidDrive			0x0B		// logical drive number is invalid (internal error)
#define	staFsNotEnabled				0x0C
#define	staFsNoFileSystem			0x0D		// drive doesn't contain valid file system
#define	staFsAborted				0x0E		// operation aborted due to bad parameter
#define	staFsTimeout				0x1F
#define	staFsLocked					0x10		// file sharing violation
#define	staFsOutOfMemory			0x11		// file system out of internal memory
#define	staFsTooManyFiles			0x12		// too many open files
#define	staFsInvalidParameter		0x13
#define	staFsInvalidHandle			0x14

/* Status codes returned by the GetUpdateStatus() function. These are a special case
** as they aren't really about command success/failure, but about the ongoing status
** of the firmware update process.
*/
#define	staUpdateSuccess			0x01
#define	staUpdateBusy				0x02		// firmware updater is still working
#define	staUpdateAbort				0x03		// firmware updater couldn't start
#define	staUpdateError				0x04		// firmware update fatal error

/* ------------------------------------------------------------ */
/*					Variable Declarations						*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */

#endif	// _PROTODEFS_H_

/********************************************************************************/
