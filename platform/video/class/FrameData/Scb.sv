//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Scb
//  Version : 1.0.3
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataScb #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1
) extends uvm_scoreboard;

    `uvm_component_param_utils(FrameDataScb #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    uvm_blocking_get_port #(TXN) imon_getp;
    uvm_blocking_get_port #(TXN) omon_getp;
    uvm_blocking_get_port #(TXN) mdl_getp;

    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    int unsigned ref_latency = 0;

    function new(string name="FrameDataScb", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(this, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("FrameDataScb", "video configuration is not set.")
        end
        ref_latency = video_cfg.ref_latency;
        imon_getp = new("imon_getp", this);
        omon_getp = new("omon_getp", this);
        mdl_getp = new("mdl_getp", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN itxn;
        TXN otxn;

        TXN stimulus_input;
        TXN expected_output;
        TXN actual_output;

        bit imon_txn_got;
        bit ref_mdl_txn_got;

        forever begin
            actual_output = TXN::type_id::create("actual_output");
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
                        `uvm_fatal("FrameDataScb", "no input for DUT output.")
                    end
                end
            join_any

            stimulus_input = TXN::type_id::create("stimulus_input");
            stimulus_input.copy(itxn);

            //  get txn from reference model
            ref_mdl_txn_got = 0;
            fork
                begin
                    mdl_getp.get(itxn);
                    ref_mdl_txn_got = 1;
                end
                begin
                    #1;
                    if (!ref_mdl_txn_got) begin
                        `uvm_fatal("FrameDataScb", "no expected output for DUT output.")
                    end
                end
            join_any

            expected_output = TXN::type_id::create("expected_output");
            expected_output.copy(otxn);

            //  check DUT output
            value_check(expected_output, actual_output);
            latency_check(stimulus_input, actual_output);
        end
    endtask

    function void value_check(const ref TXN exp_txn, const ref TXN act_txn);
        bit txn_equal;

        txn_equal = exp_txn.compare(act_txn);
        if (txn_equal) begin
            `uvm_info("FrameDataScb", "expected output and actual output match.", UVM_MEDIUM)
        end
        else begin
            `uvm_error("FrameDataScb", "expected output and actual output mismatch.")
            `uvm_info("FrameDataScb", "expected output:", UVM_NONE)
            exp_txn.print();
            `uvm_info("FrameDataScb", "actual output:", UVM_NONE)
            act_txn.print();
        end
    endfunction

    function void latency_check(const ref TXN stm_txn, const ref TXN act_txn);
        longint unsigned dut_latency;

        dut_latency = act_txn.timestamp - stm_txn.timestamp;
        if (dut_latency == ref_latency) begin
            `uvm_info("FrameDataScb", "DUT latency is as expected.", UVM_MEDIUM)
        end
        else begin
            `uvm_error("FrameDataScb", "DUT latency is not as expected.")
            `uvm_info("FrameDataScb", $sformatf("expected latency is %0d clocks.", ref_latency), UVM_NONE)
            `uvm_info("FrameDataScb", $sformatf("actual latency is %0d clocks.", dut_latency), UVM_NONE)
        end
    endfunction
endclass
