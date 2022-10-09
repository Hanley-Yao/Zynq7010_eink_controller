/************************************************************************/
/*                                                                      */
/*    HTMLSDPage.cpp                                                    */
/*                                                                      */
/*    Renders pages off of the SD card filesystem                       */
/*    Typically you would make this the default page handler            */
/*                                                                      */
/************************************************************************/
/*    Author:     Keith Vogel                                           */
/*    Copyright 2013, Digilent Inc.                                     */
/************************************************************************/
/* 
*
* Copyright (c) 2013-2014, Digilent <www.digilentinc.com>
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
/*    7/19/2013(KeithV): Created                                         */
/************************************************************************/
#include    "HTTPServer.h"
#ifdef __MICROBLAZE__
#include    "DXSPISDVOL.h" //If an error occurs, you need to add a PmodSD IP block to your design
DXSPISDVOL dSDVol(XPAR_PMODSD_0_AXI_LITE_SPI_BASEADDR, XPAR_PMODSD_0_AXI_LITE_SDCS_BASEADDR);
DFILE       dFile;              // Create a File handle to use to open files with
#else
#include "SD/DSDIOVOL.h"
DSDIOVOL dSDVol(1);
static DFILE dFile;		/* File object */
#endif
/************************************************************************/
/*    SD Card Reader variables                                          */
/************************************************************************/
// create the sd volume and a file instance to use
//DefineSDSPI(dSDSpi);            // Macro from Board_Defs.h to create an SPI object to the uSD
//DefineDSDVOL(dSDVol, dSDSpi);   // Macro from Board_Defs.h to create an DSDVOL object to the uSD


// the drive to mount the SD volume too.
// options are: "0:", "1:", "2:", "3:", "4:"
static const char szDriveNbr[] = "0:";

// used externally to this file
// this should not be used externally directly
// use the "is/take/release" functions defined in HTPServer.h
bool fSDfs = false;
uint32_t sdLockCur = SDUNLOCKED;
uint32_t sdLock = 1;

static const char * szFileName      = NULL;
static const char   szDefaultPage[] = "HomePage.htm";
static CLIENTINFO * pClientMutex    = NULL;
static uint32_t     cbSent          = 0;
static uint32_t     tStart          = 0;
static uint32_t     sdLockId        = SDUNLOCKED;

/************************************************************************/
/*    HTML Strings                                                      */
/************************************************************************/
static const char szEndOfURL[] = " HTTP";
static const char szGET[] = "GET /";

/************************************************************************/
/*    State machine states                                              */
/************************************************************************/
typedef enum {
    PARSEFILENAME,
    BUILDHTTP,
    EXIT,
    SENDFILE,
    JMPFILENOTFOUND,
    DONE
 } STATE;

 /***    uint32_t SDRead(File fileSD, uint8_t * pbRead, uint32_t cbRead)
 *
 *    Parameters:
 *          fileSD: An open SD file to read from, you must set the positon before calling SDRead
 *          pbRead: A pointer to a buffer to receive the data read
 *          cbRead: Max size of pbRead buffer
 *              
 *    Return Values:
 *          How many bytes were actually read.
 *
 *    Description: 
 *    
 *      Helper routine to read a buffer from a file.
 * ------------------------------------------------------------ */
uint32_t SDRead(DFILE& dFile, uint8_t * pbRead, uint32_t cbRead)
 {
    uint32_t cbA;

    cbA = min(min(dFile.fssize(), cbRead), DFILE::FS_DEFAULT_BUFF_SIZE);
    dFile.fsread(pbRead, cbA, &cbRead);


    return(cbRead);
 }

/***    void SDSetup(void)
 *
 *    Parameters:
 *          None
 *              
 *    Return Values:
 *          None
 *
 *    Description: 
 *    
 *      Initializes SD Reader for HTML file operations
 *    
 * ------------------------------------------------------------ */
void SDSetup(void)
{
    FRESULT fr = FR_OK;

    // set up the lock counters
    sdLockCur   = SDUNLOCKED;
    sdLock      = SDUNLOCKED + 1; // never want this to be zero

    // Mount the SD Vol to drive "0" as known by FATFS
    // Note that there is only one global pre initialized dFatFs instance

    if((fr = DFATFS::fsmount (dSDVol, szDriveNbr, 1)) == FR_OK)
    {
	    // Card successfully initialized, so we have a file system.
    	xil_printf("SD card initialized. Drive %s mounted!\r\n", szDriveNbr);
    }
    else
    {
    	xil_printf("Failed to mount drive %s\r\nError: %d", szDriveNbr, fr);
        return;
    }

    // Open the file on the current (implied) drive "0"

    if((fr = dFile.fsopen(szDefaultPage, FA_READ)) == FR_OK)
    {
    	xil_printf("Default HTML page: %s exists!\r\n", szDefaultPage);
        fSDfs = true;
        dFile.fsclose();
    }


    else
    {
    	xil_printf("Unable to find default HTML page: %s\r\nError: %d", szDefaultPage, fr);
        return;
    }

}

/***    GCMD::ACTION ComposeHTMLSDPage(CLIENTINFO * pClientInfo)
 *
 *    Parameters:
 *          pClientInfo - the client info representing this connection and web page
 *              
 *    Return Values:
 *          GCMD::ACTION    - GCMD::CONTINUE, just return with no outside action
 *                          - GCMD::READ, non-blocking read of input data into the rgbIn buffer appended to the end of cbRead
 *                          - GCMD::GETLINE, blocking read until a line of input is read or until the rgbIn buffer is full, always the line starts at the beginnig of the rgbIn
 *                          - GCMD::WRITE, loop writing until all cbWrite bytes are written from the pbOut buffer
 *                          - GCMD::DONE, we are done processing and the connection can be closed
 *
 *    Description: 
 *    
 *      This renders a page off of the SD filesystem. Pages of type
 *      .htm, .html, .jpeg, .png, .txt and more may be rendered
 *      The file extension on the filename determine the MIME type
 *      returned to the client.
 *    
 * ------------------------------------------------------------ */
GCMD::ACTION ComposeHTMLSDPage(CLIENTINFO * pClientInfo)
{
    char * pFileNameEnd     = NULL;

    GCMD::ACTION retCMD = GCMD::CONTINUE;

    switch(pClientInfo->htmlState)
    {
        case HTTPSTART:

            if(pClientMutex != NULL || (sdLockId = lockSD()) == SDUNLOCKED)
            {
                break;
            }
            pClientMutex = pClientInfo;

            xil_printf("Read an HTML page off of the SD card\r\n");

            xil_printf("Entering Client ID: 0x%X\r\n", pClientMutex);

            pClientInfo->htmlState = PARSEFILENAME;
            retCMD = GCMD::GETLINE;
            break;

        case PARSEFILENAME:

            // the assumption is that the file name will be on the first line of the command
            // there is a bunch of other stuff on the line we don't care about, but it is at the
            // end of the line.
        	xil_printf("%s\r\n",(char *) pClientInfo->rgbIn);

            // find the begining of the file name
            szFileName = strstr((const char *) pClientInfo->rgbIn, szGET);
            if(szFileName == NULL)
            {
                pClientInfo->htmlState = JMPFILENOTFOUND;
                break;
            }
            szFileName += sizeof(szGET) - 1;

            // find the end of the file name
            pFileNameEnd = strstr(szFileName, szEndOfURL);

            if(pFileNameEnd == NULL)
            {
                pClientInfo->htmlState = JMPFILENOTFOUND;
                break;
            }
            else if(pFileNameEnd == szFileName)
            {
                szFileName = szDefaultPage;
            }
            else
            {
                *pFileNameEnd = '\0';
            }

            xil_printf("SD FileName: %s", szFileName);


            if(dFile.fsopen(szFileName, FA_READ) == FR_OK)
            {
            	xil_printf("HTML page: %s exists!\r\n", szFileName);
                pClientInfo->htmlState = BUILDHTTP;
            }

            else
            {
            	xil_printf("Unable to find HTML page: %s\r\n", szFileName);
                pClientInfo->htmlState = JMPFILENOTFOUND;
            }
            break;

        // We need to build the HTTP directive
        case BUILDHTTP:

            if(dFile && (dFile.fslseek(0) == FR_OK))
            {
                pClientInfo->cbWrite = BuildHTTPOKStr(false, dFile.fssize(), szFileName, (char *) pClientInfo->rgbOut, sizeof(pClientInfo->rgbOut));
                if(pClientInfo->cbWrite > 0)
                {
                    pClientInfo->pbOut = pClientInfo->rgbOut;
                    retCMD = GCMD::WRITE;
                    pClientInfo->htmlState = SENDFILE;
                    cbSent = 0;
                    tStart = SYSGetMilliSecond();

                    xil_printf("Writing file:%s\r\n", szFileName);
                }
                else
                {
                	xil_printf("Unable to build HTTP directive for file: %s", szFileName);
                    pClientInfo->htmlState = JMPFILENOTFOUND;
                }
            }
            else
            {
            	xil_printf("Unable to open HTML page: %s\r\n", szFileName);
                pClientInfo->htmlState = JMPFILENOTFOUND;
            }
            break;

        // Send the file
        case SENDFILE:
            {
                uint32_t    cbT = 0;

                if((cbT = SDRead(dFile, pClientInfo->rgbOut, sizeof(pClientInfo->rgbOut))) > 0)
                {
                    cbSent += cbT;
                    pClientInfo->pbOut = pClientInfo->rgbOut;
                    pClientInfo->cbWrite = cbT;
                    tStart = SYSGetMilliSecond();
                    retCMD = GCMD::WRITE;
                }
                else if(cbSent == dFile.fssize())
                {
                   pClientInfo->htmlState = EXIT;
                }
                else if((SYSGetMilliSecond() - tStart) > SDREADTIMEOUT)
                {
                   pClientInfo->htmlState = HTTPTIMEOUT;
                }
            }
            break;
    
         case EXIT:
        	 xil_printf("Wrote page cleanly\r\n");
            pClientInfo->htmlState = HTTPDISCONNECT;
            break;

        case JMPFILENOTFOUND:
        	xil_printf("Jumping to HTTP File Not Found page\r\n");

            if(isMySD(sdLockId))
            {
                if(dFile)
                {
                    dFile.fsclose();
                }
                sdLockId = unlockSD(sdLockId);
            }
            pClientMutex = NULL;
            return(JumpToComposeHTMLPage(pClientInfo, ComposeHTTP404Error));
            break;

        case HTTPTIMEOUT:
        	xil_printf("Timeout error occured, closing the session\r\n");

            // fall thru to close

        case HTTPDISCONNECT:
            if(pClientMutex == pClientInfo)
            {
            	xil_printf("Closing Client ID: 0x%X\r\n", pClientMutex);
                if(isMySD(sdLockId))
                {
                    if(dFile)
                    {
                        dFile.fsclose();
                    }
                    sdLockId = unlockSD(sdLockId);
                }
                pClientMutex = NULL;
            }
            // fall thru Done

        case DONE:
        default:
            pClientInfo->cbWrite = 0;
            retCMD = GCMD::DONE;
            break;
    }

    return(retCMD);
}
