/************************************************************************/
/*                                                                      */
/*    DFATFS.cpp                                                        */
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
#include "DFATFS.h"

#define iMKFS (_VOLUMES - 1)    // when we mount, we will do it on the last volume we have 

extern "C" int get_ldnumber (		/* Returns logical drive number (-1:invalid drive) */
	const char** path	/* Pointer to pointer to the path name */
);

DIR         DDIRINFO::_dir;
FILINFO     DDIRINFO::_fileInfo;
DFSVOL *    DFATFS::_arDFSVOL[_VOLUMES]= { 0 };
char const * const DFATFS::szFatFsVols[_VOLUMES] = {"0:", "1:", "2:", "3:", "4:"};

//**********************************************************************
//
//          DFILE Class Thunks to the underlying FATFS C code
//
//**********************************************************************
FRESULT DFILE::fsopen (const char * path, uint8_t mode)
{
    FRESULT fr = f_open (&_file, path, mode);
    _fOpen = (fr == FR_OK);
    return(fr);
}

FRESULT DFILE::fsclose (void)											
{
    _fOpen = false;
    return(f_close (&_file));
}

FRESULT DFILE::fsread (void* buff, uint32_t btr, uint32_t * br, uint32_t cSectorMax)			
{
    // check to see that we don't exceed our read/write size
    if(cSectorMax != FS_INFINITE_SECTOR_CNT && btr > (cSectorMax * _CB_SECTOR_))
    {
        *br = 0;
        return(FR_INVALID_PARAMETER);
    }

    return(f_read (&_file, buff, btr, br));
}

FRESULT DFILE::fswrite (const void* buff, uint32_t btw, uint32_t* bw, uint32_t cSectorMax)
{

    // check to see that we don't exceed our read/write size
    if(cSectorMax != FS_INFINITE_SECTOR_CNT && btw > (cSectorMax * _CB_SECTOR_))
    {
        *bw = 0;
        return(FR_INVALID_PARAMETER);
    }

    return(f_write (&_file, buff, btw, bw));
}

FRESULT DFILE::fslseek (uint32_t ofs)							
{
    return(f_lseek (&_file, ofs));
}

FRESULT DFILE::fstruncate (void)										
{
    return(f_truncate (&_file));
}

FRESULT DFILE::fssync (void)										
{
    return(f_sync (&_file));
}

int DFILE::fsputc (char c)									
{
    return(f_putc (c, &_file));
}

int DFILE::fsputs (const char* str)								
{
    return(f_puts (str, &_file));
}

int DFILE::fsprintf (const char * str, va_list va)						
{
    return(f_printf (&_file, str, va));  
}

char* DFILE::fsgets (char * buff, int32_t len)					
{
    return((char *) f_gets (buff, len, &_file));
}

#if (_USE_FORWARD == 1)
FRESULT DFILE::fsforward (uint32_t(*func)(const uint8_t *,uint32_t), uint32_t btf, uint32_t* bf)	
{
    return(f_forward (&_file, func, btf, bf));
}
#endif


//**********************************************************************
//
//          DDIRINFO Class Thunks
//
//**********************************************************************
FRESULT DDIRINFO::fsreaddir (void)
{
    return(f_readdir (&_dir, &_fileInfo));
}

FRESULT DDIRINFO::fsopendir (const char * path)
{
    return(f_opendir (&_dir, path));
}

FRESULT DDIRINFO::fsclosedir (void)
{
    return(f_closedir (&_dir));
}

FRESULT DDIRINFO::fsstat (const char * path)
{
    return(f_stat (path, &_fileInfo));
}

FRESULT DDIRINFO::fsutime (const char * path, uint16_t date, uint16_t time)
{
    _fileInfo.fdate = date;
    _fileInfo.ftime = time;
    return(f_utime (path, &_fileInfo));
}

//**********************************************************************
//
//          DFATFS Class Thunks
//
//**********************************************************************
FRESULT DFATFS::fsmkdir(const char* path)
{
    return(f_mkdir(path));
}

FRESULT DFATFS::fsunlink(const char* path)
{
    return(f_unlink(path));
}

FRESULT DFATFS::fsrename(const char* path_old, const char* path_new)
{
    return(f_rename(path_old, path_new));
}

FRESULT DFATFS::fschmod(const char* path, uint8_t value, uint8_t mask)
{
    return(f_chmod(path, value, mask));
}

FRESULT DFATFS::fschdir(const char* path)
{
    return(f_chdir(path));
}

FRESULT DFATFS::fschdrive(const char* path)
{
    return(f_chdrive(path));
}

FRESULT DFATFS::fsgetcwd(char* buff, uint32_t len)
{
    return(f_getcwd (buff, len));
}

FRESULT DFATFS::fsgetfree (const char* path, uint32_t* nclst)
{
    FATFS * pfatfs;
    return(f_getfree(path, nclst, &pfatfs));  
}

FRESULT DFATFS::fsgetlabel(const char* path, char * label, uint32_t* vsn) 
{
    return(f_getlabel(path, label, vsn));
}

FRESULT DFATFS::fssetlabel(const char* label)
{
    return(f_setlabel(label));
}

FRESULT DFATFS::fsmount(DFSVOL& dfsvol, const char* path, uint8_t opt) // FATFS comes from VOL
{ 
    const char *    pathT   = path;
    FRESULT fr = FR_INVALID_DRIVE;
    int iVol = get_ldnumber(&pathT);

    if(0 <= iVol && iVol < _VOLUMES)
    {
        DFATFS::_arDFSVOL[iVol] = &dfsvol;
        if((fr = f_mount(&dfsvol._fatfs, path, opt)) != FR_OK)
        {
            DFATFS::_arDFSVOL[iVol] = 0;
        }
    }

    return(fr);
}

FRESULT DFATFS::fsunmount(const char* path) 
{
    const char *    pathT   = path;
    int             iVol    = get_ldnumber(&pathT);
    FRESULT         fr      = f_mount(0, path, 1);

    if(0 <= iVol && iVol < _VOLUMES && fr == FR_OK)
    {
            DFATFS::_arDFSVOL[iVol] = NULL;
    }
    return(fr);
}

FRESULT DFATFS::fsmkfs(DFSVOL& dfsVol)
{
    FRESULT fr = FR_OK;
    DFSVOL * pDFSVolSave = _arDFSVOL[iMKFS];

    // unmount the drive, in case it is mounted
    fsunmount(szFatFsVols[iMKFS]);

    // delay mount the volume   
    if((fr = fsmount(dfsVol, szFatFsVols[iMKFS], 0)) != FR_OK)
    {
        return(fr);
    }

    // create the file system
    fr = f_mkfs(szFatFsVols[iMKFS], dfsVol._sfd, dfsVol._au);
    // unmount the drive
    fsunmount(szFatFsVols[iMKFS]);

    // restore the old mount
    if(pDFSVolSave != NULL)
    {
        fsmount(*pDFSVolSave, szFatFsVols[iMKFS], 0);
    }

    return(fr);
}

#ifdef DEAD
#if (_MULTI_PARTITION == 1)
FRESULT DFATFS::fsfdisk(uint8_t pdrv, const uint32_t szt[], void* work)
{
    return(f_fdisk (pdrv, szt, work));
}
#endif
#endif







