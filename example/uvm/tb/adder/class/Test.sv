//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.1.3
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

    localparam int DATA_WIDTH = 8;

    //  variable definition
    Env #(DATA_WIDTH) env;

    function new(string name="BaseTest", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        this.set_report_verbosity_level_hier(UVM_LOW);
        uvm_config_db #(int unsigned)::set(this, "env.scb", "ref_latency", 1);
        uvm_config_db #(uvm_object_wrapper)::set(this,
            "env.i_agt.sqr.main_phase",
            "default_sequence",
            BaseSeq #(DATA_WIDTH)::type_id::get());
        env = Env #(DATA_WIDTH)::type_id::create("env", this);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server rpt_ser;
        int err_num;

        super.report_phase(phase);
        rpt_ser = get_report_server();
        err_num = rpt_ser.get_severity_count(UVM_ERROR);

        if (err_num) begin
            $write("\n");
            $write("============\n");
            $write("Test failed.\n");
            $write("============\n");
            $write("\n");
        end
        else begin
            $write("\n");
            $write("============\n");
            $write("Test passed.\n");
            $write("============\n");
            $write("\n");
        end
    endfunction

    virtual function void final_phase (uvm_phase phase);
        super.final_phase(phase);

        $stop(2);
    endfunction
endclass


