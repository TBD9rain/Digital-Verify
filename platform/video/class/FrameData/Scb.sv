//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Scb
//  Version : 1.1.0
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
    typedef FrameDataTxn #(DATA_WIDTH) ITXN;
    typedef FrameDataTxn #(DATA_WIDTH) OTXN;

    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    uvm_nonblocking_get_port #(ITXN) imon_getp;
    uvm_blocking_get_port #(OTXN) omon_getp;
    uvm_nonblocking_get_port #(OTXN) mdl_getp;

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
        ITXN itxn;
        OTXN otxn;

        ITXN sti_itxn;
        OTXN exp_otxn;
        OTXN obs_otxn;

        forever begin
            obs_otxn = OTXN::type_id::create("obs_otxn");
            omon_getp.get(otxn);
            obs_otxn.copy(otxn);

            if (imon_getp.try_get(itxn)) begin
                sti_itxn = ITXN::type_id::create("sti_itxn");
                sti_itxn.copy(itxn);
            end
            else begin
                `uvm_fatal("FrameDataScb", "no input for DUT output.")
            end

            if (mdl_getp.try_get(otxn)) begin
                exp_otxn = OTXN::type_id::create("exp_otxn");
                exp_otxn.copy(otxn);
            end
            else begin
                `uvm_fatal("FrameDataScb", "no expected output for DUT output.")
            end

            value_check(sti_itxn, exp_otxn, obs_otxn);
            latency_check(sti_itxn, obs_otxn);
        end
    endtask

    function void value_check(const ref ITXN sti_itxn, const ref OTXN exp_otxn, const ref OTXN obs_otxn);
        bit txn_equal;

        txn_equal = exp_otxn.compare(obs_otxn);
        if (txn_equal) begin
            `uvm_info("FrameDataScb", "expected output and actual output match.", UVM_MEDIUM)
        end
        else begin
            `uvm_error("FrameDataScb", "expected output and actual output mismatch.")
        end

        if ((get_report_verbosity_level() == UVM_DEBUG) || (!txn_equal)) begin
            `uvm_info("FrameDataScb", "DUT input:", UVM_NONE)
            sti_itxn.print();
            `uvm_info("FrameDataScb", "DUT expected output:", UVM_NONE)
            exp_otxn.print();
            `uvm_info("FrameDataScb", "DUT observed output:", UVM_NONE)
            obs_otxn.print();
        end
    endfunction

    function void latency_check(const ref ITXN sti_itxn, const ref OTXN obs_otxn);
        longint unsigned dut_latency;

        dut_latency = obs_otxn.timestamp - sti_itxn.timestamp;
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
