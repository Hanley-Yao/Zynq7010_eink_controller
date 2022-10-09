open_project video_scaler
set_top video_scaler
add_files video_scaler.cpp
add_files video_scaler.h
add_files -tb test/fox.bmp
add_files -tb video_scaler_test.cpp 
open_solution "solution1"
set_part {xc7z020clg484-1} -tool vivado
create_clock -period 6.67 -name default
#source "directives.tcl"
#csim_design -clean
csynth_design
#cosim_design
export_design -rtl verilog -format ip_catalog -description "Video Scaler" -vendor "digilentinc.com" -library "video" -display_name "Video Scaler"
exit
