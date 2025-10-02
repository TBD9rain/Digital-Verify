//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : test
//  Version : 1.0.0
//
//  Description
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

    parameter DATA_WIDTH = 8
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
    input [3*DATA_WIDTH - 1: 0] vin_data,

    output reg vout_vsync,
    output reg vout_hsync,
    output reg vout_de,
    output reg [3*DATA_WIDTH - 1: 0] vout_data
);


//===============
//  DESIGN CODING
//===============

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        vout_vsync  <= 'b0;
        vout_hsync  <= 'b0;
        vout_de     <= 'b0;
        vout_data   <= 'b0;
    end
    else begin
        vout_vsync  <= vin_vsync;
        vout_hsync  <= vin_hsync;
        vout_de     <= vin_de;
        vout_data   <= vin_data;
    end
end


endmodule

