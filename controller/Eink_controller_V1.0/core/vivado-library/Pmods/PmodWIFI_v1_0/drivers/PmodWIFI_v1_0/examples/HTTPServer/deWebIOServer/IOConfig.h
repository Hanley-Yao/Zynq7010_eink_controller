/************************************************************************/
/*                                                                      */
/*    IOConfgi.h                                                        */
/*                                                                      */
/*    Simple mapping of LEDs, BTNs, or SWTs for the demo per board      */
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
//#if "xparameters.h"
//#include "xparameters.h"
//#endif


#if defined(_BOARD_UC32_)       // this assumes a BasicIO Shield is attached

    // services for the SD card, status LED and Serial Camera
    // these are required for the HTTP library and the Camera library
    #define PIN_SDCS        4
    #define PIN_LED_SAFE    PIN_LED2
    #define CAMSERIAL       Serial1

    // pin 0,1: Serial Monitor UART
    // pin 2, MRF24 INT
    // pin PIN_SDCS: Chip Select for the uSD
    // SS, 44: CS for the MRF24
    // MOSI, MISO, SCK: SPI to the uSD and MRF24
    // PIN_LED_SAFE: Heartbeat LED
    // 34,35,36: MRF24 HIB, WP, RESET
    #define DEDCATEDPINS {0, 1, 2, PIN_SDCS, SS, 34, 35, 36, 44, MOSI, MISO, SCK, PIN_LED_SAFE}

#elif defined (_BOARD_WF32_)

    // services for the SD card, status LED and Serial Camera
    // these are required for the HTTP library and the Camera library
    #define PIN_SDCS        51
    #define PIN_LED_SAFE    PIN_LED4
    #define CAMSERIAL       Serial1

    // pin 0,1: Serial Monitor UART
    // 49 - 59, uSD and MRF24
    // PIN_LED_SAFE: Heartbeat LED
    #define DEDCATEDPINS {0, 1, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, PIN_LED_SAFE}

#elif defined (_BOARD_WIFIRE_)

    // services for the SD card, status LED and Serial Camera
    // these are required for the HTTP library and the Camera library
    #define PIN_SDCS        52
    #define PIN_LED_SAFE    PIN_LED4
    #define CAMSERIAL       Serial1

    // pin 0,1: Serial Monitor UART
    // 51 - 61, uSD and MRF24
    // PIN_LED_SAFE: Heartbeat LED
    #define DEDCATEDPINS {0, 1, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, PIN_LED_SAFE}

#elif defined (_BOARD_MEGA_)

    // services for the SD card, status LED and Serial Camera
    // these are required for the HTTP library and the Camera library
    #define PIN_SDCS        4
    #define PIN_LED_SAFE    PIN_LED2
    #define CAMSERIAL       Serial1

    // pin 0,1: Serial Monitor UART
    // 4,29,43,53   uSD
    // 2,53,78,80   MRF24
    // PIN_LED_SAFE: Heartbeat LED

    #define DEDCATEDPINS {0, 1, 2, PIN_SDCS, 29, 43, 52, 53, 78, 80, PIN_LED_SAFE}

#elif defined (_BOARD_CEREBOT_MX7CK_) || defined(_BOARD_CEREBOT_32MX7_)

    // PmodSD on JD, Pmod
    // services for the SD card, status LED and Serial Camera
    // these are required for the HTTP library and the Camera library
    #define PIN_SDCS        PIN_DSPI0_SS
    #define PIN_LED_SAFE    PIN_LED1
    #define CAMSERIAL       Serial1

    // pin 33,34: Serial Monitor UART
    // 24,25,26,27   SD
    // 40,41,42,43,44,45,46,48   MRF24
    // PIN_LED_SAFE: Heartbeat PIN_LED1

    #define DEDCATEDPINS {33,34,24,25,26,27,40,41,42,43,44,45,46,48,PIN_LED_SAFE}

#elif defined (_BOARD_CEREBOT_MX4CK_) || defined(_BOARD_CEREBOT_32MX4_)

    // PmodSD on JK, PmodWiFi on JB
    // services for the SD card, status LED and Serial Camera
    // these are required for the HTTP library and the Camera library
    #define PIN_SDCS        SD_CS_PIN
    #define PIN_LED_SAFE    PIN_LED1
    #define CAMSERIAL       Serial1

    // pin 33,34: Serial Monitor UART
    // 64,65,66,67   SD, Top of JK
    // 8,9,10,11,12,13,14,15   MRF24, JB
    // PIN_LED_SAFE: Heartbeat PIN_LED1

    #define DEDCATEDPINS {33,34,64,65,66,67,8,9,10,11,12,13,14,15,PIN_LED_SAFE}

#elif defined (XPAR_CPU_ID)//Microblaze/ZYNQ
	#define DEDCATEDPINS {}
	
	#define INPUT 1
	#define OUTPUT 0
	#define LOW 0
	#define HIGH 1



#else
    #error HTTP Server does not support this board
#endif

typedef enum
{
    DEDICATED       = 0b00000,
    TRISTATE        = 0b00001,
    ANALOGIN        = 0b00010,
    DIGITALIN       = 0b00100,
    DIGITALOUTLOW   = 0b01000,
    DIGITALOUTHIGH  = 0b10000
} PINCFG;

typedef uint32_t PINCAP;

typedef struct _GPIO
{
    PINCAP  pincap;     // what this pin can be (can it be analog?)
    PINCFG  pinState;   // what it is currently set to be
    u32 	baseaddr;	// Zybo/Microblaze Designs only, the base address of the GPIO block
    u8		bitnum;		// Zybo/Microblaze Designs only, the bit number of the LED
} GPIO;

typedef struct _PINDATA
{
    char szPin[4];
    char equal;
    char state;
} __attribute__((packed)) PINDATA;

#if defined(__PIC32MZ__)
    #define ANALOGRANGE 4096
#else
    #define ANALOGRANGE 1024
#endif

extern void InitializePins(void);
void addPINs(u32 BASE_ADDR, u32 num_pins, bool input);

