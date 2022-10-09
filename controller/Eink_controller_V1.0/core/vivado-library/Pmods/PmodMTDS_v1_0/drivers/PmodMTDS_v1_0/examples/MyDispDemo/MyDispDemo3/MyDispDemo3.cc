/******************************************************************************/
/*                                                                            */
/* MyDispDemo3.cc -- MyDisp Library Reference Example 3                       */
/*                                                                            */
/******************************************************************************/
/* Author: Gene Apperson                                                      */
/* Copyright 2016, Digilent Inc. All rights reserved.                         */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This program demonstrates the use of the MyDisp library to create and use  */
/* touch buttons to build a user interface. The example sketch MyDispDemo1    */
/* illustrates the use of most features of the MyDisp library except buttons. */
/* It is assumed that the user is familiar with the operation of that sketch. */
/*                                                                            */
/* This sketch is very similar to MyDispDemo2. It uses different bitmaps for  */
/* the buttons and then demonstrates a couple of other features, including an */
/* example of how to animate a progress wheel. It makes use of images from the*/
/* the Resources directory where the example sketches were obtained. It makes */
/* use of some of the bitmaps in the Images folder, which must be on an SD    */
/* card in the SD card connector on the display board for this sketch to      */
/* work.                                                                      */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    10/06/2016(GeneA):    Created                                           */
/*    02/14/2017(SamB):     Removed Serial references to port to Xilinx SDK   */
/*    12/11/2017(atangzwj): Validated for Vivado 2016.4                       */
/*    01/09/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/* ------------------------------------------------------------ */
/*                Include File Definitions                      */
/* ------------------------------------------------------------ */

#include <mtds.h>
#include <MyDisp.h>
#include <stdint.h>
#include <string.h>
#include "sleep.h"

/* ------------------------------------------------------------ */
/*                Local Type Definitions                        */
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*                Global Variables                              */
/* ------------------------------------------------------------ */

/* These are the names of the bitmap images that make up the progress wheel
** animation.
*/
char *rgszPw[16] = {
   (char*) "BmpLib\\Progress Wheel\\PW1.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW2.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW3.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW4.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW5.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW6.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW7.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW8.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW9.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW10.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW11.bmp",
   (char*) "BmpLib\\Progress Wheel\\PW12.bmp"
};

/* ------------------------------------------------------------ */
/*                Local Variables                               */
/* ------------------------------------------------------------ */

int      iszPwCur  = 0;   // Starting image in the progress wheel display
int      iszPwMax  = 12;  // Number of images in the progress wheel display
uint32_t msPwCur   = 0;   // When was the last progress wheel image drawn
uint32_t msPwDelta = 100; // Time interval between updates of the progress wheel

/* ------------------------------------------------------------ */
/*                Forward Declarations                          */
/* ------------------------------------------------------------ */

void EraseImageBox();
void UpdateProgressWheel();

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

   msPwCur = millis();

   /* Initialize the user interface library. It is quite possible that the
   ** display board hasn't completed its power on/reset initialization at this
   ** point and the begin() function will fail.
   ** Because of this it's a good idea to run the begin() function in a loop in
   ** case it fails the first time. Keep looping until it succeeds.
   */
   while (true) {
      fStat = mydisp.begin();
      if (fStat) {
         xil_printf("mydisp.begin() succeeded\n\r");
         break;
      }
      else {
         xil_printf("mydisp.begin() failed\n\r");
         sleep(1);
      }
   }

   /* Create the buttons that we are going to use.
   ** Here, we are using the createButton() variant that takes the name of a
   ** single bitmap file. This variant draws the bitmap at full intensity when
   ** drawing the button in the up position and draws the same bitmap at reduced
   ** intensity when drawing the button in the down position.
   **
   ** The bitmap used here is just a white square with rounded corners. It was
   ** drawn on a black background, so that when it is drawn with transparency,
   ** it has rounded corners when drawn over the top of the background bitmap.
   */
   char *btn = (char*) "BmpLib\\icon48x48_white_on_black.bmp";
   mydisp.createButton(0, btn, 10, 260);
   mydisp.createButton(1, btn, 96, 260);
   mydisp.createButton(2, btn, 182, 260);
 
   /* Draw this full screen bitmap on the display so that we aren't working
   ** against a black background.
   */
   char *background = (char*) "Images/IMG_LOGO.BMP";
   mydisp.drawImage(background, 0, 0);

   /* Draw a few other of the bitmaps in the BmpLib folder. These are drawn
   ** without transparency, since it defaults to off and we haven't turned it on
   ** yet. We want transparency off when these are drawn, as some of the
   ** graphics in them is black and we want the black to be drawn.
   */
   char *bmp0 = (char*) "BmpLib\\3bar_32x32_black_on_grayy.bmp";
   char *bmp1 = (char*) "BmpLib\\back_arrow_black_on_grayy.bmp";
   char *bmp2 = (char*) "BmpLib\\checkbox_unchecked_black_on_gray.bmp";
   char *bmp3 = (char*) "BmpLib\\checkbox_checked_black_on_gray.bmp";
   mydisp.drawImage(bmp0, 10, 140);
   mydisp.drawImage(bmp1, 50, 140);
   mydisp.drawImage(bmp2, 90, 140);
   mydisp.drawImage(bmp3, 130, 140);
  
   /* When a button is first created, it is disabled. Enable the buttons so that
   ** they are active. A disabled/inactive button isn't drawn by drawButton()
   ** and doesn't respond to touch activity.
   */
   mydisp.enableButton(0, true);
   mydisp.enableButton(1, true);
   mydisp.enableButton(2, true);
  
   /* This function clears a part of the display where images will be drawn
   ** later.
   */
   EraseImageBox();
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
   /* This function must be called periodically to process touch messages from
   ** the display board. It maintains the current touch state and handles any
   ** processing to link touch activity to buttons. If this function isn't called
   ** often enough, touch activity tracking will become erratic.
   */
   mydisp.checkTouch();

   /* This function updates the progress wheel animation. The progress wheel
   ** bitmaps are drawn on a black background
   */
   UpdateProgressWheel();
  
   /* Update the appearance of the buttons. For each button, check if it is
   ** currently being touched or not and draw the appropriate image.
   ** drawButton() keeps track of the last image drawn for each button and only
   ** actually draws anything when there is a state change.
   **
   ** The bitmaps were drawn as a square with rounded corners on a black
   ** background. We want to make sure transparency is on when we draw them so
   ** that we get the rounded corners and not black corners.
   */
   mydisp.setTransparency(true);
   mydisp.drawButton(0, mydisp.isTouched(0) ? BUTTON_DOWN : BUTTON_UP);
   mydisp.drawButton(1, mydisp.isTouched(1) ? BUTTON_DOWN : BUTTON_UP);
   mydisp.drawButton(2, mydisp.isTouched(2) ? BUTTON_DOWN : BUTTON_UP);
   mydisp.setTransparency(false);
  
   /* See if there has been a button press and perform the related button action
   ** if there has been. getButton() returns the ID of the last button for which
   ** there has been a "button press" event, or -1 if there hasn't been. A
   ** "button press" is a finger going down on the button and then back up
   ** without having moved outside of the button area before going up.
   */
   switch (mydisp.getButton()) {
   case 0:
      /* Button 0 was pressed. Erase the image area on the display and then draw
      ** an image and a label with the image name there.
      */
      EraseImageBox();
      mydisp.drawImage((char*) "Images/IMG_0010.BMP", 50, 20);
      mydisp.setForeground(clrGreen);
      mydisp.setTransparency(true);
      mydisp.drawText((char*) "Image: IMG_0010.BMP", 20, 108);
      mydisp.setTransparency(false);
      break;

   case 1:
      /* Button 0 was pressed. Erase the image area on the display and then draw
      ** an image and a label with the image name there.
      */
      EraseImageBox();
      mydisp.drawImage((char*) "Images/IMG_0011.BMP", 30, 20);
      mydisp.setForeground(clrGreen);
      mydisp.setTransparency(true);
      mydisp.drawText((char*) "Image: IMG_0011.BMP", 20, 108);
      mydisp.setTransparency(false);
      break;

   case 2:
      /* Button 0 was pressed. Erase the image area on the display and then draw
      ** an image and a label with the image name there.
      */
      EraseImageBox();
      mydisp.drawImage((char*) "Images/IMG_0100.BMP", 20, 20);
      mydisp.setForeground(clrGreen);
      mydisp.setTransparency(true);
      mydisp.drawText((char*) "Image: IMG_0100.BMP", 20, 108);
      mydisp.setTransparency(false);
      break;
   }
}

/* ------------------------------------------------------------ */
/*** EraseImageBox
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
**      This function clears an area on the display in preparation for drawing
**      an image there.
*/
void EraseImageBox() {
   /* Fill the rectangle with dark gray.
   */
   mydisp.setForeground(clrDkGray);
   mydisp.setPen(penNull);
   mydisp.drawRectangle(true, 10, 10, 230, 120);

   /* And draw a white border around it.
   */
   mydisp.setForeground(clrWhite);
   mydisp.setPen(penSolid);
   mydisp.drawRectangle(false, 10, 10, 230, 120);
}

/* ------------------------------------------------------------ */
/*** UpdateProgressWheel()
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
**      This function draws an animation of a progress wheel. The progress wheel
**      was drawn using Adobe Photoshop as a series of bitmaps showing various
**      states of the wheel as it rotates. The basic process is to keep track of
**      the array index and the time of when the last image was drawn. After the
**      appropriate amount of time has elapsed, increment the index and draw the
**      next image called for in the array. When the index hits the end, set it
**      back to the beginning.
*/
void UpdateProgressWheel() {
   uint32_t ms;

   /* Get the current time.
   */
   ms = millis();
  
   /* If the current time is greater than the last update time plus the update
   ** delta or if the current time is less than the last update time (timer
   ** reset since last check), then we need to update to the next image in the
   ** sequence.
   */
   if (ms > msPwCur + msPwDelta || ms < msPwCur) {
      iszPwCur += 1;
      if (iszPwCur >= iszPwMax) {
         iszPwCur = 0;
      }
      mydisp.drawImage(rgszPw[iszPwCur], 96, 190);

      /* Save this as the last update time.
      */
      msPwCur = ms;
   }
}
