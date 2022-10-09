------------------------------------------------------------------------------
--
-- File: HandshakeData.vhd
-- Author: Elod Gyorgy
-- Original Project: Atlys2 User Demo 
-- Date: 29 June 20116
--
-------------------------------------------------------------------------------
-- (c) 2016 Copyright Digilent Incorporated
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
-- Purpose:
--    This module passes parallel data from the input clock domain (InClk) to the
--    output clock domain (OutClk) by the means of handshake signals. A
--    low-to-high transition on iPush will register iData inside the module
--    and will start propagating the handshake signals towards the output domain.
--    The data will appear on oData and is valid when oValid pulses high.
--    The reception of data by the receiver on the OutClk domain is signaled
--    by a pulse on oAck. This will propagate back to the input domain and
--    assert iRdy signaling to the sender that a new data can be pushed though.
--    If oData is always read when oValid pulses, oAck may be tied permanently
--    high.
--    Only assert iPush when iRdy is high!
--
-- Changelog:
--    2016-Jun-29: Fixed oValid not being a pulse.
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HandshakeData is
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
end HandshakeData;

architecture Behavioral of HandshakeData is
   signal iPush_q, iPushRising, iPushT, iPushTBack, iReset : std_logic;
   signal iData_int : std_logic_vector(kDataWidth-1 downto 0);
   signal oPushT, oPushT_q, oPushTBack, oPushTChanged : std_logic;
   attribute DONT_TOUCH : string;
   attribute DONT_TOUCH of aReset: signal is "TRUE";
begin

DetectPush: process(aReset, InClk)
begin
   if (aReset = '1') then
      iPush_q <= '0';
   elsif Rising_Edge(InClk) then
      iPush_q <= iPush;
   end if;
end process DetectPush;

iPushRising <= iPush and not iPush_q; 

-- Register data when iPush is rising and toggle internal flag
LatchData: process(aReset, InClk)
begin
   if (aReset = '1') then
      iData_int <= (others => '0');
      iPushT <= '0';
   elsif Rising_Edge(InClk) then
      if (iPushRising = '1') then
         iData_int <= iData;
         iPushT <= not iPushT;
      end if;
   end if;
end process;

-- Cross toggle flag through synchronizer 
SyncAsyncPushT: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aReset => aReset,
      aIn => iPushT,
      OutClk => OutClk,
      oOut => oPushT);

-- Detect a push edge in the OutClk domain
-- If receiver acknowledges receipt, we can propagate the push signal back
-- towards the input, where it will be used to generate iRdy      
DetectToggle: process(aReset, OutClk)
begin
   if (aReset = '1') then
      oPushT_q <= '0';
	   oPushTBack <= '0';
   elsif Rising_Edge(OutClk) then
      oPushT_q <= oPushT;
      if (oAck = '1') then
         oPushTBack <= oPushT_q;
      end if;
   end if;
end process DetectToggle;

oPushTChanged <= '1' when oPushT_q /= oPushT else '0';

-- Cross data from InClk domain reg (iData_in) to OutClk domain
-- The enable for this register is the propagated and sync'd to the OutClk domain
-- We assume here that the time it took iPush to propagate to oPushTChanged is
-- more than the time it takes iData_int to propagate to the oData register's D pin
OutputData: process (aReset, OutClk)
begin
   if (aReset = '1') then
      oData <= (others => '0');
      oValid <= '0';
   elsif Rising_Edge(OutClk) then
      if (oPushTChanged = '1') then
         oData <= iData_int;
      end if;
      oValid <= oPushTChanged;
   end if;
end process OutputData;

-- Cross toggle flag back through synchronizer 
SyncAsyncPushTBack: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aReset => aReset,
      aIn => oPushTBack,
      OutClk => InClk,
      oOut => iPushTBack);

-- Synchronize aReset into the InClk domain
-- We need it to keep iRdy low, when aReset de-asserts
SyncReset: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => aReset,
      OutClk => InClk,
      oRst => iReset);
      
ReadySignal: process(aReset, InClk)
begin
   if (aReset = '1') then
      iRdy <= '0';
   elsif Rising_Edge(InClk) then
      iRdy <= not iPush and (iPushTBack xnor iPushT) and not iReset; 
   end if; 
end process ReadySignal;

end Behavioral;
