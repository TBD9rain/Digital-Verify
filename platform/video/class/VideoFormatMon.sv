//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoFormatMon
//  Version : 1.1.1
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoFormatOutMon #(
    parameter int DATA_WIDTH = 8
) extends uvm_monitor;

    `uvm_component_param_utils(VideoFormatOutMon #(DATA_WIDTH))

    //  variable definition
    typedef virtual video_if #(DATA_WIDTH).mon_mp mon_vif;
    typedef VideoFormatTxn TXN;

    virtual interface video_if.mon_mp vif;

    video_timing_t video_timing;

    uvm_analysis_port #(TXN) ap;

    function new(string name="VideoFormatOutMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(mon_vif)::get(this, "", "vif", vif)) begin
            `uvm_fatal("VideoFormatOutMon", "Virtual interface is not set.")
        end
        if (!uvm_config_db #(video_timing_t)::get(this, "", "video_timing", video_timing)) begin
            `uvm_fatal("VideoFormatOutMon", "video timing is not set.")
        end
        ap = new("ap", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN txn;

        bit vsync_curr;
        bit vsync_prev;

        @vif.cb;
        vsync_curr = vif.cb.vout_vsync;
        vsync_prev = vif.cb.vout_vsync;
        while (!(vsync_prev == 0 && vsync_curr == 1)) begin
            @vif.cb;
            vsync_prev = vsync_curr;
            vsync_curr = vif.cb.vout_vsync;
        end

        forever begin
            sample_txn(txn);
            ap.write(txn);
        end
    endtask

    task sample_txn;
        output TXN txn;
        int unsigned h_total;

        h_total = video_timing.h_active + video_timing.h_fp + video_timing.h_sync + video_timing.h_bp;

        txn = TXN::type_id::create("txn");
        txn.h_total = h_total;
        txn.alloc_mem();

        for (int i = 0; i < h_total; i++) begin
            txn.de[i] = vif.cb.vout_de;
            txn.hsync[i] = vif.cb.vout_hsync;
            txn.vsync[i] = vif.cb.vout_vsync;
            @vif.cb;
        end
    endtask
endclass

