//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   Mdl
//
//  Description     :   reference model class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class Mdl #(
    parameter type ITXN = InTxn,
    parameter type OTXN = OutTxn
) extends uvm_component;
    `uvm_component_param_utils(Mdl #(ITXN, OTXN))

    //  variable definition
    uvm_blocking_get_port #(ITXN) imon_getp;
    uvm_blocking_put_port #(OTXN) scb_putp;

    function new(string name="Mdl", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imon_getp = new("imon_getp", this);
        scb_putp = new("scb_putp", this);
    endfunction

    task main_phase(uvm_phase phase);
        ITXN mon_txn;
        OTXN exp_txn;

        forever begin
            imon_getp.get(mon_txn);
            ref_proc(mon_txn, exp_txn);
            scb_putp.put(exp_txn);
        end
    endtask

    task ref_proc(
        const ref ITXN in_txn,
        output OTXN out_txn);

        out_txn = OTXN::type_id::create("out_txn");
        out_txn.sum = in_txn.addend0 + in_txn.addend1;
    endtask
endclass


