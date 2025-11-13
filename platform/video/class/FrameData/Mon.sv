//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : Mon
//  Version : 1.0.3
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataInMon #(
    parameter int DATA_WIDTH = 8
) extends uvm_monitor;

    `uvm_component_param_utils(FrameDataInMon #(DATA_WIDTH))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;
    typedef virtual video_if #(DATA_WIDTH).mon_mp mon_vif;

    mon_vif vif;
    FrameFormatObj frame_format;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameDataInMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(mon_vif)::get(this, "", "vif", vif)) begin
            `uvm_fatal("FrameDataInMon", "virtual interface is not set.")
        end
        if (!uvm_config_db #(FrameFormatObj)::get(this, "", "frame_format", frame_format)) begin
            `uvm_fatal("FrameDataInMon", "frame format is not set.")
        end
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

        txn = TXN::type_id::create("txn");
        txn.frame_height = frame_format.v_active;
        txn.frame_width = frame_format.h_active;
        txn.alloc_mem();
        pixel_idx = 0;

        while (pixel_idx < txn.frame_height*txn.frame_width) begin
            @vif.cb;
            if (vif.cb.vin_de) begin
                txn.frame_data[pixel_idx] = vif.cb.vin_data;
                pixel_idx++;
            end
        end
        txn.timestamp = vif.cb.clk_cnt;
    endtask
endclass


class FrameDataOutMon #(
    parameter int DATA_WIDTH = 8
) extends uvm_monitor;

    `uvm_component_param_utils(FrameDataOutMon #(DATA_WIDTH))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;
    typedef virtual video_if #(DATA_WIDTH).mon_mp mon_vif;

    mon_vif vif;
    FrameFormatObj  frame_format;

    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameDataOutMon", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(mon_vif)::get(this, "", "vif", vif)) begin
            `uvm_fatal("FrameDataOutMon", "virtual interface is not set.")
        end
        if (!uvm_config_db #(FrameFormatObj)::get(this, "", "frame_format", frame_format)) begin
            `uvm_fatal("FrameDataOutMon", "frame format is not set.")
        end
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

        txn = TXN::type_id::create("txn");
        txn.frame_height = frame_format.v_active;
        txn.frame_width = frame_format.h_active;
        txn.alloc_mem();
        pixel_idx = 0;

        while (pixel_idx < txn.frame_height*txn.frame_width) begin
            @vif.cb;
            if (vif.cb.vout_de) begin
                txn.frame_data[pixel_idx] = vif.cb.vout_data;
                pixel_idx++;
            end
        end
        txn.timestamp = vif.cb.clk_cnt;
    endtask
endclass

