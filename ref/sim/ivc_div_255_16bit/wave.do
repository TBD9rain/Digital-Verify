onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ivc_div_255_16bit_tb/ifc_ini/clk
add wave -noupdate /ivc_div_255_16bit_tb/ifc_ini/rst_n
add wave -noupdate /ivc_div_255_16bit_tb/ifc_ini/cb_dut/cb_dut_event
add wave -noupdate /ivc_div_255_16bit_tb/ifc_ini/cb_dut/data_in_vld
add wave -noupdate -radix unsigned /ivc_div_255_16bit_tb/ifc_ini/cb_dut/dividend_in
add wave -noupdate /ivc_div_255_16bit_tb/ifc_rsp/cb_rsp/cb_rsp_event
add wave -noupdate /ivc_div_255_16bit_tb/ifc_rsp/cb_rsp/data_out_vld
add wave -noupdate -radix unsigned /ivc_div_255_16bit_tb/ifc_rsp/cb_rsp/quotient_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {108627 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 138
configure wave -valuecolwidth 65
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
WaveRestoreZoom {20438 ps} {325687 ps}
