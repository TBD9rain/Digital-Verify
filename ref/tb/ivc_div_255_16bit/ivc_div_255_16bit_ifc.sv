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

interface div_255_ini_ifc (
    clk     ,
    rst_n   );

    input               clk             ;
    input               rst_n           ;

    logic               data_in_vld = 0 ;
    logic   [15: 0]     dividend_in = 0 ;

    clocking cb_dut @(posedge clk);
        input   data_in_vld;
        input   dividend_in;
    endclocking

endinterface

interface div_255_rsp_ifc (
    clk);

    input               clk             ;

    logic               data_out_vld    ;
    logic   [ 8: 0]     quotient_out    ;

    clocking cb_rsp @(posedge clk);
        input   data_out_vld;
        input   quotient_out;
    endclocking
endinterface

