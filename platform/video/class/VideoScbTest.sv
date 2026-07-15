//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoScbTest
//  Version : 1.0.0
//
//  Description
//      Scoreboard-verification test. Extends the base test and enables fault injection so the
//      scoreboard is expected to report mismatches. The pass/fail logic is inverted: injected
//      faults that raise scoreboard errors mean the scoreboard works; zero errors means the
//      scoreboard failed to catch them.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoScbTest extends VideoBaseTest;

    `uvm_component_utils(VideoScbTest)

    function new(string name="VideoScbTest", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //  inject faults on the DUT output so the scoreboard is expected to report mismatches
        video_cfg.fault_inject_en = 1;
        video_cfg.cov_en = 0;

        //  do not abort on the injected errors
        uvm_report_server::get_server().set_max_quit_count(0);
        set_report_verbosity_level_hier(UVM_LOW);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server rpt_ser;
        int err_num;

        rpt_ser = get_report_server();
        err_num = rpt_ser.get_severity_count(UVM_ERROR);

        if (err_num == 0) begin
            $write("\n");
            $write("=======================\n");
            $write("Scoreboard Test FAILED.\n");
            $write("=======================\n");
            $write("\n");
        end
        else begin
            $write("\n");
            $write("=======================\n");
            $write("Scoreboard Test PASSED.\n");
            $write("=======================\n");
            $write("\n");
        end
    endfunction
endclass
