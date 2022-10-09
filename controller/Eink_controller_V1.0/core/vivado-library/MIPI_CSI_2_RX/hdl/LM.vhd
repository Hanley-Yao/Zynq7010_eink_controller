-------------------------------------------------------------------------------
--
-- File: LM.vhd
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

library work;
use work.SimpleFIFO;
use work.DebugLib;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LM is
   Generic(
      kMaxLaneCount : natural := 4;
      --PPI
      kLaneCount : natural range 1 to 4 := 2 --[1,2,4]
   );
   Port (
      RxByteClkHS : in STD_LOGIC;
      RxDataHS : in  STD_LOGIC_VECTOR (8 * kLaneCount - 1 downto 0);
      RxSyncHS : in  STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
      RxValidHS : in  STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
      RxActiveHS : in  STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
       
      --Master AXI-Stream
      rbMAxisTdata : out std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
      rbMAxisTkeep : out std_logic_vector(kMaxLaneCount - 1 downto 0);
      rbMAxisTvalid : out std_logic;
      rbMAxisTready : in std_logic;
      rbMAxisTlast : out std_logic;
      
      rbErrSkew : out std_logic;
      rbErrOvf : out std_logic;
      
      rbEn : in std_logic;
      rbRst : in std_logic;
      
      dbgLMLane : out DebugLib.DebugLMLanes_t;
      dbgLM : out DebugLib.DebugLM_t
   );
end LM;

architecture Behavioral of LM is
   type state_t is (stReset, stIdle, stWaitForReady, stWaitForValid, stReceive, stEndReceive, stError);
   signal rbState, rbNstate : state_t;
   
   signal rbByteCnt : natural range 0 to kMaxLaneCount - 1 := 0;
   signal rbTvalidInt, rbMAxisTvalidInt,  rbTlastInt, rbPartial : std_logic;
   signal rbTdataInt : std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
   signal rbTkeepInt : std_logic_vector(kMaxLaneCount - 1 downto 0);
   constant kAllOnes : std_logic_vector(kMaxLaneCount - 1 downto 0) := (others => '1');
   
   alias rbDataHSInt is RxDataHS;
   alias rbSyncHSInt is RxSyncHS;
   alias rbValidHSInt is RxValidHS;
   alias rbActiveHSInt is RxActiveHS;
   
   signal rbRdEn, rbWrEn, rbFull : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal rbEnInt : std_logic;
   
   -- De-skewed PPI data lanes
   signal rbDataHS : STD_LOGIC_VECTOR (8 * kLaneCount - 1 downto 0);
   signal rbSyncHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal rbValidHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal rbActiveHS, rbActiveHS_q : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   
   -- VHDL-2008 back-port
   function orv(vec : std_logic_vector) return std_logic is
      variable result : std_logic := '0';
   begin
      for i in vec'range loop
         result := result or vec(i);
      end loop;
      return result;
   end orv;
   -- VHDL-2008 back-port
   function andv(vec : std_logic_vector) return std_logic is
      variable result : std_logic := '1';
   begin
      for i in vec'range loop
         result := result and vec(i);
      end loop;
      return result;
   end andv;
   
begin

dbgLM.state <= std_logic_vector(to_unsigned(state_t'pos(rbState), 3));
dbgLM.rbByteCnt <= std_logic_vector(to_unsigned(rbByteCnt, 2));


-- Shallow, synchronous FIFOs for each data lane are used to delay data
-- on those that transmit earlier than the rest. Thus, data lanes
-- are de-skewed and their RxActiveHS edges aligned. This approach relies
-- on the timing of RxValidHS relative to the corresponding RxActiveHS to be
-- the same for all lanes.  
DeskewFIFOs: for i in 0 to kLaneCount - 1 generate

   dbgLMLane(i).rbSkwRdEn <= rbRdEn(i);
   dbgLMLane(i).rbSkwWrEn <= rbEn;
   dbgLMLane(i).rbSkwFull <= rbFull(i);
   dbgLMLane(i).rbActiveHS <= rbActiveHS(i);
   dbgLMLane(i).rbSyncHS <= rbSyncHS(i);
   dbgLMLane(i).rbValidHS <= rbValidHS(i);
   dbgLMLane(i).rbDataHS <= rbDataHS((i+1)*8-1 downto i*8);

DeskewFIFOx: entity work.SimpleFIFO
   Generic map (kDataWidth => 11)
   Port map (
      InClk => RxByteClkHS,
      iRst => rbRst,
      iDataIn => rbActiveHSInt(i) & rbSyncHSInt(i) & rbValidHSInt(i) & rbDataHSInt((i+1)*8-1 downto i*8),
      iWrEn => rbWrEn(i),
      iRdEn => rbRdEn(i),
      iFull => rbFull(i),
      iEmpty => open,
      iDataOut(10) => rbActiveHS(i),
      iDataOut(9) => rbSyncHS(i),
      iDataOut(8) => rbValidHS(i),
      iDataOut(7 downto 0) => rbDataHS((i+1)*8-1 downto i*8)
   );

rbWrEn(i) <= rbEnInt;
rbRdEn(i) <=   '0' when (rbState = stReset) else 
               '0' when (rbActiveHS(i) = '1' and andv(rbActiveHS) = '0' and andv(rbActiveHS_q) = '0') else -- lane is active while others not, pause it
               '0' when (andv(rbActiveHS) = '1' and rbState = stWaitForReady) else -- all lanes active, but we are held up by rbMAxisTready
               '1';
            
process (RxByteClkHS)
begin
   if Rising_Edge(RxByteClkHS) then
      if (rbRdEn(i) = '1') then
         rbActiveHS_q(i) <= rbActiveHS(i);
      end if;
   end if;
end process;
   
end generate DeskewFIFOs;

InternalEnable: process (RxByteClkHS)
begin
   if Rising_Edge(RxByteClkHS) then
      if (rbState = stReset) then
         rbEnInt <= '0';
      else
         rbEnInt <= rbEn;
      end if;
   end if;
end process;

-- The deskew error flag is set when one of the lanes was halted for so long awaiting valid data on the
-- other lanes that the FIFOs filled up. Possible causes:
-- not all lanes in the specified kLaneCount are receiving data, or
-- lane skew larger than 8 RxByteClkHS periods.
DeskewFullFlag: process (RxByteClkHS)
begin
   if Rising_Edge(RxByteClkHS) then
      if (rbRst = '1') then
         rbErrSkew <= '0';
      elsif (rbEnInt = '1' and orv(rbFull) = '1') then
         rbErrSkew <= '1';
      end if;
   end if;
end process;

-- The overflow error flag set whenever we provide valid data on the AXI-Stream
-- and the slave is not ready to receive. Buffering should be done downstream.
OverflowFlag: process (RxByteClkHS)
begin
   if Rising_Edge(RxByteClkHS) then
      if (rbRst = '1') then
         rbErrOvf <= '0';
      elsif (rbMAxisTvalidInt = '1' and rbMAxisTready = '0') then 
         rbErrOvf <= '1';
      end if;
   end if;
end process;
      
SYNC_PROC: process (RxByteClkHS)
begin 
   if Rising_Edge(RxByteClkHS) then
      if (rbRst = '1') then
         rbState <= stReset;
      else
         rbState <= rbNstate;
      end if;
   end if;
end process;

ByteRegisters: process (RxByteClkHS)
begin
   if Rising_Edge(RxByteClkHS) then
      if (rbRst = '1') then
         rbTdataInt <= (others => '0');
         rbTkeepInt <= (others => '0');
      else
         if (rbState = stReceive or rbState = stWaitForValid) then
            --Walk the valid signals, register valid bytes and set keep bits
            --Order is important: last bytes are filled from low-order lanes to high-order ones
            if (rbTvalidInt = '1') then
               rbTkeepInt <= (others => '0');
            end if;
            for i in 0 to kLaneCount - 1 loop
               if (rbValidHS(i) = '0') then
                  exit;
               end if;
               rbTdataInt((i+rbByteCnt+1)*8-1 downto (i+rbByteCnt)*8) <= rbDataHS((i+1)*8-1 downto i*8);
               rbTkeepInt(i+rbByteCnt) <= '1';
            end loop;
         end if;
      end if;
   end if;
end process;

BufferCounter: process (RxByteClkHS)
begin
   if Rising_Edge(RxByteClkHS) then
      if (rbState = stIdle) then
         rbByteCnt <= 0;
      else
         if (rbState = stWaitForValid and orv(rbValidHS) = '1') or (rbState = stReceive) then
            if (rbByteCnt = kMaxLaneCount - kLaneCount) then
               rbByteCnt <= 0;
            else
               rbByteCnt <= rbByteCnt + kLaneCount;
            end if;
         end if;
      end if;
   end if;
end process;

rbTValidInt <= '1' when ((rbState = stReceive and (rbByteCnt = 0 or orv(rbValidHS) = '0')) -- buffer full, or no more bytes
                        or (rbState = stEndReceive)) -- flush partial packet
               else '0';
rbTlastInt <= '1' when (rbState = stReceive and orv(rbValidHS) = '0') -- no more bytes
                        or (rbState = stEndReceive) -- partial packet is last
               else '0';

OutputRegister: process (RxByteClkHS)
begin
   if Rising_Edge(RxByteClkHS) then
      if (rbRst = '1') then
         rbMAxisTdata <= rbTdataInt;
         rbMAxisTkeep <= rbTkeepInt;
         rbMAxisTvalidInt <= rbTvalidInt;
         rbMAxisTlast <= rbTlastInt;
      else
         rbMAxisTvalidInt <= rbTvalidInt;
         if (rbTvalidInt = '1') then
            rbMAxisTdata <= rbTdataInt;
            rbMAxisTkeep <= rbTkeepInt;
            rbMAxisTlast <= rbTlastInt;
         end if;
      end if;
   end if;
end process;

rbMAxisTvalid <= rbMAxisTvalidInt;

NEXT_STATE_DECODE: process (rbState, rbActiveHS, rbValidHS, rbFull, rbMAxisTready)
begin
   rbNstate <= rbState;  --default is to stay in current rbState
   case (rbState) is
      when stReset => 
         if (orv(rbFull) = '0') then
            rbNstate <= stWaitForReady;
         end if;
      when stWaitForReady =>
         if (orv(rbFull) = '1') then
            rbNstate <= stError;
         elsif (rbMAxisTready = '1') then
            rbNstate <= stIdle;
         end if;         
      when stIdle =>
         if (orv(rbFull) = '1') then --deskew overflow
            rbNstate <= stError;
         elsif (andv(rbActiveHS) = '1') then --when all channels present active
            rbNstate <= stWaitForValid;
         end if;
      when stWaitForValid => -- in High-Speed reception but no data yet
         if (andv(rbValidHS) = '1') then -- first full data
            rbNstate <= stReceive;
         elsif (orv(rbValidHS) = '1') then -- partial data; first is also the last
            rbNstate <= stEndReceive;
         end if;
      when stReceive => -- we are receiving High-Speed data
         if (orv(rbValidHS) = '0') then
            rbNstate <= stIdle;  --no more data
         elsif (andv(rbValidHS) = '0') then -- partial data; last packet
            rbNstate <= stEndReceive;
         end if;
      when stEndReceive =>
         rbNstate <= stIdle; -- last packet seen
      when stError =>
         if (orv(rbActiveHS) = '0') then
            rbNstate <= stIdle;
         end if;
      when others =>
         rbNstate <= stIdle;
   end case;
end process;

end Behavioral;
