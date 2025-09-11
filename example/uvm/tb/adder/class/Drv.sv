//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
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
    virtual interface adder_if.drv_mp vif;

    function new(string name="Drv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual adder_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("Drv", "Virtual interface is not set.")
        end
    endfunction

    task reset_phase(uvm_phase phase);
        vif.drv_cb.data_in_vld <= 0;
        vif.drv_cb.addend0 <= 0;
        vif.drv_cb.addend1 <= 0;
    endtask

    task main_phase(uvm_phase phase);
        while(!vif.rst_n) begin
            @vif.drv_cb;
        end
        forever begin
            seq_item_port.get_next_item(req);
            drive_req(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_req;
        input REQ txn;

        vif.drv_cb.data_in_vld <= 1;
        vif.drv_cb.addend0 <= txn.addend0;
        vif.drv_cb.addend1 <= txn.addend1;
        @vif.drv_cb
        vif.drv_cb.data_in_vld <= 0;
        vif.drv_cb.addend0 <= 0;
        vif.drv_cb.addend1 <= 0;
    endtask
endclass


