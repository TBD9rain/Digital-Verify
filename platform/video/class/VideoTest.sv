//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoTest
//  Version : 1.1.3
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoBaseTest extends uvm_test;

    `uvm_component_utils(VideoBaseTest)

    localparam DATA_WIDTH = 8;

    //  variable definition
    FrameDataEnv #(DATA_WIDTH) data_env;
    VideoFormatEnv #(DATA_WIDTH) format_env;

    video_timing_t  video_timing;

    function new(string name="VideoBaseTest", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        video_timing = '{1920, 88, 44, 148, 1080, 4, 5, 36, 1, 1};
        video_timing = '{8, 2, 4, 3, 8, 2, 4, 3, 1, 1};
        uvm_config_db #(video_timing_t)::set(this, "data_env.*", "video_timing", video_timing);
        uvm_config_db #(video_timing_t)::set(this, "format_env.*", "video_timing", video_timing);

        uvm_config_db #(int unsigned)::set(this, "data_env.scb", "ref_latency", 1);

        data_env = FrameDataEnv #(DATA_WIDTH)::type_id::create("data_env", this);
        format_env = VideoFormatEnv #(DATA_WIDTH)::type_id::create("format_env", this);

        uvm_config_db#(uvm_object_wrapper)::set(this,
            "data_env.i_agt.sqr.main_phase",
            "default_sequence",
            FrameDataBaseSeq #(DATA_WIDTH)::type_id::get());

        set_report_verbosity_level_hier(UVM_LOW);
    endfunction

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

