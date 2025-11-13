//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Sqr
//  Version : 1.0.3
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

    FrameFormatObj frame_format;
    string frame_data_file_path;

    function new(string name="FrameDataSqr", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(FrameFormatObj)::get(this, "", "frame_format", frame_format)) begin
            `uvm_fatal("FrameDataSqr", "frame format is not set.")
        end
        if (!uvm_config_db #(string)::get(this, "", "frame_data_file_path", frame_data_file_path)) begin
            `uvm_fatal("FrameDataSqr", "frame data file path is not set.")
        end
    endfunction
endclass

