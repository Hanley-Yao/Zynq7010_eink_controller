# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set kDataWidth  [  ipgui::add_param $IPINST -name "kDataWidth" -parent ${Page_0} -display_name {Input Data Width}]
  set_property tooltip {Input Data Width} ${kDataWidth}


}

proc update_PARAM_VALUE.kDataWidth { PARAM_VALUE.kDataWidth } {
	# Procedure called to update kDataWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kDataWidth { PARAM_VALUE.kDataWidth } {
	# Procedure called to validate kDataWidth
	return true
}


proc update_MODELPARAM_VALUE.kDataWidth { MODELPARAM_VALUE.kDataWidth PARAM_VALUE.kDataWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kDataWidth}] ${MODELPARAM_VALUE.kDataWidth}
}

