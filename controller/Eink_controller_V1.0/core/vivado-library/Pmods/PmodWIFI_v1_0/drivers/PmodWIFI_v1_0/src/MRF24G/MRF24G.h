/************************************************************************/
/*                                                                      */
/*    MRF24G.h                                                          */
/*          MRF24WG0MA support                                          */
/*          Not to be confused with the older MRF24WB0MA                */
/*                                                                      */
/*                                                                      */
/*    Supports:                                                         */
/*                                                                      */
/*  uC32 JP5&7 on Master with WiFi Shield                               */
/*  uC32 JP5&7 on Master with PmodShield and PmodWiFi on connector JC   */
/*  Max32 JP3&4 on Master with WiFi Shield                              */
/*  Max32 JP3&4 on Master with PmodShield and PmodWiFi on connector JC  */
/*  MX3cK JP6&8 on Master with PmodWiFi on connector JE                 */
/*  MX3cK-512 JP6&8 on Master with PmodWiFi on connector JE             */
/*  MX4ck JP3 on INT3 with PmodWiFi on connector JB                     */
/*  MX7ck with PmodWiFi on connector JF                                 */
/*  WF32 Uses on board WiFi MRF24WG0MA                                  */
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
/*                                                                      */
/*    12/5/2013(KeithV): Created                                        */
/*                                                                      */
/************************************************************************/
#ifndef MRF24G_H
#define MRF24G_H

#if defined(_DEIPCK_H)
    #error DEIPcK.h must be included after MRF24G.h
#elif defined( _DEWFCK_H)
    #error DEWFcK.h must be included after MRF24G.h
#endif

#ifndef DEIPINCLUDECODEHERE
#define DEIPINCLUDECODEHERE
#endif

#endif // MRF24G_H