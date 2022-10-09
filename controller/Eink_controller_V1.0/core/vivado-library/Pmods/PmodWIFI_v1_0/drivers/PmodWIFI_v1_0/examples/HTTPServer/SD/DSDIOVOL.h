/************************************************************************/
/*                                                                      */
/*    DSDIOVOL.h                                                          */
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
/*    10/19/2015(KeithV): Created                                       */
/*	  08/08/2016(TommyK): Modified to use xsdps on Zynq processor		*/
/************************************************************************/
#ifndef _DSDIOVOL_INCLUDE_
#define _DSDIOVOL_INCLUDE_

#include "DFATFS.h"       // required for the interface DFSVOL
#include "DEIPcK/utility/System.h"
#include "xsdps.h"

#define FILE_SYSTEM_INTERFACE_SD
#define HIGH_SPEED_SUPPORT	0x01U
#define WIDTH_4_BIT_SUPPORT	0x4U
#define SD_CLK_25_MHZ		25000000U
#define SD_CLK_26_MHZ		26000000U
#define SD_CLK_52_MHZ		52000000U
#define EXT_CSD_DEVICE_TYPE_BYTE	196
#define EXT_CSD_4_BIT_WIDTH_BYTE	183
#define EXT_CSD_HIGH_SPEED_BYTE		185
#define EXT_CSD_DEVICE_TYPE_HIGH_SPEED	0x3
#define SD_CD_DELAY		10000U

class DSDIOVOL : public DFSVOL
{
    private:

        // variables used by the MMC/SD
        volatile DSTATUS    Stat;

        XSdPs SdInstance;
        u32 BaseAddress;
        u32 CardDetect;
        u32 WriteProtect;
        u32 SlotType;
        u8 HostCntrlrVer;

		#ifdef __ICCARM__
		#pragma data_alignment = 32
		u8 ExtCsd[512];
		#pragma data_alignment = 4
		#else
		u8 ExtCsd[512] __attribute__ ((aligned(32)));
		#endif

		DSDIOVOL();

    public:

        DSDIOVOL(u8 a) : DFSVOL(0,1), Stat(STA_NOINIT) {}

        DSTATUS disk_initialize (void);
		DSTATUS disk_status (void);
		DRESULT disk_read (uint8_t* buff, uint32_t sector, uint32_t count);
		DRESULT disk_write (const uint8_t* buff, uint32_t sector, uint32_t count);
		DRESULT disk_ioctl (uint8_t cmd, void* buff);
};
#endif

