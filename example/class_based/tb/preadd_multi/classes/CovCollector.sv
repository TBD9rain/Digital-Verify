//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   CovCollector
//
//  Description     :   DUT testcase coverage collector
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class CovCollector #(
    parameter DATA_WIDTH = 8);

    //  input transaction class
    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    mailbox #(INPUT_TXN) i2cov_mbox;

    INPUT_TXN txn_data;

    //  coverage group definition
    covergroup data_in_cov;
        //  coverage point definition
        addend0: coverpoint txn_data.data_in_a0 {
            //  bins definition
            bins a0[] = {[0:255]};}
        addend1: coverpoint txn_data.data_in_a1 {
            //  bins definition
            bins a1[] = {[0:255]};}
        addend2: coverpoint txn_data.data_in_b0 {
            //  bins definition
            bins b0[] = {[0:255]};}
        addend3: coverpoint txn_data.data_in_b1 {
            //  bins definition
            bins b1[] = {[0:255]};}
        //  cross coverage definition

    endgroup

    function new();
        //  instantiate coverage group
        data_in_cov = new();
        print_msg($typename(this), "initialization completed.", INFO, MEDIUM, LOG);
    endfunction

    task run;
        forever begin
            i2cov_mbox.get(txn_data);
            //  coverage sample
            data_in_cov.sample();
        end
    endtask

    function real get_coverage(
        ref int num_bins_covered,
        ref int num_bins_total);

        get_coverage = data_in_cov.get_coverage(num_bins_covered, num_bins_total);
    endfunction
endclass

