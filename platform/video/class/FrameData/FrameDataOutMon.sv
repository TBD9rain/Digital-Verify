//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : OutMon
//  Version : 1.0.5
//
//  Description
//      Samples the output video stream, PIXEL_PER_CLOCK pixels per active clock.
//      Pixel k occupies bits [k*3*DATA_WIDTH +: 3*DATA_WIDTH] of the packed pixel bus.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataOutMon #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1
) extends uvm_monitor;

    `uvm_component_param_utils(FrameDataOutMon #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  variable definition
    localparam int PIX_W = 3*DATA_WIDTH;

    typedef FrameDataTxn #(DATA_WIDTH) TXN;
    virtual video_if #(DATA_WIDTH, PIXEL_PER_CLOCK).mon_mp vif;

    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameDataOutMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(this, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("FrameDataOutMon", "video configuration is not set.")
        end
        vif = video_cfg.vif;
        ap = new("ap", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN txn;

        forever begin
            sample_txn(txn);
            ap.write(txn);
        end
    endtask

    task sample_txn;
        output TXN txn;
        int unsigned pixel_idx;
        int unsigned total_pixel;
        int k;

        txn = TXN::type_id::create("txn");
        txn.frame_height = video_cfg.frame_cfg.v_active;
        txn.frame_width  = video_cfg.frame_cfg.h_active;
        txn.alloc_mem();
        pixel_idx = 0;
        total_pixel = txn.frame_height*txn.frame_width;

        while (pixel_idx < total_pixel) begin
            @(posedge vif.clk);
            if (vif.vout_de) begin
                for (k = 0; k < PIXEL_PER_CLOCK && pixel_idx < total_pixel; k++) begin
                    txn.frame_data[pixel_idx] = vif.vout_pix[k*PIX_W +: PIX_W];
                    pixel_idx++;
                end
            end
        end
        txn.timestamp = vif.clk_cnt;
    endtask
endclass
