//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   preadd_multi_tb
//
//  Description     :   pre-add multiplier testbench
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

`timescale 1ns/100ps

module  preadd_multi_tb;

//======================
//  PARAMETER DEFINITION
//======================

parameter   DATA_WIDTH  = 8;

parameter   CLK_HALF_PERIOD     = 10/2;

parameter   MAX_RAND_ITERATION      = 10000;
parameter   TARGET_COVERAGE_RATE    = 100.00;


//=====================
//  PACKAGE IMPORTATION
//=====================

import msg_print_pkg::*;

import preadd_multi_pkg::*;


//=====================
//  VARIABLE DEFINITION
//=====================

bit clk;
bit rst_n;

real    coverage_rate;
int     num_bins_covered;
int     num_bins_total;

int i;


//=========================
//  INTERFACE INSTANTIATION
//=========================

preadd_multi_if #(.DATA_WIDTH (DATA_WIDTH)) tb_if();

adder_if #(.DATA_WIDTH (DATA_WIDTH)) sub_if();


//===================
//  DUT INSTANTIATION
//===================

preadd_multi #(
    .DATA_WIDTH (DATA_WIDTH))
u_dut(
    .clk    (tb_if.clk),
    .rst_n  (tb_if.rst_n),

    .data_in_vld    (tb_if.data_in_vld),
    .data_in_a0     (tb_if.data_in_a0),
    .data_in_a1     (tb_if.data_in_a1),
    .data_in_b0     (tb_if.data_in_b0),
    .data_in_b1     (tb_if.data_in_b1),

    .data_out_vld   (tb_if.data_out_vld),
    .data_out       (tb_if.data_out));


//================================
//  TEST ENVIRONMENT INSTANTIATION
//================================

TestEnv #(.DATA_WIDTH (DATA_WIDTH)) tb_env;

adder_pkg::TestEnv #(
    .DATA_IN_WIDTH (DATA_WIDTH),
    .DATA_OUT_WIDTH (DATA_WIDTH + 1))
    sub_env;


//===========================
//  INTERFACE PORT CONNECTION
//===========================

assign  tb_if.clk   = clk;
assign  tb_if.rst_n = rst_n;

assign  sub_if.clk          = clk;
assign  sub_if.rst_n        = rst_n;
assign  sub_if.data_in_vld  = u_dut.data_in_vld;
assign  sub_if.addend0      = u_dut.data_in_a0;
assign  sub_if.addend1      = u_dut.data_in_a1;
assign  sub_if.data_out_vld = u_dut.data_out_vld_a;
assign  sub_if.sum          = u_dut.data_out_a;


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
    sub_env     = new(0, 0);
    sub_env.vif = sub_if;
    $write("\n");

    print_msg("Testbench", "component connecting...", INFO, HIGHEST, LOG);
    tb_env.connect;
    sub_env.connect;
    $write("\n");

    print_msg("Testbench", "start components...", INFO, HIGHEST, LOG);
    tb_env.run;
    sub_env.run;
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

    @tb_env.tc_done;
    #1000;
    print_msg("Testbench", "verification ends.\n", INFO, HIGHEST, LOG);
    $stop(2);

    //  cover with random testcase
    i = 0;
    coverage_rate = 0;
    while (coverage_rate < TARGET_COVERAGE_RATE && i < MAX_RAND_ITERATION) begin
        print_msg("Testbench", "add random testcases...", INFO, HIGHEST, LOG);
        tb_env.add_random_tc(100);
        $write("\n");

        @tb_env.tc_done;
        #1000;

        coverage_rate = tb_env.get_coverage(num_bins_covered, num_bins_total);
        print_msg("Testbench", $sformatf({
            "Iteration NO.%0d, DUT input coverage:\n",
            "coverage rate: %0.4f\%\n",
            "bins covered : %0d\n",
            "bins total   : %0d\n"
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


