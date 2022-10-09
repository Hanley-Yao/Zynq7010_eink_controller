# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Board [ipgui::add_page $IPINST -name "Board"]
  ipgui::add_static_text $IPINST -name "Board_Text" -parent ${Board} -text {Associate IP interface with board interface}
  ipgui::add_static_text $IPINST -name "Label_Board_Interface" -text {<b>Board Interface}
  ipgui::add_static_text $IPINST -name "Label_IP_Interface" -text {<b>IP Interface}
  ipgui::add_param $IPINST -name "PMOD" -show_label false -show_range false -widget comboBox
  ipgui::add_static_text $IPINST -name "Board::PMOD" -text {}

  set AD1_CLOCKS_PER_BIT [ipgui::add_param $IPINST -name "AD1_CLOCKS_PER_BIT"]
  set_property tooltip {Number of AXI clock edges per SCLK cycle} ${AD1_CLOCKS_PER_BIT}
  set AD1_CLOCKS_BEFORE_DATA [ipgui::add_param $IPINST -name "AD1_CLOCKS_BEFORE_DATA"]
  set_property tooltip {Number of AXI clock cycles after CS goes low before SCLK begins cycling} ${AD1_CLOCKS_BEFORE_DATA}
  set AD1_CLOCKS_AFTER_DATA [ipgui::add_param $IPINST -name "AD1_CLOCKS_AFTER_DATA"]
  set_property tooltip {Number of AXI clock cycles after data has finished transferring before CS is brought high} ${AD1_CLOCKS_AFTER_DATA}
  set AD1_CLOCKS_BETWEEN_TRANSACTIONS [ipgui::add_param $IPINST -name "AD1_CLOCKS_BETWEEN_TRANSACTIONS"]
  set_property tooltip {Number of AXI clock cycles that CS is held high between data transactions} ${AD1_CLOCKS_BETWEEN_TRANSACTIONS}
#  set INCLUDE_DEBUG_INTERFACE [ipgui::add_param $IPINST -name "INCLUDE_DEBUG_INTERFACE"]
#  set_property tooltip {Instantiates a second Pmod Port for the IP core that can be used to pass internal signals to a logic analyzer} ${INCLUDE_DEBUG_INTERFACE}

}

proc update_PARAM_VALUE.AD1_CLOCKS_AFTER_DATA { PARAM_VALUE.AD1_CLOCKS_AFTER_DATA } {
	# Procedure called to update AD1_CLOCKS_AFTER_DATA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AD1_CLOCKS_AFTER_DATA { PARAM_VALUE.AD1_CLOCKS_AFTER_DATA } {
	# Procedure called to validate AD1_CLOCKS_AFTER_DATA
	return true
}

proc update_PARAM_VALUE.AD1_CLOCKS_BEFORE_DATA { PARAM_VALUE.AD1_CLOCKS_BEFORE_DATA } {
	# Procedure called to update AD1_CLOCKS_BEFORE_DATA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AD1_CLOCKS_BEFORE_DATA { PARAM_VALUE.AD1_CLOCKS_BEFORE_DATA } {
	# Procedure called to validate AD1_CLOCKS_BEFORE_DATA
	return true
}

proc update_PARAM_VALUE.AD1_CLOCKS_BETWEEN_TRANSACTIONS { PARAM_VALUE.AD1_CLOCKS_BETWEEN_TRANSACTIONS } {
	# Procedure called to update AD1_CLOCKS_BETWEEN_TRANSACTIONS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AD1_CLOCKS_BETWEEN_TRANSACTIONS { PARAM_VALUE.AD1_CLOCKS_BETWEEN_TRANSACTIONS } {
	# Procedure called to validate AD1_CLOCKS_BETWEEN_TRANSACTIONS
	return true
}

proc update_PARAM_VALUE.AD1_CLOCKS_PER_BIT { PARAM_VALUE.AD1_CLOCKS_PER_BIT } {
	# Procedure called to update AD1_CLOCKS_PER_BIT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AD1_CLOCKS_PER_BIT { PARAM_VALUE.AD1_CLOCKS_PER_BIT } {
	# Procedure called to validate AD1_CLOCKS_PER_BIT
	return true
}

proc update_PARAM_VALUE.AXI_LITE_SAMPLE_BASEADDR { PARAM_VALUE.AXI_LITE_SAMPLE_BASEADDR } {
	# Procedure called to update AXI_LITE_SAMPLE_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_LITE_SAMPLE_BASEADDR { PARAM_VALUE.AXI_LITE_SAMPLE_BASEADDR } {
	# Procedure called to validate AXI_LITE_SAMPLE_BASEADDR
	return true
}

proc update_PARAM_VALUE.AXI_LITE_SAMPLE_HIGHADDR { PARAM_VALUE.AXI_LITE_SAMPLE_HIGHADDR } {
	# Procedure called to update AXI_LITE_SAMPLE_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_LITE_SAMPLE_HIGHADDR { PARAM_VALUE.AXI_LITE_SAMPLE_HIGHADDR } {
	# Procedure called to validate AXI_LITE_SAMPLE_HIGHADDR
	return true
}

proc update_PARAM_VALUE.INCLUDE_DEBUG_INTERFACE { PARAM_VALUE.INCLUDE_DEBUG_INTERFACE } {
	# Procedure called to update INCLUDE_DEBUG_INTERFACE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INCLUDE_DEBUG_INTERFACE { PARAM_VALUE.INCLUDE_DEBUG_INTERFACE } {
	# Procedure called to validate INCLUDE_DEBUG_INTERFACE
	return true
}

proc get_pmod_vlnv {} {
	return "digilentinc.com:interface:pmod_rtl:1.0"
}

proc update_PARAM_VALUE.PMOD {IPINST PARAM_VALUE.PMOD PROJECT_PARAM.BOARD} {
	set param_range [get_board_interface_param_range $IPINST -name "PMOD"]
	set_property range $param_range ${PARAM_VALUE.PMOD}
}

proc validate_PARAM_VALUE.PMOD { PARAM_VALUE.PMOD PARAM_VALUE.USE_BOARD_FLOW IPINST PROJECT_PARAM.BOARD} {
	set pmod_vlnv [get_pmod_vlnv]
	set intf [ get_property value ${PARAM_VALUE.PMOD} ]
	set board ${PROJECT_PARAM.BOARD}
	return true
}


proc update_PARAM_VALUE.USE_BOARD_FLOW { PARAM_VALUE.USE_BOARD_FLOW } {
	# Procedure called to update USE_BOARD_FLOW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_BOARD_FLOW { PARAM_VALUE.USE_BOARD_FLOW } {
	# Procedure called to validate USE_BOARD_FLOW
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.AD1_CLOCKS_PER_BIT { MODELPARAM_VALUE.AD1_CLOCKS_PER_BIT PARAM_VALUE.AD1_CLOCKS_PER_BIT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AD1_CLOCKS_PER_BIT}] ${MODELPARAM_VALUE.AD1_CLOCKS_PER_BIT}
}

proc update_MODELPARAM_VALUE.AD1_CLOCKS_BEFORE_DATA { MODELPARAM_VALUE.AD1_CLOCKS_BEFORE_DATA PARAM_VALUE.AD1_CLOCKS_BEFORE_DATA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AD1_CLOCKS_BEFORE_DATA}] ${MODELPARAM_VALUE.AD1_CLOCKS_BEFORE_DATA}
}

proc update_MODELPARAM_VALUE.AD1_CLOCKS_AFTER_DATA { MODELPARAM_VALUE.AD1_CLOCKS_AFTER_DATA PARAM_VALUE.AD1_CLOCKS_AFTER_DATA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AD1_CLOCKS_AFTER_DATA}] ${MODELPARAM_VALUE.AD1_CLOCKS_AFTER_DATA}
}

proc update_MODELPARAM_VALUE.AD1_CLOCKS_BETWEEN_TRANSACTIONS { MODELPARAM_VALUE.AD1_CLOCKS_BETWEEN_TRANSACTIONS PARAM_VALUE.AD1_CLOCKS_BETWEEN_TRANSACTIONS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AD1_CLOCKS_BETWEEN_TRANSACTIONS}] ${MODELPARAM_VALUE.AD1_CLOCKS_BETWEEN_TRANSACTIONS}
}

proc update_MODELPARAM_VALUE.INCLUDE_DEBUG_INTERFACE { MODELPARAM_VALUE.INCLUDE_DEBUG_INTERFACE PARAM_VALUE.INCLUDE_DEBUG_INTERFACE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INCLUDE_DEBUG_INTERFACE}] ${MODELPARAM_VALUE.INCLUDE_DEBUG_INTERFACE}
}

