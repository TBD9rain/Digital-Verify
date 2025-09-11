//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   Scb
//
//  Description     :   scoreboard class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class Scb #(
    parameter type TXN = OutTxn
) extends uvm_scoreboard;
    `uvm_component_param_utils(Scb #(TXN))

    //  variable definition
    TXN exp_txn_q[$];
    uvm_blocking_get_port #(TXN) omon_getp;
    uvm_blocking_get_port #(TXN) mdl_getp;

    function new(string name="Scb", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        omon_getp = new("omon_getp", this);
        mdl_getp = new("mdl_getp", this);
    endfunction

    task main_phase(uvm_phase phase);
        TXN tmp_txn;
        TXN exp_txn;
        TXN act_txn;
        bit txn_equal;

        fork
            forever begin
                mdl_getp.get(tmp_txn);
                exp_txn_q.push_front(tmp_txn);
            end
            forever begin
                omon_getp.get(act_txn);
                if (exp_txn_q.size() > 0) begin
                    exp_txn = exp_txn_q.pop_back();
                    txn_equal = act_txn.compare(exp_txn);
                    if (txn_equal) begin
                        `uvm_info("Scb", "expected output and actual output match.", UVM_MEDIUM)
                    end
                    else begin
                        `uvm_error("Scb", "expected output and actual output mismatch.")
                        `uvm_info("Scb", "expected output:", UVM_NONE)
                        exp_txn.print();
                        `uvm_info("Scb", "actual output:", UVM_NONE)
                        act_txn.print();
                    end
                end
                else begin
                    `uvm_error("Scb", "unexpected DUT output with no input.")
                end
            end
        join
    endtask
endclass


