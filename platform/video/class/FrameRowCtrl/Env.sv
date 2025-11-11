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

class FrameRowCtrlEnv #(
    parameter int DATA_WIDTH = 8
) extends uvm_env;

    `uvm_component_param_utils(FrameRowCtrlEnv #(DATA_WIDTH))

    //  variable definition
    typedef FrameRowCtrlTxn TXN;

    FrameRowCtrlOutAgt #(DATA_WIDTH) o_agt;
    FrameRowCtrlRefMdl mdl;
    FrameRowCtrlScb scb;

    uvm_tlm_analysis_fifo #(TXN) oagt_scb_fifo;
    uvm_tlm_fifo #(TXN) mdl_scb_fifo;

    function new(string name="FrameRowCtrlEnv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        o_agt = FrameRowCtrlOutAgt #(DATA_WIDTH)::type_id::create("o_agt", this);
        mdl = FrameRowCtrlRefMdl::type_id::create("mdl", this);
        scb = FrameRowCtrlScb::type_id::create("scb", this);

        oagt_scb_fifo = new("oagt_scb_fifo", this);
        mdl_scb_fifo = new("mdl_scb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        o_agt.ap.connect(oagt_scb_fifo.analysis_export);
        scb.omon_getp.connect(oagt_scb_fifo.blocking_get_export);

        mdl.scb_putp.connect(mdl_scb_fifo.blocking_put_export);
        scb.mdl_getp.connect(mdl_scb_fifo.blocking_get_export);
    endfunction
endclass

