# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  ipgui::add_param $IPINST -name "perturb_div_int"

}

proc update_PARAM_VALUE.perturb_div_int { PARAM_VALUE.perturb_div_int } {
	# Procedure called to update perturb_div_int when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.perturb_div_int { PARAM_VALUE.perturb_div_int } {
	# Procedure called to validate perturb_div_int
	return true
}


proc update_MODELPARAM_VALUE.perturb_div_int { MODELPARAM_VALUE.perturb_div_int PARAM_VALUE.perturb_div_int } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.perturb_div_int}] ${MODELPARAM_VALUE.perturb_div_int}
}

