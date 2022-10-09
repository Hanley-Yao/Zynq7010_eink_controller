

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "PmodSD" "NUM_INSTANCES" "DEVICE_ID"  "AXI_LITE_SPI_BASEADDR" "AXI_LITE_SPI_HIGHADDR" "AXI_LITE_SDCS_BASEADDR" "AXI_LITE_SDCS_HIGHADDR"
}
