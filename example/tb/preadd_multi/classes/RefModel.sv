//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   RefModel
//
//  Description     :   reference model
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class RefModel #(
    parameter DATA_IN_WIDTH = 8,
    parameter DATA_OUT_WIDTH = 18);

    //  input transaction class
    typedef InputTxn #(.DATA_WIDTH (DATA_IN_WIDTH)) INPUT_TXN;
    typedef OutputTxn #(.DATA_WIDTH (DATA_OUT_WIDTH)) OUTPUT_TXN;

    mailbox #(INPUT_TXN) i2ref_mbox;
    mailbox #(OUTPUT_TXN) ref2score_mbox;

    function new();
        print_msg($typename(this), "initialization completed.", INFO, MEDIUM, LOG);
    endfunction

    task run;
        INPUT_TXN txn_in;
        OUTPUT_TXN txn_ref;

        forever begin
            i2ref_mbox.get(txn_in);
            preadd_multi(txn_in, txn_ref);
            ref2score_mbox.put(txn_ref);
        end
    endtask

    task preadd_multi(
        input INPUT_TXN txn_in,
        output OUTPUT_TXN txn_ref);

        txn_ref = new((txn_in.data_in_a0 + txn_in.data_in_a1) * (txn_in.data_in_b0 + txn_in.data_in_b1));
    endtask
endclass

