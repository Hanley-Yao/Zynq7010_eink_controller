-------------------------------------------------------------------------------
--
-- File: ECC.vhd
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
-- Description: The error correcting code used is a 7+1bits Hamming-modified
-- code (72,64) and the subset of it is 5+1bits or (30,24).
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ECC is
   Port (
      StreamClk : in std_logic;
      sHeaderIn : in std_logic_vector(31 downto 0);
      sCE : in std_logic;
      sReady : out std_logic;
      sHeaderOut : out std_logic_vector(31 downto 0);
      sValid: out std_logic; --asserted for one cycle when ECC processing is done and correct data is present on sHeaderOut
      sError: out std_logic; --asserted for one cycle when ECC processing detected an error
      
      sRst : in std_logic
   );
end ECC;

architecture Behavioral of ECC is
   type bit_parity is array ( 0 to 23 ) of std_logic_vector(7 downto 0);
   constant syndrome : bit_parity := (  "00000111", "00001011", "00001101", "00001110", "00010011", "00010101", "00010110", "00011001",
                                "00011010", "00011100", "00100011", "00100101", "00100110", "00101001", "00101010", "00101100",
                                "00110001", "00110010", "00110100", "00111000", "00011111", "00101111", "00110111", "00111011");
   type state_type is (stReset, stIdle, stGenParity, stCorrect);
   signal sState, sNstate : state_type;
   signal sProcessing : std_logic;
   signal sDataIn : std_logic_vector(23 downto 0); --24-bit data
   signal sECCIn, sParity, sErrSyndrome : std_logic_vector(5 downto 0); --6-bit ECC
begin

sReady <=   '1' when sState = stIdle else
            '0';

InputRegister: process(StreamClk)
begin
   if Rising_Edge(StreamClk) then
      if (sState = stIdle and sCE = '1') then
         sECCIn <= sHeaderIn(29 downto 24);
         sDataIn <= sHeaderIn(23 downto 0);
      end if;
   end if;
end process;

-- The syndrome table is used to determine which bits of data participate in
-- each parity bit. There are 24 syndromes, one for each data bit. Each syndrome
-- encodes which parity bits does the data bit participate in. For example,
-- syndrome(0)=00000111 means that sDataIn(0) and many other data bits are XOR'd
-- together to calculate parity(2), parity(1) and parity(0) (where the syndrome
-- bits are 1).
ParityGen: process(StreamClk)
variable parity : std_logic_vector(sParity'range);
begin
   if Rising_Edge(StreamClk) then
      if (sState = stGenParity) then
         parity := (others => '0');
         for iP in 0 to 5 loop
            for iD in 0 to 23 loop
               if (syndrome(iD)(iP) = '1') then
                  parity(iP) := parity(iP) xor sDataIn(iD);
               end if;
            end loop;
         end loop;
         sParity <= parity;
         sErrSyndrome <= parity xor sECCIn;
      end if;
   end if;
end process;

Correction: process(StreamClk)
begin
   if Rising_Edge(StreamClk) then
      if (sState = stCorrect) then
         sValid <= '0'; sError <= '1'; -- unrecoverable error
         sHeaderOut <= "00" & sErrSyndrome & sDataIn; -- debug output
         
         case (sErrSyndrome) is
            when "000000" => --no error
               sHeaderOut <= "00" & sECCIn & sDataIn;
               sValid <= '1'; sError <= '0';
            when "000001" | "000010" | "000100" | "001000" | "010000" | "100000" =>
            --if error syndrome only has one bit set, it indicates that the ECC is incorrect
               sHeaderOut <= "00" & (sECCIn xor sErrSyndrome) & sDataIn; --flip the bit
               sValid <= '1'; sError <= '1';
            when others =>
            --error in data, try to correct
               for iD in 0 to 23 loop
                  -- if error syndrome matches a value in the syndrome matrix, the
                  -- corresponding data bit is incorrect
                  if (syndrome(iD)(5 downto 0) = sErrSyndrome) then
                     sHeaderOut <= "00" & sECCIn & sDataIn;
                     sHeaderOut(iD) <= not sDataIn(iD);
                     sValid <= '1'; sError <= '1';
                  end if;
               end loop;
         end case;
      else --sState/=stCorrect
         sValid <= '0'; sError <= '0';
      end if;
   end if;
end process;

SYNC_PROC: process (StreamClk)
begin
   if Rising_Edge(StreamClk) then
      if (sRst = '1') then
         sState <= stReset;
      else
         sState <= sNstate;
      end if;
   end if;
end process;

NEXT_STATE_DECODE: process (sState, sCE)
begin
   sNstate <= sState;  --default is to stay in current sState
   case (sState) is
      when stReset =>
         sNstate <= stIdle;
      when stIdle =>
         if (sCE = '1') then
            sNstate <= stGenParity;
         end if;
      when stGenParity => -- calculate all parity bits
         sNstate <= stCorrect;
      when stCorrect => -- compare ECC, calculate error syndrome and correct data, if possible
         sNstate <= stIdle;
      when others =>
         sNstate <= stReset;
   end case;
end process;


end Behavioral;
