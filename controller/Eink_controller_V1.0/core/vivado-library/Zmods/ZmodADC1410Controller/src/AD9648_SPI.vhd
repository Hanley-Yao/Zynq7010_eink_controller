
-------------------------------------------------------------------------------
--
-- File: AD9648_SPI.vhd
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
--This module manages the SPI communication with the Zmod ADC 1410's AD9848.
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.ALL;

entity AD9648_SPI is
    Port (
           SysClk : in STD_LOGIC; --100MHZ input clock
           sRst_n : in STD_LOGIC; --active low reset signal
           --AD9648 SPI interface signals
           sSPI_Clk : out STD_LOGIC;  
           sSDIO : inout STD_LOGIC;
           sCS : out STD_LOGIC;
           --Upper layer Interface signals
           sRdData : out std_logic_vector(15 downto 0); --SPI read data output
           sWrData : in std_logic_vector(15 downto 0);  --SPI register data
           sAddr : in std_logic_vector(12 downto 0);  --SPI register sAddr
           sWidth : in std_logic_vector(1 downto 0);  --Number of data bytes + 1; only width 0 tested
           sRdEn : in STD_LOGIC;  --Trigger an SPI read operation
           sWrEn : in STD_LOGIC;  --Trigger an SPI write operation
           sDone : out STD_LOGIC); --Transfer complete flag
end AD9648_SPI;

architecture Behavioral of AD9648_SPI is

signal sClkCounter : std_logic_vector(3 downto 0);
signal sSPI_ClkRst: std_logic;
signal sRdDataR : std_logic_vector(15 downto 0);
signal sTxVector : std_logic_vector (31 downto 0);
signal sRdWr : std_logic;
signal sRxData, sTxData : std_logic;
signal sTxShift, sRxShift : std_logic;
signal sLdTx : std_logic;
signal sTxCount, sRxCount : std_logic_vector(4 downto 0);
signal sBitCount, sBitCountR : std_logic_vector(4 downto 0);
signal sDir, sDirFsm : std_logic;
signal sCS_Fsm : std_logic;
signal sDoneFsm : std_logic;
type FsmStates_t is (StIdle, StWrite, StRead1, StRead2, StRead3, StDone); 
signal sCurrentState, sNextState : FsmStates_t;
signal fsm_state, fsm_state_r : std_logic_vector(3 downto 0);

begin

InstIOBUF : IOBUF --SDIO three state output buffer
   generic map (
      DRIVE => 12,
      IOSTANDARD => "LVCMOS18",
      SLEW => "SLOW")
   port map (
      O => sRxData,     -- Buffer output
      IO => sSDIO,   -- Buffer inout port (connect directly to top-level port)
      I => sTxData,     -- Buffer input
      T => sDir      -- 3-state enable input, high=input, low=output 
   );
   
ProcClkCounter: process (SysClk) --clock frequency divider
      begin
          if (SysClk' event and SysClk = '1') then
              if ((sRst_n = '0') or (sSPI_ClkRst = '1')) then
                  sClkCounter <= (others => '0');
              else
                  sClkCounter <= sClkCounter + '1';
              end if;
          end if;
      end process; 

sSPI_Clk <= sClkCounter(3); --divide input clock by 16                   

sBitCount <= (sWidth + '1') & "000";

ProcShiftTx: process (SysClk) --Transmit shift register
      begin
          if (SysClk' event and SysClk = '1') then
              if ((sRst_n = '0') or (sLdTx = '1')) then
                  sTxVector <= sRdWr & sWidth & sAddr & sWrData;
                  sTxData <= '0';
              else
                if(sTxShift = '1') then 
                    if (sClkCounter = "0100") then
                      sTxVector(31 downto 0) <= sTxVector(30 downto 0) & '0';
                      sTxData <= sTxVector(31);
                    end if;  
                end if;    
              end if;
          end if;
      end process;

ProcTxCount: process (SysClk) --Count transmitted bits over SDIO signal
      begin
          if (SysClk' event and SysClk = '1') then
              if ((sRst_n = '0') or (sLdTx = '1')) then
                  sTxCount <= (others => '0');
              else
                if(sTxShift = '1') then 
                    if (sClkCounter = "0100") then
                      sTxCount <= sTxCount + '1';
                    end if;  
                end if;    
              end if;
          end if;
      end process;

ProcDir: process (SysClk) --Three state buffer direction control register
      begin
          if (SysClk' event and SysClk = '1') then
              if ((sRst_n = '0') or (sLdTx = '1')) then
                  sDir <= sDirFsm;
              else
                if (sClkCounter = "1111") then
                      sDir <= sDirFsm;
                end if;  
              end if;    
          end if;
      end process;
 
ProcShiftRx: process (SysClk) --Receive deserializer
    begin
        if (SysClk' event and SysClk = '1') then
            if ((sRst_n = '0') or (sRxShift = '0')) then
                sRdDataR <= (others =>'0');
                sRxCount <= (others =>'0');
            else
                if (sRxShift = '1') then
                    if (sClkCounter = "1000") then
                        sRdDataR(15 downto 0) <= sRdDataR(14 downto 0) & sRxData;
                        sRxCount <= sRxCount + '1';
                    end if;    
                end if;  
            end if;
        end if;
    end process;
    
ProcRdData: process (SysClk) --register SPI read data once read instruction is completed
      begin
         if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
               sRdData <= (others => '0');
               sDone <= sDoneFsm;
            else
                sDone <= sDoneFsm;
                if (sDoneFsm = '1') then
                    sRdData <= sRdDataR;
                end if;    
            end if;        
         end if;
      end process;
  
ProcFsmSync: process (SysClk) --State machine synchronous process
      begin
         if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
               sCurrentState <= StIdle;
            else
               sCurrentState <= sNextState;
            end if;        
         end if;
      end process;
      
ProcNextStateAndOutputDecode: process (sCurrentState, sRdEn, sWrEn, sTxCount, sRxCount, sBitCount)
      begin         
         sNextState <= sCurrentState;  
         sDirFsm <= '0';
         sCS_Fsm <= '1';
         sDoneFsm <= '0';
         sRxShift <= '0';
         sTxShift <= '0';
         fsm_state <= (others => '0');
         sRdWr <= '0';
         sLdTx <= '0';
         sSPI_ClkRst <= '1';
         
         case (sCurrentState) is
            when StIdle =>
               fsm_state <= "0000";
               sLdTx <= '1';
               if (sRdEn = '1') then
                  sNextState <= StRead1;
                  sRdWr <= '1';
               elsif (sWrEn = '1') then
                  sNextState <= StWrite;
               end if;
              
            when StRead1 => --send command bytes
                fsm_state <= "0001";
                sCS_Fsm <= '0';
                sTxShift <= '1';
                sRdWr <= '1';
                sSPI_ClkRst <= '0'; 
                if (sTxCount = "10000") then
                    sDirFsm <= '1';
                    sNextState <= StRead2;
                end if;
                
            when StRead2 => --send last command byte; change three state buffer direction
                    fsm_state <= "0010";
                    sDirFsm <= '1';
                    sCS_Fsm <= '0';
                    sTxShift <= '1';
                    sRdWr <= '1';
                    sSPI_ClkRst <= '0'; 
                    if (sTxCount = "10001") then
                        sNextState <= StRead3;
                    end if;
                                    
            when StRead3 => --receive register read data
                fsm_state <= "0011";
                sDirFsm <= '1';
                sCS_Fsm <= '0';
                sRxShift <= '1';
                sRdWr <= '1';
                sSPI_ClkRst <= '0';
                if (sRxCount = sBitCount) then
                    sNextState <= StDone;
                end if;
                
            when StWrite => --send SPI command and register data
                fsm_state <= "0100";
                sCS_Fsm <= '0';
                sTxShift <= '1';
                sSPI_ClkRst <= '0';
                if (sTxCount = (sBitCount + "10001")) then
                    sNextState <= StDone;
                end if;
                
             when StDone => --signal SPI instruction complete
                fsm_state <= "0101";
                sCS_Fsm <= '0';
                sDoneFsm <= '1';
                sNextState <= StIdle;
                     
            when others =>
                fsm_state <= (others => '1');
                sNextState <= StIdle;
         end case;      
      end process;    

ProcRegCS: process (SysClk)
      begin
         if (SysClk'event and SysClk = '1') then
            if (sRst_n = '0') then
               sCS <= '0';
               fsm_state_r <= (others => '0');
            else
               sCS <= sCS_Fsm;
               fsm_state_r <= fsm_state;
            end if;        
         end if;
      end process;
 
ProcRegBitCount: process (SysClk)
     begin
        if (SysClk'event and SysClk = '1') then
           if (sRst_n = '0') then
              sBitCountR <= (others => '0');
           else
              sBitCountR <= sBitCount;
           end if;        
        end if;
     end process;
           
end Behavioral;      