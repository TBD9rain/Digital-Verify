//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : FrameDataRefMdl
//  Version : 1.0.1
//
//  Description
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataRefMdl #(
    parameter int DATA_WIDTH = 8
) extends uvm_component;

    `uvm_component_param_utils(FrameDataRefMdl #(DATA_WIDTH))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    uvm_blocking_get_port #(TXN) imon_getp;
    uvm_blocking_put_port #(TXN) scb_putp;

    function new(string name="FrameDataRefMdl", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imon_getp = new("imon_getp", this);
        scb_putp = new("scb_putp", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN mon_txn;
        TXN exp_txn;

        forever begin
            imon_getp.get(mon_txn);
            ref_proc(mon_txn, exp_txn);
            scb_putp.put(exp_txn);
        end
    endtask

    task ref_proc(
        const ref TXN in_txn,
        output TXN out_txn);

        out_txn = TXN::type_id::create("out_txn");
        out_txn.copy(in_txn);
    endtask
endclass

