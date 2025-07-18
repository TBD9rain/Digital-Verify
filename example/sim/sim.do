# 0. VARIABLE DEFINITIONS

# when sim_time == 0, run all
set sim_time        1000

# diamond pmi source library
# set pmi_lib         D:/lscc/diamond/3.11_x64/cae_library/simulation/verilog/pmi
# radiant pmi source library
# set pmi_lib         D:/lscc/radiant/3.2/ip/pmi

set tb_module       adder_tb
set wave_do         wave.do

# 1. QUIT SIMULATION & CLEAR COMMAND LINES
quit -sim
# .main clear

# 2. CREATE A DIRECTORY TO SAVE MODELSIM DATA FILES
if {[file exists work]} {
    file delete -force work
}
vlib work

# 3. MAP LOGIC LIBRARY
vmap work ./work

# 4. COMPILE CODES

# add "+libext+.v -y $pmi_lib" to compile original pmi source files

# add "+incdir+<directory>" to specify directories to search "`include" files
# add "+define+<marco_name>[=<macro_text>] to define or override a macro

vlog -sv +cover=bcefst -work work -f file_list.txt

# 5. Optimize designs
# FOR QUESTASIM ONLY
# SKIP THIS STEP IN MODELSIM
if {$sim_time <= 0} {
    vopt -64 -O4 $tb_module -o opt_tb
} else {
    vopt -64 -O4 +acc $tb_module -o opt_tb
}

# 6. SIMULATION

# replace "opt_tb" with "work.$tb_module" in ModelSim

# add "-L <device_lib>" for post simulation and timing simulation
# add "-sdftyp <sdf_file>" for timing simulation
# add "+transport_int_delays" and "+transport_path_delays" for timing simulation
# add "+typdelays" or "+maxdelays" or "+mindelays" for timing simulation

# add "-g<param_name>=<param_value>" to assign a value to a parameter without explicit value
# add "-G<param_name>=<param_value>" to assign or override a parameter 

vsim -lib work \
    -coverage \
    opt_tb \
    -t 1ps -l sim.log

# 7 RUN
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

