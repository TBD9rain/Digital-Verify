//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.0
//  Title           :   OutputTxn
//
//  Description     :   output data transaction
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class OutputTxn #(
    parameter DATA_WIDTH = 9);

    //  variable definition
    logic [DATA_WIDTH - 1: 0] sum;

    //  timing check variable
    longint unsigned timestamp;

    function new(
        input logic [DATA_WIDTH - 1: 0] sum = 0,
        input longint unsigned timestamp = 0);

        this.sum = sum;
        this.timestamp = timestamp;
    endfunction

    function string print;
        print = $sformatf("sum: %0d\n", sum);
    endfunction

    function bit compare(
        input OutputTxn txn);

        compare = (txn.sum === sum);
    endfunction
endclass

