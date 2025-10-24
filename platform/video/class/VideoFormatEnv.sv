//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoFormatEnv
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoFormatEnv #(
    parameter type TXN = VideoFormatTxn
) extends uvm_env;
    `uvm_component_param_utils(VideoFormatEnv #(TXN))

    //  variable definition
    VideoFormatOutAgt #(TXN) o_agt;
    VideoFormatRefMdl #(TXN) mdl;
    VideoFormatScb #(TXN) scb;

    uvm_tlm_analysis_fifo #(TXN) oagt_scb_fifo;
    uvm_tlm_fifo #(TXN) mdl_scb_fifo;

    function new(string name="VideoFormatEnv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        o_agt = VideoFormatOutAgt #(TXN)::type_id::create("o_agt", this);
        mdl = VideoFormatRefMdl #(TXN)::type_id::create("mdl", this);
        scb = VideoFormatScb #(TXN)::type_id::create("scb", this);

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

