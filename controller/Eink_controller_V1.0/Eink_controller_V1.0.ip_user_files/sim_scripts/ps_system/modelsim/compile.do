vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/processing_system7_vip_v1_0_10
vlib modelsim_lib/msim/xil_defaultlib

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap processing_system7_vip_v1_0_10 modelsim_lib/msim/processing_system7_vip_v1_0_10
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xilinx_vip  -incr -sv -L axi_vip_v1_1_8 -L processing_system7_vip_v1_0_10 -L xilinx_vip "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work processing_system7_vip_v1_0_10  -incr -sv -L axi_vip_v1_1_8 -L processing_system7_vip_v1_0_10 -L xilinx_vip "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/ps_system/ip/ps_system_processing_system7_0_0/sim/ps_system_processing_system7_0_0.v" \
"../../../bd/ps_system/ip/ps_system_xbar_0/sim/ps_system_xbar_0.v" \
"../../../bd/ps_system/ip/ps_system_s00_regslice_0/sim/ps_system_s00_regslice_0.v" \
"../../../bd/ps_system/ip/ps_system_s00_data_fifo_0/sim/ps_system_s00_data_fifo_0.v" \
"../../../bd/ps_system/ip/ps_system_auto_cc_0/sim/ps_system_auto_cc_0.v" \
"../../../bd/ps_system/ip/ps_system_s01_regslice_0/sim/ps_system_s01_regslice_0.v" \
"../../../bd/ps_system/ip/ps_system_s01_data_fifo_0/sim/ps_system_s01_data_fifo_0.v" \
"../../../bd/ps_system/ip/ps_system_auto_cc_1/sim/ps_system_auto_cc_1.v" \
"../../../bd/ps_system/ip/ps_system_s02_regslice_0/sim/ps_system_s02_regslice_0.v" \
"../../../bd/ps_system/ip/ps_system_s02_data_fifo_0/sim/ps_system_s02_data_fifo_0.v" \
"../../../bd/ps_system/ip/ps_system_auto_cc_2/sim/ps_system_auto_cc_2.v" \
"../../../bd/ps_system/ip/ps_system_m00_data_fifo_0/sim/ps_system_m00_data_fifo_0.v" \
"../../../bd/ps_system/ip/ps_system_m00_regslice_0/sim/ps_system_m00_regslice_0.v" \
"../../../bd/ps_system/ip/ps_system_auto_pc_0/sim/ps_system_auto_pc_0.v" \
"../../../bd/ps_system/ipshared/4d18/uiFDMA.v" \
"../../../bd/ps_system/ip/ps_system_uiFDMA_0_0/sim/ps_system_uiFDMA_0_0.v" \
"../../../bd/ps_system/ip/ps_system_uiFDMA_0_1/sim/ps_system_uiFDMA_0_1.v" \
"../../../bd/ps_system/ip/ps_system_uiFDMA_0_2/sim/ps_system_uiFDMA_0_2.v" \
"../../../bd/ps_system/ip/ps_system_util_vector_logic_0_0/sim/ps_system_util_vector_logic_0_0.v" \
"../../../bd/ps_system/sim/ps_system.v" \

vlog -work xil_defaultlib \
"glbl.v"

