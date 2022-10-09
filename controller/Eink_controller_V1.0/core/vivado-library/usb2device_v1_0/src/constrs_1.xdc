#create_clock -period 10.000 -name S_AXI_ACLK -waveform {0.000 5.000} [get_ports S_AXI_ACLK]
#create_clock -period 10.000 -name m_axi_mm2s_aclk -waveform {0.000 5.000} [get_ports m_axi_mm2s_aclk]
#create_clock -period 10.000 -name m_axi_s2mm_aclk -waveform {0.000 5.000} [get_ports m_axi_s2mm_aclk]
#create_clock -period 16.667 -name ulpi_clk -waveform {0.000 8.333} [get_ports ulpi_clk]
#set_input_delay -clock [get_clocks ulpi_clk] -min -add_delay 7.100 [get_ports {ulpi_data[*]}]
#set_input_delay -clock [get_clocks ulpi_clk] -max -add_delay 9.100 [get_ports {ulpi_data[*]}]
#set_input_delay -clock [get_clocks ulpi_clk] -min -add_delay 7.100 [get_ports ulpi_dir]
#set_input_delay -clock [get_clocks ulpi_clk] -max -add_delay 9.100 [get_ports ulpi_dir]
#set_input_delay -clock [get_clocks ulpi_clk] -min -add_delay 7.100 [get_ports ulpi_nxt]
#set_input_delay -clock [get_clocks ulpi_clk] -max -add_delay 9.100 [get_ports ulpi_nxt]
#set_output_delay -clock [get_clocks ulpi_clk] -min -add_delay 0.100 [get_ports {ulpi_data[*]}]
#set_output_delay -clock [get_clocks ulpi_clk] -max -add_delay 6.100 [get_ports {ulpi_data[*]}]
#set_output_delay -clock [get_clocks ulpi_clk] -min -add_delay 0.100 [get_ports ulpi_stp]
#set_output_delay -clock [get_clocks ulpi_clk] -max -add_delay 6.100 [get_ports ulpi_stp]

set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages_reg[0]/D} -hier]
set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages*/PRE || NAME =~ *SyncAsync*/oSyncStages*/CLR} -hier]

# The handshake module does not need recovery check on aReset
#set_false_path -through [get_pins Inst_HandshakeData*/*/CLR]
set_false_path -through [get_pins -filter {NAME =~ *Inst_HandshakeData*/*/CLR} -hier]
# Tested by me
set_false_path -from [get_cells -hier -filter {NAME =~ *Inst_HandshakeData*/*iData_int_reg[*]}] -to [get_cells -hier -filter {NAME=~ *Inst_HandshakeData*/*oData_reg[*]}]