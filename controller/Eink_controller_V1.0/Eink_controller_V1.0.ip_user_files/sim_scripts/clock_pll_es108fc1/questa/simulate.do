onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib clock_pll_es108fc1_opt

do {wave.do}

view wave
view structure
view signals

do {clock_pll_es108fc1.udo}

run -all

quit -force
