onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib clock_pll_ed097tc2_opt

do {wave.do}

view wave
view structure
view signals

do {clock_pll_ed097tc2.udo}

run -all

quit -force
