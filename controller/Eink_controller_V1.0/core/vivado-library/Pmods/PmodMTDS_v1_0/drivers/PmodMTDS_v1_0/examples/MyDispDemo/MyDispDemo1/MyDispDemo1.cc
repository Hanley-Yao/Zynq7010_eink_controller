/******************************************************************************/
/*                                                                            */
/* MyDispDemo1.cc -- MyDisp Library Reference Example 1                       */
/*                                                                            */
/******************************************************************************/
/* Author: Gene Apperson                                                      */
/* Copyright 2016, Digilent Inc. All rights reserved.                         */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* Among other things, this sketch demonstrates drawing images taken from     */
/* bitmap files stored on the SD card. The bitmaps drawn are contained in the */
/* resource zip file that accompanied the download of the demo projects.      */
/* Ensure that the bitmaps are in the Images folder on the SD card before     */
/* running the sketch.                                                        */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    10/05/2016(GeneA):    Created                                           */
/*    02/14/2017(SamB):     Removed Serial references to port to Xilinx SDK   */
/*    12/09/2017(atangzwj): Validated for Vivado 2016.4                       */
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

int itstMax = 4;

int itstCur;

/* ------------------------------------------------------------ */
/*                Forward Declarations                          */
/* ------------------------------------------------------------ */

void MyDispTest1();
void MyDispTest2();
void MyDispTest3();
void MyDispTest4();

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

   itstCur = 1;

   /* The following initializes the library and the communications interface to
   ** the display board. It is quite possible that the display board hasn't
   ** completed its power on or reset initialization at this point and the
   ** begin() function will fail. Because of this it's a good idea to run the
   ** begin() function in a loop in case it fails the first time. Keep looping
   ** until it succeeds.
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
   mydisp.clearDisplay(clrBlack);

   /* Uncomment the following line and assign the test number to itstCur to
   ** cause a specific test to be repeatedly displayed.
   */
   //itstCur = 1;
   switch (itstCur) {
   case 1:
      MyDispTest1();
      break;

   case 2:
      MyDispTest2();
      break;

   case 3:
      MyDispTest3();
      break;

   case 4:
      MyDispTest4();
      break;
   }
   itstCur += 1;
   if (itstCur > itstMax) {
      itstCur = 1;
   }
   sleep(3);
}

/* ------------------------------------------------------------ */
/*                Test Functions                                */
/* ------------------------------------------------------------ */

/*** MyDispTest1()
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
**      Demonstrate the basic graphic rendering functions in the MyDisp library.
*/
void MyDispTest1() {
   int xco;
   uint32_t clr;

   /* Set up some of the basic drawing properties. These are persistent until
   ** they are changed. This way they don't have to be specified as parameters
   ** on each graphics rendering function.
   */
   mydisp.setForeground(clrWhite);
   mydisp.setBackground(clrBlack);
   mydisp.setPen(penSolid);
   mydisp.setTransparency(false);

   /* Demonstrate setPixel and getPixel
   */
   /* This will draw a red horizontal line at y=20 by setting pixels while
   ** incrementing x.
   */
   for (xco = 10; xco < 230; xco++) {
      mydisp.setPixel(xco, 20, clrRed);
   }

   /* Read back the first pixel set by the above loop. The value returned will
   ** be the color of the specified pixel, which in this case will be clrRed as
   ** set above.
   */
   clr = mydisp.getPixel(10, 20);
   xil_printf(" Pixel color = ");
   xil_printf("0x%x\n\r", clr);

   /* This will draw a horizontal line at y=30. The color is what was read back
   ** from the display using getPixel(), so it will be red as well.
   */
   for (xco = 10; xco < 230; xco++) {
      mydisp.setPixel(xco, 30, clr);
   }

   /* Demonstrate drawLine
   */
   /* The foreground color was set to clrWhite above, so the first couple of
   ** diagonal lines will be white.
   */
   mydisp.drawLine(10, 30, 230, 100);
   mydisp.drawLine(230, 30, 10, 100);

   /* Setting the foreground color to clrBlue will cause a couple of blue
   ** vertical lines to be drawn connecting the ends of the diagonal lines.
   */
   mydisp.setForeground(clrBlue);
   mydisp.drawLine(10, 30, 10, 100);
   mydisp.drawLine(230, 30, 230, 100);

   /* And now a green line will be drawn, connecting the diagonal lines at the
   ** bottom.
   */
   mydisp.setForeground(clrGreen);
   mydisp.drawLine(10, 100, 230, 100);

   /* Demonstrate drawArc. An arc is specified by the upper left corner and
   ** lower right corner of a bounding rectangle, which defines the ellipse. The
   ** arc section of the defining ellipse is specified by a pair of radial lines
   ** specifying the beginning and ending angles. In this case, the corners of
   ** the bounding rectangle are the same as the endpoints of the white diagonal
   ** lines we draw above. The beginning and ending angles are specified by the
   ** endpoints of the diagonal lines as well, so the arc will begin at one of
   ** the diagonal lines and end at the other one. The arc will be drawn with a
   ** dark yellow color.
   */
   mydisp.setPen(penSolid);
   mydisp.setForeground(clrDkYellow);
   mydisp.drawArc(10, 30, 230, 100, 10, 100, 230, 100);

   /* Demonstrate drawRectangle. We set the pen to penDash, the foreground color
   ** to dark yellow and the background color to clrRed. This will cause the
   ** perimeter of the rectangle to be drawn with a dashed line alternating
   ** between dark yellow and red. When the first rectangle is drawn, fill is
   ** suppressed, so only the outline is drawn.
   **
   ** A second rectangle is drawn inside the first one. By setting the pen to
   ** penNull, this suppresses drawing the perimeter of the rectangle. By
   ** setting the foreground color to clrDkGray and specifying to fill when the
   ** rectangle is drawn, we get a solid dark gray rectangle with no border
   ** around it.
   */
   mydisp.setPen(penDash);
   mydisp.setForeground(clrDkYellow);
   mydisp.setBackground(clrRed);
   mydisp.drawRectangle(false, 20, 120, 220, 190);
   mydisp.setPen(penNull);
   mydisp.setForeground(clrDkGray);
   mydisp.drawRectangle(true, 25, 125, 215, 185);

   /* Demonstrate drawText. This will draw a green text string with a black
   ** background in the middle of the rectangles drawn above. Background
   ** transparency was set to off, so the black background is drawn. If
   ** transparency had been set to true, this would give a green text string on
   ** the dark gray background of the rectangle.
   **
   ** Note: There is a bug in display device firmware version 1.04 that will
   ** cause the text colors to be incorrect if the pen is set to penNull. Ensure
   ** that the pen is not set to penNull before drawing text.
   */
   mydisp.setPen(penSolid);
   mydisp.setForeground(clrGreen);
   mydisp.setBackground(clrBlack);
   mydisp.drawText((char*) "This is some text", 50, 150);

   /* Demonstrate drawEllipse. This is very similar to the rectangles drawn
   ** above. A dash pen is selected with foreground color of dark red and
   ** background color of dark yellow. An ellipse is specified by giving the
   ** upper left and lower right corners of a bounding rectangle. The ellipse is
   ** drawn tangent to the rectangle.
   **
   ** In the first case, the ellipse is drawn with a dashed, dark red and dark
   ** yellow line. Filling the ellipse is suppressed, so only the perimeter is
   ** drawn.
   **
   ** The second ellipse is drawn inside the first. In this case, drawing the
   ** perimeter is suppressed by selecting penNull and fill is specified, so we
   ** get a dark gray ellipse with the perimeter not drawn.
   */
   mydisp.setPen(penDash);
   mydisp.setForeground(clrDkRed);
   mydisp.setBackground(clrDkYellow);
   mydisp.drawEllipse(false, 20, 200, 220, 300);
   mydisp.setPen(penNull);
   mydisp.setForeground(clrDkGray);
   mydisp.drawEllipse(true, 25, 205, 215, 295);
}

/* ------------------------------------------------------------ */
/*** MyDispTest2()
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
**      Demonstrate the drawImage() function.
*/
void MyDispTest2() {
   /* Draw three of the images from the onto the display..
   */
   /* This image is a 16-bit per pixel device independent bitmap.
   */
   mydisp.drawImage((char*) "Images/IMG_0100.bmp", 10, 10);

   /* This image is a 24-bit per pixel device independent bitmap.
   */
   mydisp.drawImage((char*) "Images/IMG_0101.bmp", 10, 110);

   /* This image is a 32-bit per pixel device independent bitmap.
   */
   mydisp.drawImage((char*) "Images/IMG_0102.bmp", 10, 210);
}

/* ------------------------------------------------------------ */
/*** MyDispTest3()
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
**      Another demonstration of the drawImage() function.
*/
void MyDispTest3() {
   /* This image is a full screen (240x320), 24-bit per pixel device independent
   ** bitmap.
   */
   mydisp.drawImage((char*) "Images/IMG_LOGO.bmp", 0, 0);
}

/* ------------------------------------------------------------ */
/*** MyDispTest4()
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
**      Demonstrate creating and rendering buttons. This demonstrates how to
**      create a button and how to cause it to be drawn, but does not do any of
**      the touch processing to make it a functional button. The touch
**      processing is demonstrated in sketches MyDispDemo2 and MyDispDemo3.
*/
void MyDispTest4() {
   /* Create the first button. We are using the createButton() variant that
   ** takes the names of two bitmaps as parameters. This variant draws the first
   ** bitmap when drawing the button in the up position and draws the second
   ** bitmap when drawing the button in the down position. These two bitmaps are
   ** not actually particularly good images to use for buttons, but they happen
   ** to be around because they have been used for other demos.
   **
   ** Here, we are assigning this button the hard coded value 0 as its ID. It
   ** would be better programming practice to define symbolic constants to use
   ** as the button IDs. These symbols would have meaningful names related to
   ** the function that the button performs.
   */
   char *btnUp   = (char*) "Images/IMG_0001.BMP";
   char *btnDown = (char*) "Images/IMG_0002.BMP";
   if (mydisp.createButton(0, btnUp, btnDown, 10, 10)) {
      xil_printf("mydisp.createButton(0) succeeded\n\r");
   }
   else {
      xil_printf("mydisp.createButton(0) failed\n\r");
   }

   /* Create a second button. Here, we are using the createButton() variant that
   ** takes the name of a single bitmap file. This variant draws the bitmap at
   ** full intensity when drawing the button in the up position and draws the
   ** same bitmap at reduced intensity when drawing the button in the down
   ** position. Again, this is a bitmap that just happens to be around and is
   ** not necessarily a good image to use as the graphic for a button.
   */
   char *btn = (char*) "Images/IMG_0010.BMP";
   if (mydisp.createButton(1, btn, 10, 100)) {
      xil_printf("mydisp.createButton(1) succeeded\n\r");
   }
   else {
      xil_printf("mydisp.createButton(1) failed\n\r");
   }

   /* Draw this full screen bitmap on the display so that we aren't working
   ** against a black background.
   */
   char *background = (char*) "Images/IMG_LOGO.BMP";
   mydisp.drawImage(background, 0, 0);
 
   /* Enable the buttons so that they are active. An inactive button won't be
   ** drawn by drawButton().
   */
   mydisp.enableButton(0, true);
   mydisp.enableButton(1, true);
 
   /* Draw the two buttons in the up position.
   */
   mydisp.drawButton(0, BUTTON_UP);
   mydisp.drawButton(1, BUTTON_UP);

   /* Pause so that we can see what it looks like after they have been drawn.
   */
   sleep(2);

   /* Now draw the two buttons in the down position.
   */
   mydisp.drawButton(0, BUTTON_DOWN);
   mydisp.drawButton(1, BUTTON_DOWN);

   /* And pause again so that we can see them.
   */
   sleep(2);

   /* Draw them again in the up position.
   */
   mydisp.drawButton(0, BUTTON_UP);
   mydisp.drawButton(1, BUTTON_UP);
  
   sleep(2);

   /* And finally, erase them to restore the display to the state before we
   ** started drawing them.
   */
   mydisp.drawButton(0, BUTTON_ERASE);
   mydisp.drawButton(1, BUTTON_ERASE);

   sleep(2);
  
   /* Clean up the buttons before we get out of this function. It is always
   ** necessary to free any resources that have been allocated when they are no
   ** longer needed. This function gets called over and over again. If the
   ** buttons weren't deleted before we leave, the createButton() calls would
   ** fail the next time.
   */
   mydisp.enableButton(0, false);
   mydisp.enableButton(1, false);
   mydisp.deleteButton(0);
   mydisp.deleteButton(1);
}
