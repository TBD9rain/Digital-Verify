//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   InMon
//
//  Description     :   monitor class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InMon #(
    parameter type TXN = InTxn
) extends uvm_monitor;
    `uvm_component_param_utils(InMon #(TXN))

    //  variable definition
    virtual interface adder_if.mon_mp vif;

    uvm_analysis_port #(TXN) ap;

    function new(string name="InMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual adder_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("InMon", "Virtual interface is not set.")
        end
        ap = new("ap", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN txn;

        forever begin
            sample_txn(txn);
            ap.write(txn);
        end
    endtask

    task sample_txn;
        output TXN txn;

        @vif.mon_cb;
        while (vif.mon_cb.data_in_vld !== 1) begin
            @vif.mon_cb;
        end
        txn = TXN::type_id::create("txn");
        txn.addend0 = vif.mon_cb.addend0;
        txn.addend1 = vif.mon_cb.addend1;
    endtask
endclass


class OutMon #(
    parameter type TXN = OutTxn
) extends uvm_monitor;
    `uvm_component_param_utils(OutMon #(TXN))

    //  variable definition
    virtual interface adder_if.mon_mp vif;

    uvm_analysis_port #(TXN) ap;

    function new(string name="OutMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual adder_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("OutMon", "Virtual interface is not set.")
        end
        ap = new("ap", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN txn;

        forever begin
            sample_txn(txn);
            ap.write(txn);
        end
    endtask

    task sample_txn;
        output TXN txn;

        @vif.mon_cb
        while (vif.mon_cb.data_out_vld !== 1) begin
            @vif.mon_cb;
        end
        txn = TXN::type_id::create("txn");
        txn.sum = vif.mon_cb.sum;
    endtask
endclass


