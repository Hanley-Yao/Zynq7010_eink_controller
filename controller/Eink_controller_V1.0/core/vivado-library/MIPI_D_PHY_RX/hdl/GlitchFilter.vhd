-------------------------------------------------------------------------------
--
-- File: GlitchFilter.vhd
-- Author: Elod Gyorgy
-- Original Project: MIPI D-PHY Receiver IP
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
--    This module filters any pulses on sIn lasting less than the number of
--    periods specified in kNoOfPeriodsToFilter. The output sOut will be
--    delayed by kNoOfPeriodsToFilter cycles, but glitch-free.
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

entity GlitchFilter is
   Generic (
      kNoOfPeriodsToFilter : natural);
   Port (
      SampleClk : in STD_LOGIC;
      sIn : in STD_LOGIC;
      sOut : out STD_LOGIC;
      sRst : in STD_LOGIC);
end GlitchFilter;

architecture Behavioral of GlitchFilter is
signal cntPeriods : natural range 0 to kNoOfPeriodsToFilter - 1 := kNoOfPeriodsToFilter - 1;
signal sIn_q : std_logic;
begin

Bypass: if kNoOfPeriodsToFilter = 0 generate
   sOut <= sIn; 
end generate Bypass;

Filter: if kNoOfPeriodsToFilter > 0 generate
   process (SampleClk)
   begin
      if Rising_Edge(SampleClk) then
         sIn_q <= sIn;
         if (cntPeriods = 0) then
            sOut <= sIn_q;
         end if;
      end if;
   end process;
   
   PeriodCounter: process (SampleClk)
   begin
      if Rising_Edge(SampleClk) then
         if (sIn_q /= sIn or sRst = '1') then --edge detected
            cntPeriods <= kNoOfPeriodsToFilter - 1; --reset counter
         elsif (cntPeriods /= 0) then
            cntPeriods <= cntPeriods - 1; --count down
         end if;
      end if;
   end process PeriodCounter;
end generate Filter;

end Behavioral;
