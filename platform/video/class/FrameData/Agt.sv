//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Agt
//  Version : 1.0.1
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataInAgt #(
    parameter int DATA_WIDTH = 8
) extends uvm_agent;

    `uvm_component_param_utils(FrameDataInAgt #(DATA_WIDTH))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    FrameDataSqr #(DATA_WIDTH) sqr;
    FrameDataDrv #(DATA_WIDTH) drv;
    FrameDataInMon #(DATA_WIDTH) mon;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameDataInAgt", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active)) begin
            `uvm_fatal(get_name(), "is_active is not set.")
        end
        if (is_active == UVM_ACTIVE) begin
            sqr = FrameDataSqr #(DATA_WIDTH)::type_id::create("sqr", this);
            drv = FrameDataDrv #(DATA_WIDTH)::type_id::create("drv", this);
        end
        mon = FrameDataInMon #(DATA_WIDTH)::type_id::create("mon", this);
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
    parameter int DATA_WIDTH = 8
) extends uvm_agent;

    `uvm_component_param_utils(FrameDataOutAgt #(DATA_WIDTH))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    FrameDataOutMon #(DATA_WIDTH) mon;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameDataOutAgt", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = FrameDataOutMon #(DATA_WIDTH)::type_id::create("mon", this);
        ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.ap.connect(ap);
    endfunction
endclass

