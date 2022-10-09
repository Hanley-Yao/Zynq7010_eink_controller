-------------------------------------------------------------------------------
--
-- File: InputBuffer.vhd
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
-- This module instantiates the input buffers of the required I/O standard
-- for the LP(1:0) and HS pins. The D-PHY lane is expected to be connected
-- to the FPGA according to Xilinx App Note 894:
-- http://www.xilinx.com/support/documentation/application_notes/xapp894-d-phy-solutions.pdf 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity InputBuffer is
   Generic (
      kNoLP : boolean := false
   );
   Port (
      HS_p : in std_logic;
      HS_n : in std_logic;
      LP_n : in std_logic;
      LP_p : in std_logic;
      
      aHS : out std_logic;
      aLP : out std_logic_vector(1 downto 0) 
   );
end InputBuffer;

architecture Behavioral of InputBuffer is

begin

LaneHighSpeed: IBUFDS
generic map (
   DIFF_TERM => FALSE, -- Differential Termination 
   IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
   IOSTANDARD => "LVDS_25")
port map (
   O => aHS,  -- Buffer output
   I => HS_p,  -- Diff_p buffer input (connect directly to top-level port)
   IB => HS_n -- Diff_n buffer input (connect directly to top-level port)
);

LaneWithLP: if not kNoLP generate
LaneLowPower0: IBUF
generic map (
   IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
   IOSTANDARD => "HSUL_12")
port map (
   O => aLP(0),     -- Buffer output
   I => LP_n      -- Buffer input (connect directly to top-level port)
);

LaneLowPower1: IBUF
generic map (
   IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
   IOSTANDARD => "HSUL_12")
port map (
   O => aLP(1),     -- Buffer output
   I => LP_p      -- Buffer input (connect directly to top-level port)
);
end generate LaneWithLP;
LaneWithoutLP: if kNoLP generate
    aLP <= "11";
end generate LaneWithoutLP;

end Behavioral;
