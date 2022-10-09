# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Control}]
  ipgui::add_param $IPINST -name "kGenerateAXIL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kDebug" -parent ${Page_0}

  #Adding Page
  set MIPI [ipgui::add_page $IPINST -name "MIPI"]
  ipgui::add_param $IPINST -name "kLaneCount" -parent ${MIPI} -widget comboBox
  ipgui::add_param $IPINST -name "kTargetDT" -parent ${MIPI} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXIS_COMPONENT_WIDTH" -parent ${MIPI} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXIS_TDATA_WIDTH" -parent ${MIPI} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_MAX_SAMPLES_PER_CLOCK" -parent ${MIPI} -widget comboBox


}

proc update_PARAM_VALUE.C_M_AXIS_COMPONENT_WIDTH { PARAM_VALUE.C_M_AXIS_COMPONENT_WIDTH } {
	# Procedure called to update C_M_AXIS_COMPONENT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_COMPONENT_WIDTH { PARAM_VALUE.C_M_AXIS_COMPONENT_WIDTH } {
	# Procedure called to validate C_M_AXIS_COMPONENT_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_M_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_M_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_MAX_SAMPLES_PER_CLOCK { PARAM_VALUE.C_M_MAX_SAMPLES_PER_CLOCK } {
	# Procedure called to update C_M_MAX_SAMPLES_PER_CLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_MAX_SAMPLES_PER_CLOCK { PARAM_VALUE.C_M_MAX_SAMPLES_PER_CLOCK } {
	# Procedure called to validate C_M_MAX_SAMPLES_PER_CLOCK
	return true
}

proc update_PARAM_VALUE.kDebug { PARAM_VALUE.kDebug } {
	# Procedure called to update kDebug when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kDebug { PARAM_VALUE.kDebug } {
	# Procedure called to validate kDebug
	return true
}

proc update_PARAM_VALUE.kGenerateAXIL { PARAM_VALUE.kGenerateAXIL } {
	# Procedure called to update kGenerateAXIL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kGenerateAXIL { PARAM_VALUE.kGenerateAXIL } {
	# Procedure called to validate kGenerateAXIL
	return true
}

proc update_PARAM_VALUE.kLaneCount { PARAM_VALUE.kLaneCount } {
	# Procedure called to update kLaneCount when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kLaneCount { PARAM_VALUE.kLaneCount } {
	# Procedure called to validate kLaneCount
	return true
}

proc update_PARAM_VALUE.kTargetDT { PARAM_VALUE.kTargetDT } {
	# Procedure called to update kTargetDT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kTargetDT { PARAM_VALUE.kTargetDT } {
	# Procedure called to validate kTargetDT
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

proc update_MODELPARAM_VALUE.kVersionMajor { MODELPARAM_VALUE.kVersionMajor PARAM_VALUE.kVersionMajor } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kVersionMajor}] ${MODELPARAM_VALUE.kVersionMajor}
}

proc update_MODELPARAM_VALUE.kVersionMinor { MODELPARAM_VALUE.kVersionMinor PARAM_VALUE.kVersionMinor } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kVersionMinor}] ${MODELPARAM_VALUE.kVersionMinor}
}

proc update_MODELPARAM_VALUE.kTargetDT { MODELPARAM_VALUE.kTargetDT PARAM_VALUE.kTargetDT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kTargetDT}] ${MODELPARAM_VALUE.kTargetDT}
}

proc update_MODELPARAM_VALUE.kGenerateAXIL { MODELPARAM_VALUE.kGenerateAXIL PARAM_VALUE.kGenerateAXIL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kGenerateAXIL}] ${MODELPARAM_VALUE.kGenerateAXIL}
}

proc update_MODELPARAM_VALUE.kDebug { MODELPARAM_VALUE.kDebug PARAM_VALUE.kDebug } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kDebug}] ${MODELPARAM_VALUE.kDebug}
}

proc update_MODELPARAM_VALUE.kLaneCount { MODELPARAM_VALUE.kLaneCount PARAM_VALUE.kLaneCount } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kLaneCount}] ${MODELPARAM_VALUE.kLaneCount}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_COMPONENT_WIDTH { MODELPARAM_VALUE.C_M_AXIS_COMPONENT_WIDTH PARAM_VALUE.C_M_AXIS_COMPONENT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_COMPONENT_WIDTH}] ${MODELPARAM_VALUE.C_M_AXIS_COMPONENT_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_MAX_SAMPLES_PER_CLOCK { MODELPARAM_VALUE.C_M_MAX_SAMPLES_PER_CLOCK PARAM_VALUE.C_M_MAX_SAMPLES_PER_CLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_MAX_SAMPLES_PER_CLOCK}] ${MODELPARAM_VALUE.C_M_MAX_SAMPLES_PER_CLOCK}
}

