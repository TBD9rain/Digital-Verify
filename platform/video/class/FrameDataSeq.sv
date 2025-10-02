//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : FrameDataSeq
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataSeq #(
    parameter type REQTXN = FrameDataTxn
) extends uvm_sequence #(.REQ (REQTXN));
    `uvm_object_param_utils(FrameDataSeq #(REQTXN))

    //  handler to sequencer
    `uvm_declare_p_sequencer(FrameDataSqr)

    function new(string name="FrameDataSeq");
        super.new(name);
    endfunction

    virtual task body();
        REQTXN tc_txn;

        if (starting_phase != null) begin
            starting_phase.raise_objection(this);

            `uvm_create(tc_txn)
            //  transaction prepare
            tc_txn.frame_width = p_sequencer.video_timing.h_active;
            tc_txn.frame_height = p_sequencer.video_timing.v_active;
            tc_txn.prefix_vsync = 1;
            tc_txn.suffix_vsync = 1;
            tc_txn.alloc_mem();
            tc_txn.gen_color_bar();
            `uvm_send(tc_txn)
        end
        //  delay before drop objection
        starting_phase.phase_done.set_drain_time(this, 1000ns);
        if (starting_phase != null) begin
            starting_phase.drop_objection(this);
        end
    endtask
endclass

