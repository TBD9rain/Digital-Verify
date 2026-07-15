//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Agt
//  Version : 1.0.2
//
//  Description
//      Input agent activeness is taken from VideoConfig.video_drv_en.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataInAgt #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1
) extends uvm_agent;

    `uvm_component_param_utils(FrameDataInAgt #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    FrameDataSqr #(DATA_WIDTH, PIXEL_PER_CLOCK) sqr;
    FrameDataDrv #(DATA_WIDTH, PIXEL_PER_CLOCK) drv;
    FrameDataInMon #(DATA_WIDTH, PIXEL_PER_CLOCK) mon;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameDataInAgt", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(this, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("FrameDataInAgt", "video configuration is not set.")
        end
        is_active = video_cfg.video_drv_en;

        if (is_active == UVM_ACTIVE) begin
            sqr = FrameDataSqr #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("sqr", this);
            drv = FrameDataDrv #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("drv", this);
            uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "sqr", "video_cfg", video_cfg);
            uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "drv", "video_cfg", video_cfg);
        end
        mon = FrameDataInMon #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("mon", this);
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "mon", "video_cfg", video_cfg);
        ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
        mon.ap.connect(ap);
    endfunction
endclass


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
