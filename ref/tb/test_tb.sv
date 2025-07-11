//===============================================================================
//                            COPYRIGHT NOTICE
//  Copyright 2000-2019 (c) Lattice Semiconductor Corporation
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
//  Project          :
//  File             :
//  Version          :
//  Title            :
//  
//  Description      :
//                     
//  Addt'l info      : 
//  Version history  :
//
//===============================================================================

`include    ".\\msg_print_pkg.sv"
`timescale  1ns/100ps

module test_tb;

parameter   CLK_PERIOD  = 10;

import msg_print_pkg::*;

bit     clk;

initial begin
    clk = #(CLK_PERIOD/2) clk;
end

initial begin
    # 300;
    print_msg("test_tb", "test succeeded", .act (STOP));
end

endmodule

