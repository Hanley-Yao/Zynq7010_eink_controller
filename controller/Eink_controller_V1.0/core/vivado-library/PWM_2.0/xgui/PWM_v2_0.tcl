# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set NUM_PWM [ipgui::add_param $IPINST -name "NUM_PWM" -parent ${Page_0}]
  set_property tooltip {Number of PWM signals to output} ${NUM_PWM}
  set POLARITY [ipgui::add_param $IPINST -name "POLARITY" -parent ${Page_0} -widget comboBox]
  set_property tooltip {The polarity of the output pulse. Setting this to Low will cause larger duty cycle values to result in smaller pulses} ${POLARITY}


}

proc update_PARAM_VALUE.NUM_PWM { PARAM_VALUE.NUM_PWM } {
	# Procedure called to update NUM_PWM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_PWM { PARAM_VALUE.NUM_PWM } {
	# Procedure called to validate NUM_PWM
	return true
}

proc update_PARAM_VALUE.POLARITY { PARAM_VALUE.POLARITY } {
	# Procedure called to update POLARITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.POLARITY { PARAM_VALUE.POLARITY } {
	# Procedure called to validate POLARITY
	return true
}

proc update_PARAM_VALUE.C_PWM_AXI_DATA_WIDTH { PARAM_VALUE.C_PWM_AXI_DATA_WIDTH } {
	# Procedure called to update C_PWM_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PWM_AXI_DATA_WIDTH { PARAM_VALUE.C_PWM_AXI_DATA_WIDTH } {
	# Procedure called to validate C_PWM_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_PWM_AXI_ADDR_WIDTH { PARAM_VALUE.C_PWM_AXI_ADDR_WIDTH } {
	# Procedure called to update C_PWM_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PWM_AXI_ADDR_WIDTH { PARAM_VALUE.C_PWM_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_PWM_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_PWM_AXI_BASEADDR { PARAM_VALUE.C_PWM_AXI_BASEADDR } {
	# Procedure called to update C_PWM_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PWM_AXI_BASEADDR { PARAM_VALUE.C_PWM_AXI_BASEADDR } {
	# Procedure called to validate C_PWM_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_PWM_AXI_HIGHADDR { PARAM_VALUE.C_PWM_AXI_HIGHADDR } {
	# Procedure called to update C_PWM_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PWM_AXI_HIGHADDR { PARAM_VALUE.C_PWM_AXI_HIGHADDR } {
	# Procedure called to validate C_PWM_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_PWM_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_PWM_AXI_DATA_WIDTH PARAM_VALUE.C_PWM_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PWM_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_PWM_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_PWM_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_PWM_AXI_ADDR_WIDTH PARAM_VALUE.C_PWM_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PWM_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_PWM_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.NUM_PWM { MODELPARAM_VALUE.NUM_PWM PARAM_VALUE.NUM_PWM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_PWM}] ${MODELPARAM_VALUE.NUM_PWM}
}

proc update_MODELPARAM_VALUE.POLARITY { MODELPARAM_VALUE.POLARITY PARAM_VALUE.POLARITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POLARITY}] ${MODELPARAM_VALUE.POLARITY}
}

