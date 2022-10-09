-------------------------------------------------------------------------------
--
-- File: Control_Registers.vhd
-- Author: Gherman Tudor
-- Original Project: USB Device IP on 7-series Xilinx FPGA
-- Date: 2 May 2016
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
-- This module implements the control registers required by USB Device IP.
-- Control Registers data is written/read over an AXI Lite interface 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Control_Registers is
	generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 32
	);
	port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic; 
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
        
        --Identification: Configuration Constants
        USBSCFG_rd	: out std_logic_vector(31 downto 0);
        --Operational : Interrupts, Schedule Pointers (Host), and Endpoint Pointers (Device)
        USBCMD_rd	: out std_logic_vector(31 downto 0);
        USBSTS_wr_UI  : in std_logic;
        USBCMD_SUTW_wr    : in std_logic;
        USBCMD_SUTW_wr_en    : in std_logic;
        USBCMD_ATDTW_wr    : in std_logic;
        USBCMD_ATDTW_wr_en    : in std_logic;
        USBSTS_rd	: out std_logic_vector(31 downto 0);
        USBSTS_wr_NAKI    :  in std_logic;  
        USBSTS_wr_SLI    :  in std_logic;
        USBSTS_wr_SRI    :  in std_logic;
        USBSTS_wr_URI    :  in std_logic;
        USBSTS_wr_PCI    :  in std_logic;
        USBSTS_wr_en_NAK    :  in std_logic;
        USBSTS_wr_en_SLI    :  in std_logic;
        USBSTS_wr_en_SRI    :  in std_logic;
        USBSTS_wr_en_URI    :  in std_logic;
        USBSTS_wr_en_PCI    :  in std_logic;
        USBSTS_wr_en_UI  : in std_logic;
        USBINTR_rd	: out std_logic_vector(31 downto 0);
        FRINDEX_rd	: out std_logic_vector(31 downto 0);
        FRINDEX_wr	: in std_logic_vector(10 downto 0);
        FRINDEX_wr_en	: in std_logic;
        a_DEVICEADDR_rd	: out std_logic_vector(31 downto 0);
        a_DEVICEADDR_IPush	: out std_logic;
        ENDPOINTLISTADDR_rd	: out std_logic_vector(31 downto 0);
        ENDPTNAK_rd	: out std_logic_vector(31 downto 0);
        ENDPTNAK_wr	: in std_logic_vector(31 downto 0);
        ENDPTNAK_wr_en	: in std_logic;
        ENDPTNAKEN_rd	: out std_logic_vector(31 downto 0);
        CONFIGFLAG_rd	: out std_logic_vector(31 downto 0);
        PORTSC1_rd	: out std_logic_vector(31 downto 0);
        PORTSC1_PSPD_wr    : in std_logic_vector(1 downto 0);
        PORTSC1_PSPD_wr_en    : in std_logic;
        OTGSC_rd	: out std_logic_vector(31 downto 0);
        USBMODE_rd	: out std_logic_vector(31 downto 0);
        ENDPTSETUPSTAT_rd	: out std_logic_vector(31 downto 0);
        ENDPTSETUPSTAT_wr	: in std_logic_vector(31 downto 0);
        ENDPTSETUPSTAT_wr_en	: in std_logic;
        ENDPTPRIME_rd	: out std_logic_vector(31 downto 0);
        ENDPTPRIME_clear    : in std_logic_vector(31 downto 0);
        ENDPTPRIME_clear_en    : in std_logic;
        ENDPTPRIME_set    : in std_logic_vector(31 downto 0);
        ENDPTPRIME_set_en    : in std_logic;
        EMDPTFLUSH_rd	: out std_logic_vector(31 downto 0);
        EMDPTFLUSH_clear	: in std_logic_vector(31 downto 0);
        EMDPTFLUSH_clear_en	: in std_logic;
        EMDPTFLUSH_set    : in std_logic_vector(31 downto 0);
        EMDPTFLUSH_set_en    : in std_logic;
        ENDPTSTAT_wr	: in std_logic_vector(31 downto 0);
        ENDPTCOMPLETE_rd	: out std_logic_vector(31 downto 0);
        ENDPTCOMPLETE_wr	: in std_logic_vector(31 downto 0);
        ENDPTCOMPLETE_wr_en	: in std_logic;
        ENDPTCTRL0_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL1_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL2_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL3_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL4_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL5_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL6_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL7_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL8_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL9_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL10_rd	: out std_logic_vector(31 downto 0);
        ENDPTCTRL11_rd	: out std_logic_vector(31 downto 0)
	);
end Control_Registers;

architecture arch_imp of Control_Registers is

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 6;

	signal a_USBSCFG_Reg	            :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_USBCMD_Reg	            :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_USBSTS_Reg	            :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_USBINTR_Reg	            :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_FRINDEX_Reg	            :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_DEVICEADDR_Reg	        :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPOINTLISTADDR_Reg	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTNAK_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTNAKEN_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_CONFIGFLAG_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_PORTSC1_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_OTGSC_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_USBMODE_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTSETUPSTAT_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTPRIME_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_EMDPTFLUSH_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTSTAT_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCOMPLETE_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL0_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL1_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL2_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL3_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL4_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL5_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL6_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL7_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL8_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL9_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL10_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal a_ENDPTCTRL11_Reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	
    constant ID	:  std_logic_vector(31 downto 0) := (others => '0');
    constant HWGENERAL    :  std_logic_vector(31 downto 0) := (others => '0');
    constant HWDEVICE    :  std_logic_vector(31 downto 0) := (others => '0');
    constant HWTXBUF    :  std_logic_vector(31 downto 0) := (others => '0');
    constant HWRXBUF    :  std_logic_vector(31 downto 0) := (others => '0');
    
    constant CAPLENGTH_HCIVERSION	: std_logic_vector(31 downto 0) := (others => '0');
    constant DCIVERSION    : std_logic_vector(31 downto 0) := (others => '0');
    constant DCCPARAMS    : std_logic_vector(31 downto 0) := (others => '0');
    
--    attribute mark_debug : string;
--    attribute keep : string;

--    attribute mark_debug of USBCMD_rd : signal is "true";
--    attribute keep of USBCMD_rd : signal is "true";
--    attribute mark_debug of USBSTS_rd : signal is "true";
--    attribute keep of USBSTS_rd : signal is "true";
--    attribute mark_debug of ENDPTPRIME_rd : signal is "true";
--    attribute keep of ENDPTPRIME_rd : signal is "true";
--    attribute mark_debug of ENDPTCTRL0_rd : signal is "true";
--    attribute keep of ENDPTCTRL0_rd : signal is "true";
--    attribute mark_debug of ENDPOINTLISTADDR_rd : signal is "true";
--    attribute keep of ENDPOINTLISTADDR_rd : signal is "true";    
--    attribute mark_debug of ENDPTCOMPLETE_rd : signal is "true";
--    attribute keep of ENDPTCOMPLETE_rd : signal is "true";
--    attribute mark_debug of ENDPTSETUPSTAT_rd : signal is "true";
--    attribute keep of ENDPTSETUPSTAT_rd : signal is "true"; 
--    attribute mark_debug of a_ENDPTSTAT_Reg : signal is "true";
--    attribute keep of a_ENDPTSTAT_Reg : signal is "true"; 
                      
begin
    USBSCFG_rd <= a_USBSCFG_Reg;
    USBCMD_rd <= a_USBCMD_Reg;
    USBSTS_rd <= a_USBSTS_Reg;
    USBINTR_rd <= a_USBINTR_Reg;
    FRINDEX_rd <= a_FRINDEX_Reg;
    a_DEVICEADDR_rd <= a_DEVICEADDR_Reg;
    ENDPOINTLISTADDR_rd <= a_ENDPOINTLISTADDR_Reg;
    ENDPTNAK_rd <= a_ENDPTNAK_Reg;
    ENDPTNAKEN_rd <= a_ENDPTNAKEN_Reg; 
    CONFIGFLAG_rd <= a_CONFIGFLAG_Reg;
    PORTSC1_rd <= a_PORTSC1_Reg;
    OTGSC_rd <= a_OTGSC_Reg;
    USBMODE_rd <= a_USBMODE_Reg;
    ENDPTSETUPSTAT_rd <= a_ENDPTSETUPSTAT_Reg;
    ENDPTPRIME_rd <= a_ENDPTPRIME_Reg;
    EMDPTFLUSH_rd <= a_EMDPTFLUSH_Reg;
    a_ENDPTSTAT_Reg <= ENDPTSTAT_wr;
    ENDPTCOMPLETE_rd <= a_ENDPTCOMPLETE_Reg;
    ENDPTCTRL0_rd <= a_ENDPTCTRL0_Reg;
    ENDPTCTRL1_rd <= a_ENDPTCTRL1_Reg;
    ENDPTCTRL2_rd <= a_ENDPTCTRL2_Reg;
    ENDPTCTRL3_rd <= a_ENDPTCTRL3_Reg;
    ENDPTCTRL4_rd <= a_ENDPTCTRL4_Reg;
    ENDPTCTRL5_rd <= a_ENDPTCTRL5_Reg;
    ENDPTCTRL6_rd <= a_ENDPTCTRL6_Reg;
    ENDPTCTRL7_rd <= a_ENDPTCTRL7_Reg;
    ENDPTCTRL8_rd <= a_ENDPTCTRL8_Reg;
    ENDPTCTRL9_rd <= a_ENDPTCTRL9_Reg;
    ENDPTCTRL10_rd <= a_ENDPTCTRL10_Reg;
    ENDPTCTRL11_rd <= a_ENDPTCTRL11_Reg;        
	-- I/O Connections assignments
	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	<= axi_rdata;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
	        axi_awready <= '1';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then      
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      a_USBSCFG_Reg <= (others => '0');
	      a_USBCMD_Reg <= (others => '0');
	      a_USBINTR_Reg <= (others => '0');
	      a_FRINDEX_Reg <= (others => '0');
	      a_DEVICEADDR_Reg <= (others => '0');
	      a_DEVICEADDR_IPush <= '0';
	      a_ENDPOINTLISTADDR_Reg <= (others => '0');
	      a_ENDPTNAK_Reg <= (others => '0');
	      a_ENDPTNAKEN_Reg <= (others => '0');
	      a_CONFIGFLAG_Reg <= (others => '0');
	      a_PORTSC1_Reg <= (others => '0');
	      a_OTGSC_Reg <= (others => '0');
	      a_USBMODE_Reg <= (others => '0');
	      a_ENDPTPRIME_Reg <= (others => '0');
	      a_ENDPTCOMPLETE_Reg <= (others => '0');
	      a_ENDPTCTRL0_Reg <= (others => '0');
	      a_ENDPTCTRL1_Reg <= (others => '0');
	      a_ENDPTCTRL2_Reg <= (others => '0');
	      a_ENDPTCTRL3_Reg <= (others => '0');
	      a_ENDPTCTRL4_Reg <= (others => '0');
	      a_ENDPTCTRL5_Reg <= (others => '0');
	      a_ENDPTCTRL6_Reg <= (others => '0');
	      a_ENDPTCTRL7_Reg <= (others => '0');
	      a_ENDPTCTRL8_Reg <= (others => '0');
	      a_ENDPTCTRL9_Reg <= (others => '0');
	      a_ENDPTCTRL10_Reg <= (others => '0');
	      a_ENDPTCTRL11_Reg <= (others => '0');
	    else
	      loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	      if (slv_reg_wren = '1') then
	        case loc_addr is
	          when b"0100100" => --SBUSCFG 0x0090
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_USBSCFG_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1010000" => --USBCMD 0x0140
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_USBCMD_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1010010" => --USBINTR 0x0148
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_USBINTR_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1010011" => --FRINDEX 0x014C
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_FRINDEX_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1010101" => --DEVICEADDR 0x0154
	            a_DEVICEADDR_IPush <= '1';
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_DEVICEADDR_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1010110" => --ENDPOINTLISTADDR 0x158
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_ENDPOINTLISTADDR_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1011110" => --ENDPTNAK 0x0178
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_ENDPTNAK_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1011111" => -- ENDPTNAKEN 0x17c
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_ENDPTNAKEN_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_ENDPTCTRL7_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_ENDPTCTRL8_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1100001" => --PORTSC1 0x0184
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_PORTSC1_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1101001" => --OTGSC 0x01A4
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_OTGSC_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1101010" => --USBMODE 0x1A8
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                a_USBMODE_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1101100" => --ENDPTPRIME 0x01B0
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                    if ( S_AXI_WSTRB(byte_index) = '1' ) then
                      a_ENDPTPRIME_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                    end if;
                end loop;
                when b"1101111" => --ENDPTCOMPLETE 0x01BC
                  for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                    if ( S_AXI_WSTRB(byte_index) = '1' ) then
                      a_ENDPTCOMPLETE_Reg(byte_index*8+7 downto byte_index*8) <= a_ENDPTCOMPLETE_Reg(byte_index*8+7 downto byte_index*8) and ( not (S_AXI_WDATA(byte_index*8+7 downto byte_index*8)));
                    end if;
                  end loop; 
	          when b"1110000" => --ENDPTCTRL0 0x01C0
                    for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                      if ( S_AXI_WSTRB(byte_index) = '1' ) then
                        a_ENDPTCTRL0_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                      end if;
                    end loop;
              when b"1110001" => --ENDPTCTRL1 0x01C4
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    a_ENDPTCTRL1_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"1110010" => --ENDPTCTRL2 0x01C8
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    a_ENDPTCTRL2_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"1110011" => --ENDPTCTRL3 0x01CC
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    a_ENDPTCTRL3_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"1110100" => --ENDPTCTRL4 0x01D0
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    a_ENDPTCTRL4_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"1110101" => --ENDPTCTRL5 0x01D4
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    a_ENDPTCTRL5_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"1110110" => --ENDPTCTRL6 0x01D8
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    a_ENDPTCTRL6_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if; 
                end loop;     
              when b"1110111" => --ENDPTCTRL7 0x01DC
                  for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                    if ( S_AXI_WSTRB(byte_index) = '1' ) then
                      a_ENDPTCTRL7_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                    end if; 
                  end loop; 
              when b"1111000" => --ENDPTCTRL8 0x01E0
                    for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                      if ( S_AXI_WSTRB(byte_index) = '1' ) then
                        a_ENDPTCTRL8_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                      end if; 
                    end loop; 
              when b"1111001" => --ENDPTCTRL9 0x01E4
                      for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                        if ( S_AXI_WSTRB(byte_index) = '1' ) then
                          a_ENDPTCTRL9_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                        end if; 
                      end loop; 
              when b"1111010" => --ENDPTCTRL10 0x01E8
                        for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                          if ( S_AXI_WSTRB(byte_index) = '1' ) then
                            a_ENDPTCTRL10_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                          end if; 
                        end loop; 
              when b"1111011" => --D 0x01EC
                          for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                            if ( S_AXI_WSTRB(byte_index) = '1' ) then
                              a_ENDPTCTRL11_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                            end if; 
                          end loop;                                                                                                                                             
	          when others =>
	            a_USBSCFG_Reg <= a_USBSCFG_Reg;
	            a_USBCMD_Reg <= a_USBCMD_Reg;
	            a_USBINTR_Reg <= a_USBINTR_Reg;
	            a_FRINDEX_Reg <= a_FRINDEX_Reg;
	            a_DEVICEADDR_Reg <= a_DEVICEADDR_Reg;
	            a_DEVICEADDR_IPush <= '0';
	            a_ENDPOINTLISTADDR_Reg <= a_ENDPOINTLISTADDR_Reg;
	            a_ENDPTNAK_Reg <= a_ENDPTNAK_Reg;
	            a_ENDPTNAKEN_Reg <= a_ENDPTNAKEN_Reg;
	            a_CONFIGFLAG_Reg <= a_CONFIGFLAG_Reg;
	            a_PORTSC1_Reg <= a_PORTSC1_Reg;
	            a_OTGSC_Reg <= a_OTGSC_Reg;
	            a_USBMODE_Reg <= a_USBMODE_Reg;
	            a_ENDPTPRIME_Reg <= a_ENDPTPRIME_Reg;
	            a_ENDPTCOMPLETE_Reg <= a_ENDPTCOMPLETE_Reg;
	            a_ENDPTCTRL0_Reg <= a_ENDPTCTRL0_Reg;
	            a_ENDPTCTRL1_Reg <= a_ENDPTCTRL1_Reg;
	            a_ENDPTCTRL2_Reg <= a_ENDPTCTRL2_Reg;
	            a_ENDPTCTRL3_Reg <= a_ENDPTCTRL3_Reg;
	            a_ENDPTCTRL4_Reg <= a_ENDPTCTRL4_Reg;
	            a_ENDPTCTRL5_Reg <= a_ENDPTCTRL5_Reg;
	            a_ENDPTCTRL6_Reg <= a_ENDPTCTRL6_Reg;
	            a_ENDPTCTRL7_Reg <= a_ENDPTCTRL7_Reg;
	            a_ENDPTCTRL8_Reg <= a_ENDPTCTRL8_Reg;
	            a_ENDPTCTRL9_Reg <= a_ENDPTCTRL9_Reg;
	            a_ENDPTCTRL10_Reg <= a_ENDPTCTRL10_Reg;
	            a_ENDPTCTRL11_Reg <= a_ENDPTCTRL11_Reg;
	        end case;
        
	      elsif (USBCMD_SUTW_wr_en = '1') then
	           a_USBCMD_Reg(13) <= USBCMD_SUTW_wr;
	      elsif (USBCMD_ATDTW_wr_en = '1') then
               a_USBCMD_Reg(14) <= USBCMD_ATDTW_wr;	
          elsif (a_USBCMD_Reg(1) = '1') then
               a_USBCMD_Reg(1) <= '0';     
	      elsif (FRINDEX_wr_en = '1') then
	           a_FRINDEX_Reg(10 downto 0) <= FRINDEX_wr;
	      elsif (ENDPTNAK_wr_en = '1') then
	           a_ENDPTNAK_Reg <= ENDPTNAK_wr;
	      elsif (PORTSC1_PSPD_wr_en = '1') then
	           a_PORTSC1_Reg(27 downto 26) <= PORTSC1_PSPD_wr;     
	      elsif (ENDPTPRIME_clear_en = '1') then
	           a_ENDPTPRIME_Reg <= a_ENDPTPRIME_Reg and ENDPTPRIME_clear;
	      elsif (ENDPTPRIME_set_en = '1') then
               a_ENDPTPRIME_Reg <= a_ENDPTPRIME_Reg or ENDPTPRIME_set;	           
	      elsif (ENDPTCOMPLETE_wr_en = '1') then
	           a_ENDPTCOMPLETE_Reg <= a_ENDPTCOMPLETE_Reg or ENDPTCOMPLETE_wr; 
	      end if;
	    end if;
	  end if;                   
	end process; 
	
    ENDPTSETUPSTAT_PROC : process (S_AXI_ACLK)
        variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
        begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                a_ENDPTSETUPSTAT_Reg <= (others => '0');
            else
               loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
               if (slv_reg_wren = '1' and loc_addr = "1101011") then
                   for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                        if ( S_AXI_WSTRB(byte_index) = '1' ) then
                            a_ENDPTSETUPSTAT_Reg(byte_index*8+7 downto byte_index*8) <= a_ENDPTSETUPSTAT_Reg(byte_index*8+7 downto byte_index*8) and ( not (S_AXI_WDATA(byte_index*8+7 downto byte_index*8)));   
                        end if;
                   end loop;                   
                elsif (ENDPTSETUPSTAT_wr_en = '1') then
                    a_ENDPTSETUPSTAT_Reg <= a_ENDPTSETUPSTAT_Reg or ENDPTSETUPSTAT_wr;  
                end if;       
	        end if;
        end if;
    end process;  

    ENDPTFLUSH_PROC : process (S_AXI_ACLK)
        variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
        begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                a_EMDPTFLUSH_Reg <= (others => '0');
            else
               loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
               if (slv_reg_wren = '1' and loc_addr = "1101101") then  --EMDPTFLUSH 0x01B4
                   for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                        if ( S_AXI_WSTRB(byte_index) = '1' ) then
                            a_EMDPTFLUSH_Reg(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);   
                        end if;
                   end loop;                   
                elsif (EMDPTFLUSH_clear_en = '1') then
                    a_EMDPTFLUSH_Reg <= a_EMDPTFLUSH_Reg and EMDPTFLUSH_clear; 
                elsif (EMDPTFLUSH_set_en = '1') then
                    a_EMDPTFLUSH_Reg <= a_EMDPTFLUSH_Reg or EMDPTFLUSH_set;                     
                end if;       
	        end if;
        end if;
    end process;  
    
    USBSTS_PROC : process (S_AXI_ACLK)
        variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
        begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                a_USBSTS_Reg <= (others => '0');
            else
               loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
               if (slv_reg_wren = '1' and loc_addr = "1010001") then
                   for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                        if ( S_AXI_WSTRB(byte_index) = '1' ) then
                            a_USBSTS_Reg(byte_index*8+7 downto byte_index*8) <= (a_USBSTS_Reg(byte_index*8+7 downto byte_index*8)) and (not (S_AXI_WDATA(byte_index*8+7 downto byte_index*8)));   
                        end if;
                   end loop;                   
                elsif (USBSTS_wr_en_UI = '1' or USBSTS_wr_en_NAK = '1' or USBSTS_wr_en_SLI = '1' or USBSTS_wr_en_SRI = '1' or USBSTS_wr_en_URI = '1' or USBSTS_wr_en_PCI = '1') then
                    a_USBSTS_Reg(0) <= a_USBSTS_Reg(0) or USBSTS_wr_en_UI; 
                    a_USBSTS_Reg(16) <= a_USBSTS_Reg(16) or USBSTS_wr_en_NAK; 
                    a_USBSTS_Reg(8) <= a_USBSTS_Reg(8) or USBSTS_wr_en_SLI; 
                    a_USBSTS_Reg(7) <= a_USBSTS_Reg(7) or USBSTS_wr_en_SRI; 
                    a_USBSTS_Reg(6) <= a_USBSTS_Reg(6) or USBSTS_wr_en_URI; 
                    a_USBSTS_Reg(2) <= a_USBSTS_Reg(2) or USBSTS_wr_en_PCI; 
                end if;       
            end if;
        end if;
    end process;         	            

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        axi_arready <= '1';
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 
 
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (a_USBSCFG_Reg, a_USBCMD_Reg, a_USBSTS_Reg, a_USBINTR_Reg, a_FRINDEX_Reg, a_DEVICEADDR_Reg, a_ENDPOINTLISTADDR_Reg, a_ENDPTNAK_Reg, a_ENDPTNAKEN_Reg, a_CONFIGFLAG_Reg, a_PORTSC1_Reg, a_OTGSC_Reg, a_USBMODE_Reg, a_ENDPTSETUPSTAT_Reg, a_ENDPTPRIME_Reg, a_EMDPTFLUSH_Reg, a_ENDPTSTAT_Reg, a_ENDPTCOMPLETE_Reg, a_ENDPTCTRL0_Reg, a_ENDPTCTRL1_Reg, a_ENDPTCTRL2_Reg, a_ENDPTCTRL3_Reg, a_ENDPTCTRL4_Reg, a_ENDPTCTRL5_Reg, a_ENDPTCTRL6_Reg, a_ENDPTCTRL7_Reg, a_ENDPTCTRL8_Reg, a_ENDPTCTRL9_Reg, a_ENDPTCTRL10_Reg, a_ENDPTCTRL11_Reg, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
	    -- Address decoding for reading registers
	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	    case loc_addr is
	      when b"0000000" =>
	        reg_data_out <= ID;
	      when b"0000001" =>
	        reg_data_out <= HWGENERAL;
	      when b"0000011" =>
	        reg_data_out <= HWDEVICE;
	      when b"000100" =>
	        reg_data_out <= HWTXBUF;
	      when b"000101" =>
	        reg_data_out <= HWRXBUF;
	      when b"0100100" => --SBUSCFG
	        reg_data_out <= a_USBSCFG_Reg;
	      when b"1000000" => --CAPLENGTH_HCIVERSION
	        reg_data_out <= CAPLENGTH_HCIVERSION;
	      when b"1001000" => --DCIVERSION
	        reg_data_out <= DCIVERSION;
	      when b"1001001" => --DCCPARAMS
	        reg_data_out <= DCCPARAMS;
	      when b"1010000" => --USBCMD
	        reg_data_out <= a_USBCMD_Reg;
	      when b"1010001" => --USBSTS
	        reg_data_out <= a_USBSTS_Reg;
	      when b"1010010" => --USBINTR
	        reg_data_out <= a_USBINTR_Reg;
	      when b"1010011" => --FRINDEX
	        reg_data_out <= a_FRINDEX_Reg;
	      when b"1010101" => --DEVICEADDR
	        reg_data_out <= a_DEVICEADDR_Reg;
	      when b"1010110" =>  --ENDPOINTLISTADDR
	        reg_data_out <= a_ENDPOINTLISTADDR_Reg;
	      when b"1011110" => --ENDPTNAK
	        reg_data_out <= a_ENDPTNAK_Reg;
	      when b"1011111" => --ENDPTNAKEN
	        reg_data_out <= a_ENDPTNAKEN_Reg;
	      when b"1100000" => --CONFIGFLAG
	        reg_data_out <= a_CONFIGFLAG_Reg;
	      when b"1100001" => --PORTSC1
	        reg_data_out <= a_PORTSC1_Reg;
	      when b"1101001" => --OTGSC
	        reg_data_out <= a_OTGSC_Reg;
	      when b"1101010" => --USBMODE
	        reg_data_out <= a_USBMODE_Reg;
	      when b"1101011" => --ENDPTSETUPSTAT
	        reg_data_out <= a_ENDPTSETUPSTAT_Reg;
	      when b"1101100" => --ENDPTPRIME
	        reg_data_out <= a_ENDPTPRIME_Reg;
	      when b"1101101" => --EMDPTFLUSH
	        reg_data_out <= a_EMDPTFLUSH_Reg;
	      when b"1101110" => --ENDPTSTAT
	        reg_data_out <= a_ENDPTSTAT_Reg;
	      when b"1101111" => --ENDPTCOMPLETE
	        reg_data_out <= a_ENDPTCOMPLETE_Reg;
	      when b"1110000" => --ENDPTCTRL0
	        reg_data_out <= a_ENDPTCTRL0_Reg;
	      when b"1110001" => --ENDPTCTRL1
            reg_data_out <= a_ENDPTCTRL1_Reg;
          when b"1110010" => --ENDPTCTRL2
            reg_data_out <= a_ENDPTCTRL1_Reg;
          when b"1110011" => --ENDPTCTRL3
            reg_data_out <= a_ENDPTCTRL3_Reg;
	      when b"1110100" => --ENDPTCTRL4
            reg_data_out <= a_ENDPTCTRL4_Reg;
	      when b"1110101" => --ENDPTCTRL5
            reg_data_out <= a_ENDPTCTRL5_Reg;
	      when b"1110110" => --ENDPTCTRL6
            reg_data_out <= a_ENDPTCTRL6_Reg;
	      when b"1110111" => --ENDPTCTRL7
            reg_data_out <= a_ENDPTCTRL7_Reg;
	      when b"1111000" => --ENDPTCTRL8
            reg_data_out <= a_ENDPTCTRL8_Reg; 
	      when b"1111001" => --ENDPTCTRL9
            reg_data_out <= a_ENDPTCTRL9_Reg; 
	      when b"1111010" => --ENDPTCTRL10
            reg_data_out <= a_ENDPTCTRL10_Reg; 
	      when b"1111011" => --ENDPTCTRL11
            reg_data_out <= a_ENDPTCTRL11_Reg;                                                                                                                   
	      when others =>
	        reg_data_out  <= (others => '0');
	    end case;
	end process; 

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (slv_reg_rden = '1') then
	          axi_rdata <= reg_data_out;     -- register read data
	      end if;   
	    end if;
	  end if;
	end process;

end arch_imp;