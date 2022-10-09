

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "PWM" "NUM_INSTANCES" "DEVICE_ID"  "C_PWM_AXI_BASEADDR" "C_PWM_AXI_HIGHADDR"
}
