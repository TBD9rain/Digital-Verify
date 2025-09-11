//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
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
    parameter type REQTXN = InTxn
) extends uvm_sequence #(.REQ (REQTXN));
    `uvm_object_param_utils(BaseSeq #(REQTXN))

    function new(string name="BaseSeq");
        super.new(name);
    endfunction

    virtual task body();
        REQTXN tc_txn;
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


