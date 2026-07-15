//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : RefMdl
//  Version : 1.1.5
//
//  Description
//      Reference model for the row timing.
//      Horizontal boundaries are expressed in clocks: pixel counts divided by PIXEL_PER_CLOCK.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameRowCtrlRefMdl #(
    parameter int DATA_WIDTH = 8,
    parameter int PIXEL_PER_CLOCK = 1
) extends uvm_component;

    `uvm_component_param_utils(FrameRowCtrlRefMdl #(DATA_WIDTH, PIXEL_PER_CLOCK))

    //  variable definition
    typedef FrameRowCtrlTxn TXN;

    uvm_blocking_put_port #(TXN) scb_putp;

    VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK) video_cfg;

    function new(string name="FrameRowCtrlRefMdl", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(VideoConfig #(DATA_WIDTH, PIXEL_PER_CLOCK))::get(this, "", "video_cfg", video_cfg)) begin
            `uvm_fatal("FrameRowCtrlRefMdl", "video configuration is not set.")
        end
        scb_putp = new("scb_putp", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN exp_txn;
        int unsigned v_total;
        int unsigned h_total;
        int unsigned h_sync_clk;
        int unsigned h_bp_clk;
        int unsigned h_active_clk;
        int unsigned h_fp_clk;
        int unsigned i;
        int unsigned j;

        //  vertical counted in lines
        v_total = video_cfg.frame_cfg.v_sync + video_cfg.frame_cfg.v_bp +
            video_cfg.frame_cfg.v_active + video_cfg.frame_cfg.v_fp;

        //  horizontal counted in clocks
        h_sync_clk   = video_cfg.frame_cfg.h_sync   / PIXEL_PER_CLOCK;
        h_bp_clk     = video_cfg.frame_cfg.h_bp     / PIXEL_PER_CLOCK;
        h_active_clk = video_cfg.frame_cfg.h_active / PIXEL_PER_CLOCK;
        h_fp_clk     = video_cfg.frame_cfg.h_fp     / PIXEL_PER_CLOCK;
        h_total = h_sync_clk + h_bp_clk + h_active_clk + h_fp_clk;

        forever begin
            for (i = 0; i < v_total; i++) begin
                exp_txn = TXN::type_id::create("exp_txn");
                exp_txn.h_total = h_total;
                exp_txn.alloc_mem();

                for (j = 0; j < h_total; j++) begin

                    if (i < video_cfg.frame_cfg.v_sync) begin
                        exp_txn.vsync[j] = video_cfg.frame_cfg.v_sync_pos ? 1 : 0;
                    end
                    else begin
                        exp_txn.vsync[j] = video_cfg.frame_cfg.v_sync_pos ? 0 : 1;
                    end

                    if (j < h_sync_clk) begin
                        exp_txn.hsync[j] = video_cfg.frame_cfg.h_sync_pos ? 1 : 0;
                    end
                    else begin
                        exp_txn.hsync[j] = video_cfg.frame_cfg.h_sync_pos ? 0 : 1;
                    end

                    if ((i >= (video_cfg.frame_cfg.v_sync + video_cfg.frame_cfg.v_bp)) &&
                        (i < (video_cfg.frame_cfg.v_sync + video_cfg.frame_cfg.v_bp + video_cfg.frame_cfg.v_active)) &&
                        (j >= (h_sync_clk + h_bp_clk)) &&
                        (j < (h_sync_clk + h_bp_clk + h_active_clk))) begin
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
