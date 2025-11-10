//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoFormatAgt
//  Version : 1.0.1
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoFormatOutAgt #(
    parameter int DATA_WIDTH = 8
) extends uvm_agent;

    `uvm_component_param_utils(VideoFormatOutAgt #(DATA_WIDTH))

    //  variable definition
    typedef VideoFormatTxn TXN;

    VideoFormatOutMon #(DATA_WIDTH) mon;

    uvm_analysis_port #(TXN) ap;

    function new(string name="VideoFormatOutAgt", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = VideoFormatOutMon #(DATA_WIDTH)::type_id::create("mon", this);
        ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.ap.connect(ap);
    endfunction
endclass

