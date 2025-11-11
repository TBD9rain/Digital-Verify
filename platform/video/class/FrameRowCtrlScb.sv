//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : FrameRowCtrlScb
//  Version : 1.0.2
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameRowCtrlScb extends uvm_scoreboard;
    `uvm_component_utils(FrameRowCtrlScb)

    //  variable definition
    typedef FrameRowCtrlTxn TXN;

    uvm_blocking_get_port #(TXN) omon_getp;
    uvm_blocking_get_port #(TXN) mdl_getp;

    bit frame_data_seq_done;

    function new(string name="FrameRowCtrlScb", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        omon_getp = new("omon_getp", this);
        mdl_getp = new("mdl_getp", this);

        frame_data_seq_done = 0;
    endfunction

    task main_phase(uvm_phase phase);
        TXN otxn;
        TXN expected_output;
        TXN actual_output;

        bit ref_mdl_txn_got;

        forever begin
            //  stop when frame data sequence is completed
            void'(uvm_config_db #(bit)::get(this, "", "frame_data_seq_done", frame_data_seq_done));
            if (frame_data_seq_done) begin
                break;
            end

            actual_output = TXN::type_id::create("actual_output");
            omon_getp.get(otxn);
            actual_output.copy(otxn);

            //  get txn from reference model
            ref_mdl_txn_got = 0;
            fork
                begin
                    mdl_getp.get(otxn);
                    ref_mdl_txn_got = 1;
                end
                begin
                    #1;
                    if (~ref_mdl_txn_got) begin
                        `uvm_fatal("FrameRowCtrlScb", "no expected output for DUT output.")
                    end
                end
            join_any

            expected_output = TXN::type_id::create("expected_output");
            expected_output.copy(otxn);

            //  check DUT output
            value_check(expected_output, actual_output);
        end
    endtask

    function void value_check(const ref TXN exp_txn, const ref TXN act_txn);
        bit txn_equal;

        txn_equal = exp_txn.compare(act_txn);
        if (txn_equal) begin
            `uvm_info("FrameRowCtrlScb", "expected output and actual output match.", UVM_MEDIUM)
        end
        else begin
            `uvm_error("FrameRowCtrlScb", "expected output and actual output mismatch.")
            `uvm_info("FrameRowCtrlScb", "expected output:", UVM_NONE)
            exp_txn.print();
            `uvm_info("FrameRowCtrlScb", "actual output:", UVM_NONE)
            act_txn.print();
        end
    endfunction
endclass

