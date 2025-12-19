//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.2
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
) extends uvm_sequence #(.REQ (REQ));

    `uvm_object_param_utils(BaseSeq #(DATA_WIDTH))

    function new(string name="BaseSeq");
        super.new(name);
    endfunction

    virtual task pre_start();
        super.pre_start();

        if (starting_phase == null) begin
            if (get_parent_sequence() != null) begin
                starting_phase = get_parent_sequence().starting_phase;
            end
            else begin
                `uvm_fatal("BaseSeq", "starting_phase is null.")
            end
        end
    endtask

    virtual task body();
        REQ tc_txn;

        starting_phase.raise_objection(this);

        repeat (10) begin
            `uvm_do(tc_txn)
        end

        //  delay before drop objection
        starting_phase.phase_done.set_drain_time(this, 1000ns);

        starting_phase.drop_objection(this);
    endtask
endclass


