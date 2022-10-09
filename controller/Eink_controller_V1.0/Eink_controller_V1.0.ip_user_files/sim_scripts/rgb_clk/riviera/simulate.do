onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+rgb_clk -L xilinx_vip -L xpm -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.rgb_clk xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {rgb_clk.udo}

run -all

endsim

quit -force
