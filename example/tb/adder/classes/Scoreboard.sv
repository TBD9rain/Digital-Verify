//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   Scoreboard
//
//  Description     :   verification scoreboard
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class Scoreboard #(
    parameter DATA_IN_WIDTH = 8,
    parameter DATA_OUT_WIDTH = 9);

    //  input transaction class
    typedef InputTxn #(.DATA_WIDTH (DATA_IN_WIDTH)) INPUT_TXN;
    typedef OutputTxn #(.DATA_WIDTH (DATA_OUT_WIDTH)) OUTPUT_TXN;

    virtual interface adder_if.env vif;

    mailbox #(INPUT_TXN) i2score_mbox;
    mailbox #(OUTPUT_TXN) o2score_mbox;
    mailbox #(OUTPUT_TXN) ref2score_mbox;

    longint unsigned ptn_cnt;

    function new();
        this.ptn_cnt    = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        string  msg;

        INPUT_TXN txn_in;
        OUTPUT_TXN txn_out;
        OUTPUT_TXN txn_ref;

        forever begin
            @vif.env_cb;
            if (~vif.rst_n && o2score_mbox.num() == 0) begin
                //  clear mailbox
                while (i2score_mbox.try_get(txn_in)) begin
                    msg = $sformatf({
                        "Testcase ABORTED due to reset:\n",
                        "\tNO.%0d\n",
                        data_print_str(txn_in, null, null)
                        }, ptn_cnt);
                    ptn_cnt++;

                    print_msg($typename(this), msg, WARN, HIGH, LOG);
                end
                while (ref2score_mbox.try_get(txn_ref)) begin end

                txn_out = null;
                txn_in  = null;
                txn_ref = null;

                continue;
            end

            o2score_mbox.get(txn_out);
            i2score_mbox.get(txn_in);
            ref2score_mbox.get(txn_ref);

            //  output check
            assert (output_check(txn_out, txn_ref)) begin
                msg = $sformatf({
                    "Testcase passed:\n",
                    "\tNO.%0d\n",
                    data_print_str(txn_in, txn_out, txn_ref)
                    }, ptn_cnt);

                print_msg($typename(this), msg, INFO, MEDIUM, LOG);
            end
            else begin
                msg = $sformatf({
                    "Testcase failed:\n",
                    "\tNO.%0d\n",
                    data_print_str(txn_in, txn_out, txn_ref)
                    }, ptn_cnt);

                print_msg($typename(this), msg, ERROR, HIGHEST, STOP);
            end

            //  timing check
            assert (timing_check(txn_in, txn_out))
            else begin
                msg = $sformatf({
                    "Testcase NO. %0d timing error:\n",
                    "\tinput time : %d\n",
                    "\toutput time: %d\n"
                    }, ptn_cnt, txn_in.timestamp, txn_out.timestamp);

                print_msg($typename(this), msg, ERROR, HIGHEST, STOP);
            end

            ptn_cnt++;
        end
    endtask

    function bit output_check(
        input OUTPUT_TXN txn_out,
        input OUTPUT_TXN txn_ref);

        output_check = (txn_out.sum === txn_ref.sum);
    endfunction

    function bit timing_check(
        input INPUT_TXN txn_in,
        input OUTPUT_TXN txn_out);

        timing_check = (txn_out.timestamp - txn_in.timestamp) == 1;
    endfunction

    function string data_print_str(
        input INPUT_TXN txn_in,
        input OUTPUT_TXN txn_out,
        input OUTPUT_TXN txn_ref);

        string str_data_in = "";
        string str_data_out = "";
        string str_data_ref = "";

        if (txn_in) begin
            str_data_in = $sformatf({
                "\tInput addend0: %03d\n",
                "\tInput addend1: %03d\n"
                }, txn_in.addend0, txn_in.addend1);
        end
        if (txn_out) begin
            str_data_out = $sformatf({"\tOutput sum   : %03d\n"}, txn_out.sum);
        end
        if (txn_ref) begin
            str_data_ref = $sformatf({"\tReference sum: %03d\n"}, txn_ref.sum);
        end

        data_print_str  = $sformatf({str_data_in, "\n", str_data_out, str_data_ref});
    endfunction
endclass

