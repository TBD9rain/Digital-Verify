//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
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
    parameter int DATA_WIDTH = 8,
    localparam type REQ = InTxn #(DATA_WIDTH)
) extends uvm_sequencer #(REQ);
    `uvm_component_param_utils(Sqr #(DATA_WIDTH))

    function new(string name="Sqr", uvm_component parent=null);
        super.new(name, parent);
    endfunction
endclass


