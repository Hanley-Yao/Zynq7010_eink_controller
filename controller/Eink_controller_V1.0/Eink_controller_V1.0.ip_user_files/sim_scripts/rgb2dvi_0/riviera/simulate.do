onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+rgb2dvi_0 -L xilinx_vip -L xpm -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.rgb2dvi_0 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {rgb2dvi_0.udo}

run -all

endsim

quit -force
