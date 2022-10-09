onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib clock_pll_et047tc1_opt

do {wave.do}

view wave
view structure
view signals

do {clock_pll_et047tc1.udo}

run -all

quit -force
