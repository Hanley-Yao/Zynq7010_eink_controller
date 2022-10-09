# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "Threshold" -parent ${Page_0}


}

proc update_PARAM_VALUE.Threshold { PARAM_VALUE.Threshold } {
	# Procedure called to update Threshold when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Threshold { PARAM_VALUE.Threshold } {
	# Procedure called to validate Threshold
	return true
}


proc update_MODELPARAM_VALUE.Threshold { MODELPARAM_VALUE.Threshold PARAM_VALUE.Threshold } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Threshold}] ${MODELPARAM_VALUE.Threshold}
}

