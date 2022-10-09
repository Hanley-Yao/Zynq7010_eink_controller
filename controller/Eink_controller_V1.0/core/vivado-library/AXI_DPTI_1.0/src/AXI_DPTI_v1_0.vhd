------------------------------------------------------------------------------
--
-- File: axi_dpti_v1_0.vhd
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
--This is the top module for the AXI DPTI project. It defines the top level ports
--for the DPTI interface, AXI Lite interface and the AXI Stream interface. The module 
--is also used to declare the FIFOs (RX and TX) and the DPTI to STREAM and STREAM to 
--DPTI converters as well as the module responsible for the AXI Lite interface. 
--Another function for the module is the clock domain crossings for the LENGTH, 
--CONTROL and STATUS AXI Lite registers, using the HandshakeData and SyncAsync 
--modules. A PLL is also instantiated here which is used to compensate for the 
--prog_clko BUFG delay. 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity axi_dpti_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface AXI_LITE
		C_AXI_LITE_DATA_WIDTH	: integer	:= 32;
		C_AXI_LITE_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
      --DPTI INTERFACE
      prog_clko : in STD_LOGIC;
      prog_rxen : in STD_LOGIC;
      prog_txen : in STD_LOGIC;
      prog_spien : in STD_LOGIC;
      prog_rdn : out STD_LOGIC;
      prog_wrn : out STD_LOGIC;
      prog_oen : out STD_LOGIC;
      prog_siwun : out STD_LOGIC;
      prog_d : inout STD_LOGIC_VECTOR (7 downto 0);
      
      --AXI STREAM INTERFACE
      m_axis_aclk : in  std_logic; 
      m_axis_aresetn : in  std_logic; 
      m_axis_tready : in  std_logic; 
      m_axis_tdata : out std_logic_vector(31 downto 0);     
      m_axis_tkeep : out std_logic_vector(3 downto 0); 
      m_axis_tlast : out std_logic; 
      m_axis_tvalid : out std_logic; 
      
      s_axis_aclk : in  std_logic;
      s_axis_aresetn : in  std_logic; 
      s_axis_tready : out std_logic;  
      s_axis_tdata : in  std_logic_vector(31 downto 0);  
      s_axis_tkeep : in  std_logic_vector(3 downto 0);  
      s_axis_tlast : in  std_logic;  
      s_axis_tvalid : in  std_logic;  

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface AXI_LITE
		axi_lite_aclk	: in std_logic;
		axi_lite_aresetn	: in std_logic;
		axi_lite_awaddr	: in std_logic_vector(C_AXI_LITE_ADDR_WIDTH-1 downto 0);
		axi_lite_awprot	: in std_logic_vector(2 downto 0);
		axi_lite_awvalid	: in std_logic;
		axi_lite_awready	: out std_logic;
		axi_lite_wdata	: in std_logic_vector(C_AXI_LITE_DATA_WIDTH-1 downto 0);
		axi_lite_wstrb	: in std_logic_vector((C_AXI_LITE_DATA_WIDTH/8)-1 downto 0);
		axi_lite_wvalid	: in std_logic;
		axi_lite_wready	: out std_logic;
		axi_lite_bresp	: out std_logic_vector(1 downto 0);
		axi_lite_bvalid	: out std_logic;
		axi_lite_bready	: in std_logic;
		axi_lite_araddr	: in std_logic_vector(C_AXI_LITE_ADDR_WIDTH-1 downto 0);
		axi_lite_arprot	: in std_logic_vector(2 downto 0);
		axi_lite_arvalid	: in std_logic;
		axi_lite_arready	: out std_logic;
		axi_lite_rdata	: out std_logic_vector(C_AXI_LITE_DATA_WIDTH-1 downto 0);
		axi_lite_rresp	: out std_logic_vector(1 downto 0);
		axi_lite_rvalid	: out std_logic;
		axi_lite_rready	: in std_logic
	);
end axi_dpti_v1_0; 

architecture arch_imp of axi_dpti_v1_0 is

--------------------------------------------------------------------------------------------------------------------------

-- component declaration
component axi_dpti_v1_0_AXI_LITE is
   generic (
      C_S_AXI_DATA_WIDTH	: integer	:= 32;
      C_S_AXI_ADDR_WIDTH	: integer	:= 4
   );
   port (
      lAXI_LiteLengthReg : out std_logic_vector (31 downto 0);
      lAXI_LiteControlReg : out std_logic_vector (31 downto 0);
      lAXI_LiteStatusReg : out std_logic_vector (31 downto 0);
      lPushLength : out std_logic;        
      lPushControl : out std_logic;  
      lRdyLength : in std_logic;
      lRdyControl : in std_logic;
      lAckLength : in std_logic;
      lAckControl : in std_logic;
      
      TxLengthEmpty : in std_logic;
      RxLengthEmpty : in std_logic;
      
      prog_spien : in std_logic;
           
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
      S_AXI_RREADY	: in std_logic
   );
end component axi_dpti_v1_0_AXI_LITE;
--------------------------------------------------------------------------------------------------------------------------

component HandshakeData is
   Generic (
      kDataWidth : natural := 32);
   Port (
      InClk : in STD_LOGIC;
      OutClk : in STD_LOGIC;
      iData : in STD_LOGIC_VECTOR (kDataWidth-1 downto 0);
      oData : out STD_LOGIC_VECTOR (kDataWidth-1 downto 0);
      iPush : in STD_LOGIC;
      iRdy : out STD_LOGIC;
      oAck : in STD_LOGIC := '1';
      oValid : out STD_LOGIC;
      aReset : in std_logic
   );
end component;    

--------------------------------------------------------------------------------------------------------------------------

component fifo_generator_dpti 
   PORT (
      m_aclk : IN STD_LOGIC;
      s_aclk : IN STD_LOGIC;
      s_aresetn : IN STD_LOGIC;
      s_axis_tvalid : IN STD_LOGIC;
      s_axis_tready : OUT STD_LOGIC;
      s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axis_tkeep : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axis_tlast : IN STD_LOGIC;
      m_axis_tvalid : OUT STD_LOGIC;
      m_axis_tready : IN STD_LOGIC;
      m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axis_tkeep : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axis_tlast : OUT STD_LOGIC
   );
end component; 

--------------------------------------------------------------------------------------------------------------------------

component AXI_S_to_DPTI_converter is
   Port ( 
      pResetnTx : in std_logic;
      PROG_CLK : in std_logic;    
      pTxe : in std_logic;
      pWr : out std_logic;
      pDataOut : out std_logic_vector (7 downto 0);
      pOutTready : out std_logic;
      pInTdata : in std_logic_vector (31 downto 0);
      pInTvalid : in std_logic;
      pInTlast : in std_logic;
      pInTkeep : in std_logic_vector (3 downto 0);
      pAXI_L_Length : in std_logic_vector (31 downto 0);
      pOvalidLength : in std_logic;
      pAXI_L_Control : in std_logic_vector (31 downto 0);
      pOvalidControl : in std_logic;       
      pTxLengthEmpty : out std_logic
   );
end component; 

--------------------------------------------------------------------------------------------------------------------------

component DPTI_to_AXI_S_converter is
   Port ( 
      pResetnRx : in std_logic;
      PROG_CLK : in std_logic;    
      pRxf : in std_logic;    
      pRd : out std_logic;        
      pOe : out std_logic;        
      pDataIn : in std_logic_vector (7 downto 0);
      pInTready : in std_logic;
      pOutTdata : out std_logic_vector (31 downto 0);
      pOutTvalid : out std_logic;
      pOutTlast : out std_logic;
      pOutTkeep : out std_logic_vector (3 downto 0);
      pAXI_L_Length : in std_logic_vector (31 downto 0);
      pOvalidLength : in std_logic;
      pAXI_L_Control : in std_logic_vector (31 downto 0);
      pOvalidControl : in std_logic;     
      pRxLengthEmpty : out std_logic
   );
end component; 

--------------------------------------------------------------------------------------------------------------------------

signal pCtlDataOut : std_logic_vector (7 downto 0);
signal pCtlDataIn : std_logic_vector (7 downto 0);
signal pCtlOe : std_logic;

signal pCtlInTready : std_logic;
signal pCtlOutTdata : std_logic_vector(31 downto 0);
signal pCtlOutTvalid : std_logic;
signal pCtlOutTlast : std_logic;
signal pCtlOutTkeep : std_logic_vector(3 downto 0);

signal pCtlOutTready : std_logic;
signal pCtlInTdata : std_logic_vector(31 downto 0);
signal pCtlInTvalid : std_logic;
signal pCtlInTlast : std_logic;
signal pCtlInTkeep : std_logic_vector(3 downto 0);

signal lCtlAXI_LiteLengthReg : std_logic_vector(31 downto 0);
signal lCtlAXI_LiteControlReg : std_logic_vector(31 downto 0);
signal lCtlAXI_LiteStatusReg : std_logic_vector(31 downto 0);

signal lCtlPushLength : std_logic;
signal lCtlPushControl : std_logic;

---------------------------------------------------
--SYNC_ASYNC---------------------------------------
---------------------------------------------------
signal pControlRegSyncd : std_logic_vector (31 downto 0);
signal pLengthRegSyncd : std_logic_vector (31 downto 0);
--signal pStatusReg : std_logic_vector (31 downto 0);

signal lCtlRdyLength : std_logic; 
signal pCtlAckLength : std_logic := '0';
signal lCtlAckLength : std_logic; 
signal pCtlValidLength : std_logic; 
signal aCtlResetLength : std_logic :='1'; 
 
signal lCtlRdyControl : std_logic;  
signal pCtlAckControl : std_logic := '0';
signal lCtlAckControl : std_logic; 
signal pCtlValidControl : std_logic;
signal aCtlResetControl : std_logic :='1';

signal iPushStatus : std_logic := '0';
signal iRdyStatus : std_logic;  
signal oValidStatus : std_logic;
signal aResetStatus : std_logic :='1';

signal pCtlRxLengthEmpty : std_logic :='1';
signal pCtlTxLengthEmpty : std_logic :='1';
signal lCtlRxLengthEmpty : std_logic :='1';
signal lCtlTxLengthEmpty : std_logic :='1';

--------------------------------------------------------------------------------------------------------------------------

signal spien_syncReg : std_logic;
signal aCtlResetnRx : std_logic;
signal aCtlResetnTx : std_logic;
signal pAXI_LiteReset : std_logic := '0';
signal pM_AXIS_Reset : std_logic := '0';
signal pS_AXIS_Reset : std_logic := '0';

--------------------------------------------------------------------------------------------------------------------------
-- PLL and BUFG signals
--------------------------------------------------------------------------------------------------------------------------

signal PLL_Fb_OutClk : std_logic;
signal PLL_Fb_InClk : std_logic;
signal PROG_CLK : std_logic;
signal aPLL_Reset : std_logic;
signal aPLL_Pwrdwn : std_logic := '0';
signal pPLL_Locked : std_logic := '0';  

--------------------------------------------------------------------------------------------------------------------------	

signal aSoft_Reset:std_logic;
signal pSoft_Reset:std_logic;

signal prog_rdn_0 :std_logic;
signal prog_wrn_0 : std_logic;
signal prog_oen_0 : std_logic;
signal pCtlOeN :std_logic;

signal clearFlag:std_logic;

begin

pCtlOeN <= not pCtlOe;

aSoft_Reset <= lCtlAXI_LiteControlReg(2);
prog_rdn <= prog_rdn_0;
prog_wrn <= prog_wrn_0;
prog_oen <= prog_oen_0;

-- prog_spien is used as a sync reset signal by the PC.
-- spien_syncReg logic. Latch falling edge of prog_spien, prog_clk will stop. Wait until PROG_CLK is enabled again to disable reset
process (prog_clko, prog_spien)begin
    if(prog_spien='1')then
        spien_syncreg<=prog_spien;
    else if rising_edge(prog_clko)then
            spien_syncReg<=prog_spien;
        end if;
    end if;
end process;

-- reset signals
aCtlResetnTx <= pPLL_Locked and pAXI_LiteReset and pS_AXIS_Reset and not pSoft_Reset and not spien_syncReg; --pPLL_Locked and 
aCtlResetnRx <= pPLL_Locked and pAXI_LiteReset and pM_AXIS_Reset and not pSoft_Reset and not spien_syncReg; --pPLL_Locked and 
aPLL_Reset <= '0';--prog_spien;

-- status register
--pStatusReg (0) <= pCtlTxLengthEmpty;
--pStatusReg (16) <= pCtlRxLengthEmpty;
--pStatusReg (15 downto 1) <= (others => '0'); 
--pStatusReg (31 downto 17) <= (others => '0'); 

-- IOBUF is implemented
DataIOBUFs: for i in 0 to 7 generate
IOBUF_inst : IOBUF
   generic map (
      DRIVE => 12,
      IOSTANDARD => "DEFAULT",
      SLEW => "SLOW")
   port map (
      O => pCtlDataIn(i),     -- Buffer output
      IO => prog_d(i),   -- Buffer inout port (connect directly to top-level port)
      I => pCtlDataOut(i),     -- Buffer input
      T => pCtlOeN      -- 3-state enable input, high=input, low=output 
   );
   end generate DataIOBUFs;

--prog_d <= pCtlDataOut when pCtlOe = '1' else "ZZZZZZZZ";    
--pCtlDataIn <= prog_d;

-- SIWU signal is not used
prog_siwun <= '1';  

prog_oen_0 <= pCtlOe;

aCtlResetLength <= not pPLL_Locked;
aCtlResetControl <= not pPLL_Locked;

PROG_CLK <= Pll_Fb_InClk;

--------------------------------------------------------------------------------------------------------------------------
-- Instantiations
--------------------------------------------------------------------------------------------------------------------------

BUFG_inst : BUFG  -- used for PLL feedback clock
   port map (
      O => Pll_Fb_InClk, -- 1-bit output: Clock output
      I => Pll_Fb_OutClk  -- 1-bit input: Clock input
   );
   


--BUFIO_Inst : BUFR
--    generic map (
--      BUFR_DIVIDE => "BYPASS",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
--      SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
--   )
--    port map (
--     O => PROG_CLK,
--     I => prog_clko,
--     CE => '0', -- Unused in BYPASS mode
--     CLR => '0' -- Unused in BYPASS mode
-- );

--------------------------------------------------------------------------------------------------------------------------

PLLE2_BASE_inst : PLLE2_BASE -- PLL used to correct BUFG delay for prog_clko
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
      CLKFBOUT_MULT => 15,        -- Multiply value for all CLKOUT, (2-64)
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
      CLKIN1_PERIOD => 16.67,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT0_DIVIDE => 15,
      CLKOUT1_DIVIDE => 1,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
      STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
--      CLKOUT0 => PROG_CLK,   -- 1-bit output: CLKOUT0        
--      CLKOUT1 => CLKOUT1,   -- 1-bit output: CLKOUT1
--      CLKOUT2 => CLKOUT2,   -- 1-bit output: CLKOUT2
--      CLKOUT3 => CLKOUT3,   -- 1-bit output: CLKOUT3
--      CLKOUT4 => CLKOUT4,   -- 1-bit output: CLKOUT4
--      CLKOUT5 => CLKOUT5,   -- 1-bit output: CLKOUT5
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => Pll_Fb_OutClk, -- 1-bit output: Feedback clock
      LOCKED => pPLL_Locked,     -- 1-bit output: LOCK
      CLKIN1 => prog_clko,     -- 1-bit input: Input clock
      -- Control Ports: 1-bit (each) input: PLL control ports
      PWRDWN => aPLL_Pwrdwn,     -- 1-bit input: Power-down
      RST => aPLL_Reset,           -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => Pll_Fb_InClk    -- 1-bit input: Feedback clock
   );

--------------------------------------------------------------------------------------------------------------------------

-- Instantiation of Axi Bus Interface AXI_LITE
axi_dpti_v1_0_AXI_LITE_inst : axi_dpti_v1_0_AXI_LITE
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_AXI_LITE_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_AXI_LITE_ADDR_WIDTH
	)
	port map (
      lAXI_LiteLengthReg => lCtlAXI_LiteLengthReg,
      lAXI_LiteControlReg => lCtlAXI_LiteControlReg,
      lAXI_LiteStatusReg => lCtlAXI_LiteStatusReg,
      lPushLength => lCtlPushLength,
      lPushControl => lCtlPushControl,
      lRdyLength => lCtlRdyLength,
      lRdyControl => lCtlRdyControl,  
      lAckLength => lCtlAckLength,    
      lAckControl => lCtlAckControl,
      
      TxLengthEmpty => lCtlTxLengthEmpty,
      RxLengthEmpty => lCtlRxLengthEmpty,
      
      prog_spien => prog_spien,

		S_AXI_ACLK	=> axi_lite_aclk,
		S_AXI_ARESETN	=> axi_lite_aresetn,
		S_AXI_AWADDR	=> axi_lite_awaddr,
		S_AXI_AWPROT	=> axi_lite_awprot,
		S_AXI_AWVALID	=> axi_lite_awvalid,
		S_AXI_AWREADY	=> axi_lite_awready,
		S_AXI_WDATA	=> axi_lite_wdata,
		S_AXI_WSTRB	=> axi_lite_wstrb,
		S_AXI_WVALID	=> axi_lite_wvalid,
		S_AXI_WREADY	=> axi_lite_wready,
		S_AXI_BRESP	=> axi_lite_bresp,
		S_AXI_BVALID	=> axi_lite_bvalid,
		S_AXI_BREADY	=> axi_lite_bready,
		S_AXI_ARADDR	=> axi_lite_araddr,
		S_AXI_ARPROT	=> axi_lite_arprot,
		S_AXI_ARVALID	=> axi_lite_arvalid,
		S_AXI_ARREADY	=> axi_lite_arready,
		S_AXI_RDATA	=> axi_lite_rdata,
		S_AXI_RRESP	=> axi_lite_rresp,
		S_AXI_RVALID	=> axi_lite_rvalid,
		S_AXI_RREADY	=> axi_lite_rready
	);

	-- Add user logic here
--------------------------------------------------------------------------------------------------------------------------
   
in_length_sync : HandshakeData -- synchronization module for AXI LITE LENGTH register crossing to PROG_CLK clock domain 
   Port map (
      InClk => axi_lite_aclk,
      OutClk => PROG_CLK,
      iData => lCtlAXI_LiteLengthReg,
      oData => pLengthRegSyncd,   -- synchronized output
      iPush => lCtlPushLength,
      iRdy => lCtlRdyLength,  
      oAck => pCtlAckLength,  
      oValid => pCtlValidLength,   -- indicates valid synchronized data
      aReset => aCtlResetLength
   );
--------------------------------------------------------------------------------------------------------------------------
in_control_sync : HandshakeData -- synchronization module for AXI LITE CONTROL register crossing to PROG_CLK clock domain
   Port map (
      InClk => axi_lite_aclk,
      OutClk => PROG_CLK,
      iData => lCtlAXI_LiteControlReg,
      oData => pControlRegSyncd,  -- synchronized output
      iPush => lCtlPushControl,
      iRdy => lCtlRdyControl,  
      oAck => pCtlAckControl,  
      oValid => pCtlValidControl,  -- indicates valid synchronized data
      aReset => aCtlResetControl
   );
--------------------------------------------------------------------------------------------------------------------------

SyncAsync_oAckLength: entity work.SyncAsync
    generic map (
        kResetTo => '0',
        kStages => 2)
        port map (
        aReset => '0',
        aIn => pCtlAckLength,
        OutClk => axi_lite_aclk,
        oOut => lCtlAckLength);

--------------------------------------------------------------------------------------------------------------------------

SyncAsync_oAckControl: entity work.SyncAsync
    generic map (
        kResetTo => '0',
        kStages => 2)
        port map (
        aReset => '0',
        aIn => pCtlAckControl,
        OutClk => axi_lite_aclk,
        oOut => lCtlAckControl);
        
--------------------------------------------------------------------------------------------------------------------------
        
--GenSyncStatusReg: for i in 0 to 31 generate  -- STATUS register sync module (from PROG_CLK domain to AXI_L_CLK domain)
--SyncAsyncMultiple: entity work.SyncAsync
--   generic map (
--      kResetTo => '0',
--      kStages => 2) --use double FF synchronizer
--   port map (
--      aReset => '0',
--      aIn => pStatusReg(i),
--      OutClk => axi_lite_aclk,
--      oOut => lCtlAXI_LiteStatusReg(i)
--   );
--end generate GenSyncStatusReg;

SyncAsyncTxLenEmpty: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => '0',
      aIn => pCtlTxLengthEmpty,
      OutClk => axi_lite_aclk,
      oOut => lCtlTxLengthEmpty
   );
   
SyncAsyncRxLenEmpty: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => '0',
      aIn => pCtlRxLengthEmpty,
      OutClk => axi_lite_aclk,
      oOut => lCtlRxLengthEmpty
   );

------------------------------------------------------------------------------------------------

SyncReset_AXI_LITE: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => axi_lite_aresetn,
      OutClk => PROG_CLK,
      oRst => pAXI_LiteReset);
      
SyncReset_M_AXIS: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => m_axis_aresetn,
      OutClk => PROG_CLK,
      oRst => pM_AXIS_Reset);

SyncReset_S_AXIS: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => s_axis_aresetn,
      OutClk => PROG_CLK,
      oRst => pS_AXIS_Reset);    
      
SyncReset_SoftReset: entity work.ResetBridge
   generic map (
      kPolarity => '1')
   port map (
      aRst => aSoft_Reset,
      OutClk => PROG_CLK,
      oRst => pSoft_Reset);   

------------------------------------------------------------------------------------------------

RX_fifo : fifo_generator_dpti PORT MAP (  -- AXI STREAM FIFO : used only for clock domain crossing. low capacity
      m_aclk => m_axis_aclk,
      s_aclk => PROG_CLK,
      s_aresetn => aCtlResetnRx,
      s_axis_tvalid => pCtlOutTvalid,
      s_axis_tready => pCtlInTready,
      s_axis_tdata => pCtlOutTdata,
      s_axis_tkeep => pCtlOutTkeep,
      s_axis_tlast => pCtlOutTlast,
      m_axis_tvalid => m_axis_tvalid,
      m_axis_tready => m_axis_tready,
      m_axis_tdata => m_axis_tdata,
      m_axis_tkeep => m_axis_tkeep,
      m_axis_tlast => m_axis_tlast
      );

----------------------------------------------------------------------------------------------------------   
 
TX_fifo : fifo_generator_dpti PORT MAP (  -- AXI STREAM FIFO : used only for clock domain crossing. low capacity
      m_aclk => PROG_CLK,
      s_aclk => s_axis_aclk,
      s_aresetn => aCtlResetnTx,
      s_axis_tvalid => s_axis_tvalid,
      s_axis_tready => s_axis_tready,
      s_axis_tdata => s_axis_tdata,
      s_axis_tkeep => s_axis_tkeep,
      s_axis_tlast => s_axis_tlast,
      m_axis_tvalid => pCtlInTvalid,
      m_axis_tready => pCtlOutTready,
      m_axis_tdata => pCtlInTdata,
      m_axis_tkeep => pCtlInTkeep,
      m_axis_tlast => pCtlInTlast
      );
        
----------------------------------------------------------------------------------------------------------

AXI_S_to_DPTI_inst : AXI_S_to_DPTI_converter PORT MAP (  -- converts 32bit AXI STREAM from TX_FIFO data to 8bit data which is then sent to the DPTI interface 
      pResetnTx => aCtlResetnTx,
      PROG_CLK => PROG_CLK,
      pTxe => prog_txen,
      pWr => prog_wrn_0,
      pDataOut => pCtlDataOut,
        
      pOutTready => pCtlOutTready,
      pInTdata => pCtlInTdata,
      pInTvalid => pCtlInTvalid,
      pInTlast => pCtlInTlast,
      pInTkeep => pCtlInTkeep,
          
      pAXI_L_Length => pLengthRegSyncd,
      pOvalidLength => pCtlValidLength,
      pAXI_L_Control => pControlRegSyncd,
      pOvalidControl => pCtlValidControl,
      pTxLengthEmpty => pCtlTxLengthEmpty 
        
      );
       
----------------------------------------------------------------------------------------------------------

DPTI_to_AXI_S_inst : DPTI_to_AXI_S_converter PORT MAP (  -- converts 8bit data received from the DPTI interface to 32bit AXI STREAM data sent to RX_FIFO
      pResetnRx => aCtlResetnRx,
      PROG_CLK => PROG_CLK,
      pRxf => prog_rxen,
      pRd => prog_rdn_0,
      pOe => pCtlOe,
      pDataIn => pCtlDataIn,
               
      pInTready => pCtlInTready,
      pOutTdata => pCtlOutTdata,
      pOutTvalid => pCtlOutTvalid,
      pOutTlast => pCtlOutTlast,
      pOutTkeep => pCtlOutTkeep,
           
      pAXI_L_Length => pLengthRegSyncd,
      pOvalidLength => pCtlValidLength,
      pAXI_L_Control => pControlRegSyncd,
      pOvalidControl => pCtlValidControl,
      pRxLengthEmpty => pCtlRxLengthEmpty
      
      );
        
----------------------------------------------------------------------------------------------------------
-- processes
----------------------------------------------------------------------------------------------------------

Length_oACK: process (PROG_CLK,  pCtlValidLength) is -- generates auxiliary signals for LENGTH register HandshakeData module 
variable count : integer range 0 to 2;
begin
if rising_edge (PROG_CLK) then
   if pCtlValidLength = '0' then
      count := 2;
      pCtlAckLength <= '0';
   elsif count = 2 then
      pCtlAckLength <= '1';
      count := count - 1;
   elsif count = 1 then
      pCtlAckLength <= '0';
      count := 0;
   else 
      pCtlAckLength <= '0';
      count := count - 1;
   end if;
end if;
end process;   
    
----------------------------------------------------------------------------------------------------------
    
Control_oACK: process (PROG_CLK,  pCtlValidControl) is -- generates auxiliary signals for CONTROL register HandshakeData module 
variable count : integer range 0 to 2;
begin
if rising_edge (PROG_CLK) then
   if pCtlValidControl = '0' then
      count := 2;
      pCtlAckControl <= '0';
   elsif count = 2 then
      pCtlAckControl <= '1';
      count := count - 1;
   elsif count = 1 then
      pCtlAckControl <= '0';
      count := 0;
   else 
      pCtlAckControl <= '0';
      count := count - 1;
   end if;
end if;
end process;

----------------------------------------------------------------------------------------------------------
	-- User logic ends

end arch_imp;
