###############################################################################
##
## File: MIPI_DPHY_Receiver_clocks.xdc
## Author: Elod Gyorgy
## Original Project: MIPI D-PHY Receiver IP
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

# setup, hold = 0.15*UI = 0.75ns
set_input_delay -clock [get_clocks -of_objects [get_ports dphy_clk_hs_p]] -clock_fall -min -add_delay 0.750 [get_ports {dphy_data_hs_n[*]}]
set_input_delay -clock [get_clocks -of_objects [get_ports dphy_clk_hs_p]] -clock_fall -max -add_delay 4.250 [get_ports {dphy_data_hs_n[*]}]
set_input_delay -clock [get_clocks -of_objects [get_ports dphy_clk_hs_p]] -min -add_delay 0.750 [get_ports {dphy_data_hs_n[*]}]
set_input_delay -clock [get_clocks -of_objects [get_ports dphy_clk_hs_p]] -max -add_delay 4.250 [get_ports {dphy_data_hs_n[*]}]
set_input_delay -clock [get_clocks -of_objects [get_ports dphy_clk_hs_p]] -clock_fall -min -add_delay 0.750 [get_ports {dphy_data_hs_p[*]}]
set_input_delay -clock [get_clocks -of_objects [get_ports dphy_clk_hs_p]] -clock_fall -max -add_delay 4.250 [get_ports {dphy_data_hs_p[*]}]
set_input_delay -clock [get_clocks -of_objects [get_ports dphy_clk_hs_p]] -min -add_delay 0.750 [get_ports {dphy_data_hs_p[*]}]
set_input_delay -clock [get_clocks -of_objects [get_ports dphy_clk_hs_p]] -max -add_delay 4.250 [get_ports {dphy_data_hs_p[*]}]