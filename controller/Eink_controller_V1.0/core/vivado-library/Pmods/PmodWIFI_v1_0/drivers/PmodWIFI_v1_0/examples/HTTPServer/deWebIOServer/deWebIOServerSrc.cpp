/************************************************************************/
/*                                                                      */
/*    deWebIOServerSrc                                                  */
/*                                                                      */
/*    A Example chipKIT HTTP Server implementation                      */
/*    This sketch is designed to work with web browser clients          */
/*                                                                      */
/************************************************************************/
/*    Author:     Keith Vogel                                           */
/*    Copyright 2014-2015, Digilent Inc.                                */
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
/*                                                                      */
/*    6/15/2014(KeithV): Created                                        */
/*    10/29/2015(KeithV): Updated to new SD implementation              */
/************************************************************************/
#include    "../HTTPServer.h"
#include "xil_io.h"

/************************************************************************/
/*    HTTP URL Matching Strings                                         */
/************************************************************************/
// These are the HTTP URL match strings for the dynamically created
// HTML rendering functions.
// Make these static const so they get put in flash
static const char szHTMLRestart[]       = "GET /Restart ";
static const char szHTMLTerminate[]     = "GET /Terminate ";
static const char szHTMLReboot[]        = "GET /Reboot ";
static const char szHTMLFavicon[]       = "GET /favicon.ico ";
static const char szHTMLGetPins[]       = "GET /PinsPage.htm ";
static const char szHTMLPostPins[]      = "POST /PinsPage.htm ";

// here is our sample/example dynamically created HTML page
GCMD::ACTION ComposeHTMLGetPINS(CLIENTINFO * pClientInfo);
GCMD::ACTION ComposeHTMLPostPINS(CLIENTINFO * pClientInfo);

// get rid of as much of the heap as we can, the SD library requires some heap
#define CHANGE_HEAP_SIZE(size) __asm__ volatile ("\t.globl _min_heap_size\n\t.equ _min_heap_size, " #size "\n")
CHANGE_HEAP_SIZE(0x200);

void loop(void);
/***    void setup(void)
 *
 *    Parameters:
 *          None
 *              
 *    Return Values:
 *          None
 *
 *    Description: 
 *    
 *      Arduino Master Initialization routine
 *      
 *      
 * ------------------------------------------------------------ */
int main(void)
{   
    // Must do a Serial.begin because the HTTP Server
    // has diagnostic prints in it.
	Xil_ICacheEnable();
	Xil_DCacheEnable();
	xil_printf("IOServer v1.0\r\n");
	xil_printf("Copyright 2015, Digilent Inc.\r\n");
	xil_printf("Written by Keith Vogel\r\n");

	setPmodWifiAddresses(XPAR_PMODWIFI_0_AXI_LITE_SPI_BASEADDR,
			XPAR_PMODWIFI_0_AXI_LITE_WFGPIO_BASEADDR,
			XPAR_PMODWIFI_0_AXI_LITE_WFCS_BASEADDR,
			XPAR_PMODWIFI_0_S_AXI_TIMER_BASEADDR);

#if defined(__MICROBLAZE__)
	setPmodWifiIntVector(XPAR_INTC_0_PMODWIFI_0_VEC_ID);
#else
	setPmodWifiIntVector(XPAR_FABRIC_PMODWIFI_0_WF_INTERRUPT_INTR);
#endif
	//Add pins to PinsPage.htm
	addPINs(XPAR_AXI_GPIO_0_BASEADDR, 4, 0);
	addPINs(XPAR_AXI_GPIO_0_BASEADDR+8, 4, 1);
	
	//Initialize system timer
    WF_TimerInit();

    // add rendering functions for dynamically created web pages
    // max of 10 AddHTMLPage() allowed 

    // these are the Select picture pages in Post.htm
    AddHTMLPage(szHTMLGetPins,      ComposeHTMLGetPINS);
    AddHTMLPage(szHTMLPostPins,     ComposeHTMLPostPINS);

    // comment this out if you do not want to support
    // restarting the network stack from a browser
    AddHTMLPage(szHTMLRestart,      ComposeHTMLRestartPage);

    // comment this out if you do not want to support
    // terminating the server from a browser
    AddHTMLPage(szHTMLTerminate,    ComposeHTMLTerminatePage);

    // comment this out if you do not want to support
    // rebooting (effectively hitting MCLR) the server from a browser
    AddHTMLPage(szHTMLReboot,       ComposeHTMLRebootPage);

    // This example supports favorite ICONs, 
    // those are those icon's next to the URL in the address line 
    // on the browser once the page is displayed.
    // To support those icons, have at the root of the SD file direcotory
    // an ICON (.ico) file with your ICON in it. The file MUST be named
    // favicon.ico. If you do not have an icon, then uncomment the following
    // line so the server will tell the browser with an HTTP file not found
    // error that we don't have a favoite ICON.
    // AddHTMLPage(szHTMLFavicon,      ComposeHTTP404Error);

    // Make reading files from the SD card the default compose function
    SetDefaultHTMLPage(ComposeHTMLSDPage);

    // Initialize the SD card
    SDSetup();

    // Initialize the HTTP server
    ServerSetup();

    while(1){
    	loop();
    }
    return 1;
}

/***    void loop(void) 
 *
 *    Parameters:
 *          None
 *              
 *    Return Values:
 *          None
 *
 *    Description: 
 *    
 *      Arduino Master Loop routine
 *      
 *      
 * ------------------------------------------------------------ */
void loop(void) 
{
    // process the HTTP Server
    ProcessServer();
}


