//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : FrameDataEnv
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataEnv #(
    parameter type TXN = FrameDataTxn,
    parameter longint unsigned LATENCY = 1
) extends uvm_env;
    `uvm_component_param_utils(FrameDataEnv #(TXN, LATENCY))

    //  variable definition
    FrameDataInAgt #(TXN) i_agt;
    FrameDataOutAgt #(TXN) o_agt;
    FrameDataRefMdl #(TXN) mdl;
    FrameDataScb #(TXN) scb;

    uvm_tlm_analysis_fifo #(TXN) iagt_mdl_fifo;
    uvm_tlm_analysis_fifo #(TXN) iagt_scb_fifo;
    uvm_tlm_analysis_fifo #(TXN) oagt_scb_fifo;
    uvm_tlm_fifo #(TXN) mdl_scb_fifo;

    function new(string name="FrameDataEnv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        i_agt = FrameDataInAgt #(TXN)::type_id::create("i_agt", this);
        o_agt = FrameDataOutAgt #(TXN)::type_id::create("o_agt", this);
        scb = FrameDataScb #(TXN)::type_id::create("scb", this);
        mdl = FrameDataRefMdl #(TXN)::type_id::create("mdl", this);

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

