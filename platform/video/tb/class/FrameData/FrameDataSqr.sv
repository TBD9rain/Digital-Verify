//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Sqr
//  Version : 1.0.5
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataSqr #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1,
    localparam type REQ = FrameDataTxn #(DATA_WIDTH)
) extends uvm_sequencer #(.REQ (REQ));

    `uvm_component_param_utils(FrameDataSqr #(DATA_WIDTH, PIXEL_PER_CLOCK))

    function new(string name="FrameDataSqr", uvm_component parent=null);
        super.new(name, parent);
    endfunction
endclass
