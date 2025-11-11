//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Sqr
//  Version : 1.0.1
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataSqr #(
    parameter DATA_WIDTH = 8,
    localparam type REQ = FrameDataTxn
) extends uvm_sequencer #(.REQ (REQ));

    `uvm_component_param_utils(FrameDataSqr #(DATA_WIDTH))

    video_timing_t video_timing;

    function new(string name="FrameDataSqr", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(video_timing_t)::get(this, "", "video_timing", video_timing)) begin
            `uvm_fatal("FrameDataSqr", "video timing is not set.")
        end
    endfunction
endclass

