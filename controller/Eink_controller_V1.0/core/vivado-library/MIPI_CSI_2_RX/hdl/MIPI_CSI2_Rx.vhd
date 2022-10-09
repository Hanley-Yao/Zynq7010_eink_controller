-------------------------------------------------------------------------------
--
-- File: MIPI_CSI2_Rx.vhd
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.DebugLib.all;

entity MIPI_CSI2_Rx is
   Generic (
      kTargetDT : string := "RAW10";
      kDebug : boolean := true; 
      --PPI
      kLaneCount : natural range 1 to 4 := 2; --[1,2,4]
      --Video Format
      C_M_AXIS_COMPONENT_WIDTH : natural := 10; -- [8,10]
      C_M_AXIS_TDATA_WIDTH : natural := 40;
      C_M_MAX_SAMPLES_PER_CLOCK : natural := 4
   );
   Port ( 
      --PPI
      RxByteClkHS : in STD_LOGIC;
      aClkStopstate : in std_logic;
      aRxClkActiveHS : in std_logic;
      
      rbRxDataHS : in STD_LOGIC_VECTOR (8 * kLaneCount - 1 downto 0);
      rbRxSyncHS : in STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
      rbRxValidHS : in STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
      rbRxActiveHS : in STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
      aDEnable : out STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);      
      aClkEnable : out STD_LOGIC;
      
      --axi stream signals
      m_axis_video_tdata    : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
      m_axis_video_tvalid   : out std_logic;
      m_axis_video_tready   : in std_logic;
      m_axis_video_tlast    : out std_logic;
      m_axis_video_tuser    : out std_logic_vector(0 downto 0);
      
      video_aresetn        : in std_logic;
      video_aclk           : in std_logic;
      vEnable              : in std_logic  --TODO proper buffer flushing on disable, perhaps waiting on active transfer to end
    );
end MIPI_CSI2_Rx;

architecture Behavioral of MIPI_CSI2_Rx is
   component LM is
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
         
         rbEn  : in std_logic;
         rbRst : in std_logic;
               
         dbgLMLane : out DebugLMLanes_t;
         dbgLM : out DebugLM_t
      );
   end component LM;
   component LLP is
      Generic(
         kMaxLaneCount : natural := 4;
         --PPI
         kLaneCount : natural range 1 to 4 := 2; --[1,2,4];
         kTargetDT : string := "RAW10"
      );
      Port (
         SAxisClk : in STD_LOGIC;
         --Slave AXI-Stream
         sAxisTdata : in std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
         sAxisTkeep : in std_logic_vector(kMaxLaneCount - 1 downto 0);
         sAxisTvalid : in std_logic;
         sAxisTready : out std_logic;
         sAxisTlast : in std_logic;
         
         MAxisClk : in std_logic;
         --Master AXI-Stream
         mAxisTdata : out std_logic_vector(40 - 1 downto 0);
         mAxisTvalid : out std_logic;
         mAxisTready : in std_logic;
         mAxisTlast : out std_logic;
         mAxisTuser : out std_logic_vector(0 downto 0);
               
         sOverflow : out std_logic;
         aRst : in std_logic; -- global asynchronous reset; synchronized internally to both clock domains
         
         dbgLLP : out DebugLLP_t
      );
   end component;
   
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
   
   constant kMaxLaneCount : natural := 4;
   
   
   signal rbLMAxisTdata : std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
   signal rbLMAxisTkeep : std_logic_vector(kMaxLaneCount - 1 downto 0);
   signal rbLMAxisTvalid, rbLMAxisTlast : std_logic;
   signal rbLMErrOvf, rbLMErrSkew : std_logic;
   signal rbLLPAxisTready : std_logic;
   signal rbRst_n, rbEn : std_logic;
   signal vTready, vRst : std_logic;
   signal dbgLMLane : DebugLMLanes_t;
   signal dbgLM : DebugLM_t;
   signal dbgLLP : DebugLLP_t;
   signal rbRxClkTrigOut, vRxClkTrigOut, vTrigIn, vTrigInAck, rbTrigInAck : std_logic;
   signal rbRxClkLaneTrigOut, vRxClkLaneTrigOut : std_logic_vector(kMaxLaneCount - 1 downto 0);
   signal aClkEnableInt : std_logic;
   signal aDEnableInt : std_logic_vector(kMaxLaneCount - 1 downto 0);
begin

-- Synchronize video_aresetn into the RxByteClkHS domain
SyncReset: entity work.ResetBridge
   generic map (
      kPolarity => '0')
   port map (
      aRst => video_aresetn,
      OutClk => RxByteClkHS,
      oRst => rbRst_n);

-- Synchronize vEnable into the RxByteClkHS domain
SyncAsyncEnable: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2, --use double FF synchronizer
      kResetPolarity => '0') 
   port map (
      aReset => rbRst_n,
      aIn => vEnable,
      OutClk => RxByteClkHS,
      oOut => rbEn);

GlitchFree_vRst: process(video_aclk)
begin
   if Rising_Edge(video_aclk) then
      vRst <= not video_aresetn;
   end if;
end process;

PPI_Clock_Enable: process(video_aclk)
begin
   if Rising_Edge(video_aclk) then
      aClkEnableInt <= vEnable and video_aresetn;
      aDEnableInt <= (others => vEnable and video_aresetn);
   end if;
end process;

aClkEnable <= aClkEnableInt;

-- Initially data lanes were only enabled when the LLP module below doing
-- data buffering was ready to receive data. However, this was problematic for
-- two reasons:
-- 1. not all lanes (clock and data) were enabled simultaneously and
-- 2. since LLP requires a few RxByteClkHS clock cycles to assert ready on its
-- slave port, the data lanes were only enabled after the clock lane was already
-- transmitting clock. The data lanes still needed Stop state of T_INIT long
-- at least to complete initialization after enablement, resulting in loss of
-- the first data packets.
-- Instead, we rely on LM to do a limited buffering upon exit from reset and
-- on T_CLK_PRE 
--PPI_Data_Enable: process(video_aclk)
--begin
--   if Rising_Edge(video_aclk) then
--      if (video_aresetn = '0') then
--         aDEnableInt    <= (others => '0');
--      else
--         if (vEnable = '0') then
--            aDEnableInt    <= (others => '0');
--         elsif (vTready = '1') then --LLP buffer should be ready to receive data before enabling the PHY
--            aDEnableInt    <= (others => '1');
--         end if;
--      end if;
--   end if;
--end process;

aDEnable <= aDEnableInt(kLaneCount-1 downto 0);
            
SyncAsyncTready: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2, --use double FF synchronizer
      kResetPolarity => '0') 
   port map (
      aReset => video_aresetn,
      aIn => rbLLPAxisTready,
      OutClk => video_aclk,
      oOut => vTready);

-- Lane merger compacts the CSI-2 lane into a wide AXI-Stream bus
-- Both the input and output interfaces are synchronous to RxByteClkHS
-- and it does not buffer data
LM_inst: LM
   Generic Map( 
      kMaxLaneCount  => kMaxLaneCount,
      kLaneCount     => kLaneCount
   )
   Port Map( 
      RxByteClkHS    => RxByteClkHS,
      RxDataHS       => rbRxDataHS,
      RxSyncHS       => rbRxSyncHS,
      RxValidHS      => rbRxValidHS,
      RxActiveHS     => rbRxActiveHS,
      
      rbMAxisTdata   => rbLMAxisTdata,
      rbMAxisTkeep   => rbLMAxisTkeep,
      rbMAxisTvalid  => rbLMAxisTvalid,
      rbMAxisTready  => rbLLPAxisTready,
      rbMAxisTlast   => rbLMAxisTlast,
      
      rbErrSkew      => rbLMErrSkew,
      rbErrOvf       => rbLMErrOvf,
      
      rbEn           => rbEn,
      rbRst          => not rbRst_n,

      dbgLMLane      => dbgLMLane,
      dbgLM          => dbgLM
   );

-- Link-level protocol decodes short and long packets into frames, lines
-- and pixels. It synchronizes data from the MIPI clock domain (RxByteClkHS)
-- to the video pipeline domain video_aclk. It does error detection
-- and correction, filters data according to the target data type and
-- formats it according to UG934, ready to source a video processing
-- pipeline.
LLP_inst: LLP
   Generic map (
      kMaxLaneCount => kMaxLaneCount,
      --PPI
      kLaneCount => kLaneCount, --[1,2,4]
      kTargetDT => kTargetDT
   )
   Port map (
      SAxisClk => RxByteClkHS,
      --Slave AXI-Stream
      sAxisTdata => rbLMAxisTdata, 
      sAxisTkeep => rbLMAxisTkeep,
      sAxisTvalid => rbLMAxisTvalid,
      sAxisTready => rbLLPAxisTready,
      sAxisTlast => rbLMAxisTlast,
      
      MAxisClk => video_aclk,
      --Master AXI-Stream
      mAxisTdata => m_axis_video_tdata,
      mAxisTvalid => m_axis_video_tvalid,
      mAxisTready => m_axis_video_tready,
      mAxisTlast => m_axis_video_tlast,
      mAxisTuser => m_axis_video_tuser,
      
      aRst => vRst,            
      sOverflow => open,
      
      dbgLLP => dbgLLP
   );

----------------------------------------------------------------------------------
-- Debug modules
----------------------------------------------------------------------------------
GenerateDebug: if kDebug generate

ILARxClk : ila_rxclk
PORT MAP (
	clk => RxByteClkHS,

	trig_out => rbRxClkTrigOut,
	trig_out_ack => rbTrigInAck,

	probe0 => dbgLM.state, 
	probe1 => dbgLM.rbByteCnt, 
	probe2 => rbLMAxisTdata, 
	probe3 => rbLMAxisTkeep, 
	probe4(0) => rbLMAxisTvalid, 
	probe5(0) => rbLLPAxisTready, 
	probe6(0) => rbLMAxisTlast, 
	probe7(0) => rbLMErrSkew, 
	probe8(0) => rbLMErrOvf,
	probe9(0) => dbgLLP.rbRst,
	probe10(0) => dbgLLP.rbOvf,
	probe11(0) => dbgLLP.rbFIFO_Rstn,
	probe12(0) => rbRst_n,
	probe13(0) => rbEn
);

ILAVidClk : ila_vidclk
PORT MAP (
	clk => video_aclk,
	trig_in => vTrigIn,
   trig_in_ack => vTrigInAck,
   
	probe0(0) => dbgLLP.mRst, 
	probe1(0) => dbgLLP.mFIFO_Tvalid, 
	probe2(0) => dbgLLP.mFIFO_Tready, 
	probe3(0) => dbgLLP.mFIFO_Tlast, 
	probe4 => dbgLLP.mFIFO_Tdata, 
	probe5 => dbgLLP.mFIFO_Tkeep, 
	probe6(0) => dbgLLP.mIsHeader, 
	probe7(0) => dbgLLP.mECC_En, 
	probe8(0) => dbgLLP.mECC_Ready, 
	probe9(0) => dbgLLP.mECC_Valid, 
	probe10(0) => dbgLLP.mECC_Error, 
	probe11 => dbgLLP.mWC, 
	probe12 => dbgLLP.mDT, 
	probe13(0) => dbgLLP.mFlush, 
	probe14(0) => dbgLLP.mKeep, 
	probe15 => dbgLLP.mWordCount, 
	probe16(0) => dbgLLP.mReg_Tvalid, 
	probe17(0) => dbgLLP.mReg_Tready, 
	probe18(0) => dbgLLP.mReg_Tlast,
	probe19(0) => dbgLLP.mReg_Tuser, 
	probe20 => dbgLLP.mReg_Tdata, 
	probe21 => dbgLLP.mReg_Tkeep, 
	probe22 => dbgLLP.mCRC_Sent, 
	probe23(0) => dbgLLP.mCRC_En, 
	probe24(0) => dbgLLP.mCRC_Rst, 
	probe25 => dbgLLP.mCRC_Out, 
	probe26(0) => dbgLLP.mFmt_Tvalid, 
	probe27(0) => dbgLLP.mFmt_Tready, 
	probe28(0) => dbgLLP.mFmt_Tlast,
	probe29(0) => dbgLLP.mFmt_Tuser, 
	probe30 => dbgLLP.mFmt_Tdata, 
	probe31 => dbgLLP.mFmt_cnt,
	probe32 => dbgLLP.mBufDataCnt,
	probe33(0) => aClkEnableInt,
	probe34 => aDEnableInt,
	probe35(0) => vTready
);

SyncAsyncTrigOut: entity work.SyncAsync
   port map (
      aReset => '0',
      aIn => rbRxClkTrigOut,
      OutClk => video_aclk,
      oOut => vRxClkTrigOut);
      
SyncAsyncTrigAck: entity work.SyncAsync
   port map (
      aReset => '0',
      aIn => vTrigInAck,
      OutClk => RxByteClkHS,
      oOut => rbTrigInAck);
      
ILA_LaneGen: for i in kLaneCount-1 downto 0 generate      

   ILARxClk_Lane : ila_rxclk_lane
   PORT MAP (
      clk => RxByteClkHS,
   
      trig_out => rbRxClkLaneTrigOut(i),
      trig_out_ack => rbTrigInAck,
   
      probe0(0) => dbgLMLane(i).rbSkwRdEn, 
      probe1(0) => dbgLMLane(i).rbSkwWrEn, 
      probe2(0) => dbgLMLane(i).rbSkwFull, 
      probe3(0) => dbgLMLane(i).rbActiveHS, 
      probe4(0) => dbgLMLane(i).rbSyncHS, 
      probe5(0) => dbgLMLane(i).rbValidHS,
      probe6 => dbgLMLane(i).rbDataHS
   );
     
   SyncAsyncTrigOut: entity work.SyncAsync
      port map (
         aReset => '0',
         aIn => rbRxClkLaneTrigOut(i),
         OutClk => video_aclk,
         oOut => vRxClkLaneTrigOut(i));
         
end generate ILA_LaneGen;      

vTrigIn <= orv(vRxClkLaneTrigOut) or vRxClkTrigOut;

end generate;

end Behavioral;
