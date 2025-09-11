//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   Agt
//
//  Description     :   agent class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InAgt #(
    parameter type TXN = InTxn
) extends uvm_agent;
    `uvm_component_param_utils(InAgt #(TXN))

    //  variable definition
    Sqr #(TXN) sqr;
    Drv #(TXN) drv;
    InMon #(TXN) mon;

    uvm_analysis_port #(TXN) ap;

    function new(string name="InAgt", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active)) begin
            `uvm_fatal("Agt", "is_active is not set.")
        end
        if (is_active == UVM_ACTIVE) begin
            sqr = Sqr #(TXN)::type_id::create("sqr", this);
            drv = Drv #(TXN)::type_id::create("drv", this);
        end
        mon = InMon #(TXN)::type_id::create("mon", this);
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


class OutAgt #(
    parameter type TXN = OutTxn
) extends uvm_agent;
    `uvm_component_param_utils(OutAgt #(TXN))

    //  variable definition
    OutMon #(TXN) mon;

    uvm_analysis_port #(TXN) ap;

    function new(string name="OutAgt", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = OutMon #(TXN)::type_id::create("mon", this);
        ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.ap.connect(ap);
    endfunction
endclass


