//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.2
//  Title           :   adder_8bit_tb
//
//  Description     :   top testbench
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

`timescale 1ns/100ps

module  adder_tb;

//======================
//  PARAMETER DEFINITION
//======================

//  DUT
parameter   DATA_WIDTH  = 8;

//  verification
parameter   CLK_HALF_PERIOD     = 10/2;
parameter   MAX_RAND_ITERATION  = 100;


//=====================
//  PACKAGE IMPORTATION
//=====================

import msg_print_pkg::*;

import adder_pkg::*;


//=====================
//  VARIABLE DEFINITION
//=====================

bit clk;
bit rst_n;

real    coverage_rate = 0;
int     num_bins_covered = 0;
int     num_bins_total = 0;

int i;


//=========================
//  INTERFACE INSTANTIATION
//=========================

adder_if #(
    .DATA_WIDTH (DATA_WIDTH))
tb_if();


//===================
//  DUT INSTANTIATION
//===================

adder #(
    .DATA_WIDTH (DATA_WIDTH))
u_dut(
    .clk    (tb_if.clk),
    .rst_n  (tb_if.rst_n),

    .data_in_vld    (tb_if.data_in_vld),
    .data_in0       (tb_if.addend0),
    .data_in1       (tb_if.addend1),

    .data_out_vld   (tb_if.data_out_vld),
    .data_out       (tb_if.sum));


//================================
//  TEST ENVIRONMENT INSTANTIATION
//================================

TestEnv #(
    .DATA_IN_WIDTH  (DATA_WIDTH),
    .DATA_OUT_WIDTH (DATA_WIDTH + 1))
tb_env;


//===========================
//  INTERFACE PORT CONNECTION
//===========================

assign  tb_if.clk   = clk;
assign  tb_if.rst_n = rst_n;


//=====================
//  VERIFICATION CODING
//=====================

//  clock generator
initial begin
    forever begin
        #(CLK_HALF_PERIOD);
        clk = ~clk;
    end
end

//  verification environment
initial begin
    svrt_thold = HIGH;
    clean_msg_log;

    print_msg("Testbench", "verification starts.\n", INFO, HIGHEST, LOG);

    print_msg("Testbench", "component initiating...", INFO, HIGHEST, LOG);
    tb_env      = new();
    tb_env.vif  = tb_if;
    $write("\n");

    print_msg("Testbench", "component connecting...", INFO, HIGHEST, LOG);
    tb_env.connect;
    $write("\n");

    print_msg("Testbench", "start components...", INFO, HIGHEST, LOG);
    tb_env.run;
    $write("\n");
end

//  verification stimulation
initial begin
    rst_n = 1'b0;
    #1000;
    rst_n = 1'b1;

    #5000;
    print_msg("Testbench", "add random testcases...", INFO, HIGHEST, LOG);
    tb_env.add_random_tc(10);
    $write("\n");

    #55;
    rst_n = 1'b0;
    #100;
    rst_n = 1'b1;

    @tb_env.tc_done;
    #1000;

    i = 0;
    while (coverage_rate < 99.99 && i < MAX_RAND_ITERATION) begin
        print_msg("Testbench", "add random testcases...", INFO, HIGHEST, LOG);
        tb_env.add_random_tc(100);
        $write("\n");

        @tb_env.tc_done;
        #1000;

        coverage_rate = tb_env.get_coverage(num_bins_covered, num_bins_total);
        print_msg("Testbench", $sformatf({
            "Iteration NO.%0d, DUT input coverage:\n",
            "\tcoverage rate: %0.4f\%\n",
            "\tbins covered : %0d\n",
            "\tbins total   : %0d\n"
            }, i, coverage_rate, num_bins_covered, num_bins_total), INFO, HIGH, LOG);
        if (coverage_rate == 100) begin
            print_msg("Testbench", "coverage rate: 100.0%.\n", INFO, HIGHEST, LOG);
            break;
        end
        i++;
        if (i >= MAX_RAND_ITERATION) begin
            print_msg("Testbench", "reached maximum of random testcase iteration.\n", INFO, HIGHEST, LOG);
        end
    end
    print_msg("Testbench", "verification ends.\n", INFO, HIGHEST, LOG);
    $stop(2);
end


endmodule


