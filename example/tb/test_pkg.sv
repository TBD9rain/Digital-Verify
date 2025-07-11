//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   test_pkg
//
//  Description     :   test component definition
//
//  Additional info :
//  Author          :   shi_l
//  Email           :
//
//==================================================================================================

package test_pkg;


//=====================
//  PACKAGE IMPORTATION
//=====================

import msg_print_pkg::*;


//==================
//  CLASS DEFINITION
//==================


//  DUT input transaction
class InputTxn;
    //  variable definition
    randc   bit [ 7: 0] addend0;
    randc   bit [ 7: 0] addend1;

    function new(
        input   bit [ 7: 0]   addend0 = 0,
        input   bit [ 7: 0]   addend1 = 0);

        this.addend0 = addend0;
        this.addend1 = addend1;
    endfunction
endclass


//  DUT output transaction
class OutputTxn;
    //  variable definition
    logic   [ 8: 0] sum;

    function new(
        input   logic   [ 7: 0]   sum = 0);

        this.sum = sum;
    endfunction
endclass


//  testcase sequencer
class InputSeqr;
    mailbox #(InputTxn) seqr_mbox;

    longint unsigned    txn_num;

    event   tc_done;

    function new();

        this.seqr_mbox  = new();
        this.txn_num    = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task put(
        input   InputTxn    txn_data);

        seqr_mbox.put(txn_data);
        txn_num++;
    endtask

    task get(
        output  InputTxn    txn_data);

        assert (txn_num > 0) begin
            seqr_mbox.get(txn_data);
            txn_num--;
            if (txn_num == 0) begin
                -> tc_done;
            end
        end
        else begin
            txn_data    = null;
        end
    endtask

    function longint unsigned num();

        num = txn_num;
    endfunction
endclass


//  testcase sequence
class InputSeq;
    InputSeqr seqr;

    function new();

        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task gen_rand_tc(
        input   longint unsigned    tc_num = 1);

        InputTxn    txn_data;

        for(int i = 0; i < tc_num; i++) begin
            txn_data    = new();
            assert(txn_data.randomize())
            else begin
                print_msg($typename(this), "randomization failed.", ERROR, HIGHEST, STOP);
            end
            seqr.put(txn_data);
        end
        print_msg($typename(this), $sformatf("added %0d random testcases.", tc_num), INFO, MEDIUM, LOG);
    endtask

    task add_case(
        input   InputTxn    txn_data);

        seqr.put(txn_data);
    endtask
endclass


//  DUT input driver
class InputDrv;
    virtual interface   test_if.drv_mp  vif;

    InputSeqr   seqr;

    function new();

        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        InputTxn    tc_txn;

        forever begin
            seqr.get(tc_txn);
            assert (tc_txn) begin
                drive(tc_txn);
            end
            else begin
                @vif.drv_cb;
                vif.drv_cb.data_in_vld  <= 1'b0;
                vif.drv_cb.addend0      <= 'b0;
                vif.drv_cb.addend1      <= 'b0;
            end
        end
    endtask

    task drive(
        input   InputTxn    tc_txn);

        @vif.drv_cb;
        vif.drv_cb.data_in_vld  <= 1'b1;
        vif.drv_cb.addend0      <= tc_txn.addend0;
        vif.drv_cb.addend1      <= tc_txn.addend1;
    endtask
endclass


//  DUT input monitor
class InputMon;
    virtual interface   test_if.mon_mp  vif;

    mailbox #(InputTxn) i2cov_mbox;
    mailbox #(InputTxn) i2ref_mbox;
    mailbox #(InputTxn) i2score_mbox;

    longint unsigned    ptn_cnt;

    function new();

        this.ptn_cnt = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        forever begin
            catch;
        end
    endtask

    task catch;

        string      msg;
        InputTxn    txn_caught;

        bit [ 7: 0] addend0;
        bit [ 7: 0] addend1;

        @vif.mon_cb;
        if (vif.mon_cb.data_in_vld) begin
            addend0 = vif.mon_cb.addend0;
            addend1 = vif.mon_cb.addend1;

            txn_caught = new(addend0, addend1);

            msg = $sformatf({
                "DUT input pattern caught:\n",
                "\tNO. %0d\n",
                data_print_str(txn_caught)},
                ptn_cnt);
            print_msg($typename(this), msg, INFO, LOW, LOG);

            i2cov_mbox.put(txn_caught);
            i2ref_mbox.put(txn_caught);
            i2score_mbox.put(txn_caught);

            ptn_cnt++;
        end
    endtask

    function string data_print_str(
        input   InputTxn    txn_print);

        data_print_str  = $sformatf({
            "\taddend0: %03d\n",
            "\taddend1: %03d\n"
            }, txn_print.addend0, txn_print.addend1);
    endfunction
endclass



//  DUT input agent
class InputAgent;
    virtual interface   test_if vif;

    InputSeqr   seqr;
    InputDrv    driver;
    InputMon    monitor;

    mailbox #(InputTxn) i2cov_mbox;
    mailbox #(InputTxn) i2ref_mbox;
    mailbox #(InputTxn) i2score_mbox;

    bit drive_en;

    event   tc_done;

    function new(
        input   bit drive_en = 'b1);

        this.drive_en   = drive_en;

        if (this.drive_en) begin
            this.seqr   = new();
            this.driver = new();
        end
        this.monitor    = new();
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    function void connect;

        if (drive_en) begin
            driver.vif  = vif;
            driver.seqr = seqr;
            tc_done     = seqr.tc_done;
        end

        monitor.vif             = vif;
        monitor.i2cov_mbox      = i2cov_mbox;
        monitor.i2ref_mbox      = i2ref_mbox;
        monitor.i2score_mbox    = i2score_mbox;

        print_msg($typename(this), "connection completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        fork
            if (drive_en) begin
                driver.run;
            end
            monitor.run;
        join_none
    endtask
endclass


//  testcase coverage collector
class CovCollector;
    mailbox #(InputTxn) i2cov_mbox;

    InputTxn    txn_data;

    //  coverage group definition
    covergroup  adder_8bit_tc;
        //  coverage point definition
        addend0: coverpoint txn_data.addend0 {
            //  bins definition
            bins a0 = {[  0:127]};
            bins a1 = {[128:255]};
        }
        addend1: coverpoint txn_data.addend1 {
            //  bins definition
            bins b[] = {[  0:255]};
        }
    endgroup

    function new();

        //  instantiate coverage group
        this.adder_8bit_tc = new();
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        forever begin
            i2cov_mbox.get(txn_data);
            //  coverage sample
            adder_8bit_tc.sample();
        end
    endtask
endclass


//  DUT output monitor
class OutputMon;
    virtual interface   test_if.mon_mp  vif;

    mailbox #(OutputTxn) o2score_mbox;

    longint unsigned    ptn_cnt;

    function new();

        this.ptn_cnt = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        forever begin
            catch;
        end
    endtask

    task catch;

        string      msg;
        OutputTxn    txn_caught;

        bit [ 8: 0] sum;

        @vif.mon_cb;
        if (vif.mon_cb.data_out_vld) begin
            sum = vif.mon_cb.sum;

            txn_caught = new(sum);

            msg = $sformatf({
                "DUT input pattern caught:\n",
                "\tNO. %0d\n",
                data_print_str(txn_caught)},
                ptn_cnt);
            print_msg($typename(this), msg, INFO, LOW, LOG);

            o2score_mbox.put(txn_caught);

            ptn_cnt++;
        end
    endtask

    function string data_print_str(
        input   OutputTxn    txn_print);

        data_print_str  = $sformatf({
            "\tsum: %03d\n"
            }, txn_print.sum);
    endfunction
endclass


//  DUT output agent
class OutputAgent;
    virtual interface   test_if vif;

    OutputMon   monitor;

    mailbox #(OutputTxn)    o2score_mbox;

    function new();

        this.monitor = new();
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    function void connect;

        monitor.vif             = vif;
        monitor.o2score_mbox    = o2score_mbox;
        print_msg($typename(this), "connection completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        monitor.run;
    endtask
endclass


//  DUT reference model
class RefModel;
    mailbox #(InputTxn)     i2ref_mbox;
    mailbox #(OutputTxn)    ref2score_mbox;

    function new();

        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        InputTxn    txn_in;
        OutputTxn   txn_ref;

        forever begin
            i2ref_mbox.get(txn_in);
            adder(txn_in, txn_ref);
            ref2score_mbox.put(txn_ref);
        end
    endtask

    task adder(
        input   InputTxn    txn_in,
        output  OutputTxn   txn_ref);

        txn_ref = new(txn_in.addend0 + txn_in.addend1);
    endtask
endclass


//  DUT output scoreboard
class Scoreboard;
    mailbox #(InputTxn)     i2score_mbox;
    mailbox #(OutputTxn)    o2score_mbox;
    mailbox #(OutputTxn)    ref2score_mbox;

    longint unsigned    ptn_cnt;

    function new();

        this.ptn_cnt    = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        string  msg;

        InputTxn    txn_in;
        OutputTxn   txn_out;
        OutputTxn   txn_ref;

        forever begin
            i2score_mbox.get(txn_in);
            o2score_mbox.get(txn_out);
            ref2score_mbox.get(txn_ref);

            assert (output_check(txn_out, txn_ref)) begin
                msg = $sformatf({
                    "Testcase passed:\n",
                    "\tNO.%0d\n",
                    data_print_str(txn_in, txn_out, txn_ref)},
                    ptn_cnt);

                print_msg($typename(this), msg, INFO, MEDIUM, LOG);
            end
            else begin
                msg = $sformatf({
                    "Testcase failed:\n",
                    "\tNO.%0d\n",
                    data_print_str(txn_in, txn_out, txn_ref)},
                    ptn_cnt);

                print_msg($typename(this), msg, ERROR, HIGHEST, STOP);
            end

            ptn_cnt++;
        end
    endtask

    function bit output_check(
        input   OutputTxn   data_out,
        input   OutputTxn   data_ref);

        output_check    = data_out.sum == data_ref.sum;
    endfunction

    function string data_print_str(
        input   InputTxn    txn_in,
        input   OutputTxn   txn_out,
        input   OutputTxn   txn_ref);

        data_print_str  = $sformatf({
            "\tInput addend0: %03d\n",
            "\tInput addend1: %03d\n",
            "\n",
            "\tOutput sum   : %03d\n",
            "\tReference sum: %03d\n"
            }, txn_in.addend0, txn_in.addend1,txn_out.sum, txn_ref.sum);
    endfunction
endclass


//  test environment
class TestEnv;
    virtual interface   test_if  vif;

    InputSeq        seq;
    InputAgent      input_agt;
    CovCollector    cov_coll;
    OutputAgent     output_agt;
    RefModel        ref_mdl;
    Scoreboard      scr_brd;

    mailbox #(InputTxn) i2cov_mbox;
    mailbox #(InputTxn) i2ref_mbox;
    mailbox #(InputTxn) i2score_mbox;

    mailbox #(OutputTxn)    o2score_mbox;
    mailbox #(OutputTxn)    ref2score_mbox;

    event   tc_done;

    bit drive_en;
    bit cover_en;

    function new(
        bit drive_en    = 1'b1,
        bit cover_en    = 1'b1);

        this.drive_en   = drive_en;
        this.cover_en   = cover_en;

        if (this.drive_en) begin
            this.seq    = new();
        end
        this.input_agt  = new(this.drive_en);
        if (this.cover_en) begin
            this.cov_coll    = new();
        end
        this.output_agt = new();
        this.ref_mdl    = new();
        this.scr_brd    = new();

        this.i2cov_mbox     = new();
        this.i2ref_mbox     = new();
        this.i2score_mbox   = new();
        this.o2score_mbox   = new();
        this.ref2score_mbox = new();

        print_msg($typename(this), "initialization completed.", INFO, HIGHEST, LOG);
    endfunction

    function void connect;

        if (drive_en) begin
            seq.seqr    = input_agt.seqr;
        end

        input_agt.vif   = vif;
        output_agt.vif  = vif;

        input_agt.i2cov_mbox    = i2cov_mbox;
        input_agt.i2ref_mbox    = i2ref_mbox;
        input_agt.i2score_mbox  = i2score_mbox;

        if (cover_en) begin
            cov_coll.i2cov_mbox = i2cov_mbox;
        end

        output_agt.o2score_mbox = o2score_mbox;

        ref_mdl.i2ref_mbox      = i2ref_mbox;
        ref_mdl.ref2score_mbox  = ref2score_mbox;

        scr_brd.i2score_mbox    = i2score_mbox;
        scr_brd.o2score_mbox    = o2score_mbox;
        scr_brd.ref2score_mbox  = ref2score_mbox;

        input_agt.connect;
        output_agt.connect;

        if (drive_en) begin
            tc_done     = input_agt.tc_done;
        end

        print_msg($typename(this), "connection completed.", INFO, HIGHEST, LOG);
    endfunction

    task run;

        fork
            input_agt.run;
            if (cover_en) begin
                cov_coll.run;
            end
            output_agt.run;
            ref_mdl.run;
            scr_brd.run;
        join_none
    endtask

    task add_case(
        InputTxn    txn_data);

        seq.add_case(txn_data);
    endtask

    task add_random_tc(
        longint unsigned    case_num = 1);

        seq.gen_rand_tc(case_num);
    endtask
endclass


endpackage


