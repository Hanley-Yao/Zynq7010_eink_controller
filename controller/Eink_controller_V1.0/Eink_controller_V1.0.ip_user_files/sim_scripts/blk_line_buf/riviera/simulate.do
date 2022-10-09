onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+blk_line_buf -L xilinx_vip -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.blk_line_buf xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {blk_line_buf.udo}

run -all

endsim

quit -force
