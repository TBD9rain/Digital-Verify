//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : video_if
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

interface video_if #(
    //  channel width of R, G, or B
    parameter DATA_WIDTH = 8)
(
    input logic clk,
    input logic rst_n);

    //  DUT IO port
    logic vin_vsync = 0;
    logic vin_hsync = 0;
    logic vin_de = 0;
    logic [3*DATA_WIDTH - 1: 0] vin_data = 0;

    logic vout_vsync;
    logic vout_hsync;
    logic vout_de;
    logic [3*DATA_WIDTH - 1: 0] vout_data;

    //  clock counter for time stamp
    longint unsigned clk_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            clk_cnt <= 0;
        end
        else begin
            clk_cnt <= clk_cnt + 1;
        end
    end

    clocking cb @(posedge clk);
        inout vin_vsync;
        inout vin_hsync;
        inout vin_de;
        inout vin_data;

        input vout_vsync;
        input vout_hsync;
        input vout_de;
        input vout_data;

        input clk_cnt;
    endclocking

    //  driver
    modport drv_mp (
        clocking cb,
        input rst_n,
        output vin_vsync,
        output vin_hsync,
        output vin_de,
        output vin_data);

    //  monitor
    modport mon_mp (
        clocking cb,
        input rst_n,
        input vin_vsync,
        input vin_hsync,
        input vin_de,
        input vin_data);

    //  DUT
    modport dut_mp (
        input clk,
        input rst_n,

        input vin_vsync,
        input vin_hsync,
        input vin_de,
        input vin_data,

        output vout_vsync,
        output vout_hsync,
        output vout_de,
        output vout_data);
endinterface

