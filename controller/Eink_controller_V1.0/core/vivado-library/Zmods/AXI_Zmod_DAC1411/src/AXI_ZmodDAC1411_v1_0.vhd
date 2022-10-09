
-------------------------------------------------------------------------------
--
-- File: AXI_ZmodDAC1411_v1_0.vhd
-- Author: Tudor Gherman
-- Original Project: Zmod DAC 1411 AXI Adapter
-- Date: 15 January 2020
--
-------------------------------------------------------------------------------
-- (c) 2020 Copyright Digilent Incorporated
-- All Rights Reserved
-- 
-- This program is free software; distributed under the terms of BSD 3-clause 
-- license ("Revised BSD License", "New BSD License", or "Modified BSD License")
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
--    of its contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
--
--This module provides the means to interface the Zmod DAC 1411 Low Level 
--Controller with an AXI based processing system. It includes a set of control
--and status registers that can be accessed over the AXI Lite interface, a module
--that managages the indirect access of the AD9717 SPI interface over the SPI 
--indirect access port (IAP), a circular buffer implememnted in BRAM and a bridge 
--between the AXI Stream interface and the circular buffer. Sample data is expected 
--to be defined by the PS in system memory and moved through a DMA engine to the 
--circular buffer. 
--  
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXI_ZmodDAC1411_v1_0 is
	generic (
		-- Users to add parameters here
        kBufferSize :integer := 14;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 7;
		kCrossRegCnt: integer range 0 to 31 := 12
	);
	port (
		-- Users to add ports here
		SysClk : in std_logic; 
		AxiStreamClk : in std_logic; 
		lRst_n	: in std_logic;
		sZmodControllerRst_n : out std_logic;
		lIrqOut: out std_logic;
		sInitDone_n : in std_logic;
        sCh1Out   : out std_logic_vector(13 downto 0);
        sCh2Out   : out std_logic_vector(13 downto 0);
        sDacEnOut : out std_logic;
        sCh1ScaleSelect : out std_logic;  -- 0 -> Low Gain; 1 -> High Gain; 
        sCh2ScaleSelect : out std_logic;  -- 0 -> Low Gain; 1 -> High Gain; 
        sCh1LgMultCoef : out std_logic_vector (17 downto 0); --Channel1 low gain gain compensation coefficient output port
        sCh1LgAddCoef  : out std_logic_vector (17 downto 0);  --Channel1 low gain offset compensation coefficient output port
        sCh1HgMultCoef : out std_logic_vector (17 downto 0); --Channel1 high gain gain compensation coefficient output port 
        sCh1HgAddCoef  : out std_logic_vector (17 downto 0);  --Channel1 high gain offset compensation coefficient output port 
        sCh2LgMultCoef : out std_logic_vector (17 downto 0); --Channel2 low gain gain compensation coefficient output port 
        sCh2LgAddCoef  : out std_logic_vector (17 downto 0);  --Channel2 low gain offset compensation coefficient output port 
        sCh2HgMultCoef : out std_logic_vector (17 downto 0); --Channel2 high gain gain compensation coefficient output port 
        sCh2HgAddCoef  : out std_logic_vector (17 downto 0);  --Channel2 high gain offset compensation coefficient output port 
        sAdcSPI_Idle : in std_logic; --Input flag indicating that the configuration state machine is in the IDLE state 
        sADC_SPI_CmdDone : in std_logic; --Pulse indicating that the SPI command has been succesfully completed
        sSPI_TxRdEn : in std_logic; --Read enable used by lower level IP to load data from the command FIFO
        sSPI_TxRdEnRdy : out STD_LOGIC; --the lower level IP should first assign sSPI_TxRdEn and than wait sSPI_TxRdEnRdy to be asserted before signaling command completion
        sSPI_TxDout : out std_logic_vector (23 downto 0); --Command output data
        sSPI_TxValid : out STD_LOGIC; --Command output data valid signal
        sSPI_EnTx : out STD_LOGIC; --Enable command transmit over the external SPI access interface
        sSPI_EnRx : out STD_LOGIC; --Enable command receive data over the external SPI access interface
        sSPI_RxWrEn : in std_logic; --Receive data FIFO write enable input 
        sSPI_RxDin : in std_logic_vector (7 downto 0); --Receive data input 
                        
        s_axis_mm2s_tdata : in STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_mm2s_tkeep : in STD_LOGIC_VECTOR(3 DOWNTO 0);
        s_axis_mm2s_tvalid : in STD_LOGIC;
        s_axis_mm2s_tready : out STD_LOGIC;
        s_axis_mm2s_tlast : in STD_LOGIC;

		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end AXI_ZmodDAC1411_v1_0;

architecture arch_imp of AXI_ZmodDAC1411_v1_0 is

	-- component declaration
	component AXI_ZmodDAC1411_v1_0_S00_AXI is
		generic (
		kAxiLiteDataWidth	: integer	:= 32;
		kAxiLiteAddrWidth	: integer	:= 5
		);
		port (
		lRegRstPulse : in std_logic;
	    AxiLiteClk	: in std_logic;
		lAxiAreset_n	: in std_logic;
		lAxiAwaddr	: in std_logic_vector(kAxiLiteAddrWidth-1 downto 0);
		lAxiAwprot	: in std_logic_vector(2 downto 0);
		lAxiAwvalid	: in std_logic;
		lAxiAwready	: out std_logic;
		lAxiWdata	: in std_logic_vector(kAxiLiteDataWidth-1 downto 0);
		lAxiWstrb	: in std_logic_vector((kAxiLiteDataWidth/8)-1 downto 0);
		lAxiWvalid	: in std_logic;
		lAxiWready	: out std_logic;
		lAxiBresp	: out std_logic_vector(1 downto 0);
		lAxiBvalid	: out std_logic;
		lAxiBready	: in std_logic;
		lAxiAraddr	: in std_logic_vector(kAxiLiteAddrWidth-1 downto 0);
		lAxiArprot	: in std_logic_vector(2 downto 0);
		lAxiArvalid	: in std_logic;
		lAxiArready	: out std_logic;
		lAxiRdata	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
		lAxiRresp	: out std_logic_vector(1 downto 0);
		lAxiRvalid	: out std_logic;
		lAxiRready	: in std_logic;
		
		lReg0Rd	: OUT std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg1Rd    : OUT std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg2Rd    : OUT std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg3Rd    : OUT std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg4Rd    : OUT std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg5Rd    : OUT std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg6Rd    : OUT std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg7Rd    : OUT std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg8Rd	   : OUT std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg9Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg10Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg11Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg12Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg13Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg14Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg15Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg16Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);  
        
        lAdcSPI_Idle : IN STD_LOGIC;
        sInitDone_n : in std_logic;
        lBufferFull : IN STD_LOGIC;
        lSetStop : IN STD_LOGIC; 
        lSPI_CmdRxDone : IN STD_LOGIC;
        lSPI_CmdTxDone : IN STD_LOGIC;
        lSPI_CmdTxCount : in STD_LOGIC_VECTOR(6 downto 0);
        lSPI_CmdRxCount : in STD_LOGIC_VECTOR(6 downto 0);
        lSPI_TxFifoWrEn : out STD_LOGIC;
        lSPI_RxFifoRdEn : out STD_LOGIC;
        lSPI_CmdRx : in STD_LOGIC_VECTOR(7 downto 0);
        lSPI_CmdTxRxError : in STD_LOGIC_VECTOR(3 downto 0)
        );
	end component AXI_ZmodDAC1411_v1_0_S00_AXI;
	
	component Circular_Buffer is
        generic (
        kBufferSize: integer range 0 to 1024 := 14
        );
        Port ( 
        SysClk : in STD_LOGIC;
        AxiStreamClk : in STD_LOGIC;
        AxiLiteClk : in std_logic;
        sRst_n : in STD_LOGIC;
        xsRst_n : in STD_LOGIC;
        sInitDone_n: in STD_LOGIC;
        sCh1Out : out STD_LOGIC_VECTOR (13 downto 0);
        sCh2Out : out STD_LOGIC_VECTOR (13 downto 0);
           
        s_axis_mm2s_tdata : in STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_mm2s_tkeep : in STD_LOGIC_VECTOR(3 DOWNTO 0);
        s_axis_mm2s_tvalid : in STD_LOGIC;
        s_axis_mm2s_tready : out STD_LOGIC;
        s_axis_mm2s_tlast : in STD_LOGIC;
           
        sDacEn: in STD_LOGIC;
        sTransferLength : in STD_LOGIC_VECTOR (kBufferSize-1 downto 0);
        xsTransferLength : in std_logic_vector (kBufferSize-1 downto 0); 
        sOutAddrCntRst : in std_logic;
        sDivRate : in std_logic_vector(13 downto 0);
        lBufferFull : out STD_LOGIC
        );
    end component Circular_Buffer;
    
    component SPI_Adapter is
    Port ( SysClk : in STD_LOGIC;
           AxiLiteClk : in STD_LOGIC;
           sRst_n : in std_logic;
           lRst_n : in STD_LOGIC;
           sADC_SPI_CmdDone : in std_logic;
           sSPI_CmdRunStop  : in STD_LOGIC;
           sSPI_CmdReadEn : in STD_LOGIC;
           lSPI_CmdTx : in STD_LOGIC_VECTOR(23 downto 0);
           lSPI_CmdRx : out STD_LOGIC_VECTOR(7 downto 0);
           lSPI_CmdTxDone : out STD_LOGIC;
           lSPI_CmdRxDone : out STD_LOGIC;
           lSPI_CmdTxCount : out STD_LOGIC_VECTOR(6 downto 0);
           lSPI_CmdRxCount : out STD_LOGIC_VECTOR(6 downto 0);
           lSPI_CmdTxRxError : out STD_LOGIC_VECTOR(3 downto 0);
           lTxFifoWrEn : in STD_LOGIC;
           lRxFifoRdEn : in STD_LOGIC;
           sTxFifoRdEnRdy : out STD_LOGIC;
           sTxFifoDout : out STD_LOGIC_VECTOR(23 downto 0); --
           sSPI_TxValid : out STD_LOGIC;
           sTxFifoRdEn : in STD_LOGIC; --
           sRxFifoWrEn : in STD_LOGIC; --
           sRxFifoDin : in STD_LOGIC_VECTOR (7 downto 0) --
          
           );
end component SPI_Adapter;

component HandshakeData is
   Generic (
      kDataWidth : natural := 8);
   Port (
      InClk : in STD_LOGIC;
      OutClk : in STD_LOGIC;
      iData : in STD_LOGIC_VECTOR (kDataWidth-1 downto 0);
      oData : out STD_LOGIC_VECTOR (kDataWidth-1 downto 0);
      iPush : in STD_LOGIC;
      iRdy : out STD_LOGIC;
      oAck : in STD_LOGIC := '1';
      oValid : out STD_LOGIC;
      aReset : in std_logic);
end component HandshakeData;

component ResetBridge is
   Generic (
      kPolarity : std_logic := '1');
   Port (
      aRst : in STD_LOGIC; -- asynchronous reset; active-high, if kPolarity=1
      OutClk : in STD_LOGIC;
      oRst : out STD_LOGIC);
end component ResetBridge;

signal lSync	:  std_logic_vector(3 downto 0);

signal lRegRst, lRegRstR, lRegRstPulse, lRegRst_n, sRst_n, xsRst_n, lExtRegRst_n : std_logic;
signal sDacEn   :  std_logic;
signal sTransferLength, xsTransferLength, lDinTL, xsDoutTL :  std_logic_vector (kBufferSize-1 downto 0);
signal lBufferFull, lSetStop : std_logic;
signal lAdcSPI_Idle : std_logic;
signal sOutAddrCntRst, sOutAddrCntRstR, sOutAddrCntRstPulse : std_logic;
signal sDivRate : std_logic_vector(13 downto 0);

signal lSPI_CmdTxCount : STD_LOGIC_VECTOR(6 downto 0);
signal lSPI_CmdRxCount : STD_LOGIC_VECTOR(6 downto 0);
signal lIntrEn : std_logic;
signal lCMD_TX_DONE, lCMD_RX_DONE : STD_LOGIC;
signal sSPI_CmdRunStop, SYS_SPI_CMD_R_S : STD_LOGIC;
signal sSPI_CmdReadEn, SYS_SPI_CMD_READ_EN : STD_LOGIC;
signal lSPI_CmdTx : STD_LOGIC_VECTOR(23 downto 0);
signal lSPI_CmdRx : STD_LOGIC_VECTOR(7 downto 0);
signal lSPI_CmdTxDone, lSPI_CmdRxDone : STD_LOGIC;
signal lSPI_CmdTxRxError : STD_LOGIC_VECTOR(3 downto 0);
signal lSPI_RxFifoRdEn, lSPI_TxFifoWrEn : std_logic;

signal lIrqEn : std_logic_vector(31 downto 0);

signal lReg0Rd, sReg0Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg1Rd, sReg1Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg2Rd, sReg2Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg3Rd, sReg3Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg4Rd, sReg4Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg5Rd, sReg5Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg6Rd, sReg6Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg7Rd, sReg7Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg8Rd, sReg8Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg9Rd, sReg9Rd	    :std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg10Rd, sReg10Rd	:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg11Rd, sReg11Rd	:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg12Rd, sReg12Rd	:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg13Rd, sReg13Rd	:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg14Rd, sReg14Rd	:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg15Rd, sReg15Rd	:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
signal lReg16Rd, sReg16Rd	:std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);

--Clock domain Crossing Signals
signal aHanshakeReset : std_logic;
signal Index	: integer;
signal xsValidTL, lIpushTL, lIrdyTL, lSetIpushTL, lRstIpushTL : std_logic;
type RegisterFile_t is array (kCrossRegCnt downto 0) of std_logic_vector(31 downto 0);
signal lRegisters, lRegistersDin, sRegHanshakeOut, sRegisters, lRegistersR : RegisterFile_t;
signal lIpushReg, lSetIpushReg, lIrdyReg, sValidReg, lRstIpushReg: std_logic_vector (kCrossRegCnt downto 0);
signal sAdcSPI_IdleR, sAdcSPI_IdleRdy, sAdcSPI_IdleSetPush, sAdcSPI_IdlePush, sAdcSPI_IdleRstPush, lAdcSPI_IdleValid : std_logic;
signal sAdcSPI_IdleDin, lAdcSPI_IdleDout : std_logic_vector (0 downto 0);       
        
begin

sSPI_EnTx <= SYS_SPI_CMD_R_S;
sSPI_EnRx <= SYS_SPI_CMD_READ_EN;
SYS_SPI_CMD_R_S <= sSPI_CmdRunStop;
SYS_SPI_CMD_READ_EN <= sSPI_CmdReadEn;

---------------------------------------------RESET------------------------------------------------
lExtRegRst_n <= lRst_n and (not lRegRst);
lRegRst_n <= not lRegRst;

ProcRegRstReg: process (s00_axi_aclk) 
begin
    if (s00_axi_aclk' event and s00_axi_aclk = '1') then
        if (lRst_n = '0') then
            lRegRstR <= '0';
        else
            lRegRstR <= lRegRst;
        end if;
    end if;
end process;

lRegRstPulse <= lRegRst and (not lRegRstR);

InstLaxiResetHandshake : ResetBridge
   Generic map(
      kPolarity => '0')
   Port map(
      aRst => lExtRegRst_n, -- asynchronous reset; active-high, if kPolarity=1
      OutClk => SysClk,
      oRst => sRst_n);
      
sZmodControllerRst_n <= sRst_n;      

InstSaxiResetHandshake : ResetBridge
   Generic map(
      kPolarity => '0')
   Port map(
      aRst => lExtRegRst_n, -- asynchronous reset; active-high, if kPolarity=1
      OutClk => AxiStreamClk,
      oRst => xsRst_n);
      
aHanshakeReset <= lRegRst and (not lRst_n);

-------------------------------------------------------------------------------------------------------------------------
-- Instantiation of Axi Bus Interface S00_AXI
AXI_ZmodDAC1411_v1_0_S00_AXI_inst : AXI_ZmodDAC1411_v1_0_S00_AXI
	generic map (
		kAxiLiteDataWidth	=> C_S00_AXI_DATA_WIDTH,
		kAxiLiteAddrWidth	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    lRegRstPulse => lRegRstPulse,
	    AxiLiteClk	=> s00_axi_aclk,
		lAxiAreset_n	=> lRst_n,
		lAxiAwaddr	=> s00_axi_awaddr,
		lAxiAwprot	=> s00_axi_awprot,
		lAxiAwvalid	=> s00_axi_awvalid,
		lAxiAwready	=> s00_axi_awready,
		lAxiWdata	=> s00_axi_wdata,
		lAxiWstrb	=> s00_axi_wstrb,
		lAxiWvalid	=> s00_axi_wvalid,
		lAxiWready	=> s00_axi_wready,
		lAxiBresp	=> s00_axi_bresp,
		lAxiBvalid	=> s00_axi_bvalid,
		lAxiBready	=> s00_axi_bready,
		lAxiAraddr	=> s00_axi_araddr,
		lAxiArprot	=> s00_axi_arprot,
		lAxiArvalid	=> s00_axi_arvalid,
		lAxiArready	=> s00_axi_arready,
		lAxiRdata	=> s00_axi_rdata,
		lAxiRresp	=> s00_axi_rresp,
		lAxiRvalid	=> s00_axi_rvalid,
		lAxiRready	=> s00_axi_rready,
		
	   	lReg0Rd	=> lReg0Rd,
        lReg1Rd => lReg1Rd,
        lReg2Rd => lReg2Rd,
        lReg3Rd => lReg3Rd,
        lReg4Rd => lReg4Rd,
        lReg5Rd => lReg5Rd,
        lReg6Rd => lReg6Rd,
        lReg7Rd => lReg7Rd,
        lReg8Rd => lReg8Rd,
        lReg9Rd => lReg9Rd,
        lReg10Rd => lReg10Rd,
        lReg11Rd => lReg11Rd,
        lReg12Rd => lReg12Rd,
        lReg13Rd => lReg13Rd,
        lReg14Rd => lReg14Rd,
        lReg15Rd => lReg15Rd,
        lReg16Rd => lReg16Rd,
    
        lAdcSPI_Idle => lAdcSPI_Idle,
        sInitDone_n => sInitDone_n,
        lBufferFull => lBufferFull,
        lSetStop => lSetStop, 
        lSPI_CmdRxDone => lCMD_RX_DONE,
        lSPI_CmdTxDone => lSPI_CmdTxDone,
        lSPI_CmdTxCount => lSPI_CmdTxCount,
        lSPI_CmdRxCount => lSPI_CmdRxCount,
        lSPI_TxFifoWrEn => lSPI_TxFifoWrEn,
        lSPI_RxFifoRdEn => lSPI_RxFifoRdEn,
        lSPI_CmdRx => lSPI_CmdRx,
        lSPI_CmdTxRxError => lSPI_CmdTxRxError
	);

Circular_Buffer_inst : Circular_Buffer
	port map (
        SysClk => SysClk,
        AxiStreamClk => AxiStreamClk,
        AxiLiteClk => s00_axi_aclk,
        sRst_n => sRst_n,
        xsRst_n => xsRst_n,
        sInitDone_n => sInitDone_n,
        sCh1Out => sCh1Out,
        sCh2Out => sCh2Out,
        
        s_axis_mm2s_tdata => s_axis_mm2s_tdata,
        s_axis_mm2s_tkeep => s_axis_mm2s_tkeep,
        s_axis_mm2s_tvalid => s_axis_mm2s_tvalid,
        s_axis_mm2s_tready => s_axis_mm2s_tready,
        s_axis_mm2s_tlast => s_axis_mm2s_tlast,
           
        sDacEn => sDacEn,
        sTransferLength => sTransferLength,
        xsTransferLength => xsTransferLength,
        sOutAddrCntRst => sOutAddrCntRst,
        sDivRate => sDivRate,
        lBufferFull => lBufferFull
	);
	
	SPI_Adapter_inst :SPI_Adapter
    Port map ( 
        SysClk => SysClk,
        AxiLiteClk => s00_axi_aclk,
        lRst_n => lRegRst_n,--lExtRegRst_n,
        sRst_n => sRst_n,
        --sAdcSPI_Idle => sAdcSPI_Idle,
        sADC_SPI_CmdDone => sADC_SPI_CmdDone,
        sSPI_CmdRunStop  => sSPI_CmdRunStop,
        sSPI_CmdReadEn => sSPI_CmdReadEn,
        lSPI_CmdTx => lSPI_CmdTx,
        lSPI_CmdRx => lSPI_CmdRx,
        lSPI_CmdTxDone => lSPI_CmdTxDone,
        lSPI_CmdRxDone => lSPI_CmdRxDone,
        lSPI_CmdTxCount => lSPI_CmdTxCount,
        lSPI_CmdRxCount => lSPI_CmdRxCount,
        lSPI_CmdTxRxError => lSPI_CmdTxRxError,
        lTxFifoWrEn => lSPI_TxFifoWrEn,
        lRxFifoRdEn => lSPI_RxFifoRdEn,
        sTxFifoRdEnRdy => sSPI_TxRdEnRdy,
        sTxFifoDout => sSPI_TxDout,
        sSPI_TxValid => sSPI_TxValid,
        sTxFifoRdEn => sSPI_TxRdEn,
        sRxFifoWrEn => sSPI_RxWrEn,
        sRxFifoDin => sSPI_RxDin 
        );
        
---------------------Register Clock Domain Crossing-----------------------------------
lRegisters(0) <= lReg0Rd;
lRegisters(1) <= lReg1Rd;
lRegisters(2) <= lReg6Rd;
lRegisters(3) <= lReg7Rd;
lRegisters(4) <= lReg8Rd;
lRegisters(5) <= lReg9Rd;
lRegisters(6) <= lReg10Rd;
lRegisters(7) <= lReg11Rd;
lRegisters(8) <= lReg12Rd;
lRegisters(9) <= lReg13Rd;
lRegisters(10) <= lReg14Rd;
lRegisters(11) <= lReg15Rd;
lRegisters(12) <= lReg16Rd;

---------------------REGISTERS CLOCK DOMAIN CROSSING---------------------------------------------------------------------

ProcRegRegister: process (s00_axi_aclk)  
begin
    if (s00_axi_aclk' event and s00_axi_aclk = '1') then
        if (lRst_n = '0') then
            lRegistersR <= (others => (others => '0'));
        else
            lRegistersR <= lRegisters;
        end if;
    end if;
end process;

ProcRegIpushSet: process (s00_axi_aclk) 
--Since iPush transition only trigers input data to propagate
--towrds the output if iRdy is set, it is necessary to have two distinct signals: one to monitor regster modifications
--and one to push data through the hanshake block whenever the input data was modified and the hanshake module is ready
begin
    if (s00_axi_aclk' event and s00_axi_aclk = '1') then
        if (lRst_n = '0') then
            lSetIpushReg <=  (others => '0');
            lRegistersDin <= (others => (others => '0'));
        else
            for Index in 0 to kCrossRegCnt loop
                if ((lRegistersR(Index) /= lRegisters(Index)) or (lRegRstPulse = '1')) then
                    lSetIpushReg(Index) <= '1';
                    lRegistersDin(Index) <= lRegisters(Index);
                elsif (lRstIpushReg(Index) = '1') then
                    lSetIpushReg(Index) <= '0';
                end if;
            end loop;
        end if;
    end if;
end process;

ProcRegIpush: process (s00_axi_aclk) 
begin
    if (s00_axi_aclk' event and s00_axi_aclk = '1') then
        if (lRst_n = '0') then
            lIpushReg  <=  (others => '0');
            lRstIpushReg  <=  (others => '0');
        else
            for Index in 0 to kCrossRegCnt loop
                if ((lSetIpushReg(Index) = '1') and (lIrdyReg(Index) = '1') and (lIpushReg(Index) = '0'))then
                    lIpushReg(Index) <= '1';
                    lRstIpushReg(Index) <= '1';
                else
                    lIpushReg(Index) <= '0';
                    lRstIpushReg(Index) <= '0';
                end if;
            end loop;        
        end if;
    end if;
end process;

GenerateHanshake: for InstIndex in 0 to kCrossRegCnt generate
    InstSyncHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
    	generic map (
		kDataWidth	=> 32
	   )
       Port map (
          InClk => s00_axi_aclk,
          OutClk => SysClk,
          iData => lRegistersDin(InstIndex),
          oData => sRegHanshakeOut(InstIndex),   -- synchronized output
          iPush => lIpushReg(InstIndex),
          iRdy => lIrdyReg(InstIndex),  
          oAck => '1',  
          oValid => sValidReg(InstIndex),   -- indicates valid synchronized data
          aReset => aHanshakeReset
       );
end generate GenerateHanshake;

ProcRegOData: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sRegisters <= (others => (others => '0'));
        else
            for Index in 0 to kCrossRegCnt loop
                if (sValidReg(Index) = '1') then
                    sRegisters(Index) <= sRegHanshakeOut(Index);
                end if;
            end loop;    
        end if;
    end if;
end process;

---------------------TRANSFER LENGTH CLOCK DOMAIN CROSSING---------------------------------------------------------------

ProcTLIpushSet: process (s00_axi_aclk) 
--Since iPush transition only trigers input data to propagate
--towrds the output if iRdy is set, it is necessary to have two distinct signals: one to monitor regster modifications
--and one to push data through the hanshake block whenever the input data was modified and the hanshake module is ready
begin
    if (s00_axi_aclk' event and s00_axi_aclk = '1') then
        if (lExtRegRst_n = '0') then
            lSetIpushTL <=  '0'; 
            lDinTL <= (others => '0');
        else
            if (lRegistersR(2) /= lRegisters(2)) then
                lSetIpushTL <= '1';
                lDinTL <= lReg6Rd(kBufferSize+1 downto 2);
            elsif (lRstIpushTL = '1') then
                lSetIpushTL <= '0';
            end if;
        end if;
    end if;
end process;
              
ProcTLIpush: process (s00_axi_aclk) 
begin
    if (s00_axi_aclk' event and s00_axi_aclk = '1') then
        if (lExtRegRst_n = '0') then
            lIpushTL  <=  '0';
            lRstIpushTL <= '0';
        else
                if ((lSetIpushTL = '1') and (lIrdyTL = '1') and (lIpushTL = '0'))then
                    lIpushTL <= '1';
                    lRstIpushTL <= '1';
                else
                    lIpushTL <= '0';
                    lRstIpushTL <= '0';
                end if;     
        end if;
    end if;
end process;

InstStreamTLHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> kBufferSize
    )
    Port map (
        InClk => s00_axi_aclk,
        OutClk => AxiStreamClk,
        iData => lReg6Rd(kBufferSize+1 downto 2),
        oData => xsDoutTL,   -- synchronized output
        iPush => lIpushTL,
        iRdy => lIrdyTL,  
        oAck => '1',  
        oValid => xsValidTL,   -- indicates valid synchronized data
        aReset => aHanshakeReset
        );

ProcTLOData: process (AxiStreamClk) 
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsTransferLength <= (others => '0');
        else
            for Index in 0 to kCrossRegCnt loop
                if (xsValidTL = '1') then
                    xsTransferLength <= xsDoutTL;
                end if;
            end loop;    
        end if;
    end if;
end process;

---------------------SPI IDLE CLOCK DOMAIN CROSSING-----------------------------------------------------------------------
ProcIdleRegister: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sAdcSPI_IdleR <=  '0';
        else
            sAdcSPI_IdleR <= sAdcSPI_Idle;
        end if;
    end if;
end process;



ProcIdleIpushSet: process (SysClk) 
--Since iPush transition only trigers input data to propagate
--towrds the output if iRdy is set, it is necessary to have two distinct signals: one to monitor regster modifications
--and one to push data through the hanshake block whenever the input data was modified and the hanshake module is ready
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sAdcSPI_IdleSetPush <=  '0'; 
            sAdcSPI_IdleDin <= "0"; 
        else
            if (sAdcSPI_Idle /= sAdcSPI_IdleR) then
                sAdcSPI_IdleSetPush <= '1';
                sAdcSPI_IdleDin(0) <= sAdcSPI_Idle;
            elsif (sAdcSPI_IdleRstPush = '1') then
                sAdcSPI_IdleSetPush <= '0';
            end if;
        end if;
    end if;
end process;
              
ProcIdleIpush: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sAdcSPI_IdlePush  <=  '0';
            sAdcSPI_IdleRstPush <= '0';
        else
                if ((sAdcSPI_IdleSetPush = '1') and (sAdcSPI_IdleRdy = '1') and (sAdcSPI_IdlePush = '0'))then
                    sAdcSPI_IdlePush <= '1';
                    sAdcSPI_IdleRstPush <= '1';
                else
                    sAdcSPI_IdlePush <= '0';
                    sAdcSPI_IdleRstPush <= '0';
                end if;     
        end if;
    end if;
end process;

InstIdleHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => s00_axi_aclk,
        iData => sAdcSPI_IdleDin,
        oData => lAdcSPI_IdleDout,   -- synchronized output
        iPush => sAdcSPI_IdlePush,
        iRdy => sAdcSPI_IdleRdy,  
        oAck => '1',  
        oValid => lAdcSPI_IdleValid,   -- indicates valid synchronized data
        aReset => aHanshakeReset
        );

ProcIdleOData: process (s00_axi_aclk) 
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (lExtRegRst_n = '0') then
            lAdcSPI_Idle <= '0';
        else
            if (xsValidTL = '1') then
                lAdcSPI_Idle <= lAdcSPI_IdleDout(0);
            end if;  
        end if;
    end if;
end process;
------------------------------------------------------------------------------------------------------------------

sReg0Rd  <= sRegisters(0);
sReg1Rd  <= sRegisters(1);
sReg6Rd  <= sRegisters(2);
sReg7Rd  <= sRegisters(3);
sReg8Rd  <= sRegisters(4);
sReg9Rd  <= sRegisters(5);
sReg10Rd <= sRegisters(6);
sReg11Rd <= sRegisters(7);
sReg12Rd <= sRegisters(8);
sReg13Rd <= sRegisters(9);
sReg14Rd <= sRegisters(10);
sReg15Rd <= sRegisters(11);
sReg16Rd <= sRegisters(12);

--Control Register (00h)
sSPI_CmdRunStop <= sReg0Rd(1);
sSPI_CmdReadEn  <= sReg0Rd(2);
lIntrEn         <= lReg0Rd(3);  --NO CROSSING
sOutAddrCntRst  <= sReg0Rd(6);
sDivRate        <= sReg0Rd(29 downto 16);
lRegRst         <= lReg0Rd(31); --NO CROSSING
sDacEn          <= sReg0Rd(4);
sDacEnOut       <= sReg0Rd(4);
--Interrupt Enable Register (08h)
lIrqEn(0)  <= lReg2Rd(0);   --NO CROSSING
lIrqEn(21) <= lReg2Rd(21);  --NO CROSSING
--SPI_CMD_TX Register(0Ch)
lSPI_CmdTx <= lReg3Rd(23 downto 0);  --NO CROSSING HERE
--AXIS_S2MM_LENGTH Register (14h)
sTransferLength <= sReg6Rd(kBufferSize+1 downto 2); 
--AXIS_S2MM_LENGTH Register (18h) -> Not implemented
--Zmod Specific Registers: TRIGGER CONTROL (1Ch)
sCh1ScaleSelect     <= sReg7Rd(21);
sCh2ScaleSelect     <= sReg7Rd(22);
----Zmod Specific Registers: TRIGGER CONTROL (20h)
--lWindowPosition <= lReg8Rd(kBufferSize-1 downto 0);
--Calibration Coefficients assignment
sCh1LgMultCoef <= sReg9Rd(17 downto 0);
sCh1LgAddCoef  <= sReg10Rd(17 downto 0);
sCh1HgMultCoef <= sReg11Rd(17 downto 0);
sCh1HgAddCoef  <= sReg12Rd(17 downto 0);
sCh2LgMultCoef <= sReg13Rd(17 downto 0);
sCh2LgAddCoef  <= sReg14Rd(17 downto 0);
sCh2HgMultCoef <= sReg15Rd(17 downto 0);
sCh2HgAddCoef  <= sReg16Rd(17 downto 0);
	
ProcIrq: process (s00_axi_aclk)  
begin
    if (s00_axi_aclk' event and s00_axi_aclk = '1') then
        if (lRegRst = '1') then
            lIrqOut <= '0';
        else
            if (((lReg1Rd and lIrqEn) /= x"00000000") and lIntrEn = '1') then
                lIrqOut <= '1';
            else
                lIrqOut <= '0';
            end if;
        end if;
    end if;
end process;

end arch_imp;
