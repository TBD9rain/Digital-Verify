//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.2
//  Title           :   InputAgent
//
//  Description     :   DUT input agent
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InputAgent #(
    parameter DATA_WIDTH = 8);

    //  input transaction class
    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    virtual interface adder_if vif;

    InputSeqr #(.DATA_WIDTH (DATA_WIDTH)) seqr;
    InputDrv #(.DATA_WIDTH (DATA_WIDTH))  driver;
    InputMon #(.DATA_WIDTH (DATA_WIDTH))  monitor;

    mailbox #(INPUT_TXN) i2cov_mbox;
    mailbox #(INPUT_TXN) i2ref_mbox;
    mailbox #(INPUT_TXN) i2score_mbox;

    bit drive_en;
    bit cover_en;

    event tc_done;

    function new(
        input bit drive_en = 'b1,
        input bit cover_en = 'b1);

        this.drive_en = drive_en;
        this.cover_en = cover_en;
        if (this.drive_en) begin
            this.seqr = new();
            this.driver = new();
        end
        this.monitor = new(this.cover_en);
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    function void connect;
        if (drive_en) begin
            driver.vif = vif;
            driver.seqr = seqr;
            tc_done = seqr.tc_done;
        end
        monitor.vif = vif;
        monitor.i2cov_mbox = i2cov_mbox;
        monitor.i2ref_mbox = i2ref_mbox;
        monitor.i2score_mbox = i2score_mbox;
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

