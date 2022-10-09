/********************************************************************************/
/*																				*/
/*	mtds.cpp	--	Digilent Multi-Touch Display Shield Library					*/
/*																				*/
/********************************************************************************/
/*	Author: 	Gene Apperson													*/
/*	Copyright 2015, Digilent, Inc. All rights reserved.							*/
/********************************************************************************/
/*  Module Description: 														*/
/*																				*/
/*																				*/
/********************************************************************************/
/*  Revision History:															*/
/*																				*/
/*	2015/08/03(GeneApperson): Created											*/
/*	2016-09-27(GeneApperson): Changed calls to low level driver functions to	*/
/*		use functions in the new hardware abstraction layer to make library		*/
/*		more portable across platforms.											*/
/*	2016-09-27(GeneApperson) Changed conditionals from __SIM__ to MPIDE to make	*/
/*		it more explicit that it was for generating debugging output when being	*/
/*		built under MPIDE for testing.											*/
/*  12/20/2017(atangzwj): Replaced delay functions with sleep                   */
/*																				*/
/********************************************************************************/

#define	OPT_BOARD_INTERNAL

/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include	<stdlib.h>
#include	<string.h>

#include	<stdint.h>

#include	"ProtoDefs.h"
#include	"mtds.h"
#include	"MtdsCore.h"
#include	"MtdsHal.h"
#include "sleep.h"

/* ------------------------------------------------------------ */
/*				Local Type Definitions							*/
/* ------------------------------------------------------------ */

//#define	__MTDSTRACE__

/* ------------------------------------------------------------ */
/*				Global Variables								*/
/* ------------------------------------------------------------ */

/* Instantiate single static instances of the interface object classes.
*/
MTDS	mtds;
MTFS	mtfs;
MTWS	mtws;

extern RHDR *	prhdrMtdsRet;
extern DHDR *	pdhdrMtdsData;
extern uint8_t	rgbMtdsRetVal[cbRetValInit];

/* ------------------------------------------------------------ */
/*				Local Variables									*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Forward Declarations							*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				Procedure Definitions							*/
/* ------------------------------------------------------------ */


/* ------------------------------------------------------------ */
/*				MTDS Object Class Implementation				*/
/* ------------------------------------------------------------ */
/***	MTDS::MTDS()
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
**		Default constructor.
*/

MTDS::MTDS() {

	fInitialized = false;
	fUpdating = false;

	clsLastError = 0;
	cmdLastError = 0;
	staLastError = staCmdSuccess;

	tusElapsed = 0;

}

/* ------------------------------------------------------------ */
/***	MTDS::~MTDS()
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
**		Default destructor
*/

MTDS::~MTDS() {

}

/* ------------------------------------------------------------ */
/***	MTDS::begin()
**
**	Parameters:
**
**	Return Values:
**
**	Errors:
**
**	Description:
**		Intialize the library, establish contact with the firmware running on
**		the shield and initialize it for operation.
*/

bool MTDS::begin() {

	return begin(pinMtdsSelStd, frqMtdsSpiDefault);

}

/* ------------------------------------------------------------ */
/***	MTDS::begin(pinSel, frqSpi)
**
**	Parameters:
**		pinSelInit		- digital pin number to use for SPI CS
**		frqSpi			- SPI clock frequency to use
**
**	Return Values:
**		no return value
**
**	Errors:
**		Returns true if successful, false if not.
**
**	Description:
**		Intialize the library, establish contact with the firmware running on
**		the shield and initialize it for operation.
*/

bool MTDS::begin(int pinSelInit, uint32_t frqSpi) {
	int		cntInit;

	/* Set up the basic hardware environment.
	*/
	MtdsHalInit(pinSelInit);

	/* Initialize the SPI port that we will use to talk to the shield. Set up the
	** other pins used by the interface.
	*/
	MtdsHalInitSpi(_SPI_BASE, frqSpi);

	if (MtdsHalResetDisplay(pinSelInit)) {
		sleep(2);
	}

	/* We need to establish communication with the shield. Depending on how quickly
	** we got called, the shield might still be doing its power on reset processing.
	*/
	usleep(1000);
	if (!MtdsSyncChannel()) {
		return false;
	}

	cntInit = 10;
	while (true) {
		if (mtds.FInitDisplay()) {
			break;
		}
		else {
			cntInit -= 1;
			if (cntInit < 0) {
				return false;
			}
			sleep(1);
		}
	}

	mtds.ClearDisplay(0);

	fInitialized = true;
	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::end()
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
**		Tell the display shield that we aren't interested in talking to it anymore.
**		After calling this, it is necessary to call MTDS::begin() in order to start
**		using it again.
*/

void MTDS::end() {

	fInitialized = false;

}

/* ------------------------------------------------------------ */
/***	MTDS::GetStatusPin(idPin)
**
**	Parameters:
**		idPin	- identifier for pin to check (0=PinA, 1=PinB)
**
**	Return Values:
**		Returns state of specified status pin. True if high, false if low.
**
**	Errors:
**		none
**
**	Description:
**		Check the state of the specified status pin and return true if high. The
**		status pin being low indicates that the shield is signaling for
**		attention.
*/

bool MTDS::GetStatusPin(int idPin) {

	return MtdsHalGetStatusPin(idPin);

}

/* ------------------------------------------------------------ */
/***	MTDS::MtdsSyncChannel()
**
**	Parameters:
**		none
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if successful. False if unable to establish
**		communications with the shield.
**
**	Description:
**		Wait for the shield to be ready to communicate and then
**		synchroniza communications with the shield firmware.
**		Depending on when this is called, the shield firmware may still be
**		in the process of power on initialization, it may be in the middle of
**		sending back a status packet or sending a data packet. This is being
**		called because we have lost communication synchronization with the shield
**		or we never had it to begin with.
**		The procedure is as follows:
**			Send chnCmdSync bytes to the shield until it responds with a chnStaSync.
**			Because the first chnStaSync we see coming back could possible be data
**			from a data packet being sent, we keep doing this until we have seen
**			ten chnStaSync bytes in a row.
**			Once we have seen ten chnStaSync bytes in a row, we assume that the shield
**			communication state machine is in the sync state. We then send chnCmdStart
**			bytes to the shield until we get back a chnStaIdle.
**			It should not normally take more than two chnCmdStart bytes before we see
**			the first chnStaIdle, so if we send more than five without seeing the correct
**			response, we assume that the shield isn't working correctly and report an error.
**		During this whole procedure, we check for timing out and if it takes too long, we
**		assume that the shield isn't responding and report an error.
*/

bool MTDS::MtdsSyncChannel() {
	int		cntSync;
	int		cntStart;
	int		cntByte;
	uint8_t	bRcv;

	/* Get the shield into the sync state.
	*/
	cntSync = 0;
	cntByte = 0;
	while (cntSync < cbSyncCount) {
		usleep(tusSyncDelay);
		while (!MtdsHalSpiReady()) {
		}		
		MtdsHalEnableSlave(true);
		bRcv = MtdsHalPutSpiByte(chnCmdSync);
		MtdsHalEnableSlave(false);
		if (bRcv == chnStaSync) {
			cntSync += 1;
		}
		else {
			cntSync = 0;
		}

		cntByte += 1;
		if (cntByte >= cbSyncLimit) {
			/* We have sent the maximum allowed number of bytes waiting for the
			** shield to respond and we're not getting the expected result. Report
			** an error.
			*/
#if !defined(__SIM__)
			/* This needs to be suppressed when building to run under the simulator.
			** There are no communications delays when running under the simulator and the
			** return happens too fast there. Since communications errors aren't really
			** possible when running under the simulator this condition couldn't actually
			** come up anyway.
			*/
			return false;
#endif
		}
	}

	/* Now, get the shield out of the sync state and into the run state.
	*/
	cntStart = 0;
	while (true) {
		usleep(tusPacketDelay);
		while (!MtdsHalSpiReady()) {
		}		
		MtdsHalEnableSlave(true);
		bRcv = MtdsHalPutSpiByte(chnCmdStart);
		MtdsHalEnableSlave(false);
		if (bRcv == chnStaIdle) {
			break;
		}
		cntStart += 1;
		if (cntStart >= cbStartLimit) {
			return false;
		}
	}

	return true;
}

/* ------------------------------------------------------------ */
/***	MTDS::MtdsProcessCmdWr(cls, cmd, cbParam, pbParam, cbData, pbData)
**
**	Parameters:
**		cls		- command class
**		cmd		- command code
**		cbParam	- number of bytes of parameter data in command packet
**		pbParam	- pointer to parameter data to send
**		cbData	- number of bytes of data to send in data out packets
**		pbData	- pointer to data to send
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		This function will send a command packet and optionally data-out packets
**		to the shield. 
**		It will then wait for the response packet to be received.
**		This function processes time-outs and will attempt to resynchronize
**		communications with the shield if a time-out occur.
*/

void MTDS::MtdsProcessCmdWr(uint8_t cls, uint8_t cmd, uint16_t cbParam, uint8_t * pbParam,
						uint16_t cbData, uint8_t * pbData) {

	uint16_t	cbCur;
	uint8_t	*	pbCur;
	uint16_t	cbRem;
	uint8_t		chnSta;
	bool		fStat;
	uint32_t	tusStart;

	tusStart = MtdsHalTusElapsed();

	/* Send the command packet.
	*/
	clsLastError = cls;
	cmdLastError = cmd;
	staLastError = staCmdError;

#if defined(MPIDE)
#if !defined(__MTDSTRACE__)
	if ((cls == clsCmdUtil) && (cmd == cmdUtilBeginUpdate)) {
		Serial.print("Cmd Wr: cls = ");
		Serial.print(cls, HEX);
		Serial.print(" cmd = ");
		Serial.print(cmd, HEX);
		Serial.print(" cb = ");
		Serial.print(cbParam, DEC);
		Serial.print(" cbData = ");
		Serial.print(cbData, DEC);
		Serial.println();
	}
#endif
#endif

	MtdsSendCmdPacket(cls, cmd, cbParam, pbParam);
	if (!MtdsWaitUntilShieldBusy()) {
		/* Timed out waiting for display device to go to busy state. The display
		** is not responding correctly and we either have a bad communications channel,
		** the display device is in some weird state, or it has crashed.
		** Try resynchronizing the channel.
		*/
		goto lSyncError;
	}

	/* Send data out packets if requested.
	*/
	if (cbData != 0) {
		pbCur = pbData;
		cbRem = cbData;
		fStat = true;

		while (cbRem > 0) {
			/* The shield firmware may not have had time to be ready for the next
			** data packet yet. Wait until it indicates that it is ready for the data 
			** before sending it. The shield status will go busy as soon as it starts to
			** receive the command packet. It will go to ready once it has had time to
			** start processing the command and is ready for the next data packet.
			*/
			chnSta = MtdsWaitUntilShieldReady();
			if (chnSta != chnStaReady) {
				/* We either got an abort from the shield, or we timed out waiting
				** for the shield to become ready.
				*/
				if (chnSta == chnStaAbort) {
					/* The shield wants to abort the command, so we need to stop
					** sending it data packets.
					*/
#if defined(MPIDE)
#if defined(__MTDSTRACE__)
					Serial.println("!CmdWr: abort command");
#endif
#endif
					if (!MtdsResumeChannel()) {
						/* We timed out waiting for the display to resume.
						*/
						chnSta = chnStaTimeout;
						fStat = false;
					}
				}
				break;
			}

			cbCur = cbRem;
			if (cbCur > cbDataOutMax) {
				cbCur = cbDataOutMax;
			}

			MtdsSendDataPacket(cmd, cbCur, pbCur);

			cbRem -= cbCur;
			pbCur += cbCur;
		}

		if (!fStat) {
			/* MtdsWaitUntilShieldReady() returns with chnStaReady, chnStaAbort
			** or chnStaTimeout. chnStaReady and chnStaAbort have already been handled,
			** so we timed out. The display device is not responding correctly, so
			** we have a bad communications channel, it is in some weird state, or it
			** has crashed. Try resynchronizing the channel.
			*/
#if !defined(MPIDE)
#if defined(__MTDSTRACE__)
			Serial.println("!CmdWr: ready timeout");
#endif
#endif
			goto lSyncError;
		}
	}

	/* Wait for the shield to finish executing the command. Then send the command
	** to read the status packet. The shield will start sending back chnStaDone when
	** it has finished processing the command packet and the last data out packet.
	*/
	if (!MtdsWaitUntilShieldDone()) {
		/* Error waiting for the shield to go to the done state. This means that we
		** timed out waiting for a response from the shield.
		*/
#if !defined(MPIDE)
#if defined(__MTDSTRACE__)
		Serial.println("!CmdWr: shield idle timeout");
#endif
#endif
		goto lSyncError;
	}

	MtdsSendCmdPacket(clsCmdUtil, cmdUtilReadStatusPacket, 0, 0);

	/* Read the status packet to get the result.
	*/
	if (!MtdsReadStatusPacket()) {
		/* Got an error reading the status packet. Recover from the error.
		** The value in prhdrMtdsRet->cls is the channel status that indicates
		** what the error is. If it is chnStaTimeout then we timed out waiting
		** for the beginning of the status packet. Othwerwise, it is the channel
		** status byte received from the display device. In any case, we seem
		** to be out of sync with the display device.
		*/
#if !defined(MPIDE)
#if defined(__MTDSTRACE__)
		Serial.println("!CmdWr: read status packet error");
#endif
#endif
		goto lSyncError;
	}

	/* Verify that the status packet we got back is actually for the last command
	** that we sent to make sure that we are in sync with the shield.
	*/
	if (((cls & ~mskPacketCls) != (prhdrMtdsRet->cls & ~mskPacketCls)) ||
		 (cmd != prhdrMtdsRet->cmd)) {
#if !defined(MPIDE)
#if defined(__MTDSTRACE__)
		Serial.println("!CmdWr: status packet doesn't match command");
		Serial.print("   cls = ");
		Serial.print(cls, HEX);
		Serial.print(" cmd = ");
		Serial.print(cmd, HEX);
		Serial.print(" clsRhdr = ");
		Serial.print(prhdrMtdsRet->cls, HEX);
		Serial.print(" cmdRhdr = ");
		Serial.println(prhdrMtdsRet->cmd, HEX);
#endif
#endif
	}

#if defined(DEAD)
	Serial.print("Sta: cls = ");
	Serial.print(rgbMtdsRetVal[0], HEX);
	Serial.print(" cmd = ");
	Serial.print(rgbMtdsRetVal[1], HEX);
	Serial.print(" sta = ");
	Serial.print(rgbMtdsRetVal[2], HEX);
	Serial.print(" cbRet = ");
	Serial.println(rgbMtdsRetVal[3], DEC);
#endif

	staLastError = prhdrMtdsRet->sta;
	goto lCmdWrExit;

lSyncError:
	/* We seem to be in some anomolous state as the display device is not responding
	** as expected, or the display device thinks that the comm channel is out of sync.
	** We need to resynchronize the channel.
	*/
	if (MtdsSyncChannel()) {
		/* We have resynchronized the channel. Report that this command
		** failed.
		*/
		staLastError = staCmdInternalError;
	}
	else {
		/* Unable to synchronize the channel. We are totally hosed. Report
		** sync error to the caller.
		*/
		staLastError = staCmdSync;
	}

lCmdWrExit:
	;

	tusElapsed = MtdsHalTusElapsed() - tusStart;

}

/* ------------------------------------------------------------ */
/***	MTDS::MtdsProcessCmdRd(cls, cmd, cbParam, pbParam, cbData, pbData)
**
**	Parameters:
**		cls		- command class
**		cmd		- command code
**		cbParam	- number of bytes of parameter data in command packet
**		pbParam	- pointer to parameter data to send
**		cbData	- number of bytes of data to receive in data-in packets
**		pbData	- pointer to data to buffer to receive data
**
**	Return Values:
**		none
**
**	Errors:
**		none
**
**	Description:
**		This function will send a command packet and then read data-in packets
**		sent in response to the command.
**		It will then wait for the response/status packet to be received.
**		This function processes time-outs and will attempt to resynchronize
**		communications with the shield if a time-out occur.
*/

void MTDS::MtdsProcessCmdRd(uint8_t cls, uint8_t cmd, uint16_t cbParam, uint8_t * pbParam,
						uint16_t cbData, uint8_t * pbData) {
	uint16_t	cbCur;
	uint8_t	*	pbCur;
	uint16_t	cbRem;
	uint16_t	cbRead;
	bool		fStat;
	uint32_t	tusStart;

	tusStart = MtdsHalTusElapsed();

	/* Send the command packet.
	*/
	clsLastError = cls;
	cmdLastError = cmd;
	staLastError = staCmdError;

#if defined(MPIDE)
#if !defined(__MTDSTRACE__)
	Serial.print("Cmd Rd: cls = ");
	Serial.print(cls, HEX);
	Serial.print(" cmd = ");
	Serial.print(cmd, HEX);
	Serial.print(" cb = ");
	Serial.println(cbParam, DEC);
#endif
#endif

	MtdsSendCmdPacket(cls, cmd, cbParam, pbParam);
	if (!MtdsWaitUntilShieldBusy()) {
		/* Timed out waiting for display device to go to busy state. The display
		** is not responding correctly and we either have a bad communications channel,
		** the display device is in some weird state, or it has crashed.
		** Try resynchronizing the channel.
		*/
		goto lSyncError;
	}

	/* Read and process the data in packets generated by the shield.
	*/
	pbCur = pbData;
	cbRem = cbData;
	fStat = true;

	while (cbRem > 0) {

		cbCur = cbRem;
		if (cbCur > cbDataInMax) {
			cbCur = cbDataInMax;
		}

		/* Read the next data-in packet. We will generally get a data in packet
		** at this point, but if the shield terminates the command early, we
		** won't get one. The shield terminating early will be indicated by the
		** shield sending a chnStaDone instead of the initial class byte for
		** a data packet. We can also get timeout errors as well.
		** If the data read fails, the reason for the failure will be
		** indicated by the cls field of the data packet header.
		** Check the cls byte of the data packet header. If it is chnStaIdle,
		** we got an early termination of the command by the shield, but
		** it isn't an error. It just means that we aren't getting data
		** from the shield. This might be because of a command level error
		** (e.g. bad parameter to the command), but it isn't an error in the
		** communications channel itsel.
		** Otherwise, we have a communications error and we need to attempt to
		** recover the channel.
		*/
		if (!MtdsReadDataPacket(cbCur, pbCur, &cbRead)) {
			if (pdhdrMtdsData->cls != chnStaDone) {
				fStat = false;
			}
			break;
		}
		
		cbRem -= cbRead;
		pbCur += cbRead;

		if (cbRead < cbCur) {
			/* The shield didn't send as much as we asked for. We have an early
			** end to the loop.
			*/
			break;
		}
	}

	if (!fStat) {
		/* The above loop terminated because of some communications error.
		** MtdsReadDataPacket() will get a data packet or the display device
		** terminated the command by sending chnStaDone, or we timed out. A timeout
		** means we are out of sync with the display device. To recover from the
		** error, we attempt to resynchronize communications with the display.
		*/
#if defined(MPIDE)
#if !defined(__MTDSTRACE__)
		Serial.println("!CmdRd: timeout");
#endif
#endif
		goto lSyncError;
	}

	/* Wait for the shield to finish executing the command. Then send the command
	** to read the status packet. The shield will start sending back chnStaDone when
	** it has finished processing the command packet and the last data out packet.
	*/
	if (!MtdsWaitUntilShieldDone()) {
		/* Error waiting for the shield to go to the done state. This means that we
		** timed out waiting for a response from the shield.
		*/
#if defined(MPIDE)
#if !defined(__MTDSTRACE__)
		Serial.println("!CmdRd: shield done timeout");
#endif
#endif
		goto lSyncError;
	}
	MtdsSendCmdPacket(clsCmdUtil, cmdUtilReadStatusPacket, 0, 0);

	/* Get the status packet to get the result.
	*/
	if (!MtdsReadStatusPacket()) {
		/* Got an error reading the status packet. This either means that we
		** timed out waiting for the first byte of the status packet. We seem
		** to be out of sync with the display device.
		*/
#if defined(MPIDE)
#if !defined(__MTDSTRACE__)
		Serial.println("!CmdRd: read status packet error");
#endif
#endif
		goto lSyncError;
	}

	staLastError = prhdrMtdsRet->sta;
	goto lCmdRdExit;

lSyncError:
	/* We seem to be in some anomolous state as the display device is not responding
	** as expected, or the display device thinks that the comm channel is out of sync.
	** We need to resynchronize the channel.
	*/
	if (MtdsSyncChannel()) {
		/* We have resynchronized the channel. Report that this command
		** failed.
		*/
		staLastError = staCmdInternalError;
	}
	else {
		/* Unable to synchronize the channel. We are totally hosed. Report
		** sync error to the caller.
		*/
		staLastError = staCmdSync;
	}

lCmdRdExit:
	;

	tusElapsed = MtdsHalTusElapsed() - tusStart;

}

/* ------------------------------------------------------------ */
/***	MTDS::FCheckName
**
**	Parameters:
**		sz		- name string to check
**		cls		- command class
**		cmd		- command opcode
**
**	Return Values:
**		none
**
**	Errors:
**		Returns true if string is OK, false if not
**
**	Description:
**		Check that the specified string is acceptable. If it is not,
**		set the class and command into the return status buffer.
*/ 

bool MTDS::FCheckName(char * sz, uint8_t cls, uint8_t cmd) {

	if (strlen(sz) > cchNameMax) {
		clsLastError = cls;
		cmdLastError = cmd;
		staLastError = staGdiBadParameter;
		return false;
	}

	return true;
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
/*				XXXX Object Class Implementation				*/
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

/********************************************************************************/

