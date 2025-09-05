//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   InputSeqr
//
//  Description     :   DUT testcase sequencer
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InputSeqr #(
    parameter DATA_WIDTH = 8);

    //  input transaction class
    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    mailbox #(INPUT_TXN) seqr_mbox;

    longint unsigned txn_num;

    event tc_done;

    function new();
        this.seqr_mbox = new();
        this.txn_num = 0;
        print_msg($typename(this), "initialization completed.", INFO, MEDIUM, LOG);
    endfunction

    task put(
        input INPUT_TXN txn_data);

        seqr_mbox.put(txn_data);
        txn_num++;
    endtask

    task get(
        output INPUT_TXN txn_data);

        assert (txn_num > 0) begin
            seqr_mbox.get(txn_data);
            txn_num--;
            if (txn_num == 0) begin
                -> tc_done;
            end
        end
        else begin
            txn_data = null;
        end
    endtask

    function longint unsigned num();
        num = txn_num;
    endfunction
endclass

