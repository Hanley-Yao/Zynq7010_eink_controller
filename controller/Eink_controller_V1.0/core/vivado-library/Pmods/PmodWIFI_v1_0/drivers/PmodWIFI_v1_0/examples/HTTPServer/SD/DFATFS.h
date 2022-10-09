/************************************************************************/
/*                                                                      */
/*    DFATFS.h                                                       */
/*                                                                      */
/*                                                                      */
/************************************************************************/
/*    Author:     Keith Vogel                                           */
/*    Copyright 2015, Digilent Inc.                                     */
/************************************************************************/
/* 
*
* Copyright (c) 2015, Digilent <www.digilentinc.com>
* Contact Digilent for the latest version.
*
* This program is free software; distributed under the terms of 
* BSD 3-clause license ("Revised BSD License", "New BSD License", or "Modified BSD License")
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1.    Redistributions of source code must retain the above copyright notice, this
*        list of conditions and the following disclaimer.
* 2.    Redistributions in binary form must reproduce the above copyright notice,
*        this list of conditions and the following disclaimer in the documentation
*        and/or other materials provided with the distribution.
* 3.    Neither the name(s) of the above-listed copyright holder(s) nor the names
*        of its contributors may be used to endorse or promote products derived
*        from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*    10/16/2015(KeithV): Created                                       */
/************************************************************************/

/************************************************************************/
/*                                                                      */
/*    Error codes copied from the FATFS fs_ff.h                         */
/*                                                                      */
/************************************************************************/
/*
	FR_OK = 0,				 (0) Succeeded 
	FR_DISK_ERR,			 (1) A hard error occurred in the low level disk I/O layer 
	FR_INT_ERR,				 (2) Assertion failed 
	FR_NOT_READY,			 (3) The physical drive cannot work 
	FR_NO_FILE,				 (4) Could not find the file 
	FR_NO_PATH,				 (5) Could not find the path 
	FR_INVALID_NAME,		 (6) The path name format is invalid 
	FR_DENIED,				 (7) Access denied due to prohibited access or directory full 
	FR_EXIST,				 (8) Access denied due to prohibited access 
	FR_INVALID_OBJECT,		 (9) The file/directory object is invalid 
	FR_WRITE_PROTECTED,		 (10) The physical drive is write protected 
	FR_INVALID_DRIVE,		 (11) The logical drive number is invalid 
	FR_NOT_ENABLED,			 (12) The volume has no work area 
	FR_NO_FILESYSTEM,		 (13) There is no valid FAT volume 
	FR_MKFS_ABORTED,		 (14) The f_mkfs() aborted due to any parameter error 
	FR_TIMEOUT,				 (15) Could not get a grant to access the volume within defined period 
	FR_LOCKED,				 (16) The operation is rejected according to the file sharing policy 
	FR_NOT_ENOUGH_CORE,		 (17) LFN working buffer could not be allocated 
	FR_TOO_MANY_OPEN_FILES,	 (18) Number of open files > _FS_SHARE 
	FR_INVALID_PARAMETER	 (19) Given parameter is invalid 
*/

#ifndef _FATFS_INCLUDE_
#define _FATFS_INCLUDE_

//#include <Arduino.h>
#include "utility/fs_ff.h"
#include "utility/fs_diskio.h"
#include "xil_types.h"
#include <stdarg.h>

#define _FATFS_CBMINSECTORS_    128
#define _FATFS_CBSECTOR_        512

#ifdef __cplusplus

class DFATFS;

class DFSVOL
{
private:
    FATFS   _fatfs;
    const uint8_t _sfd;       // Partitioning rule 0:FDISK, 1:SFD 
    const uint32_t _au;       // how many sectors in an allocation unit (page size / 512)

    DFSVOL();

protected:
    DFSVOL(uint8_t sfd, uint32_t au) : _sfd(sfd), _au(au) {}

public:
    virtual DSTATUS disk_initialize (void) = 0;
    virtual DSTATUS disk_status (void) = 0;
    virtual DRESULT disk_read (uint8_t* buff, uint32_t sector, uint32_t count) = 0;
    virtual DRESULT disk_write (const uint8_t* buff, uint32_t sector, uint32_t count) = 0;
    virtual DRESULT disk_ioctl (uint8_t cmd, void* buff) = 0;

friend class DFATFS;
};

class DFILE//: public Stream
{
private:
    static const uint32_t _CB_SECTOR_ = _FATFS_CBSECTOR_;   // this is hard coded in the FatFs engine
    static const uint32_t _DEFAULT_SECTOR_CNT_ = 1;         // By default this is how many sectors to read/write in one call (At 4MHz, this is about 1ms).
    FIL _file;
    bool _fOpen;

public:

    DFILE() : _fOpen(false) {}

    static const uint32_t FS_DEFAULT_BUFF_SIZE = (_DEFAULT_SECTOR_CNT_ * _CB_SECTOR_);  // By default this is how many sectors to read/write in one call (At 4MHz, this is about 1ms).
    static const uint32_t FS_INFINITE_SECTOR_CNT = 0;                                   // Do not block on reads or writes no matter how big the buffer

    FRESULT fsopen (const char * path, uint8_t mode);				            /* Open or create a file */
    operator bool() {return(_fOpen);}
    FRESULT fsclose (void);											            /* Close an open file object */
    FRESULT fsread (void* buff, uint32_t btr, uint32_t * br, uint32_t cSectorMax=_DEFAULT_SECTOR_CNT_);			    /* Read data from a file */
    FRESULT fswrite (const void* buff, uint32_t btw, uint32_t* bw, uint32_t cSectorMax=_DEFAULT_SECTOR_CNT_);	    /* Write data to a file */

    FRESULT fslseek (uint32_t ofs);								                /* Move file pointer of a file object */
    FRESULT fstruncate (void);										            /* Truncate file */
    FRESULT fssync (void);											            /* Flush cached data of a writing file */

    size_t write(uint8_t c) { return fsputc(c); }
    int read() { uint32_t r; char c; fsread(&c, 1, &r); return c; }
    int available() { return fssize() - fstell(); }
    void peek() { uint32_t pos = fstell(); read(); fslseek(pos); }
    void flush() { fssync(); }

    int fsputc (char c);										                /* Put a character to the file */
    int fsputs (const char* str);								                /* Put a string to the file */
    int fsprintf (const char * str, va_list va);						        /* Put a formatted string to the file */
    char* fsgets (char * buff, int32_t len);			                        /* Get a string from the file */

    int fseof(void) { return((int32_t)(_file.fptr == _file.fsize)); }
    uint8_t fserror(void) { return(_file.err); }
    uint32_t fstell(void) { return((uint32_t) _file.fptr); }
    size_t fssize(void)  { return((size_t) _file.fsize); }

#if (_USE_FORWARD == 1)
    FRESULT fsforward (uint32_t(*func)(const uint8_t *,uint32_t), uint32_t btf, uint32_t* bf);	/* Forward data to the stream */
#endif

};

class DDIRINFO
{
private:
    static DIR     _dir;
    static FILINFO _fileInfo;

    // make the constructor private so no-one can instantiate this
    DDIRINFO() {}

public:

    static FRESULT fsreaddir(void);							                        /* Read a directory item */
    static FRESULT fsopendir(const char * path);						            /* Open a directory */
    static FRESULT fsclosedir(void);										        /* Close an open directory */
    static FRESULT fsstat(const char * path);
    static FRESULT fsutime(const char * path, uint16_t date, uint16_t time);        /* Change times-tamp of the file/dir */

    // This gives access to the file info structure
    static uint32_t fsgetFileSize(void) { return(_fileInfo.fsize); }
    static uint16_t fsgetDate(void) { return(_fileInfo.fdate); }
    static uint16_t fsgetTime(void) { return(_fileInfo.ftime); }
    static uint8_t fsgetAttrib(void) { return(_fileInfo.fattrib); }
    static const char * fsget8Dot3Filename(void) { return(_fileInfo.fname); }
#if _USE_LFN
    static const char * fsgetLongFilename(void) { return(_fileInfo.lfname); }
    static uint32_t fsgetLongFilenameLength(void) { return(_fileInfo.lfsize); }
#endif
};

class DFATFS
{
private:
    static DFSVOL * _arDFSVOL[_VOLUMES];

    // make the constructor private so no-one can instantiate this
    DFATFS() {}

public:

    static char const * const szFatFsVols[_VOLUMES];

    static FRESULT fsmkdir (const char * path);								        /* Create a sub directory */
    static FRESULT fsunlink (const char * path);								    /* Delete an existing file or directory */
    static FRESULT fsrename (const char * path_old, const char* path_new);	        /* Rename/Move a file or directory */
    static FRESULT fschmod (const char * path, uint8_t value, uint8_t mask);        /* Change attribute of the file/dir */
    static FRESULT fschdir (const char * path);								        /* Change current directory */
    static FRESULT fschdrive (const char * path);								    /* Change current drive */
    static FRESULT fsgetcwd (char * buff, uint32_t len);						    /* Get current directory */
    static FRESULT fsgetfree (const char * path, uint32_t* nclst);	                /* Get number of free clusters on the drive */
    static FRESULT fsgetlabel (const char * path, char * label, uint32_t* vsn);	    /* Get volume label */
    static FRESULT fssetlabel (const char * label);							        /* Set volume label */
    static FRESULT fsmount (DFSVOL& dfsvol, const char * path, uint8_t opt);        /* Mount a logical drive */
    static FRESULT fsunmount(const char* path);                                     /* UnMount the logical drive */
    static FRESULT fsmkfs (DFSVOL& dfsvol);				                            /* Create a file system on the volume */
    static bool fsexists(const char * path) { return(DDIRINFO::fsstat(path) == FR_OK); }

    friend DSTATUS disk_initialize (uint8_t pdrv);
    friend DSTATUS disk_status (uint8_t pdrv);
    friend DRESULT disk_read (uint8_t pdrv, uint8_t* buff, uint32_t sector, uint32_t count);
    friend DRESULT disk_write (uint8_t pdrv, const uint8_t* buff, uint32_t sector, uint32_t count);
    friend DRESULT disk_ioctl (uint8_t pdrv, uint8_t cmd, void* buff);
};

#endif // C++

#endif // _FATFS_INCLUDE_


