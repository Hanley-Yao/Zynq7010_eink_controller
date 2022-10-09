/************************************************************************/
/*                                                                      */
/*  SPIandINT.h  Macros to set up the SPI and Interrupts needed for     */
/*               the MRF Universal Driver                               */
/*                                                                      */
/************************************************************************/
/*  Author: Keith Vogel                                                 */
/*          Copyright 2013, Digilent Inc.                               */
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
/*  Module Description:                                                 */
/*                                                                      */
/*      Macros to set up the SPI and Interrupt values for the MRF24 UD  */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*  10/16/2012(KeithV): Created                                         */
/*                                                                      */
/************************************************************************/

#ifndef SPIANDINT_H
#define	SPIANDINT_H

#ifdef	__cplusplus
extern "C" {
#endif

// some pasting macros
#define CAT1_2(a,b)         a##b
#define CAT_2(a,b)          CAT1_2(a,b)
#define CAT_3(a,b,c)        CAT_2(CAT_2(a,b),c)
#define CAT_4(a,b,c,d)      CAT_2(CAT_2(a,b),CAT_2(c,d))
#define CAT_5(a,b,c,d,e)    CAT_2(CAT_3(a,b,c),CAT_2(d,e))

// set up the interrupt values
#define WF_INT_VEC  CAT_3(_EXTERNAL_,WF_INT,_VECTOR)    // _EXTERNAL_x__VECTOR

#if defined(__PIC32MZ__)
    #define WF_INT_IRQ WF_INT_VEC
#else
    #define WF_INT_IRQ  CAT_3(_EXTERNAL_,WF_INT,_IRQ)       // _EXTERNAL_x_IRQ
#endif

#if (WF_INT_IRQ < 32)
    #define WIFI_INT_IFREG_INT  0_INT
    #define WIFI_INT_IFREG      0
    #define WIFI_IECxCLR        IEC0CLR
    #define WIFI_IFSxCLR        IFS0CLR
    #define WIFI_IECxSET        IEC0SET
    #define WIFI_IFSxSET        IFS0SET
#elif (WF_INT_IRQ < 64)
    #define WIFI_INT_IFREG_INT  1_INT
    #define WIFI_INT_IFREG      1
    #define WIFI_IECxCLR        IEC1CLR
    #define WIFI_IFSxCLR        IFS1CLR
    #define WIFI_IECxSET        IEC1SET
    #define WIFI_IFSxSET        IFS1SET
#elif (WF_INT_IRQ < 96)
    #define WIFI_INT_IFREG_INT  2_INT
    #define WIFI_INT_IFREG      2
    #define WIFI_IECxCLR        IEC2CLR
    #define WIFI_IFSxCLR        IFS2CLR
    #define WIFI_IECxSET        IEC2SET
    #define WIFI_IFSxSET        IFS2SET
#else
    #error WiFi interrupt not supported
#endif

#if (WF_INT_IRQ < 4)
        #define WIFI_INT_IPCREG      0
#elif (WF_INT_IRQ < 8)
        #define WIFI_INT_IPCREG      1
#elif (WF_INT_IRQ < 12)
        #define WIFI_INT_IPCREG      2
#elif (WF_INT_IRQ < 16)
        #define WIFI_INT_IPCREG      3
#elif (WF_INT_IRQ < 20)
        #define WIFI_INT_IPCREG      4
#elif (WF_INT_IRQ < 24)
        #define WIFI_INT_IPCREG      5
#endif

#define WIFI_INT_MASK   CAT_4(_IEC,WIFI_INT_IFREG_INT,WF_INT,IE_MASK)   // _IECx_INTxIE_MASK
#define WIFI_INT_EDGE   CAT_3(INTCONbits.INT,WF_INT,EP)                 // INTCONbits.INTxEP
#define WIFI_INT_IE     CAT_5(IEC,WIFI_INT_IFREG,bits.INT,WF_INT,IE)    // IECxbits.INTx1IE
#define WIFI_INT_IF     CAT_5(IFS,WIFI_INT_IFREG,bits.INT,WF_INT,IF)    // IFSxbits.INTxIF
#define WIFI_IPC_IP     CAT_5(IPC,WIFI_INT_IPCREG,bits.INT,WF_INT,IP)   // IPCxbits.INTxIP
#define WIFI_IPC_IS     CAT_5(IPC,WIFI_INT_IPCREG,bits.INT,WF_INT,IS)   // IPCxbits.INTxIS

// set up the SPI macro
#if defined(__PIC32MZ__)
    #define WF_SPI_VEC      CAT_4(_SP,I,WF_SPI,_FAULT_VECTOR)               // _SPI_x_VECTOR _SPIx_FAULT_VECTOR
    #define WF_SPI_IRQ      WF_SPI_VEC
#else
    #define WF_SPI_VEC      CAT_3(_SPI_,WF_SPI,_VECTOR)                     // _SPI_x_VECTOR
    #define WF_SPI_IRQ      CAT_4(_SP,I,WF_SPI,_ERR_IRQ)                    // _SPIx_ERR_IRQ
#endif

#if (WF_SPI_IRQ < 32)
    #define SPI_IEF_REG 0
#elif (WF_SPI_IRQ < 64)
    #define SPI_IEF_REG 1
#elif (WF_SPI_IRQ < 96)
    #define SPI_IEF_REG 2
#elif (WF_SPI_IRQ < 128)
    #define SPI_IEF_REG 3
#elif (WF_SPI_IRQ < 160)
    #define SPI_IEF_REG 4
#elif (WF_SPI_IRQ < 192)
    #define SPI_IEF_REG 5
#else
    #error SPI port not supported
#endif

#define WIFI_SPI_INT_EIE     CAT_5(IEC,SPI_IEF_REG,bits.SPI,WF_SPI,EIE)     // IPCxbits.SPIxEIE
#define WIFI_SPI_INT_TXIE    CAT_5(IEC,SPI_IEF_REG,bits.SPI,WF_SPI,TXIE)    // IPCxbits.SPIxTXIE
#define WIFI_SPI_INT_RXIE    CAT_5(IEC,SPI_IEF_REG,bits.SPI,WF_SPI,RXIE)    // IPCxbits.SPIxRXIE
#define WIFI_SPIBUF          CAT_3(SPI,WF_SPI,BUF)                          // SPIxBUFF
#define WIFI_SPICON          CAT_3(SPI,WF_SPI,CON)                          // SPIxCON
#define WIFI_SPIBRG          CAT_3(SPI,WF_SPI,BRG)                          // SPIxBRG
#define WIFI_SPISTATbits     CAT_3(SPI,WF_SPI,STATbits)                     // SPIxSTATbits
#define WIFI_SPICONbits      CAT_3(SPI,WF_SPI,CONbits)                      // SPIxSTATbits

#ifdef	__cplusplus
}
#endif

#endif	/* SPIANDINT_H */

