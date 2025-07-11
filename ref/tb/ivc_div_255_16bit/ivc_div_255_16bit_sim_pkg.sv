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

package ivc_div_255_16bit_sim_pkg;

import msg_print_pkg::*;

    class div_255_ini_ptn;

        randc   bit     [15: 0]     dividend;

        function new(
            bit     [15: 0]     d = 0);
            dividend = d;
        endfunction

        function void copy(
            div_255_ini_ptn     src);
            dividend = src.dividend;
        endfunction

    endclass

    class div_255_ini_stm;

        virtual interface div_255_ini_ifc       vif                 ;

        mailbox #(div_255_ini_ptn)              mb_testcase         ;

        event                                   testcase_stm_end    ;

        task run;
            div_255_ini_ptn     data_ini    ;
            forever begin
                if (mb_testcase.try_get(data_ini) > 0) begin
                    dut_drive(data_ini);
                    data_ini = null;
 
                    if (mb_testcase.num() == 0) begin
                        -> testcase_stm_end;
                    end
                end
                else begin
                    @(posedge vif.clk);
                    vif.data_in_vld = 1'b0;
                    vif.dividend_in = 'b0;
                end
            end
        endtask

        task dut_drive(
            ref div_255_ini_ptn     data_ini    );

            int                 i           ;
            string              msg         ;

            @(posedge vif.clk);
            vif.data_in_vld = 1'b1;
            vif.dividend_in = data_ini.dividend;

            msg = $sformatf("DUT input dividend %0d.", data_ini.dividend);
            print_msg($typename(this), msg, INFO, LOW, LOG);
        endtask

    endclass

    class div_255_ini_mon;

        virtual interface div_255_ini_ifc.cb_dut        vif         ;

        mailbox #(div_255_ini_ptn)                      mb_ini2ref  ;
        mailbox #(div_255_ini_ptn)                      mb_ini2chk  ;

        bit     [31: 0]                                 ptn_cnt = 0 ;

        task run;
            forever begin
                mon_ifc;
            end
        endtask

        task mon_ifc;
            string              msg         ;
            div_255_ini_ptn     data_ini    ;

            @(vif.cb_dut);
            if (vif.rst_n && vif.cb_dut.data_in_vld) begin
                data_ini    = new(vif.cb_dut.dividend_in);
                mb_ini2ref.put(data_ini);
                mb_ini2chk.put(data_ini);

                msg = $sformatf({"DUT valid input detected: \n", 
                    "   NO.         %0d\n", 
                    "   dividend    %0d"}, 
                    ptn_cnt, data_ini.dividend);
                print_msg($typename(this), msg, INFO, LOW, LOG);

                ptn_cnt++;
            end
        endtask

    endclass

    class div_255_ini_agt;

        virtual interface div_255_ini_ifc       vif                 ;

        div_255_ini_stm                         stm                 ;
        div_255_ini_mon                         mon                 ;

        mailbox #(div_255_ini_ptn)              mb_testcase         ;
        mailbox #(div_255_ini_ptn)              mb_ini2ref          ;
        mailbox #(div_255_ini_ptn)              mb_ini2chk          ;

        bit                                     active              ;

        event                                   testcase_stm_end    ;

        function new(
            bit    stm_act = 1);

            active  = stm_act;

            if (active) begin
                stm         = new();
                mb_testcase = new();
            end
            mon     = new();

            print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
        endfunction

        function void connect;
            if (active) begin
                stm.vif             = vif;
                stm.mb_testcase     = mb_testcase;
                testcase_stm_end    = stm.testcase_stm_end;
            end
            mon.vif         = vif;
            mon.mb_ini2ref  = mb_ini2ref;
            mon.mb_ini2chk  = mb_ini2chk;

            print_msg($typename(this), "connection completed.", INFO, HIGH, LOG);
        endfunction

        task run;
            fork
                if (active) begin
                    stm.run;
                end
                mon.run;
            join_none
        endtask

        task add_testcase(
            div_255_ini_ptn     data    );

            div_255_ini_ptn     data_ini;

            data_ini = new;
            data_ini.copy(data);
            mb_testcase.put(data_ini);
        endtask

    endclass

    class div_255_rsp_ptn;

        bit     [ 8: 0]         quotient;

        function new(
            bit     [ 8: 0]     q = 0   );
            quotient    = q;
        endfunction

    endclass

    class div_255_rsp_stm;

        virtual interface div_255_rsp_ifc       vif             ;

        task run;
            forever begin
                @(vif.clk);
            end
        endtask

    endclass

    class div_255_rsp_mon;

        virtual interface div_255_rsp_ifc.cb_rsp        vif         ;

        mailbox #(div_255_rsp_ptn)                      mb_rsp2chk  ;

        bit     [31: 0]                                 ptn_cnt = 0 ;

        task run;
            forever begin
                mon_ifc;
            end
        endtask

        task mon_ifc;
            string              msg         ;
            div_255_rsp_ptn     data_rsp    ;

            @(vif.cb_rsp);
            if (vif.cb_rsp.data_out_vld) begin
                data_rsp    = new(vif.cb_rsp.quotient_out);
                mb_rsp2chk.put(data_rsp);

                msg = $sformatf({"DUT valid output detected: \n", 
                    "   NO.        %0d\n", 
                    "   quotient   %0d"}, ptn_cnt, data_rsp.quotient);
                print_msg($typename(this), msg, INFO, LOW, LOG);

                ptn_cnt++;
            end
        endtask

    endclass

    class div_255_rsp_agt;

        virtual interface div_255_rsp_ifc       vif         ;

        div_255_rsp_stm                         stm         ;
        div_255_rsp_mon                         mon         ;

        mailbox #(div_255_rsp_ptn)              mb_rsp2chk  ;

        bit                                     active      ;

        function new(
            bit    stm_act = 1);

            active  = stm_act;

            if (active) begin
                stm     = new();
            end
            mon     = new();

            print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
        endfunction

        function void connect;
            if (active) begin
                stm.vif = vif;
            end
            mon.vif         = vif;
            mon.mb_rsp2chk  = mb_rsp2chk;

            print_msg($typename(this), "connection completed.", INFO, HIGH, LOG);
        endfunction

        task run;
            fork
                if (active) begin
                    stm.run;
                end
                mon.run;
            join_none
        endtask

    endclass

    class div_255_ref_mdl;

        mailbox #(div_255_ini_ptn)      mb_ini2ref  ;
        mailbox #(div_255_rsp_ptn)      mb_ref2chk  ;

        task run;
            forever begin
                div_255;
            end
        endtask

        task div_255;
            div_255_ini_ptn     data_ini    ;
            div_255_rsp_ptn     data_ref    ;

            mb_ini2ref.get(data_ini);
            
            data_ref            = new();
            data_ref.quotient   = data_ini.dividend / 255;

            mb_ref2chk.put(data_ref);
        endtask

    endclass

    class div_255_checker;

        mailbox #(div_255_ini_ptn)      mb_ini2chk  ;
        mailbox #(div_255_rsp_ptn)      mb_rsp2chk  ;
        mailbox #(div_255_rsp_ptn)      mb_ref2chk  ;

        div_255_ini_ptn                 data_ini    ;
        div_255_rsp_ptn                 data_rsp    ;
        div_255_rsp_ptn                 data_ref    ;

        event                           chk_pass    ;

        bit     [31: 0]                 ptn_cnt = 0 ;

        task run;
            forever begin
                chk_div;
            end
        endtask

        task chk_div;
            string              msg         ;

            mb_ini2chk.get(data_ini);
            mb_rsp2chk.get(data_rsp);
            mb_ref2chk.get(data_ref);

            if (data_rsp.quotient == data_ref.quotient) begin
                msg = $sformatf({"test passed: \n", 
                    "   NO.                 %0d\n", 
                    "   input dividend      %0d\n", 
                    "   output quotient     %0d\n", 
                    "   reference quotient  %0d."}, 
                    ptn_cnt, data_ini.dividend, data_rsp.quotient, data_ref.quotient);
                print_msg($typename(this), msg, INFO, MEDIUM, LOG);

                -> chk_pass;
            end
            else begin
                msg = $sformatf({"test failed: \n", 
                    "   NO.                 %0d\n", 
                    "   input dividend      %0d\n", 
                    "   output quotient     %0d\n", 
                    "   reference quotient  %0d."}, 
                    ptn_cnt, data_ini.dividend, data_rsp.quotient, data_ref.quotient);
                print_msg($typename(this), msg, ERROR, HIGHEST, STOP);
            end

            ptn_cnt++;
        endtask

    endclass

    class div_255_env;

        virtual interface div_255_ini_ifc       vif_ini             ;
        virtual interface div_255_rsp_ifc       vif_rsp             ;

        div_255_ini_agt                         agt_ini             ;
        div_255_rsp_agt                         agt_rsp             ;

        div_255_ref_mdl                         ref_mdl             ;
        div_255_checker                         dut_chk             ;

        mailbox #(div_255_ini_ptn)              mb_ini2ref          ;
        mailbox #(div_255_ini_ptn)              mb_ini2chk          ;
        mailbox #(div_255_rsp_ptn)              mb_rsp2chk          ;
        mailbox #(div_255_rsp_ptn)              mb_ref2chk          ;

        event                                   testcase_stm_end    ;

        covergroup cvp_div_255 @(dut_chk.chk_pass);
            option.auto_bin_max = 128;
            d:  coverpoint      dut_chk.data_ini.dividend;
            q:  coverpoint      dut_chk.data_rsp.quotient{
                bins    quotient[]  = {[ 0:256]};
            }
        endgroup

        function new(
            bit     stm_act = 1,
            bit     cvp_act = 1);
            agt_ini     = new(stm_act);
            agt_rsp     = new(stm_act);
            ref_mdl     = new();
            dut_chk     = new();

            mb_ini2ref  = new();
            mb_ini2chk  = new();
            mb_rsp2chk  = new();
            mb_ref2chk  = new();

            if (cvp_act) begin
                cvp_div_255 = new();
            end

            print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
        endfunction

        function void connect;
            agt_ini.vif             = vif_ini;
            agt_rsp.vif             = vif_rsp;

            agt_ini.mb_ini2ref      = mb_ini2ref;
            ref_mdl.mb_ini2ref      = mb_ini2ref;

            agt_ini.mb_ini2chk      = mb_ini2chk;
            dut_chk.mb_ini2chk      = mb_ini2chk;

            agt_rsp.mb_rsp2chk      = mb_rsp2chk;
            dut_chk.mb_rsp2chk      = mb_rsp2chk;

            ref_mdl.mb_ref2chk      = mb_ref2chk;
            dut_chk.mb_ref2chk      = mb_ref2chk;

            agt_ini.connect();
            agt_rsp.connect();

            testcase_stm_end        = agt_ini.testcase_stm_end;

            print_msg($typename(this), "connection completed.", INFO, HIGH, LOG);
        endfunction

        task run;
            print_msg($typename(this), "run start...", INFO, HIGH, LOG);
            fork
                agt_ini.run;
                agt_rsp.run;
                ref_mdl.run;
                dut_chk.run;
            join_none
        endtask

        task add_testcase(
            div_255_ini_ptn     data    );
            agt_ini.add_testcase(data);
        endtask

    endclass

endpackage

