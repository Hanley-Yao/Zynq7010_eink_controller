onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib rgb_clk_opt

do {wave.do}

view wave
view structure
view signals

do {rgb_clk.udo}

run -all

quit -force
