------------------------------------------------------------------------------
--
-- File: AXI_S_to_DPTI_converter.vhd
-- Author: Sergiu Arpadi
-- Original Project: AXI DPTI 
-- Date: 8 June 2016
--
-------------------------------------------------------------------------------
-- (c) 2016 Copyright Digilent Incorporated
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
-- This module reads data from the AXI STREAM interface and sends it to the DPTI 
-- interface. It will require a 32 bit TDATA bus, 4 bit TKEEP, TVALID and TLAST 
-- as inputs and it will output the TREADY signal. It uses the DPTI clock of 60 MHz
-- to perform all the operations and it will use the maximum bandwidth of the DPTI 
-- interface which is 480 mbps as long as valid data is received from the AXI STREAM 
-- interface. In order to achieve this, FOR loops have been used which will generate 
-- combinational logic that allows the simultaneous verification of all of the 4 TKEEP
-- bits received. Along with the DPTI clock, the module also reads the PROG_TXEN 
-- signal and it will generate the PROG_D bus and PROG_WRN signal. In order to control 
-- the module, two AXI Lite registers are used, one for direction/control and one for
-- the lenght of the transfer, which are synchronized in the top module.  
-- The module also uses a reset signal aResetTx which is generated in the top module.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_arith.all;


entity AXI_S_to_DPTI_converter is
   Port ( 
      -- clock, reset and DPTI signals
      pResetnTx : in std_logic;
      PROG_CLK : in std_logic;    
      pTxe : in std_logic;
      pWr : out std_logic;
      pDataOut : out std_logic_vector (7 downto 0);
      
      -- AXI Stream signals
      pOutTready : out std_logic;
      pInTdata : in std_logic_vector (31 downto 0);
      pInTvalid : in std_logic;
      pInTlast : in std_logic;
      pInTkeep : in std_logic_vector (3 downto 0);
      
      -- AXI Lite registers
      pAXI_L_Length : in std_logic_vector (31 downto 0);
      pOvalidLength : in std_logic;
      pAXI_L_Control : in std_logic_vector (31 downto 0);
      pOvalidControl : in std_logic;       
      pTxLengthEmpty : out std_logic
    
   );
end AXI_S_to_DPTI_converter;

architecture Behavioral of AXI_S_to_DPTI_converter is

--------------------------------------------------------------------------------------------------------------------------

signal pTxEnDir : std_logic := '0';
signal pLengthTxCnt : std_logic_vector (22 downto 0) := (others => '0');
signal Index : integer range 0 to 3;
signal pCtlOutTready : std_logic := '0';
signal pCtlWr : std_logic := '1';
signal pTransferInvalidFlag : std_logic := '1';
signal pAuxTdata : std_logic_vector(31 downto 0);
signal pAuxTkeep : std_logic_vector(3 downto 0) := (others => '0');

--------------------------------------------------------------------------------------------------------------------------
 
begin

--------------------------------------------------------------------------------------------------------------------------

pWr <= pCtlWr;
pOutTready <= pCtlOutTready;

--------------------------------------------------------------------------------------------------------------------------

pTxLengthEmpty <= '1' when pLengthTxCnt = 0 else '0';  -- we check to see if we are currently doing a tranfer. this will be a part of the AXI Lite status register  

-- Generating TREADY signal which will request data from the AXI STREAM interface
pCtlOutTready <= '1' when (pAuxTkeep = "0001" or pAuxTkeep = "0010" or pAuxTkeep = "0100" or pAuxTkeep = "1000" or (pAuxTkeep = "0000" )) and pTxe = '0' and pLengthTxCnt > 0 else '0';
-- new data will be requested when we have at most one valid data byte in the current TDATA bus. other conditions are that a transfer must be in progress and the DPTI interface can accept more data

pTransferInvalidFlag <= '1' when pTxe = '1' and  pCtlWr = '0' else '0'; -- detecting if a transfer has failed because the FT_TXE signal from FTDI was '1'

--------------------------------------------------------------------------------------------------------------------------

generate_WR: process (PROG_CLK, pLengthTxCnt, pResetnTx) -- PROG_WRN is generated
begin
if pResetnTx = '0' then
    pCtlWr <= '1';
else if rising_edge (PROG_CLK) then
        if pAuxTkeep /= 0 and pLengthTxCnt > 0 then  -- check if the transfer is not finnished and there is at least one valid data byte
            pCtlWr <= '0'; -- when the signal is 0 then the byte currently on the PROG_D bus is valid  
        else   -- if valid data is not available or the transfer is completed
            pCtlWr <= '1'; -- PROG_WRN is '1'
        end if;  
    end if;   
end if;
end process;

--------------------------------------------------------------------------------------------------------------------------

read_Tkeep_and_Tdata: process (PROG_CLK, pResetnTx)
variable aux_tkindex : integer;
begin
if pResetnTx = '0' then
      aux_tkindex := 0;
      pAuxTkeep  <= (others => '0');
      pAuxTdata <= (others => '0');
else if rising_edge(PROG_CLK)then
      if  pLengthTxCnt > 0 and pTxe = '0' and pTxEnDir = '1' then   -- check to see if a transfer is in progress
         if (pAuxTkeep = 0 or pAuxTkeep = 1 or pAuxTkeep = 2 or pAuxTkeep = 4 or pAuxTkeep = 8)  and pInTvalid = '1' then  -- check if the current set of TDATA and TKEEP contains at most one valid byte of data    
            pAuxTkeep <= pInTkeep; --new tkeep is read 
            pAuxTdata <= pInTdata; --new data is read
            -- TDATA and TKEEP are used in the "generate_pDataOut" process below
         else  -- if more than one valid bytes exist
            for Index in 3 downto 0 loop  -- we use a FOR loop to check all of the bytes simultaneously        
               if pAuxTkeep (Index) = '1'  then -- each valid byte is identified by checking TKEEP
                  aux_tkindex := Index;  
               end if;            
            end loop; 
            pAuxTkeep(aux_tkindex) <= '0'; --reset one bit at a time after sending the corresponding valid byte to the DPTI interface   
         end if;
      end if;
   end if;
end if;
end process;

--------------------------------------------------------------------------------------------------------------------------

generate_pDataOut: process (PROG_CLK, pResetnTx)
begin
if pResetnTx = '0' then
  pDataOut <= (others => '0');
  pLengthTxCnt <= (others=>'0');
else if rising_edge(PROG_CLK) then
      if  pOvalidControl = '1' and pLengthTxCnt = 0 then -- the control bit (and the direction) can only be changed when the module is idle
         pTxEnDir <= pAXI_L_Control(0);   -- Reading control byte from AXI LITE register. Bit (0) sets the transfer's direction.   
      end if;
      if  pOvalidLength = '1' and pTxEnDir = '1' then  -- checking if the module was enabled and if valid value is present in register
         pLengthTxCnt (22 downto 0) <= pAXI_L_Length(22 downto 0);  -- LENGTH register is read            
      end if;
      if  pLengthTxCnt > 0 and pTxe = '0' and pTxEnDir = '1' then  -- conditions for starting transfer
         for Index in 3 downto 0 loop  -- the FOR loop allows us to check all of the bytes simultaneously     
            if pAuxTkeep (Index) = '1'  then -- we identify the valid byte's position 
               pDataOut(7 downto 0) <=  pAuxTdata((8 * (Index + 1)) -1 downto (8 * (Index)));   -- the valid byte is extracted and sent to the DPTI interface
               pLengthTxCnt <= pLengthTxCnt - '1';   -- since one valid byte was transferred, length is decremented
            end if;            
         end loop; 
      end if;
    end if;      
end if;     
end process;

--------------------------------------------------------------------------------------------------------------------------
 
end Behavioral;
