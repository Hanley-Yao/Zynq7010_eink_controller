# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\Users\Admin\Desktop\Zynq7010_eink_controller\controller\Eink_controller_V1.0\Eink_controller_V1.0.vitis\frame_buffer_system\_ide\scripts\systemdebugger_frame_buffer_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\Users\Admin\Desktop\Zynq7010_eink_controller\controller\Eink_controller_V1.0\Eink_controller_V1.0.vitis\frame_buffer_system\_ide\scripts\systemdebugger_frame_buffer_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent PYNQ 235179734731A" && level==0 && jtag_device_ctx=="jsn-PYNQ-235179734731A-13722093-0"}
fpga -file C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.vitis/frame_buffer/_ide/bitstream/eink_controller_et068sc1_img_demo.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.vitis/ps_system/export/ps_system/hw/eink_controller_et068sc1_img_demo.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.vitis/frame_buffer/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.vitis/frame_buffer/Debug/frame_buffer.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
