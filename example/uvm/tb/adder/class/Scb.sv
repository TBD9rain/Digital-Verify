//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.0
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
    parameter type ITXN = InTxn,
    parameter type OTXN = OutTxn,
    parameter longint unsigned LATENCY = 1
) extends uvm_scoreboard;
    `uvm_component_param_utils(Scb #(ITXN, OTXN, LATENCY))

    //  variable definition
    ITXN imon_txn_q[$];
    OTXN mdl_txn_q[$];
    uvm_blocking_get_port #(ITXN) imon_getp;
    uvm_blocking_get_port #(OTXN) omon_getp;
    uvm_blocking_get_port #(OTXN) mdl_getp;

    function new(string name="Scb", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imon_getp = new("imon_getp", this);
        omon_getp = new("omon_getp", this);
        mdl_getp = new("mdl_getp", this);
    endfunction

    task main_phase(uvm_phase phase);
        ITXN itxn;
        OTXN otxn;
        ITXN imon_txn;
        OTXN mdl_txn;
        OTXN omon_txn;
        bit txn_equal;

        fork
            forever begin
                imon_getp.get(itxn);
                imon_txn_q.push_front(itxn);
            end
            forever begin
                mdl_getp.get(otxn);
                mdl_txn_q.push_front(otxn);
            end
            forever begin
                omon_getp.get(omon_txn);
                if (imon_txn_q.size() > 0 && mdl_txn_q.size() > 0) begin
                    //  value check
                    txn_equal = omon_txn.compare(mdl_txn);
                    mdl_txn = mdl_txn_q.pop_back();
                    if (txn_equal) begin
                        `uvm_info("Scb", "expected output and actual output match.", UVM_MEDIUM)
                    end
                    else begin
                        `uvm_error("Scb", "expected output and actual output mismatch.")
                        `uvm_info("Scb", "expected output:", UVM_NONE)
                        mdl_txn.print();
                        `uvm_info("Scb", "actual output:", UVM_NONE)
                        omon_txn.print();
                    end
                    //  latency check
                    imon_txn = imon_txn_q.pop_back();
                    if (omon_txn.timestamp - imon_txn.timestamp === LATENCY) begin
                        `uvm_info("Scb", "DUT latency is as expected.", UVM_MEDIUM)
                    end
                    else begin
                        `uvm_error("Scb", "DUT latency is not as expected.")
                        `uvm_info("Scb", "input monitor transaction:", UVM_NONE)
                        imon_txn.print();
                        `uvm_info("Scb", "output monitor transaction:", UVM_NONE)
                        omon_txn.print();
                    end
                end
                else begin
                    `uvm_error("Scb", "unexpected DUT output with no input.")
                end
            end
        join
    endtask
endclass


