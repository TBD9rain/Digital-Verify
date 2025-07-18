//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   InputDrv
//
//  Description     :   DUT input driver
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class InputDrv #(
    parameter DATA_WIDTH = 8);

    //  input transaction class
    typedef InputTxn #(.DATA_WIDTH (DATA_WIDTH)) INPUT_TXN;

    virtual interface test_if.drv_mp vif;

    InputSeqr seqr;

    function new();
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        INPUT_TXN tc_txn;

        forever begin
            @vif.drv_cb;
            if (~vif.rst_n) begin
                no_drive;
            end
            else begin
                seqr.get(tc_txn);
                assert (tc_txn) begin
                    drive(tc_txn);
                end
                else begin
                    no_drive;
                end
            end
        end
    endtask

    task drive(
        input INPUT_TXN tc_txn);

        vif.drv_cb.data_in_vld <= 'b1;
        vif.drv_cb.addend0 <= tc_txn.addend0;
        vif.drv_cb.addend1 <= tc_txn.addend1;
    endtask

    task no_drive;
        vif.drv_cb.data_in_vld <= 'b0;
        vif.drv_cb.addend0 <= 'b0;
        vif.drv_cb.addend1 <= 'b0;
    endtask
endclass

