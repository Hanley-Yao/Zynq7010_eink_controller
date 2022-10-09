/************************************************************************/
/*                                                                      */
/*	DNS.c  This implements the DNS code per RFC 2131                    */
/*          as part of the Application Layer                            */
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
/*	Technecally DNS is implemented at the application layer             */
/*	and depends on UDP                                                  */
/*                                                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	4/11/2013(KeithV): Created                                          */
/*                                                                      */
/************************************************************************/
#include "deIP.h"

#ifdef __IMPORT
#undef __IMPORT
#endif
#define __IMPORT __attribute__((section(".data")))
#include <ctype.h>

/*********************************************************************
 * Function:        int strncasecmp(const char *s1,	const char *s2,	size_t n)
 *
 * Input:
 *                  See standard runtime implementations
 *
 * Returns:         See standard runtime implementations
 *
 * Note:
 *                  DIRECT COPY FROM THE NEWLIB STRING IMPLEMENTATION
 *                  from: https://github.com/jasonkajita/pic32-newlib/blob/master/newlib/libc/string/strncasecmp.c
 *
 ********************************************************************/
int strncasecmp(const char *s1,	const char *s2,	size_t n)
{
    const unsigned char *ucs1 = (const unsigned char *) s1;
    const unsigned char *ucs2 = (const unsigned char *) s2;
    int d = 0;
    for ( ; n != 0; n--)
    {
        const int c1 = tolower(*ucs1++);
        const int c2 = tolower(*ucs2++);
        if (((d = c1 - c2) != 0) || (c2 == '\0'))
            break;
    }
    return d;
}

/*********************************************************************
 * Function:        uint8_t * DNSSkipName(uint8_t * pName, uint8_t * pEnd)
 *
 * Input:
 *                  pName:  A pointer to the name you want to find
 *                  pEnd:   A pointer to 1 past the last valid byte we can look at
 *
 * Returns:         True if they match, false otherwise
 *
 * Note:
 *                  This just skips the name part of the RR
 *                  This does not pointers, it skips them!
 *                  This is just to get past the name in the Resource Record
 *
 ********************************************************************/
static uint8_t * DNSSkipName(uint8_t * pName, uint8_t * pEnd)
{

    // skip past the name
    while(pName < pEnd && *pName != 0)
    {
        // we have a pointer record
        // BIG NOTE!!! we always keep offset pointer in network order, we NEVER
        // in machine order as it becomes ambiguous if it is a ptr, or end of the Domain Name
        if((*pName & DNSLBLPTRMASK) == DNSLBLPTRMASK)
        {
            // ExEndian(pRR, sizeof(uint16_t));
            pName++;  // only add 1 as we will add another when we break out.

            // end of the name, get out
            break;
        }
        else
        {
            // skip past this label
            pName += *pName + 1;
        }
    }
    pName++;  // get past the zero terminator

    return(min(pName, pEnd));
}

/*********************************************************************
 * Function:        uint32_t DNSGetNameLabelList(const uint8_t * pBase, const uint8_t * pName, const uint8_t * pEnd, uint32_t cEndSkip, uint16_t * rgPtr, uint32_t crgPtr)
 *
 * Input:
 *                  pBase:      A pointer to the base of the DNS record, must apply to both pName and pRR
 *                  pName:      A pointer to the name you want to parse
 *                  pEnd:       A pointer to 1 past the last valid byte we can look at
 *                  cEndSkip:   The number of labels at the end of the domain name to no process
 *                  rgPtr:      An array of shorts to recieve the offsets to the labels in the name
 *                  crgPtr:     How many elemens are in the rgPtr array
 *
 * Returns:         Total number of labels in the name less cEndSkip. So this can be more than crgPtr
 *                  However, only the last crgPtr elements are filled in the rgPtr array
 *
 *                  A return value of zero indicates an error
 *
 * Note:
 *                  If there are more labels in the name than array entries (crgPtr), then only the last
 *                  crgPtr labels are returned. However the total number is returned in the count.
 *
 *                  By setting cEndSkip, this effectively just cuts off the last cEndSkip labels in the name
 *                  so you can call this function again and pick up the eariler labels not returned in the
 *                  overflowing previous call. Keep calling until the return value is less than crgPtr and by
 *                  setting cEndSkip to the number of labels already read.
 *
 *                  This function operates from right to left in the name because the right most
 *                  label is the top of the domain name space and we want to work backwards from the top down
 *
 ********************************************************************/
static uint32_t DNSGetNameLabelList(const uint8_t * pBase, const uint8_t * pName, const uint8_t * pEnd, uint32_t cEndSkip, uint16_t * rgPtr, uint32_t crgPtr)
{
    int32_t     iEnd    = 0;
    int32_t     iStart  = 0;
    uint32_t    cT      = 0;

    if(pName < pBase)
    {
        return(0);
    }

    while(pName < pEnd)
    {
        // skip by offest records and jump to the actuall name segment.
        while((*pName & DNSLBLPTRMASK) == DNSLBLPTRMASK && pName+1 < pEnd)
        {
            pName = pBase + ((((uint16_t) (*pName & ~DNSLBLPTRMASK)) << 8) + ((uint16_t) *(pName+1)));
        }

        // got corruption in the pointer
        // remember there is always a zero at the end of the name
        // so keep the compares < not <=
        if( !(pBase <= pName && pName < pEnd)           ||
             (*pName & DNSLBLPTRMASK) == DNSLBLPTRMASK  ||
            !(pName + *pName < pEnd)  )
        {
            return(0);
        }

        // we are done building the list, get out
        if(*pName == 0)
        {
            break;
        }

        // if we are skipping the the end, don't include these values.
        if(cEndSkip == 0)
        {
            // assign this pointer in the list in a round robin way
            rgPtr[(iEnd % crgPtr)] = (uint16_t) (pName - pBase);
            iEnd++;
        }
        else
        {
            cEndSkip--;
        }
        pName += *pName + 1;
    }

    // we found everything, lets set our start pointer and counts
    cT = iEnd - iStart;
    if(iEnd > (int32_t) crgPtr)
    {
        iStart = iEnd - (int32_t) crgPtr;
    }

    // now exchange the list order
    iEnd--;     // we are one past the end, get on the last item in the list
    while(iEnd > iStart)
    {
        uint16_t ptrT = rgPtr[(iEnd % crgPtr)];
        rgPtr[(iEnd % crgPtr)] = rgPtr[(iStart % crgPtr)];
        rgPtr[(iStart % crgPtr)] = ptrT;
        iEnd--;
        iStart++;
    }

    return(cT);
}

/*********************************************************************
 * Function:        uint32_t DNSCompareLabelListAndName(const uint8_t * pBase, const uint8_t * pName, const uint8_t * pEnd, uint32_t cEndSkip, const uint16_t * rgPtr, uint32_t crgPtr)
 *
 * Input:
 *                  pBase:      A pointer to the base of the DNS record, must apply to both pName and pRR
 *                  pName:      A pointer to the name you want to compare with
 *                  pEnd:       A pointer to 1 past the last valid byte we can look at
 *                  cEndSkip:   The number of labels at the end of the domain name to no process
 *                  rgPtr:      An array of shorts to with pointer to the other name to compare
 *                  crgPtr:     How many elemens are in the rgPtr array
 *
 * Returns:         The number of comparing labels from right to left in the domain name
 *
 * Note:
 *
 ********************************************************************/
static uint32_t DNSCompareLabelListAndName(const uint8_t * pBase, const uint8_t * pName, const uint8_t * pEnd, uint32_t cEndSkip, const uint16_t * rgPtr, uint32_t const crgPtr)
{
    uint16_t    rgLL[DNScLL];
    uint16_t *  prgLL   = rgLL;
    uint32_t    cDone   = 0;
    uint32_t    cPass   = DNScLL;
    uint32_t    i       = 0;

    while(cDone < crgPtr && cPass == DNScLL)
    {
        prgLL = rgLL;
        cPass = min(min(DNSGetNameLabelList(pBase, pName, pEnd, cEndSkip, rgLL, DNScLL), DNScLL), (crgPtr - cDone));
        cEndSkip += cPass;

        if(cPass == 0)
        {
            return(cDone);
        }

        for(i=0; i<cPass; i++)
        {
            // did not match
            if(!((*(pBase + *prgLL) == *(pBase + *rgPtr)) && (strncasecmp((char *) (pBase+*prgLL+1), (char *) (pBase+*rgPtr+1), *(pBase + *prgLL)) == 0)))
            {
                // return how many matching values
                return(cDone);
            }

            // if we got here, it did match
            prgLL++;
            rgPtr++;
            cDone++;
        }
    }

    return(0);
}

/*********************************************************************
 * Function:        bool DNSCompareRRName(uint8_t * pBase, uint8_t * pName, uint8_t * pRR, uint8_t * pEnd)
 *
 * Input:
 *                  pBase:  A pointer to the base of the DNS record, must apply to both pName and pRR
 *                  pName:  A pointer to the name you want to find
 *                  pRR:    A pointer to a pointer to the name to compare too
 *                  pEnd:   A pointer to 1 past the last valid byte we can look at
 *
 * Returns:         True if they match, false otherwise
 *
 * Note:
 *                  Typically you will take the question name, and compare against CNames in the DNS datagram
 *                  Unfortunately we can't return after the name because we might have jump to an offset and
 *                  actually be somewhere else.
 *
 ********************************************************************/
static bool DNSCompareRRName(const uint8_t * pBase, const uint8_t * pName, const uint8_t * pRR, const uint8_t * pEnd)
{
    while(pName < pEnd && pRR < pEnd)
    {
        // skip by offest records and jump to the actuall name segment.
        while((*pName & DNSLBLPTRMASK) == DNSLBLPTRMASK && pName+1 < pEnd)
        {
            pName = pBase + ((((uint16_t) (*pName & ~DNSLBLPTRMASK)) << 8) + ((uint16_t) *(pName+1)));
        }
        while((*pRR & DNSLBLPTRMASK) == DNSLBLPTRMASK && pRR+1 < pEnd)
        {
            pRR = pBase + ((((uint16_t) (*pRR & ~DNSLBLPTRMASK)) << 8) + ((uint16_t) *(pRR+1)));
        }

        // got corruption in the pointer
        if( !(pBase <= pName && pName < pEnd && pBase <= pRR && pRR < pEnd) ||
             (*pName & DNSLBLPTRMASK) == DNSLBLPTRMASK                      ||
             (*pRR & DNSLBLPTRMASK) == DNSLBLPTRMASK                        )
        {
            return(false);
        }

        // short cut, we know the strings are the same if the pointers are the same
        if(pName == pRR)
        {
            return(true);
        }

        // see if they are the same length or end of name
        if(*pName == *pRR)
        {
            // we are at the end of the name and it compared
            if (*pName == 0)
            {
                return(true);
            }

            //  compare the label in name
            // RFC 1035 2.3.3 case insensitive
            else if(strncasecmp((char *) (pName+1), (char *) (pRR+1), *pName) != 0)
            {
                return(false);
            }

            // otherwise just keep going and keep comparing
            pName   += *pName + 1;
            pRR     += *pRR + 1;
        }

        // Did not match, we are done
        else
        {
            return(false);
        }
    }

    return(false);
}

static uint16_t DNSCopyDomainName(const uint8_t * pBase, const uint8_t * pName, const uint8_t * pEnd, uint8_t * pchrr, uint16_t cbchrr)
{
    uint16_t cbRet = 0;

    while(pBase <= pName && pName < pEnd && cbRet < cbchrr)
    {
        // skip by offest records and jump to the actual name segment.
        while((*pName & DNSLBLPTRMASK) == DNSLBLPTRMASK && pName+1 < pEnd)
        {
            pName = pBase + ((((uint16_t) (*pName & ~DNSLBLPTRMASK)) << 8) + ((uint16_t) *(pName+1)));
        }

        // see if this is pointing to something reasonably
        if(pBase <= pName && pName < pEnd && (*pName & DNSLBLPTRMASK) != DNSLBLPTRMASK)
        {
            uint8_t i = *pName++;
            pchrr[cbRet++] = i;

            // we are at the end of the record we are done
            if (i == 0)
            {
                return(cbRet);
            }
            else if((pName+i) >= pEnd || (cbRet+i) > cbchrr)
            {
                return(0);
            }

            // copy the name
            memcpy(&pchrr[cbRet], pName, i);
            pName += i;
            cbRet += i;
        }
        else
        {
            return(0);
        }
    }

    return(0);
}

static uint8_t * ExDNSRRecord(uint8_t * pRR, bool fQuestionRecord, uint8_t * pEnd)
{
    DNSRR *     pDNSRR = NULL;
    uint8_t *   pEx = DNSSkipName(pRR, pEnd);

    // skip past the name
    pDNSRR = (DNSRR *) pEx;
    pEx += (fQuestionRecord ? sizeof(DNSQRR) : sizeof(DNSRR));

    // this is an error case
    if(pEx > pEnd)
    {
        return(NULL);
    }

    ExEndian(&pDNSRR->TYPE, sizeof(pDNSRR->TYPE));
    ExEndian(&pDNSRR->CLASS, sizeof(pDNSRR->CLASS));

    if(!fQuestionRecord)
    {
        ExEndian(&pDNSRR->TTL, sizeof(pDNSRR->TTL));
        ExEndian(&pDNSRR->RDLENGTH, sizeof(pDNSRR->RDLENGTH));
        pEx += pDNSRR->RDLENGTH;
    }

    // went too far
    if(pEx > pEnd)
    {
        return(NULL);
    }

    return(pEx);
}

static uint32_t ExDNSDG(DNSDG * pDNSDG, int16_t cbMax)
{
    bool        fMachineOrder   = DNSIsInMachineOrder(pDNSDG);
    uint8_t *   pRR             = pDNSDG->rrRecords;
    uint8_t *   pEnd            = ((uint8_t *) pDNSDG) + cbMax;
    uint16_t    cQD             = pDNSDG->dnsHdr.QDCOUNT;
    uint16_t    cRR             = pDNSDG->dnsHdr.ANCOUNT + pDNSDG->dnsHdr.NSCOUNT + pDNSDG->dnsHdr.ARCOUNT + cQD;
    uint16_t    i               = 0;

    // exchange the header
    // ExEndian(&pDNSDG->dnsHdr.ID, sizeof(pDNSDG->dnsHdr.ID));
    ExEndian(&pDNSDG->dnsHdr.QDCOUNT, sizeof(pDNSDG->dnsHdr.QDCOUNT));
    ExEndian(&pDNSDG->dnsHdr.ANCOUNT, sizeof(pDNSDG->dnsHdr.ANCOUNT));
    ExEndian(&pDNSDG->dnsHdr.NSCOUNT, sizeof(pDNSDG->dnsHdr.NSCOUNT));
    ExEndian(&pDNSDG->dnsHdr.ARCOUNT, sizeof(pDNSDG->dnsHdr.ARCOUNT));
    DNSToggleOrder(pDNSDG);
    
    // if we got the counts wrong before, get them correct now.
    if(!fMachineOrder)
    {
        cQD = pDNSDG->dnsHdr.QDCOUNT;
        cRR = pDNSDG->dnsHdr.ANCOUNT + pDNSDG->dnsHdr.NSCOUNT + pDNSDG->dnsHdr.ARCOUNT + cQD;
    }

    // now switch all of the answer records
    for(i=0; i < cRR && pRR < pEnd; i++)
    {
        pRR = ExDNSRRecord(pRR, (i < cQD), pEnd);
    }

    return(pRR - ((uint8_t *) pDNSDG));
}

static uint8_t * DNSSkipRRecord(uint8_t * pRecord, bool fQuestionRecord, uint8_t * pEnd)
{
    uint8_t * pLoc = DNSSkipName(pRecord, pEnd);

    if(pLoc != NULL)
    {
        if(fQuestionRecord)
        {
            pLoc += sizeof(DNSQRR);
        }
        else
        {
            pLoc += ((DNSRR *) pLoc)->RDLENGTH + sizeof(DNSRR);
        }
    }

    return(min(pLoc, pEnd));
}

static uint8_t * DNSSkipToRRSection(DNSDG * pDNSDG, uint32_t rrr, uint8_t * pEnd)
{
    uint8_t *   pRR     = pDNSDG->rrRecords;
    uint32_t    cRRSkip = 0;
    uint32_t    i       = 0;
    
    if(rrr > DNSRRQD)
    {
        cRRSkip = pDNSDG->dnsHdr.QDCOUNT;
    }
    
    if(rrr > DNSRRAN)
    {
        cRRSkip += pDNSDG->dnsHdr.ANCOUNT;
    }
   
    if(rrr > DNSRRNS)
    {
        cRRSkip += pDNSDG->dnsHdr.NSCOUNT;
    }
    
    // too far
    if(rrr > DNSRRAR)
    {
        return(NULL);
    }
   
    // skip up to the record in question
    for(i=0; i<cRRSkip && pRR < pEnd; i++)
    {
        pRR     = DNSSkipRRecord(pRR, (i < pDNSDG->dnsHdr.QDCOUNT), pEnd);
    }
    
    return(pRR);
}

// NULL name will always match
static DNSRR* DNSFindRR(DNSDG * pDNSDG, void * pRRCur, uint32_t rrr, uint16_t type, uint16_t _class, uint8_t * pName, uint8_t * pEnd)
{
    uint8_t *   pRR     = DNSSkipToRRSection(pDNSDG, rrr, pEnd);
    uint32_t    cRR     = ((uint16_t *) &pDNSDG->dnsHdr.QDCOUNT)[rrr-DNSRRQD];
    uint32_t    cbDNSRR = (rrr == DNSRRQD) ? sizeof(DNSQRR) : sizeof(DNSRR);
    uint32_t    i       = 0;

    // if we have indexed in
    for(i=0; i<cRR && pRR < pEnd; i++)
    {
        DNSRR *     pDNSRR = (DNSRR *) DNSSkipName(pRR, pEnd);

        // compare the names
        if( pRR >= (uint8_t *) pRRCur   &&
            pDNSRR->TYPE    == type     &&
            pDNSRR->CLASS   == _class    &&
            (pName == NULL || DNSCompareRRName((uint8_t *) pDNSDG, pName, pRR, pEnd)))
        {
            // we found a matching CName, so lets use the new CName and see if we find another CName
            return(pDNSRR);
        }

        pRR = ((uint8_t *) pDNSRR) + pDNSRR->RDLENGTH + cbDNSRR;
    }

    return(NULL);
}

static uint8_t * DNSFindCName(DNSDG * pDNSDG, uint32_t rrr, uint8_t * pCName, uint8_t * pEnd)
{
    DNSRR *     pDNSRR = NULL;

    while((pDNSRR = DNSFindRR(pDNSDG, NULL, rrr, DNSTYPECNAME, DNSCLASSIN, pCName, pEnd)) != NULL)
    {
        pCName = pDNSRR->RDATA;
    }

    return(pCName);
}


static DNSRR * DNSFindNSARR(DNSDG * pDNSDG, uint8_t * pName, uint8_t * pEnd, uint16_t dnsType)
{
    DNSRR *     pDNSRRNS        = NULL;
    DNSRR *     pDNSRRA         = NULL;
    uint32_t    i               = 0;
    uint32_t    cBestMatch      = 0;
    DNSRR *     pDNSRRABest     = NULL;
    uint8_t *   pRR             = DNSSkipToRRSection(pDNSDG, DNSRRNS, pEnd);
    uint16_t    rgLL[DNScLL];
    uint32_t    crgLL           = DNSGetNameLabelList((uint8_t *) pDNSDG, pName, pEnd, 0, rgLL, DNScLL);

    if(crgLL == 0)
    {
        return(NULL);
    }

    // now walk all of the name servers looking for the best match
    for(i=0; i < pDNSDG->dnsHdr.NSCOUNT && ((uint8_t *) pDNSDG) <= pRR && pRR < pEnd; i++)
    {
        uint32_t    cLabelMatches = 0;
        
        pDNSRRNS = (DNSRR *) DNSSkipName(pRR, pEnd);

        // see if this is a NS and that there is a dnsType in Additional records
        if(pDNSRRNS != NULL && pDNSRRNS->TYPE == DNSTYPENS && (pDNSRRA = DNSFindRR(pDNSDG, NULL, DNSRRAR, dnsType, DNSCLASSIN, pDNSRRNS->RDATA, pEnd)) != NULL)
        {

            // now lets see how well this name matches to what we are looking for
            cLabelMatches = DNSCompareLabelListAndName((uint8_t *) pDNSDG, pRR, pEnd, 0, rgLL, crgLL);

            if(cLabelMatches > cBestMatch || pDNSRRABest == NULL)
            {
                pDNSRRABest = pDNSRRA;
            }
        }

        pRR = ((uint8_t *) pDNSRRNS) + sizeof(DNSRR) + pDNSRRNS->RDLENGTH;
    }

    return(pDNSRRABest);
}

static uint16_t DNSParseDomainName(uint8_t const * const szDomainName, uint32_t const cbParse, uint8_t * const pchrr, uint16_t const cbchrr)
{
    uint8_t *   pcbLabel = pchrr;
    uint8_t *   pch = pchrr+1;                      // get past the first count
    uint32_t    i = 0;

    // got to be able to hold the whole string in the RR.
    // remember we need to have a leading count and a trailing 0
    // so we need 2 extra bytes of the strlen over the szDomainName.
    *pcbLabel = 0;
    if((int32_t) cbParse > cbchrr-2)
    {
        return(0);
    }

    // copy everything over, changing '.'s to counts
    for(i=0; i<=cbParse; i++)
    {
        // label seperater
        if(szDomainName[i] == '.' || szDomainName[i] == '\0')
        {
            // save away the count
            *pcbLabel = pch - pcbLabel - 1;

            // zero it out, this may be the terminator
            *pch = 0;

            // now if this has a zero length, we are at the end of the Domain name
            // a double .. will terminate the domain name
            // remember pch is 1 byte ahead of pchLabel if *pchLabel == 0, so pch will
            // include the terminting 0
            if(*pcbLabel == 0)
            {
                return(pch - pchrr);
            }

            // assigne the next count location
            pcbLabel = pch;

            // move pch ahead of the count
            pch++;
        }

        // valid domain name label; RFC 1035 2.3.1
        else if( isalnum(szDomainName[i]) || szDomainName[i] == '-' )
        {
            // a simple copy
            *pch++ = szDomainName[i];
        }

        // not valid character, invalid Domain Name
        else
        {
            return(0);
        }
    }

    // return how many char we populated
    return(pch - pchrr);
}

static uint16_t DNSCreateIPv4Query(const LLADP * pLLAdp, uint16_t cbDN, DNSDG * pDNSDG)
{
    DNSQRR *    pDNSQRR = (DNSQRR *) (pDNSDG->rrRecords + cbDN);  // get past the DN

    if(cbDN > 0)
    {
        memset(&pDNSDG->dnsHdr, 0, sizeof(DNSHDR));
        pDNSDG->dnsHdr.ID       = pLLAdp->ipMy.ipv4.u32 + GetSysTick(); // psudo random ID number.
        pDNSDG->dnsHdr.QR       = DNSQRQUERY;                           // Query request
        pDNSDG->dnsHdr.Opcode   = DNSOPQUERY;                           // standard query
        pDNSDG->dnsHdr.RD       = true;                                 // want the server to search recursively
        pDNSDG->dnsHdr.QDCOUNT  = 1;                                    // only 1 question, what is the IP
        DNSSetToMachineOrder(pDNSDG);
        // make the question
        pDNSQRR->TYPE           = DNSTYPEA;                             // Asking for an IP
        pDNSQRR->CLASS          = DNSCLASSIN;                           // on the internet

        // Debug stuff
//        pDNSQRR->TYPE           = DNSTYPENS;
//        pDNSDG->dnsHdr.RD       = false;                              // As a pratical matter, if you don't go recursive, you get nothing.

        return(sizeof(DNSHDR) + cbDN + sizeof(DNSQRR));
    }

    return(0);
}
static uint16_t DNSCreateIPv4QueryCB(const LLADP * pLLAdp, const uint8_t * pchDomainName, uint32_t cchDomainName, DNSDG * pDNSDG)
{
    return(DNSCreateIPv4Query(pLLAdp, DNSParseDomainName(pchDomainName, cchDomainName, pDNSDG->rrRecords, sizeof(pLLAdp->pDNSMem->rgbDNSData)), pDNSDG));
}

static uint16_t DNSCreateIPv4QueryDN(const LLADP * pLLAdp, const uint8_t * pBase, const uint8_t * pName, const uint8_t * pEnd, DNSDG * pDNSDG)
{
    return(DNSCreateIPv4Query(pLLAdp, DNSCopyDomainName(pBase, pName, pEnd, pDNSDG->rrRecords, sizeof(pLLAdp->pDNSMem->rgbDNSData)), pDNSDG));
}

// Notes on dnsNSMax and cDhcpNS. You would think that we should only cycle through cDhcpNS as this is the number
// DNS servers given to us by DHCP, however, sometimes DHCP does not give us good DNS servers and for the
// SNTP server to work, we need a good DNS server. So we continue to check the default, pre initialized google DNS
// servers after the DHCP DNS servers are checked first. If we get a lot of DNS servers from DHCP, then ultimately
// all of the pre installed google servers will be overwritten in the dnsNSMax list, but if we got a lot of DNS servers
// the assumption is that they are good ones. In particular, I found that Verizon did not give me very good DNS servers, they
// could not resolve the SNTP time servers.
static void DNSStateMachine(const LLADP * pLLAdp)
{
    IPSTATUS    status      = ipsSuccess;

    if(pLLAdp == NULL || pLLAdp->pDNSMem == NULL || !ILIsIPSetup(pLLAdp, NULL))
    {
        return;
    }

    switch(pLLAdp->pDNSMem->dnsState)
    {
        case dnsSend:
            if(pLLAdp->pDNSMem->dnsNSMax == 0)
            {
                pLLAdp->pDNSMem->dnsState = dnsReady;
                pLLAdp->pDNSMem->cTry = 0;
                break;
            }
            else if(pLLAdp->pDNSMem->cTry >= (pLLAdp->pDNSMem->dnsNSMax * DNSMINTRY))
            {
                if(pLLAdp->pDNSMem->iDNSCur == pLLAdp->pDNSMem->iDNSWorks)
                {
                    pLLAdp->pDNSMem->iDNSWorks = DNSiInvalid;
                }
                pLLAdp->pDNSMem->iDNSCur = DNSiInvalid;
                pLLAdp->pDNSMem->dnsState = dnsReady;
                pLLAdp->pDNSMem->cTry = 0;
                break;
            }
            else if(pLLAdp->pDNSMem->iDNSWorks < pLLAdp->pDNSMem->dnsNSMax)
            {
                pLLAdp->pDNSMem->iDNSCur = pLLAdp->pDNSMem->iDNSWorks;
            }
            else if(pLLAdp->pDNSMem->iDNSCur >= pLLAdp->pDNSMem->dnsNSMax)
            {
                pLLAdp->pDNSMem->iDNSCur = 0;
            }
            else
            {
                pLLAdp->pDNSMem->iDNSCur = (pLLAdp->pDNSMem->iDNSCur + 1) % pLLAdp->pDNSMem->dnsNSMax;
            }

            // set this up for an attempt to get the IP address
            memcpy(&pLLAdp->pDNSMem->socket.s.ipRemote, &pLLAdp->pDNSMem->dnsNS[pLLAdp->pDNSMem->iDNSCur], ILIPSize(pLLAdp));

            // fall thru on success

        case dnsReadySend:

            // clear the current IP address
            memset(&pLLAdp->pDNSMem->ip, 0, sizeof(IPv4or6));

            // just make this unique for this pass
            pLLAdp->pDNSMem->dnsDG.dnsHdr.ID++;

            // set my timers and counts
            pLLAdp->pDNSMem->cTry++;
            pLLAdp->pDNSMem->tTimeout = dnsWaitForRetry;
            pLLAdp->pDNSMem->tStart = SYSGetMilliSecond();

            // send out the DNS datagram
            UDPSend(&pLLAdp->pDNSMem->socket, (uint8_t *) &pLLAdp->pDNSMem->dnsDG, pLLAdp->pDNSMem->cbDNSDG, &status);

            // see if it went out.
            if(IsIPStatusAnError(status))
            {
                pLLAdp->pDNSMem->dnsState = dnsReady;
                pLLAdp->pDNSMem->cTry = 0;
            }
            else
            {
                pLLAdp->pDNSMem->dnsState = dnsWaiting;
            }
            break;

        case dnsWaiting:
            {
                uint16_t cbDG = UDPAvailable(&pLLAdp->pDNSMem->socket) ;
                IPSTATUS status;

                if(cbDG > sizeof(DNSHDR))
                {
                    // we need some space for the datagram
                    uint8_t     rgbDNSDG[DNSMAXUDPSIZE];
                    DNSDG *     pDNSDG  = (DNSDG *) rgbDNSDG;
                    uint8_t *   pEnd    = NULL;
                    uint8_t *   pCName  = NULL;
                    DNSRR *     pDNSRRA = NULL;

                    // read the DNS datagram
                    cbDG = UDPRead(&pLLAdp->pDNSMem->socket, rgbDNSDG, DNSMAXUDPSIZE, &status);

                    // There are some servers setting this and they should not! RFC 6195 2.1 and I need to ignore it
                    // Plus this is used internally to determine if we are in machine or network order. This is in network order right now.
                    pDNSDG->dnsHdr.Z = 0;

                    // now put in machine order.
                    cbDG = ExDNSDG(pDNSDG, cbDG);
                    pEnd = rgbDNSDG + cbDG;
                    
                    // if this is not a my response, keep waiting
                    // remember the ID is not exchanged, so network and machine order will have the same ID
                    if(!pDNSDG->dnsHdr.QR || pDNSDG->dnsHdr.ID != pLLAdp->pDNSMem->dnsDG.dnsHdr.ID)
                    {
                        break;
                    }

                    // ops and error occured, jump to finish with error
                    // go to the error state with no address found
                    if(pDNSDG->dnsHdr.RCODE != DNSRCODENoError)
                    {
                        // this is a failure case; go to the next DNS server
                        pLLAdp->pDNSMem->dnsState = dnsSend;
                        break;
                    }
                    
                    // get the canonical name for what we are looking for
                    // the first record is the question which has the name we used.
                    // we need to use the one in this datagram because we do memory range
                    // checking and if we use the QR we sent, it would be out of the memory range
                    pCName = DNSFindCName(pDNSDG, DNSRRAN, pDNSDG->rrRecords, pEnd);

                    // now find the A record
                    pDNSRRA = DNSFindRR(pDNSDG, NULL, DNSRRAN, DNSTYPEA, DNSCLASSIN, pCName, pEnd);

                    // if we got the A record we are done
                    if( pDNSRRA != NULL                                             &&
                        ((ILIsIPv6(pLLAdp)  &&  pDNSRRA->RDLENGTH == sizeof(IPv6))  ||
                         (!ILIsIPv6(pLLAdp) &&  pDNSRRA->RDLENGTH == sizeof(IPv4))  )   )
                    {
                        // copy in our result
                        memcpy(&pLLAdp->pDNSMem->ip, pDNSRRA->RDATA, pDNSRRA->RDLENGTH);

                        // say we are done
                        pLLAdp->pDNSMem->dnsState = dnsReady;
                        pLLAdp->pDNSMem->cTry = 0;

                        // We got an IP so we know this DNS server can work, remember that
                        if(pLLAdp->pDNSMem->iDNSCur < pLLAdp->pDNSMem->dnsNSMax)
                        {
                            pLLAdp->pDNSMem->iDNSWorks = pLLAdp->pDNSMem->iDNSCur;
                        }

                        // get out we found it and are done.
                        break;
                    }

                    // by default we will go to the next well know sever unless we pick up a better NS to go to
                    pLLAdp->pDNSMem->dnsState = dnsSend;

                    // we did not find anything, so update our DNS request to use the new CName
                    if(pCName != pDNSDG->rrRecords)
                    {
                        // make the new DNS packet with the CName instead of what we were using
                        uint16_t cbMax = DNSCreateIPv4QueryDN(pLLAdp, rgbDNSDG, pCName, pEnd, &pLLAdp->pDNSMem->dnsDG);
                        pLLAdp->pDNSMem->cbDNSDG = ExDNSDG(&pLLAdp->pDNSMem->dnsDG, cbMax);
                    }

                    // Didn't find an A record
                    // But maybe there is a name server we should try.
                    // If we asked for recursion and go it, no sense working the issue ourselves.
                    // likewise if there are now NS with IP addresses, no sense working the issue
                    if(!(pDNSDG->dnsHdr.RD && pDNSDG->dnsHdr.RA) && pDNSDG->dnsHdr.NSCOUNT > 0 && pDNSDG->dnsHdr.ARCOUNT > 0)
                    {
                        // this DNS server gave us something, so remember it
                        if(pLLAdp->pDNSMem->iDNSCur < pLLAdp->pDNSMem->dnsNSMax)
                        {
                            pLLAdp->pDNSMem->iDNSWorks = pLLAdp->pDNSMem->iDNSCur;
                        }

                        pDNSRRA = DNSFindNSARR(pDNSDG, pCName, pEnd, DNSTYPEA);

                        // if this looks like a good IP address to try, lets contact that name server
                        if(pDNSRRA != NULL && pDNSRRA->RDLENGTH == sizeof(IPv4))
                        {
                            // say were are not using one of our well known DNS servers
                            pLLAdp->pDNSMem->iDNSCur = DNSiInvalid;
                            
                            // Put the IP in our socket
                            memcpy(&pLLAdp->pDNSMem->socket.s.ipRemote, pDNSRRA->RDATA, pDNSRRA->RDLENGTH);
                            pLLAdp->pDNSMem->dnsState = dnsReadySend;
                        }
                    }

                    else if(pLLAdp->pDNSMem->iDNSWorks == pLLAdp->pDNSMem->iDNSCur)
                    {
                        pLLAdp->pDNSMem->iDNSWorks = DNSiInvalid;
                    }

                }
                else if((SYSGetMilliSecond() - pLLAdp->pDNSMem->tStart) >= pLLAdp->pDNSMem->tTimeout)
                {
                    pLLAdp->pDNSMem->dnsState = dnsWaitTry;
                }
            }
            break;

        case dnsWaitTry:

            if(pLLAdp->pDNSMem->iDNSWorks == pLLAdp->pDNSMem->iDNSCur)
            {
                pLLAdp->pDNSMem->iDNSWorks = DNSiInvalid;
            }
            
            if((pLLAdp->pDNSMem->cTry % DNSMINTRY) == 0)
            {
                pLLAdp->pDNSMem->dnsState = dnsSend;                
            }
            else
            {
                pLLAdp->pDNSMem->dnsState = dnsReadySend;
            }

            break;

        case dnsReady:
            pLLAdp->pDNSMem->cTry = 0;
            break;

        // noting to do here, either we have something in the DNS memory IP or not.
        case dnsRedirect:
        case dnsUninit:
        default:
            break;
    }
}

void DNSPeriodicTasks(void)
{
    const LLADP * pLLAdp = NULL;

    // walk all of the adpators and process each DHCP State
    while((pLLAdp = (LLADP*)FFNext(&ffptAdaptors, pLLAdp)) != NULL)
    {
        DNSStateMachine(pLLAdp);
    }
}

void DNSAbort(const LLADP * pLLAdp)
{
    if(pLLAdp->pDNSMem != NULL)
    {
        pLLAdp->pDNSMem->dnsState = dnsReady;
        pLLAdp->pDNSMem->cTry = 0;
    }
}

bool DNSTerminate(const LLADP * pLLAdp)
{
    if(pLLAdp != NULL && pLLAdp->pDNSMem != NULL)
    {
        pLLAdp->pDNSMem->dnsState = dnsUninit;
        UDPClose(&pLLAdp->pDNSMem->socket);
        ((LLADP *) pLLAdp)->pDNSMem = NULL;
    }

    return(true);
}

bool DNSAddNS(const LLADP * pLLAdp, const void * pIPvX, uint32_t index)
{
    if(pLLAdp->pDNSMem != NULL && pIPvX != NULL && index < pLLAdp->pDNSMem->dnsNSMax)
    {
        memcpy(&pLLAdp->pDNSMem->dnsNS[index], pIPvX, ILIPSize(pLLAdp));
        return(true);
    }
    return(false);
}

bool DNSGetNS(const LLADP * pLLAdp, uint32_t index, void * pIPvX)
{
    if(pLLAdp->pDNSMem != NULL && pIPvX != NULL && index < pLLAdp->pDNSMem->dnsNSMax)
    {
        memcpy(pIPvX, &pLLAdp->pDNSMem->dnsNS[index], ILIPSize(pLLAdp));
        return(true);
    }
    return(false);
}

bool DNSInit(const LLADP * pLLAdp, void * rgbDNSMem, uint32_t cbDNSMem, HPMGR hPMGR, IPSTATUS * pStatus)
{
    IPSTATUS    status = ipsSuccess;
    DNSMEM *    pDNSMem = (DNSMEM *) rgbDNSMem;
    uint32_t    i = 0;

    if(pLLAdp == NULL)
    {
        status = ipsAdaptorMustBeSpecified;
    }
    else if(hPMGR == NULL)
    {
        status = ipsNoPMGRGiven;
    }
    else if(rgbDNSMem == NULL)
    {
        status = ipsDNSMemIsNULL;
    }
    else if(cbDNSMem < sizeof(DNSMEM))
    {
        status = ipsDNSNotEnoughMem;
    }
    else if(pLLAdp->pDNSMem != NULL)
    {
        status = ipsDNSAlreadyInitialized;
    }
    else if(ILIsIPv6(pLLAdp))
    {
        status = ipsIPv6NotSupported;
    }

    if(IsIPStatusAnError(status))
    {
        AssignStatusSafely(pStatus, status);
        return(false);
    }

    memset(pDNSMem, 0, cbDNSMem);
    if(&pDNSMem->socket != UDPOpenWithSocket(pLLAdp, &pDNSMem->socket, hPMGR, &IPv4BROADCAST, portDNSServer, portDynamicallyAssign, &status) ||
       IsIPStatusAnError(status))
    {
        UDPClose(&pDNSMem->socket);
        AssignStatusSafely(pStatus, status);
        return(false);
    }

    pDNSMem->dnsNSMax = (cbDNSMem - sizeof(DNSMEM)) / sizeof(IPv4or6);
    pDNSMem->cDhcpNS = 0;
    pDNSMem->iDNSCur = DNSiInvalid;
    pDNSMem->iDNSWorks = DNSiInvalid;
    pDNSMem->dnsState = dnsReady;
    pDNSMem->cTry = 0;
    ((LLADP *) pLLAdp)->pDNSMem = pDNSMem;

    // initialize them all to the Google NS
    // that way there is something in all of the slots
    // this will get over written if DHCP is used.
    for(i=0; i<pDNSMem->dnsNSMax; i++)
    {
        if((i % 2) == 0)
        {
            pDNSMem->dnsNS[i].ipv4.u32 = 0x04040808; // Google public DNS server
        }
        else
        {
            pDNSMem->dnsNS[i].ipv4.u32 = 0x08080808; // Google public DNS server
        }
    }

    AssignStatusSafely(pStatus, status);
    return(true);
}

static bool DNSStartIPv4Request(const LLADP * pLLAdp, const uint8_t * pchDomainName, uint32_t cchDomanName, IPSTATUS * pStatus)
{
    uint16_t cbMax = DNSCreateIPv4QueryCB(pLLAdp, pchDomainName, cchDomanName, &pLLAdp->pDNSMem->dnsDG);

    // start a new request.
    if(cbMax > 0)
    {
        // put in network order
        pLLAdp->pDNSMem->cbDNSDG = ExDNSDG(&pLLAdp->pDNSMem->dnsDG, cbMax);

        // Go into the state machine
        pLLAdp->pDNSMem->ip.ipv4.u32 = IPv4NONE.u32;
        pLLAdp->pDNSMem->dnsState = dnsSend;
        pLLAdp->pDNSMem->pchDomainName = pchDomainName;
        pLLAdp->pDNSMem->cchDomainName = cchDomanName;
        AssignStatusSafely(pStatus, ipsDNSIsResolving);
        return(true);
    }

    // else the name did not parse
    else
    {
        AssignStatusSafely(pStatus, ipsDNSInvalidName);
        return(false);
    }
}


// This is not a URL, this must be a domain nume such as www.foo.bar.com with an optional . at the end.
bool DNSResolve(const LLADP * pLLAdp, uint8_t const * const pchDomainName, uint32_t cchDomanName, void * pIPvX, IPSTATUS * pStatus)
{
    IPSTATUS    status = ipsSuccess;

    // see if we are initialized
    if(pLLAdp == NULL)
    {
        status = ipsAdaptorMustBeSpecified;
    }
    else if( !ILIsIPSetup(pLLAdp, &status) )
    {
        // do nothing, I got the status
    }
    else if(pLLAdp->pDNSMem == NULL || pLLAdp->pDNSMem->dnsState == dnsUninit)
    {
        status = ipsDNSIsNotInitialized;
    }
    else if(pchDomainName == NULL)
    {
        status = ipsDomainNameIsNULL;
    }
    else if(pIPvX == NULL)
    {
        status = ipsIPIsNULL;
    }

    // we are currently processing a DNS reqeust
    else if(pLLAdp->pDNSMem->dnsState != dnsReady)
    {
        // this is not the one we are working on!
        if(pLLAdp->pDNSMem->pchDomainName != pchDomainName)
        {
            status = ipsDNSIsInUse;
        }

        // this is the one we are working on, check to see if it is done.
        else
        {
            // go into the state machine.
            status = ipsDNSIsResolving;
        }
    }

    // we are done, see if we got it or not
    else if(pLLAdp->pDNSMem->pchDomainName == pchDomainName && pLLAdp->pDNSMem->cchDomainName == cchDomanName && strncmp((char *) pLLAdp->pDNSMem->pchDomainName, (char *) pchDomainName, cchDomanName) == 0)
    {
        if(ILIsIPv6(pLLAdp))
        {
            // have no idea
            if(memcmp(&pLLAdp->pDNSMem->ip.ipv6, &IPv6NONE, sizeof(IPv6)) == 0)
            {
                status = ipsDNSFailedToResolve;
            }
            // got it
            else
            {
                memcpy(pIPvX, &pLLAdp->pDNSMem->ip.ipv6, sizeof(IPv6));
            }
        }
        // IPv4
        else
        {
            // have no idea
            if(pLLAdp->pDNSMem->ip.ipv4.u32 == IPv4NONE.u32)
            {
                status = ipsDNSFailedToResolve;
            }
            // got it
            else
            {
                memcpy(pIPvX, &pLLAdp->pDNSMem->ip.ipv4, sizeof(IPv4));
            }
        }
    }

    // if we are ready, but he is asking for something else, start a new request.
    // check to see if the domain name starts with a number; as in IP address
    // TODO: IPv6 support
    else if(isdigit(*pchDomainName))
    {
        uint32_t i = 0;
        uint32_t j = 0;
        uint32_t k = 0;
        uint8_t const * pch = pchDomainName;
        
        if(ILIsIPv6(pLLAdp))
        {
            // TODO: do IPv6 support
        }
        else
        {    
            for(i=0; i<4; i++)
            {
                for(j=0, k=0; j<3 && isdigit(*pch); j++, pch++)
                {
                    k *= 10;
                    k += (*pch - '0');                    
                }
                
                if((i<3 && *pch == '.') || (i == 3 && (*pch == '/' || *pch == '\0')))
                {
                    ((IPv4 *) pIPvX)->u8[i] = (uint8_t) k;
                    pch++;
                }

                // if is clearly not an IP address
                // try it as a domain name
                else
                {
                    DNSStartIPv4Request(pLLAdp, pchDomainName, cchDomanName, &status);
                    break;
                }
            }
        
            if(status == ipsSuccess)
            {
                // pretend we got the IP
                pLLAdp->pDNSMem->ip.ipv4.u32 = ((IPv4 *) pIPvX)->u32;
                pLLAdp->pDNSMem->pchDomainName = pchDomainName;
                pLLAdp->pDNSMem->cchDomainName = cchDomanName;
            }
            else
            {
                memcpy(pIPvX, &IPv4NONE, sizeof(IPv4));
            }
        }
    }

    // otherwise we need to go look it up.
    else
    {
        DNSStartIPv4Request(pLLAdp, pchDomainName, cchDomanName, &status);
    }

    AssignStatusSafely(pStatus, status);
    return(status == ipsSuccess);
}

// This parses out the domain name and port
const uint8_t *  DNSParseURL(uint8_t const * const szURL, uint32_t * pcchDomainName, uint16_t * pPort)
{
    uint8_t const * pchProtocol   = szURL;
    uint8_t const * pchDomainName = NULL;
    uint8_t const * pchPort       = NULL;
    uint32_t  port          = 0;
    uint32_t cchProtocol    = 0;
    uint32_t cchDomanName   = 0;

    if(szURL == NULL || pcchDomainName == NULL || pPort == NULL)
    {
        return(NULL);
    }
    *pPort = 0;

    // search for a :, could be at the port, or after the protocol
    pchDomainName = (uint8_t const *) strchr((const char *) szURL, ':');

    // if either port start or protocol was found
    if(pchDomainName != NULL)
    {
        // see if this is the port number
        if(isdigit(*(pchDomainName+1)))
        {
            pchPort = pchDomainName;
            pchDomainName = pchProtocol;    // The begining of the string points to the domain name
            pchProtocol = NULL;             // the : was a port, no protocol listed
        }

        // if not, we must have found the protocol,
        // now look for the port
        else
        {
            pchPort = (uint8_t const *) strchr((const char *) pchDomainName+1, ':');
            // leave the protocol at the begining of the string as we have a protocol
        }
    }

    // if we did not find a :, there is no port or protocol
    // assume the start of the string points to the domain name
    else
    {
            pchDomainName = pchProtocol;
            pchProtocol = NULL;
    }

    // did we even find a port number?
    if(pchPort == NULL || !isdigit(*(pchPort+1)))
    {
        pchPort = NULL;
    }

    // if we found a : and a number did not follow, it must have been
    // that the URL started with a protocol
    if(pchProtocol != NULL)
    {
        cchProtocol = pchDomainName - pchProtocol;
        pchDomainName++;                // get the domain name off of the : ie http://xxxx
    }

    // skip any slashes on the domain name
    while( *pchDomainName == '/' || *pchDomainName == '\\')
    {
        pchDomainName++;
    }

    // get the port number
    if(pchPort != NULL)
    {
        uint8_t const *   pchEnd = (uint8_t const *) strchr((const char *) pchDomainName, '/');
        uint8_t const *   pchEnd1 = (uint8_t const *) strchr((const char *) pchDomainName, '\\');
        uint32_t    i = 0;

        if(pchEnd != NULL && pchEnd1 != NULL)
        {
            pchEnd = min(pchEnd, pchEnd1);
        }
        else if(pchEnd == NULL && pchEnd1 != NULL)
        {
            pchEnd = pchEnd1;
        }

        if(pchEnd == NULL)
        {
            pchEnd = pchPort + strlen((const char *) pchPort);
        }

        cchDomanName = pchPort - pchDomainName;
        pchPort++;  // get past the :

        // get the port number
        for(i=0, port=0; i<5 && pchPort < pchEnd; i++, pchPort++)
        {
            port *= 10;
            if(isdigit(*pchPort))
            {
                port += (*pchPort - '0');
            }
            else
            {
                return(NULL);
            }
        }
    }

    // there is no port number, look for the end of the domain name
    else
    {
        uint8_t const *   pchEnd = (uint8_t const *) strchr((const char *) pchDomainName, '/');
        uint8_t const *   pchEnd1 = (uint8_t const *) strchr((const char *) pchDomainName, '\\');

        if(pchEnd != NULL && pchEnd1 != NULL)
        {
            pchEnd = min(pchEnd, pchEnd1);
        }
        else if(pchEnd == NULL && pchEnd1 != NULL)
        {
            pchEnd = pchEnd1;
        }

        if(pchEnd == NULL)
        {
            pchEnd = pchDomainName + strlen((const char *) pchDomainName);
        }

        cchDomanName = pchEnd - pchDomainName;
    }

    // if no port number was given, then get the port from the protocol
    if(port == 0)
    {
        if(pchProtocol == NULL)
        {
            port = 80;
        }
        else if(cchProtocol == 4 && strncasecmp((const char *) pchProtocol, "http", cchProtocol) == 0)
        {
            port = 80;
        }
        else if(cchProtocol == 3 && strncasecmp((const char *) pchProtocol, "ftp", cchProtocol) == 0)
        {
            port = 21;
        }
        else if(cchProtocol == 4 && strncasecmp((const char *) pchProtocol, "tftp", cchProtocol) == 0)
        {
            port = 69;
        }
        else if(cchProtocol == 6 && strncasecmp((const char *) pchProtocol, "Telnet", cchProtocol) == 0)
        {
            port = 23;
        }
        else if(cchProtocol == 4 && strncasecmp((const char *) pchProtocol, "smtp", cchProtocol) == 0)
        {
            port = 25;
        }
        else if(cchProtocol == 4 && strncasecmp((const char *) pchProtocol, "snmp", cchProtocol) == 0)
        {
            port = 161;
        }
        else if(cchProtocol == 3 && strncasecmp((const char *) pchProtocol, "dns", cchProtocol) == 0)
        {
            port = 53;
        }
        else if(cchProtocol == 6 && strncasecmp((const char *) pchProtocol, "finger", cchProtocol) == 0)
        {
            port = 79;
        }
        else if(cchProtocol == 4 && strncasecmp((const char *) pchProtocol, "pop3", cchProtocol) == 0)
        {
            port = 110;
        }
        else if(cchProtocol == 4 && strncasecmp((const char *) pchProtocol, "nntp", cchProtocol) == 0)
        {
            port = 119;
        }
        else
        {
            port = 80;
        }
    }
    
    if(port >= portInvalid)
    {
        return(NULL);
    }

    *pPort = (uint16_t) port;
    *pcchDomainName = cchDomanName;
    return(pchDomainName);
}
