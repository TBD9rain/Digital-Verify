//==================================================================================================
//
//  Project         :   Digital Verify Example
//  Version         :   v1.0.0
//  Title           :   test_tb
//
//  Description     :   top testbench
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

`timescale 1ns/1ns

module test_tb;

parameter   CLK_HALF_PERIOD = 10/2;

import msg_log_pkg::*;
import verify_pkg::*;

bit         clk;
bit         rst_n;

test_if tb_if(
    .clk    (clk),
    .rst_n  (rst_n));

testEnv     tb_env;

adder_8bit
u_dut(
    .clk    (tb_if.dut_mp.clk),
    .rst_n  (tb_if.dut_mp.rst_n),

    .data_in_vld    (tb_if.dut_mp.data_in_vld),
    .data_in0       (tb_if.dut_mp.data_in0),
    .data_in1       (tb_if.dut_mp.data_in1),

    .data_out_vld   (tb_if.dut_mp.data_out_vld),
    .data_out       (tb_if.dut_mp.data_out));

initial begin
    forever begin
        #(CLK_HALF_PERIOD);
        clk = ~clk;
    end
end

initial begin
    rst_n = 1'b0;
    #1000;

    rst_n = 1'b1;
end

initial begin
    svrt_thold = LOW;

    clean_msg_log;

    print_msg("Testbench", "Verification starts.\n", INFO, HIGHEST, LOG);

    tb_env      = new;
    tb_env.vif  = tb_if;

    tb_env.connect;

    tb_env.add_random_case(10);

    @tb_env.drive_end;
    print_msg("Testbench", "Verification ends.\n", INFO, HIGHEST, LOG);
    $stop(2);
end

endmodule

