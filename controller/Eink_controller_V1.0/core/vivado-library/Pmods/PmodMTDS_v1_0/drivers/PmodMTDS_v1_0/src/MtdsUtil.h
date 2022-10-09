/********************************************************************************/
/*																				*/
/*	MtdsUtil.h	--	Utility Support Functions for mtds.cpp						*/
/*																				*/
/********************************************************************************/
/*	Author:		Gene Apperson													*/
/*	Copyright 2015, Digilent, Inc. All rights reserved.							*/
/********************************************************************************/
/*  File Description:															*/
/*																				*/
/*	This header file contains declarations for MtdsUtil.c. This module contains	*/
/*	miscellaneous support functions for the Digilent Multi-Touch Display Shield	*/
/*	library defined in mtds.cpp.												*/
/*																				*/
/********************************************************************************/
/*  Revision History:															*/
/*																				*/
/* 2015/08/03(GeneApperson): Created											*/
/*																				*/
/********************************************************************************/

#if !defined(_MTDSUTIL_H_)
#define	_MTDSUTIL_H_

#if !defined(__SIM__)
#include	<WProgram.h>

#include	<p32xxxx.h>
#include	<p32_defs.h>
#endif

#include <stdint.h>

/* ------------------------------------------------------------ */
/*					Miscellaneous Declarations					*/
/* ------------------------------------------------------------ */

/* The cbSyncLimit value specifies the maximum number of bytes to send to the shield
** when attempting to synchronize the communications channel. The worst case would
** normally be we we attempt to synchronize when the shield thinks it sending back a
** maximum size data packet.
** cbSyncCount specifies the number of sync bytes we need to receive in a row to decide
** that the shield is in the synchronization state
** cbStartCount specifies the maximum number of start bytes to send to get the shield
** out of the sync state and into the idle state so that we can start actually talking
** to it.
*/
#define	cbSyncLimit		768
#define	cbStartLimit	5
#define	cbSyncCount		10

#define	cbDataOutMax	512					// maximum payload of data out packet
#define	cbRhdrDataMax	16					// largest allowed return value data size
#define	cbRetValInit	(sizeof(RHDR)+cbRhdrDataMax)	// size of return value buffer

#define		cbMtdsTxBufInit		32
#define		cbMtdsRxBufInit		32

#if defined(__SIM__)
#define	StiEnableInterrupts()	0
#define	StiDisableInterrupts()	0, HostDisableInt()
#define	RestoreInterrupts(val)	HostRestoreInt()
void	HostDisableInt();
void	HostRestoreInt();
#endif

/* Symbols used for initializing and operating the SPI controller.
*/
#define SPI_MODE0 0x100		// CKP = 0 CKE = 1
#define SPI_MODE1 0x00		// CKP = 0 CKE = 0
#define SPI_MODE2 0x140		// CKP = 1 CKE = 1 
#define SPI_MODE3 0x40		// CKP = 1 CKE = 0

/* ------------------------------------------------------------ */
/*					General Type Declarations					*/
/* ------------------------------------------------------------ */

#if defined(__SIM__)
#pragma pack(1)
#endif	// __SIM__
/* Packet header structures. 
** This header structure is used for command packets.
*/
struct CHDR {
	uint8_t		cls;		// command class
	uint8_t		cmd;		// command code
	uint16_t	cb;			// byte count of parameter bytes
};

/* This header structure is used for return value packets.
*/
struct RHDR {
	uint8_t		cls;		// return value packet class
	uint8_t		cmd;		// command code
	uint8_t		sta;		// status code
	uint8_t		cb;			// byte count of return value bytes in packet
};

/* This structure is used for data in and data out packets.
*/
struct DHDR {
	uint8_t		cls;		// data packet class
	uint8_t		cmd;		// command code
	uint16_t	cb;			// number of data bytes in packet
};

/* Structure definitions for command parameters.
** These structure are ovelaid on the command buffer to allow easy
** access to the parameters.
*/
// M00TODO Pack parameter structure definitions
/* Up to four 32 bit values.
*/
struct PRM1A {
	uint32_t	valA1;
};

struct PRM2A {
	uint32_t	valA1;
	uint32_t	valA2;
};

/* Up to four 16 bit values;.
*/
struct PRM1B {
	uint16_t	valB1;
};

struct PRM2B {
	uint16_t	valB1;
	uint16_t	valB2;
};

struct PRM3B {
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
};

struct PRM4B {
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
};

struct PRM1A1B {
	uint32_t	valA1;
	uint16_t	valB1;
};

struct PRM1A2B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
};

struct PRM1A3B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
};

struct PRM1A4B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
};

struct PRM1A5B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint16_t	valB5;
};

struct PRM1A6B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint16_t	valB5;
	uint16_t	valB6;
};

/* A 32 bit value followed by up to eight 16 bit values.
*/
struct PRM1A8B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint16_t	valB5;
	uint16_t	valB6;
	uint16_t	valB7;
	uint16_t	valB8;
};

/* A 32 bit value, four 16 bit values, a 32 bit value, and up to three 16 bit values.
** These is used by BitBlt and DrawBitmap
*/
struct PRM1A4B1A {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint32_t	valA2;
};

struct PRM1A4B1A2B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint32_t	valA2;
	uint16_t	valB5;
	uint16_t	valB6;
};

struct PRM1A4B1A3B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint32_t	valA2;
	uint16_t	valB5;
	uint16_t	valB6;
	uint16_t	valB7;
};

/* Structure definitions for return value packet.
** These structure are ovelaid on the return value buffer to allow easy
** access to the members.
*/
/* Up to four 32 bit values.
*/
struct RET4A {
	uint32_t	valA1;
	uint32_t	valA2;
	uint32_t	valA3;
	uint32_t	valA4;
};

/* Up to four 16 bit values.
*/
struct RET4B {
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
};

#if defined(__SIM__)
#pragma pack()
#endif	// __SIM__

/* ------------------------------------------------------------ */
/*					Object Class Declarations					*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Variable Declarations						*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */

bool	MtdsSyncChannel();
void	MtdsProcessCmd(uint8_t cls, uint8_t cmd, uint16_t cbParam, uint8_t * pbParam, 
						uint16_t cbData, uint8_t * pbData);

void	MtdsInitPins(int pinSel, int pinInt, bool fUseInt);
void	MtdsInitSpi(uint32_t frq);
void	MtdsSetPinSel(int pinSel);
void	MtdsSetPinInt(int pinInt, bool fUseInt);

/* ------------------------------------------------------------ */

#endif	// _MTDSUTIL_H_

/********************************************************************************/
