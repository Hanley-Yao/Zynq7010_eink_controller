#
# This file was created by Xilinx Vitis tool.
#


#
# tools
#

RM = rm -f
RMDIR = rm -rf



#
# variables
#

SDCARD_GEN = sdcard_gen
GENERATE_BIF = ::scw::generate_bif

XPFM_PATH = C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.vitis/ps_system/export/ps_system/ps_system.xpfm
SYS_CONFIG = ps_system
DOMAINS = standalone_domain
BIF_PATH = C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.vitis/FSBL_system/Debug/system.bif

BITSTREAM_PATH = C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.vitis/FSBL/_ide/bitstream/eink_controller_et073.bit
SD_FILES = --elf C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.vitis/FSBL/Debug/FSBL.elf,ps7_cortexa9_0

#
# primary build targets
#

all: package

package:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 3345 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --bitstream ${BITSTREAM_PATH} ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} package
	${RM} system.bif

.PHONY: all package clean


