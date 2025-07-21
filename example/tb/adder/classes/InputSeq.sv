//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   InputSeq
//
//  Description     :   testcase input sequence
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InputSeq #(
    parameter DATA_WIDTH = 8);

    //  input transaction class
    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    InputSeqr seqr;

    function new();
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task gen_rand_tc(
        input longint unsigned tc_num = 1);

        INPUT_TXN txn_data;

        for(int i = 0; i < tc_num; i++) begin
            txn_data = new();
            assert(txn_data.randomize())
            else begin
                print_msg($typename(this), "randomization failed.", ERROR, HIGHEST, STOP);
            end
            seqr.put(txn_data);
        end
        print_msg($typename(this), $sformatf("added %0d random testcases.", tc_num), INFO, MEDIUM, LOG);
    endtask

    task add_case(
        input InputTxn txn_data);

        seqr.put(txn_data);
    endtask
endclass

