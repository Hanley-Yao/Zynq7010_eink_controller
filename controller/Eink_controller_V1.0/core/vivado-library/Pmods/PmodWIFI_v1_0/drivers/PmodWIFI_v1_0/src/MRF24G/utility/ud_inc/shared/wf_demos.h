/*******************************************************************************
 MRF24WG Demo Selection

  Summary: This module contains defines that allow selection of demos.

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

#ifndef __WF_DEMOS_H
#define __WF_DEMOS_H

#ifdef __cplusplus
extern "C" {
#endif


//------------------------------------------------------------------------------
// lwIP Demos (only one at a time can be selected)
//------------------------------------------------------------------------------


// Demo requires the python TCP server program (TBD.py) to be running on a laptop within
// the WiFi network.
#define TCP_CLIENT_DEMO


//------------------------------------------------------------------------------
// Network Defaults (specific to lwIP demo)
//------------------------------------------------------------------------------
#define DEFAULT_HOST_NAME           "MCHP_BOARD"

#define DEFAULT_IP_ADDR_BYTE1        (169)
#define DEFAULT_IP_ADDR_BYTE2        (254)
#define DEFAULT_IP_ADDR_BYTE3        (1)
#define DEFAULT_IP_ADDR_BYTE4        (1)

#define DEFAULT_MASK_BYTE1           (255)
#define DEFAULT_MASK_BYTE2           (255)
#define DEFAULT_MASK_BYTE3           (0)
#define DEFAULT_MASK_BYTE4           (0)

#define DEFAULT_GATE_BYTE1           (169)
#define DEFAULT_GATE_BYTE2           (254)
#define DEFAULT_GATE_BYTE3           (1)
#define DEFAULT_GATE_BYTE4           (1)



#ifdef __cplusplus
}
#endif


#endif /* __WF_DEMOS_H */

