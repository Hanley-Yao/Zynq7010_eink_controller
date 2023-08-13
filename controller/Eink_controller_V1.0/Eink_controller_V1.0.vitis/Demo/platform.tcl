# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\Admin\Desktop\open\Zynq7010_eink_controller\controller\Eink_controller_V1.0\Eink_controller_V1.0.vitis\Demo\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\Admin\Desktop\open\Zynq7010_eink_controller\controller\Eink_controller_V1.0\Eink_controller_V1.0.vitis\Demo\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {Demo}\
-hw {C:\Users\Admin\Desktop\open\Zynq7010_eink_controller\controller\Eink_controller_V1.0\eink_controller_es108fc1.xsa}\
-proc {ps7_cortexa9_0} -os {standalone} -fsbl-target {psu_cortexa53_0} -out {C:/Users/Admin/Desktop/open/Zynq7010_eink_controller/controller/Eink_controller_V1.0/Eink_controller_V1.0.vitis}

platform write
platform generate -domains 
platform active {Demo}
platform generate
platform active {Demo}
platform config -updatehw {C:/Users/Admin/Desktop/open/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/open/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/open/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform generate -domains 
platform active {Demo}
platform config -updatehw {C:/Users/Admin/Desktop/open/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform generate -domains 
platform active {Demo}
platform config -updatehw {C:/Users/Admin/Desktop/open/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform clean
