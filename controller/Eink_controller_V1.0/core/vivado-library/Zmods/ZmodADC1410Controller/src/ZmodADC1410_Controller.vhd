
-------------------------------------------------------------------------------
--
-- File: ZmodADC1410_Controller.vhd
-- Author: Tudor Gherman
-- Original Project: Zmod ADC 1410 Low Level Controller
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
--This module interfaces directly with the Zmod ADC 1410. It configures the gain 
--and coupling select relays, writes an initial configuration to the AD9648 on the 
--Zmod via the SPI interface, demultiplexes the data received 
--over the ADC's parallel interface and forwards it to the user logic. 
--  
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;

entity ZmodADC1410_Controller is
    Generic (
        --TestMode : boolean := true;
        kExtRelayConfigEn : boolean := false;
        --DEBUG PURPOSES; External calibration ports will be enabled by kExtCmdInterfaceEn
        kExtCalibEn : boolean := true; 
        --
        kExtCmdInterfaceEn : boolean := false;
        kExtSyncEn : boolean := false;
        kCh1CouplingStatic : std_logic := '0'; -- 0 -> DC coupling; 1 -> AC coupling; 
        kCh2CouplingStatic : std_logic := '0'; -- 0 -> DC coupling; 1 -> AC coupling; 
        kCh1GainStatic : std_logic := '0'; -- 0 -> Low Gain; 1 -> High Gain; 
        kCh2GainStatic : std_logic := '0'; -- 0 -> Low Gain; 1 -> High Gain;       
        
        kCh1LgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; --Channel1 low gain gain compensation coefficient parameter
        kCh1LgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000"; --Channel1 low gain offset compensation coefficient parameter
        kCh1HgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; --Channel1 high gain gain compensation coefficient parameter 
        kCh1HgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000"; --Channel1 high gain offset compensation coefficient parameter
        kCh2LgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; --Channel2 low gain gain compensation coefficient parameter 
        kCh2LgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000"; --Channel2 low gain offset compensation coefficient parameter 
        kCh2HgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; --Channel2 high gain gain compensation coefficient parameter 
        kCh2HgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000" --Channel2 high gain offset compensation coefficient parameter

    );
    Port (
         SysClk : in  std_logic;    --100MHZ clock input
         ADC_InClk : in  std_logic;    --400MHz input (ADC input clock and SYNC generation)
         sRst_n          : in std_logic;   --low level reset input
         sInitDone_n : out std_logic;  --initialization complete signaling
         FIFO_EMPTY_CHA : out std_logic; --used for debug
         FIFO_EMPTY_CHB : out std_logic; --used for debug

         sCh1Out : out std_logic_vector (15 downto 0);          --ADC Channel1 output
         sCh2Out : out std_logic_vector (15 downto 0);          --ADC Channel2 outut
         sExtCh1LgMultCoef : in std_logic_vector (17 downto 0); --Channel1 low gain gain compensation coefficient external port
         sExtCh1LgAddCoef : in std_logic_vector (17 downto 0);  --Channel1 low gain offset compensation coefficient external port
         sExtCh1HgMultCoef : in std_logic_vector (17 downto 0); --Channel1 high gain gain compensation coefficient external port 
         sExtCh1HgAddCoef : in std_logic_vector (17 downto 0);  --Channel1 high gain offset compensation coefficient external port 
         sExtCh2LgMultCoef : in std_logic_vector (17 downto 0); --Channel2 low gain gain compensation coefficient external port 
         sExtCh2LgAddCoef : in std_logic_vector (17 downto 0);  --Channel2 low gain offset compensation coefficient external port 
         sExtCh2HgMultCoef : in std_logic_vector (17 downto 0); --Channel2 high gain gain compensation coefficient external port 
         sExtCh2HgAddCoef : in std_logic_vector (17 downto 0);  --Channel2 high gain offset compensation coefficient external port 
         sCh1CouplingConfig : in std_logic;                     --Channel1 AC/DC coupling select signal (Optional)
         sCh2CouplingConfig : in std_logic;                     --Channel2 AC/DC coupling select signal (Optional)
         sCh1GainConfig : in std_logic;                         --Channel1 High Gain/Low Gain coupling select signal (Optional) 
         sCh2GainConfig : in std_logic;                         --Channel2 High Gain/Low Gain coupling select signal (Optional) 
         sTestMode : in std_logic; 
         sSyncIn : in std_logic_vector(3 downto 0);             --ADC Controller SYNC input (Optional)
         --External access for the SPI configuration interface; Designed to work with 2 FIFOs, one for transmit commands and one for received data
         sExtSPI_Idle : out std_logic;                       --Flag indicating that the configuration state machine is in the IDLE state 
         sExtSPI_CmdDone : out std_logic;                    --Pulse indicating that the SPI command has been succesfully completed
         sExtSPI_TxRdEn : out std_logic;                     --Read enable used to load data from the command FIFO
         sExtSPI_TxRdEnRdy : in STD_LOGIC;                    --the IP waits for this signal to be asserted before signaling SPI command completion to upper level IP
         sExtSPI_TxDout : in std_logic_vector (23 downto 0); --Command input data
         sExtSPI_TxValid : in STD_LOGIC;                     --Command input data valid signal
         sExtSPI_EnTx : in STD_LOGIC;                        --Enable command transmit over the external SPI access interface
         sExtSPI_EnRx : in STD_LOGIC;                        --Enable command receive data over the external SPI access interface  
         sExtSPI_RxWrEn : out std_logic;                     --Receive data FIFO write enable signal  
         sExtSPI_RxDin : out std_logic_vector (7 downto 0);  --Receive data output 

        --AD9648 signals
         adcClkIn_p : out std_logic;
         adcClkIn_n : out std_logic;
         adcSync    : out std_logic;
         DcoClk       : in std_logic;
         dADC_Data    : in std_logic_vector(13 downto 0);
   
         sADC_SDIO : inout std_logic;
         sADC_CS   : out std_logic;
         sADC_Sclk : out std_logic;
         --Relay drive signals
         sCh1CouplingH   : out std_logic;
         sCh1CouplingL   : out std_logic;
         sCh2CouplingH   : out std_logic;
         sCh2CouplingL   : out std_logic;
         sCh1GainH   : out std_logic;
         sCh1GainL   : out std_logic;
         sCh2GainH   : out std_logic;
         sCh2GainL   : out std_logic;
         sRelayComH  : out std_logic;
         sRelayComL  : out std_logic
         );
end ZmodADC1410_Controller;

architecture Behavioral of ZmodADC1410_Controller is

component AD9648_SPI is
Port ( 
        SysClk : in STD_LOGIC;
        sRst_n : in STD_LOGIC;
        sSPI_Clk : out STD_LOGIC;
        sSDIO : inout STD_LOGIC;
        sCS : out STD_LOGIC;
        sRdData : out std_logic_vector(15 downto 0);
        sWrData : in std_logic_vector(15 downto 0);
        sAddr : in std_logic_vector(12 downto 0);
        sWidth : in std_logic_vector(1 downto 0);
        sRdEn : in STD_LOGIC;
        sWrEn : in STD_LOGIC;
        sDone : out STD_LOGIC);
end component;

COMPONENT fifo_generator_adc
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC
  );
END COMPONENT;

signal Rst : std_logic;
--PLL&Clock signals
signal DcoBufgClk, DcoBufioClk, FboutDcoClk, FbinDcoClk, OddrClk, DcoPLL_Clk : std_logic;
--Initialization complete flag
signal sInitDoneR_n, sInitDoneFsm_n : std_logic;
--SPI Interface
signal sADC_SPI_RdData : std_logic_vector(15 downto 0);
signal sADC_SPI_WrData, sADC_SPI_WrDataR : std_logic_vector(15 downto 0);
signal sADC_SPI_Addr, sADC_SPI_AddrR : std_logic_vector(12 downto 0);
signal sADC_SPI_Width, sADC_SPI_WidthR : std_logic_vector(1 downto 0);
signal sADC_SPI_RdEn, sADC_SPI_RdEnR : std_logic;
signal sADC_SPI_WrEn, sADC_SPI_WrEnR : std_logic;
signal sADC_SPI_done : std_logic;
type ADC_SPI_Commands_t is array (15 downto 0) of std_logic_vector(23 downto 0);
type ADC_SPI_Readback_t is array (15 downto 0) of std_logic_vector(7 downto 0);
constant kADC_SPI_Cmd : ADC_SPI_Commands_t := (x"000500",  -- Device index: none
                                               x"000800", -- Power modes: Normal operation
                                               x"000503", -- Device index: A|B
                                               x"003A02", -- Sync control : continuous | sync enable | 0
                                               x"001781", -- Output Delay; DCO delay enabled; 0.56ns
                                               x"001511", -- Output adjust: CMOS drive strength 01 - 2X [DCO | DOUT]
                                               x"002A00", -- Overrange control: output disable
                                               x"001680", -- Clock Phase control: DCO inverted, Input clock divider phase adjust 0
                                               x"000B03", -- Clck Divide: 4
                                               x"000500", -- Device index: none
                                               x"001421", -- Output mode: CMOS | interleave | enable B | output not invert | Gray code
                                               x"000502", -- Device index: B
                                               x"001431", -- Output mode: CMOS | interleave | disable A | output not invert | 2's Complement
                                               x"000501", -- Device index: A
                                               x"000803", -- Power modes: digital reset
                                               x"000503" -- Device index A|B
                                            );    
constant kADC_SPI_Rdbck : ADC_SPI_Readback_t:= (x"00",  -- Device index: none
                                                x"00", -- Power modes: Normal operation
                                                x"03", -- Device index: A|B
                                                x"02", -- Sync control : continuous | sync enable | 0
                                                x"81", -- Output Delay; DCO delay enabled; 0.56ns
                                                x"11", -- Output adjust: CMOS drive strength 01 - 2X [DCO | DOUT]
                                                x"00", -- Overrange control: output disable
                                                x"80", -- Clock Phase control: DCO inverted, Input clock divider phase adjust 0
                                                x"03", -- Clck Divide: 4
                                                x"00", -- Device index: none
                                                x"21", -- Output mode: CMOS | interleave | enable B | output not invert | Gray code
                                                x"02", -- Device index: B
                                                x"31", -- Output mode: CMOS | interleave | disable A | output not invert | 2's Complement
                                                x"01", -- Device index: A
                                                x"03", -- Power modes: digital reset
                                                x"03" -- Device index A|B
                                               );                                                                                   
signal sCmdCnt : integer range 0 to 31;
signal sIncCmdCnt, sRstCmdCnt : std_logic;
--FSM states & outputs
type FsmStates_t is (StStart, StConfigCouplingCh1, StConfigCouplingCh1Rst, StConfigCouplingCh2, StConfigCouplingCh2Rst, StConfigGainCh1, 
StConfigGainCh1Rst, StConfigGainCh2, StConfigGainCh2Rst, StCheckCmdCnt, StWriteSoftReset, StWaitDoneRst, StReadPortConfig, StCheckResetDone,  
StReadID, StWaitDoneID, StWriteControlReg, StWaitDoneWriteReg, StWaitDoneReadReg, StReadControlReg,  StWaitRecover, StInitDone, StIdle, 
StError, StExtSPI_Decode, StExtSPI_WrCmd,  StWaitDoneExtWrReg, StWaitDoneExtRdReg, StRegExtRxData, StExtSPI_TxDone, StExtSPI_RxDone, 
StExtSPI_RdCmd, StChangeCouplingCh1, StChangeCouplingCh2, StChangeGainCh1, StChangeGainCh2); 
signal sCurrentState, sNextState : FsmStates_t;
signal fsmcfg_state, fsmcfg_state_r : std_logic_vector(5 downto 0); --REMOVE!!!!!!!!!!!!!!!!!!!!!!!!!!!
--Timers
signal sRelayPrescaler : integer range 0 to 524287;
signal sRelayTimer : integer range 0 to 65535;
signal sRelayCntEn, sRelayRst : std_logic;
--FIFOs
signal dFIFO_WrEnChA, sFIFO_RdEnChA, dFIFO_WrEnChB, sFIFO_RdEnChB: std_logic;
signal sFIFO_EmptyChA, dFIFO_FullChA, sFIFO_EmptyChB, dFIFO_FullChB : std_logic;
signal sFIFO_AlmostEmptyChA, sFIFO_AlmostEmptyChB, dFIFO_AlmostFullChA, dFIFO_AlmostFullChB : std_logic;
--RELAY CONFIG
signal SC1_AC_DC, SC2_AC_DC, SC1_HG_LG, SC2_HG_LG : std_logic;
signal sCh1CouplingConfigFsm, sCh2CouplingConfigFsm, sCh1GainConfigFsm, sCh2GainConfigFsm : std_logic;
signal sCh1CouplingConfigR, sCh2CouplingConfigR, sCh1GainConfigR, sCh2GainConfigR : std_logic;
signal sCh1CouplingChangeSet, sCh1CouplingChangeRst : std_logic;
signal sCh2CouplingChangeSet, sCh2CouplingChangeRst : std_logic;
signal sCh1GainChangeSet, sCh1GainChangeRst : std_logic;
signal sCh2GainChangeSet, sCh2GainChangeRst : std_logic;
signal sCh1GainState, sCh2GainState : std_logic;
--External Command FIFO Interface
signal sExtSPI_RxWrEn_fsm: std_logic;
signal sExtSPI_RxDin_fsm : std_logic_vector(7 downto 0);
--Data Path
--constant kOne18b : signed (17 downto 0) := "010000000000000000";
signal dChannelA, dChannelB : std_logic_vector(13 downto 0); 
signal sChannelA, sChannelB : std_logic_vector(13 downto 0);
signal sSChannelA18b, sSChannelB18b : signed(17 downto 0);
signal sChannelA18b, sChannelB18b : std_logic_vector(17 downto 0);
signal sCh1CalibMult, sCh1CalibMultInv,  sCh2CalibMult : signed(35 downto 0);
signal sCh1CalibAdd, sCh2CalibAdd : signed(35 downto 0);
signal sCh1Calib, sCh2Calib : std_logic_vector(17 downto 0);
signal sCh1CoefAdd, sCh2CoefAdd : std_logic_vector(35 downto 0);
signal sCh1CoefMult, sCh2CoefMult : std_logic_vector(17 downto 0);
signal sSCh1CoefMult, sSCh2CoefMult : signed(17 downto 0);
signal sCh1CoefMultLg, sCh1CoefMultHg :  std_logic_vector (17 downto 0);
signal sCh1CoefAddLg, sCh1CoefAddHg : std_logic_vector (17 downto 0);
signal sSCh1CoefAdd, sSCh2CoefAdd : signed (35 downto 0);
signal sCh2CoefMultLg, sCh2CoefMultHg : std_logic_vector (17 downto 0);
signal sCh2CoefAddLg, sCh2CoefAddHg : std_logic_vector (17 downto 0);
--Sync OSERDES input
signal sADC_SyncOserdes : std_logic_vector(3 downto 0);
 
begin


FIFO_EMPTY_CHA <= sFIFO_EmptyChA;
FIFO_EMPTY_CHB <= sFIFO_EmptyChB;

Rst <= not sRst_n;

AD9648_SPI_inst: AD9648_SPI 
Port Map( 
    --
    SysClk => SysClk,
    sRst_n => sRst_n,
    sSPI_Clk => sADC_Sclk,
    sSDIO => sADC_SDIO,
    sCS => sADC_CS, 
    sRdData => sADC_SPI_RdData,
    sWrData => sADC_SPI_WrDataR,
    sAddr => sADC_SPI_AddrR,
    sWidth => sADC_SPI_WidthR, --tested only for width = "00"
    sRdEn => sADC_SPI_RdEnR,
    sWrEn => sADC_SPI_WrEnR,
    sDone => sADC_SPI_done
    );                

--------------------------External Status signals-------------------------------------------------------------

ProcInitDoneReg: process (SysClk) --register calibration done FSM output signal  
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sInitDoneR_n <= '1';
        else
            sInitDoneR_n <= sInitDoneFsm_n;  
        end if;
    end if;
end process;

sInitDone_n <= sInitDoneR_n; -- Calibration done output flag; Indicates when the ADC initialization is completed

ProcFsmIdle: process (SysClk, sRst_n) -- Indicate when the ADC configuration state machine is in IDLE state
     begin
        if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
                sExtSPI_Idle <= '0';
            else
                if (sCurrentState = StIdle) then
                    sExtSPI_Idle <= '1';
                else
                    sExtSPI_Idle <= '0';
                end if;
            end if;        
         end if;
      end process; 
      
------------------------------Relay configuration-------------------------------------------------------------------------------------------------

SC1_AC_DC <= sCh1CouplingConfig when kExtRelayConfigEn = true else kCh1CouplingStatic; --Channel1 AC/DC setting (output port or IP parameter)
SC2_AC_DC <= sCh2CouplingConfig when kExtRelayConfigEn = true else kCh2CouplingStatic; --Channel2 AC/DC setting (output port or IP parameter)
SC1_HG_LG <= sCh1GainConfig when kExtRelayConfigEn = true else kCh1GainStatic;  --Channel1 High Gain/Low Gain setting (output port or IP parameter)
SC2_HG_LG <= sCh2GainConfig when kExtRelayConfigEn = true else kCh2GainStatic;  --Channel2 High Gain/Low Gain setting setting (output port or IP parameter)

ProcRelayConfigReg: process (SysClk)  --delay relay configuration setting one clock cycle to detect state changes
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sCh1CouplingConfigR <= '0';
            sCh2CouplingConfigR <= '0';
            sCh1GainConfigR <= '0';
            sCh2GainConfigR <= '0';
        else
            sCh1CouplingConfigR <= sCh1CouplingConfig;
            sCh2CouplingConfigR <= sCh2CouplingConfig;
            sCh1GainConfigR <= sCh1GainConfig;
            sCh2GainConfigR <= sCh2GainConfig; 
        end if;
    end if;
end process;

ProcCh1CouplingChange: process (SysClk) --detect state change for scope channel1 AC/DC setting
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0' or sCh1CouplingChangeRst = '1') then
            sCh1CouplingChangeSet <= '0';
        else
            if (sCh1CouplingConfigR /= sCh1CouplingConfig) then
                sCh1CouplingChangeSet <= '1';
            end if;  
        end if;
    end if;
end process;

ProcCh2CouplingChange: process (SysClk) --detect state change for scope channel2 AC/DC setting 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0' or sCh2CouplingChangeRst = '1') then
            sCh2CouplingChangeSet <= '0';
        else
            if (sCh2CouplingConfigR /= sCh2CouplingConfig) then
                sCh2CouplingChangeSet <= '1';
            end if;  
        end if;
    end if;
end process;

ProcCh1GainChange: process (SysClk)  --detect state change for scope channel1 High Gain/Low Gain setting
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0' or sCh1GainChangeRst = '1') then 
            sCh1GainChangeSet <= '0';  
        else
            if (sCh1GainConfigR /= sCh1GainConfig) then
                sCh1GainChangeSet <= '1';
            end if;  
        end if;
    end if;
end process;

ProcCh2GainChange: process (SysClk)  --detect state change for scope channel2 High Gain/Low Gain setting 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0' or sCh2GainChangeRst = '1') then
            sCh2GainChangeSet <= '0';
        else
            if (sCh2GainConfigR /= sCh2GainConfig) then
                sCh2GainChangeSet <= '1';
            end if;  
        end if;
    end if;
end process;

ProcRelayReg: process (SysClk)  --Generate relay drive signals
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sCh1CouplingH <= '0';
            sCh1CouplingL <= '0';
            sCh2CouplingH <= '0';
            sCh2CouplingL <= '0';
            sCh1GainH <= '0';
            sCh1GainL <= '0';
            sCh2GainH <= '0';
            sCh2GainL <= '0';
            sRelayComH <= '0';
            sRelayComL <= '0';
            sCh1GainState <= '0';
            sCh2GainState <= '0';
        else
            if (sCh1CouplingConfigFsm = '1') then 
                sCh2CouplingH <= '0';
                sCh2CouplingL <= '0';
                sCh1GainH <= '0';
                sCh1GainL <= '0';
                sCh2GainH <= '0';
                sCh2GainL <= '0';
                if (SC1_AC_DC = '0') then --DC Coupling (Relay set)
                    sCh1CouplingH <= '1';
                    sCh1CouplingL <= '0';
                    sRelayComH <= '0';
                    sRelayComL <= '1';
                else                      --AC Coupling (Relay reset)
                    sCh1CouplingH <= '0';
                    sCh1CouplingL <= '1';
                    sRelayComH <= '1';
                    sRelayComL <= '0';
                end if;
            elsif (sCh2CouplingConfigFsm = '1') then
                sCh1CouplingH <= '0';
                sCh1CouplingL <= '0';
                sCh1GainH <= '0';
                sCh1GainL <= '0';
                sCh2GainH <= '0';
                sCh2GainL <= '0';
                if (SC2_AC_DC = '1') then --DC Coupling (Relay set)
                    sCh2CouplingH <= '1';
                    sCh2CouplingL <= '0';
                    sRelayComH <= '0';
                    sRelayComL <= '1';
                else                      --AC Coupling (Relay reset)
                    sCh2CouplingH <= '0';
                    sCh2CouplingL <= '1';
                    sRelayComH <= '1';
                    sRelayComL <= '0';
                end if;
            elsif (sCh1GainConfigFsm = '1') then
                sCh1CouplingH <= '0';
                sCh1CouplingL <= '0';
                sCh2CouplingH <= '0';
                sCh2CouplingL <= '0';
                sCh2GainH <= '0';
                sCh2GainL <= '0';
                if (SC1_HG_LG = '1') then --High Gain (Relay set)
                    sCh1GainH <= '1';
                    sCh1GainL <= '0';
                    sRelayComH <= '0';
                    sRelayComL <= '1';
                    sCh1GainState <= '1';
                else                     --Low Gain (Relay reset)
                    sCh1GainH <= '0';
                    sCh1GainL <= '1';
                    sRelayComH <= '1';
                    sRelayComL <= '0';
                    sCh1GainState <= '0';
                end if;
            elsif (sCh2GainConfigFsm = '1') then  
                sCh1CouplingH <= '0';
                sCh1CouplingL <= '0';
                sCh2CouplingH <= '0';
                sCh2CouplingL <= '0';
                sCh1GainH <= '0';
                sCh1GainL <= '0';
                if (SC2_HG_LG = '1') then --High Gain (Relay set)
                    sCh2GainH <= '1';
                    sCh2GainL <= '0';
                    sRelayComH <= '0';
                    sRelayComL <= '1';
                    sCh2GainState <= '1';
                else                      --Low Gain (Relay reset)
                    sCh2GainH <= '0';
                    sCh2GainL <= '1';
                    sRelayComH <= '1';
                    sRelayComL <= '0';
                    sCh2GainState <= '0';
                end if;
            else
                sCh1CouplingH <= '0';
                sCh1CouplingL <= '0';
                sCh2CouplingH <= '0';
                sCh2CouplingL <= '0';
                sCh1GainH <= '0';
                sCh1GainL <= '0';
                sCh2GainH <= '0';
                sCh2GainL <= '0';
                sRelayComH <= '0';
                sRelayComL <= '0';    
            end if;
        end if;
    end if;
end process;

ProcRelayPrescaler: process (SysClk)  --Relay timer prescaler
begin
    if (SysClk' event and SysClk = '1') then
        if ((sRst_n = '0') or (sRelayRst = '0')) then
            sRelayPrescaler <= 0;
        else
            sRelayPrescaler <= sRelayPrescaler + 1;
            if (sRelayPrescaler = 99999) then
                sRelayCntEn <= '1';
            else
                sRelayCntEn <= '0';
            end if;    
        end if;
    end if;
end process;

ProcRelayTimer: process (SysClk)   --Relay timer
begin
    if (SysClk' event and SysClk = '1') then
        if ((sRst_n = '0') or (sRelayRst = '0')) then
            sRelayTimer <= 0;
        else
            if(sRelayCntEn = '1') then
                sRelayTimer <= sRelayTimer + 1;
            end if;        
        end if;
    end if;
end process;

------------------------------------------------------ADC SPI configuration-----------------------------------------------------------------
ProcCmdCounter: process (SysClk) --sent command counter 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRstCmdCnt = '0' or sRst_n = '0') then
            sCmdCnt <= 0;
        else
            if (sIncCmdCnt = '1') then
                sCmdCnt <= sCmdCnt + 1;
            end if;
        end if;        
    end if;
end process;

ProcRxExtFIFO_Reg: process (SysClk, sRst_n) --Register SPI command receive data for external SPI access channel  
     begin
        if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
                sExtSPI_RxWrEn <= '0';
                sExtSPI_RxDin <= (others => '0');
            else
                if (sExtSPI_EnRx = '1') then
                    sExtSPI_RxWrEn <= sExtSPI_RxWrEn_fsm;
                    sExtSPI_RxDin <= sExtSPI_RxDin_fsm;
                else
                    sExtSPI_RxWrEn <= '0';
                    sExtSPI_RxDin <= (others => '0');
                end if;
            end if;        
         end if;
      end process; 
 
ProcSPI_ControllerRegister: process (SysClk, sRst_n)
    begin
        if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
               sADC_SPI_RdEnR <= '0';
               sADC_SPI_WrEnR <= '0';
               sADC_SPI_WrDataR <= (others => '0');
               sADC_SPI_AddrR <= (others => '0');
               sADC_SPI_WidthR <= (others => '0');
            else
               sADC_SPI_RdEnR <= sADC_SPI_RdEn;
               sADC_SPI_WrEnR <= sADC_SPI_WrEn;
               sADC_SPI_WrDataR <= sADC_SPI_WrData;
               sADC_SPI_AddrR <= sADC_SPI_Addr;
               sADC_SPI_WidthR <= sADC_SPI_Width;
            end if;        
         end if;
      end process;        
          
--------------------------------------------Configuration FSM--------------------------------------------------------------------------

ProcSyncFsm: process (SysClk, sRst_n)
      begin
         if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
               sCurrentState <= StStart;
               fsmcfg_state_r <= (others => '0');
            else
               sCurrentState <= sNextState;
               fsmcfg_state_r <= fsmcfg_state;
            end if;        
         end if;
      end process;
      
ProcNextStateAndOutputDecode: process (sCurrentState, sADC_SPI_RdData, sADC_SPI_done, sRelayCntEn, sCmdCnt, sRelayTimer, sExtSPI_EnTx,
sExtSPI_EnRx, sExtSPI_TxValid, sExtSPI_TxDout, sCh1CouplingChangeSet, sCh2CouplingChangeSet, sCh1GainChangeSet, sCh2GainChangeSet)
      begin         
         sNextState <= sCurrentState;  
         fsmcfg_state <= "000000";
         sADC_SPI_WrData <= (others => '0');
         sADC_SPI_Addr <= (others => '0');
         sADC_SPI_Width <= (others => '0');
         sADC_SPI_RdEn <= '0';
         sADC_SPI_WrEn  <= '0';
         sRstCmdCnt <= '0';
         sIncCmdCnt <= '0';
         sCh1GainConfigFsm <= '0';
         sCh2GainConfigFsm <= '0';
         sCh1CouplingConfigFsm <= '0';
         sCh2CouplingConfigFsm <= '0';
         sCh1CouplingChangeRst <= '0';
         sCh2CouplingChangeRst <= '0';
         sCh1GainChangeRst <= '0';
         sCh2GainChangeRst <= '0';

         sRelayRst <= '0';
         sInitDoneFsm_n <= '1';
         sExtSPI_CmdDone  <= '0';
         
         sExtSPI_TxRdEn <= '0';
         sExtSPI_RxWrEn_fsm  <= '0';
         sExtSPI_RxDin_fsm  <= (others => '0');
                  
         case (sCurrentState) is
            when StStart =>
                fsmcfg_state <= "000000";
                sNextState <= StConfigCouplingCh1;
                
             when StConfigCouplingCh1 => --configure AC/DC coupling for channel1
                fsmcfg_state <= "000001";
                sRelayRst <= '1';
                sCh1CouplingChangeRst <= '1';
                sCh1CouplingConfigFsm <= '1';
                if (sRelayTimer = 4) then
                    sNextState <= StConfigCouplingCh1Rst;
                end if;   
                  
             when StConfigCouplingCh1Rst =>  -- reset relay timer
                fsmcfg_state <= "000010"; 
                sNextState <= StConfigCouplingCh2; 
                
             when StConfigCouplingCh2 => --configure AC/DC coupling for channel2 
                fsmcfg_state <= "000011";
                sRelayRst <= '1';
                sCh2CouplingChangeRst <= '1';
                sCh2CouplingConfigFsm <= '1';
                if (sRelayTimer = 4) then
                    sNextState <= StConfigCouplingCh2Rst;
                end if;
                
             when StConfigCouplingCh2Rst => -- reset relay timer
                fsmcfg_state <= "000100";
                sNextState <= StConfigGainCh1; 

             when StConfigGainCh1 =>  --configure High Gain/Low Gain coupling for channel1
                fsmcfg_state <= "000101";
                sRelayRst <= '1';
                sCh1GainChangeRst <= '0';
                sCh1GainConfigFsm <= '1';
                if (sRelayTimer = 4) then
                    sNextState <= StConfigGainCh1Rst;
                end if;
                
             when StConfigGainCh1Rst =>  -- reset relay timer
                fsmcfg_state <= "000111"; 
                sNextState <= StConfigGainCh2; 
                
             when StConfigGainCh2 =>   --configure High Gain/Low Gain coupling for channel2
                fsmcfg_state <= "001000";
                sRelayRst <= '1';
                sCh2GainChangeRst <= '0';
                sCh2GainConfigFsm <= '1';
                if (sRelayTimer = 4) then
                    sNextState <= StConfigGainCh2Rst;
                end if;
                
             when StConfigGainCh2Rst =>  -- reset relay timer
                fsmcfg_state <= "001001";
                sNextState <= StWriteSoftReset;                                        
                
            when StWriteSoftReset =>  --ADC soft reset
                fsmcfg_state <= "001011";
                sADC_SPI_WrData <= x"3C00";
                sADC_SPI_Addr <= "0000000000000";
                sADC_SPI_Width <= (others => '0');
                sADC_SPI_WrEn  <= '1';
                sNextState <= StWaitDoneRst;  

             when StWaitDoneRst =>  --wait for SPI command to be completed
                fsmcfg_state <= "001100";
                if (sADC_SPI_done = '1') then
                    sNextState <= StReadPortConfig;
                end if;  

            when StReadPortConfig =>  --read the soft reset register to make sure the soft reset has completed
                fsmcfg_state <= "001101";
                sADC_SPI_Addr <= "0000000000000";
                sADC_SPI_RdEn <= '1';
                sNextState <= StCheckResetDone; 

             when StCheckResetDone =>  --wait for SPI command to be completed and check the read value against the expected result
                fsmcfg_state <= "001110";
                if (sADC_SPI_done = '1') then
                    if (sADC_SPI_RdData(7 downto 0) = x"18") then
                        sNextState <= StReadID;
                    else
                        sNextState <= StReadPortConfig; 
                    end if;
                end if; 
              
            when StReadID => --read the ADC chip ID 
                fsmcfg_state <= "001111";
                sADC_SPI_Addr <= "0000000000001";
                sADC_SPI_RdEn <= '1';
                sNextState <= StWaitDoneID;
                
             when StWaitDoneID =>   --wait for SPI command to be completed and check the read value against the expected result
                fsmcfg_state <= "010000";
                if (sADC_SPI_done = '1') then
                    if (sADC_SPI_RdData(7 downto 0) = x"88") then
                        sNextState <= StWriteControlReg;
                    else
                        sNextState <= StStart;
                    end if;
                end if;
                
            when StWriteControlReg => --start executing the intitialization SPI command sequence
                sRstCmdCnt <= '1';
                fsmcfg_state <= "010001";
                sADC_SPI_WrData <= kADC_SPI_Cmd(sCmdCnt)(7 downto 0) & x"00";
                sADC_SPI_Addr <= kADC_SPI_Cmd(sCmdCnt)(20 downto 8);
                sADC_SPI_Width <= kADC_SPI_Cmd(sCmdCnt)(22 downto 21);
                sADC_SPI_WrEn  <= '1';
                sNextState <= StWaitDoneWriteReg;  

             when StWaitDoneWriteReg => --wait for SPI command to be completed
                fsmcfg_state <= "010010";
                sRstCmdCnt <= '1';
                if (sADC_SPI_done = '1') then
                    sNextState <= StReadControlReg;
                end if;

            when StReadControlReg => --read back the register value
                fsmcfg_state <= "010011";
                sRstCmdCnt <= '1';
                sADC_SPI_Addr <= kADC_SPI_Cmd(sCmdCnt)(20 downto 8);
                sADC_SPI_Width <= kADC_SPI_Cmd(sCmdCnt)(22 downto 21);
                sADC_SPI_RdEn <= '1';
                sNextState <= StWaitDoneReadReg; 

             when StWaitDoneReadReg => --wait for SPI command to be completed and compare the read data against the expected value (the readback sequence)
                fsmcfg_state <= "010100";
                sRstCmdCnt <= '1';
                if (sADC_SPI_done = '1') then
                    if (sADC_SPI_RdData(7 downto 0) = kADC_SPI_Rdbck(sCmdCnt)) then
                        sNextState <= StCheckCmdCnt;
                    else
                        sNextState <= StError;
                    end if;
                end if;   

             when StCheckCmdCnt => --check if the command sequence has completed
                fsmcfg_state <= "010101";
                sRstCmdCnt <= '1';
                if (sCmdCnt = 15) then 
                    sNextState <= StWaitRecover;
                else
                    sIncCmdCnt <= '1';
                    sNextState <= StWriteControlReg;       
                end if;   

             when StWaitRecover =>  --wait to recover form power done mode
                fsmcfg_state <= "010110";
                sRelayRst <= '1';
                if (sRelayTimer = 150) then
                    sNextState <= StInitDone;
                end if;
                            
             when StInitDone =>  --indicate the initialization sequence has completed
                fsmcfg_state <= "010111";
                sInitDoneFsm_n <= '0';
                sNextState <= StIdle;
             
             when StIdle =>  --IDLE state; wait for changes on the external SPI access interface or on the relay configuration signals
                fsmcfg_state <= "011000";
                sInitDoneFsm_n <= '0';
                if (sExtSPI_EnTx = '1' and sExtSPI_TxValid = '1') then
                    sNextState <= StExtSPI_Decode;
                elsif (sCh1CouplingChangeSet = '1') then
                    sNextState <= StChangeCouplingCh1;
                elsif (sCh2CouplingChangeSet = '1') then
                    sNextState <= StChangeCouplingCh2;
                elsif (sCh1GainChangeSet = '1') then
                    sNextState <= StChangeGainCh1;
                elsif (sCh2GainChangeSet = '1') then
                    sNextState <= StChangeGainCh2;    
                else
                    sNextState <= StIdle;
                end if;
                          
             when StExtSPI_Decode =>  --decode the external SPI command
                fsmcfg_state <= "011001";
                sInitDoneFsm_n <= '0';
                if (sExtSPI_TxDout(23) = '0') then
                    sNextState <= StExtSPI_WrCmd; 
                else
                    sNextState <= StExtSPI_RdCmd; 
                end if; 
                                
             when StExtSPI_WrCmd =>  --execute the write register command
                fsmcfg_state <= "011010";
                sInitDoneFsm_n <= '0';
                sADC_SPI_WrData <= sExtSPI_TxDout(7 downto 0) & x"00";
                sADC_SPI_Addr <= sExtSPI_TxDout(20 downto 8);
                sADC_SPI_Width <= sExtSPI_TxDout(22 downto 21);
                sADC_SPI_WrEn  <= '1';
                sNextState <= StWaitDoneExtWrReg;    

             when StWaitDoneExtWrReg => --wait for the write register command to complete
                fsmcfg_state <= "011011";
                sInitDoneFsm_n <= '0';
                if (sADC_SPI_done = '1') then
                    sExtSPI_TxRdEn <= '1';
                    sNextState <= StExtSPI_TxDone;
                end if;
                
            when StExtSPI_TxDone =>  
                fsmcfg_state <= "011100";
                sInitDoneFsm_n <= '0';
                if (sExtSPI_TxRdEnRdy = '1') then
                    sExtSPI_CmdDone  <= '1';
                    sNextState <= StIdle;
                end if;
                                
            when StExtSPI_RdCmd =>  --execute the read register command
                fsmcfg_state <= "011101";
                sInitDoneFsm_n <= '0';
                sADC_SPI_Addr <= sExtSPI_TxDout(20 downto 8);
                sADC_SPI_Width <= sExtSPI_TxDout(22 downto 21);
                sADC_SPI_RdEn <= '1';
                sNextState <= StWaitDoneExtRdReg; 

             when StWaitDoneExtRdReg => --wait for the read register command to complete and load the next command for the transmit FIFO
                fsmcfg_state <= "011110";
                sInitDoneFsm_n <= '0';
                if (sADC_SPI_done = '1') then
                    sExtSPI_TxRdEn <= '1';
                    sNextState <= StRegExtRxData;
                end if;
                
             when StRegExtRxData => --used to register the incomming SPI data
                fsmcfg_state <= "011111";
                sInitDoneFsm_n <= '0';
                sExtSPI_RxWrEn_fsm  <= '1';
                sExtSPI_RxDin_fsm  <= sADC_SPI_RdData(7 downto 0);
--                sExtSPI_CmdDone  <= '1';
                sNextState <= StExtSPI_RxDone;
                
            when StExtSPI_RxDone =>  
                fsmcfg_state <= "011100";
                sInitDoneFsm_n <= '0';
                if (sExtSPI_TxRdEnRdy = '1') then
                    sExtSPI_CmdDone  <= '1';
                    sNextState <= StIdle;
                end if;  
                
             when StChangeCouplingCh1 => --configure AC/DC coupling for channel1
                fsmcfg_state <= "100000";
                sRelayRst <= '1';
                sCh1CouplingChangeRst <= '1';
                sCh1CouplingConfigFsm <= '1';
                if (sRelayTimer = 4) then
                    sNextState <= StIdle;
                end if;   
                
             when StChangeCouplingCh2 => --configure AC/DC coupling for channel2
                fsmcfg_state <= "100001";
                sRelayRst <= '1';
                sCh2CouplingChangeRst <= '1';
                sCh2CouplingConfigFsm <= '1';
                if (sRelayTimer = 4) then
                    sNextState <= StIdle;
                end if;

             when StChangeGainCh1 => --configure High Gain/Low gain coupling for channel1
                fsmcfg_state <= "100010";
                sRelayRst <= '1';
                sCh1GainChangeRst <= '1';
                sCh1GainConfigFsm <= '1';
                if (sRelayTimer = 4) then
                    sNextState <= StIdle;
                end if;
                
             when StChangeGainCh2 =>  --configure High Gain/Low gain coupling for channel2
                fsmcfg_state <= "100011";
                sRelayRst <= '1';
                sCh2GainChangeRst <= '1';
                sCh2GainConfigFsm <= '1';
                if (sRelayTimer = 4) then
                    sNextState <= StIdle;
                end if;    
                                                
             when StError => --Error management to be added
                fsmcfg_state <= "111111";
                sNextState <= StStart;
                                                   
            when others =>
                sNextState <= StStart;
         end case;      
      end process; 
      
-----------------------------DATA PATH---------------------------------------------------

InstDcoBufio : BUFIO     --Clock buffer for IDDR primitive
   port map (
      O => DcoBufioClk, -- 1-bit output: Clock output (connect to I/O clock loads).
      I => DcoClk --CLK_DCO_Delay  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
   );
   
GenerateIDDR : for i in 0 to 13 generate      
      InstIDDR : IDDR 
      generic map (
         DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE", "SAME_EDGE" 
                                          -- or "SAME_EDGE_PIPELINED" 
         INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
         INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
         SRTYPE => "SYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
      port map (
         Q1 => dChannelA(i), -- 1-bit output for positive edge of clock  
         Q2 => dChannelB(i), -- 1-bit output for negative edge of clock
         C => DcoBufioClk,   -- 1-bit clock input
         CE => '1', -- 1-bit clock enable input
         D => dADC_Data(i),   -- 1-bit DDR data input
         R => '0',   -- 1-bit reset
         S => '0'    -- 1-bit set
         );
      
   end generate GenerateIDDR;

InstDcoBufg : BUFG    --Clock buffer for write FIFO clcok
   port map (
      O => DcoBufgClk, -- 1-bit output: Clock output (connect to I/O clock loads).
      I => DcoPLL_Clk  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
   );
   
--FIFO write clock deskew

InstBufgFeedbackPLL : BUFG  
   port map (
      O => FbinDcoClk, -- 1-bit output: Clock output (connect to I/O clock loads).
      I => FboutDcoClk --CLK_DCO_Delay  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
   );

   InstPLLE2 : PLLE2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
      CLKFBOUT_MULT => 8,        -- Multiply value for all CLKOUT, (2-64)
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
      CLKIN1_PERIOD => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT0_DIVIDE => 8,
      CLKOUT1_DIVIDE => 1,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
      STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => DcoPLL_Clk,   -- 1-bit output: CLKOUT0
      CLKOUT1 => open,   -- 1-bit output: CLKOUT1
      CLKOUT2 => open,   -- 1-bit output: CLKOUT2    
      CLKOUT3 => open,   -- 1-bit output: CLKOUT3
      CLKOUT4 => open,   -- 1-bit output: CLKOUT4
      CLKOUT5 => open,   -- 1-bit output: CLKOUT5
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => FboutDcoClk , -- 1-bit output: Feedback clock
      LOCKED => open,     -- 1-bit output: LOCK
      CLKIN1 => DcoClk,     -- 1-bit input: Input clock
      -- Control Ports: 1-bit (each) input: PLL control ports
      PWRDWN => '0',     -- 1-bit input: Power-down
      RST => Rst,           -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => FbinDcoClk    -- 1-bit input: Feedback clock
   );

--generate ADC CLKIN

InstADC_ClkODDR : ODDR   
   generic map(
      DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
      INIT => '0',   -- Initial value for Q port ('1' or '0')
      SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
   port map (
      Q => OddrClk,   -- 1-bit DDR output
      C => ADC_InClk,    -- 1-bit clock input
      CE => '1',  -- 1-bit clock enable input
      D1 => '1',  -- 1-bit data input (positive edge)
      D2 => '0',  -- 1-bit data input (negative edge)
      R => '0',    -- 1-bit reset input
      S => '0'     -- 1-bit set input
   ); 
   
InstADC_ClkOBUFDS : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
      SLEW => "SLOW")          -- Specify the output slew rate
   port map (
      O => adcClkIn_p,     -- Diff_p output (connect directly to top-level port)
      OB => adcClkIn_n,   -- Diff_n output (connect directly to top-level port)
      I => OddrClk      -- Buffer input 
   );
      
ProcChAFIFO_Wr : process (DcoBufgClk) --CHA FIFO write enable generation
begin
    if(DcoBufgClk' event and DcoBufgClk = '1') then
        if (dFIFO_AlmostFullChA = '1') then 
            dFIFO_WrEnChA <= '0';
        else
            dFIFO_WrEnChA <= '1';
        end if;
    end if;
end process;

ProcChAFIFO_Rd : process (SysClk)  --CHA FIFO read enable generation
begin
    if(SysClk' event and SysClk = '1') then
        if (sFIFO_AlmostEmptyChA = '1') then 
            sFIFO_RdEnChA <= '0';
        else
            sFIFO_RdEnChA <= '1';
        end if;
    end if;
end process;

ProcChBFIFO_Wr : process (DcoBufgClk)  --CHB FIFO write enable generation
begin
    if(DcoBufgClk' event and DcoBufgClk = '1') then
        if (dFIFO_AlmostFullChB = '1') then --if (dco_FIFO_WR_Rst_Busy_CHB = '1' or dco_FIFO_Full_CHB = '1') then
            dFIFO_WrEnChB <= '0';
        else
            dFIFO_WrEnChB <= '1';
        end if;
    end if;
end process;

ProcChBFIFO_Rd : process (SysClk)  --CHB FIFO read enable generation
begin
    if(SysClk' event and SysClk = '1') then
        if (sFIFO_AlmostEmptyChB = '1') then 
            sFIFO_RdEnChB <= '0';
        else
            sFIFO_RdEnChB <= '1';
        end if;
    end if;
end process;

-- Data Path FIFOs

InstChAFIFO : fifo_generator_adc --CHA FIFO
  PORT MAP (
    rst => sInitDoneR_n,
    wr_clk => DcoBufgClk,
    rd_clk => SysClk,
    din => dChannelA,
    wr_en => dFIFO_WrEnChA,
    rd_en => sFIFO_RdEnChA,
    dout => sChannelA,
    full => dFIFO_FullChA,
    almost_full => dFIFO_AlmostFullChA,
    empty => sFIFO_EmptyChA,
    almost_empty => sFIFO_AlmostEmptyChA
  );

InstChBFIFO : fifo_generator_adc  --CHB FIFO
  PORT MAP (
    rst => sInitDoneR_n,
    wr_clk => DcoBufgClk,
    rd_clk => SysClk,
    din => dChannelB,
    wr_en => dFIFO_WrEnChB,
    rd_en => sFIFO_RdEnChB,
    dout => sChannelB,
    full => dFIFO_FullChB,
    almost_full => dFIFO_AlmostFullChB,
    empty => sFIFO_EmptyChB,
    almost_empty => sFIFO_AlmostEmptyChB
    --wr_rst_busy => dco_FIFO_WR_Rst_Busy_CHB,
    --rd_rst_busy => sys_FIFO_RD_Rst_Busy_CHB
  );

-------------------------------Calibration-------------------------------------------------------------------------  
--Channel1 low gain gain compensation coefficient (output port or IP parameter)
sCh1CoefMultLg <= sExtCh1LgMultCoef when kExtCalibEn = true else kCh1LgMultCoefStatic;
--Channel1 high gain gain compensation coefficient (output port or IP parameter) 
sCh1CoefMultHg <= sExtCh1HgMultCoef when kExtCalibEn = true else kCh1HgMultCoefStatic;
--Channel1 low gain offset compensation coefficient (output port or IP parameter) 
sCh1CoefAddLg  <= sExtCh1LgAddCoef  when kExtCalibEn = true else kCh1LgAddCoefStatic;
--Channel1 high gain offset compensation coefficient (output port or IP parameter)  
sCh1CoefAddHg  <= sExtCh1HgAddCoef  when kExtCalibEn = true else kCh1HgAddCoefStatic;  
--Channel2 low gain gain compensation coefficient (output port or IP parameter)
sCh2CoefMultLg <= sExtCh2LgMultCoef when kExtCalibEn = true else kCh2LgMultCoefStatic; 
--Channel2 high gain gain compensation coefficient (output port or IP parameter)
sCh2CoefMultHg <= sExtCh2HgMultCoef when kExtCalibEn = true else kCh2HgMultCoefStatic; 
--Channel2 low gain offset compensation coefficient (output port or IP parameter)
sCh2CoefAddLg  <= sExtCh2LgAddCoef  when kExtCalibEn = true else kCh2LgAddCoefStatic;  
--Channel2 high gain offset compensation coefficient (output port or IP parameter)
sCh2CoefAddHg  <= sExtCh2HgAddCoef  when kExtCalibEn = true else kCh2HgAddCoefStatic;  

ProcCh1AddCoef : process (SysClk)  --determine CH1 additive coefficient
    begin
        if(SysClk' event and SysClk = '1') then
            if (sCh1GainState = '0') then 
                sCh1CoefAdd <= sCh1CoefAddLg(17) & sCh1CoefAddLg(17) & sCh1CoefAddLg & x"0000";
            else
                sCh1CoefAdd <= sCh1CoefAddHg(17) & sCh1CoefAddHg(17) & sCh1CoefAddHg & x"0000";
            end if;
        end if;
    end process;

ProcCh2AddCoef : process (SysClk)  --determine CH2 additive coefficient
    begin
        if(SysClk' event and SysClk = '1') then
            if (sCh2GainState = '0') then 
                sCh2CoefAdd <= sCh2CoefAddLg(17) & sCh2CoefAddLg(17) & sCh2CoefAddLg & x"0000";
            else
                sCh2CoefAdd <= sCh2CoefAddHg(17) & sCh2CoefAddHg(17) & sCh2CoefAddHg & x"0000";
            end if;
        end if;
    end process;

ProcCh1MultCoef : process (SysClk)  --determine CH1 additive coefficient
    begin
        if(SysClk' event and SysClk = '1') then
            if (sCh1GainState = '0') then 
                sCh1CoefMult <= sCh1CoefMultLg;
            else
                sCh1CoefMult <= sCh1CoefMultHg;
            end if;
        end if;
    end process;

ProcCh2MultCoef : process (SysClk) --determine CH2 additive coefficient 
    begin
        if(SysClk' event and SysClk = '1') then
            if (sCh2GainState = '0') then 
                sCh2CoefMult <= sCh2CoefMultLg;
            else
                sCh2CoefMult <= sCh2CoefMultHg;
            end if;
        end if;
    end process;

sChannelA18b <= sChannelA & "0000";
sSChannelA18b <= signed (sChannelA18b);
sChannelB18b <= sChannelB & "0000";
sSChannelB18b <= signed (sChannelB18b);
sSCh1CoefMult <= signed (sCh1CoefMult);
sSCh2CoefMult <= signed (sCh2CoefMult);
sSCh1CoefAdd <= signed (sCh1CoefAdd);
sSCh2CoefAdd <= signed (sCh2CoefAdd);

ProcCh1RegMultResult : process (SysClk) --register multiplication with multiplicative coefficien result for channel1 
begin
    if(SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then 
            sCh1CalibMult <= (others => '0');
        else
            sCh1CalibMult <= sSChannelA18b * sSCh1CoefMult;--sCh1CalibMult <= sSChannelA18b * (kOne18b + sSCh1CoefMult);
        end if;
    end if;
end process;

ProcCh2RegMultResult : process (SysClk) --register multiplication with multiplicative coefficien result for channel2 
begin
    if(SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then 
            sCh2CalibMult <= (others => '0');
        else
            sCh2CalibMult <= sSChannelB18b * sSCh2CoefMult;--sCh2CalibMult <= sSChannelB18b * (kOne18b + sSCh2CoefMult);
        end if;
    end if;
end process;

--sCh1CalibMult <= sSChannelA18b * (kOne18b + sSCh1CoefMult);
--sCh2CalibMult <= sSChannelB18b * (kOne18b + sSCh2CoefMult);
sCh1CalibMultInv <= -sCh1CalibMult;
sCh1CalibAdd <= sCh1CalibMultInv + sSCh1CoefAdd; 
--sCh1CalibAddInv <= -sCh1CalibAdd;
sCh2CalibAdd <= sCh2CalibMult + sSCh2CoefAdd; 
    
ProcCh1Calib : process (SysClk) --register calibration result for channel1 
begin
    if(SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then 
            sCh1Calib <= (others => '0');
        else
            if (sTestMode = '0') then
                if ((sCh1CalibAdd(35) = '1') and (sCh1CalibAdd(34 downto 33) /= "11")) then -- <-1
                    sCh1Calib <= "10" & x"0000";
                elsif ((sCh1CalibAdd(35) = '0') and (sCh1CalibAdd(34 downto 33) /= "00")) then -->1
                    sCh1Calib <= "01" & x"FFFF";
                else
                    sCh1Calib <= std_logic_vector (sCh1CalibAdd(33 downto 16));
                end if;
            else
                sCh1Calib <=  sChannelA & "0000";
            end if;
        end if;
    end if;
end process;

ProcCh2Calib : process (SysClk) --register calibration result for channel2   
begin
    if(SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then 
            sCh2Calib <= (others => '0');
        else
            if (sTestMode = '0') then
                if ((sCh2CalibAdd(35) = '1') and (sCh2CalibAdd(34 downto 33) /= "11")) then -- <-1
                    sCh2Calib <= "10" & x"0000";
                elsif ((sCh2CalibAdd(35) = '0') and (sCh2CalibAdd(34 downto 33) /= "00")) then -->1
                    sCh2Calib <= "01" & x"FFFF";
                else
                    sCh2Calib <= std_logic_vector (sCh2CalibAdd(33 downto 16));
                end if;
            else
                sCh2Calib <=  sChannelB & "0000";
            end if;
        end if;
    end if;
end process;

--CH1_TEST <= sChannelA;
--CH2_TEST <= sChannelB;

sCh2Out <= sCh2Calib(17 downto 2); 
sCh1Out <= sCh1Calib(17 downto 2); 

--SYNC generation
sADC_SyncOserdes <= sSyncIn;

InstSyncOserdes : OSERDESE2
   generic map (
      DATA_RATE_OQ => "SDR",   -- DDR, SDR
      DATA_RATE_TQ => "BUF",   -- DDR, BUF, SDR
      DATA_WIDTH => 4,         -- Parallel data width (2-8,10,14)
      INIT_OQ => '0',          -- Initial value of OQ output (1'b0,1'b1)
      INIT_TQ => '0',          -- Initial value of TQ output (1'b0,1'b1)
      SERDES_MODE => "MASTER", -- MASTER, SLAVE
      SRVAL_OQ => '0',         -- OQ output value when SR is used (1'b0,1'b1)
      SRVAL_TQ => '0',         -- TQ output value when SR is used (1'b0,1'b1)
      TBYTE_CTL => "FALSE",    -- Enable tristate byte operation (FALSE, TRUE)
      TBYTE_SRC => "FALSE",    -- Tristate byte source (FALSE, TRUE)
      TRISTATE_WIDTH => 1      -- 3-state converter width (1,4)
   )
   port map (
      OFB => open,             -- 1-bit output: Feedback path for data
      OQ => adcSync,               -- 1-bit output: Data path output
      -- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
      SHIFTOUT1 => open,
      SHIFTOUT2 => open,
      TBYTEOUT => open,   -- 1-bit output: Byte group tristate
      TFB => open,             -- 1-bit output: 3-state control
      TQ => open,               -- 1-bit output: 3-state control
      CLK => ADC_InClk,             -- 1-bit input: High speed clock
      CLKDIV => SysClk,       -- 1-bit input: Divided clock
      -- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
      D1 => sADC_SyncOserdes(0),
      D2 => sADC_SyncOserdes(1),
      D3 => sADC_SyncOserdes(2),
      D4 => sADC_SyncOserdes(3),
      D5 => '0',
      D6 => '0',
      D7 => '0',
      D8 => '0',
      OCE => '1',             -- 1-bit input: Output data clock enable
      RST => Rst,             -- 1-bit input: Reset
      -- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
      T1 => '0',
      T2 => '0',
      T3 => '0',
      T4 => '0',
      TBYTEIN => '0',     -- 1-bit input: Byte group tristate
      TCE => '0'              -- 1-bit input: 3-state clock enable
   );
             
end Behavioral;

