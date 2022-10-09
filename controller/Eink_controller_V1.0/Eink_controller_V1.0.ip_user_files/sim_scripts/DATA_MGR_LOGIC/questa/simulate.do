onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib DATA_MGR_LOGIC_opt

do {wave.do}

view wave
view structure
view signals

do {DATA_MGR_LOGIC.udo}

run -all

quit -force
