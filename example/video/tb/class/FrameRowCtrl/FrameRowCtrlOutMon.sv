//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Mon
//  Version : 1.1.7
//
//  Description
//      Monitors the row timing (de / hsync / vsync) on the DUT output.
//      Horizontal totals are counted in clocks: pixel counts divided by PIXEL_PER_CLOCK.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameRowCtrlOutMon #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1
) extends uvm_monitor;

    `uvm_component_param_utils(FrameRowCtrlOutMon #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  variable definition
    typedef FrameRowCtrlTxn TXN;
    virtual video_if #(DATA_WIDTH, PIXEL_PER_CLOCK).mon_mp vif;

    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameRowCtrlOutMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(this, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("FrameRowCtrlOutMon", "video configuration is not set.")
        end
        vif = video_cfg.vif;
        ap = new("ap", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN txn;

        bit vsync_prev;
        bit vsync_curr;

        @(posedge vif.clk)
        vsync_prev = vif.vout_vsync;
        vsync_curr = vif.vout_vsync;
        while (!(vsync_prev == ~video_cfg.frame_cfg.v_sync_pos && vsync_curr == video_cfg.frame_cfg.v_sync_pos)) begin
            @(posedge vif.clk)
            vsync_prev = vsync_curr;
            vsync_curr = vif.vout_vsync;
        end

        forever begin
            sample_txn(txn);
            ap.write(txn);
        end
    endtask

    task sample_txn;
        output TXN txn;
        int unsigned h_total;

        h_total = (video_cfg.frame_cfg.h_active + video_cfg.frame_cfg.h_fp +
            video_cfg.frame_cfg.h_sync + video_cfg.frame_cfg.h_bp) / PIXEL_PER_CLOCK;

        txn = TXN::type_id::create("txn");
        txn.h_total = h_total;
        txn.alloc_mem();

        for (int i = 0; i < h_total; i++) begin
            txn.de[i] = vif.vout_de;
            txn.hsync[i] = vif.vout_hsync;
            txn.vsync[i] = vif.vout_vsync;
            @(posedge vif.clk);
        end
    endtask
endclass
