SHELL := cmd
.SHELLFLAGS := /C

#=============================================
#   QuestaSim 2026.2 UVM Simulation Makefile
#=============================================

#----------
# Variables
#----------

UVM_TEST ?= VideoBaseTest
RANDSEED ?= 0
DEBUG ?= 0
COV_EN ?= 1
ON_STOP ?= stop

SIM_TIME ?= 0
VOPT_EXTRA_ARGS ?=
VSIM_EXTRA_ARGS ?=

QUESTA_HOME ?= D:/questasim64_2026.2
UVM_LIB_DIR := $(QUESTA_HOME)/uvm-1.2
UVM_SRC_DIR := $(QUESTA_HOME)/verilog_src/uvm-1.2/src
UVM_DPI_LIB := $(UVM_LIB_DIR)/win64/uvm_dpi

TB_MODULE := video_tb
SRC_FILELIST := src_filelist.txt
TB_FILELIST := tb_file_list.txt
SIM_LOG := sim.log


#-------------
# Make Targets
#-------------

.PHONY: help all init compile optimize run run-all run-time reload-do cov-merge cov-report visualizer clean

help:
	@echo Targets:
	@echo   make all        - init + compile + run-all
	@echo   make init       - initialize simulation environment
	@echo   make compile    - compile RTL and TB files
	@echo   make optimize   - optimize compiled design
	@echo   make run-all    - load design and run to end of simulation
	@echo   make run-time   - load design and run for SIM_TIME
	@echo   make reload-do  - (auto-run by run-*) write reload.do for in-Visualizer iteration
	@echo                     use it from Visualizer Tcl: do reload.do
	@echo   make cov-merge  - merge coverage DB into sum.ucdb
	@echo   make cov-report - generate HTML coverage report from sum.ucdb
	@echo   make visualizer - launch Visualizer to inspect qwave.db
	@echo.
	@echo   make clean    - remove generated simulation data
	@echo.
	@echo Overridable vars:
	@echo   UVM_TEST=^<name^> - default: VideoBaseTest, designate test to run
	@echo   RANDSEED=^<int^> - default: 0, assign randomization seed
	@echo   SIM_TIME=^<time^> - default: 0, assign time to run for run-time
	@echo   DEBUG=^<0^|1^|2^> - default: 0
	@echo                	- 0: batch sim (vsim -c)
	@echo                	- 1: enable data recording and post viewing
	@echo                	- 2: enable live simulation
	@echo   COV_EN=^<0^|1^>  - default: 1
	@echo                	- 0: disable code ^& functional coverage collection
	@echo                	- 1: enable code ^& functional coverage collection
	@echo   ON_STOP=^<stop^|exit^> - default: stop, stop/exit when $finish
	@echo   VOPT_EXTRA_ARGS=^<args^> - default: empty, append extra vopt options,
	@echo                			 - example: -G^<PARAM_NAME^>=^<PARAM_VALUE^>
	@echo   VSIM_EXTRA_ARGS=^<args^> - default: empty, append extra vsim options


#--------------
# Make Commands
#--------------

all: init compile optimize run-all

init:
	@echo [Make Command: init] Initialize simulation environment
	@if exist work rmdir /S /Q work
	@vlib work
	@vmap -suppress 223 uvm-1.2 "$(UVM_LIB_DIR)"
	@vmap -suppress 223 work ./work

ifeq ($(COV_EN),1)
VLOG_COVER_ARGS := +cover=bcefst
else
VLOG_COVER_ARGS :=
endif

ifeq ($(DEBUG),2)
VOPT_DEBUG_ARGS := -designfile design.bin -debug,livesim
else ifeq ($(DEBUG),1)
VOPT_DEBUG_ARGS := -debug
else
VOPT_DEBUG_ARGS :=
endif

compile:
	@echo [Make Command: compile] Compile RTL and TB files
	@vlog -work work -suppress 223 $(VLOG_COVER_ARGS) -f "$(SRC_FILELIST)"
	@vlog -work work -suppress 223 -sv -sv17compat +incdir+"$(UVM_SRC_DIR)" -L uvm-1.2 -f "$(TB_FILELIST)"

optimize:
	@echo [Make Command: optimize] Optimize compiled design
	@vopt -64 -O4 -suppress 223,2240,53 $(VOPT_DEBUG_ARGS) $(VOPT_EXTRA_ARGS) -L uvm-1.2 "$(TB_MODULE)" -o opt_tb

run: run-time

ifeq ($(DEBUG),2)
VSIM_DEBUG_ARGS := -visualizer -qwavedb=+livesim -classdebug
else ifeq ($(DEBUG),1)
VSIM_DEBUG_ARGS := -c -qwavedb=+signal
else
VSIM_DEBUG_ARGS := -c
endif

ifeq ($(COV_EN),1)
VSIM_COVER_ARGS := -coverage -coverstore cov_db
else
VSIM_COVER_ARGS :=
endif

VSIM_BASE_ARGS := $(VSIM_DEBUG_ARGS) \
	-lib work -L uvm-1.2 -sv_lib "$(UVM_DPI_LIB)" \
	$(VSIM_COVER_ARGS) \
	+UVM_TESTNAME=$(UVM_TEST) \
	-uvmtestname \
	-sv_seed "$(RANDSEED)" \
	-onfinish "$(ON_STOP)" \
	$(VSIM_EXTRA_ARGS) \
	-suppress 223 \
	opt_tb \
	-t 1ps -l "$(SIM_LOG)"

# vsim args used inside an already-open Visualizer: drop -c/-visualizer so
# the command reloads the current Visualizer kernel instead of spawning a new
# Visualizer process.
RELOAD_VSIM_ARGS := $(filter-out -c -visualizer,$(VSIM_BASE_ARGS))

ifeq ($(DEBUG),2)
RUN_ALL_DO := set UserTimeUnit ns; \
	if {[file exists wave.do]} {do wave.do}; \
	run -all; \
	simstats;
else
RUN_ALL_DO := set UserTimeUnit ns; \
	run -all; \
	simstats;
endif

run-all: reload-do
	@echo [Make Command: run-all] Load design and run to end of simulation
	@vsim $(VSIM_BASE_ARGS) \
		-do "$(RUN_ALL_DO)"

ifeq ($(DEBUG),2)
RUN_TIME_DO := set UserTimeUnit ns; \
	if {[file exists wave.do]} {do wave.do}; \
	set RunLength 1000; \
	run $(SIM_TIME);
else
RUN_TIME_DO := set UserTimeUnit ns; \
	set RunLength 1000; \
	run $(SIM_TIME);
endif

run-time: reload-do
	@echo [Make Command: run-time] Load design and run for SIM_TIME=$(SIM_TIME)
	@vsim $(VSIM_BASE_ARGS) \
		-do "$(RUN_TIME_DO)"

reload-do:
	@echo [Make Command: reload-do] Generate reload.do for in-Visualizer iteration
	@(echo # Auto-generated by Makefile. In Visualizer Tcl console, type: do reload.do) > reload.do
	@(echo # It quits the current sim, recompiles, reloads design, and re-runs --) >> reload.do
	@(echo # all inside the current Visualizer process.) >> reload.do
	@(echo quit -sim) >> reload.do
	@(echo vlog -work work -suppress 223 $(VLOG_COVER_ARGS) -f "$(SRC_FILELIST)") >> reload.do
	@(echo vlog -work work -suppress 223 -sv -sv17compat +incdir+"$(UVM_SRC_DIR)" -L uvm-1.2 -f "$(TB_FILELIST)") >> reload.do
	@(echo vopt -64 -O4 -suppress 223,2240,53 $(VOPT_DEBUG_ARGS) $(VOPT_EXTRA_ARGS) -L uvm-1.2 "$(TB_MODULE)" -o opt_tb) >> reload.do
	@(echo vsim $(RELOAD_VSIM_ARGS) -do {$(RUN_TIME_DO)}) >> reload.do

cov-merge:
	@echo [Make Command: cov-merge] Merge coverage DB
	@vcover merge -out sum.ucdb cov_db

VISUALIZER_DO := if {[file exists wave.do]} {do wave.do};

ifneq ($(wildcard sum.ucdb),)
VISUALIZER_COV_ARGS := -viewcov sum.ucdb
else
VISUALIZER_COV_ARGS :=
endif

visualizer:
	@echo [Make Command: visualizer] Launch Visualizer to inspect qwave.db
	@start "" visualizer -designfile design.bin -wavefile qwave.db $(VISUALIZER_COV_ARGS) -do "$(VISUALIZER_DO)"
	@echo Visualizer will be launched in a new window, please wait for it to load...

cov-report: cov-merge
	@echo [Make Command: cov-report] Generate HTML coverage report
	@vcover report -details -html -output cov_rpt_html sum.ucdb

CLEAN_DIRS := work .visualizer cov_rpt_html
CLEAN_FILES := modelsim.ini design.bin $(SIM_LOG) qwave.db reload.do \
	sum.ucdb transcript visualizer.log tr_db.log sysinfo.log

clean:
	@echo [Make Command: clean] Remove generated simulation outputs
	@echo   - remove directories
	@for %%d in ($(CLEAN_DIRS)) do @if exist "%%d" rmdir /S /Q "%%d"
	@echo   - remove files
	@for %%f in ($(CLEAN_FILES)) do @if exist "%%f" del /F /Q "%%f"
