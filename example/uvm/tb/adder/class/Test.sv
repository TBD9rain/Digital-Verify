//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.1
//  Title           :   Test
//
//  Description     :   test class definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class BaseTest extends uvm_test;
    `uvm_component_utils(BaseTest)

    localparam  DATA_IN_WIDTH = 8;
    localparam  DATA_OUT_WIDTH = 9;

    localparam type ITXN = InTxn #(DATA_IN_WIDTH);
    localparam type OTXN = OutTxn #(DATA_OUT_WIDTH);

    //  variable definition
    Env #(ITXN, OTXN) env;

    function new(string name="BaseTest", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        this.set_report_verbosity_level_hier(UVM_LOW);
        uvm_config_db#(uvm_object_wrapper)::set(this,
            "env.i_agt.sqr.main_phase",
            "default_sequence",
            BaseSeq #(ITXN)::type_id::get());
        env = Env #(ITXN, OTXN)::type_id::create("env", this);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server rpt_ser;
        int err_num;

        super.report_phase(phase);
        rpt_ser = get_report_server();
        err_num = rpt_ser.get_severity_count(UVM_ERROR);

        if (err_num) begin
            $write("\nTest failed.\n");
        end
        else begin
            $write("\nTest passed.\n");
        end
    endfunction
endclass


