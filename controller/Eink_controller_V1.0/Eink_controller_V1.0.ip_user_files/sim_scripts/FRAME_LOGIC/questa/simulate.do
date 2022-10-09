onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib FRAME_LOGIC_opt

do {wave.do}

view wave
view structure
view signals

do {FRAME_LOGIC.udo}

run -all

quit -force
