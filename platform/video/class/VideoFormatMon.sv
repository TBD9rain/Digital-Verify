//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : VideoFormatMon
//  Version : 1.0.0
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class VideoFormatOutMon #(
    parameter type TXN = VideoFormatTxn
) extends uvm_monitor;
    `uvm_component_param_utils(VideoFormatOutMon #(TXN))

    //  variable definition
    virtual interface video_if.mon_mp vif;

    uvm_analysis_port #(TXN) ap;

    function new(string name="VideoFormatOutMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual video_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_name(), "Virtual interface is not set.")
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
            @vif.cb;
        end
    endtask

    task sample_txn;
        output TXN txn;

        txn = TXN::type_id::create("txn");

        txn.de = vif.cb.vout_de;
        txn.hsync = vif.cb.vout_hsync;
        txn.vsync = vif.cb.vout_vsync;
        txn.timestamp = vif.cb.clk_cnt;
    endtask
endclass

