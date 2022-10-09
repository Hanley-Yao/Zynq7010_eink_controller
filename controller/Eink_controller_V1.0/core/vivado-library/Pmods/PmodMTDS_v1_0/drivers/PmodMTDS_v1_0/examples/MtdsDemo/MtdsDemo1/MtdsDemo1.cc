/******************************************************************************/
/*                                                                            */
/* MtdsDemo1.cc -- MTDS Library Reference Example 1                           */
/*                                                                            */
/******************************************************************************/
/* Author: Gene Apperson                                                      */
/* Copyright 2016, Digilent Inc. All rights reserved.                         */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This program demonstrates using most of the graphical API functions in the */
/* MTDS library. It cycles through a number of different screens              */
/* demonstrating the use of the various API functions.                        */
/*                                                                            */
/* This program consists of a number of different test functions that each    */
/* illustrate one or more aspects of using the MTDS library. Each function    */
/* contains detailed comments explaining various aspects of the MTDS system   */
/* and how to use it to render various kinds of graphics.                     */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    09/28/2016(GeneA):    Adapted from an earlier test program.             */
/*    02/14/2017(SamB):     Removed Serial references to port to Xilnx SDK    */
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

/* ------------------------------------------------------------ */
/*                Global Variables                              */
/* ------------------------------------------------------------ */

RCT rctDisp;
int itstCur = 1;

/* ------------------------------------------------------------ */
/*                Local Type Definitions                        */
/* ------------------------------------------------------------ */

/* ------------------------------------------------------------ */
/*                Global Variables                              */
/* ------------------------------------------------------------ */

int itstMax = 26;

/* ------------------------------------------------------------ */
/*                Forward Declarations                          */
/* ------------------------------------------------------------ */

void MtdsTest1();
void MtdsTest2();
void MtdsTest3();
void MtdsTest4();
void MtdsTest5();
void MtdsTest6();
void MtdsTest7();
void MtdsTest8();
void MtdsTest9();
void MtdsTest10();
void MtdsTest11();
void MtdsTest12();
void MtdsTest13();
void MtdsTest14();
void MtdsTest15();
void MtdsTest16();
void MtdsTest17();
void MtdsTest18();
void MtdsTest19();
void MtdsTest20();
void MtdsTest21();
void MtdsTest22();
void MtdsTest23();
void MtdsTest24();
void MtdsTest25();
void MtdsTest26();

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

   rctDisp.xcoLeft   = 0;
   rctDisp.ycoTop    = 0;
   rctDisp.xcoRight  = 239;
   rctDisp.ycoBottom = 319;

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
   mtds.ClearDisplay(clrBlack);

   /* Uncomment the following line and assign the test number to itstCur to
   ** cause a specific test to be repeatedly displayed.
   */
   //itstCur = 1;
   switch (itstCur) {
   case 1:
      MtdsTest1();
      break;

   case 2:
      MtdsTest2();
      break;

   case 3:
      MtdsTest3();
      break;

   case 4:
      MtdsTest4();
      break;

   case 5:
      MtdsTest5();
      break;

   case 6:
      MtdsTest6();
      break;

   case 7:
      MtdsTest7();
      break;

   case 8:
      MtdsTest8();
      break;

   case 9:
      MtdsTest9();
      break;

   case 10:
      MtdsTest10();
      break;

   case 11:
      MtdsTest11();
      break;

   case 12:
      MtdsTest12();
      break;

   case 13:
      MtdsTest13();
      break;

   case 14:
      MtdsTest14();
      break;

   case 15:
      MtdsTest15();
      break;

   case 16:
      MtdsTest16();
      break;

   case 17:
      MtdsTest17();
      break;

   case 18:
      MtdsTest18();
      break;

   case 19:
      MtdsTest19();
      break;

   case 20:
      MtdsTest20();
      break;

   case 21:
      MtdsTest21();
      break;

   case 22:
      MtdsTest22();
      break;

   case 23:
      MtdsTest23();
      break;

   case 24:
      MtdsTest24();
      break;

   case 25:
      MtdsTest25();
      break;

   case 26:
      MtdsTest26();
      break;
   }
   itstCur += 1;
   if (itstCur > itstMax) {
      itstCur = 1;
   }
   sleep(3);
}

/* ------------------------------------------------------------ */
/*            Graphics Demo Functions                           */
/* ------------------------------------------------------------ */

/*** MtdsTest1()
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
**      This demonstrates the use of the basic graphics functions used to set up
**      properties in the DS as well as some of the rendering functions, such as
**      SetPixel(), MoveTo(), LineTo() and PolyLine().
*/
void MtdsTest1() {
   HDS   hds;
   HBMP  hbmp;
   PNT   rgpnt[21] = {
      {  30,  30 },
      { 210,  30 },
      { 210, 310 },
      {  30, 310 },
      {  30,  50 },
      { 190,  50 },
      { 190, 290 },
      {  50, 290 },
      {  50,  70 },
      { 170,  70 },
      { 170, 270 },
      {  70, 270 },
      {  70,  90 },
      { 150,  90 },
      { 150, 250 },
      {  90, 250 },
      {  90, 110 },
      { 130, 110 },
      { 130, 230 },
      { 110, 230 },
      { 110, 130 }
   };
   RCT rct;
   PNT pntS;
   PNT pntT;
   uint32_t clr;
   uint32_t clrS;
   uint32_t clrT;

   hds = mtds.GetDisplayDs();

   /* The following functions demonstrate and test the various functions to set
   ** and get properties in the DS. The DS (drawing state object) holds all of
   ** the basic properties that control rendering of graphical elements.
   */
   mtds.SetFgColor(hds, clrWhite);
   clrS = mtds.GetFgColor(hds);
   clrT = mtds.GetNearestColor(clrWhite);
   if (clrS != clrT) {
      xil_printf("Set/Get FG Color error: set = ");
      xil_printf("0x%x", clrWhite);
      xil_printf(" get = ");
      xil_printf("0x%x", clrS);
      xil_printf("\n\r");
   }

   mtds.SetBgColor(hds, clrWhite);
   clrS = mtds.GetBgColor(hds);
   clrT = mtds.GetNearestColor(clrWhite);
   if (clrS != clrT) {
      xil_printf("Set/Get BG Color error: set = ");
      xil_printf("0x%x", clrWhite);
      xil_printf(" get = ");
      xil_printf("0x%x", clrS);
      xil_printf("\n\r");
   }

   mtds.SetTransColor(hds, clrWhite);
   clrS = mtds.GetTransColor(hds);
   clrT = mtds.GetNearestColor(clrWhite);
   if (clrS != clrT) {
      xil_printf("Set/Get Trans Color error\n\r");
   }

   mtds.SetIntensity(hds, 20);
   if (mtds.GetIntensity(hds) != 20) {
      xil_printf("Set/Get Intensity error\n\r");
   }

   mtds.SetPen(hds, 0x8CC8);
   if (mtds.GetPen(hds) != 0x8CC8) {
      xil_printf("Set/Get Pen error\n\r");
   }

   mtds.SetBkMode(hds, bkTransparent);
   if (mtds.GetBkMode(hds) != bkTransparent) {
      xil_printf("Set/Get Bk Mode error\n\r");
   }

   mtds.SetDrwRop(hds, drwNotXorPen);
   if (mtds.GetDrwRop(hds) != drwNotXorPen) {
      xil_printf("Set/Get Drw Rop error\n\r");
   }

   mtds.SetPixel(hds, 100, 100, clrRed);
   clr = mtds.GetPixel(hds, 100, 100);
   if (clr != mtds.GetNearestColor(clrRed)) {
      xil_printf("Set/Get Pixel error\n\r");
   }

   mtds.SetFont(hds, hfntMedium);
   if (mtds.GetFont(hds) != hfntMedium) {
      xil_printf("Set/Get Font error\n\r");
   }

   mtds.SetBrush(hds, hbrWhite);
   if (mtds.GetBrush(hds) != hbrWhite) {
      xil_printf("Set/Get Brush error\n\r");
   }

   hbmp = mtds.GetDisplayBitmap();
   mtds.SetDrawingSurface(hds, hbmp);
   if (mtds.GetDrawingSurface(hds) != hbmp) {
      xil_printf("Set/Get Drawing Surface error\n\r");
   }

   pntS.xco = 27;
   pntS.yco = 43;
   mtds.MoveTo(hds, pntS.xco, pntS.yco);
   mtds.GetCurPos(hds, &pntT);
   if ((pntS.xco != pntT.xco) || (pntS.yco != pntT.yco)) {
      xil_printf("MoveTo/GetCurPos error\n\r");
   }

   mtds.ReleaseDs(hds);

   /* By releasing and reacquiring the handle to the display DS, we reset all of
   ** the DS properties, so the changes that were made earlier no longer apply.
   ** Now we are getting the display DS and setting it up for some actual
   ** drawing.
   */
   hds = mtds.GetDisplayDs();

   /* The DS maintains a "current position." The current position is set by
   ** calling MoveTo(). Many graphics functions use the current position as the
   ** starting point. Some graphics functions update the current position to the
   ** ending point that was drawn. Other graphics functions leave the current
   ** position unchanged. The ones whose name ends in "To" update the current
   ** position, while functions whose name does not end in "To" leave the
   ** current position unchanged.
   **
   ** For example:
   **    LineTo(): Draws a line from the current position to the specified
   **              endpoint and updates the current position to the endpoint.
   **    Line():   Draws a line starting at the current position to the
   **              specified endpoint and leaves the current position unchanged.
   **
   ** This convention only applies to functions that use the current position as
   ** the starting point for drawing.
   */

   /* Set up to draw white lines on a black background using a dot pattern pen.
   ** This is done by selecting white as the foreground color and black as the
   ** background color. The pen is set to penDot, which is one of the
   ** predefined pen patterns. It produces a dotted line. The background
   ** transparency mode defaults to opaque, so the background color gets drawn
   ** when we draw the dotted lines. The drwCopyPen drawing mode causes the pen
   ** to overwrite whatever is in the pixels being drawn on.
   */
   mtds.SetFgColor(hds, clrWhite);
   mtds.SetBgColor(hds, clrBlack);
   mtds.SetPen(hds, penDot);
   mtds.SetDrwRop(hds, drwCopyPen);

   /* Draw two diagonal lines that cross the entire display.
   */
   mtds.MoveTo(hds, 0, 0);
   mtds.LineTo(hds, 240, 320);
   mtds.MoveTo(hds, 239, 0);
   mtds.LineTo(hds, 0, 320);

   /* The following will draw two red lines. The foreground color is set to red,
   ** and the pen is set to penSolid, so we get solid red lines with no dot
   ** pattern. The background color remains black as was set above. The LineTo()
   ** function is used to draw the lines, so the current position is updated to
   ** the endpoint of the first one when it is drawn. This then becomes the
   ** starting point of the second line.
   */
   mtds.SetFgColor(hds, clrRed);
   mtds.SetPen(hds, penSolid);
   mtds.MoveTo(hds, 20, 60);
   mtds.LineTo(hds, 120, 20);
   mtds.LineTo(hds, 220, 60);

   /* This will draw two blue lines beginning at (120, 30). Because the Line()
   ** function is being used, the current position in the DS doesn't change when
   ** drawing the lines. Each line drawn starts at the same point.
   */
   mtds.SetFgColor(hds, clrBlue);
   mtds.MoveTo(hds, 120, 30);
   mtds.Line(hds, 20, 70);
   mtds.Line(hds, 220, 70);

   /* We can read back the current drawing position, and see that it is
   ** unchanged from what was set by MoveTo().
   */
   mtds.GetCurPos(hds, &pntT);
   if ((pntT.xco != 120) || (pntT.yco != 30)) {
      xil_printf("MoveTo/Line error\n\r");
   }

   /* Now set up to draw green lines. Since the background color isn't being
   ** changed, it stays as what was set above, which is black. In this case a
   ** solid pen is selected, so it draws a solid line without any dot/dash
   ** pattern. The FrameRect() function draws the outline of the specified
   ** rectangle. This results in a green rectangle that spans most of the
   ** display.
   */
   mtds.SetFgColor(hds, clrGreen);
   mtds.SetPen(hds, penSolid);
   rct.xcoLeft = 20;
   rct.ycoTop = 20;
   rct.xcoRight = 220;
   rct.ycoBottom = 300;
   mtds.FrameRect(hds, &rct);

   /* Now, we are going to demonstrate a couple of other shapes. When filled
   ** shapes, such as Rectangle() or Ellipse() are drawn, the perimeter is drawn
   ** using the current pen, foreground color, background color, etc. The
   ** interior is filled using the current brush. To draw the perimeter without
   ** filling the interior, select a null brush (i.e. hbrNull). To fill the
   ** interior without drawing the perimeter, select a null pen (i.e. penNull).
   ** In this case, we draw the perimeter of the rectangle with a dash pattern
   ** pen in light gray, suppressing filling the interior, and draw an ellipse
   ** using a dot pattern pen in medium gray, again suppressing filling the
   ** interior.
   */
   mtds.SetBrush(hds, hbrNull);
   mtds.SetPen(hds, penDash);
   mtds.SetFgColor(hds, clrLtGray);
   mtds.Rectangle(hds, 25, 25, 215, 295);
   mtds.SetPen(hds, penDot);
   mtds.SetFgColor(hds, clrMedGray);
   mtds.Ellipse(hds, 35, 35, 205, 285);

   /* Now, we select a solid pen with the foreground color red. This will draw
   ** red pixels. Since the drawing mode hasn't been changed from drwCopyPen set
   ** above, this will still cause the pen pixels to overwrite whatever is being
   ** drawn on. In this case, we are demonstrating the Polyline() function. This
   ** function draws a series of line segments connecting the points in the
   ** array of PNT structures. The array of points was initialized at the
   ** beginning of this function. In this case, we are using the first point in
   ** the array as the starting point (we set the current position to there
   ** using MoveTo()) and then use Polyline() to draw lines connecting the rest
   ** of the points in the array.
   */
   mtds.SetFgColor(hds, clrRed);
   mtds.SetPen(hds, penSolid);
   mtds.MoveTo(hds, &rgpnt[0]);
   mtds.PolyLineTo(hds, 20, &rgpnt[1]);

   /* This demonstrates using another drawing mode besides drwCopyPen. In this
   ** case, it demonstrates the drwOrPen drawing mode. This mode causes the pen
   ** pixels to be bitwise OR'd with the existing pixels being drawn on.
   **
   ** Set the color to dark red and drawing mode to drwCopy pen, then draw a
   ** line. Then, set the color to blue, the drawing mode to drwOrPen and then
   ** draw another line over the top of the previous one. This causes the blue
   ** pixels in the second line to be OR'd with the dark red pixels drawn for
   ** the first line. The resulting color will be the result of OR'ing the bits
   ** of dark red with blue, giving a medium magenta color.
   */
   mtds.SetFgColor(hds, clrDkRed);
   mtds.SetPen(hds, penSolid);
   mtds.SetDrwRop(hds, drwCopyPen);
   mtds.MoveTo(hds, 20, 280);
   mtds.LineTo(hds, 220, 280);
   mtds.SetFgColor(hds, clrBlue);
   mtds.SetDrwRop(hds, drwOrPen);
   mtds.MoveTo(hds, 20, 280);
   mtds.LineTo(hds, 220, 280);

   /* The DS handle must be released once it is no longer being used. Since it
   ** was acquired inside this function, it must be released before the function
   ** exits or it is lost until the system is reset.
   */
   mtds.ReleaseDs(hds);
}

/* ------------------------------------------------------------ */
/*** MtdsTest2()
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
**      This function demonstrates drawing lines that extend off of the display
**      and are thus clipped.
**
**      The coordinate system extends +/-32K in X and +/-32K in Y. Graphical
**      elements can be rendered at any virtual coordinate but any portion of
**      the element that isn't on the display is clipped.
*/
void MtdsTest2() {
   HDS hds;
   int16_t xcoT;
   int16_t ycoT;

   /* We're going to be drawing on the display, so get the handle to the display
   ** DS. Then set the pen to solid as we want to draw solid lines. Actually,
   ** setting the pen to solid here is redundant as penSolid is the default when
   ** the DS is obtained.
   */
   hds = mtds.GetDisplayDs();
   mtds.SetPen(hds, penSolid);

   /* Set the foreground color to red so that we draw red lines.
   **
   ** The first iteration of the loop below draws a line from (120,-200) to
   ** (10,340). This is from a point well above the center of the top of the
   ** screen to a point below the lower edge. It also draws a line from
   ** (120,520) to (10,-20). Again, this is from a point well below the center
   ** to the screen to above the upper edge. These lines get clipped at both
   ** ends and only the part visible on the display is actually rendered. This
   ** demonstrates clipping in Y.
   */
   mtds.SetFgColor(hds, clrRed);
   for (xcoT = 10; xcoT < 240; xcoT += 10) {
      mtds.MoveTo(hds, 120, -200);
      mtds.LineTo(hds, xcoT, 340);
      mtds.MoveTo(hds, 120, 520);
      mtds.LineTo(hds, xcoT, -20);
   }

   /* Draw some green lines that demonstrate clipping in X.
   */
   mtds.SetFgColor(hds, clrDkGreen);
   for (xcoT = 10; xcoT < 240; xcoT += 20) {
      mtds.MoveTo(hds, -30, 160);
      mtds.LineTo(hds, xcoT, 330);
      mtds.MoveTo(hds, -30, 160);
      mtds.LineTo(hds, xcoT, -10);
      mtds.MoveTo(hds, 270, 160);
      mtds.LineTo(hds, xcoT, 330);
      mtds.MoveTo(hds, 270, 160);
      mtds.LineTo(hds, xcoT, -10);
   }

   /* Draw some dark cyan lines that demonstrate more clipping.
   */
   mtds.SetFgColor(hds, clrDkCyan);
   for (ycoT = 10; ycoT < 320; ycoT += 10) {
      mtds.MoveTo(hds, -200, 160);
      mtds.LineTo(hds, 260, ycoT);
      mtds.MoveTo(hds, 440, 160);
      mtds.LineTo(hds, -20, ycoT);
   }

   /* Always release the DS when it is no longer used. Since it was acquired
   ** inside this function, it must be released before the functions exits.
   */
   mtds.ReleaseDs(hds);
}

/* ------------------------------------------------------------ */
/*** MtdsTest3()
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
**      This demonstrates drawing filled shapes using a brush.
*/
void MtdsTest3() {
   HDS hdsDisp;
   HBR hbrDiagCross;
   int xcoL;
   int ycoT;
   int xcoR;
   int ycoB;

   /* Set up the coordinates of the upper left and lower right corners of a
   ** rectangle.
   */
   xcoL = 10;
   ycoT = 20;
   xcoR = 230;
   ycoB = 120;

   /* Get the display DS so that we can draw on it.
   ** Create a pattern brush that will be used for fill. In this case, we're
   ** creating a pattern brush with a diagonal crosshatch pattern with
   ** foreground color of red and background color of black.
   */
   hdsDisp = mtds.GetDisplayDs();
   hbrDiagCross = mtds.CreatePatternBrush(idpsDiagCross, clrRed, clrBlack);

   mtds.SetBgColor(hdsDisp, clrBlack);
   mtds.SetDrwRop(hdsDisp, drwCopyPen);

   /* Select foreground color white, solid pen and null brush. The Rectangle()
   ** function will draw the perimeter of the rectangle with solid white lines
   ** and not fill the interior.
   */
   mtds.SetFgColor(hdsDisp, clrWhite);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetBrush(hdsDisp, hbrNull);
   mtds.Rectangle(hdsDisp, xcoL, ycoT, xcoR, ycoB);

   /* Now, we select foreground color green and select the brush created above.
   ** The Ellipse() function is given the same rectangle, so it will draw the
   ** ellipse tangent to the rectangle drawn above. It will have the perimeter
   ** drawn in green and the interior filled with the red and black brush
   ** created above.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetBrush(hdsDisp, hbrDiagCross);
   mtds.Ellipse(hdsDisp, xcoL, ycoT, xcoR, ycoB);

   /* Set up the coordinates of a different rectangle.
   */
   xcoL = 70;
   ycoT = 140;
   xcoR = 170;
   ycoB = 300;

   /* Now, we are going to do essentially the same thing as above, but with a
   ** different rectangle.
   */
   mtds.SetFgColor(hdsDisp, clrWhite);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetBrush(hdsDisp, hbrNull);
   mtds.Rectangle(hdsDisp, xcoL, ycoT, xcoR, ycoB);

   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetBrush(hdsDisp, hbrDiagCross);
   mtds.Ellipse(hdsDisp, xcoL, ycoT, xcoR, ycoB);

   /* We always have to release or destroy any resources that we no longer need,
   ** so that the memory isn't lost. In this case since the brush was created
   ** inside this function and we aren't saving the handle anywhere, it must be
   ** destroyed before the function exits. Again, since we acquired the display
   ** DS in this function we must release it before we return.
   */
   mtds.DestroyBrush(hbrDiagCross);
   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest4()
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
**      Demonstrates drawing some concentric ellipses. This draws two sets of
**      concentric ellipses without filling the interiors. The first set of
**      ellipses aren't strictly concentric, but each one drawn contains the
**      previous ones drawn. Since the bounding rectangles that specify the
**      second set of ellipses are actually squares, the ellipses are actually
**      circles.
*/
void MtdsTest4() {
   HDS hdsDisp;
   int i;
   int16_t xcoL;
   int16_t ycoT;
   int16_t xcoR;
   int16_t ycoB;

   /* Get the display DS and select a null brush to suppress filling the
   ** ellipses.
   */
   hdsDisp = mtds.GetDisplayDs();
   mtds.SetBgColor(hdsDisp, clrBlack);
   mtds.SetDrwRop(hdsDisp, drwCopyPen);
   mtds.SetBrush(hdsDisp, hbrNull);

   /* Draw red ellipses with solid perimeter.
   */
   mtds.SetFgColor(hdsDisp, clrRed);
   mtds.SetPen(hdsDisp, penSolid);

   /* Set up the initial bounding rectangle for the first set of ellipses.
   */
   xcoL = 30;
   ycoT = 70;
   xcoR = 20;
   ycoB = 70;

   for (i = 0; i < 10; i++) {
      /* Move the sides of the rectangle out a bit and then draw the ellipse.
      */
      xcoL -= 2;
      xcoR += 20;
      ycoT -= 5;
      ycoB += 5;
      mtds.Ellipse(hdsDisp, xcoL, ycoT, xcoR, ycoB);
   }

   /* Draw green ellipses with a dotted perimeter.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.SetPen(hdsDisp, penDot);

   /* Set up the initial bounding rectangle for the second set of ellipses.
   */
   xcoL = 119;
   ycoT = 219;
   xcoR = 121;
   ycoB = 221;

   for (i = 0; i < 15; i++) {
      /* Move the sides of the rectangle out a bit and then draw the ellipse.
      */
      xcoL -= 5;
      xcoR += 5;
      ycoT -= 5;
      ycoB += 5;
      mtds.Ellipse(hdsDisp, xcoL, ycoT, xcoR, ycoB);
   }

   /* Release the DS before we leave.
   */
   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest5
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
**      This demonstration tiles the display with two interleaved sets of
**      concentric circles.
*/
void MtdsTest5() {
   HDS hdsDisp;
   int16_t xco;
   int16_t yco;

   /* Get the display DS and initialize the parameters we care about. Note that
   ** the only one we actually need to set is the brush, as we are setting the
   ** others to the default values. Setting the brush to null suppresses filling
   ** the circles.
   */
   hdsDisp = mtds.GetDisplayDs();
   mtds.SetBgColor(hdsDisp, clrBlack);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetDrwRop(hdsDisp, drwCopyPen);
   mtds.SetBrush(hdsDisp, hbrNull);

   /* Iterate over the surface of the display, tiling it with sets of blue
   ** circles.
   */
   mtds.SetFgColor(hdsDisp, clrBlue);
   for (yco = 25; yco <= 255; yco += 45) {
      for (xco = 30; xco <= 170; xco += 45) {
         /* Draw four concentric circles centered at the current position.
         */
         mtds.Ellipse(hdsDisp, xco, yco, xco + 39, yco + 39);
         mtds.Ellipse(hdsDisp, xco + 5, yco + 5, xco + 34, yco + 34);
         mtds.Ellipse(hdsDisp, xco + 10, yco + 10, xco + 29, yco + 29);
         mtds.Ellipse(hdsDisp, xco + 15, yco + 15, xco + 24, yco + 24);
      }
   }

   /* Iterate over the surface of the display, tiling it with sets of red
   ** circles that are interleaved between the blue ones drawn above.
   */
   mtds.SetFgColor(hdsDisp, clrRed);
   for (yco = 5; yco <= 275; yco += 45) {
      for (xco = 10; xco <= 190; xco += 45) {
         /* Draw four concentric circles centered at the current position.
         */
         mtds.Ellipse(hdsDisp, xco, yco, xco + 39, yco + 39);
         mtds.Ellipse(hdsDisp, xco + 5, yco + 5, xco + 34, yco + 34);
         mtds.Ellipse(hdsDisp, xco + 10, yco + 10, xco + 29, yco + 29);
         mtds.Ellipse(hdsDisp, xco + 15, yco + 15, xco + 24, yco + 24);
      }
   }

   /* Release the display DS before we leave.
   */
   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest6
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
**      This demonstrates drawing both filled and non-filled rectangles and
**      rounded rectangles. The RoundRect() function draws a rectangle with
**      rounded corners.
*/
void MtdsTest6() {
   HDS hdsDisp;
   HBR hbrChecker;

   /* Get the display DS so that we can use it to draw on the display.
   ** Create a pattern brush with a checkerboard pattern with foreground color
   ** red and background color black.
   */
   hdsDisp = mtds.GetDisplayDs();
   hbrChecker = mtds.CreatePatternBrush(idpsChecker, clrRed, clrBlack);

   mtds.SetBgColor(hdsDisp, clrBlack);
   mtds.SetDrwRop(hdsDisp, drwCopyPen);

   /* Draw a rectangle with solid green pen and no fill.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetBrush(hdsDisp, hbrNull);
   mtds.Rectangle(hdsDisp, 10, 10, 110, 80);

   /* Draw the same size rectangle to the right of it, but this time filled with
   ** the brush that we created above.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.Rectangle(hdsDisp, 120, 10, 220, 80);

   /* Draw a rounded rectangle with solid green brush and no fill. In this case,
   ** the corners are rounded with circular arcs of radius 30.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetBrush(hdsDisp, hbrNull);
   mtds.RoundRect(hdsDisp, 10, 140, 110, 300, 30, 30);

   /* Draw the same size rounded rectangle to the right of it, but filled with
   ** the above brush.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.RoundRect(hdsDisp, 120, 140, 220, 300, 30, 30);

   /* Destroy the brush and release the DS before we leave so that the resources
   ** aren't lost.
   */
   mtds.DestroyBrush(hbrChecker);
   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest7
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
**      This demonstrates the use of the Arc() function for drawing an
**      elliptical arc. In this case, though, rather than drawing directly on
**      the display bitmap, it creates a window and does all of the rendering
**      inside of the window.
*/
void MtdsTest7() {
   HDS     hdsDisp;
   HWIN    hwin;
   int16_t xcoLeft;
   int16_t ycoTop;
   int16_t xcoRight;
   int16_t ycoBottom;
   int16_t xcoStart;
   int16_t ycoStart;
   int16_t xcoEnd;
   int16_t ycoEnd;
   int16_t xcoC;
   int16_t ycoC;
   RCT     rct;

   /* The following code clears the display to white by initializing an RCT
   ** structure with the coordinates of the boundary of the display and then
   ** using FillRect to fill the resulting rectangle with white. This could be
   ** done more easily with ClearDisplay(), however, this demonstrates a
   ** technique that could be used to clear portions of the display.
   */
   hdsDisp = mtds.GetDisplayDs();

   rct.xcoLeft   = 0;
   rct.ycoTop    = 0;
   rct.xcoRight  = 239;
   rct.ycoBottom = 319;
   mtds.FillRect(hdsDisp, &rct, hbrWhite);

   mtds.ReleaseDs(hdsDisp);

   /* Create the window that we are going to use to contain the graphics
   ** rendered by this demonstration.
   */
   hwin = mtws.CreateWindow(hwinDesktop, wclsUser, wstlVisible | wstlThinBorder,
         5, 5, 230, 200);
   mtws.GetClientRect(hwin, &rct);

   /* Get a DS handle that can be used to draw on the client area of the window
   ** and then fill the client area with dark gray.
   */
   hdsDisp = mtws.BeginUpdate(hwin);
   mtws.DrawBorder(hwin);
   mtds.FillRect(hdsDisp, &rct, hbrDkGray);

   /* Set up the drawing parameters that we are going to use.
   */
   mtds.SetFgColor(hdsDisp, clrRed);
   mtds.SetBgColor(hdsDisp, clrBlack);
   mtds.SetDrwRop(hdsDisp, drwCopyPen);
   mtds.SetPen(hdsDisp, penSolid);
   mtds.SetBrush(hdsDisp, hbrNull);

   /* Set up the bounding rectangle that will be used to define the ellipse for
   ** the elliptical arc section.
   */
   xcoLeft = 10;
   ycoTop = 10;
   xcoRight = 210;
   ycoBottom = 110;

   /* Compute the center of the ellipse.
   */
   xcoC = (xcoRight + xcoLeft) / 2;
   ycoC = (ycoBottom + ycoTop) / 2;

   /* Following section has code to initialize variables with the endpoints of
   ** the radial lines that define the starting angle and the ending angle of
   ** the arc. This code merely has a number of different initializations that
   ** can be turned on or off using conditional compilation. All but one of them
   ** do not get compiled because they are dependent on defined(DEAD) (DEAD
   ** should not be defined). By having one of these be dependent on
   ** !defined(DEAD), it is easy to switch in one set or another without having
   ** to retype a lot of values. This makes it easy to see how changing the
   ** endpoints of the radial lines changes the arc that gets drawn.
   */
#if defined(DEAD)
   xcoStart = 25;
   ycoStart = -50;
   xcoEnd = 50;
   ycoEnd = -25;
#endif
#if defined(DEAD)
   xcoStart = 50;
   ycoStart = -25;
   xcoEnd = 50;
   ycoEnd = 25;
#endif
#if defined(DEAD)
   xcoStart = 50;
   ycoStart = 25;
   xcoEnd = 25;
   ycoEnd = 50;
#endif
#if !defined(DEAD) // NOTE: this one actually gets compiled
   xcoStart = 25;
   ycoStart = 50;
   xcoEnd = -25;
   ycoEnd = 50;
#endif
#if defined(DEAD)
   xcoStart = -25;
   ycoStart = 50;
   xcoEnd = -50;
   ycoEnd = 25;
#endif
#if defined(DEAD)
   xcoStart = -50;
   ycoStart = 25;
   xcoEnd = -50;
   ycoEnd = -25;
#endif
#if defined(DEAD)
   xcoStart = -50;
   ycoStart = -25;
   xcoEnd = -25;
   ycoEnd = -50;
#endif
#if defined(DEAD)
   xcoStart = -25;
   ycoStart = -50;
   xcoEnd = 25;
   ycoEnd = -50;
#endif
#if defined(DEAD)
   xcoStart = 25;
   ycoStart = -50;
   xcoEnd = -25;
   ycoEnd = -50;
#endif
#if defined(DEAD)
   xcoStart = 0;
   ycoStart = -50;
   xcoEnd = 0;
   ycoEnd = 50;
#endif

   /* This section draws an ellipse with the same bounding rectangle as the
   ** ellipse that will define the arc. It also draws the lines that are used to
   ** define the starting and ending angles for the arc.
   */
   mtds.SetFgColor(hdsDisp, clrWhite);
   mtds.Ellipse(hdsDisp, xcoLeft, ycoTop, xcoRight, ycoBottom);
   mtds.MoveTo(hdsDisp, xcoC, ycoC);
   mtds.LineTo(hdsDisp, xcoC + xcoStart, ycoC + ycoStart);
   mtds.MoveTo(hdsDisp, xcoC, ycoC);
   mtds.LineTo(hdsDisp, xcoC + xcoEnd, ycoC + ycoEnd);

   /* This now draws the actual arc in green over the white ellipse drawn above.
   ** This shows how the ellipse and the radial lines define the arc that gets
   ** drawn.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.Arc(hdsDisp, xcoLeft, ycoTop, xcoRight, ycoBottom, xcoC + xcoStart,
         ycoC + ycoStart, xcoC + xcoEnd, ycoC + ycoEnd);

   /* Release the DS used for window update (this was obtained by calling
   ** BeginUpdate()) and then destroy the window before we exit so that the
   ** resources aren't lost.
   */
   mtws.EndUpdate(hwin);
   mtws.DestroyWindow(hwin);
}

/* ------------------------------------------------------------ */
/*** MtdsTest8
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
**      Demonstrate the use of BitBlt(). This draws a pattern in the center of
**      the display and then uses BitBlt() to copy that pattern to eight other
**      locations on the display. This illustrates the use of BitBlt() with the
**      source and destination bitmaps being the display.
*/
void MtdsTest8() {
   HDS hds;

   /* Get the DS for drawing on the display.
   */
   hds = mtds.GetDisplayDs();

   /* Draw a pattern in the center of the display. This is made up of two green
   ** diagonal lines with a red square around them.
   */
   mtds.SetDrwRop(hds, drwCopyPen);
   mtds.SetPen(hds, penSolid);

   mtds.SetFgColor(hds, clrGreen);
   mtds.MoveTo(hds, 100, 140);
   mtds.LineTo(hds, 139, 179);
   mtds.MoveTo(hds, 139, 140);
   mtds.LineTo(hds, 100, 179);

   mtds.SetFgColor(hds, clrRed);
   mtds.MoveTo(hds, 100, 140);
   mtds.LineTo(hds, 139, 140);
   mtds.LineTo(hds, 139, 179);
   mtds.LineTo(hds, 100, 179);
   mtds.LineTo(hds, 100, 140);

   /* Now use BitBlt to copy that pattern to other locations on the display.
   ** Note that the source location is the same each time, but that the
   ** destination locations are different.
   */
   mtds.BitBlt(hds,  10,  10, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds, 100,  10, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds, 190,  10, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds,  10, 140, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds, 190, 140, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds,  10, 270, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds, 100, 270, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds, 190, 270, 40, 40, hds, 100, 140, ropSrcCopy);

   /* Release the DS before we leave so that it doesn't get lost.
   */
   mtds.ReleaseDs(hds);
}

/* ------------------------------------------------------------ */
/*** MtdsTest9
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
**      Demonstrate the use of BitBlt() to copy a rectangle of pixels from one
**      place on the display to another. In this case it also illustrates the
**      clipping that occurs when part of the destination rectangle is off of
**      the display. This is essentially the same as MtdsTest8() above, except
**      that the destination locations are partially off the display.
*/
void MtdsTest9() {
   HDS hds;

   hds = mtds.GetDisplayDs();

   /* Draw a pattern in the center of the display. This is made up of two green
   ** diagonal lines with a red square around them.
   */
   mtds.SetDrwRop(hds, drwCopyPen);
   mtds.SetPen(hds, penSolid);

   mtds.SetFgColor(hds, clrGreen);
   mtds.MoveTo(hds, 100, 140);
   mtds.LineTo(hds, 139, 179);
   mtds.MoveTo(hds, 139, 140);
   mtds.LineTo(hds, 100, 179);

   mtds.SetFgColor(hds, clrRed);
   mtds.MoveTo(hds, 100, 140);
   mtds.LineTo(hds, 139, 140);
   mtds.LineTo(hds, 139, 179);
   mtds.LineTo(hds, 100, 179);
   mtds.LineTo(hds, 100, 140);

   /* Now use BitBlt to copy that pattern to other locations on the display.
   ** Note that the destination locations are all near the border of the display
   ** causing the copies of the pattern to be clipped.
   */
   mtds.BitBlt(hds,  -20,  -20, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds,  100,  -20, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds,  220,  -20, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds,  -20,  140, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds,  220,  140, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds,  -20,  300, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds,  100,  300, 40, 40, hds, 100, 140, ropSrcCopy);
   mtds.BitBlt(hds,  220,  300, 40, 40, hds, 100, 140, ropSrcCopy);

   mtds.ReleaseDs(hds);
}

/* ------------------------------------------------------------ */
/*** MtdsTest10
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
**      This demonstrates the use of an off-screen or memory bitmap. In the MTDS
**      system any bitmap can be drawn on equivalently. This illustrates
**      creation of an off-screen bitmap, selecting it as the drawing surface in
**      a DS, drawing onto the off-screen bitmap, and then using BitBlt() to
**      copy the off-screen bitmap onto the display.
*/
void MtdsTest10() {
   HDS hdsDisp;
   HDS hdsTest;
   HBMP hbmpTest;
   int16_t xco;
   int16_t yco;

   /* In this case, we are going to need two DS objects, one for drawing onto
   ** the display and one for drawing onto the off-screen bitmap. GetDisplayDs()
   ** returns a handle to a DS initialized for drawing on the display. GetDs()
   ** returns a DS that is not associated with any bitmap as the drawing
   ** surface.
   */
   hdsDisp = mtds.GetDisplayDs();
   hdsTest = mtds.GetDs();

   /* Create an off-screen bitmap in memory on the display board. In this case,
   ** we are creating a 40x40 pixel, color bitmap. This bitmap is then selected
   ** as the drawing surface for the DS whose handle is in hdsTest. Setting the
   ** bitmap as the drawing surface in the DS makes that the bitmap that is
   ** drawn on when any drawing operations occur using the DS.
   */
   hbmpTest = mtds.CreateBitmap(40, 40, 16);
   if (hbmpTest == 0) {
      xil_printf("MtdsTest10: CreateBitmap failed\n\r");
   }
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Now that we have a DS with a drawing surface, initialize the other drawing
   ** parameters that we are going to use and then draw some graphics onto the
   ** off-screen bitmap.
   */
   mtds.SetDrwRop(hdsTest, drwCopyPen);
   mtds.SetPen(hdsTest, penSolid);

   /* This draws a dark gray circle and a filled dark gray circle inside it.
   */
   mtds.SetFgColor(hdsTest, clrMedGray);
   mtds.SetBrush(hdsTest, hbrNull);
   mtds.Ellipse(hdsTest, 1, 1, 38, 38);
   mtds.SetBrush(hdsTest, hbrDkGray);
   mtds.Ellipse(hdsTest, 6, 6, 33, 33);

   /* This draws two green diagonal lines from corner to corner of the bitmap.
   */
   mtds.SetFgColor(hdsTest, clrGreen);
   mtds.MoveTo(hdsTest, 0, 0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.MoveTo(hdsTest, 39, 0);
   mtds.LineTo(hdsTest, 0, 39);

   /* This draws a red square around the perimeter of the off-screen bitmap.
   */
   mtds.SetFgColor(hdsTest, clrRed);
   mtds.MoveTo(hdsTest, 0, 0);
   mtds.LineTo(hdsTest, 39, 0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.LineTo(hdsTest, 0, 39);
   mtds.LineTo(hdsTest, 0, 0);

   /* Now that we have drawn some graphics onto the off-screen bitmap, use
   ** BitBlt() to copy it onto the display, tiling the surface of the display
   ** with it.
   */
   for (yco = 5; yco <= 275; yco += 45) {
      for (xco = 10; xco <= 190; xco += 45) {
         mtds.BitBlt(hdsDisp, xco, yco, 40, 40, hdsTest, 0, 0, ropSrcCopy);
      }
   }

   /* We are finished with this demo, so we need to destroy and release all of
   ** the resources used so that the memory isn't lost.
   */
   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);
}

/* ------------------------------------------------------------ */
/*** MtdsTest11
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
**      This demonstrates drawing onto an off-screen bitmap and then using
**      BitBlt() to copy the off-screen bitmap onto the display with the result
**      being clipped. The destination locations for the calls to BitBlt()
**      result in the target being partially off the display and so part of the
**      bitmap being copied is clipped to the display.
*/
void MtdsTest11() {
   HDS  hdsDisp;
   HDS  hdsTest;
   HBMP hbmpTest;

   /* In this case, we are going to need two DS objects, one for drawing onto
   ** the display and one for drawing onto the off-screen bitmap. GetDisplayDs()
   ** returns a handle to a DS initialized for drawing on the display. GetDs()
   ** returns a DS that is not associated with any bitmap as the drawing
   ** surface.
   */
   hdsDisp = mtds.GetDisplayDs();
   hdsTest = mtds.GetDs();

   /* Create an off-screen bitmap in memory on the display board. In this case,
   ** we are creating a 40x40 pixel, color bitmap. This bitmap is then selected
   ** as the drawing surface for the DS whose handle is in hdsTest. Setting the
   ** bitmap as the drawing surface in the DS makes that the bitmap that is
   ** drawn on when any drawing operations occur using the DS.
   */
   hbmpTest = mtds.CreateBitmap(40, 40, 16);
   if (hbmpTest == 0) {
      xil_printf("MtdsTest11: CreateBitmap failed\n\r");
   }
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Now that we have a DS with a drawing surface, initialize the other drawing
   ** parameters that we are going to use and then draw some graphics onto the
   ** off-screen bitmap.
   */
   mtds.SetDrwRop(hdsTest, drwCopyPen);
   mtds.SetPen(hdsTest, penSolid);

   /* Draw diagonal green lines between the corners of the off-screen bitmap.
   */
   mtds.SetFgColor(hdsTest, clrGreen);
   mtds.MoveTo(hdsTest,  0,  0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.MoveTo(hdsTest, 39,  0);
   mtds.LineTo(hdsTest,  0, 39);

   /* Draw a red square around the perimeter of the off-screen bitmap.
   */
   mtds.SetFgColor(hdsTest, clrRed);
   mtds.MoveTo(hdsTest,  0,  0);
   mtds.LineTo(hdsTest, 39,  0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.LineTo(hdsTest,  0, 39);
   mtds.LineTo(hdsTest,  0,  0);

   /* Use BitBlt() to copy the off-screen bitmap onto the display. The target
   ** locations are all partially off the display, so portions of the bitmap
   ** being copied will be clipped.
   */
   mtds.BitBlt(hdsDisp, -20, -20, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, -20, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 220, -20, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, -20, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 220, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, -20, 300, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 300, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 220, 300, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave.
   */
   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);
}

/* ------------------------------------------------------------ */
/*** MtdsTest12
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
**      This demonstrates drawing onto an off-screen bitmap and then using
**      BitBlt() to copy the off-screen bitmap onto the display. This is similar
**      to MtdsTest10 and MtdsTest11 above, except that in this case, the source
**      rectangle to BitBlt() is specified in such a way that it causes the
**      source bitmap to be clipped before it is copied. In all cases, the
**      destination specified to BitBlt() is entirely on the display, but the
**      source location specified causes part of the source rectangle to be off
**      the source bitmap, requiring that the transfer be clipped. When doing
**      BitBlt(), either the source rectangle or the destination rectangle can
**      reference pixels that are outside the bounds of the bitmap. What gets
**      transferred is the intersection of the visible part of the source
**      rectangle and the visible part of the destination rectangle.
*/
void MtdsTest12() {
   HDS  hdsDisp;
   HDS  hdsTest;
   HBMP hbmpTest;

   /* We need two DS objects, one for drawing onto the display and one for
   ** drawing onto the off-screen bitmap. GetDisplayDs() returns a handle to a
   ** DS initialized for drawing on the display. GetDs() returns a DS that is
   ** not associated with any bitmap as the drawing surface.
   */
   hdsDisp = mtds.GetDisplayDs();
   hdsTest = mtds.GetDs();
   hbmpTest = mtds.CreateBitmap(40, 40, 16);
   if (hbmpTest == 0) {
      xil_printf("MtdsTest12: CreateBitmap failed\n\r");
   }
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Now that we have a DS with a drawing surface, initialize the other drawing
   ** parameters that we are going to use and then draw some graphics onto the
   ** off-screen bitmap.
   */
   mtds.SetDrwRop(hdsTest, drwCopyPen);
   mtds.SetPen(hdsTest, penSolid);

   /* Draw diagonal green lines between the corners of the off-screen bitmap.
   */
   mtds.SetFgColor(hdsTest, clrGreen);
   mtds.MoveTo(hdsTest,  0,  0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.MoveTo(hdsTest, 39,  0);
   mtds.LineTo(hdsTest,  0, 39);

   /* Draw a red square around the perimeter of the off-screen bitmap.
   */
   mtds.SetFgColor(hdsTest, clrRed);
   mtds.MoveTo(hdsTest,  0,  0);
   mtds.LineTo(hdsTest, 39,  0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.LineTo(hdsTest,  0, 39);
   mtds.LineTo(hdsTest,  0,  0);

   /* Use BitBlt() to copy the off-screen bitmap onto the display. The source
   ** locations are all partially off the bitmap, so portions of the bitmap
   ** being copied will be clipped.
   */
   mtds.BitBlt(hdsDisp,  10,  10, 40, 40, hdsTest, -10, -10, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  10, 40, 40, hdsTest,   0, -10, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  10, 40, 40, hdsTest,  10, -10, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  10, 140, 40, 40, hdsTest, -10,   0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest,   0,   0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 140, 40, 40, hdsTest,  10,   0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  10, 270, 40, 40, hdsTest, -10,  10, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 270, 40, 40, hdsTest,   0,  10, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 270, 40, 40, hdsTest,  10,  10, ropSrcCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave.
   */
   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);
}

/* ------------------------------------------------------------ */
/*** MtdsTest13
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
**      This demonstrates drawing onto and off-screen bitmap and then using
**      BitBlt() to copy pixels from one location in the off-screen bitmap to
**      another location in the same off-screen bitmap. BitBlt() is then used to
**      copy the resulting off-screen bitmap onto the display. This is very
**      similar to MtdsTest10 above, except that a different pattern is drawn
**      initially onto the off-screen bitmap, and then BitBlt() is used to copy
**      some pixels within the off-screen bitmap before BitBlt() is used to copy
**      the result to the display.
*/
void MtdsTest13() {
   HDS  hdsDisp;
   HDS  hdsTest;
   HBMP hbmpTest;

   /* We need two DS objects, one for drawing onto the display and one for
   ** drawing onto the off-screen bitmap. GetDisplayDs() returns a handle to a
   ** DS initialized for drawing on the display. GetDs() returns a DS that is
   ** not associated with any bitmap as the drawing surface.
   */
   hdsDisp = mtds.GetDisplayDs();
   hdsTest = mtds.GetDs();
   hbmpTest = mtds.CreateBitmap(40, 40, 16);
   if (hbmpTest == 0) {
      xil_printf("MtdsTest13: CreateBitmap failed\n\r");
   }
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Now that we have a DS with a drawing surface, initialize the other drawing
   ** parameters that we are going to use and then draw some graphics onto the
   ** off-screen bitmap.
   */
   mtds.SetDrwRop(hdsTest, drwCopyPen);
   mtds.SetPen(hdsTest, penSolid);

   /* Draw a couple of diagonal green lines. These don't extend from corner to
   ** corner of the entire off-screen bitmap. This is similar to the pattern
   ** drawn in MtdsTest11 and MtdsTest12, but smaller.
   */
   mtds.SetFgColor(hdsTest, clrGreen);
   mtds.MoveTo(hdsTest, 10, 10);
   mtds.LineTo(hdsTest, 29, 29);
   mtds.MoveTo(hdsTest, 29, 10);
   mtds.LineTo(hdsTest, 10, 29);

   /* Draw a red square around the diagonal lines.
   */
   mtds.SetFgColor(hdsTest, clrRed);
   mtds.MoveTo(hdsTest, 10, 10);
   mtds.LineTo(hdsTest, 29, 10);
   mtds.LineTo(hdsTest, 29, 29);
   mtds.LineTo(hdsTest, 10, 29);
   mtds.LineTo(hdsTest, 10, 10);

   /* This BitBlt() copies pixels within the off-screen bitmap. Note that the
   ** source DS and the destination DS are the same. This means that the source
   ** bitmap and the destination bitmap will be the same. A 20x20 pixel
   ** rectangle of pixels is being copied up and to the left by 10 pixels, which
   ** copies the pattern drawn above up and to the left.
   */
   mtds.BitBlt(hdsTest, 0, 0, 20, 20, hdsTest, 10, 10, ropSrcCopy);

   /* Now that we have the resulting pattern in the off-screen bitmap, use
   ** BitBlt() to copy it onto the display in a few places. In this case all of
   ** the destination rectangles are on the display, so no clipping is done.
   */
   mtds.BitBlt(hdsDisp,  10,  10, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  10, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  10, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  10, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  10, 270, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 270, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 270, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave.
   */
   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);
}

/* ------------------------------------------------------------ */
/*** MtdsTest14
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
**      This demonstrates additional use of BitBlt(). In this case, it
**      illustrates using BitBlt() to copy pixels from the display to an
**      off-screen bitmap. It also illustrates that drawing can be done on the
**      display or onto off-screen bitmaps equally. This program first draws a
**      figure onto the display. It then copies that figure from the display
**      onto an off-screen bitmap. It then draws some additional graphics onto
**      the off-screen bitmap and then copies the result back onto the display.
*/
void MtdsTest14() {
  HDS  hdsDisp;
  HDS  hdsTest;
  HBMP hbmpTest;

   /* We need two DS objects, one for drawing onto the display and one for
   ** drawing onto the off-screen bitmap. GetDisplayDs() returns a handle to a
   ** DS initialized for drawing on the display. GetDs() returns a DS that is
   ** not associated with any bitmap as the drawing surface.
   */
   hdsDisp = mtds.GetDisplayDs();
   hdsTest = mtds.GetDs();
   hbmpTest = mtds.CreateBitmap(40, 40, 16);
   if (hbmpTest == 0) {
      xil_printf("MtdsTest14: CreateBitmap failed\n\r");
   }
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Now that we have a DS with a drawing surface, initialize the other drawing
   ** parameters that we are going to use and then draw some graphics onto the
   ** off-screen bitmap.
   */
   mtds.SetDrwRop(hdsDisp, drwCopyPen);
   mtds.SetPen(hdsDisp, penSolid);

   /* Here we are drawing to the center of the display. We are drawing the same
   ** pattern used in the previous demonstrations, a couple of green diagonal
   ** lines with a red square around them. Since we are drawing against the DS
   ** in hdsDisp, and hdsDisp was obtained by calling GetDisplayDs(), this draws
   ** on the display.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.MoveTo(hdsDisp, 100, 140);
   mtds.LineTo(hdsDisp, 139, 179);
   mtds.MoveTo(hdsDisp, 139, 140);
   mtds.LineTo(hdsDisp, 100, 179);

   mtds.SetFgColor(hdsDisp, clrRed);
   mtds.MoveTo(hdsDisp, 100, 140);
   mtds.LineTo(hdsDisp, 139, 140);
   mtds.LineTo(hdsDisp, 139, 179);
   mtds.LineTo(hdsDisp, 100, 179);
   mtds.LineTo(hdsDisp, 100, 140);

   /* Now that we have drawn the pattern in the center of the display, use
   ** BitBlt() to copy it onto the off-screen bitmap we set up earlier. In this
   ** case, the source is specified as hdsDisp and the destination is specified
   ** as hdsTest, so we are copying from the display to the off-screen bitmap.
   */
   mtds.BitBlt(hdsTest, 0, 0, 40, 40, hdsDisp, 100, 140, ropSrcCopy);

   /* We can continue to draw onto the off-screen bitmap by setting up
   ** additional drawing parameters in hdsTest and drawing graphics using it.
   ** The following draws a white, dotted square onto the off-screen bitmap.
   ** Note that if we had done this drawing before the BitBlt(), it would have
   ** been written over by the pixels copied by BitBlt().
   */
   mtds.SetDrwRop(hdsTest, drwCopyPen);
   mtds.SetPen(hdsTest, penDot);
   mtds.SetFgColor(hdsTest, clrWhite);
   mtds.MoveTo(hdsTest,  5,  5);
   mtds.LineTo(hdsTest, 34,  5);
   mtds.LineTo(hdsTest, 34, 34);
   mtds.LineTo(hdsTest,  5, 34);
   mtds.LineTo(hdsTest,  5,  5);

   /* Now that we have the resulting off-screen bitmap, we can copy it onto the
   ** display using BitBlt(). This copies it to various location on the display.
   */
   mtds.BitBlt(hdsDisp,  10,  10, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  10, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  10, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  10, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   /* Note that the following line would copy the off-screen bitmap over the top
   ** of the figure that was originally drawn onto the display. It is commented
   ** out so that we can see what the original figure looked like.
   */
   //mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  10, 270, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 270, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 270, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave.
   */
   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);
}

/* ------------------------------------------------------------ */
/*** MtdsTest15
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
**      This demonstrates the use of CreatePatternBrush() and PatBlt().
**      A pattern brush is one created using one of the predefined crosshatch
**      patterns with user specified colors. A brush is used as the fill pattern
**      when drawing a filled shape, or can be used with PatBlt() for various
**      effects. PatBlt() can be used to copy the brush pattern onto a rectangle
**      of the destination bitmap. Alternatively, different raster operation-
**      codes (raster-ops) can be used to create other effects, such as
**      highlighting.
*/
void MtdsTest15() {
   HDS hdsDisp;
   HBR hbrHorizontal;
   HBR hbrVertical;
   HBR hbrFwDiagonal;
   HBR hbrBkDiagonal;
   HBR hbrCross;
   HBR hbrDiagCross;
   HBR hbrChecker;
   HBR hbrBlock;
   HBR hbrHalfTone;

   /* In this demo, we are only going to be drawing onto the display, so we only
   ** need the display Ds.
   */
   hdsDisp = mtds.GetDisplayDs();

   /* Create pattern brushes illustrating the brush crosshatch patterns that are
   ** available. The brushes are created with a red foreground and a black
   ** background.
   */
   hbrHorizontal = mtds.CreatePatternBrush(idpsHorizontal, clrRed, clrBlack);
   hbrVertical   = mtds.CreatePatternBrush(idpsVertical,   clrRed, clrBlack);
   hbrFwDiagonal = mtds.CreatePatternBrush(idpsFwDiagonal, clrRed, clrBlack);
   hbrBkDiagonal = mtds.CreatePatternBrush(idpsBkDiagonal, clrRed, clrBlack);
   hbrCross      = mtds.CreatePatternBrush(idpsCross,      clrRed, clrBlack);
   hbrDiagCross  = mtds.CreatePatternBrush(idpsDiagCross, clrRed, clrBlack);
   hbrChecker    = mtds.CreatePatternBrush(idpsChecker,    clrRed, clrBlack);
   hbrBlock      = mtds.CreatePatternBrush(idpsBlock,      clrRed, clrBlack);
   hbrHalfTone   = mtds.CreatePatternBrush(idpsHalfTone,   clrRed, clrBlack);

   /* Now, use PatBlt() to copy the patterns onto the display to illustrate what
   ** they look like. By using the ropPatCopy raster-op, the pattern pixels are
   ** written over the destination pixels.
   */
   mtds.SetBrush(hdsDisp, hbrHorizontal);
   mtds.PatBlt(hdsDisp, 10, 10, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrVertical);
   mtds.PatBlt(hdsDisp, 80, 10, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrFwDiagonal);
   mtds.PatBlt(hdsDisp, 150, 10, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrBkDiagonal);
   mtds.PatBlt(hdsDisp, 10, 110, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrCross);
   mtds.PatBlt(hdsDisp, 80, 110, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrDiagCross);
   mtds.PatBlt(hdsDisp, 150, 110, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.PatBlt(hdsDisp, 10, 210, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrBlock);
   mtds.PatBlt(hdsDisp, 80, 210, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrHalfTone);
   mtds.PatBlt(hdsDisp, 150, 210, 60, 90, ropPatCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave.
   */
   mtds.DestroyBrush(hbrHorizontal);
   mtds.DestroyBrush(hbrVertical);
   mtds.DestroyBrush(hbrFwDiagonal);
   mtds.DestroyBrush(hbrBkDiagonal);
   mtds.DestroyBrush(hbrCross);
   mtds.DestroyBrush(hbrDiagCross);
   mtds.DestroyBrush(hbrChecker);
   mtds.DestroyBrush(hbrBlock);
   mtds.DestroyBrush(hbrHalfTone);

   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest16
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
**      This demonstration is very similar to MtdsTest15 above. The only real
**      difference is that when it uses PatBlt() to copy the patterns onto the
**      display, it specifies destination rectangles that are partially off of
**      the display to illustrate that clipping occurs with PatBlt() the same
**      way that it does with BitBlt().
*/
void MtdsTest16() {
   HDS hdsDisp;
   HBR hbrHorizontal;
   HBR hbrVertical;
   HBR hbrFwDiagonal;
   HBR hbrBkDiagonal;
   HBR hbrCross;
   HBR hbrDiagCross;
   HBR hbrChecker;
   HBR hbrBlock;
   HBR hbrHalfTone;

   /* In this demo, we are only going to be drawing onto the display, so we only
   ** need the display Ds.
   */
   hdsDisp = mtds.GetDisplayDs();

   /* Create pattern brushes illustrating the brush crosshatch patterns that are
   ** available. The brushes are created with a red foreground and a black
   ** background.
   */
   hbrHorizontal = mtds.CreatePatternBrush(idpsHorizontal, clrRed, clrBlack);
   hbrVertical   = mtds.CreatePatternBrush(idpsVertical,   clrRed, clrBlack);
   hbrFwDiagonal = mtds.CreatePatternBrush(idpsFwDiagonal, clrRed, clrBlack);
   hbrBkDiagonal = mtds.CreatePatternBrush(idpsBkDiagonal, clrRed, clrBlack);
   hbrCross      = mtds.CreatePatternBrush(idpsCross,      clrRed, clrBlack);
   hbrDiagCross  = mtds.CreatePatternBrush(idpsDiagCross,  clrRed, clrBlack);
   hbrChecker    = mtds.CreatePatternBrush(idpsChecker,    clrRed, clrBlack);
   hbrBlock      = mtds.CreatePatternBrush(idpsBlock,      clrRed, clrBlack);
   hbrHalfTone   = mtds.CreatePatternBrush(idpsHalfTone,   clrRed, clrBlack);

   /* Now, use PatBlt() to copy the patterns onto the display to illustrate what
   ** they look like. In this case, the destination of each call to PatBlt() is
   ** specified such that clipping needs to occur when writing to the
   ** destination.
   */
   mtds.SetBrush(hdsDisp, hbrHorizontal);
   mtds.PatBlt(hdsDisp, -30, -45, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrVertical);
   mtds.PatBlt(hdsDisp, 90, -45, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrFwDiagonal);
   mtds.PatBlt(hdsDisp, 210, -45, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrBkDiagonal);
   mtds.PatBlt(hdsDisp, -30, 115, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrCross);
   mtds.PatBlt(hdsDisp, 90, 115, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrDiagCross);
   mtds.PatBlt(hdsDisp, 210, 115, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.PatBlt(hdsDisp, -30, 275, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrBlock);
   mtds.PatBlt(hdsDisp, 90, 275, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrHalfTone);
   mtds.PatBlt(hdsDisp, 210, 275, 60, 90, ropPatCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave.
   */
   mtds.ReleaseDs(hdsDisp);
   mtds.DestroyBrush(hbrHorizontal);
   mtds.DestroyBrush(hbrVertical);
   mtds.DestroyBrush(hbrFwDiagonal);
   mtds.DestroyBrush(hbrBkDiagonal);
   mtds.DestroyBrush(hbrCross);
   mtds.DestroyBrush(hbrDiagCross);
   mtds.DestroyBrush(hbrChecker);
   mtds.DestroyBrush(hbrBlock);

   mtds.DestroyBrush(hbrHalfTone);
}

/* ------------------------------------------------------------ */
/*** MtdsTest17
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
**      This demonstration illustrates the use of pattern brushes and PatBlt().
**      It is very similar to MtdsTest15 above, except that the call to PatBlt()
**      performs the operation on an off-screen bitmap. Once all of the PatBlt()
**      operation have been completed, the off-screen bitmap is copied onto the
**      display.
*/
void MtdsTest17() {
   HDS  hdsDisp;
   HDS  hdsTest;
   HBMP hbmpTest;
   HBR  hbrHorizontal;
   HBR  hbrVertical;
   HBR  hbrFwDiagonal;
   HBR  hbrBkDiagonal;
   HBR  hbrCross;
   HBR  hbrDiagCross;
   HBR  hbrChecker;
   HBR  hbrBlock;
   HBR  hbrHalfTone;

   /* We are going to be drawing onto the display and onto an off-screen bitmap.
   ** So, get the DS handles that we are going to use and create the off-screen
   ** bitmap. In this case, the off-screen bitmap is a color bitmap that has the
   ** same dimensions as the display.
   */
   hdsDisp = mtds.GetDisplayDs();
   hdsTest = mtds.GetDs();
   hbmpTest = mtds.CreateBitmap(240, 320, 16);
   if (hbmpTest == 0) {
      xil_printf("MtdsTest17: CreateBitmap failed\n\r");
   }
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Create pattern brushes illustrating the brush crosshatch patterns that are
   ** available. The brushes are created with a green foreground and a black
   ** background.
   */
   hbrHorizontal = mtds.CreatePatternBrush(idpsHorizontal, clrGreen, clrBlack);
   hbrVertical   = mtds.CreatePatternBrush(idpsVertical,   clrGreen, clrBlack);
   hbrFwDiagonal = mtds.CreatePatternBrush(idpsFwDiagonal, clrGreen, clrBlack);
   hbrBkDiagonal = mtds.CreatePatternBrush(idpsBkDiagonal, clrGreen, clrBlack);
   hbrCross      = mtds.CreatePatternBrush(idpsCross,      clrGreen, clrBlack);
   hbrDiagCross  = mtds.CreatePatternBrush(idpsDiagCross,  clrGreen, clrBlack);
   hbrChecker    = mtds.CreatePatternBrush(idpsChecker,    clrGreen, clrBlack);
   hbrBlock      = mtds.CreatePatternBrush(idpsBlock,      clrGreen, clrBlack);
   hbrHalfTone   = mtds.CreatePatternBrush(idpsHalfTone,   clrGreen, clrBlack);

   /* Now, use PatBlt() to copy the patterns onto the off-screen bitmap.
   */
   mtds.SetBrush(hdsTest, hbrHorizontal);
   mtds.PatBlt(hdsTest, 10, 10, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrVertical);
   mtds.PatBlt(hdsTest, 80, 10, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrFwDiagonal);
   mtds.PatBlt(hdsTest, 150, 10, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrBkDiagonal);
   mtds.PatBlt(hdsTest, 10, 110, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrCross);
   mtds.PatBlt(hdsTest, 80, 110, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrDiagCross);
   mtds.PatBlt(hdsTest, 150, 110, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrChecker);
   mtds.PatBlt(hdsTest, 10, 210, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrBlock);
   mtds.PatBlt(hdsTest, 80, 210, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrHalfTone);
   mtds.PatBlt(hdsTest, 150, 210, 60, 90, ropPatCopy);

   /* Now that we have rendered all of the patterns onto the off-screen bitmap,
   ** use BitBlt() to copy the off-screen bitmap onto the display. In this case,
   ** we are overwriting the entire display with the off-screen bitmap.
   */
   mtds.BitBlt(hdsDisp, 0, 0, 240, 320, hdsTest, 0, 0, ropSrcCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave.
   */
   mtds.DestroyBrush(hbrHorizontal);
   mtds.DestroyBrush(hbrVertical);
   mtds.DestroyBrush(hbrFwDiagonal);
   mtds.DestroyBrush(hbrBkDiagonal);
   mtds.DestroyBrush(hbrCross);
   mtds.DestroyBrush(hbrDiagCross);
   mtds.DestroyBrush(hbrChecker);
   mtds.DestroyBrush(hbrBlock);
   mtds.DestroyBrush(hbrHalfTone);

   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);
}

/* ------------------------------------------------------------ */
/*** MtdsTest18
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
**      This demonstration illustrates the use of pattern brushes, PatBlt(), and
**      off-screen bitmaps. It is essentially the same as MtdsTest17 above,
**      except that in this case the destination rectangles specified for
**      PatBlt() are all partially off the visible surface of the off-screen
**      bitmap requiring that the result be clipped during the PatBlt()
**      operation.
*/
void MtdsTest18() {
   HDS  hdsDisp;
   HDS  hdsTest;
   HBMP hbmpTest;
   HBR  hbrHorizontal;
   HBR  hbrVertical;
   HBR  hbrFwDiagonal;
   HBR  hbrBkDiagonal;
   HBR  hbrCross;
   HBR  hbrDiagCross;
   HBR  hbrChecker;
   HBR  hbrBlock;
   HBR  hbrHalfTone;

   /* We are going to be drawing onto the display and onto an off-screen bitmap.
   ** So, get the DS handles that we are going to use and create the off-screen
   ** bitmap. In this case, the off-screen bitmap is a color bitmap that has the
   ** same dimensions as the display.
   **/
   hdsDisp = mtds.GetDisplayDs();
   hdsTest = mtds.GetDs();
   hbmpTest = mtds.CreateBitmap(240, 320, 16);
   if (hbmpTest == 0) {
      xil_printf("MtdsTest18: CreateBitmap failed\n\r");
   }
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Create pattern brushes illustrating the brush crosshatch patterns that are
   ** available. The brushes are created with a green foreground and a black
   ** background.
   */
   hbrHorizontal = mtds.CreatePatternBrush(idpsHorizontal, clrGreen, clrBlack);
   hbrVertical   = mtds.CreatePatternBrush(idpsVertical,   clrGreen, clrBlack);
   hbrFwDiagonal = mtds.CreatePatternBrush(idpsFwDiagonal, clrGreen, clrBlack);
   hbrBkDiagonal = mtds.CreatePatternBrush(idpsBkDiagonal, clrGreen, clrBlack);
   hbrCross      = mtds.CreatePatternBrush(idpsCross,      clrGreen, clrBlack);
   hbrDiagCross  = mtds.CreatePatternBrush(idpsDiagCross,  clrGreen, clrBlack);
   hbrChecker    = mtds.CreatePatternBrush(idpsChecker,    clrGreen, clrBlack);
   hbrBlock      = mtds.CreatePatternBrush(idpsBlock,      clrGreen, clrBlack);
   hbrHalfTone   = mtds.CreatePatternBrush(idpsHalfTone,   clrGreen, clrBlack);

   /* Now, use PatBlt() to copy the patterns onto the off-screen bitmap. In this
   ** case, the destination rectangles have all been specified such that they
   ** are all partially off the visible surface of the off-screen bitmap,
   ** requiring that they be clipped during the PatBlt() operation.
   */
   mtds.SetBrush(hdsTest, hbrHorizontal);
   mtds.PatBlt(hdsTest, -30, -45, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrVertical);
   mtds.PatBlt(hdsTest, 90, -45, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrFwDiagonal);
   mtds.PatBlt(hdsTest, 210, -45, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrBkDiagonal);
   mtds.PatBlt(hdsTest, -30, 115, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrCross);
   mtds.PatBlt(hdsTest, 90, 115, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrDiagCross);
   mtds.PatBlt(hdsTest, 210, 115, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrChecker);
   mtds.PatBlt(hdsTest, -30, 275, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrBlock);
   mtds.PatBlt(hdsTest, 90, 275, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsTest, hbrHalfTone);
   mtds.PatBlt(hdsTest, 210, 275, 60, 90, ropPatCopy);

   /* Now that we have rendered all of the patterns onto the off-screen bitmap,
   ** use BitBlt() to copy the off-screen bitmap onto the display. In this case,
   ** we are overwriting the entire display with the off-screen bitmap.
   */
   mtds.BitBlt(hdsDisp, 0, 0, 240, 320, hdsTest, 0, 0, ropSrcCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave.
   */
   mtds.DestroyBrush(hbrHorizontal);
   mtds.DestroyBrush(hbrVertical);
   mtds.DestroyBrush(hbrFwDiagonal);
   mtds.DestroyBrush(hbrBkDiagonal);
   mtds.DestroyBrush(hbrCross);
   mtds.DestroyBrush(hbrDiagCross);
   mtds.DestroyBrush(hbrChecker);
   mtds.DestroyBrush(hbrBlock);
   mtds.DestroyBrush(hbrHalfTone);

   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);
}

/* ------------------------------------------------------------ */
/*** MtdsTest19
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
**      This demo illustrates the use of stock brushes and solid brushes as well
**      as the use of a pattern brush. PatBlt() is used to render the various
**      brushes onto the display to show their appearance. It is similar to
**      MtdsTest15 above, except for the brushes that are rendered.
**
**      A solid brush is one where all the pixels of the brush pattern are the
**      same color. A solid brush of any given color can be created by the user.
**      Stock brushes are a small set of solid brushes that are predefined by
**      the system and always available.
*/
void MtdsTest19() {
   HDS hdsDisp;
   HBR hbrMyRed;
   HBR hbrMyGreen;
   HBR hbrMyBlue;
   HBR hbrBlock;

   /* In this demo, we are only going to be drawing onto the display, so we only
   ** need the display Ds.
   */
   hdsDisp = mtds.GetDisplayDs();

   /* Create some solid brushes and a pattern brush.
   ** Note that there actually are red, green, and blue stock brushes defined by
   ** the system, so these are somewhat redundant, but it illustrates creating a
   ** solid brush. Also note that there is a special stock brush, hbrNull,
   ** that is defined to suppress area fill when drawing a filled shape, such as
   ** Rectangle().
   */
   hbrMyRed   = mtds.CreateSolidBrush(clrRed);
   hbrMyGreen = mtds.CreateSolidBrush(clrGreen);
   hbrMyBlue  = mtds.CreateSolidBrush(clrBlue);

   hbrBlock = mtds.CreatePatternBrush(idpsBlock, clrRed, clrBlack);

   /* Use PatBlt() to render the solid brushes onto the display.
   */
   mtds.SetBrush(hdsDisp, hbrMyRed);
   mtds.PatBlt(hdsDisp, 10, 10, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrMyGreen);
   mtds.PatBlt(hdsDisp, 80, 10, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrMyBlue);
   mtds.PatBlt(hdsDisp, 150, 10, 60, 90, ropPatCopy);

   /* Now use PatBlt() to render some of the stock brushes onto the display.
   */
   mtds.SetBrush(hdsDisp, hbrDkGray);
   mtds.PatBlt(hdsDisp, 10, 110, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrMedGray);
   mtds.PatBlt(hdsDisp, 80, 110, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrLtGray);
   mtds.PatBlt(hdsDisp, 150, 110, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrWhite);
   mtds.PatBlt(hdsDisp, 10, 210, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrBlack);
   mtds.PatBlt(hdsDisp, 80, 210, 60, 90, ropPatCopy);

   /* Finally, use PatBlt() to render the pattern brush onto the display.
   */
   mtds.SetBrush(hdsDisp, hbrBlock);
   mtds.PatBlt(hdsDisp, 150, 210, 60, 90, ropPatCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave. Stock brushes are predefined by the system and should not be
   ** destroyed, although the system will ignore an attempt to do so. You only
   ** need to destroy brushes that were created.
   */
   mtds.DestroyBrush(hbrMyRed);
   mtds.DestroyBrush(hbrMyGreen);
   mtds.DestroyBrush(hbrMyBlue);
   mtds.DestroyBrush(hbrBlock);

   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest20
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
**      This demonstrates the use of raster-ops with PatBlt() to create
**      different effects.
*/
void MtdsTest20() {
   HDS hdsDisp;
   HBR hbrChecker;
   HBR hbrHalfTone;

   /* In this demo, we are only going to be drawing onto the display, so we only
   ** need the display Ds.
   */
   hdsDisp = mtds.GetDisplayDs();

   /* Create a couple of pattern brushes that will provide the pattern to
   ** illustrate using different raster-ops with PatBlt().
   */
   hbrChecker  = mtds.CreatePatternBrush(idpsChecker,  clrRed, clrBlack);
   hbrHalfTone = mtds.CreatePatternBrush(idpsHalfTone, clrRed, clrBlack);

   /* Illustrate the ropPatDstXor raster-op. This will XOR the pattern pixels
   ** with the destination pixels. The brush contains red pixels and black
   ** pixels. When the black pixels are XOR'd with the white pixels in the
   ** display, they are left unchanged. When the red pixels are XOR'd with the
   ** white pixels, the result will be cyan, so we get a checkerboard of cyan
   ** and white squares.
   */
   mtds.SetBrush(hdsDisp, hbrWhite);
   mtds.PatBlt(hdsDisp, 10, 10, 60, 90, ropPatCopy);
   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.PatBlt(hdsDisp, 10, 10, 60, 90, ropPatDstXor);

   /* Illustrate the ropPatDstOr raster-op. This will OR the pattern pixels with
   ** the destination pixels. The brush contains red and black pixels. When the
   ** black pixels in the brush are OR'd with the pixels in the destination,
   ** they are left unchanged, meaning that they are left green. The color red
   ** has the following value: 0x00FF0000, the color green has the following
   ** pattern: 0x0000FF00. When red and green are OR'd, the result is
   ** 0x00FFFF00, which is the color yellow, so we get a checkerboard of green
   ** and yellow squares.
   */
   mtds.SetBrush(hdsDisp, hbrGreen);
   mtds.PatBlt(hdsDisp, 80, 10, 60, 90, ropPatCopy);
   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.PatBlt(hdsDisp, 80, 10, 60, 90, ropPatDstOr);

   /* Illustrate the ropPatDstOrNot raster-op. This will OR the pattern pixels
   ** with the destination pixels and then NOT the result. The brush contains
   ** red and black pixels. When the black pixels in the brush are OR'd with the
   ** pixels in the destination, they are left unchanged, resulting in green
   ** pixels where the brush is black. This has the value 0x0000FF00. When this
   ** is NOT'd, the result is 0xXXFF00FF, which is the color magenta. (ignore
   ** the high 8 bits of the color as they are not used) The color red has the
   ** following value: 0x00FF0000, the color green has the following pattern:
   ** 0x0000FF00. When red and green are OR'd, the result is 0x00FFFF00. When
   ** this is NOT'd, the result is 0xXX0000FF, which is the color blue. We get a
   ** checkerboard of magenta and blue squares.
   */
   mtds.SetBrush(hdsDisp, hbrGreen);
   mtds.PatBlt(hdsDisp, 150, 10, 60, 90, ropPatCopy);
   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.PatBlt(hdsDisp, 150, 10, 60, 90, ropPatDstOrNot);

   /* Illustrate the ropPatDstAnd raster-op. This will AND the pattern pixels
   ** with the destination pixels. The brush contains red and black pixels. When
   ** the black pixels in the brush are AND'd with the white pixels currently in
   ** the destination, the result is black. When the red pixels are AND'd with
   ** the white pixels the result is red. So we end up with a checkerboard of
   ** red and black squares.
   */
   mtds.SetBrush(hdsDisp, hbrWhite);
   mtds.PatBlt(hdsDisp, 10, 110, 60, 90, ropPatCopy);
   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.PatBlt(hdsDisp, 10, 110, 60, 90, ropPatDstAnd);

   /* Illustrate the ropPatDstAndNot raster-op. this will AND the pattern pixels
   ** with the destination pixels and then NOT the result. When the black pixels
   ** in the brush are AND'd with white pixels in the display, the result is
   ** black. When black is NOT'd, the result is white. When the red pixels in
   ** the brush are AND'd with the white pixels in the display, the result is
   ** red. When red is NOT'd, the result is cyan. So, we end up with a
   ** checkerboard of white and cyan squares, which, as expected, is the inverse
   ** of the first pattern that was drawn.
   */
   mtds.SetBrush(hdsDisp, hbrWhite);
   mtds.PatBlt(hdsDisp, 80, 110, 60, 90, ropPatCopy);
   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.PatBlt(hdsDisp, 80, 110, 60, 90, ropPatDstAndNot);

   /* Illustrate the ropPatDstNotAnd raster-op. This will NOT the destination
   ** pixels and then AND the result with the pattern. When the green in the
   ** destination is NOT'd, the result is magenta. When the magenta is AND'd
   ** with red, the result is red. So we get a checkerboard of red and black
   ** pixels.
   */
   mtds.SetBrush(hdsDisp, hbrGreen);
   mtds.PatBlt(hdsDisp, 150, 110, 60, 90, ropPatCopy);
   mtds.SetBrush(hdsDisp, hbrChecker);
   mtds.PatBlt(hdsDisp, 150, 110, 60, 90, ropPatDstNotAnd);

   /* The next three sections simply copy the patterns to the display. This
   ** shows the hbrLtBlueGray and hbrMedBlueGray stock brushes and the
   ** hbrHalfTone pattern.
   */
   mtds.SetBrush(hdsDisp, hbrLtBlueGray);
   mtds.PatBlt(hdsDisp, 10, 210, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrMedBlueGray);
   mtds.PatBlt(hdsDisp, 80, 210, 60, 90, ropPatCopy);

   mtds.SetBrush(hdsDisp, hbrHalfTone);
   mtds.PatBlt(hdsDisp, 150, 210, 60, 90, ropPatCopy);

   /* Free all of the resources being used by this demonstration function before
   ** we leave. Stock brushes are predefined by the system and should not be
   ** destroyed, although the system will ignore an attempt to do so. You only
   ** need to destroy brushes that were created.
   */
   mtds.DestroyBrush(hbrChecker);
   mtds.DestroyBrush(hbrHalfTone);

   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest21
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
**      This demonstration illustrates drawing text on the display. It also
**      shows all of the characters defined in the hfntConsole font.
*/
void MtdsTest21() {
   HDS     hdsDisp;
   int16_t xco;
   int16_t yco;
   int16_t dyco;
   PNT     pntTxt;

   /* Declare the strings that we are going to print.
   */
   char rgchTest1[] = { "ABCDEFGHIJKLMNOPQRSTUVWXYZ" };
   char rgchTest2[] = { "abcdefghijklmnopqrstuvwxyz" };
   char rgchTest3[] = { "0123456789" };
   char rgchTest4[] = { " !\"#$%&'()*+,-./:;<=>?" };
   char rgchTest5[] = { "@[\\]^_`{|}~" };

   char rgchTest6[] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                        0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F };
   char rgchTest7[] = { 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
                        0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F };
   char rgchTest8[] = { 0x7F };

   /* Get the DS for drawing on the display and initialize it.
   */
   hdsDisp = mtds.GetDisplayDs();

   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.SetBgColor(hdsDisp, clrBlack);
   mtds.SetDrwRop(hdsDisp, drwCopyPen);
   mtds.SetFont(hdsDisp, hfntConsole);

   /* We are going to be drawing several lines of text, so figure out how much
   ** space needs to be allowed between lines. This can be done by calling
   ** GetTextExtent() with any of the strings, as what we are looking for is the
   ** Y extent of the text.
   **
   ** Unfortunately, Ver 1.04 of the display firmware has a bug where calls to
   ** GetTextExtent() return incorrect values until after TextOut() has been
   ** called the first time. It would be better to be able to call
   ** GetTextExtent() before any text has been drawn, but it won't work
   ** correctly in V1.04 firmware. This bug has been fixed in later versions of
   ** the display device firmware.
   */
#if defined(DEAD)
   mtds.GetTextExtent(hdsDisp, strlen(rgchTest1), rgchTest1, &pntTxt);
   xil_printf("TextExtent: xco = %d yco = %d\n\r", pntTxt.xco, pntTxt.yco);
#endif

   /* We'll use a two pixel margin at the top and left of the screen.
   */
   xco = 2;
   yco = 2;
  
   /* Print out the strings, advancing by a line each time.
   */
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest1), rgchTest1);

   /* Use the line height plus one pixel of leading for the distance from the
   ** origin of one line of text to the next. As mentioned above, it would be
   ** more convenient to have set this up before the first call to TextOut().
   ** Another option would have been to do a dummy write of a single character
   ** to an off-screen location. The text output would get clipped so that
   ** nothing is visible, but this would have the side effect of working around
   ** the bug in GetTextExtent().
   */
   mtds.GetTextExtent(hdsDisp, strlen(rgchTest1), rgchTest1, &pntTxt);
   dyco = pntTxt.yco + 1;

   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest3), rgchTest3);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest4), rgchTest4);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest5), rgchTest5);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, 16, rgchTest6);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, 16, rgchTest7);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, 1, rgchTest8);
   yco += dyco;

   /* Release the DS before we leave so that it doesn't get lost.
   */
   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest22
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
**      This demonstration shows drawing text and shows how text is clipped if
**      portions of the printed string are off the visible surface of the
**      bitmap.
*/
void MtdsTest22() {
   HDS     hdsDisp;
   int16_t xco;
   int16_t yco;
   int16_t dyco;
   PNT     pnt;

   char rgchTest1[] = { "ABCDEFGHIJKLMNOPQRSTUVWXYZ" };
   char rgchTest2[] = { "abcdefghijklmnopqrstuvwxyz" };
   char rgchTest3[] = { "0123456789" };
   char rgchTest4[] = { " !\"#$%&'()*+,-./:;<=>?" };
   char rgchTest5[] = { "@[\\]^_`{|}~" };

   char rgchTest6[] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                        0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F };
   char rgchTest7[] = { 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
                        0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F };
   char rgchTest8[] = { 0x7F };

   /* Get the DS for drawing on the display and initialize it.
   */
   hdsDisp = mtds.GetDisplayDs();
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.SetBgColor(hdsDisp, clrBlack);
   mtds.SetDrwRop(hdsDisp, drwCopyPen);
   mtds.SetFont(hdsDisp, hfntConsole);

   /* Test clipping at the top of the bitmap.
   */
   xco = -4;
   yco = -2;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   xco = 88;
   yco = -2;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   /* Use GetTextExtent() to determine the Y extent of the font and use that
   ** to compute the vertical spacing from the origin of one line to the next.
   */
   mtds.GetTextExtent(hdsDisp, 8, rgchTest1, &pnt);
   dyco = pnt.yco + 1;

   xco = 180;
   yco = -2;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);
   yco += dyco;

   xco = -4;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   xco = 88;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   xco = 180;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   /* Test clipping at the bottom of the bitmap.
   */
   xco = -4;
   yco = 316;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   xco = 88;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   xco = 180;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);
   yco -= dyco;

   xco = -4;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   xco = 88;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   xco = 180;
   mtds.TextOut(hdsDisp, xco, yco, 8, rgchTest1);

   /* Test clipping on the left side of the bitmap.
   */
   xco = 2;
   yco = 28;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest1), rgchTest1);
   yco += dyco;

   xco = -4;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest1), rgchTest1);
   yco += dyco;

   xco = -8;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest1), rgchTest1);
   yco += dyco;

   xco = -12;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest1), rgchTest1);
   yco += dyco;

   xco = -196;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest1), rgchTest1);
   yco += dyco;

   xco = -200;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest1), rgchTest1);
   yco += dyco;

   xco = -204;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest1), rgchTest1);
   yco += dyco;

   /* Test clipping on the right side of the bitmap.
   */
   xco = 2;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   xco = 32;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   xco = 36;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   xco = 40;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   xco = 224;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   xco = 228;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   xco = 232;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   xco = 236;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   /* Output some more characters just for something to do.
   */
   xco = 10;
   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest3), rgchTest3);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest4), rgchTest4);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, strlen(rgchTest5), rgchTest5);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, 16, rgchTest6);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, 16, rgchTest7);
   yco += dyco;

   mtds.TextOut(hdsDisp, xco, yco, 1, rgchTest8);
   yco += dyco;

   /* Release the display DS before we leave so that it doesn't get lost.
   */
   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest23()
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
**      This demonstration illustrates drawing text onto off-screen bitmaps. It
**      also illustrates using BitBlt() to copy from a monochrome off-screen
**      bitmap onto the display.
*/
void MtdsTest23() {
   HDS     hdsDisp;
   HDS     hdsColor;
   HBMP    hbmpColor;
   HDS     hdsMono;
   HBMP    hbmpMono;
   int16_t xco;
   int16_t yco;
   int16_t dyco;

   /* Define the text strings that we are going to be printing.
   */
   char rgchTest1[] = { "ABCDEFGHIJKLMNOPQRSTUVWXYZ" };
   char rgchTest2[] = { "abcdefghijklmnopqrstuvwxyz" };
   char rgchTest3[] = { "0123456789" };
   char rgchTest4[] = { " !\"#$%&'()*+,-./:;<=>?" };
   char rgchTest5[] = { "@[\\]^_`{|}~" };

   char rgchTest6[] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                        0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F };
   char rgchTest7[] = { 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
                        0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F };
   char rgchTest8[] = { 0x7F };

   /* Get the display DS for drawing on the display.
   */
   hdsDisp = mtds.GetDisplayDs();

   /* We're going to use a color off-screen bitmap. Create the bitmap and then
   ** set it as the drawing surface for a DS so that we can draw on it.
   */
   hdsColor = mtds.GetDs();
   hbmpColor = mtds.CreateBitmap(210, 80, 16);
   mtds.SetDrawingSurface(hdsColor, hbmpColor);

   /* We're also going to use a monochrome off-screen bitmap. Create this bitmap
   ** and set it as the drawing surface for another DS so that we can draw on it
   ** as well. A monochrome bitmap has a single bit per pixel, so we specify 1
   ** for the pixel format when we create it.
   */
   hdsMono = mtds.GetDs();
   hbmpMono = mtds.CreateBitmap(210, 80, 1);
   mtds.SetDrawingSurface(hdsMono, hbmpMono);

   /* Draw some text on the color bitmap and then BitBlt() the result to the
   ** display.
   */
   mtds.SetFgColor(hdsColor, clrGreen);
   mtds.SetBgColor(hdsColor, clrBlack);
   mtds.SetDrwRop(hdsColor, drwCopyPen);
   mtds.SetFont(hdsColor, hfntConsole);

   xco = 2;
   yco = 3;

   /* To be strictly "correct" we should use GetTextExtent() to determine what
   ** the vertical extent of the text is when printed. However, we actually know
   ** that we are using the hfntConsole font and that its character height is 8
   ** pixels. As long as we know the environment (i.e. version of display card
   ** firmware, specific font, version of the font, etc.) we can cheat and use
   ** the knowledge about the font. This may, of course, break if anything about
   ** the system changes, so it is better overall to do it "correctly" by
   ** calling GetTextExtent(). Certainly, if the font being used can change,
   ** then GetTextExtent() must be used.
   */
   dyco = 9;

   /* Drawing text onto an off-screen bitmap is exactly the same as drawing onto
   ** the display bitmap, except that we use a different DS that has been set up
   ** to use the off-screen bitmap as the drawing surface.
   */
   mtds.TextOut(hdsColor, xco, yco, strlen(rgchTest1), rgchTest1);
   yco += dyco;

   mtds.TextOut(hdsColor, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   mtds.TextOut(hdsColor, xco, yco, strlen(rgchTest3), rgchTest3);
   yco += dyco;

   mtds.TextOut(hdsColor, xco, yco, strlen(rgchTest4), rgchTest4);
   yco += dyco;

   mtds.TextOut(hdsColor, xco, yco, strlen(rgchTest5), rgchTest5);
   yco += dyco;

   mtds.TextOut(hdsColor, xco, yco, 16, rgchTest6);
   yco += dyco;

   mtds.TextOut(hdsColor, xco, yco, 16, rgchTest7);
   yco += dyco;

   mtds.TextOut(hdsColor, xco, yco, 1, rgchTest8);
   yco += dyco;

   /* Copy the off-screen bitmap onto the display. Color off-screen bitmaps use
   ** the same color format as the display, so no conversions need to occur when
   ** copying from a color bitmap (off-screen) to a color bitmap (the display).
   */
   mtds.BitBlt(hdsDisp, 15, 5, 210, 80, hdsColor, 0, 0, ropSrcCopy);

   /* Draw some text on the monochrome bitmap and then copy the result to the
   ** display.
   */
   mtds.SetFgColor(hdsMono, clrWhite);
   mtds.SetBgColor(hdsMono, clrBlack);
   mtds.SetDrwRop(hdsMono, drwCopyPen);
   mtds.SetFont(hdsMono, hfntConsole);

   xco  = 1;
   yco  = 2;
   dyco = 9;

   /* Again, there is no difference between drawing on different off-screen
   ** bitmaps. We use a DS that has been set up with the appropriate off-screen
   ** bitmap as the drawing surface. In this case, the drawing surface is a
   ** monochrome bitmap. When drawing text or linear elements on a monochrome
   ** bitmap, the foreground and background colors should be set to clrWhite or
   ** clrBlack. If foreground is clrWhite and background is clrBlack, white
   ** figures will be drawn on a black background. When foreground is clrBlack
   ** and background is clrWhite, black figures will be drawn on a white
   ** background. Background transparency mode works the same as with color
   ** bitmaps. If the transparency mode is set to bkTransparent, background
   ** pixels are not drawn.
   */
   mtds.TextOut(hdsMono, xco, yco, strlen(rgchTest1), rgchTest1);
   yco += dyco;

   mtds.TextOut(hdsMono, xco, yco, strlen(rgchTest2), rgchTest2);
   yco += dyco;

   mtds.TextOut(hdsMono, xco, yco, strlen(rgchTest3), rgchTest3);
   yco += dyco;

   mtds.TextOut(hdsMono, xco, yco, strlen(rgchTest4), rgchTest4);
   yco += dyco;

   mtds.TextOut(hdsMono, xco, yco, strlen(rgchTest5), rgchTest5);
   yco += dyco;

   mtds.TextOut(hdsMono, xco, yco, 16, rgchTest6);
   yco += dyco;

   mtds.TextOut(hdsMono, xco, yco, 16, rgchTest7);
   yco += dyco;

   mtds.TextOut(hdsMono, xco, yco, 1, rgchTest8);
   yco += dyco;

   /* Now, use BitBlt() to copy from the off-screen bitmap to the display
   ** bitmap. When copying from a monochrome bitmap to a color bitmap, color
   ** conversion occurs. Pixels that are set ('1') in the off-screen bitmap get
   ** translated to the foreground color, pixels that are clear ('0') get
   ** translated to the background color. The foreground and background colors
   ** that are used are the ones set in the destination DS. Here, we are setting
   ** the foreground color to white and the background color to dark gray. So
   ** after we have performed the BitBlt() we will see white text on a dark gray
   ** background.
   */
   mtds.SetFgColor(hdsDisp, clrWhite);
   mtds.SetBgColor(hdsDisp, clrDkGray);
   mtds.BitBlt(hdsDisp, 15, 120, 210, 80, hdsMono, 0, 0, ropSrcCopy);

   /* Clean up. Destroy and release all resources used before we return so that
   ** the memory isn't lost.
   */
   mtds.DestroyBitmap(hbmpColor);
   mtds.DestroyBitmap(hbmpMono);
   mtds.ReleaseDs(hdsColor);
   mtds.ReleaseDs(hdsMono);
   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest24()
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
**      This demo illustrates using DrawBitmap() to copy pixels from an
**      off-screen bitmap to the display. DrawBitmap() works very similarly to
**      BitBlt(). The primary difference is that DrawBitmap() doesn't use a
**      raster operation code and it uses only the source and destination
**      bitmaps, not the brush pattern. Instead of a raster-op, DrawBitmap()
**      uses the background transparency mode and intensity to control how the
**      result gets drawn. This particular test doesn't use background
**      transparency or intensity, so it illustrates the simplest use of
**      DrawBitmap(). In this case, it is essentially identical to BitBlt()
**      using the ropSrcCopy raster-op.
*/
void MtdsTest24() {
   HDS  hdsDisp;
   HDS  hdsTest;
   HBMP hbmpTest;

   /* We are drawing on the display and onto a color off-screen bitmap. Get the
   ** two DS objects we will use, create the off-screen bitmap and set it as the
   ** drawing surface for the DS we will use for drawing onto it.
   */
   hdsDisp  = mtds.GetDisplayDs();
   hdsTest  = mtds.GetDs();
   hbmpTest = mtds.CreateBitmap(40, 40, 16);
   if (hbmpTest == 0) {
      xil_printf("MtdsTest24: CreateBitmap failed\n\r");
   }
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Initialize for drawing onto the off-screen bitmap
   */
   mtds.SetDrwRop(hdsTest, drwCopyPen);
   mtds.SetPen(hdsTest, penSolid);

   /* Draw a pattern onto the off-screen bitmap. In this case, we draw a red
   ** square with a bunch of green radial lines going from the center of the
   ** square out to the edges.
   */
   mtds.SetFgColor(hdsTest, clrGreen);
   for (int xco = 0; xco < 40; xco += 5) {
      mtds.MoveTo(hdsTest, 20, 20);
      mtds.LineTo(hdsTest, xco, 0);
      mtds.MoveTo(hdsTest, 20, 20);
      mtds.LineTo(hdsTest, xco, 39);
   }
   for (int yco = 0; yco < 40; yco += 5) {
      mtds.MoveTo(hdsTest, 20, 20);
      mtds.LineTo(hdsTest, 0, yco);
      mtds.MoveTo(hdsTest, 20, 20);
      mtds.LineTo(hdsTest, 39, yco);
   }

   mtds.SetFgColor(hdsTest, clrRed);
   mtds.MoveTo(hdsTest, 0, 0);
   mtds.LineTo(hdsTest, 39, 0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.LineTo(hdsTest, 0, 39);
   mtds.LineTo(hdsTest, 0, 0);

   /* Now that we have drawn the pattern into the off-screen bitmap, copy it to
   ** the display multiple times using DrawBitmap().
   */
   mtds.DrawBitmap(hdsDisp,  10,  10, 40, 40, hdsTest, 0, 0);
   mtds.DrawBitmap(hdsDisp, 100,  10, 40, 40, hdsTest, 0, 0);
   mtds.DrawBitmap(hdsDisp, 190,  10, 40, 40, hdsTest, 0, 0);
   mtds.DrawBitmap(hdsDisp,  10, 140, 40, 40, hdsTest, 0, 0);
   mtds.DrawBitmap(hdsDisp, 100, 140, 40, 40, hdsTest, 0, 0);
   mtds.DrawBitmap(hdsDisp, 190, 140, 40, 40, hdsTest, 0, 0);
   mtds.DrawBitmap(hdsDisp,  10, 270, 40, 40, hdsTest, 0, 0);
   mtds.DrawBitmap(hdsDisp, 100, 270, 40, 40, hdsTest, 0, 0);
   mtds.DrawBitmap(hdsDisp, 190, 270, 40, 40, hdsTest, 0, 0);

   /* Free the resources that we used before we return so that the memory
   ** doesn't get lost.
   */
   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);
}

/* ------------------------------------------------------------ */
/*** MtdsTest25()
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
**      This demonstration illustrates the use of BitBlt() to copy pixels from a
**      color bitmap to a monochrome bitmap and then back to the color bitmap.
**      Essentially, this illustrates the color conversion that occurs when
**      copying between bitmaps with different color formats.
*/
void MtdsTest25() {
   HDS  hdsDisp;
   HDS  hdsTest;
   HBMP hbmpTest;

   /* We're going to be drawing onto the display and onto a monochrome
   ** off-screen bitmap. Get the two DS objects that we are going to use, create
   ** the off-screen bitmap and set up one DS for drawing onto it. Note that a
   ** monochrome bitmap has a single bit per pixel, so we specify a color format
   ** of 1 when we create it.
   */
   hdsDisp  = mtds.GetDisplayDs();
   hdsTest  = mtds.GetDs();
   hbmpTest = mtds.CreateBitmap(40, 40, 1);
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Init the DS for drawing onto the display. In this case, we are not setting
   ** the background color. It defaults to clrBlack, so we will be getting black
   ** as the background color.
   */
   mtds.SetDrwRop(hdsDisp, drwCopyPen);
   mtds.SetPen(hdsDisp, penSolid);

   /* Draw the test pattern at the center of the display. This pattern is a pair
   ** of green diagonal lines inside a red square.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);
   mtds.MoveTo(hdsDisp, 100, 140);
   mtds.LineTo(hdsDisp, 139, 179);
   mtds.MoveTo(hdsDisp, 139, 140);
   mtds.LineTo(hdsDisp, 100, 179);

   mtds.SetFgColor(hdsDisp, clrRed);
   mtds.MoveTo(hdsDisp, 100, 140);
   mtds.LineTo(hdsDisp, 139, 140);
   mtds.LineTo(hdsDisp, 139, 179);
   mtds.LineTo(hdsDisp, 100, 179);
   mtds.LineTo(hdsDisp, 100, 139);

   /* Now, use BitBlt() to copy the pattern from the center of the display to
   ** the off-screen bitmap. When doing a BitBlt() from a color bitmap to a
   ** monochrome bitmap, pixels in the source that match the background color
   ** are copied as a 0 bit, pixels in the source that don't match the
   ** background color are copied as a 1 bit. The background color that is used
   ** is the one set in the destination DS. In this case, the destination DS is
   ** the one for the off-screen bitmap. The background color in this DS was
   ** never set, so it defaults to clrBlack. So, in this case, pixels in the
   ** source that are black get copied as 0, and pixels that are not black get
   ** copied as 1.
   */
   mtds.BitBlt(hdsTest, 0, 0, 40, 40, hdsDisp, 100, 140, ropSrcCopy);

   /* We are now going to use BitBlt() to copy from the monochrome off-screen
   ** bitmap back to the display. This will cause a color conversion from
   ** monochrome back to color. When copying from a monochrome bitmap to a color
   ** bitmap, pixels in the monochrome bitmap that are 0 are copied as the
   ** background color and pixels that are 1 are copied as the foreground color.
   ** Here, we are setting the foreground color to white and the background
   ** color to dark red. The result will be a white pattern on a dark red
   ** background.
   */
   mtds.SetFgColor(hdsDisp, clrWhite);
   mtds.SetBgColor(hdsDisp, clrDkRed);

   /* Copy the pattern multiple time from the off-screen bitmap onto the
   ** display.
   */
   mtds.BitBlt(hdsDisp,  10,  10, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  10, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  10, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  10, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   /* This would copy the off-screen bitmap over the original pattern drawn onto
   ** the display. It is commented out so that the original pattern can be seen.
   */
   //mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  10, 270, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 270, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 270, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   /* Free all of the resource used before we leave so that the memory isn't
   ** lost.
   */
   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsTest);
   mtds.ReleaseDs(hdsDisp);
}

/* ------------------------------------------------------------ */
/*** MtdsTest26()
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
**      This demonstration illustrates drawing onto a monochrome off-screen
**      bitmap and then using BitBlt() to copy the result onto the display.
*/
void MtdsTest26() {
   HDS     hdsDisp;
   HDS     hdsTest;
   HBMP    hbmpTest;
   int16_t co;

   /* Get the DS for drawing on the display.
   */
   hdsDisp = mtds.GetDisplayDs();
  
   /* Get the DS for drawing onto the off-screen bitmap, create the off-screen
   ** bitmap, and then set it as the drawing surface for the DS. Note that when
   ** we create the bitmap we specify the pixel format as 1 bit per pixel to
   ** make it a monochrome bitmap.
   */
   hdsTest = mtds.GetDs();
   hbmpTest = mtds.CreateBitmap(40, 40, 1);
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Set up the drawing parameters in the DS for drawing on the off-screen
   ** bitmap. When drawing on a monochrome bitmap, the foreground color should
   ** be white and the background color should be black. The calls to SetDrwRop,
   ** SetPen, and SetFgColor here are actually redundant as the values being set
   ** are the same as the default values set in a DS when it is first obtained.
   */
   mtds.SetDrwRop(hdsTest, drwCopyPen);
   mtds.SetPen(hdsTest, penSolid);
   mtds.SetFgColor(hdsTest, clrWhite);

   /* Draw the graphical pattern on the monochrome bitmap. This draws a square
   ** and a series of radial lines from the center of the square around the
   ** edges. Note that the method is exactly the same as it would be if we were
   ** drawing onto the display or onto a color bitmap.
   */
   for (co = 0; co < 40; co += 5) {
      mtds.MoveTo(hdsTest, 19, 19);
      mtds.LineTo(hdsTest, co,  0);
      mtds.MoveTo(hdsTest, 19, 19);
      mtds.LineTo(hdsTest, co, 39);
      mtds.MoveTo(hdsTest, 19, 19);
      mtds.LineTo(hdsTest,  0, co);
      mtds.MoveTo(hdsTest, 19, 19);
      mtds.LineTo(hdsTest, 39, co);
   }

   mtds.MoveTo(hdsTest,  0,  0);
   mtds.LineTo(hdsTest, 39,  0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.LineTo(hdsTest,  0, 39);
   mtds.LineTo(hdsTest,  0,  0);

   /* Set up for copying from the monochrome bitmap to the display. When using
   ** BitBlt() to copy from a monochrome bitmap to a color bitmap, a color
   ** conversion occurs. Pixels in the monochrome bitmap that are 0 are copied
   ** as the background color and pixels that are 1 are copied as the foreground
   ** color. The foreground color is set to green. Since the background color
   ** defaults to black and isn't being set, we will get a green pattern on a
   ** black background. When doing a BitBlt() from one color format to another,
   ** the color conversion is done first, and then the raster-op function is
   ** applied.
   */
   mtds.SetFgColor(hdsDisp, clrGreen);

   /* Copy the monochrome bitmap onto the display, tiling the surface.
   */
   mtds.BitBlt(hdsDisp,  10,   5, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,   5, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,   5, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,   5, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,   5, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  50, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  50, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  50, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  50, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  50, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  95, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  95, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  95, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  95, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  95, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 185, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 185, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 185, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 185, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 185, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 230, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 230, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 230, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 230, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 230, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 275, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 275, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 275, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 275, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 275, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   /* Free all of the resources used before we leave so that the memory isn't
   ** lost.
   */
   mtds.DestroyBitmap(hbmpTest);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);
}
