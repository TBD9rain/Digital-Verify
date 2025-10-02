//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : FrameDataSqr
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataSqr #(
    parameter type REQTXN = FrameDataTxn
) extends uvm_sequencer #(.REQ (REQTXN));
    `uvm_component_param_utils(FrameDataSqr #(REQTXN))

    video_timing_t video_timing;

    function new(string name="FrameDataSqr", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(video_timing_t)::get(this, "", "video_timing", video_timing)) begin
            `uvm_fatal(get_name(), "video timing is not set.")
        end
    endfunction
endclass

