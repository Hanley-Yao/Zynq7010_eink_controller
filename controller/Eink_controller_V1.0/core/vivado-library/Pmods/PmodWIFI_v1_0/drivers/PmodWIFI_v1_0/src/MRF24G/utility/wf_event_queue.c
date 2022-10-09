/*******************************************************************************
 MRF24WG Event Queue

  Summary: Contains functions pertaining to event queue handling

  Description: As WiFi events occur they are stored in the event queue, and
               ultimately passed to the WF_ProcessEvent function in wf_event_stub.c
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

//==============================================================================
//                                  INCLUDES
//==============================================================================
#include <stdio.h>
#include <string.h>

#include "./ud_inc/shared/wf_universal_driver.h"
#include "./ud_inc/internal/wf_global_includes.h"


//==============================================================================
//                                  MACROS
//==============================================================================
#define IncrementReadIndex()                    \
    if (g_eventQueue.readIndex == MAX_EVENTS)   \
    {                                           \
        g_eventQueue.readIndex = 0;             \
    }                                           \
    else                                        \
    {                                           \
        ++g_eventQueue.readIndex;               \
    }

#define IncrementWriteIndex()                   \
    if (g_eventQueue.writeIndex == MAX_EVENTS)  \
    {                                           \
        g_eventQueue.writeIndex = 0;            \
    }                                           \
    else                                        \
    {                                           \
        ++g_eventQueue.writeIndex;              \
    }

//==============================================================================
//                                  LOCAL GLOBALS
//==============================================================================
static t_wfEventQueue g_eventQueue;

/*****************************************************************************
  Function:
    void EventQInit(void);

  Summary:
    Initializes MRF24WG event queue

  Description:
    Called by Universal Driver during initialization.  After this call the
    event queue is in an empty state.

 Parameters:
    None

  Returns:
    None

  Remarks:
    None
*****************************************************************************/
void EventQInit(void)
{
    memset(&g_eventQueue, 0x00, sizeof(g_eventQueue));

    g_eventQueue.readIndex  = 0;
    g_eventQueue.writeIndex = 0;
}

/*****************************************************************************
  Function:
    void EventEnqueue(uint8_t eventType, uint32_t eventData);

  Summary:
    Adds an MRF24WG event to the event queue.

  Description:
    Called by Universal Driver when events occur.

 Parameters:
    eventType  -- event type
    eventData  -- data associated with the event; not always used.

  Returns:
    None

  Remarks:
    None
*****************************************************************************/
// increment write index, the write
void EventEnqueue(uint8_t eventType, uint32_t eventData)
{
#if 0
    if (eventType == WF_EVENT_ERROR)
    {
        dbgprintf("WF_EVENT_ERROR\n");
    }
#endif

    t_event *p_eventInQueue;

    // if event queue has filled then most likely a series of errors have occurred,
    // so it is probably best to simply throw away any new events
    if (isEventQFull())
    {
        return;
    }

    p_eventInQueue = &g_eventQueue.event[g_eventQueue.writeIndex];

    // write data to queue
    p_eventInQueue->eventType = eventType;
    p_eventInQueue->eventData = eventData;

    IncrementWriteIndex();
}

/*****************************************************************************
  Function:
    void EventDequeue(t_event *p_event);

  Summary:
    Removes an event from the event queue.

  Description:
    Called by Universal Driver when it is going to report an event to the
    application via a callback function.

 Parameters:
    p_event -- pointer to where event data is written

  Returns:
    Pointer to event object

  Remarks:
    None
*****************************************************************************/
void EventDequeue(t_event *p_event)
{
    t_event *p_eventInQueue;

    // event queue should never be empty
    if (isEventQEmpty())
    {
        // ToDo: callback here?
        for(;;);
    }

    // point to next event in event queue
    p_eventInQueue = &g_eventQueue.event[g_eventQueue.readIndex];

    // copy event info into callers structure
    p_event->eventType = p_eventInQueue->eventType;
    p_event->eventData = p_eventInQueue->eventData;

    IncrementReadIndex();
}

/*****************************************************************************
  Function:
    bool isEventQEmpty(void)

  Summary:
    Determines if event queue is empty

  Description:
    None

 Parameters:
    None

  Returns:
    NonePointer to event object

  Remarks:
    This may appear somewhat complex, but the goal was to avoid the % operator.
    Doing it this way is much more efficient.
*****************************************************************************/

INLINE bool isEventQEmpty(void)
{
    return (g_eventQueue.readIndex == g_eventQueue.writeIndex);
}

// queue full when writeIndex + 1 = readIndex
INLINE bool isEventQFull(void)
{
    uint8_t readIndex  = g_eventQueue.readIndex;
    uint8_t writeIndex = g_eventQueue.writeIndex;

    // check wrap case first
    if ((writeIndex == MAX_EVENTS) && (readIndex == 0))
    {
        return true;
    }
    // else do regular check
    else if ( (writeIndex + 1) == readIndex )
    {
        return true;
    }

    return false;
}
