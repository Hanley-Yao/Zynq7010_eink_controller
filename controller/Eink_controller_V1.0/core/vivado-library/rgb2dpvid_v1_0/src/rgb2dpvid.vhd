-------------------------------------------------------------------------------
--
-- File: rgb2dpvid.vhd
-- Author: Mihaita Nagy
-- Original Project: RGB to Displayport Video
-- Date: 12 November 2014
--
-------------------------------------------------------------------------------
-- (c) 2014 Copyright Digilent Incorporated
-- All Rights Reserved
-- 
-- This program is free software; distributed under the terms of BSD 3-clause 
-- license ("Revised BSD License", "New BSD License", or "Modified BSD License")
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
--    of its contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
--
-- Purpose:
--  Converts a kDataWidth-bit RGB interface (VGA compatible) given as input to a 
--  Displayport Video interface
--
-------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;

entity rgb2dpvid is
   generic(
      -- Width of the input data bus
      kDataWidth  : integer := 24
   );
   port(
      -- RGB interface
      PixelClk    : in  std_logic;
      pData       : in  std_logic_vector((kDataWidth-1) downto 0);
      pHSync      : in  std_logic;
      pVSync      : in  std_logic;
      pVde        : in  std_logic;
      
      -- Displayport Video interface
      pVidClk     : out std_logic;
      pVidPixel0  : out std_logic_vector(47 downto 0);
      pVidHSync   : out std_logic;
      pVidVSync   : out std_logic;
      pVidOddEven : out std_logic;
      pVidRst     : out std_logic;
      pVidEnable  : out std_logic
   );
end rgb2dpvid;

architecture rtl of rgb2dpvid is

begin

   -- Video clock the same as the pixel clock
   pVidClk     <= PixelClk;
   
   -- Odd/Even qualifier not used
   pVidOddEven <= '0';
   
   -- Also reset is not used
   pVidRst     <= '0';
   
   -- Synchronous process to distribute the video data
   SyncIns: process(PixelClk)
   begin
      if rising_edge(PixelClk) then
         pVidHSync <= pHSync;
         pVidVSync <= pVSync;
         pVidEnable <= pVde;
         -- Red component
         pVidPixel0(47 downto 47-((kDataWidth/3)-1)) <= pData((kDataWidth-1) downto (kDataWidth-kDataWidth/3));
         pVidPixel0(39 downto 32) <= (others => '0');
         -- Green component
         pVidPixel0(31 downto 31-((kDataWidth/3)-1)) <= pData(((kDataWidth-2*kDataWidth/3)-1) downto 0);
         pVidPixel0(23 downto 16) <= (others => '0');
         -- Blue component
         pVidPixel0(15 downto 15-((kDataWidth/3)-1)) <= pData(((kDataWidth-kDataWidth/3)-1) downto (kDataWidth-2*kDataWidth/3));
         pVidPixel0(7 downto 0) <= (others => '0');
      end if;
   end process SyncIns;

end rtl;
