/*******************************************************************************
 MRF24WG Universal Driver Customization.

  Summary: This module contains defines that allow for customization of the
           Universal Driver.

  Description: None
*******************************************************************************/

/*******************************************************************************
FileName:   wf_customize.h

Copyright (C) 2012 Microchip Technology Inc. and its subsidiaries (Microchip).
All rights reserved.
You are permitted to use the software and its derivatives with Microchip products.
See the license agreement accompanying this software, if any, for additional info
regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED ?AS IS? WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP, SMSC, OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY FOR ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
DAMAGES, OR OTHER SIMILAR COSTS.
*******************************************************************************/

#ifndef __WF_CUSTOMIZE_H
#define __WF_CUSTOMIZE_H

#ifdef __cplusplus
extern "C" {
#endif



//------------------------------------------------------------------------------
// Set the Host endianness to BIG_ENDIAN or LITTLE_ENDIAN.  The MRF24WG is big-endian.
// The numbers are only needed to match the lwIP defines.  It is normally OK to
// simply use: #define LITTLE_ENDIAN
//------------------------------------------------------------------------------
#define LITTLE_ENDIAN 1234      // or #define BIG_ENDIAN 4321

//------------------------------------------------------------------------------
// Compiler specific keyword used for inline functions.  Customize for your compiler.
// If inline functions are not supported make the define empty.
//------------------------------------------------------------------------------
#if defined(__MICROBLAZE__)||defined(__arm__)
#define INLINE
#else
#define INLINE inline
#endif
// TODO: need OVERLAY_MEMORY_USED switch for global variables in interrupt?


//------------------------------------------------------------------------------
// This define allows host code to calculate a PSK binary key when using a WPA/WPA2
// passphrase.  It is also required for WPS passphrase calculation on the host.
//
// When WF_USE_HOST_WPA_KEY_CALCULATION is defined, then WF_ConvWpaPassphraseToKey()
// will be compiled into the build along with supporting code.
// For PIC32 it consumes 8184 code bytes optimized, 18548 code bytes unoptimized.
//
// If this feature is not used than the MRF24WG will calculate PSK keys, taking
// about 30 seconds to do so.  In comparision, a PIC32, running at 80MHz, can do
// the binary key generation in about 4 seconds.
//------------------------------------------------------------------------------
#define WF_USE_HOST_WPA_KEY_CALCULATION

//------------------------------------------------------------------------------
// This define is used to compile in all code related to WPS security.  If you
// are not using WPS security then comment it out to save some code and data
// space.
//------------------------------------------------------------------------------
#define WF_USE_WPS_SECURITY

//------------------------------------------------------------------------------
// The MRF24WG supports two options for utilizing multicast filters, only one of
// which can be selected.
//
//   WF_USE_HARDWARE_MULTICAST_FILTER
//   --------------------------------
//   Support 2 hardware multicast filters.  Allows configuration of up to two
//   multicast filters where all of the 6 MAC bytes must match before the
//   message is forwarded to the host.  These filters are controlled with
//   MRF24WG hardware and are very fast.  To select this option, uncomment
//   the WF_USE_HARDWARE_MULTICAST_FILTER define below.
//
//   WF_USE_SOFTWARE_MULTICAST_FILTER
//   --------------------------------
//   Support up to 16 software multicast filters.  Allows configuration of up to
//   16 multicast filters.  Each filter supports individual byte masking so one
//   can filter on a partial MAC address.  For example, one could filter on
//   Multicast Address of 01:00:5e:xx:xx:xx where xx are don't care bytes.  The
//   filtering is done with software and is not as efficient as the above option.
//
//  If multicast filters are not needed for the application, simply comment
//  out both options.  
//------------------------------------------------------------------------------
#define WF_USE_HARDWARE_MULTICAST_FILTER
//#define WF_USE_SOFTWARE_MULTICAST_FILTER

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Error Checking Below This Point -- DO NOT REMOVE
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
#if defined(WF_USE_HARDWARE_MULTICAST_FILTER) && defined(WF_USE_SOFTWARE_MULTICAST_FILTER)
    #error "Cannot define both WF_USE_HARDWARE_MULTICAST_FILTER and WF_USE_SOFTWARE_MULTICAST_FILTER."
#endif

#ifdef __cplusplus
}
#endif


#endif /* __WF_CUSTOMIZE_H */



