//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.1
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
                        "NO.%0d\n",
                        txn_in.print
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
            assert (txn_out.compare(txn_ref)) begin
                msg = $sformatf({
                    "Testcase passed:\n",
                    "NO.%0d\n",
                    txn_in.print, "\n",
                    "out ", txn_out.print,
                    "ref ", txn_ref.print
                    }, ptn_cnt);

                print_msg($typename(this), msg, INFO, MEDIUM, LOG);
            end
            else begin
                msg = $sformatf({
                    "Testcase passed:\n",
                    "NO.%0d\n",
                    txn_in.print, "\n",
                    "out ", txn_out.print,
                    "ref ", txn_ref.print
                    }, ptn_cnt);

                print_msg($typename(this), msg, ERROR, HIGHEST, STOP);
            end

            //  timing check
            assert (timing_check(txn_in, txn_out))
            else begin
                msg = $sformatf({
                    "Testcase NO. %0d timing error:\n",
                    "input time: %d\n",
                    "output time: %d\n"
                    }, ptn_cnt, txn_in.timestamp, txn_out.timestamp);

                print_msg($typename(this), msg, ERROR, HIGHEST, STOP);
            end

            ptn_cnt++;
        end
    endtask

    function bit timing_check(
        input INPUT_TXN txn_in,
        input OUTPUT_TXN txn_out);

        timing_check = (txn_out.timestamp - txn_in.timestamp) == 1;
    endfunction
endclass

