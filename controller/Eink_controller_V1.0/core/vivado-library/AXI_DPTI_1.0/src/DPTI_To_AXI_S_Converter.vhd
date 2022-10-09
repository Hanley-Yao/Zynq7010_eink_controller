------------------------------------------------------------------------------
--
-- File: DPTI_to_AXI_S_converter.vhd
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
-- This module reads data from the DPTI interface and converts it so that it is 
-- compatible with the AXI STREAM interface.  Along with 32 bit TDATA, it also generates 
-- the 4 bit TKEEP, TVALID and TLAST, using TREADY as an input. On the DPTI side, 
-- it uses the interface clock PROG_CLK, it reads data from pDataIn and uses pRxf 
-- to identify valid data and it generates the output enable pOe signal and pRd which 
-- requests more data. All these ports will be connected to the DPTI ports in the top. 
-- The pDataIn bus will also pass through an IOBUF controlled by pOe. The converter works 
-- by reading a data byte fron the DPTI,  it then determines if the data is valid, 
-- and if it is, it then uses it to create the TDATA bus and the TKEEP bus. The module 
-- will wait until it has 4 valid bytes in order to avoid sending incomplete transfers, 
-- except for the last transfer  which can be incomplete due to the nature of the length
-- which is requested (if the number is not divisible by 4). When a transfer is prepared, 
-- the TVALID signal is generated which acomplishes the actual transfer along with the 
-- TLAST signal  when the transfer is the last one. During this time, it monitors the 
-- TREADY signal as well as pRxf signal coming from the DPTI interface.  In order to 
-- control the module, two AXI Lite registers are used, one for direction/control and 
-- one for the lenght of the transfer, which are synchronized in the top module. 
-- The module also uses a reset signal aResetRx which is generated in the top module.

-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_arith.all;


entity DPTI_to_AXI_S_converter is
   Port ( 
      -- clock, reset and DPTI signals
      pResetnRx : in std_logic;
      PROG_CLK : in std_logic;    
      pRxf : in std_logic;    
      pRd : out std_logic;        
      pOe : out std_logic;        
      pDataIn : in std_logic_vector (7 downto 0);
      
      -- AXI Stream signals
      pInTready : in std_logic;
      pOutTdata : out std_logic_vector (31 downto 0);
      pOutTvalid : out std_logic;
      pOutTlast : out std_logic;
      pOutTkeep : out std_logic_vector (3 downto 0);
      
      -- AXI Lite registers
      pAXI_L_Length : in std_logic_vector (31 downto 0);
      pOvalidLength : in std_logic;
      pAXI_L_Control : in std_logic_vector (31 downto 0);
      pOvalidControl : in std_logic;     
      pRxLengthEmpty : out std_logic
   
   );
            
end DPTI_to_AXI_S_converter;

architecture Behavioral of DPTI_to_AXI_S_converter is

--------------------------------------------------------------------------------------------------------------------------

signal Index: integer range 0 to 3;
signal pCountSentBytes : std_logic_vector (1 downto 0);       
signal pCountBytesIncrFlag : std_logic := '1';
signal pRxEnDir : std_logic := '0';
signal pLengthRxCnt : std_logic_vector (23 downto 0); 
signal pCtlRd : std_logic := '1';
signal pCtlOutTvalid : std_logic := '0';
signal pCtlOutTlast : std_logic := '0';
signal pLengthRxCntDepletedFlag : std_logic := '0';
signal pAuxLengthRxDecrFlag : std_logic := '0';
signal pLastTransferFlag : std_logic := '0'; 
signal pRxfDelay : std_logic := '1';
 
--------------------------------------------------------------------------------------------------------------------------

begin

--------------------------------------------------------------------------------------------------------------------------

pOutTlast <= pCtlOutTlast;
pOutTvalid <= pCtlOutTvalid;

pOe <= not pRxEnDir ;
pRd <= pCtlRd;

pCtlOutTvalid <= '1' when pCountSentBytes = 0 and pCountBytesIncrFlag = '0' else '0';   -- TVALID signal is generated       
-- pCountSentBytes = 0 - allows TVALID to be '1' only after 4 valid data bytes have been processed
-- pCountBytesIncrFlag = '0' - This signal will ensure that the TVALID signal is high for only one Clock period. It checks if the current byte is valid or not. The counter will only increment when the data byte is valid. 

pCtlOutTlast <= '1' when pCountSentBytes = 0 and pCountBytesIncrFlag = '0' and pLengthRxCnt < 4 else '0';   -- TLAST signal is generated
-- TLAST is very similar to TVALID however it must only be asserted at the end of the last AXI STREAM transfer. In order to accomplish this, pLengthRxCnt must be less than 4 (no more than 4 bytes left to transfer) so that only one more STREAM transfer is needed.   

pCtlRd <= '0' when pLastTransferFlag = '0' and pInTready = '1' and pRxfDelay = '0' else '1';  -- PROG_RDN is generated
-- the signal must be 0 only when TREADY (input) is '1' since that means that the STREAM interface is ready for at least one extra set of data since the date currently being read will be transfered in the next AXI STREAM transfer
-- pLastTransferFlag indicatges that only one more transfer will be required. Once this signal is '1' this indicates that there is no more data required for the dpti to stream transfer
-- pRxfDelay will mirror the PROG_RXEN signal received from the DPTI interface. when the FTDI empties its internal FIFO, it will drive PROG_RXEN high and even if the FPGA can still receive data, PROG_RDN must be driven high, otherwise the FTDI will provide the wrong data when PROG_RXEN becomes '0'

pLastTransferFlag <= '1' when pLengthRxCnt < 4 else '0';  -- This signal will indicate when the module has reached the last AXI Stream transfer. If there are less than 4 bytes left to be transfered
-- this signal is used to determine when there is only one STREAM transfer left

pRxLengthEmpty <= '1' when pLengthRxCnt = 0 else '0';  -- this signal (used by driver) will indicate the status of the module. when high, the module is ready to do another transfer

--------------------------------------------------------------------------------------------------------------------------

generate_pRxfDelay: process(PROG_CLK) -- the signal pRxfDelay will be identical to PROG_RXEN delayed by one clock period which will then become the PROG_RDN signal.
begin
if rising_edge (PROG_CLK) then
    if pRxf = '1' then 
        pRxfDelay <= '1';
    else
        pRxfDelay <= '0';
    end if;
end if;
end process;

--------------------------------------------------------------------------------------------------------------------------

generate_pCountSentBytes: process (PROG_CLK, pResetnRx) -- this counter will increment when a valid byte was read from the DPTI interface and processed 
begin
if pResetnRx = '0'   then
   pCountSentBytes <= (others => '0');
   pCountBytesIncrFlag <= '1';
elsif rising_edge(PROG_CLK)  then
   if  pLengthRxCnt > 0 and ((pRxf = '0' and pRxfDelay = '0') or pLastTransferFlag = '1') and pInTready = '1' then -- check if a transfer is in progress and all the conditions are in place to read and process a byte
      pCountSentBytes <= pCountSentBytes + '1';   -- the counter is incremented
      pCountBytesIncrFlag <= '0'; -- the flag which indicates a change in the counter's value
   elsif pLengthRxCnt = 0 then  -- if a transfer was completed
      pCountSentBytes <= (others => '0');   -- counter is reset        
      pCountBytesIncrFlag <= '1';   -- flag is set     
   else 
      pCountSentBytes <= pCountSentBytes; -- when a transfer is in progress and conditions for a valid byte to be processed are not met
      pCountBytesIncrFlag <= '1';   -- flag is set      
   end if;
end if;
end process;

--------------------------------------------------------------------------------------------------------------------------

generate_Index: process (PROG_CLK, pResetnRx)  -- the Index integer is used for positioning the individual bytes in the 4 byte TDATA register
begin

if pResetnRx = '0'  then
    Index <= 0;
elsif rising_edge(PROG_CLK)  then
    if  pLengthRxCnt > 0 and pRxf = '0' and pRxfDelay = '0' and pInTready = '1' then  -- in order to increment Index, the data provided must be valid and the receivind FIFO must not be full
        if Index < 3 then  -- index will have values between 0 and 3
            Index <= Index + 1;  -- when conditions are met, index is incremented
        else
            Index <= 0;
        end if;
    elsif  pLengthRxCnt = 0 then   -- when a transfer is completed, Index becomes 0
        Index <= 0;
    else
        Index <= Index;
    end if;
end if;
end process;

--------------------------------------------------------------------------------------------------------------------------

generate_pOutTdata: process (PROG_CLK, pResetnRx, Index, pLengthRxCnt) is  -- TDATA is generated from data received from the DPTI interface
begin
if (pResetnRx = '0') then
   pOutTdata <= (others => '0');
elsif rising_edge(PROG_CLK) then 
   if pLengthRxCnt > 3 and pRxEnDir = '1' and pRxf = '0' and pRxfDelay = '0' and pInTready = '1'  then  -- conditions for data to be considered valid
      pOutTdata(( 8 * (Index + 1)) - 1 downto ( 8 * (Index))) <= pDataIn(7 downto 0); -- TDATA bus is being built. the new byte's position is determined by the value of Index
   end if;
end if;
end process;

--------------------------------------------------------------------------------------------------------------------------

gen_pOutTkeep_read_AXI_Lite_registers: process (PROG_CLK, pResetnRx, Index, pLengthRxCnt) is  -- reading the AXI Lite registers, controlling the main counters, generating TKEEP
begin
if (pResetnRx = '0') then
   pLengthRxCnt <= (others => '0');
elsif rising_edge(PROG_CLK) then 
   if pOvalidControl = '1' and pLengthRxCnt = 0 then -- the control bit (and the direction) can only be changed when the module is idle
      pRxEnDir <= pAXI_L_Control (1);  -- Reading control byte from AXI LITE register. Bit (1) sets the transfer's direction.   
   end if;   
   if pOvalidLength = '1' and pRxEnDir = '1' then  -- checking if the module was enabled and if valid value is present in the LENGTH register
      pLengthRxCnt (23 downto 0) <= pAXI_L_Length(23 downto 0) + "11"; -- The counter will be the requested transfer length + 3 so that after all of the valid bytes are received and processed, there will be 3 more clock periods where it will decrement which will allow us to generate the signals required to send the last STREAM transfer, especially TLAST.      
   end if;   
   if pLengthRxCnt > 0 and (pLastTransferFlag = '1' or (pRxf = '0' and pRxfDelay = '0' and pInTready = '1')) then  -- here the module checks if the byte received is valid or if we are going to send the last STREAM package 
      pLengthRxCnt <= pLengthRxCnt - '1'; -- the counter is decremented.
   end if;
   if pLengthRxCnt > 3 and pRxf = '0' and pRxfDelay = '0' and pInTready = '1'  then   -- check when a valid byte has been read from the DPTI interface
         pOutTkeep (Index) <= '1';   -- the TKEEP bit of the byte sent to AXI STREAM in the "generate_pOutTdata" process is set
   else
         pOutTkeep (Index) <= '0';   -- if the byte is not valid, the bit will be '0'
   end if;
end if;
end process;

--------------------------------------------------------------------------------------------------------------------------

end Behavioral;
