//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Drv
//  Version : 1.0.5
//
//  Description
//      Drives the video stream, PIXEL_PER_CLOCK pixels per clock.
//      Pixel k occupies bits [k*3*DATA_WIDTH +: 3*DATA_WIDTH] of the packed pixel bus.
//      Horizontal timing is specified in pixels and converted to whole clocks internally.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataDrv #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1,
    localparam type REQ = FrameDataTxn #(DATA_WIDTH)
) extends uvm_driver #(.REQ (REQ));

    `uvm_component_param_utils(FrameDataDrv #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  variable definition
    localparam int PIX_W = 3*DATA_WIDTH;

    virtual video_if #(DATA_WIDTH, PIXEL_PER_CLOCK).drv_mp vif;
    
    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    //  timing in pixels / lines
    int unsigned h_active;
    int unsigned h_fp;
    int unsigned h_sync;
    int unsigned h_bp;

    int unsigned v_active;
    int unsigned v_fp;
    int unsigned v_sync;
    int unsigned v_bp;

    bit h_sync_pos;
    bit v_sync_pos;

    //  horizontal timing in clocks (pixels / PIXEL_PER_CLOCK)
    int unsigned h_active_clk;
    int unsigned h_fp_clk;
    int unsigned h_sync_clk;
    int unsigned h_bp_clk;

    function new(string name="FrameDataDrv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(this, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("FrameDataDrv", "video configuration is not set.")
        end
        video_cfg.validate();

        vif = video_cfg.vif;

        h_active = video_cfg.frame_cfg.h_active;
        h_fp     = video_cfg.frame_cfg.h_fp;
        h_sync   = video_cfg.frame_cfg.h_sync;
        h_bp     = video_cfg.frame_cfg.h_bp;

        v_active = video_cfg.frame_cfg.v_active;
        v_fp     = video_cfg.frame_cfg.v_fp;
        v_sync   = video_cfg.frame_cfg.v_sync;
        v_bp     = video_cfg.frame_cfg.v_bp;

        h_sync_pos = video_cfg.frame_cfg.h_sync_pos;
        v_sync_pos = video_cfg.frame_cfg.v_sync_pos;

        h_active_clk = h_active / PIXEL_PER_CLOCK;
        h_fp_clk     = h_fp     / PIXEL_PER_CLOCK;
        h_sync_clk   = h_sync   / PIXEL_PER_CLOCK;
        h_bp_clk     = h_bp     / PIXEL_PER_CLOCK;
    endfunction

    task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        vif.cb.vin_vsync <= 'b0;
        vif.cb.vin_hsync <= 'b0;
        vif.cb.vin_de    <= 'b0;
        vif.cb.vin_pix   <= 'b0;
        phase.drop_objection(this);
    endtask

    task pre_main_phase(uvm_phase phase);
        phase.raise_objection(this);
        while (!vif.rst_n) begin
            @vif.cb;
        end
        phase.drop_objection(this);
    endtask

    task main_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_req(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_req(REQ txn);
        int x, y, k;

        if (txn.frame_height != v_active || txn.frame_width != h_active) begin
            `uvm_fatal("FrameDataDrv", "video timing does not match transaction frame size.")
        end

        vif.cb.vin_de  <= 'b0;
        vif.cb.vin_pix <= 'b0;

        if (txn.prefix_vsync) begin
            drv_vsync;
        end

        //  video frame
        for (y = 0; y < v_active; y++) begin
            vif.cb.vin_hsync <= h_sync_pos;
            repeat (h_sync_clk) @vif.cb;
            vif.cb.vin_hsync <= ~h_sync_pos;
            repeat (h_bp_clk) @vif.cb;
            for (x = 0; x < h_active; x = x + PIXEL_PER_CLOCK) begin
                vif.cb.vin_de <= 1'b1;
                for (k = 0; k < PIXEL_PER_CLOCK; k++) begin
                    vif.cb.vin_pix[k*PIX_W +: PIX_W] <= txn.frame_data[h_active*y + x + k];
                end
                @vif.cb;
            end
            vif.cb.vin_de  <= 1'b0;
            vif.cb.vin_pix <= 'b0;
            repeat (h_fp_clk) @vif.cb;
        end

        if (txn.suffix_vsync) begin
            drv_vsync;
        end
    endtask

    task drv_vsync;
        //  V blank front porch
        vif.cb.vin_vsync <= ~v_sync_pos;
        repeat (v_fp) begin
            vif.cb.vin_hsync <= h_sync_pos;
            repeat (h_sync_clk) @vif.cb;
            vif.cb.vin_hsync <= ~h_sync_pos;
            repeat (h_bp_clk) @vif.cb;
            repeat (h_active_clk) @vif.cb;
            repeat (h_fp_clk) @vif.cb;
        end

        //  V blank sync
        vif.cb.vin_vsync <= v_sync_pos;
        repeat (v_sync) begin
            vif.cb.vin_hsync <= h_sync_pos;
            repeat (h_sync_clk) @vif.cb;
            vif.cb.vin_hsync <= ~h_sync_pos;
            repeat (h_bp_clk) @vif.cb;
            repeat (h_active_clk) @vif.cb;
            repeat (h_fp_clk) @vif.cb;
        end

        //  V blank back porch
        vif.cb.vin_vsync <= ~v_sync_pos;
        repeat (v_bp) begin
            vif.cb.vin_hsync <= h_sync_pos;
            repeat (h_sync_clk) @vif.cb;
            vif.cb.vin_hsync <= ~h_sync_pos;
            repeat (h_bp_clk) @vif.cb;
            repeat (h_active_clk) @vif.cb;
            repeat (h_fp_clk) @vif.cb;
        end
    endtask
endclass
