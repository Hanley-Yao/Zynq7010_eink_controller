/************************************************************************/
/*                                                                      */
/*    ProcessClient.cpp                                                 */
/*                                                                      */
/*    A chipKIT WiFi HTTP Web Server implementation                     */
/*    This processes connected clients                                  */
/*    This sketch is designed to work with web browsers                 */
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
/*    2/1/2013(KeithV): Created                                         */
/************************************************************************/
#include    "HTTPServer.h"

// The HTML Redering page list
typedef struct 
{
    const char *    szMatchString;
    uint32_t        cbMatch;
    FNRENDERHTML    ComposeHTMLPage;
} HTTPCMD;

static HTTPCMD rgHttpCmd[CNTHTTPCMD];
static FNRENDERHTML DefaultHTMLPage = ComposeHTTP404Error;

typedef enum
{
    START           = 0,
    READINPUT,
    PARSENEXTLINE,
    WAITCMD,
    DEFAULTCMD,
    DISPLAYTIME,
    PROCESSHTML,
    WRITEBUFFER,
    STOPCLIENT,     // any state after the connection is lost must be placed below here 
    EXIT,           // just finishing up the client processing
    RESTART,        // want to restart the server
    TERMINATE,      // want to terminate the server
    REBOOT          // reboot the processor; MCLR
} CLIENTSTATE;

/***    GCMD::ACTION ProcessClient(CLIENTINFO * pClientInfo)
 *
 *    Parameters:
 *          pClientInfo - a pointer to CLIENTINFO structure with the socket and local data used by the connection
 *              
 *    Return Values:
 *          GCMD::ACTION -  Generally GCMD::CONTINUE is returned to keep the server running
 *                          However if GCMD::RESTART is returned, the server is restarted
 *                          And if GCMD::TERMINATE is returned, the server is cleanly shutdown and loops forever doing nothing.
 *
 *    Description: 
 *    
 *      In the CLINTINFO structure there is an fInUse flag, and this is what tells the server
 *      that the CLINTINFO has an active connection. Only active connections are processed by the server
 *      so this function is only called with pClientInfo->fInUse == true. This function sets it false when the connection
 *      is closed or lost.
 *
 *      Having said that, there are a few cases when the connection will be dropped. For example if the other side
 *      unexpectedly drops the connection, or the network goes down.
 *
 *      When the connection is closed (state == STOPCLIENT) for whatever reason, the HTML rendering function will be called with 
 *      pClientInfo->htmlState == HTTPDISCONNECT. This is the only intential time the HTML Rendering function will
 *      be called with the connection closed. This is to allow the Rendering page to deinitialize any state.
 *      So if a file is open, or hardware is process, the rendering page function will have an opertunity to close
 *      resources. This is particularly useful if the connection is unexpectedly dropped, this will allow
 *      for cleanup. When the HTML rendering function is called with HTTPDISCONNECT, GCMD::DONE is expected to be returned.
 *      
 * ------------------------------------------------------------ */
GCMD::ACTION ProcessClient(CLIENTINFO * pClientInfo)
{   
    GCMD::ACTION    action = GCMD::CONTINUE;
    IPSTATUS        status = ipsSuccess;
    uint32_t        tCur = SYSGetMilliSecond();

    // timeout occured, get out
    if(pClientInfo->clientState != START && (tCur - pClientInfo->tStartClient)  >= (secClientTO * 1000))
    {
    	xil_printf("Timeout on client: 0x%X\r\n", pClientInfo);
        pClientInfo->nextClientState    =   EXIT;
 
        // if no data came in at all, then just close the connection
        if(pClientInfo->cbRead == 0)
        {
            pClientInfo->clientState        =   STOPCLIENT;
        }

        // if some data came in, then give the data to the default HTML page.
        else if(pClientInfo->ComposeHTMLPage == NULL)
        {
            pClientInfo->clientState        =   DEFAULTCMD;
        }
        else
        {
            pClientInfo->clientState        =   PROCESSHTML;
            pClientInfo->htmlState          =   HTTPTIMEOUT;
        }
    }

    // lost the connection, get out
    if(((CLIENTSTATE) pClientInfo->clientState < STOPCLIENT)  && !pClientInfo->pTCPClient->isEstablished())
    {
    	xil_printf("Connection Lost\r\n");
        pClientInfo->clientState        = STOPCLIENT;
        pClientInfo->tStartClient       = tCur;
        pClientInfo->nextClientState    = EXIT;
    }

    switch((CLIENTSTATE) pClientInfo->clientState)
    {   
        case START:
        	xil_printf("New Client detected\r\n");

            // we know for the most part, the CLIENTINFO is zero'ed 
            // so only set non-zero values
            pClientInfo->pbOut              =   pClientInfo->rgbOut;
            pClientInfo->htmlState          =   HTTPSTART;                  // forces the initialization state to be executed
            pClientInfo->tStartClient       =   tCur;
            pClientInfo->clientState        =   READINPUT;
            pClientInfo->nextClientState    =   WAITCMD;
            break;

        case READINPUT:
                // read in the HTTP URL, any additional data.
                if(pClientInfo->pTCPClient->available() > 0 && pClientInfo->cbRead < sizeof(pClientInfo->rgbIn))
                {                        
                    pClientInfo->cbRead += pClientInfo->pTCPClient->readStream(&pClientInfo->rgbIn[pClientInfo->cbRead], sizeof(pClientInfo->rgbIn) - pClientInfo->cbRead);
                }
                pClientInfo->clientState = pClientInfo->nextClientState;
                break;

        case WAITCMD:
            // until we read something, match, or timeout, we keep reading and waiting.
            pClientInfo->clientState        =   READINPUT;
            pClientInfo->nextClientState    =   WAITCMD;

            // check the match strings, only if we have something to compare against
            if(pClientInfo->cbRead > 0)
            {
                bool fPartialMatch = false;

                // now look to see if HTML redering pages matches this URL
                for(uint32_t i = 0; i < CNTHTTPCMD; i++) 
                {
                    // does this entry have anything in it?
                    if(rgHttpCmd[i].cbMatch > 0)
                    {
                        uint32_t cbCmp = rgHttpCmd[i].cbMatch > pClientInfo->cbRead ? pClientInfo->cbRead : rgHttpCmd[i].cbMatch;

                        // see if we found a matching URL
                        if(memcmp(pClientInfo->rgbIn, rgHttpCmd[i].szMatchString, cbCmp) == 0)
                        {
                            // we either have a partial or full match
                            fPartialMatch = true;

                            // we have a full match; we know what dynamic page to call
                            if(cbCmp == rgHttpCmd[i].cbMatch)
                            {
                                pClientInfo->ComposeHTMLPage = rgHttpCmd[i].ComposeHTMLPage;
                                pClientInfo->clientState = DISPLAYTIME;
                                pClientInfo->tStartClient = tCur;

                                // fournd it, get out.
                                break;
                            }
                        }
                    }
                }


                // if we didn't find a perfect match, then lets see if we are done anyway
                if(pClientInfo->clientState == READINPUT)
                {
                    // only quit if we can't read anymore; our input buffer is full
                    // otherwise keep reading, we may get more bytes to give us a full match
                    if(!fPartialMatch || pClientInfo->cbRead == sizeof(pClientInfo->rgbIn) ||
                        (pClientInfo->cbRead >= 4 && 
                        pClientInfo->rgbIn[pClientInfo->cbRead-4] == '\r' && pClientInfo->rgbIn[pClientInfo->cbRead-3] == '\n' && 
                        pClientInfo->rgbIn[pClientInfo->cbRead-2] == '\r' && pClientInfo->rgbIn[pClientInfo->cbRead-1] == '\n'  ) )
                    {
                        pClientInfo->clientState = DEFAULTCMD;
                        pClientInfo->tStartClient = tCur;
                    }
                }
             }
            break;

        case DEFAULTCMD:
        	xil_printf("Default page called\r\n");
            pClientInfo->ComposeHTMLPage = DefaultHTMLPage;        
            pClientInfo->tStartClient = tCur;
            pClientInfo->clientState = DISPLAYTIME;
            break;

        case DISPLAYTIME:
            {
#ifndef NOTIME

                unsigned int epochTime = 0;
                char szTemp[256];

                epochTime = deIPcK.secondsSinceEpoch();
                GetDayAndTime(epochTime, szTemp);
                Serial.println(szTemp);
#endif
                pClientInfo->clientState = PROCESSHTML;   
                pClientInfo->tStartClient = tCur;
            }
            break;

        case PROCESSHTML:

            // process the HTML page
            switch((action = pClientInfo->ComposeHTMLPage(pClientInfo)))
            {
                // just come back to this state
                case GCMD::CONTINUE:
                    pClientInfo->clientState = PROCESSHTML;
                    break;

                // TODO, read more from the input.
                case GCMD::READ:
                    pClientInfo->nextClientState    =   PROCESSHTML;
                    pClientInfo->clientState        =   READINPUT;
                    break;

                // we have data to write out
                case GCMD::WRITE:
                    pClientInfo->nextClientState    = PROCESSHTML;
                    pClientInfo->clientState        = WRITEBUFFER;
                    break;

                // Done processing the client, close the client and get out
                case GCMD::DONE:
                    pClientInfo->nextClientState    = EXIT;         // we are done!
                    pClientInfo->clientState        = STOPCLIENT;
                    break;

                case GCMD::RESTART:
                    pClientInfo->nextClientState    = RESTART;      // we want to terminate the server
                    pClientInfo->clientState        = STOPCLIENT;
                    break;

                case GCMD::TERMINATE:
                    pClientInfo->nextClientState    = TERMINATE;   // we want to terminate the server
                    pClientInfo->clientState        = STOPCLIENT;
                    break;
     
                case GCMD::REBOOT:
                    pClientInfo->nextClientState    = REBOOT;       // we want to reboot the server
                    pClientInfo->clientState        = STOPCLIENT;
                    break;
     
                case GCMD::GETLINE:
                    pClientInfo->clientState        = PARSENEXTLINE;
                    break;

                default:
                	xil_printf("Unsupported compose command detected: %d\r\n",action);
                    pClientInfo->nextClientState    = EXIT;     // we are done!
                    pClientInfo->clientState        = STOPCLIENT;
                    break;
            }

            pClientInfo->cbWritten          = 0;
            pClientInfo->tStartClient       = tCur;
            break;

        case PARSENEXTLINE:
            {
                uint32_t    i                   = 0;
                bool     fFoundNewLine       = false;
                bool     fNullTerminator     = false;
 
                // we are looking for either a /r/n or a /0.
                // if we find the /r/n first, than replace the /r/n with /0 and that is our first line
                // otherwise if we find the /0, go find the next /r/n
                for(i = 0; i < pClientInfo->cbRead; i++)
                {
                    if( (fFoundNewLine = pClientInfo->rgbIn[i] == '\n')  ||
                        (fNullTerminator = pClientInfo->rgbIn[i] == '\0')                                   )
                    {
                         break;
                    }
                }

                // found the line end, terminate it and return.
                if(fFoundNewLine)
                {
                    pClientInfo->rgbIn[i] = '\0';
                    if(i > 0 && pClientInfo->rgbIn[i-1] == '\r')
                    {
                        pClientInfo->rgbIn[i-1] = '\0';
                    }
                    pClientInfo->clientState = PROCESSHTML; 
                }

                else if(fNullTerminator)
                {
                    // go to beyond the \0
                    for( ; i < pClientInfo->cbRead && pClientInfo->rgbIn[i] == '\0'; i++);
 
                    if(i == pClientInfo->cbRead)
                    {
                        // nothing left in the buffer to read, so we can reset it.
                        pClientInfo->cbRead             = 0;
                        pClientInfo->clientState        = READINPUT;
                        pClientInfo->nextClientState    = PARSENEXTLINE;
                        if(pClientInfo->rgbOverflow[0] != '\0')
                        {
                            pClientInfo->rgbIn[0] = pClientInfo->rgbOverflow[0];
                            pClientInfo->rgbOverflow[0] = '\0';
                            pClientInfo->cbRead = 1;
                        }
                    }

                    // copy the end of the buffer to the front of the buffer
                    // memcpy should be a safe overlapping copy.
                    else
                    {
                        pClientInfo->cbRead -= i;
                        memcpy(pClientInfo->rgbIn, &pClientInfo->rgbIn[i], pClientInfo->cbRead);
                        // stay at this state to go find the end of line
                    }
                }

                // this is a hard condition, our input buffer is full, and it doesn't even contain a full line.
                else if(i == sizeof(pClientInfo->rgbIn))
                {
                    // save away the last byte and return it as a line, even though there is a line break.
                    pClientInfo->rgbOverflow[0] = pClientInfo->rgbIn[sizeof(pClientInfo->rgbIn)-1];
                    pClientInfo->rgbIn[sizeof(pClientInfo->rgbIn)-1] = '\0';
                    pClientInfo->clientState = PROCESSHTML; 
                }

                // we need to read more data.
                else
                {
                    pClientInfo->clientState        = READINPUT;
                    pClientInfo->nextClientState    = PARSENEXTLINE;
                }
            }

            break;

        case WRITEBUFFER:

            // see if we are done

            if(pClientInfo->cbWritten == pClientInfo->cbWrite)
            {
                pClientInfo->clientState        = pClientInfo->nextClientState;
                pClientInfo->nextClientState    = STOPCLIENT;
                break;
            }

            // otherwise we have data to write
            pClientInfo->cbWritten += pClientInfo->pTCPClient->writeStream(&pClientInfo->pbOut[pClientInfo->cbWritten], pClientInfo->cbWrite - pClientInfo->cbWritten, &status);
            //xil_printf("%s", pClientInfo->pbOut);

            // got an error, terminate the connection
            if(IsIPStatusAnError(status))
            {
            	xil_printf("Error writing\r\n");
                pClientInfo->clientState        = STOPCLIENT;
                pClientInfo->nextClientState    = EXIT;
            }

            // or we are done now after the write
            else if(pClientInfo->cbWritten == pClientInfo->cbWrite)
            {
                pClientInfo->clientState        = pClientInfo->nextClientState;
                pClientInfo->nextClientState    = STOPCLIENT;
            }

            pClientInfo->tStartClient = tCur;
            break;

         case STOPCLIENT:  
        	 xil_printf("Closing connection for client: 0x%X\r\n", pClientInfo);
            pClientInfo->pTCPClient->close();
            if(pClientInfo->ComposeHTMLPage != NULL)
            {
                pClientInfo->htmlState = HTTPDISCONNECT;
                pClientInfo->ComposeHTMLPage(pClientInfo);
            }
            pClientInfo->clientState = pClientInfo->nextClientState;
            pClientInfo->tStartClient = tCur;
            return(GCMD::ADDSOCKET);
            break;
                     
        case EXIT:
            break;

        case RESTART:
        	xil_printf("Restart Commanded\r\n");
            return(GCMD::RESTART);
            break;

        case TERMINATE:
        	xil_printf("Termination Commanded\r\n");
            return(GCMD::TERMINATE);
            break;

        case REBOOT:
        	xil_printf("Reboot Commanded\r\n");
            return(GCMD::REBOOT);
            break;

        default:
        	xil_printf("Unknown client state: %d\r\n", pClientInfo->clientState);
            pClientInfo->clientState        = STOPCLIENT;
            pClientInfo->nextClientState    = EXIT;
            pClientInfo->tStartClient       = tCur;
            break;

    }

    return(GCMD::CONTINUE);
}

/***    bool AddHTMLPage(const char * szMatchStr, FNRENDERHTML FnComposeHTMLPage)
 *
 *    Parameters:
 *          szMatchStr -    A pointer to a constant string; this string MUST exist for the life of the sketch
 *                          typically this is a string stored in flash like -- static const char szHTMLFavicon[]   = "GET /favicon.ico "; --
 *  
 *          FnComposeHTMLPage - A pointer to the HTML Rendering page, for example: -- GCMD::ACTION ComposeHTMLRestartPage(CLIENTINFO * pClientInfo) --
 *                      
 *    Return Values:
 *          true if it was added, false if there was no room to add the page search string
 *
 *    Description: 
 *    
 *      In the simple case this searchs for HTTP GET commands and matches on the URL and then calls the associated Compose function. It is intentional that GET / is 
 *      part of the match string as this will also allow you to repond to POST. Also, you can do partial matches. For example if you have "GET /filesystem/" as your
 *      match string, the associated compose function would be called for GET commands like "GET /filesystem/dir1/object.x" because the first part of the string matches.
 *      This allows you to have some URL call dynamically generated pages like taking a realtime picture, OR you could have another URL access a filesystem by filename.
 *      The Compose function will get the full input string, so the compose function can independently parse the GET line.
 *      
 *      
 * ------------------------------------------------------------ */
bool AddHTMLPage(const char * szMatchStr, FNRENDERHTML FnComposeHTMLPage)
{
    for(uint32_t i = 0; i < CNTHTTPCMD; i++)
    {
        if(rgHttpCmd[i].cbMatch == 0)
        {
            rgHttpCmd[i].szMatchString      = szMatchStr;
            rgHttpCmd[i].cbMatch            = strlen(szMatchStr);
            rgHttpCmd[i].ComposeHTMLPage    = FnComposeHTMLPage;
            return(true);
        }
    }

    return(false);
}

/***    void SetDefaultHTMLPage(FNRENDERHTML FnDefaultHTMLPage)
 *
 *    Parameters:
 *          FnComposeHTMLPage - A pointer to the HTML Rendering page, for example: -- GCMD::ACTION ComposeHTMLDefaultPage(CLIENTINFO * pClientInfo) --
 *              
 *    Return Values:
 *          None
 *
 *    Description: 
 *    
 *      If no match strings match, than the default compose HTML page is called. This is optional as the HTTP 404 file not found page
 *      is initialized as the default page. Function allows you to replace the default.
 *      
 *      
 * ------------------------------------------------------------ */
void SetDefaultHTMLPage(FNRENDERHTML FnDefaultHTMLPage)
{
    DefaultHTMLPage    = FnDefaultHTMLPage;
}


/***    GCMD::ACTION JumpToComposeHTMLPage(CLIENTINFO * pClientInfo, FNRENDERHTML FnJumpComposeHTMLPage)
 *
 *    Parameters:
 *          pClientInfo             - a pointer to your current CLIENTINFO structure
 *          FnJumpComposeHTMLPage   - The page compose function you want to jump to 
 *              
 *    Return Values:
 *          GCMD::ACTION -  GCMD::CONTINUE is returned to start executing in the new compose page
 *                         
 *    Description: 
 *          You MUST pass your current pClientInfo as this will get processed.
 *          You MUST be prepared to leave your current compose page; you must be fully cleaned up
 *              as this compose function will NOT be called again. Cleanup all mutexes as if you
 *              got a HTTPDISCONNECT state; but your connection is NOT disconnecting, it will 
 *              be used in the jumped to compose page.
 *      
 * ------------------------------------------------------------ */
GCMD::ACTION JumpToComposeHTMLPage(CLIENTINFO * pClientInfo, FNRENDERHTML FnJumpComposeHTMLPage)
{   
    pClientInfo->htmlState          = HTTPSTART; 
    pClientInfo->ComposeHTMLPage    = FnJumpComposeHTMLPage;
    return(GCMD::CONTINUE);
}
