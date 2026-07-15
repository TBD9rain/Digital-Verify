//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : FrameConfig
//  Version : 1.0.0
//
//  Description
//      Video frame timing configuration.
//      Successor of the former FrameFormatObj: holds the horizontal / vertical timing and the
//      sync polarities, populated through set_frame_format().
//
//  Additional info
//      Horizontal timing (h_active / h_fp / h_sync / h_bp) is expressed in pixels.
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameConfig extends uvm_object;

    `uvm_object_utils(FrameConfig)

    //----------
    //  Variable
    //----------

    int unsigned h_active = 0;
    int unsigned h_fp     = 0;
    int unsigned h_sync   = 0;
    int unsigned h_bp     = 0;

    int unsigned v_active = 0;
    int unsigned v_fp     = 0;
    int unsigned v_sync   = 0;
    int unsigned v_bp     = 0;

    bit h_sync_pos = 1;
    bit v_sync_pos = 1;


    //--------
    //  Method
    //--------

    function new(string name="FrameConfig");
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
