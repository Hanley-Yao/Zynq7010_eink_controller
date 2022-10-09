# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "kExtCmdInterfaceEn" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kExtScaleConfigEn" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kExtCalibEn" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1HgMultCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1HgAddCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1LgMultCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1LgAddCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2HgMultCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2HgAddCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2LgMultCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2LgAddCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2ScaleStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1ScaleStatic" -parent ${Page_0}


}

proc update_PARAM_VALUE.kCh1HgAddCoefStatic { PARAM_VALUE.kCh1HgAddCoefStatic } {
	# Procedure called to update kCh1HgAddCoefStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh1HgAddCoefStatic { PARAM_VALUE.kCh1HgAddCoefStatic } {
	# Procedure called to validate kCh1HgAddCoefStatic
	return true
}

proc update_PARAM_VALUE.kCh1HgMultCoefStatic { PARAM_VALUE.kCh1HgMultCoefStatic } {
	# Procedure called to update kCh1HgMultCoefStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh1HgMultCoefStatic { PARAM_VALUE.kCh1HgMultCoefStatic } {
	# Procedure called to validate kCh1HgMultCoefStatic
	return true
}

proc update_PARAM_VALUE.kCh1LgAddCoefStatic { PARAM_VALUE.kCh1LgAddCoefStatic } {
	# Procedure called to update kCh1LgAddCoefStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh1LgAddCoefStatic { PARAM_VALUE.kCh1LgAddCoefStatic } {
	# Procedure called to validate kCh1LgAddCoefStatic
	return true
}

proc update_PARAM_VALUE.kCh1LgMultCoefStatic { PARAM_VALUE.kCh1LgMultCoefStatic } {
	# Procedure called to update kCh1LgMultCoefStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh1LgMultCoefStatic { PARAM_VALUE.kCh1LgMultCoefStatic } {
	# Procedure called to validate kCh1LgMultCoefStatic
	return true
}

proc update_PARAM_VALUE.kCh1ScaleStatic { PARAM_VALUE.kCh1ScaleStatic } {
	# Procedure called to update kCh1ScaleStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh1ScaleStatic { PARAM_VALUE.kCh1ScaleStatic } {
	# Procedure called to validate kCh1ScaleStatic
	return true
}

proc update_PARAM_VALUE.kCh2HgAddCoefStatic { PARAM_VALUE.kCh2HgAddCoefStatic } {
	# Procedure called to update kCh2HgAddCoefStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh2HgAddCoefStatic { PARAM_VALUE.kCh2HgAddCoefStatic } {
	# Procedure called to validate kCh2HgAddCoefStatic
	return true
}

proc update_PARAM_VALUE.kCh2HgMultCoefStatic { PARAM_VALUE.kCh2HgMultCoefStatic } {
	# Procedure called to update kCh2HgMultCoefStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh2HgMultCoefStatic { PARAM_VALUE.kCh2HgMultCoefStatic } {
	# Procedure called to validate kCh2HgMultCoefStatic
	return true
}

proc update_PARAM_VALUE.kCh2LgAddCoefStatic { PARAM_VALUE.kCh2LgAddCoefStatic } {
	# Procedure called to update kCh2LgAddCoefStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh2LgAddCoefStatic { PARAM_VALUE.kCh2LgAddCoefStatic } {
	# Procedure called to validate kCh2LgAddCoefStatic
	return true
}

proc update_PARAM_VALUE.kCh2LgMultCoefStatic { PARAM_VALUE.kCh2LgMultCoefStatic } {
	# Procedure called to update kCh2LgMultCoefStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh2LgMultCoefStatic { PARAM_VALUE.kCh2LgMultCoefStatic } {
	# Procedure called to validate kCh2LgMultCoefStatic
	return true
}

proc update_PARAM_VALUE.kCh2ScaleStatic { PARAM_VALUE.kCh2ScaleStatic } {
	# Procedure called to update kCh2ScaleStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh2ScaleStatic { PARAM_VALUE.kCh2ScaleStatic } {
	# Procedure called to validate kCh2ScaleStatic
	return true
}

proc update_PARAM_VALUE.kExtCalibEn { PARAM_VALUE.kExtCalibEn } {
	# Procedure called to update kExtCalibEn when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kExtCalibEn { PARAM_VALUE.kExtCalibEn } {
	# Procedure called to validate kExtCalibEn
	return true
}

proc update_PARAM_VALUE.kExtCmdInterfaceEn { PARAM_VALUE.kExtCmdInterfaceEn } {
	# Procedure called to update kExtCmdInterfaceEn when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kExtCmdInterfaceEn { PARAM_VALUE.kExtCmdInterfaceEn } {
	# Procedure called to validate kExtCmdInterfaceEn
	return true
}

proc update_PARAM_VALUE.kExtScaleConfigEn { PARAM_VALUE.kExtScaleConfigEn } {
	# Procedure called to update kExtScaleConfigEn when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kExtScaleConfigEn { PARAM_VALUE.kExtScaleConfigEn } {
	# Procedure called to validate kExtScaleConfigEn
	return true
}


proc update_MODELPARAM_VALUE.kCh1LgMultCoefStatic { MODELPARAM_VALUE.kCh1LgMultCoefStatic PARAM_VALUE.kCh1LgMultCoefStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh1LgMultCoefStatic}] ${MODELPARAM_VALUE.kCh1LgMultCoefStatic}
}

proc update_MODELPARAM_VALUE.kCh1LgAddCoefStatic { MODELPARAM_VALUE.kCh1LgAddCoefStatic PARAM_VALUE.kCh1LgAddCoefStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh1LgAddCoefStatic}] ${MODELPARAM_VALUE.kCh1LgAddCoefStatic}
}

proc update_MODELPARAM_VALUE.kCh1HgMultCoefStatic { MODELPARAM_VALUE.kCh1HgMultCoefStatic PARAM_VALUE.kCh1HgMultCoefStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh1HgMultCoefStatic}] ${MODELPARAM_VALUE.kCh1HgMultCoefStatic}
}

proc update_MODELPARAM_VALUE.kCh1HgAddCoefStatic { MODELPARAM_VALUE.kCh1HgAddCoefStatic PARAM_VALUE.kCh1HgAddCoefStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh1HgAddCoefStatic}] ${MODELPARAM_VALUE.kCh1HgAddCoefStatic}
}

proc update_MODELPARAM_VALUE.kCh2LgMultCoefStatic { MODELPARAM_VALUE.kCh2LgMultCoefStatic PARAM_VALUE.kCh2LgMultCoefStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh2LgMultCoefStatic}] ${MODELPARAM_VALUE.kCh2LgMultCoefStatic}
}

proc update_MODELPARAM_VALUE.kCh2LgAddCoefStatic { MODELPARAM_VALUE.kCh2LgAddCoefStatic PARAM_VALUE.kCh2LgAddCoefStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh2LgAddCoefStatic}] ${MODELPARAM_VALUE.kCh2LgAddCoefStatic}
}

proc update_MODELPARAM_VALUE.kCh2HgMultCoefStatic { MODELPARAM_VALUE.kCh2HgMultCoefStatic PARAM_VALUE.kCh2HgMultCoefStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh2HgMultCoefStatic}] ${MODELPARAM_VALUE.kCh2HgMultCoefStatic}
}

proc update_MODELPARAM_VALUE.kCh2HgAddCoefStatic { MODELPARAM_VALUE.kCh2HgAddCoefStatic PARAM_VALUE.kCh2HgAddCoefStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh2HgAddCoefStatic}] ${MODELPARAM_VALUE.kCh2HgAddCoefStatic}
}

proc update_MODELPARAM_VALUE.kCh1ScaleStatic { MODELPARAM_VALUE.kCh1ScaleStatic PARAM_VALUE.kCh1ScaleStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh1ScaleStatic}] ${MODELPARAM_VALUE.kCh1ScaleStatic}
}

proc update_MODELPARAM_VALUE.kCh2ScaleStatic { MODELPARAM_VALUE.kCh2ScaleStatic PARAM_VALUE.kCh2ScaleStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh2ScaleStatic}] ${MODELPARAM_VALUE.kCh2ScaleStatic}
}

proc update_MODELPARAM_VALUE.kExtCalibEn { MODELPARAM_VALUE.kExtCalibEn PARAM_VALUE.kExtCalibEn } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kExtCalibEn}] ${MODELPARAM_VALUE.kExtCalibEn}
}

proc update_MODELPARAM_VALUE.kExtScaleConfigEn { MODELPARAM_VALUE.kExtScaleConfigEn PARAM_VALUE.kExtScaleConfigEn } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kExtScaleConfigEn}] ${MODELPARAM_VALUE.kExtScaleConfigEn}
}

proc update_MODELPARAM_VALUE.kExtCmdInterfaceEn { MODELPARAM_VALUE.kExtCmdInterfaceEn PARAM_VALUE.kExtCmdInterfaceEn } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kExtCmdInterfaceEn}] ${MODELPARAM_VALUE.kExtCmdInterfaceEn}
}

