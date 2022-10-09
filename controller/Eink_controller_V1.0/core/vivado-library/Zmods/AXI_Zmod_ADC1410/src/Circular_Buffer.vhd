
-------------------------------------------------------------------------------
--
-- File: Circular_Buffer.vhd
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
--This module implements the circular buffer, the trigger mechanism and the 
--AXI Stream to BRAM bridge.
--  
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Circular_Buffer is
    Generic 
    (
    kBufferSize: integer range 0 to 1024 := 14
    );
    Port ( SysClk : in STD_LOGIC; --100MHz input clock
           AxiStreamClk : in STD_LOGIC; --AXI Stream input clock
           AxiLiteClk : in std_logic; --AXI Lite input clock
           sRst_n : in STD_LOGIC; --Active low synchronous reset signal synchronized with SysClk
           xsRst_n : in STD_LOGIC; --Active low synchronous reset signal synchronized with AxiStreamClk 
           sInitDone_n: in STD_LOGIC; --Input flag (active low) indicating that the Zmod DAC Low Level 
                                      -- Controller has succesfully completed initialization 
           sCh1In : in STD_LOGIC_VECTOR (13 downto 0); --Channel1 data input
           sCh2In : in STD_LOGIC_VECTOR (13 downto 0); --Channel2 data input
           --AXI Stream (MM2S)
           s_axis_s2mm_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           s_axis_s2mm_tkeep : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
           s_axis_s2mm_tvalid : OUT STD_LOGIC;
           s_axis_s2mm_tready : IN STD_LOGIC;
           s_axis_s2mm_tlast : OUT STD_LOGIC;
           
           sAqRunStop: in STD_LOGIC; --Control bit triggering the start of a new aquisition when the buffer control FSM is in idle state
           sTrigLevel : in STD_LOGIC_VECTOR (13 downto 0); --Trigger Level
           sTrigMode : in STD_LOGIC_VECTOR (1 downto 0); --Trigger mode: AUTO, NONE, NORMAL
           sTrigRisingFalling : in STD_LOGIC; --0 -> rising; 1 -> falling
           sTrigChSelect : in STD_LOGIC; -- 0 -> Channel1; 1 -> Channel2
           lWindowPosition : in STD_LOGIC_VECTOR (kBufferSize-1 downto 0); --Trigger position in window
           sTransferLength : in STD_LOGIC_VECTOR (kBufferSize-1 downto 0); --Circular buffer depth (ynchronized in SysClk clock domain)
           xsTransferLength : in std_logic_vector (kBufferSize-1 downto 0); --Circular buffer depth (ynchronized in AxiStreamClk clock domain)
           lSetStop : out STD_LOGIC; --Pulse that resets the Aquisition Run/Stop bit in the Control Register
           lBufferFull : out STD_LOGIC--Flag indicating that the number of samples specified in the S2MM_Lenght registers
                                       --have been loaded in the circular buffer
          );
end Circular_Buffer;

architecture Behavioral of Circular_Buffer is

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
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

type BufferDataArray_t is array (27 downto 0) of std_logic_vector(0 downto 0);
type WeDataArray_t is array (27 downto 0) of std_logic_vector(0 downto 0);
type FsmStates_t is (StIdle, StArm, StWaitTrigger, StLoadBufferNormal, StLoadBufferNone, StBufferFullPush, StBufferFullAck, StSendBufferDummy, 
StSendBuffer, StSetStop, StSetStopAck, StOutAddrCntPush, StOutAddrCntAck, StWaitStop);
--Active high reset signal 
signal aRst_p : std_logic;
--Buffer write channel related signals
signal sBufferInputData : std_logic_vector (27 downto 0);
signal sEnaBuffer, sEnaBufferFsm : std_logic_vector (27 downto 0);
signal sWeaBuffer : std_logic_vector (27 downto 0);
signal sWeaArray : WeDataArray_t;
signal sBufferInputArray : BufferDataArray_t;
signal sInAddrCounter, sInAddrCounterR : std_logic_vector (kBufferSize-1 downto 0); --conter used to generate the BRAM write port address
signal sInAddrCntEn : std_logic; --write port address counter increment enable
signal sInAddrCntRst: std_logic; --write port address counter reset
signal sLoadBufStart : std_logic; --flag indicating that the trigger condition has been met
signal sAddrTrigger : std_logic_vector (kBufferSize-1 downto 0); --BRAM write port address corresponding to trigger condition being met
--Buffer read channel and BRAM to Axi Stream related signals
signal xsBufferOutputData : std_logic_vector (27 downto 0);
signal xsEnbBuffer : std_logic_vector (27 downto 0);
signal xsBufferOutArray : BufferDataArray_t;
signal xsOutAddrCounter, xsOutAddrCounterR : std_logic_vector (kBufferSize-1 downto 0);
signal xsBufferFullAddr : std_logic_vector (kBufferSize-1 downto 0);
signal sOutAddrCntEn, sOutAddrCntEnR : std_logic_vector(0 downto 0);
signal xsOutAddrCntEnR, xsOutAddrCntEn, xsOutAddrCntEnRR: std_logic;
signal xsOutAddrCntPulse, xsOutAddrCntPulseR : std_logic;
signal xsOutAddrCntStart, sOutAddrCntStart : std_logic_vector (kBufferSize-1 downto 0); --buffer start address in BRAM
signal xsBufEmpty, xsBufEmptyR : std_logic; --flag indicating all requested S2MM data has been transfered in Axi Stream clock domain
signal sBufEmpty : std_logic_vector(0 downto 0); --flag indicating all requested S2MM data has been transfered in system clock domain
signal sLoadOutCnt : std_logic_vector (0 downto 0); --signal that resets the BRAM read address port counter once the buffer is filled (in system clock domain)
signal xsLoadOutCnt : std_logic; --signal that resets the BRAM read address port counter once the buffer is filled (in system Axi Stream clock domain)
signal xsTvalidDisable : std_logic; --signal used to deassert s_axis_s2mm_tvalid once all requested bytes have been transfered
--Buffer control state machine related signals
signal sCurrentState, sNextState : FsmStates_t;
signal fsmcfg_state, fsmcfg_state_r : std_logic_vector(4 downto 0);
--Trigger related signals
signal sTriggerSource, sTriggerSourceR : std_logic_vector (13 downto 0);
signal sTriggerCondition : std_logic;
--Axi Stream interface related signals
signal xsS2MM_TkeepLoc  : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal xsS2MM_TvalidLoc : STD_LOGIC;
signal xsS2MM_TlastLoc  :  STD_LOGIC;
signal xsS2MM_TdataLoc, xsTdataAux :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal xsS2MM_TreadyR, xsTreadyRising, xsTreadyFalling :  STD_LOGIC;
--Control register and status register write strobe signals
signal sBufferFull : std_logic_vector(0 downto 0); --pulse indicating the buffer has aquired the requested amount of data
signal sSetStop : std_logic_vector(0 downto 0); --pulse reseting the run/stop bit in the control register once the requested data has been transffered to system memory
--Clock domain crossing related signals
signal sBufFullRdy, sBufFullPush, lBufFullValid : std_logic;
signal xsBufEmptyIdata : std_logic_vector(0 downto 0);
signal xsBufEmptyRdy, xsBufEmptyPush, sBufEmptyValid : std_logic;
signal sSetStopRdy, sSetStopPush, lSetStopValid : std_logic;
signal sLoadOutCntPush, sLoadOutCntRdy, xsLoadOutCntValid : std_logic;
signal sOutAddrCntStartPush, sOutAddrCntStartRdy, xsOutAddrCntStartValid : std_logic;
signal sOutAddrCntEnRdy, sOutAddrCntEnPush, xsOutAddrCntEnValid, sOutAddrCntEnRstPush, sOutAddrCntEnSetPush : std_logic;
signal xsOutAddrCntEnDout,sOutAddrCntEnDin : std_logic_vector(0 downto 0);
signal xsOutAddrCntOdata : std_logic_vector (kBufferSize-1 downto 0); 
       
begin

aRst_p <= not sRst_n;
sBufferInputData <= sCh1In & sCh2In;
sTriggerSource <= sCh1In when (sTrigChSelect = '0') else sCh2In;

ProcBufferPortAssign : process (sWeaBuffer)
begin
	for Index in 0 to 27 loop
        sWeaArray(Index)(0) <= sWeaBuffer(Index);
        sBufferInputArray(Index)(0) <= sBufferInputData(Index);
        xsBufferOutputData(Index) <= xsBufferOutArray(Index)(0);
    end loop;
end process;
sEnaBuffer <= (others => '1'); 

GenerateBuffer : for Index in 0 to 27 generate     
  
    InstBRAM_Buffer : blk_mem_gen_0
      PORT MAP (
        clka => SysClk,
        ena => sEnaBuffer(Index),
        wea => sWeaArray(Index),
        addra => sInAddrCounterR,
        dina => sBufferInputArray(Index),
        clkb => AxiStreamClk,
        enb => xsEnbBuffer(Index),
        addrb => xsOutAddrCounter,
        doutb => xsBufferOutArray(Index)
      );        
 end generate GenerateBuffer;
 
 --Input Buffer Address Counter
ProcInAddrCounter: process (SysClk)  
begin
    if (SysClk' event and SysClk = '1') then
        if ((sInitDone_n = '1') or (sInAddrCntRst = '0')) then
            sInAddrCounter <= (others => '0');
            sInAddrCounterR <= (others => '0');
            sWeaBuffer <= (others => '0');
        else
            sInAddrCounterR <= sInAddrCounter;
            if(sInAddrCntEn = '1') then
                sInAddrCounter <= sInAddrCounter + '1';
                sWeaBuffer <= (others => '1');
            else
                sWeaBuffer <= (others => '0');
            end if;        
        end if;
    end if;
end process;

ProcAddrTrigger: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sAddrTrigger <= (others => '0');
        else
            if(sLoadBufStart = '1') then
                sAddrTrigger <= sInAddrCounterR;
            end if;        
        end if;
    end if;
end process;

ProcTriggerSource: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sTriggerSourceR <= (others => '0');
        else
            sTriggerSourceR <= sTriggerSource;        
        end if;
    end if;
end process;

ProcTriggerCondition: process (sTrigLevel, sTrigRisingFalling)
begin
    if (sTrigRisingFalling = '0') then --Rising edge
        if (sTrigLevel(13) = '0') then --Trigger is positive
            if ((sTriggerSource(13) = '0') and (sTriggerSourceR(13) = '0')) then
                if ((sTriggerSource(12 downto 0) >= sTrigLevel(12 downto 0)) and (sTriggerSourceR(12 downto 0) <= sTrigLevel(12 downto 0))) then 
                    sTriggerCondition <= '1';
                else
                    sTriggerCondition <= '0';       
                end if;
            elsif ((sTriggerSource(13) = '0') and (sTriggerSourceR(13) = '1')) then --trigger source is rising; condition gurantees sTriggerSourceR < sTriggerSource
                if (sTriggerSource(12 downto 0) >= sTrigLevel(12 downto 0)) then 
                    sTriggerCondition <= '1';
                else
                    sTriggerCondition <= '0';       
                end if;
            else
                sTriggerCondition <= '0'; 
            end if;
        else --Trigger is negative
            if ((sTriggerSource(13) = '1') and (sTriggerSourceR(13) = '1')) then
                if ((sTriggerSource(12 downto 0) <= sTrigLevel(12 downto 0)) and (sTriggerSourceR(12 downto 0) >= sTrigLevel(12 downto 0))) then 
                    sTriggerCondition <= '1';
                else
                    sTriggerCondition <= '0';       
                end if;
            elsif ((sTriggerSource(13) = '0') and (sTriggerSourceR(13) = '1')) then --trigger source is rising; condition gurantees sTriggerSourceR < sTriggerSource
                if (sTriggerSource(12 downto 0) <= sTrigLevel(12 downto 0)) then 
                    sTriggerCondition <= '1';
                else
                    sTriggerCondition <= '0';       
                end if;
            else
                sTriggerCondition <= '0'; 
            end if;
        end if;
    else --Falling edge
        if (sTrigLevel(13) = '0') then --Trigger is positive
            if ((sTriggerSource(13) = '0') and (sTriggerSourceR(13) = '0')) then
                if ((sTriggerSource(12 downto 0) <= sTrigLevel(12 downto 0)) and (sTriggerSourceR(12 downto 0) >= sTrigLevel(12 downto 0))) then 
                    sTriggerCondition <= '1';
                else
                    sTriggerCondition <= '0';       
                end if;
            elsif ((sTriggerSourceR(13) = '0') and (sTriggerSource(13) = '1')) then --trigger source is rising; condition gurantees sTriggerSourceR > sTriggerSource
                if (sTriggerSource(12 downto 0) <= sTrigLevel(12 downto 0)) then 
                    sTriggerCondition <= '1';
                else
                    sTriggerCondition <= '0';       
                end if;
            else
                sTriggerCondition <= '0'; 
            end if;
        else --Trigger is negative
            if ((sTriggerSource(13) = '1') and (sTriggerSourceR(13) = '1')) then
                if ((sTriggerSource(12 downto 0) >= sTrigLevel(12 downto 0)) and (sTriggerSourceR(12 downto 0) <= sTrigLevel(12 downto 0))) then 
                    sTriggerCondition <= '1';
                else
                    sTriggerCondition <= '0';       
                end if;
            elsif ((sTriggerSourceR(13) = '0') and (sTriggerSource(13) = '1')) then --trigger source is rising; condition gurantees sTriggerSourceR > sTriggerSource
                if (sTriggerSource(12 downto 0) >= sTrigLevel(12 downto 0)) then 
                    sTriggerCondition <= '1';
                else
                    sTriggerCondition <= '0';       
                end if;
            else
                sTriggerCondition <= '0'; 
            end if;
        end if;
    end if;
end process;
 
ProcSyncFSM: process (SysClk, sRst_n)
      begin
         if (SysClk'event and SysClk = '1') then
            if ((sInitDone_n = '1') or (sRst_n = '0'))then
               sCurrentState <= StIdle;
               fsmcfg_state_r <= fsmcfg_state;
            else
               sCurrentState <= sNextState;
               fsmcfg_state_r <= fsmcfg_state;

            end if;        
         end if;
      end process;
      
ProcNextStateAndOutputDecode: process (sCurrentState, sAqRunStop, sInAddrCounter)
begin 
    sNextState <= sCurrentState;  
    fsmcfg_state <= "00000";
    sLoadBufStart <= '0';     
    sInAddrCntEn <= '0';
    sInAddrCntRst <= '0';
    sSetStop <= "0";
    sSetStopPush <= '0';
    sBufferFull <= "0";
    sBufFullPush <= '0';
    sLoadOutCntPush <= '0';
    sLoadOutCnt <= "0";
    sOutAddrCntStartPush <= '0';
    sOutAddrCntEn <= "0";
    
    case (sCurrentState) is
        when StIdle =>
        fsmcfg_state <= "00000";
        sLoadBufStart <= '0'; 
        if (sAqRunStop = '1') then
            if (sTrigMode = "00") then 
                sNextState <= StArm;
            elsif (sTrigMode = "01") then
                sLoadBufStart <= '1'; 
                sNextState <= StLoadBufferNone;
            end if;
        end if;
        
        when StArm =>
        fsmcfg_state <= "00001";
        sInAddrCntEn <= '1';
        sInAddrCntRst <= '1';
        if(sInAddrCounter = lWindowPosition) then
            sNextState <= StWaitTrigger;
        end if;
            
        when StWaitTrigger =>
        fsmcfg_state <= "00010";
        sInAddrCntRst <= '1';
        if ((sTriggerCondition = '1') and (lWindowPosition = sTransferLength - '1'))then
            sInAddrCntEn <= '1';
            sLoadBufStart <= '1'; 
            sNextState <= StSendBufferDummy; --extra cycle needed for sLoadOutCnt to preload first 32b word from fifo; 
                                                --sLoadOutCnt and xsLoadOutCnt_rr should not occur simultaneously
        elsif ((sTriggerCondition = '1') and (lWindowPosition /= sTransferLength - '1')) then
            sInAddrCntEn <= '1';
            sLoadBufStart <= '1'; 
            sNextState <= StLoadBufferNormal;
        else
            sInAddrCntEn <= '1';
            sNextState <= StWaitTrigger;
        end if;
        
        when StLoadBufferNormal =>
        fsmcfg_state <= "00011";
        sInAddrCntEn <= '1';
        sInAddrCntRst <= '1';
        if ((sInAddrCounter = sAddrTrigger + sTransferLength - lWindowPosition) or (lWindowPosition = sTransferLength - '1')) then --correct condition
            sNextState <= StOutAddrCntPush;
        end if;
        
        when StLoadBufferNone =>
        fsmcfg_state <= "00100";
        sInAddrCntEn <= '1';
        sInAddrCntRst <= '1';
        if (sInAddrCounter = sTransferLength) then 
            sNextState <= StOutAddrCntPush;
        end if;

        when StSendBufferDummy =>
        fsmcfg_state <= "00101";
        sNextState <= StOutAddrCntPush;
        
        when StOutAddrCntPush => --Push the read BRAM port start address in the AxiStreamClk domain 
                             -- The start adreess must be available in the AxiStream Clk domain before the LoadOutCnt pulse (see ProcAddrOutCnt process)
        fsmcfg_state <= "00110";
        if (sOutAddrCntStartRdy = '1') then
            sOutAddrCntStartPush <= '1';
            sNextState <= StOutAddrCntAck;
        end if; 
        
        when StOutAddrCntAck =>
        fsmcfg_state <= "00111";
        if (sOutAddrCntStartRdy = '1') then
            sNextState <= StBufferFullPush;
        end if;        
        
        when StBufferFullPush =>
        fsmcfg_state <= "01000";
        if ((sBufFullRdy = '1') and (sLoadOutCntRdy = '1')) then
            sBufferFull <= "1";
            sBufFullPush <= '1';
            sLoadOutCntPush <= '1';
            sLoadOutCnt <= "1";
            sNextState <= StBufferFullAck;
        end if;
        
        when StBufferFullAck =>
        fsmcfg_state <= "01001";
        if (sBufFullRdy = '1') then
            sNextState <= StSendBuffer;
        end if;
        
        when StSendBuffer =>
        fsmcfg_state <= "01010";
        sOutAddrCntEn <= "1";
        if ((sBufEmptyValid = '1') and (sBufEmpty = "1"))then     
            sNextState <= StSetStop;
        end if;
        
        when StSetStop =>  --
        fsmcfg_state <= "01011";
        if (sSetStopRdy = '1') then
            sSetStop <= "1";
            sSetStopPush <= '1';
            sNextState <= StSetStopAck;
        end if;
        
        when StSetStopAck =>
        fsmcfg_state <= "01100";
        if (sSetStopRdy = '1') then
            sNextState <= StWaitStop;
        end if;
            
        when StWaitStop =>
        fsmcfg_state <= "01101";
        if (sAqRunStop = '0') then --if axi interface and ADC in different clock domins condition must be redesigned
            sNextState <= StIdle;
        end if;
        
        when others =>
            sNextState <= StIdle;
        end case;      
end process; 

ProcOutAddrCntStart: process (sTrigMode)
begin
    case (sTrigMode) is
        when "00" =>
            sOutAddrCntStart <= sAddrTrigger - lWindowPosition;
        when "01" =>
            sOutAddrCntStart <= sAddrTrigger;
        when others =>
            sOutAddrCntStart <= (others => '0');
    end case;  
end process;

ProcBufferFull: process (AxiStreamClk) 
begin
   if (AxiStreamClk' event and AxiStreamClk = '1') then
       if (xsRst_n = '0') then
           xsOutAddrCntEnR <= '0';
           xsOutAddrCntEnRR <= '0';
           xsOutAddrCntPulseR <= '0';
       else
           xsOutAddrCntEnR <= xsOutAddrCntEn;  
           xsOutAddrCntEnRR <=xsOutAddrCntEnR;
           xsOutAddrCntPulseR <= xsOutAddrCntPulse;  
       end if;
   end if;
end process;
 
xsOutAddrCntPulse <= xsOutAddrCntEn and (not xsOutAddrCntEnR);
 
 --Input Buffer Address Counter
xsEnbBuffer <= (others => '1');
ProcAddrOutCnt: process (AxiStreamClk) 
 begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if ((xsRst_n = '0') or (xsLoadOutCnt = '1') or (xsBufEmpty = '1')) then
            xsOutAddrCounter <= xsOutAddrCntStart;
            xsOutAddrCounterR <= xsOutAddrCntStart;
        else
            xsOutAddrCounterR <= xsOutAddrCounter;
            if ((xsOutAddrCntEn = '1' and xsOutAddrCntEnRR = '1') or xsOutAddrCntPulse = '1') then
                if (s_axis_s2mm_tready = '1') then
                    xsOutAddrCounter <= xsOutAddrCounter + '1';  
                end if;          
            end if;        
        end if;
    end if;
 end process;
 
ProcBufferFullAddr: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsBufferFullAddr <= (others => '0');
        else
            xsBufferFullAddr <= xsOutAddrCntStart + xsTransferLength;
        end if;
    end if;
end process;
 
ProcAxiStreamTvalid: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if ((xsRst_n = '0') or (xsBufEmpty = '1')) then
            xsS2MM_TvalidLoc <= '0';
            xsTvalidDisable <= '0';
        else
            if(xsOutAddrCntEn = '1' and xsOutAddrCntEnRR = '1') then
                if ((xsTvalidDisable = '0') and (xsOutAddrCounter /= xsBufferFullAddr + 1)) then
                    xsS2MM_TvalidLoc <= '1';
                elsif (xsOutAddrCounter = xsBufferFullAddr+1) then
                    if (s_axis_s2mm_tready = '1') then
                        xsS2MM_TvalidLoc <= '0';
                        xsTvalidDisable <= '1';
                    else
                        xsS2MM_TvalidLoc <= '1';  
                        xsTvalidDisable <= '0';
                    end if;
                else
                    xsS2MM_TvalidLoc <= '0';                 
                end if;
           else
               xsTvalidDisable <= '0';
               xsS2MM_TvalidLoc <= '0';    
           end if;        
        end if;
    end if;
end process;

ProcAxiStreamTkeep: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if ((xsRst_n = '0') or (xsBufEmpty = '1')) then
            xsS2MM_TkeepLoc <= (others => '0');
        else
            if(xsOutAddrCntEn = '1' and xsOutAddrCntEnRR = '1') then
                if ((xsTvalidDisable = '0') and (xsOutAddrCounter /= xsBufferFullAddr + 1)) then
                    xsS2MM_TkeepLoc <= (others => '1');
                elsif (xsOutAddrCounter = xsBufferFullAddr+1) then
                    if (s_axis_s2mm_tready = '1') then
                        xsS2MM_TkeepLoc <= (others => '0');
                    else
                        xsS2MM_TkeepLoc <= (others => '1');
                    end if;
                else
                    xsS2MM_TkeepLoc <= (others => '0');               
                end if;
           else
               xsS2MM_TkeepLoc <= (others => '0');  
           end if;        
        end if;
    end if;
end process;

ProcBufEmpty: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if ((xsRst_n = '0') or (xsLoadOutCnt = '1')) then
            xsBufEmpty <= '0';
        else
            if(xsOutAddrCntEn = '1' and xsOutAddrCntEnRR = '1') then
                if (xsOutAddrCounter = xsBufferFullAddr+1) then
                    if (s_axis_s2mm_tready = '1') then
                        xsBufEmpty <= '1'; 
                    else
                        xsBufEmpty <= '0';  
                    end if;
                end if; 
            end if;            
        end if;
    end if;
end process;

ProcAxiStreamTlast: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if ((xsRst_n = '0') or (xsLoadOutCnt = '1')) then
            xsS2MM_TlastLoc <= '0';
        else
            if(xsOutAddrCntEn = '1' and xsOutAddrCntEnRR = '1') then
                if (xsOutAddrCounter = xsBufferFullAddr) then
                    if (s_axis_s2mm_tready = '1') then
                        xsS2MM_TlastLoc <= '1';
                    else
                        xsS2MM_TlastLoc <= '0';
                    end if;    
                elsif (xsOutAddrCounter = xsBufferFullAddr+1) then
                    if (s_axis_s2mm_tready = '1') then
                        xsS2MM_TlastLoc <= '0';
                    else
                        xsS2MM_TlastLoc <= '1';   
                    end if;
                else
                    xsS2MM_TlastLoc <= '0';
                end if; 
            end if;            
        end if;
    end if;
end process;           

ProcAxiStreamTreadyReg: process (AxiStreamClk) 
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsS2MM_TreadyR <= '0';
        else
            xsS2MM_TreadyR <= s_axis_s2mm_tready;
        end if;
    end if;
end process;

xsTreadyRising <= (not xsS2MM_TreadyR) and s_axis_s2mm_tready;
xsTreadyFalling <= (not s_axis_s2mm_tready) and xsS2MM_TreadyR;
xsS2MM_TdataLoc <= xsBufferOutputData(27 downto 14) & "00" & xsBufferOutputData(13 downto 0) & "00";

ProcTdataAux: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsTdataAux <= (others => '0');
        else
            if (xsTreadyFalling = '1') then
                xsTdataAux <= xsS2MM_TdataLoc;
            end if;
        end if;
    end if;
end process;
 
ProcAxiStreamTdata: process (AxiStreamClk) 
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            s_axis_s2mm_tdata <= (others => '0');
        else
            if (xsTreadyRising = '1' and xsS2MM_TvalidLoc = '1') then
                s_axis_s2mm_tdata <= xsTdataAux;
            elsif (xsOutAddrCntPulseR = '1' or (xsS2MM_TvalidLoc = '1' and s_axis_s2mm_tready = '1'))then 
                s_axis_s2mm_tdata <= xsS2MM_TdataLoc;  
            end if;  
        end if;
    end if;
 end process;
   
s_axis_s2mm_tkeep <= xsS2MM_TkeepLoc;
s_axis_s2mm_tvalid <= xsS2MM_TvalidLoc;  
s_axis_s2mm_tlast <= xsS2MM_TlastLoc;  
----------------------------------------CLOCK DOMAIN CROSSING----------------------------------------------------------
InstLoadOutCntHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiStreamClk,
        iData => sLoadOutCnt,
        oData => open,   -- synchronized output
        iPush => sLoadOutCntPush,
        iRdy => sLoadOutCntRdy,  
        oAck => '1',  
        oValid => xsLoadOutCntValid,   -- indicates valid synchronized data
        aReset => aRst_p
        );

xsLoadOutCnt <= xsLoadOutCntValid;     

InstOutAddrCntStartHandshake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> kBufferSize
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiStreamClk,
        iData => sOutAddrCntStart,
        oData => xsOutAddrCntOdata,   -- synchronized output
        iPush => sOutAddrCntStartPush,
        iRdy => sOutAddrCntStartRdy,  
        oAck => '1',  
        oValid => xsOutAddrCntStartValid,   -- indicates valid synchronized data
        aReset => aRst_p
        );    
            
ProcOutAddrCntOdata: process (AxiStreamClk) 
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsOutAddrCntStart <= (others => '0');
        else
            if (xsOutAddrCntStartValid = '1') then
                xsOutAddrCntStart <= xsOutAddrCntOdata;
            end if; 
        end if;
    end if;
 end process;

InstBufFullHandShake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => AxiStreamClk,
        OutClk => AxiLiteClk,
        iData => sBufferFull,
        oData => open,   -- synchronized output
        iPush => sBufFullPush,
        iRdy => sBufFullRdy,  
        oAck => '1',  
        oValid => lBufFullValid,   -- indicates valid synchronized data
        aReset => aRst_p
        );
lBufferFull <= lBufFullValid;

ProcRegBufEmpty: process (AxiStreamClk) 
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsBufEmptyR <= '0';
        else
            xsBufEmptyR <= xsBufEmpty; 
        end if;
    end if;
 end process;
 
ProcBufEmptyPush: process (AxiStreamClk) 
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsBufEmptyPush <= '0';
        else
            if ((xsBufEmptyR /= xsBufEmpty) and (xsBufEmptyPush = '0') and (xsBufEmptyRdy = '1')) then
                xsBufEmptyPush <= '1';
            else 
                xsBufEmptyPush <= '0'; 
            end if;  
        end if;
    end if;
 end process;
 
 xsBufEmptyIdata(0) <= xsBufEmptyR;

InstBufEmptyHandShake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => AxiStreamClk,
        OutClk => SysClk,
        iData => xsBufEmptyIdata,
        oData => sBufEmpty,   -- synchronized output
        iPush => xsBufEmptyPush,
        iRdy => xsBufEmptyRdy,  
        oAck => '1',  
        oValid => sBufEmptyValid,   -- indicates valid synchronized data
        aReset => aRst_p
        );

InstBufSetStopHandShake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiLiteClk,
        iData => sSetStop,
        oData => open,   -- synchronized output
        iPush => sSetStopPush,
        iRdy => sSetStopRdy,  
        oAck => '1',  
        oValid => lSetStopValid,   -- indicates valid synchronized data
        aReset => aRst_p
        );
lSetStop <= lSetStopValid;
    
ProcAddrCntEnRegisterIn: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sOutAddrCntEnR <= "0";
        else
            sOutAddrCntEnR <= sOutAddrCntEn;
        end if;
    end if;
 end process;
 
ProcAddrCntEnSetPush: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sOutAddrCntEnSetPush <= '0';
            sOutAddrCntEnDin <= "0";
        else
            if (sOutAddrCntEnR /= sOutAddrCntEn) then
                sOutAddrCntEnSetPush <= '1';
                sOutAddrCntEnDin <= sOutAddrCntEn;
            elsif (sOutAddrCntEnRstPush = '1') then
                sOutAddrCntEnSetPush <= '0';
            end if;
        end if;
    end if;
 end process;

ProcAddrCntEnPush: process (SysClk) 
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0') then
            sOutAddrCntEnPush  <=  '0';
            sOutAddrCntEnRstPush <= '0';
        else
                if ((sOutAddrCntEnSetPush = '1') and (sOutAddrCntEnRdy = '1') and (sOutAddrCntEnPush = '0'))then
                    sOutAddrCntEnPush <= '1';
                    sOutAddrCntEnRstPush <= '1';
                else
                    sOutAddrCntEnPush <= '0';
                    sOutAddrCntEnRstPush <= '0';
                end if;     
        end if;
    end if;
end process;

InstOutAddrCntEnHandShake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => SysClk,
        OutClk => AxiStreamClk,
        iData => sOutAddrCntEnDin,
        oData => xsOutAddrCntEnDout,   -- synchronized output
        iPush => sOutAddrCntEnPush,
        iRdy => sOutAddrCntEnRdy,  
        oAck => '1',  
        oValid => xsOutAddrCntEnValid,   -- indicates valid synchronized data
        aReset => aRst_p
        );
    
ProcAddrCntEnRegister: process (AxiStreamClk) 
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsOutAddrCntEn <= '0';
        else
            if (xsOutAddrCntEnValid = '1') then
                xsOutAddrCntEn <= xsOutAddrCntEnDout(0);
            end if;  
        end if;
    end if;
 end process;
                
end Behavioral;
