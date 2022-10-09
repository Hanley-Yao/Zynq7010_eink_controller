/*******************************************************************************
 MRF24WG SPI Stub Functions

  Summary: Functions to control MRF24WG RESET and HIBERNATE pins need by the
           Universal Driver.  Functions in this module should not be called
           directly by the application code.

*******************************************************************************/

/* MRF24WG0M Universal Driver
*
* Copyright (c) 2012-2013, Microchip <www.microchip.com>
* Contact Microchip for the latest version.
*
* This program is free software; distributed under the terms of BSD
* license:
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1.    Redistributions of source code must retain the above copyright notice, this
*        list of conditions and the following disclaimer.
* 2.    Redistributions in binary form must reproduce the above copyright notice,
*        this list of conditions and the following disclaimer in the documentation
*        and/or other materials provided with the distribution.
* 3.    Neither the name(s) of the above-listed copyright holder(s) nor the names
*        of its contributors may be used to endorse or promote products derived
*        from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//==============================================================================
//                                  INCLUDES
//==============================================================================
// board-specific includes
#include <NetworkProfile.x>
#include "../ud_inc/shared/wf_universal_driver.h"
#include "../../../DEIPcK/utility/System.h"


/*****************************************************************************
  Function:
    void WF_SpiInit(void);

  Summary:
    Initializes SPI controller used to communicate with MRF24WG

  Description:
    Called by Universal Driver during initialization to initialize SPI interface.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_SpiInit(void)
{
    volatile uint8_t rxData;

#if defined(__PIC32MZ__)
    WF_INT_PPS();
    WF_HIB_PPS();
    WF_RESET_PPS();
    WF_CS_PPS();
    WF_SCK_PPS();
    WF_SDI_PPS();
    WF_SDO_PPS();
#endif

    // The MRF24WG chip select line will be controlled using an I/O pin, not by
    // the SPI controller.
    WF_CS_IO       = 1;     // set the level high (chip select disabled)
    WF_CS_TRIS     = 0;     // Configure the I/O pin as an output and drive it

    // disable the three possible SPI interrupts (SP1 Fault, SP1 Rx done,
    // SPI1 Transfer Done).  Universal Driver does not require SPI interrupts.
//    SPI_IECxCLR = 0x03800000;  //
    WIFI_SPI_INT_EIE     = 0;
    WIFI_SPI_INT_TXIE    = 0;
    WIFI_SPI_INT_RXIE    = 0;

    // disable SPI controller
    WIFI_SPICONbits.ON = 0;

    // clear the receive buffer
    rxData = WIFI_SPIBUF;
    (void) rxData;  //  prevent unsued warning

    // set the SPI baud rate to 10MHz
    //   Fsck = Fpb / (2 * (SPI1BRG + 1) = 80MHz / (2 * (3 + 1)) = 80MHz / 8 = 10MHz
    WIFI_SPIBRG = max((((int) ((GetPeripheralClock() + WF_SPI_FREQ) / 2 / WF_SPI_FREQ)) - 1), 0);
                  
    // configure SPI1:
    //   * Master Mode enabled (MSTEN = 1)
    //   * Clock Polarity is idle high, active low (CKP = 1)
    //   * Serial output data changes on transition from idle clock state to active
    //       clock state, or high to low transition (CKE = 0)
    //   * Data sampled at end of output time (SMP = 1), on rising edge
    WIFI_SPICON = 0x00000260;

    // enable SPI controller
    WIFI_SPICONbits.ON = 1;
}

/*****************************************************************************
  Function:
    void WF_SpiEnableChipSelect(void);

  Summary:
    Selects the MRF24WG SPI by setting the CS line low.

  Description:
    Called by Universal Driver when preparing to transmit data to the MRF24WG.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_SpiEnableChipSelect(void)
{
    // if the SPI controller is being shared with another device then save its
    // context here and configure the SPI controller for the MRF24WG
    // (not needed for this hardware platform)

    // select the MRF24WG
    WF_CS_IO = 0;
}

/*****************************************************************************
  Function:
    void WF_SpiDisableChipSelect(void);

  Summary:
    Deselects the MRF24WG SPI by setting CS high.

  Description:
    Called by Universal Driver after completing an SPI transaction.

 Parameters:
    None

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_SpiDisableChipSelect(void)
{
    // deselect the MRF24WG
    WF_CS_IO = 1;

    // if the SPI controller is being shared with another device then restore its
    // context here from the context that was saved in mrf_spi_enable_cs().
    // (not needed for this hardware platform)

}

/*****************************************************************************
  Function:
    void WF_SpiTxRx(uint8_t *p_txBuf, uint16_t txLength, uint8_t *p_rxBuf, uint16_t rxLength);

  Summary:
    Transmits and receives SPI bytes with the MRF24WG.

  Description:
    Called by Universal Driver to communicate with the MRF24WG.

 Parameters:
    p_txBuf  -- pointer to the transmit buffer
    txLength -- number of bytes to be transmitted from p_txBuf
    p_rxBuf  -- pointer to receive buffer
    rxLength -- number of bytes to read and copy into p_rxBuf

  Returns:
    None

  Remarks:
    Should not be called directly from application code.
*****************************************************************************/
void WF_SpiTxRx(const uint8_t *p_txBuf,
                uint16_t txLength,
                uint8_t *p_rxBuf,
                uint16_t rxLength)
{
    uint16_t byteCount;
    uint16_t i;
    volatile uint8_t  rxTrash;

    // TODO: need a check either here or somewhere else to flag an error if
    //       MRF24WG is in hibernate mode.  Another stub function to check if
    //       in hibernate mode?
    
    // total number of bytes to clock out is whichever is larger, txLength or rxLength
    byteCount = (txLength >= rxLength)?txLength:rxLength;

    // for each byte being clocked 
    for (i = 0; i < byteCount; ++i)
    {
        /* if still have bytes to transmit from tx buffer */
        if (txLength > 0)
        {
            WIFI_SPIBUF = *p_txBuf++;
            --txLength;
        }
        /* else done writing bytes out from tx buffer */
        else
        {
            WIFI_SPIBUF = 0xff;  /* clock out a "don't care" byte */
        }

        // wait until byte in SPI Tx buffer has fully clocked and the incoming
        // byte is fully received
        while (!WIFI_SPISTATbits.SPITBE || !WIFI_SPISTATbits.SPIRBF);

        // if still have bytes to read into rx buffer
        if (rxLength > 0)
        {
            *p_rxBuf++ = WIFI_SPIBUF;
            --rxLength;
        }
        // else done reading bytes into rx buffer
        else
        {
            rxTrash = WIFI_SPIBUF;  // read and throw away byte
            (void) rxTrash;  // prevent unused warning
        }
    }  // end for loop 
}
