//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Seq
//  Version : 1.0.7
//
//  Description
//      Sends a color-bar frame followed by a frame read from a binary file.
//      Video timing and the frame data file path are taken from the VideoConfig held by the
//      sequencer.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataBaseSeq #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1,
    localparam type REQ = FrameDataTxn #(DATA_WIDTH)
) extends uvm_sequence #(.REQ (REQ));

    `uvm_object_param_utils(FrameDataBaseSeq #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  handler to sequencer
    `uvm_declare_p_sequencer(FrameDataSqr #(DATA_WIDTH, PIXEL_PER_CLOCK))

    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    function new(string name="FrameDataBaseSeq");
        super.new(name);
    endfunction

    virtual task pre_start();
        super.pre_start();

        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(p_sequencer, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("FrameDataBaseSeq", "video configuration is not set.")
        end
    endtask

    virtual task body();
        REQ txn;

        //  color-bar frame
        txn = REQ::type_id::create("txn");
        start_item(txn);
        txn.frame_width = video_cfg.frame_cfg.h_active;
        txn.frame_height = video_cfg.frame_cfg.v_active;
        txn.prefix_vsync = 1;
        txn.suffix_vsync = 1;
        txn.alloc_mem();
        txn.gen_color_bar();
        finish_item(txn);

        //  frame read from binary file
        txn = REQ::type_id::create("txn");
        start_item(txn);
        txn.frame_width = video_cfg.frame_cfg.h_active;
        txn.frame_height = video_cfg.frame_cfg.v_active;
        txn.prefix_vsync = 0;
        txn.suffix_vsync = 1;
        txn.alloc_mem();
        txn.read_bin_frame(video_cfg.frame_data_file_path);
        finish_item(txn);

        //  notify the row-timing scoreboard that all frames have been sent
        uvm_config_db #(bit)::set(null, "uvm_test_top.*", "frame_data_seq_done", 1);
    endtask
endclass
