onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib ALGO_LOGIC_opt

do {wave.do}

view wave
view structure
view signals

do {ALGO_LOGIC.udo}

run -all

quit -force
