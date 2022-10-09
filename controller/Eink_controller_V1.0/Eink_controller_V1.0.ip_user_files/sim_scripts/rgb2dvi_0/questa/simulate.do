onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib rgb2dvi_0_opt

do {wave.do}

view wave
view structure
view signals

do {rgb2dvi_0.udo}

run -all

quit -force
