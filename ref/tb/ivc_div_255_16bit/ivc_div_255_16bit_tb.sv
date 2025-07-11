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

`timescale 1ns/100ps

module ivc_div_255_16bit_tb;

import msg_print_pkg::*;
import ivc_div_255_16bit_sim_pkg::*;

parameter   CLK_PERIOD      = 10;
parameter   NUM_RAND_PTN    = 65536;

string                  mod_name    = "ivc_div_255_16bit_tb";

bit                     clk     ;
bit                     rst_n   ;

div_255_ini_ptn         data_ini    ;
div_255_env             tb_env      ;

div_255_ini_ifc ifc_ini(
    .clk    (clk    ),
    .rst_n  (rst_n  ));

div_255_rsp_ifc ifc_rsp(
    .clk    (clk    ));

ivc_div_255_16bit u_dut(
    .clk                (ifc_ini.clk                    ),
    .rst_n              (ifc_ini.rst_n                  ),

    .data_in_vld        (ifc_ini.cb_dut.data_in_vld     ),
    .dividend_in        (ifc_ini.cb_dut.dividend_in     ),

    .data_out_vld       (ifc_rsp.data_out_vld           ),
    .quotient_out       (ifc_rsp.quotient_out           ));

initial begin
    forever begin
        #(CLK_PERIOD / 2);
        clk = ~clk;
    end
end

initial begin
    svrt_thold = HIGH;

    clean_msg_log;

    print_msg(mod_name, "Verification Start.\n", INFO, HIGHEST, LOG);

    data_ini                = new;

    tb_env                  = new();
    tb_env.vif_ini          = ifc_ini;
    tb_env.vif_rsp          = ifc_rsp;

    tb_env.connect;

    #({$random} % 100);
    rst_n   = 1'b1;

    #({$random} % 100);
    tb_env.run;

    #({$random} % 100);
    for (int i = 0; i < NUM_RAND_PTN; i++) begin
        assert(data_ini.randomize())
        else begin
            print_msg(mod_name, "randomization failed.", ERROR, HIGHEST, STOP);
        end
        if ({$random} % 100 >= 80) begin
            #(100 + ({$random} % 100));
        end
        tb_env.add_testcase(data_ini);
    end

    @tb_env.testcase_stm_end;
    # 2000
    print_msg(mod_name, "Verification Finished.\n", INFO, HIGHEST, LOG);
    $stop(2);
end

endmodule


