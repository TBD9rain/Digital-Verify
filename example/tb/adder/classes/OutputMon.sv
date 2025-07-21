//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
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
        OUTPUT_TXN txn_caught;

        bit [DATA_WIDTH - 1: 0] sum;

        longint unsigned timestamp;

        if (vif.mon_cb.data_out_vld) begin
            sum = vif.mon_cb.sum;

            timestamp = vif.mon_cb.clk_cnt;

            txn_caught = new(sum, timestamp);

            msg = $sformatf({
                "DUT input pattern caught:\n",
                "\tNO. %0d\n",
                data_print_str(txn_caught)},
                ptn_cnt);
            print_msg($typename(this), msg, INFO, LOW, LOG);

            o2score_mbox.put(txn_caught);

            ptn_cnt++;
        end
    endtask

    function string data_print_str(
        input OUTPUT_TXN txn_print);

        data_print_str  = $sformatf({
            "\tsum: %03d\n"
            }, txn_print.sum);
    endfunction
endclass

