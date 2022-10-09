/******************************************************************************/
/*                                                                            */
/* MtdsDemo3.cc -- MTDS Library Reference Example 3                           */
/*                                                                            */
/******************************************************************************/
/* Author: Gene Apperson                                                      */
/* Copyright 2015, Digilent Inc. All rights reserved.                         */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This program demonstrates using the MTDS library to load bitmaps from an   */
/* SD card and then rendering them on the display. In order for this sketch   */
/* to work correctly, the following bitmaps need to be placed on the SD card. */
/* These bitmaps are in the Resources directory where the example programs    */
/* were obtained. They should all be placed in a folder called Images on the  */
/* SD card.                                                                   */
/*                                                                            */
/* Bitmaps files used:                                                        */
/*    Images/IMG_0001.BMP - Resources folder or created by running MtdsDemo2  */
/*    Images/IMG_0002.BMP - Resources folder or created by running MtdsDemo2  */
/*    Images/IMG_0098.BMP - Resources folder or created by running MtdsDemo2  */
/*    Images/IMG_0099.BMP - Resources folder or created by running MtdsDemo2  */
/*    Images/IMG_0010.BMP - in the Resources folder                           */
/*    Images/IMG_0011.BMP - in the Resources folder                           */
/*    Images/IMG_0100.BMP - in the Resources folder                           */
/*    Images/IMG_0101.BMP - in the Resources folder                           */
/*    Images/IMG_0102.BMP - in the Resources folder                           */
/*    Images/IMG_LOGO.BMP - in the Resources folder                           */
/*                                                                            */
/* IMG_0010 is a 24-bit per pixel image created using Microsoft Windows Paint */
/* IMG_0011 is an 8-bit per pixel image created using Microsoft Windows Paint */
/* IMG_0100 is a 16-bit per pixel image created using Adobe Photoshop         */
/* IMG_0101 is a 24-bit per pixel image created using Adobe Photoshop         */
/* IMG_0102 is a 32-bit per pixel image created using Adobe Photoshop         */
/* IMG_LOGO is a 24-bit per pixel rendering from a 3D CAD tool                */
/*                                                                            */
/* This program contains several test functions that each demonstrate the use */
/* of one or more features of the MTDS system. The basic use of the graphics  */
/* functions in the MTDS library are explained in MtdsDemo1. It is assumed    */
/* that the user will have worked through MtdsDemo1 prior to working through  */
/* this example. Because of this, basic operation of the MTDS library is not  */
/* explained here. Only the new features not previously covered in MtdsDemo1  */
/* are covered in detail here.                                                */
/*                                                                            */
/* This program also makes use of bitmap files created by MtdsDemo2. The user */
/* should be familiar with the operation of MtdsDemo2 as well.                */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    09/30/2016(GeneA):    Created                                           */
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

#define TEST_CLIP

/* ------------------------------------------------------------ */
/*                Global Variables                              */
/* ------------------------------------------------------------ */

int itstCur = 1;

/* ------------------------------------------------------------ */
/*                Local Variables                               */
/* ------------------------------------------------------------ */

int itstMax = 7;

/* ------------------------------------------------------------ */
/*                Forward Declarations                          */
/* ------------------------------------------------------------ */

bool MtdsTestFs1();
bool MtdsTestFs2();
bool MtdsTestFs3();
bool MtdsTestFs4();
bool MtdsTestFs5();
bool MtdsTestFs6();
bool MtdsTestFs7();

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
      fStat = mtds.begin(pinMtdsSelStd, 12000000);
      if (fStat) {
         xil_printf("mtds.begin() succeeded\n\r");
         break;
      }
      else {
         xil_printf("mtds.begin() failed\n\r");
         sleep(1);
      }
   }

   /* Mount the file system on the SD card. This entire demo involves reading
    ** from the SD card, so if it doesn't mount successfully, there is not point
    ** in continuing.
    */
   while (true) {
      if (mtfs.MountFs(true, true)) {
         xil_printf("mtds.MountFs() succeeded\n\r");
         break;
      }
      else {
         xil_printf("mtds.MountFs() failed\n\r");
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

   switch (itstCur) {
   case 1:
      if (!MtdsTestFs1()) {
         while (true);
      }
      break;

   case 2:
      if (!MtdsTestFs2()) {
         while (true);
      }
      break;

   case 3:
      if (!MtdsTestFs3()) {
         while (true);
      }
      break;

   case 4:
      if (!MtdsTestFs4()) {
         while (true);
      }
      break;

   case 5:
      if (!MtdsTestFs5()) {
         while (true);
      }
      break;

   case 6:
      if (!MtdsTestFs6()) {
         while (true);
      }
      break;

   case 7:
      if (!MtdsTestFs7()) {
         while (true);
      }
      break;
   }
   itstCur += 1;
   if (itstCur > itstMax) {
      itstCur = 1;
   }
   sleep(3);
}

/* ------------------------------------------------------------ */
/*                GDI Test Functions                            */
/* ------------------------------------------------------------ */

/*** MtdsTestFs1()
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
**      This function illustrates loading a device independent bitmap into
**      memory and then copying it to the display.
*/
bool MtdsTestFs1() {
   HDS  hdsDisp;
   HDS  hdsTest1;
   HBMP hbmpLoad1;
   char szFile1[] = "Images/IMG_0001.bmp";

   /* Get the DS for drawing on the display.
   */
   hdsDisp = mtds.GetDisplayDs();

   /* Get a second DS to be used with the off-screen bitmap.
   */
   hdsTest1 = mtds.GetDs();

   /* Load the bitmap file into memory and then set the resulting bitmap as the
   ** drawing surface for the DS.
   */
   hbmpLoad1 = mtds.LoadBitmap(szFile1);
   if (hbmpLoad1 == 0) {
      xil_printf("Error loading IMG_0001.bmp\n\r");
      return false;
   }
   mtds.SetDrawingSurface(hdsTest1, hbmpLoad1);

   /* Copy the bitmap loaded from the SD card onto the display. We tile the
   ** display with this bitmap. Note: we are assuming the dimensions of the
   ** bitmap here. As this bitmap was created by a sketch that we wrote and we
   ** "know" its dimensions, this is OK, even though this is not strictly good
   ** programming practice. If we are wrong, and the bitmap that we got isn't
   ** really the one created by MtdsDemo2, nothing bad will happen. If the
   ** bitmap is smaller than we are assuming, BitBlt() will clip the amount
   ** copied down to the actual size of the bitmap. If the bitmap is larger than
   ** what we are expecting, we will just get the upper left-hand corner of
   ** whatever the total bitmap contains. If the bitmap isn't the one we
   ** expected, nothing bad will happen, but we also won't get the expected
   ** result.
   */
   mtds.BitBlt(hdsDisp,  10,   5, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,   5, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,   5, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,   5, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,   5, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  95, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  95, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  95, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  95, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  95, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 185, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 185, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 185, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 185, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 185, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 275, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 275, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 275, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 275, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 275, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   /* Free all resources used before we return so that the memory isn't lost to
   ** the system.
   */
   mtds.DestroyBitmap(hbmpLoad1);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest1);

   return true;
}

/* ------------------------------------------------------------ */
/*** MtdsTestFs2()
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
**      This function loads a bitmap in memory from a device independent bitmap
**      file on the SD card and then copies it to the display. It is essentially
**      identical to the function MtdsTestFs1() except that it uses a different
**      bitmap file.
*/
bool MtdsTestFs2() {
   HDS  hdsDisp;
   HDS  hdsTest2;
   HBMP hbmpLoad2;
   char szFile2[] = "Images/IMG_0002.bmp";

   hdsDisp  = mtds.GetDisplayDs();
   hdsTest2 = mtds.GetDs();

   hbmpLoad2 = mtds.LoadBitmap(szFile2);
   if (hbmpLoad2 == 0) {
      xil_printf("Error loading IMG_0002.bmp\n\r");
      return false;
   }
   mtds.SetDrawingSurface(hdsTest2, hbmpLoad2);

   mtds.BitBlt(hdsDisp,  10,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  50, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  50, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  50, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  50, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  50, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 140, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 140, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 140, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 140, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 230, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 230, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 230, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 230, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 230, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.DestroyBitmap(hbmpLoad2);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest2);
  
   return true;
}

/* ------------------------------------------------------------ */
/*** MtdsTestFs3()
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
**      This function loads two bitmaps into memory from device independent
**      bitmap files on the SD card and then copies them to the display. It is
**      essentially identical to the function MtdsTestFs1() except that it loads
**      two bitmaps into memory and copies both to the display.
*/
bool MtdsTestFs3() {
   HDS  hdsDisp;
   HDS  hdsTest1;
   HDS  hdsTest2;
   HBMP hbmpLoad1;
   HBMP hbmpLoad2;
   char szFile1[] = "Images/IMG_0001.bmp";
   char szFile2[] = "Images/IMG_0002.bmp";

   hdsDisp  = mtds.GetDisplayDs();
   hdsTest1 = mtds.GetDs();
   hdsTest2 = mtds.GetDs();

   hbmpLoad1 = mtds.LoadBitmap(szFile1);
   if (hbmpLoad1 == 0) {
      xil_printf("Error loading IMG_0001.bmp\n\r");
      return false;
   }
   mtds.SetDrawingSurface(hdsTest1, hbmpLoad1);
  
   hbmpLoad2 = mtds.LoadBitmap(szFile2);
   if (hbmpLoad2 == 0) {
      xil_printf("Error loading IMG_0002.bmp\n\r");
      return false;
   }
   mtds.SetDrawingSurface(hdsTest2, hbmpLoad2);

   mtds.BitBlt(hdsDisp,  10,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,   5, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,   5, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  50, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  50, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  95, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  95, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 140, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 140, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 185, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 185, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 230, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 230, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 275, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 275, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.DestroyBitmap(hbmpLoad1);
   mtds.DestroyBitmap(hbmpLoad2);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest1);
   mtds.ReleaseDs(hdsTest2);

   return true;
}

/* ------------------------------------------------------------ */
/*** MtdsTestFs4()
**
**   Parameters:
**      none
**
**   Return Values:
**      True or false reflecting function success
**
**   Errors:
**      none
**
**   Description:
**      This function loads two bitmaps into memory from device independent
**      bitmap files on the SD card and then copies them to the display. It is
**      essentially identical to the function MtdsTestFs3() except for how the
**      bitmap files were created. In this case the two bitmap files are the
**      ones that MtdsDemo2 created by copying the files using the file system
**      API functions.
*/
bool MtdsTestFs4() {
   HDS  hdsDisp;
   HDS  hdsTest1;
   HDS  hdsTest2;
   HBMP hbmpLoad1;
   HBMP hbmpLoad2;
   char szFile1[] = "Images/IMG_0099.bmp";
   char szFile2[] = "Images/IMG_0098.bmp";

   hdsDisp  = mtds.GetDisplayDs();
   hdsTest1 = mtds.GetDs();
   hdsTest2 = mtds.GetDs();

   hbmpLoad1 = mtds.LoadBitmap(szFile1);
   if (hbmpLoad1 == 0) {
      xil_printf("Error loading IMG_0099.bmp\n\r");
      return false;
   }
   mtds.SetDrawingSurface(hdsTest1, hbmpLoad1);

   hbmpLoad2 = mtds.LoadBitmap(szFile2);
   if (hbmpLoad2 == 0) {
      xil_printf("Error loading IMG_0098.bmp\n\r");
      return false;
   }
   mtds.SetDrawingSurface(hdsTest2, hbmpLoad2);

   mtds.BitBlt(hdsDisp,  10,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,   5, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,   5, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,   5, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  50, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  50, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  50, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55,  95, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145,  95, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190,  95, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 140, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 140, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 140, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 185, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 185, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 185, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 230, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 230, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 230, 40, 40, hdsTest1, 0, 0, ropSrcCopy);

   mtds.BitBlt(hdsDisp,  10, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp,  55, 275, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 100, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 145, 275, 40, 40, hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 190, 275, 40, 40, hdsTest2, 0, 0, ropSrcCopy);

   mtds.DestroyBitmap(hbmpLoad1);
   mtds.DestroyBitmap(hbmpLoad2);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest1);
   mtds.ReleaseDs(hdsTest2);

   return true;
}

/* ------------------------------------------------------------ */
/*** MtdsTestFs5()
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
**      This function loads two bitmaps into memory from device independent
**      bitmap files on the SD card and then copies them to the display. The
**      things that distinguish this function from the previous ones is how the
**      bitmaps were created and what their format is, and that no assumptions
**      are made about their size. This illustrates using GetBitmapDimesions()
**      to determine the size of a bitmap in memory.
**
**      The images loaded in the previous examples were either created and saved
**      by the MTDS system, or copied from one of those files. They are 16-bit
**      per pixel images saved using the internal 5:6:5 color format.
**
**      The bitmap file IMG_0010.BMP was created using the Microsoft Windows
**      Paint program. It is a 16-bit per pixel image stored in the default
**      5:5:5 color format.
**
**      The bitmap file IMG_0011.BMP was also created using Windows Paint. It is
**      an 8-bit per pixel image with a color mapping table.
**
**      The main point of this is to illustrate that the DIB loader in the MTDS
**      display device firmware can handle these DIB formats. The loading of the
**      bitmaps into memory and copying them to the display is the same as was
**      illustrated in the previous examples.
*/
bool MtdsTestFs5() {
   HDS  hdsDisp;
   HDS  hdsTest1;
   HDS  hdsTest2;
   HBMP hbmpLoad1;
   HBMP hbmpLoad2;
   BMPD bmpd1;
   BMPD bmpd2;
   int16_t ycoCur;

   /* Get the DS objects that we are going to need. One for drawing on the
   ** display and the other two for the off-screen bitmaps that we are going to
   ** be using.
   */
   hdsDisp  = mtds.GetDisplayDs();
   hdsTest1 = mtds.GetDs();
   hdsTest2 = mtds.GetDs();

   /* Load the first bitmap into memory. Here, we are assuming that we know
   ** nothing about the bitmap that was loaded. We call GetBitmapDimensions() to
   ** learn what its size is and what its color format is.
   */
   hbmpLoad1 = mtds.LoadBitmap((char*) "Images/IMG_0010.bmp");
   mtds.GetBitmapDimensions(hbmpLoad1, &bmpd1);
   mtds.SetDrawingSurface(hdsTest1, hbmpLoad1);

   /* Load the second bitmap and gets its dimensions.
   */
   hbmpLoad2 = mtds.LoadBitmap((char*) "Images/IMG_0011.bmp");
   mtds.GetBitmapDimensions(hbmpLoad2, &bmpd2);
   mtds.SetDrawingSurface(hdsTest2, hbmpLoad2);

   /* Now we're going to use BitBlt() to copy the bitmaps to the display. Note
   ** here, that rather than having hard coded dimensions for the width and
   ** height of the bitmaps, we are using the widths and heights that we
   ** obtained by calling GetBitmapDimensions().
   */
   ycoCur = 10;
   mtds.BitBlt(hdsDisp, 10,  ycoCur, bmpd1.dxco, bmpd1.dyco, hdsTest1, 0, 0,
         ropSrcCopy);
   mtds.BitBlt(hdsDisp, 120 - bmpd1.dxco / 2, ycoCur, bmpd1.dxco, bmpd1.dyco,
         hdsTest1, 0, 0, ropSrcCopy);
   mtds.BitBlt(hdsDisp, 229 - bmpd1.dxco, ycoCur, bmpd1.dxco, bmpd1.dyco,
         hdsTest1, 0, 0, ropSrcCopy);
  
   ycoCur += bmpd1.dyco + 10;
   mtds.BitBlt(hdsDisp, 10, ycoCur, bmpd2.dxco, bmpd2.dyco, hdsTest2, 0, 0,
         ropSrcCopy);
   mtds.BitBlt(hdsDisp, 229 - bmpd2.dxco, ycoCur, bmpd2.dxco, bmpd2.dyco,
         hdsTest2, 0, 0, ropSrcCopy);

   /* Free all of the resources used before we return so that the memory isn't
   ** lost to the system.
   */
   mtds.DestroyBitmap(hbmpLoad1);
   mtds.DestroyBitmap(hbmpLoad2);
   mtds.ReleaseDs(hdsTest1);
   mtds.ReleaseDs(hdsTest2);
   mtds.ReleaseDs(hdsDisp);

   return true;
}

/* ------------------------------------------------------------ */
/*** MtdsTestFs6()
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
**      This example illustrates loading bitmaps into memory from files on the
**      SD card and then copying them onto the display. This is similar to the
**      previous examples in this sketch. The differences here are:
**         1) How the bitmaps were created and what their pixel formats are
**         2) Demonstrating reuse of a single DS to copy multiple bitmaps to the
**            display.
**
**      The three bitmap files were created using Adobe Photoshop.
**         - IMG_0100.BMP is a 16-bit per pixel image in the default DIB 5:5:5
**                        color format.
**         - IMG_0101.BMP is a 24-bit per pixel image.
**         - IMG_0102.BMP is a 32-bit per pixel image.
**      In all cases, when a color DIB is loaded into memory, it is converted
**      into a 16-bit per pixel bitmap in the internal 5:6:5 color format.
*/
bool MtdsTestFs6() {
   HDS  hdsDisp;
   HDS  hdsTest;
   HBMP hbmpLoad1;
   HBMP hbmpLoad2;
   HBMP hbmpLoad3;
   BMPD bmpd1;
   BMPD bmpd2;
   BMPD bmpd3;
   int16_t ycoCur;

   /* Get the DS objects that we are going to need. One for drawing on the
   ** display and one for the off-screen bitmaps that we are going to be using.
   ** Note, in many previous examples, we have gotten a separate DS to use for
   ** each off-screen bitmap. This example shows reuse of a single DS. In this
   ** case, we call SetDrawingSurface() to select each bitmap into the DS just
   ** before calling BitBlt().
   */
   hdsDisp = mtds.GetDisplayDs();
   hdsTest = mtds.GetDs();

   /* Load the bitmaps into memory and get their dimensions.
   */
   hbmpLoad1 = mtds.LoadBitmap((char*) "Images/IMG_0100.bmp");
   mtds.GetBitmapDimensions(hbmpLoad1, &bmpd1);

   hbmpLoad2 = mtds.LoadBitmap((char*) "Images/IMG_0101.bmp");
   mtds.GetBitmapDimensions(hbmpLoad2, &bmpd2);

   hbmpLoad3 = mtds.LoadBitmap((char*) "Images/IMG_0102.bmp");
   mtds.GetBitmapDimensions(hbmpLoad3, &bmpd3);

   /* Copy the bitmaps to the display. Since we are using a single DS to copy all
   ** three bitmaps, we need to select each into the DS as the drawing surface before
   ** we call BitBlt() to copy them.
   */
   ycoCur = 10;
   mtds.SetDrawingSurface(hdsTest, hbmpLoad1);
   mtds.BitBlt(hdsDisp, 120 - bmpd1.dxco / 2, ycoCur, bmpd1.dxco, bmpd1.dyco,
         hdsTest, 0, 0, ropSrcCopy);

   ycoCur += bmpd1.dyco + 10;
   mtds.SetDrawingSurface(hdsTest, hbmpLoad2);
   mtds.BitBlt(hdsDisp, 120 - bmpd2.dxco / 2, ycoCur, bmpd2.dxco, bmpd2.dyco,
         hdsTest, 0, 0, ropSrcCopy);

   ycoCur += bmpd1.dyco + 10;
   mtds.SetDrawingSurface(hdsTest, hbmpLoad3);
   mtds.BitBlt(hdsDisp, 120 - bmpd3.dxco / 2, ycoCur, bmpd3.dxco, bmpd3.dyco,
         hdsTest, 0, 0, ropSrcCopy);

   /* Free all of the resources used before we return so that the memory isn't
   ** lost to the system.
   */
   mtds.DestroyBitmap(hbmpLoad1);
   mtds.DestroyBitmap(hbmpLoad2);
   mtds.DestroyBitmap(hbmpLoad3);
   mtds.ReleaseDs(hdsTest);
   mtds.ReleaseDs(hdsDisp);

   return true;
}

/* ------------------------------------------------------------ */
/*** MtdsTestFs7()
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
**      This example illustrates loading a bitmap into memory from a device
**      independent bitmap file and copying it to the display using BitBlt().
**      The difference in this case is that the bitmap file contains a bitmap
**      the full size of the display. The bitmap dimensions are assumed, as it
**      was created as a 240x320 pixel image. This also illustrates using the
**      timing functions to determine how long it took to load the bitmap file
**      into memory and how long it took to copy it to the display.
*/
bool MtdsTestFs7() {
   HDS  hdsDisp;
   HDS  hdsTest1;
   HBMP hbmpLoad1;
   //BMPD bmpd1;
   int16_t  xcoCur;
   int16_t  ycoCur;
   uint32_t tusLoad;
   uint32_t tusCopy;

   /* Get the DS objects that we are going to use.
   */
   hdsDisp = mtds.GetDisplayDs();
   hdsTest1 = mtds.GetDs();

   /* Load the bitmap into memory.
   */
   hbmpLoad1 = mtds.LoadBitmap((char*) "Images/IMG_LOGO.bmp");
   tusLoad = mtds.GetElapsedTime();
   mtds.SetDrawingSurface(hdsTest1, hbmpLoad1);

   xcoCur = 0;
   ycoCur = 0;
   mtds.BitBlt(hdsDisp, xcoCur, ycoCur, 240, 320, hdsTest1, 0, 0, ropSrcCopy);
   tusCopy = mtds.GetElapsedTime();
  
   /* Print the load time and the copy time to the serial monitor window.
   */
   xil_printf("MtdsTestFs7 -----\n\r");
   xil_printf("Load time = ");
   xil_printf("%d", tusLoad);
   xil_printf(" microseconds\n\r");
   xil_printf("BitBlt time = ");
   xil_printf("%d", tusCopy);
   xil_printf(" microseconds\n\r");
   xil_printf("--------\n\r");

   /* Free all of the resources used before we return so that the memory isn't
   ** lost to the system.
   */
   mtds.DestroyBitmap(hbmpLoad1);
   mtds.ReleaseDs(hdsTest1);
   mtds.ReleaseDs(hdsDisp);

   return true;
}
