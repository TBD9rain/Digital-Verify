//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.0
//  Title           :   Env
//
//  Description     :   environment class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class Env #(
    parameter type ITXN = InTxn,
    parameter type OTXN = OutTxn,
    parameter longint unsigned LATENCY = 1
) extends uvm_env;
    `uvm_component_param_utils(Env #(ITXN, OTXN, LATENCY))

    //  variable definition
    InAgt #(ITXN) i_agt;
    OutAgt #(OTXN) o_agt;
    Cov #(ITXN) cov;
    Mdl #(ITXN, OTXN) mdl;
    Scb #(ITXN, OTXN, LATENCY) scb;

    uvm_tlm_analysis_fifo #(ITXN) iagt_cov_fifo;
    uvm_tlm_analysis_fifo #(ITXN) iagt_mdl_fifo;
    uvm_tlm_analysis_fifo #(ITXN) iagt_scb_fifo;
    uvm_tlm_analysis_fifo #(OTXN) oagt_scb_fifo;
    uvm_tlm_fifo #(OTXN) mdl_scb_fifo;

    function new(string name="Env", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        i_agt = InAgt #(ITXN)::type_id::create("i_agt", this);
        o_agt = OutAgt #(OTXN)::type_id::create("o_agt", this);
        cov = Cov #(ITXN)::type_id::create("cov", this);
        mdl = Mdl #(ITXN, OTXN)::type_id::create("mdl", this);
        scb = Scb #(ITXN, OTXN, LATENCY)::type_id::create("scb", this);

        uvm_config_db#(uvm_active_passive_enum)::set(this, "i_agt", "is_active", UVM_ACTIVE);

        iagt_mdl_fifo = new("iagt_mdl_fifo", this);
        iagt_cov_fifo = new("iagt_cov_fifo", this);
        iagt_scb_fifo = new("iagt_scb_fifo", this);
        oagt_scb_fifo = new("oagt_scb_fifo", this);
        mdl_scb_fifo = new("mdl_scb_fifo", this, 64);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        i_agt.ap.connect(iagt_cov_fifo.analysis_export);
        cov.imon_getp.connect(iagt_cov_fifo.blocking_get_export);

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


