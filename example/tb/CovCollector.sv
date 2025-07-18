//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   CovCollector
//
//  Description     :   coverage collector
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
    covergroup adder_8bit_tc;
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

    function real get_coverage(
        ref int num_bins_covered,
        ref int num_bins_total);

        get_coverage = adder_8bit_tc.get_coverage(num_bins_covered, num_bins_total);
    endfunction
endclass

