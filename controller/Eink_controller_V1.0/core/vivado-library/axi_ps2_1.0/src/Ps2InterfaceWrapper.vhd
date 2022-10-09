------------------------------------------------------------------------------
--
-- File: Ps2InterfaceWrapper.vhd
-- Author: Sergiu Arpadi
-- Original Project: AXI PS2 
-- Date: 10 October 2017
--
-------------------------------------------------------------------------------
--Copyright (c) 2017 Digilent
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
-------------------------------------------------------------------------------
--
-- Purpose:
--This module is a wrapper for the PS/2 module used to faciliate the addition
--of the TX and RX FIFOs. It also contains some additional logic strictly related
--to these entities.
-- 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Ps2InterfaceWrapper is

   Port ( 
   PS2_Data_I : in std_logic;
   PS2_Data_O : out std_logic;
   PS2_Data_T : out std_logic;
   PS2_Clk_I : in std_logic;
   PS2_Clk_O : out std_logic;
   PS2_Clk_T : out std_logic;
   
   clk : in std_logic;
   rst : in std_logic;
   lSrst : in std_logic;
   lTxDataReg : in std_logic_vector (31 downto 0);  
   lTxTrig : in std_logic;
   
   lRxDataReg : out std_logic_vector (31 downto 0);
   lRxAck : in std_logic;
       
   -- ISR signals
   IsrBitTxNoAck : out std_logic;
   IsrBitTxAck : out std_logic;
   IsrBitRxOvf : out std_logic;
   IsrBitRxErr : out std_logic;
   IsrBitRxFull : out std_logic;

   -- Status register
   lStatusReg : out std_logic_vector (31 downto 0) 
   );

end Ps2InterfaceWrapper;

architecture Behavioral of Ps2InterfaceWrapper is

------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------

signal lRxDataBuf : std_logic_vector(7 downto 0);
signal lTxBufFlag : std_logic := '0';
signal lBusy : std_logic;
signal lErrNack : std_logic;
signal lErrPar : std_logic;
signal lAck : std_logic;
signal lReset : std_logic := '0';
signal lWrite : std_logic := '0'; 
signal lRead : std_logic := '0';

--TX FIFO signals
signal TxDin   : std_logic_vector (7 downto 0); 
signal TxWrEn  : std_logic := '0';
signal TxRdEn  : std_logic := '0';
signal TxDout  : std_logic_vector (7 downto 0); 
signal TxFull  : std_logic; 
signal TxEmpty : std_logic; 

--RX FIFO signals
signal RxDin   : std_logic_vector (7 downto 0); 
signal RxWrEn  : std_logic := '0';  
signal RxRdEn  : std_logic := '0';   
signal RxDout  : std_logic_vector (7 downto 0); 
signal RxFull  : std_logic;  
signal RxEmpty : std_logic;

COMPONENT fifo_generator_0
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;

--------------------------------------------------------------------------------
begin
--------------------------------------------------------------------------------

-- AXI Lite Status register signal assignment
lStatusReg (0) <= TxFull;
lStatusReg (1) <= TxEmpty;
lStatusReg (2) <= RxFull;
lStatusReg (3) <= RxEmpty;
lStatusReg (31 downto 4) <= (others => '0'); -- bits that are not used are always 0

-- ISR interrupts constructed
IsrBitRxOvf <= lRead and RxFull;
IsrBitTxAck <= lAck;
IsrBitTxNoack <= lErrNack;
IsrBitRxErr <= lErrPar;
IsrBitRxFull <= not RxEmpty;
 
lReset <= (not rst) or lSrst; --not used 

--------------------------------------------------------------------------------
--FIFOs
--------------------------------------------------------------------------------

-- AXI Lite data registers
TxDin <= lTxDataReg (7 downto 0);
lRxDataReg (7 downto 0) <= RxDout;
TxWrEn <= lTxTrig; --write enable connected to AXI Lite logic. Writes new TX data to TX FIFO
RxWrEn <= lRead; --write enable connected to AXI Lite logic. Writes new RX data to RX FIFO 
RxRdEn <= lRxAck; --reads data out of RX FIFO and passes it to RX Data register
 
--------------------------------------------------------------------------------

Ps2Interface: entity work.Ps2Interface
   port map (
      PS2_Data_I => PS2_Data_I,
      PS2_Data_O => PS2_Data_O,
      PS2_Data_T => PS2_Data_T,
      PS2_Clk_I => PS2_Clk_I,
      PS2_Clk_O => PS2_Clk_O,
      PS2_Clk_T => PS2_Clk_T,
      clk => clk,
      rst => lReset,
      tx_data => TxDout,   
      write_data => lWrite,
      rx_data => RxDin,
      read_data => lRead,
      ack => lAck,
      busy => lBusy,
      err_par => lErrPar,
      err_nack => lErrNack
      );

--------------------------------------------------------------------------------

TxFIFO: fifo_generator_0
   PORT MAP (
      clk   => clk,
      srst  => lReset,
      din   => TxDin,
      wr_en => TxWrEn,
      rd_en => TxRdEn,
      dout  => TxDout,
      full  => TxFull,
      empty => TxEmpty
   );
   
--------------------------------------------------------------------------------
  
RxFIFO: fifo_generator_0
   PORT MAP (
      clk   => clk,
      srst  => lReset,
      din   => RxDin,
      wr_en => RxWrEn,
      rd_en => RxRdEn,
      dout  => RxDout,
      full  => RxFull,
      empty => RxEmpty
   );

--------------------------------------------------------------------------------
--this process passes he next TX data byte from the TX FIFO to the PS/2 logic when 
--data is available in the FIFO and the PS/2 core is not busy    
OS_LWRITE_TXRDEN: process (clk)
variable count : integer range 0 to 1;
begin
if rising_edge (clk) then
   if TxEmpty = '1' or lBusy = '1'  then 
      count := 1;  
      lWrite <= '0';
      TxRdEn <= '0';
   elsif count = 1 then
      lWrite <= '1';
      TxRdEn <= '1';
   else   
      count := 0; 
      lWrite <= '0'; 
      TxRdEn <= '0';
   end if;
end if;
end process;

end Behavioral;