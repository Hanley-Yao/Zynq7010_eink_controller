/******************************************************************************/
/*                                                                            */
/* MtdsDemo2.cc -- MTDS Library Reference Example 2                           */
/*                                                                            */
/******************************************************************************/
/* Author: Gene Apperson                                                      */
/* Copyright 2016, Digilent Inc. All rights reserved.                         */
/******************************************************************************/
/* Module Description:                                                        */
/*                                                                            */
/* This program demonstrates using the MTDS library to render graphics onto   */
/* the display and saving and loading bitmaps to and from files on an SD      */
/* card. It also demonstrates using some of the file system API functions to  */
/* read and write files on the SD card.                                       */
/*                                                                            */
/* This program contains several test functions that each demonstrate the use */
/* of one or more features of the MTDS system. The basic use of the graphics  */
/* functions in the MTDS library are explained in MtdsDemo1. It is assumed    */
/* that the user will have worked through MtdsDemo1 prior to working through  */
/* this example. Because of this, basic operation of the MTDS library is not  */
/* explained here. Only the new features not previously covered in MtdsDemo1  */
/* are covered in detail here.                                                */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    09/29/2016(GeneA):    Created                                           */
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

/* ------------------------------------------------------------ */
/*                Global Variables                              */
/* ------------------------------------------------------------ */

int itstCur = 1;

bool fWriteTest1;
bool fWriteTest2;

/* ------------------------------------------------------------ */
/*                Local Variables                               */
/* ------------------------------------------------------------ */

int itstMax = 2;

/* ------------------------------------------------------------ */
/*                Forward Declarations                          */
/* ------------------------------------------------------------ */

bool MtdsTestFs1();
bool MtdsTestFs2();

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
   DTM  dtmSet;

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

   /* Mount the file system. We are going to be writing a couple of files to the
   ** SD card, so we must have the file system successfully mounted or we can't
   ** proceed to the rest of the example.
   */
   if (mtfs.MountFs(true, true)) {
      xil_printf("mtds.MountFs() succeeded\n\r");
   }
   else {
      xil_printf("mtds.MountFs() failed\n\r");
      /* Mount failed, so lock up rather than run on to the rest of the demo.
      */
      while (true);
   }

   fWriteTest1 = true;
   fWriteTest2 = true;

   /* The file system code uses the real time clock to set the date and time
   ** stamps on the files that it writes. There is a simple software-maintained
   ** real time clock in the display board, but it isn't able to maintain the
   ** time when it is not powered. Each time the display board resets, the date
   ** and time get set to midnight, January 1, 2016 . Here we are setting it to
   ** a different time. Just for the purpose of the example, it is being set to
   ** approximately the time when this demo program was written.
   */
   dtmSet.sec   = 0;
   dtmSet.min   = 50;
   dtmSet.hour  = 13;
   dtmSet.day   = 29;
   dtmSet.month = 9;
   dtmSet.year  = 2016;
   mtds.SetDateTime(&dtmSet);
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
**      This demo illustrates drawing onto an off-screen bitmap and then using
**      the SaveBitmap() function to write the off-screen bitmap to a file on
**      the SD card.
*/
bool MtdsTestFs1() {
   HDS  hdsDisp;
   HDS  hdsTest;
   HBMP hbmpTest;
   HBMP hbmpLoad1;
   HBMP hbmpLoad2;
   char szFile1[] = "Images/IMG_0001.bmp";
   char szFile2[] = "Images/IMG_0002.bmp";
   RCT rctFrame   = { 0, 0, 39, 39 };

   /* Get the DS for drawing onto the display.
   */
   hdsDisp = mtds.GetDisplayDs();
  
   /* Get another DS and set up for drawing onto an off-screen bitmap.
   */
   hdsTest  = mtds.GetDs();
   hbmpTest = mtds.CreateBitmap(40, 40, 16);
   mtds.SetDrawingSurface(hdsTest, hbmpTest);

   /* Draw a test pattern into the off-screen bitmap. Note here that we are
   ** using the drwXorPen drawing mode. This causes the colors to be XOR'd
   ** wherever the lines being drawn cross or overlap.
   */
   mtds.SetDrwRop(hdsTest, drwXorPen);
   mtds.SetPen(hdsTest, penSolid);

   mtds.SetFgColor(hdsTest, clrGreen);
   mtds.MoveTo(hdsTest, 19,  9);
   mtds.LineTo(hdsTest, 29,  0);
   mtds.LineTo(hdsTest, 29,  9);
   mtds.LineTo(hdsTest, 39,  9);
   mtds.LineTo(hdsTest, 29, 19);
   mtds.LineTo(hdsTest, 39, 29);
   mtds.LineTo(hdsTest, 29, 29);
   mtds.LineTo(hdsTest, 29, 39);
   mtds.LineTo(hdsTest, 19, 29);
   mtds.LineTo(hdsTest,  9, 39);
   mtds.LineTo(hdsTest,  9, 29);
   mtds.LineTo(hdsTest,  0, 29);
   mtds.LineTo(hdsTest,  9, 19);
   mtds.LineTo(hdsTest,  0,  9);
   mtds.LineTo(hdsTest,  9,  9);
   mtds.LineTo(hdsTest,  9,  0);
   mtds.LineTo(hdsTest, 19,  9);

   mtds.SetFgColor(hdsTest, clrYellow);
   mtds.MoveTo(hdsTest,  9,  9);
   mtds.LineTo(hdsTest, 29, 29);
   mtds.MoveTo(hdsTest, 29,  9);
   mtds.LineTo(hdsTest,  9, 29);

   mtds.SetFgColor(hdsTest, clrRed);
   mtds.MoveTo(hdsTest, 19,  9);
   mtds.LineTo(hdsTest, 29, 19);
   mtds.LineTo(hdsTest, 19, 29);
   mtds.LineTo(hdsTest,  9, 19);
   mtds.LineTo(hdsTest, 19,  9);

   /* Now that we have drawn the test pattern onto the off-screen bitmap, copy
   ** it onto the display so that we can see it.
   */
   mtds.BitBlt(hdsDisp, 10, 5, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   /* Here, we come to the main purpose of this demo function. The StoreBitmap()
   ** function writes the off-screen bitmap to a file on the SD card in device
   ** independent bitmap format.
   **
   ** In order to reduce wear on the SD card, we only write the bitmap to the SD
   ** card the first time this function is called. Each subsequent time we get
   ** called, we only draw the test pattern on the off-screen bitmap and then
   ** copy it to the display.
   */
   if (fWriteTest1) {
      if (!mtds.StoreBitmap(szFile1, hbmpTest)) {
         xil_printf("StoreBitmap failed on Img_0001.bmp\n\r");
         fWriteTest1 = false;
         return false;
      }
   }
  
   /* Now that we have written the bitmap to a file, we're going to clear the
   ** off-screen bitmap, draw a new test pattern and then save that bitmap to a
   ** different file.
   */
   mtds.FillRect(hdsTest, &rctFrame, hbrBlack);

   mtds.SetFgColor(hdsTest, clrGreen);
   mtds.MoveTo(hdsTest,  0,  0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.MoveTo(hdsTest, 39,  0);
   mtds.LineTo(hdsTest,  0, 39);

   mtds.SetFgColor(hdsTest, clrRed);
   mtds.MoveTo(hdsTest,  0,  0);
   mtds.LineTo(hdsTest, 39,  0);
   mtds.LineTo(hdsTest, 39, 39);
   mtds.LineTo(hdsTest,  0, 39);
   mtds.LineTo(hdsTest,  0,  0);

   /* Copy the new test pattern to the display so that we can see it.
   */
   mtds.BitBlt(hdsDisp, 55, 5, 40, 40, hdsTest, 0, 0, ropSrcCopy);

   /* Now, write the off-screen bitmap to the SD card again. Since this is a
   ** new pattern and we don't want to overwrite the previous one, we write it
   ** to a file with a different name.
   */
   if (fWriteTest1) {
      if (!mtds.StoreBitmap(szFile2, hbmpTest)) {
         xil_printf("StoreBitmap failed on Img_0002.bmp\n\r");
         fWriteTest1 = false;
         return false;
      }
   }

   /* Here, we come to the second main point being illustrated in this function.
   ** We are going to use LoadBitmap() to read the bitmap files from the SD card
   ** and then copy them to the display using BitBlt(). LoadBitmap() reads a
   ** device independent bitmap from a file on the SD card. It creates an
   ** off-screen bitmap and then loads the DIB data from the file, converts it
   ** to the internal bitmap format and saves the data into the off-screen
   ** bitmap in memory. We end up with a memory bitmap that is identical to one
   ** created by CreateBitmap() except that is has been initialized with the
   ** image data stored in the DIB file. It can be used in the same way that any
   ** other memory bitmap can be used. It needs to be selected into a DS as the
   ** drawing surface. Once that has been done, it can be drawn on the same as
   ** any other memory bitmap and it can be copied to the display using
   ** BitBlt().
   */
   if ((hbmpLoad1 = mtds.LoadBitmap(szFile1)) != 0) {
      mtds.SetDrawingSurface(hdsTest, hbmpLoad1);
      /* Note here that we are kind of cheating by assuming the dimensions of
      ** the bitmap that was obtained from LoadBitmap(). Since we created it
      ** originally, we can know what the dimensions are and use them. However,
      ** in general it is better practice to call GetBitmapDimensions() on a
      ** bitmap obtained from LoadBitmap(). In many cases, that will be the only
      ** way to determine its size.
      */
      mtds.BitBlt(hdsDisp, 100, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   }
   else {
      xil_printf("LoadBitmap failed on IMG_0001\n\r");
      return false;
   }

   /* Load the second bitmap file that we created above and copy the resulting
   ** bitmap to the display.
   */
   if ((hbmpLoad2 = mtds.LoadBitmap(szFile2)) != 0) {
      mtds.SetDrawingSurface(hdsTest, hbmpLoad2);
      mtds.BitBlt(hdsDisp, 145, 140, 40, 40, hdsTest, 0, 0, ropSrcCopy);
   }
   else {
      xil_printf("LoadBitmap failed on IMG_0002.bmp\n\r");
      return false;
   }

   /* We must free all resources used in this function before we return so that
   ** they aren't lost to the system.
   */
   mtds.DestroyBitmap(hbmpTest);
   mtds.DestroyBitmap(hbmpLoad1);
   mtds.DestroyBitmap(hbmpLoad2);
   mtds.ReleaseDs(hdsDisp);
   mtds.ReleaseDs(hdsTest);

   /* Set the control variable so that we only write to the SD card the first
   ** time through this function.
   */
   fWriteTest1 = false;

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
**      This demo function illustrates using some of the file system API
**      functions to read and write files. In this case, we take the two bitmap
**      files that were created by the MtdsTestFs1 function and copy them to new
**      files. We then load the bitmaps from these new files into memory and
**      then copy them to the display.
*/

bool MtdsTestFs2() {
   HFIL fhSrc;
   HFIL fhDst;
   char szSrc1[] = "Images/IMG_0001.bmp";
   char szSrc2[] = "Images/IMG_0002.bmp";
   char szDst1[] = "Images/IMG_0098.bmp";
   char szDst2[] = "Images/IMG_0099.bmp";
   HDS  hdsDisp;
   HDS  hdsTest1;
   HDS  hdsTest2;
   HBMP hbmpTest1;
   HBMP hbmpTest2;
   uint8_t  rgbBuf[512];
   uint32_t cbRes;
   uint32_t cbRead;

   /* In order to reduce wear on the SD card, we only write the new files the
   ** first time that we execute this function. Each subsequent time that we
   ** are called, we just load them into memory and copy them to the display.
   */
   if (fWriteTest2) {
      /* Copy the first bitmap file into a new bitmap file. We do this by
      ** opening the source file for read and the destination file for write. We
      ** read data from the source file and write it to the destination file
      ** until we reach the end of the source file.
      */
      mtfs.DeleteFile(szDst1);
      fhSrc = mtfs.OpenFile(szSrc1, mdMtdsRead | mdMtdsOpenExisting);
      fhDst = mtfs.OpenFile(szDst1, mdMtdsWrite | mdMtdsCreateAlways);
      if ((fhSrc == 0) || (fhDst == 0)) {
         xil_printf("Error opening files to copy bitmap IMP_0001\n\r");
         fWriteTest2 = false;
         return false;
      }
      while (!mtfs.Feof(fhSrc)) {
         mtfs.ReadFile(fhSrc, rgbBuf, 512, &cbRead);
         if (cbRead > 0) {
            mtfs.WriteFile(fhDst, rgbBuf, cbRead, &cbRes);
         }
      }
      mtfs.CloseFile(fhSrc);
      mtfs.CloseFile(fhDst);

      /* Copy the second bitmap file into a new bitmap file. This is done the
      ** same was as the first one.
      */
      mtfs.DeleteFile(szDst2);
      fhSrc = mtfs.OpenFile(szSrc2, mdMtdsRead | mdMtdsOpenExisting);
      fhDst = mtfs.OpenFile(szDst2, mdMtdsWrite | mdMtdsCreateAlways);
      if ((fhSrc == 0) || (fhDst == 0)) {
         xil_printf("Error opening files to copy bitmap IMG_0002\n\r");
         fWriteTest2 = false;
         return false;
      }
      while (!mtfs.Feof(fhSrc)) {
         mtfs.ReadFile(fhSrc, rgbBuf, 512, &cbRead);
         if (cbRead > 0) {
            mtfs.WriteFile(fhDst, rgbBuf, cbRead, &cbRes);
         }
      }
      mtfs.CloseFile(fhSrc);
      mtfs.CloseFile(fhDst);
   }

   /* Now that we have copied the two source bitmap files and created two new
   ** bitmap files, we are going to load the new ones into memory and copy them
   ** to the display. As long as we have correctly copied all of the data from
   ** the source files, the new files will be valid device independent bitmap
   ** files and can be loaded into memory using LoadBitmap().
   */
  
   /* We're going to be drawing on the display, so get the display DS to do it
   ** with.
   */
   hdsDisp = mtds.GetDisplayDs();

   /* Load the first of the new bitmap files into memory and set up to copy it
   ** to the display. In order to operate on the new bitmap, we need to obtain a
   ** DS and then set the bitmap we load into memory as the drawing surface.
   */
   hbmpTest1 = mtds.LoadBitmap(szDst1);
   if (hbmpTest1 == 0) {
      xil_printf("Error loading IMG_0098.bmp\n\r");
      return false;
   }
   hdsTest1 = mtds.GetDs();
   mtds.SetDrawingSurface(hdsTest1, hbmpTest1);

   /* Do the same thing for the second new bitmap file.
   */
   hbmpTest2 = mtds.LoadBitmap(szDst2);
   if (hbmpTest2 == 0) {
      xil_printf("Error loading IMG_0099.bmp\n\r");
      return false;
   }
   hdsTest2 = mtds.GetDs();
   mtds.SetDrawingSurface(hdsTest2, hbmpTest2);

   /* Now, copy these bitmaps to the display. Here, we are tiling the surface of
   ** the display with the new bitmaps, alternating between them.
   */
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

   /* Free all of the resource used before we leave so that the memory isn't
   ** lost to the system.
   */
   mtds.DestroyBitmap(hbmpTest1);
   mtds.DestroyBitmap(hbmpTest2);
   mtds.ReleaseDs(hdsTest1);
   mtds.ReleaseDs(hdsTest2);
   mtds.ReleaseDs(hdsDisp);

   /* Set the control variable so that we only write to the SD card the first
   ** time through this function.
   */
   fWriteTest2 = false;
   return true;
}
