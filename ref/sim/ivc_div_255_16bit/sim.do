# 0. VARIABLE DEFINITIONS
# diamond pmi source library
set pmi_lib         D:/lscc/diamond/3.11_x64/cae_library/simulation/verilog/pmi
# radiant pmi source library
# set pmi_lib         D:/lscc/radiant/3.2/ip/pmi

set tb_module       ivc_div_255_16bit_tb
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
vlog -sv -work work -f file_list.txt \
    +libext+.v -y $pmi_lib

# 6. DESIGN OPTIMIZATION (QusetaSim)
# add "+acc" to preserve visibility of all objects
vopt -O4 +acc "work.$tb_module" -o opt_tb

# 7. INIT SIMULATION
# REPLACE "work.$tb_module" with opt_tb in QuestaSim
# add "-L pmi_wrok" to use pre-complied PMI components
# add "-L <Device Library>" to use pre-complied device components
#   for gate-level simulation
# add "-L <Device Library>
#   -sdftype /$tb_module/u_dut=<SDF FILE PATH>
#   -transport_int_delays +transport_path_delay"
#   for gate-level timing simulation
vsim -lib work \
    opt_tb \
    -t 1ps -l sim.log

# 8 RUN SIMULATION
set UserTimeUnit ns
if {$sim_time <= 0} {
    run -all
} else {
    # ADD WAVEFORM
    if {[file exists $wave_do]} {
        do $wave_do
    }

    # RUN sim_time
    run $sim_time

    # SET STEP RUN LENGTH
    set RunLength 1000

    # WAVE WINDOW DISPLAY ADJUSTMENT
    wave zoom full
    configure wave -timelineunits ns
}

