//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.3
//  Title           :   test_if
//
//  Description     :   interface definition
//
//  Additional info :
//  Author          :   shi_l
//  Email           :
//
//==================================================================================================

interface test_if #(
    parameter   DATA_WIDTH  = 8);

    logic   clk;
    logic   rst_n;

    //  environment variable
    longint unsigned    clk_cnt;

    //  DUT IO port
    logic                       data_in_vld;
    logic   [DATA_WIDTH - 1: 0] addend0;
    logic   [DATA_WIDTH - 1: 0] addend1;

    logic                   data_out_vld;
    logic   [DATA_WIDTH: 0] sum;

    //  environment
    clocking env_cb @(posedge clk);
        output  clk_cnt;
    endclocking

    modport env_mp (
        input       rst_n,
        clocking    env_cb);

    //  driver
    clocking drv_cb @(posedge clk);
        output  data_in_vld;
        output  addend0;
        output  addend1;

        input   data_out_vld;
        input   sum;
    endclocking

    modport drv_mp (
        input       rst_n,
        clocking    drv_cb);

    //  monitor
    clocking mon_cb @(posedge clk);
        input   clk_cnt;

        input   data_in_vld;
        input   addend0;
        input   addend1;

        input   data_out_vld;
        input   sum;
    endclocking

    modport mon_mp (
        input       rst_n,
        clocking    mon_cb);

    //  DUT
    modport dut_mp (
        input   clk,
        input   rst_n,

        input   data_in_vld,
        input   addend0,
        input   addend1,

        input   data_out_vld,
        input   sum);
endinterface


