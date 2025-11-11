//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Env
//  Version : 1.0.1
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataEnv #(
    parameter int DATA_WIDTH = 8
) extends uvm_env;

    `uvm_component_param_utils(FrameDataEnv #(DATA_WIDTH))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    FrameDataInAgt #(DATA_WIDTH) i_agt;
    FrameDataOutAgt #(DATA_WIDTH) o_agt;
    FrameDataRefMdl #(DATA_WIDTH) mdl;
    FrameDataScb #(DATA_WIDTH) scb;

    uvm_tlm_analysis_fifo #(TXN) iagt_mdl_fifo;
    uvm_tlm_analysis_fifo #(TXN) iagt_scb_fifo;
    uvm_tlm_analysis_fifo #(TXN) oagt_scb_fifo;
    uvm_tlm_fifo #(TXN) mdl_scb_fifo;

    function new(string name="FrameDataEnv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        i_agt = FrameDataInAgt #(DATA_WIDTH)::type_id::create("i_agt", this);
        o_agt = FrameDataOutAgt #(DATA_WIDTH)::type_id::create("o_agt", this);
        scb = FrameDataScb #(DATA_WIDTH)::type_id::create("scb", this);
        mdl = FrameDataRefMdl #(DATA_WIDTH)::type_id::create("mdl", this);

        iagt_mdl_fifo = new("iagt_mdl_fifo", this);
        iagt_scb_fifo = new("iagt_scb_fifo", this);
        oagt_scb_fifo = new("oagt_scb_fifo", this);
        mdl_scb_fifo = new("mdl_scb_fifo", this);

        uvm_config_db #(uvm_active_passive_enum)::set(this, "i_agt", "is_active", UVM_ACTIVE);
        uvm_config_db #(uvm_active_passive_enum)::set(this, "o_agt", "is_active", UVM_PASSIVE);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

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

