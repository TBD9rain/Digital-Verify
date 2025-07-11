//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   test_if
//
//  Description     :   interface definition
//
//  Additional info :
//  Author          :   shi_l
//  Email           :
//
//==================================================================================================

interface test_if;

    logic   clk;
    logic   rst_n;

    //  parameter definition

    //  wire definition
    logic           data_in_vld;
    logic   [ 7: 0] addend0;
    logic   [ 7: 0] addend1;

    logic           data_out_vld;
    logic   [ 8: 0] sum;

    //  testbench driver
    clocking drv_cb @(posedge clk);
        //  testbench IO
        output  data_in_vld;
        output  addend0;
        output  addend1;

        input   data_out_vld;
        input   sum;
    endclocking

    modport drv_mp (clocking drv_cb);

    //  testbench monitor
    clocking mon_cb @(posedge clk);
        //  testbench IO
        input   data_in_vld;
        input   addend0;
        input   addend1;

        input   data_out_vld;
        input   sum;
    endclocking

    modport mon_mp (clocking mon_cb);

    //  DUT
    modport dut_mp (
        //  DUT IO
        input   clk,
        input   rst_n,

        input   data_in_vld,
        input   addend0,
        input   addend1,

        input   data_out_vld,
        input   sum);
endinterface


