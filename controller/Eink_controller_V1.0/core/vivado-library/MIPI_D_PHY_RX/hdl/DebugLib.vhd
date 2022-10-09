-------------------------------------------------------------------------------
--
-- File: DebugLib.vhd
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package DebugLib is

   COMPONENT ila_scnn_refclk
   
   PORT (
      clk : IN STD_LOGIC;
   
      trig_out : OUT STD_LOGIC;
      trig_out_ack : IN STD_LOGIC;
   
      probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
      probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe4 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
      probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      probe9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
   );
   END COMPONENT  ;
   COMPONENT ila_sfen_refclk
      
      PORT (
         clk : IN STD_LOGIC;
         trig_out : OUT STD_LOGIC;
         trig_out_ack : IN STD_LOGIC;      
         trig_in : IN STD_LOGIC;
         trig_in_ack : OUT STD_LOGIC;
         probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
         probe1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
         probe2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
         probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
         probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
         probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
         probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
         probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
      );
   END COMPONENT  ;
   COMPONENT ila_sfen_rxclk
   
   PORT (
      clk : IN STD_LOGIC;
      
      trig_in : IN STD_LOGIC;
      trig_in_ack : OUT STD_LOGIC;
      probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      probe8 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
   );
   END COMPONENT  ;   
   type DebugSCNN_Type is record
      cIntRst : std_logic;
      cLP : std_logic_vector(1 downto 0);
      cHSRst : std_logic;
      cHSClkLocked : std_logic;
      state : std_logic_vector(3 downto 0);
      cClkSettleTout : std_logic;
      cBUFR_Rst : std_logic;
      cMMCM_Rst : std_logic;
      cMMCM_RstTout : std_logic;  
      cMMCM_Locked : std_logic;
   end record;
   
   type DebugSFEN_Type is record
      cIntRst : std_logic;
      cLP : std_logic_vector(1 downto 0);
      state : std_logic_vector(2 downto 0);
      cHSClkRst : std_logic;
      cForceRxmode : std_logic;
      cInitTout : std_logic;
      cHSSettleTout : std_logic;
      cHSSettled : std_logic;
      cHSReset : std_logic;
      dSyncHard : std_logic;
      dSyncSoft : std_logic;
      dSyncErr : std_logic;
   end record;

end package;
