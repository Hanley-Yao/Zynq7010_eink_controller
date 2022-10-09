----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/27/2017 03:44:54 PM
-- Design Name: 
-- Module Name: tb_ECC - Behavioral
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
use STD.textio.all;  

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_ECC is
--  Port ( );
end tb_ECC;

architecture Behavioral of tb_ECC is
   component ECC is
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
   end component;
   
   constant kClkPeriod : time := 10ns;
   type stimulus_t is array (natural range <>) of std_logic_vector(31 downto 0);
   constant kStimulus : stimulus_t := (x"3F01F037", x"3F01F037");
   signal StreamClk, sRst, sCE, sReady, sValid, sError : std_logic := '0';
   signal sHeaderIn, sHeaderOut : std_logic_vector(31 downto 0);
begin

StreamClk <= not StreamClk after kClkPeriod / 2;

process
variable temp : std_logic_vector(31 downto 0);
begin
   sRst <= '1';
   wait for 5*kClkPeriod;
   
   sCE <= '0';
   sRst <= '0';
   wait until Rising_Edge(StreamClk);
   
   for i in kStimulus'range loop
      wait until Rising_Edge(StreamClk);
      -- unmodified stimulus
      assert (sReady = '1') report "DUT ECC is not ready when it should be" severity failure;
      sCE <= '1';
      sHeaderIn <= kStimulus(i);
      wait until Rising_Edge(StreamClk);
      sCE <= '0';
      wait until Rising_Edge(StreamClk);
      wait until Rising_Edge(StreamClk);
      wait until Rising_Edge(StreamClk);
      assert (sValid = '1' and sError = '0' and sHeaderOut = sHeaderIn) report "ECC error where there should not be one" severity failure;
      
      for iBit in 29 downto 0 loop -- Bits 31 and 30 (7 and 6 of ECC) are always 0
         wait until Rising_Edge(StreamClk);
         -- modified stimulus (one bit flipped)
         assert (sReady = '1') report "DUT ECC is not ready when it should be" severity failure;
         sCE <= '1';
         temp := kStimulus(i);
         temp(iBit) := not temp(iBit);
         sHeaderIn <= temp;
         wait until Rising_Edge(StreamClk);
         sCE <= '0';
         wait until Rising_Edge(StreamClk);
         wait until Rising_Edge(StreamClk);
         wait until Rising_Edge(StreamClk);
         assert (sValid = '1' and sError = '1' and sHeaderOut = kStimulus(i)) report "ECC one-bit error was not fixed" severity failure;
      end loop;
      
      for iBit in 29 downto 0 loop
         for iBit2 in 29 downto 0 loop
            if (iBit /= iBit2) then
               wait until Rising_Edge(StreamClk);
               -- modified stimulus (one bit flipped)
               assert (sReady = '1') report "DUT ECC is not ready when it should be" severity failure;
               sCE <= '1';
               temp := kStimulus(i);
               temp(iBit) := not temp(iBit);
               temp(iBit2) := not temp(iBit2);
               sHeaderIn <= temp;
               wait until Rising_Edge(StreamClk);
               sCE <= '0';
               wait until Rising_Edge(StreamClk);
               wait until Rising_Edge(StreamClk);
               wait until Rising_Edge(StreamClk);
               assert (sValid = '0' and sError = '1') report "ECC two-bit error was not detected" severity failure;
            end if;
         end loop;
      end loop;
      
   end loop;
   wait;
end process;

DUT: ECC 
   Port map (
      StreamClk => StreamClk,
      sHeaderIn => sHeaderIn,
      sCE => sCE,
      sReady => sReady,
      sHeaderOut => sHeaderOut,
      sValid => sValid,
      sError => sError,
      
      sRst => sRst
   );
end Behavioral;
