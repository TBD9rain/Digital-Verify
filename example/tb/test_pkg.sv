//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.3.0
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
class InputTxn #(
    parameter   DATA_WIDTH  = 8);

    //  variable definition
    randc   bit [DATA_WIDTH - 1: 0] addend0;
    randc   bit [DATA_WIDTH - 1: 0] addend1;

    //  timing check variable
    longint unsigned    timestamp;

    function new(
        input   bit [DATA_WIDTH - 1: 0] addend0 = 0,
        input   bit [DATA_WIDTH - 1: 0] addend1 = 0,
        input   longint unsigned        timestamp = 0);

        this.addend0 = addend0;
        this.addend1 = addend1;

        this.timestamp = timestamp;
    endfunction
endclass


//  DUT output transaction
class OutputTxn #(
    parameter   DATA_WIDTH = 9);

    //  variable definition
    logic   [DATA_WIDTH - 1: 0] sum;

    //  timing check variable
    longint unsigned    timestamp;

    function new(
        input   logic   [DATA_WIDTH - 1: 0] sum = 0,
        input   longint unsigned            timestamp = 0);

        this.sum = sum;

        this.timestamp = timestamp;
    endfunction
endclass


//  clock counter
class ClockCnt;
    virtual interface   test_if.env_mp vif;

    longint unsigned    clk_cnt;

    function new();

        this.clk_cnt    = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        forever begin
            @vif.env_cb;
            clk_cnt++;   //  avoid contest with monitors
            vif.env_cb.clk_cnt  <= clk_cnt;
        end
    endtask
endclass


//  testcase sequencer
class InputSeqr #(
    parameter   DATA_WIDTH  = 8);

    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    mailbox #(INPUT_TXN) seqr_mbox;

    longint unsigned    txn_num;

    event   tc_done;

    function new();

        this.seqr_mbox  = new();
        this.txn_num    = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task put(
        input   INPUT_TXN   txn_data);

        seqr_mbox.put(txn_data);
        txn_num++;
    endtask

    task get(
        output  INPUT_TXN   txn_data);

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
class InputSeq #(
    parameter   DATA_WIDTH  = 8);

    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    InputSeqr seqr;

    function new();

        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task gen_rand_tc(
        input   longint unsigned    tc_num = 1);

        INPUT_TXN   txn_data;

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
        input   INPUT_TXN   txn_data);

        seqr.put(txn_data);
    endtask
endclass


//  DUT input driver
class InputDrv #(
    parameter   DATA_WIDTH  = 8);

    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    virtual interface   test_if.drv_mp  vif;

    InputSeqr   seqr;

    function new();

        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        INPUT_TXN   tc_txn;

        forever begin
            @vif.drv_cb;
            if (~vif.rst_n) begin
                no_drive;
            end
            else begin
                seqr.get(tc_txn);
                assert (tc_txn) begin
                    drive(tc_txn);
                end
                else begin
                    no_drive;
                end
            end
        end
    endtask

    task drive(
        input   INPUT_TXN   tc_txn);

        vif.drv_cb.data_in_vld  <= 1'b1;
        vif.drv_cb.addend0      <= tc_txn.addend0;
        vif.drv_cb.addend1      <= tc_txn.addend1;
    endtask

    task no_drive;
        vif.drv_cb.data_in_vld  <= 1'b0;
        vif.drv_cb.addend0      <= 'b0;
        vif.drv_cb.addend1      <= 'b0;
    endtask
endclass


//  DUT input monitor
class InputMon #(
    parameter   DATA_WIDTH  = 8);

    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    virtual interface   test_if.mon_mp  vif;

    mailbox #(INPUT_TXN)    i2cov_mbox;
    mailbox #(INPUT_TXN)    i2ref_mbox;
    mailbox #(INPUT_TXN)    i2score_mbox;

    longint unsigned    ptn_cnt;

    function new();

        this.ptn_cnt = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        forever begin
            @vif.mon_cb;
            if (~vif.rst_n) begin
                continue;
            end
            catch;
        end
    endtask

    task catch;

        string      msg;
        INPUT_TXN   txn_caught;

        bit [DATA_WIDTH - 1: 0] addend0;
        bit [DATA_WIDTH - 1: 0] addend1;

        longint unsigned    timestamp;

        if (vif.mon_cb.data_in_vld) begin
            addend0 = vif.mon_cb.addend0;
            addend1 = vif.mon_cb.addend1;

            timestamp = vif.mon_cb.clk_cnt;

            txn_caught = new(addend0, addend1, timestamp);

            msg = $sformatf({
                "DUT input caught:\n",
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
        input   INPUT_TXN   txn_print);

        data_print_str  = $sformatf({
            "\taddend0: %03d\n",
            "\taddend1: %03d\n"
            }, txn_print.addend0, txn_print.addend1);
    endfunction
endclass


//  DUT input agent
class InputAgent #(
    parameter   DATA_WIDTH  = 8);

    typedef InputTxn #( .DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    virtual interface   test_if vif;

    InputSeqr   #(.DATA_WIDTH (DATA_WIDTH)) seqr;
    InputDrv    #(.DATA_WIDTH (DATA_WIDTH)) driver;
    InputMon    #(.DATA_WIDTH (DATA_WIDTH)) monitor;

    mailbox #(INPUT_TXN)    i2cov_mbox;
    mailbox #(INPUT_TXN)    i2ref_mbox;
    mailbox #(INPUT_TXN)    i2score_mbox;

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
class CovCollector #(
    parameter   DATA_WIDTH  = 8);

    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    mailbox #(INPUT_TXN)    i2cov_mbox;

    INPUT_TXN   txn_data;

    //  coverage group definition
    covergroup  adder_8bit_tc;
        //  coverage point definition
        addend0: coverpoint txn_data.addend0 {
            //  bins definition
            bins a[] = {[  0:255]};
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
class OutputMon #(
    parameter   DATA_WIDTH  = 9);

    typedef OutputTxn #(.DATA_WIDTH (DATA_WIDTH)) OUTPUT_TXN;

    virtual interface   test_if.mon_mp  vif;

    mailbox #(OUTPUT_TXN)   o2score_mbox;

    longint unsigned    ptn_cnt;

    function new();

        this.ptn_cnt = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        forever begin
            @vif.mon_cb;
            if (~vif.rst_n) begin
                continue;
            end
            catch;
        end
    endtask

    task catch;

        string      msg;
        OUTPUT_TXN  txn_caught;

        bit [DATA_WIDTH - 1: 0] sum;

        longint unsigned    timestamp;

        if (vif.mon_cb.data_out_vld) begin
            sum = vif.mon_cb.sum;

            timestamp = vif.mon_cb.clk_cnt;

            txn_caught = new(sum, timestamp);

            msg = $sformatf({
                "DUT output caught:\n",
                "\tNO. %0d\n",
                data_print_str(txn_caught)},
                ptn_cnt);
            print_msg($typename(this), msg, INFO, LOW, LOG);

            o2score_mbox.put(txn_caught);

            ptn_cnt++;
        end
    endtask

    function string data_print_str(
        input   OUTPUT_TXN  txn_print);

        data_print_str  = $sformatf({
            "\tsum: %03d\n"
            }, txn_print.sum);
    endfunction
endclass


//  DUT output agent
class OutputAgent #(
    parameter   DATA_WIDTH  = 9);

    typedef OutputTxn #(.DATA_WIDTH (DATA_WIDTH)) OUTPUT_TXN;

    virtual interface   test_if vif;

    OutputMon #(.DATA_WIDTH (DATA_WIDTH)) monitor;

    mailbox #(OUTPUT_TXN)   o2score_mbox;

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
class RefModel #(
    parameter   DATA_IN_WIDTH   = 8,
    parameter   DATA_OUT_WIDTH  = 9);

    typedef InputTxn    #(.DATA_WIDTH (DATA_IN_WIDTH))  INPUT_TXN;
    typedef OutputTxn   #(.DATA_WIDTH (DATA_OUT_WIDTH)) OUTPUT_TXN;

    mailbox #(INPUT_TXN)    i2ref_mbox;
    mailbox #(OUTPUT_TXN)   ref2score_mbox;

    function new();

        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        INPUT_TXN   txn_in;
        OUTPUT_TXN  txn_ref;

        forever begin
            i2ref_mbox.get(txn_in);
            adder(txn_in, txn_ref);
            ref2score_mbox.put(txn_ref);
        end
    endtask

    task adder(
        input   INPUT_TXN   txn_in,
        output  OUTPUT_TXN  txn_ref);

        txn_ref = new(txn_in.addend0 + txn_in.addend1);
    endtask
endclass


//  DUT output scoreboard
class Scoreboard #(
    parameter   DATA_IN_WIDTH   = 8,
    parameter   DATA_OUT_WIDTH  = 9);

    typedef InputTxn    #(.DATA_WIDTH (DATA_IN_WIDTH))  INPUT_TXN;
    typedef OutputTxn   #(.DATA_WIDTH (DATA_OUT_WIDTH)) OUTPUT_TXN;

    virtual interface   test_if.env vif;

    mailbox #(INPUT_TXN)    i2score_mbox;
    mailbox #(OUTPUT_TXN)   o2score_mbox;
    mailbox #(OUTPUT_TXN)   ref2score_mbox;

    longint unsigned    ptn_cnt;

    function new();

        this.ptn_cnt    = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;

        string  msg;

        INPUT_TXN   txn_in;
        OUTPUT_TXN  txn_out;
        OUTPUT_TXN  txn_ref;

        forever begin
            @vif.env_cb;
            if (~vif.rst_n && o2score_mbox.num() == 0) begin
                //  clear mailbox
                while (i2score_mbox.try_get(txn_in)) begin
                    msg = $sformatf({
                        "Testcase ABORTED due to reset:\n",
                        "\tNO.%0d\n",
                        data_print_str(txn_in, null, null)
                        }, ptn_cnt);
                    ptn_cnt++;

                    print_msg($typename(this), msg, WARN, HIGH, LOG);
                end
                while (ref2score_mbox.try_get(txn_ref)) begin end

                txn_out = null;
                txn_in  = null;
                txn_ref = null;

                continue;
            end

            o2score_mbox.get(txn_out);
            i2score_mbox.get(txn_in);
            ref2score_mbox.get(txn_ref);

            //  output check
            assert (output_check(txn_out, txn_ref)) begin
                msg = $sformatf({
                    "Testcase passed:\n",
                    "\tNO.%0d\n",
                    data_print_str(txn_in, txn_out, txn_ref)
                    }, ptn_cnt);

                print_msg($typename(this), msg, INFO, MEDIUM, LOG);
            end
            else begin
                msg = $sformatf({
                    "Testcase failed:\n",
                    "\tNO.%0d\n",
                    data_print_str(txn_in, txn_out, txn_ref)
                    }, ptn_cnt);

                print_msg($typename(this), msg, ERROR, HIGHEST, STOP);
            end

            //  timing check
            assert (timing_check(txn_in, txn_out))
            else begin
                msg = $sformatf({
                    "Testcase NO. %0d timing error:\n",
                    "\tinput time : %d\n",
                    "\toutput time: %d\n"
                    }, ptn_cnt, txn_in.timestamp, txn_out.timestamp);

                print_msg($typename(this), msg, ERROR, HIGHEST, STOP);
            end

            ptn_cnt++;
        end
    endtask

    function bit output_check(
        input   OUTPUT_TXN  txn_out,
        input   OUTPUT_TXN  txn_ref);

        output_check    = (txn_out.sum === txn_ref.sum);
    endfunction

    function bit timing_check(
        input   INPUT_TXN   txn_in,
        input   OUTPUT_TXN  txn_ref);

        timing_check = (txn_ref.timestamp - txn_in.timestamp) == 1;
    endfunction

    function string data_print_str(
        input   INPUT_TXN   txn_in  = null,
        input   OUTPUT_TXN  txn_out = null,
        input   OUTPUT_TXN  txn_ref = null);

        string  str_in  = "";
        string  str_out = "";
        string  str_ref = "";

        if (txn_in) begin
            str_in  = $sformatf({
                "\tInput addend0: %03d\n",
                "\tInput addend1: %03d\n"
                }, txn_in.addend0, txn_in.addend1);
        end

        if (txn_out) begin
            str_out = $sformatf({"\tOutput sum   : %03d\n"}, txn_out.sum);
        end

        if (txn_ref) begin
            str_ref = $sformatf({"\tReference sum: %03d\n"}, txn_ref.sum);
        end

        data_print_str  = $sformatf({str_in, "\n", str_out, str_ref});
    endfunction
endclass


//  test environment
class TestEnv #(
    parameter   DATA_IN_WIDTH   = 8,
    parameter   DATA_OUT_WIDTH  = 9);

    typedef InputTxn    #(.DATA_WIDTH (DATA_IN_WIDTH))  INPUT_TXN;
    typedef OutputTxn   #(.DATA_WIDTH (DATA_OUT_WIDTH)) OUTPUT_TXN;

    virtual interface   test_if  vif;

    ClockCnt    clk_cnt;

    InputSeq        #(.DATA_WIDTH (DATA_IN_WIDTH))  seq;
    InputAgent      #(.DATA_WIDTH (DATA_IN_WIDTH))  input_agt;
    CovCollector    #(.DATA_WIDTH (DATA_IN_WIDTH))  cov_coll;
    OutputAgent     #(.DATA_WIDTH (DATA_OUT_WIDTH)) output_agt;

    RefModel #(
        .DATA_IN_WIDTH  (DATA_IN_WIDTH),
        .DATA_OUT_WIDTH (DATA_OUT_WIDTH))
        ref_mdl;
    Scoreboard #(
        .DATA_IN_WIDTH  (DATA_IN_WIDTH),
        .DATA_OUT_WIDTH (DATA_OUT_WIDTH))
        scr_brd;

    mailbox #(INPUT_TXN)    i2cov_mbox;
    mailbox #(INPUT_TXN)    i2ref_mbox;
    mailbox #(INPUT_TXN)    i2score_mbox;

    mailbox #(OUTPUT_TXN)   o2score_mbox;
    mailbox #(OUTPUT_TXN)   ref2score_mbox;

    event   tc_done;

    bit drive_en;
    bit cover_en;

    function new(
        bit drive_en    = 1'b1,
        bit cover_en    = 1'b1);

        this.drive_en   = drive_en;
        this.cover_en   = cover_en;

        this.clk_cnt    = new();
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

        if (this.cover_en) begin
            this.i2cov_mbox       = new();
        end
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

        clk_cnt.vif     = vif;
        input_agt.vif   = vif;
        output_agt.vif  = vif;
        scr_brd.vif     = vif;

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
            clk_cnt.run;
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
        INPUT_TXN   txn_data);

        seq.add_case(txn_data);
    endtask

    task add_random_tc(
        longint unsigned    case_num = 1);

        seq.gen_rand_tc(case_num);
    endtask
endclass


endpackage


