vlib work
vlib activehdl

vlib activehdl/xilinx_vip
vlib activehdl/xpm
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_vip_v1_1_8
vlib activehdl/processing_system7_vip_v1_0_10
vlib activehdl/xil_defaultlib
vlib activehdl/generic_baseblocks_v2_1_0
vlib activehdl/axi_register_slice_v2_1_22
vlib activehdl/fifo_generator_v13_2_5
vlib activehdl/axi_data_fifo_v2_1_21
vlib activehdl/axi_crossbar_v2_1_23
vlib activehdl/axi_clock_converter_v2_1_21
vlib activehdl/axi_protocol_converter_v2_1_22
vlib activehdl/util_vector_logic_v2_0_1

vmap xilinx_vip activehdl/xilinx_vip
vmap xpm activehdl/xpm
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_8 activehdl/axi_vip_v1_1_8
vmap processing_system7_vip_v1_0_10 activehdl/processing_system7_vip_v1_0_10
vmap xil_defaultlib activehdl/xil_defaultlib
vmap generic_baseblocks_v2_1_0 activehdl/generic_baseblocks_v2_1_0
vmap axi_register_slice_v2_1_22 activehdl/axi_register_slice_v2_1_22
vmap fifo_generator_v13_2_5 activehdl/fifo_generator_v13_2_5
vmap axi_data_fifo_v2_1_21 activehdl/axi_data_fifo_v2_1_21
vmap axi_crossbar_v2_1_23 activehdl/axi_crossbar_v2_1_23
vmap axi_clock_converter_v2_1_21 activehdl/axi_clock_converter_v2_1_21
vmap axi_protocol_converter_v2_1_22 activehdl/axi_protocol_converter_v2_1_22
vmap util_vector_logic_v2_0_1 activehdl/util_vector_logic_v2_0_1

vlog -work xilinx_vip  -sv2k12 "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_8  -sv2k12 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/94c3/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_10  -sv2k12 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/ps_system/ip/ps_system_processing_system7_0_0/sim/ps_system_processing_system7_0_0.v" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_22  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/af2c/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5 -93 \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_21  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/54c0/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_23  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/bc0a/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/ps_system/ip/ps_system_xbar_0/sim/ps_system_xbar_0.v" \
"../../../bd/ps_system/ip/ps_system_s00_regslice_0/sim/ps_system_s00_regslice_0.v" \
"../../../bd/ps_system/ip/ps_system_s00_data_fifo_0/sim/ps_system_s00_data_fifo_0.v" \

vlog -work axi_clock_converter_v2_1_21  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/1304/hdl/axi_clock_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/ps_system/ip/ps_system_auto_cc_0/sim/ps_system_auto_cc_0.v" \
"../../../bd/ps_system/ip/ps_system_s01_regslice_0/sim/ps_system_s01_regslice_0.v" \
"../../../bd/ps_system/ip/ps_system_s01_data_fifo_0/sim/ps_system_s01_data_fifo_0.v" \
"../../../bd/ps_system/ip/ps_system_auto_cc_1/sim/ps_system_auto_cc_1.v" \
"../../../bd/ps_system/ip/ps_system_s02_regslice_0/sim/ps_system_s02_regslice_0.v" \
"../../../bd/ps_system/ip/ps_system_s02_data_fifo_0/sim/ps_system_s02_data_fifo_0.v" \
"../../../bd/ps_system/ip/ps_system_auto_cc_2/sim/ps_system_auto_cc_2.v" \
"../../../bd/ps_system/ip/ps_system_m00_data_fifo_0/sim/ps_system_m00_data_fifo_0.v" \
"../../../bd/ps_system/ip/ps_system_m00_regslice_0/sim/ps_system_m00_regslice_0.v" \

vlog -work axi_protocol_converter_v2_1_22  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/5cee/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/ps_system/ip/ps_system_auto_pc_0/sim/ps_system_auto_pc_0.v" \
"../../../bd/ps_system/ipshared/4d18/uiFDMA.v" \
"../../../bd/ps_system/ip/ps_system_uiFDMA_0_0/sim/ps_system_uiFDMA_0_0.v" \
"../../../bd/ps_system/ip/ps_system_uiFDMA_0_1/sim/ps_system_uiFDMA_0_1.v" \
"../../../bd/ps_system/ip/ps_system_uiFDMA_0_2/sim/ps_system_uiFDMA_0_2.v" \

vlog -work util_vector_logic_v2_0_1  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/3f90/hdl/util_vector_logic_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/ec67/hdl" "+incdir+../../../../Eink_controller.gen/sources_1/bd/ps_system/ipshared/34f8/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/ps_system/ip/ps_system_util_vector_logic_0_0/sim/ps_system_util_vector_logic_0_0.v" \
"../../../bd/ps_system/sim/ps_system.v" \

vlog -work xil_defaultlib \
"glbl.v"

