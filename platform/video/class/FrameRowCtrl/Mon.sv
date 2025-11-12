//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Mon
//  Version : 1.1.4
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameRowCtrlOutMon #(
    parameter int DATA_WIDTH = 8
) extends uvm_monitor;

    `uvm_component_param_utils(FrameRowCtrlOutMon #(DATA_WIDTH))

    //  variable definition
    typedef virtual video_if #(DATA_WIDTH).mon_mp mon_vif;
    typedef FrameRowCtrlTxn TXN;

    virtual interface video_if.mon_mp vif;

    FrameFormatObj frame_format;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameRowCtrlOutMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(mon_vif)::get(this, "", "vif", vif)) begin
            `uvm_fatal("FrameRowCtrlOutMon", "Virtual interface is not set.")
        end
        if (!uvm_config_db #(FrameFormatObj)::get(this, "", "frame_format", frame_format)) begin
            `uvm_fatal("FrameRowCtrlOutMon", "video timing is not set.")
        end
        ap = new("ap", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN txn;

        bit vsync_prev;
        bit vsync_curr;

        @vif.cb;
        vsync_prev = vif.cb.vout_vsync;
        vsync_curr = vif.cb.vout_vsync;
        while (!(vsync_prev == ~frame_format.v_sync_pos && vsync_curr == frame_format.v_sync_pos)) begin
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

        h_total = frame_format.h_active + frame_format.h_fp + frame_format.h_sync + frame_format.h_bp;

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

