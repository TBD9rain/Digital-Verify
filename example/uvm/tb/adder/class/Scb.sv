//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.4
//  Title           :   Scb
//
//  Description     :   scoreboard class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class Scb #(
    parameter int DATA_WIDTH = 8
) extends uvm_scoreboard;
    `uvm_component_param_utils(Scb #(DATA_WIDTH))

    //  variable definition
    typedef InTxn #(DATA_WIDTH) ITXN;
    typedef OutTxn #(DATA_WIDTH) OTXN;

    uvm_blocking_get_port #(ITXN) imon_getp;
    uvm_blocking_get_port #(OTXN) omon_getp;
    uvm_blocking_get_port #(OTXN) mdl_getp;

    int unsigned ref_latency = 0;

    function new(string name="Scb", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(int unsigned)::get(this, "", "ref_latency", ref_latency)) begin
            `uvm_fatal("Scb", "Reference latency is not set.")
        end
        imon_getp = new("imon_getp", this);
        omon_getp = new("omon_getp", this);
        mdl_getp = new("mdl_getp", this);
    endfunction

    task main_phase(uvm_phase phase);
        ITXN itxn;
        OTXN otxn;

        ITXN stimulus_input;
        OTXN expected_output;
        OTXN actual_output;

        bit imon_txn_got;
        bit ref_mdl_txn_got;

        forever begin
            actual_output = OTXN::type_id::create("actual_output");
            omon_getp.get(otxn);
            actual_output.copy(otxn);

            //  get txn from input monitor
            imon_txn_got = 0;
            fork
                begin
                    imon_getp.get(itxn);
                    imon_txn_got = 1;
                end
                begin
                    #1;
                    if (!imon_txn_got) begin
                        `uvm_fatal("Scb", "no input for DUT output.")
                    end
                end
            join_any

            stimulus_input = ITXN::type_id::create("stimulus_input");
            stimulus_input.copy(itxn);

            //  get txn from reference model
            ref_mdl_txn_got = 0;
            fork
                begin
                    mdl_getp.get(otxn);
                    ref_mdl_txn_got = 1;
                end
                begin
                    #1;
                    if (!ref_mdl_txn_got) begin
                        `uvm_fatal("Scb", "no expected output for DUT output.")
                    end
                end
            join_any

            expected_output = OTXN::type_id::create("expected_output");
            expected_output.copy(otxn);

            value_check(expected_output, actual_output);
            latency_check(stimulus_input, actual_output);
        end
    endtask

    function void value_check(const ref OTXN exp_txn, const ref OTXN act_txn);
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

    function void latency_check(const ref ITXN stm_txn, const ref OTXN act_txn);
        longint unsigned dut_latency;

        dut_latency = act_txn.timestamp - stm_txn.timestamp;
        if (dut_latency == ref_latency) begin
            `uvm_info("Scb", "DUT latency is as expected.", UVM_MEDIUM)
        end
        else begin
            `uvm_error("Scb", "DUT latency is not as expected.")
            `uvm_info("Scb", $sformatf("expected latency is %0d clocks.", ref_latency), UVM_NONE)
            `uvm_info("Scb", $sformatf("actual latency is %0d clocks.", dut_latency), UVM_NONE)
        end
    endfunction
endclass


