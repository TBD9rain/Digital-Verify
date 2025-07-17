//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.2
//  Title           :   adder_8bit_tb
//
//  Description     :   top testbench
//
//  Additional info :
//  Author          :   shi_l
//  Email           :
//
//==================================================================================================

`timescale 1ns/100ps

module  adder_8bit_tb;

//======================
//  PARAMETER DEFINITION
//======================

parameter   CLK_HALF_PERIOD = 10/2;


//=====================
//  PACKAGE IMPORTATION
//=====================

import msg_print_pkg::*;
import test_pkg::*;


//=====================
//  VARIABLE DEFINITION
//=====================

bit         clk;
bit         rst_n;

//  test environment class
TestEnv     tb_env;


//=========================
//  INTERFACE INSTANTIATION
//=========================

test_if tb_if();


//===================
//  DUT INSTANTIATION
//===================

adder_8bit
u_dut(
    .clk    (tb_if.clk),
    .rst_n  (tb_if.rst_n),

    .data_in_vld    (tb_if.data_in_vld),
    .data_in0       (tb_if.addend0),
    .data_in1       (tb_if.addend1),

    .data_out_vld   (tb_if.data_out_vld),
    .data_out       (tb_if.sum));


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

//  verification testcases
initial begin
    rst_n = 1'b0;
    #1000;
    rst_n = 1'b1;

    #5000;
    print_msg("Testbench", "add random testcases...", INFO, HIGHEST, LOG);
    tb_env.add_random_tc(10000);
    $write("\n");

    #55;
    rst_n = 1'b0;
    #100;
    rst_n = 1'b1;

    @tb_env.tc_done;
    #1000;
    print_msg("Testbench", "verification ends.\n", INFO, HIGHEST, LOG);
    $stop(2);
end


endmodule


