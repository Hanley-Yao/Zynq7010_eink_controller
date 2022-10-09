

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "PmodBLE" "NUM_INSTANCES" "DEVICE_ID"  "S_AXI_UART_BASEADDR" "S_AXI_UART_HIGHADDR" "S_AXI_GPIO_BASEADDR" "S_AXI_GPIO_HIGHADDR"
}
