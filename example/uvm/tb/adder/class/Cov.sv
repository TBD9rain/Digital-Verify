//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   Cov
//
//  Description     :   coverage collector class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class Cov #(
    parameter int DATA_WIDTH = 8,
    localparam type TXN = InTxn #(DATA_WIDTH)
) extends uvm_subscriber #(TXN);
    `uvm_component_param_utils(Cov #(DATA_WIDTH))

    //  variable definition
    uvm_blocking_get_port #(TXN) imon_getp;
    TXN tc_txn;

    //  coverage group definition
    covergroup adder_cov;
        //  coverage point definition
        addend0: coverpoint tc_txn.addend0 {
            //  bins definition
            bins a0[] = {[  0:255]};
        }
        addend1: coverpoint tc_txn.addend1 {
            //  bins definition
            bins a1[] = {[  0:255]};
        }
    endgroup

    function new(string name="Cov", uvm_component parent=null);
        super.new(name, parent);
        this.adder_cov = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imon_getp = new("imon_getp", this);
    endfunction

    task main_phase(uvm_phase phase);
        forever begin
            imon_getp.get(tc_txn);
            adder_cov.sample();
        end
    endtask

    function void write(T t);
    endfunction
endclass


