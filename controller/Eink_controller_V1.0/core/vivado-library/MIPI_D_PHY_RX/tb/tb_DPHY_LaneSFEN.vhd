----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2016 05:12:32 PM
-- Design Name: 
-- Module Name: tb_DPHY_LaneSFEN - Behavioral
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
use ieee.math_real.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

library STD;
use STD.textio.all;                     -- basic I/O

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_DPHY_LaneSFEN is
--  Port ( );
end tb_DPHY_LaneSFEN;

architecture Behavioral of tb_DPHY_LaneSFEN is

component DPHY_LaneSFEN is
   Generic (
      kCtlClkFreqHz : natural := 100_000_000
   );
   Port (
      aLP : in STD_LOGIC_VECTOR (1 downto 0);
      aHS : in STD_LOGIC;
      CtlClk : in STD_LOGIC;
      
      SerClkHS : in STD_LOGIC;
      DivClk : in STD_LOGIC;
   
      RxByteClkHS : out std_logic;      
      rbRxDataHS : out std_logic_vector(7 downto 0);
      rbRxValidHS : out std_logic;
      rbRxActiveHS : out std_logic;
      rbRxSyncHS : out std_logic;
      rbErrSotHS : out std_logic;
      rbErrSotSyncHS : out std_logic;
   
      
      aEnable : in std_logic; --Enable Lane Module. DivClk&SerClkHS must be stable
      aForceRxmode : in std_logic; --Force Lane Module Into Receive mode / Wait for Stop state 
      aStopstate : out std_logic --Lane is in Stop state.

   );
end component DPHY_LaneSFEN;
function max(l : time; r : time) return time is
begin
   if (l > r) then
      return l;
   else
      return r;
   end if;
end function max;

constant kSerClkPeriod : time := 2 ns;
constant kCtlClkPeriod : time := 10 ns;
constant kUI : time := kSerClkPeriod / 2;
constant kT_LPX : time := 50 ns;
constant kT_HS_PREPARE : time := 40 ns + 4*kUI;
constant kT_HS_ZERO : time := 100 ns + 6*kUI;
constant kT_HS_TRAIL : time := max(1*8*kUI, 60 ns + 1*4*kUI);
constant kT_HS_EXIT : time := 100 ns;
constant kTInit      : time := 100 us;
constant kSyncSeq : std_logic_vector(7 downto 0) := "10111000"; --least significant bit

signal SerClkHS, DivClkHS, CtlClk, cHSClkLocked : std_logic := '1';
signal HS : std_logic;
signal LP : std_logic_vector(1 downto 0);
signal rbRxDataHS : std_logic_vector(7 downto 0);
signal rbRxValidHS, rbRxActiveHS, rbRxSyncHS, rbErrSotHS, rbErrSotSyncHS, aDataStopstate : std_logic;
signal RxByteClkHS : std_logic;
begin

DUT: DPHY_LaneSFEN
   Port map (
      aLP => LP,
      aHS => HS,
      CtlClk => CtlClk,
      
      SerClkHS => SerClkHS,
      DivClk => DivClkHS,

      --PPI
      RxByteClkHS =>  RxByteClkHS,  
      rbRxDataHS => rbRxDataHS,
      rbRxValidHS => rbRxValidHS,
      rbRxActiveHS => rbRxActiveHS,
      rbRxSyncHS => rbRxSyncHS,
      rbErrSotHS => rbErrSotHS,
      rbErrSotSyncHS => rbErrSotSyncHS,      

      aEnable => '1',
      aStopstate => aDataStopstate,
      aForceRxmode => '0'
   );

--Clocks
SerClkHS <= not SerClkHS after kSerClkPeriod / 2;
DivClkHS <= not DivClkHS after kSerClkPeriod / 2 * 4;
CtlClk <= not CtlClk after kCtlClkPeriod / 2;

Stimulus: process
   procedure Stopstate(dur : in time) is
   begin
      LP <= "11";
      HS <= 'X';
      wait for dur;
   end procedure;
   procedure HS_Rqst is
   begin
      LP <= "01";
      wait for kT_LPX;
   end procedure;
   procedure HS_Prepare is
   begin
      LP <= "00";
      wait for kT_HS_PREPARE;
   end procedure;
   procedure HS_Zero is
   begin
      HS <= '0';
      wait for kT_HS_ZERO;
   end procedure;
   procedure HS_Send0(nbits : in natural) is
   begin
      for i in 0 to nbits-1 loop
         HS <= '0';
         wait until SerClkHS'event;
      end loop;
   end procedure;
   procedure HS_Send(byte : in std_logic_vector(7 downto 0)) is
   begin
      for i in 0 to 7 loop
         wait for kUI / 2; --90deg phase difference between data and clock
         HS <= byte(i);
         wait until SerClkHS'event;
      end loop;   
   end procedure;
   procedure HS_Trail is
   begin
      wait for kUI / 2;
      HS <= not HS;
      wait for kT_HS_TRAIL;
   end procedure;

   variable seed1, seed2: positive;               -- seed values for random generator
   variable rand: real;   -- random real-number value in range 0 to 1.0  
   variable range_of_rand : real := 10.0;    -- the range of random values created will be 0 to +1000.
   variable to_send : natural;
begin

Stopstate(kTInit + 1 us);

for i in 0 to 7 loop
   HS_Rqst;
   HS_Prepare;
   wait for kUI; -- this will test different word alignments
   HS_Zero;
   wait until Falling_Edge(SerClkHS);
   HS_Send(kSyncSeq);
   uniform(seed1, seed2, rand);   -- generate random number
   for j in 0 to integer(rand*range_of_rand) loop
      case (j) is
         when 0 => HS_Send(x"DE");
         when 1 => HS_Send(x"AD");
         when 2 => HS_Send(x"BE");
         when 3 => HS_Send(x"EF");
         when others => HS_Send(std_logic_vector(to_unsigned(j-4,8)));
      end case;
   end loop;
   HS_Trail;
   Stopstate(kT_HS_EXIT);
end loop;

wait;

end process Stimulus;

Verification: process (LP, RxByteClkHS)
variable cnt_hs : natural := 0;
variable cnt_byte : natural := 0;
variable bit_last : std_logic := '1';
variable f_err_hold, f_err_temp, f_intrail : boolean := true;
impure function check_data(data : std_logic_vector(7 downto 0); i : natural) return boolean is
begin
   if (not f_intrail) then
      if (data =  (not bit_last) & (not bit_last) & (not bit_last) & (not bit_last) &
                  (not bit_last) & (not bit_last) & (not bit_last) & (not bit_last)) then
         f_intrail := true;
      else
         bit_last := data(7); --least-significant first
      end if;
   else
      if (data /=  (not bit_last) & (not bit_last) & (not bit_last) & (not bit_last) &
                  (not bit_last) & (not bit_last) & (not bit_last) & (not bit_last)) then
         f_intrail := false;
         bit_last := data(7); --least-significant first  
      end if;       
   end if;
   
   case (i) is
      when 0 =>      f_err_temp := (data = x"DE");
      when 1 =>      f_err_temp := (data = x"AD");
      when 2 =>      f_err_temp := (data = x"BE");
      when 3 =>      f_err_temp := (data = x"EF");
      when others => f_err_temp := (data = std_logic_vector(to_unsigned(i-4, 8)));
   end case;
   -- Keep the error in mind for later, we might not be in trail after all
   if (f_intrail) then
      f_err_hold := f_err_hold and f_err_temp;
      return true;
   else
      return f_err_hold and f_err_temp;
   end if;
   
end check_data;
variable my_line : line;  -- type 'line' comes from textio
begin
   if LP'event and LP = "00" then
      cnt_hs := cnt_hs + 1;
      cnt_byte := 0;
      f_intrail := false;
      f_err_hold := true;
      bit_last := '1'; --sync sequence last bit
   end if;
   
   if LP = "00" and Rising_Edge(RxByteClkHS) then
      if rbRxValidHS = '1' then
         if not check_data(rbRxDataHS, cnt_byte) then
            write(my_line, string'("Error at byte "));
            write(my_line, cnt_byte);
            write(my_line, string'(", data: "));
            hwrite(my_line, rbRxDataHS);
            write(my_line, string'(", time: "));
            write(my_line, now);
            writeline(output, my_line);
         end if;
         cnt_byte := cnt_byte + 1;
      end if;
   end if;
end process;

end Behavioral;
