onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib ps_system_opt

do {wave.do}

view wave
view structure
view signals

do {ps_system.udo}

run -all

quit -force
