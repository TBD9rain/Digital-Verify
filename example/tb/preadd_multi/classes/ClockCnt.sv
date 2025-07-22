//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   ClockCnt
//
//  Description     :   clock counter
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

class ClockCnt;
    virtual interface preadd_multi_if.env_mp vif;

    longint unsigned clk_cnt;

    function new();
        this.clk_cnt = 0;
        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        forever begin
            @vif.env_cb;
            clk_cnt++;
            vif.env_cb.clk_cnt  <= clk_cnt;
        end
    endtask
endclass

