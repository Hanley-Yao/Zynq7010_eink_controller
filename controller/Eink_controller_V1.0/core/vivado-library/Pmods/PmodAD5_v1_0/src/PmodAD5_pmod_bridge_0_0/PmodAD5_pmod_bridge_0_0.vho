-- (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: digilentinc.com:ip:pmod_bridge:1.0
-- IP Revision: 10

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT PmodAD5_pmod_bridge_0_0
  PORT (
    in0_I : OUT STD_LOGIC;
    in1_I : OUT STD_LOGIC;
    in2_I : OUT STD_LOGIC;
    in3_I : OUT STD_LOGIC;
    in0_O : IN STD_LOGIC;
    in1_O : IN STD_LOGIC;
    in2_O : IN STD_LOGIC;
    in3_O : IN STD_LOGIC;
    in0_T : IN STD_LOGIC;
    in1_T : IN STD_LOGIC;
    in2_T : IN STD_LOGIC;
    in3_T : IN STD_LOGIC;
    out0_I : IN STD_LOGIC;
    out1_I : IN STD_LOGIC;
    out2_I : IN STD_LOGIC;
    out3_I : IN STD_LOGIC;
    out4_I : IN STD_LOGIC;
    out5_I : IN STD_LOGIC;
    out6_I : IN STD_LOGIC;
    out7_I : IN STD_LOGIC;
    out0_O : OUT STD_LOGIC;
    out1_O : OUT STD_LOGIC;
    out2_O : OUT STD_LOGIC;
    out3_O : OUT STD_LOGIC;
    out4_O : OUT STD_LOGIC;
    out5_O : OUT STD_LOGIC;
    out6_O : OUT STD_LOGIC;
    out7_O : OUT STD_LOGIC;
    out0_T : OUT STD_LOGIC;
    out1_T : OUT STD_LOGIC;
    out2_T : OUT STD_LOGIC;
    out3_T : OUT STD_LOGIC;
    out4_T : OUT STD_LOGIC;
    out5_T : OUT STD_LOGIC;
    out6_T : OUT STD_LOGIC;
    out7_T : OUT STD_LOGIC
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : PmodAD5_pmod_bridge_0_0
  PORT MAP (
    in0_I => in0_I,
    in1_I => in1_I,
    in2_I => in2_I,
    in3_I => in3_I,
    in0_O => in0_O,
    in1_O => in1_O,
    in2_O => in2_O,
    in3_O => in3_O,
    in0_T => in0_T,
    in1_T => in1_T,
    in2_T => in2_T,
    in3_T => in3_T,
    out0_I => out0_I,
    out1_I => out1_I,
    out2_I => out2_I,
    out3_I => out3_I,
    out4_I => out4_I,
    out5_I => out5_I,
    out6_I => out6_I,
    out7_I => out7_I,
    out0_O => out0_O,
    out1_O => out1_O,
    out2_O => out2_O,
    out3_O => out3_O,
    out4_O => out4_O,
    out5_O => out5_O,
    out6_O => out6_O,
    out7_O => out7_O,
    out0_T => out0_T,
    out1_T => out1_T,
    out2_T => out2_T,
    out3_T => out3_T,
    out4_T => out4_T,
    out5_T => out5_T,
    out6_T => out6_T,
    out7_T => out7_T
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

