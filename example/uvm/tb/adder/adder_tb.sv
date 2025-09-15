//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   adder_tb
//
//  Description     :   testbench definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

`timescale 1ns/100ps

module adder_tb;

//======================
//  PARAMETER DEFINITION
//======================

parameter   CLK_HALF_PERIOD     = 10/2;


//=====================
//  PACKAGE IMPORTATION
//=====================

`include "uvm_macros.svh"
import uvm_pkg::*;

import adder_pkg::*;


//=====================
//  VARIABLE DEFINITION
//=====================

bit clk;
bit rst_n;

adder_if #(
    .DATA_WIDTH (8))
tb_if(
    .clk    (clk),
    .rst_n  (rst_n));


//===================
//  DUT INSTANTIATION
//===================

adder #(
    .DATA_WIDTH (8))
u_dut(
    .clk    (tb_if.clk),
    .rst_n  (tb_if.rst_n),

    .data_in_vld    (tb_if.data_in_vld),
    .data_in0       (tb_if.addend0),
    .data_in1       (tb_if.addend1),

    .data_out_vld   (tb_if.data_out_vld),
    .data_out       (tb_if.sum));


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

initial begin
    rst_n = 1'b0;
    #1000;
    rst_n = 1'b1;
end

initial begin
    $write("*****************************\n");
    $write("Running UVM version:\t %s\n", `UVM_VERSION_STRING);
    $write("*****************************\n\n");
end

initial begin
    //  turn off QuestaSim UVM transaction recording
    uvm_config_db#(int)::set(null, "", "recording_detail", 0);
    uvm_config_db#(uvm_bitstream_t)::set(null, "", "recording_detail", 0);

    uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.env.i_agt.drv", "vif", tb_if);
    uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.env.i_agt.mon", "vif", tb_if);
    uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.env.o_agt.mon", "vif", tb_if);
end

initial begin
    run_test("BaseTest");
    $stop(2);
end


endmodule


