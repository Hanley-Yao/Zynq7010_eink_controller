onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib blk_line_buf_opt

do {wave.do}

view wave
view structure
view signals

do {blk_line_buf.udo}

run -all

quit -force
