//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : RefMdl
//  Version : 1.1.2
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameRowCtrlRefMdl extends uvm_component;

    `uvm_component_utils(FrameRowCtrlRefMdl)

    //  variable definition
    typedef FrameRowCtrlTxn TXN;

    uvm_blocking_put_port #(TXN) scb_putp;

    video_timing_t  video_timing;

    function new(string name="FrameRowCtrlRefMdl", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(video_timing_t)::get(this, "", "video_timing", video_timing)) begin
            `uvm_fatal("FrameRowCtrlRefMdl", "video timing is not set.")
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
                exp_txn = TXN::type_id::create("exp_txn");
                exp_txn.h_total = h_total;
                exp_txn.alloc_mem();

                for (j = 0; j < h_total; j++) begin

                    if (i < video_timing.v_sync) begin
                        exp_txn.vsync[j] = video_timing.v_sync_pos ? 1 : 0;
                    end
                    else begin
                        exp_txn.vsync[j] = video_timing.v_sync_pos ? 0 : 1;
                    end

                    if (j < video_timing.h_sync) begin
                        exp_txn.hsync[j] = video_timing.h_sync_pos ? 1 : 0;
                    end
                    else begin
                        exp_txn.hsync[j] = video_timing.h_sync_pos ? 0 : 1;
                    end

                    if ((i >= (video_timing.v_sync + video_timing.v_bp)) &&
                        (i < (video_timing.v_sync + video_timing.v_bp + video_timing.v_active)) &&
                        (j >= (video_timing.h_sync + video_timing.h_bp)) &&
                        (j < (video_timing.h_sync + video_timing.h_bp + video_timing.h_active))) begin
                        exp_txn.de[j] = 1;
                    end
                    else begin
                        exp_txn.de[j] = 0;
                    end
                end

                scb_putp.put(exp_txn);
            end
        end
    endtask
endclass

