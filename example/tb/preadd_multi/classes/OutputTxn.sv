//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   OutputTxn
//
//  Description     :   DUT Output transaction
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class OutputTxn #(
    parameter DATA_WIDTH = 18);

    //  variable definition
    logic [DATA_WIDTH - 1: 0] data_out;

    //  timing check variable
    longint unsigned timestamp;

    function new(
        input logic [DATA_WIDTH - 1: 0] data_out = 0,
        input longint unsigned timestamp = 0);

        this.data_out = data_out;
        this.timestamp = timestamp;
    endfunction
endclass

