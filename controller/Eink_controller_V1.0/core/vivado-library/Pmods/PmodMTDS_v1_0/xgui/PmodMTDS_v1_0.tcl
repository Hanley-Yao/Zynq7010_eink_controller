
package require xilinx::board 1.0
namespace import ::xilinx::board::*

proc get_pmod_vlnv {} {
	return "digilentinc.com:interface:pmod_rtl:1.0"
}
proc get_spi_vlnv {} {
	return "xilinx.com:interface:spi_rtl:1.0"
}

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST PROJECT_PARAM.ARCHITECTURE PROJECT_PARAM.BOARD } {
  set c_family ${PROJECT_PARAM.ARCHITECTURE}
  set board ${PROJECT_PARAM.BOARD}
  set Component_Name [ ipgui::add_param  $IPINST  -parent  $IPINST  -name Component_Name ]
  
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Interfaces [ipgui::add_page $IPINST -name "Interface"]
  set_property tooltip {Choose output interface} ${Interfaces}
  ipgui::add_param $IPINST -name "Interface" -parent ${Interfaces} -widget comboBox
  
 
  add_board_tab $IPINST
}

proc update_PARAM_VALUE.PMOD {IPINST PARAM_VALUE.PMOD PROJECT_PARAM.BOARD} {
	set param_range [get_board_interface_param_range $IPINST -name "PMOD"]
	set_property range $param_range ${PARAM_VALUE.PMOD}
}

proc validate_PARAM_VALUE.PMOD { PARAM_VALUE.PMOD PARAM_VALUE.USE_BOARD_FLOW IPINST PROJECT_PARAM.BOARD} {
	set pmod_vlnv [get_pmod_vlnv]
	set intf [ get_property value ${PARAM_VALUE.PMOD} ]
	set board ${PROJECT_PARAM.BOARD}
	return true
}
proc update_PARAM_VALUE.SPI_INTERFACE {IPINST PARAM_VALUE.SPI_INTERFACE PROJECT_PARAM.BOARD} {
	set param_range [get_board_interface_param_range $IPINST -name "SPI_INTERFACE"]
	set_property range $param_range ${PARAM_VALUE.SPI_INTERFACE}
}

proc validate_PARAM_VALUE.SPI_INTERFACE { PARAM_VALUE.SPI_INTERFACE PARAM_VALUE.USE_BOARD_FLOW IPINST PROJECT_PARAM.BOARD} {
	set spi_vlnv [get_spi_vlnv]
	set intf [ get_property value ${PARAM_VALUE.SPI_INTERFACE} ]
	set board ${PROJECT_PARAM.BOARD}
	return true
}
proc update_PARAM_VALUE.Interface {PARAM_VALUE.Interface PARAM_VALUE.SPI_INTERFACE PROJECT_PARAM.BOARD} {
        set boardIfName [get_property value ${PARAM_VALUE.SPI_INTERFACE}]
	if { $boardIfName ne "Custom"} {
		set_property value "SPI" ${PARAM_VALUE.Interface}
	} else {
		set_property value "PMOD" ${PARAM_VALUE.Interface}
	}
}

proc update_MODELPARAM_VALUE.Interface { MODELPARAM_VALUE.Interface PARAM_VALUE.Interface} {
	set_property value [ get_property value ${PARAM_VALUE.Interface} ]  ${MODELPARAM_VALUE.Interface} 
}

proc update_PARAM_VALUE.C_AXI_LITE_GPIO_DATA_WIDTH { PARAM_VALUE.C_AXI_LITE_GPIO_DATA_WIDTH } {
	# Procedure called to update C_AXI_LITE_GPIO_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_GPIO_DATA_WIDTH { PARAM_VALUE.C_AXI_LITE_GPIO_DATA_WIDTH } {
	# Procedure called to validate C_AXI_LITE_GPIO_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_GPIO_ADDR_WIDTH { PARAM_VALUE.C_AXI_LITE_GPIO_ADDR_WIDTH } {
	# Procedure called to update C_AXI_LITE_GPIO_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_GPIO_ADDR_WIDTH { PARAM_VALUE.C_AXI_LITE_GPIO_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_LITE_GPIO_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_GPIO_BASEADDR { PARAM_VALUE.C_AXI_LITE_GPIO_BASEADDR } {
	# Procedure called to update C_AXI_LITE_GPIO_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_GPIO_BASEADDR { PARAM_VALUE.C_AXI_LITE_GPIO_BASEADDR } {
	# Procedure called to validate C_AXI_LITE_GPIO_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_GPIO_HIGHADDR { PARAM_VALUE.C_AXI_LITE_GPIO_HIGHADDR } {
	# Procedure called to update C_AXI_LITE_GPIO_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_GPIO_HIGHADDR { PARAM_VALUE.C_AXI_LITE_GPIO_HIGHADDR } {
	# Procedure called to validate C_AXI_LITE_GPIO_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_SPI_DATA_WIDTH { PARAM_VALUE.C_AXI_LITE_SPI_DATA_WIDTH } {
	# Procedure called to update C_AXI_LITE_SPI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_SPI_DATA_WIDTH { PARAM_VALUE.C_AXI_LITE_SPI_DATA_WIDTH } {
	# Procedure called to validate C_AXI_LITE_SPI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_SPI_ADDR_WIDTH { PARAM_VALUE.C_AXI_LITE_SPI_ADDR_WIDTH } {
	# Procedure called to update C_AXI_LITE_SPI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_SPI_ADDR_WIDTH { PARAM_VALUE.C_AXI_LITE_SPI_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_LITE_SPI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_SPI_BASEADDR { PARAM_VALUE.C_AXI_LITE_SPI_BASEADDR } {
	# Procedure called to update C_AXI_LITE_SPI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_SPI_BASEADDR { PARAM_VALUE.C_AXI_LITE_SPI_BASEADDR } {
	# Procedure called to validate C_AXI_LITE_SPI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_SPI_HIGHADDR { PARAM_VALUE.C_AXI_LITE_SPI_HIGHADDR } {
	# Procedure called to update C_AXI_LITE_SPI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_SPI_HIGHADDR { PARAM_VALUE.C_AXI_LITE_SPI_HIGHADDR } {
	# Procedure called to validate C_AXI_LITE_SPI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_LITE_GPIO_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_GPIO_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_GPIO_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_GPIO_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_GPIO_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_GPIO_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_GPIO_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_GPIO_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_GPIO_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_GPIO_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_SPI_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_SPI_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_SPI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_SPI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_SPI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_SPI_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_SPI_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_SPI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_SPI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_SPI_ADDR_WIDTH}
}

