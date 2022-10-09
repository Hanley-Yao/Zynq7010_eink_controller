
-------------------------------------------------------------------------------
--
-- File: Circular_Buffer.vhd
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
--This module implements the circular buffer and the AXI Stream to BRAM bridge.
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
           sCh1Out : out STD_LOGIC_VECTOR (13 downto 0); --Channel1 data output
           sCh2Out : out STD_LOGIC_VECTOR (13 downto 0); --Channel2 data output
           
           --AXI Stream (MM2S)
           s_axis_mm2s_tdata : in STD_LOGIC_VECTOR(31 DOWNTO 0);
           s_axis_mm2s_tkeep : in STD_LOGIC_VECTOR(3 DOWNTO 0);
           s_axis_mm2s_tvalid : in STD_LOGIC;
           s_axis_mm2s_tready : out STD_LOGIC;
           s_axis_mm2s_tlast : in STD_LOGIC;
           
           sDacEn: in STD_LOGIC; -- Control signal that enables the circular buffer's output address
                                 -- counter and closes the Zmod DAC 1411 output relay contacts
           sTransferLength : in STD_LOGIC_VECTOR (kBufferSize-1 downto 0); -- Buffer's length synchronised in the SysClk domain
           xsTransferLength : in std_logic_vector (kBufferSize-1 downto 0); -- Buffer's length synchronised in the AxiStreamClk domain 
           sOutAddrCntRst : in std_logic; -- Control bit that resets the circular buffer's output address counter
           sDivRate : in std_logic_vector(13 downto 0); -- Factor by which the default 100MHz increment rate of the circular's buffer 
                                                        -- output address counter is divided
           lBufferFull : out STD_LOGIC --Flag indicating that the number of samples specified in the MM2S_Lenght registers
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
signal xsBufferInputData : std_logic_vector (27 downto 0);
signal xsEnaBuffer : std_logic_vector (27 downto 0);
signal xsBitValid : std_logic_vector (31 downto 0);
signal xsWeaBuffer : std_logic_vector (27 downto 0);
signal xsWeaArray : WeDataArray_t;
signal xsBufferInputArray : BufferDataArray_t;
signal xsInAddrCounter, xsInAddrCounterR : std_logic_vector (kBufferSize-1 downto 0); --conter used to generate the BRAM write port address
--Buffer read channel and BRAM to Axi Stream related signals
signal sBufferOutputData : std_logic_vector (27 downto 0);
signal sEnbBuffer : std_logic_vector (27 downto 0);
signal sBufferOutArray : BufferDataArray_t;
signal sOutAddrCntAux : std_logic_vector (13 downto 0);
signal sOutAddrCntEn : std_logic;
signal sOutAddrCounter, sOutAddrCounterR : std_logic_vector (kBufferSize-1 downto 0);
signal xsBufferFull : std_logic; --flag indicating that the buffer was loaded successfuly
signal sLoadOutCnt : std_logic_vector (0 downto 0); --signal that resets the BRAM read address port counter once the buffer is filled (in system clock domain)
signal xsLoadOutCnt : std_logic; --signal that resets the BRAM read address port counter once the buffer is filled (in system Axi Stream clock domain)
signal xsTvalidDisable : std_logic; --signal used to deassert s_axis_s2mm_tvalid once all requested bytes have been transfered
--Buffer control state machine related signals
signal sCurrentState, sNextState : FsmStates_t;
signal fsmcfg_state, fsmcfg_state_r : std_logic_vector(4 downto 0);
--Axi Stream interface related signals

--Control register and status register write strobe signals
signal sBufferFull : std_logic_vector(0 downto 0); --pulse indicating the buffer has aquired the requested amount of data
--Clock domain crossing related signals
signal sBufFullRdy, sBufFullPush, lBufFullValid : std_logic;
                   
begin

aRst_p <= not sRst_n;
s_axis_mm2s_tready <= '1';
xsBufferInputData <= s_axis_mm2s_tdata(31 downto 18) & s_axis_mm2s_tdata(15 downto 2);

ProcBufferPortAssign : process (xsWeaBuffer)
begin
	for Index in 0 to 27 loop
        xsWeaArray(Index)(0) <= s_axis_mm2s_tvalid; --assume tkeep = "1111" for all valid data;
        xsBufferInputArray(Index)(0) <= xsBufferInputData(Index);
        sBufferOutputData(Index) <= sBufferOutArray(Index)(0);
    end loop;
end process;
xsEnaBuffer <= (others => '1');
sEnbBuffer <= (others => '1');  

GenerateBuffer : for Index in 0 to 27 generate     
  
    InstBRAM_Buffer : blk_mem_gen_0
      PORT MAP (
        clka => AxiStreamClk,
        ena => xsEnaBuffer(Index),
        wea => xsWeaArray(Index),
        addra => xsInAddrCounter,
        dina => xsBufferInputArray(Index),
        clkb => SysClk,
        enb => sEnbBuffer(Index),
        addrb => sOutAddrCounter,
        doutb => sBufferOutArray(Index)
      );        
 end generate GenerateBuffer;
 
 sCh1Out <= sBufferOutputData(27 downto 14);
 sCh2Out <= sBufferOutputData(13 downto 0);
 
 --Input Buffer Address Counter
ProcInAddrCounter: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if ((xsRst_n = '0') or (s_axis_mm2s_tlast = '1'))then
            xsInAddrCounter <= (others => '0');
            xsInAddrCounterR <= (others => '0');
        else
            xsInAddrCounterR <= xsInAddrCounter;
            if(s_axis_mm2s_tvalid = '1') then
                xsInAddrCounter <= xsInAddrCounter + '1';
            end if;        
        end if;
    end if;
end process;

ProcBufferFull: process (AxiStreamClk)  
begin
    if (AxiStreamClk' event and AxiStreamClk = '1') then
        if (xsRst_n = '0') then
            xsBufferFull <= '0';
        else
            if ((s_axis_mm2s_tlast = '1') and (xsInAddrCounter = xsTransferLength - '1')) then
                xsBufferFull <= '1';    
            else
                xsBufferFull <= '0';
            end if;    
        end if;
    end if;
end process;

ProcOutAddrCntEn: process (SysClk)  
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0' or sOutAddrCntRst = '1') then
            sOutAddrCntAux <= (others => '0');
            sOutAddrCntEn <= '0';
        else
            if(sDacEn = '1') then
                if(sOutAddrCntAux = sDivRate) then
                    sOutAddrCntAux <= (others => '0');
                    sOutAddrCntEn <= '1';
                else
                    sOutAddrCntAux <= sOutAddrCntAux + '1';
                    sOutAddrCntEn <= '0';
                end if;
            end if;        
        end if;
    end if;
end process;

ProcOutAddrCounter: process (SysClk)  
begin
    if (SysClk' event and SysClk = '1') then
        if (sRst_n = '0' or sOutAddrCntRst = '1') then
            sOutAddrCounter <= (others => '0');
            sOutAddrCounterR <= (others => '0');
        else
            sOutAddrCounterR <= sOutAddrCounter;
            if((sDacEn = '1') and (sOutAddrCntEn = '1'))then
                if(sOutAddrCounter = (sTransferLength - '1')) then
                    sOutAddrCounter <= (others => '0');
                else
                    sOutAddrCounter <= sOutAddrCounter + '1';
                end if;
            end if;        
        end if;
    end if;
end process;

----------------------------------------CLOCK DOMAIN CROSSING----------------------------------------------------------

InstBufFullHandShake : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
generic map (
    kDataWidth	=> 1
    )
    Port map (
        InClk => AxiStreamClk,
        OutClk => AxiLiteClk,
        iData => "1",
        oData => open,   -- synchronized output
        iPush => xsBufferFull,
        iRdy => open,  
        oAck => '1',  
        oValid => lBufFullValid,   -- indicates valid synchronized data
        aReset => aRst_p
        );
lBufferFull <= lBufFullValid;
                
end Behavioral;
