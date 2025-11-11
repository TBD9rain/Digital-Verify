//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Agt
//  Version : 1.0.2
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameRowCtrlOutAgt #(
    parameter int DATA_WIDTH = 8
) extends uvm_agent;

    `uvm_component_param_utils(FrameRowCtrlOutAgt #(DATA_WIDTH))

    //  variable definition
    typedef FrameRowCtrlTxn TXN;

    FrameRowCtrlOutMon #(DATA_WIDTH) mon;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameRowCtrlOutAgt", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = FrameRowCtrlOutMon #(DATA_WIDTH)::type_id::create("mon", this);
        ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.ap.connect(ap);
    endfunction
endclass

