/******************************************************************************/
/*                                                                            */
/* MyDispDemo2.cc -- MyDisp Library Reference Example 2                       */
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
/* This sketch demonstrates the creation of three buttons and than responding */
/* to events as the user touches the buttons. It makes use of images from the */
/* Resources directory where the example sketches were obtained. It makes use */
/* of some of the bitmaps in the Images folder, which must be on an SD card   */
/* in the SD card connector on the display board for this sketch to work.     */
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

/* ------------------------------------------------------------ */
/*                Local Variables                               */
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*                Forward Declarations                          */
/* ------------------------------------------------------------ */

void EraseImageBox();

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

   /* The images that are being used for the buttons have been drawn on a black
   ** background. By turning transparency on, the background can show through
   ** the button images when they are drawn.
   */
   mydisp.setTransparency(true);

   /* Create the buttons that we are going to use.
   ** We are using the createButton() variant that takes the names of two
   ** bitmaps as parameters. This variant draws the first bitmap when drawing
   ** the button in the up position and draws the second bitmap when drawing the
   ** button in the down position. These two bitmaps are not particularly good
   ** images to use for buttons, but they happen to be available because they
   ** have been used for other demos.
   **
   ** We are assigning these buttons hard coded values 0-2 as Their IDs. It
   ** would be better programming practice to define symbolic constants to use
   ** as the button IDs. These symbols would have meaningful names related to
   ** the function that the buttons perform.
   */
   char *btnUp   = (char*) "Images/IMG_0001.BMP";
   char *btnDown = (char*) "Images/IMG_0002.BMP";
   mydisp.createButton(0, btnUp, btnDown,  10, 270);
   mydisp.createButton(1, btnUp, btnDown, 100, 270);
   mydisp.createButton(2, btnUp, btnDown, 190, 270);

   /* This is a full screen images that is being used as a background so that the screen
   ** isn't black.
   */
   char *background = (char*) "Images/IMG_LOGO.BMP";
   mydisp.drawImage(background, 0, 0);

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
**      Arduino/MPIDE main sketch function.
*/
void loop() {
   /* This function must be called periodically to process touch messages from
   ** the display board. It maintains the current touch state and handles any
   ** processing to link touch activity to buttons. If this function isn't
   ** called often enough, touch activity tracking will become erratic.
   */
   mydisp.checkTouch();

   /* Update the appearance of the buttons. For each button, check if it is
   ** currently being touched or not and draw the appropriate image.
   ** drawButton() keeps track of the last image drawn for each button and only
   ** actually draws anything when there is a state change.
   */
   mydisp.drawButton(0, mydisp.isTouched(0) ? BUTTON_DOWN : BUTTON_UP);
   mydisp.drawButton(1, mydisp.isTouched(1) ? BUTTON_DOWN : BUTTON_UP);
   mydisp.drawButton(2, mydisp.isTouched(2) ? BUTTON_DOWN : BUTTON_UP);

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
      mydisp.drawText((char*) "Image: IMG_0010.BMP", 20, 108);
      break;

   case 1:
      /* Button 1 was pressed. Erase the image area on the display and then draw
      ** an image and a label with the image name there.
      */
      EraseImageBox();
      mydisp.drawImage((char*) "Images/IMG_0011.BMP", 30, 20);
      mydisp.setForeground(clrGreen);
      mydisp.drawText((char*) "Image: IMG_0011.BMP", 20, 108);
      break;

   case 2:
      /* Button 2 was pressed. Erase the image area on the display and then draw
      ** an image and a label with the image name there.
      */
      EraseImageBox();
      mydisp.drawImage((char*) "Images/IMG_0100.BMP", 20, 20);
      mydisp.setForeground(clrGreen);
      mydisp.drawText((char*) "Image: IMG_0100.BMP", 20, 108);
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
