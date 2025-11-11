//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Drv
//  Version : 1.0.2
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
    FrameFormatObj frame_format;

    function new(string name="FrameDataDrv", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(drv_vif)::get(this, "", "vif", vif)) begin
            `uvm_fatal("FrameDataDrv", "Virtual interface is not set.")
        end
        if (!uvm_config_db #(FrameFormatObj)::get(this, "", "frame_format", frame_format)) begin
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

        if (txn.frame_height != frame_format.v_active || txn.frame_width != frame_format.h_active) begin
            `uvm_fatal("FrameDataDrv", "video timing does not match transaction frame size.")
        end

        vif.cb.vin_de   <= 'b0;
        vif.cb.vin_data <= 'b0;

        if (txn.prefix_vsync) begin
            drv_vsync;
        end

        //  video frame
        for (y = 0; y < frame_format.v_active; y++) begin
            vif.cb.vin_hsync <= frame_format.h_sync_pos;
            repeat (frame_format.h_sync) @vif.cb;
            vif.cb.vin_hsync <= ~frame_format.h_sync_pos;
            repeat (frame_format.h_bp) @vif.cb;
            for (x = 0; x < frame_format.h_active; x++) begin
                vif.cb.vin_de   <= 1'b1;
                vif.cb.vin_data <= txn.frame_data[frame_format.h_active*y + x];
                @vif.cb;
            end
            vif.cb.vin_de   <= 1'b0;
            vif.cb.vin_data <= 'b0;
            repeat (frame_format.h_fp) @vif.cb;
        end

        if (txn.suffix_vsync) begin
            drv_vsync;
        end
    endtask

    task drv_vsync;
        //  V blank front porch
        vif.cb.vin_vsync <= ~frame_format.v_sync_pos;
        repeat (frame_format.v_fp) begin
            vif.cb.vin_hsync <= frame_format.h_sync_pos;
            repeat (frame_format.h_sync) @vif.cb;
            vif.cb.vin_hsync <= ~frame_format.h_sync_pos;
            repeat (frame_format.h_bp) @vif.cb;
            repeat (frame_format.h_active) @vif.cb;
            repeat (frame_format.h_fp) @vif.cb;
        end

        //  V blank sync
        vif.cb.vin_vsync <= frame_format.v_sync_pos;
        repeat (frame_format.v_sync) begin
            vif.cb.vin_hsync <= frame_format.h_sync_pos;
            repeat (frame_format.h_sync) @vif.cb;
            vif.cb.vin_hsync <= ~frame_format.h_sync_pos;
            repeat (frame_format.h_bp) @vif.cb;
            repeat (frame_format.h_active) @vif.cb;
            repeat (frame_format.h_fp) @vif.cb;
        end

        //  V blank back porch
        vif.cb.vin_vsync <= ~frame_format.v_sync_pos;
        repeat (frame_format.v_bp) begin
            vif.cb.vin_hsync <= frame_format.h_sync_pos;
            repeat (frame_format.h_sync) @vif.cb;
            vif.cb.vin_hsync <= ~frame_format.h_sync_pos;
            repeat (frame_format.h_bp) @vif.cb;
            repeat (frame_format.h_active) @vif.cb;
            repeat (frame_format.h_fp) @vif.cb;
        end
    endtask
endclass

