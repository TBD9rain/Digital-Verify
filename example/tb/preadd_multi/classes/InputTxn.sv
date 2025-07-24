//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.0
//  Title           :   InputTxn
//
//  Description     :   DUT input transaction
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InputTxn #(
    parameter DATA_WIDTH = 8);

    //  variable definition
    randc bit [DATA_WIDTH - 1: 0] data_in_a0;
    randc bit [DATA_WIDTH - 1: 0] data_in_a1;
    randc bit [DATA_WIDTH - 1: 0] data_in_b0;
    randc bit [DATA_WIDTH - 1: 0] data_in_b1;

    //  timing check variable
    longint unsigned timestamp;

    function new(
        input bit [DATA_WIDTH - 1: 0] data_in_a0 = 0,
        input bit [DATA_WIDTH - 1: 0] data_in_a1 = 0,
        input bit [DATA_WIDTH - 1: 0] data_in_b0 = 0,
        input bit [DATA_WIDTH - 1: 0] data_in_b1 = 0,
        input longint unsigned timestamp = 0);

        this.data_in_a0 = data_in_a0;
        this.data_in_a1 = data_in_a1;
        this.data_in_b0 = data_in_b0;
        this.data_in_b1 = data_in_b1;
        this.timestamp = timestamp;
    endfunction

    function string print;
        print = $sformatf({
            "data_in_a0: %0d\n",
            "data_in_a1: %0d\n",
            "data_in_b0: %0d\n",
            "data_in_b1: %0d\n"
            }, data_in_a0, data_in_a1, data_in_b0, data_in_b1);
    endfunction
endclass

