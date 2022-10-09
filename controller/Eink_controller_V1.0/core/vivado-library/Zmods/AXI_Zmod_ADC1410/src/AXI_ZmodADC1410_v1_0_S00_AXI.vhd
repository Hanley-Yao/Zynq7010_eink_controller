
-------------------------------------------------------------------------------
--
-- File: AXI_ZmodADC1410_v1_0_S00_AXI.vhd
-- Author: Tudor Gherman
-- Original Project: Zmod ADC 1410 AXI Adapter
-- Date: 15 January 2020
--
-------------------------------------------------------------------------------
-- (c) 2020 Copyright Digilent Incorporated
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
--This module manages the AXI Lite interface, implements the control and
--status registers and manages the registers' access policies. 
--  
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXI_ZmodADC1410_v1_0_S00_AXI is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		kAxiLiteDataWidth	: integer	:= 32;
		-- Width of S_AXI address bus
		kAxiLiteAddrWidth	: integer	:= 7
	);
	port (
	    lRegRstPulse : in std_logic;
	    --AXI LITE interface
		-- Global Clock Signal
		AxiLiteClk	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		lAxiAreset_n	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		lAxiAwaddr	: in std_logic_vector(kAxiLiteAddrWidth-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		lAxiAwprot	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		lAxiAwvalid	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		lAxiAwready	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		lAxiWdata	: in std_logic_vector(kAxiLiteDataWidth-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		lAxiWstrb	: in std_logic_vector((kAxiLiteDataWidth/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		lAxiWvalid	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		lAxiWready	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		lAxiBresp	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		lAxiBvalid	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		lAxiBready	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		lAxiAraddr	: in std_logic_vector(kAxiLiteAddrWidth-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		lAxiArprot	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		lAxiArvalid	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		lAxiArready	: out std_logic;
		-- Read data (issued by slave)
		lAxiRdata	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		lAxiRresp	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		lAxiRvalid	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		lAxiRready	: in std_logic;
		--IP read register interface (register file to IP access)
        lReg0Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg1Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg2Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg3Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg4Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg5Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg6Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg7Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg8Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);   
        lReg9Rd	    : out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg10Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg11Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg12Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg13Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg14Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg15Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);
        lReg16Rd	: out std_logic_vector(kAxiLiteDataWidth-1 downto 0);  
        --IP write register interface (IP to AXI register file access)
        lAdcSPI_Idle      : in std_logic;
        sInitDone_n       : in std_logic;
        lBufferFull       : in std_logic;
        lSetStop          : in std_logic; 
        lSPI_CmdRxDone    : in std_logic;
        lSPI_CmdTxDone    : in std_logic;
        lSPI_CmdTxCount   : in std_logic_vector(6 downto 0);
        lSPI_CmdRxCount   : in std_logic_vector(6 downto 0);
        lSPI_TxFifoWrEn   : out std_logic;
        lSPI_RxFifoRdEn   : out std_logic;
        lSPI_CmdRx        : in std_logic_vector(7 downto 0);
        lSPI_CmdTxRxError : in std_logic_vector(3 downto 0)
	);
end AXI_ZmodADC1410_v1_0_S00_AXI;

architecture arch_imp of AXI_ZmodADC1410_v1_0_S00_AXI is

	-- AXI4LITE signals
	signal lAxiAwaddrLoc	: std_logic_vector(kAxiLiteAddrWidth-1 downto 0);
	signal lAxiAwreadyLoc	: std_logic;
	signal lAxiWreadyLoc	: std_logic;
	signal lAxiBrespLoc	    : std_logic_vector(1 downto 0);
	signal lAxiBvalidLoc	: std_logic;
	signal lAxiAraddrLoc	: std_logic_vector(kAxiLiteAddrWidth-1 downto 0);
	signal lAxiArreadyLoc	: std_logic;
	signal lAxiRdataLoc	    : std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lAxiRrespLoc   	: std_logic_vector(1 downto 0);
	signal lAxiRvalidLoc	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit kAxiLiteDataWidth
	-- kAddrLsb is used for addressing 32/64 bit registers/memories
	-- kAddrLsb = 2 for 32 bits (n downto 2)
	-- kAddrLsb = 3 for 64 bits (n downto 3)
	constant kAddrLsb  : integer := (kAxiLiteDataWidth/32)+ 1;
	constant kOptMemAddrBits : integer := 4;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 8
	signal lSlvReg0	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg1	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg2	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg3	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg4	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg5	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg6	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg7	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg8	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg9	: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg10: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg11: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg12: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg13: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg14: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg15: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvReg16: std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lSlvRegRdEn	: std_logic;
	signal lSlvRegWrEn	: std_logic;
	signal lRegDataOut	:std_logic_vector(kAxiLiteDataWidth-1 downto 0);
	signal lByteIndex	: integer;
	signal lAwEn	: std_logic;	
	signal lSlvReg4RdEn : std_logic;
            
begin
	
	lReg0Rd <= lSlvReg0;
	lReg1Rd <= lSlvReg1;
	lReg2Rd <= lSlvReg2;
	lReg3Rd <= lSlvReg3;
    lReg4Rd <= lSlvReg4;
    lReg5Rd <= lSlvReg5;
    lReg6Rd <= lSlvReg6;
    lReg7Rd <= lSlvReg7;
    lReg8Rd <= lSlvReg8;
    lReg9Rd <= lSlvReg9;
	lReg10Rd <= lSlvReg10;
	lReg11Rd <= lSlvReg11;
    lReg12Rd <= lSlvReg12;
    lReg13Rd <= lSlvReg13;
    lReg14Rd <= lSlvReg14;
    lReg15Rd <= lSlvReg15;
    lReg16Rd <= lSlvReg16;

	lAxiAwready	<= lAxiAwreadyLoc;
	lAxiWready	<= lAxiWreadyLoc;
	lAxiBresp	<= lAxiBrespLoc;
	lAxiBvalid	<= lAxiBvalidLoc;
	lAxiArready	<= lAxiArreadyLoc;
	lAxiRdata	<= lAxiRdataLoc;
	lAxiRresp	<= lAxiRrespLoc;
	lAxiRvalid	<= lAxiRvalidLoc;
	-- Implement lAxiAwreadyLoc generation
	-- lAxiAwreadyLoc is asserted for one AxiLiteClk clock cycle when both
	-- lAxiAwvalid and lAxiWvalid are asserted. lAxiAwreadyLoc is
	-- de-asserted when reset is low.

	process (AxiLiteClk)
	begin
	  if rising_edge(AxiLiteClk) then 
	    if lAxiAreset_n = '0' then
	      lAxiAwreadyLoc <= '0';
	      lAwEn <= '1';
	    else
	      if (lAxiAwreadyLoc = '0' and lAxiAwvalid = '1' and lAxiWvalid = '1' and lAwEn = '1') then
	        -- slave is ready to accept write address when
	        -- there is a valid write address and write data
	        -- on the write address and data bus. This design 
	        -- expects no outstanding transactions. 
	        lAxiAwreadyLoc <= '1';
	        elsif (lAxiBready = '1' and lAxiBvalidLoc = '1') then
	            lAwEn <= '1';
	        	lAxiAwreadyLoc <= '0';
	      else
	        lAxiAwreadyLoc <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	-- Implement lAxiAwaddrLoc latching
	-- This process is used to latch the address when both 
	-- lAxiAwvalid and lAxiWvalid are valid. 

	process (AxiLiteClk)
	begin
	  if rising_edge(AxiLiteClk) then 
	    if lAxiAreset_n = '0' then
	      lAxiAwaddrLoc <= (others => '0');
	    else
	      if (lAxiAwreadyLoc = '0' and lAxiAwvalid = '1' and lAxiWvalid = '1' and lAwEn = '1') then
	        -- Write Address latching
	        lAxiAwaddrLoc <= lAxiAwaddr;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement lAxiWreadyLoc generation
	-- lAxiWreadyLoc is asserted for one AxiLiteClk clock cycle when both
	-- lAxiAwvalid and lAxiWvalid are asserted. lAxiWreadyLoc is 
	-- de-asserted when reset is low. 

	process (AxiLiteClk)
	begin
	  if rising_edge(AxiLiteClk) then 
	    if lAxiAreset_n = '0' then
	      lAxiWreadyLoc <= '0';
	    else
	      if (lAxiWreadyLoc = '0' and lAxiWvalid = '1' and lAxiAwvalid = '1' and lAwEn = '1') then
	          -- slave is ready to accept write data when 
	          -- there is a valid write address and write data
	          -- on the write address and data bus. This design 
	          -- expects no outstanding transactions.           
	          lAxiWreadyLoc <= '1';
	      else
	        lAxiWreadyLoc <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- lAxiAwreadyLoc, lAxiWvalid, lAxiWreadyLoc and lAxiWvalid are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	lSlvRegWrEn <= lAxiWreadyLoc and lAxiWvalid and lAxiAwreadyLoc and lAxiAwvalid ;

ProcFifoWrEn: process (AxiLiteClk)
    variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	   if rising_edge(AxiLiteClk) then 
	       if lAxiAreset_n = '0' then
	           lSPI_TxFifoWrEn <= '0';
	       else
	           loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	           if ((lSlvRegWrEn = '1' and loc_addr =  b"00011")) then
	               lSPI_TxFifoWrEn <= '1';
	           else
	               lSPI_TxFifoWrEn <= '0';
	           end if;
	       end if;
	   end if;                   
	end process; 
-----------------------------------REGISTER CONTENT ASSIGNMENT------------------------------------------
ProcSlvReg0: process (AxiLiteClk)  --Control Register
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg0 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      --Access conditions:
	      --1. Bits 4: processor can only set the bit, while the hardware can only clear it
	      --2. All other bits R/W access and can only be modified by the processor
	      if ((lSetStop) = '1' and (lSlvReg0(4) = '1')) then
               lSlvReg0(4) <= not lSetStop;
	      elsif (lSlvRegWrEn = '1' and loc_addr = "00000") then
            if (lAxiWstrb(0) = '1') then
	            lSlvReg0(7 downto 5) <= lAxiWdata(7 downto 5);
	            lSlvReg0(3 downto 0) <= lAxiWdata(3 downto 0);
	            if (lAxiWdata(4) = '1') then
	                lSlvReg0(4) <= lAxiWdata(4);
	            end if;
	        end if; 
            if (lAxiWstrb(1) = '1') then
	            lSlvReg0(15 downto 8) <= lAxiWdata(15 downto 8);
            end if;
            if (lAxiWstrb(2) = '1') then
	            lSlvReg0(23 downto 16) <= lAxiWdata(23 downto 16);
            end if;
            if (lAxiWstrb(3) = '1') then
	            lSlvReg0(31 downto 24) <= lAxiWdata(31 downto 24);
            end if;            
	      end if;
	    end if;
	  end if;                   
	end process;  

ProcSlvReg1: process (AxiLiteClk)
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg1 <= (others => '0');
	    else
	      lSlvReg1(9 downto 3) <= lSPI_CmdTxCount;
	      lSlvReg1(16 downto 10) <= lSPI_CmdRxCount;
	      lSlvReg1(2) <= lAdcSPI_Idle;
	      lSlvReg1(22) <= not sInitDone_n;
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      --Access conditions:
	      --1. Bits 0,1,21: processor can only clear the bits, while the hardware can only set them
	      --2. Bit [16:3]: Read only.
	      --3. Bits [20:17] To be defined
	      --4. CmdRxDone to be removed
	      if ((lBufferFull) = '1' and (lSlvReg1(21) = '0')) then
               lSlvReg1(21) <= lBufferFull;
          elsif ((lSPI_CmdTxDone = '1') and (lSlvReg1(0) = '0')) then
               lSlvReg1(0) <= lSPI_CmdTxDone;
          elsif ((lSPI_CmdRxDone = '1') and (lSlvReg1(1) = '1')) then
               lSlvReg1(1) <= lSPI_CmdRxDone;
	      elsif (lSlvRegWrEn = '1' and loc_addr = "00001") then
            if (lAxiWstrb(0) = '1') then
                if (lAxiWdata(0) = '1') then
	                lSlvReg1(0) <= '0';
	            end if;
	            if (lAxiWdata(1) = '1') then
	                lSlvReg1(1) <= '0';
	            end if;
	        end if; 
            if (lAxiWstrb(2) = '1') then
                if (lAxiWdata(21) = '1') then
	                lSlvReg1(21) <= '0';
	            end if;
            end if;
	      end if;
	    end if;
	  end if;                   
	end process;
	
ProcSlvReg2: process (AxiLiteClk) --Interrupt Enable Register
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg2 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "00010")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg2(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      else
	          lSlvReg2 <= lSlvReg2;
	      end if;
	    end if;
	  end if;                   
	end process; 

ProcSlvReg3: process (AxiLiteClk) --SPI CMD TX Register
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg3 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "00011")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg3(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 

    lSlvReg4 <= x"000000" & lSPI_CmdRx; --SPI CMD RX Register
    
ProcSlvReg5: process (AxiLiteClk) --AXIS_S2MM_LENGTH Register 
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg5 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "00101")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg5(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 

ProcSlvReg6: process (AxiLiteClk)  --Reg6 not used
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg6 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "00110")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg6(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 

ProcSlvReg7: process (AxiLiteClk) --Trigger Control Register
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg7 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "00111")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg7(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 

ProcSlvReg8: process (AxiLiteClk)  --Window Register
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg8 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "01000")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg8(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process;

ProcSlvReg9: process (AxiLiteClk)  --sExtCh1LgMultCoef
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg9 <= x"00010000";
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "01001")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg9(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 
	
ProcSlvReg10: process (AxiLiteClk)  --sExtCh1LgAddCoef
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg10 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "01010")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg10(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 
	
ProcSlvReg11: process (AxiLiteClk)  --sExtCh1HgMultCoef
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg11 <= x"00010000";
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "01011")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg11(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 
	
ProcSlvReg12: process (AxiLiteClk)  --sExtCh1HgAddCoef
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg12 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "01100")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg12(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 
	
ProcSlvReg13: process (AxiLiteClk)  --sExtCh2LgMultCoef
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg13 <= x"00010000";
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "01101")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg13(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 
	
ProcSlvReg14: process (AxiLiteClk)  --sExtCh2LgAddCoef
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg14 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "01110")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg14(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 
	
ProcSlvReg15: process (AxiLiteClk)  --sExtCh2HgMultCoef
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg15 <= x"00010000";
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "01111")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg15(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 

ProcSlvReg16: process (AxiLiteClk)  --sExtCh2HgMultCoef
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0); 
	begin
	  if rising_edge(AxiLiteClk) then 
	    if ((lAxiAreset_n = '0') or (lRegRstPulse = '1')) then
	      lSlvReg16 <= (others => '0');
	    else
	      loc_addr := lAxiAwaddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	      if ((lSlvRegWrEn = '1') and (loc_addr = "10000")) then
	            for lByteIndex in 0 to (kAxiLiteDataWidth/8-1) loop
	              if ( lAxiWstrb(lByteIndex) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                lSlvReg16(lByteIndex*8+7 downto lByteIndex*8) <= lAxiWdata(lByteIndex*8+7 downto lByteIndex*8);
	              end if;
	            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 
									 		    
	process (AxiLiteClk)
	begin
	  if rising_edge(AxiLiteClk) then 
	    if lAxiAreset_n = '0' then
	      lAxiBvalidLoc  <= '0';
	      lAxiBrespLoc   <= "00"; --need to work more on the responses
	    else
	      if (lAxiAwreadyLoc = '1' and lAxiAwvalid = '1' and lAxiWreadyLoc = '1' and lAxiWvalid = '1' and lAxiBvalidLoc = '0'  ) then
	        lAxiBvalidLoc <= '1';
	        lAxiBrespLoc  <= "00"; 
	      elsif (lAxiBready = '1' and lAxiBvalidLoc = '1') then   --check if bready is asserted while bvalid is high)
	        lAxiBvalidLoc <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 


	-- Implement lAxiArreadyLoc generation
	-- lAxiArreadyLoc is asserted for one AxiLiteClk clock cycle when
	-- lAxiArvalid is asserted. lAxiAwreadyLoc is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when lAxiArvalid is 
	-- asserted. lAxiAraddrLoc is reset to zero on reset assertion.

	process (AxiLiteClk)
	begin
	  if rising_edge(AxiLiteClk) then 
	    if lAxiAreset_n = '0' then
	      lAxiArreadyLoc <= '0';
	      lAxiAraddrLoc  <= (others => '1');
	    else
	      if (lAxiArreadyLoc = '0' and lAxiArvalid = '1') then
	        -- indicates that the slave has acceped the valid read address
	        lAxiArreadyLoc <= '1';
	        -- Read Address latching 
	        lAxiAraddrLoc  <= lAxiAraddr;           
	      else
	        lAxiArreadyLoc <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arvalid generation
	-- lAxiRvalidLoc is asserted for one AxiLiteClk clock cycle when both 
	-- lAxiArvalid and lAxiArreadyLoc are asserted. The slave registers 
	-- data are available on the lAxiRdataLoc bus at this instance. The 
	-- assertion of lAxiRvalidLoc marks the validity of read data on the 
	-- bus and lAxiRrespLoc indicates the status of read transaction.lAxiRvalidLoc 
	-- is deasserted on reset (active low). lAxiRrespLoc and lAxiRdataLoc are 
	-- cleared to zero on reset (active low).  
	process (AxiLiteClk)
	begin
	  if rising_edge(AxiLiteClk) then
	    if lAxiAreset_n = '0' then
	      lAxiRvalidLoc <= '0';
	      lAxiRrespLoc  <= "00";
	    else
	      if (lAxiArreadyLoc = '1' and lAxiArvalid = '1' and lAxiRvalidLoc = '0') then
	        -- Valid read data is available at the read data bus
	        lAxiRvalidLoc <= '1';
	        lAxiRrespLoc  <= "00"; -- 'OKAY' response
	      elsif (lAxiRvalidLoc = '1' and lAxiRready = '1') then
	        -- Read data is accepted by the master
	        lAxiRvalidLoc <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	lSlvRegRdEn <= lAxiArreadyLoc and lAxiArvalid and (not lAxiRvalidLoc) ;

	process (lSlvReg2, lSlvReg3, lSlvReg4, lSlvReg5, lSlvReg6, lSlvReg7, lAxiAraddrLoc, lAxiAreset_n, lSlvRegRdEn)
	variable loc_addr :std_logic_vector(kOptMemAddrBits downto 0);
	begin
	    -- Address decoding for reading registers
	    loc_addr := lAxiAraddrLoc(kAddrLsb + kOptMemAddrBits downto kAddrLsb);
	    lSlvReg4RdEn <= '0';
	    case loc_addr is
	      when b"00000" =>
	        lRegDataOut <= lSlvReg0;
	      when b"00001" =>
	        lRegDataOut <= lSlvReg1;
	      when b"00010" =>
	        lRegDataOut <= lSlvReg2;
	      when b"00011" =>
	        lRegDataOut <= lSlvReg3;
	      when b"00100" =>
	        lRegDataOut <= lSlvReg4;
	        lSlvReg4RdEn <= '1';
	      when b"00101" =>
	        lRegDataOut <= lSlvReg5;
	      when b"00110" =>
	        lRegDataOut <= lSlvReg6;
	      when b"00111" =>
	        lRegDataOut <= lSlvReg7;
	      when b"01000" =>
	        lRegDataOut <= lSlvReg8;
	      when b"01001" =>
	        lRegDataOut <= lSlvReg9;  
	      when b"01010" =>
	        lRegDataOut <= lSlvReg10;  
	      when b"01011" =>
	        lRegDataOut <= lSlvReg11;  
	      when b"01100" =>
	        lRegDataOut <= lSlvReg12;  
	      when b"01101" =>
	        lRegDataOut <= lSlvReg13;  
	      when b"01110" =>
	        lRegDataOut <= lSlvReg14;  
	      when b"01111" =>
	        lRegDataOut <= lSlvReg15;  
	      when b"10000" =>
	        lRegDataOut <= lSlvReg16;    
	      when others =>
	        lRegDataOut  <= (others => '0');
	        lSlvReg4RdEn <= '0';
	    end case;
	end process; 

	-- Output register or memory read data
	process( AxiLiteClk ) is
	begin
	  if (rising_edge (AxiLiteClk)) then
	    if ( lAxiAreset_n = '0' ) then
	      lAxiRdataLoc  <= (others => '0');
	    else
	      if (lSlvRegRdEn = '1') then
	        -- When there is a valid read address (lAxiArvalid) with 
	        -- acceptance of read address by the slave (lAxiArreadyLoc), 
	        -- output the read dada 
	        -- Read address mux
	          lAxiRdataLoc <= lRegDataOut;     -- register read data
	      end if;   
	    end if;
	  end if;
	end process;

	process( AxiLiteClk ) is
	begin
	  if (rising_edge (AxiLiteClk)) then
	    if ( lAxiAreset_n = '0' ) then
	      lSPI_RxFifoRdEn <= '0';
	    else
	      if (lSlvRegRdEn = '1') then
            lSPI_RxFifoRdEn <= lSlvReg4RdEn;
          else
            lSPI_RxFifoRdEn <= '0';
	      end if;   
	    end if;
	  end if;
	end process;
	-- Add user logic here

	-- User logic ends

end arch_imp;
