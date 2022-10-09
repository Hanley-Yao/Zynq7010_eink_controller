onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+blk_mem_gen_rgb -L xilinx_vip -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.blk_mem_gen_rgb xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {blk_mem_gen_rgb.udo}

run -all

endsim

quit -force
