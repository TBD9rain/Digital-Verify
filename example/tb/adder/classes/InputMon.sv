//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.1
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

    virtual interface adder_if.mon_mp vif;

    mailbox #(INPUT_TXN) i2cov_mbox;
    mailbox #(INPUT_TXN) i2ref_mbox;
    mailbox #(INPUT_TXN) i2score_mbox;

    longint unsigned ptn_cnt;

    bit cover_en;

    function new(
        input bit cover_en = 1'b1);

        this.cover_en = cover_en;
        this.ptn_cnt = 0;
        print_msg($typename(this), "initialization completed.", INFO, MEDIUM, LOG);
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
                "NO. %0d\n",
                txn_caught.print},
                ptn_cnt);
            print_msg($typename(this), msg, INFO, DEBUG, LOG);

            if (cover_en) begin
                i2cov_mbox.put(txn_caught);
            end
            i2ref_mbox.put(txn_caught);
            i2score_mbox.put(txn_caught);

            ptn_cnt++;
        end
    endtask
endclass

