//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   Seq
//
//  Description     :   sequence definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class BaseSeq #(
    parameter int DATA_WIDTH = 8,
    localparam type REQ = InTxn #(DATA_WIDTH)
) extends uvm_sequence #(REQ);
    `uvm_object_param_utils(BaseSeq #(DATA_WIDTH))

    function new(string name="BaseSeq");
        super.new(name);
    endfunction

    virtual task body();
        REQ tc_txn;
        uvm_phase phase;

        if (starting_phase != null) begin
            starting_phase.raise_objection(this);
            repeat (10) begin
                `uvm_do(tc_txn)
            end
        end
        //  delay before drop objection
        starting_phase.phase_done.set_drain_time(this, 1000ns);
        if (starting_phase != null) begin
            starting_phase.drop_objection(this);
        end
    endtask
endclass


