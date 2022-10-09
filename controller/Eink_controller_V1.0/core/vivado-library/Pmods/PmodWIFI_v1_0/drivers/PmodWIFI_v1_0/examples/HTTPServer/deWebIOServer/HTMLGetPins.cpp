/************************************************************************/
/*                                                                      */
/*    HTMLGetIO.cpp                                                    */
/*                                                                      */
/*    Renders a simple dynamically generated HTML page                  */
/*                                                                      */
/************************************************************************/
/*    Author:     Keith Vogel                                           */
/*    Copyright 2014, Digilent Inc.                                     */
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
/*    6/18/2014(KeithV): Created                                        */
/************************************************************************/
// Required header
#include    "../HTTPServer.h"
#include "xparameters.h"
#include "xil_io.h"
#include "stdio.h"
#include "string.h"

/************************************************************************/
/*    Local Module Variables                                            */
/************************************************************************/


static CLIENTINFO * pClientMutex    = NULL;

static uint8_t rgDedicatedPins[] = DEDCATEDPINS;
u8 LEDS=0;

static u32 NUM_DIGITAL_PINS=0;
static GPIO gpio[128];
static uint32_t cbPage = 0;
static uint32_t iPin = 0;
static char szPinNbr[4];
static uint32_t cbPinNbr = 0;
static char szCurPinValue[] = "------";

static uint32_t cParsed = 0;
static uint32_t cbContentLenght = 0;
static uint32_t iIn = 0;

#define cModifiablePins (NUM_DIGITAL_PINS - (sizeof(rgDedicatedPins)/sizeof(rgDedicatedPins[0])))
/************************************************************************/
/*    HTML Strings                                                      */
/************************************************************************/
static const char szHTMLStart[] =
"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"> \n\
<html xmlns=\"http://www.w3.org/1999/xhtml\"> \n\
<head> \n\
<meta content=\"en-us\" http-equiv=\"Content-Language\" /> \n\
<meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\" /> \n\
<title>GPIO States</title> \n\
<style type=\"text/css\"> \n\
.auto-style1 { \n\
	color: #0000FF; \n\
} \n\
</style> \n\
</head> \n\
<body> \n\
		<div style=\"width:500px; margin:0px auto 20px;\" > \n\
			<img alt=\"Digilent Logo\" height=\"112\" src=\"Digilent.png\" width=\"500\" /> \n\
		</div> \n\
<p>GPIO States</p> \n\
<form method=\"post\" style=\"width: 785px\"> \n\
	<input name=\"PINS1\" type=\"submit\" value=\"Refresh\" /><br /><br />\n";

static const char szPin[]         = "Pin    : \n";
#define IPINNBR 7
static const char szDedicated[]   = "DEDICATED <br />\n";
static const char szState[]       = "<input type=\"radio\" value=\"X\" name=\"____\" ";
#define IVALUE 27       // index of the value field (X) is in the szState string
#define IPINNAME 40
static const char szChecked[]     = "checked=\"checked\" ";
static const char szTriState[]    = "/>TriState\n";
static const char szDigitalIn[]   = "/>Digital Input\n";
static const char szDigitalHigh[] = "/>Digital Output HIGH\n";
static const char szDigitalLow[]  = "/>Digital Output LOW\n";
static const char szAnalogIn[]    = "/>Analog Input\n";
static const char szPinValue[]    = "&nbsp;<span class=\"auto-style1\">Pin Value: ------</span><br />\n";
#define IPINVALUE 43

static const char szHTMLEnd[] =
"	<br /> \n\
	<input name=\"PINS2\" type=\"submit\" value=\"Refresh\" /> \n\
	</form> \n\
</body> \n\
</html> \n";

static const char szHIGH[] = "  HIGH";
static const char szLOW[]  = "   LOW";
static const char szTRI[]  = "------";

static const char szContentLength[] = "Content-Length: ";

/************************************************************************/
/*    State machine states                                              */
/************************************************************************/
// these are local to this file, and we can duplicate the names
// in other files as the compiler will not see these in other files.
// These are your local state machine states.
typedef enum {
    WRITEHTTP,
    WRITEHTMLSTART,
    WRITEPIN,
    WRITETRISTATE,
    WRITEDIGITALIN,
    WRITEDIGITALOUTLOW,
    WRITEDIGITALOUTHIGH,
    WRITEANALOGIN,
    WRITEDEDICATED,
    WRITEPINSTATE,
    WRITEHTMLEND,
    EXIT,
    JMPFILENOTFOUND,
    DONE
} STATEGet;


void inline pinMode(int pin, int state){
	if (state)//Input
		Xil_Out32(gpio[pin].baseaddr+4,Xil_In32(gpio[pin].baseaddr+4)|1<<gpio[pin].bitnum);
	else
		Xil_Out32(gpio[pin].baseaddr+4,Xil_In32(gpio[pin].baseaddr+4)&~1<<gpio[pin].bitnum);
}
void inline digitalWrite(int pin, int state){
	if (state)
		Xil_Out32(gpio[pin].baseaddr,Xil_In32(gpio[pin].baseaddr)|1<<gpio[pin].bitnum);
	else
		Xil_Out32(gpio[pin].baseaddr,Xil_In32(gpio[pin].baseaddr)&~(1<<gpio[pin].bitnum));
}
u32 inline digitalRead(int pin){
	return Xil_In32(gpio[pin].baseaddr)&1<<gpio[pin].bitnum;
}


/*
    There are 3 magic predefined states:

        HTTPSTART: 
            This is a required state to have.
            This is always the starting state and the first state
            in your compose function.

        HTTPDISCONNECT:
            Not a required state to have, but this state will be called whenever
            your conneciton is closed. This will always be called even if you
            return GCMD::DONE requesting the connection to be closed. This is
            nice because you can do clean up steps here, because no matter how
            the connection was closed, you get a chance to clean up.

        HTTPTIMEOUT:
            This is not a required state to have.
            This is called if the connection timed out, that is, the connection was
            made, your compose function got called but some pending data did not come in.
            For example if you returned a GCMD::GETLINE yet a line never came in.
*/

/***    GCMD::ACTION ComposeHTMLGetIO(CLIENTINFO * pClientInfo)
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
 *      This renders a page of the LEDs, BTNs, or SWTs on the device
 *      It reads a template page from the SD card, puts it into a temp
 *      RAM buffer, and then updates the template with acutal values
 * ------------------------------------------------------------ */
GCMD::ACTION ComposeHTMLGetPINS(CLIENTINFO * pClientInfo)
{
    int i                       = 0;
    int value                   = 0;
    char szT[sizeof(szCurPinValue)];

    GCMD::ACTION retCMD = GCMD::CONTINUE;

    switch(pClientInfo->htmlState)
    {
        case HTTPSTART:


            // serialize so we only do this page once at a time
            // this protects the szPageBuffer
            // we may have jumped here from the post; so the mutex
            // may already be set to me.
            if(!(pClientMutex == NULL || pClientMutex == pClientInfo))
            {
                break;
            }
            pClientMutex = pClientInfo;

            xil_printf("Get Pin Page Detected\r\n");

            xil_printf("Entering Client ID: 0x%X", (u32)pClientMutex);

            pClientInfo->htmlState = WRITEHTTP;
            break;

        // Put out the header
        case WRITEHTTP:
            pClientInfo->cbWrite = BuildHTTPOKStr(false, cbPage, ".htm", (char *) pClientInfo->rgbOut, sizeof(pClientInfo->rgbOut));
            pClientInfo->pbOut = pClientInfo->rgbOut;
            pClientInfo->htmlState = WRITEHTMLSTART;
            retCMD = GCMD::WRITE;
            break;

        case WRITEHTMLSTART:
            pClientInfo->pbOut = (byte *) szHTMLStart;
            pClientInfo->cbWrite = sizeof(szHTMLStart) - 1;
            pClientInfo->htmlState = WRITEPIN;
            iPin = 0;
            retCMD = GCMD::WRITE;
            break;

        case WRITEPIN:
            if(iPin < NUM_DIGITAL_PINS)
            {
            	sprintf(szPinNbr, "%d", (int)iPin);
                cbPinNbr = strlen(szPinNbr);
                memcpy(pClientInfo->rgbOut, szPin, sizeof(szPin)-1);
                memcpy(&pClientInfo->rgbOut[IPINNBR - cbPinNbr], szPinNbr, cbPinNbr);
                pClientInfo->cbWrite = sizeof(szPin) - 1;
                pClientInfo->pbOut = pClientInfo->rgbOut;
                pClientInfo->htmlState = WRITETRISTATE;
                retCMD = GCMD::WRITE;
            }
            else 
            {
                pClientInfo->htmlState = WRITEHTMLEND;
            }
            break;

        case WRITETRISTATE:
            if((gpio[iPin].pincap & TRISTATE) == TRISTATE)
            {
                memcpy(pClientInfo->rgbOut, szState, sizeof(szState)-1);
                pClientInfo->rgbOut[IVALUE] = 'T';
                memcpy(&pClientInfo->rgbOut[IPINNAME - cbPinNbr], szPinNbr, cbPinNbr);
                pClientInfo->cbWrite = sizeof(szState) - 1;
                if(gpio[iPin].pinState == TRISTATE)
                {
                    memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szChecked, sizeof(szChecked)-1);
                    pClientInfo->cbWrite += sizeof(szChecked) - 1;
                }
                memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szTriState, sizeof(szTriState)-1);
                pClientInfo->cbWrite += sizeof(szTriState)-1;
                pClientInfo->pbOut = pClientInfo->rgbOut;
                retCMD = GCMD::WRITE;
            }
            pClientInfo->htmlState = WRITEDIGITALIN;
            break;

        case WRITEDIGITALIN:
            if((gpio[iPin].pincap & DIGITALIN) == DIGITALIN)
            {
                memcpy(pClientInfo->rgbOut, szState, sizeof(szState)-1);
                pClientInfo->rgbOut[IVALUE] = 'D';
                memcpy(&pClientInfo->rgbOut[IPINNAME - cbPinNbr], szPinNbr, cbPinNbr);
                pClientInfo->cbWrite = sizeof(szState) - 1;
                if(gpio[iPin].pinState == DIGITALIN)
                {
                    memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szChecked, sizeof(szChecked)-1);
                    pClientInfo->cbWrite += sizeof(szChecked) - 1;
                }
                memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szDigitalIn, sizeof(szDigitalIn)-1);
                pClientInfo->cbWrite += sizeof(szDigitalIn)-1;
                pClientInfo->pbOut = pClientInfo->rgbOut;
                retCMD = GCMD::WRITE;
            }
            pClientInfo->htmlState = WRITEDIGITALOUTLOW;
            break;

        case WRITEDIGITALOUTLOW:
            if((gpio[iPin].pincap & DIGITALOUTLOW) == DIGITALOUTLOW)
            {
                memcpy(pClientInfo->rgbOut, szState, sizeof(szState)-1);
                pClientInfo->rgbOut[IVALUE] = 'L';
                memcpy(&pClientInfo->rgbOut[IPINNAME - cbPinNbr], szPinNbr, cbPinNbr);
                pClientInfo->cbWrite = sizeof(szState) - 1;
                if(gpio[iPin].pinState == DIGITALOUTLOW)
                {
                    memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szChecked, sizeof(szChecked)-1);
                    pClientInfo->cbWrite += sizeof(szChecked) - 1;
                }
                memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szDigitalLow, sizeof(szDigitalLow)-1);
                pClientInfo->cbWrite += sizeof(szDigitalLow)-1;
                pClientInfo->pbOut = pClientInfo->rgbOut;
                retCMD = GCMD::WRITE;
            }
            pClientInfo->htmlState = WRITEDIGITALOUTHIGH;
            break;

        case WRITEDIGITALOUTHIGH:
            if((gpio[iPin].pincap & DIGITALOUTHIGH) == DIGITALOUTHIGH)
            {
                memcpy(pClientInfo->rgbOut, szState, sizeof(szState)-1);
                pClientInfo->rgbOut[IVALUE] = 'H';
                memcpy(&pClientInfo->rgbOut[IPINNAME - cbPinNbr], szPinNbr, cbPinNbr);
                pClientInfo->cbWrite = sizeof(szState) - 1;
                if(gpio[iPin].pinState == DIGITALOUTHIGH)
                {
                    memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szChecked, sizeof(szChecked)-1);
                    pClientInfo->cbWrite += sizeof(szChecked) - 1;
                }
                memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szDigitalHigh, sizeof(szDigitalHigh)-1);
                pClientInfo->cbWrite += sizeof(szDigitalHigh)-1;
                pClientInfo->pbOut = pClientInfo->rgbOut;
                retCMD = GCMD::WRITE;
            }
            pClientInfo->htmlState = WRITEANALOGIN;
            break;

        case WRITEANALOGIN:
            if((gpio[iPin].pincap & ANALOGIN) == ANALOGIN)
            {
                memcpy(pClientInfo->rgbOut, szState, sizeof(szState)-1);
                pClientInfo->rgbOut[IVALUE] = 'A';
                memcpy(&pClientInfo->rgbOut[IPINNAME - cbPinNbr], szPinNbr, cbPinNbr);
                pClientInfo->cbWrite = sizeof(szState) - 1;
                if(gpio[iPin].pinState == ANALOGIN)
                {
                    memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szChecked, sizeof(szChecked)-1);
                    pClientInfo->cbWrite += sizeof(szChecked) - 1;
                }
                memcpy(&pClientInfo->rgbOut[pClientInfo->cbWrite], szAnalogIn, sizeof(szAnalogIn)-1);
                pClientInfo->cbWrite += sizeof(szAnalogIn)-1;
                pClientInfo->pbOut = pClientInfo->rgbOut;
                retCMD = GCMD::WRITE;
            }
            pClientInfo->htmlState = WRITEDEDICATED;
            break;

        case WRITEDEDICATED:
            if(gpio[iPin].pincap == DEDICATED)
            {
                pClientInfo->pbOut = (byte *) szDedicated;
                pClientInfo->cbWrite = sizeof(szDedicated) - 1;
                retCMD = GCMD::WRITE;
                iPin++;
                pClientInfo->htmlState = WRITEPIN;
            }
            else
            {
                pClientInfo->htmlState = WRITEPINSTATE;
            }
            break;

        case WRITEPINSTATE:

            switch(gpio[iPin].pinState)
            {
                // no value on pin
                case DEDICATED:
                case TRISTATE:
                    strcpy(szCurPinValue, szTRI);
                    break;

                // read the analog value from the pin
                case ANALOGIN:
                    value =0; //(analogRead(iPin) * 3300) / (ANALOGRANGE-1);
                    //itoa(value, szT, 10);
                    sprintf(szT, "%d", value);
                    i = strlen(szT);
                    i = sizeof(szCurPinValue) - i - 2;
                    memset(szCurPinValue, '0', sizeof(szCurPinValue)-1);
                    szCurPinValue[sizeof(szCurPinValue)-1] = '\0';
                    strcpy(&szCurPinValue[i], szT);
                    szCurPinValue[0] = szCurPinValue[1];
                    szCurPinValue[1] = '.';
                    szCurPinValue[sizeof(szCurPinValue)-2] = 'v';
                    break;

                // Must be a digital pin
                default:
                    if(digitalRead(iPin))
                    {
                        strcpy(szCurPinValue, szHIGH);
                    }
                    else
                    {
                        strcpy(szCurPinValue, szLOW);
                    }
                    break;
            }

            memcpy(pClientInfo->rgbOut, szPinValue, sizeof(szPinValue)-1);
            memcpy(&pClientInfo->rgbOut[IPINVALUE], szCurPinValue, sizeof(szCurPinValue)-1);
            pClientInfo->cbWrite = sizeof(szPinValue)-1;
            pClientInfo->pbOut = pClientInfo->rgbOut;
            retCMD = GCMD::WRITE;
            iPin++;
            pClientInfo->htmlState = WRITEPIN;
            break;

        // Read the template htm
        // Send the file
        case WRITEHTMLEND:
            pClientInfo->pbOut = (byte *) szHTMLEnd;
            pClientInfo->cbWrite = sizeof(szHTMLEnd) - 1;
            pClientInfo->htmlState = EXIT;
            retCMD = GCMD::WRITE;
            break;

         case EXIT:
        	 xil_printf("Wrote page cleanly\r\n");
            pClientInfo->htmlState = HTTPDISCONNECT;
            break;

        case JMPFILENOTFOUND:
        	xil_printf("Jumping to HTTP File Not Found page\r\n");
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

/***    void UpdatePin(const int iPin, const char pinState)
 *
 *    Parameters:
 *          iPin -  The pin number to update
 *          pinState - The Post letter disignator to modify the pin state
 *                          T - TriState
 *                          D - Digital input
 *                          L - Digital output set to a LOW state
 *                          H - Digital output set to a HIGH state
 *                          A - Analog input
 *              
 *    Return Values:
 *          None
 *
 *    Description: 
 *    
 *      Sets the pin state to the requested GPIO / Analog setting
 * ------------------------------------------------------------ */
static void UpdatePin(const u32 iPin, const char pinState)
{
    PINCFG pinCfg = DEDICATED;

    // a valid pin was sent
    if(iPin >= NUM_DIGITAL_PINS)
    {
        return;
    }

    // what state is requested
    switch(pinState)
    {
        case 'T':
            pinCfg = TRISTATE;
            break;
        case 'D':
            pinCfg = DIGITALIN;
            break;
        case 'L':
            pinCfg = DIGITALOUTLOW;
            break;
        case 'H':
            pinCfg = DIGITALOUTHIGH;
            break;
        case 'A':
            pinCfg = ANALOGIN;
            break;
        default:
            return;     // not a valid state
            break;
    }

    // we are already at that state, do nothing
    if(gpio[iPin].pinState == pinCfg)
    {
        return;
    }

    // going to change the state of the pin
    // make sure the pins supports it
    if((gpio[iPin].pincap & pinCfg) != pinCfg)
    {
        return;
    }

    // change the state of the pin
    switch(pinCfg)
    {
        case TRISTATE:
        case DIGITALIN:
        case ANALOGIN:
            pinMode(iPin, INPUT);
            break;
        case DIGITALOUTLOW:
            pinMode(iPin, OUTPUT);
            digitalWrite(iPin, LOW);
            break;
        case DIGITALOUTHIGH:
            pinMode(iPin, OUTPUT);
            digitalWrite(iPin, HIGH);
           break;
        default:
            return;
            break;
    }

    gpio[iPin].pinState = pinCfg;

    return;
}

/************************************************************************/
/*    State machine states                                              */
/************************************************************************/
// these are local to this file, and we can duplicate the names
// in other files as the compiler will not see these in other files.
// These are your local state machine states.
typedef enum {
    CONTLEN,
    ENDHDR,
    DATA,
    GETPAGE,
    FINISH
} STATEPost;


/*
    There are 3 magic predefined states:

        HTTPSTART: 
            This is a required state to have.
            This is always the starting state and the first state
            in your compose function.

        HTTPDISCONNECT:
            Not a required state to have, but this state will be called whenever
            your conneciton is closed. This will always be called even if you
            return GCMD::DONE requesting the connection to be closed. This is
            nice because you can do clean up steps here, because no matter how
            the connection was closed, you get a chance to clean up.

        HTTPTIMEOUT:
            This is not a required state to have.
            This is called if the connection timed out, that is, the connection was
            made, your compose function got called but some pending data did not come in.
            For example if you returned a GCMD::GETLINE yet a line never came in.
*/

/***    GCMD::ACTION ComposeHTMLPostPicture(CLIENTINFO * pClientInfo)
 *
 *    Parameters:
 *          pClientInfo - the client info representing this connection and web page
 *
 *    Return Values:
 *          GCMD::ACTION    - GCMD::CONTINUE, just return with no outside action
 *                          - GCMD::READ, non-blocking read of input data into the rgbIn buffer appended to the end of rgbIn[] which has a predefined size of 256 bytes
 *                              when we return to this compose function cbRead will have the number of bytes read, and likely could be zero.
 *                          - GCMD::GETLINE, blocking read until a line of input is read or until the rgbIn buffer is full, always the line starts at the beginnig of the rgbIn
 *                              cbRead has the number of bytes read
 *                          - GCMD::WRITE, loop writing until all cbWrite bytes are written from the pbOut buffer
 *                              pbOut can point to any valid buffer that will remain unchanged until execution returns to this function. We could get a TIMOUT
 *                              if we can't write the data. cbWritten will have the number of bytes actually written. As part of each connection there is a
 *                              scratch buffer of 256 provide at rgbOut; it is optional to point pbOut to rgbOut. PbOut can point anywhere and that is what will be written
 *                              cbWrite must be set to the number of bytes to write.
 *                          - GCMD::DONE, we are done processing and the connection can be closed
 *
 *    Description:
 *
 *      This parsge the Post command and sets the picture to print
 *      and jumps to the SelPic page to redraw the picture.
 *
 * ------------------------------------------------------------ */
GCMD::ACTION ComposeHTMLPostPINS(CLIENTINFO * pClientInfo)
{
    GCMD::ACTION retCMD = GCMD::CONTINUE;

    // a word of caution... DO NOT cast htmlState to your enum type!
    // the compiler will silently remove the HTTPSTART case as
    // that state is not part of your enum. Keep the switch on typed
    // aginst the generic uint32_t.
    switch(pClientInfo->htmlState)
    {

        // Every Compose function will start at the magic HTTPSTART state
        // we MUST support this state.
        case HTTPSTART:

            // serialize so we only do this page once at a time
            // this protects the szPageBuffer
            if(pClientMutex != NULL)
            {
                break;
            }
            pClientMutex = pClientInfo;

            xil_printf("Post Pins Page Detected\r\n");
            pClientInfo->htmlState = CONTLEN;
            retCMD = GCMD::GETLINE;
            break;

        case CONTLEN:

            // if we hit the end of the header then there was no content length
            // and we don't know how to handle that, so exit with an error
            // File not found is probably the wrong error, but it does get out out
            // Fortunately all major browsers put in the content lenght, so this
            // will almost never fail.
            if(strlen((char *) pClientInfo->rgbIn) == 0)    // cbRead may be longer than just the line, so do a strlen()
            {
                pClientMutex = NULL;
                return(JumpToComposeHTMLPage(pClientInfo, ComposeHTTP404Error));
            }

            // found the content lengths
            else if(memcmp((byte *) szContentLength, pClientInfo->rgbIn, sizeof(szContentLength)-1) == 0)
            {

                cbContentLenght = atoi((char *) &pClientInfo->rgbIn[sizeof(szContentLength)-1]);
                pClientInfo->htmlState = ENDHDR;
            }
            retCMD = GCMD::GETLINE;
            break;

        case ENDHDR:

            // the header is ended with a double \r\n\r\n, so I will get
            // a zero length line. Just keep reading lines until we get to the blank line
            if(strlen((char *) pClientInfo->rgbIn) == 0)    // cbRead may be longer than just the line, so do a strlen()
            {
                uint32_t i = 0;

                // go to beyond the \0
                for(i = 0; i < pClientInfo->cbRead && pClientInfo->rgbIn[i] == '\0'; i++);

                // move the buffer to the front
                pClientInfo->cbRead -= i;
                if(pClientInfo->cbRead > 0)
                {
                    memcpy(pClientInfo->rgbIn, &pClientInfo->rgbIn[i], pClientInfo->cbRead);
                }

                pClientInfo->htmlState = DATA;
                cParsed = 0;
                iIn = 0;
            }
            else
            {
                retCMD = GCMD::GETLINE;
            }
            break;

        case DATA:

            if(cParsed < cModifiablePins)
            {
                char * pUnderscore = NULL;

                // because we are doing string searches, we need to make sure there is a null terminator on the string
                // remember, we have 4 extra overflow byes at the end of the read buffer we can write into, so even if
                // the rgbIn buffer is completely full, we can write one past the end with the zero terminator.
                pClientInfo->rgbIn[pClientInfo->cbRead] = '\0';

                // there are other things in the form post besides the pin values, specifically
                // there is the submit button entry, so we need to skip about anything that is not a pin state
                // search for an underscore, that is the start of the pin number
                if((pUnderscore = strstr((char *) &pClientInfo->rgbIn[iIn], "_")) != NULL)
                {
                    // move up to the underscore, the start of the pin number
                    iIn += ((byte *) pUnderscore - &pClientInfo->rgbIn[iIn]);
                }

                if((pClientInfo->cbRead - iIn) < sizeof(PINDATA))
                {
                    memcpy(pClientInfo->rgbIn, &pClientInfo->rgbIn[iIn], (pClientInfo->cbRead - iIn));
                    pClientInfo->cbRead -= iIn;
                    iIn = 0;
                    retCMD = GCMD::READ;
                }
                else
                {
                    uint32_t i = 0;
                    PINDATA * ppinData = (PINDATA *) &pClientInfo->rgbIn[iIn];

                    iIn += sizeof(PINDATA);
                    cParsed++;
                    for(i=0; i<sizeof(ppinData->szPin); i++)
                    {
                        if(ppinData->szPin[i] == '_')
                        {
                            ppinData->szPin[i] = ' ';
                        }
                        else
                        {
                            break;
                        }
                    }

                    if(i<sizeof(ppinData->szPin))
                    {
                        ppinData->equal = '\0';
                        i = atoi(&ppinData->szPin[i]);
                        UpdatePin(i, ppinData->state);
                    }
                }
            }
            else
            {
                pClientInfo->htmlState = GETPAGE;
            }
            break;

        case GETPAGE:
        	xil_printf("Jumping to Pins Page\r\n");
            return(JumpToComposeHTMLPage(pClientInfo, ComposeHTMLGetPINS));
            break;

        case HTTPDISCONNECT:
            if(pClientMutex == pClientInfo)
            {
            	xil_printf("Closing Client ID: 0x%X\r\n", pClientMutex);
                pClientMutex = NULL;
            }
            // fall thru Done

        // the done state is were we say we are done, and that
        // the connection can be closed
        case FINISH:
        default:

            // by returning DONE, we will close the connection
            // and be done with this page
            retCMD = GCMD::DONE;
            break;
    }

    // Return the command we want to do
    // like WRITE, or DONE
    return(retCMD);
}

/***    void InitializePins(void)
 *
 *    Parameters:
 *          None
 *
 *    Return Values:
 *          None
 *
 *    Description:
 *
 *      Intialize the capabilities of the pins and 
 *      set all pins to input
 *
 * ------------------------------------------------------------ */
void InitializePins(void)
{
    uint32_t i = 0;

    memset(gpio, 0, sizeof(gpio));
    cbPage = 0;

    for(i=0; i<NUM_DIGITAL_PINS; i++)
    {

        // macro assumption about the pin
        gpio[i].pincap = TRISTATE | DIGITALIN | DIGITALOUTLOW | DIGITALOUTHIGH;
        gpio[i].pinState = TRISTATE;

        // we know the first 14 pins are not analog on chipKIT devices
        // but then we have to check to see if it is an analog pin
//        if(i>=14 && digitalPinToAnalog(i) != NOT_ANALOG_PIN)
//        {
//            gpio[i].pincap |= ANALOGIN;
//        }
    }

    // take out dedicated pins
    for(i=0; i<(sizeof(rgDedicatedPins)/sizeof(rgDedicatedPins[0])); i++)
    {
        gpio[rgDedicatedPins[i]].pincap     = DEDICATED;
        gpio[rgDedicatedPins[i]].pinState   = DEDICATED;
    }

    // set the pin state to a known state
    for(i=0; i<NUM_DIGITAL_PINS; i++)
    {
        // add up the pin count
        cbPage += sizeof(szPin) - 1;

        if(gpio[i].pincap & TRISTATE)
        {
            cbPage += sizeof(szState) + sizeof(szTriState) - 2;
        }

        if(gpio[i].pincap & ANALOGIN)
        {
            cbPage += sizeof(szState) + sizeof(szAnalogIn) - 2;
        }

        if(gpio[i].pincap & DIGITALIN)
        {
            cbPage += sizeof(szState) + sizeof(szDigitalIn) - 2;
        }

        if(gpio[i].pincap & DIGITALOUTLOW)
        {
            cbPage += sizeof(szState) + sizeof(szDigitalLow) - 2;
        }
        if(gpio[i].pincap & DIGITALOUTHIGH)
        {
            cbPage += sizeof(szState) + sizeof(szDigitalHigh) - 2;
        }

        if(gpio[i].pincap)
        {
            cbPage += sizeof(szPinValue) + sizeof(szChecked) - 2;
        }
        else
        {
            cbPage += sizeof(szDedicated) - 1;
        }

        switch(gpio[i].pinState)
        {
            case TRISTATE:
                pinMode(i, INPUT);
                break;
            default:
                break;
        }
    }

    cbPage += sizeof(szHTMLStart) + sizeof(szHTMLEnd) - 2;
}



/***    void addPINs(u32 BASE_ADDR, u32 num_pins, bool input)
 *
 *    Parameters:
 *          BASE_ADDR	-	Base Address of the GPIO block
 *          num_pins	-	GPIO Width (number of pins)
 *          input		-	1 if input 0 if output
 *
 *    Return Values:
 *          None
 *
 *    Description:
 *
 *			Adds pins to the GPIO array which is posted on
 *			PinsPage.htm
 *
 * ------------------------------------------------------------ */
void addPINs(u32 BASE_ADDR, u32 num_pins, bool input){
	if (cbPage==0){
		cbPage += sizeof(szHTMLStart) + sizeof(szHTMLEnd) - 2;
	}
	for (u32 i=NUM_DIGITAL_PINS; i<NUM_DIGITAL_PINS+num_pins; i++){
		cbPage += sizeof(szPin) - 1;
		cbPage += sizeof(szPinValue) + sizeof(szChecked) - 2;
		gpio[i].baseaddr=BASE_ADDR;
		gpio[i].bitnum=i-NUM_DIGITAL_PINS;
		if (input){
			cbPage += sizeof(szState) + sizeof(szDigitalIn) - 2;
			pinMode(i, 1);
			gpio[i].pincap=DIGITALIN;
			gpio[i].pinState=DIGITALIN;

		}
		else{
			pinMode(i, 0);
			cbPage += sizeof(szState) + sizeof(szDigitalLow) - 2;
			cbPage += sizeof(szState) + sizeof(szDigitalHigh) - 2;
			gpio[i].pincap=DIGITALOUTLOW | DIGITALOUTHIGH;
			gpio[i].pinState=DIGITALOUTLOW;
		}
	}
	NUM_DIGITAL_PINS+=num_pins;
}

