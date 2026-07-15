//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : test
//  Version : 1.0.1
//
//  Description
//      Placeholder DUT: a one-clock passthrough of the video stream.
//      Written in Verilog. The pixel data is a packed vector carrying PIXEL_PER_CLOCK pixels.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

module video_test #(
    //======================
    //  PARAMETER DEFINITION
    //======================

    parameter DATA_WIDTH = 8,
    parameter PIXEL_PER_CLOCK = 1
)
(
    //=================
    //  PORT DEFINITION
    //=================

    input clk,
    input rst_n,

    input vin_vsync,
    input vin_hsync,
    input vin_de,
    input [PIXEL_PER_CLOCK*3*DATA_WIDTH - 1: 0] vin_pix,

    output reg vout_vsync,
    output reg vout_hsync,
    output reg vout_de,
    output reg [PIXEL_PER_CLOCK*3*DATA_WIDTH - 1: 0] vout_pix
);


//===============
//  DESIGN CODING
//===============

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        vout_vsync  <= 'b0;
        vout_hsync  <= 'b0;
        vout_de     <= 'b0;
        vout_pix    <= 'b0;
    end
    else begin
        vout_vsync  <= vin_vsync;
        vout_hsync  <= vin_hsync;
        vout_de     <= vin_de;
        vout_pix    <= vin_pix;
    end
end


endmodule
