//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : video_tb
//  Version : 1.1.2
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

`timescale 1ns/100ps

module video_tb;

//======================
//  PARAMETER DEFINITION
//======================

parameter   CLK_HALF_PERIOD     = 10/2;

parameter DATA_WIDTH = 8;


//=====================
//  PACKAGE IMPORTATION
//=====================

`include "uvm_macros.svh"
import uvm_pkg::*;

import video_pkg::*;


//=====================
//  VARIABLE DEFINITION
//=====================

bit clk;
bit rst_n;

video_if #(
    .DATA_WIDTH (DATA_WIDTH)
) video_if (
    .clk    (clk),
    .rst_n  (rst_n));

typedef virtual video_if #(DATA_WIDTH).drv_mp drv_vif;
typedef virtual video_if #(DATA_WIDTH).mon_mp mon_vif;


//===================
//  DUT INSTANTIATION
//===================

video_test #(
    .DATA_WIDTH (8))
u_dut (
    .clk        (clk),
    .rst_n      (rst_n),

    .vin_vsync  (video_if.vin_vsync),
    .vin_hsync  (video_if.vin_hsync),
    .vin_de     (video_if.vin_de),
    .vin_data   (video_if.vin_data),

    .vout_vsync (video_if.vout_vsync),
    .vout_hsync (video_if.vout_hsync),
    .vout_de    (video_if.vout_de),
    .vout_data  (video_if.vout_data));


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
    $write("\n*****************************\n");
    $write("Running UVM version: %s\n", `UVM_VERSION_STRING);
    $write("*****************************\n\n");
end

initial begin
    //  turn off QuestaSim UVM transaction recording
    uvm_config_db #(int)::set(null, "", "recording_detail", 0);
    uvm_config_db #(uvm_bitstream_t)::set(null, "", "recording_detail", 0);

    uvm_config_db #(drv_vif)::set(null, "uvm_test_top.data_env.i_agt.drv", "vif", video_if);
    uvm_config_db #(mon_vif)::set(null, "uvm_test_top.data_env.i_agt.mon", "vif", video_if);
    uvm_config_db #(mon_vif)::set(null, "uvm_test_top.data_env.o_agt.mon", "vif", video_if);
    uvm_config_db #(mon_vif)::set(null, "uvm_test_top.format_env.o_agt.mon", "vif", video_if);
end

initial begin
    run_test("VideoBaseTest");
end

endmodule

