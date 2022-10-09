
-------------------------------------------------------------------------------
--
-- File: ZmodDAC1411_controller.vhd
-- Author: Tudor Gherman
-- Original Project: Zmod DAC 1411 Low Level Controller
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
--This module interfaces directly with the Zmod ADC 1410. It configures the Zmod's 
--DAC gain based on user options, writes an initial configuration to the AD9717
--(also performing a self calibration sequence), manages the DAC's SPI interface 
--and multiplexes the samples recieved on the two input data channels in the format
--requested by AD9717.
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;

entity ZmodDAC1411_Controller is
	generic (
	   kExtCalibEn : boolean := false;
       kExtScaleConfigEn : boolean := false;
       kExtCmdInterfaceEn : boolean := false;
    
	   kCh1LgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; --Channel1 low gain gain compensation coefficient parameter
	   kCh1LgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000"; --Channel1 low gain offset compensation coefficient parameter
       kCh1HgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; --Channel1 high gain gain compensation coefficient parameter 
       kCh1HgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000"; --Channel1 high gain offset compensation coefficient parameter
       kCh2LgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; --Channel2 low gain gain compensation coefficient parameter 
       kCh2LgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000"; --Channel2 low gain offset compensation coefficient parameter 
       kCh2HgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; --Channel2 high gain gain compensation coefficient parameter 
       kCh2HgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000"; --Channel2 high gain offset compensation coefficient parameter
    
       kCh1ScaleStatic : std_logic := '0'; -- 0 -> Low Gain; 1 -> High Gain; 
       kCh2ScaleStatic : std_logic := '0'  -- 0 -> Low Gain; 1 -> High Gain; 
    );
    Port (
       SysClk         : in  std_logic; -- 100MHZ clock input
       DacClk         : in  std_logic; -- 100MHZ clock input
       sRst_n          : in std_logic; --synchronous active low reset
       sInitDone_n : out std_logic;    -- initialization done active low indicator
       sCh1In : in std_logic_vector(13 downto 0);  --Channel1 data input
       sCh2In : in std_logic_vector(13 downto 0);  --Channel2 data input
       sDAC_EnIn : in std_logic;     --Zmod output relay control input signal 
       sExtCh1Scale : in std_logic;  --Channel1 scale select control input
       sExtCh2Scale : in std_logic;  --Channel2 scale select control input
       --Calibration
       sExtCh1LgMultCoef : in std_logic_vector (17 downto 0); --Channel1 low gain gain compensation coefficient external port
       sExtCh1LgAddCoef : in std_logic_vector (17 downto 0);  --Channel1 low gain offset compensation coefficient external port
       sExtCh1HgMultCoef : in std_logic_vector (17 downto 0); --Channel1 high gain gain compensation coefficient external port 
       sExtCh1HgAddCoef : in std_logic_vector (17 downto 0); --Channel1 high gain offset compensation coefficient external port 
       sExtCh2LgMultCoef : in std_logic_vector (17 downto 0); --Channel2 low gain gain compensation coefficient external port 
       sExtCh2LgAddCoef : in std_logic_vector (17 downto 0); --Channel2 low gain offset compensation coefficient external port 
       sExtCh2HgMultCoef : in std_logic_vector (17 downto 0); --Channel2 high gain gain compensation coefficient external port 
       sExtCh2HgAddCoef : in std_logic_vector (17 downto 0); --Channel2 high gain offset compensation coefficient external port 
       --AD9717 interface
       sDAC_CS : out std_logic;
       sDAC_SCLK : out std_logic;
       sDAC_SDIO : inout std_logic;
       sDAC_Reset : out std_logic;
       sDAC_ClkIO   : out std_logic;
       sDAC_Clkin   : out std_logic;
       sDAC_Data     : out std_logic_vector(13 downto 0);
       --Zmod DAC output control signals
       sDAC_SetFS1  : out std_logic;  --Scale select output control signal
       sDAC_SetFS2  : out std_logic;  --Scale select output control signal
       sDAC_EnOut : out std_logic;    --Zmod output relay control output signal
       --External access for the SPI configuration interface; Designed to work with 2 FIFOs, one for transmit commands and one for received data
       sExtSPI_Idle : out std_logic;                       --Flag indicating that the configuration state machine is in the IDLE state 
       sExtSPI_CmdDone : out std_logic;                    --Pulse indicating that the SPI command has been succesfully completed
       sExtSPI_TxRdEn : out std_logic;                     --Read enable used to load data from the command FIFO
       sExtSPI_TxRdEnRdy : in STD_LOGIC;                    --the IP waits for this signal to be asserted before signaling SPI command completion to upper level IP
       sExtSPI_TxDout : in std_logic_vector (23 downto 0); --Command input data
       sExtSPI_TxValid : in std_logic;                     --Command input data valid signal
       sExtSPI_EnTx : in std_logic;                        --Enable command transmit over the external SPI access interface
       sExtSPI_EnRx : in std_logic;                        --Enable command receive data over the external SPI access interface  
       sExtSPI_RxWrEn : out std_logic;                     --Receive data FIFO write enable signal  
       sExtSPI_RxDin : out std_logic_vector (7 downto 0)  --Receive data output 
       );
end ZmodDAC1411_Controller;

architecture Behavioral of ZmodDAC1411_Controller is
--Configuartion related signals
signal sInitDoneR_n, sInitDoneFsm_n : std_logic;
signal sCh1ScaleState, sCh2ScaleState : std_logic;
type FsmStates_t is (StStart, StWriteConfigReg, StReadConfigReg, StCheckRegData, StCheckCmdCnt, StInitDone, StError, StIdle, StExtSPI_Decode, 
StExtSPI_WrCmd, StExtSPI_RdCmd, StWaitDoneExtWrReg, StExtSPI_TxDone, StExtSPI_RxDone, StWaitDoneExtRdReg, StRegExtRxData, StCheckTimer, StReadCalstat, 
StCheckCalstat, StDisableCalen, StReadCalen, StDisableCalclk, StReadCalclk, StCheckCalclk, StCheckCalen); 
signal sCurrentState, sNextState : FsmStates_t;
signal fsmcfg_state, DAC_FSM_STATE_R : std_logic_vector(5 downto 0); --TO BE REMOVED
signal sDacEnFsm : std_logic;
signal sCmdCnt : integer range 0 to 21;
signal sIncCmdCnt, sRstCmdCnt : std_logic;
--SPI Interface signals
signal sDAC_SPI_StartTransfer, sDAC_SPI_RdWr, sDAC_SPI_Done :std_logic; 
signal sDAC_SPI_RdData, sDAC_SPI_WrData : std_logic_vector (7 downto 0);
signal sDAC_SPI_Width : std_logic_vector (1 downto 0);
signal sDAC_SPI_Addr : std_logic_vector (4 downto 0);
type DAC_SPI_Commands_t is array (10 downto 0) of std_logic_vector(15 downto 0);
type DAC_SPI_Readback_t is array (10 downto 0) of std_logic_vector(7 downto 0);
constant kDAC_SPI_Cmd : DAC_SPI_Commands_t := ( x"1210", --CALEN
                                                x"0E3A",
                                                x"0E0A",
                                                x"0E02",
                                                x"1200", --CALEN
                                                x"1400", --
                                                x"1408",
                                                x"1400",   -- Toggle Reaquire bit in CLKMODE register
                                                x"02B4",   -- Data Control
                                                x"0000",   -- SPI Control : Clear Reset
                                                x"0020"   -- SPI Control : Set Reset
                                               );
constant DAC_SPI_mask : DAC_SPI_Readback_t := ( x"EF", --CALEN
                                                x"00", --0E
                                                x"00", --0E
                                                x"00", --0E
                                                x"EF", --CALEN
                                                x"C3", --
                                                x"CB",
                                                x"C3",   
                                                x"40",
                                                x"80",
                                                x"80"
                                               );
--External Command FIFO Interface
signal sExtSPI_RxWrEn_fsm: std_logic;
signal sExtSPI_RxDin_fsm : std_logic_vector(7 downto 0);                                               
--Data Path signals
signal sODDR_D1, sODDR_D2 : std_logic_vector(13 downto 0);
signal sCh1CalibMult, sCh2CalibMult : signed(35 downto 0);
signal sCh1CalibAdd, sCh2CalibAdd : signed(35 downto 0);
signal sCh1Calib, sCh2Calib : std_logic_vector(17 downto 0);
signal sCh1CoefAdd, sCh2CoefAdd : std_logic_vector(35 downto 0);
signal sCh1CoefMult, sCh2CoefMult : std_logic_vector(17 downto 0);
signal sCh1CoefMultLg, sCh1CoefMultHg :  std_logic_vector (17 downto 0);
signal sCh1CoefAddLg, sCh1CoefAddHg : std_logic_vector (17 downto 0);
signal sCh2CoefMultLg, sCh2CoefMultHg : std_logic_vector (17 downto 0);
signal sCh2CoefAddLg, sCh2CoefAddHg : std_logic_vector (17 downto 0);
signal sSCh1_18b, sSCh2_18b : signed(17 downto 0);
signal sCh1_18b, sCh2_18b : std_logic_vector(17 downto 0);
signal sSCh1CoefMult, sSCh2CoefMult : signed(17 downto 0);
signal sSCh1CoefAdd, sSCh2CoefAdd : signed (35 downto 0);
--Timer
signal sTimer : integer range 0 to 65535;
signal sTimerCntEn, sTimerRst : std_logic;

component DAC_SPI 
    Port (           
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           SPI_CLK : out STD_LOGIC;
           SDIO : inout STD_LOGIC;
           CS : out STD_LOGIC;
           --TEST : out STD_LOGIC;
    
           START_TRANSFER : in std_logic;
           RD_DATA : out std_logic_vector(7 downto 0);
           WR_DATA : in std_logic_vector(7 downto 0);
           ADDRESS : in std_logic_vector(4 downto 0);
           WIDTH : in std_logic_vector(1 downto 0); --only one byte rx/tx supported
           RD_WR : in STD_LOGIC; 
           DONE : out STD_LOGIC );
end component;

begin

----------------------------Zmod Configuration-----------------------------------------------------------------------------------------
ProcDAC_Reset: process (SysClk) --AD9717 reset signal generation
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sDAC_Reset <= '1';
        else
            sDAC_Reset <= '0';
        end if;
    end if;
end process;

ProcDAC_En: process (SysClk) --Zmod DAC 1411 output relay control
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sDAC_EnOut <= '0';
        else
            sDAC_EnOut <= sDacEnFsm and sDAC_EnIn; --enable output once initialization is complete and external enable port is set
        end if;
    end if;
end process;

--Select Static or dynamic control for scale select
sCh1ScaleState <= sExtCh1Scale when kExtScaleConfigEn = true else kCh1ScaleStatic; --Channel1 AC/DC setting (output port or IP parameter)
sCh2ScaleState <= sExtCh2Scale when kExtScaleConfigEn = true else kCh2ScaleStatic; --Channel2 AC/DC setting (output port or IP parameter)
sDAC_SetFS1 <= sCh1ScaleState;
sDAC_SetFS2 <= sCh2ScaleState;

InstDAC_SPI: DAC_SPI --SPI controller instantiation
    Port Map (           
           CLK => SysClk,
           RST => sRst_n,
           SPI_CLK => sDAC_SCLK,
           SDIO => sDAC_SDIO,
           CS => sDAC_CS,
           START_TRANSFER => sDAC_SPI_StartTransfer, 
           RD_DATA => sDAC_SPI_RdData,               
           WR_DATA => sDAC_SPI_WrData,               
           ADDRESS => sDAC_SPI_Addr,                  
           WIDTH => sDAC_SPI_Width,
           RD_WR => sDAC_SPI_RdWr,
           DONE => sDAC_SPI_Done );

ProcCmdConter: process (SysClk)  -- Succesfully sent SPI command counter
begin
    if (SysClk' event and SysClk = '1') then
        if (sRstCmdCnt = '1' or sRst_n = '0') then
            sCmdCnt <= 0;
        else
            if (sIncCmdCnt = '1') then
                sCmdCnt <= sCmdCnt + 1;
            end if;
        end if;        
    end if;
end process;

ProcRelayTimer: process (SysClk)   --Timer
begin
    if (SysClk' event and SysClk = '1') then
        if ((sRst_n = '0') or (sTimerRst = '0')) then 
            sTimer <= 0;
        else
            if(sTimerCntEn = '1') then
                sTimer <= sTimer + 1;
            end if;        
        end if;
    end if;
end process;
   
--Configuration state machine
ProcFsmSync: process (SysClk)
      begin
         if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
               sCurrentState <= StStart;
               DAC_FSM_STATE_R <= (others => '0');
            else
               sCurrentState <= sNextState;
               DAC_FSM_STATE_R <= fsmcfg_state;
            end if;        
         end if;
      end process;
      
procNextStateAndOutput: process (sCurrentState, sCmdCnt, sDAC_SPI_Done, sDAC_SPI_RdData)
      begin         
         sNextState <= sCurrentState;  
         fsmcfg_state <= "000000";
         sRstCmdCnt <= '1';
         sIncCmdCnt <= '0';
         sInitDoneFsm_n <= '1';      
         sDAC_SPI_StartTransfer <= '0';                              
         sDAC_SPI_Addr <= (others => '0');
         sDAC_SPI_WrData <= (others => '0');                  
         sDAC_SPI_Width <= "00";
         sDAC_SPI_RdWr <= '0';
         sDacEnFsm <= '0';
         sExtSPI_TxRdEn <= '0';
         sExtSPI_CmdDone <= '0';
         sExtSPI_RxWrEn_fsm  <= '0';
         sExtSPI_RxDin_fsm  <= (others => '0');
         sTimerRst <= '0';
         sTimerCntEn <= '0';
         
         case (sCurrentState) is
            when StStart =>
                fsmcfg_state <= "000000";
                sNextState <= StWriteConfigReg;              
                
            when StWriteConfigReg =>
                fsmcfg_state <= "000001"; 
                sRstCmdCnt <= '0';
                sDAC_SPI_StartTransfer <= '1';                
                sDAC_SPI_WrData <= kDAC_SPI_Cmd(sCmdCnt)(7 downto 0);--x"84";               
                sDAC_SPI_Addr <= kDAC_SPI_Cmd(sCmdCnt)(12 downto 8);--"00010";                  
                sDAC_SPI_Width <= "00";
                if (sDAC_SPI_Done = '1') then
                    sNextState <= StReadConfigReg; 
                    sDAC_SPI_StartTransfer <= '0';   
                end if;
    
             when StReadConfigReg =>
                fsmcfg_state <= "000010"; 
                sRstCmdCnt <= '0';
                sDAC_SPI_StartTransfer <= '1';                              
                sDAC_SPI_Addr <= kDAC_SPI_Cmd(sCmdCnt)(12 downto 8);--"00010";                  
                sDAC_SPI_Width <= "00";
                sDAC_SPI_RdWr <= '1';
                if (sDAC_SPI_Done = '1') then
                    sNextState <= StCheckRegData;
                end if;
    
             when StCheckRegData =>
                fsmcfg_state <= "000011";
                sRstCmdCnt <= '0';                             
                if ((sDAC_SPI_RdData or DAC_SPI_mask(sCmdCnt)) = (kDAC_SPI_Cmd(sCmdCnt)(7 downto 0) or DAC_SPI_mask(sCmdCnt))) then
                    sNextState <= StCheckCmdCnt;
                else
                    sNextState <= StWriteConfigReg;    
                end if;                           

             when StCheckCmdCnt =>
                fsmcfg_state <= "000100";
                sRstCmdCnt <= '0';
                if (sCmdCnt = 10) then
                    sNextState <= StCheckTimer;
                else
                    sIncCmdCnt <= '1';
                    sNextState <= StWriteConfigReg;       
                end if; 
                
             when StCheckTimer => --Self Calibration step 4: Wait aprox 300 calibration clk cycles
                sTimerRst <= '1';
                sTimerCntEn <= '1';
                if (sTimer = 65535) then
                    sNextState <= StReadCalstat;
                end if;   
   
             when StReadCalstat => --Self calibration step 5: Check self calibration status
                fsmcfg_state <= "000101"; 
                sRstCmdCnt <= '0';
                sDAC_SPI_StartTransfer <= '1';                              
                sDAC_SPI_Addr <= "01111"; --Cal Memory Register                
                sDAC_SPI_Width <= "00";
                sDAC_SPI_RdWr <= '1';
                if (sDAC_SPI_Done = '1') then
                    sNextState <= StCheckCalstat;
                end if;
    
             when StCheckCalstat =>
                if ((sDAC_SPI_RdData(7 downto 6) = "11")) then --Check CALSTATQ, CALSTATI
                    sNextState <= StDisableCalen;
                else
                    sNextState <= StReadCalstat;    
                end if;   

             when StDisableCalen =>    --Self Calibration Step 6: Write 0x00 to Register 0x12
                fsmcfg_state <= "000110"; 
                sRstCmdCnt <= '0';
                sDAC_SPI_StartTransfer <= '1';                
                sDAC_SPI_WrData <= x"00";             
                sDAC_SPI_Addr <= "10010"; --Memory R/W Register                 
                sDAC_SPI_Width <= "00";
                if (sDAC_SPI_Done = '1') then
                    sNextState <= StReadCalen; 
                    sDAC_SPI_StartTransfer <= '0';   
                end if;
    
             when StReadCalen =>
                fsmcfg_state <= "000111"; 
                sRstCmdCnt <= '0';
                sDAC_SPI_StartTransfer <= '1';                              
                sDAC_SPI_Addr <= "10010";            
                sDAC_SPI_Width <= "00";
                sDAC_SPI_RdWr <= '1';
                if (sDAC_SPI_Done = '1') then
                    sNextState <= StCheckCalen;
                end if;
    
             when StCheckCalen => --Check if Register 0x12 has been correctly written
                fsmcfg_state <= "001000";
                sRstCmdCnt <= '0';                             
                if (sDAC_SPI_RdData = x"00") then
                    sNextState <= StDisableCalclk;
                else
                    sNextState <= StError;    
                end if; 

             when StDisableCalclk =>   --Self Calibration step 7: disable calibration clock
                fsmcfg_state <= "001001"; 
                sRstCmdCnt <= '0';
                sDAC_SPI_StartTransfer <= '1';                
                sDAC_SPI_WrData <= x"00";             
                sDAC_SPI_Addr <= "01110"; --Cal Control               
                sDAC_SPI_Width <= "00";
                if (sDAC_SPI_Done = '1') then
                    sNextState <= StReadCalclk; 
                    sDAC_SPI_StartTransfer <= '0';   
                end if;
    
             when StReadCalclk =>
                fsmcfg_state <= "001010"; 
                sRstCmdCnt <= '0';
                sDAC_SPI_StartTransfer <= '1';                              
                sDAC_SPI_Addr <= "01110";            
                sDAC_SPI_Width <= "00";
                sDAC_SPI_RdWr <= '1';
                if (sDAC_SPI_Done = '1') then
                    sNextState <= StCheckCalclk;
                end if;
    
             when StCheckCalclk =>
                fsmcfg_state <= "001011";
                sRstCmdCnt <= '0';                             
                if (sDAC_SPI_RdData = x"00") then
                    sNextState <= StInitDone;
                else
                    sNextState <= StError;    
                end if; 
                                                            
             when StInitDone => 
                fsmcfg_state <= "001100";
                sDacEnFsm <= '1';
                sInitDoneFsm_n <= '0';
                sNextState <= StIdle;

             when StIdle =>  --IDLE state; wait for changes on the external SPI access interface or on the relay configuration signals
                fsmcfg_state <= "001101";
                sDacEnFsm <= '1';
                sInitDoneFsm_n <= '0';
                if (sExtSPI_EnTx = '1' and sExtSPI_TxValid = '1') then 
                    sNextState <= StExtSPI_Decode;
                else
                    sNextState <= StIdle;
                end if;
                          
             when StExtSPI_Decode =>  --decode the external SPI command   
                fsmcfg_state <= "001110";
                sDacEnFsm <= '1';
                sInitDoneFsm_n <= '0';
                if (sExtSPI_TxDout(23) = '0') then
                    sNextState <= StExtSPI_WrCmd; 
                else
                    sNextState <= StExtSPI_RdCmd; 
                end if; 
                                
             when StExtSPI_WrCmd =>  --execute the write register command
                fsmcfg_state <= "001111";
                sDacEnFsm <= '1';
                sInitDoneFsm_n <= '0';
                sDAC_SPI_StartTransfer <= '1';
                sDAC_SPI_WrData <= sExtSPI_TxDout(7 downto 0);
                sDAC_SPI_Addr <= sExtSPI_TxDout(12 downto 8);
                sDAC_SPI_Width <= sExtSPI_TxDout(22 downto 21);
--                sADC_SPI_WrEn  <= '1';
                if (sDAC_SPI_Done = '1') then
                    sExtSPI_TxRdEn <= '1';
                    sNextState <= StExtSPI_TxDone;
                end if;
                --sNextState <= StWaitDoneExtWrReg;    

--             when StWaitDoneExtWrReg => --wait for the write register command to complete
--                fsmcfg_state <= "011101";
--                sInitDoneFsm_n <= '0';
--                if (sDAC_SPI_Done = '1') then
--                    sExtSPI_TxRdEn <= '1';
--                    sNextState <= StExtSPI_TxDone;
--                end if;
                
            when StExtSPI_TxDone =>  
                fsmcfg_state <= "010000";
                sDacEnFsm <= '1';
                sInitDoneFsm_n <= '0';
                if (sExtSPI_TxRdEnRdy = '1') then
                    sExtSPI_CmdDone  <= '1';
                    sNextState <= StIdle;
                end if;
                                
            when StExtSPI_RdCmd =>  --execute the read register command
                fsmcfg_state <= "010001";
                sDacEnFsm <= '1';
                sInitDoneFsm_n <= '0';
                sDAC_SPI_StartTransfer <= '1';
                sDAC_SPI_RdWr <= '1';
                sDAC_SPI_Addr <= sExtSPI_TxDout(12 downto 8);
                sDAC_SPI_Width <= sExtSPI_TxDout(22 downto 21);
--                sADC_SPI_RdEn <= '1';
                if (sDAC_SPI_Done = '1') then
                    sExtSPI_TxRdEn <= '1';
                    sNextState <= StRegExtRxData;
                end if;
--                sNextState <= StWaitDoneExtRdReg; 


--             when StWaitDoneExtRdReg => --wait for the read register command to complete and load the next command for the transmit FIFO
--                fsmcfg_state <= "011110";
--                sInitDoneFsm_n <= '0';
--                if (sDAC_SPI_Done = '1') then
--                    sExtSPI_TxRdEn <= '1';
--                    sNextState <= StRegExtRxData;
--                end if;
               
             when StRegExtRxData => --used to register the incomming SPI data
                fsmcfg_state <= "010010";
                sDacEnFsm <= '1';
                sInitDoneFsm_n <= '0';
                sExtSPI_RxWrEn_fsm  <= '1';
                sExtSPI_RxDin_fsm  <= sDAC_SPI_RdData(7 downto 0);
                --sExtSPI_CmdDone  <= '1';
                sNextState <= StExtSPI_RxDone;

            when StExtSPI_RxDone =>  
                fsmcfg_state <= "010011";
                sDacEnFsm <= '1';
                sInitDoneFsm_n <= '0';
                if (sExtSPI_TxRdEnRdy = '1') then
                    sExtSPI_CmdDone  <= '1';
                    sNextState <= StIdle;
                end if;
                                                
             when StError =>
                fsmcfg_state <= "111111";
                sNextState <= StStart;
                                       
            when others =>
                sNextState <= StStart;
         end case;      
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
      
ProcInitDone: process (SysClk) --Initialization complete flag process
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sInitDoneR_n <= '1';
        else
            sInitDoneR_n <= sInitDoneFsm_n;  
        end if;
    end if;
end process;

sInitDone_n <= sInitDoneR_n;

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
------------------------------------Output Clock Genereation---------------------------------------------------------------------------

InstDAC_ClkinODDR : ODDR
generic map(
   DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "ASYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => sDAC_Clkin,   -- 1-bit DDR output
   C => DacClk,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => '1',  -- 1-bit data input (positive edge)
   D2 => '0',  -- 1-bit data input (negative edge)
   R => '0',    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);
InstDAC_ClkIO_ODDR : ODDR
generic map(
   DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "ASYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => sDAC_ClkIO,   -- 1-bit DDR output
   C => DacClk,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => '1',  -- 1-bit data input (positive edge)
   D2 => '0',  -- 1-bit data input (negative edge)
   R => '0',    -- 1-bit reset input
   S => '0'     -- 1-bit set input
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
            if (sCh1ScaleState = '0') then 
                sCh1CoefAdd <= sCh1CoefAddLg(17) & sCh1CoefAddLg(17) & sCh1CoefAddLg & x"0000";
            else
                sCh1CoefAdd <= sCh1CoefAddHg(17) & sCh1CoefAddHg(17) & sCh1CoefAddHg & x"0000";
            end if;
        end if;
    end process;

ProcCh2AddCoef : process (SysClk)  --determine CH2 additive coefficient
    begin
        if(SysClk' event and SysClk = '1') then
            if (sCh2ScaleState = '0') then 
                sCh2CoefAdd <= sCh2CoefAddLg(17) & sCh2CoefAddLg(17) & sCh2CoefAddLg & x"0000";
            else
                sCh2CoefAdd <= sCh2CoefAddHg(17) & sCh2CoefAddHg(17) & sCh2CoefAddHg & x"0000";
            end if;
        end if;
    end process;

ProcCh1MultCoef : process (SysClk)  --determine CH1 additive coefficient
    begin
        if(SysClk' event and SysClk = '1') then
            if (sCh1ScaleState = '0') then 
                sCh1CoefMult <= sCh1CoefMultLg;
            else
                sCh1CoefMult <= sCh1CoefMultHg;
            end if;
        end if;
    end process;

ProcCh2MultCoef : process (SysClk) --determine CH2 additive coefficient 
    begin
        if(SysClk' event and SysClk = '1') then
            if (sCh2ScaleState = '0') then 
                sCh2CoefMult <= sCh2CoefMultLg;
            else
                sCh2CoefMult <= sCh2CoefMultHg;
            end if;
        end if;
    end process;

sCh1_18b <= sCh1In & "0000";
sSCh1_18b <= signed (sCh1_18b);
sCh2_18b <= sCh2In & "0000";
sSCh2_18b <= signed (sCh2_18b);
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
            sCh1CalibMult <= sSCh1_18b * sSCh1CoefMult;--sCh1CalibMult <= sSCh1_18b * (kOne18b + sSCh1CoefMult);
        end if;
    end if;
end process;

ProcCh2RegMultResult : process (SysClk) --register multiplication with multiplicative coefficien result for channel2 
begin
    if(SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then 
            sCh2CalibMult <= (others => '0');
        else
            sCh2CalibMult <= sSCh2_18b * sSCh2CoefMult;--sCh2CalibMult <= sSCh2_18b * (kOne18b + sSCh2CoefMult);
        end if;
    end if;
end process;

sCh1CalibAdd <= sCh1CalibMult + sSCh1CoefAdd; 
sCh2CalibAdd <= sCh2CalibMult + sSCh2CoefAdd; 
    
ProcCh1Calib : process (SysClk) --register calibration result for channel1 
begin
    if(SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then 
            sCh1Calib <= (others => '0');
        else
            --if (sTestMode = '0') then
                if ((sCh1CalibAdd(35) = '1') and (sCh1CalibAdd(34 downto 33) /= "11")) then -- <-1
                    sCh1Calib <= "10" & x"0000";
                elsif ((sCh1CalibAdd(35) = '0') and (sCh1CalibAdd(34 downto 33) /= "00")) then -->1
                    sCh1Calib <= "01" & x"FFFF";
                else
                    sCh1Calib <= std_logic_vector (sCh1CalibAdd(33 downto 16));
                end if;
            --else
                --sCh1Calib <=  sChannelA & "0000";
            --end if;
        end if;
    end if;
end process;

ProcCh2Calib : process (SysClk) --register calibration result for channel2   
begin
    if(SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then 
            sCh2Calib <= (others => '0');
        else
            --if (sTestMode = '0') then
                if ((sCh2CalibAdd(35) = '1') and (sCh2CalibAdd(34 downto 33) /= "11")) then -- <-1
                    sCh2Calib <= "10" & x"0000";
                elsif ((sCh2CalibAdd(35) = '0') and (sCh2CalibAdd(34 downto 33) /= "00")) then -->1
                    sCh2Calib <= "01" & x"FFFF";
                else
                    sCh2Calib <= std_logic_vector (sCh2CalibAdd(33 downto 16));
                end if;
            --else
                --sCh2Calib <=  sChannelB & "0000";
            --end if;
        end if;
    end if;
end process;

sODDR_D1 <=  sCh1Calib(17 downto 4);
sODDR_D2 <=  sCh2Calib(17 downto 4);

---------------------------------Output Data DDR Interface---------------------------------------------------------
ForDAC_Data: for i in 0 to 13 generate
InstDataODDR : ODDR
generic map(
   DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "ASYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => sDAC_Data(i),   -- 1-bit DDR output
   C => SysClk,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => sODDR_D1(i),  -- 1-bit data input (positive edge)
   D2 => sODDR_D2(i),  -- 1-bit data input (negative edge)
   R => '0',    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);
end generate;


end Behavioral;
