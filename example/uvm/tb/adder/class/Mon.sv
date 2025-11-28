//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.6
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
    parameter int DATA_WIDTH = 8
) extends uvm_monitor;
    `uvm_component_param_utils(InMon #(DATA_WIDTH))

    //  variable definition
    typedef InTxn #(DATA_WIDTH) TXN;
    typedef virtual adder_if#(.DATA_WIDTH (DATA_WIDTH)).mon_mp mon_vif;

    mon_vif vif;

    uvm_analysis_port #(TXN) ap;

    function new(string name="InMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(mon_vif)::get(this, "", "vif", vif)) begin
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

        @(posedge vif.clk);
        while (vif.data_in_vld !== 1) begin
            @(posedge vif.clk);
        end
        txn = TXN::type_id::create("txn");
        txn.addend0 = vif.addend0;
        txn.addend1 = vif.addend1;
        txn.timestamp = vif.clk_cnt;
    endtask
endclass


class OutMon #(
    parameter int DATA_WIDTH = 8,
    localparam type TXN = OutTxn #(DATA_WIDTH)
) extends uvm_monitor;
    `uvm_component_param_utils(OutMon #(DATA_WIDTH))

    //  variable definition
    typedef virtual adder_if#(.DATA_WIDTH (DATA_WIDTH)).mon_mp mon_vif;
    mon_vif vif;

    uvm_analysis_port #(TXN) ap;

    function new(string name="OutMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(mon_vif)::get(this, "", "vif", vif)) begin
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

        @(posedge vif.clk);
        while (vif.data_out_vld !== 1) begin
            @(posedge vif.clk);
        end
        txn = TXN::type_id::create("txn");
        txn.sum = vif.sum;
        txn.timestamp = vif.clk_cnt;
    endtask
endclass


