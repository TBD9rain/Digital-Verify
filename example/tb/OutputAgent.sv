//==================================================================================================
//
//  Project         :   Digital Verify  Example
//  Version         :   v1.0.0
//  Title           :   OutputAgent
//
//  Description     :   DUT output agent
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class OutputAgent #(
    parameter DATA_WIDTH = 9);

    //  input transaction class
    typedef OutputTxn #(.DATA_WIDTH (DATA_WIDTH)) OUTPUT_TXN;

    virtual interface test_if vif;

    OutputMon #(.DATA_WIDTH (DATA_WIDTH)) monitor;

    mailbox #(OUTPUT_TXN) o2score_mbox;

    function new();
        this.monitor = new();
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    function void connect;
        monitor.vif = vif;
        monitor.o2score_mbox = o2score_mbox;
        print_msg($typename(this), "connection completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        monitor.run;
    endtask
endclass

