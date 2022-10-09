# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "kExtRelayConfigEn" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kExtCalibEn" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kExtSyncEn" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kExtCmdInterfaceEn" -parent ${Page_0}
  set kCh1CouplingStatic [ipgui::add_param $IPINST -name "kCh1CouplingStatic" -parent ${Page_0}]
  set_property tooltip {kCh1CouplingStatic} ${kCh1CouplingStatic}
  ipgui::add_param $IPINST -name "kCh2HgAddCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2HgMultCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2LgAddCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2LgMultCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1HgAddCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1HgMultCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1LgAddCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1LgMultCoefStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2GainStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh1GainStatic" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kCh2CouplingStatic" -parent ${Page_0}


}

proc update_PARAM_VALUE.kCh1CouplingStatic { PARAM_VALUE.kCh1CouplingStatic } {
	# Procedure called to update kCh1CouplingStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh1CouplingStatic { PARAM_VALUE.kCh1CouplingStatic } {
	# Procedure called to validate kCh1CouplingStatic
	return true
}

proc update_PARAM_VALUE.kCh1GainStatic { PARAM_VALUE.kCh1GainStatic } {
	# Procedure called to update kCh1GainStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh1GainStatic { PARAM_VALUE.kCh1GainStatic } {
	# Procedure called to validate kCh1GainStatic
	return true
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

proc update_PARAM_VALUE.kCh2CouplingStatic { PARAM_VALUE.kCh2CouplingStatic } {
	# Procedure called to update kCh2CouplingStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh2CouplingStatic { PARAM_VALUE.kCh2CouplingStatic } {
	# Procedure called to validate kCh2CouplingStatic
	return true
}

proc update_PARAM_VALUE.kCh2GainStatic { PARAM_VALUE.kCh2GainStatic } {
	# Procedure called to update kCh2GainStatic when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kCh2GainStatic { PARAM_VALUE.kCh2GainStatic } {
	# Procedure called to validate kCh2GainStatic
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

proc update_PARAM_VALUE.kExtRelayConfigEn { PARAM_VALUE.kExtRelayConfigEn } {
	# Procedure called to update kExtRelayConfigEn when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kExtRelayConfigEn { PARAM_VALUE.kExtRelayConfigEn } {
	# Procedure called to validate kExtRelayConfigEn
	return true
}

proc update_PARAM_VALUE.kExtSyncEn { PARAM_VALUE.kExtSyncEn } {
	# Procedure called to update kExtSyncEn when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kExtSyncEn { PARAM_VALUE.kExtSyncEn } {
	# Procedure called to validate kExtSyncEn
	return true
}


proc update_MODELPARAM_VALUE.kCh1CouplingStatic { MODELPARAM_VALUE.kCh1CouplingStatic PARAM_VALUE.kCh1CouplingStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh1CouplingStatic}] ${MODELPARAM_VALUE.kCh1CouplingStatic}
}

proc update_MODELPARAM_VALUE.kCh2CouplingStatic { MODELPARAM_VALUE.kCh2CouplingStatic PARAM_VALUE.kCh2CouplingStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh2CouplingStatic}] ${MODELPARAM_VALUE.kCh2CouplingStatic}
}

proc update_MODELPARAM_VALUE.kCh1GainStatic { MODELPARAM_VALUE.kCh1GainStatic PARAM_VALUE.kCh1GainStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh1GainStatic}] ${MODELPARAM_VALUE.kCh1GainStatic}
}

proc update_MODELPARAM_VALUE.kCh2GainStatic { MODELPARAM_VALUE.kCh2GainStatic PARAM_VALUE.kCh2GainStatic } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kCh2GainStatic}] ${MODELPARAM_VALUE.kCh2GainStatic}
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

proc update_MODELPARAM_VALUE.kExtRelayConfigEn { MODELPARAM_VALUE.kExtRelayConfigEn PARAM_VALUE.kExtRelayConfigEn } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kExtRelayConfigEn}] ${MODELPARAM_VALUE.kExtRelayConfigEn}
}

proc update_MODELPARAM_VALUE.kExtCalibEn { MODELPARAM_VALUE.kExtCalibEn PARAM_VALUE.kExtCalibEn } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kExtCalibEn}] ${MODELPARAM_VALUE.kExtCalibEn}
}

proc update_MODELPARAM_VALUE.kExtCmdInterfaceEn { MODELPARAM_VALUE.kExtCmdInterfaceEn PARAM_VALUE.kExtCmdInterfaceEn } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kExtCmdInterfaceEn}] ${MODELPARAM_VALUE.kExtCmdInterfaceEn}
}

proc update_MODELPARAM_VALUE.kExtSyncEn { MODELPARAM_VALUE.kExtSyncEn PARAM_VALUE.kExtSyncEn } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kExtSyncEn}] ${MODELPARAM_VALUE.kExtSyncEn}
}

