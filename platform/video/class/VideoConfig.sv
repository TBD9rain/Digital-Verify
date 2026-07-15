//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoConfig
//  Version : 1.0.0
//
//  Description
//      Central video configuration object.
//      Bundles the virtual interface handle, the frame timing (FrameConfig), pixel-per-clock, the
//      frame data file path, the expected DUT latency and the input agent activeness.
//
//  Additional info
//      Parameterized by PIXEL_PER_CLOCK so the held virtual interface matches the TB instance.
//      pixel_per_clock (the field) mirrors the PIXEL_PER_CLOCK parameter for reporting.
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoConfig #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1
) extends uvm_object;

    `uvm_object_param_utils(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //----------
    //  Variable
    //----------

    //  virtual interface handle (generic; components derive their modport view)
    virtual video_if #(DATA_WIDTH, PIXEL_PER_CLOCK) vif;

    //  frame timing
    FrameConfig frame_cfg;

    //  pixels transferred per clock (mirrors the PIXEL_PER_CLOCK parameter)
    int unsigned pixel_per_clock = PIXEL_PER_CLOCK;

    //  frame data binary file
    string frame_data_file_path = "data.bin";

    //  expected DUT latency in clocks (used by the scoreboard)
    int unsigned ref_latency = 0;

    //  input (stimulus) agent activeness
    uvm_active_passive_enum video_drv_en = UVM_ACTIVE;

    //  scoreboard enable
    bit scb_en = 1;


    //--------
    //  Method
    //--------

    function new(string name="VideoConfig");
        super.new(name);
    endfunction

    //  check that the horizontal timing can be mapped to whole clocks
    function void validate();
        if (frame_cfg == null) begin
            `uvm_fatal("VideoConfig", "frame_cfg is not set.")
        end
        if (PIXEL_PER_CLOCK == 0) begin
            `uvm_fatal("VideoConfig", "PIXEL_PER_CLOCK must be greater than 0.")
        end
        if ((frame_cfg.h_active % PIXEL_PER_CLOCK != 0) ||
            (frame_cfg.h_fp     % PIXEL_PER_CLOCK != 0) ||
            (frame_cfg.h_sync   % PIXEL_PER_CLOCK != 0) ||
            (frame_cfg.h_bp     % PIXEL_PER_CLOCK != 0)) begin
            `uvm_fatal("VideoConfig",
                $sformatf("horizontal timing must be divisible by PIXEL_PER_CLOCK (=%0d).",
                    PIXEL_PER_CLOCK))
        end
    endfunction
endclass
