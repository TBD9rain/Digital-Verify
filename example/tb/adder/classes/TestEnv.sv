//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   TestEnv
//
//  Description     :   test environment
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class TestEnv #(
    parameter DATA_IN_WIDTH = 8,
    parameter DATA_OUT_WIDTH = 9);

    //  input transaction class
    typedef InputTxn #(.DATA_WIDTH (DATA_IN_WIDTH)) INPUT_TXN;
    typedef OutputTxn #(.DATA_WIDTH (DATA_OUT_WIDTH)) OUTPUT_TXN;

    virtual interface adder_if vif;

    ClockCnt clk_cnt;

    InputSeq #(.DATA_WIDTH (DATA_IN_WIDTH)) seq;
    InputAgent #(.DATA_WIDTH (DATA_IN_WIDTH)) input_agt;
    CovCollector #(.DATA_WIDTH (DATA_IN_WIDTH)) cov_coll;
    OutputAgent #(.DATA_WIDTH (DATA_OUT_WIDTH)) output_agt;

    RefModel #(
        .DATA_IN_WIDTH (DATA_IN_WIDTH),
        .DATA_OUT_WIDTH (DATA_OUT_WIDTH))
        ref_mdl;
    Scoreboard #(
        .DATA_IN_WIDTH (DATA_IN_WIDTH),
        .DATA_OUT_WIDTH (DATA_OUT_WIDTH))
        scr_brd;

    mailbox #(INPUT_TXN) i2cov_mbox;
    mailbox #(INPUT_TXN) i2ref_mbox;
    mailbox #(INPUT_TXN) i2score_mbox;

    mailbox #(OUTPUT_TXN) o2score_mbox;
    mailbox #(OUTPUT_TXN) ref2score_mbox;

    event tc_done;

    bit drive_en;
    bit cover_en;

    function new(
        bit drive_en = 1'b1,
        bit cover_en = 1'b1);

        this.drive_en = drive_en;
        this.cover_en = cover_en;

        this.clk_cnt = new();
        if (this.drive_en) begin
            this.seq = new();
        end
        this.input_agt = new(this.drive_en);
        if (this.cover_en) begin
            this.cov_coll = new();
        end
        this.output_agt = new();
        this.ref_mdl = new();
        this.scr_brd = new();

        if (this.cover_en) begin
            this.i2cov_mbox = new();
        end
        this.i2ref_mbox = new();
        this.i2score_mbox = new();
        this.o2score_mbox = new();
        this.ref2score_mbox = new();

        print_msg($typename(this), "initialization completed.", INFO, HIGHEST, LOG);
    endfunction

    function void connect;
        if (drive_en) begin
            seq.seqr = input_agt.seqr;
        end

        clk_cnt.vif = vif;
        input_agt.vif = vif;
        output_agt.vif = vif;
        scr_brd.vif = vif;

        input_agt.i2cov_mbox = i2cov_mbox;
        input_agt.i2ref_mbox = i2ref_mbox;
        input_agt.i2score_mbox = i2score_mbox;

        if (cover_en) begin
            cov_coll.i2cov_mbox = i2cov_mbox;
        end

        output_agt.o2score_mbox = o2score_mbox;

        ref_mdl.i2ref_mbox = i2ref_mbox;
        ref_mdl.ref2score_mbox = ref2score_mbox;

        scr_brd.i2score_mbox = i2score_mbox;
        scr_brd.o2score_mbox = o2score_mbox;
        scr_brd.ref2score_mbox = ref2score_mbox;

        input_agt.connect;
        output_agt.connect;

        if (drive_en) begin
            tc_done = input_agt.tc_done;
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
        InputTxn txn_data);

        seq.add_case(txn_data);
    endtask

    task add_random_tc(
        longint unsigned case_num = 1);

        seq.gen_rand_tc(case_num);
    endtask

    function real get_coverage(
        ref int num_bins_covered,
        ref int num_bins_total);

        get_coverage = cov_coll.get_coverage(num_bins_covered, num_bins_total);
    endfunction
endclass

