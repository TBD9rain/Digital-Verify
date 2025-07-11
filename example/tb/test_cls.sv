//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   test_cls
//
//  Description     :   test environment component definitions
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================


class inputPtn;
    randc   bit [ 7: 0]     addend0;
    randc   bit [ 7: 0]     addend1;

    function new(
        bit [ 7: 0]     addend0 = 0,
        bit [ 7: 0]     addend1 = 0);

        this.addend0    = addend0;
        this.addend1    = addend1;
    endfunction

    function string  data_print_str(
        longint unsigned    tab_num = 1,
        string  prefix_str = "");

        string  tab_str = "";

        for (int i = 0; i < tab_num; i++) begin
            tab_str = {tab_str, "\t"};
        end

        data_print_str  = $sformat({
            tab_str, prefix_str, "addend0:\t%0d\n",
            tab_str, prefix_str, "addend1:\t%0d\n"},
            addend0, addend1);
    endfunction
endclass


class outputPtn;
    bit     [ 8: 0]     sum;

    function new(
        bit     [ 8: 0]     sum);

        this.sum    = sum;
    endfunction

    function string  data_print_str(
        longint unsigned    tab_num = 1,
        string  prefix_str = "");

        string  tab_str = "";

        for (int i = 0; i < tab_num; i++) begin
            tab_str = {tab_str, "\t"};
        end

        data_print_str  = $sformat({
            tab_str, prefix_str, "sum:\t%0d\n"},
            sum);
    endfunction
endclass


class testEnv;
    virtual interface   test_if.tb_mp  vif;

    inputSeq    seq;
    inputAgt    input_agt;
    covAcc      cov_acc;
    outputAgt   output_agt;
    refMdl      ref_mdl;
    scoreBoard  dut_chk;

    mailbox #(inputPtn) i2cov_mbox;
    mailbox #(inputPtn) i2ref_mbox;
    mailbox #(inputPtn) i2score_mbox;

    mailbox #(outputPtn)    o2score_mbox;
    mailbox #(outputPtn)    ref2score_mbox;

    bit     driver_bypass;

    function new(
        bit     driver_bypass   = 'b1);

        this.driver_bypass  = driver_bypass;

        if (~this.driver_bypass) begin
            this.seq    = new;
        end
        this.input_agt  = new(this.driver_bypass);
        this.cov_acc    = new;
        this.output_agt = new;
        this.ref_mdl    = new;
        this.dut_chk    = new;

        this.i2cov_mbox     = new;
        this.i2ref_mbox     = new;
        this.i2score_mbox   = new;
        this.o2score_mbox   = new;
        this.ref2score_mbox = new;

        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    function void connect;
        if (~driver_bypass) begin
            seq.seqr    = input_agt.seqr;
        end

        input_agt.vif   = vif;
        output_agt.vif  = vif;

        input_agt.i2cov_mbox    = i2cov_mbox;
        input_agt.i2ref_mbox    = i2ref_mbox;
        input_agt.i2score_mbox  = i2score_mbox;

        cov_acc.i2cov_mbox  = i2cov_mbox;

        output_agt.o2score_mbox = o2score_mbox;

        ref_mdl.i2ref_mbox      = i2ref_mbox;
        ref_mdl.ref2score_mbox  = ref2score_mbox;

        dut_chk.i2score_mbox    = i2score_mbox;
        dut_chk.o2score_mbox    = o2score_mbox;
        dut_chk.ref2score_mbox  = ref2score_mbox;

        input_agt.connect;
        output_agt.connect;

        print_msg($typename(this), "connection completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        fork
            input_agt.run;
            cov_acc.run;
            output_agt.run;
            ref_mdl.run;
            dut_chk.run;
        join_none
    endtask

    task add_case(
        inputPtn    case_data);

        seq.add_case(case_data);
    endtask

    task add_random_case(
        longint unsigned    case_num);

        seq.gen_rand_case(case_num);
    endtask
endclass


class inputSeq;
    inputSeqr   seqr;

    function new;
    endfunction

    task gen_rand_case(
        longint unsigned    case_num);

        inputPtn    case_data;

        for(int i = 0; i < case_num; i++) begin
            case_data   = new;
            assert(case_data.randomize())
            else begin
                print_msg($typename(this), "randomization failed.", ERROR, HIGHEST, STOP);
            end
            seqr.put(case_data);
            case_data = null;
        end
    endtask

    task add_case(
        inputPtn    case_data);

        seqr.put(case_data);
    endtask
endclass


class inputSeqr;
    mailbox #(inputPtn)     seqr_mbox;

    longint unsigned    data_num;

    function new;
        this.seqr_mbox  = new;
        this.data_num   = 0;
    endfunction

    task put(
        input   inputPtn    case_data);

        seqr_mbox.put(case_data);
        data_num++;
    endtask

    task get(
        output  inputPtn    case_data);

        seqr_mbox.get(case_data);
        data_num--;
    endtask

    function longint unsigned num;
        num = data_num;
    endfunction
endclass


class inputDvr;
    virtual interface   test_if.tb_mp   vif;

    inputSeqr   seqr;

    event   drive_end;

    function new;
    endfunction

    task run;
        inputPtn    in_data;
        forever begin
            if (seqr.num > 0) begin
                seqr.get(in_data);
                drive(in_data);

                if (seqr.num() == 0) begin
                    -> drive_end;
                end
            end
            else begin
                @vif.cb;
                vif.cb.data_in_vld  = 'b0;
                vif.cb.addend0      = 'b0;
                vif.cb.addend1      = 'b0;
            end
        end
    endtask

    task drive(
        ref inputPtn    in_data);
        @vif.cb;
        vif.cb.data_in_vld  = 'b1;
        vif.cb.addend0      = in_data.data_in0;
        vif.cb.addend1      = in_data.data_in1;
    endtask
endclass


class inputMon;
    virtual interface   test_if.tb_mp  vif;

    mailbox #(inputPtn) i2cov_mbox;
    mailbox #(inputPtn) i2ref_mbox;
    mailbox #(inputPtn) i2score_mbox;

    event   dut_input_catch;

    longint unsigned    ptn_cnt;

    function new;
        this.ptn_cnt = 0;
    endfunction

    task run;
        forever begin
            catch;
        end
    endtask

    task catch;
        string      msg;
        inputPtn    data_caught;

        bit     [ 7: 0]     addend0;
        bit     [ 7: 0]     addend1;

        @vif.cb;
        if (vif.cb.data_in_vld) begin
            addend0 = vif.cb.addend0;
            addend1 = vif.cb.addend1;

            data_caught = new(addend0, addend1);

            msg = $sformat({
                "DUT input pattern caught:\n",
                "\tNO. %0d\n",
                data_caught.data_print_str(1, "")},
                ptn_cnt);
            print_msg($typename(this), msg, INFO, LOW, LOG);

            i2cov_mbox.put(data_caught);
            i2ref_mbox.put(data_caught);
            i2score_mbox.put(data_caught);

            ptn_cnt++;
        end
    endtask
endclass


class inputAgt;
    virtual interface   test_if.tb_mp  vif;

    inputSeqr   seqr;
    inputDvr    driver;
    inputMon    monitor;

    mailbox #(inputPtn) i2cov_mbox;
    mailbox #(inputPtn) i2ref_mbox;
    mailbox #(inputPtn) i2score_mbox;

    bit     drive_en;

    event   drive_end;

    function new(
        bit     drive_en    = 'b1);

        this.drive_en   = drive_en;

        if (this.drive_en) begin
            this.seqr   = new;
            this.driver = new;
        end
        this.monitor = new;

        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    function void connect;
        if (drive_en) begin
            driver.vif  = vif;
            driver.seqr = seqr;
            drive_end   = driver.drive_end;
        end

        monitor.vif             = vif;
        monitor.i2cov_mbox      = i2cov_mbox;
        monitor.i2ref_mbox      = i2ref_mbox;
        monitor.i2score_mbox    = i2score_mbox;

        print_msg($typename(this), "connection completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        fork
            if (drive_en) begin
                driver.run;
            end
            monitor.run;
        join_none
    endtask
endclass


class covAcc;
    mailbox #(inputPtn)     i2cov_mbox;

    covergroup  adder_cov_grp;
        //  coverage point definition
        addend0: coverpoint case_data.addend0 {
            //  bins definition
            bins a1 = {[  0:127]};
            bins a2 = {[128:255]};
        }

        addend1: coverpoint case_data.adddend1 {
            //  bins definition
            bins b1[] = {[  0:127]};
            bins b2[] = {[128:255]};
        }

        //  cross coverage definition

    endgroup

    function new;
        this.adder_cov_grp  = new;
    endfunction

    task run;
        inputPtn    case_data;

        forever begin
            i2cov_mbox.get(case_data);
            adder_cov_grp.sample;
        end
    endtask
endclass


class outputMon;
    virtual interface   test_if.tb_mp  vif;

    mailbox #(outputPtn)    o2score_mbox;

    longint unsigned    ptn_cnt;

    function new;
        this.ptn_cnt    = 0;
    endfunction

    task run;
        forever begin
            catch;
        end
    endtask

    task catch;
        string      msg;
        outputPtn   data_caught;

        bit     [ 8: 0]     sum;

        @vif.cb;
        if (vif.cb.data_out_vld) begin
            sum = vif.cb.sum;

            data_caught = new(sum);

            msg = $sformat({
                "DUT output pattern caught:\n",
                "\tNO. %0d\n",
                data_caught.data_print_str(1, "")},
                ptn_cnt);
            print_msg($typename(this), msg, INFO, LOW, LOG);

            o2score_mbox.put(data_caught);

            ptn_cnt++;
        end
    endtask
endclass


class outputAgt;
    virtual interface   test_if.tb_mp  vif;

    outputMon   out_monitor;

    mailbox #(outputPtn)    o2score_mbox;

    function new;
        this.out_monitor = new;

        print_msg($typename(this), "initialization completed.", INFO, HIGH, LOG);
    endfunction

    function void connect;
        out_monitor.vif             = vif;
        out_monitor.o2score_mbox    = o2score_mbox;

        print_msg($typename(this), "connection completed.", INFO, HIGH, LOG);
    endfunction

    task run;
        out_monitor.run;
    endtask
endclass


class refMdl;
    mailbox #(inputPtn)     i2ref_mbox;
    mailbox #(outputPtn)    ref2score_mbox;

    function new();
    endfunction

    task run;
        inputPtn    in_data;
        outputPtn   out_data;

        forever begin
            i2ref_mbox.get(in_data);
            adder;
            ref2score_mbox.put(out_data);
        end
    endtask

    task adder;
        bit     [ 7: 0]     addend0;
        bit     [ 7: 0]     addend1;
        bit     [ 8: 0]     sum;

        addend0 = in_data.data_in0;
        addend1 = in_data.data_in1;

        sum = addend0 + addend1;

        out_data = new(sum);
    endtask
endclass


class scoreBoard;
    mailbox #(inputPtn)     i2score_mbox;
    mailbox #(outputPtn)    o2score_mbox;
    mailbox #(outputPtn)    ref2score_mbox;

    inputPtn    in_data;
    outputPtn   out_data;
    outputPtn   ref_data;

    event   rsp_ref_match;
    event   rsp_ref_dismatch;

    longint unsigned    ptn_cnt;

    function new;
        this.ptn_cnt    = 0;
    endfunction

    task run;
        string  msg;

        forever begin
            i2score_mbox.get(in_data);
            o2score_mbox.get(out_data);
            ref2score_mbox.get(ref_data);

            if (output_comp) begin
                msg = $sformat({
                    "Testcase passed:\n",
                    "\tNO.%0d\n",
                    in_data.data_print_str(1, ""),
                    out_data.data_print_str(1, ""),
                    ref_data.data_print_str(1, "")},
                    ptn_cnt);

                print_msg($typename(this), msg, INFO, MEDIUM, LOG);

                -> rsp_ref_match;
            end
            else begin
                msg = $sformat({
                    "Testcase failed:\n",
                    "\tNO.%0d\n",
                    in_data.data_print_str(1, ""),
                    out_data.data_print_str(1, ""),
                    ref_data.data_print_str(1, "")},
                    ptn_cnt);

                print_msg($typename(this), msg, ERROR, HIGHEST, STOP);

                -> rsp_ref_dismatch;
            end

            ptn_cnt++;
        end
    endtask

    function bit output_comp;
        output_comp = out_data.sum == ref_data.sum;
    endfunction
endclass


