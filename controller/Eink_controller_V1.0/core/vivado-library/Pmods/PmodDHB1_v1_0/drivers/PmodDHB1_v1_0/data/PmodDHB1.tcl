

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "PmodDHB1" "NUM_INSTANCES" "DEVICE_ID" "AXI_LITE_GPIO_BASEADDR" "AXI_LITE_GPIO_HIGHADDR" "PWM_AXI_BASEADDR" "PWM_AXI_HIGHADDR" "MOTOR_FB_AXI_BASEADDR" "MOTOR_FB_AXI_HIGHADDR"
}
