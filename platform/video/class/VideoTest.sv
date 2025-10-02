//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoTest
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoTest extends uvm_test;
    `uvm_component_utils(VideoTest)

    localparam DATA_WIDTH = 8;

    localparam type TXN = FrameDataTxn #(DATA_WIDTH);
    localparam longint unsigned LATENCY = 1;

    //  variable definition
    FrameDataEnv #(TXN, LATENCY) env;

    video_timing_t  video_timing;

    function new(string name="VideoTest", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_db#(uvm_object_wrapper)::set(this,
            "env.i_agt.sqr.main_phase",
            "default_sequence",
            FrameDataSeq #(TXN)::type_id::get());
        env = FrameDataEnv #(TXN, LATENCY)::type_id::create("env", this);

        video_timing = '{1920, 88, 44, 148, 1080, 4, 5, 36, 1, 1};
        uvm_config_db #(video_timing_t)::set(this, "env.*", "video_timing", video_timing);

        set_report_verbosity_level_hier(UVM_MEDIUM);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server rpt_ser;
        int err_num;

        super.report_phase(phase);
        rpt_ser = get_report_server();
        err_num = rpt_ser.get_severity_count(UVM_ERROR);

        if (err_num) begin
            $write("\nTest failed.\n");
        end
        else begin
            $write("\nTest passed.\n");
        end
    endfunction

    virtual function void final_phase (uvm_phase phase);
        super.final_phase(phase);

        $stop(2);
    endfunction
endclass

