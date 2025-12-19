//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Seq
//  Version : 1.0.6
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataBaseSeq #(
    parameter int DATA_WIDTH = 8,
    localparam type REQ = FrameDataTxn #(DATA_WIDTH)
) extends uvm_sequence #(.REQ (REQ));

    `uvm_object_param_utils(FrameDataBaseSeq #(DATA_WIDTH))

    //  handler to sequencer
    `uvm_declare_p_sequencer(FrameDataSqr)


    function new(string name="FrameDataBaseSeq");
        super.new(name);
    endfunction

    virtual task pre_start();
        super.pre_start();

        if (starting_phase == null) begin
            if (get_parent_sequence() != null) begin
                starting_phase = get_parent_sequence().starting_phase;
            end
            else begin
                `uvm_fatal("FrameDataBaseSeq", "starting_phase is null.")
            end
        end
    endtask

    virtual task body();
        REQ tc_txn;

        starting_phase.raise_objection(this);

        `uvm_create(tc_txn)
        //  transaction prepare
        tc_txn.frame_width = p_sequencer.frame_format.h_active;
        tc_txn.frame_height = p_sequencer.frame_format.v_active;
        tc_txn.prefix_vsync = 1;
        tc_txn.suffix_vsync = 1;
        tc_txn.alloc_mem();
        tc_txn.gen_color_bar();
        `uvm_send(tc_txn)

        `uvm_create(tc_txn)
        //  transaction prepare
        tc_txn.frame_width = p_sequencer.frame_format.h_active;
        tc_txn.frame_height = p_sequencer.frame_format.v_active;
        tc_txn.prefix_vsync = 0;
        tc_txn.suffix_vsync = 1;
        tc_txn.alloc_mem();
        tc_txn.read_bin_frame(p_sequencer.frame_data_file_path);
        `uvm_send(tc_txn)

        uvm_config_db #(bit)::set(null, "uvm_test_top.*", "frame_data_seq_done", 1);
        //  delay before drop objection
        starting_phase.phase_done.set_drain_time(this, 1000ns);

        starting_phase.drop_objection(this);
    endtask
endclass

