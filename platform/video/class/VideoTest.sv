//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoTest
//  Version : 1.2.0
//
//  Description
//      Base video test. Obtains the VideoConfig from the TB, fills in the FrameConfig, frame data
//      file, expected latency and driver activeness, distributes it to each environment, and starts
//      the frame data sequence on the input sequencer.
//      Environments are specialized on the local PIXEL_PER_CLOCK, which must match the video_tb
//      parameter of the same name.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoBaseTest extends uvm_test;

    `uvm_component_utils(VideoBaseTest)

    localparam DATA_WIDTH = 8;
    localparam PIXEL_PER_CLOCK = 1;

    //  variable definition
    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    FrameDataEnv #(DATA_WIDTH, PIXEL_PER_CLOCK) data_env;
    FrameRowCtrlEnv #(DATA_WIDTH, PIXEL_PER_CLOCK) format_env;

    function new(string name="VideoBaseTest", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(this, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("VideoBaseTest", "video configuration is not set.")
        end

        //  frame timing (small frame for simulation; horizontal timing kept even so that
        //  PIXEL_PER_CLOCK up to 2 divides evenly)
        video_cfg.frame_cfg = FrameConfig::type_id::create("frame_cfg");
        video_cfg.frame_cfg.set_frame_format(8, 2, 4, 6, 8, 2, 4, 6, 1, 1);
        video_cfg.frame_data_file_path = "data.bin";
        video_cfg.ref_latency = 1;
        video_cfg.video_drv_en = UVM_ACTIVE;
        video_cfg.validate();

        //  distribute the configuration to each environment
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "data_env", "video_cfg", video_cfg);
        uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::set(this, "format_env", "video_cfg", video_cfg);

        data_env = FrameDataEnv #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("data_env", this);
        format_env = FrameRowCtrlEnv #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("format_env", this);

        //  simulation exit due to too many errors
        uvm_report_server::get_server().set_max_quit_count(20);

        set_report_verbosity_level_hier(UVM_LOW);
    endfunction

    virtual task main_phase(uvm_phase phase);
        FrameDataBaseSeq #(DATA_WIDTH, PIXEL_PER_CLOCK) seq;

        phase.raise_objection(this);

        //  control sequence start
        seq = FrameDataBaseSeq #(DATA_WIDTH, PIXEL_PER_CLOCK)::type_id::create("seq");
        seq.start(data_env.i_agt.sqr);

        //  delay before drop objection
        phase.phase_done.set_drain_time(this, 1000ns);
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server rpt_ser;
        int err_num;

        super.report_phase(phase);
        rpt_ser = get_report_server();
        err_num = rpt_ser.get_severity_count(UVM_ERROR);

        if (err_num) begin
            $write("\n");
            $write("============\n");
            $write("Test FAILED.\n");
            $write("============\n");
            $write("\n");
        end
        else begin
            $write("\n");
            $write("============\n");
            $write("Test PASSED.\n");
            $write("============\n");
            $write("\n");
        end
    endfunction

    virtual function void final_phase (uvm_phase phase);
        super.final_phase(phase);

        $stop(2);
    endfunction
endclass
