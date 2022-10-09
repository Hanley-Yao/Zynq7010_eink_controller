// (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

// IP VLNV: xilinx.com:ip:fifo_generator:13.2
// IP Revision: 4

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
cdc_fifo your_instance_name (
  .m_aclk(m_aclk),                // input wire m_aclk
  .s_aclk(s_aclk),                // input wire s_aclk
  .s_aresetn(s_aresetn),          // input wire s_aresetn
  .s_axis_tvalid(s_axis_tvalid),  // input wire s_axis_tvalid
  .s_axis_tready(s_axis_tready),  // output wire s_axis_tready
  .s_axis_tdata(s_axis_tdata),    // input wire [31 : 0] s_axis_tdata
  .s_axis_tkeep(s_axis_tkeep),    // input wire [3 : 0] s_axis_tkeep
  .s_axis_tlast(s_axis_tlast),    // input wire s_axis_tlast
  .m_axis_tvalid(m_axis_tvalid),  // output wire m_axis_tvalid
  .m_axis_tready(m_axis_tready),  // input wire m_axis_tready
  .m_axis_tdata(m_axis_tdata),    // output wire [31 : 0] m_axis_tdata
  .m_axis_tkeep(m_axis_tkeep),    // output wire [3 : 0] m_axis_tkeep
  .m_axis_tlast(m_axis_tlast)    // output wire m_axis_tlast
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file cdc_fifo.v when simulating
// the core, cdc_fifo. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

