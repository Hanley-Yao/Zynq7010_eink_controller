/******************************************************************************/
/*                                                                            */
/* PmodJSTK2.c -- Driver source for the PmodJSTK2                             */
/*                                                                            */
/******************************************************************************/
/* Author: Samuel Lowe`                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This file contains the drivers for the PmodJSTK2 IP from Digilent          */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*   06/01/2016(SamL):     Created                                            */
/*   08/10/2017(ArtVVB):   Validated for Vivado 2015.4                        */
/*   11/02/2017(atangzwj): Validated for Vivado 2016.4                        */
/*   01/13/2018(atangzwj): Validated for Vivado 2017.4                        */
/*                                                                            */
/******************************************************************************/

/***************************** Include Files *******************************/

#include "PmodJSTK2.h"
#include "sleep.h"

/************************** Function Definitions ***************************/

XSpi_Config JSTK2Config =
{
   0,
   0,
   1,
   0,
   1,
   8,
   0,
   0,
   0,
   0,
   0
};

/* ------------------------------------------------------------ */
/*** void JSTK2_begin(PmodJSTK2* InstancePtr, u32 SPI_Address,
**         u32 GPIO_Address)
**
**   Parameters:
**      InstancePtr:  A PmodJSTK2 object to start
**      SPI_Address:  The base address of the PmodJSTK2 SPI Device
**      GPIO_Address: The base address of the PmodJSTK2 Chip-Select GPIO Device
**
**   Return Value:
**      None
**
**   Description:
**      Initialize the JSTK2 IP
*/
void JSTK2_begin(PmodJSTK2* InstancePtr, u32 SPI_Address, u32 GPIO_Address) {
   JSTK2Config.BaseAddress = SPI_Address;
   InstancePtr->GpioAddr = GPIO_Address;
   JSTK2_SPIInit(&InstancePtr->SpiDevice);
   Xil_Out32(InstancePtr->GpioAddr + 4, 0x0);
   Xil_Out32(InstancePtr->GpioAddr, 0x1);
}

/* ------------------------------------------------------------ */
/*** JSTK2_end(void)
**
**   Parameters:
**      InstancePtr: PmodJSTK2 device to stop
**
**   Return Value:
**      None
**
**   Description:
**      Clean up the JSTK2
*/
void JSTK2_end(PmodJSTK2* InstancePtr) {
   XSpi_Stop(&InstancePtr->SpiDevice);
}

/* ------------------------------------------------------------ */
/*** int JSTK2_SPIInit(XSpi* SpiInstancePtr)
**
**   Parameters:
**      SpiInstancePtr: JSTK2 SPI driver device to initialize
**
**   Return Value:
**      XST_SUCCESS or XST_FAILURE
**
**   Description:
**      Initializes the PmodJSTK2 SPI.
*/
int JSTK2_SPIInit(XSpi* SpiInstancePtr) {
   int Status;

   Status = XSpi_CfgInitialize(SpiInstancePtr, &JSTK2Config,
         JSTK2Config.BaseAddress);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   Status = XSpi_SetOptions(SpiInstancePtr,
         (XSP_MASTER_OPTION) | XSP_MANUAL_SSELECT_OPTION);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   // Even though we are generating the CS signal through the GPIO controller,
   // the SPI driver does not work without this statement
   Status = XSpi_SetSlaveSelect(SpiInstancePtr, 1);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }

   // Start the SPI driver so that the device is enabled.
   XSpi_Start(SpiInstancePtr);

   // Disable Global interrupt to use polled mode operation
   XSpi_IntrGlobalDisable(SpiInstancePtr);

   return XST_SUCCESS;
}

/* ------------------------------------------------------------ */
/*** void JSTK2_setLedRGB(PmodJSTK2* InstancePtr, u8 red, u8 green, u8 blue)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 object to start
**      Red:         PWM for red led (0-255)
**      Green:       PWM for green led (0-255)
**      Blue:        PWM for blue led (0-255)
**
**   Return Value:
**      none
**
**   Description:
**      Sets the color of the JSTK2's RGB LED
*/
void JSTK2_setLedRGB(PmodJSTK2* InstancePtr, u8 red, u8 green, u8 blue) {
   u8 recv[5];
   // Load buffer to send led data
   recv[0] = JSTK2_cmdSetLedRGB;
   recv[1] = red;
   recv[2] = green;
   recv[3] = blue;
   // Recv[4] is a dummy byte
   JSTK2_getData(InstancePtr, recv, 5);
}

/* ------------------------------------------------------------ */
/*** void JSTK2_getBtn(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 object to start
**
**   Return Value:
**      btn: The 8 bit representation of the buttons which are in the 0th and
**           1st positions
**
**   Description:
**      Gets the push button states of the PmodJSTK2
**      The button states can be accessed from the return value of this function
**      with the following macros:
**         JSTK2_<bn/bit>Trigger : 1 if the trigger is pressed
**         JSTK2_<bn/bit>Jstk    : 1 if the joystick inline button is pressed
**      In order to test a button state, the following operation is recommended:
**         if ((Status & JSTK2_bit<a button bit name>) != 0)
*/
u8 JSTK2_getBtns(PmodJSTK2* InstancePtr) {
   u8 recv[5] = {0};
   JSTK2_getData(InstancePtr, recv, 5);

   return (recv[4] & 0x03);
}

/* ------------------------------------------------------------ */
/*** u8 JSTK2_getX(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**
**   Return Value:
**      8 bit representation of the JSTK2 X position
**
**   Description:
**      Captures X axis position data from the JSTK2
*/
u8 JSTK2_getX(PmodJSTK2* InstancePtr) {
   u8 recv[7] = {0};

   recv[0] = JSTK2_cmdGetPosition;
   JSTK2_getData(InstancePtr, recv, 7);

   return recv[5];
}

/* ------------------------------------------------------------ */
/*** u8 JSTK2_getY(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**
**   Return Value:
**      8 bit representation of the JSTK2 Y position
**
**   Description:
**      Captures Y axis position data from the JSTK2
*/
u8 JSTK2_getY(PmodJSTK2* InstancePtr) {
   u8 recv[7] = {0};

   recv[0] = JSTK2_cmdGetPosition;
   JSTK2_getData(InstancePtr, recv, 7);

   return recv[6];
}

/* ------------------------------------------------------------ */
/*** JSTK2_DataPacket JSTK2_getDataPacket(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**
**   Return Value:
**      A basic data packet containing button states and X and Y position data
**
**   Description:
**      Captures state data from the JSTK2
*/
JSTK2_DataPacket JSTK2_getDataPacket(PmodJSTK2* InstancePtr) {
   u8 recv[5] = {0};
   JSTK2_DataPacket rawdata;

   recv[0] = JSTK2_cmdGetRaw;

   JSTK2_getData(InstancePtr, recv, 5);

   rawdata.XData = recv[0] | (recv[1] << 8);
   rawdata.YData = recv[2] | (recv[3] << 8);
   rawdata.Trigger = (recv[4] & JSTK2_bitTrigger) >> JSTK2_bnTrigger;
   rawdata.Jstk = (recv[4] & JSTK2_bitJstk) >> JSTK2_bnJstk;

   return rawdata;
}

/* ------------------------------------------------------------ */
/*** JSTK2_Position JSTK2_getPosition(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**
**   Return Value:
**      The contents of the position registers of the JSTK2, packed into a
**      JSTK2_Position struct
**
**   Description:
**      Captures the contents of the JSTK2's position registers
*/
JSTK2_Position JSTK2_getPosition(PmodJSTK2* InstancePtr) {
   u8 recv[7] = {0};
   JSTK2_Position data;
   recv[0] = JSTK2_cmdGetPosition;
   JSTK2_getData(InstancePtr, recv, 7);
   data.XData = recv[5];
   data.YData = recv[6];
   return data;
}

/* ------------------------------------------------------------ */
/*** u8 JSTK2_getStatus(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**
**   Return Value:
**      The contents of the Status register of the JSTK2
**
**   Description:
**      Captures the contents of the JSTK2's status register, use these macros
**      to access specific bits:
**         JSTK2_<bn/bit>Calibrating : 1 if JSTK2 is currently undergoing
**                                     calibration
**         JSTK2_<bn/bit>LastCal     : 1 if the last calibration operation was
**                                     successful
**         JSTK2_<bn/bit>LastFWS     : 1 if the last flash write was successful
**         JSTK2_<bn/bit>LastFRS     : 1 if the last flash read was successful
**         JSTK2_<bn/bit>InvertX     : 1 if joystick x axis inversion is enabled
**         JSTK2_<bn/bit>InvertY     : 1 if joystick y axis inversion is enabled
**      In order to test a status bit, the following operation is recommended:
**         if ((Status & JSTK2_bit<a Status bit name>) != 0)
*/
u8 JSTK2_getStatus(PmodJSTK2* InstancePtr) {
   u8 recv[6] = {0};

   recv[0] = JSTK2_cmdGetStatus;
   JSTK2_getData(InstancePtr, recv, 6);

   return recv[5];
}

/* ------------------------------------------------------------ */
/*** void JSTK2_setInversion(PmodJSTK2* InstancePtr, u8 invX, u8 invY)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**      invX:        1 if the X Axis is to be inverted, 0 otherwise
**      invY:        1 if the Y Axis is to be inverted, 0 otherwise
**
**   Return Value:
**      None
**
**   Description:
**      Sets the JSTK2's inversion bits, inverting a direction will cause data
**      returned to go from forward-back mapping to back-forward (255-0 instead
**      of 0-255)
*/
void JSTK2_setInversion(PmodJSTK2* InstancePtr, u8 invX, u8 invY) {
   u8 recv[5] = {0};

   recv[0] = JSTK2_cmdSetInversion;
   if (invX != 0) {
      recv[0] |= JSTK2_bitInvertX;
   }
   if (invY != 0) {
      recv[0] |= JSTK2_bitInvertY;
   }
   JSTK2_getData(InstancePtr, recv, 5);
}

/* ------------------------------------------------------------ */
/*** void JSTK2_startFlashReload(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**
**   Return Value:
**      None
**
**   Description:
**      Initiates the process to retrieve calibration data in the JSTK2's flash
**      memory and store it in the JSTK2's RAM
**
**      The user should wait at least 100 us after this command is called before
**      performing any other SPI transactions
*/
void JSTK2_startFlashReload(PmodJSTK2* InstancePtr) {
   u8 recv[5] = {0};

   recv[0] = JSTK2_cmdRldFromFlash;
   JSTK2_getData(InstancePtr, recv, 5);

   return;
}

/* ------------------------------------------------------------ */
/*** void JSTK2_startFlashWrite(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**
**   Return Value:
**      None
**
**   Description:
**      Initiates the process to store calibration data in the JSTK2's RAM to
**      flash memory
**
**      The user should wait at least 5 ms after this command is called before
**      performing any other SPI transactions
*/
void JSTK2_startFlashWrite(PmodJSTK2* InstancePtr) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdWriteFlash;

   JSTK2_getData(InstancePtr, buffer, 5);
   return;
}

/* ------------------------------------------------------------ */
/*** void JSTK2_startCalibration(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**
**   Return Value:
**      None
**
**   Description:
**      Initiates the calibration process on the JSTK2
**      The user should wait at least one second after this command is called to
**      begin polling the status register to determine that calibration is
**      finished.
*/
void JSTK2_startCalibration(PmodJSTK2* InstancePtr) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdCalibrate;

   JSTK2_getData(InstancePtr, buffer, 5);
}

/* ------------------------------------------------------------ */
/*** u16 JSTK2_getCal...(PmodJSTK2* InstancePtr)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**
**   Return Value:
**      The specified calibration parameter
**
**   Description:
**      Retrieves a calibration parameter from the JSTK2 onboard RAM.
*/
u16 JSTK2_getCalXMin(PmodJSTK2* InstancePtr) {
   u8 buffer[7] = {0};
   buffer[0] = JSTK2_cmdGetCalXMin;

   JSTK2_getData(InstancePtr, buffer, 7);

   return ((u16)((buffer[5] << 8) | buffer[6]));

}

u16 JSTK2_getCalXMax(PmodJSTK2* InstancePtr) {
   u8 buffer[7] = {0};
   buffer[0] = JSTK2_cmdGetCalXMax;

   JSTK2_getData(InstancePtr, buffer, 7);

   return ((u16)((buffer[5] << 8) | buffer[6]));
}

u16 JSTK2_getCalYMin(PmodJSTK2* InstancePtr) {
   u8 buffer[7] = {0};
   buffer[0] = JSTK2_cmdGetCalYMin;

   JSTK2_getData(InstancePtr, buffer, 7);

   return ((u16)((buffer[5] << 8) | buffer[6]));
}

u16 JSTK2_getCalYMax(PmodJSTK2* InstancePtr) {
   u8 buffer[7] = {0};
   buffer[0] = JSTK2_cmdGetCalYMax;

   JSTK2_getData(InstancePtr, buffer, 7);

   return ((u16)((buffer[5] << 8) | buffer[6]));
}

u16 JSTK2_getCalXCenMin(PmodJSTK2* InstancePtr) {
   u8 buffer[7] = {0};
   buffer[0] = JSTK2_cmdGetCalXCenMin;

   JSTK2_getData(InstancePtr, buffer, 7);

   return ((u16)((buffer[5] << 8) | buffer[6]));
}

u16 JSTK2_getCalXCenMax(PmodJSTK2* InstancePtr) {
   u8 buffer[7] = {0};
   buffer[0] = JSTK2_cmdGetCalXCenMax;

   JSTK2_getData(InstancePtr, buffer, 7);

   return ((u16)((buffer[5] << 8) | buffer[6]));
}

u16 JSTK2_getCalYCenMin(PmodJSTK2* InstancePtr) {
   u8 buffer[7] = {0};
   buffer[0] = JSTK2_cmdGetCalYCenMin;

   JSTK2_getData(InstancePtr, buffer, 7);

   return ((u16)((buffer[5] << 8) | buffer[6]));
}

u16 JSTK2_getCalYCenMax(PmodJSTK2* InstancePtr) {
   u8 buffer[7] = {0};
   buffer[0] = JSTK2_cmdGetCalYCenMax;

   JSTK2_getData(InstancePtr, buffer, 7);

   return ((u16)((buffer[5] << 8) | buffer[6]));
}


/* ------------------------------------------------------------ */
/*** void JSTK2_setCal...(PmodJSTK2* InstancePtr, u16 ...Cal)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to interact with
**      ...Cal:      The value to set the specified calibration parameter to
**
**   Return Value:
**      None
**
**   Description:
**      Sets a calibration parameter in the JSTK2 onboard RAM.
*/
void JSTK2_setCalXMin(PmodJSTK2* InstancePtr, u16 XMinCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalXMin;
   buffer[1] = XMinCal & 0x00FF;
   buffer[2] = XMinCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalXMax(PmodJSTK2* InstancePtr, u16 XMaxCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalXMax;
   buffer[1] = XMaxCal & 0x00FF;
   buffer[2] = XMaxCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalYMin(PmodJSTK2* InstancePtr, u16 YMinCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalYMin;
   buffer[1] = YMinCal & 0x00FF;
   buffer[2] = YMinCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalYMax(PmodJSTK2* InstancePtr, u16 YMaxCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalYMax;
   buffer[1] = YMaxCal & 0x00FF;
   buffer[2] = YMaxCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalXCenMin(PmodJSTK2* InstancePtr, u16 XCenMinCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalXCenMin;
   buffer[1] = XCenMinCal & 0x00FF;
   buffer[2] = XCenMinCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalXCenMax(PmodJSTK2* InstancePtr, u16 XCenMaxCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalXCenMax;
   buffer[1] = XCenMaxCal & 0x00FF;
   buffer[2] = XCenMaxCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalYCenMin(PmodJSTK2* InstancePtr, u16 YCenMinCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalYCenMin;
   buffer[1] = YCenMinCal & 0x00FF;
   buffer[2] = YCenMinCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalYCenMax(PmodJSTK2* InstancePtr, u16 YCenMaxCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalYCenMax;
   buffer[1] = YCenMaxCal & 0x00FF;
   buffer[2] = YCenMaxCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalXMinMax(PmodJSTK2* InstancePtr, u16 XMinCal, u16 XMaxCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalXMinMax;
   buffer[1] = XMinCal & 0x00FF;
   buffer[2] = XMinCal >> 8;
   buffer[3] = XMaxCal & 0x00FF;
   buffer[4] = XMaxCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalYMinMax(PmodJSTK2* InstancePtr, u16 YMinCal, u16 YMaxCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalYMinMax;
   buffer[1] = YMinCal & 0x00FF;
   buffer[2] = YMinCal >> 8;
   buffer[3] = YMaxCal & 0x00FF;
   buffer[4] = YMaxCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalXCenMinMax(PmodJSTK2* InstancePtr, u16 XCenMinCal,
      u16 XCenMaxCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalXCenMinMax;
   buffer[1] = XCenMinCal & 0x00FF;
   buffer[2] = XCenMinCal >> 8;
   buffer[3] = XCenMaxCal & 0x00FF;
   buffer[4] = XCenMaxCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

void JSTK2_setCalYCenMinMax(PmodJSTK2* InstancePtr, u16 YCenMinCal,
      u16 YCenMaxCal) {
   u8 buffer[5] = {0};
   buffer[0] = JSTK2_cmdSetCalXCenMinMax;
   buffer[1] = YCenMinCal & 0x00FF;
   buffer[2] = YCenMinCal >> 8;
   buffer[3] = YCenMaxCal & 0x00FF;
   buffer[4] = YCenMaxCal >> 8;

   JSTK2_getData(InstancePtr, buffer, 5);
}

/* ------------------------------------------------------------ */
/*** void JSTK2_getData(PmodJSTK2* InstancePtr, u8* recv, u8 nData)
**
**   Parameters:
**      InstancePtr: A PmodJSTK2 device to capture from
**      recv:        A byte array to act as the receive and send buffer
**      nData:       The number of bytes to send and receive, recv must be at
**                   least this size
**
**   Return Value:
**      None
**
**   Description:
**      Manages a SPI transaction with the PmodJSTK2
**
**   Problems:
**      Holding the chip select low between bytes through the QSPI driver isn't
**      working so bit-banging that line with an AXI GPIO controller instead
*/
void JSTK2_getData(PmodJSTK2* InstancePtr, u8* recv, u8 nData) {
   int i = 0;

   // Bring chip select low
   Xil_Out32(InstancePtr->GpioAddr, 0b0);

   usleep(5); // 5 us delay from cs->low to first byte

   for (i = 0; i < nData; i++) {
      usleep(10); // 10 us delay between bytes
      XSpi_Transfer(&InstancePtr->SpiDevice, &recv[i], &recv[i], 1);
   }

   usleep(20); // 20 us delay from last packet to cs->high

   // Bring chip select high
   Xil_Out32(InstancePtr->GpioAddr, 0b1);

   usleep(25);
}
