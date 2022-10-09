----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/13/2017 06:22:52 PM
-- Design Name: 
-- Module Name: tb_MIPI_CSI2 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_MIPI_CSI2 is
--  Port ( );
end tb_MIPI_CSI2;

architecture Behavioral of tb_MIPI_CSI2 is
   component MIPI_CSI2_Rx is
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
   end component MIPI_CSI2_Rx;
   
   constant kTargetDT : string := "RAW10";
   constant kLaneCount : natural := 2;
   constant C_M_AXIS_COMPONENT_WIDTH : natural := 10; -- [8,10]
   constant C_M_AXIS_TDATA_WIDTH : natural := 40;
   constant C_M_MAX_SAMPLES_PER_CLOCK : natural := 4;
   constant kRxClkPeriod : time := 10 ns;
   constant kVidClkPeriod : time := 20ns;

   signal mRst_n : std_logic;
   
   signal RxByteClkHS : STD_LOGIC := '0';
   signal rbRxDataHS : STD_LOGIC_VECTOR (8 * kLaneCount - 1 downto 0);
   signal rbRxSyncHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal rbRxValidHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal rbRxActiveHS : STD_LOGIC_VECTOR (kLaneCount - 1 downto 0);
   signal aDEnable : std_logic_vector(kLaneCount - 1 downto 0);
   signal aClkEnable : std_logic;
   
   signal mAxisTdata : std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
   signal mAxisTvalid, mAxisTready, mAxisTlast : std_logic;
   signal mAxisTuser : std_logic_vector(0 downto 0);
   signal MAxisClk : std_logic := '0';
   
   procedure Idle(signal RxValidHS : out std_logic; signal RxSyncHS : out std_logic;
                  signal RxActiveHS : out std_logic; signal RxDataHS : out std_logic_vector) is
   begin
      RxValidHS <= '0';
      RxSyncHS <= '0';
      RxActiveHS <= '0';
      RxDataHS <= (others => '-');
   end procedure;
   
   type mem is array (natural range <>) of std_logic_vector(7 downto 0);
   --LSByte first
   constant fs_err : mem := (x"00", x"01", x"C0", x"1A", x"EF", x"BE"); --frame start with two ECC errors and extra bytes (if no EoT processing is done in PHY)
   constant fs : mem := (x"00", x"01", x"00", x"1A"); --frame start with no ECC errors
   constant long_err : mem := (x"2B", x"FF", x"FF", x"00", x"00", x"00", x"00", x"00", x"E4", x"E4", x"E4", x"E4");  --uncorrectable error
   constant length_err : mem := (x"2B", x"FF", x"FF", x"2D", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00");  --correct header, incorrect length
   constant longRAW10_err : mem := (x"2B", x"0A", x"80", x"2E", x"00", x"00", x"00", x"00", x"E4", x"01", x"01", x"01", x"01", x"E4", x"E9", x"FB", x"EF", x"BE", x"AD", x"DE");  --active line RAW8, error in third byte 00, extra bytes
   constant fe : mem := (x"01", x"01", x"00", x"0D"); --frame end with one ECC error (error in last byte 1D)
begin

RxByteClkHS <= not RxByteClkHS after kRxClkPeriod / 2 when aClkEnable = '1' else
               '0';
MAxisClk <= not MAxisClk after kVidClkPeriod / 2;

ResetGen: process
begin
   mRst_n <= '0';
   -- Reset of 16 clock periods is recommended for AXI IP
   for i in 1 to 16 loop
      wait until Rising_Edge(MAxisClk);
   end loop;
   mRst_n <= '1';
   wait;
end process;

WriteProc: process
   procedure SendPacket(test_vect : in mem) is
      variable iLane : natural range test_vect'range := 0;
   begin
      --Put all lanes in idle then activate them
      for iLane in 0 to kLaneCount - 1 loop
         Idle(rbRxValidHS(iLane), rbRxSyncHS(iLane), rbRxActiveHS(iLane), rbRxDataHS((iLane+1)*8-1 downto iLane*8));
      end loop;
      wait for 100ns;
      for iLane in 0 to kLaneCount - 1 loop
         rbRxActiveHS(iLane) <= '1';
         rbRxSyncHS(iLane) <= '1' ;
      end loop;
      wait until Rising_Edge(RxByteClkHS);
      for iLane in 0 to kLaneCount - 1 loop
         rbRxSyncHS(iLane) <= '0';
      end loop;

      iLane := 0;
      SendData: for i in test_vect'range loop
         rbRxDataHS((iLane+1)*8-1 downto iLane*8) <= test_vect(i);
         rbRxValidHS(iLane) <= '1';
         if (iLane = kLaneCount - 1) then
            iLane := 0;
            wait until Rising_Edge(RxByteClkHS);
         else
            iLane := iLane + 1;
         end if;
      end loop SendData;
      -- EoT on remainder lanes for last packet
      for i in iLane to kLaneCount - 1 loop
          rbRxValidHS(i) <= '0';        
          rbRxActiveHS(i) <= '0';
      end loop;
      wait until Rising_Edge(RxByteClkHS);
      -- EoT on all lanes
      for iLane in 0 to kLaneCount - 1 loop
         Idle(rbRxValidHS(iLane), rbRxSyncHS(iLane), rbRxActiveHS(iLane), rbRxDataHS((iLane+1)*8-1 downto iLane*8));
      end loop;
      wait until Rising_Edge(RxByteClkHS);
   end procedure;
   
begin
   for iLane in 0 to kLaneCount - 1 loop
      Idle(rbRxValidHS(iLane), rbRxSyncHS(iLane), rbRxActiveHS(iLane), rbRxDataHS((iLane+1)*8-1 downto iLane*8));
   end loop;
   wait until aDEnable = "11";
   SendPacket(fs_err);
   SendPacket(long_err);
   SendPacket(length_err);
   SendPacket(fs);
   SendPacket(longRAW10_err);
   SendPacket(long_err);
   SendPacket(fe);
   wait;
end process;


ReadProc: process
begin
   mAxisTready <= '1';
   wait until Rising_Edge(MAxisClk) and mAxisTready = '1' and mAxisTvalid = '1';
   assert (unsigned(mAxisTdata)=to_unsigned(0,C_M_AXIS_TDATA_WIDTH)) report "Expected throw-away data has unexpected value" severity failure;
   for i in 0 to 8 - 1 loop
      if (i mod C_M_MAX_SAMPLES_PER_CLOCK = 0) then
         wait until Rising_Edge(MAxisClk) and mAxisTready = '1' and mAxisTvalid = '1';
      end if;
      if (i/C_M_MAX_SAMPLES_PER_CLOCK = 0) then
         assert(mAxisTuser="1") report "Tuser not asserted at SOF" severity failure;
      else
         assert(mAxisTuser="0") report "Tuser asserted mid-frame" severity failure;
      end if;
      assert (to_unsigned(i,10)=unsigned(mAxisTdata(((i mod C_M_MAX_SAMPLES_PER_CLOCK)+1)*10-1 downto (i mod C_M_MAX_SAMPLES_PER_CLOCK)*10))) report "Output data does not match input" severity failure;
      if (i/C_M_MAX_SAMPLES_PER_CLOCK = (8-1)/C_M_MAX_SAMPLES_PER_CLOCK) then
         assert(mAxisTlast='1') report "Tlast not asserted at EOL" severity failure;
      else
         assert(mAxisTlast='0') report "Tlast asserted mid-line" severity failure;
      end if;        
   end loop;
   report "Testbench executed successfully" severity note;
   wait;
end process;

DUT: MIPI_CSI2_Rx
   Generic map(
      kTargetDT => kTargetDT,
      kDebug => false,       
      --PPI
      kLaneCount => kLaneCount, --[1,2,4]
      --Video Format
      C_M_AXIS_COMPONENT_WIDTH => C_M_AXIS_COMPONENT_WIDTH, -- [8,10]
      C_M_AXIS_TDATA_WIDTH => C_M_AXIS_TDATA_WIDTH,
      C_M_MAX_SAMPLES_PER_CLOCK => C_M_MAX_SAMPLES_PER_CLOCK
   )
   Port map( 
      --PPI
      RxByteClkHS => RxByteClkHS,
      aClkStopstate => '0',
      aRxClkActiveHS => '1',
      
      rbRxDataHS => rbRxDataHS,
      rbRxSyncHS => rbRxSyncHS,
      rbRxValidHS => rbRxValidHS,
      rbRxActiveHS => rbRxActiveHS,
      aDEnable => aDEnable,      
      aClkEnable => aClkEnable,   
      
      --axi stream signals
      m_axis_video_tdata    => mAxisTdata,
      m_axis_video_tvalid   => mAxisTvalid,
      m_axis_video_tready   => mAxisTready,
      m_axis_video_tlast    => mAxisTlast,
      m_axis_video_tuser    => mAxisTuser,
      
      video_aresetn        => mRst_n,
      video_aclk           => MAxisClk,
      vEnable              => '1'
    );

end Behavioral;
