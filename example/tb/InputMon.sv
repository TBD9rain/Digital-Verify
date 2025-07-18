//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   InputMon
//
//  Description     :   DUT input monitor
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InputMon #(
    parameter DATA_WIDTH = 8);

    //  input transaction class
    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    virtual interface test_if.mon_mp vif;

    mailbox #(INPUT_TXN) i2cov_mbox;
    mailbox #(INPUT_TXN) i2ref_mbox;
    mailbox #(INPUT_TXN) i2score_mbox;

    longint unsigned ptn_cnt;

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
        string msg;
        INPUT_TXN txn_caught;

        bit [DATA_WIDTH - 1: 0] addend0;
        bit [DATA_WIDTH - 1: 0] addend1;

        longint unsigned timestamp;

        if (vif.mon_cb.data_in_vld) begin
            addend0 = vif.mon_cb.addend0;
            addend1 = vif.mon_cb.addend1;

            timestamp = vif.mon_cb.clk_cnt;

            txn_caught = new(addend0, addend1, timestamp);

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
        input INPUT_TXN txn_print);

        data_print_str  = $sformatf({
            "\taddend0: %03d\n",
            "\taddend1: %03d\n"
            }, txn_print.addend0, txn_print.addend1);
    endfunction
endclass

