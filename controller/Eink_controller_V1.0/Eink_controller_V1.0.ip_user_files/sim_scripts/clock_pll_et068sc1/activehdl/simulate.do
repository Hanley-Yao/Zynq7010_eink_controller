onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+clock_pll_et068sc1 -L xilinx_vip -L xpm -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.clock_pll_et068sc1 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {clock_pll_et068sc1.udo}

run -all

endsim

quit -force
