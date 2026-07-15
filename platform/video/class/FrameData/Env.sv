//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Env
//  Version : 1.0.2
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataEnv #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1
) extends uvm_env;

    `uvm_component_param_utils(FrameDataEnv #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    FrameDataInAgt #(DATA_WIDTH, PIXEL_PER_CLOCK) i_agt;
    FrameDataOutAgt #(DATA_WIDTH, PIXEL_PER_CLOCK) o_agt;
    FrameDataRefMdl #(DATA_WIDTH) mdl;
    FrameDataScb #(DATA_WIDTH, PIXEL_PER_CLOCK) scb;

    bit scb_en = 0;

    uvm_tlm_analysis_fifo #(TXN) iagt_mdl_fifo;
    uvm_tlm_analysis_fifo #(TXN) iagt_scb_fifo;
    uvm_tlm_analysis_fifo #(TXN) oagt_scb_fifo;
    uvm_tlm_fifo #(TXN) mdl_scb_fifo;

    function new(string name="FrameDataEnv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(this, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("FrameDataEnv", "video configuration is not set.")
        end
        scb_en = video_cfg.scb_en;

        i_agt = FrameDataInAgt #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("i_agt", this);
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "i_agt", "video_cfg", video_cfg);

        o_agt = FrameDataOutAgt #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("o_agt", this);
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "o_agt", "video_cfg", video_cfg);

        if (!scb_en) begin
            return;
        end

        mdl = FrameDataRefMdl #(DATA_WIDTH)::type_id::create("mdl", this);
        scb = FrameDataScb #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("scb", this);
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "scb", "video_cfg", video_cfg);

        iagt_mdl_fifo = new("iagt_mdl_fifo", this);
        iagt_scb_fifo = new("iagt_scb_fifo", this);
        oagt_scb_fifo = new("oagt_scb_fifo", this);
        mdl_scb_fifo = new("mdl_scb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (!scb_en) begin
            return;
        end

        i_agt.ap.connect(iagt_mdl_fifo.analysis_export);
        mdl.imon_getp.connect(iagt_mdl_fifo.blocking_get_export);

        i_agt.ap.connect(iagt_scb_fifo.analysis_export);
        scb.imon_getp.connect(iagt_scb_fifo.blocking_get_export);

        o_agt.ap.connect(oagt_scb_fifo.analysis_export);
        scb.omon_getp.connect(oagt_scb_fifo.blocking_get_export);

        mdl.scb_putp.connect(mdl_scb_fifo.blocking_put_export);
        scb.mdl_getp.connect(mdl_scb_fifo.blocking_get_export);
    endfunction
endclass
