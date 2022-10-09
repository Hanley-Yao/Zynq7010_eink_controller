/******************************************************************************/
/*                                                                            */
/* PmodKYPD.c -- Driver for the Pmod Keypad                                   */
/*                                                                            */
/******************************************************************************/
/* Author: Mikel Skreen                                                       */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This library contains basic functions to read the states of the keys of    */
/* the Digilent's PmodKYPD                                                    */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    06/08/2016(MikelS):   Created                                           */
/*    08/17/2017(artvvb):   Validated for Vivado 2015.4                       */
/*    08/30/2017(artvvb):   Validated for Vivado 2016.4                       */
/*                          Added Multiple keypress error detection           */
/*    01/27/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files ****************************/

#include "PmodKYPD.h"

/*************************** Function Prototypes ************************/

u8 KYPD_lookupShiftPattern(u16 shift);

/************************** Function Definitions ************************/

/* -------------------------------------------------------------------- */
/*** void KYPD_begin(PmodKYPD *InstancePtr, u32 GPIO_Address)
**
**   Parameters:
**      InstancePtr: A PmodKYPD device to start
**      GPIO_Address: The Base address of the PmodKYPD GPIO
**
**   Return Value:
**      none
**
**   Description:
**      Initialize the PmodKYPD driver device
*/
void KYPD_begin(PmodKYPD *InstancePtr, u32 GPIO_Address) {
   InstancePtr->GPIO_addr = GPIO_Address;
   // Set tri-state register, lower 4 pins are column outputs, upper 4 pins are
   // row inputs
   Xil_Out32(InstancePtr->GPIO_addr + 4, 0xF0);
   InstancePtr->keytable_loaded = FALSE;
}

/* -------------------------------------------------------------------- */
/*** void KYPD_setCols(PmodKYPD *InstancePtr, u32 cols)
**
**   Parameters:
**      InstancePtr: A PmodKYPD device to use
**      cols: column bits to set the output pins to
**
**   Return Value:
**      none
**
**   Description:
**      Set the column output pins
*/
void KYPD_setCols(PmodKYPD *InstancePtr, u32 cols) {
   Xil_Out32(InstancePtr->GPIO_addr, cols & 0xF);
}

/* -------------------------------------------------------------------- */
/*** u32 KYPD_getRows(PmodKYPD *InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodKYPD device to use
**
**   Return Value:
**      rows: row bits read from the input pins
**
**   Description:
**      Read the row input pins
*/
u32 KYPD_getRows(PmodKYPD *InstancePtr) {
   return (Xil_In32(InstancePtr->GPIO_addr) >> 4) & 0xF;
}

/* -------------------------------------------------------------------- */
/*** u16 KYPD_getKeyStates(PmodKYPD *InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodKYPD device to use
**
**   Return Value:
**      keystate: 16 bits, each represents the status of one key (active high).
**                Each set of four keys on a single row are grouped together.
**
**   Description:
**      Capture the state of each key on the keypad
**
**   Errors:
**      Multiple key presses may not be detected properly - it can be detected
**      that multiple keys are pressed, but not which.
*/
u16 KYPD_getKeyStates(PmodKYPD *InstancePtr) {
   u32 rows, cols;
   u16 keystate;
   u16 shift[4] = {0, 0, 0, 0};

   // Test each column combination, this will help to detect when multiple keys
   // in the same row are pressed.
   for (cols = 0; cols < 16; cols++) {
      KYPD_setCols(InstancePtr, cols);
      rows = KYPD_getRows(InstancePtr);
      // Group bits from each individual row
      shift[0] = (shift[0] << 1) | (rows & 0x1);
      shift[1] = (shift[1] << 1) | (rows & 0x2) >> 1;
      shift[2] = (shift[2] << 1) | (rows & 0x4) >> 2;
      shift[3] = (shift[3] << 1) | (rows & 0x8) >> 3;
   }

   // Translate shift patterns for each row into button presses.
   keystate = 0;
   keystate |= KYPD_lookupShiftPattern(shift[0]);
   keystate |= KYPD_lookupShiftPattern(shift[1]) << 4;
   keystate |= KYPD_lookupShiftPattern(shift[2]) << 8;
   keystate |= KYPD_lookupShiftPattern(shift[3]) << 12;
   return keystate;
}

/* -------------------------------------------------------------------- */
/*** void KYPD_loadKeyTable(PmodKYPD *InstancePtr, char keytable[16])
**
**   Parameters:
**      InstancePtr: A PmodKYPD device to use
**      keytable:    A 16-character array containing the characters that
**                   represent each key.
**
**   Return Value:
**      None
**
**   Description:
**      Set the keytable array so that KYPD_getKeyPressed will return will
**      return the human-readable character that the pressed key represents
*/
void KYPD_loadKeyTable(PmodKYPD *InstancePtr, u8 keytable[16]) {
   int i;

   for (i = 0; i < 16; i++) {
      // Hard copy string into device struct
      InstancePtr->keytable[i] = keytable[i];
   }

   InstancePtr->keytable_loaded = TRUE;
}

/* -------------------------------------------------------------------- */
/*** XStatus KYPD_getKeyPressed(PmodKYPD *InstancePtr, u16 keystate, char *cptr)
**
**   Parameters:
**      InstancePtr: A PmodKYPD device to use
**      keystate:    Status of each key, pressed indicated by a '1' in that
**                      key's bit position.
**                   Bit positions correspond with character positions in
**                      InstancePtr->keytable.
**      cptr:        Address to return additional information when a single key
**                      is pressed.
**
**   Return Value:
**      status:
**         XST_SUCCESS when only one key is pressed.
**           cptr is loaded with a human-readable character when keytable is
**              loaded.
**           cptr is loaded with the key index when keytable is not loaded.
**       KYPD_MULTI_KEY when multiple keys are pressed.
**       KYPD_NO_KEY when no keys are pressed.
**
**  Errors:
**    KYPD_MULTI_KEY - cannot differentiate which keys are pressed in some
**                     multi-key cases.
**
**  Description:
**    Set the keytable array so that KYPD_getKeyPressed will return will
**    return the human-readable character that the pressed key represents
*/
u32 KYPD_getKeyPressed(PmodKYPD *InstancePtr, u16 keystate, u8 *cptr) {
   u8 i = 0;
   u8 ci = 0;
   u32 count = 0;

   for (i = 0; i < 16; i++) {
      // If key reading is 0 (pressed)
      if (0x1 == (keystate & 0x1)) {
         count++; // Count the number of pressed keys
         ci = i;
      }
      // Increment through keystate bits
      keystate >>= 1;
   }

   if (count > 1) {
      // Multiple keys pressed, cannot differentiate which
      return KYPD_MULTI_KEY;
   } else if (count == 0) {
      // No key pressed
      return KYPD_NO_KEY;
   } else {
      // One key pressed
      if (InstancePtr->keytable_loaded == TRUE)
         *cptr = InstancePtr->keytable[ci]; // Return human-readable key label
      else
         *cptr = ci; // Return index of pressed key
      return KYPD_SINGLE_KEY;
   }
}

/* -------------------------------------------------------------------- */
/*** u8 KYPD_lookupShiftPattern(u16 shift)
**
**   Parameters:
**      InstancePtr: A PmodKYPD device to use
**      shift:       A 16-bit array containing the read bits of a single row
**                   received for each column pattern.
**
**   Return Value:
**      buttons: The button presses detected on this row.
**
**   Description:
**      Translates reading-pattern detected on a single row into the buttons
**      pressed on that row.
*/
u8 KYPD_lookupShiftPattern(u16 shift) {
   // Attempt to determine which keys are pressed in this row
   // These patterns were determined experimentally
   switch(shift) {
   case 0xFFFF: return 0x0;
   case 0x00FF: return 0x1;
   case 0x0F0F: return 0x2;
   case 0x0FFF: return 0x3;
   case 0x3333: return 0x4;
   case 0x33FF: return 0x5;
   case 0x3F3F: return 0x6;
   case 0x033F: return 0x7;
   case 0x5555: return 0x8;
   case 0x55FF: return 0x9;
   case 0x5F5F: return 0xA;
   case 0x055F: return 0xB;
   case 0x7777: return 0xC;
   case 0x1177: return 0xD;
   case 0x1717: return 0xE;
   case 0x177F: return 0xF;
   default:     return 0x0;
   }
}
