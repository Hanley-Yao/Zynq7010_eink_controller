onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib clock_pll_et017qc4_opt

do {wave.do}

view wave
view structure
view signals

do {clock_pll_et017qc4.udo}

run -all

quit -force
