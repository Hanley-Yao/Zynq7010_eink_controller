----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/23/2017 08:00:19 PM
-- Design Name: 
-- Module Name: tb_LLP - Behavioral
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

use work.mypkg.all;
   
entity tb_LLP is
--  Port ( );
end tb_LLP;

architecture Behavioral of tb_LLP is
   component LLP is
      Generic(
         kMaxLaneCount : natural := 4;
         --PPI
         kLaneCount : natural range 1 to 4 := 2 --[1,2,4]
      );
      Port (
         SAxisClk : in STD_LOGIC;
         --Slave AXI-Stream
         sAxisTdata : in std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
         sAxisTkeep : in std_logic_vector(kMaxLaneCount - 1 downto 0);
         sAxisTvalid : in std_logic;
         sAxisTready : out std_logic;
         sAxisTlast : in std_logic;
         --TODO: sAxisTdest : in std_logic;
         
         MAxisClk : in std_logic;
         --Master AXI-Stream
         mAxisTdata : out std_logic_vector(40 - 1 downto 0);
         mAxisTvalid : out std_logic;
         mAxisTready : in std_logic;
         mAxisTlast : out std_logic;
         mAxisTuser : out std_logic_vector(0 downto 0);
               
         sOverflow : out std_logic;
         aRst : in std_logic
      );
   end component LLP;
   constant kSClkPeriod : time := 10ns;
   constant kMClkPeriod : time := 13ns;
   constant kMaxLaneCount : natural := 4;
   constant kPixPerBeat : natural := 4;
   
   type mem is array (natural range <>) of std_logic_vector(7 downto 0);
   --LSByte first
  
   constant fs_err : mem := (x"00", x"01", x"C0", x"1A", x"EF", x"BE"); --frame start with two ECC errors and extra bytes (if no EoT processing is done in PHY)
   constant fs : mem := (x"00", x"01", x"00", x"1A"); --frame start with no ECC errors
   constant longRAW10_cnt_err : mem := (x"2B", x"01", x"00", x"0D", x"00", x"00", x"00"); --shorter line
   constant longRAW10_err : mem := (x"2B", x"0A", x"80", x"2E", x"00", x"00", x"00", x"00", x"E4", x"01", x"01", x"01", x"01", x"E4", x"E9", x"FB", x"EF", x"BE", x"AD", x"DE");  --active line RAW8, error in third byte 00, extra bytes
   constant fe : mem := (x"01", x"01", x"00", x"0D"); --frame end with one ECC error (error in last byte 1D)
     
   signal sAxisTdata : std_logic_vector(8 * kMaxLaneCount - 1 downto 0);
   signal sAxisTkeep : std_logic_vector(kMaxLaneCount - 1 downto 0);
   signal sAxisTvalid, sAxisTready, sAxisTlast : std_logic;
   signal MAxisClk, SAxisClk : std_logic := '0';
   signal mAxisTdata : std_logic_vector(kPixPerBeat*10 - 1 downto 0);
   signal mAxisTvalid, mAxisTready, mAxisTlast : std_logic;
   signal mAxisTuser : std_logic_vector(0 downto 0);
   signal aRst : std_logic;

begin

--TODO generate for all lane counts
SAxisClk <= not SAxisClk after kSClkPeriod / 2;
MAxisClk <= not MAxisClk after kMClkPeriod / 2;

WriteProc: process
variable iLane : natural := 0;
   procedure SendPacket(test_vect : in mem) is
   begin
      sAxisTkeep <= (others => '0');
      sAxisTlast <= '0';
      iLane := 0;
      for i in 0 to test_vect'length - 1 loop
         sAxisTdata((iLane+1)*8-1 downto iLane*8) <= test_vect(i);
         sAxisTkeep(iLane) <= '1';
         if (iLane = 3 or i = test_vect'length - 1) then
            sAxisTvalid <= '1';
            if (i = test_vect'length - 1) then
               sAxisTlast <= '1';
            end if;
            wait until Rising_Edge(SAxisClk) and sAxisTready = '1';
            iLane := 0;
            sAxisTkeep <= (others => '0');
         else
            iLane := iLane + 1;
         end if;
      end loop;
      sAxisTvalid <= '0';      
   end procedure;
begin
   sAxisTvalid <= '0';
   sAxisTdata <= (others => '0');
   sAxisTkeep <= (others => '0');
   aRst <= '1';
   wait for max(kSclkPeriod, kMClkPeriod)*5;
   aRst <= '1';
   wait for max(kSclkPeriod, kMClkPeriod)*5;
   aRst <= '0';
   wait until Rising_Edge(SAxisClk) and sAxisTready = '1'; --wait for LLP to complete reset
   
   SendPacket(fs_err);
   --switch to low-power state between packets
   wait until Rising_Edge(SAxisClk);
   wait until Rising_Edge(SAxisClk);
   SendPacket(fs);
   wait until Rising_Edge(SAxisClk);
   wait until Rising_Edge(SAxisClk);
   SendPacket(longRAW10_cnt_err);
   wait until Rising_Edge(SAxisClk);
   wait until Rising_Edge(SAxisClk);   
   SendPacket(longRAW10_err);
   wait until Rising_Edge(SAxisClk);
   wait until Rising_Edge(SAxisClk);
   SendPacket(fe);
   wait;
   
end process;

ReadProc: process
begin
   mAxisTready <= '0'; 
   wait until sAxisTvalid = '1' and sAxisTready = '1' and Rising_Edge(SAxisClk); --first write
   mAxisTready <= '1';
   for i in 0 to 8 - 1 loop
      if (i mod kPixPerBeat = 0) then
         wait until Rising_Edge(MAxisClk) and mAxisTready = '1' and mAxisTvalid = '1';
      end if;
      if (i/kPixPerBeat = 0) then
         assert(mAxisTuser="1") report "Tuser not asserted at SOF" severity failure;
      else
         assert(mAxisTuser="0") report "Tuser asserted mid-frame" severity failure;
      end if;
      assert (to_unsigned(i,10)=unsigned(mAxisTdata(((i mod kPixPerBeat)+1)*10-1 downto (i mod kPixPerBeat)*10))) report "Output data does not match input" severity failure;
      if (i/kPixPerBeat = (8-1)/kPixPerBeat) then
         assert(mAxisTlast='1') report "Tlast not asserted at EOL" severity failure;
      else
         assert(mAxisTlast='0') report "Tlast asserted mid-line" severity failure;
      end if;        
   end loop;
end process;

DUT: LLP
   Generic map(
      kMaxLaneCount => 4,
      kLaneCount => 2 --[1,2,4]
   )
   Port map(
      SAxisClk => SAxisClk,
      --Slave AXI-Stream
      sAxisTdata => sAxisTdata,
      sAxisTkeep => sAxisTkeep,
      sAxisTvalid => sAxisTvalid,
      sAxisTready => sAxisTready,
      sAxisTlast => sAxisTlast,
      
      MAxisClk => MAxisClk,
      --Master AXI-Stream
      mAxisTdata => mAxisTdata,
      mAxisTvalid => mAxisTvalid,
      mAxisTready => mAxisTready,
      mAxisTlast => mAxisTlast,
      mAxisTuser => mAxisTuser,
      
      sOverflow => open,
      aRst => aRst
   );

end Behavioral;
