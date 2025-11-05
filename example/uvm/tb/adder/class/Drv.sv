//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.2
//  Title           :   Drv
//
//  Description     :   driver class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class Drv #(
    parameter type REQTXN = InTxn
) extends uvm_driver #(.REQ (REQTXN));
    `uvm_component_param_utils(Drv #(REQTXN))

    //  variable definition
    typedef virtual adder_if#(.DATA_WIDTH (8)).drv_mp drv_vif;
    drv_vif vif;

    function new(string name="Drv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(drv_vif)::get(this, "", "vif", vif)) begin
            `uvm_fatal("Drv", "Virtual interface is not set.")
        end
    endfunction

    task reset_phase(uvm_phase phase);
        vif.cb.data_in_vld <= 0;
        vif.cb.addend0 <= 0;
        vif.cb.addend1 <= 0;
    endtask

    task main_phase(uvm_phase phase);
        while(!vif.rst_n) begin
            @vif.cb;
        end
        forever begin
            seq_item_port.get_next_item(req);
            drive_req(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_req;
        input REQ txn;

        vif.cb.data_in_vld <= 1;
        vif.cb.addend0 <= txn.addend0;
        vif.cb.addend1 <= txn.addend1;
        @vif.cb
        vif.cb.data_in_vld <= 0;
        vif.cb.addend0 <= 0;
        vif.cb.addend1 <= 0;
    endtask
endclass


