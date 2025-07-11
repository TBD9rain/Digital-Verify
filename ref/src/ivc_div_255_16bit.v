//===============================================================================
//                            COPYRIGHT NOTICE
//  Copyright 2000-2023 (c) Lattice Semiconductor Corporation
//  ALL RIGHTS RESERVED
//  This confidential and proprietary software may be used only as authorised by
//  a licensing agreement from Lattice Semiconductor Corporation.
//  The entire notice above must be reproduced on all authorized copies and
//  copies may only be made to the extent permitted by a licensing agreement from
//  Lattice Semiconductor Corporation.
//
//  Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
//  5555 NE Moore Court                      408-826-6000 (other locations)
//  Hillsboro, OR 97124                      web  : http://www.latticesemi.com/
//  U.S.A                                    email: techsupport@latticesemi.com
//===============================================================================
//
//  Project          :  icon validity checker
//  File             :  ivc_div_255_16bit.v
//  Version          :  v1.0
//  Title            :  16-bit divider with 255 as invariant divisor
//  
//  Description      :  specilized operation for 16-bit division 
//                      by invariant 16-bit 255: 
//
//                      n / 255 = 32897*n / 2^23
//                     
//  Addt'l info      : 
//  Version history  :  
//                      v1.0
//                      basic functions
//
//===============================================================================

module ivc_div_255_16bit(
    //  IO PORT DECLARATIONS
    clk             ,
    rst_n           ,

    data_in_vld     ,
    dividend_in     ,

    data_out_vld    ,
    quotient_out    );

//-----------------------
//  PARAMETER DEFINITIONS
//-----------------------

localparam  LATENCY     = 2     ;

//------------------
//  PORT DEFINITIONS
//------------------

input               clk             ;
input               rst_n           ;

input               data_in_vld     ;
input   [15: 0]     dividend_in     ;

output              data_out_vld    ;
output  [ 8: 0]     quotient_out    ;

//----------------------
//  VARIABLE DEFINITIONS
//----------------------

reg     [LATENCY - 1: 0]    vld_reg         ;
reg     [15: 0]             dividend_reg    ;
reg     [16: 0]             a0              ;
reg     [16: 0]             a1              ;

//----------------
//  VERILOG CODING
//----------------

//  valid shift register
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        vld_reg     <= 'b0;
    end
    else begin
        vld_reg     <= {vld_reg, data_in_vld};
    end
end

assign  data_out_vld    = vld_reg[LATENCY - 1];

//  division operating
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        dividend_reg    <= 'b0;
        a0              <= 'b0;
        a1              <= 'b0;
    end
    else begin
        dividend_reg    <= dividend_in;
        a0              <= dividend_in + dividend_in[15: 7];
        a1              <= dividend_reg + a0[16: 8];
    end
end

assign  quotient_out = a1[16: 8];

endmodule

