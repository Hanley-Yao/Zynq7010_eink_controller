/******************************************************************************/
/*                                                                            */
/* MtdsDemo4.cc -- MTDS Library Reference Example 4                           */
/*                                                                            */
/******************************************************************************/
/* Author: Gene Apperson                                                      */
/* Copyright 2016, Digilent Inc. All rights reserved.                         */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This program demonstrates the use of the touch panel on the display board. */
/* Information about touch activity is presented to the application sketch    */
/* via the messaging system provided by the MTDS display device firmware. The */
/* program learns of touch activity by reading touch messages from the        */
/* message queue and then performing activities based on those messages.      */
/*                                                                            */
/* In this case, this application draws a bitmap when it detects finger 1     */
/* touch and then moves the bitmap across the display tracking finger 1's     */
/* movement. It does the same thing with finger 2's activity, drawing a       */
/* different bitmap to show the position of finger 2.                         */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    10/01/2016(GeneA):    Created                                           */
/*    02/14/2017(SamB):     Removed Serial references to port to Xilinx SDK   */
/*    12/19/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    01/09/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/


/* ------------------------------------------------------------ */
/*                Include File Definitions                      */
/* ------------------------------------------------------------ */

#include <mtds.h>
#include <stdint.h>
#include <string.h>
#include "sleep.h"

/* ------------------------------------------------------------ */
/*                Local Type Definitions                        */
/* ------------------------------------------------------------ */

/* Uncomment this define directive to print out the contents of touch messages
** being generated in response to touch activity. Doing so will slow down the
** program significantly, however. More details are in the loop() function.
*/
//#define  PRINT_MSG

/* ------------------------------------------------------------ */
/*                Global Variables                              */
/* ------------------------------------------------------------ */

HDS  hdsDisp;
HDS  hdsFng1;
HBMP hbmpFng1;
HDS  hdsFng2;
HBMP hbmpFng2;

int16_t xcoPrv1;
int16_t ycoPrv1;
int16_t xcoPrv2;
int16_t ycoPrv2;

/* ------------------------------------------------------------ */
/*                Local Variables                               */
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*                Forward Declarations                          */
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*                Procedure Definitions                         */
/* ------------------------------------------------------------ */

/*** setup()
**
**   Parameters:
**      none
**
**   Return Values:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Arduino/MPIDE sketch initialization function.
*/
void setup() {
   bool fStat;

   /* It is possible that we are trying to initialize the interface to the
   ** display board before it has finished its power on initialization. If so,
   ** then the first call to mtds.begin() will fail. We run in a loop trying
   ** to initialize until it succeeds. This usually doesn't take more than one
   ** or two iterations of the loop before it succeeds.
   */
   while (true) {
      fStat = mtds.begin(pinMtdsSelStd, frqMtdsSpiDefault);
      if (fStat) {
         xil_printf("mtds.begin() succeeded\n\r");
         break;
      }
      else {
         xil_printf("mtds.begin() failed\n\r");
         sleep(1);
      }
   }

   /* In this example, unlike the earlier ones, we are getting the DS for the
   ** display and saving it in a global variable. We hold onto it for the entire
   ** life of the program.  The previous demo programs each had a number of
   ** functions that were called to demonstrate particular aspects of the MTDS
   ** system. Each of those functions was a self-contained unit that obtained
   ** resources at the beginning of the function and then released them at the
   ** end. In this case, this program demonstrates a single thing. So it is
   ** reasonable to obtain the necessary resources here in setup() and hold onto
   ** them for the entire life of the program.
   */
   hdsDisp = mtds.GetDisplayDs();

   /* The code in loop() is going to make use of a couple of off-screen bitmaps.
   ** Here we are setting them up and drawing the figures into them that we will
   ** use later in loop().
   */
   /* Obtain a DS and create a bitmap for the image used to display finger 1
   ** touches. Like the display DS, this DS and bitmap are maintained and used
   ** for the entire life of the program.
   */
   hdsFng1  = mtds.GetDs();
   hbmpFng1 = mtds.CreateBitmap(40, 40, 16);
   mtds.SetDrawingSurface(hdsFng1, hbmpFng1);

   mtds.SetDrwRop(hdsFng1, drwCopyPen);
   mtds.SetPen(hdsFng1, penSolid);

   mtds.SetFgColor(hdsFng1, clrGreen);
   mtds.MoveTo(hdsFng1,  0,  0);
   mtds.LineTo(hdsFng1, 39, 39);
   mtds.MoveTo(hdsFng1, 39,  0);
   mtds.LineTo(hdsFng1,  0, 39);

   mtds.SetFgColor(hdsFng1, clrRed);
   mtds.MoveTo(hdsFng1,  0,  0);
   mtds.LineTo(hdsFng1, 39,  0);
   mtds.LineTo(hdsFng1, 39, 39);
   mtds.LineTo(hdsFng1,  0, 39);
   mtds.LineTo(hdsFng1,  0,  0);

   /* Obtain the DS and set up the bitmap used to display finger 2 touches.
   */
   hdsFng2  = mtds.GetDs();
   hbmpFng2 = mtds.CreateBitmap(40, 40, 16);
   mtds.SetDrawingSurface(hdsFng2, hbmpFng2);

   mtds.SetDrwRop(hdsFng2, drwCopyPen);
   mtds.SetPen(hdsFng2, penSolid);
   mtds.SetBrush(hdsFng2, hbrNull);

   mtds.SetFgColor(hdsFng2, clrRed);
   mtds.Ellipse(hdsFng2, 0, 0, 39, 39);
   mtds.SetFgColor(hdsFng2, clrWhite);
   mtds.MoveTo(hdsFng2, 19,  0);
   mtds.LineTo(hdsFng2, 19, 39);
   mtds.MoveTo(hdsFng2,  0, 19);
   mtds.LineTo(hdsFng2, 39, 19);
}

/* ------------------------------------------------------------ */
/*** loop()
**
**   Parameters:
**      none
**
**   Return Values:
**      none
**
**   Errors:
**      none
**
**   Description:
**      Arduino/MPIDE main sketch function
*/
void loop() {
   MTCH mtch;

   /* Check to see if there is a message in the message queue.
   */
   if (mtds.GetMsgStatus() != 0) {
      /* There is a message in the message queue. Read it into the local MTCH
      ** structure so that we can process it.
      ** Note: We are assuming that the only messages in the message queue will
      ** be touch messages. Assuming that to be true, we can read the message
      ** directly into an MTCH structure. If there were other types of messages
      ** in the queue, it would be better to read the message into a generic
      ** MEVT structure. Then we could look at the message id, see what kind of
      ** message it is, and then cast the pointer to a more appropriate message
      ** structure type.
      */
      mtds.GetMsg((MEVT*) &mtch);
    
#if defined(PRINT_MSG)
      /* This will print out the contents of the touch message to the serial
      ** monitor window. This allows you to see the actual messages generated as
      ** the result of touch activity. This slows the processing of messages
      ** down noticeably, though, and will cause the tracking of finger move
      ** message to lag considerably.
      */
      xil_printf("----------------\n\r");
      xil_printf("  tms = ");
      xil_printf("%d", mtch.tms);
      xil_printf("  hwin = ");
      xil_printf("0x%x",mtch.hwin);
      xil_printf("  msg = ");
      xil_printf("0x%x\n\r", mtch.msg);
      xil_printf("  xco = ");
      xil_printf("%d", mtch.xco);
      xil_printf("  yco = ");
      xil_printf("%d", mtch.yco);
      xil_printf("  wgt = ");
      xil_printf("%d", mtch.wgt);
      xil_printf("  spd = ");
      xil_printf("0x%x\n\r",mtch.spd);
#endif

      /* We have gotten a touch message from the message queue. The response
      ** that we perform will depend on the specific message. The first thing
      ** that we do is check that it is actually a touch message and ignore any
      ** messages outside the range of touch messages. We then switch based on
      ** the message id of the message. The message id tells us what specific
      ** kind of touch activity the message is reporting.
      **
      ** The tms member gives a time stamp for when the message was posted to
      ** the system message queue.
      **
      ** The hwin member tells the window handle of the topmost window
      ** containing the coordinate where the touch event occurred. If the
      ** windowing system is not in use, this can be ignored.
      **
      ** The msg member identifies the specific kind of touch activity being
      ** reported.
      **
      ** The xco, yco members give the position of the touch event. For a finger
      ** down message, it gives the pixel position of where the finger came
      ** down. For a finger move message, it gives the current finger position.
      ** For a finger up message, it gives the last know position of the finger.
      **
      ** The wgt member gives an indication of the total area covered by the
      ** touch.
      **
      ** The spd member gives an indication of finger velocity for finger move
      ** messages. The wgt and spd members are generally ignored.
      */
      if ((mtch.msg >= msgFingerFirst) && (mtch.msg <= msgFingerLast)) {
         switch (mtch.msg) {
         case msgFinger1Down:
            /* It is a finger 1 down message. This means that finger 1 was not
            ** previously on the display and has just touched the display. Our
            ** response to this is to draw the finger 1 bitmap on the display.
            ** The bitmap is 40x40 pixels. By subtracting 20 from x and 40 from
            ** y, we will draw it approximately centered above the finger
            ** position. We are remembering the position where we drew the
            ** bitmap so that we can erase it later when we get finger move or
            ** finger up messages.
            */
            xcoPrv1 = mtch.xco - 20;
            ycoPrv1 = mtch.yco - 40;
            mtds.BitBlt(hdsDisp, xcoPrv1, ycoPrv1, 40, 40, hdsFng1, 0, 0,
                  ropSrcCopy);
            break;

         case msgFinger1Move:
            /* It is a finger 1 move message. This means that finger 1 has moved
            ** to a new location on the display without leaving the display. Our
            ** response to this is to erase the finger 1 bitmap at the last
            ** location where we drew it and to draw it again at the new
            ** location.
            **
            ** Note the the display is being erased by using BitBlt() to copy
            ** the same bitmap using the ropSrcInvert raster-op. This raster-op
            ** will XOR the source pixels with the destination pixels. This will
            ** ignore black pixels in the source or destination, but set any
            ** pixels that match between the source and destination to black,
            ** effectively erasing what we drew before. This really only works,
            ** though, because we are drawing on a black background. A more
            ** general erase would be done by copying the current contents of
            ** the display to another off-screen bitmap before drawing, then
            ** using this bitmap to erase the display.
            */
            mtds.BitBlt(hdsDisp, xcoPrv1, ycoPrv1, 40, 40, hdsFng1, 0, 0,
                  ropSrcInvert);
            xcoPrv1 = mtch.xco - 20;
            ycoPrv1 = mtch.yco - 40;
            mtds.BitBlt(hdsDisp, xcoPrv1, ycoPrv1, 40, 40, hdsFng1, 0, 0,
                  ropSrcCopy);
            break;

         case msgFinger1Up:
            /* It is a finger 1 up message. This means that finger 1 is no
            ** longer in contact with the display. Our response to this is to
            ** erase the finger 1 bitmap from the display. See the previous
            ** discussion of how the erase is being done.
            */
            mtds.BitBlt(hdsDisp, xcoPrv1, ycoPrv1, 40, 40, hdsFng1, 0, 0,
                  ropSrcInvert);
            break;

         case msgFinger2Down:
            /* It is a finger 2 down message. this means that a second finger
            ** has come in contact with the display while finger 1 is still in
            ** contact. We treat the finger 2 messages in exactly the same was
            ** as the finger 1 messages, except that we draw the finger 2
            ** bitmap. The way finger tracking works is that as long as a finger
            ** is in contact with the display it retains the same
            ** finger1/finger2 identity. So, if finger 1 is in contact with the
            ** display, another touch is treated as finger 2. Once a touch has
            ** been identified as finger 2, it will continue to be reported as
            ** finger 2 even if finger 1 leaves the display and finger 2 is the
            ** only one in contact.
            */
            xcoPrv2 = mtch.xco - 20;
            ycoPrv2 = mtch.yco - 40;
            mtds.BitBlt(hdsDisp, xcoPrv2, ycoPrv2, 40, 40, hdsFng2, 0, 0,
                  ropSrcCopy);
            break;

         case msgFinger2Move:
            /* Finger 2 move message. Finger 2 has moved to a new location
            ** without leaving the display. Erase the finger 2 bitmap from the
            ** previous location and draw it as the new location.
            */
            mtds.BitBlt(hdsDisp, xcoPrv2, ycoPrv2, 40, 40, hdsFng2, 0, 0,
                  ropSrcInvert);
            xcoPrv2 = mtch.xco - 20;
            ycoPrv2 = mtch.yco - 40;
            mtds.BitBlt(hdsDisp, xcoPrv2, ycoPrv2, 40, 40, hdsFng2, 0, 0,
                  ropSrcCopy);
            break;

         case msgFinger2Up:
            /* Finger 2 up message. Finger 2 has left the display. Erase the
            ** finger 2 bitmap at the location where it was previously drawn.
            */
            mtds.BitBlt(hdsDisp, xcoPrv2, ycoPrv2, 40, 40, hdsFng2, 0, 0,
                  ropSrcInvert);
            break;
         }
      }
   }
}
