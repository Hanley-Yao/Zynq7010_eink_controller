/************************************************************************/
/*                                                                      */
/*    Helper.cpp                                                        */
/*                                                                      */
/*    Helper functions to deal with date and time                       */
/*    and blinking LEDs                                                 */
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
/*    2/1/2013(KeithV): Created                                         */
/************************************************************************/
#include    "HTTPServer.h"
#include "stdio.h"
#include "xparameters.h"

#define LEDAD	XPAR_AXI_GPIO_LED_BASEADDR
/***    void SetLED(SLED::STATE state)
    *
    *    Parameters:
    *          state The SYSSTATE to change to
    *              
    *    Return Values:
    *          None
    *
    *    Description: 
    *    
    *      This controls the system LED.
    *      If the system is not ready, that is no IP stack is open
    *      then we are NOTREADY and the LED will be OFF.
    *      If however we are listening, we are READY and the LED will blink
    *      If however we are processing a request, we are WORKING and the LED will be ON
    *
    *      It is the parameter SLED::STATE that the comiler will not 
    *      accept unless the namespace is also supplied, not sure why
    *      parameters are out of enum typedef scope when eveything else is.
    * ------------------------------------------------------------ */
static SLED::STATE ledCurState = SLED::NOTREADY;
void SetLED(SLED::STATE state)
{
    static unsigned long msblinkPeriod = 500;     // blinks every 1/2 second
    static unsigned long tStart = 0;
    static int  blinkState = 0;

    // only change if we are told to do something new
    if(state != SLED::PROCESS)
    {
        ledCurState = state;
    }

    switch(ledCurState)
    {
        case SLED::NOTREADY:
            blinkState = 0;
            break;

        case SLED::READY:
            if(SYSGetMilliSecond() - tStart > msblinkPeriod)
            {
                blinkState ^= 1;
                tStart = SYSGetMilliSecond();
            }
            break;

        case SLED::WORKING:
            blinkState = 1;
            break;

        case SLED::PROCESS:
        default:
            break;
    }

    //Xil_Out32(LEDAD, blinkState);
    //digitalWrite(PIN_LED_SAFE, blinkState);
}

SLED::STATE GetLEDState(void)
{
    return(ledCurState);
}

/***    int GetIP(IPv4& ip, sz)
 *
 *    Parameters:
 *          ip, the IP to print
 *          sz - a pointer to a buffer long enough to take the number
 *
 *    Return Values:
 *          nbr or char in the string
 *
 *    Description: 
 *    
 *      A simple routine to print the IP address out
 *      on the serial monitor.
 * ------------------------------------------------------------ */
int GetIP(IPv4& ip, char * sz)
{
    sprintf(sz, "IP: %d.%d.%d.%d",ip.u8[0],ip.u8[1],ip.u8[2],ip.u8[3]);
    return 1;
    //return(cch + GetNumb(ip.u8, 4, '.', &sz[cch]));
}

/***    int GetMAC(MAC& mac, sz)
 *
 *    Parameters:
 *          mac, the MAC to print
 *          sz - a pointer to a buffer long enough to take the number
 *              
 *    Return Values:
 *          nbr or char in the string
 *
 *    Description: 
 *    
 *      A simple routine to print the MAC address out
 *      on the serial monitor.
 * ------------------------------------------------------------ */
int GetMAC(MACADDR& mac, char * sz)
{
    sprintf(sz, "MAC: %d:%d:%d:%d:%d:%d", mac.u8[0],mac.u8[1],mac.u8[2],mac.u8[3],mac.u8[4],mac.u8[5]);

    return 1;
}

/***    int GetNumb(byte * rgb, int cb, char chDelim, sz)
 *
 *    Parameters:
 *          rgb - a pointer to a MAC or IP, or any byte string to print
 *          cb  - the number of bytes in rgb
 *          chDelim - the delimiter to use between bytes printed
 *          sz - a pointer to a buffer long enough to take the number
 *              
 *    Return Values:
 *          nbr or char in the string
 *
 *    Description: 
 *    
 *      A simple routine to print to the serial monitor bytes in either HEX or DEC
 *      If the delimiter is a ':' the output will be in HEX
 *      All other delimiters will be in DEC.
 *      Only HEX numbers get leading 0
 *      DEC number have no leading zeros on the number.
 * ------------------------------------------------------------ */
int GetNumb(byte * rgb, int cb, char chDelim, char * sz)
{
    int cch = 0;

    for(int i=0; i<cb; i++)
    {
        if(chDelim == ':' && rgb[i] < 16)
        {
            sz[cch++] = '0';
        }

        if(chDelim == ':')
        {
            //itoa(rgb[i], &sz[cch], 16);
            sprintf(sz+cch,"%X", rgb[i]);
        }
        else
        {
            //itoa(rgb[i], &sz[cch], 10);
        	sprintf(sz+cch,"%d", rgb[i]);
        }
        cch += strlen(&sz[cch]);

        if(i < cb-1)
        {
            sz[cch++] = chDelim;
        }
    }
    sz[cch] = 0;

    return(cch);
}

/***    void GetDayAndTime()
 *
 *    Parameters:
 *          epochTimeT  - the epoch time to format to UTC time.
 *          sz - a pointer to a buffer long enough to take the number (min of 29, but leave 32 bytes)
 *              
 *    Return Values:
 *          nbr or char in the string
 *
 *    Description: 
 *    
 *      This illistrates how to use the Ethernet.secondsSinceEpoch()
 *      method to get the current time and display it.
 *
 *      In order for this call to work you must have a valid 
 *      DNS server so the time servers can be located 
 * ------------------------------------------------------------ */
int GetDayAndTime(unsigned int epochTimeT, char * sz)
{
    // Epoch is 1/1/1970; I guess that is when computers became real?
    // There are 365 days/year, every 4 years is leap year, every 100 years skip leap year. Every 400 years, do not skip the leap year. 2000 did not skip the leap year
    static const unsigned int secPerMin = 60;
    static const unsigned int secPerHour = 60 * secPerMin;
    static const unsigned int secPerDay  = 24 * secPerHour;
    static const unsigned int secPerYear = 365 * secPerDay;
    static const unsigned int secPerLeapYearGroup = 4 * secPerYear + secPerDay;
    static const unsigned int secPerCentury = 25 * secPerLeapYearGroup - secPerDay;
    static const unsigned int secPer400Years = 4 * secPerCentury + secPerDay;;
    static const int daysPerMonth[] = {31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 29}; // Feb has 29, we must allow for leap year.
    static const char * szMonths[] = {"Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb"}; 
    
    int cch = 0;
 
    // go ahead and adjust to a leap year, and to a century boundary
    // at Mar 2000 we have 30 years (From 1970) + 8 leap days (72,76,80,84,88,92,96, and Feb 2000 do not skip leap year) and Jan (31) + Feb(28)
    unsigned int secSinceMar2000 = epochTimeT - 30 * secPerYear - (8 + 31 + 28) * secPerDay;
 
    unsigned int nbr400YearGroupsFromMar2000 = secSinceMar2000 / secPer400Years;
    unsigned int secInThis400YearGroups = secSinceMar2000 % secPer400Years;
    
    // now we are aligned so the weirdness for the not skiping of a leap year is the very last day of the 400 year group.
    // because of this extra day in the 400 year group, it is possible to have 4 centries and a day.
    unsigned int nbrCenturiesInThis400YearGroup = secInThis400YearGroups / secPerCentury;
    unsigned int secInThisCentury = secInThis400YearGroups % secPerCentury;

    // if we come up with 4 centries, then we must be on leap day that we don't skip at the end of the 400 year group
    // so add the century back on as this  Century is the extra day in this century.
    if(nbrCenturiesInThis400YearGroup == 4)
    {
        nbrCenturiesInThis400YearGroup = 3;   // This can be a max of 3 years
        secInThisCentury += secPerCentury;    // go ahead and add the century back on to our time in this century
    }

    // This is going to work out just fine
    // either this is a normal century and the last leap year group is going to be a day short,
    // or this is at the end of the 400 year group and the last 4 year leap year group will work out to have 29 days as in a normal
    // 4 year leap year group.  
    unsigned int nbrLeapYearGroupsInThisCentury = secInThisCentury / secPerLeapYearGroup;
    unsigned int secInThisLeapYearGroup = secInThisCentury % secPerLeapYearGroup;
 
    // if this is at the end of the leap year group, there could be an extra day
    // which could cause us to come up with 4 years in this leap year group.
    unsigned int nbrYearsInThisLeapYearGroup = secInThisLeapYearGroup / secPerYear;
    unsigned int secInThisYear = secInThisLeapYearGroup % secPerYear;

    // are we on a leap day?
    if(nbrYearsInThisLeapYearGroup == 4)
    {
        nbrYearsInThisLeapYearGroup = 3;    // that is the max it can be.
        secInThisYear += secPerYear;        // add back the year we just took off the leap year group
    }
  
    int nbrOfDaysInThisYear = (int) (secInThisYear / secPerDay); // who cares if there is an extra day for leap year
    int secInThisDay = (int) (secInThisYear % secPerDay);
 
    int nbrOfHoursInThisDay = secInThisDay / secPerHour;
    int secInThisHours = secInThisDay % secPerHour;
 
    int nbrMinInThisHour = secInThisHours / secPerMin;
    int secInThisMin = secInThisHours % secPerMin;
    
    int monthCur = 0;
    int dayCur = nbrOfDaysInThisYear;
    int yearCur = 2000 + 400 * nbr400YearGroupsFromMar2000 + 100 * nbrCenturiesInThis400YearGroup + 4 * nbrLeapYearGroupsInThisCentury + nbrYearsInThisLeapYearGroup;
  
    // this will walk us past the current month as the dayCur can go negative.
    // we made the leap day the very last day in array, so if this is leap year, we will be able to
    // handle the 29th day.
    for(monthCur = 0, dayCur = nbrOfDaysInThisYear; dayCur >= 0; monthCur++)
    {
      dayCur -= daysPerMonth[monthCur];
    }
     
    // since we know we went past, we can back up a month
    monthCur--;
    dayCur += daysPerMonth[monthCur]; // put the last months days back to go positive on days
     
    // We did zero based days in a month, but we read 1 based days in a month.
    dayCur++;

    // we have one remaining issue
    // if this is Jan or Feb, we are really into the next year. Remember we started our year in Mar, not Jan
    // so if this is Jan or Feb, then add a year to the year
    if(monthCur >= 10)
    {
        yearCur++;
    }
     

    // local
    strcpy(sz, "UTC: ");
    cch += strlen(sz);

    // month
    strcpy(&sz[cch], szMonths[monthCur]);
    cch += strlen(szMonths[monthCur]);
    sz[cch++] = ' ';

    // day
    //itoa(dayCur, &sz[cch], 10);
    sprintf(sz+cch, "%d", dayCur);
    cch += strlen(&sz[cch]);
    sz[cch++] = ',';
    sz[cch++] = ' ';
    
    // year
    //itoa(yearCur, &sz[cch], 10);
    sprintf(sz+cch, "%d", yearCur);
    cch += strlen(&sz[cch]);
    sz[cch++] = ' ';
    sz[cch++] = '@';
    sz[cch++] = ' ';

    // hour
    //itoa(nbrOfHoursInThisDay, &sz[cch], 10);
    sprintf(sz+cch, "%d", nbrOfHoursInThisDay);
    cch += strlen(&sz[cch]);
    sz[cch++] = ':';
    
    // min
    if(nbrMinInThisHour < 10)
    {
        sz[cch++] = '0';
    }
    //itoa(nbrMinInThisHour, &sz[cch], 10);
    sprintf(sz+cch, "%d", nbrMinInThisHour);
    cch += strlen(&sz[cch]);
    sz[cch++] = ':';


    // sec
    if(secInThisMin < 10)
    {
        sz[cch++] = '0';
    }
   //itoa(secInThisMin, &sz[cch], 10);
    sprintf(sz+cch, "%d", secInThisMin);
    cch += strlen(&sz[cch]);
    sz[cch] = 0;

    return(cch);
 }

