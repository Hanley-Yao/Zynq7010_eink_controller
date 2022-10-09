
-------------------------------------------------------------------------------
--
-- File: SPI_Adapter.vhd
-- Author: Tudor Gherman
-- Original Project: Zmod ADC 1410 AXI Adapter
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
--This module implements the SPI indirect access port (IAP). The physical SPI interface of the AD9648 is managed 
--by the Zmod ADC 1410 low level controller, this module representing a bridge between the AXI Lite interface and 
--the Zmod ADC 1410 Low Level Controller. CMD_TX register  write accesses will trigger SPI commands to be loaded in 
--the transmit FIFO. The CMD_R/S bit in the Control Register will instruct the Zmod ADC 1410 Low Level Controller to
--fetch SPI commands from the transmit FIFO, process them and store the requested data bytes (in case of a read command)
--in the receive FIFO. The CMD_DONE bit in the Status Register will be set on the successful completion of the last 
--command in the transmit FIFO.  
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SPI_Adapter is
    Port ( SysClk : in STD_LOGIC; --100MHz input clock
           AxiLiteClk : in STD_LOGIC; --AXI Lite input clock
           sRst_n : in std_logic; --Active low synchronous reset signal synchronized with SysClk 
           lRst_n : in STD_LOGIC; --Active low synchronous reset signal synchronized with AxiLiteClk 
           --Control/Status register interface
           sADC_SPI_CmdDone : in std_logic; -- Flag indicating that the low level controller has succesfully completed the requested SPI command
           sSPI_CmdRunStop  : in STD_LOGIC; -- Control bit that enables the low level controller to start processing SPI commands
           sSPI_CmdReadEn : in STD_LOGIC;
           lSPI_CmdTx : in STD_LOGIC_VECTOR(23 downto 0); --SPI command input (CMD_TX register)
           lSPI_CmdRx : out STD_LOGIC_VECTOR(7 downto 0); --SPI returned data byte
           lSPI_CmdTxDone : out STD_LOGIC; --Flag indicating that the command queue has been successfully processed
           lSPI_CmdRxDone : out STD_LOGIC;
           lSPI_CmdTxCount : out STD_LOGIC_VECTOR(6 downto 0); --Transmit FIFO command count 
           lSPI_CmdRxCount : out STD_LOGIC_VECTOR(6 downto 0); --Receive FIFO command count
           lSPI_CmdTxRxError : out STD_LOGIC_VECTOR(3 downto 0);
           lTxFifoWrEn : in STD_LOGIC; --Transmit FIFO write enable input
           lRxFifoRdEn : in STD_LOGIC; --Receive data FIFO read enable input
           --Low Level Controller Interface         
           sTxFifoRdEnRdy : out STD_LOGIC; --the lower level IP should first assign sTxFifoRdEn and than wait sTxFifoRdEnRdy to be asserted before signaling command completion
           sTxFifoDout : out STD_LOGIC_VECTOR(23 downto 0); --Command output data
           sSPI_TxValid : out STD_LOGIC; --Command output data valid signal
           sTxFifoRdEn : in STD_LOGIC; --Transmit FIFO read enable input 
           sRxFifoWrEn : in STD_LOGIC; --Receive data FIFO write enable input
           sRxFifoDin : in STD_LOGIC_VECTOR (7 downto 0) --Receive data input 
          );
end SPI_Adapter;

architecture Behavioral of SPI_Adapter is

COMPONENT RX_FIFO
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT TX_FIFO
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    wr_data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;

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

signal sRxFifoFull : STD_LOGIC;
signal sRxFifoAlmostFull : STD_LOGIC;
signal lRxFifoEmpty : STD_LOGIC;
signal lRxFifoAlmostEmpty : STD_LOGIC;
signal lRxFifoValid : STD_LOGIC;
signal sRxFifoWrRstBusy : STD_LOGIC;
signal lRxFifoRdRstBusy : STD_LOGIC;
signal lTxFifoFull : STD_LOGIC;
signal lTxFifoAlmostFull : STD_LOGIC;
signal sTxFifoEmpty: STD_LOGIC;
signal lTxFifoEmpty, lTxFifoEmptyR, lTxFifoEmptyPulse : STD_LOGIC;
signal sTxFifoAlmostEmpty : STD_LOGIC;

signal lTxFifoWrRstBusy : STD_LOGIC;
signal sTxFifoRdRstBusy : STD_LOGIC;
signal lADC_CmdDone, lTxDoneSet, lTxDoneSetR, lTxDonePulse : std_logic;

signal lTxFifoCounter : std_logic_vector (6 downto 0);
signal lTxFifoRdEn : std_logic;
signal lRxFifoCounter : std_logic_vector (6 downto 0);
signal lRxFifoWrEn : std_logic;

signal sSetPushTxFifoEmpty, sTxFifoEmptyR, sRstPushTxFifoEmpty, sPushTxFifoEmpty, sRdyTxFifoEmpty, lValidTxFifoEmpty : std_logic;
signal sDinTxFifioEmpty, lDoutTxFifioEmpty : std_logic_vector(0 downto 0);

signal lRst_p : std_logic;
               
begin

lRst_p <= not lRst_n;

lSPI_CmdTxCount <= lTxFifoCounter;
lSPI_CmdRxCount <= lRxFifoCounter;

RECEIVE_FIFO : RX_FIFO
  PORT MAP (
    rst => lRst_p,
    wr_clk => SysClk,
    rd_clk => AxiLiteClk,
    din => sRxFifoDin,
    wr_en => sRxFifoWrEn,
    rd_en => lRxFifoRdEn,
    dout => lSPI_CmdRx,
    full => sRxFifoFull,
    almost_full => sRxFifoAlmostFull,
    empty => lRxFifoEmpty,
    almost_empty => lRxFifoAlmostEmpty,
    valid => lRxFifoValid,
    rd_data_count => open,
    wr_rst_busy => sRxFifoWrRstBusy,
    rd_rst_busy => lRxFifoRdRstBusy
  );
  
 TRANSMIT_FIFO : TX_FIFO
  PORT MAP (
    rst => lRst_p,
    wr_clk => AxiLiteClk,
    rd_clk => SysClk,
    din => lSPI_CmdTx,
    wr_en => lTxFifoWrEn,
    rd_en => sTxFifoRdEn,
    dout => sTxFifoDout,
    full => lTxFifoFull,
    almost_full => lTxFifoAlmostFull,
    empty => sTxFifoEmpty,
    almost_empty => sTxFifoAlmostEmpty,
    valid => sSPI_TxValid,
    wr_data_count => open,
    wr_rst_busy => lTxFifoWrRstBusy,
    rd_rst_busy => sTxFifoRdRstBusy
  );

ProcTxFifoEmptyReg: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sTxFifoEmptyR <=  '0'; 
        else
            sTxFifoEmptyR <= sTxFifoEmpty;
        end if;
    end if;
end process;

ProcTxFifoEmptyPushSet: process (SysClk) 
--Since iPush transition only trigers input data to propagate
--towrds the output if iRdy is set, it is necessary to have two distinct signals: one to monitor regster modifications
--and one to push data through the hanshake block whenever the input data was modified and the hanshake module is ready
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sSetPushTxFifoEmpty <=  '0'; 
            sDinTxFifioEmpty <= (others => '0');
        else
            if (sTxFifoEmptyR /= sTxFifoEmpty) then
                sSetPushTxFifoEmpty <= '1';
                sDinTxFifioEmpty(0) <= sTxFifoEmpty;
            elsif (sRstPushTxFifoEmpty = '1') then
                sSetPushTxFifoEmpty <= '0';
            end if;
        end if;
    end if;
end process;
              
ProcTxFifoEmptyPush: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sPushTxFifoEmpty  <=  '0';
            sRstPushTxFifoEmpty <= '0';
        else
                if ((sSetPushTxFifoEmpty = '1') and (sRdyTxFifoEmpty = '1') and (sPushTxFifoEmpty = '0'))then
                    sPushTxFifoEmpty <= '1';
                    sRstPushTxFifoEmpty <= '1';
                else
                    sPushTxFifoEmpty <= '0';
                    sRstPushTxFifoEmpty <= '0';
                end if;     
        end if;
    end if;
end process;

InstTxFifoEmptyHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiLiteClk,
        iData => sDinTxFifioEmpty,
        oData => lDoutTxFifioEmpty,   -- synchronized output
        iPush => sPushTxFifoEmpty,
        iRdy => sRdyTxFifoEmpty,  
        oAck => '1',  
        oValid => lValidTxFifoEmpty,   -- indicates valid synchronized data
        aReset => lRst_p
        );
 
ProcTxFifoEmptyOdata: process (AxiLiteClk) 
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxFifoEmpty <=  '0'; 
        else
            if (lValidTxFifoEmpty = '1') then
                lTxFifoEmpty <= lDoutTxFifioEmpty(0);
            end if;
        end if;
    end if;
end process;

InstAdcCmdDoneEmptyHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiLiteClk,
        iData => "1",
        oData => open,   -- synchronized output
        iPush => sADC_SPI_CmdDone,
        iRdy => open,  
        oAck => '1',  
        oValid => lADC_CmdDone,   -- indicates valid synchronized data
        aReset => lRst_p
        );

InstTxFifoRdEnHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiLiteClk,
        iData => "1",
        oData => open,   -- synchronized output
        iPush => sTxFifoRdEn,
        iRdy => sTxFifoRdEnRdy,  
        oAck => '1',  
        oValid => lTxFifoRdEn,   -- indicates valid synchronized data
        aReset => lRst_p
        );

InstRxFifoWrEnHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiLiteClk,
        iData => "1",
        oData => open,   -- synchronized output
        iPush => sRxFifoWrEn,
        iRdy => open,  
        oAck => '1',  
        oValid => lRxFifoWrEn,   -- indicates valid synchronized data
        aReset => lRst_p
        );

TX_FIFO_COUNTER_PROC: process (AxiLiteClk)  
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxFifoCounter <= (others => '0');
        else
            if ((lTxFifoWrEn = '1') and (lTxFifoRdEn = '0')) then
                lTxFifoCounter <= lTxFifoCounter + '1';
            elsif ((lTxFifoWrEn = '0') and (lTxFifoRdEn = '1')) then
                lTxFifoCounter <= lTxFifoCounter - '1';
            end if;        
        end if;
    end if;
end process;

RX_FIFO_COUNTER_PROC: process (AxiLiteClk)  
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lRxFifoCounter <= (others => '0');
        else
            if ((lRxFifoWrEn = '1') and (lRxFifoRdEn = '0')) then
                lRxFifoCounter <= lRxFifoCounter + '1';
            elsif ((lRxFifoWrEn = '0') and (lRxFifoRdEn = '1')) then
                lRxFifoCounter <= lRxFifoCounter - '1';
            end if;        
        end if;
    end if;
end process;
 
FIFO_EMPTY_R_PROC: process (AxiLiteClk)  
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxFifoEmptyR <= '0';
        else
            lTxFifoEmptyR <= lTxFifoEmpty;
        end if;
    end if;
end process;

lTxFifoEmptyPulse <= lTxFifoEmpty and (not lTxFifoEmptyR);

SYS_TXDONE_PROC: process (AxiLiteClk)  
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxDoneSet <= '0';
        else
            if (lADC_CmdDone = '1' and lTxFifoCounter = "000000") then
                lTxDoneSet <= '1';
            elsif (lTxDoneSet = '1') then
                lTxDoneSet <= '0';
            end if;
        end if;
    end if;
end process;

FIFO_TXDONE_R_PROC: process (AxiLiteClk)  
begin
    if (AxiLiteClk' event and AxiLiteClk = '1') then
        if (lRst_n = '0') then
            lTxDoneSetR <= '0';
        else
            lTxDoneSetR <= lTxDoneSet;
        end if;
    end if;
end process;

lTxDonePulse <= lTxDoneSet and (not lTxDoneSetR);
lSPI_CmdTxDone <= lTxDonePulse;--lTxFifoEmptyPulse;


end Behavioral;
