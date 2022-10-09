# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page0 [ipgui::add_page $IPINST -name "Page0"]
  set kRstActiveHigh [ipgui::add_param $IPINST -name "kRstActiveHigh" -parent ${Page0}]
  set_property tooltip {Tick for active-high, untick for active-low} ${kRstActiveHigh}
  ipgui::add_param $IPINST -name "kResetTo" -parent ${Page0} -widget comboBox
  ipgui::add_param $IPINST -name "kStages" -parent ${Page0}
  ipgui::add_param $IPINST -name "kRegisterInput" -parent ${Page0}


}

proc update_PARAM_VALUE.kRegisterInput { PARAM_VALUE.kRegisterInput } {
	# Procedure called to update kRegisterInput when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kRegisterInput { PARAM_VALUE.kRegisterInput } {
	# Procedure called to validate kRegisterInput
	return true
}

proc update_PARAM_VALUE.kResetTo { PARAM_VALUE.kResetTo } {
	# Procedure called to update kResetTo when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kResetTo { PARAM_VALUE.kResetTo } {
	# Procedure called to validate kResetTo
	return true
}

proc update_PARAM_VALUE.kRstActiveHigh { PARAM_VALUE.kRstActiveHigh } {
	# Procedure called to update kRstActiveHigh when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kRstActiveHigh { PARAM_VALUE.kRstActiveHigh } {
	# Procedure called to validate kRstActiveHigh
	return true
}

proc update_PARAM_VALUE.kStages { PARAM_VALUE.kStages } {
	# Procedure called to update kStages when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kStages { PARAM_VALUE.kStages } {
	# Procedure called to validate kStages
	return true
}


proc update_MODELPARAM_VALUE.kRstActiveHigh { MODELPARAM_VALUE.kRstActiveHigh PARAM_VALUE.kRstActiveHigh } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kRstActiveHigh}] ${MODELPARAM_VALUE.kRstActiveHigh}
}

proc update_MODELPARAM_VALUE.kResetTo { MODELPARAM_VALUE.kResetTo PARAM_VALUE.kResetTo } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kResetTo}] ${MODELPARAM_VALUE.kResetTo}
}

proc update_MODELPARAM_VALUE.kRegisterInput { MODELPARAM_VALUE.kRegisterInput PARAM_VALUE.kRegisterInput } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kRegisterInput}] ${MODELPARAM_VALUE.kRegisterInput}
}

proc update_MODELPARAM_VALUE.kStages { MODELPARAM_VALUE.kStages PARAM_VALUE.kStages } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kStages}] ${MODELPARAM_VALUE.kStages}
}

