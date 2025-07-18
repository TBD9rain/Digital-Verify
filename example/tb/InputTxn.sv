//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   InputTxn
//
//  Description     :   input data transaction
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InputTxn #(
    parameter DATA_WIDTH = 8);

    //  variable definition
    randc bit [DATA_WIDTH - 1: 0] addend0;
    randc bit [DATA_WIDTH - 1: 0] addend1;

    //  timing check variable
    longint unsigned timestamp;

    function new(
        input bit [DATA_WIDTH - 1: 0] addend0 = 0,
        input bit [DATA_WIDTH - 1: 0] addend1 = 0,
        input longint unsigned timestamp = 0);

        this.addend0 = addend0;
        this.addend1 = addend1;
        this.timestamp = timestamp;
    endfunction
endclass

