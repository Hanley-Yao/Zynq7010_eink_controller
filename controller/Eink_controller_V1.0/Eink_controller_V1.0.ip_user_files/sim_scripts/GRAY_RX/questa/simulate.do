onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib GRAY_RX_opt

do {wave.do}

view wave
view structure
view signals

do {GRAY_RX.udo}

run -all

quit -force
