//==================================================================================================
//
//  Project : Video Verification Platform
//  Title   : ScbFI
//  Version : 1.0.0
//
//  Description
//      Scoreboard fault injector. Sits between the output monitor and the scoreboard: it copies the
//      observed output transaction, corrupts it, and forwards it. Enabled by
//      VideoConfig.fault_inject_en; used to confirm the scoreboard detects mismatches.
//
//  Additional info
//
//  Author  : TBD9rain
//
//==================================================================================================

class FrameDataScbFI #(
    parameter int DATA_WIDTH = 8
) extends uvm_component;

    `uvm_component_param_utils(FrameDataScbFI #(DATA_WIDTH))

    //  variable definition
    typedef FrameDataTxn #(DATA_WIDTH) TXN;

    uvm_analysis_imp #(TXN, FrameDataScbFI #(DATA_WIDTH)) imp;
    uvm_analysis_port #(TXN) ap;

    function new(string name="FrameDataScbFI", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        imp = new("imp", this);
        ap = new("ap", this);
    endfunction

    //  Reference only - adapt the fault model to the real verification goals.
    //  The default corrupts one pixel so the scoreboard observes a value mismatch.
    virtual function void fault_inject(TXN txn);
        if (txn.frame_data.size() > 0) begin
            txn.frame_data[0] = ~txn.frame_data[0];
        end
    endfunction

    virtual function void write(TXN txn);
        TXN insert_txn;

        insert_txn = TXN::type_id::create("insert_txn");
        insert_txn.copy(txn);

        fault_inject(insert_txn);

        ap.write(insert_txn);
    endfunction
endclass
