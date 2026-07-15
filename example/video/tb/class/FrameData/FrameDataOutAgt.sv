//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : OutAgt
//  Version : 1.0.3
//
//  Description
//      Output agent (monitor only). Distributes VideoConfig to its monitor.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataOutAgt #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1
) extends uvm_agent;

    `uvm_component_param_utils(FrameDataOutAgt #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    FrameDataOutMon #(DATA_WIDTH, PIXEL_PER_CLOCK) mon;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameDataOutAgt", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(this, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("FrameDataOutAgt", "video configuration is not set.")
        end

        mon = FrameDataOutMon #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("mon", this);
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "mon", "video_cfg", video_cfg);
        ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.ap.connect(ap);
    endfunction
endclass
