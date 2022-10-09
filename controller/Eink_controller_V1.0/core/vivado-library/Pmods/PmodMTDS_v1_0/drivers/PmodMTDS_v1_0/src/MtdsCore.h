/********************************************************************************/
/*																				*/
/*	MtdsCore.h	--	Low Level Support Functions for mtds.cpp					*/
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
/* 2016/10/05(GeneApperson): Renamed from MtdsUtil.h							*/
/* 2016-09-27(GeneApperson): Moved all platform dependent declarations to the	*/
/*		new file MtdsHal.h as part of the definition of a hardware abstraction	*/
/*		layer to make the library more portable between platforms				*/
/*																				*/
/********************************************************************************/

#if !defined(_MTDSCORE_H_)
#define	_MTDSCORE_H_

#if defined(MPIDE)
#include	<WProgram.h>
#include	<p32xxxx.h>
#include	<p32_defs.h>
#endif

#include <stdint.h>

/* ------------------------------------------------------------ */
/*					Miscellaneous Declarations					*/
/* ------------------------------------------------------------ */

#define	verMtdsMajor	1			// library major version number
#define	verMtdsMinor	1			// library minor version number

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
#define	tusPacketDelay	10
#define	tusSyncDelay	100
#define	tmsRhdrTimeout	1000		// time to wait for a status packet header
#define	tmsDhdrTimeout	1000		// time to wait for a data packet header
#define	tmsIdleTimeout	1000		// time to wait for slave to go to idle state
#define	tmsBusyTimeout	1000		// time to wait for slave to go to the busy state
#define	tmsDoneTimeout	1000		// time to wait for slave to go to done state
#define	tmsReadyTimeout	1000		// time to wait for slave to go to ready state
#define	tmsSyncTimeout	1000		// time to wait for shield to go to sync state
#define	tmsResumeTimeout 1000		// time to wait for shield to return to idle state on resume
#define	tmsUpdateTimeout 5000		// time to wait for shield to begin firmware update

#define	cbDataOutMax	cbDhdrDataOutMax				// maximum payload of data out packet
#define cbDataInMax		cbDhdrDataInMax					// maximum payload of data in packet
#define	cbRetValInit	(sizeof(RHDR)+cbRhdrDataMax)	// size of status packet buffer

/* ------------------------------------------------------------ */
/*					General Type Declarations					*/
/* ------------------------------------------------------------ */

/* Packet header structures. 
** This header structure is used for command packets.
*/
#pragma pack(push, 1)
struct CHDR {
	uint8_t		cls;		// command class
	uint8_t		cmd;		// command code
	uint16_t	cb;			// byte count of parameter bytes
};
#pragma pack(pop)

/* This header structure is used for return value packets.
*/
#pragma pack(push, 1)
struct RHDR {
	uint8_t		cls;		// return value packet class
	uint8_t		cmd;		// command code
	uint8_t		sta;		// status code
	uint8_t		cb;			// byte count of return value bytes in packet
};
#pragma pack(pop)

/* This structure is used for data in and data out packets.
*/
#pragma pack(push, 1)
struct DHDR {
	uint8_t		cls;		// data packet class
	uint8_t		cmd;		// command code
	uint16_t	cb;			// number of data bytes in packet
};
#pragma pack(pop)

/* Structure definitions for command parameters.
** These structure are ovelaid on the command buffer to allow easy
** access to the parameters.
*/
/* Up to four 32 bit values.
*/
#pragma pack(push, 1)
struct PRM1A {
	uint32_t	valA1;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM2A {
	uint32_t	valA1;
	uint32_t	valA2;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM3A {
	uint32_t	valA1;
	uint32_t	valA2;
	uint32_t	valA3;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM4A {
	uint32_t	valA1;
	uint32_t	valA2;
	uint32_t	valA3;
	uint32_t	valA4;
};
#pragma pack(pop)

/* Up to four 16 bit values;.
*/
#pragma pack(push, 1)
struct PRM1B {
	uint16_t	valB1;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM2B {
	uint16_t	valB1;
	uint16_t	valB2;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM3B {
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM4B {
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM6B {
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint16_t	valB5;
	uint16_t	valB6;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM1A1B {
	uint32_t	valA1;
	uint16_t	valB1;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM1A2B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM1A3B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM1A4B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM1A5B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint16_t	valB5;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct PRM1A6B {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint16_t	valB5;
	uint16_t	valB6;
};
#pragma pack(pop)

/* A 32 bit value followed by eight 16 bit values.
*/
#pragma pack(push, 1)
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
#pragma pack(pop)

/* Two 32 bit values followed by one 16 bit value.
*/
#pragma pack(push, 1)
struct PRM2A1B {
	uint32_t	valA1;
	uint32_t	valA2;
	uint16_t	valB1;
};
#pragma pack(pop)

/* Two 32 bit values followed by two 16 bit values.
*/
#pragma pack(push, 1)
struct PRM2A2B {
	uint32_t	valA1;
	uint32_t	valA2;
	uint16_t	valB1;
	uint16_t	valB2;
};
#pragma pack(pop)

/* Four 32 bit values followed by eight 16 bit values.
*/
#pragma pack(push, 1)
struct PRM4A8B {
	uint32_t	valA1;
	uint32_t	valA2;
	uint32_t	valA3;
	uint32_t	valA4;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint16_t	valB5;
	uint16_t	valB6;
	uint16_t	valB7;
	uint16_t	valB8;
};
#pragma pack(pop)

/* A 32 bit value, four 16 bit values, a 32 bit value, and up to three 16 bit values.
** These is used by BitBlt and DrawBitmap
*/
#pragma pack(push, 1)
struct PRM1A4B1A {
	uint32_t	valA1;
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint32_t	valA2;
};
#pragma pack(pop)

#pragma pack(push, 1)
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
#pragma pack(pop)

#pragma pack(push, 1)
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
#pragma pack(pop)

/* Structure definitions for return value packet.
** These structure are ovelaid on the return value buffer to allow easy
** access to the members.
*/
/* Up to four 32 bit values.
*/
#pragma pack(push, 1)
struct RET4A {
	uint32_t	valA1;
	uint32_t	valA2;
	uint32_t	valA3;
	uint32_t	valA4;
};
#pragma pack(pop)

/* Up to four 16 bit values.
*/
#pragma pack(push, 1)
struct RET4B {
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
};
#pragma pack(pop)

/* Up to four 16 bit values.
*/
#pragma pack(push, 1)
struct RET6B {
	uint16_t	valB1;
	uint16_t	valB2;
	uint16_t	valB3;
	uint16_t	valB4;
	uint16_t	valB5;
	uint16_t	valB6;
};
#pragma pack(pop)

/* ------------------------------------------------------------ */
/*					Object Class Declarations					*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Variable Declarations						*/
/* ------------------------------------------------------------ */



/* ------------------------------------------------------------ */
/*					Procedure Declarations						*/
/* ------------------------------------------------------------ */

void	MtdsSendCmdPacket(uint8_t cls, uint8_t cmd, uint16_t cbParam, uint8_t * pbParam);
void	MtdsSendDataPacket(uint8_t cmd, uint16_t cb, uint8_t * pb);
bool	MtdsReadStatusPacket();
bool	MtdsReadDataPacket(uint16_t cbMax, uint8_t * pb, uint16_t * pcbRes);
bool	MtdsReadRhdr(uint8_t * pb);
bool	MtdsReadDhdr(uint8_t * pb);
void	MtdsSendData(uint16_t cb, uint8_t * pb);
void	MtdsReadData(uint16_t cb, uint8_t * pb);

bool	MtdsWaitUntilShieldIdle();
bool	MtdsWaitUntilShieldBusy();
bool	MtdsWaitUntilShieldDone();
uint8_t	MtdsWaitUntilShieldReady();
bool	MtdsResumeChannel();
uint8_t	MtdsBeginUpdate();
uint8_t	MtdsQueryUpdate();

/* ------------------------------------------------------------ */

#endif	// _MTDSCORE_H_

/********************************************************************************/
