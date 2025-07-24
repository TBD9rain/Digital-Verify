//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.1
//  Title           :   OutputMon
//
//  Description     :   DUT output monitor
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class OutputMon #(
    parameter DATA_WIDTH = 9);

    //  input transaction class
    typedef OutputTxn #(.DATA_WIDTH (DATA_WIDTH)) OUTPUT_TXN;

    virtual interface adder_if.mon_mp vif;

    mailbox #(OUTPUT_TXN) o2score_mbox;

    longint unsigned ptn_cnt;

    function new();
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
        OUTPUT_TXN txn_caught;

        bit [DATA_WIDTH - 1: 0] sum;

        longint unsigned timestamp;

        if (vif.mon_cb.data_out_vld) begin
            sum = vif.mon_cb.sum;

            timestamp = vif.mon_cb.clk_cnt;

            txn_caught = new(sum, timestamp);

            msg = $sformatf({
                "DUT output pattern caught:\n",
                "NO. %0d\n",
                txn_caught.print},
                ptn_cnt);
            print_msg($typename(this), msg, INFO, DEBUG, LOG);

            o2score_mbox.put(txn_caught);

            ptn_cnt++;
        end
    endtask
endclass

