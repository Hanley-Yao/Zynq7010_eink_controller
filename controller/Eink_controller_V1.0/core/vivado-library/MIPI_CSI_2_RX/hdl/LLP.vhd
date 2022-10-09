-------------------------------------------------------------------------------
--
-- File: LLP.vhd
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

use work.DebugLib;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LLP is
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
      
      dbgLLP : out DebugLib.DebugLLP_t
   );
end LLP;

architecture Behavioral of LLP is
   COMPONENT cdc_fifo
     PORT (
       m_aclk : IN STD_LOGIC;
       s_aclk : IN STD_LOGIC;
       s_aresetn : IN STD_LOGIC;
       s_axis_tvalid : IN STD_LOGIC;
       s_axis_tready : OUT STD_LOGIC;
       s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       s_axis_tkeep : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       s_axis_tlast : IN STD_LOGIC;
       m_axis_tvalid : OUT STD_LOGIC;
       m_axis_tready : IN STD_LOGIC;
       m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       m_axis_tkeep : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       m_axis_tlast : OUT STD_LOGIC
     );
   END COMPONENT;
   COMPONENT line_buffer
     PORT (
       s_axis_aresetn : IN STD_LOGIC;
       s_axis_aclk : IN STD_LOGIC;
       s_axis_tvalid : IN STD_LOGIC;
       s_axis_tready : OUT STD_LOGIC;
       s_axis_tdata : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
       s_axis_tlast : IN STD_LOGIC;
       s_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
       m_axis_tvalid : OUT STD_LOGIC;
       m_axis_tready : IN STD_LOGIC;
       m_axis_tdata : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
       m_axis_tlast : OUT STD_LOGIC;
       m_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
       axis_wr_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       axis_rd_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
     );
   END COMPONENT;
   subtype data_type_t is std_logic_vector(5 downto 0);
   constant kDTFrameStart  : data_type_t := "000000";
   constant kDTFrameEnd    : data_type_t := "000001";
   constant kDTLineStart   : data_type_t := "000010";
   constant kDTLineEnd     : data_type_t := "000011";
   
   constant kDT_RAW10      : data_type_t := "101011";
   constant kDT_RGB565     : data_type_t := "100010";
   signal kTargetDTInt : data_type_t;
  
   signal mRst, sRst, sFIFO_Rstn : std_logic;
   signal mIsHeader : std_logic;
   signal mECC_Ready, mECC_Valid, mECC_Error, mECC_En: std_logic;
   signal mECC_HeaderOut : std_logic_vector(31 downto 0);
   signal mWordCount : unsigned(15 downto 0);
   signal mDataType : std_logic_vector(5 downto 0);

   signal mCRC_Rst, mCRC_En : std_logic;
   signal mCRC_Out, mCRC_Sent : std_logic_vector(15 downto 0);
   signal sAxisTreadyInt : std_logic;
   signal mFIFO_Tdata : std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
   signal mFIFO_Tlast, mFIFO_Tvalid, mFIFO_Tready : std_logic;
   signal mFIFO_Tkeep : std_logic_vector(kMaxLaneCount - 1 downto 0);
   
   signal mPkt_Tdata : std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
   signal mPkt_Tlast, mPkt_Tvalid, mPkt_Tready : std_logic;
   signal mPkt_Tkeep : std_logic_vector(kMaxLaneCount - 1 downto 0); 
   
   signal mReg_Tdata : std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
   signal mReg_Tlast, mReg_Tvalid, mReg_Tready : std_logic;
   signal mReg_Tkeep : std_logic_vector(kMaxLaneCount - 1 downto 0); 
   signal mReg_Tuser : std_logic_vector(0 downto 0);
   
   signal mFmt_Tdata : std_logic_vector(4 * 10 - 1 downto 0); -- Four RAW10 pixels per beat supported
   signal mFmt_Tlast, mFmt_Tvalid, mFmt_Tready : std_logic;
   signal mFmt_Tuser : std_logic_vector(0 downto 0);
   
   signal mBuf_Tready : std_logic;
   
   signal mFlush, mKeep : std_logic;

   signal mVC : std_logic_vector(1 downto 0);
   signal mDT : std_logic_vector(5 downto 0);
   signal mWC : std_logic_vector(15 downto 0);
   signal mECC : std_logic_vector(7 downto 0);
   
   signal mBufDataCnt : std_logic_vector(31 downto 0);
begin

-- Data Flow
--  -> sAxis
--  FIFO -> mFIFO_*
--      ECC -> mECC_*
--      Header stripping, byte counting -> mPkt_*
--      Packet register -> mReg_*
--          CRC processing -> mCRC_Out
--          Video formatter -> mFmt_*
--              Line Buffer -> mAxis_*
assert (kMaxLaneCount = 4) report "LLP module only supports a maximum of four lanes" severity failure;
RAW10_DT: if (kTargetDT = "RAW10") generate
   kTargetDTInt <= kDT_RAW10;
end generate;

-- Synchronize aRst into the MAxis domain
SyncMReset: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => aRst,
      OutClk => MAxisClk,
      oRst => mRst);
      
-- Synchronize aRst into the SAxis domain
SyncSReset: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => aRst,
      OutClk => SAxisClk,
      oRst => sRst);

sOverflow <= sAxisTvalid and not sAxisTreadyInt;

-- Gate sAxisTready because FIFO Generator below does not guarantee de-assertion
-- during reset
process(sFIFO_Rstn, SAxisClk)
   constant kTreadyDelay : natural := 1;
   variable delay : std_logic_vector(kTreadyDelay downto 0);
begin
   sAxisTready <= delay(delay'high);
   if (sFIFO_Rstn = '0') then
      delay := (others => '0');
   elsif Rising_Edge(SAxisClk) then
      delay := delay(delay'high - 1) & sAxisTreadyInt;
   end if;
end process;

-- This FIFO provides buffering for data from lane merge before header decoding and other
-- processing can happen.
-- It also separates the MIPI RxByteClkHS domain from the internal video pipeline clock
-- This buffer must always be able to accept data on the slave port, since the MIPI stream cannot
-- be stopped. If overflow occurs, error is signaled.
-- Underflow is not an error condition.
-- PG057: The value of s_axis_tready (...) is 1 when s_aresetn is 0.
sFIFO_Rstn <= not sRst;
DataFIFO: CDC_fifo
  PORT MAP (
    m_aclk => MAxisClk,
    s_aclk => SAxisClk,
    s_aresetn => sFIFO_Rstn, --asynchronous reset; initial reset has to be provided
    
    s_axis_tvalid => sAxisTvalid,
    s_axis_tready => sAxisTreadyInt, -- not de-asserted when aresetn = 0; need to gate it before sending upstream
    s_axis_tdata => sAxisTdata,
    s_axis_tkeep => sAxisTkeep,
    s_axis_tlast => sAxisTlast,
    
    m_axis_tvalid => mFIFO_Tvalid,
    m_axis_tready => mFIFO_Tready,
    m_axis_tdata => mFIFO_Tdata,
    m_axis_tkeep => mFIFO_Tkeep,
    m_axis_tlast => mFIFO_Tlast
  );

-- Since the header is 32-bit wide, the first word in a stream is the header
PacketFlag: process(MAxisClk)
begin
   if Rising_Edge(MAxisClk) then
      if (mRst = '1') then
         mIsHeader <= '1';
      else
         if (mFIFO_Tvalid = '1' and mFIFO_Tready = '1') then
            if (mFIFO_Tlast = '1') then
               mIsHeader <= '1';
            else
               mIsHeader <= '0';
            end if;
         end if;
      end if;
   end if;
end process;

mFIFO_Tready <=   '1' when (mECC_En = '1' and mECC_Ready = '1') or -- pop header into ECC block
                           (mFlush = '1' and mKeep = '0') or -- flush unneeded data
                           (mKeep = '1' and mPkt_Tready = '1') -- pop data when accepted downstream
                  else '0';

mECC_En <= mIsHeader and mFIFO_Tvalid;
-- Send header to processing while popping it from the FIFO
-- in 3 cycles we will get a corrected one back
ECCx: entity work.ECC 
   Port map (
      StreamClk => MAxisClk,
      sHeaderIn => mFIFO_Tdata,
      sCE => mECC_En,
      sReady => mECC_Ready,
      sHeaderOut => mECC_HeaderOut,
      sValid => mECC_Valid,
      sError => mECC_Error,
      
      sRst => mRst
   );

--Waiting on Santa to bring us VHDL-2008 support
--(mECC, mWC, mVC, mDT) <= mECC_HeaderOut;
mECC <= mECC_HeaderOut(31 downto 24);
mWC <= mECC_HeaderOut(23 downto 8); 
mVC <= mECC_HeaderOut(7 downto 6);
mDT <= mECC_HeaderOut(5 downto 0);

-- Short packet processing, assert Tuser for Start-of-Frame
FrameStart: process(MAxisClk)
begin
   if Rising_Edge(MAxisClk) then
      if (mRst = '1') then
         mReg_Tuser(0) <= '0';
      elsif (mECC_Valid = '1' and mDT = kDTFrameStart) then 
         mReg_Tuser(0) <= '1';
      elsif (mReg_Tvalid = '1' and mReg_Tready = '1') then --first word transmitted
         mReg_Tuser(0) <= '0';
      end if;
   end if;
end process;

-- Once ECC check result comes back, start emptying the FIFO until Tlast is observed
-- Flush happens regardless of the validness of the header/packet.
FlushFIFO: process(MAxisClk)
begin
   if Rising_Edge(MAxisClk) then
      if (mRst = '1') then
         mFlush <= '0';
      else
         if (mFIFO_Tlast = '1' and mFIFO_Tvalid = '1' and mFIFO_Tready = '1') then -- last byte of packet read
            mFlush <= '0';
         elsif ((mECC_Valid = '1' or mECC_Error = '1') and mIsHeader = '0') then --if there are extra bytes after the header
            mFlush <= '1';
         end if; 
      end if;
   end if;
end process;

-- If the header checks out and we have a recognized data type, forward data
-- Also register the Data Type from the header
KeepData: process(MAxisClk)
begin
   if Rising_Edge(MAxisClk) then
      if (mRst = '1') then
         mKeep <= '0';
         mDataType <= (others => '0');
      else
         if (mECC_Valid = '1') then
            if (mDT = kTargetDTInt) then -- supported long packet data types
               mKeep <= '1';
               mDataType <= mDT;
            else --unsupported data type or short packet
               mKeep <= '0';
            end if;
         elsif (mECC_Error = '1') then --uncorrectable header error
            mKeep <= '0';
         elsif (mPkt_Tlast = '1' and mPkt_Tvalid = '1' and mPkt_Tready = '1') then -- when the packet ends according to word count
            mKeep <= '0';
         end if;
      end if;
   end if;
end process;

-- Once the ECC check is complete, register the Word Count from the header
-- Count down the number of bytes forwarded
WordCountFromHeader: process (MAxisClk)
begin
   if Rising_Edge(MAxisClk) then
      if (mRst = '1') then
         mWordCount <= to_unsigned(0, 16);
      elsif (mECC_Valid = '1') then
         if (not std_match(mDT, "00----")) then -- not short packet == long packet
            mWordCount <= unsigned(mWC);
         end if;
      elsif (mPkt_Tvalid = '1' and mPkt_Tready = '1') then -- count down the bytes forwarded
         if std_match(mFIFO_Tkeep, "1111") then
            mWordCount <= mWordCount - 4;
         elsif std_match(mFIFO_Tkeep, "0111") then
            mWordCount <= mWordCount - 3;
         elsif std_match(mFIFO_Tkeep, "-011") then
            mWordCount <= mWordCount - 2;
         elsif std_match(mFIFO_Tkeep, "--01") then
            mWordCount <= mWordCount - 1;
         end if;
      end if;
   end if;
end process;

-- Generate AXI4-Stream for recognized data packet after counting data bytes, stripping header and CRC.
mPkt_Tvalid <= mFIFO_Tvalid and mKeep;
mPkt_Tready <= mReg_Tready;
mPkt_Tdata <= mFIFO_Tdata;
process(mWordCount, mFIFO_Tkeep, mFIFO_Tlast)
begin
   if mFIFO_Tlast = '1' then -- if data count incorrect and input ends sooner, end packet too 
      mPkt_Tlast <= '1';
      mPkt_Tkeep <= mFIFO_Tkeep;
   elsif mWordCount = 1 then
      mPkt_Tlast <= '1';
      mPkt_Tkeep <= "0001";
   elsif mWordCount = 2 then
      mPkt_Tlast <= '1';
      mPkt_Tkeep <= "0011";
   elsif mWordCount = 3 then
      mPkt_Tlast <= '1';
      mPkt_Tkeep <= "0111";
   elsif mWordCount = 4 then
      mPkt_Tlast <= '1';
      mPkt_Tkeep <= "1111";
   else
      mPkt_Tlast <= '0'; 
      mPkt_Tkeep <= mFIFO_Tkeep;
   end if;
end process;

-- Register packet data to improve timing
mReg_Tready <= mFmt_Tready;
PacketReg: process (MAxisClk)
begin
   if Rising_Edge(MAxisClk) then     
      if (mRst = '1') then
         mReg_Tvalid <= '0';
      elsif (mReg_Tready = '1') then
         if (mPkt_Tvalid = '1') then
            mReg_Tlast <= mPkt_Tlast;
            mReg_Tdata <= mPkt_Tdata;
            mReg_Tkeep <= mPkt_Tkeep;
            mReg_Tvalid <= '1';
         else
            mReg_Tvalid <= '0';
         end if;
      end if;
   end if;
end process;

-- Register two bytes after the data packet ends, this will be the transmitted CRC
RegisterCRC: process(MAxisClk)
variable CRCRemains : natural;
begin
   if Rising_Edge(MAxisClk) then
      if (mCRC_Rst = '1') then
         CRCRemains := 0;
      elsif (CRCRemains /= 0 and mFIFO_Tvalid = '1') then -- we have CRC bytes left to read; set when last encountered
         if (CRCRemains = 2) then
            mCRC_Sent <= mFIFO_Tdata(15 downto 0);
         elsif (CRCRemains = 1) then
            mCRC_Sent(15 downto 8) <= mFIFO_Tdata(7 downto 0);
         end if;
         CRCRemains := 0;
      elsif (mPkt_Tvalid = '1' and mPkt_Tready = '1' and mPkt_Tlast = '1') then --last valid data
         if (mWordCount = kMaxLaneCount) then
            CRCRemains := 2;
         elsif (mWordCount = kMaxLaneCount - 1) then
            CRCRemains := 1;
            mCRC_Sent(7 downto 0) <= mFIFO_Tdata(kMaxLaneCount * 8 - 1 downto (kMaxLaneCount - 1) * 8);
         elsif (mWordCount <= kMaxLaneCount - 2) then
            CRCRemains := 0;
            mCRC_Sent <= mFIFO_Tdata(kMaxLaneCount * 8 - 1 downto (kMaxLaneCount - 2) * 8);
         end if;
      end if;
   end if;
end process;

-- Generate Reset signal for CRC module. It should be reset before every new data packet.
mCRC_Rst <= mIsHeader and mFIFO_Tready; -- when a new header is popped
-- Pipe data written to DataFIFO into CRC module for data integrity verification at the end
mCRC_En <= mReg_Tvalid and mFmt_Tready;

CRC16x: entity work.CRC16
   generic map (kLaneCount => 4)
   port map (
      ByteClk => MAxisClk,
      bData => mReg_Tdata,
      bDataEnable => mCRC_En,
      bKeep => mReg_Tkeep,
      bCRC => mCRC_Out,
      bRst => mCRC_Rst
   );

--TODO do CRC compare for statistics

--CSI-2 RAW10 spec: The length of each packet must be a multiple of 4 pixels, 5 bytes
mFmt_Tready <= mBuf_Tready;


RAW10Formatter: process(MAxisClk)
constant kPixelWidth : natural := 10;
constant kNoPixels : natural := 4;
constant kNoBytes : natural := 5;
type pixels_t is array (natural range <>) of std_logic_vector(kPixelWidth downto 0);
variable pix_mux : pixels_t(0 to kNoPixels-1);
variable cnt : natural range 0 to kNoBytes-1 := 0;
begin
   if Rising_Edge(MAxisClk) then
      dbgLLP.mFmt_cnt <= std_logic_vector(to_unsigned(cnt, 3));
      if (mRst = '1') then
         cnt := 0;
         mFmt_Tvalid <= '0';
         mFmt_Tuser <= "0";
      elsif (mFmt_Tready = '1') then
         mFmt_Tvalid <= mReg_Tvalid;
         if (mFmt_Tvalid = '1') then --first pixels transmitted
            mFmt_Tuser <= "0";
         elsif (mReg_Tuser = "1") then
            mFmt_Tuser <= "1";
         end if;
         if (mReg_Tvalid = '1') then
            case (cnt) is
               when 0 =>
                  pix_mux(3)(9 downto 2) := mReg_Tdata(31 downto 24);
                  pix_mux(2)(9 downto 2) := mReg_Tdata(23 downto 16);
                  pix_mux(1)(9 downto 2) := mReg_Tdata(15 downto 8);
                  pix_mux(0)(9 downto 2) := mReg_Tdata(7 downto 0);
                  mFmt_Tvalid <= '0';
                  mFmt_Tlast <= mReg_Tlast; -- if there is last here, error
               when 1 =>
                  for i in 0 to 3 loop
                     mFmt_Tdata((i+1)*10-1 downto i*10+2) <= pix_mux(i)(9 downto 2); -- from previous word
                  end loop;
                  pix_mux(2)(9 downto 2) := mReg_Tdata(31 downto 24);
                  pix_mux(1)(9 downto 2) := mReg_Tdata(23 downto 16);
                  pix_mux(0)(9 downto 2) := mReg_Tdata(15 downto 8);
                  pix_mux(3)(1 downto 0) := mReg_Tdata(7 downto 6);
                  pix_mux(2)(1 downto 0) := mReg_Tdata(5 downto 4);
                  pix_mux(1)(1 downto 0) := mReg_Tdata(3 downto 2);
                  pix_mux(0)(1 downto 0) := mReg_Tdata(1 downto 0);
                  for i in 0 to 3 loop
                     mFmt_Tdata((i*10+1) downto i*10) <= pix_mux(i)(1 downto 0); -- from current word
                  end loop;
                  mFmt_Tvalid <= '1';
                  mFmt_Tlast <= mReg_Tlast;
               when 2 =>
                  for i in 0 to 2 loop
                     mFmt_Tdata((i+1)*10-1 downto i*10+2) <= pix_mux(i)(9 downto 2); -- from previous word
                  end loop;
                  pix_mux(1)(9 downto 2) := mReg_Tdata(31 downto 24);
                  pix_mux(0)(9 downto 2) := mReg_Tdata(23 downto 16);
                  pix_mux(3)(1 downto 0) := mReg_Tdata(15 downto 14);
                  pix_mux(2)(1 downto 0) := mReg_Tdata(13 downto 12);
                  pix_mux(1)(1 downto 0) := mReg_Tdata(11 downto 10);
                  pix_mux(0)(1 downto 0) := mReg_Tdata(9 downto 8);
                  pix_mux(3)(9 downto 2) := mReg_Tdata(7 downto 0);
                  for i in 3 to 3 loop
                     mFmt_Tdata((i+1)*10-1 downto i*10+2) <= pix_mux(i)(9 downto 2); -- from current word
                  end loop;
                  for i in 0 to 3 loop
                     mFmt_Tdata((i*10+1) downto i*10) <= pix_mux(i)(1 downto 0); -- from current word
                  end loop;
                  mFmt_Tvalid <= '1';
                  mFmt_Tlast <= mReg_Tlast;
               when 3 =>
                  for i in 0 to 1 loop
                     mFmt_Tdata((i+1)*10-1 downto i*10+2) <= pix_mux(i)(9 downto 2); -- from previous word
                  end loop;
                  pix_mux(0)(9 downto 2) := mReg_Tdata(31 downto 24);
                  pix_mux(3)(1 downto 0) := mReg_Tdata(23 downto 22);
                  pix_mux(2)(1 downto 0) := mReg_Tdata(21 downto 20);
                  pix_mux(1)(1 downto 0) := mReg_Tdata(19 downto 18);
                  pix_mux(0)(1 downto 0) := mReg_Tdata(17 downto 16);
                  pix_mux(3)(9 downto 2) := mReg_Tdata(15 downto 8);
                  pix_mux(2)(9 downto 2) := mReg_Tdata(7 downto 0);
                  for i in 2 to 3 loop
                     mFmt_Tdata((i+1)*10-1 downto i*10+2) <= pix_mux(i)(9 downto 2); -- from current word
                  end loop;
                  for i in 0 to 3 loop
                     mFmt_Tdata((i*10+1) downto i*10) <= pix_mux(i)(1 downto 0); -- from current word
                  end loop;
                  mFmt_Tvalid <= '1';
                  mFmt_Tlast <= mReg_Tlast;
               when 4 =>
                  for i in 0 to 0 loop
                     mFmt_Tdata((i+1)*10-1 downto i*10+2) <= pix_mux(i)(9 downto 2); -- from previous word
                  end loop;
                  pix_mux(3)(1 downto 0) := mReg_Tdata(31 downto 30);
                  pix_mux(2)(1 downto 0) := mReg_Tdata(29 downto 28);
                  pix_mux(1)(1 downto 0) := mReg_Tdata(27 downto 26);
                  pix_mux(0)(1 downto 0) := mReg_Tdata(25 downto 24);
                  pix_mux(3)(9 downto 2) := mReg_Tdata(23 downto 16);
                  pix_mux(2)(9 downto 2) := mReg_Tdata(15 downto 8);
                  pix_mux(1)(9 downto 2) := mReg_Tdata(7 downto 0);
                  for i in 1 to 3 loop
                     mFmt_Tdata((i+1)*10-1 downto i*10+2) <= pix_mux(i)(9 downto 2); -- from current word
                  end loop;
                  for i in 0 to 3 loop
                     mFmt_Tdata((i*10+1) downto i*10) <= pix_mux(i)(1 downto 0); -- from current word
                  end loop;
                  mFmt_Tvalid <= '1'; 
                  mFmt_Tlast <= mReg_Tlast;            
            end case;
            if (cnt < kNoBytes-1 and mReg_Tlast = '0') then
               cnt := cnt + 1;
            else
               cnt := 0;
            end if; 
         end if;
      end if;
   end if;
end process;

LineBufferFIFO: line_buffer
   PORT MAP (
      s_axis_aclk => MAxisClk,
      s_axis_aresetn => not mRst, -- active-low synchronous reset
      s_axis_tvalid => mFmt_Tvalid,
      s_axis_tready => mBuf_Tready, -- de-asserted properly when aresetn = 0
      s_axis_tdata => mFmt_Tdata,
      s_axis_tlast => mFmt_Tlast,
      s_axis_tuser => mFmt_Tuser,
      m_axis_tvalid => mAxisTvalid, -- de-asserted properly when aresetn = 0
      m_axis_tready => mAxisTready,
      m_axis_tdata => mAxisTdata,
      m_axis_tlast => mAxisTlast,
      m_axis_tuser => mAxisTuser,
      axis_wr_data_count => mBufDataCnt,
      axis_rd_data_count => open
   );

-- Debug signals
dbgLLP.rbRst <= sRst;
dbgLLP.rbFIFO_Rstn <= sFIFO_Rstn;
dbgLLP.mRst <= mRst;
dbgLLP.mFIFO_Tvalid <= mFIFO_Tvalid;
dbgLLP.mFIFO_Tready <= mFIFO_Tready;
dbgLLP.mFIFO_Tlast <= mFIFO_Tlast;
dbgLLP.mFIFO_Tdata <= mFIFO_Tdata;
dbgLLP.mFIFO_Tkeep <= mFIFO_Tkeep;
dbgLLP.mIsHeader <= mIsHeader;
dbgLLP.mECC_En <= mECC_En;
dbgLLP.mECC_Ready <= mECC_Ready;
dbgLLP.mECC_Valid <= mECC_Valid;
dbgLLP.mECC_Error <= mECC_Error;
dbgLLP.mWC <= mWC;
dbgLLP.mDT <= mDT;
dbgLLP.mFlush <= mFlush;
dbgLLP.mKeep <= mKeep;
dbgLLP.mWordCount <= std_logic_vector(mWordCount);
dbgLLP.mReg_Tvalid <= mReg_Tvalid;
dbgLLP.mReg_Tready <= mReg_Tready;
dbgLLP.mReg_Tlast <= mReg_Tlast;
dbgLLP.mReg_Tuser <= mReg_Tuser(0);
dbgLLP.mReg_Tdata <= mReg_Tdata;
dbgLLP.mReg_Tkeep <= mReg_Tkeep;
dbgLLP.mCRC_Sent <= mCRC_Sent;
dbgLLP.mCRC_En <= mCRC_En;
dbgLLP.mCRC_Rst <= mCRC_Rst;
dbgLLP.mCRC_Out <= mCRC_Out;
dbgLLP.mFmt_Tvalid <= mFmt_Tvalid;
dbgLLP.mFmt_Tready <= mFmt_Tready;
dbgLLP.mFmt_Tlast <= mFmt_Tlast;
dbgLLP.mFmt_Tuser <= mFmt_Tuser(0);
dbgLLP.mFmt_Tdata <= mFmt_Tdata;
dbgLLP.mBufDataCnt <= mBufDataCnt(10 downto 0);
end Behavioral;
