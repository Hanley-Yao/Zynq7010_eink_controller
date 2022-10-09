onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib EPD_LOGIC_opt

do {wave.do}

view wave
view structure
view signals

do {EPD_LOGIC.udo}

run -all

quit -force
