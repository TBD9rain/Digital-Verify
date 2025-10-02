//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : FrameDataScb
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataScb #(
    parameter type TXN = FrameDataTxn,
    parameter longint unsigned LATENCY = 1
) extends uvm_scoreboard;
    `uvm_component_param_utils(FrameDataScb #(TXN, LATENCY))

    //  variable definition
    TXN imon_txn_q[$];
    TXN mdl_txn_q[$];
    uvm_blocking_get_port #(TXN) imon_getp;
    uvm_blocking_get_port #(TXN) omon_getp;
    uvm_blocking_get_port #(TXN) mdl_getp;

    function new(string name="FrameDataScb", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imon_getp = new("imon_getp", this);
        omon_getp = new("omon_getp", this);
        mdl_getp = new("mdl_getp", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN itxn_get;
        TXN otxn_get;

        TXN itxn;
        TXN otxn;

        TXN stimulus_input;
        TXN expected_output;
        TXN actual_output;

        fork
            forever begin
                imon_getp.get(itxn_get);
                imon_txn_q.push_front(itxn_get);
            end
            forever begin
                mdl_getp.get(otxn_get);
                mdl_txn_q.push_front(otxn_get);
            end
            forever begin
                actual_output = TXN::type_id::create("actual_output");
                omon_getp.get(otxn);
                actual_output.copy(otxn);

                if (imon_txn_q.size() > 0 && mdl_txn_q.size() > 0) begin
                    expected_output = TXN::type_id::create("expected_output");
                    otxn = mdl_txn_q.pop_back();
                    expected_output.copy(otxn);

                    stimulus_input = TXN::type_id::create("stimulus_input");
                    itxn = imon_txn_q.pop_back();
                    stimulus_input.copy(itxn);

                    value_check(expected_output, actual_output);
                    latency_check(stimulus_input, actual_output);
                end
                else begin
                    `uvm_error("Scb", "unexpected DUT output with no input.")
                end
            end
        join
    endtask

    function void value_check(const ref TXN exp_txn, const ref TXN act_txn);
        bit txn_equal;

        txn_equal = exp_txn.compare(act_txn);
        if (txn_equal) begin
            `uvm_info("Scb", "expected output and actual output match.", UVM_MEDIUM)
        end
        else begin
            `uvm_error("Scb", "expected output and actual output mismatch.")
            `uvm_info("Scb", "expected output:", UVM_NONE)
            exp_txn.print();
            `uvm_info("Scb", "actual output:", UVM_NONE)
            act_txn.print();
        end
    endfunction

    function void latency_check(const ref TXN stm_txn, const ref TXN act_txn);
        longint unsigned dut_latency;

        dut_latency = act_txn.timestamp - stm_txn.timestamp;
        if (dut_latency == LATENCY) begin
            `uvm_info("Scb", "DUT latency is as expected.", UVM_MEDIUM)
        end
        else begin
            `uvm_error("Scb", "DUT latency is not as expected.")
            `uvm_info("Scb", $sformatf("expected latency is %0d clocks.", LATENCY), UVM_NONE)
            `uvm_info("Scb", $sformatf("actual latency is %0d clocks.", dut_latency), UVM_NONE)
        end
    endfunction
endclass

