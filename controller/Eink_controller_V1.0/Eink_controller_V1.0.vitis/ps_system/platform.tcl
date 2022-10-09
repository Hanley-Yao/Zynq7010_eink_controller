# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\Admin\Desktop\Zynq7010_eink_controller\controller\Z7_Lite\Eink_controller\Eink_controller.vitis\ps_system\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\Admin\Desktop\Zynq7010_eink_controller\controller\Z7_Lite\Eink_controller\Eink_controller.vitis\ps_system\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {ps_system}\
-hw {C:\Users\Admin\Desktop\Zynq7010_eink_controller\controller\Z7_Lite\Eink_controller\eink_controller.xsa}\
-proc {ps7_cortexa9_0} -os {standalone} -fsbl-target {psu_cortexa53_0} -out {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/Eink_controller.vitis}

platform write
platform generate -domains 
platform active {ps_system}
platform generate
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
domain active {zynq_fsbl}
bsp reload
domain active {standalone_domain}
bsp reload
bsp setlib -name xilffs -ver 4.4
bsp config use_lfn "1"
bsp config use_strfunc "0"
bsp config use_strfunc "2"
bsp write
bsp reload
catch {bsp regenerate}
bsp reload
platform generate -domains standalone_domain 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
domain active {zynq_fsbl}
bsp reload
domain active {standalone_domain}
bsp reload
bsp reload
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform generate
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
domain active {zynq_fsbl}
bsp reload
domain active {standalone_domain}
bsp reload
platform generate -domains 
platform generate
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
domain active {zynq_fsbl}
bsp reload
catch {bsp regenerate}
domain active {standalone_domain}
bsp reload
catch {bsp regenerate}
domain active {zynq_fsbl}
catch {bsp regenerate}
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Z7_Lite/Eink_controller/eink_controller.xsa}
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller/eink_controller.xsa}
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller/eink_controller.xsa}
domain active {zynq_fsbl}
bsp reload
bsp reload
catch {bsp regenerate}
domain active {standalone_domain}
bsp reload
catch {bsp regenerate}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller/eink_controller.xsa}
platform generate
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_v1.0.xsa}
platform generate
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_v1.0.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
bsp reload
catch {bsp regenerate}
domain active {zynq_fsbl}
bsp reload
catch {bsp regenerate}
platform generate -domains standalone_domain,zynq_fsbl 
platform active {ps_system}
bsp reload
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains standalone_domain 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains standalone_domain 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate -domains 
domain active {standalone_domain}
bsp reload
catch {bsp regenerate}
bsp reload
platform generate -domains standalone_domain 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller.xsa}
platform generate
platform active {ps_system}
bsp reload
bsp reload
platform generate
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ebaz4205.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ebaz4205.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ebaz4205.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ebaz4205.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed108.xsa}
platform generate -domains 
platform generate
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed017.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed017.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed017.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed017.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ebaz4205.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed052tc4.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed052tc4.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed052tc4.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed052tc4.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc_img_demo.xsa}
platform generate
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc_img_demo.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc_img_demo.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed052tc4.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed052tc4.xsa}
platform generate
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed052tc4.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1.xsa}
platform generate
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et047tc1_img_demo.xsa}
platform generate
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_ed052tc4_img_demo.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et047tc1_img_demo.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073tc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et047tc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et047tc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073tc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073tc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073tc1_img_demo.xsa}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073tc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073tc1_img_demo.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073tc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073tc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et073tc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_es108fc1_img_demo.xsa}
platform generate -domains 
platform active {ps_system}
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et068sc1_img_demo.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/Admin/Desktop/Zynq7010_eink_controller/controller/Eink_controller_V1.0/eink_controller_et068sc1_img_demo.xsa}
platform generate -domains 
