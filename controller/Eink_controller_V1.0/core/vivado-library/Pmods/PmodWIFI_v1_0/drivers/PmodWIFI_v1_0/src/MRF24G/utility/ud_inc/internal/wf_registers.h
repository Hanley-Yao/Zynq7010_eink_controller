/*******************************************************************************
 MRF24WG Universal Driver Registers

  Summary: This module contains MRF24WG register definitions

  Description: None
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

#ifndef __WF_REGISTERS_H
#define __WF_REGISTERS_H

#ifdef __cplusplus
extern "C" {
#endif


// Used when accessing MRF24WG registers
#define WF_READ_REGISTER_MASK               ((uint8_t)0x40)
#define WF_WRITE_REGISTER_MASK              ((uint8_t)0x00)
#define SPI_WRITE_MASK                      ((uint8_t)0x00)     // bit 0 = 0
#define SPI_READ_MASK                       ((uint8_t)0x01)     // bit 0 = 1
#define SPI_AUTO_INCREMENT_ENABLED_MASK     ((uint8_t)0x00)     // bit 1 = 0
#define SPI_AUTO_INCREMENT_DISABLED_MASK    ((uint8_t)0x02)     // bit 1 = 1


/*--------------------------------*/
/* MRF24W 8-bit Host Registers */
/*--------------------------------*/
#define WF_HOST_INTR_REG            ((uint8_t)0x01)  /* 8-bit register containing 1st level interrupt bits. */
#define WF_HOST_MASK_REG            ((uint8_t)0x02)  /* 8-bit register containing 1st level interrupt mask. */

/*---------------------------------*/
/* MRF24W 16-bit Host Registers */
/*---------------------------------*/
#define WF_HOST_MAIL_BOX_0_MSW_REG  ((uint16_t)0x10)
#define WF_HOST_MAIL_BOX_0_LSW_REG  ((uint16_t)0x12)

#define WF_HOST_RESET_REG           ((uint16_t)0x3c)
#define WF_HOST_RESET_MASK          ((uint16_t)0x0001)

/* Scratchpad registers */
#define WF_SCRATCHPAD_0_REG         ((uint16_t)0x3d)
#define WF_SCRATCHPAD_1_REG         ((uint16_t)0x3e)

#define WF_HOST_INTR2_REG           ((uint16_t)0x2d) /* 16-bit register containing 2nd level interrupt bits */
#define WF_HOST_INTR2_MASK_REG      ((uint16_t)0x2e)
#define WF_HOST_WFIFO_BCNT0_REG     ((uint16_t)0x2f) /* 16-bit register containing available write size for fifo 0 (data tx)*/
                                                     /* (LS 12 bits contain the length)                                     */
                                                       
#define WF_HOST_WFIFO_BCNT1_REG     ((uint16_t)0x31) /* 16-bit register containing available write size for fifo 1 (mgmt tx)*/
                                                     /* (LS 12 bits contain the length)                                     */

#define WF_HOST_RFIFO_BCNT0_REG     ((uint16_t)0x33) /* 16-bit register containing number of bytes in read fifo 0 (data rx) */
                                                     /* (LS 12 bits contain the length)                                     */
                                                     
#define WF_HOST_RFIFO_BCNT1_REG     ((uint16_t)0x35) /* 16-bit register containing number of bytes in read fifo 1 (mgmt rx) */
                                                     /* (LS 12 bits contain the length)                                     */
                                                     
                                                       
#define WF_PSPOLL_H_REG             ((uint16_t)0x3d) /* 16-bit register used to control low power mode                      */
#define WF_INDEX_ADDR_REG           ((uint16_t)0x3e) /* 16-bit register to move the data window                             */
#define WF_INDEX_DATA_REG           ((uint16_t)0x3f) /* 16-bit register to read or write address-indexed register           */

/*----------------------------------------------------------------------------------------*/
/* WiFi registers accessed via the WF_INDEX_ADDR_REG and WF_INDEX_DATA_REG registers */
/*----------------------------------------------------------------------------------------*/
#define WF_HW_STATUS_REG            ((uint16_t)0x2a) /* 16-bit read only register providing hardware status bits */
#define WF_CONFIG_CTRL0_REG         ((uint16_t)0x2e) /* 16-bit register used to initiate Hard reset              */
#define WF_WAKE_CONTROL_REG         ((uint16_t)0x2f)
#define WF_SCRATCHPAD_0_REG         ((uint16_t)0x3d)
#define WF_SCRATCHPAD_1_REG         ((uint16_t)0x3e) /* 16-bit register read to determine when low power is done */
#define WF_PSPOLL_CONFIG_REG        ((uint16_t)0x40)
#define WF_XTAL_SETTLE_TIME_REG     ((uint16_t)0x41)

/* This bit mask is used in the HW_STATUS_REG to determine */
/* when the MRF24W has completed its hardware reset.       */
/*  0 : MRF24W is in reset                                 */
/*  1 : MRF24W is not in reset                             */
#define WF_HW_STATUS_NOT_IN_RESET_MASK ((uint16_t)0x1000)

/* Definitions represent individual interrupt bits for the 8-bit host interrupt registers */
/*  WF_HOST_INTR_REG and WF_HOST_MASK_REG                                                 */
#define WF_HOST_INT_MASK_INT2               ((uint8_t)0x01)
#define WF_HOST_INT_MASK_FIFO_1_THRESHOLD   ((uint8_t)0x80)
#define WF_HOST_INT_MASK_FIFO_0_THRESHOLD   ((uint8_t)0x40)
#define WF_HOST_INT_MASK_RAW_0_INT_0        ((uint8_t)0x02)     /* Data Rx */
#define WF_HOST_INT_MASK_RAW_1_INT_0        ((uint8_t)0x04)     /* Data Tx */
#define WF_HOST_INT_MASK_ALL_INT            ((uint8_t)0xff)

/* Definitions represent individual interrupt bits for */
/*  WF_HOST_INTR2_REG and WF_HOST_MASK2_REG            */
#define WF_HOST_INT_MASK_RAW_2_INT_0        ((uint16_t)0x0010)   /* Mgmt Rx  */
#define WF_HOST_INT_MASK_RAW_3_INT_0        ((uint16_t)0x0020)   /* Mgmt Tx  */
#define WF_HOST_INT_MASK_RAW_4_INT_0        ((uint16_t)0x0004)   /* Scratch  */
#define WF_HOST_INT_MASK_RAW_5_INT_0        ((uint16_t)0x0008)   /* Not used */
#define WF_HOST_INT_MASK_MAIL_BOX_0_WRT     ((uint16_t)0x0001)

/* Bit mask for all interrupts in the level 2 16-bit interrupt register */
#define WF_HOST_2_INT_MASK_ALL_INT          ((uint16_t)0xffff)

//----------
// PLL BLOCK
//----------
// Required analog registers needed for PLL work-around
#define ANALOG_PORT_3_REG_TYPE              ((uint32_t)0x09)   /* 16-bit analog register in SPI Port 3                                          */
#define ANALOG_PORT_2_REG_TYPE              ((uint32_t)0x08)   /* 16-bit analog register in SPI Port 2                                          */
#define ANALOG_PORT_1_REG_TYPE              ((uint32_t)0x0a)   /* 16-bit analog register in SPI Port 1                                          */
#define ANALOG_PORT_0_REG_TYPE              ((uint32_t)0x0b)   /* 16-bit analog register in SPI Port 0                                          */

#define PLL9_REG   ((uint32_t)(9 * 2)) // SPI Port 3 Registers (Port 5 if going through Master SPI controller)
#define PLL8_REG   ((uint32_t)(8 * 2))
#define PLL7_REG   ((uint32_t)(7 * 2))
#define PLL6_REG   ((uint32_t)(6 * 2))
#define PLL5_REG   ((uint32_t)(5 * 2))
#define PLL4_REG   ((uint32_t)(4 * 2))
#define PLL3_REG   ((uint32_t)(3 * 2))
#define PLL2_REG   ((uint32_t)(2 * 2))
#define PLL1_REG   ((uint32_t)(1 * 2))
#define PLL0_REG   ((uint32_t)(0 * 2))

#define OSC0_REG            ((uint32_t)(0 * 2))
#define OSC1_REG            ((uint32_t)(1 * 2))
#define OSC2_REG            ((uint32_t)(2 * 2))
#define PLDO_REG            ((uint32_t)(3 * 2))
#define BIAS_REG            ((uint32_t)(4 * 2))
#define ANALOG_SPARE_REG    ((uint32_t)(5 * 2))

// Host Reset register bit masks
#define HR_HOST_ANA_SPI_EN_MASK               ((uint16_t)0x01 << 12)
#define HR_HOST_ANA_SPI_DOUT_MASK             ((uint16_t)0x01 << 10)
#define HR_HOST_ANA_SPI_CLK_MASK              ((uint16_t)0x01 << 9)


//---------------
// END PLL BLOCK
//---------------
uint8_t  Read8BitWFRegister(uint8_t regId);
void     Write8BitWFRegister(uint8_t regId, uint8_t value);
void     Write16BitWFRegister(uint8_t regId, uint16_t value);
uint16_t Read16BitWFRegister(uint8_t regId);
void WriteWFArray(uint8_t regId, const uint8_t *p_Buf, uint16_t length);
void ReadWFArray(uint8_t  regId, uint8_t *p_Buf, uint16_t length);

#ifdef __cplusplus
}
#endif

#endif /* __WF_REGISTERS_H */

