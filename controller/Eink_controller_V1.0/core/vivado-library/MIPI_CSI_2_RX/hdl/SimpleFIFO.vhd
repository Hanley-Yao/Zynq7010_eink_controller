-------------------------------------------------------------------------------
--
-- File: SimpleFIFO.vhd
-- Author: Elod Gyorgy
-- Original Project: MIPI CSI-2 Receiver IP
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

entity SimpleFIFO is
   Generic (
      kDataWidth : natural
   );
   Port (
      InClk : in std_logic;
      iRst : in std_logic;
      iDataIn : in std_logic_vector(kDataWidth-1 downto 0);
      iWrEn : in std_logic;
      iRdEn : in std_logic;
      iFull : out std_logic;
      iEmpty : out std_logic;
      iDataOut : out std_logic_vector(kDataWidth-1 downto 0)
   );
end SimpleFIFO;

architecture Behavioral of SimpleFIFO is

   constant kFIFO_Depth : natural := 2**5; --implementation assumes power of 2
   subtype FIFO_data_t is std_logic_vector(kDataWidth-1 downto 0);
   type FIFO_t is array (0 to kFIFO_Depth-1) of FIFO_data_t;
   signal FIFO : FIFO_t;
   signal iRdA, iWrA : natural range 0 to kFIFO_Depth-1; --read and write addresses
   signal iFullInt, iEmptyInt : std_logic := '1';
begin

-- The process below should result in a dual-port distributed RAM
FIFOProc: process (InClk)
begin
   if Rising_Edge(InClk) then
      if (iWrEn = '1') then
         FIFO(iWrA) <= iDataIn;
      end if;
   end if;
end process FIFOProc;
iDataOut <= FIFO(iRdA);

-- FIFO address counters
FIFO_WrA: process (InClk)
begin
   if Rising_Edge(InClk) then
      if (iRst = '1') then
         iWrA <= 0;
      elsif (iFullInt = '0' or iWrEn = '1') then
         if (iWrA = kFIFO_Depth - 1) then
            iWrA <= 0;
         else
            iWrA <= iWrA + 1;
         end if;
      end if;
   end if;
end process FIFO_WrA;

FIFO_RdA: process (InClk)
begin
   if Rising_Edge(InClk) then
      if (iRst = '1') then
         iRdA <= 0;
      elsif (iRdEn = '1' and iEmptyInt = '0') then
         if (iRdA = kFIFO_Depth - 1) then
            iRdA <= 0;
         else
            iRdA <= iRdA + 1;
         end if;
      end if;   
   end if;
end process FIFO_RdA;

FullFlag: process (InClk)
begin
   if Rising_Edge(InClk) then
      if (iRst = '1') then
         iFullInt <= '1';
      elsif (iEmptyInt = '1') then
         iFullInt <= '0';
      elsif (iFullInt = '1' and iRdEn = '1') then
         iFullInt <= '0';
      elsif (((iWrA + 1) mod kFIFO_Depth = iRdA) and iWrEn = '1' and iRdEn = '0') then
         iFullInt <= '1'; 
      end if;   
   end if;
end process;

EmptyFlag: process (InClk)
begin
   if Rising_Edge(InClk) then
      if (iRst = '1') then
         iEmptyInt <= '1';
      elsif (iWrEn = '1') then
         iEmptyInt <= '0';         
      elsif (((iRdA + 1) mod kFIFO_Depth = iWrA) and iRdEn = '1' and iWrEn = '0') then
         iEmptyInt <= '1';
      end if;   
   end if;
end process;

iFull <= iFullInt;
iEmpty <= iEmptyInt;

end Behavioral;
