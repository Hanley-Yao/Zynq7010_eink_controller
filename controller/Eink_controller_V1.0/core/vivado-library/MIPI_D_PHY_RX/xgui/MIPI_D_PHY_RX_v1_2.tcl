
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/MIPI_D_PHY_RX_v1_2.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Control [ipgui::add_page $IPINST -name "Control"]
  ipgui::add_param $IPINST -name "kGenerateAXIL" -parent ${Control}
  set kLPFromLane0 [ipgui::add_param $IPINST -name "kLPFromLane0" -parent ${Control}]
  set_property tooltip {Check if only Lane 0 has low-power signals and should be shared between all data lanes.} ${kLPFromLane0}
  set kDebug [ipgui::add_param $IPINST -name "kDebug" -parent ${Control}]
  set_property tooltip {Instantiate ILAs to probe pre-defined signals} ${kDebug}
  #Adding Group
  set Clocking [ipgui::add_group $IPINST -name "Clocking" -parent ${Control}]
  ipgui::add_param $IPINST -name "kRefClkFreqHz" -parent ${Clocking}
  ipgui::add_param $IPINST -name "C_S_AXI_LITE_FREQ_HZ" -parent ${Clocking}


  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {D-PHY}]
  set kGenerateMMCM [ipgui::add_param $IPINST -name "kGenerateMMCM" -parent ${Page_0}]
  set_property tooltip {Not implemented yet} ${kGenerateMMCM}
  ipgui::add_param $IPINST -name "kNoOfDataLanes" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "kAddDelayClk_ps" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kAddDelayData0_ps" -parent ${Page_0}
  ipgui::add_param $IPINST -name "kAddDelayData1_ps" -parent ${Page_0}


}

proc update_PARAM_VALUE.kAddDelayData1_ps { PARAM_VALUE.kAddDelayData1_ps PARAM_VALUE.kNoOfDataLanes } {
	# Procedure called to update kAddDelayData1_ps when any of the dependent parameters in the arguments change
	
	set kAddDelayData1_ps ${PARAM_VALUE.kAddDelayData1_ps}
	set kNoOfDataLanes ${PARAM_VALUE.kNoOfDataLanes}
	set values(kNoOfDataLanes) [get_property value $kNoOfDataLanes]
	if { [gen_USERPARAMETER_kAddDelayData1_ps_ENABLEMENT $values(kNoOfDataLanes)] } {
		set_property enabled true $kAddDelayData1_ps
	} else {
		set_property enabled false $kAddDelayData1_ps
	}
}

proc validate_PARAM_VALUE.kAddDelayData1_ps { PARAM_VALUE.kAddDelayData1_ps } {
	# Procedure called to validate kAddDelayData1_ps
	return true
}

proc update_PARAM_VALUE.kLPFromLane0 { PARAM_VALUE.kLPFromLane0 PARAM_VALUE.kNoOfDataLanes } {
	# Procedure called to update kLPFromLane0 when any of the dependent parameters in the arguments change
	
	set kLPFromLane0 ${PARAM_VALUE.kLPFromLane0}
	set kNoOfDataLanes ${PARAM_VALUE.kNoOfDataLanes}
	set values(kNoOfDataLanes) [get_property value $kNoOfDataLanes]
	if { [gen_USERPARAMETER_kLPFromLane0_ENABLEMENT $values(kNoOfDataLanes)] } {
		set_property enabled true $kLPFromLane0
	} else {
		set_property enabled false $kLPFromLane0
	}
}

proc validate_PARAM_VALUE.kLPFromLane0 { PARAM_VALUE.kLPFromLane0 } {
	# Procedure called to validate kLPFromLane0
	return true
}

proc update_PARAM_VALUE.C_S_AXI_LITE_FREQ_HZ { PARAM_VALUE.C_S_AXI_LITE_FREQ_HZ } {
	# Procedure called to update C_S_AXI_LITE_FREQ_HZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_LITE_FREQ_HZ { PARAM_VALUE.C_S_AXI_LITE_FREQ_HZ } {
	# Procedure called to validate C_S_AXI_LITE_FREQ_HZ
	return true
}

proc update_PARAM_VALUE.kAddDelayClk_ps { PARAM_VALUE.kAddDelayClk_ps } {
	# Procedure called to update kAddDelayClk_ps when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kAddDelayClk_ps { PARAM_VALUE.kAddDelayClk_ps } {
	# Procedure called to validate kAddDelayClk_ps
	return true
}

proc update_PARAM_VALUE.kAddDelayData0_ps { PARAM_VALUE.kAddDelayData0_ps } {
	# Procedure called to update kAddDelayData0_ps when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kAddDelayData0_ps { PARAM_VALUE.kAddDelayData0_ps } {
	# Procedure called to validate kAddDelayData0_ps
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

proc update_PARAM_VALUE.kGenerateMMCM { PARAM_VALUE.kGenerateMMCM } {
	# Procedure called to update kGenerateMMCM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kGenerateMMCM { PARAM_VALUE.kGenerateMMCM } {
	# Procedure called to validate kGenerateMMCM
	return true
}

proc update_PARAM_VALUE.kNoOfDataLanes { PARAM_VALUE.kNoOfDataLanes } {
	# Procedure called to update kNoOfDataLanes when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.kNoOfDataLanes { PARAM_VALUE.kNoOfDataLanes } {
	# Procedure called to validate kNoOfDataLanes
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

proc update_MODELPARAM_VALUE.kVersionMajor { MODELPARAM_VALUE.kVersionMajor PARAM_VALUE.kVersionMajor } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kVersionMajor}] ${MODELPARAM_VALUE.kVersionMajor}
}

proc update_MODELPARAM_VALUE.kVersionMinor { MODELPARAM_VALUE.kVersionMinor PARAM_VALUE.kVersionMinor } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kVersionMinor}] ${MODELPARAM_VALUE.kVersionMinor}
}

proc update_MODELPARAM_VALUE.kNoOfDataLanes { MODELPARAM_VALUE.kNoOfDataLanes PARAM_VALUE.kNoOfDataLanes } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kNoOfDataLanes}] ${MODELPARAM_VALUE.kNoOfDataLanes}
}

proc update_MODELPARAM_VALUE.kGenerateMMCM { MODELPARAM_VALUE.kGenerateMMCM PARAM_VALUE.kGenerateMMCM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kGenerateMMCM}] ${MODELPARAM_VALUE.kGenerateMMCM}
}

proc update_MODELPARAM_VALUE.kGenerateAXIL { MODELPARAM_VALUE.kGenerateAXIL PARAM_VALUE.kGenerateAXIL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kGenerateAXIL}] ${MODELPARAM_VALUE.kGenerateAXIL}
}

proc update_MODELPARAM_VALUE.kAddDelayClk_ps { MODELPARAM_VALUE.kAddDelayClk_ps PARAM_VALUE.kAddDelayClk_ps } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kAddDelayClk_ps}] ${MODELPARAM_VALUE.kAddDelayClk_ps}
}

proc update_MODELPARAM_VALUE.kAddDelayData0_ps { MODELPARAM_VALUE.kAddDelayData0_ps PARAM_VALUE.kAddDelayData0_ps } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kAddDelayData0_ps}] ${MODELPARAM_VALUE.kAddDelayData0_ps}
}

proc update_MODELPARAM_VALUE.kAddDelayData1_ps { MODELPARAM_VALUE.kAddDelayData1_ps PARAM_VALUE.kAddDelayData1_ps } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kAddDelayData1_ps}] ${MODELPARAM_VALUE.kAddDelayData1_ps}
}

proc update_MODELPARAM_VALUE.kRefClkFreqHz { MODELPARAM_VALUE.kRefClkFreqHz PARAM_VALUE.kRefClkFreqHz } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kRefClkFreqHz}] ${MODELPARAM_VALUE.kRefClkFreqHz}
}

proc update_MODELPARAM_VALUE.kDebug { MODELPARAM_VALUE.kDebug PARAM_VALUE.kDebug } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kDebug}] ${MODELPARAM_VALUE.kDebug}
}

proc update_MODELPARAM_VALUE.C_S_AXI_LITE_FREQ_HZ { MODELPARAM_VALUE.C_S_AXI_LITE_FREQ_HZ PARAM_VALUE.C_S_AXI_LITE_FREQ_HZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_LITE_FREQ_HZ}] ${MODELPARAM_VALUE.C_S_AXI_LITE_FREQ_HZ}
}

proc update_MODELPARAM_VALUE.kLPFromLane0 { MODELPARAM_VALUE.kLPFromLane0 PARAM_VALUE.kLPFromLane0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.kLPFromLane0}] ${MODELPARAM_VALUE.kLPFromLane0}
}

