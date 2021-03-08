onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_maxAccelerator/clk
add wave -noupdate /tb_maxAccelerator/reset
add wave -noupdate /tb_maxAccelerator/dataValid
add wave -noupdate -radix unsigned /tb_maxAccelerator/DUT/count
add wave -noupdate -radix decimal /tb_maxAccelerator/dataIn
add wave -noupdate -radix decimal /tb_maxAccelerator/dataOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {84 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {291 ps} {417 ps}
