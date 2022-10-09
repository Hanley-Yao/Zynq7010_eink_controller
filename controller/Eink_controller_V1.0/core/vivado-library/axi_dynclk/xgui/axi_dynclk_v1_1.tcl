# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set kAddBUFMR [ipgui::add_param $IPINST -name "kAddBUFMR" -parent ${Page_0}]
  set_property tooltip {Add a BUFMR between the MMCM output and BUFIO/BUFR inputs to allow the MMCM to be placed in a different bank than the high-speed data bus. Useful if two high-speed data buses that require MMCMs are on the same bank.} ${kAddBUFMR}
  ipgui::add_param $IPINST -name "kRefClkFreqHz" -parent ${Page_0}


}

proc update_PARAM_VALUE.kAddBUFMR { PARAM_VALUE.kAddBUFMR } {
	# Procedure called to update kAddBUFMR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kAddBUFMR { PARAM_VALUE.kAddBUFMR } {
	# Procedure called to validate kAddBUFMR
	return true
}

proc update_PARAM_VALUE.kRefClkFreqHz { PARAM_VALUE.kRefClkFreqHz } {
	# Procedure called to update kRefClkFreqHz when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kRefClkFreqHz { PARAM_VALUE.kRefClkFreqHz } {
	# Procedure called to validate kRefClkFreqHz
	return true
}

proc update_PARAM_VALUE.kVersionMajor { PARAM_VALUE.kVersionMajor } {
	# Procedure called to update kVersionMajor when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kVersionMajor { PARAM_VALUE.kVersionMajor } {
	# Procedure called to validate kVersionMajor
	return true
}

proc update_PARAM_VALUE.kVersionMinor { PARAM_VALUE.kVersionMinor } {
	# Procedure called to update kVersionMinor when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kVersionMinor { PARAM_VALUE.kVersionMinor } {
	# Procedure called to validate kVersionMinor
	return true
}

proc update_PARAM_VALUE.C_S_AXI_LITE_DATA_WIDTH { PARAM_VALUE.C_S_AXI_LITE_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_LITE_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_LITE_DATA_WIDTH { PARAM_VALUE.C_S_AXI_LITE_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_LITE_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_LITE_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_LITE_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_LITE_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_LITE_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_LITE_BASEADDR { PARAM_VALUE.C_S_AXI_LITE_BASEADDR } {
	# Procedure called to update C_S_AXI_LITE_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_LITE_BASEADDR { PARAM_VALUE.C_S_AXI_LITE_BASEADDR } {
	# Procedure called to validate C_S_AXI_LITE_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_LITE_HIGHADDR { PARAM_VALUE.C_S_AXI_LITE_HIGHADDR } {
	# Procedure called to update C_S_AXI_LITE_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_LITE_HIGHADDR { PARAM_VALUE.C_S_AXI_LITE_HIGHADDR } {
	# Procedure called to validate C_S_AXI_LITE_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_LITE_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_LITE_DATA_WIDTH PARAM_VALUE.C_S_AXI_LITE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_LITE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_LITE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_LITE_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_LITE_ADDR_WIDTH PARAM_VALUE.C_S_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_LITE_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_LITE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.kRefClkFreqHz { MODELPARAM_VALUE.kRefClkFreqHz PARAM_VALUE.kRefClkFreqHz } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kRefClkFreqHz}] ${MODELPARAM_VALUE.kRefClkFreqHz}
}

proc update_MODELPARAM_VALUE.kVersionMajor { MODELPARAM_VALUE.kVersionMajor PARAM_VALUE.kVersionMajor } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kVersionMajor}] ${MODELPARAM_VALUE.kVersionMajor}
}

proc update_MODELPARAM_VALUE.kVersionMinor { MODELPARAM_VALUE.kVersionMinor PARAM_VALUE.kVersionMinor } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kVersionMinor}] ${MODELPARAM_VALUE.kVersionMinor}
}

proc update_MODELPARAM_VALUE.kAddBUFMR { MODELPARAM_VALUE.kAddBUFMR PARAM_VALUE.kAddBUFMR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kAddBUFMR}] ${MODELPARAM_VALUE.kAddBUFMR}
}

