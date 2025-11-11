//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : FrameFormatObj
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameFormatObj extends uvm_sequence_item;

    //----------
    //  Variable
    //----------
    int unsigned h_active = 0;
    int unsigned h_fp = 0;
    int unsigned h_sync = 0;
    int unsigned h_bp = 0;

    int unsigned v_active = 0;
    int unsigned v_fp = 0;
    int unsigned v_sync = 0;
    int unsigned v_bp = 0;

    bit h_sync_pos = 1;
    bit v_sync_pos = 1;


    //----------
    //  Registry
    //----------

    `uvm_object_utils_begin(FrameFormatObj)
        `uvm_field_int(h_active, UVM_ALL_ON)
        `uvm_field_int(h_fp, UVM_ALL_ON)
        `uvm_field_int(h_sync, UVM_ALL_ON)
        `uvm_field_int(h_bp, UVM_ALL_ON)
        `uvm_field_int(v_active, UVM_ALL_ON)
        `uvm_field_int(v_fp, UVM_ALL_ON)
        `uvm_field_int(v_sync, UVM_ALL_ON)
        `uvm_field_int(v_bp, UVM_ALL_ON)
        `uvm_field_int(h_sync_pos, UVM_ALL_ON)
        `uvm_field_int(v_sync_pos, UVM_ALL_ON)
    `uvm_object_utils_end


    //--------
    //  Method
    //--------

    function new(string name="FrameFormatObj");
        super.new(name);
    endfunction

    function void set_frame_format(
        int unsigned h_active = 1920,
        int unsigned h_fp = 88,
        int unsigned h_sync = 44,
        int unsigned h_bp = 148,

        int unsigned v_active = 1080,
        int unsigned v_fp = 4,
        int unsigned v_sync = 5,
        int unsigned v_bp = 36,

        bit h_sync_pos = 1,
        bit v_sync_pos = 1);

        this.h_active = h_active;
        this.h_fp = h_fp;
        this.h_sync = h_sync;
        this.h_bp = h_bp;

        this.v_active = v_active;
        this.v_fp = v_fp;
        this.v_sync = v_sync;
        this.v_bp = v_bp;

        this.h_sync_pos = h_sync_pos;
        this.v_sync_pos = v_sync_pos;
    endfunction
endclass

