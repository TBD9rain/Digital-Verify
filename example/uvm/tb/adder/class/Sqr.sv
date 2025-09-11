//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   Sqr
//
//  Description     :   sequencer class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class Sqr #(
    parameter type REQTXN = InTxn
) extends uvm_sequencer #(.REQ (REQTXN));
    `uvm_component_param_utils(Sqr #(REQTXN))

    function new(string name="Sqr", uvm_component parent=null);
        super.new(name, parent);
    endfunction
endclass


