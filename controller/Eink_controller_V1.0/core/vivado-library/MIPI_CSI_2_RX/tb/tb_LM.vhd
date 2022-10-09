----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/31/2017 07:40:43 PM
-- Design Name: 
-- Module Name: tb_LM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library STD;
use STD.textio.all;                     -- basic I/O
use ieee.std_logic_textio.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_LM is
--  Port ( );
end tb_LM;

architecture Behavioral of tb_LM is
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
         
         rbEn : in std_logic;
         rbRst : in std_logic
      );
   end component LM;
  
   constant kLaneCount : natural := 4;
   constant kMaxLaneCount : natural := 4; 
   signal RxByteClkHS : STD_LOGIC := '0';
   signal RxDataHS : STD_LOGIC_VECTOR (8 * kLaneCount - 1 downto 0);
   signal RxSyncHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal RxValidHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal RxActiveHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal m_axis_tdata : std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
   signal m_axis_tkeep : std_logic_vector(kMaxLaneCount - 1 downto 0);
   signal m_axis_tvalid : std_logic;
   signal m_axis_tready : std_logic;
   signal m_axis_tlast : std_logic;
   signal m_axis_tid : std_logic;
   signal rbRst, rbEn : std_logic;
   constant kClkPeriod : time := 10 ns;

   procedure Idle(dur : in time; signal RxValidHS : out std_logic; signal RxSyncHS : out std_logic;
                  signal RxActiveHS : out std_logic; signal RxDataHS : out std_logic_vector) is
   begin
      RxValidHS <= '0';
      RxSyncHS <= '0';
      RxActiveHS <= '0';
      RxDataHS <= (others => '-');
      wait for dur;
   end procedure;
   
   procedure SetFor(cPeriods : in natural; signal Rx: out std_logic; value : in std_logic; signal RxClk: in std_logic) is
   begin
      Rx <= value;
      for i in 1 to cPeriods loop
         wait until Rising_Edge(RxClk);
      end loop;
   end procedure;

type mem is array (natural range <>) of std_logic_vector(7 downto 0);
--LSByte first
constant data_stim : mem := (x"CC", x"78", x"00", x"0F",
            x"FF", x"00", x"00", x"02", x"B9", x"DC", x"F3", x"72", x"BB", x"D4", x"B8", x"5A", x"C8", x"75", x"C2", x"7C", x"81", x"F8", x"05", x"DF", x"FF", x"00", x"00", x"01",
            x"F0", x"00",
            
            --dummy data
            x"fc", x"04", x"29", x"37"
);

begin

--TODO generate for all lane counts
RxByteClkHS <= not RxByteClkHS after kClkPeriod / 2;

Lanes: for iLane in 0 to kLaneCount-1 generate
   LaneStimulus: process
   begin
      Idle(100ns, RxValidHS(iLane), RxSyncHS(iLane), RxActiveHS(iLane), RxDataHS((iLane+1)*8-1 downto iLane*8));
      wait until Rising_Edge(RxByteClkHS);
      if (iLane = 0) then
      --lane skew
         wait until Rising_Edge(RxByteClkHS);
         wait until Rising_Edge(RxByteClkHS);
      end if;
      if (iLane = 1) then
      --lane skew
         wait until Rising_Edge(RxByteClkHS);
      end if;      
      RxActiveHS(iLane) <= '1';
      SetFor(1, RxSyncHS(iLane), '1', RxByteClkHS);
      RxSyncHS(iLane) <= '0';
      
      SendData: for i in 0 to data_stim'length/kLaneCount loop
         if (kLaneCount*i + iLane > data_stim'length-1) then
            RxDataHS((iLane+1)*8-1 downto iLane*8) <= (others => '-');
            RxValidHS(iLane) <= '0';
            RxActiveHS(iLane) <= '0';
         else
            RxDataHS((iLane+1)*8-1 downto iLane*8) <= data_stim(kLaneCount*i+iLane);
            RxValidHS(iLane) <= '1';
         end if;
         wait until Rising_Edge(RxByteClkHS);
      end loop SendData;
      
      RxActiveHS(iLane) <= '0';
      RxValidHS(iLane) <= '0';
      wait;
   end process;
end generate Lanes;

process
begin
   rbRst <= '1';
   rbEn <= '0';
   m_axis_tready <= '0';
   wait until Rising_Edge(RxByteClkHS);
   wait until Rising_Edge(RxByteClkHS);
   wait until Rising_Edge(RxByteClkHS);
   rbRst <= '0';
   rbEn <= '1';
   SetFor(17, m_axis_tready, '0', RxByteClkHS);
   m_axis_tready <= '1';
   wait;
end process;

Verification: process (RxByteClkHS)
variable cnt_byte : natural := 0;
variable my_line : line;  -- type 'line' comes from textio
begin   
   if Rising_Edge(RxByteClkHS) then
      if (m_axis_tvalid = '1') then
         if (m_axis_tready = '1') then
            for i in 0 to kMaxLaneCount - 1 loop
               if (m_axis_tkeep(i) = '1') then
                  if m_axis_tdata((i+1)*8-1 downto i*8) /= data_stim(cnt_byte) then
                     write(my_line, string'("Error at byte "));
                     write(my_line, cnt_byte);
                     write(my_line, string'(", data: "));
                     write(my_line, m_axis_tdata((i+1)*8-1 downto i*8));
                     write(my_line, string'(", stim: "));
                     write(my_line, data_stim(cnt_byte));
                     writeline(output, my_line);
                  end if;
                  cnt_byte := cnt_byte + 1;
               end if;
            end loop;
            if (m_axis_tlast = '1' and cnt_byte < data_stim'length) or
               (m_axis_tlast = '0' and cnt_byte >= data_stim'length) then
               write(my_line, string'("Error at last byte; misaligned cnt_byte="));
               write(my_line, cnt_byte);
               writeline(output, my_line);
            end if;
            if (m_axis_tlast = '1' and cnt_byte = data_stim'length) then
                write(my_line, string'("Success, received last byte"));
                writeline(output, my_line);
            end if;
         else
            write(my_line, string'("Error, overflow"));
            writeline(output, my_line);
            assert (false) report "Error, overflow" severity failure;
         end if;
      end if;
   end if;
end process;

DUT: LM
   generic map (
      kLaneCount => kLaneCount
   )
   port map (
      RxByteClkHS => RxByteClkHS,
      RxDataHS => RxDataHS,
      RxSyncHS => RxSyncHS,
      RxValidHS => RxValidHS,
      RxActiveHS => RxActiveHS,
      rbMAxisTdata => m_axis_tdata,
      rbMAxisTkeep => m_axis_tkeep,
      rbMAxisTvalid => m_axis_tvalid,
      rbMAxisTready => m_axis_tready,
      rbMAxisTlast => m_axis_tlast,

      rbErrSkew => open,
      rbErrOvf => open,
      
      rbEn           => rbEn,
      rbRst          => rbRst
   );

end Behavioral;
