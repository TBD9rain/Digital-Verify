//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : FrameDataDrv
//  Version : 1.0.1
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataDrv #(
    parameter int DATA_WIDTH = 8,
    localparam type REQ = FrameDataTxn
) extends uvm_driver #(.REQ (REQ));

    `uvm_component_param_utils(FrameDataDrv #(DATA_WIDTH))

    //  variable definition
    typedef virtual video_if #(DATA_WIDTH).drv_mp drv_vif;

    drv_vif vif;
    video_timing_t video_timing;

    function new(string name="FrameDataDrv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(drv_vif)::get(this, "", "vif", vif)) begin
            `uvm_fatal("FrameDataDrv", "Virtual interface is not set.")
        end
        if (!uvm_config_db #(video_timing_t)::get(this, "", "video_timing", video_timing)) begin
            `uvm_fatal("FrameDataDrv", "video timing is not set.")
        end
    endfunction

    task reset_phase(uvm_phase phase);
    endtask

    task main_phase(uvm_phase phase);
        while(!vif.rst_n) begin
            @vif.cb;
        end
        forever begin
            seq_item_port.get_next_item(req);
            drive_req(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_req(REQ txn);
        int x, y;

        if (txn.frame_height != video_timing.v_active || txn.frame_width != video_timing.h_active) begin
            `uvm_fatal("FrameDataDrv", "video timing does not match transaction frame size.")
        end

        vif.cb.vin_de   <= 'b0;
        vif.cb.vin_data <= 'b0;

        if (txn.prefix_vsync) begin
            drv_vsync;
        end

        //  video frame
        for (y = 0; y < video_timing.v_active; y++) begin
            vif.cb.vin_hsync <= video_timing.h_sync_pos;
            repeat (video_timing.h_sync) @vif.cb;
            vif.cb.vin_hsync <= ~video_timing.h_sync_pos;
            repeat (video_timing.h_bp) @vif.cb;
            for (x = 0; x < video_timing.h_active; x++) begin
                vif.cb.vin_de   <= 1'b1;
                vif.cb.vin_data <= txn.frame_data[video_timing.h_active*y + x];
                @vif.cb;
            end
            vif.cb.vin_de   <= 1'b0;
            vif.cb.vin_data <= 'b0;
            repeat (video_timing.h_fp) @vif.cb;
        end

        if (txn.suffix_vsync) begin
            drv_vsync;
        end
    endtask

    task drv_vsync;
        //  V blank front porch
        vif.cb.vin_vsync <= ~video_timing.v_sync_pos;
        repeat (video_timing.v_fp) begin
            vif.cb.vin_hsync <= video_timing.h_sync_pos;
            repeat (video_timing.h_sync) @vif.cb;
            vif.cb.vin_hsync <= ~video_timing.h_sync_pos;
            repeat (video_timing.h_bp) @vif.cb;
            repeat (video_timing.h_active) @vif.cb;
            repeat (video_timing.h_fp) @vif.cb;
        end

        //  V blank sync
        vif.cb.vin_vsync <= video_timing.v_sync_pos;
        repeat (video_timing.v_sync) begin
            vif.cb.vin_hsync <= video_timing.h_sync_pos;
            repeat (video_timing.h_sync) @vif.cb;
            vif.cb.vin_hsync <= ~video_timing.h_sync_pos;
            repeat (video_timing.h_bp) @vif.cb;
            repeat (video_timing.h_active) @vif.cb;
            repeat (video_timing.h_fp) @vif.cb;
        end

        //  V blank back porch
        vif.cb.vin_vsync <= ~video_timing.v_sync_pos;
        repeat (video_timing.v_bp) begin
            vif.cb.vin_hsync <= video_timing.h_sync_pos;
            repeat (video_timing.h_sync) @vif.cb;
            vif.cb.vin_hsync <= ~video_timing.h_sync_pos;
            repeat (video_timing.h_bp) @vif.cb;
            repeat (video_timing.h_active) @vif.cb;
            repeat (video_timing.h_fp) @vif.cb;
        end
    endtask
endclass

