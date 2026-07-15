//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : video_tb
//  Version : 1.2.0
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

parameter PIXEL_PER_CLOCK = 1;


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
    .DATA_WIDTH      (DATA_WIDTH),
    .PIXEL_PER_CLOCK (PIXEL_PER_CLOCK)
) video_if (
    .clk    (clk),
    .rst_n  (rst_n));

VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;


//===================
//  DUT INSTANTIATION
//===================

video_test #(
    .DATA_WIDTH      (DATA_WIDTH),
    .PIXEL_PER_CLOCK (PIXEL_PER_CLOCK))
u_dut (
    .clk        (clk),
    .rst_n      (rst_n),

    .vin_vsync  (video_if.vin_vsync),
    .vin_hsync  (video_if.vin_hsync),
    .vin_de     (video_if.vin_de),
    .vin_pix    (video_if.vin_pix),

    .vout_vsync (video_if.vout_vsync),
    .vout_hsync (video_if.vout_hsync),
    .vout_de    (video_if.vout_de),
    .vout_pix   (video_if.vout_pix));


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

    video_cfg = VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("video_cfg");
    video_cfg.vif = video_if;
    video_cfg.pixel_per_clock = PIXEL_PER_CLOCK;
    uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(
        null, "uvm_test_top", "video_cfg", video_cfg);

    run_test("VideoBaseTest");
end

endmodule
