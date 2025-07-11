//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   test_if
//
//  Description     :   interface definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

interface test_if (
    input   logic   clk,
    input   logic   rst_n);

    //  IO definition
    logic               data_in_vld;
    logic   [ 7: 0]     addend0;
    logic   [ 7: 0]     addend1;

    logic               data_out_vld;
    logic   [ 8: 0]     sum;

    clocking cb @(posedge clk);
        //  testbench IO
        output  data_in_vld;
        output  addend0;
        output  addend1;

        input   data_out_vld;
        input   sum;
    endclocking

    modport tb_mp (clocking cb);

    modport dut_mp (
        //  DUT IO
        input   clk,
        input   rst_n,

        input   data_in_vld,
        input   addend0,
        input   addend1,

        output  data_out_vld,
        output  sum);
endinterface


