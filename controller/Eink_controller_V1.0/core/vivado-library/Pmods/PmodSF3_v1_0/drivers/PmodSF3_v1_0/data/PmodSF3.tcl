

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "PmodSF3" "NUM_INSTANCES" "DEVICE_ID"  "AXI_LITE_SPI_BASEADDR" "AXI_LITE_SPI_HIGHADDR"
}
