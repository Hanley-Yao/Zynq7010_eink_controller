/********************************************************************************/
/*																				*/
/*	MtdsFs.cpp	--	Implementation for MTDS FileSystem Functions				*/
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
/*	2015/10/07(GeneApperson): Created											*/
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
/*				MTFS Object Class Implementation				*/
/* ------------------------------------------------------------ */
/***	MTFS::MountFs(fMount, fDelay)
**
**	Parameters:
**		fMount		- mount (true) unmount (false) the file system
**		fDelay		- when mounting, true specifies delayed mount
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Mount/unmount a file system. The file system must be mounted before any
**		access to the SD card is allowed. The file system is unmounted before the
**		SD card can be removed.
*/

bool MTFS::MountFs(bool fMount, bool fDelay) {
	PRM2B	prm;

	/* Send the command packet.
	*/
	prm.valB1 = fMount ? 1 : 0;
	prm.valB2 = fDelay ? 1 : 0;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsMount, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::GetFreeSpace(pdwFree)
**
**	Parameters:
**		pdwFree		- pointer to variable to receive free space on disk
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Returns the number of free sectors on the SD card.
*/

bool MTFS::GetFreeSpace(uint32_t * pdwFree) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1B	prm;

	/* Send the command packet.
	*/
	prm.valB1 = 0;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsGetFreeSpace, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		*pdwFree = 0;
		return false;
	}

	*pdwFree = pret->valA1;
	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::SetCurrentDir(szDir)
**
**	Parameters:
**		szDir		- path string to make current directory
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		make the specified directory be the current working directory.
*/

bool MTFS::SetCurrentDir(char * szDir) {
	PRM1B	prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!mtds.FCheckName(szDir, clsCmdFs, cmdFsSetCurDir)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valB1 = strlen(szDir)+1;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsSetCurDir, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szDir);

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
/***	MTFS::GetCurrentDir(cbMax, szDir)
**
**	Parameters:
**		cbMax		- size of return buffer
**		szDir		- buffer to receive current directory
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Return the name of the current working directory.
*/

bool MTFS::GetCurrentDir(int cbMax, char * szDir) {
	PRM1B	prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!mtds.FCheckName(szDir, clsCmdFs, cmdFsSetCurDir)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valB1 = strlen(szDir)+1;

	mtds.MtdsProcessCmdRd(clsCmdFs, cmdFsGetCurDir, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szDir);

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
/***	MTFS::SetVolumeLabel(szVol)
**
**	Parameters:
**		szVol		- volume label to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Set the volume label to the specified string.
*/

bool MTFS::SetVolumeLabel(char * szVol) {
	return false;
}

/* ------------------------------------------------------------ */
/***	MTFS::GetVolumeLabel(cbMax, szVol)
**
**	Parameters:
**		cbMax		- size of return buffer
**		szDir		- buffer to receive current volume label
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Return the the current volume label of the disk.
*/

bool MTFS::GetVolumeLabel(int cbMax, char * szVol) {
	return false;
}

/* ------------------------------------------------------------ */
/***	MTFS::CreateDir(szDir)
**
**	Parameters:
**		szDir		- path string of directory to create
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Create the specified directory.
*/

bool MTFS::CreateDir(char * szDir) {
	PRM1B	prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!mtds.FCheckName(szDir, clsCmdFs, cmdFsMkdir)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valB1 = strlen(szDir)+1;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsMkdir, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szDir);

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
/***	MTFS::OpenDir(szDir)
**
**	Parameters:
**		szDir		- path string of directory to open
**
**	Return Values:
**		Returns directory handle to the open directory
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Open the specified directory for read.
*/

HDIR MTFS::OpenDir(char * szDir) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1B	prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!mtds.FCheckName(szDir, clsCmdFs, cmdFsOpenDir)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valB1 = strlen(szDir)+1;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsOpenDir, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szDir);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return success.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTFS::ReadDir(hdir, pfinf)
**
**	Parameters:
**		hdir		- handle to open directory
**		pfinf		- pointer to file info structure to receive data
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Read the next directory entry from the specified open directory
*/

bool MTFS::ReadDir(HDIR hdir, FINF * pfinf) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hdir;

	mtds.MtdsProcessCmdRd(clsCmdFs, cmdFsReadDir, sizeof(prm), (uint8_t *)&prm,
						sizeof(FINF), (uint8_t *)pfinf);

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
/***	MTFS::CloseDir(hdir)
**
**	Parameters:
**		hdir		- handle to open directory to close
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Close the specified directory.
*/

bool MTFS::CloseDir(HDIR hdir) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = hdir;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsCloseDir, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::FileStat(szFile, pfinf)
**
**	Parameters:
**		szFile		- name of file to query
**		pfifn		- buffer to receive file status information
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Return status information about the specified file.
**		This function requires both sending a data packet and receiving a data packet.
**		There isn't an underlying mechanism to do that. It uses a utility command to
**		send the file name first, and then follows up with a command to read the FINF
**		value.
*/

bool MTFS::FileStat(char * szFile, FINF * pfinf) {
	PRM1B	prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!mtds.FCheckName(szFile, clsCmdFs, cmdFsStat)) {
		return false;
	}

	/* Send the command packet to set the file name.
	*/
	prm.valB1 = strlen(szFile)+1;
	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsSetFname, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szFile);

	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Now send the command to read the FINF structure for the file.
	*/
	prm.valB1 = 0;		//This is a dummy value that isn't used
	mtds.MtdsProcessCmdRd(clsCmdFs, cmdFsStat, sizeof(prm), (uint8_t *)&prm,
						sizeof(FINF), (uint8_t *)pfinf);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::OpenFile(szFile, md)
**
**	Parameters:
**		szFile		- path string of file to open
**		md			- file access mode
**
**	Return Values:
**		Returns file handle to the open file.
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Open or create the specfied file.
*/

HDIR MTFS::OpenFile(char * szFile, uint8_t md) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM2B	prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!mtds.FCheckName(szFile, clsCmdFs, cmdFsOpen)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valB1 = strlen(szFile)+1;
	prm.valB2 = md;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsOpen, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szFile);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return 0;
	}

	/* Return the file handle.
	*/
	return pret->valA1;

}

/* ------------------------------------------------------------ */
/***	MTFS::CloseFile(fh)
**
**	Parameters:
**		fh		- file handle to close
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Close the specified file.
*/

bool MTFS::CloseFile(HFIL fh) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsClose, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::ReadFile(fh, rgbBuf, cbRead, pcbRes)
**
**	Parameters:
**		fh		- file handle of file to read
**		rgbBuf	- buffer to receive the data
**		cbRead	- number of bytes to read
**		pcbRes	- pointer to variable to receive number of bytes read
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Read the specified number of bytes from the specified file.
*/

bool MTFS::ReadFile(HFIL fh, uint8_t * rgbBuf, uint32_t cbRead, uint32_t * pcbRes) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM2A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;
	prm.valA2 = cbRead;

	mtds.MtdsProcessCmdRd(clsCmdFs, cmdFsRead, sizeof(prm), (uint8_t *)&prm, cbRead, rgbBuf);

	*pcbRes = pret->valA1;

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
/***	MTFS::WriteFile(fh, rgbBuf, cbWrite, pcbRes)
**
**	Parameters:
**		fh		- file handle of file to write
**		rgbBuf	- buffer of data to write
**		cbWrite	- number of bytes to write
**		pcbRes	- pointer to variable to receive number of bytes written
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Write the specified number of bytes to the specified file.
*/

bool MTFS::WriteFile(HFIL fh, uint8_t * rgbBuf, uint32_t cbWrite, uint32_t * pcbRes) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM2A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;
	prm.valA2 = cbWrite;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsWrite, sizeof(prm), (uint8_t *)&prm, cbWrite, rgbBuf);

	*pcbRes = pret->valA1;

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Return the file handle.
	*/
	return true;

}

/* ------------------------------------------------------------ */
/***	MTFS::SyncFile(fh)
**
**	Parameters:
**		fh		- file handle to synchronize
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Sychronize the file by flushing any unwritten data to the disk.
*/

bool MTFS::SyncFile(HFIL fh) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsSync, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::TruncateFile(fh)
**
**	Parameters:
**		fh		- file handle to truncate
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Truncate the file to the current file pointer position.
*/

bool MTFS::TruncateFile(HFIL fh) {
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsTruncate, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::SetFilePointer(fh, off)
**
**	Parameters:
**		fh		- file handle to synchronize
**		off		- position within the file
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the file read/write pointer to the specified position.
*/

bool MTFS::SetFilePointer(HFIL fh, uint32_t off) {
	PRM2A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;
	prm.valA2 = off;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsSeek, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::GetFilePointer(fh, poff)
**
**	Parameters:
**		fh		- file handle to synchronize
**		poff	- pointer to variable to receive current position within the file
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Get the current file read/write pointer position.
*/

bool MTFS::GetFilePointer(HFIL fh, uint32_t * poff) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsTell, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		*poff = 0;
		return false;
	}

	/* Return the file handle.
	*/
	*poff = pret->valA1;
	return true;

}

/* ------------------------------------------------------------ */
/***	MTFS::DeleteFile(szFile)
**
**	Parameters:
**		szFile		- name of file or directory to delete
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Delete the specified file or directory.
*/

bool MTFS::DeleteFile(char * szFile) {
	PRM1B	prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!mtds.FCheckName(szFile, clsCmdFs, cmdFsDelete)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valB1 = strlen(szFile)+1;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsDelete, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szFile);

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
/***	MTFS::RenameFile(szOld, szNew)
**
**	Parameters:
**		szOld		- name of file or directory to rename
**		szNew		- new name to rename file or directory to
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Rename the specified file or directory.
*/

bool MTFS::RenameFile(char * szOld, char * szNew) {
	PRM1B	prm;

	/* Error check that the file name lengths are acceptable.
	*/
	if (!mtds.FCheckName(szOld, clsCmdFs, cmdFsStat)) {
		return false;
	}

	if (!mtds.FCheckName(szNew, clsCmdFs, cmdFsStat)) {
		return false;
	}

	/* Send the command packet to set the old file file name. The command processing
	** model only supports sending one data packet with to pass parameter information
	** with a command, the SetFName command causes the old name to be stored
	** temporarily on the display device until the rename command is sent with the
	** new name.
	*/
	prm.valB1 = strlen(szOld)+1;
	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsSetFname, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szOld);

	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Now send the command to rename the file along with the new name.
	*/
	prm.valB1 = strlen(szNew)+1;
	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsRename, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szNew);


	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::SetFileAttrib(attrib, mask)
**
**	Parameters:
**		attrib		- new file attribute bits to set
**		mask		- mask to indicate which bits to modify
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the file attributes to the value specified by *pinf
*/

bool MTFS::SetFileAttrib(char * szFile, uint8_t attrib, uint8_t mask) {
	PRM3B	prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!mtds.FCheckName(szFile, clsCmdFs, cmdFsStat)) {
		return false;
	}

	/* Send the command packet.
	*/
	prm.valB1 = strlen(szFile)+1;
	prm.valB2 = attrib;
	prm.valB3 = mask;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsSetAttrib, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szFile);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::SetFileTime(szFile, pfinf)
**
**	Parameters:
**		szFile		- name of file or directory to set
**		pfinf		- pointer to file info structure containing file times to set
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Set the file modification data nd time to the value specified by *pinf
*/

bool MTFS::SetFileTime(char * szFile, FINF * pfinf) {
	PRM1B	prm;

	/* Error check that the file name length is acceptable.
	*/
	if (!mtds.FCheckName(szFile, clsCmdFs, cmdFsStat)) {
		return false;
	}

	/* Send the command packet to set the file name.
	*/
	prm.valB1 = strlen(szFile)+1;
	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsSetFname, sizeof(prm), (uint8_t *)&prm,
						prm.valB1, (uint8_t *)szFile);

	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	/* Now send the command with the FINF structure for time to set.
	*/
	prm.valB1 = 0;		//This is a dummy value that isn't used
	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsSetTime, sizeof(prm), (uint8_t *)&prm,
						sizeof(FINF), (uint8_t *)pfinf);

	/* Check for error.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		return false;
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTFS::GetFileSize(fh, pcbSize)
**
**	Parameters:
**		fh		- file handle to synchronize
**		pcbSize	- pointer to variable to receive file size
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if not
**
**	Description:
**		Get the current size of the file.
*/

bool MTFS::GetFileSize(HFIL fh, uint32_t * pcbSize) {
	RET4A *	pret = (RET4A *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsSize, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		*pcbSize = 0;
		return false;
	}

	/* Return the file handle.
	*/
	*pcbSize = pret->valA1;
	return true;

}

/* ------------------------------------------------------------ */
/***	MTFS::Feof(fh)
**
**	Parameters:
**		fh		- open file handle
**
**	Return Values:
**		Returns true if file pointer is at end of file
**
**	Errors:
**		Returns true if invalid file handle
**
**	Description:
**		This function returns true if the current file pointer is at the end of
**		the file.
**		Note: This function return true (i.e. end of file) if the file handle is
**		invalid. To distinguish actual 'end of file' from 'invalid file handle',
**		call MTDS::GetLastError. This will return staCmdSuccess if the file handle
**		is valid and no error occured.
*/

bool MTFS::Feof(HFIL fh) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsFeof, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		/* Note: in the case that the command failed, we return true so that it
		** looks line end of file.
		*/
		return true;
	}

	/* Return the end of file status.
	*/
	return pret->valB1 != 0;

}

/* ------------------------------------------------------------ */
/***	MTFS::Ferr(fh)
**
**	Parameters:
**		fh		- open file handle
**
**	Return Values:
**		Returns last error on the file specified by fh.
**
**	Errors:
**		Returns true if invalid file handle
**
**	Description:
**		Returns the error code for the last error to occur on fh.
*/

int MTFS::Ferr(HFIL fh) {
	RET4B *	pret = (RET4B *)&rgbMtdsRetVal[sizeof(RHDR)];
	PRM1A	prm;

	/* Send the command packet.
	*/
	prm.valA1 = fh;

	mtds.MtdsProcessCmdWr(clsCmdFs, cmdFsErr, sizeof(prm), (uint8_t *)&prm, 0, 0);

	/* Check for error and return failure.
	*/
	if (prhdrMtdsRet->sta != staCmdSuccess) {
		/* Note: in the case that the command failed, we return -1, which is different
		** than any error code.
		*/
		return -1;
	}

	/* Return the end of file status.
	*/
	return pret->valB1;

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

