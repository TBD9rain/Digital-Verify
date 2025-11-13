//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : RefMdl
//  Version : 1.1.4
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

    FrameFormatObj frame_format;

    function new(string name="FrameRowCtrlRefMdl", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(FrameFormatObj)::get(this, "", "frame_format", frame_format)) begin
            `uvm_fatal("FrameRowCtrlRefMdl", "frame format is not set.")
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
        v_total = frame_format.v_sync + frame_format.v_bp + frame_format.v_active + frame_format.v_fp;
        h_total = frame_format.h_sync + frame_format.h_bp + frame_format.h_active + frame_format.h_fp;

        forever begin
            for (i = 0; i < v_total; i++) begin
                exp_txn = TXN::type_id::create("exp_txn");
                exp_txn.h_total = h_total;
                exp_txn.alloc_mem();

                for (j = 0; j < h_total; j++) begin

                    if (i < frame_format.v_sync) begin
                        exp_txn.vsync[j] = frame_format.v_sync_pos ? 1 : 0;
                    end
                    else begin
                        exp_txn.vsync[j] = frame_format.v_sync_pos ? 0 : 1;
                    end

                    if (j < frame_format.h_sync) begin
                        exp_txn.hsync[j] = frame_format.h_sync_pos ? 1 : 0;
                    end
                    else begin
                        exp_txn.hsync[j] = frame_format.h_sync_pos ? 0 : 1;
                    end

                    if ((i >= (frame_format.v_sync + frame_format.v_bp)) &&
                        (i < (frame_format.v_sync + frame_format.v_bp + frame_format.v_active)) &&
                        (j >= (frame_format.h_sync + frame_format.h_bp)) &&
                        (j < (frame_format.h_sync + frame_format.h_bp + frame_format.h_active))) begin
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

