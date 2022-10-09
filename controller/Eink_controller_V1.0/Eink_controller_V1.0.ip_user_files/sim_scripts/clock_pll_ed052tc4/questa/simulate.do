onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib clock_pll_ed052tc4_opt

do {wave.do}

view wave
view structure
view signals

do {clock_pll_ed052tc4.udo}

run -all

quit -force
