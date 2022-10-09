----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/28/2015 07:22:57 PM
-- Design Name: 
-- Module Name: Sync - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Sync is
   Generic (
      kRstActiveHigh : boolean := true; --'1' if aRst (active-high) is in use, '0' if aRst_n (active_low)
      kResetTo  : std_logic := '0'; --the reset value of oOut when aRst/aRst_n is asserted
      kRegisterInput : boolean := true; --should iIn be re-registered on the InClk domain  
      kStages : natural := 2); --how many synchronizer stages to use
   Port (
      aRst : in STD_LOGIC;
      aRst_n : in STD_LOGIC;
      iIn : in STD_LOGIC;
      InClk :in STD_LOGIC;
      OutClk : in STD_LOGIC;
      oOut : out STD_LOGIC);
end Sync;

architecture Behavioral of Sync is
signal aRst_int, iIn_q : std_logic;

begin
ResetActiveLow: if not kRstActiveHigh generate
   aRst_int <= not aRst_n;
end generate ResetActiveLow;

ResetActiveHigh: if kRstActiveHigh generate
   aRst_int <= aRst;
end generate ResetActiveHigh;

ReRegister: if kRegisterInput generate
   --By re-registering iIn on its own domain, we make sure iIn_q is glitch-free
   SyncSource: process(aRst_int, InClk)
   begin
      if (aRst_int = '1') then
         iIn_q <= kResetTo;
      elsif Rising_Edge(InClk) then
         iIn_q <= iIn;
      end if;
   end process SyncSource;
end generate ReRegister;

DontRegister: if not kRegisterInput generate
   iIn_q <= iIn;
end generate DontRegister;

--Crossing clock boundary here 
SyncAsyncx: entity work.SyncAsync
   generic map (
      kResetTo => kResetTo,
      kStages => kStages)
   port map (
      aReset => aRst_int,
      aIn => iIn_q,
      OutClk => OutClk,
      oOut => oOut);


end Behavioral;
