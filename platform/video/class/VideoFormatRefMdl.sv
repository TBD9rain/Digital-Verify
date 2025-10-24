//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoFormatRefMdl
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoFormatRefMdl #(
    parameter type TXN = VideoFormatTxn
) extends uvm_component;
    `uvm_component_param_utils(VideoFormatRefMdl #(TXN))

    //  variable definition
    uvm_blocking_put_port #(TXN) scb_putp;

    video_timing_t  video_timing;

    function new(string name="VideoFormatRefMdl", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(video_timing_t)::get(this, "", "video_timing", video_timing)) begin
            `uvm_fatal(get_name(), "video timing is not set.")
        end
        scb_putp = new("scb_putp", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN exp_txn;
        int unsigned v_total;
        int unsigned h_total;
        int unsigned i;
        int unsigned j;

        //  Sync interval is the first
        v_total = video_timing.v_sync + video_timing.v_bp + video_timing.v_active + video_timing.v_fp;
        h_total = video_timing.h_sync + video_timing.h_bp + video_timing.h_active + video_timing.h_fp;

        forever begin
            for (i = 0; i < v_total; i++) begin
                for (j = 0; j < h_total; j++) begin
                    exp_txn = TXN::type_id::create("exp_txn");

                    if (i < video_timing.v_sync) begin
                        exp_txn.vsync = video_timing.v_sync_pos ? 1 : 0;
                    end
                    else begin
                        exp_txn.vsync = video_timing.v_sync_pos ? 0 : 1;
                    end

                    if (j < video_timing.h_sync) begin
                        exp_txn.hsync = video_timing.h_sync_pos ? 1 : 0;
                    end
                    else begin
                        exp_txn.hsync = video_timing.h_sync_pos ? 0 : 1;
                    end

                    if ((i >= (video_timing.v_sync + video_timing.v_bp)) &&
                        (i < (video_timing.v_sync + video_timing.v_bp + video_timing.v_active)) &&
                        (j >= (video_timing.h_sync + video_timing.h_bp)) &&
                        (j < (video_timing.h_sync + video_timing.h_bp + video_timing.h_active))) begin
                        exp_txn.de = 1;
                    end
                    else begin
                        exp_txn.de = 0;
                    end

                    scb_putp.put(exp_txn);
                end
            end
        end
    endtask
endclass

