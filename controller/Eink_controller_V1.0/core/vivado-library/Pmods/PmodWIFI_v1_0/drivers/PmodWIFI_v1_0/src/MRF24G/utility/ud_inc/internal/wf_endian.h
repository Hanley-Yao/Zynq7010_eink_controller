/*******************************************************************************
 MRF24WG Universal Driver Endian control

  Summary: This module contains endian defintions

  Description: None
*******************************************************************************/

/* MRF24WG0M Universal Driver
*
* Copyright (c) 2012-2013, Microchip <www.microchip.com>
* Contact Microchip for the latest version.
*
* This program is free software; distributed under the terms of BSD
* license:
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

#ifndef __WF_ENDIAN_H
#define __WF_ENDIAN_H

// #include "wf_universal_driver.h"

#ifdef __cplusplus
extern "C" {
#endif


// if host is little-endian then need to convert as MRF24WG is big-endian
#if defined(LITTLE_ENDIAN) && !defined(BIG_ENDIAN)
    #define htons(A) ((((uint16_t)(A) & 0xff00) >> 8) | \
                      (((uint16_t)(A) & 0x00ff) << 8))

    #define htonl(A) ((((uint32_t)(A) & 0xff000000) >> 24) | \
                      (((uint32_t)(A) & 0x00ff0000) >> 8)  | \
                      (((uint32_t)(A) & 0x0000ff00) << 8)  | \
                      (((uint32_t)(A) & 0x000000ff) << 24))
    #define ntohs  htons

#define ntohl  htonl

// else if host is big-endian, no need to convert
#elif defined(BIG_ENDIAN) && !defined(LITTLE_ENDIAN)
    #define htons(A) (A)
    #define htonl(A) (A)
    #define ntohs(A) (A)
    #define ntohl(A) (A)
#else
    #warning "Must define either BIG_ENDIAN or LITTLE_ENDIAN" // NOTE(andreW): Currently the compiler will always trip on this preprocessor, and as an #error will fail the build step. This solution allows compilation without removing the message.
#endif

#ifdef __cplusplus
}
#endif


#endif /* __WF_ENDIAN_H */

