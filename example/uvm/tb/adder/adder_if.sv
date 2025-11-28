//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.4
//  Title           :   test_if
//
//  Description     :   interface definition
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

interface adder_if #(
    parameter   DATA_WIDTH  = 8)
(
    input   logic   clk,
    input   logic   rst_n);

    //  DUT IO port
    logic                       data_in_vld;
    logic   [DATA_WIDTH - 1: 0] addend0;
    logic   [DATA_WIDTH - 1: 0] addend1;

    logic                   data_out_vld;
    logic   [DATA_WIDTH: 0] sum;

    //  clock counter for time stamp
    longint unsigned clk_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            clk_cnt <= 0;
        end
        else begin
            clk_cnt <= clk_cnt + 1;
        end
    end

    //  clocking block
    clocking cb @(posedge clk);
        output  data_in_vld;
        output  addend0;
        output  addend1;

        input   data_out_vld;
        input   sum;

        input   clk_cnt;
    endclocking

    //  driver
    modport drv_mp (
        clocking    cb,
        input       rst_n);

    //  monitor
    modport mon_mp (
        input   clk,
        input   rst_n,

        input   data_in_vld,
        input   addend0,
        input   addend1,

        input   data_out_vld,
        input   sum,

        input   clk_cnt);

    //  DUT
    modport dut_mp (
        input   clk,
        input   rst_n,

        input   data_in_vld,
        input   addend0,
        input   addend1,

        output  data_out_vld,
        output  sum);
endinterface


