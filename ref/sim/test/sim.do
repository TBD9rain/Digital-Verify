# 0. VARIABLE DEFINITIONS
# diamond pmi source library
set pmi_lib         D:/lscc/diamond/3.11_x64/cae_library/simulation/verilog/pmi
# radiant pmi source library
# set pmi_lib         D:/lscc/radiant/3.2/ip/pmi

set tb_module       test_tb
set wave_do         wave.do

# when sim_time == 0, run all
set sim_time        1000

# 1. QUIT SIMULATION
quit -sim

# 2. CLEAR COMMAND LINES
# .main clear

# 3. CREATE A DIRECOTRY TO SAVE MODELSIM DATA FILES
if {[file exists work]} {
    file delete -force work
}
vlib work

# 4. MAP LOGIC LIBRARY
vmap work ./work

# 5. COMPILE CODES
# use "+libext+.v -y $pmi_lib" to compile original pmi source files
# vlog -work work -f file_list.txt

vlog -sv -work work ../tb_sv/test_tb.sv

# 6. SIMULATION
# 6a. START FUNCTIONAL SIMULATION
vsim -lib work -L pmi_work \
    "work.$tb_module" \
    -t 1ps -l sim.log

# 6b. START GATE-LEVEL SIMULATION
# vsim -lib work -L pmi_work -L <Device Library> \
#     "work.$tb_module" \
#     -t 1ps -l sim.log

# 6c. START GATE-LEVEL + TIMING SIMULATION
# vsim -lib work -L pmi_work -L <Device Library> \
#     "work.$tb_module" \
#     -sdftyp /$tb_module/u0_dut=<SDF FILE PATH> \
#     +transport_int_delays +transport_path_delays \
#     -t 1ps -l sim.log

# 7 SIMULATION
set UserTimeUnit ns
if {$sim_time <= 0} {
    run -all
} else {
    # ADD WAVEFORM
    if {[file exists $wave_do]} {
        do $wave_do
    } else {
        add wave "${tb_module}/*"
    }

    # RUN sim_time
    run $sim_time

    # SET STEP RUN LENGTH
    set RunLength 1000

    # WAVE WINDOW DISPLAY ADJUSTMENT
    wave zoom full
    configure wave -timelineunits ns
}


