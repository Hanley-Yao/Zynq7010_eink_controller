

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "PmodGPS" "NUM_INSTANCES" "DEVICE_ID"  "AXI_LITE_UART_BASEADDR" "AXI_LITE_UART_HIGHADDR" "AXI_LITE_GPIO_BASEADDR" "AXI_LITE_GPIO_HIGHADDR"
}
