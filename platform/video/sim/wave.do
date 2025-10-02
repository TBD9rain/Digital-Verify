onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /video_tb/u_dut/clk
add wave -noupdate /video_tb/u_dut/rst_n
add wave -noupdate /video_tb/u_dut/vin_vsync
add wave -noupdate /video_tb/u_dut/vin_hsync
add wave -noupdate /video_tb/u_dut/vin_de
add wave -noupdate /video_tb/u_dut/vin_data
add wave -noupdate /video_tb/u_dut/vout_vsync
add wave -noupdate /video_tb/u_dut/vout_hsync
add wave -noupdate /video_tb/u_dut/vout_de
add wave -noupdate /video_tb/u_dut/vout_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1050 ns}
