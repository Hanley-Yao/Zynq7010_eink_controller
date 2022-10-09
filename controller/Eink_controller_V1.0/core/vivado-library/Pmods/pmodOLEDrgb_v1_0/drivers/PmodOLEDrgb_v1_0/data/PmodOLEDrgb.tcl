

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "PmodOLEDrgb" "NUM_INSTANCES" "DEVICE_ID"  "C_AXI_LITE_GPIO_BASEADDR" "C_AXI_LITE_GPIO_HIGHADDR" "C_AXI_LITE_SPI_BASEADDR" "C_AXI_LITE_SPI_HIGHADDR"
}
