/************************************************************************/
/*                                                                      */
/*	HeapMgr.h This implements the heap, page, and stream managers       */
/*                                                                      */
/************************************************************************/
/*  Author:     Keith Vogel                                             */
/*  Copyright 2013, Digilent Inc.                                       */
/************************************************************************/
/* deIP core network library
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
/*	HeapMgr This implements the heap, page, and stream managers         */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	6/5/2013(KeithV): Created                                           */
/*                                                                      */
/************************************************************************/

#ifndef HEAPMGR_H
#define	HEAPMGR_H

#ifdef	__cplusplus
extern "C" {
#endif

#pragma pack(push,1)                    // we want to have control over this structure


#define RRHPEndEn(_pH) ((RRHE *) ((_pH)->rgbHeap + (_pH)->cbHeap))
#define RRHPcbMinEn sizeof(IPSTACK)
#define RRHPNextEn(_pE) ((RRHE *) ((_pE)->rgbData + (_pE)->cbData))

typedef const void * HRRHEAP;

typedef struct RRHE_T
{
    uint16_t        cbData;
    uint16_t        fInUse;
    uint8_t         rgbData[0];
} RRHE;

typedef struct RRHEAP_T
{
    RRHE * phpenNext;
    uint32_t cbHeap;
    uint16_t cFail;
    uint16_t cInUse;
    uint8_t rgbHeap[0];
} RRHEAP;


typedef const void * HPMGR;
typedef uint8_t PGID;

// Initializing and terminating of the device page manager is device specific and
// must completely fill in the PMGR structure with the required information.
// it must also allocate enough room for the rgPages array, 1 byte per page.
// an example init routine might look like
// #define RAMGetPageMGRSize(_cPages, _pf2Page) (sizeof(PMGR) + (_cPages) + ((_cPages) * (1 << _pf2Page)))
// HPMGR RAMCreatePageMGR(uint8_t * pRam, uint32_t cbRam, uint8_t cPages, uint8_t pf2PageSize);
typedef uint16_t (* DPMGRCopyToPage)(HPMGR hPMGR, PGID pageID, uint16_t offset, const uint8_t * pb, uint16_t cb);
typedef uint16_t (* DPMGRCopyFromPage)(HPMGR hPMGR, PGID pageID, uint16_t offset, uint8_t * pb, uint16_t cb);

// pageIDs must only be 1 byte in size and can not be 0xFF
// therefore we have a max of 255 useful pages
// minPage size is 32 bytes. or pf2 == 5.

#define PMGRFreePage    0xFF                // we can only have pages 0-254
#define PMGRpf2Max      15                  // we can not deal with a page size greater than 32K
#define PMGRpf2Min      5                   // we must have at least 32 bytes in a page.
#define PMGRGetPageSizeFromPF2(_pf2)        ((uint16_t) (1 << (_pf2)))
#define PMGRGetAllocBytesNeeded(_cPages)    ((uint8_t) ((((uint16_t) (_cPages)) + 0x7) >> 3))
#define PMGRIsAlloc(_pPMGR, _pageID)        (((_pageID) < (_pPMGR)->cPages) ? ((bool) ((((_pPMGR)->rgAllocMap[((_pageID) >> 3)]) >> ((_pageID) & 0x7)) & 0x01)) : false)
#define PMGRGetPMGRSize(_cPage)             SYSAdjToDerefSize((sizeof(PMGR) + PMGRGetAllocBytesNeeded(_cPage)))

// the completion of the page manager
// this is non-device specific; imp
PGID PMGRAlloc(HPMGR hPMGR);
void PMGRFree(HPMGR hPMGR, PGID pageID);
uint8_t PMGRCntAlloc(HPMGR hPMGR);
#define PMGRCopyToPage(_hPMGR, _pageID, _offset, _pb, _cb) ((PMGR *) (_hPMGR))->CopyToPage(_hPMGR, _pageID, _offset, _pb, _cb)
#define PMGRCopyFromPage(_hPMGR, _pageID, _offset, _pb, _cb) ((PMGR *) (_hPMGR))->CopyFromPage(_hPMGR, _pageID, _offset, _pb, _cb)
#define PMGRcbPage(_h) PMGRGetPageSizeFromPF2(((PMGR *) (_h))->pf2PerPage)
#define PMGRMaxAlloc(_h) ((((PMGR *) (_h))->cPages) * PMGRcbPage(_h))
#define PMGRMaxFree(_h) (((((PMGR *) (_h))->cPages) - (((PMGR *) (_h))->cAlloc)) * PMGRcbPage(_h))

typedef struct PMGR_T
{
    DPMGRCopyToPage     CopyToPage;         // copy bytes to a page
    DPMGRCopyFromPage   CopyFromPage;       // read bytes from a page
    uint8_t             pf2PerPage;         // this is the power of 2 power factor, thus (1 << pfPerPage) MUST == cbPerPage.
    uint8_t             cPages;             // max of 255 pages 0-254; 0x255 == PMGRFreePage is reserved
    uint8_t             cAlloc;             // number of alloced pages
    uint8_t             cbAllocMap;         // how many bytes are in the allocation map
    uint8_t             rgAllocMap[0];       // A bit map of pages in use 1 = in use, 0 free
} PMGR;

// the stream manager is typically used internally by a socket,
// but can be used by anyone who follows the rules.
#define SMGRAtBegining  0x0000
#define SMGRAtEnding    0xFFFF


// the socket stream manager

typedef struct SMGR_T
{
    PMGR *      pPMGR;          // a handle to the page manager; many streams may use the same page manager
    uint32_t    iStart;         // linear start offset into the stream
    uint32_t    iEnd;           // linear end offset into the stream
    uint8_t     cPages;
    PGID        rgPages[0];
} SMGR;

// Stream Manager
typedef const void * HSMGR;
#define GetSMGRSize(_cPages) SYSAdjToDerefSize((sizeof(SMGR) + _cPages))
HSMGR SMGRInit(void * pbSMGRMEM, uint32_t cbSMGRMEM, HPMGR hPMGR);
uint16_t SMGRCopyInOut(HSMGR hSMGR, bool fIn, uint16_t index, void * pb, uint16_t cb);
#define SMGRWrite(_hSMGR, _index, _pb, _cb) SMGRCopyInOut(_hSMGR, true, _index, ((void *) (_pb)), _cb)
#define SMGRRead(_hSMGR, _index, _pb, _cb) SMGRCopyInOut(_hSMGR, false, _index, _pb, _cb)
void SMGRMoveEnd(HSMGR hSMGR, uint16_t index, uint16_t end);
#define SMGRcbStream(_hSMGR) (((SMGR *) (_hSMGR))->iEnd - ((SMGR *) (_hSMGR))->iStart)
void SMGRFree(HSMGR hSMGR);

typedef struct FFPT_T
{
    void * pvFirst;
    void * pvLast;
} FFPT;

#define RRHPMaxAlloc(_h)    (((RRHEAP *) (_h))->cbHeap)
#define RRHPcInUse(_h)      (((RRHEAP *) (_h))->cInUse)
#define RRHPIsInUse(_h)     (RRHPcInUse(_h) > 0)

#pragma pack(pop)

#define RAMGetPMGRSize(_cPages, _pf2Page) (PMGRGetPMGRSize(_cPages) + ((_cPages) * (0x01 << (_pf2Page))))
HPMGR RAMCreatePageMGR(uint8_t * pRam, uint32_t cbRam, uint8_t cPages, uint8_t pf2PageSize);
void RAMTerminatePageMGR(HPMGR hPMGR);

HRRHEAP RRHPInit(uint8_t * rgbHeap, uint32_t cbHeap);
bool RRHPFree(HRRHEAP hHeap, void * pMem);
void * RRHPAlloc(HRRHEAP hHeap, uint16_t cbAlloc);
void RRHPTerminate(HRRHEAP hHeap);
bool RRHPVerify(HRRHEAP hHeap, uint16_t * pcInUse, uint16_t * pcFail);

void FFInPacket(FFPT * ffpt, void * pv);
void * FFOutPacket(FFPT * ffpt);
void * FFNext(const FFPT * ffpt, const void * pvLast);
void FFRemove(FFPT * ffpt, void * pv);

#ifdef	__cplusplus
}
#endif

#endif	/* HEAPMGR_H */

