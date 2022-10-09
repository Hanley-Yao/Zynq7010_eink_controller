###############################################################################
##
## File: mipi_csi2_rx_clocks.xdc
## Author: Elod Gyorgy
## Original Project: MIPI CSI-2 Rx IP
## Date: 15 December 2017
##
###############################################################################
##MIT License
##
##Copyright (c) 2016 Digilent
##
##Permission is hereby granted, free of charge, to any person obtaining a copy
##of this software and associated documentation files (the "Software"), to deal
##in the Software without restriction, including without limitation the rights
##to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##copies of the Software, and to permit persons to whom the Software is
##furnished to do so, subject to the following conditions:
##
##The above copyright notice and this permission notice shall be included in all
##copies or substantial portions of the Software.
##
##THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##SOFTWARE.
##
###############################################################################

# Uncomment below when data needs to be handshaked into the s_axi_lite_aclk domain
# Make sure the path from the iData_int register to oData register is smaller than 2 OutClk (s00_axi_aclk) periods
#set OutClk [get_clocks -of [get_ports s_axi_lite_aclk]]

#set_max_delay -datapath_only -from [get_pins -filter {NAME =~ */HandshakeData*/iData_int_reg[*]/C} -hier] -to [get_pins -filter {NAME =~ */HandshakeData*/oData_reg[*]/D} -hier] [expr [get_property -min PERIOD $OutClk] * 2]