-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Mon Jan 24 18:33:06 2022
-- Host        : Duller running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top ps_system_uiFDMA_0_1 -prefix
--               ps_system_uiFDMA_0_1_ ps_system_uiFDMA_0_1_sim_netlist.vhdl
-- Design      : ps_system_uiFDMA_0_1
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps_system_uiFDMA_0_1_uiFDMA is
  port (
    fdma_wvalid : out STD_LOGIC;
    fdma_rvalid : out STD_LOGIC;
    M_AXI_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    fdma_wstart_locked_reg_0 : out STD_LOGIC;
    M_AXI_WVALID : out STD_LOGIC;
    M_AXI_WLAST : out STD_LOGIC;
    fdma_rstart_locked_reg_0 : out STD_LOGIC;
    M_AXI_RREADY : out STD_LOGIC;
    M_AXI_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXI_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXI_AWVALID : out STD_LOGIC;
    M_AXI_ARVALID : out STD_LOGIC;
    M_AXI_ACLK : in STD_LOGIC;
    M_AXI_WREADY : in STD_LOGIC;
    fdma_wready : in STD_LOGIC;
    fdma_wareq : in STD_LOGIC;
    M_AXI_ARESETN : in STD_LOGIC;
    fdma_waddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    fdma_wsize : in STD_LOGIC_VECTOR ( 15 downto 0 );
    M_AXI_RVALID : in STD_LOGIC;
    fdma_rready : in STD_LOGIC;
    fdma_rareq : in STD_LOGIC;
    fdma_raddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    fdma_rsize : in STD_LOGIC_VECTOR ( 15 downto 0 );
    M_AXI_AWREADY : in STD_LOGIC;
    M_AXI_ARREADY : in STD_LOGIC
  );
end ps_system_uiFDMA_0_1_uiFDMA;

architecture STRUCTURE of ps_system_uiFDMA_0_1_uiFDMA is
  signal \^m_axi_araddr\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \M_AXI_ARLEN[7]_INST_0_i_1_n_0\ : STD_LOGIC;
  signal \^m_axi_arvalid\ : STD_LOGIC;
  signal \^m_axi_awaddr\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \M_AXI_AWLEN[7]_INST_0_i_1_n_0\ : STD_LOGIC;
  signal \^m_axi_awvalid\ : STD_LOGIC;
  signal \axi_araddr[0]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr[13]_i_2_n_0\ : STD_LOGIC;
  signal \axi_araddr[13]_i_3_n_0\ : STD_LOGIC;
  signal \axi_araddr[13]_i_4_n_0\ : STD_LOGIC;
  signal \axi_araddr[13]_i_5_n_0\ : STD_LOGIC;
  signal \axi_araddr[13]_i_6_n_0\ : STD_LOGIC;
  signal \axi_araddr[13]_i_7_n_0\ : STD_LOGIC;
  signal \axi_araddr[17]_i_2_n_0\ : STD_LOGIC;
  signal \axi_araddr[17]_i_3_n_0\ : STD_LOGIC;
  signal \axi_araddr[17]_i_4_n_0\ : STD_LOGIC;
  signal \axi_araddr[17]_i_5_n_0\ : STD_LOGIC;
  signal \axi_araddr[1]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr[21]_i_2_n_0\ : STD_LOGIC;
  signal \axi_araddr[21]_i_3_n_0\ : STD_LOGIC;
  signal \axi_araddr[21]_i_4_n_0\ : STD_LOGIC;
  signal \axi_araddr[21]_i_5_n_0\ : STD_LOGIC;
  signal \axi_araddr[25]_i_2_n_0\ : STD_LOGIC;
  signal \axi_araddr[25]_i_3_n_0\ : STD_LOGIC;
  signal \axi_araddr[25]_i_4_n_0\ : STD_LOGIC;
  signal \axi_araddr[25]_i_5_n_0\ : STD_LOGIC;
  signal \axi_araddr[29]_i_2_n_0\ : STD_LOGIC;
  signal \axi_araddr[29]_i_3_n_0\ : STD_LOGIC;
  signal \axi_araddr[29]_i_4_n_0\ : STD_LOGIC;
  signal \axi_araddr[29]_i_5_n_0\ : STD_LOGIC;
  signal \axi_araddr[31]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr[31]_i_3_n_0\ : STD_LOGIC;
  signal \axi_araddr[31]_i_4_n_0\ : STD_LOGIC;
  signal \axi_araddr[5]_i_2_n_0\ : STD_LOGIC;
  signal \axi_araddr[5]_i_3_n_0\ : STD_LOGIC;
  signal \axi_araddr[5]_i_4_n_0\ : STD_LOGIC;
  signal \axi_araddr[5]_i_5_n_0\ : STD_LOGIC;
  signal \axi_araddr[5]_i_6_n_0\ : STD_LOGIC;
  signal \axi_araddr[5]_i_7_n_0\ : STD_LOGIC;
  signal \axi_araddr[5]_i_8_n_0\ : STD_LOGIC;
  signal \axi_araddr[9]_i_2_n_0\ : STD_LOGIC;
  signal \axi_araddr[9]_i_3_n_0\ : STD_LOGIC;
  signal \axi_araddr[9]_i_4_n_0\ : STD_LOGIC;
  signal \axi_araddr[9]_i_5_n_0\ : STD_LOGIC;
  signal \axi_araddr[9]_i_6_n_0\ : STD_LOGIC;
  signal \axi_araddr[9]_i_7_n_0\ : STD_LOGIC;
  signal \axi_araddr[9]_i_8_n_0\ : STD_LOGIC;
  signal \axi_araddr[9]_i_9_n_0\ : STD_LOGIC;
  signal \axi_araddr_reg[13]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr_reg[13]_i_1_n_1\ : STD_LOGIC;
  signal \axi_araddr_reg[13]_i_1_n_2\ : STD_LOGIC;
  signal \axi_araddr_reg[13]_i_1_n_3\ : STD_LOGIC;
  signal \axi_araddr_reg[13]_i_1_n_4\ : STD_LOGIC;
  signal \axi_araddr_reg[13]_i_1_n_5\ : STD_LOGIC;
  signal \axi_araddr_reg[13]_i_1_n_6\ : STD_LOGIC;
  signal \axi_araddr_reg[13]_i_1_n_7\ : STD_LOGIC;
  signal \axi_araddr_reg[17]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr_reg[17]_i_1_n_1\ : STD_LOGIC;
  signal \axi_araddr_reg[17]_i_1_n_2\ : STD_LOGIC;
  signal \axi_araddr_reg[17]_i_1_n_3\ : STD_LOGIC;
  signal \axi_araddr_reg[17]_i_1_n_4\ : STD_LOGIC;
  signal \axi_araddr_reg[17]_i_1_n_5\ : STD_LOGIC;
  signal \axi_araddr_reg[17]_i_1_n_6\ : STD_LOGIC;
  signal \axi_araddr_reg[17]_i_1_n_7\ : STD_LOGIC;
  signal \axi_araddr_reg[21]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr_reg[21]_i_1_n_1\ : STD_LOGIC;
  signal \axi_araddr_reg[21]_i_1_n_2\ : STD_LOGIC;
  signal \axi_araddr_reg[21]_i_1_n_3\ : STD_LOGIC;
  signal \axi_araddr_reg[21]_i_1_n_4\ : STD_LOGIC;
  signal \axi_araddr_reg[21]_i_1_n_5\ : STD_LOGIC;
  signal \axi_araddr_reg[21]_i_1_n_6\ : STD_LOGIC;
  signal \axi_araddr_reg[21]_i_1_n_7\ : STD_LOGIC;
  signal \axi_araddr_reg[25]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr_reg[25]_i_1_n_1\ : STD_LOGIC;
  signal \axi_araddr_reg[25]_i_1_n_2\ : STD_LOGIC;
  signal \axi_araddr_reg[25]_i_1_n_3\ : STD_LOGIC;
  signal \axi_araddr_reg[25]_i_1_n_4\ : STD_LOGIC;
  signal \axi_araddr_reg[25]_i_1_n_5\ : STD_LOGIC;
  signal \axi_araddr_reg[25]_i_1_n_6\ : STD_LOGIC;
  signal \axi_araddr_reg[25]_i_1_n_7\ : STD_LOGIC;
  signal \axi_araddr_reg[29]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr_reg[29]_i_1_n_1\ : STD_LOGIC;
  signal \axi_araddr_reg[29]_i_1_n_2\ : STD_LOGIC;
  signal \axi_araddr_reg[29]_i_1_n_3\ : STD_LOGIC;
  signal \axi_araddr_reg[29]_i_1_n_4\ : STD_LOGIC;
  signal \axi_araddr_reg[29]_i_1_n_5\ : STD_LOGIC;
  signal \axi_araddr_reg[29]_i_1_n_6\ : STD_LOGIC;
  signal \axi_araddr_reg[29]_i_1_n_7\ : STD_LOGIC;
  signal \axi_araddr_reg[31]_i_2_n_3\ : STD_LOGIC;
  signal \axi_araddr_reg[31]_i_2_n_6\ : STD_LOGIC;
  signal \axi_araddr_reg[31]_i_2_n_7\ : STD_LOGIC;
  signal \axi_araddr_reg[5]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr_reg[5]_i_1_n_1\ : STD_LOGIC;
  signal \axi_araddr_reg[5]_i_1_n_2\ : STD_LOGIC;
  signal \axi_araddr_reg[5]_i_1_n_3\ : STD_LOGIC;
  signal \axi_araddr_reg[5]_i_1_n_4\ : STD_LOGIC;
  signal \axi_araddr_reg[5]_i_1_n_5\ : STD_LOGIC;
  signal \axi_araddr_reg[5]_i_1_n_6\ : STD_LOGIC;
  signal \axi_araddr_reg[5]_i_1_n_7\ : STD_LOGIC;
  signal \axi_araddr_reg[9]_i_1_n_0\ : STD_LOGIC;
  signal \axi_araddr_reg[9]_i_1_n_1\ : STD_LOGIC;
  signal \axi_araddr_reg[9]_i_1_n_2\ : STD_LOGIC;
  signal \axi_araddr_reg[9]_i_1_n_3\ : STD_LOGIC;
  signal \axi_araddr_reg[9]_i_1_n_4\ : STD_LOGIC;
  signal \axi_araddr_reg[9]_i_1_n_5\ : STD_LOGIC;
  signal \axi_araddr_reg[9]_i_1_n_6\ : STD_LOGIC;
  signal \axi_araddr_reg[9]_i_1_n_7\ : STD_LOGIC;
  signal axi_arvalid_i_1_n_0 : STD_LOGIC;
  signal \axi_awaddr[0]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr[13]_i_2_n_0\ : STD_LOGIC;
  signal \axi_awaddr[13]_i_3_n_0\ : STD_LOGIC;
  signal \axi_awaddr[13]_i_4_n_0\ : STD_LOGIC;
  signal \axi_awaddr[13]_i_5_n_0\ : STD_LOGIC;
  signal \axi_awaddr[13]_i_6_n_0\ : STD_LOGIC;
  signal \axi_awaddr[13]_i_7_n_0\ : STD_LOGIC;
  signal \axi_awaddr[17]_i_2_n_0\ : STD_LOGIC;
  signal \axi_awaddr[17]_i_3_n_0\ : STD_LOGIC;
  signal \axi_awaddr[17]_i_4_n_0\ : STD_LOGIC;
  signal \axi_awaddr[17]_i_5_n_0\ : STD_LOGIC;
  signal \axi_awaddr[1]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr[21]_i_2_n_0\ : STD_LOGIC;
  signal \axi_awaddr[21]_i_3_n_0\ : STD_LOGIC;
  signal \axi_awaddr[21]_i_4_n_0\ : STD_LOGIC;
  signal \axi_awaddr[21]_i_5_n_0\ : STD_LOGIC;
  signal \axi_awaddr[25]_i_2_n_0\ : STD_LOGIC;
  signal \axi_awaddr[25]_i_3_n_0\ : STD_LOGIC;
  signal \axi_awaddr[25]_i_4_n_0\ : STD_LOGIC;
  signal \axi_awaddr[25]_i_5_n_0\ : STD_LOGIC;
  signal \axi_awaddr[29]_i_2_n_0\ : STD_LOGIC;
  signal \axi_awaddr[29]_i_3_n_0\ : STD_LOGIC;
  signal \axi_awaddr[29]_i_4_n_0\ : STD_LOGIC;
  signal \axi_awaddr[29]_i_5_n_0\ : STD_LOGIC;
  signal \axi_awaddr[31]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr[31]_i_3_n_0\ : STD_LOGIC;
  signal \axi_awaddr[31]_i_4_n_0\ : STD_LOGIC;
  signal \axi_awaddr[5]_i_2_n_0\ : STD_LOGIC;
  signal \axi_awaddr[5]_i_3_n_0\ : STD_LOGIC;
  signal \axi_awaddr[5]_i_4_n_0\ : STD_LOGIC;
  signal \axi_awaddr[5]_i_5_n_0\ : STD_LOGIC;
  signal \axi_awaddr[5]_i_6_n_0\ : STD_LOGIC;
  signal \axi_awaddr[5]_i_7_n_0\ : STD_LOGIC;
  signal \axi_awaddr[5]_i_8_n_0\ : STD_LOGIC;
  signal \axi_awaddr[9]_i_2_n_0\ : STD_LOGIC;
  signal \axi_awaddr[9]_i_3_n_0\ : STD_LOGIC;
  signal \axi_awaddr[9]_i_4_n_0\ : STD_LOGIC;
  signal \axi_awaddr[9]_i_5_n_0\ : STD_LOGIC;
  signal \axi_awaddr[9]_i_6_n_0\ : STD_LOGIC;
  signal \axi_awaddr[9]_i_7_n_0\ : STD_LOGIC;
  signal \axi_awaddr[9]_i_8_n_0\ : STD_LOGIC;
  signal \axi_awaddr[9]_i_9_n_0\ : STD_LOGIC;
  signal \axi_awaddr_reg[13]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr_reg[13]_i_1_n_1\ : STD_LOGIC;
  signal \axi_awaddr_reg[13]_i_1_n_2\ : STD_LOGIC;
  signal \axi_awaddr_reg[13]_i_1_n_3\ : STD_LOGIC;
  signal \axi_awaddr_reg[13]_i_1_n_4\ : STD_LOGIC;
  signal \axi_awaddr_reg[13]_i_1_n_5\ : STD_LOGIC;
  signal \axi_awaddr_reg[13]_i_1_n_6\ : STD_LOGIC;
  signal \axi_awaddr_reg[13]_i_1_n_7\ : STD_LOGIC;
  signal \axi_awaddr_reg[17]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr_reg[17]_i_1_n_1\ : STD_LOGIC;
  signal \axi_awaddr_reg[17]_i_1_n_2\ : STD_LOGIC;
  signal \axi_awaddr_reg[17]_i_1_n_3\ : STD_LOGIC;
  signal \axi_awaddr_reg[17]_i_1_n_4\ : STD_LOGIC;
  signal \axi_awaddr_reg[17]_i_1_n_5\ : STD_LOGIC;
  signal \axi_awaddr_reg[17]_i_1_n_6\ : STD_LOGIC;
  signal \axi_awaddr_reg[17]_i_1_n_7\ : STD_LOGIC;
  signal \axi_awaddr_reg[21]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr_reg[21]_i_1_n_1\ : STD_LOGIC;
  signal \axi_awaddr_reg[21]_i_1_n_2\ : STD_LOGIC;
  signal \axi_awaddr_reg[21]_i_1_n_3\ : STD_LOGIC;
  signal \axi_awaddr_reg[21]_i_1_n_4\ : STD_LOGIC;
  signal \axi_awaddr_reg[21]_i_1_n_5\ : STD_LOGIC;
  signal \axi_awaddr_reg[21]_i_1_n_6\ : STD_LOGIC;
  signal \axi_awaddr_reg[21]_i_1_n_7\ : STD_LOGIC;
  signal \axi_awaddr_reg[25]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr_reg[25]_i_1_n_1\ : STD_LOGIC;
  signal \axi_awaddr_reg[25]_i_1_n_2\ : STD_LOGIC;
  signal \axi_awaddr_reg[25]_i_1_n_3\ : STD_LOGIC;
  signal \axi_awaddr_reg[25]_i_1_n_4\ : STD_LOGIC;
  signal \axi_awaddr_reg[25]_i_1_n_5\ : STD_LOGIC;
  signal \axi_awaddr_reg[25]_i_1_n_6\ : STD_LOGIC;
  signal \axi_awaddr_reg[25]_i_1_n_7\ : STD_LOGIC;
  signal \axi_awaddr_reg[29]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr_reg[29]_i_1_n_1\ : STD_LOGIC;
  signal \axi_awaddr_reg[29]_i_1_n_2\ : STD_LOGIC;
  signal \axi_awaddr_reg[29]_i_1_n_3\ : STD_LOGIC;
  signal \axi_awaddr_reg[29]_i_1_n_4\ : STD_LOGIC;
  signal \axi_awaddr_reg[29]_i_1_n_5\ : STD_LOGIC;
  signal \axi_awaddr_reg[29]_i_1_n_6\ : STD_LOGIC;
  signal \axi_awaddr_reg[29]_i_1_n_7\ : STD_LOGIC;
  signal \axi_awaddr_reg[31]_i_2_n_3\ : STD_LOGIC;
  signal \axi_awaddr_reg[31]_i_2_n_6\ : STD_LOGIC;
  signal \axi_awaddr_reg[31]_i_2_n_7\ : STD_LOGIC;
  signal \axi_awaddr_reg[5]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr_reg[5]_i_1_n_1\ : STD_LOGIC;
  signal \axi_awaddr_reg[5]_i_1_n_2\ : STD_LOGIC;
  signal \axi_awaddr_reg[5]_i_1_n_3\ : STD_LOGIC;
  signal \axi_awaddr_reg[5]_i_1_n_4\ : STD_LOGIC;
  signal \axi_awaddr_reg[5]_i_1_n_5\ : STD_LOGIC;
  signal \axi_awaddr_reg[5]_i_1_n_6\ : STD_LOGIC;
  signal \axi_awaddr_reg[5]_i_1_n_7\ : STD_LOGIC;
  signal \axi_awaddr_reg[9]_i_1_n_0\ : STD_LOGIC;
  signal \axi_awaddr_reg[9]_i_1_n_1\ : STD_LOGIC;
  signal \axi_awaddr_reg[9]_i_1_n_2\ : STD_LOGIC;
  signal \axi_awaddr_reg[9]_i_1_n_3\ : STD_LOGIC;
  signal \axi_awaddr_reg[9]_i_1_n_4\ : STD_LOGIC;
  signal \axi_awaddr_reg[9]_i_1_n_5\ : STD_LOGIC;
  signal \axi_awaddr_reg[9]_i_1_n_6\ : STD_LOGIC;
  signal \axi_awaddr_reg[9]_i_1_n_7\ : STD_LOGIC;
  signal axi_awvalid_i_1_n_0 : STD_LOGIC;
  signal axi_rburst_size : STD_LOGIC_VECTOR ( 11 downto 3 );
  signal axi_rlast0 : STD_LOGIC;
  signal axi_rlast0_carry_i_1_n_0 : STD_LOGIC;
  signal axi_rlast0_carry_i_2_n_0 : STD_LOGIC;
  signal axi_rlast0_carry_i_3_n_0 : STD_LOGIC;
  signal axi_rlast0_carry_i_4_n_0 : STD_LOGIC;
  signal axi_rlast0_carry_i_5_n_0 : STD_LOGIC;
  signal axi_rlast0_carry_n_2 : STD_LOGIC;
  signal axi_rlast0_carry_n_3 : STD_LOGIC;
  signal axi_rready : STD_LOGIC;
  signal axi_rready_i_1_n_0 : STD_LOGIC;
  signal axi_rstart_locked : STD_LOGIC;
  signal axi_rstart_locked1 : STD_LOGIC;
  signal axi_rstart_locked_i_1_n_0 : STD_LOGIC;
  signal axi_rstart_locked_i_2_n_0 : STD_LOGIC;
  signal axi_rstart_locked_r1 : STD_LOGIC;
  signal axi_rstart_locked_r2 : STD_LOGIC;
  signal axi_wburst_size : STD_LOGIC_VECTOR ( 11 downto 3 );
  signal axi_wlast0 : STD_LOGIC;
  signal axi_wlast0_carry_i_1_n_0 : STD_LOGIC;
  signal axi_wlast0_carry_i_2_n_0 : STD_LOGIC;
  signal axi_wlast0_carry_i_3_n_0 : STD_LOGIC;
  signal axi_wlast0_carry_i_4_n_0 : STD_LOGIC;
  signal axi_wlast0_carry_i_5_n_0 : STD_LOGIC;
  signal axi_wlast0_carry_n_2 : STD_LOGIC;
  signal axi_wlast0_carry_n_3 : STD_LOGIC;
  signal axi_wstart_locked : STD_LOGIC;
  signal axi_wstart_locked1 : STD_LOGIC;
  signal axi_wstart_locked_i_1_n_0 : STD_LOGIC;
  signal axi_wstart_locked_i_2_n_0 : STD_LOGIC;
  signal axi_wstart_locked_r1 : STD_LOGIC;
  signal axi_wstart_locked_r2 : STD_LOGIC;
  signal axi_wvalid : STD_LOGIC;
  signal axi_wvalid_i_1_n_0 : STD_LOGIC;
  signal fdma_rleft_cnt : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal \fdma_rleft_cnt0_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__0_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__0_n_1\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__0_n_2\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__0_n_3\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__1_i_1_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__1_i_2_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__1_i_3_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__1_i_4_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__1_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__1_n_1\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__1_n_2\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__1_n_3\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__2_i_1_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__2_i_2_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__2_i_3_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__2_i_4_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__2_n_1\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__2_n_2\ : STD_LOGIC;
  signal \fdma_rleft_cnt0_carry__2_n_3\ : STD_LOGIC;
  signal fdma_rleft_cnt0_carry_i_1_n_0 : STD_LOGIC;
  signal fdma_rleft_cnt0_carry_i_2_n_0 : STD_LOGIC;
  signal fdma_rleft_cnt0_carry_i_3_n_0 : STD_LOGIC;
  signal fdma_rleft_cnt0_carry_i_4_n_0 : STD_LOGIC;
  signal fdma_rleft_cnt0_carry_n_0 : STD_LOGIC;
  signal fdma_rleft_cnt0_carry_n_1 : STD_LOGIC;
  signal fdma_rleft_cnt0_carry_n_2 : STD_LOGIC;
  signal fdma_rleft_cnt0_carry_n_3 : STD_LOGIC;
  signal \fdma_rleft_cnt[15]_i_1_n_0\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[0]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[10]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[11]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[12]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[13]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[14]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[15]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[1]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[2]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[3]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[4]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[5]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[6]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[7]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[8]\ : STD_LOGIC;
  signal \fdma_rleft_cnt_reg_n_0_[9]\ : STD_LOGIC;
  signal fdma_rstart : STD_LOGIC;
  signal fdma_rstart_locked_i_1_n_0 : STD_LOGIC;
  signal fdma_rstart_locked_i_2_n_0 : STD_LOGIC;
  signal fdma_rstart_locked_i_3_n_0 : STD_LOGIC;
  signal fdma_rstart_locked_i_4_n_0 : STD_LOGIC;
  signal fdma_rstart_locked_i_5_n_0 : STD_LOGIC;
  signal \^fdma_rstart_locked_reg_0\ : STD_LOGIC;
  signal \^fdma_rvalid\ : STD_LOGIC;
  signal fdma_wleft_cnt : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal \fdma_wleft_cnt0_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__0_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__0_n_1\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__0_n_2\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__0_n_3\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__1_i_1_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__1_i_2_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__1_i_3_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__1_i_4_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__1_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__1_n_1\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__1_n_2\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__1_n_3\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__2_i_1_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__2_i_2_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__2_i_3_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__2_i_4_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__2_n_1\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__2_n_2\ : STD_LOGIC;
  signal \fdma_wleft_cnt0_carry__2_n_3\ : STD_LOGIC;
  signal fdma_wleft_cnt0_carry_i_1_n_0 : STD_LOGIC;
  signal fdma_wleft_cnt0_carry_i_2_n_0 : STD_LOGIC;
  signal fdma_wleft_cnt0_carry_i_3_n_0 : STD_LOGIC;
  signal fdma_wleft_cnt0_carry_i_4_n_0 : STD_LOGIC;
  signal fdma_wleft_cnt0_carry_n_0 : STD_LOGIC;
  signal fdma_wleft_cnt0_carry_n_1 : STD_LOGIC;
  signal fdma_wleft_cnt0_carry_n_2 : STD_LOGIC;
  signal fdma_wleft_cnt0_carry_n_3 : STD_LOGIC;
  signal \fdma_wleft_cnt[15]_i_1_n_0\ : STD_LOGIC;
  signal \fdma_wleft_cnt_reg_n_0_[0]\ : STD_LOGIC;
  signal \fdma_wleft_cnt_reg_n_0_[1]\ : STD_LOGIC;
  signal \fdma_wleft_cnt_reg_n_0_[2]\ : STD_LOGIC;
  signal \fdma_wleft_cnt_reg_n_0_[3]\ : STD_LOGIC;
  signal \fdma_wleft_cnt_reg_n_0_[4]\ : STD_LOGIC;
  signal \fdma_wleft_cnt_reg_n_0_[5]\ : STD_LOGIC;
  signal \fdma_wleft_cnt_reg_n_0_[6]\ : STD_LOGIC;
  signal \fdma_wleft_cnt_reg_n_0_[7]\ : STD_LOGIC;
  signal fdma_wstart : STD_LOGIC;
  signal fdma_wstart_locked_i_1_n_0 : STD_LOGIC;
  signal fdma_wstart_locked_i_2_n_0 : STD_LOGIC;
  signal fdma_wstart_locked_i_3_n_0 : STD_LOGIC;
  signal fdma_wstart_locked_i_4_n_0 : STD_LOGIC;
  signal fdma_wstart_locked_i_5_n_0 : STD_LOGIC;
  signal \^fdma_wstart_locked_reg_0\ : STD_LOGIC;
  signal \^fdma_wvalid\ : STD_LOGIC;
  signal p_0_in : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal p_0_in_0 : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \p_0_in__0\ : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal \rburst_cnt[7]_i_2_n_0\ : STD_LOGIC;
  signal \rburst_cnt[8]_i_3_n_0\ : STD_LOGIC;
  signal rburst_cnt_reg : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal rburst_len : STD_LOGIC;
  signal \rburst_len[8]_i_2_n_0\ : STD_LOGIC;
  signal rburst_len_req : STD_LOGIC;
  signal \rfdma_cnt[0]_i_3_n_0\ : STD_LOGIC;
  signal rfdma_cnt_reg : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal \rfdma_cnt_reg[0]_i_2_n_0\ : STD_LOGIC;
  signal \rfdma_cnt_reg[0]_i_2_n_1\ : STD_LOGIC;
  signal \rfdma_cnt_reg[0]_i_2_n_2\ : STD_LOGIC;
  signal \rfdma_cnt_reg[0]_i_2_n_3\ : STD_LOGIC;
  signal \rfdma_cnt_reg[0]_i_2_n_4\ : STD_LOGIC;
  signal \rfdma_cnt_reg[0]_i_2_n_5\ : STD_LOGIC;
  signal \rfdma_cnt_reg[0]_i_2_n_6\ : STD_LOGIC;
  signal \rfdma_cnt_reg[0]_i_2_n_7\ : STD_LOGIC;
  signal \rfdma_cnt_reg[12]_i_1_n_1\ : STD_LOGIC;
  signal \rfdma_cnt_reg[12]_i_1_n_2\ : STD_LOGIC;
  signal \rfdma_cnt_reg[12]_i_1_n_3\ : STD_LOGIC;
  signal \rfdma_cnt_reg[12]_i_1_n_4\ : STD_LOGIC;
  signal \rfdma_cnt_reg[12]_i_1_n_5\ : STD_LOGIC;
  signal \rfdma_cnt_reg[12]_i_1_n_6\ : STD_LOGIC;
  signal \rfdma_cnt_reg[12]_i_1_n_7\ : STD_LOGIC;
  signal \rfdma_cnt_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \rfdma_cnt_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \rfdma_cnt_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \rfdma_cnt_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \rfdma_cnt_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \rfdma_cnt_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \rfdma_cnt_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \rfdma_cnt_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \rfdma_cnt_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \rfdma_cnt_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \rfdma_cnt_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \rfdma_cnt_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \rfdma_cnt_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \rfdma_cnt_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \rfdma_cnt_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \rfdma_cnt_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal \wburst_cnt[7]_i_2_n_0\ : STD_LOGIC;
  signal \wburst_cnt[8]_i_3_n_0\ : STD_LOGIC;
  signal wburst_cnt_reg : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal wburst_len : STD_LOGIC;
  signal \wburst_len[8]_i_2_n_0\ : STD_LOGIC;
  signal wburst_len_req : STD_LOGIC;
  signal wburst_len_req_i_1_n_0 : STD_LOGIC;
  signal \wfdma_cnt[0]_i_3_n_0\ : STD_LOGIC;
  signal wfdma_cnt_reg : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal \wfdma_cnt_reg[0]_i_2_n_0\ : STD_LOGIC;
  signal \wfdma_cnt_reg[0]_i_2_n_1\ : STD_LOGIC;
  signal \wfdma_cnt_reg[0]_i_2_n_2\ : STD_LOGIC;
  signal \wfdma_cnt_reg[0]_i_2_n_3\ : STD_LOGIC;
  signal \wfdma_cnt_reg[0]_i_2_n_4\ : STD_LOGIC;
  signal \wfdma_cnt_reg[0]_i_2_n_5\ : STD_LOGIC;
  signal \wfdma_cnt_reg[0]_i_2_n_6\ : STD_LOGIC;
  signal \wfdma_cnt_reg[0]_i_2_n_7\ : STD_LOGIC;
  signal \wfdma_cnt_reg[12]_i_1_n_1\ : STD_LOGIC;
  signal \wfdma_cnt_reg[12]_i_1_n_2\ : STD_LOGIC;
  signal \wfdma_cnt_reg[12]_i_1_n_3\ : STD_LOGIC;
  signal \wfdma_cnt_reg[12]_i_1_n_4\ : STD_LOGIC;
  signal \wfdma_cnt_reg[12]_i_1_n_5\ : STD_LOGIC;
  signal \wfdma_cnt_reg[12]_i_1_n_6\ : STD_LOGIC;
  signal \wfdma_cnt_reg[12]_i_1_n_7\ : STD_LOGIC;
  signal \wfdma_cnt_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \wfdma_cnt_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \wfdma_cnt_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \wfdma_cnt_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \wfdma_cnt_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \wfdma_cnt_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \wfdma_cnt_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \wfdma_cnt_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \wfdma_cnt_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \wfdma_cnt_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \wfdma_cnt_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \wfdma_cnt_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \wfdma_cnt_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \wfdma_cnt_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \wfdma_cnt_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \wfdma_cnt_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal \NLW_axi_araddr_reg[31]_i_2_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_axi_araddr_reg[31]_i_2_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \NLW_axi_awaddr_reg[31]_i_2_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_axi_awaddr_reg[31]_i_2_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal NLW_axi_rlast0_carry_CO_UNCONNECTED : STD_LOGIC_VECTOR ( 3 to 3 );
  signal NLW_axi_rlast0_carry_O_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_axi_wlast0_carry_CO_UNCONNECTED : STD_LOGIC_VECTOR ( 3 to 3 );
  signal NLW_axi_wlast0_carry_O_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_fdma_rleft_cnt0_carry__2_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  signal \NLW_fdma_wleft_cnt0_carry__2_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  signal \NLW_rfdma_cnt_reg[12]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  signal \NLW_wfdma_cnt_reg[12]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \M_AXI_ARLEN[0]_INST_0\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \M_AXI_ARLEN[1]_INST_0\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \M_AXI_ARLEN[2]_INST_0\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \M_AXI_ARLEN[3]_INST_0\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \M_AXI_ARLEN[4]_INST_0\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \M_AXI_ARLEN[7]_INST_0_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \M_AXI_AWLEN[0]_INST_0\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \M_AXI_AWLEN[1]_INST_0\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \M_AXI_AWLEN[2]_INST_0\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \M_AXI_AWLEN[3]_INST_0\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \M_AXI_AWLEN[4]_INST_0\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \M_AXI_AWLEN[7]_INST_0_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of M_AXI_RREADY_INST_0 : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of M_AXI_WLAST_INST_0 : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \axi_araddr[1]_i_1\ : label is "soft_lutpair6";
  attribute ADDER_THRESHOLD : integer;
  attribute ADDER_THRESHOLD of \axi_araddr_reg[13]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_araddr_reg[17]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_araddr_reg[21]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_araddr_reg[25]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_araddr_reg[29]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_araddr_reg[31]_i_2\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_araddr_reg[5]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_araddr_reg[9]_i_1\ : label is 11;
  attribute SOFT_HLUTNM of \axi_awaddr[1]_i_1\ : label is "soft_lutpair4";
  attribute ADDER_THRESHOLD of \axi_awaddr_reg[13]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_awaddr_reg[17]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_awaddr_reg[21]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_awaddr_reg[25]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_awaddr_reg[29]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_awaddr_reg[31]_i_2\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_awaddr_reg[5]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \axi_awaddr_reg[9]_i_1\ : label is 11;
  attribute SOFT_HLUTNM of axi_rstart_locked_i_2 : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of axi_wstart_locked_i_2 : label is "soft_lutpair5";
  attribute ADDER_THRESHOLD of fdma_rleft_cnt0_carry : label is 35;
  attribute ADDER_THRESHOLD of \fdma_rleft_cnt0_carry__0\ : label is 35;
  attribute ADDER_THRESHOLD of \fdma_rleft_cnt0_carry__1\ : label is 35;
  attribute ADDER_THRESHOLD of \fdma_rleft_cnt0_carry__2\ : label is 35;
  attribute SOFT_HLUTNM of fdma_rstart_locked_i_3 : label is "soft_lutpair6";
  attribute ADDER_THRESHOLD of fdma_wleft_cnt0_carry : label is 35;
  attribute ADDER_THRESHOLD of \fdma_wleft_cnt0_carry__0\ : label is 35;
  attribute ADDER_THRESHOLD of \fdma_wleft_cnt0_carry__1\ : label is 35;
  attribute ADDER_THRESHOLD of \fdma_wleft_cnt0_carry__2\ : label is 35;
  attribute SOFT_HLUTNM of fdma_wstart_locked_i_3 : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \rburst_cnt[0]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \rburst_cnt[1]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \rburst_cnt[2]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \rburst_cnt[3]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \rburst_cnt[4]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \rburst_cnt[7]_i_2\ : label is "soft_lutpair10";
  attribute ADDER_THRESHOLD of \rfdma_cnt_reg[0]_i_2\ : label is 11;
  attribute ADDER_THRESHOLD of \rfdma_cnt_reg[12]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \rfdma_cnt_reg[4]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \rfdma_cnt_reg[8]_i_1\ : label is 11;
  attribute SOFT_HLUTNM of \wburst_cnt[0]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \wburst_cnt[1]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \wburst_cnt[2]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \wburst_cnt[3]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \wburst_cnt[4]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \wburst_cnt[7]_i_2\ : label is "soft_lutpair8";
  attribute ADDER_THRESHOLD of \wfdma_cnt_reg[0]_i_2\ : label is 11;
  attribute ADDER_THRESHOLD of \wfdma_cnt_reg[12]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \wfdma_cnt_reg[4]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \wfdma_cnt_reg[8]_i_1\ : label is 11;
begin
  M_AXI_ARADDR(31 downto 0) <= \^m_axi_araddr\(31 downto 0);
  M_AXI_ARVALID <= \^m_axi_arvalid\;
  M_AXI_AWADDR(31 downto 0) <= \^m_axi_awaddr\(31 downto 0);
  M_AXI_AWVALID <= \^m_axi_awvalid\;
  fdma_rstart_locked_reg_0 <= \^fdma_rstart_locked_reg_0\;
  fdma_rvalid <= \^fdma_rvalid\;
  fdma_wstart_locked_reg_0 <= \^fdma_wstart_locked_reg_0\;
  fdma_wvalid <= \^fdma_wvalid\;
\M_AXI_ARLEN[0]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => axi_rburst_size(3),
      O => M_AXI_ARLEN(0)
    );
\M_AXI_ARLEN[1]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => axi_rburst_size(4),
      I1 => axi_rburst_size(3),
      O => M_AXI_ARLEN(1)
    );
\M_AXI_ARLEN[2]_INST_0\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"A9"
    )
        port map (
      I0 => axi_rburst_size(5),
      I1 => axi_rburst_size(3),
      I2 => axi_rburst_size(4),
      O => M_AXI_ARLEN(2)
    );
\M_AXI_ARLEN[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"AAA9"
    )
        port map (
      I0 => axi_rburst_size(6),
      I1 => axi_rburst_size(4),
      I2 => axi_rburst_size(3),
      I3 => axi_rburst_size(5),
      O => M_AXI_ARLEN(3)
    );
\M_AXI_ARLEN[4]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AAAAAAA9"
    )
        port map (
      I0 => axi_rburst_size(7),
      I1 => axi_rburst_size(5),
      I2 => axi_rburst_size(3),
      I3 => axi_rburst_size(4),
      I4 => axi_rburst_size(6),
      O => M_AXI_ARLEN(4)
    );
\M_AXI_ARLEN[5]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAA9"
    )
        port map (
      I0 => axi_rburst_size(8),
      I1 => axi_rburst_size(6),
      I2 => axi_rburst_size(4),
      I3 => axi_rburst_size(3),
      I4 => axi_rburst_size(5),
      I5 => axi_rburst_size(7),
      O => M_AXI_ARLEN(5)
    );
\M_AXI_ARLEN[6]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AAAAAAA9"
    )
        port map (
      I0 => axi_rburst_size(9),
      I1 => axi_rburst_size(7),
      I2 => \M_AXI_ARLEN[7]_INST_0_i_1_n_0\,
      I3 => axi_rburst_size(6),
      I4 => axi_rburst_size(8),
      O => M_AXI_ARLEN(6)
    );
\M_AXI_ARLEN[7]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFE00000001"
    )
        port map (
      I0 => axi_rburst_size(9),
      I1 => axi_rburst_size(7),
      I2 => \M_AXI_ARLEN[7]_INST_0_i_1_n_0\,
      I3 => axi_rburst_size(6),
      I4 => axi_rburst_size(8),
      I5 => axi_rburst_size(10),
      O => M_AXI_ARLEN(7)
    );
\M_AXI_ARLEN[7]_INST_0_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => axi_rburst_size(4),
      I1 => axi_rburst_size(3),
      I2 => axi_rburst_size(5),
      O => \M_AXI_ARLEN[7]_INST_0_i_1_n_0\
    );
\M_AXI_AWLEN[0]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => axi_wburst_size(3),
      O => M_AXI_AWLEN(0)
    );
\M_AXI_AWLEN[1]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => axi_wburst_size(4),
      I1 => axi_wburst_size(3),
      O => M_AXI_AWLEN(1)
    );
\M_AXI_AWLEN[2]_INST_0\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"A9"
    )
        port map (
      I0 => axi_wburst_size(5),
      I1 => axi_wburst_size(3),
      I2 => axi_wburst_size(4),
      O => M_AXI_AWLEN(2)
    );
\M_AXI_AWLEN[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"AAA9"
    )
        port map (
      I0 => axi_wburst_size(6),
      I1 => axi_wburst_size(4),
      I2 => axi_wburst_size(3),
      I3 => axi_wburst_size(5),
      O => M_AXI_AWLEN(3)
    );
\M_AXI_AWLEN[4]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AAAAAAA9"
    )
        port map (
      I0 => axi_wburst_size(7),
      I1 => axi_wburst_size(5),
      I2 => axi_wburst_size(3),
      I3 => axi_wburst_size(4),
      I4 => axi_wburst_size(6),
      O => M_AXI_AWLEN(4)
    );
\M_AXI_AWLEN[5]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAA9"
    )
        port map (
      I0 => axi_wburst_size(8),
      I1 => axi_wburst_size(6),
      I2 => axi_wburst_size(4),
      I3 => axi_wburst_size(3),
      I4 => axi_wburst_size(5),
      I5 => axi_wburst_size(7),
      O => M_AXI_AWLEN(5)
    );
\M_AXI_AWLEN[6]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AAAAAAA9"
    )
        port map (
      I0 => axi_wburst_size(9),
      I1 => axi_wburst_size(7),
      I2 => \M_AXI_AWLEN[7]_INST_0_i_1_n_0\,
      I3 => axi_wburst_size(6),
      I4 => axi_wburst_size(8),
      O => M_AXI_AWLEN(6)
    );
\M_AXI_AWLEN[7]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFE00000001"
    )
        port map (
      I0 => axi_wburst_size(9),
      I1 => axi_wburst_size(7),
      I2 => \M_AXI_AWLEN[7]_INST_0_i_1_n_0\,
      I3 => axi_wburst_size(6),
      I4 => axi_wburst_size(8),
      I5 => axi_wburst_size(10),
      O => M_AXI_AWLEN(7)
    );
\M_AXI_AWLEN[7]_INST_0_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => axi_wburst_size(4),
      I1 => axi_wburst_size(3),
      I2 => axi_wburst_size(5),
      O => \M_AXI_AWLEN[7]_INST_0_i_1_n_0\
    );
M_AXI_RREADY_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => fdma_rready,
      I1 => axi_rready,
      O => M_AXI_RREADY
    );
M_AXI_WLAST_INST_0: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => axi_wlast0,
      I1 => M_AXI_WREADY,
      I2 => axi_wvalid,
      I3 => fdma_wready,
      O => M_AXI_WLAST
    );
M_AXI_WVALID_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => fdma_wready,
      I1 => axi_wvalid,
      O => M_AXI_WVALID
    );
\axi_araddr[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(0),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(0),
      O => \axi_araddr[0]_i_1_n_0\
    );
\axi_araddr[13]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => axi_rburst_size(11),
      O => \axi_araddr[13]_i_2_n_0\
    );
\axi_araddr[13]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => axi_rburst_size(10),
      O => \axi_araddr[13]_i_3_n_0\
    );
\axi_araddr[13]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(13),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(13),
      O => \axi_araddr[13]_i_4_n_0\
    );
\axi_araddr[13]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(12),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(12),
      O => \axi_araddr[13]_i_5_n_0\
    );
\axi_araddr[13]_i_6\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_rburst_size(11),
      I1 => fdma_raddr(11),
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => \^m_axi_araddr\(11),
      O => \axi_araddr[13]_i_6_n_0\
    );
\axi_araddr[13]_i_7\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_rburst_size(10),
      I1 => fdma_raddr(10),
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => \^m_axi_araddr\(10),
      O => \axi_araddr[13]_i_7_n_0\
    );
\axi_araddr[17]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(17),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(17),
      O => \axi_araddr[17]_i_2_n_0\
    );
\axi_araddr[17]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(16),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(16),
      O => \axi_araddr[17]_i_3_n_0\
    );
\axi_araddr[17]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(15),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(15),
      O => \axi_araddr[17]_i_4_n_0\
    );
\axi_araddr[17]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(14),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(14),
      O => \axi_araddr[17]_i_5_n_0\
    );
\axi_araddr[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(1),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(1),
      O => \axi_araddr[1]_i_1_n_0\
    );
\axi_araddr[21]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(21),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(21),
      O => \axi_araddr[21]_i_2_n_0\
    );
\axi_araddr[21]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(20),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(20),
      O => \axi_araddr[21]_i_3_n_0\
    );
\axi_araddr[21]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(19),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(19),
      O => \axi_araddr[21]_i_4_n_0\
    );
\axi_araddr[21]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(18),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(18),
      O => \axi_araddr[21]_i_5_n_0\
    );
\axi_araddr[25]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(25),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(25),
      O => \axi_araddr[25]_i_2_n_0\
    );
\axi_araddr[25]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(24),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(24),
      O => \axi_araddr[25]_i_3_n_0\
    );
\axi_araddr[25]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(23),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(23),
      O => \axi_araddr[25]_i_4_n_0\
    );
\axi_araddr[25]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(22),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(22),
      O => \axi_araddr[25]_i_5_n_0\
    );
\axi_araddr[29]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(29),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(29),
      O => \axi_araddr[29]_i_2_n_0\
    );
\axi_araddr[29]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(28),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(28),
      O => \axi_araddr[29]_i_3_n_0\
    );
\axi_araddr[29]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(27),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(27),
      O => \axi_araddr[29]_i_4_n_0\
    );
\axi_araddr[29]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(26),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(26),
      O => \axi_araddr[29]_i_5_n_0\
    );
\axi_araddr[31]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"80008000FFFF8000"
    )
        port map (
      I0 => fdma_rready,
      I1 => axi_rready,
      I2 => M_AXI_RVALID,
      I3 => axi_rlast0,
      I4 => fdma_rareq,
      I5 => \^fdma_rstart_locked_reg_0\,
      O => \axi_araddr[31]_i_1_n_0\
    );
\axi_araddr[31]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(31),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(31),
      O => \axi_araddr[31]_i_3_n_0\
    );
\axi_araddr[31]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(30),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(30),
      O => \axi_araddr[31]_i_4_n_0\
    );
\axi_araddr[5]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => axi_rburst_size(5),
      O => \axi_araddr[5]_i_2_n_0\
    );
\axi_araddr[5]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => axi_rburst_size(4),
      O => \axi_araddr[5]_i_3_n_0\
    );
\axi_araddr[5]_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => axi_rburst_size(3),
      O => \axi_araddr[5]_i_4_n_0\
    );
\axi_araddr[5]_i_5\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_rburst_size(5),
      I1 => fdma_raddr(5),
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => \^m_axi_araddr\(5),
      O => \axi_araddr[5]_i_5_n_0\
    );
\axi_araddr[5]_i_6\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_rburst_size(4),
      I1 => fdma_raddr(4),
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => \^m_axi_araddr\(4),
      O => \axi_araddr[5]_i_6_n_0\
    );
\axi_araddr[5]_i_7\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_rburst_size(3),
      I1 => fdma_raddr(3),
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => \^m_axi_araddr\(3),
      O => \axi_araddr[5]_i_7_n_0\
    );
\axi_araddr[5]_i_8\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_araddr\(2),
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => fdma_rareq,
      I3 => fdma_raddr(2),
      O => \axi_araddr[5]_i_8_n_0\
    );
\axi_araddr[9]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => axi_rburst_size(9),
      O => \axi_araddr[9]_i_2_n_0\
    );
\axi_araddr[9]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => axi_rburst_size(8),
      O => \axi_araddr[9]_i_3_n_0\
    );
\axi_araddr[9]_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => axi_rburst_size(7),
      O => \axi_araddr[9]_i_4_n_0\
    );
\axi_araddr[9]_i_5\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      I2 => axi_rburst_size(6),
      O => \axi_araddr[9]_i_5_n_0\
    );
\axi_araddr[9]_i_6\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_rburst_size(9),
      I1 => fdma_raddr(9),
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => \^m_axi_araddr\(9),
      O => \axi_araddr[9]_i_6_n_0\
    );
\axi_araddr[9]_i_7\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_rburst_size(8),
      I1 => fdma_raddr(8),
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => \^m_axi_araddr\(8),
      O => \axi_araddr[9]_i_7_n_0\
    );
\axi_araddr[9]_i_8\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_rburst_size(7),
      I1 => fdma_raddr(7),
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => \^m_axi_araddr\(7),
      O => \axi_araddr[9]_i_8_n_0\
    );
\axi_araddr[9]_i_9\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_rburst_size(6),
      I1 => fdma_raddr(6),
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => \^m_axi_araddr\(6),
      O => \axi_araddr[9]_i_9_n_0\
    );
\axi_araddr_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr[0]_i_1_n_0\,
      Q => \^m_axi_araddr\(0),
      R => '0'
    );
\axi_araddr_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[13]_i_1_n_7\,
      Q => \^m_axi_araddr\(10),
      R => '0'
    );
\axi_araddr_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[13]_i_1_n_6\,
      Q => \^m_axi_araddr\(11),
      R => '0'
    );
\axi_araddr_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[13]_i_1_n_5\,
      Q => \^m_axi_araddr\(12),
      R => '0'
    );
\axi_araddr_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[13]_i_1_n_4\,
      Q => \^m_axi_araddr\(13),
      R => '0'
    );
\axi_araddr_reg[13]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_araddr_reg[9]_i_1_n_0\,
      CO(3) => \axi_araddr_reg[13]_i_1_n_0\,
      CO(2) => \axi_araddr_reg[13]_i_1_n_1\,
      CO(1) => \axi_araddr_reg[13]_i_1_n_2\,
      CO(0) => \axi_araddr_reg[13]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 2) => B"00",
      DI(1) => \axi_araddr[13]_i_2_n_0\,
      DI(0) => \axi_araddr[13]_i_3_n_0\,
      O(3) => \axi_araddr_reg[13]_i_1_n_4\,
      O(2) => \axi_araddr_reg[13]_i_1_n_5\,
      O(1) => \axi_araddr_reg[13]_i_1_n_6\,
      O(0) => \axi_araddr_reg[13]_i_1_n_7\,
      S(3) => \axi_araddr[13]_i_4_n_0\,
      S(2) => \axi_araddr[13]_i_5_n_0\,
      S(1) => \axi_araddr[13]_i_6_n_0\,
      S(0) => \axi_araddr[13]_i_7_n_0\
    );
\axi_araddr_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[17]_i_1_n_7\,
      Q => \^m_axi_araddr\(14),
      R => '0'
    );
\axi_araddr_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[17]_i_1_n_6\,
      Q => \^m_axi_araddr\(15),
      R => '0'
    );
\axi_araddr_reg[16]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[17]_i_1_n_5\,
      Q => \^m_axi_araddr\(16),
      R => '0'
    );
\axi_araddr_reg[17]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[17]_i_1_n_4\,
      Q => \^m_axi_araddr\(17),
      R => '0'
    );
\axi_araddr_reg[17]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_araddr_reg[13]_i_1_n_0\,
      CO(3) => \axi_araddr_reg[17]_i_1_n_0\,
      CO(2) => \axi_araddr_reg[17]_i_1_n_1\,
      CO(1) => \axi_araddr_reg[17]_i_1_n_2\,
      CO(0) => \axi_araddr_reg[17]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \axi_araddr_reg[17]_i_1_n_4\,
      O(2) => \axi_araddr_reg[17]_i_1_n_5\,
      O(1) => \axi_araddr_reg[17]_i_1_n_6\,
      O(0) => \axi_araddr_reg[17]_i_1_n_7\,
      S(3) => \axi_araddr[17]_i_2_n_0\,
      S(2) => \axi_araddr[17]_i_3_n_0\,
      S(1) => \axi_araddr[17]_i_4_n_0\,
      S(0) => \axi_araddr[17]_i_5_n_0\
    );
\axi_araddr_reg[18]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[21]_i_1_n_7\,
      Q => \^m_axi_araddr\(18),
      R => '0'
    );
\axi_araddr_reg[19]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[21]_i_1_n_6\,
      Q => \^m_axi_araddr\(19),
      R => '0'
    );
\axi_araddr_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr[1]_i_1_n_0\,
      Q => \^m_axi_araddr\(1),
      R => '0'
    );
\axi_araddr_reg[20]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[21]_i_1_n_5\,
      Q => \^m_axi_araddr\(20),
      R => '0'
    );
\axi_araddr_reg[21]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[21]_i_1_n_4\,
      Q => \^m_axi_araddr\(21),
      R => '0'
    );
\axi_araddr_reg[21]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_araddr_reg[17]_i_1_n_0\,
      CO(3) => \axi_araddr_reg[21]_i_1_n_0\,
      CO(2) => \axi_araddr_reg[21]_i_1_n_1\,
      CO(1) => \axi_araddr_reg[21]_i_1_n_2\,
      CO(0) => \axi_araddr_reg[21]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \axi_araddr_reg[21]_i_1_n_4\,
      O(2) => \axi_araddr_reg[21]_i_1_n_5\,
      O(1) => \axi_araddr_reg[21]_i_1_n_6\,
      O(0) => \axi_araddr_reg[21]_i_1_n_7\,
      S(3) => \axi_araddr[21]_i_2_n_0\,
      S(2) => \axi_araddr[21]_i_3_n_0\,
      S(1) => \axi_araddr[21]_i_4_n_0\,
      S(0) => \axi_araddr[21]_i_5_n_0\
    );
\axi_araddr_reg[22]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[25]_i_1_n_7\,
      Q => \^m_axi_araddr\(22),
      R => '0'
    );
\axi_araddr_reg[23]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[25]_i_1_n_6\,
      Q => \^m_axi_araddr\(23),
      R => '0'
    );
\axi_araddr_reg[24]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[25]_i_1_n_5\,
      Q => \^m_axi_araddr\(24),
      R => '0'
    );
\axi_araddr_reg[25]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[25]_i_1_n_4\,
      Q => \^m_axi_araddr\(25),
      R => '0'
    );
\axi_araddr_reg[25]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_araddr_reg[21]_i_1_n_0\,
      CO(3) => \axi_araddr_reg[25]_i_1_n_0\,
      CO(2) => \axi_araddr_reg[25]_i_1_n_1\,
      CO(1) => \axi_araddr_reg[25]_i_1_n_2\,
      CO(0) => \axi_araddr_reg[25]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \axi_araddr_reg[25]_i_1_n_4\,
      O(2) => \axi_araddr_reg[25]_i_1_n_5\,
      O(1) => \axi_araddr_reg[25]_i_1_n_6\,
      O(0) => \axi_araddr_reg[25]_i_1_n_7\,
      S(3) => \axi_araddr[25]_i_2_n_0\,
      S(2) => \axi_araddr[25]_i_3_n_0\,
      S(1) => \axi_araddr[25]_i_4_n_0\,
      S(0) => \axi_araddr[25]_i_5_n_0\
    );
\axi_araddr_reg[26]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[29]_i_1_n_7\,
      Q => \^m_axi_araddr\(26),
      R => '0'
    );
\axi_araddr_reg[27]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[29]_i_1_n_6\,
      Q => \^m_axi_araddr\(27),
      R => '0'
    );
\axi_araddr_reg[28]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[29]_i_1_n_5\,
      Q => \^m_axi_araddr\(28),
      R => '0'
    );
\axi_araddr_reg[29]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[29]_i_1_n_4\,
      Q => \^m_axi_araddr\(29),
      R => '0'
    );
\axi_araddr_reg[29]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_araddr_reg[25]_i_1_n_0\,
      CO(3) => \axi_araddr_reg[29]_i_1_n_0\,
      CO(2) => \axi_araddr_reg[29]_i_1_n_1\,
      CO(1) => \axi_araddr_reg[29]_i_1_n_2\,
      CO(0) => \axi_araddr_reg[29]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \axi_araddr_reg[29]_i_1_n_4\,
      O(2) => \axi_araddr_reg[29]_i_1_n_5\,
      O(1) => \axi_araddr_reg[29]_i_1_n_6\,
      O(0) => \axi_araddr_reg[29]_i_1_n_7\,
      S(3) => \axi_araddr[29]_i_2_n_0\,
      S(2) => \axi_araddr[29]_i_3_n_0\,
      S(1) => \axi_araddr[29]_i_4_n_0\,
      S(0) => \axi_araddr[29]_i_5_n_0\
    );
\axi_araddr_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[5]_i_1_n_7\,
      Q => \^m_axi_araddr\(2),
      R => '0'
    );
\axi_araddr_reg[30]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[31]_i_2_n_7\,
      Q => \^m_axi_araddr\(30),
      R => '0'
    );
\axi_araddr_reg[31]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[31]_i_2_n_6\,
      Q => \^m_axi_araddr\(31),
      R => '0'
    );
\axi_araddr_reg[31]_i_2\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_araddr_reg[29]_i_1_n_0\,
      CO(3 downto 1) => \NLW_axi_araddr_reg[31]_i_2_CO_UNCONNECTED\(3 downto 1),
      CO(0) => \axi_araddr_reg[31]_i_2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 2) => \NLW_axi_araddr_reg[31]_i_2_O_UNCONNECTED\(3 downto 2),
      O(1) => \axi_araddr_reg[31]_i_2_n_6\,
      O(0) => \axi_araddr_reg[31]_i_2_n_7\,
      S(3 downto 2) => B"00",
      S(1) => \axi_araddr[31]_i_3_n_0\,
      S(0) => \axi_araddr[31]_i_4_n_0\
    );
\axi_araddr_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[5]_i_1_n_6\,
      Q => \^m_axi_araddr\(3),
      R => '0'
    );
\axi_araddr_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[5]_i_1_n_5\,
      Q => \^m_axi_araddr\(4),
      R => '0'
    );
\axi_araddr_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[5]_i_1_n_4\,
      Q => \^m_axi_araddr\(5),
      R => '0'
    );
\axi_araddr_reg[5]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \axi_araddr_reg[5]_i_1_n_0\,
      CO(2) => \axi_araddr_reg[5]_i_1_n_1\,
      CO(1) => \axi_araddr_reg[5]_i_1_n_2\,
      CO(0) => \axi_araddr_reg[5]_i_1_n_3\,
      CYINIT => '0',
      DI(3) => \axi_araddr[5]_i_2_n_0\,
      DI(2) => \axi_araddr[5]_i_3_n_0\,
      DI(1) => \axi_araddr[5]_i_4_n_0\,
      DI(0) => '0',
      O(3) => \axi_araddr_reg[5]_i_1_n_4\,
      O(2) => \axi_araddr_reg[5]_i_1_n_5\,
      O(1) => \axi_araddr_reg[5]_i_1_n_6\,
      O(0) => \axi_araddr_reg[5]_i_1_n_7\,
      S(3) => \axi_araddr[5]_i_5_n_0\,
      S(2) => \axi_araddr[5]_i_6_n_0\,
      S(1) => \axi_araddr[5]_i_7_n_0\,
      S(0) => \axi_araddr[5]_i_8_n_0\
    );
\axi_araddr_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[9]_i_1_n_7\,
      Q => \^m_axi_araddr\(6),
      R => '0'
    );
\axi_araddr_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[9]_i_1_n_6\,
      Q => \^m_axi_araddr\(7),
      R => '0'
    );
\axi_araddr_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[9]_i_1_n_5\,
      Q => \^m_axi_araddr\(8),
      R => '0'
    );
\axi_araddr_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_araddr[31]_i_1_n_0\,
      D => \axi_araddr_reg[9]_i_1_n_4\,
      Q => \^m_axi_araddr\(9),
      R => '0'
    );
\axi_araddr_reg[9]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_araddr_reg[5]_i_1_n_0\,
      CO(3) => \axi_araddr_reg[9]_i_1_n_0\,
      CO(2) => \axi_araddr_reg[9]_i_1_n_1\,
      CO(1) => \axi_araddr_reg[9]_i_1_n_2\,
      CO(0) => \axi_araddr_reg[9]_i_1_n_3\,
      CYINIT => '0',
      DI(3) => \axi_araddr[9]_i_2_n_0\,
      DI(2) => \axi_araddr[9]_i_3_n_0\,
      DI(1) => \axi_araddr[9]_i_4_n_0\,
      DI(0) => \axi_araddr[9]_i_5_n_0\,
      O(3) => \axi_araddr_reg[9]_i_1_n_4\,
      O(2) => \axi_araddr_reg[9]_i_1_n_5\,
      O(1) => \axi_araddr_reg[9]_i_1_n_6\,
      O(0) => \axi_araddr_reg[9]_i_1_n_7\,
      S(3) => \axi_araddr[9]_i_6_n_0\,
      S(2) => \axi_araddr[9]_i_7_n_0\,
      S(1) => \axi_araddr[9]_i_8_n_0\,
      S(0) => \axi_araddr[9]_i_9_n_0\
    );
axi_arvalid_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"40FF4040"
    )
        port map (
      I0 => M_AXI_ARREADY,
      I1 => axi_rstart_locked,
      I2 => \^m_axi_arvalid\,
      I3 => axi_rstart_locked_r2,
      I4 => axi_rstart_locked_r1,
      O => axi_arvalid_i_1_n_0
    );
axi_arvalid_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_arvalid_i_1_n_0,
      Q => \^m_axi_arvalid\,
      R => '0'
    );
\axi_awaddr[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(0),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(0),
      O => \axi_awaddr[0]_i_1_n_0\
    );
\axi_awaddr[13]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => axi_wburst_size(11),
      O => \axi_awaddr[13]_i_2_n_0\
    );
\axi_awaddr[13]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => axi_wburst_size(10),
      O => \axi_awaddr[13]_i_3_n_0\
    );
\axi_awaddr[13]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(13),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(13),
      O => \axi_awaddr[13]_i_4_n_0\
    );
\axi_awaddr[13]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(12),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(12),
      O => \axi_awaddr[13]_i_5_n_0\
    );
\axi_awaddr[13]_i_6\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_wburst_size(11),
      I1 => fdma_waddr(11),
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => \^m_axi_awaddr\(11),
      O => \axi_awaddr[13]_i_6_n_0\
    );
\axi_awaddr[13]_i_7\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_wburst_size(10),
      I1 => fdma_waddr(10),
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => \^m_axi_awaddr\(10),
      O => \axi_awaddr[13]_i_7_n_0\
    );
\axi_awaddr[17]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(17),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(17),
      O => \axi_awaddr[17]_i_2_n_0\
    );
\axi_awaddr[17]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(16),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(16),
      O => \axi_awaddr[17]_i_3_n_0\
    );
\axi_awaddr[17]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(15),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(15),
      O => \axi_awaddr[17]_i_4_n_0\
    );
\axi_awaddr[17]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(14),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(14),
      O => \axi_awaddr[17]_i_5_n_0\
    );
\axi_awaddr[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(1),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(1),
      O => \axi_awaddr[1]_i_1_n_0\
    );
\axi_awaddr[21]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(21),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(21),
      O => \axi_awaddr[21]_i_2_n_0\
    );
\axi_awaddr[21]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(20),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(20),
      O => \axi_awaddr[21]_i_3_n_0\
    );
\axi_awaddr[21]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(19),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(19),
      O => \axi_awaddr[21]_i_4_n_0\
    );
\axi_awaddr[21]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(18),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(18),
      O => \axi_awaddr[21]_i_5_n_0\
    );
\axi_awaddr[25]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(25),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(25),
      O => \axi_awaddr[25]_i_2_n_0\
    );
\axi_awaddr[25]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(24),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(24),
      O => \axi_awaddr[25]_i_3_n_0\
    );
\axi_awaddr[25]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(23),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(23),
      O => \axi_awaddr[25]_i_4_n_0\
    );
\axi_awaddr[25]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(22),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(22),
      O => \axi_awaddr[25]_i_5_n_0\
    );
\axi_awaddr[29]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(29),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(29),
      O => \axi_awaddr[29]_i_2_n_0\
    );
\axi_awaddr[29]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(28),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(28),
      O => \axi_awaddr[29]_i_3_n_0\
    );
\axi_awaddr[29]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(27),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(27),
      O => \axi_awaddr[29]_i_4_n_0\
    );
\axi_awaddr[29]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(26),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(26),
      O => \axi_awaddr[29]_i_5_n_0\
    );
\axi_awaddr[31]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"80008000FFFF8000"
    )
        port map (
      I0 => fdma_wready,
      I1 => axi_wvalid,
      I2 => M_AXI_WREADY,
      I3 => axi_wlast0,
      I4 => fdma_wareq,
      I5 => \^fdma_wstart_locked_reg_0\,
      O => \axi_awaddr[31]_i_1_n_0\
    );
\axi_awaddr[31]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(31),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(31),
      O => \axi_awaddr[31]_i_3_n_0\
    );
\axi_awaddr[31]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(30),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(30),
      O => \axi_awaddr[31]_i_4_n_0\
    );
\axi_awaddr[5]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => axi_wburst_size(5),
      O => \axi_awaddr[5]_i_2_n_0\
    );
\axi_awaddr[5]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => axi_wburst_size(4),
      O => \axi_awaddr[5]_i_3_n_0\
    );
\axi_awaddr[5]_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => axi_wburst_size(3),
      O => \axi_awaddr[5]_i_4_n_0\
    );
\axi_awaddr[5]_i_5\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_wburst_size(5),
      I1 => fdma_waddr(5),
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => \^m_axi_awaddr\(5),
      O => \axi_awaddr[5]_i_5_n_0\
    );
\axi_awaddr[5]_i_6\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_wburst_size(4),
      I1 => fdma_waddr(4),
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => \^m_axi_awaddr\(4),
      O => \axi_awaddr[5]_i_6_n_0\
    );
\axi_awaddr[5]_i_7\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_wburst_size(3),
      I1 => fdma_waddr(3),
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => \^m_axi_awaddr\(3),
      O => \axi_awaddr[5]_i_7_n_0\
    );
\axi_awaddr[5]_i_8\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BA8A"
    )
        port map (
      I0 => \^m_axi_awaddr\(2),
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => fdma_wareq,
      I3 => fdma_waddr(2),
      O => \axi_awaddr[5]_i_8_n_0\
    );
\axi_awaddr[9]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => axi_wburst_size(9),
      O => \axi_awaddr[9]_i_2_n_0\
    );
\axi_awaddr[9]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => axi_wburst_size(8),
      O => \axi_awaddr[9]_i_3_n_0\
    );
\axi_awaddr[9]_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => axi_wburst_size(7),
      O => \axi_awaddr[9]_i_4_n_0\
    );
\axi_awaddr[9]_i_5\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      I2 => axi_wburst_size(6),
      O => \axi_awaddr[9]_i_5_n_0\
    );
\axi_awaddr[9]_i_6\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_wburst_size(9),
      I1 => fdma_waddr(9),
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => \^m_axi_awaddr\(9),
      O => \axi_awaddr[9]_i_6_n_0\
    );
\axi_awaddr[9]_i_7\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_wburst_size(8),
      I1 => fdma_waddr(8),
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => \^m_axi_awaddr\(8),
      O => \axi_awaddr[9]_i_7_n_0\
    );
\axi_awaddr[9]_i_8\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_wburst_size(7),
      I1 => fdma_waddr(7),
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => \^m_axi_awaddr\(7),
      O => \axi_awaddr[9]_i_8_n_0\
    );
\axi_awaddr[9]_i_9\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55C5AACA"
    )
        port map (
      I0 => axi_wburst_size(6),
      I1 => fdma_waddr(6),
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => \^m_axi_awaddr\(6),
      O => \axi_awaddr[9]_i_9_n_0\
    );
\axi_awaddr_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr[0]_i_1_n_0\,
      Q => \^m_axi_awaddr\(0),
      R => '0'
    );
\axi_awaddr_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[13]_i_1_n_7\,
      Q => \^m_axi_awaddr\(10),
      R => '0'
    );
\axi_awaddr_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[13]_i_1_n_6\,
      Q => \^m_axi_awaddr\(11),
      R => '0'
    );
\axi_awaddr_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[13]_i_1_n_5\,
      Q => \^m_axi_awaddr\(12),
      R => '0'
    );
\axi_awaddr_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[13]_i_1_n_4\,
      Q => \^m_axi_awaddr\(13),
      R => '0'
    );
\axi_awaddr_reg[13]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_awaddr_reg[9]_i_1_n_0\,
      CO(3) => \axi_awaddr_reg[13]_i_1_n_0\,
      CO(2) => \axi_awaddr_reg[13]_i_1_n_1\,
      CO(1) => \axi_awaddr_reg[13]_i_1_n_2\,
      CO(0) => \axi_awaddr_reg[13]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 2) => B"00",
      DI(1) => \axi_awaddr[13]_i_2_n_0\,
      DI(0) => \axi_awaddr[13]_i_3_n_0\,
      O(3) => \axi_awaddr_reg[13]_i_1_n_4\,
      O(2) => \axi_awaddr_reg[13]_i_1_n_5\,
      O(1) => \axi_awaddr_reg[13]_i_1_n_6\,
      O(0) => \axi_awaddr_reg[13]_i_1_n_7\,
      S(3) => \axi_awaddr[13]_i_4_n_0\,
      S(2) => \axi_awaddr[13]_i_5_n_0\,
      S(1) => \axi_awaddr[13]_i_6_n_0\,
      S(0) => \axi_awaddr[13]_i_7_n_0\
    );
\axi_awaddr_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[17]_i_1_n_7\,
      Q => \^m_axi_awaddr\(14),
      R => '0'
    );
\axi_awaddr_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[17]_i_1_n_6\,
      Q => \^m_axi_awaddr\(15),
      R => '0'
    );
\axi_awaddr_reg[16]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[17]_i_1_n_5\,
      Q => \^m_axi_awaddr\(16),
      R => '0'
    );
\axi_awaddr_reg[17]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[17]_i_1_n_4\,
      Q => \^m_axi_awaddr\(17),
      R => '0'
    );
\axi_awaddr_reg[17]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_awaddr_reg[13]_i_1_n_0\,
      CO(3) => \axi_awaddr_reg[17]_i_1_n_0\,
      CO(2) => \axi_awaddr_reg[17]_i_1_n_1\,
      CO(1) => \axi_awaddr_reg[17]_i_1_n_2\,
      CO(0) => \axi_awaddr_reg[17]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \axi_awaddr_reg[17]_i_1_n_4\,
      O(2) => \axi_awaddr_reg[17]_i_1_n_5\,
      O(1) => \axi_awaddr_reg[17]_i_1_n_6\,
      O(0) => \axi_awaddr_reg[17]_i_1_n_7\,
      S(3) => \axi_awaddr[17]_i_2_n_0\,
      S(2) => \axi_awaddr[17]_i_3_n_0\,
      S(1) => \axi_awaddr[17]_i_4_n_0\,
      S(0) => \axi_awaddr[17]_i_5_n_0\
    );
\axi_awaddr_reg[18]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[21]_i_1_n_7\,
      Q => \^m_axi_awaddr\(18),
      R => '0'
    );
\axi_awaddr_reg[19]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[21]_i_1_n_6\,
      Q => \^m_axi_awaddr\(19),
      R => '0'
    );
\axi_awaddr_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr[1]_i_1_n_0\,
      Q => \^m_axi_awaddr\(1),
      R => '0'
    );
\axi_awaddr_reg[20]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[21]_i_1_n_5\,
      Q => \^m_axi_awaddr\(20),
      R => '0'
    );
\axi_awaddr_reg[21]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[21]_i_1_n_4\,
      Q => \^m_axi_awaddr\(21),
      R => '0'
    );
\axi_awaddr_reg[21]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_awaddr_reg[17]_i_1_n_0\,
      CO(3) => \axi_awaddr_reg[21]_i_1_n_0\,
      CO(2) => \axi_awaddr_reg[21]_i_1_n_1\,
      CO(1) => \axi_awaddr_reg[21]_i_1_n_2\,
      CO(0) => \axi_awaddr_reg[21]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \axi_awaddr_reg[21]_i_1_n_4\,
      O(2) => \axi_awaddr_reg[21]_i_1_n_5\,
      O(1) => \axi_awaddr_reg[21]_i_1_n_6\,
      O(0) => \axi_awaddr_reg[21]_i_1_n_7\,
      S(3) => \axi_awaddr[21]_i_2_n_0\,
      S(2) => \axi_awaddr[21]_i_3_n_0\,
      S(1) => \axi_awaddr[21]_i_4_n_0\,
      S(0) => \axi_awaddr[21]_i_5_n_0\
    );
\axi_awaddr_reg[22]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[25]_i_1_n_7\,
      Q => \^m_axi_awaddr\(22),
      R => '0'
    );
\axi_awaddr_reg[23]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[25]_i_1_n_6\,
      Q => \^m_axi_awaddr\(23),
      R => '0'
    );
\axi_awaddr_reg[24]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[25]_i_1_n_5\,
      Q => \^m_axi_awaddr\(24),
      R => '0'
    );
\axi_awaddr_reg[25]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[25]_i_1_n_4\,
      Q => \^m_axi_awaddr\(25),
      R => '0'
    );
\axi_awaddr_reg[25]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_awaddr_reg[21]_i_1_n_0\,
      CO(3) => \axi_awaddr_reg[25]_i_1_n_0\,
      CO(2) => \axi_awaddr_reg[25]_i_1_n_1\,
      CO(1) => \axi_awaddr_reg[25]_i_1_n_2\,
      CO(0) => \axi_awaddr_reg[25]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \axi_awaddr_reg[25]_i_1_n_4\,
      O(2) => \axi_awaddr_reg[25]_i_1_n_5\,
      O(1) => \axi_awaddr_reg[25]_i_1_n_6\,
      O(0) => \axi_awaddr_reg[25]_i_1_n_7\,
      S(3) => \axi_awaddr[25]_i_2_n_0\,
      S(2) => \axi_awaddr[25]_i_3_n_0\,
      S(1) => \axi_awaddr[25]_i_4_n_0\,
      S(0) => \axi_awaddr[25]_i_5_n_0\
    );
\axi_awaddr_reg[26]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[29]_i_1_n_7\,
      Q => \^m_axi_awaddr\(26),
      R => '0'
    );
\axi_awaddr_reg[27]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[29]_i_1_n_6\,
      Q => \^m_axi_awaddr\(27),
      R => '0'
    );
\axi_awaddr_reg[28]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[29]_i_1_n_5\,
      Q => \^m_axi_awaddr\(28),
      R => '0'
    );
\axi_awaddr_reg[29]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[29]_i_1_n_4\,
      Q => \^m_axi_awaddr\(29),
      R => '0'
    );
\axi_awaddr_reg[29]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_awaddr_reg[25]_i_1_n_0\,
      CO(3) => \axi_awaddr_reg[29]_i_1_n_0\,
      CO(2) => \axi_awaddr_reg[29]_i_1_n_1\,
      CO(1) => \axi_awaddr_reg[29]_i_1_n_2\,
      CO(0) => \axi_awaddr_reg[29]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \axi_awaddr_reg[29]_i_1_n_4\,
      O(2) => \axi_awaddr_reg[29]_i_1_n_5\,
      O(1) => \axi_awaddr_reg[29]_i_1_n_6\,
      O(0) => \axi_awaddr_reg[29]_i_1_n_7\,
      S(3) => \axi_awaddr[29]_i_2_n_0\,
      S(2) => \axi_awaddr[29]_i_3_n_0\,
      S(1) => \axi_awaddr[29]_i_4_n_0\,
      S(0) => \axi_awaddr[29]_i_5_n_0\
    );
\axi_awaddr_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[5]_i_1_n_7\,
      Q => \^m_axi_awaddr\(2),
      R => '0'
    );
\axi_awaddr_reg[30]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[31]_i_2_n_7\,
      Q => \^m_axi_awaddr\(30),
      R => '0'
    );
\axi_awaddr_reg[31]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[31]_i_2_n_6\,
      Q => \^m_axi_awaddr\(31),
      R => '0'
    );
\axi_awaddr_reg[31]_i_2\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_awaddr_reg[29]_i_1_n_0\,
      CO(3 downto 1) => \NLW_axi_awaddr_reg[31]_i_2_CO_UNCONNECTED\(3 downto 1),
      CO(0) => \axi_awaddr_reg[31]_i_2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 2) => \NLW_axi_awaddr_reg[31]_i_2_O_UNCONNECTED\(3 downto 2),
      O(1) => \axi_awaddr_reg[31]_i_2_n_6\,
      O(0) => \axi_awaddr_reg[31]_i_2_n_7\,
      S(3 downto 2) => B"00",
      S(1) => \axi_awaddr[31]_i_3_n_0\,
      S(0) => \axi_awaddr[31]_i_4_n_0\
    );
\axi_awaddr_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[5]_i_1_n_6\,
      Q => \^m_axi_awaddr\(3),
      R => '0'
    );
\axi_awaddr_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[5]_i_1_n_5\,
      Q => \^m_axi_awaddr\(4),
      R => '0'
    );
\axi_awaddr_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[5]_i_1_n_4\,
      Q => \^m_axi_awaddr\(5),
      R => '0'
    );
\axi_awaddr_reg[5]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \axi_awaddr_reg[5]_i_1_n_0\,
      CO(2) => \axi_awaddr_reg[5]_i_1_n_1\,
      CO(1) => \axi_awaddr_reg[5]_i_1_n_2\,
      CO(0) => \axi_awaddr_reg[5]_i_1_n_3\,
      CYINIT => '0',
      DI(3) => \axi_awaddr[5]_i_2_n_0\,
      DI(2) => \axi_awaddr[5]_i_3_n_0\,
      DI(1) => \axi_awaddr[5]_i_4_n_0\,
      DI(0) => '0',
      O(3) => \axi_awaddr_reg[5]_i_1_n_4\,
      O(2) => \axi_awaddr_reg[5]_i_1_n_5\,
      O(1) => \axi_awaddr_reg[5]_i_1_n_6\,
      O(0) => \axi_awaddr_reg[5]_i_1_n_7\,
      S(3) => \axi_awaddr[5]_i_5_n_0\,
      S(2) => \axi_awaddr[5]_i_6_n_0\,
      S(1) => \axi_awaddr[5]_i_7_n_0\,
      S(0) => \axi_awaddr[5]_i_8_n_0\
    );
\axi_awaddr_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[9]_i_1_n_7\,
      Q => \^m_axi_awaddr\(6),
      R => '0'
    );
\axi_awaddr_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[9]_i_1_n_6\,
      Q => \^m_axi_awaddr\(7),
      R => '0'
    );
\axi_awaddr_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[9]_i_1_n_5\,
      Q => \^m_axi_awaddr\(8),
      R => '0'
    );
\axi_awaddr_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \axi_awaddr[31]_i_1_n_0\,
      D => \axi_awaddr_reg[9]_i_1_n_4\,
      Q => \^m_axi_awaddr\(9),
      R => '0'
    );
\axi_awaddr_reg[9]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \axi_awaddr_reg[5]_i_1_n_0\,
      CO(3) => \axi_awaddr_reg[9]_i_1_n_0\,
      CO(2) => \axi_awaddr_reg[9]_i_1_n_1\,
      CO(1) => \axi_awaddr_reg[9]_i_1_n_2\,
      CO(0) => \axi_awaddr_reg[9]_i_1_n_3\,
      CYINIT => '0',
      DI(3) => \axi_awaddr[9]_i_2_n_0\,
      DI(2) => \axi_awaddr[9]_i_3_n_0\,
      DI(1) => \axi_awaddr[9]_i_4_n_0\,
      DI(0) => \axi_awaddr[9]_i_5_n_0\,
      O(3) => \axi_awaddr_reg[9]_i_1_n_4\,
      O(2) => \axi_awaddr_reg[9]_i_1_n_5\,
      O(1) => \axi_awaddr_reg[9]_i_1_n_6\,
      O(0) => \axi_awaddr_reg[9]_i_1_n_7\,
      S(3) => \axi_awaddr[9]_i_6_n_0\,
      S(2) => \axi_awaddr[9]_i_7_n_0\,
      S(1) => \axi_awaddr[9]_i_8_n_0\,
      S(0) => \axi_awaddr[9]_i_9_n_0\
    );
axi_awvalid_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"40FF4040"
    )
        port map (
      I0 => M_AXI_AWREADY,
      I1 => axi_wstart_locked,
      I2 => \^m_axi_awvalid\,
      I3 => axi_wstart_locked_r2,
      I4 => axi_wstart_locked_r1,
      O => axi_awvalid_i_1_n_0
    );
axi_awvalid_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_awvalid_i_1_n_0,
      Q => \^m_axi_awvalid\,
      R => '0'
    );
axi_rlast0_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => NLW_axi_rlast0_carry_CO_UNCONNECTED(3),
      CO(2) => axi_rlast0,
      CO(1) => axi_rlast0_carry_n_2,
      CO(0) => axi_rlast0_carry_n_3,
      CYINIT => '1',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => NLW_axi_rlast0_carry_O_UNCONNECTED(3 downto 0),
      S(3) => '0',
      S(2) => axi_rlast0_carry_i_1_n_0,
      S(1) => axi_rlast0_carry_i_2_n_0,
      S(0) => axi_rlast0_carry_i_3_n_0
    );
axi_rlast0_carry_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000094020294"
    )
        port map (
      I0 => rburst_cnt_reg(6),
      I1 => axi_rlast0_carry_i_4_n_0,
      I2 => axi_rburst_size(9),
      I3 => rburst_cnt_reg(7),
      I4 => axi_rburst_size(10),
      I5 => rburst_cnt_reg(8),
      O => axi_rlast0_carry_i_1_n_0
    );
axi_rlast0_carry_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8200008200822400"
    )
        port map (
      I0 => axi_rlast0_carry_i_5_n_0,
      I1 => rburst_cnt_reg(4),
      I2 => axi_rburst_size(7),
      I3 => rburst_cnt_reg(3),
      I4 => axi_rburst_size(6),
      I5 => \M_AXI_ARLEN[7]_INST_0_i_1_n_0\,
      O => axi_rlast0_carry_i_2_n_0
    );
axi_rlast0_carry_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0920004000400920"
    )
        port map (
      I0 => axi_rburst_size(4),
      I1 => rburst_cnt_reg(1),
      I2 => rburst_cnt_reg(0),
      I3 => axi_rburst_size(3),
      I4 => rburst_cnt_reg(2),
      I5 => axi_rburst_size(5),
      O => axi_rlast0_carry_i_3_n_0
    );
axi_rlast0_carry_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFFE"
    )
        port map (
      I0 => axi_rburst_size(7),
      I1 => axi_rburst_size(5),
      I2 => axi_rburst_size(3),
      I3 => axi_rburst_size(4),
      I4 => axi_rburst_size(6),
      I5 => axi_rburst_size(8),
      O => axi_rlast0_carry_i_4_n_0
    );
axi_rlast0_carry_i_5: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => axi_rburst_size(8),
      I1 => rburst_cnt_reg(5),
      O => axi_rlast0_carry_i_5_n_0
    );
axi_rready_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B000FFFFB000B000"
    )
        port map (
      I0 => axi_rstart_locked_i_2_n_0,
      I1 => axi_rlast0,
      I2 => axi_rstart_locked,
      I3 => axi_rready,
      I4 => axi_rstart_locked_r2,
      I5 => axi_rstart_locked_r1,
      O => axi_rready_i_1_n_0
    );
axi_rready_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_rready_i_1_n_0,
      Q => axi_rready,
      R => '0'
    );
axi_rstart_locked_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BB0BFF00"
    )
        port map (
      I0 => axi_rstart_locked_i_2_n_0,
      I1 => axi_rlast0,
      I2 => fdma_rareq,
      I3 => \^fdma_rstart_locked_reg_0\,
      I4 => axi_rstart_locked,
      O => axi_rstart_locked_i_1_n_0
    );
axi_rstart_locked_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => fdma_rready,
      I1 => axi_rready,
      I2 => M_AXI_RVALID,
      O => axi_rstart_locked_i_2_n_0
    );
axi_rstart_locked_r1_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_rstart_locked,
      Q => axi_rstart_locked_r1,
      R => '0'
    );
axi_rstart_locked_r2_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_rstart_locked_r1,
      Q => axi_rstart_locked_r2,
      R => '0'
    );
axi_rstart_locked_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_rstart_locked_i_1_n_0,
      Q => axi_rstart_locked,
      R => '0'
    );
axi_wlast0_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => NLW_axi_wlast0_carry_CO_UNCONNECTED(3),
      CO(2) => axi_wlast0,
      CO(1) => axi_wlast0_carry_n_2,
      CO(0) => axi_wlast0_carry_n_3,
      CYINIT => '1',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => NLW_axi_wlast0_carry_O_UNCONNECTED(3 downto 0),
      S(3) => '0',
      S(2) => axi_wlast0_carry_i_1_n_0,
      S(1) => axi_wlast0_carry_i_2_n_0,
      S(0) => axi_wlast0_carry_i_3_n_0
    );
axi_wlast0_carry_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000094020294"
    )
        port map (
      I0 => wburst_cnt_reg(6),
      I1 => axi_wlast0_carry_i_4_n_0,
      I2 => axi_wburst_size(9),
      I3 => wburst_cnt_reg(7),
      I4 => axi_wburst_size(10),
      I5 => wburst_cnt_reg(8),
      O => axi_wlast0_carry_i_1_n_0
    );
axi_wlast0_carry_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8200008200822400"
    )
        port map (
      I0 => axi_wlast0_carry_i_5_n_0,
      I1 => wburst_cnt_reg(4),
      I2 => axi_wburst_size(7),
      I3 => wburst_cnt_reg(3),
      I4 => axi_wburst_size(6),
      I5 => \M_AXI_AWLEN[7]_INST_0_i_1_n_0\,
      O => axi_wlast0_carry_i_2_n_0
    );
axi_wlast0_carry_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0920004000400920"
    )
        port map (
      I0 => axi_wburst_size(4),
      I1 => wburst_cnt_reg(1),
      I2 => wburst_cnt_reg(0),
      I3 => axi_wburst_size(3),
      I4 => wburst_cnt_reg(2),
      I5 => axi_wburst_size(5),
      O => axi_wlast0_carry_i_3_n_0
    );
axi_wlast0_carry_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFFE"
    )
        port map (
      I0 => axi_wburst_size(7),
      I1 => axi_wburst_size(5),
      I2 => axi_wburst_size(3),
      I3 => axi_wburst_size(4),
      I4 => axi_wburst_size(6),
      I5 => axi_wburst_size(8),
      O => axi_wlast0_carry_i_4_n_0
    );
axi_wlast0_carry_i_5: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => axi_wburst_size(8),
      I1 => wburst_cnt_reg(5),
      O => axi_wlast0_carry_i_5_n_0
    );
axi_wstart_locked_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BB0BFF00"
    )
        port map (
      I0 => axi_wstart_locked_i_2_n_0,
      I1 => axi_wlast0,
      I2 => fdma_wareq,
      I3 => \^fdma_wstart_locked_reg_0\,
      I4 => axi_wstart_locked,
      O => axi_wstart_locked_i_1_n_0
    );
axi_wstart_locked_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => fdma_wready,
      I1 => axi_wvalid,
      I2 => M_AXI_WREADY,
      O => axi_wstart_locked_i_2_n_0
    );
axi_wstart_locked_r1_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_wstart_locked,
      Q => axi_wstart_locked_r1,
      R => '0'
    );
axi_wstart_locked_r2_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_wstart_locked_r1,
      Q => axi_wstart_locked_r2,
      R => '0'
    );
axi_wstart_locked_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_wstart_locked_i_1_n_0,
      Q => axi_wstart_locked,
      R => '0'
    );
axi_wvalid_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B000FFFFB000B000"
    )
        port map (
      I0 => axi_wstart_locked_i_2_n_0,
      I1 => axi_wlast0,
      I2 => axi_wstart_locked,
      I3 => axi_wvalid,
      I4 => axi_wstart_locked_r2,
      I5 => axi_wstart_locked_r1,
      O => axi_wvalid_i_1_n_0
    );
axi_wvalid_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => axi_wvalid_i_1_n_0,
      Q => axi_wvalid,
      R => '0'
    );
fdma_rleft_cnt0_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => fdma_rleft_cnt0_carry_n_0,
      CO(2) => fdma_rleft_cnt0_carry_n_1,
      CO(1) => fdma_rleft_cnt0_carry_n_2,
      CO(0) => fdma_rleft_cnt0_carry_n_3,
      CYINIT => '0',
      DI(3 downto 0) => fdma_rsize(3 downto 0),
      O(3 downto 0) => fdma_rleft_cnt(3 downto 0),
      S(3) => fdma_rleft_cnt0_carry_i_1_n_0,
      S(2) => fdma_rleft_cnt0_carry_i_2_n_0,
      S(1) => fdma_rleft_cnt0_carry_i_3_n_0,
      S(0) => fdma_rleft_cnt0_carry_i_4_n_0
    );
\fdma_rleft_cnt0_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => fdma_rleft_cnt0_carry_n_0,
      CO(3) => \fdma_rleft_cnt0_carry__0_n_0\,
      CO(2) => \fdma_rleft_cnt0_carry__0_n_1\,
      CO(1) => \fdma_rleft_cnt0_carry__0_n_2\,
      CO(0) => \fdma_rleft_cnt0_carry__0_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fdma_rsize(7 downto 4),
      O(3 downto 0) => fdma_rleft_cnt(7 downto 4),
      S(3) => \fdma_rleft_cnt0_carry__0_i_1_n_0\,
      S(2) => \fdma_rleft_cnt0_carry__0_i_2_n_0\,
      S(1) => \fdma_rleft_cnt0_carry__0_i_3_n_0\,
      S(0) => \fdma_rleft_cnt0_carry__0_i_4_n_0\
    );
\fdma_rleft_cnt0_carry__0_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(7),
      I1 => rfdma_cnt_reg(7),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__0_i_1_n_0\
    );
\fdma_rleft_cnt0_carry__0_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(6),
      I1 => rfdma_cnt_reg(6),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__0_i_2_n_0\
    );
\fdma_rleft_cnt0_carry__0_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(5),
      I1 => rfdma_cnt_reg(5),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__0_i_3_n_0\
    );
\fdma_rleft_cnt0_carry__0_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(4),
      I1 => rfdma_cnt_reg(4),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__0_i_4_n_0\
    );
\fdma_rleft_cnt0_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \fdma_rleft_cnt0_carry__0_n_0\,
      CO(3) => \fdma_rleft_cnt0_carry__1_n_0\,
      CO(2) => \fdma_rleft_cnt0_carry__1_n_1\,
      CO(1) => \fdma_rleft_cnt0_carry__1_n_2\,
      CO(0) => \fdma_rleft_cnt0_carry__1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fdma_rsize(11 downto 8),
      O(3 downto 0) => fdma_rleft_cnt(11 downto 8),
      S(3) => \fdma_rleft_cnt0_carry__1_i_1_n_0\,
      S(2) => \fdma_rleft_cnt0_carry__1_i_2_n_0\,
      S(1) => \fdma_rleft_cnt0_carry__1_i_3_n_0\,
      S(0) => \fdma_rleft_cnt0_carry__1_i_4_n_0\
    );
\fdma_rleft_cnt0_carry__1_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(11),
      I1 => rfdma_cnt_reg(11),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__1_i_1_n_0\
    );
\fdma_rleft_cnt0_carry__1_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(10),
      I1 => rfdma_cnt_reg(10),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__1_i_2_n_0\
    );
\fdma_rleft_cnt0_carry__1_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(9),
      I1 => rfdma_cnt_reg(9),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__1_i_3_n_0\
    );
\fdma_rleft_cnt0_carry__1_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(8),
      I1 => rfdma_cnt_reg(8),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__1_i_4_n_0\
    );
\fdma_rleft_cnt0_carry__2\: unisim.vcomponents.CARRY4
     port map (
      CI => \fdma_rleft_cnt0_carry__1_n_0\,
      CO(3) => \NLW_fdma_rleft_cnt0_carry__2_CO_UNCONNECTED\(3),
      CO(2) => \fdma_rleft_cnt0_carry__2_n_1\,
      CO(1) => \fdma_rleft_cnt0_carry__2_n_2\,
      CO(0) => \fdma_rleft_cnt0_carry__2_n_3\,
      CYINIT => '0',
      DI(3) => '0',
      DI(2 downto 0) => fdma_rsize(14 downto 12),
      O(3 downto 0) => fdma_rleft_cnt(15 downto 12),
      S(3) => \fdma_rleft_cnt0_carry__2_i_1_n_0\,
      S(2) => \fdma_rleft_cnt0_carry__2_i_2_n_0\,
      S(1) => \fdma_rleft_cnt0_carry__2_i_3_n_0\,
      S(0) => \fdma_rleft_cnt0_carry__2_i_4_n_0\
    );
\fdma_rleft_cnt0_carry__2_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"F40B"
    )
        port map (
      I0 => \^fdma_rstart_locked_reg_0\,
      I1 => fdma_rareq,
      I2 => rfdma_cnt_reg(15),
      I3 => fdma_rsize(15),
      O => \fdma_rleft_cnt0_carry__2_i_1_n_0\
    );
\fdma_rleft_cnt0_carry__2_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(14),
      I1 => rfdma_cnt_reg(14),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__2_i_2_n_0\
    );
\fdma_rleft_cnt0_carry__2_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(13),
      I1 => rfdma_cnt_reg(13),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__2_i_3_n_0\
    );
\fdma_rleft_cnt0_carry__2_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(12),
      I1 => rfdma_cnt_reg(12),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => \fdma_rleft_cnt0_carry__2_i_4_n_0\
    );
fdma_rleft_cnt0_carry_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(3),
      I1 => rfdma_cnt_reg(3),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => fdma_rleft_cnt0_carry_i_1_n_0
    );
fdma_rleft_cnt0_carry_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(2),
      I1 => rfdma_cnt_reg(2),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => fdma_rleft_cnt0_carry_i_2_n_0
    );
fdma_rleft_cnt0_carry_i_3: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(1),
      I1 => rfdma_cnt_reg(1),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => fdma_rleft_cnt0_carry_i_3_n_0
    );
fdma_rleft_cnt0_carry_i_4: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_rsize(0),
      I1 => rfdma_cnt_reg(0),
      I2 => \^fdma_rstart_locked_reg_0\,
      I3 => fdma_rareq,
      O => fdma_rleft_cnt0_carry_i_4_n_0
    );
\fdma_rleft_cnt[15]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"8080FF80"
    )
        port map (
      I0 => M_AXI_RVALID,
      I1 => axi_rready,
      I2 => fdma_rready,
      I3 => fdma_rareq,
      I4 => \^fdma_rstart_locked_reg_0\,
      O => \fdma_rleft_cnt[15]_i_1_n_0\
    );
\fdma_rleft_cnt_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(0),
      Q => \fdma_rleft_cnt_reg_n_0_[0]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(10),
      Q => \fdma_rleft_cnt_reg_n_0_[10]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(11),
      Q => \fdma_rleft_cnt_reg_n_0_[11]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(12),
      Q => \fdma_rleft_cnt_reg_n_0_[12]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(13),
      Q => \fdma_rleft_cnt_reg_n_0_[13]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(14),
      Q => \fdma_rleft_cnt_reg_n_0_[14]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(15),
      Q => \fdma_rleft_cnt_reg_n_0_[15]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(1),
      Q => \fdma_rleft_cnt_reg_n_0_[1]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(2),
      Q => \fdma_rleft_cnt_reg_n_0_[2]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(3),
      Q => \fdma_rleft_cnt_reg_n_0_[3]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(4),
      Q => \fdma_rleft_cnt_reg_n_0_[4]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(5),
      Q => \fdma_rleft_cnt_reg_n_0_[5]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(6),
      Q => \fdma_rleft_cnt_reg_n_0_[6]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(7),
      Q => \fdma_rleft_cnt_reg_n_0_[7]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(8),
      Q => \fdma_rleft_cnt_reg_n_0_[8]\,
      R => '0'
    );
\fdma_rleft_cnt_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_rleft_cnt[15]_i_1_n_0\,
      D => fdma_rleft_cnt(9),
      Q => \fdma_rleft_cnt_reg_n_0_[9]\,
      R => '0'
    );
fdma_rstart_locked_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFFAEA"
    )
        port map (
      I0 => fdma_rstart_locked_i_2_n_0,
      I1 => \fdma_rleft_cnt_reg_n_0_[6]\,
      I2 => fdma_rstart_locked_i_3_n_0,
      I3 => fdma_rstart_locked_i_4_n_0,
      I4 => fdma_rstart_locked_i_5_n_0,
      O => fdma_rstart_locked_i_1_n_0
    );
fdma_rstart_locked_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF0000FFFD0000"
    )
        port map (
      I0 => \fdma_rleft_cnt_reg_n_0_[0]\,
      I1 => \fdma_rleft_cnt_reg_n_0_[3]\,
      I2 => \fdma_rleft_cnt_reg_n_0_[4]\,
      I3 => \fdma_rleft_cnt_reg_n_0_[2]\,
      I4 => fdma_rstart_locked_i_3_n_0,
      I5 => \fdma_rleft_cnt_reg_n_0_[1]\,
      O => fdma_rstart_locked_i_2_n_0
    );
fdma_rstart_locked_i_3: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E0"
    )
        port map (
      I0 => \^fdma_rstart_locked_reg_0\,
      I1 => fdma_rareq,
      I2 => M_AXI_ARESETN,
      O => fdma_rstart_locked_i_3_n_0
    );
fdma_rstart_locked_i_4: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFFFFE"
    )
        port map (
      I0 => \fdma_rleft_cnt_reg_n_0_[10]\,
      I1 => \fdma_rleft_cnt_reg_n_0_[11]\,
      I2 => \fdma_rleft_cnt_reg_n_0_[8]\,
      I3 => \fdma_rleft_cnt_reg_n_0_[9]\,
      I4 => \rburst_len[8]_i_2_n_0\,
      O => fdma_rstart_locked_i_4_n_0
    );
fdma_rstart_locked_i_5: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF0000FF7F0000"
    )
        port map (
      I0 => M_AXI_RVALID,
      I1 => axi_rready,
      I2 => fdma_rready,
      I3 => \fdma_rleft_cnt_reg_n_0_[7]\,
      I4 => fdma_rstart_locked_i_3_n_0,
      I5 => \fdma_rleft_cnt_reg_n_0_[5]\,
      O => fdma_rstart_locked_i_5_n_0
    );
fdma_rstart_locked_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => fdma_rstart_locked_i_1_n_0,
      Q => \^fdma_rstart_locked_reg_0\,
      R => '0'
    );
fdma_rvalid_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"80"
    )
        port map (
      I0 => M_AXI_RVALID,
      I1 => axi_rready,
      I2 => fdma_rready,
      O => \^fdma_rvalid\
    );
fdma_wleft_cnt0_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => fdma_wleft_cnt0_carry_n_0,
      CO(2) => fdma_wleft_cnt0_carry_n_1,
      CO(1) => fdma_wleft_cnt0_carry_n_2,
      CO(0) => fdma_wleft_cnt0_carry_n_3,
      CYINIT => '0',
      DI(3 downto 0) => fdma_wsize(3 downto 0),
      O(3 downto 0) => fdma_wleft_cnt(3 downto 0),
      S(3) => fdma_wleft_cnt0_carry_i_1_n_0,
      S(2) => fdma_wleft_cnt0_carry_i_2_n_0,
      S(1) => fdma_wleft_cnt0_carry_i_3_n_0,
      S(0) => fdma_wleft_cnt0_carry_i_4_n_0
    );
\fdma_wleft_cnt0_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => fdma_wleft_cnt0_carry_n_0,
      CO(3) => \fdma_wleft_cnt0_carry__0_n_0\,
      CO(2) => \fdma_wleft_cnt0_carry__0_n_1\,
      CO(1) => \fdma_wleft_cnt0_carry__0_n_2\,
      CO(0) => \fdma_wleft_cnt0_carry__0_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fdma_wsize(7 downto 4),
      O(3 downto 0) => fdma_wleft_cnt(7 downto 4),
      S(3) => \fdma_wleft_cnt0_carry__0_i_1_n_0\,
      S(2) => \fdma_wleft_cnt0_carry__0_i_2_n_0\,
      S(1) => \fdma_wleft_cnt0_carry__0_i_3_n_0\,
      S(0) => \fdma_wleft_cnt0_carry__0_i_4_n_0\
    );
\fdma_wleft_cnt0_carry__0_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(7),
      I1 => wfdma_cnt_reg(7),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__0_i_1_n_0\
    );
\fdma_wleft_cnt0_carry__0_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(6),
      I1 => wfdma_cnt_reg(6),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__0_i_2_n_0\
    );
\fdma_wleft_cnt0_carry__0_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(5),
      I1 => wfdma_cnt_reg(5),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__0_i_3_n_0\
    );
\fdma_wleft_cnt0_carry__0_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(4),
      I1 => wfdma_cnt_reg(4),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__0_i_4_n_0\
    );
\fdma_wleft_cnt0_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \fdma_wleft_cnt0_carry__0_n_0\,
      CO(3) => \fdma_wleft_cnt0_carry__1_n_0\,
      CO(2) => \fdma_wleft_cnt0_carry__1_n_1\,
      CO(1) => \fdma_wleft_cnt0_carry__1_n_2\,
      CO(0) => \fdma_wleft_cnt0_carry__1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fdma_wsize(11 downto 8),
      O(3 downto 0) => fdma_wleft_cnt(11 downto 8),
      S(3) => \fdma_wleft_cnt0_carry__1_i_1_n_0\,
      S(2) => \fdma_wleft_cnt0_carry__1_i_2_n_0\,
      S(1) => \fdma_wleft_cnt0_carry__1_i_3_n_0\,
      S(0) => \fdma_wleft_cnt0_carry__1_i_4_n_0\
    );
\fdma_wleft_cnt0_carry__1_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(11),
      I1 => wfdma_cnt_reg(11),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__1_i_1_n_0\
    );
\fdma_wleft_cnt0_carry__1_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(10),
      I1 => wfdma_cnt_reg(10),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__1_i_2_n_0\
    );
\fdma_wleft_cnt0_carry__1_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(9),
      I1 => wfdma_cnt_reg(9),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__1_i_3_n_0\
    );
\fdma_wleft_cnt0_carry__1_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(8),
      I1 => wfdma_cnt_reg(8),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__1_i_4_n_0\
    );
\fdma_wleft_cnt0_carry__2\: unisim.vcomponents.CARRY4
     port map (
      CI => \fdma_wleft_cnt0_carry__1_n_0\,
      CO(3) => \NLW_fdma_wleft_cnt0_carry__2_CO_UNCONNECTED\(3),
      CO(2) => \fdma_wleft_cnt0_carry__2_n_1\,
      CO(1) => \fdma_wleft_cnt0_carry__2_n_2\,
      CO(0) => \fdma_wleft_cnt0_carry__2_n_3\,
      CYINIT => '0',
      DI(3) => '0',
      DI(2 downto 0) => fdma_wsize(14 downto 12),
      O(3 downto 0) => fdma_wleft_cnt(15 downto 12),
      S(3) => \fdma_wleft_cnt0_carry__2_i_1_n_0\,
      S(2) => \fdma_wleft_cnt0_carry__2_i_2_n_0\,
      S(1) => \fdma_wleft_cnt0_carry__2_i_3_n_0\,
      S(0) => \fdma_wleft_cnt0_carry__2_i_4_n_0\
    );
\fdma_wleft_cnt0_carry__2_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"F40B"
    )
        port map (
      I0 => \^fdma_wstart_locked_reg_0\,
      I1 => fdma_wareq,
      I2 => wfdma_cnt_reg(15),
      I3 => fdma_wsize(15),
      O => \fdma_wleft_cnt0_carry__2_i_1_n_0\
    );
\fdma_wleft_cnt0_carry__2_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(14),
      I1 => wfdma_cnt_reg(14),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__2_i_2_n_0\
    );
\fdma_wleft_cnt0_carry__2_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(13),
      I1 => wfdma_cnt_reg(13),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__2_i_3_n_0\
    );
\fdma_wleft_cnt0_carry__2_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(12),
      I1 => wfdma_cnt_reg(12),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => \fdma_wleft_cnt0_carry__2_i_4_n_0\
    );
fdma_wleft_cnt0_carry_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(3),
      I1 => wfdma_cnt_reg(3),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => fdma_wleft_cnt0_carry_i_1_n_0
    );
fdma_wleft_cnt0_carry_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(2),
      I1 => wfdma_cnt_reg(2),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => fdma_wleft_cnt0_carry_i_2_n_0
    );
fdma_wleft_cnt0_carry_i_3: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(1),
      I1 => wfdma_cnt_reg(1),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => fdma_wleft_cnt0_carry_i_3_n_0
    );
fdma_wleft_cnt0_carry_i_4: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9A99"
    )
        port map (
      I0 => fdma_wsize(0),
      I1 => wfdma_cnt_reg(0),
      I2 => \^fdma_wstart_locked_reg_0\,
      I3 => fdma_wareq,
      O => fdma_wleft_cnt0_carry_i_4_n_0
    );
\fdma_wleft_cnt[15]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"8080FF80"
    )
        port map (
      I0 => M_AXI_WREADY,
      I1 => axi_wvalid,
      I2 => fdma_wready,
      I3 => fdma_wareq,
      I4 => \^fdma_wstart_locked_reg_0\,
      O => \fdma_wleft_cnt[15]_i_1_n_0\
    );
\fdma_wleft_cnt_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(0),
      Q => \fdma_wleft_cnt_reg_n_0_[0]\,
      R => '0'
    );
\fdma_wleft_cnt_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(10),
      Q => p_0_in_0(2),
      R => '0'
    );
\fdma_wleft_cnt_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(11),
      Q => p_0_in_0(3),
      R => '0'
    );
\fdma_wleft_cnt_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(12),
      Q => p_0_in_0(4),
      R => '0'
    );
\fdma_wleft_cnt_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(13),
      Q => p_0_in_0(5),
      R => '0'
    );
\fdma_wleft_cnt_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(14),
      Q => p_0_in_0(6),
      R => '0'
    );
\fdma_wleft_cnt_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(15),
      Q => p_0_in_0(7),
      R => '0'
    );
\fdma_wleft_cnt_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(1),
      Q => \fdma_wleft_cnt_reg_n_0_[1]\,
      R => '0'
    );
\fdma_wleft_cnt_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(2),
      Q => \fdma_wleft_cnt_reg_n_0_[2]\,
      R => '0'
    );
\fdma_wleft_cnt_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(3),
      Q => \fdma_wleft_cnt_reg_n_0_[3]\,
      R => '0'
    );
\fdma_wleft_cnt_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(4),
      Q => \fdma_wleft_cnt_reg_n_0_[4]\,
      R => '0'
    );
\fdma_wleft_cnt_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(5),
      Q => \fdma_wleft_cnt_reg_n_0_[5]\,
      R => '0'
    );
\fdma_wleft_cnt_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(6),
      Q => \fdma_wleft_cnt_reg_n_0_[6]\,
      R => '0'
    );
\fdma_wleft_cnt_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(7),
      Q => \fdma_wleft_cnt_reg_n_0_[7]\,
      R => '0'
    );
\fdma_wleft_cnt_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(8),
      Q => p_0_in_0(0),
      R => '0'
    );
\fdma_wleft_cnt_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \fdma_wleft_cnt[15]_i_1_n_0\,
      D => fdma_wleft_cnt(9),
      Q => p_0_in_0(1),
      R => '0'
    );
fdma_wstart_locked_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFFAEA"
    )
        port map (
      I0 => fdma_wstart_locked_i_2_n_0,
      I1 => \fdma_wleft_cnt_reg_n_0_[6]\,
      I2 => fdma_wstart_locked_i_3_n_0,
      I3 => fdma_wstart_locked_i_4_n_0,
      I4 => fdma_wstart_locked_i_5_n_0,
      O => fdma_wstart_locked_i_1_n_0
    );
fdma_wstart_locked_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF0000FFFD0000"
    )
        port map (
      I0 => \fdma_wleft_cnt_reg_n_0_[0]\,
      I1 => \fdma_wleft_cnt_reg_n_0_[3]\,
      I2 => \fdma_wleft_cnt_reg_n_0_[4]\,
      I3 => \fdma_wleft_cnt_reg_n_0_[2]\,
      I4 => fdma_wstart_locked_i_3_n_0,
      I5 => \fdma_wleft_cnt_reg_n_0_[1]\,
      O => fdma_wstart_locked_i_2_n_0
    );
fdma_wstart_locked_i_3: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E0"
    )
        port map (
      I0 => \^fdma_wstart_locked_reg_0\,
      I1 => fdma_wareq,
      I2 => M_AXI_ARESETN,
      O => fdma_wstart_locked_i_3_n_0
    );
fdma_wstart_locked_i_4: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFFFFE"
    )
        port map (
      I0 => p_0_in_0(2),
      I1 => p_0_in_0(3),
      I2 => p_0_in_0(0),
      I3 => p_0_in_0(1),
      I4 => \wburst_len[8]_i_2_n_0\,
      O => fdma_wstart_locked_i_4_n_0
    );
fdma_wstart_locked_i_5: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF0000FF7F0000"
    )
        port map (
      I0 => M_AXI_WREADY,
      I1 => axi_wvalid,
      I2 => fdma_wready,
      I3 => \fdma_wleft_cnt_reg_n_0_[7]\,
      I4 => fdma_wstart_locked_i_3_n_0,
      I5 => \fdma_wleft_cnt_reg_n_0_[5]\,
      O => fdma_wstart_locked_i_5_n_0
    );
fdma_wstart_locked_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => fdma_wstart_locked_i_1_n_0,
      Q => \^fdma_wstart_locked_reg_0\,
      R => '0'
    );
fdma_wvalid_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"80"
    )
        port map (
      I0 => M_AXI_WREADY,
      I1 => axi_wvalid,
      I2 => fdma_wready,
      O => \^fdma_wvalid\
    );
\rburst_cnt[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => rburst_cnt_reg(0),
      O => \p_0_in__0\(0)
    );
\rburst_cnt[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => rburst_cnt_reg(0),
      I1 => rburst_cnt_reg(1),
      O => \p_0_in__0\(1)
    );
\rburst_cnt[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => rburst_cnt_reg(1),
      I1 => rburst_cnt_reg(0),
      I2 => rburst_cnt_reg(2),
      O => \p_0_in__0\(2)
    );
\rburst_cnt[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => rburst_cnt_reg(2),
      I1 => rburst_cnt_reg(0),
      I2 => rburst_cnt_reg(1),
      I3 => rburst_cnt_reg(3),
      O => \p_0_in__0\(3)
    );
\rburst_cnt[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
        port map (
      I0 => rburst_cnt_reg(3),
      I1 => rburst_cnt_reg(1),
      I2 => rburst_cnt_reg(0),
      I3 => rburst_cnt_reg(2),
      I4 => rburst_cnt_reg(4),
      O => \p_0_in__0\(4)
    );
\rburst_cnt[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFF80000000"
    )
        port map (
      I0 => rburst_cnt_reg(4),
      I1 => rburst_cnt_reg(2),
      I2 => rburst_cnt_reg(0),
      I3 => rburst_cnt_reg(1),
      I4 => rburst_cnt_reg(3),
      I5 => rburst_cnt_reg(5),
      O => \p_0_in__0\(5)
    );
\rburst_cnt[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F7FF0800"
    )
        port map (
      I0 => rburst_cnt_reg(5),
      I1 => rburst_cnt_reg(3),
      I2 => \rburst_cnt[7]_i_2_n_0\,
      I3 => rburst_cnt_reg(4),
      I4 => rburst_cnt_reg(6),
      O => \p_0_in__0\(6)
    );
\rburst_cnt[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F7FFFFFF08000000"
    )
        port map (
      I0 => rburst_cnt_reg(6),
      I1 => rburst_cnt_reg(4),
      I2 => \rburst_cnt[7]_i_2_n_0\,
      I3 => rburst_cnt_reg(3),
      I4 => rburst_cnt_reg(5),
      I5 => rburst_cnt_reg(7),
      O => \p_0_in__0\(7)
    );
\rburst_cnt[7]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => rburst_cnt_reg(1),
      I1 => rburst_cnt_reg(0),
      I2 => rburst_cnt_reg(2),
      O => \rburst_cnt[7]_i_2_n_0\
    );
\rburst_cnt[8]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => axi_rstart_locked,
      O => axi_rstart_locked1
    );
\rburst_cnt[8]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"DF20"
    )
        port map (
      I0 => rburst_cnt_reg(7),
      I1 => \rburst_cnt[8]_i_3_n_0\,
      I2 => rburst_cnt_reg(6),
      I3 => rburst_cnt_reg(8),
      O => \p_0_in__0\(8)
    );
\rburst_cnt[8]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => rburst_cnt_reg(4),
      I1 => rburst_cnt_reg(2),
      I2 => rburst_cnt_reg(0),
      I3 => rburst_cnt_reg(1),
      I4 => rburst_cnt_reg(3),
      I5 => rburst_cnt_reg(5),
      O => \rburst_cnt[8]_i_3_n_0\
    );
\rburst_cnt_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \p_0_in__0\(0),
      Q => rburst_cnt_reg(0),
      R => axi_rstart_locked1
    );
\rburst_cnt_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \p_0_in__0\(1),
      Q => rburst_cnt_reg(1),
      R => axi_rstart_locked1
    );
\rburst_cnt_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \p_0_in__0\(2),
      Q => rburst_cnt_reg(2),
      R => axi_rstart_locked1
    );
\rburst_cnt_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \p_0_in__0\(3),
      Q => rburst_cnt_reg(3),
      R => axi_rstart_locked1
    );
\rburst_cnt_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \p_0_in__0\(4),
      Q => rburst_cnt_reg(4),
      R => axi_rstart_locked1
    );
\rburst_cnt_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \p_0_in__0\(5),
      Q => rburst_cnt_reg(5),
      R => axi_rstart_locked1
    );
\rburst_cnt_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \p_0_in__0\(6),
      Q => rburst_cnt_reg(6),
      R => axi_rstart_locked1
    );
\rburst_cnt_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \p_0_in__0\(7),
      Q => rburst_cnt_reg(7),
      R => axi_rstart_locked1
    );
\rburst_cnt_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \p_0_in__0\(8),
      Q => rburst_cnt_reg(8),
      R => axi_rstart_locked1
    );
\rburst_len[8]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFE00000000"
    )
        port map (
      I0 => \rburst_len[8]_i_2_n_0\,
      I1 => \fdma_rleft_cnt_reg_n_0_[9]\,
      I2 => \fdma_rleft_cnt_reg_n_0_[8]\,
      I3 => \fdma_rleft_cnt_reg_n_0_[11]\,
      I4 => \fdma_rleft_cnt_reg_n_0_[10]\,
      I5 => rburst_len_req,
      O => rburst_len
    );
\rburst_len[8]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => \fdma_rleft_cnt_reg_n_0_[13]\,
      I1 => \fdma_rleft_cnt_reg_n_0_[12]\,
      I2 => \fdma_rleft_cnt_reg_n_0_[15]\,
      I3 => \fdma_rleft_cnt_reg_n_0_[14]\,
      O => \rburst_len[8]_i_2_n_0\
    );
\rburst_len_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => M_AXI_ACLK,
      CE => rburst_len_req,
      D => \fdma_rleft_cnt_reg_n_0_[0]\,
      Q => axi_rburst_size(3),
      R => rburst_len
    );
\rburst_len_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => rburst_len_req,
      D => \fdma_rleft_cnt_reg_n_0_[1]\,
      Q => axi_rburst_size(4),
      R => rburst_len
    );
\rburst_len_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => rburst_len_req,
      D => \fdma_rleft_cnt_reg_n_0_[2]\,
      Q => axi_rburst_size(5),
      R => rburst_len
    );
\rburst_len_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => rburst_len_req,
      D => \fdma_rleft_cnt_reg_n_0_[3]\,
      Q => axi_rburst_size(6),
      R => rburst_len
    );
\rburst_len_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => rburst_len_req,
      D => \fdma_rleft_cnt_reg_n_0_[4]\,
      Q => axi_rburst_size(7),
      R => rburst_len
    );
\rburst_len_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => rburst_len_req,
      D => \fdma_rleft_cnt_reg_n_0_[5]\,
      Q => axi_rburst_size(8),
      R => rburst_len
    );
\rburst_len_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => rburst_len_req,
      D => \fdma_rleft_cnt_reg_n_0_[6]\,
      Q => axi_rburst_size(9),
      R => rburst_len
    );
\rburst_len_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => rburst_len_req,
      D => \fdma_rleft_cnt_reg_n_0_[7]\,
      Q => axi_rburst_size(10),
      R => rburst_len
    );
\rburst_len_reg[8]\: unisim.vcomponents.FDSE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => rburst_len_req,
      D => '0',
      Q => axi_rburst_size(11),
      S => rburst_len
    );
rburst_len_req_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => \axi_araddr[31]_i_1_n_0\,
      Q => rburst_len_req,
      R => '0'
    );
\rfdma_cnt[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => fdma_rareq,
      I1 => \^fdma_rstart_locked_reg_0\,
      O => fdma_rstart
    );
\rfdma_cnt[0]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => rfdma_cnt_reg(0),
      O => \rfdma_cnt[0]_i_3_n_0\
    );
\rfdma_cnt_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[0]_i_2_n_7\,
      Q => rfdma_cnt_reg(0),
      R => fdma_rstart
    );
\rfdma_cnt_reg[0]_i_2\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \rfdma_cnt_reg[0]_i_2_n_0\,
      CO(2) => \rfdma_cnt_reg[0]_i_2_n_1\,
      CO(1) => \rfdma_cnt_reg[0]_i_2_n_2\,
      CO(0) => \rfdma_cnt_reg[0]_i_2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0001",
      O(3) => \rfdma_cnt_reg[0]_i_2_n_4\,
      O(2) => \rfdma_cnt_reg[0]_i_2_n_5\,
      O(1) => \rfdma_cnt_reg[0]_i_2_n_6\,
      O(0) => \rfdma_cnt_reg[0]_i_2_n_7\,
      S(3 downto 1) => rfdma_cnt_reg(3 downto 1),
      S(0) => \rfdma_cnt[0]_i_3_n_0\
    );
\rfdma_cnt_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[8]_i_1_n_5\,
      Q => rfdma_cnt_reg(10),
      R => fdma_rstart
    );
\rfdma_cnt_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[8]_i_1_n_4\,
      Q => rfdma_cnt_reg(11),
      R => fdma_rstart
    );
\rfdma_cnt_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[12]_i_1_n_7\,
      Q => rfdma_cnt_reg(12),
      R => fdma_rstart
    );
\rfdma_cnt_reg[12]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \rfdma_cnt_reg[8]_i_1_n_0\,
      CO(3) => \NLW_rfdma_cnt_reg[12]_i_1_CO_UNCONNECTED\(3),
      CO(2) => \rfdma_cnt_reg[12]_i_1_n_1\,
      CO(1) => \rfdma_cnt_reg[12]_i_1_n_2\,
      CO(0) => \rfdma_cnt_reg[12]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \rfdma_cnt_reg[12]_i_1_n_4\,
      O(2) => \rfdma_cnt_reg[12]_i_1_n_5\,
      O(1) => \rfdma_cnt_reg[12]_i_1_n_6\,
      O(0) => \rfdma_cnt_reg[12]_i_1_n_7\,
      S(3 downto 0) => rfdma_cnt_reg(15 downto 12)
    );
\rfdma_cnt_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[12]_i_1_n_6\,
      Q => rfdma_cnt_reg(13),
      R => fdma_rstart
    );
\rfdma_cnt_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[12]_i_1_n_5\,
      Q => rfdma_cnt_reg(14),
      R => fdma_rstart
    );
\rfdma_cnt_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[12]_i_1_n_4\,
      Q => rfdma_cnt_reg(15),
      R => fdma_rstart
    );
\rfdma_cnt_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[0]_i_2_n_6\,
      Q => rfdma_cnt_reg(1),
      R => fdma_rstart
    );
\rfdma_cnt_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[0]_i_2_n_5\,
      Q => rfdma_cnt_reg(2),
      R => fdma_rstart
    );
\rfdma_cnt_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[0]_i_2_n_4\,
      Q => rfdma_cnt_reg(3),
      R => fdma_rstart
    );
\rfdma_cnt_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[4]_i_1_n_7\,
      Q => rfdma_cnt_reg(4),
      R => fdma_rstart
    );
\rfdma_cnt_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \rfdma_cnt_reg[0]_i_2_n_0\,
      CO(3) => \rfdma_cnt_reg[4]_i_1_n_0\,
      CO(2) => \rfdma_cnt_reg[4]_i_1_n_1\,
      CO(1) => \rfdma_cnt_reg[4]_i_1_n_2\,
      CO(0) => \rfdma_cnt_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \rfdma_cnt_reg[4]_i_1_n_4\,
      O(2) => \rfdma_cnt_reg[4]_i_1_n_5\,
      O(1) => \rfdma_cnt_reg[4]_i_1_n_6\,
      O(0) => \rfdma_cnt_reg[4]_i_1_n_7\,
      S(3 downto 0) => rfdma_cnt_reg(7 downto 4)
    );
\rfdma_cnt_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[4]_i_1_n_6\,
      Q => rfdma_cnt_reg(5),
      R => fdma_rstart
    );
\rfdma_cnt_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[4]_i_1_n_5\,
      Q => rfdma_cnt_reg(6),
      R => fdma_rstart
    );
\rfdma_cnt_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[4]_i_1_n_4\,
      Q => rfdma_cnt_reg(7),
      R => fdma_rstart
    );
\rfdma_cnt_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[8]_i_1_n_7\,
      Q => rfdma_cnt_reg(8),
      R => fdma_rstart
    );
\rfdma_cnt_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \rfdma_cnt_reg[4]_i_1_n_0\,
      CO(3) => \rfdma_cnt_reg[8]_i_1_n_0\,
      CO(2) => \rfdma_cnt_reg[8]_i_1_n_1\,
      CO(1) => \rfdma_cnt_reg[8]_i_1_n_2\,
      CO(0) => \rfdma_cnt_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \rfdma_cnt_reg[8]_i_1_n_4\,
      O(2) => \rfdma_cnt_reg[8]_i_1_n_5\,
      O(1) => \rfdma_cnt_reg[8]_i_1_n_6\,
      O(0) => \rfdma_cnt_reg[8]_i_1_n_7\,
      S(3 downto 0) => rfdma_cnt_reg(11 downto 8)
    );
\rfdma_cnt_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_rvalid\,
      D => \rfdma_cnt_reg[8]_i_1_n_6\,
      Q => rfdma_cnt_reg(9),
      R => fdma_rstart
    );
\wburst_cnt[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => wburst_cnt_reg(0),
      O => p_0_in(0)
    );
\wburst_cnt[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => wburst_cnt_reg(0),
      I1 => wburst_cnt_reg(1),
      O => p_0_in(1)
    );
\wburst_cnt[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => wburst_cnt_reg(1),
      I1 => wburst_cnt_reg(0),
      I2 => wburst_cnt_reg(2),
      O => p_0_in(2)
    );
\wburst_cnt[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => wburst_cnt_reg(2),
      I1 => wburst_cnt_reg(0),
      I2 => wburst_cnt_reg(1),
      I3 => wburst_cnt_reg(3),
      O => p_0_in(3)
    );
\wburst_cnt[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
        port map (
      I0 => wburst_cnt_reg(3),
      I1 => wburst_cnt_reg(1),
      I2 => wburst_cnt_reg(0),
      I3 => wburst_cnt_reg(2),
      I4 => wburst_cnt_reg(4),
      O => p_0_in(4)
    );
\wburst_cnt[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFF80000000"
    )
        port map (
      I0 => wburst_cnt_reg(4),
      I1 => wburst_cnt_reg(2),
      I2 => wburst_cnt_reg(0),
      I3 => wburst_cnt_reg(1),
      I4 => wburst_cnt_reg(3),
      I5 => wburst_cnt_reg(5),
      O => p_0_in(5)
    );
\wburst_cnt[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F7FF0800"
    )
        port map (
      I0 => wburst_cnt_reg(5),
      I1 => wburst_cnt_reg(3),
      I2 => \wburst_cnt[7]_i_2_n_0\,
      I3 => wburst_cnt_reg(4),
      I4 => wburst_cnt_reg(6),
      O => p_0_in(6)
    );
\wburst_cnt[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F7FFFFFF08000000"
    )
        port map (
      I0 => wburst_cnt_reg(6),
      I1 => wburst_cnt_reg(4),
      I2 => \wburst_cnt[7]_i_2_n_0\,
      I3 => wburst_cnt_reg(3),
      I4 => wburst_cnt_reg(5),
      I5 => wburst_cnt_reg(7),
      O => p_0_in(7)
    );
\wburst_cnt[7]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => wburst_cnt_reg(1),
      I1 => wburst_cnt_reg(0),
      I2 => wburst_cnt_reg(2),
      O => \wburst_cnt[7]_i_2_n_0\
    );
\wburst_cnt[8]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => axi_wstart_locked,
      O => axi_wstart_locked1
    );
\wburst_cnt[8]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"DF20"
    )
        port map (
      I0 => wburst_cnt_reg(7),
      I1 => \wburst_cnt[8]_i_3_n_0\,
      I2 => wburst_cnt_reg(6),
      I3 => wburst_cnt_reg(8),
      O => p_0_in(8)
    );
\wburst_cnt[8]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => wburst_cnt_reg(4),
      I1 => wburst_cnt_reg(2),
      I2 => wburst_cnt_reg(0),
      I3 => wburst_cnt_reg(1),
      I4 => wburst_cnt_reg(3),
      I5 => wburst_cnt_reg(5),
      O => \wburst_cnt[8]_i_3_n_0\
    );
\wburst_cnt_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => p_0_in(0),
      Q => wburst_cnt_reg(0),
      R => axi_wstart_locked1
    );
\wburst_cnt_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => p_0_in(1),
      Q => wburst_cnt_reg(1),
      R => axi_wstart_locked1
    );
\wburst_cnt_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => p_0_in(2),
      Q => wburst_cnt_reg(2),
      R => axi_wstart_locked1
    );
\wburst_cnt_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => p_0_in(3),
      Q => wburst_cnt_reg(3),
      R => axi_wstart_locked1
    );
\wburst_cnt_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => p_0_in(4),
      Q => wburst_cnt_reg(4),
      R => axi_wstart_locked1
    );
\wburst_cnt_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => p_0_in(5),
      Q => wburst_cnt_reg(5),
      R => axi_wstart_locked1
    );
\wburst_cnt_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => p_0_in(6),
      Q => wburst_cnt_reg(6),
      R => axi_wstart_locked1
    );
\wburst_cnt_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => p_0_in(7),
      Q => wburst_cnt_reg(7),
      R => axi_wstart_locked1
    );
\wburst_cnt_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => p_0_in(8),
      Q => wburst_cnt_reg(8),
      R => axi_wstart_locked1
    );
\wburst_len[8]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFE00000000"
    )
        port map (
      I0 => \wburst_len[8]_i_2_n_0\,
      I1 => p_0_in_0(1),
      I2 => p_0_in_0(0),
      I3 => p_0_in_0(3),
      I4 => p_0_in_0(2),
      I5 => wburst_len_req,
      O => wburst_len
    );
\wburst_len[8]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => p_0_in_0(5),
      I1 => p_0_in_0(4),
      I2 => p_0_in_0(7),
      I3 => p_0_in_0(6),
      O => \wburst_len[8]_i_2_n_0\
    );
\wburst_len_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => M_AXI_ACLK,
      CE => wburst_len_req,
      D => \fdma_wleft_cnt_reg_n_0_[0]\,
      Q => axi_wburst_size(3),
      R => wburst_len
    );
\wburst_len_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => wburst_len_req,
      D => \fdma_wleft_cnt_reg_n_0_[1]\,
      Q => axi_wburst_size(4),
      R => wburst_len
    );
\wburst_len_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => wburst_len_req,
      D => \fdma_wleft_cnt_reg_n_0_[2]\,
      Q => axi_wburst_size(5),
      R => wburst_len
    );
\wburst_len_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => wburst_len_req,
      D => \fdma_wleft_cnt_reg_n_0_[3]\,
      Q => axi_wburst_size(6),
      R => wburst_len
    );
\wburst_len_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => wburst_len_req,
      D => \fdma_wleft_cnt_reg_n_0_[4]\,
      Q => axi_wburst_size(7),
      R => wburst_len
    );
\wburst_len_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => wburst_len_req,
      D => \fdma_wleft_cnt_reg_n_0_[5]\,
      Q => axi_wburst_size(8),
      R => wburst_len
    );
\wburst_len_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => wburst_len_req,
      D => \fdma_wleft_cnt_reg_n_0_[6]\,
      Q => axi_wburst_size(9),
      R => wburst_len
    );
\wburst_len_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => wburst_len_req,
      D => \fdma_wleft_cnt_reg_n_0_[7]\,
      Q => axi_wburst_size(10),
      R => wburst_len
    );
\wburst_len_reg[8]\: unisim.vcomponents.FDSE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => wburst_len_req,
      D => '0',
      Q => axi_wburst_size(11),
      S => wburst_len
    );
wburst_len_req_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8000FFFF80008000"
    )
        port map (
      I0 => fdma_wready,
      I1 => axi_wvalid,
      I2 => M_AXI_WREADY,
      I3 => axi_wlast0,
      I4 => \^fdma_wstart_locked_reg_0\,
      I5 => fdma_wareq,
      O => wburst_len_req_i_1_n_0
    );
wburst_len_req_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => '1',
      D => wburst_len_req_i_1_n_0,
      Q => wburst_len_req,
      R => '0'
    );
\wfdma_cnt[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => fdma_wareq,
      I1 => \^fdma_wstart_locked_reg_0\,
      O => fdma_wstart
    );
\wfdma_cnt[0]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => wfdma_cnt_reg(0),
      O => \wfdma_cnt[0]_i_3_n_0\
    );
\wfdma_cnt_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[0]_i_2_n_7\,
      Q => wfdma_cnt_reg(0),
      R => fdma_wstart
    );
\wfdma_cnt_reg[0]_i_2\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \wfdma_cnt_reg[0]_i_2_n_0\,
      CO(2) => \wfdma_cnt_reg[0]_i_2_n_1\,
      CO(1) => \wfdma_cnt_reg[0]_i_2_n_2\,
      CO(0) => \wfdma_cnt_reg[0]_i_2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0001",
      O(3) => \wfdma_cnt_reg[0]_i_2_n_4\,
      O(2) => \wfdma_cnt_reg[0]_i_2_n_5\,
      O(1) => \wfdma_cnt_reg[0]_i_2_n_6\,
      O(0) => \wfdma_cnt_reg[0]_i_2_n_7\,
      S(3 downto 1) => wfdma_cnt_reg(3 downto 1),
      S(0) => \wfdma_cnt[0]_i_3_n_0\
    );
\wfdma_cnt_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[8]_i_1_n_5\,
      Q => wfdma_cnt_reg(10),
      R => fdma_wstart
    );
\wfdma_cnt_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[8]_i_1_n_4\,
      Q => wfdma_cnt_reg(11),
      R => fdma_wstart
    );
\wfdma_cnt_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[12]_i_1_n_7\,
      Q => wfdma_cnt_reg(12),
      R => fdma_wstart
    );
\wfdma_cnt_reg[12]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \wfdma_cnt_reg[8]_i_1_n_0\,
      CO(3) => \NLW_wfdma_cnt_reg[12]_i_1_CO_UNCONNECTED\(3),
      CO(2) => \wfdma_cnt_reg[12]_i_1_n_1\,
      CO(1) => \wfdma_cnt_reg[12]_i_1_n_2\,
      CO(0) => \wfdma_cnt_reg[12]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \wfdma_cnt_reg[12]_i_1_n_4\,
      O(2) => \wfdma_cnt_reg[12]_i_1_n_5\,
      O(1) => \wfdma_cnt_reg[12]_i_1_n_6\,
      O(0) => \wfdma_cnt_reg[12]_i_1_n_7\,
      S(3 downto 0) => wfdma_cnt_reg(15 downto 12)
    );
\wfdma_cnt_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[12]_i_1_n_6\,
      Q => wfdma_cnt_reg(13),
      R => fdma_wstart
    );
\wfdma_cnt_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[12]_i_1_n_5\,
      Q => wfdma_cnt_reg(14),
      R => fdma_wstart
    );
\wfdma_cnt_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[12]_i_1_n_4\,
      Q => wfdma_cnt_reg(15),
      R => fdma_wstart
    );
\wfdma_cnt_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[0]_i_2_n_6\,
      Q => wfdma_cnt_reg(1),
      R => fdma_wstart
    );
\wfdma_cnt_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[0]_i_2_n_5\,
      Q => wfdma_cnt_reg(2),
      R => fdma_wstart
    );
\wfdma_cnt_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[0]_i_2_n_4\,
      Q => wfdma_cnt_reg(3),
      R => fdma_wstart
    );
\wfdma_cnt_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[4]_i_1_n_7\,
      Q => wfdma_cnt_reg(4),
      R => fdma_wstart
    );
\wfdma_cnt_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \wfdma_cnt_reg[0]_i_2_n_0\,
      CO(3) => \wfdma_cnt_reg[4]_i_1_n_0\,
      CO(2) => \wfdma_cnt_reg[4]_i_1_n_1\,
      CO(1) => \wfdma_cnt_reg[4]_i_1_n_2\,
      CO(0) => \wfdma_cnt_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \wfdma_cnt_reg[4]_i_1_n_4\,
      O(2) => \wfdma_cnt_reg[4]_i_1_n_5\,
      O(1) => \wfdma_cnt_reg[4]_i_1_n_6\,
      O(0) => \wfdma_cnt_reg[4]_i_1_n_7\,
      S(3 downto 0) => wfdma_cnt_reg(7 downto 4)
    );
\wfdma_cnt_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[4]_i_1_n_6\,
      Q => wfdma_cnt_reg(5),
      R => fdma_wstart
    );
\wfdma_cnt_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[4]_i_1_n_5\,
      Q => wfdma_cnt_reg(6),
      R => fdma_wstart
    );
\wfdma_cnt_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[4]_i_1_n_4\,
      Q => wfdma_cnt_reg(7),
      R => fdma_wstart
    );
\wfdma_cnt_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[8]_i_1_n_7\,
      Q => wfdma_cnt_reg(8),
      R => fdma_wstart
    );
\wfdma_cnt_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \wfdma_cnt_reg[4]_i_1_n_0\,
      CO(3) => \wfdma_cnt_reg[8]_i_1_n_0\,
      CO(2) => \wfdma_cnt_reg[8]_i_1_n_1\,
      CO(1) => \wfdma_cnt_reg[8]_i_1_n_2\,
      CO(0) => \wfdma_cnt_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \wfdma_cnt_reg[8]_i_1_n_4\,
      O(2) => \wfdma_cnt_reg[8]_i_1_n_5\,
      O(1) => \wfdma_cnt_reg[8]_i_1_n_6\,
      O(0) => \wfdma_cnt_reg[8]_i_1_n_7\,
      S(3 downto 0) => wfdma_cnt_reg(11 downto 8)
    );
\wfdma_cnt_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => M_AXI_ACLK,
      CE => \^fdma_wvalid\,
      D => \wfdma_cnt_reg[8]_i_1_n_6\,
      Q => wfdma_cnt_reg(9),
      R => fdma_wstart
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps_system_uiFDMA_0_1 is
  port (
    fdma_waddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    fdma_wareq : in STD_LOGIC;
    fdma_wsize : in STD_LOGIC_VECTOR ( 15 downto 0 );
    fdma_wbusy : out STD_LOGIC;
    fdma_wdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    fdma_wvalid : out STD_LOGIC;
    fdma_wready : in STD_LOGIC;
    fdma_raddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    fdma_rareq : in STD_LOGIC;
    fdma_rsize : in STD_LOGIC_VECTOR ( 15 downto 0 );
    fdma_rbusy : out STD_LOGIC;
    fdma_rdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    fdma_rvalid : out STD_LOGIC;
    fdma_rready : in STD_LOGIC;
    M_AXI_ACLK : in STD_LOGIC;
    M_AXI_ARESETN : in STD_LOGIC;
    M_AXI_AWID : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXI_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_AWLOCK : out STD_LOGIC;
    M_AXI_AWCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_AWPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_AWQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_AWVALID : out STD_LOGIC;
    M_AXI_AWREADY : in STD_LOGIC;
    M_AXI_WID : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_WDATA : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M_AXI_WSTRB : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXI_WLAST : out STD_LOGIC;
    M_AXI_WVALID : out STD_LOGIC;
    M_AXI_WREADY : in STD_LOGIC;
    M_AXI_BID : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_BVALID : in STD_LOGIC;
    M_AXI_BREADY : out STD_LOGIC;
    M_AXI_ARID : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXI_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_ARLOCK : out STD_LOGIC;
    M_AXI_ARCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_ARQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_ARVALID : out STD_LOGIC;
    M_AXI_ARREADY : in STD_LOGIC;
    M_AXI_RID : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_RDATA : in STD_LOGIC_VECTOR ( 63 downto 0 );
    M_AXI_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_RLAST : in STD_LOGIC;
    M_AXI_RVALID : in STD_LOGIC;
    M_AXI_RREADY : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of ps_system_uiFDMA_0_1 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of ps_system_uiFDMA_0_1 : entity is "ps_system_uiFDMA_0_1,uiFDMA,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of ps_system_uiFDMA_0_1 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of ps_system_uiFDMA_0_1 : entity is "package_project";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of ps_system_uiFDMA_0_1 : entity is "uiFDMA,Vivado 2020.2";
end ps_system_uiFDMA_0_1;

architecture STRUCTURE of ps_system_uiFDMA_0_1 is
  signal \<const0>\ : STD_LOGIC;
  signal \<const1>\ : STD_LOGIC;
  signal \^m_axi_rdata\ : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal \^fdma_wdata\ : STD_LOGIC_VECTOR ( 63 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of M_AXI_ACLK : signal is "xilinx.com:signal:clock:1.0 M_AXI_ACLK CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of M_AXI_ACLK : signal is "XIL_INTERFACENAME M_AXI_ACLK, ASSOCIATED_BUSIF M_AXI, ASSOCIATED_RESET M_AXI_ARESETN, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN ps_system_clk, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of M_AXI_ARESETN : signal is "xilinx.com:signal:reset:1.0 M_AXI_ARESETN RST";
  attribute X_INTERFACE_PARAMETER of M_AXI_ARESETN : signal is "XIL_INTERFACENAME M_AXI_ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of M_AXI_ARLOCK : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARLOCK";
  attribute X_INTERFACE_INFO of M_AXI_ARREADY : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARREADY";
  attribute X_INTERFACE_INFO of M_AXI_ARVALID : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARVALID";
  attribute X_INTERFACE_INFO of M_AXI_AWLOCK : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWLOCK";
  attribute X_INTERFACE_INFO of M_AXI_AWREADY : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWREADY";
  attribute X_INTERFACE_INFO of M_AXI_AWVALID : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWVALID";
  attribute X_INTERFACE_INFO of M_AXI_BREADY : signal is "xilinx.com:interface:aximm:1.0 M_AXI BREADY";
  attribute X_INTERFACE_INFO of M_AXI_BVALID : signal is "xilinx.com:interface:aximm:1.0 M_AXI BVALID";
  attribute X_INTERFACE_INFO of M_AXI_RLAST : signal is "xilinx.com:interface:aximm:1.0 M_AXI RLAST";
  attribute X_INTERFACE_INFO of M_AXI_RREADY : signal is "xilinx.com:interface:aximm:1.0 M_AXI RREADY";
  attribute X_INTERFACE_PARAMETER of M_AXI_RREADY : signal is "XIL_INTERFACENAME M_AXI, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 100000000, ID_WIDTH 2, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN ps_system_clk, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of M_AXI_RVALID : signal is "xilinx.com:interface:aximm:1.0 M_AXI RVALID";
  attribute X_INTERFACE_INFO of M_AXI_WLAST : signal is "xilinx.com:interface:aximm:1.0 M_AXI WLAST";
  attribute X_INTERFACE_INFO of M_AXI_WREADY : signal is "xilinx.com:interface:aximm:1.0 M_AXI WREADY";
  attribute X_INTERFACE_INFO of M_AXI_WVALID : signal is "xilinx.com:interface:aximm:1.0 M_AXI WVALID";
  attribute X_INTERFACE_INFO of fdma_rareq : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_rareq";
  attribute X_INTERFACE_INFO of fdma_rbusy : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_rbusy";
  attribute X_INTERFACE_INFO of fdma_rready : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_rready";
  attribute X_INTERFACE_INFO of fdma_rvalid : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_rvalid";
  attribute X_INTERFACE_INFO of fdma_wareq : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_wareq";
  attribute X_INTERFACE_INFO of fdma_wbusy : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_wbusy";
  attribute X_INTERFACE_INFO of fdma_wready : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_wready";
  attribute X_INTERFACE_INFO of fdma_wvalid : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_wvalid";
  attribute X_INTERFACE_INFO of M_AXI_ARADDR : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARADDR";
  attribute X_INTERFACE_INFO of M_AXI_ARBURST : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARBURST";
  attribute X_INTERFACE_INFO of M_AXI_ARCACHE : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARCACHE";
  attribute X_INTERFACE_INFO of M_AXI_ARID : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARID";
  attribute X_INTERFACE_INFO of M_AXI_ARLEN : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARLEN";
  attribute X_INTERFACE_INFO of M_AXI_ARPROT : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARPROT";
  attribute X_INTERFACE_INFO of M_AXI_ARQOS : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARQOS";
  attribute X_INTERFACE_INFO of M_AXI_ARSIZE : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARSIZE";
  attribute X_INTERFACE_INFO of M_AXI_AWADDR : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWADDR";
  attribute X_INTERFACE_INFO of M_AXI_AWBURST : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWBURST";
  attribute X_INTERFACE_INFO of M_AXI_AWCACHE : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWCACHE";
  attribute X_INTERFACE_INFO of M_AXI_AWID : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWID";
  attribute X_INTERFACE_INFO of M_AXI_AWLEN : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWLEN";
  attribute X_INTERFACE_INFO of M_AXI_AWPROT : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWPROT";
  attribute X_INTERFACE_INFO of M_AXI_AWQOS : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWQOS";
  attribute X_INTERFACE_INFO of M_AXI_AWSIZE : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWSIZE";
  attribute X_INTERFACE_INFO of M_AXI_BID : signal is "xilinx.com:interface:aximm:1.0 M_AXI BID";
  attribute X_INTERFACE_INFO of M_AXI_BRESP : signal is "xilinx.com:interface:aximm:1.0 M_AXI BRESP";
  attribute X_INTERFACE_INFO of M_AXI_RDATA : signal is "xilinx.com:interface:aximm:1.0 M_AXI RDATA";
  attribute X_INTERFACE_INFO of M_AXI_RID : signal is "xilinx.com:interface:aximm:1.0 M_AXI RID";
  attribute X_INTERFACE_INFO of M_AXI_RRESP : signal is "xilinx.com:interface:aximm:1.0 M_AXI RRESP";
  attribute X_INTERFACE_INFO of M_AXI_WDATA : signal is "xilinx.com:interface:aximm:1.0 M_AXI WDATA";
  attribute X_INTERFACE_INFO of M_AXI_WID : signal is "xilinx.com:interface:aximm:1.0 M_AXI WID";
  attribute X_INTERFACE_INFO of M_AXI_WSTRB : signal is "xilinx.com:interface:aximm:1.0 M_AXI WSTRB";
  attribute X_INTERFACE_INFO of fdma_raddr : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_raddr";
  attribute X_INTERFACE_INFO of fdma_rdata : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_rdata";
  attribute X_INTERFACE_INFO of fdma_rsize : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_rsize";
  attribute X_INTERFACE_INFO of fdma_waddr : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_waddr";
  attribute X_INTERFACE_INFO of fdma_wdata : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_wdata";
  attribute X_INTERFACE_INFO of fdma_wsize : signal is "xilinx.com:user:FDMA_S:1.0 FDMA_S fdma_wsize";
begin
  M_AXI_ARBURST(1) <= \<const0>\;
  M_AXI_ARBURST(0) <= \<const1>\;
  M_AXI_ARCACHE(3) <= \<const0>\;
  M_AXI_ARCACHE(2) <= \<const0>\;
  M_AXI_ARCACHE(1) <= \<const1>\;
  M_AXI_ARCACHE(0) <= \<const0>\;
  M_AXI_ARID(1) <= \<const0>\;
  M_AXI_ARID(0) <= \<const1>\;
  M_AXI_ARLOCK <= \<const0>\;
  M_AXI_ARPROT(2) <= \<const0>\;
  M_AXI_ARPROT(1) <= \<const0>\;
  M_AXI_ARPROT(0) <= \<const0>\;
  M_AXI_ARQOS(3) <= \<const0>\;
  M_AXI_ARQOS(2) <= \<const0>\;
  M_AXI_ARQOS(1) <= \<const0>\;
  M_AXI_ARQOS(0) <= \<const0>\;
  M_AXI_ARSIZE(2) <= \<const0>\;
  M_AXI_ARSIZE(1) <= \<const1>\;
  M_AXI_ARSIZE(0) <= \<const1>\;
  M_AXI_AWBURST(1) <= \<const0>\;
  M_AXI_AWBURST(0) <= \<const1>\;
  M_AXI_AWCACHE(3) <= \<const0>\;
  M_AXI_AWCACHE(2) <= \<const0>\;
  M_AXI_AWCACHE(1) <= \<const1>\;
  M_AXI_AWCACHE(0) <= \<const0>\;
  M_AXI_AWID(1) <= \<const0>\;
  M_AXI_AWID(0) <= \<const1>\;
  M_AXI_AWLOCK <= \<const0>\;
  M_AXI_AWPROT(2) <= \<const0>\;
  M_AXI_AWPROT(1) <= \<const0>\;
  M_AXI_AWPROT(0) <= \<const0>\;
  M_AXI_AWQOS(3) <= \<const0>\;
  M_AXI_AWQOS(2) <= \<const0>\;
  M_AXI_AWQOS(1) <= \<const0>\;
  M_AXI_AWQOS(0) <= \<const0>\;
  M_AXI_AWSIZE(2) <= \<const0>\;
  M_AXI_AWSIZE(1) <= \<const1>\;
  M_AXI_AWSIZE(0) <= \<const1>\;
  M_AXI_BREADY <= \<const1>\;
  M_AXI_WDATA(63 downto 0) <= \^fdma_wdata\(63 downto 0);
  M_AXI_WID(1) <= \<const0>\;
  M_AXI_WID(0) <= \<const0>\;
  M_AXI_WSTRB(7) <= \<const1>\;
  M_AXI_WSTRB(6) <= \<const1>\;
  M_AXI_WSTRB(5) <= \<const1>\;
  M_AXI_WSTRB(4) <= \<const1>\;
  M_AXI_WSTRB(3) <= \<const1>\;
  M_AXI_WSTRB(2) <= \<const1>\;
  M_AXI_WSTRB(1) <= \<const1>\;
  M_AXI_WSTRB(0) <= \<const1>\;
  \^fdma_wdata\(63 downto 0) <= fdma_wdata(63 downto 0);
  \^m_axi_rdata\(63 downto 0) <= M_AXI_RDATA(63 downto 0);
  fdma_rdata(63 downto 0) <= \^m_axi_rdata\(63 downto 0);
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
VCC: unisim.vcomponents.VCC
     port map (
      P => \<const1>\
    );
inst: entity work.ps_system_uiFDMA_0_1_uiFDMA
     port map (
      M_AXI_ACLK => M_AXI_ACLK,
      M_AXI_ARADDR(31 downto 0) => M_AXI_ARADDR(31 downto 0),
      M_AXI_ARESETN => M_AXI_ARESETN,
      M_AXI_ARLEN(7 downto 0) => M_AXI_ARLEN(7 downto 0),
      M_AXI_ARREADY => M_AXI_ARREADY,
      M_AXI_ARVALID => M_AXI_ARVALID,
      M_AXI_AWADDR(31 downto 0) => M_AXI_AWADDR(31 downto 0),
      M_AXI_AWLEN(7 downto 0) => M_AXI_AWLEN(7 downto 0),
      M_AXI_AWREADY => M_AXI_AWREADY,
      M_AXI_AWVALID => M_AXI_AWVALID,
      M_AXI_RREADY => M_AXI_RREADY,
      M_AXI_RVALID => M_AXI_RVALID,
      M_AXI_WLAST => M_AXI_WLAST,
      M_AXI_WREADY => M_AXI_WREADY,
      M_AXI_WVALID => M_AXI_WVALID,
      fdma_raddr(31 downto 0) => fdma_raddr(31 downto 0),
      fdma_rareq => fdma_rareq,
      fdma_rready => fdma_rready,
      fdma_rsize(15 downto 0) => fdma_rsize(15 downto 0),
      fdma_rstart_locked_reg_0 => fdma_rbusy,
      fdma_rvalid => fdma_rvalid,
      fdma_waddr(31 downto 0) => fdma_waddr(31 downto 0),
      fdma_wareq => fdma_wareq,
      fdma_wready => fdma_wready,
      fdma_wsize(15 downto 0) => fdma_wsize(15 downto 0),
      fdma_wstart_locked_reg_0 => fdma_wbusy,
      fdma_wvalid => fdma_wvalid
    );
end STRUCTURE;
