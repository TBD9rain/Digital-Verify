//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Env
//  Version : 1.0.5
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
    FrameDataCov #(DATA_WIDTH, PIXEL_PER_CLOCK) cov;
    FrameDataRefMdl #(DATA_WIDTH) mdl;
    FrameDataScb #(DATA_WIDTH, PIXEL_PER_CLOCK) scb;
    FrameDataScbFI #(DATA_WIDTH) fi;

    bit scb_en = 0;
    bit cov_en = 0;
    bit fault_inject_en = 0;

    uvm_tlm_analysis_fifo #(TXN) cov_sti_fifo;
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
        cov_en = video_cfg.cov_en;
        fault_inject_en = video_cfg.fault_inject_en;

        i_agt = FrameDataInAgt #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("i_agt", this);
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "i_agt", "video_cfg", video_cfg);

        o_agt = FrameDataOutAgt #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("o_agt", this);
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "o_agt", "video_cfg", video_cfg);

        if (cov_en) begin
            cov = FrameDataCov #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("cov", this);
            cov_sti_fifo = new("cov_sti_fifo", this);
        end

        if (!scb_en) begin
            return;
        end

        mdl = FrameDataRefMdl #(DATA_WIDTH)::type_id::create("mdl", this);
        scb = FrameDataScb #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("scb", this);
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "scb", "video_cfg", video_cfg);

        if (fault_inject_en) begin
            fi = FrameDataScbFI #(DATA_WIDTH)::type_id::create("fi", this);
        end

        iagt_mdl_fifo = new("iagt_mdl_fifo", this);
        iagt_scb_fifo = new("iagt_scb_fifo", this);
        oagt_scb_fifo = new("oagt_scb_fifo", this);
        mdl_scb_fifo = new("mdl_scb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (cov_en) begin
            i_agt.ap.connect(cov_sti_fifo.analysis_export);
            cov.imon_getp.connect(cov_sti_fifo.blocking_get_export);
        end

        if (!scb_en) begin
            return;
        end

        i_agt.ap.connect(iagt_mdl_fifo.analysis_export);
        mdl.imon_getp.connect(iagt_mdl_fifo.blocking_get_export);

        i_agt.ap.connect(iagt_scb_fifo.analysis_export);
        scb.imon_getp.connect(iagt_scb_fifo.nonblocking_get_export);

        if (fault_inject_en) begin
            o_agt.ap.connect(fi.imp);
            fi.ap.connect(oagt_scb_fifo.analysis_export);
        end
        else begin
            o_agt.ap.connect(oagt_scb_fifo.analysis_export);
        end
        scb.omon_getp.connect(oagt_scb_fifo.blocking_get_export);

        mdl.scb_putp.connect(mdl_scb_fifo.blocking_put_export);
        scb.mdl_getp.connect(mdl_scb_fifo.nonblocking_get_export);
    endfunction
endclass
