

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "PmodENC" "NUM_INSTANCES" "DEVICE_ID" "AXI_LITE_GPIO_BASEADDR" "AXI_LITE_GPIO_HIGHADDR"
}
