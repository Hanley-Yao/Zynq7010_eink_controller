/************************************************************************/
/*																		*/
/*	MtdsCore.c	--	Low Level Support Functions For mtds.cpp			*/
/*																		*/
/************************************************************************/
/*	Author: 	Gene Apperson											*/
/*	Copyright 2016, Digilent, Inc. All rights reserved.					*/
/************************************************************************/
/*  Module Description: 												*/
/*																		*/
/*	This module contains utility support functions for the Digilent		*/
/*	Multi-Touch Display Shield library defined in mtds.cpp.				*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/* 2015/08/03(GeneApperson): Created									*/
/* 2015/10/05(GeneApperson): Renamed from MtdsUtil.cpp					*/
/* 2016-09-27(GeneApperson): Moved low level driver functions to new	*/
/*		module MtdsHal.cpp to support having a hardware abstraction		*/
/*		layer to make the library portable between platforms.			*/
/* 2016-09-27(GeneApperson): Changed conditional on __SIM__ to being	*/
/*		conditional on MPIDE as part of change to using a HAL layer		*/
/*		to make library portable between platforms.	This conditional	*/
/*		was really to put out debugging information when testing under	*/
/*		MPIDE															*/
/* 12/20/2017(atangzwj): Replaced delay functions with sleep            */
/*																		*/
/************************************************************************/

#define	OPT_BOARD_INTERNAL

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include	<stdint.h>

#include	"ProtoDefs.h"
#include	"mtds.h"
#include	"MtdsCore.h"
#include	"MtdsHal.h"
#include "sleep.h"

/* ------------------------------------------------------------ */
/*				Local Type Definitions							*/
/* ------------------------------------------------------------ */

//#define __MTDSDEBUG__
//#define __MTDSTRACE__

/* ------------------------------------------------------------ */
/*				Global Variables								*/
/* ------------------------------------------------------------ */

uint8_t	rgbMtdsRetVal[cbRetValInit];

CHDR	chdrMtdsCmd;
DHDR	dhdrMtdsData;

RHDR *	prhdrMtdsRet = (RHDR *)rgbMtdsRetVal;
DHDR *	pdhdrMtdsData = &dhdrMtdsData;

/* ------------------------------------------------------------ */
/*				Local Variables									*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Forward Declarations							*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Procedure Definitions							*/
/* ------------------------------------------------------------ */
/***	MtdsSendCmdPacket(cls, cmd, cbParam, pbParam)
**
**	Parameters:
**		cls		- command class
**		cmd		- command code
**		cbParam	- number of bytes of parameter data in command packet
**		pbParam	- pointer to parameter data to send
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Send the specified command packet to the shield.
*/
void MtdsSendCmdPacket(uint8_t cls, uint8_t cmd, uint16_t cbParam, uint8_t * pbParam) {

	/* Set up the packet header.
	*/
	chdrMtdsCmd.cls = cls;
	chdrMtdsCmd.cmd = cmd;
	chdrMtdsCmd.cb = cbParam;

	/* Send the packet.
	*/
	MtdsHalEnableSlave(true);

	MtdsSendData(sizeof(CHDR), (uint8_t *)&chdrMtdsCmd);

	if (cbParam > 0) {
		MtdsSendData(cbParam, pbParam);
	}

	MtdsHalEnableSlave(false);

}

/* ------------------------------------------------------------ */
/***	MtdsReadStatusPacket()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		Returns status code
**
**	Description:
**		Read a status packet into the status packet buffer.
*/

bool MtdsReadStatusPacket() {
	bool	fStat;

	fStat = true;
	MtdsHalEnableSlave(true);

	if (MtdsReadRhdr(rgbMtdsRetVal)) {
		/* We got a good status packet header. Read the rest of the packet.
		*/
		if (prhdrMtdsRet->cb != 0) {
			MtdsReadData(prhdrMtdsRet->cb, &rgbMtdsRetVal[sizeof(RHDR)]);
		}
	}
	else {
		/* We got an error reading the header. This means that the first real
		** byte that we got back wasn't the class byte for a status packet header,
		** we timed out, or there was an internal inconsistency in the packet header.
		** The cls byte of the RHDR structure contains the channel status byte
		** indicating what happened. Return failure and let the higher level code
		** figure out how to recover.
		*/
		fStat = false;
	}

	MtdsHalEnableSlave(false);

	return fStat;
}

/* ------------------------------------------------------------ */
/***	MtdsSendDataPacket(cmd, cb, pb)
**
**	Parameters:
**		cmd		- command value to put in packet header
**		cb		- number of bytes for packet payload
**		pb		- pointer to packet payload to send
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Send the specified data packet to the shield.
*/
void MtdsSendDataPacket(uint8_t cmd, uint16_t cb, uint8_t * pb) {

	/* Set up the packet header.
	*/
	dhdrMtdsData.cls = clsDataOut;
	dhdrMtdsData.cmd = cmd;
	dhdrMtdsData.cb = cb;

	/* Send the packet payload.
	*/
	MtdsHalEnableSlave(true);
	MtdsSendData(sizeof(DHDR), (uint8_t *)&dhdrMtdsData);
	MtdsSendData(cb, pb);
	MtdsHalEnableSlave(false);

}

/* ------------------------------------------------------------ */
/***	MtdsReadDataPacket(cbMax, pb, pcbRes)
**
**	Parameters:
**		cbMax		- maximum number of bytes to read
**		pb			- pointer to buffer to receive the data
**		pcbRes		- pointer to variable to receive actual number of bytes read
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Read a data packet header and then read the packet payload
**		into the specified buffer.
*/

bool MtdsReadDataPacket(uint16_t cbMax, uint8_t * pb, uint16_t * pcbRes) {
	uint16_t	cbCur;
	uint16_t	cbRem;
	bool		fStat;

	fStat = true;
	*pcbRes = 0;
	MtdsHalEnableSlave(true);

	if (MtdsReadDhdr((uint8_t *)&dhdrMtdsData)) {
		/* We have the data in packet header. We need to read up to the requested amount
		** of data into the specified buffer.
		*/
		cbCur = dhdrMtdsData.cb;
		if (cbCur > cbMax) {
			cbCur = cbMax;
		}
		if (cbCur > 0) {
			MtdsReadData(cbCur, pb);
			*pcbRes = cbCur;
		}

		/* Discard any data from the data-in packet that won't fit in the return buffer.
		*/
		cbRem = dhdrMtdsData.cb - cbCur;
		if (cbRem > 0) {
			MtdsReadData(cbRem, 0);
		}
	}
	else {
		/* We got an error reading the header. This means that the first real
		** byte that we got back wasn't the class byte for a data packet header,
		** we timed out, or there was an internal inconsistency in the packet header.
		** The cls byte of the DHDR structure contains the channel status byte
		** indicating what happened. Return failure and let the higher level code
		** figure out how to recover.
		*/
		fStat = false;
	}

	MtdsHalEnableSlave(false);

	return fStat;

}

/* ------------------------------------------------------------ */
/***	MtdsReadRhdr(pb)
**
**	Parameters:
**		pb		- buffer to receive the data
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if we get an error.
**
**	Description:
**		Read a status packet header from the shield.
*/

bool MtdsReadRhdr(uint8_t * pb) {
	uint8_t		bRcv;
	int			cbCur;
	RHDR *		prhdr;
	uint32_t	tmsStart;

	cbCur = 0;
	prhdr = (RHDR *)pb;
	
	/* It may take a while for the shield to process the read status command
	** and to begin sending the status packet. While it is processing the command
	** we will get back "chnStaBusy" bytes. We may also get some "chnStaIdle" bytes
	** before we get the actual status packet. We need to skip past those until
	** we get the actual status packet header.
	*/
	tmsStart = MtdsHalTmsElapsed();
	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}
		bRcv = MtdsHalPutSpiByte(chnCmdRead);
		if ((bRcv & mskPacketCls) == clsPacketSta) {
			break;
		}
		if ((MtdsHalTmsElapsed() - tmsStart) > tmsRhdrTimeout) {
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!RdRhdr timeout");
#endif
#endif
			prhdr->cls = chnStaTimeout;
			return false;
		}
	}

	/* Stick the first byte in the buffer.
	*/
	*pb++ = bRcv;
	cbCur += 1;

	/* Check that we have the class byte for a status packet.
	*/
	if ((bRcv & mskPacketCls) != clsPacketSta) {
		/* We don't have the correct initial byte for a status packet.
		*/
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
		Serial.print("!RdRhdr: ");
		Serial.println(bRcv, HEX);
#endif
#endif
		return false;
	}

	/* Read the rest of the header.
	*/
	while (cbCur < sizeof(RHDR)) {
		while (!MtdsHalSpiReady()) {
		}
		bRcv = MtdsHalPutSpiByte(chnCmdRead);
		*pb++ = bRcv;
		cbCur +=1;
	}

	if (prhdr->cb > cbRhdrDataMax) {
		/* The cb field is too large for this to be a valid header. Either the host
		** sent us a bad packet, or it got screwed up by a channel error.
		*/
		prhdr->cls = chnStaDataSize;
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
		Serial.println("!RdRhdr data size");
#endif
#endif
		return false;
	}

	return true;
		
}

/* ------------------------------------------------------------ */
/***	MtdsReadDhdr(pb)
**
**	Parameters:
**		pb		- buffer to receive the data
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if we get an error.
**
**	Description:
**		Read a data packet header from the shield.
*/

bool MtdsReadDhdr(uint8_t * pb) {
	uint8_t		bRcv;
	int			cbCur;
	DHDR *		pdhdr;
	uint32_t	tmsStart;

	cbCur = 0;
	pdhdr = (DHDR *)pb;
	
	/* It may take a while for the shield to process the command and to begin
	** sending the data packet.
	** While it is processing the command we will get back "chnStaBusy" bytes. 
	** We need to skip past these. If the shield generated a data in packet, we
	** will get clsDataIn. If the shield terminated the command and didn't generate
	** a data packet, we will get chnStaDone.
	*/
	tmsStart = MtdsHalTmsElapsed();
	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}
		bRcv = MtdsHalPutSpiByte(chnCmdRead);
		if ((bRcv == clsDataIn) || (bRcv == chnStaDone)) {
			break;
		}
		if ((MtdsHalTmsElapsed() - tmsStart) > tmsDhdrTimeout) {
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!RdDhdr timeout");
#endif
#endif
			pdhdr->cls = chnStaTimeout;
			return false;
		}
	}

	/* Stick the first byte in the buffer.
	*/
	*pb++ = bRcv;
	cbCur += 1;

	/* Check that we have the class byte for a data packet.
	*/
	if (bRcv != clsDataIn) {
		return false;
	}

	/* Read the rest of the header.
	*/
	while (cbCur < sizeof(DHDR)) {
		while (!MtdsHalSpiReady()) {
		}
		bRcv = MtdsHalPutSpiByte(chnCmdRead);
		*pb++ = bRcv;
		cbCur +=1;
	}

	if (pdhdr->cb > cbDhdrDataInMax) {
		/* The cb field is too large for this to be a valid header. Either the host
		** sent us a bad packet, or it got screwed up by a channel error.
		*/
		pdhdr->cls = chnStaDataSize;
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
		Serial.println("!RdDhdr data size");
#endif
#endif
		return false;
	}

	return true;
		
}

/* ------------------------------------------------------------ */
/***	MtdsSendData(cb, pb)
**
**	Parameters:
**		cb		- number of bytes to send
**		pb		- pointer to the bytes to send
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		This functions writes the specified number of bytes into the
**		transmit buffer to the shield. Because the shield uses the SPI
**		port in enhanced mode with FIFO, we can burst the data quickly.
**		However, we need to be careful to not overrun the FIFO, so we
**		burst it in bursts of a maximum of 8 bytes and then wait a bit.
*/

void MtdsSendData(uint16_t cb, uint8_t * pb) {
	int		cbCur;

	for (cbCur = 0; cbCur < cb; cbCur++) {
		while (!MtdsHalSpiReady()) {
		}
		MtdsHalPutSpiByte(*pb++);
	}

}

/* ------------------------------------------------------------ */
/***	MtdsReadData(cb, pb)
**
**	Parameters:
**		cb		- number of bytes to receive from shield
**		pb		- buffer to receive the data, pb==0 means to discard the data
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if a time-out occurs.
**
**	Description:
**		Read the specified number of bytes from the shield.
*/

void MtdsReadData(uint16_t cb, uint8_t * pb) {
	int		cbCur;
	uint8_t	bRcv;

	cbCur = 0;

	while(cbCur < cb) {
		while (!MtdsHalSpiReady()) {
		}
		bRcv = MtdsHalPutSpiByte(chnCmdRead);
		if (pb != 0) {
			*pb++ = bRcv;
		}
		cbCur += 1;
	}

}

/* ------------------------------------------------------------ */
/***	MtdsWaitUntilShieldIdle()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Wait until the shield indicates that it had finished executing the
**		last command. 
*/

bool MtdsWaitUntilShieldIdle() {
	uint8_t		bTmp;
	uint32_t	tmsStart;

	tmsStart = MtdsHalTmsElapsed();
	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}
		MtdsHalEnableSlave(true);
		bTmp = MtdsHalPutSpiByte(chnCmdRead);
		MtdsHalEnableSlave(false);
		if (bTmp == chnStaIdle) {
			break;
		}
#if !defined(__MTDSDEBUG__)
		if ((MtdsHalTmsElapsed() - tmsStart) > tmsIdleTimeout) {
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!WaitIdle timeout");
#endif
#endif
			return false;
		}
#endif
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MtdsWaitUntilShieldBusy()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Wait until we get a chnStaBusy from the shield. This indicates that the
**		SPI FIFOs have been flushed of any previous characters that may have been
**		there prior to the transmission of the command packet. 
*/

bool MtdsWaitUntilShieldBusy() {
	uint8_t		bTmp;
	uint32_t	tmsStart;

	tmsStart = MtdsHalTmsElapsed();
	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}
		MtdsHalEnableSlave(true);
		bTmp = MtdsHalPutSpiByte(chnCmdRead);
		MtdsHalEnableSlave(false);
		if (bTmp == chnStaBusy) {
			break;
		}
#if !defined(__MTDSDEBUG__)
		if ((MtdsHalTmsElapsed() - tmsStart) > tmsBusyTimeout) {
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!WaitBusy timeout");
#endif
#endif
			return false;
		}
#endif
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MtdsWaitUntilShieldDone()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Wait until the shield indicates that it had finished executing the
**		last command. 
*/

bool MtdsWaitUntilShieldDone() {
	uint8_t		bTmp;
	uint32_t	tmsStart;

	tmsStart = MtdsHalTmsElapsed();
	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}
		MtdsHalEnableSlave(true);
		bTmp = MtdsHalPutSpiByte(chnCmdRead);
		MtdsHalEnableSlave(false);
		if (bTmp == chnStaDone) {
			break;
		}
#if !defined(__MTDSDEBUG__)
		if ((MtdsHalTmsElapsed() - tmsStart) > tmsIdleTimeout) {
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!WaitDone timeout");
#endif
#endif
			return false;
		}
#endif
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MtdsWaitUntilShieldReady()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns the ending condition.
**
**	Errors:
**		none
**
**	Description:
**		Wait until the shield indicates that it is ready to accept a
**		data out packet. The shield will return chnStaReady when it is ready
**		to accept a data packet.
**		Normally this function returns when the shield has sent chnStaReady. However,
**		it can terminate because the shield aborted the command by returning
**		chnStaAbort, or we timed out waiting for the shield to become ready or
**		abort.
**		This function returns the character that caused the end condition, or 0 if
**		it timed out.
*/

uint8_t MtdsWaitUntilShieldReady() {
	uint8_t	bTmp;
	uint32_t	tmsStart;

	tmsStart = MtdsHalTmsElapsed();
	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}		
		MtdsHalEnableSlave(true);
		bTmp = MtdsHalPutSpiByte(chnCmdRead);
		MtdsHalEnableSlave(false);
		if ((bTmp == chnStaReady) || (bTmp == chnStaAbort)) {
			/* We are waiting for the shield to indicate that it is ready for a
			** data packet, or that it wants to abort the command.
			*/
			break;
		}
#if !defined(__MTDSDEBUG__)
		if ((MtdsHalTmsElapsed() - tmsStart) > tmsReadyTimeout) {
			/* We timed out waiting for the expected response.
			*/
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!WaitReady timeout");
#endif
#endif
			return chnStaTimeout;
		}
#endif
	}

	return bTmp;
}

/* ------------------------------------------------------------ */
/***	MtdsWaitUntilShieldSync()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		Wait until the shield indicates that it is ready to accept a
**		data out packet. It will return chnStaReady when it is ready
**		to accept a data packet.
*/

bool MtdsWaitUntilShieldSync() {
	uint8_t	bTmp;
	uint32_t	tmsStart;

	tmsStart = MtdsHalTmsElapsed();
	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}		
		MtdsHalEnableSlave(true);
		bTmp = MtdsHalPutSpiByte(chnCmdRead);
		MtdsHalEnableSlave(false);
		if (bTmp == chnStaSync) {
			break;
		}
#if !defined(__MTDSDEBUG__)
		if ((MtdsHalTmsElapsed() - tmsStart) > tmsSyncTimeout) {
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!WaitSync timeout");
#endif
#endif
			return false;
		}
#endif
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MtdsResumeChannel()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful, false if it times out waiting for shield
**
**	Description:
**		Following an abort of the command by the shield, we need to send
**		chnCmdResume until it goes to the idle state.
*/

bool MtdsResumeChannel() {
	uint8_t	bTmp;
	uint32_t	tmsStart;

	tmsStart = MtdsHalTmsElapsed();

	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}		
		MtdsHalEnableSlave(true);
		bTmp = MtdsHalPutSpiByte(chnCmdResume);
		MtdsHalEnableSlave(false);
		if (bTmp == chnStaDone) {
			break;
		}
#if !defined(__MTDSDEBUG__)
		if ((MtdsHalTmsElapsed() - tmsStart) > tmsResumeTimeout) {
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!WaitResume timeout");
#endif
#endif
			return false;
		}
#endif
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MtdsBeginUpdate()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		Returns chnStaSuccess if successful, other channel status code if not
**
**	Description:
**		This issues the channel command to the shield firmware to
**		launch the firmware update process.
*/

uint8_t MtdsBeginUpdate() {
	uint8_t		bTmp;
	uint32_t	tmsStart;

	tmsStart = MtdsHalTmsElapsed();

	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}		
		MtdsHalEnableSlave(true);
		bTmp = MtdsHalPutSpiByte(chnCmdUpdate);
		MtdsHalEnableSlave(false);
		if (bTmp == chnStaUpdate) {
			break;
		}
		if ((bTmp == chnStaNak) || (bTmp == chnStaAbort) ) {
			return bTmp;
		}

#if !defined(__MTDSDEBUG__)
		if ((MtdsHalTmsElapsed() - tmsStart) > tmsUpdateTimeout) {
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!WaitUpdate timeout");
#endif
#endif
			return chnStaTimeout;
		}
#endif
	}

	return chnStaSuccess;

}

/* ------------------------------------------------------------ */
/***	MtdsQueryUpdate()
**
**	Parameters:
**		none
**
**	Return Values:
**		Returns update state code returned by the display device
**
**	Errors:
**		Errors are indicated by the update status code returned
**
**	Description:
**		Send chnCmdRead to the display device and get the returned
**		character.
*/

uint8_t	MtdsQueryUpdate() {
	uint8_t		bTmp;
	uint8_t		sta;

	usleep(tusPacketDelay);
	while (!MtdsHalSpiReady()) {
	}		
	MtdsHalEnableSlave(true);
	bTmp = MtdsHalPutSpiByte(chnCmdRead);
	MtdsHalEnableSlave(false);

	if (bTmp == chnStaNak) {
		/* The firmware updater got a fatal error. The update failed and we
		** can't recover.
		*/
		sta = staUpdateError;
	}
	else if (bTmp == chnStaAbort) {
		/* The firmware updater was unable to start the update process, but
		** the current firmware image is still intact. Tell the updater to
		** resume the current firmware image. The updater will transfer control
		** to the reset entry point for the firmware image. We send chnCmdResume
		** until we get back chnStaStartup. This indicates that the device firmware
		** is doing its reset initialization.
		*/
		while (true) {
			usleep(tusPacketDelay);
			while (!MtdsHalSpiReady()) {
			}		
			MtdsHalEnableSlave(true);
			bTmp = MtdsHalPutSpiByte(chnCmdResume);
			MtdsHalEnableSlave(false);
			if (bTmp == chnStaStartup) {
				break;
			}
		}
		sta = staUpdateAbort;
	}
	else if (bTmp == chnStaStartup) {
		/* The firmware updater has completed the update and transferred control
		** to the beginning of the new firmware image. It is in the process of
		** initializing itself.
		*/
		sta = staUpdateSuccess;
	}
	else {
		/* The updater is still working.
		*/
		sta = staUpdateBusy;
	}

	return sta;

}

/* ------------------------------------------------------------ */
/***	ProcName
**
**	Parameters:
**
**	Return Values:
**
**	Errors:
**
**	Description:
**
*/


/* ------------------------------------------------------------ */
/***	ProcName
**
**	Parameters:
**
**	Return Values:
**
**	Errors:
**
**	Description:
**
*/

/* ------------------------------------------------------------ */

/************************************************************************/

