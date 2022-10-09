-------------------------------------------------------------------------------
--
-- File: SyncAsyncReset.vhd
-- Author: Elod Gyorgy
-- Original Project: HDMI input on 7-series Xilinx FPGA
-- Date: 15 December 2017
--
-------------------------------------------------------------------------------
--MIT License
--
--Copyright (c) 2016 Digilent
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- Purpose:
-- This module is a reset-bridge. It takes a reset signal asynchronous to the 
-- target clock domain (OutClk) and provides a safe asynchronous or synchronous
-- reset for the OutClk domain (oRst). The signal oRst is asserted immediately 
-- as aRst arrives, but is de-asserted synchronously with the OutClk rising
-- edge. This means it can be used to safely reset any FF in the OutClk domain,
-- respecting recovery time specs for FFs.
-- 
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

entity ResetBridge is
   Generic (
      kPolarity : std_logic := '1');
   Port (
      aRst : in STD_LOGIC; -- asynchronous reset; active-high, if kPolarity=1
      OutClk : in STD_LOGIC;
      oRst : out STD_LOGIC);
end ResetBridge;

architecture Behavioral of ResetBridge is
begin

SyncAsyncx: entity work.SyncAsync
   generic map (
      kResetTo => kPolarity,
      kStages => 2,
      kResetPolarity => kPolarity) --use double FF synchronizer
   port map (
      aReset => aRst,
      aIn => not kPolarity,
      OutClk => OutClk,
      oOut => oRst);

end Behavioral;
