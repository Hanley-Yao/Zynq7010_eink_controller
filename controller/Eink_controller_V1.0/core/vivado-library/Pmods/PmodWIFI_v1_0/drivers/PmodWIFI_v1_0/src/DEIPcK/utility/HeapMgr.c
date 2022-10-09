/************************************************************************/
/*                                                                      */
/*	HeapMgr.c This implements the heap, page, and stream managers       */
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
#include "deIP.h"

void FFInPacket(FFPT * ffpt, void * pv)
{
    if(ffpt == NULL || pv == NULL)
    {
        return;
    }

//    if(*((void **) pv) != NULL)
//    {
//        *((void **) pv) = NULL;
//    }

    *((void **) pv) = NULL;

    if(ffpt->pvLast != NULL)
    {
        *((void **) ffpt->pvLast) = pv;
    }
    ffpt->pvLast = pv;

    if(ffpt->pvFirst == NULL)
    {
        ffpt->pvFirst = pv;
    }
}

void * FFOutPacket(FFPT * ffpt)
{
    void * pv = NULL;

    if(ffpt == NULL)
    {
        return(NULL);
    }

    // debug code
//    if(ffpt->pvLast != NULL && *((void **) ffpt->pvLast) != NULL)
//    {
//        *((void **) ffpt->pvLast) = NULL;
//    }

    pv = ffpt->pvFirst;

    if(ffpt->pvFirst != NULL)
    {
        if(ffpt->pvLast == ffpt->pvFirst)
        {
            ffpt->pvLast = NULL;
        }

        ffpt->pvFirst = *((void **) ffpt->pvFirst);
        *((void **) pv) = NULL;
    }

    return(pv);
}

void * FFNext(const FFPT * ffpt, const void * pvLast)
{
    if(ffpt == NULL)
    {
        return(NULL);
    }

    if(pvLast == NULL)
    {
        return(ffpt->pvFirst);
    }

    return(*((void **) pvLast));
}

void FFRemove(FFPT * ffpt, void * pv)
{
    void *  pvLast = NULL;

    // don't do anything
    if(pv == NULL || ffpt == NULL || ffpt->pvFirst == NULL)
    {
        return;
    }

    // it is the only item in the list
    else if(ffpt->pvFirst == pv && pv == ffpt->pvLast)
    {
        ffpt->pvFirst = NULL;
        ffpt->pvLast = NULL;
    }

    // it is the first item in the list
    else if( (pvLast = FFNext(ffpt, NULL)) == pv)
    {
        ffpt->pvFirst = FFNext(ffpt, pvLast);
    }

    // some other item in the list, find it.
    else
    {
        void *  pvCur = NULL;

        // look for it.
        while((pvCur = FFNext(ffpt, pvLast)) != pv && pvCur != NULL)
        {
            pvLast = pvCur;
        }

        // didn't find it, get out and don't touch pv
        if(pvCur != pv)
        {
            return;
        }

        // otherwise pvCur is our guy and pvLast is the one before it
        // pull pvCur out of the list
        *((void **) pvLast) = *((void **) pvCur);

        // check to see if we just removed the last one in our list?
        if(pv == ffpt->pvLast)
        {
            // the pointer before and now the last pointer
            ffpt->pvLast = pvLast;
        }
    }

    // clear the next pointer in pv
    *((void **) pv) = NULL;

    return;
}

HRRHEAP RRHPInit(uint8_t * rgbHeap, uint32_t cbHeap)
{
    RRHEAP * pHeap = (RRHEAP *) rgbHeap;

    if(pHeap == NULL)
    {
        return(NULL);
    }

    memset(rgbHeap, 0, cbHeap);
    pHeap->cbHeap = cbHeap - sizeof(RRHEAP);
    pHeap->phpenNext = (RRHE *) pHeap->rgbHeap;
    pHeap->phpenNext->cbData = pHeap->cbHeap - sizeof(RRHE);

    return((HRRHEAP) rgbHeap);
}

bool RRHPFree(HRRHEAP hHeap, void * pMem)
{
    RRHEAP * pHeap = (RRHEAP *) hHeap;

    if(pHeap != NULL && pHeap->rgbHeap <= ((uint8_t *) pMem) && ((uint8_t *) pMem) < (pHeap->rgbHeap + pHeap->cbHeap))
    {
        RRHE * phpen = (RRHE *) (pMem - sizeof(RRHE));
        
        if(phpen->fInUse)
        {           
            pHeap->cInUse--;
            phpen->fInUse = false;
            
            // don't advance if all we are doing is
            // alloc and freeing
            if(RRHPNextEn(phpen) == pHeap->phpenNext)
            {
                pHeap->phpenNext = phpen;
            }  
            return(true);
        }
    }

    return(false);
}

void * RRHPAlloc(HRRHEAP hHeap, uint16_t cbAlloc)
{
    RRHEAP *    pHeap       = (RRHEAP *) hHeap;
    RRHE *      phpenStart  = pHeap->phpenNext;
    RRHE *      phpenCur    = phpenStart;
    RRHE *      phpenNext   = NULL;
    uint32_t    cExit       = 0;

    // we want to keep things aligned on 4 byte boundaries
    cbAlloc = SYSAdjToDerefSize(cbAlloc);

    // this will never work!
    if(pHeap == NULL)
    {
        return(NULL);
    }
    else if(pHeap->cbHeap < cbAlloc)
    {
        pHeap->cFail++;
        return(NULL);
    }

    // even if the whole heap is just one entry, these won't start out as the same
    // as phpenCur will be at the end and phpenStart will be at the begining
    // so we will go through the loop at least once
    do
    {
        // Do some range checking and get us in the heap area
        // this wil correct if our cur is at the end
        if(phpenCur < ((RRHE *) pHeap->rgbHeap) || RRHPEndEn(pHeap) <= phpenCur)
        {
            // correct to the start of the heap
            phpenCur = (RRHE *) pHeap->rgbHeap;

            // we are getting stuck here
            // because of corrept data
            // or there is no memory avaiable
            if(cExit > 3)
            {
                pHeap->cFail++;
                return(NULL);
            }
            cExit++;
        }
                
        // only process this if it is not in use
        if(!phpenCur->fInUse)
        {        
            // if not big enough, try to merge with the next blocks
            while(  phpenCur->cbData < cbAlloc                              &&
                    (phpenNext = RRHPNextEn(phpenCur)) < RRHPEndEn(pHeap)   &&
                    !phpenNext->fInUse                                      )
            {
                 phpenCur->cbData += phpenNext->cbData + sizeof(RRHE);

                // if we just merged with start address, bump it up
                if(phpenStart == phpenNext)
                {
                    phpenStart = RRHPNextEn(phpenCur);
                    if(phpenStart >= RRHPEndEn(pHeap))
                    {
                        phpenStart = (RRHE *) pHeap->rgbHeap;
                    }
                }
            }
         
            // we got it, clean up and get out.
            if(phpenCur->cbData >= cbAlloc)
            {
                // only take what we need
                if((phpenCur->cbData - cbAlloc) >= (uint16_t) (sizeof(RRHE) + RRHPcbMinEn))
                {
                    RRHE * phpenNext = (RRHE *) (phpenCur->rgbData + cbAlloc);
                    phpenNext->cbData = phpenCur->cbData - cbAlloc - sizeof(RRHE);
                    phpenNext->fInUse = false;
                    phpenCur->cbData = cbAlloc;
                }

                memset(phpenCur->rgbData, 0, phpenCur->cbData);
                phpenCur->fInUse = true;
                pHeap->cInUse++;
                pHeap->phpenNext = RRHPNextEn(phpenCur);
                return(phpenCur->rgbData);
            }
        }

        // otherwise try the next one
        phpenCur = RRHPNextEn(phpenCur);

    } while(phpenCur != phpenStart);

    pHeap->cFail++;
    return(NULL);
}

void RRHPTerminate(HRRHEAP hHeap)
{
    RRHEAP * pHeap = (RRHEAP *) hHeap;

    if(pHeap != NULL)
    {
        memset((void *) pHeap, 0, pHeap->cbHeap + sizeof(RRHEAP));
    }
}

bool RRHPVerify(HRRHEAP hHeap, uint16_t * pcInUse, uint16_t * pcFail)
{
    RRHEAP *    pHeap = (RRHEAP *) hHeap;
    RRHE *      phpenCur = NULL;
    uint16_t    cInUse = 0;
    bool        fRet = false;

    if(pHeap == NULL)
    {
        if(pcInUse != NULL) *pcInUse = 0;
        if(pcFail != NULL) *pcFail = 0;
        return(true);
    }
        
    phpenCur = (RRHE *) pHeap->rgbHeap;

    while(phpenCur < RRHPEndEn(pHeap))
    {
        cInUse += phpenCur->fInUse;
        phpenCur = RRHPNextEn(phpenCur);
    }

    if(pcInUse != NULL) *pcInUse = cInUse;
    if(pcFail != NULL) *pcFail = pHeap->cFail;

    fRet = (phpenCur == RRHPEndEn(pHeap) && cInUse == pHeap->cInUse);
    pHeap->cInUse = cInUse;

    while(!fRet); // for now spin to catch the problem. Eventually take this out.
    return(fRet);
}

static uint16_t RAMCopyToFromPage(HPMGR hPMGR, bool fToPage, PGID pageID, uint16_t offset, uint8_t * pb, uint16_t cb)
{
    PMGR *      pPMGR = (PMGR *) hPMGR;

    if(hPMGR != NULL && PMGRIsAlloc(pPMGR, pageID))
    {
        uint8_t *   pbPage =   ((uint8_t *) hPMGR) +                                        // base address
                                PMGRGetPMGRSize(pPMGR->cPages) +                            // beyond the PMRG struct; 4 byte aligned
                                pageID * PMGRGetPageSizeFromPF2(pPMGR->pf2PerPage) +        // index to the page
                                offset;                                                     // offset in the page

        // make sure what is asked for fits in the page
        if((((int32_t) PMGRGetPageSizeFromPF2(pPMGR->pf2PerPage)) - cb - offset) >= 0)
        {
            if(fToPage)
            {
                memcpy(pbPage, pb, cb);
            }
            else
            {
                memcpy(pb, pbPage, cb);
            }
            return(cb);
        }
    }

    return(0);
}

static uint16_t RAMCopyToPage(HPMGR hPMGR, PGID pageID, uint16_t offset, const uint8_t * pb, uint16_t cb)
{
    return(RAMCopyToFromPage(hPMGR, true, pageID, offset, (uint8_t *) pb, cb));
}
static uint16_t RAMCopyFromPage(HPMGR hPMGR, PGID pageID, uint16_t offset, uint8_t * pb, uint16_t cb)
{
        return(RAMCopyToFromPage(hPMGR, false, pageID, offset, pb, cb));
}

HPMGR RAMCreatePageMGR(uint8_t * pRam, uint32_t cbRam, uint8_t cPages, uint8_t pf2PageSize)
{
    PMGR * pPMGR = (PMGR *) pRam;

    // lets make sure enough RAM was given and do some parameter checking
    if( cPages == PMGRFreePage                              ||
        pf2PageSize < PMGRpf2Min                            ||
        pf2PageSize > PMGRpf2Max                            ||
        cbRam < RAMGetPMGRSize(cPages, pf2PageSize)         ||
        pRam == NULL                                        )
    {
        return(NULL);
    }

    // clear the memory
    memset(pRam, 0, cbRam);

    // intialize page MGR struct
    pPMGR->CopyFromPage = RAMCopyFromPage;
    pPMGR->CopyToPage   = RAMCopyToPage;
    pPMGR->cPages       = cPages;
    pPMGR->cbAllocMap   = PMGRGetAllocBytesNeeded(cPages);
    pPMGR->pf2PerPage   = pf2PageSize;

    // We want to make sure that any extra pages in the pageMap that go beyond
    // the number of pages we have are marked as in use
    // but don't add that to the cAlloc count
    if(cPages < (((uint32_t) pPMGR->cbAllocMap) << 3))
    {
        pPMGR->rgAllocMap[pPMGR->cbAllocMap-1] = (uint8_t) (((uint16_t) 0x00FF) << (cPages & 0x07));
    }

    return((HPMGR) pPMGR);
}

void RAMTerminatePageMGR(HPMGR hPMGR)
{
    PMGR * pPMGR = (PMGR *) hPMGR;

    if(pPMGR != NULL && pPMGR->cPages > 0 &&  pPMGR->pf2PerPage > 0)
    {
        memset(pPMGR, 0, RAMGetPMGRSize(pPMGR->cPages, pPMGR->pf2PerPage));
    }
}

PGID PMGRAlloc(HPMGR hPMGR)
{
    PMGR *      pPMGR = (PMGR *) hPMGR;

    if(hPMGR != NULL)
    {
        uint32_t i = 0;
        uint32_t j = 0;

        // look for an open page
        for(i=0; i<pPMGR->cbAllocMap; i++)
        {
            // there is an open page in here
            if(pPMGR->rgAllocMap[i] != 0xFF)
            {
                uint8_t u8 = pPMGR->rgAllocMap[i];

                for(j=0; j<8; j++)
                {
                    // found an open page
                    if((u8 & 0x1) == 0)
                    {
                        u8 = 0x01 << j;
                        pPMGR->rgAllocMap[i] |= u8;
                        pPMGR->cAlloc++;
                        return(i*8+j);
                    }

                    u8 = u8 >> 1;
                }
            }
        }
    }
    return(PMGRFreePage);
}

void PMGRFree(HPMGR hPMGR, PGID pageID)
{
    PMGR *      pPMGR = (PMGR *) hPMGR;

    if(hPMGR != NULL && PMGRIsAlloc(pPMGR, pageID))
    {
        pPMGR->rgAllocMap[((pageID) >> 3)] &= (~(0x01 << (pageID & 0x7)));
        pPMGR->cAlloc--;
    }
}

uint8_t PMGRCntAlloc(HPMGR hPMGR)
{
    PMGR *  pPMGR = (PMGR *) hPMGR;

    if(hPMGR != NULL)
    {
        return(pPMGR->cAlloc);
    }

    return(0);
}

HSMGR SMGRInit(void * pbSMGRMEM, uint32_t cbSMGRMEM, HPMGR hPMGR)
{
    PMGR *  pPMGR = (PMGR *) hPMGR;
    SMGR *  pSMGR = (SMGR *) pbSMGRMEM;
    
    if(pPMGR != NULL && pbSMGRMEM != NULL && cbSMGRMEM >= SYSAdjToDerefSize(sizeof(SMGR)))
    {
        memset(pbSMGRMEM, 0, cbSMGRMEM);

        pSMGR->cPages   = min((cbSMGRMEM - sizeof(SMGR)), pPMGR->cPages);
        pSMGR->pPMGR    =   pPMGR;
        memset(pSMGR->rgPages, PMGRFreePage, pSMGR->cPages);
        return((HSMGR) pSMGR);
    }

    return(NULL);
}

uint16_t SMGRCopyInOut(HSMGR hSMGR, bool fIn, uint16_t index, void * pb, uint16_t cb)
{
    SMGR *      pSMGR   = (SMGR *) hSMGR;
    uint16_t    cbCopy  = 0;
    uint16_t    cbT     = 0;

    if(cb > 0 && pSMGR != NULL && pSMGR->pPMGR != NULL)
    {
        uint32_t    cbPage  = (1 << pSMGR->pPMGR->pf2PerPage);
        uint32_t    cPagesT = pSMGR->cPages;
        uint32_t    cbTotal = (cPagesT << pSMGR->pPMGR->pf2PerPage);

        uint32_t    iStart  = pSMGR->iStart + index;
        uint32_t    iPage   = (iStart >> pSMGR->pPMGR->pf2PerPage);
        uint32_t    oPage   = iStart & (cbPage - 1);

        uint32_t    cPage   = 0;
        uint32_t    iPageEnd = 0;
        uint32_t    i       = 0;

        // check to see if the pages are within range
        if(iStart > pSMGR->iEnd)
        {
            return(0);
        }
        // make sure we fit in the range of the stream
        else if(index + cb > cbTotal)
        {
            cb = cbTotal - index;   // adjust to max of stream
        }

        // can only READ what is valid
        if(!fIn && (iStart + cb) > pSMGR->iEnd)
        {
            cb = pSMGR->iEnd - iStart;
        }
        cPage = (cb + oPage + cbPage - 1) >> pSMGR->pPMGR->pf2PerPage;
        iPageEnd = iPage + cPage;

        // Now copy into the pages
        for(i=iPage; i<iPageEnd; i++)
        {
            uint32_t j = i % cPagesT;                                       // wrap the index
            uint16_t cbCopyThisPass = min((uint16_t) (cbPage - oPage), (uint16_t) (cb - cbCopy));     // cal the nbr of byte to copy into the page

            if(fIn)
            {
                // first make sure the page is allocated
                if(pSMGR->rgPages[j] == PMGRFreePage && (pSMGR->rgPages[j] = PMGRAlloc((HPMGR) pSMGR->pPMGR)) == PMGRFreePage)
                {
                    break;
                }

                cbT = PMGRCopyToPage((HPMGR) pSMGR->pPMGR, pSMGR->rgPages[j], oPage, &((uint8_t *) pb)[cbCopy], cbCopyThisPass);
            }
            else if(pSMGR->rgPages[j] != PMGRFreePage)
            {
                cbT = PMGRCopyFromPage((HPMGR) pSMGR->pPMGR, pSMGR->rgPages[j], oPage, &((uint8_t *) pb)[cbCopy], cbCopyThisPass);
            }
            else
            {
                break;
            }

            // we know we wrote to the end of the page, or we are done
            // so we can set the page offset to the start of the page
            oPage = 0;
            cbCopy += cbT;
            if(cbT != cbCopyThisPass)
            {
                break;
            }
        }

        // push the end out if we grew
        if(fIn && ((iStart + cbCopy) > pSMGR->iEnd))
        {
            pSMGR->iEnd = iStart + cbCopy;
        }
    }

    return(cbCopy);
}


void SMGRMoveEnd(HSMGR hSMGR, uint16_t index, uint16_t end)
{
    SMGR *  pSMGR = (SMGR *) hSMGR;
    
    if(pSMGR != NULL && pSMGR->pPMGR != NULL)
    {
        uint32_t cbPage     = (1 << pSMGR->pPMGR->pf2PerPage);
        uint32_t cbTotal    = (pSMGR->cPages << pSMGR->pPMGR->pf2PerPage);

        uint32_t iLoc       = index + pSMGR->iStart;
        uint32_t iPageLoc   = (iLoc >> pSMGR->pPMGR->pf2PerPage);

        uint32_t iPageStart  = 0;
        uint32_t iPageEnd    = 0;
        uint32_t i           = 0;
       
        if(iLoc <= pSMGR->iEnd)
        {
            if(end == SMGRAtBegining)
            {
                // get our start page
                iPageStart = (pSMGR->iStart >> pSMGR->pPMGR->pf2PerPage);

                // if we are moving the start to the end
                // then everything is cleared out and we just need to free
                // everything. iPageEnd may go 1 page too far if iLoc is at
                // the first byte of the page, but PMGRFree is okay with that.
                if(pSMGR->iEnd == iLoc)
                {
                     iPageEnd = iPageLoc + 1;
                }
                else
                {
                    // typically don't want to free the page iLoc is on because the
                    // rest of the page has valid data on it.
                    iPageEnd = iPageLoc;
                    
                    // if iPageStart == iPageEnd; then iPageStart will free the iPageEnd page
                    // and that would be bad; so don't do that, don't free the iPageStart
                    if(iPageStart == (iPageEnd % pSMGR->cPages)) iPageStart++;
                }
                  
                // move the start pointer.
                pSMGR->iStart = iLoc;
            }

            else if(end == SMGRAtEnding)
            {
                // if we are moving the end to the start
                // then everything is cleared out and we just need to free
                // everything. iPageEnd may go 1 page too far if iEnd is at 
                // the first byte of the page, but PMGRFree is okay with that.
                if(pSMGR->iStart == iLoc)
                {
                    iPageStart = iPageLoc;
                    iPageEnd = (pSMGR->iEnd >> pSMGR->pPMGR->pf2PerPage) + 1;
                }
                else
                {
                    // if the iLoc is not on the first byte of the page, then there is valid data before it
                    // in the page and we don't want to free the first page.
                    iPageStart = (iLoc & (cbPage - 1)) > 0 ? iPageLoc + 1 : iPageLoc;

                    // get the last page; and we typically want to free the last
                    // page because this is the end of the stream and we are to the end
                    iPageEnd = (pSMGR->iEnd >> pSMGR->pPMGR->pf2PerPage) + 1;
                    
                    // now if freeing the end page will free the start page we
                    // don't want to do that as the start page may still have valid data on it
                    // if it doesn't the start pointer is adjusted to free it. Anyway, don't let 
                    // the last page free the first page
                    if(iPageStart == (iPageEnd % pSMGR->cPages)) iPageEnd--;
                }

                // set the end pointer
                pSMGR->iEnd = iLoc;
            }
        }
        
        // free any pages no longer in use
        for(i=iPageStart; i<iPageEnd; i++)
        {
            uint32_t j = i % pSMGR->cPages;
            PMGRFree(((HPMGR) pSMGR->pPMGR), pSMGR->rgPages[j]);
            pSMGR->rgPages[j] = PMGRFreePage;
        }

        // We always want iStart to be within the total stream range
        // and iEnd may go beyond the end of the stream, but lets
        // shift everthing down to insure that iStart is within the totall
        // buffer range.
        while(pSMGR->iStart >= cbTotal)
        {
            pSMGR->iStart -= cbTotal;
            pSMGR->iEnd -= cbTotal;
        }
    }
}

void SMGRFree(HSMGR hSMGR)
{
    SMGR *  pSMGR = (SMGR *) hSMGR;
    uint32_t i = 0;

    if(pSMGR != NULL)
    {
        for(i=0; i<pSMGR->cPages; i++)
        {
            if(pSMGR->rgPages[i] != PMGRFreePage)
            {
                PMGRFree((HPMGR)pSMGR->pPMGR, pSMGR->rgPages[i]);
                pSMGR->rgPages[i] = PMGRFreePage;
            }
        }
    }
}
