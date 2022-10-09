###############################################################################
##
## File: MIPI_DPHY_Receiver.xdc
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

#Associate IDELAYCTRL with IDELAYE2 primitives
set_property IODELAY_GROUP MIPI_DPHY [get_cells {*GenIDELAYCTRL.IDelayCtrlX *DPHY_LaneSFEN_X/HSDeserializerX/InputDelay *ClockLane/HSClockingX/InputDelay }]

### Asynchronous clock domain crossings ###
set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages*/PRE || NAME =~ *SyncAsync*/oSyncStages*/CLR || NAME =~ *SyncAsync*/oSyncStages_reg[0]/D} -hier]
#set_false_path -through [get_pins -filter {NAME =~ *SyncBase*/iIn_q*/PRE || NAME =~ *SyncBase*/iIn_q*/CLR} -hier]