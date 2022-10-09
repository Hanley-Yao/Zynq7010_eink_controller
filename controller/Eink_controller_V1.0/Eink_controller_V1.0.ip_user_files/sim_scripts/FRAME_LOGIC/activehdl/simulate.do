onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+FRAME_LOGIC -L xilinx_vip -L xpm -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.FRAME_LOGIC xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {FRAME_LOGIC.udo}

run -all

endsim

quit -force
