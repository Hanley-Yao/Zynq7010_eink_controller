onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+GRAY_RX -L xilinx_vip -L xpm -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.GRAY_RX xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {GRAY_RX.udo}

run -all

endsim

quit -force
