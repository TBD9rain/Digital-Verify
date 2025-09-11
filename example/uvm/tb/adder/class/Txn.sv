//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   Txn
//
//  Description     :   transaction class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InTxn #(
    parameter   DATA_WIDTH = 8
) extends uvm_sequence_item;

    //  variable Definition
    rand bit [DATA_WIDTH - 1: 0] addend0;
    rand bit [DATA_WIDTH - 1: 0] addend1;

    function new(string name="InTxn");
        super.new(name);
    endfunction

    `uvm_object_param_utils_begin(InTxn #(DATA_WIDTH))
        `uvm_field_int(addend0, UVM_ALL_ON)
        `uvm_field_int(addend1, UVM_ALL_ON)
    `uvm_object_utils_end
endclass


class OutTxn #(
    parameter   DATA_WIDTH = 9
) extends uvm_sequence_item;

    //  variable Definition
    logic [DATA_WIDTH - 1: 0] sum;

    function new(string name="OutTxn");
        super.new(name);
    endfunction

    `uvm_object_param_utils_begin(OutTxn #(DATA_WIDTH))
        `uvm_field_int(sum, UVM_ALL_ON)
    `uvm_object_utils_end
endclass


