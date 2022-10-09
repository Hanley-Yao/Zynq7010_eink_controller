----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2017 12:11:15 PM
-- Design Name: 
-- Module Name: mypkg - Behavioral
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

package mypkg is
   function max (a,b : integer) return integer;
   function max (a,b : time) return time;
end mypkg;

package body mypkg is
   function max (a,b : integer) return integer is
   begin
      if (a > b) then
         return a;
      else
         return b;
      end if;
   end function max;
   function max (a,b : time) return time is
   begin
      if (a > b) then
         return a;
      else
         return b;
      end if;
   end function max;
end mypkg;
