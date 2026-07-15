//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Cov
//  Version : 1.0.0
//
//  Description
//      Functional coverage collector for the input frame data stream.
//      Enabled by VideoConfig.cov_en; fed from the input agent analysis port.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataCov #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1
) extends uvm_component;

    `uvm_component_param_utils(FrameDataCov #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    uvm_blocking_get_port #(TXN) imon_getp;

    TXN cov_txn;

    //  Reference only - adapt the cover points to the real coverage goals.
    covergroup frame_cg;
        cp_frame_width  : coverpoint cov_txn.frame_width;
        cp_frame_height : coverpoint cov_txn.frame_height;
    endgroup

    function new(string name="FrameDataCov", uvm_component parent=null);
        super.new(name, parent);
        frame_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imon_getp = new("imon_getp", this);
    endfunction

    task main_phase(uvm_phase phase);
        forever begin
            imon_getp.get(cov_txn);
            frame_cg.sample();
        end
    endtask
endclass
