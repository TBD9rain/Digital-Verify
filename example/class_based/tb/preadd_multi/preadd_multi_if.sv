//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   preadd_multi_if
//
//  Description     :   pre-adder multiplier interface definition
//
//  Additional info :
//  Author          :   lshi1
//  Email           :
//
//==================================================================================================

interface preadd_multi_if #(
    parameter   DATA_WIDTH = 8);

    logic clk;
    logic rst_n;

    //  environment variable
    longint unsigned clk_cnt;

    //  DUT IO port
    logic data_in_vld;
    logic [DATA_WIDTH - 1: 0] data_in_a0;
    logic [DATA_WIDTH - 1: 0] data_in_a1;
    logic [DATA_WIDTH - 1: 0] data_in_b0;
    logic [DATA_WIDTH - 1: 0] data_in_b1;

    logic data_out_vld;
    logic [2*(DATA_WIDTH + 1) - 1: 0] data_out;

    //  environment
    clocking env_cb @(posedge clk);
        output clk_cnt;
    endclocking

    modport env_mp (
        input rst_n,
        clocking env_cb);

    //  driver
    clocking drv_cb @(posedge clk);
        output data_in_vld;
        output data_in_a0;
        output data_in_a1;
        output data_in_b0;
        output data_in_b1;

        input data_out_vld;
        input data_out;
    endclocking

    modport drv_mp (
        input rst_n,
        clocking drv_cb);

    //  monitor
    clocking mon_cb @(posedge clk);
        input clk_cnt;

        input data_in_vld;
        input data_in_a0;
        input data_in_a1;
        input data_in_b0;
        input data_in_b1;

        input data_out_vld;
        input data_out;
    endclocking

    modport mon_mp (
        input rst_n,
        clocking mon_cb);

    //  DUT
    modport dut_mp (
        input clk,
        input rst_n,

        input data_in_vld,
        input data_in_a0,
        input data_in_a1,
        input data_in_b0,
        input data_in_b1,

        output data_out_vld,
        output data_out);
endinterface

