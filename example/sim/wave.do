onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adder_8bit_tb/u_dut/clk
add wave -noupdate /adder_8bit_tb/u_dut/rst_n
add wave -noupdate /adder_8bit_tb/u_dut/data_in_vld
add wave -noupdate /adder_8bit_tb/u_dut/data_in0
add wave -noupdate /adder_8bit_tb/u_dut/data_in1
add wave -noupdate /adder_8bit_tb/u_dut/data_out_vld
add wave -noupdate /adder_8bit_tb/u_dut/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
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
configure wave -timelineunits ns
update
WaveRestoreZoom {65456662500 ps} {65457712500 ps}
