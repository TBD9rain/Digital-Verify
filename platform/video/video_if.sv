//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : video_if
//  Version : 1.0.2
//
//  Description
//      Video interface parameterized by pixels-per-clock.
//      The pixel data is a packed vector of PIXEL_PER_CLOCK {R, G, B} words, so it connects to a
//      plain Verilog DUT port. Pixel k occupies bits [k*3*DATA_WIDTH +: 3*DATA_WIDTH].
//      The control signals (vsync / hsync / de) qualify the whole clock and remain scalar.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

interface video_if #(
    //  channel width of R, G, or B
    parameter DATA_WIDTH = 8,
    parameter PIXEL_PER_CLOCK = 1)
(
    input logic clk,
    input logic rst_n);

    //  DUT IO port
    logic vin_vsync = 0;
    logic vin_hsync = 0;
    logic vin_de = 0;
    logic [PIXEL_PER_CLOCK*3*DATA_WIDTH - 1: 0] vin_pix;

    logic vout_vsync;
    logic vout_hsync;
    logic vout_de;
    logic [PIXEL_PER_CLOCK*3*DATA_WIDTH - 1: 0] vout_pix;

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
        output vin_vsync;
        output vin_hsync;
        output vin_de;
        output vin_pix;

        input clk_cnt;
    endclocking

    //  driver
    modport drv_mp (
        clocking cb,
        input rst_n);

    //  monitor
    modport mon_mp (
        input clk,
        input rst_n,

        input vin_vsync,
        input vin_hsync,
        input vin_de,
        input vin_pix,

        input vout_vsync,
        input vout_hsync,
        input vout_de,
        input vout_pix,

        input clk_cnt);

    //  DUT (a Verilog DUT connects via explicit signal port connections in the TB, not this modport)
    modport dut_mp (
        input clk,
        input rst_n,

        input vin_vsync,
        input vin_hsync,
        input vin_de,
        input vin_pix,

        output vout_vsync,
        output vout_hsync,
        output vout_de,
        output vout_pix);
endinterface
