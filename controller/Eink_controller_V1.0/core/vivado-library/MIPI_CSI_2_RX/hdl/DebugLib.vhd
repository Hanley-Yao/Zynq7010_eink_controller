-------------------------------------------------------------------------------
--
-- File: DebugLib.vhd
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

package DebugLib is
   COMPONENT ila_rxclk
   
   PORT (
      clk : IN STD_LOGIC;
   
      trig_out : OUT STD_LOGIC;
      trig_out_ack : IN STD_LOGIC;
   
      probe0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
      probe1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
      probe2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
      probe3 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
      probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      probe11 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe12 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      probe13 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
   );
   END COMPONENT  ;
   COMPONENT ila_vidclk
   
   PORT (
      clk : IN STD_LOGIC;
   
   
      trig_in : IN STD_LOGIC;
      trig_in_ack : OUT STD_LOGIC;
      probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
      probe5 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
      probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe11 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
      probe12 : IN STD_LOGIC_VECTOR(5 DOWNTO 0); 
      probe13 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe14 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe15 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
      probe16 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe17 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe18 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe19 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe20 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
      probe21 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
      probe22 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
      probe23 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe24 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe25 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
      probe26 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe27 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe28 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe29 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe30 : IN STD_LOGIC_VECTOR(39 DOWNTO 0); 
      probe31 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
      probe32 : IN STD_LOGIC_VECTOR(10 DOWNTO 0); 
      probe33 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe34 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      probe35 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
   );
   END COMPONENT  ;
   COMPONENT ila_rxclk_lane
   
   PORT (
      clk : IN STD_LOGIC;
   
      trig_out : OUT STD_LOGIC;
      trig_out_ack : IN STD_LOGIC;
   
      probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      probe6 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
   );
   END COMPONENT  ;
   type DebugLMLane_t is record
      rbSkwRdEn : std_logic;
      rbSkwWrEn : std_logic;
      rbSkwFull : std_logic;
      rbActiveHS : std_logic;
      rbSyncHS : std_logic;
      rbValidHS : std_logic;
      rbDataHS : std_logic_vector(7 downto 0);
   end record;
   constant C_M_AXIS_TDATA_WIDTH : natural := 40;
   constant kMaxLaneCount : natural := 4;
   type DebugLMLanes_t is array(0 to kMaxLaneCount - 1) of DebugLMLane_t;
   type DebugLM_t is record      
      state : std_logic_vector(2 downto 0);
      rbByteCnt : std_logic_vector(1 downto 0);
   end record;
   type DebugLLP_t is record
      -- LLP CDC FIFO signals, RxByteClkHS domain
      rbRst : std_logic;
      rbOvf : std_logic;
      rbFIFO_Rstn : std_logic;
      -- LLP CDC FIFO signals, video_clk domain
      mRst : std_logic;
      mFIFO_Tvalid : std_logic;
      mFIFO_Tready : std_logic;
      mFIFO_Tlast : std_logic;
      mFIFO_Tdata : std_logic_vector(kMaxLaneCount*8-1 downto 0);
      mFIFO_Tkeep : std_logic_vector(kMaxLaneCount-1 downto 0);
      
      mIsHeader : std_logic; -- '1' for CSI-2 header
      mECC_En : std_logic; -- Enable signal for ECC processing
      mECC_Ready : std_logic; -- ECC block ready to accept new data
      mECC_Valid : std_logic; -- ECC processing done, output valid
      mECC_Error : std_logic; -- ECC processing done, input had errors
      
      mWC : std_logic_vector(15 downto 0); --Word Count from header
      mDT : std_logic_vector(5 downto 0); --Data Type from header

      mFlush : std_logic; -- flushes packet from CDC FIFO
      mKeep : std_logic; -- passes flushed packet through
      mWordCount : std_logic_vector(15 downto 0);
      
      -- Counted, CRC- and header-stripped packet
      mReg_Tvalid : std_logic;
      mReg_Tready : std_logic;
      mReg_Tlast : std_logic;
      mReg_Tuser : std_logic;
      mReg_Tdata : std_logic_vector(kMaxLaneCount*8-1 downto 0);
      mReg_Tkeep : std_logic_vector(kMaxLaneCount-1 downto 0);
      
      mCRC_Sent : std_logic_vector(15 downto 0); -- Transmitted packet CRC
      mCRC_En : std_logic; -- Enable signal for CRC processing
      mCRC_Rst : std_logic; -- Reset signal for CRC processing
      mCRC_Out : std_logic_vector(15 downto 0); -- Receiver packet CRC 
      
      -- Video-formatted packet written to Line Buffer
      mFmt_Tvalid : std_logic;
      mFmt_Tready : std_logic;
      mFmt_Tlast : std_logic;
      mFmt_Tuser : std_logic;
      mFmt_Tdata : std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
      mFmt_cnt : std_logic_vector(2 downto 0);
      
      mBufDataCnt : std_logic_vector(10 downto 0);
   end record;
end package;
